module RAM_controller(
	input clk,
	input reset,
	input byte_cnt,
	input [15:0]address,
	input action, 
	input RW_mode,
	inout [7:0]data_bus,
	input irq_req,
	output error,
	output ready
);
wire [7:0]input_int_bus;
wire [7:0]output_int_bus;


bidirect_bus_buffer #(8)test (
	.read_bus(input_int_bus),
	.write_bus(output_int_bus),
	.inout_bus(data_bus),
	.write_enable(RW_mode)
);

endmodule

module bidirect_bus_buffer(read_bus, write_bus, inout_bus, write_enable);
	parameter BUS_LEN = 8;
	input [BUS_LEN-1:0]write_bus;
	input write_enable;
	output [BUS_LEN-1:0]read_bus;
	inout [BUS_LEN-1:0]inout_bus;
	
	reg [BUS_LEN-1:0]out_internal;
	always@(write_bus or write_enable) begin
		if(write_enable == 1'b1) begin
			out_internal <= write_bus;
		end
		else begin
			out_internal <= 'bZ;
		end
	end
	assign inout_bus = out_internal;
	assign read_bus = inout_bus;
endmodule


module address_converter(addr, row, column);
	input addr;
	output row;
	output column;
	assign row = addr>>4'b1001;
	assign column = addr&9'b111111111;
endmodule


module mode_controller(clk, reset, action, RW_mode,irq_req, mode);
	input clk;
	input reset;
	input action;
	input RW_mode;
	input irq_req;
	output [2:0]mode;
	reg [2:0]mode_int;
	always @(posedge clk or negedge reset) begin
		if(!reset)
			mode_int = 3'b000;  //Init mode
		else begin
			if(irq_req)
				mode_int = 3'b001; // Interrupt request mode                                                                                                                                                                                                                                                                                                                                                        
			else
				if(!action)
					mode_int = 3'b010; // Idle mode
				else
						if(RW_mode)
							mode_int = 3'b011; // Read mode
						else
							mode_int = 3'b100; // Write mode
		end
	end
	assign mode = mode_int;
endmodule