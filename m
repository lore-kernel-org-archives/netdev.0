From: Glenn Maynard <glenn@zewt.org>
Subject: TCP sockets stalling (Ubuntu 2.6.31-14-server, r8169)
Date: Sat, 9 Jan 2010 01:29:19 -0500
Message-ID: <bd36f99e1001082229h6a7d6a22lb51a2c21fd64918d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:50232 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142Ab0AIG3U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jan 2010 01:29:20 -0500
Received: by pwj9 with SMTP id 9so457592pwj.21
        for <netdev@vger.kernel.org>; Fri, 08 Jan 2010 22:29:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This seems similar to
http://www.mail-archive.com/e1000-devel@lists.sourceforge.net/msg02055.html:

Some single-command SSH connections ("ssh server echo sdf") stall
indefinitely.  Everything else seems to work OK: regular SSH sessions
and everything else works fine.

Looking at SSH's debug output (running on port 50) and strace on both sides:

client strace: write(3, "\x0f\xf9\xd4\xc4\x76\xc0"..., 128) = 128
client strace: select(7, [3], [], NULL, NULL
... and the client stops here, waiting to read data from the server.

server strace: strace: read(3, "\x0f\xf9\xd4\xc4\x76\xc0"..., 16384) = 128
setsockopt(3, SOL_TCP, TCP_NODELAY, [1], 4) = 0
setsockopt(3, SOL_IP, IP_TOS, [8], 4)   = 0
...
write(3, "\xd2\xa6\x3c\xe5\x77\x43\xd0"..., 80) = 80
write(3, "\x1c\xd3\xee\x93\x9b\xf8\x73"..., 128) = 128
write(3, "\x0d\x8b\x7c\x40\xce\x91\x74"..., 352) = 352
read(9, "sdf\n", 16384)                 = 4 ("echo sdf")
write(3, "\x7d\xe3\x9a\xc3\x5e\xa8\x26"..., 176) = 176
write(3, "\xfe\xae\x36\xa0\x10\xb7\x3e"..., 64) = 64
select(12, [3 5], [], NULL, NULL

... and then stalls waiting to read data from the client.

Here's tcpdump on the server side.  The client sends its 128 byte
packet above ("\x0f\xf9\xd4..."); ssh sees it immediately, but no ACK
is being sent, so the client starts resending.  The server's sendq at
this point is 800 bytes (the above 5 packets), and it's not sending
any of that, either.

05:58:40.217172 IP (tos 0x0, ttl 64, id 34994, offset 0, flags [DF],
proto TCP (6), length 100) server.50 > client.40664: Flags [P.], seq
2320:2368, ack 2360, win 108, options [nop,nop,TS val 97945154 ecr
572925772], length 48
05:58:40.331444 IP (tos 0x0, ttl 56, id 36049, offset 0, flags [DF],
proto TCP (6), length 180) client.40664 > server.50: Flags [P.], seq
2360:2488, ack 2368, win 190, options [nop,nop,TS val 572925788 ecr
97945154], length 128
05:58:40.683518 IP (tos 0x0, ttl 56, id 36050, offset 0, flags [DF],
proto TCP (6), length 180) client.40664 > server.50: Flags [P.], seq
2360:2488, ack 2368, win 190, options [nop,nop,TS val 572925825 ecr
97945154], length 128
05:58:41.423767 IP (tos 0x0, ttl 56, id 36051, offset 0, flags [DF],
proto TCP (6), length 180) client.40664 > server.50: Flags [P.], seq
2360:2488, ack 2368, win 190, options [nop,nop,TS val 572925899 ecr
97945154], length 128
05:58:42.907976 IP (tos 0x0, ttl 56, id 36052, offset 0, flags [DF],
proto TCP (6), length 180) client.40664 > server.50: Flags [P.], seq
2360:2488, ack 2368, win 190, options [nop,nop,TS val 572926047 ecr
97945154], length 128
05:58:45.864109 IP (tos 0x0, ttl 56, id 36053, offset 0, flags [DF],
proto TCP (6), length 180) client.40664 > server.50: Flags [P.], seq
2360:2488, ack 2368, win 190, options [nop,nop,TS val 572926343 ecr
97945154], length 128

This keeps going for a long time, until the server finally wakes up,
acks the packet and starts sending the queued data (curiously, without
coalescing the packets, which I'd expect should happen even with
TCP_NODELAY set when the packets are delayed for other reasons):

06:02:34.489234 IP (tos 0x8, ttl 64, id 34995, offset 0, flags [DF],
proto TCP (6), length 132) server.50 > client.40664: Flags [P.], seq
2368:2448, ack 2488, win 120, options [nop,nop,TS val 97945173 ecr
572925788], length 80
06:02:34.489239 IP (tos 0x8, ttl 64, id 34996, offset 0, flags [DF],
proto TCP (6), length 180) server.50 > client.40664: Flags [P.], seq
2448:2576, ack 2488, win 120, options [nop,nop,TS val 97945173 ecr
572925788], length 128
06:02:34.491116 IP (tos 0x8, ttl 64, id 34997, offset 0, flags [DF],
proto TCP (6), length 404) server.50 > client.40664: Flags [P.], seq
2576:2928, ack 2488, win 120, options [nop,nop,TS val 97945173 ecr
572925788], length 352
06:02:34.491240 IP (tos 0x8, ttl 64, id 34998, offset 0, flags [DF],
proto TCP (6), length 228) server.50 > client.40664: Flags [P.], seq
2928:3104, ack 2488, win 120, options [nop,nop,TS val 97945176 ecr
572925788], length 176
06:02:34.491362 IP (tos 0x8, ttl 64, id 34999, offset 0, flags [DF],
proto TCP (6), length 116) server.50 > client.40664: Flags [P.], seq
3104:3168, ack 2488, win 120, options [nop,nop,TS val 97945176 ecr
572925788], length 64

at which point the connection wakes back up, spitting out the text and
exiting normally.  (The timestamps on those last few lines are longer
than they should be because I suspended tcpdump to check the socket
buffer.  Running it again, it took 53 seconds before the connection
started moving again, not 4 minutes.)

/proc/net/tcp on the server during this stall (twice a while apart,
not the same repro as above):

2366: server:0032 client:A975 01 00000320:00000000 01:0000013D
00000004     0        0 98188788 3 ffff880057dd1380 656 4 16 5 3
2478: server:0032 client:A975 01 00000320:00000000 01:00000963
00000007     0        0 98188788 3 ffff880057dd1380 5248 4 16 5 3

This is a colocated server, so I'm hesitant to experiment with
patches; I won't be able to recover the machine easily.  No kernel QOS
rules are active.  This is a reasonably active webserver (around 500
active connections, saturated 100mbit) and this doesn't seem to be
causing problems with that at all, or so spuriously nobody's noticing.

I also was seeing bad checksums on the client side on packets from the
server.  It was consistently a checksum problem--the checksum field in
the received packets didn't match what they were when they left the
server.  I ran "ethtool -K eth0 tx off rx off" and I'm not seeing them
anymore.  (This seems like a separate problem, but one thing I noticed
dumping these packets was that the packets with bad checksums always
seemed to end with a lot of 0's.  Possibly coincidence, but that would
explain why it wasn't causing problems with fully established SSH
connections or the webserver; there won't be a lot of packets like
that in plaintext, encrypted SSH traffic or compressed images.)

lspci says: 02:00.0 Ethernet controller: Realtek Semiconductor Co.,
Ltd. RTL8111/8168B PCI Express Gigabit Ethernet controller (rev 03)

-- 
Glenn Maynard
