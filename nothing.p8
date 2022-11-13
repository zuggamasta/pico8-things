pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
-- global variables
n = 0
current_lvl = 0

-- player variables
px = 64
py = 64
dx = 0
dy = 0
max_dx =4
background_x = 0

player_jumping = false
player_falling = false

-- fixed values
player_width = 8
jump_length_init = 6
jump_legnth = 0
ground_level = 96


-- introscreen logo position
logo_x, logo_y = 64,64



-- init() 
function _init()
	poke(0x5f38, 2) -- repeat tline U
	poke(0x5f39, 2) -- repeat tline V

	-- initialize values	
	jump_legnth = jump_length_init

	-- set game state to menu
	_update = menuupdate
	_draw = menudraw	

	
end


function _update() end
function _draw() end


function menuupdate()
	-- animate logo position
	logo_x = 64+sin(time()/4)*10
	logo_y = 64+cos(time()/7)*10
	-- change to game on button press
	if(btn(4) or btn(5)) then
		
		_update = gameupdate
		_draw = gamedraw
	end
end

function menudraw()
	cls(1)

	drawmapnew(1,1,(time()*2)%4,0)
	local moon_x, moon_y = 100,21
	circfill(moon_x,moon_y,12,13)
	circfill(moon_x-3,moon_y,12-2,1)

	-- print("MADE FOR agbic22",32,8,7)
	print("COVER ART BY jasper oprel",14,120,7)


	draw_nothing(logo_x,logo_y)
	print_fat("press start",64-20,85,7)
    
end

-- draw rectangle with X, Y, width, height, color
function draw_rect(cx,cy,w,h,c)
	local x1,y1,x2,y2 =
		cx-w/2,
		cy-h/2,
		cx+w/2,
		cy+h/2
	rectfill(x1,y1,x2,y2, c)

end

-- print outlines with text, X, Y, color, background color
function print_fat(text,x,y,color,colorbg)
	print(text,x-1,y,colorbg)
	print(text,x+1,y,colorbg)
	print(text,x,y-1,colorbg)
	print(text,x,y+1,colorbg)
	print(text,x,y,color)

end

-- draw nothing logo
function draw_nothing(nx,ny)
	--local nx,ny = 64, 64
	local logowidth = 26
	local logoheight = 10
	circfill(nx-logowidth/2,ny,7,0)
	circfill(nx+logowidth/2,ny,7,0)

	rectfill(nx-logowidth/2,ny-7,nx+logowidth/2,ny+7,0)

	circfill(nx-logowidth/2,ny,5,7)
	circfill(nx+logowidth/2,ny,5,7)

	rectfill(nx-logowidth/2,ny-5,nx+logowidth/2,ny+5,7)

	palt(0,false)
	spr(13,nx-11,ny-3,3,1)
	palt(0,true)
end


function gameupdate()
	n+=1
	playerUpdate()
	if(btnp(5)) then
		current_lvl += 1
		if(current_lvl> 4) then
			current_lvl = 0
		end
	end
end

function playerUpdate()

	if (btnp(2) and (not player_jumping) and (not player_falling)) then
		player_jumping = true
	end

	if(not player_jumping and py < ground_level) then
		player_falling = true
	end

	if(player_falling) then
		dy +=1 
	end

	if(player_jumping) then 
		dy -= 1
		jump_legnth -= 1
	end

	if(jump_legnth <= 0) then
		player_jumping = false
		jump_legnth = jump_length_init
	end
	
	if(py >= ground_level and not player_jumping) then
		player_falling = false
		dy = 0
		py = ground_level
	end

	py +=dy
	
	if (py > ground_level) then py = ground_level end


	if(btn(1)) then
		dx+=1
		background_x -= 1/5
	end

	if(btn(0)) then
		dx-=1
		background_x += 1/5
	end

	if(dx >= max_dx ) then dx = max_dx end
	if(dx <= -max_dx) then dx = -max_dx end

	if(not player_jumping) then 
		dx = dx/1.33
	end

	px += dx

	if(px >= 128 ) then 
		px = 128 
		dx = 0
	end

	if(px <= 0 ) then 
		px = 0 
		dx = 0
	end

end



function gamedraw()

	if(current_lvl == 0) then
		pal()
		cls(7)

	end
	if(current_lvl == 1) then
		pal(3,5)
		pal(4,5)
		pal(9,4)
		pal(5,13)
		pal(11,3)
		pal(12,1)
		cls(2)
	end
	if(current_lvl == 2) then
		pal(5,13)
		pal(9,2)
	end
	if(current_lvl == 3) then
		pal()
		pal(5,9)
		cls(15)

	end

	rectfill(0,0,128,64,12)
	-- sun
	if(current_lvl == 1) then
		circfill(64,64,40,2)
		circfill(64,64,30,14)
		rectfill(0,65,128,128,2)

	end

	if(current_lvl == 3) then
		circfill(64,64,32,10)
		rectfill(0,65,128,128,15)

	end

	
	myang = -0.02

	draw_horizont(current_lvl)
	
	drawmapnew( dx/20,1,(time()*2)%4,myang)

	--draw_sprite(32,1,(time()*2),myang)
	pal(9,9)
	draw_player()
	
	print(current_lvl,1,1,5)
end

function draw_horizont(level)
	if(level  == 0 ) then
		spr(64,0+background_x,49,16,2)
	end

	if(level  == 1 ) then
		spr(64,0+background_x,49,16,2)
	end

	if(level == 2 ) then
		spr(64+32,0+background_x,49,16,2)
	end

	if(level == 3 ) then
		spr(64+64,0+background_x,49,16,2)
	end
end

function draw_sprite(cx,cy,cz,angle)
	local a= angle
	local ca,sa= cos(a),-sin(a)
	ye = cz+n
		--coords in world space
		local rz=(cy*64)/(ye-64)
		-- ground height
		local rx=rz*(0-64)/64
		local x,z =
		ca*rx+sa*rz+cx,
		-sa*rx+ca*rz+cz
		-- tline(0,ye,256,ye,
		-- u and v coordinates
		-- x,z,
		-- delta u and delta v coordinates
		-- ca*rz/64,-sa*rz/64)
		spr(57,64-x,64-z) 
end


--draw world
function drawmapnew(cx,cy,cz,angle)
	
	local a= angle
	local ca,sa= cos(a),-sin(a)
	for ye=65,127 do
		--coords in world space
		local rz=(cy*64)/(ye-64)
		-- ground height
		local rx=rz*(0-64)/64
		local x,z =
		ca*rx+sa*rz+cx,
		-sa*rx+ca*rz+cz
		tline(0,ye,256,ye,
		-- u and v coordinates
		x,z,
		-- delta u and delta v coordinates
		ca*rz/64,-sa*rz/64)
	end
end

--draw player
function draw_player()

	-- render floor shadow
	if(py>92) then
		spr(7,px-player_width,106,2,1,true)
	else
		spr(23,px-player_width,107,2,1,true)
	end

	-- render tail
	spr(flr((n/10)%2)+9,px+1,py+2,1,1,false)

	-- render ears
	spr(flr((n/20)%2)+11,px-5,py-1,1,1,false)

	-- contour
	if(flr((n/6)%2)>0) then
		--draw 2x2 sprite block
		spr(
			flr((n/3)%2)*2+36
			,px-player_width+1,py+1,2,2,false)	
	else
		--draw 2x2 sprite block mirrored
		spr(
			flr((n/3)%2)*2+36
			,px-player_width+1,py+1,2,2,true)
	end

	--flip sprite every x frames
	if(flr((n/6)%2)>0) then
		--draw 2x2 sprite block
		spr(
			flr((n/3)%2)*2
			,px-player_width,py,2,2,false)	
	else
		--draw 2x2 sprite block mirrored
		spr(
			flr((n/3)%2)*2
			,px-player_width,py,2,2,true)
	end

	
end


function unused()
	draw_rect(64,64,102,58,10)
	draw_rect(64,74,82,50,10)

	draw_rect(64,64,100,56,9)
	draw_rect(64,74,80,48,9)

	draw_rect(64,64,82,44,10)
	draw_rect(64,64,80,42,12)
	draw_rect(64+30,64,20,42,6)


	spr(2,86,66,2,2,true)
	spr(64,32,54,5,2)
end



__gfx__
00000000000000000000001111000000999999993333333355555555000000000000000000000000000000000000000000001001777777777777777777777777
000001111000000000000199991000009ffff9993bbbb33355555555000000000000000000011000000000000000100100011011077077770707770777777770
000019999100000000001999999100009fff99f93bbb33b355555555000000000000000000111100000011000001101100011111007077700007777770777007
000199999910000000019991199910009ff99ff93bb33bb355555555000005555550000000111100000111100001111100011111070070070700770707070707
001999119991000000019910019910009f99fff93b33bbb355555555005555555555550001111000001111100001111100000000077007700707070707070707
00199100199100000001991000110000999ffff9333bbbb355555555055555555555555011111000011111000000000000000000077070070707070707077007
0001100019910000000199910000000099fffff933bbbbb355555555005555555555550011110000111110000000000000000000777777777777777777770707
00000001999100000000199910000000999999993333333355555555000005555550000011000000111000000000000000000000777777777777777777777077
00000019991000000000019991000000111111112222222200000000000000000000000000000000000000000000000000000000000000000000000000000000
000001999100000000000199910000001cccc1112888822200000000000000000000000000000000000000000000000000000000000000000000000000000000
000001999100000000000011100000001ccc11c12888228200000000000000000000000000000000000000000000000000000000000000000000000000000000
000000111000000000000000000000001cc11cc12882288200000000000000000000000000000000000000000000000000000000000000000000000000000000
000000111000000000000011100000001c11ccc12822888200000000000055555555000000000000000000000000000000000000000000000000000000000000
00000199910000000000019991000000111cccc12228888200000000005555555555550000000000000000000000000000000000000000000000000000000000
0000019991000000000001999100000011ccccc12288888200000000000055555555000000000000000000000000000000000000000000000000000000000000
00000011100000000000001110000000111111112222222200000000000000000000000000000000000000000000000000000000000000000000000000000000
00000033330000000000003333000000000000000000000000000011110000000000000000000000000000000000000000000000000000000000000000000000
00000333333000000000033333300000000001111000000000000111111000000000000000000000000000000000000000000000000000000000000000000000
00000333333000000000033333300000000011111100000000001111111100000000000000000000000000000000000000000000000000000000000000000000
00000333333000000000033333300000000111111110000000011111111110000000000000000000000000000000000000000000000000000000000000000000
0000003bb30bb0000000003bb3000000001111111111000000011110011110000000000000000000000000000000000000000000000000000000000000000000
0000b3bbbb3bb0000000b3bbbb3b0000001111001111000000011110001100000000000000000000000000333300000000000000000000000000000000000000
000bb3bbbb3b0000000bb3bbbb3bb000000110001111000000011111000000000000000000000000000033bbbb33000000000000000000000000000000000000
00bb003330000000000f0033300f00000000000111110000000011111000000000000000000000000003b7bbbb7b300000000000000000000000000000000000
0fb00bbbbbb0000000000bbbbbb000000000001111100000000001111100000000000000003333000003711bb117300000000000000000000000000000000000
00000bbbbbb0000000000bbbbbbb0000000001111100000000000111110000000000000003bbbb30003b711bb117b30000000000000000000000000000000000
0000bbb0bbb000000000bbb00bbb00000000011111000000000000111000000000000000371bb173003b777bb777b30000000000000000000000000000000000
0000bbb0bbb000000000bbb0003000000000001110000000000000000000000000000000377bb773003bb7bbbb7bb30000000000000000000000000000000000
00000330b3300000000003300033000000000011100000000000001110000000003333003bbbbbb30003bbbbbbbb300000000000000000000000000000000000
000033300bb00000000003300000000000000111110000000000011111000000037bb7303bbbbbb30003bbbbbbbb300000000000000000000000000000000000
000033000000000000003300000000000000011111000000000001111100000003bbbb3003bbbb30000033bbbb33000000000000000000000000000000000000
00000000000000000000000000000000000000111000000000000011100000000033330000333300000000333300000000000000000000000000000000000000
00000000000000000000444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044444000000
00000000000000000004f99400000000000000000000000000333300000000000000000000000000000000000000000000000000000000000000499999444000
00000000000000000004999400000000000000000000000003bbbb30000000000000000000000000000000000000000000000000000000000000499999999400
0000000000000000004999940000000000000000000000033bbbbbb3000000000000000000000000000000000000000000000000000000000000499999999940
00000000000000000049999940000000000000000000003bbbbbbbbb30000000000000000000000000000000000000000000000000000000000044444f449940
000000000000000004f999994000003303000000000003bbbbbbbbb3b30000000000000000000000000000000000000000000000000000000004999999999400
000000000004400049999449400003bb3b30000000003bb1bbbbbbb3b30000000000000000000000000000000000000000000000000000000004999999999440
000000000049940049444999400003bbbbb3000000003bb1bbbbbbbbbb3000333300000000000000000000000000000000000000000000000000499994449940
000000000499994499999999940003bbbbb300000003bbbbbbbb3bbbbbb033bb1b33000000000000000000000000000000000000000000000000499499999400
000000044999999944999999994003bbbbb300000003bbbbbbbb1bbbbbb3bbbbbbbb300000000000000000000000033300000000000000000000499999994000
00004449999999999949999999403bbbbbb30000003bbbbbbbbbbbbbbbb3b1bbbbbb3000000000000000000000003bbb3000000000000000000f999999940000
00049999999999999994499999403bbbbbb30000003bbbbbb3bbbbbbbbbbb3bbbbb3b30000000000000000000003bbbb33330000000000000049999999940000
00499933339994449999949999403bbbbb30000003bb3bbbb1bbbbbbbbbbbbbbbbb1b30000000000000000000003bbb3bbbb3000000000000049944999994000
049443bbbb399999999999f9999403bbbb30044003bb3bbbbbbbbbbb1bbbbbbbbbbbbb300000000000000000003bbb3bbbbbb300000000000049999999999400
499993bbbbb3999999999f944494003bb300499403bbbbbbbbbbbbbb3bbbbbbbb3bbbb300000000000000000003bbbbbbbbbb300000000000004999994499400
499993bbbbb39999999999999999403bb304999403bbbb3bbbbbbbbbbbbbbbbbb1bbbb300000000000000000003bbbbbbbbbbb300000000000004999999f9400
00000000000000000000000000000000000000007770000000000000000000000000000000000000000000007776000000000000000000000000000077700000
00000000000000000000000000000000000000077777000000000000000000000000000000000000000000777777600000000000000000000000006777770000
00000000000000000000000000000000000000077776000000000000000000000000000000000000000000777777760000000000000000000000677777776000
00000000000000000000000000000000000000777677600000000000000000000000000000000000000000777777766000000000000000000066776777776000
00000000000000000000000000000000000000776555500000000000000000000000000000000000000000667777655000000000000000000665555677600000
00000000000000000000000000000000000006766555550000000000000000000000000000000000000000566667655000000000000000000555555667600000
00000000000000000000000000000000000007655555550000000000000000000000000000000000000000555666655500000000000000005555555556700000
00000000000000000000000000000000000007655555555000000000000000000000000000000000000000655555555500000000000000055555555556700000
00000000000000000000000000000000000006555555555000000000000000000000000000000000000000555555555550000000000000555555555555600000
00000000000555500000000000000000000055555575555500000000000000000000000000000000000000555555555555000000000055555555577755550000
00000000555555557000000000000000000555577777775500000000000000000000000000000000000005555555555555550000000555555577777775555000
00000555555555555555000000000000000555576656667550000000000000000000000000000000000005555555555555555500555555555766656677555000
00055555555576655555555500000000005555655555565655000000000000000000000000000000000055555555555555555555555555556565555556555500
00566555555555565555655555500000005555555555555555550000000000000000000000000000000555555555555555555555555555555555555555555500
00555555555555555555555555555500055555555555555555555500000000000000005555555500055555555555555555555555555555555555555555555550
05555555555555555555555555555550555555555555555555555550055555555555555555555555555555555555555555555555555555555555555555555555
bbbb0000033330000000000000000000000000000e0000060000000000000000000000000000333000000000000000000000000000000000000333300000bbbb
0b3330303333333000000000000000000000000000e000e6000000000000000000000000003333330303300000000000000000000000000003333333030333b0
00333333bb3033330000000000000000000000000eeeeee6000000000000000000000000033303bb3bbb3300000000000000000000000000333303bb33333300
0333333bbbb0003300000000000000000000000000eeeee600000000000000000000000003000bb33bbbb33000000000000000000000000033000bbbb3333330
0333003bbbbb0000000000000000000000000000000eee060000000000000000000000000000b33333b03b330000000000000000000000000000bbbbb3003330
03000004b4bbb000000000000000000000000000000000060000000000000000000bbb00000b334440000033000000000000000000000000000bbb4b40000030
00000004440bb00000000000000000000000000000000006000000000000000003bbb3330003004440000000000000000000000000000000000bb04440000000
000000044400000000000000000000000000000000000006000000000000000333bb333b00000044000000000000000000000000000000000000004440000000
00000000444000000000000000000000000000000000000600000000000000033bb4000000000444000000000000000000000000000000000000044400000000
00000000444000000000000000000000000000000000000600000000000000333bb4900000000444000000000000000000000000000000000000044400000000
00000000049900000000000000000000000000000000000600000000000000330b04400000009940000000000000000000000f0f000f0f000000994000000000
000000000444000000000000000000000000000000000006000000000000000000044900000044400000000000000000000009f90009f9000000444000000000
00000000044400000000000000000000000000000000000600000000000000000000440000004440000000000000000000000f4f9f9f9f000000444000000000
00000000044940000000000000000000000000000000000600000000000000000000440000049440000000000000000000000949f4f9f9000004944000000000
00000000044440000000000000000000000000000000000600000000000000000000444000044400000000000000000000000f9f444f9f000004444000000000
000000004444490000000000000000000000000000000096000000000000000000094440009444900000000000000000000009f94449f9000004444000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000666666666666666666666666
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066066660606660666666660
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006066600006666660666006
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000060060060600660606060606
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066006600606060606060606
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066060060606060606066006
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000666666666666666666660606
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000666666666666666666666066
__map__
0600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
