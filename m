From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: NFS/TCP/IPv6 acting strangely in 4.2
Date: Fri, 11 Sep 2015 12:38:39 +0100
Message-ID: <20150911113839.GO21084@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arm-kernel@lists.infradead.org
To: Trond Myklebust <trond.myklebust@primarydata.com>,
	Anna Schumaker <anna.schumaker@netapp.com>,
	linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:40656 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751352AbbIKLiu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2015 07:38:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have a recent Marvell Armada 388 board here which uses the mvneta
driver.  I'm seeing some weird effects with NFS with it acting as a
client.  Unfortunately, the board does not have a functional RTC.

The NFS server is the same NFS server that I've used for years with
multiple other clients (it's my main NFS server) and it continues to
support all other clients without any ill effect.  The NFS server
kernel is rather old now, being a 3.x kernel.

The NFS client appears to connect using TCP/IPv6 and initially is
accessible.  Everything appears to work normally, and then the NFS
server appears to stop responding.

Running tcpdump on the NFS server, and then dumping the captured packet=
s
with tshark (because tcpdump appears not to understand IPv6 SYNs on the
NFS port) shows:

  1   0.000000 fe80::250:43ff:fe02:201 -> fe80::214:fdff:fe10:4f86 ICMP=
v6 Neighbor Solicitation for fe80::214:fdff:fe10:4f86 from 00:50:43:02:=
02:01
  2   0.000252 fe80::214:fdff:fe10:4f86 -> fe80::250:43ff:fe02:201 ICMP=
v6 Neighbor Advertisement fe80::214:fdff:fe10:4f86 (sol)
  3   0.030036 armada388 -> n2100 TCP 843=E2=86=92nfs [SYN] Seq=3D93680=
3106 Win=3D28800 Len=3D0 MSS=3D1440 SACK_PERM=3D1 TSval=3D892366 TSecr=3D=
0 WS=3D128
  4   0.030409 n2100 -> armada388 TCP nfs=E2=86=92843 [SYN, ACK] Seq=3D=
409465870 Ack=3D936803107 Win=3D28560 Len=3D0 MSS=3D1440 SACK_PERM=3D1 =
TSval=3D818169117 TSecr=3D892366 WS=3D64
  5   0.030493 armada388 -> n2100 TCP [TCP Port numbers reused] 843=E2=86=
=92nfs [SYN] Seq=3D936803633 Win=3D28800 Len=3D0 MSS=3D1440 SACK_PERM=3D=
1 TSval=3D892366 TSecr=3D0 WS=3D128
  6   0.030699 n2100 -> armada388 TCP nfs=E2=86=92843 [RST, ACK] Seq=3D=
0 Ack=3D936803634 Win=3D0 Len=3D0
  7   0.030766 armada388 -> n2100 TCP 843=E2=86=92nfs [RST] Seq=3D93680=
3107 Win=3D0 Len=3D0
  8   3.040150 armada388 -> n2100 TCP [TCP Port numbers reused] 843=E2=86=
=92nfs [SYN] Seq=3D983834371 Win=3D28800 Len=3D0 MSS=3D1440 SACK_PERM=3D=
1 TSval=3D892667 TSecr=3D0 WS=3D128
  9   3.040467 n2100 -> armada388 TCP nfs=E2=86=92843 [SYN, ACK] Seq=3D=
456498252 Ack=3D983834372 Win=3D28560 Len=3D0 MSS=3D1440 SACK_PERM=3D1 =
TSval=3D818169418 TSecr=3D892667 WS=3D64
 10   3.040552 armada388 -> n2100 TCP [TCP Port numbers reused] 843=E2=86=
=92nfs [SYN] Seq=3D983834922 Win=3D28800 Len=3D0 MSS=3D1440 SACK_PERM=3D=
1 TSval=3D892667 TSecr=3D0 WS=3D128
 11   3.040771 n2100 -> armada388 TCP nfs=E2=86=92843 [RST, ACK] Seq=3D=
0 Ack=3D983834923 Win=3D0 Len=3D0
 12   3.040845 armada388 -> n2100 TCP 843=E2=86=92nfs [RST] Seq=3D98383=
4372 Win=3D0 Len=3D0
 13   6.050296 armada388 -> n2100 TCP [TCP Port numbers reused] 843=E2=86=
=92nfs [SYN] Seq=3D1030865629 Win=3D28800 Len=3D0 MSS=3D1440 SACK_PERM=3D=
1 TSval=3D892968 TSecr=3D0 WS=3D128
 14   6.050673 n2100 -> armada388 TCP nfs=E2=86=92843 [SYN, ACK] Seq=3D=
503532268 Ack=3D1030865630 Win=3D28560 Len=3D0 MSS=3D1440 SACK_PERM=3D1=
 TSval=3D818169719 TSecr=3D892968 WS=3D64
 15   6.050761 armada388 -> n2100 TCP [TCP Port numbers reused] 843=E2=86=
=92nfs [SYN] Seq=3D1030866205 Win=3D28800 Len=3D0 MSS=3D1440 SACK_PERM=3D=
1 TSval=3D892968 TSecr=3D0 WS=3D128

It seems rather strange that the Armada388 NFS client is trying to
connect _two_ TCP/IPv6 connections from the same address and the same
port but with different sequence numbers (which suggests that packet
numbers 5, 10 and 15 are the problem ones.

However, what happens with the reset packets is most interesting.
Packet 6 looks like it's resetting the duplicate connection caused by
packet 5.  Packet 7 looks like it's resetting the initial connection
from packet 4.

It seems fairly reproducable, though I haven't worked out exactly what
triggers it.

Is this a known bug?  Any ideas where to start looking?

Thanks.

--=20
=46TTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
