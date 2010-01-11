From: Peter Rabbitson <rabbit+list@rabbit.us>
Subject: Reproducible corruption with SG offloading
Date: Mon, 11 Jan 2010 13:22:51 +0100
Message-ID: <4B4B181B.3020208@rabbit.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, mchan@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arx.rabbit.us ([76.244.88.238]:42722 "EHLO arx.rabbit.us"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753351Ab0AKM2Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jan 2010 07:28:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have the following card:

02:02.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5701 Gigabit Ethernet (rev 15)
	Subsystem: Compaq Computer Corporation NC7770 Gigabit Server Adapter (PCI-X, 10/100/1000-T)
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64 (16000ns min), Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 24
	Region 0: Memory at fc5e0000 (64-bit, non-prefetchable) [size=64K]
	[virtual] Expansion ROM at fc5d0000 [disabled] [size=64K]
	Capabilities: [40] PCI-X non-bridge device
		Command: DPERE- ERO- RBC=512 OST=1
		Status: Dev=02:02.1 64bit+ 133MHz+ SCD- USC- DC=simple DMMRBC=512 DMOST=1 DMCRS=8 RSCEM- 266MHz- 533MHz-
	Capabilities: [48] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold+)
		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [50] Vital Product Data
		Product Name: HP NC7770 Gigabit Server Adapter
		Read-only fields:
			[PN] Part number: 284685-003
			[EC] Engineering changes: 0G
			[SN] Serial number: WEURE9FB68
			[MN] Manufacture ID: 30 45 31 31
			[RV] Reserved: checksum bad, 47 byte(s) reserved
		Read/write fields:
			[YA] Asset tag: Hewlett Packard
			[RW] Read-write area: 103 byte(s) free
		End
	Capabilities: [58] MSI: Enable- Count=1/8 Maskable- 64bit+
		Address: 00312230088fb704  Data: 0000
	Kernel driver in use: tg3

When confronted with very specific repeatable data streams the card eventually
starts setting garbage down the wire. If I do ethtool -k <ifname> sg off the
problem disappears. Let me know if ou are interested in tracking this down,
(whether software or hardware) otherwise I'll throw the card away and go with
something else.

Please CC me as I am not subscribed to netdev@

This is my minimal test case with relevant data:

Program
============

#!/usr/bin/perl
use warnings;
use strict;

use DBI;
my $dbh = DBI->connect ('dbi:mysql:database=tst;host=192.168.5.2', 'stress', 123, { RaiseError => 1});

for (1 .. 92) {
  $dbh->selectall_arrayref(q|SELECT `alias` FROM dbmail_aliases WHERE `alias` like "spam@example.com"|);
}

tcpdump at the machine with the card in question
======================================

00000000  d4 c3 b2 a1 02 00 04 00  00 00 00 00 00 00 00 00  |................|
00000010  ff ff 00 00 01 00 00 00  7d 16 4b 4b b2 1a 06 00  |........}.KK....|
00000020  4a 00 00 00 4a 00 00 00  00 30 48 67 c2 1c 00 11  |J...J....0Hg....|
00000030  0a e9 fb 68 08 00 45 00  00 3c e9 c3 40 00 40 06  |...h..E..<..@.@.|
00000040  c5 a4 c0 a8 05 01 c0 a8  05 02 95 30 0c ea 31 99  |...........0..1.|
00000050  f8 84 00 00 00 00 a0 02  16 d0 c5 ed 00 00 02 04  |................|
00000060  05 b4 04 02 08 0a 02 70  11 47 00 00 00 00 01 03  |.......p.G......|
00000070  03 06 7d 16 4b 4b 5c 1b  06 00 4a 00 00 00 4a 00  |..}.KK\...J...J.|
00000080  00 00 00 11 0a e9 fb 68  00 30 48 67 c2 1c 08 00  |.......h.0Hg....|
00000090  45 00 00 3c 00 00 40 00  40 06 af 68 c0 a8 05 02  |E..<..@.@..h....|
000000a0  c0 a8 05 01 0c ea 95 30  c8 89 90 8c 31 99 f8 85  |.......0....1...|
000000b0  a0 12 16 a0 f4 28 00 00  02 04 05 b4 04 02 08 0a  |.....(..........|
000000c0  06 8b 72 41 02 70 11 47  01 03 03 07 7d 16 4b 4b  |..rA.p.G....}.KK|
000000d0  80 1b 06 00 42 00 00 00  42 00 00 00 00 30 48 67  |....B...B....0Hg|
000000e0  c2 1c 00 11 0a e9 fb 68  08 00 45 00 00 34 e9 c4  |.......h..E..4..|
000000f0  40 00 40 06 c5 ab c0 a8  05 01 c0 a8 05 02 95 30  |@.@............0|
00000100  0c ea 31 99 f8 85 c8 89  90 8d 80 10 00 5c 39 39  |..1..........\99|
00000110  00 00 01 01 08 0a 02 70  11 47 06 8b 72 41 7d 16  |.......p.G..rA}.|
00000120  4b 4b ad 1c 06 00 80 00  00 00 80 00 00 00 00 11  |KK..............|
00000130  0a e9 fb 68 00 30 48 67  c2 1c 08 00 45 08 00 72  |...h.0Hg....E..r|
00000140  e2 cc 40 00 40 06 cc 5d  c0 a8 05 02 c0 a8 05 01  |..@.@..]........|
00000150  0c ea 95 30 c8 89 90 8d  31 99 f8 85 80 18 00 2e  |...0....1.......|
00000160  79 db 00 00 01 01 08 0a  06 8b 72 41 02 70 11 47  |y.........rA.p.G|
00000170  3a 00 00 00 0a 35 2e 31  2e 34 31 2d 33 2d 6c 6f  |:....5.1.41-3-lo|
00000180  67 00 80 00 00 00 5d 2d  66 3a 2e 75 29 66 00 ff  |g.....]-f:.u)f..|
00000190  f7 21 02 00 00 00 00 00  00 00 00 00 00 00 00 00  |.!..............|
000001a0  00 48 72 2a 74 2e 24 69  67 48 72 29 6d 00 7d 16  |.Hr*t.$igHr)m.}.|
000001b0  4b 4b db 1c 06 00 42 00  00 00 42 00 00 00 00 30  |KK....B...B....0|
000001c0  48 67 c2 1c 00 11 0a e9  fb 68 08 00 45 08 00 34  |Hg.......h..E..4|
000001d0  e9 c5 40 00 40 06 c5 a2  c0 a8 05 01 c0 a8 05 02  |..@.@...........|
000001e0  95 30 0c ea 31 99 f8 85  c8 89 90 cb 80 10 00 5c  |.0..1..........\|
000001f0  38 fb 00 00 01 01 08 0a  02 70 11 47 06 8b 72 41  |8........p.G..rA|
00000200  7d 16 4b 4b 3d 30 06 00  86 00 00 00 86 00 00 00  |}.KK=0..........|
00000210  00 30 48 67 c2 1c 00 11  0a e9 fb 68 08 00 45 08  |.0Hg.......h..E.|
00000220  00 78 e9 c6 40 00 40 06  c5 5d c0 a8 05 01 c0 a8  |.x..@.@..]......|
00000230  05 02 95 30 0c ea 31 99  f8 85 c8 89 90 cb 80 18  |...0..1.........|
00000240  00 5c 8b be 00 00 01 01  08 0a 02 70 11 48 06 8b  |.\.........p.H..|
00000250  72 41 40 00 00 01 8f a2  02 00 00 00 00 40 08 00  |rA@..........@..|
00000260  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00000270  00 00 00 00 00 00 73 74  72 65 73 73 00 14 5d 16  |......stress..].|
00000280  8c 5d 41 ff 26 31 fc 5a  db fa 42 27 4a a1 6b 16  |.]A.&1.Z..B'J.k.|
00000290  1a 28 74 73 74 00 7d 16  4b 4b b8 30 06 00 42 00  |.(tst.}.KK.0..B.|
000002a0  00 00 42 00 00 00 00 11  0a e9 fb 68 00 30 48 67  |..B........h.0Hg|
000002b0  c2 1c 08 00 45 08 00 34  e2 cd 40 00 40 06 cc 9a  |....E..4..@.@...|
000002c0  c0 a8 05 02 c0 a8 05 01  0c ea 95 30 c8 89 90 cb  |...........0....|
000002d0  31 99 f8 c9 80 10 00 2e  38 e2 00 00 01 01 08 0a  |1.......8.......|
000002e0  06 8b 72 43 02 70 11 48  7d 16 4b 4b f5 30 06 00  |..rC.p.H}.KK.0..|
000002f0  4d 00 00 00 4d 00 00 00  00 11 0a e9 fb 68 00 30  |M...M........h.0|
00000300  48 67 c2 1c 08 00 45 08  00 3f e2 ce 40 00 40 06  |Hg....E..?..@.@.|
00000310  cc 8e c0 a8 05 02 c0 a8  05 01 0c ea 95 30 c8 89  |.............0..|
00000320  90 cb 31 99 f8 c9 80 18  00 2e 31 cb 00 00 01 01  |..1.......1.....|
00000330  08 0a 06 8b 72 43 02 70  11 48 07 00 00 02 00 00  |....rC.p.H......|
00000340  00 02 00 00 00 7d 16 4b  4b b9 31 06 00 57 00 00  |.....}.KK.1..W..|
00000350  00 57 00 00 00 00 30 48  67 c2 1c 00 11 0a e9 fb  |.W....0Hg.......|
00000360  68 08 00 45 08 00 49 e9  c7 40 00 40 06 c5 8b c0  |h..E..I..@.@....|
00000370  a8 05 01 c0 a8 05 02 95  30 0c ea 31 99 f8 c9 c8  |........0..1....|
00000380  89 90 d6 80 18 00 5c 8b  8f 00 00 01 01 08 0a 02  |......\.........|
00000390  70 11 49 06 8b 72 43 11  00 00 00 03 73 65 74 20  |p.I..rC.....set |
000003a0  61 75 74 6f 63 6f 6d 6d  69 74 3d 31 7d 16 4b 4b  |autocommit=1}.KK|
000003b0  a1 32 06 00 4d 00 00 00  4d 00 00 00 00 11 0a e9  |.2..M...M.......|
000003c0  fb 68 00 30 48 67 c2 1c  08 00 45 08 00 3f e2 cf  |.h.0Hg....E..?..|
000003d0  40 00 40 06 cc 8d c0 a8  05 02 c0 a8 05 01 0c ea  |@.@.............|
000003e0  95 30 c8 89 90 d6 31 99  f8 de 80 18 00 2e 31 ab  |.0....1.......1.|
000003f0  00 00 01 01 08 0a 06 8b  72 43 02 70 11 49 07 00  |........rC.p.I..|
00000400  00 01 00 00 00 02 00 00  00 7d 16 4b 4b 88 33 06  |.........}.KK.3.|
00000410  00 8f 00 00 00 8f 00 00  00 00 30 48 67 c2 1c 00  |..........0Hg...|
00000420  11 0a e9 fb 68 08 00 45  08 00 81 e9 c8 40 00 40  |....h..E.....@.@|
00000430  06 c5 52 c0 a8 05 01 c0  a8 05 02 95 30 0c ea 31  |..R.........0..1|
00000440  99 f8 de c8 89 90 e1 80  18 00 5c 8b c7 00 00 01  |..........\.....|
00000450  01 08 0a 02 70 11 49 06  8b 72 43 49 00 00 00 03  |....p.I..rCI....|
00000460  53 45 4c 45 43 54 20 60  61 6c 69 61 73 60 20 46  |SELECT `alias` F|
00000470  52 4f 4d 20 64 62 6d 61  69 6c 5f 61 6c 69 61 73  |ROM dbmail_alias|
00000480  65 73 20 57 48 45 52 45  20 60 61 6c 69 61 73 60  |es WHERE `alias`|
00000490  20 6c 69 6b 65 20 22 73  70 61 6d 40 65 78 61 6d  | like "spam@exam|
000004a0  70 6c 65 2e 63 6f 6d 22  7d 16 4b 4b 3c 34 06 00  |ple.com"}.KK<4..|
000004b0  9c 00 00 00 9c 00 00 00  00 11 0a e9 fb 68 00 30  |.............h.0|
000004c0  48 67 c2 1c 08 00 45 08  00 8e e2 d0 40 00 40 06  |Hg....E.....@.@.|
000004d0  cc 3d c0 a8 05 02 c0 a8  05 01 0c ea 95 30 c8 89  |.=...........0..|
000004e0  90 e1 31 99 f9 2b 80 18  00 2e b4 4c 00 00 01 01  |..1..+.....L....|
000004f0  08 0a 06 8b 72 43 02 70  11 49 01 00 00 01 01 3f  |....rC.p.I.....?|
00000500  00 00 02 03 64 65 66 03  74 73 74 0e 64 62 6d 61  |....def.tst.dbma|
00000510  69 6c 5f 61 6c 69 61 73  65 73 0e 64 62 6d 61 69  |il_aliases.dbmai|
00000520  6c 5f 61 6c 69 61 73 65  73 05 61 6c 69 61 73 05  |l_aliases.alias.|
00000530  61 6c 69 61 73 0c 08 00  64 00 00 00 fd 00 00 00  |alias...d.......|
00000540  00 00 05 00 00 03 fe 00  00 22 00 05 00 00 04 fe  |........."......|
00000550  00 00 22 00 7d 16 4b 4b  e0 34 06 00 8f 00 00 00  |..".}.KK.4......|
00000560  8f 00 00 00 00 30 48 67  c2 1c 00 11 0a e9 fb 68  |.....0Hg.......h|
00000570  08 00 45 08 00 81 e9 c9  40 00 40 06 c5 51 c0 a8  |..E.....@.@..Q..|
00000580  05 01 c0 a8 05 02 95 30  0c ea 31 99 f9 2b c8 89  |.......0..1..+..|
00000590  91 3b 80 18 00 5c 8b c7  00 00 01 01 08 0a 02 70  |.;...\.........p|
000005a0  11 49 06 8b 72 43 49 00  00 00 03 53 45 4c 45 43  |.I..rCI....SELEC|
000005b0  54 20 60 61 6c 69 61 73  60 20 46 52 4f 4d 20 64  |T `alias` FROM d|
000005c0  62 6d 61 69 6c 5f 61 6c  69 61 73 65 73 20 57 48  |bmail_aliases WH|
000005d0  45 52 45 20 60 61 6c 69  61 73 60 20 6c 69 6b 65  |ERE `alias` like|
000005e0  20 22 73 70 61 6d 40 65  78 61 6d 70 6c 65 2e 63  | "spam@example.c|
000005f0  6f 6d 22 7d 16 4b 4b 70  35 06 00 9c 00 00 00 9c  |om"}.KKp5.......|
......
the select statement/response repeated verbatim 90+ times
......
00007a00  06 8b 72 49 49 00 00 00  03 53 45 4c 45 43 54 20  |..rII....SELECT |
00007a10  60 61 6c 69 61 73 60 20  46 52 4f 4d 20 64 62 6d  |`alias` FROM dbm|
00007a20  61 69 6c 5f 61 6c 69 61  73 65 73 20 57 48 45 52  |ail_aliases WHER|
00007a30  45 20 60 61 6c 69 61 73  60 20 6c 69 6b 65 20 22  |E `alias` like "|
00007a40  73 70 61 6d 40 65 78 61  6d 70 6c 65 2e 63 6f 6d  |spam@example.com|
00007a50  22 7d 16 4b 4b d2 98 06  00 f3 00 00 00 f3 00 00  |"}.KK...........|
00007a60  00 00 11 0a e9 fb 68 00  30 48 67 c2 1c 08 00 45  |......h.0Hg....E|
00007a70  08 00 e5 e3 2b 40 00 40  06 cb 8b c0 a8 05 02 c0  |....+@.@........|
00007a80  a8 05 01 0c ea 95 30 c8  89 b0 df 31 9a 14 8a 80  |......0....1....|
00007a90  18 00 2e 43 e0 00 00 01  01 08 0a 06 8b 72 49 02  |...C.........rI.|
....
followed by the server error message

What the other side actually sees (note byte 7a50)
======================
...
00007a00  06 8b 72 49 49 00 00 00  03 53 45 4c 45 43 54 20  |..rII....SELECT |
00007a10  60 61 6c 69 61 73 60 20  46 52 4f 4d 20 64 62 6d  |`alias` FROM dbm|
00007a20  61 69 6c 5f 61 6c 69 61  73 65 73 20 57 48 45 52  |ail_aliases WHER|
00007a30  45 20 60 61 6c 69 61 73  60 20 6c 69 6b 65 20 22  |E `alias` like "|
00007a40  73 70 61 6d 40 65 78 61  6d 70 6c 65 2e 63 6f 6d  |spam@example.com|
00007a50  6d 7d 16 4b 4b 3d 66 06  00 f3 00 00 00 f3 00 00  |m}.KK=f.........|
00007a60  00 00 11 0a e9 fb 68 00  30 48 67 c2 1c 08 00 45  |......h.0Hg....E|
00007a70  08 00 e5 e3 2b 40 00 40  06 cb 8b c0 a8 05 02 c0  |....+@.@........|
00007a80  a8 05 01 0c ea 95 30 c8  89 b0 df 31 9a 14 8a 80  |......0....1....|
00007a90  18 00 2e 8c 2b 00 00 01  01 08 0a 06 8b 72 49 02  |....+........rI.|


