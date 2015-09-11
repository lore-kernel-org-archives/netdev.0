From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: NFS/TCP/IPv6 acting strangely in 4.2
Date: Fri, 11 Sep 2015 15:33:47 +0100
Message-ID: <20150911143347.GQ21084@n2100.arm.linux.org.uk>
References: <20150911113839.GO21084@n2100.arm.linux.org.uk>
 <1441976691.4619.58.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
	Anna Schumaker <anna.schumaker@netapp.com>,
	linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:41158 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752308AbbIKOeF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2015 10:34:05 -0400
Content-Disposition: inline
In-Reply-To: <1441976691.4619.58.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 11, 2015 at 06:04:51AM -0700, Eric Dumazet wrote:
> On Fri, 2015-09-11 at 12:38 +0100, Russell King - ARM Linux wrote:
> > Running tcpdump on the NFS server, and then dumping the captured
> > packets
> > with tshark (because tcpdump appears not to understand IPv6 SYNs on
> > the
> > NFS port) shows:
> >=20
> >   3   0.030036 armada388 -> n2100 TCP 843=E2=86=92nfs [SYN] Seq=3D9=
36803106
> > Win=3D28800 Len=3D0 MSS=3D1440 SACK_PERM=3D1 TSval=3D892366 TSecr=3D=
0 WS=3D128
>=20
> >   4   0.030409 n2100 -> armada388 TCP nfs=E2=86=92843 [SYN, ACK] Se=
q=3D409465870
> > Ack=3D936803107 Win=3D28560 Len=3D0 MSS=3D1440 SACK_PERM=3D1
> >  TSval=3D818169117 TSecr=3D892366 WS=3D64
>=20
> >   5   0.030493 armada388 -> n2100 TCP [TCP Port numbers reused]
> > 843=E2=86=92nfs [SYN] Seq=3D936803633 Win=3D28800 Len=3D0 MSS=3D144=
0 SACK_PERM=3D1
> > TSval=3D892366 TSecr=3D0 WS=3D128
>=20
> Yes, this packet looks very wrong. Like two simultaneous connect with
> same source port. It is not a retransmit (Seq numbers differ)
>=20
> >   6   0.030699 n2100 -> armada388 TCP nfs=E2=86=92843 [RST, ACK] Se=
q=3D0
> > Ack=3D936803634 Win=3D0 Len=3D0
> >   7   0.030766 armada388 -> n2100 TCP 843=E2=86=92nfs [RST] Seq=3D9=
36803107
> > Win=3D0 Len=3D0
>=20
> I suspect port reuse in NFS being broken.
>=20
> Have you tried to apply
>=20
> commit 099392048cd443349c50310f7fdc96070e40f4e7
> Author: Trond Myklebust <trond.myklebust@primarydata.com>
> Date:   Sat Aug 29 19:11:21 2015 -0700
>=20
>     SUNRPC: Prevent SYN+SYNACK+RST storms
>    =20
>     Add a shutdown() call before we release the socket in order to en=
sure the
>     reset is sent before we try to reconnect.
>    =20
>     Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>

Applying this patch changes the behaviour slightly, but doesn't fix the
problem:

  1   0.000000 armada388 -> n2100 TCP hcp-wismar=E2=86=92nfs [SYN] Seq=3D=
3766378552 Win=3D28800 Len=3D0 MSS=3D1440 SACK_PERM=3D1 TSval=3D240384 =
TSecr=3D0 WS=3D128
  2   0.000431 n2100 -> armada388 TCP nfs=E2=86=92hcp-wismar [SYN, ACK]=
 Seq=3D1297069321 Ack=3D3766378553 Win=3D28560 Len=3D0 MSS=3D1440 SACK_=
PERM=3D1 TSval=3D869361932 TSecr=3D240384 WS=3D64
  3   0.000518 armada388 -> n2100 TCP [TCP Port numbers reused] hcp-wis=
mar=E2=86=92nfs [SYN] Seq=3D3766379468 Win=3D28800 Len=3D0 MSS=3D1440 S=
ACK_PERM=3D1 TSval=3D240384 TSecr=3D0 WS=3D128
  4   0.000740 n2100 -> armada388 TCP nfs=E2=86=92hcp-wismar [RST, ACK]=
 Seq=3D0 Ack=3D3766379469 Win=3D0 Len=3D0
  5   0.000812 armada388 -> n2100 TCP [TCP Port numbers reused] hcp-wis=
mar=E2=86=92nfs [SYN] Seq=3D3766379980 Win=3D28800 Len=3D0 MSS=3D1440 S=
ACK_PERM=3D1 TSval=3D240384 TSecr=3D0 WS=3D128
  6   0.001051 n2100 -> armada388 TCP nfs=E2=86=92hcp-wismar [SYN, ACK]=
 Seq=3D1297080280 Ack=3D3766379981 Win=3D28560 Len=3D0 MSS=3D1440 SACK_=
PERM=3D1 TSval=3D869361932 TSecr=3D240384 WS=3D64
  7   0.001137 armada388 -> n2100 TCP [TCP Port numbers reused] hcp-wis=
mar=E2=86=92nfs [SYN] Seq=3D3766380519 Win=3D28800 Len=3D0 MSS=3D1440 S=
ACK_PERM=3D1 TSval=3D240384 TSecr=3D0 WS=3D128
  8   0.001352 n2100 -> armada388 TCP nfs=E2=86=92hcp-wismar [RST, ACK]=
 Seq=3D0 Ack=3D3766380520 Win=3D0 Len=3D0

Notice the lack of second reset, but the syns trying to re-use the same
port but with different sequence numbers is still there.

Eventually, we get to a storm of SYNs:

468   0.084816 armada388 -> n2100 TCP [TCP Port numbers reused] hcp-wis=
mar=E2=86=92nfs [SYN] Seq=3D3766488832 Win=3D28800 Len=3D0 MSS=3D1440 S=
ACK_PERM=3D1 TSval=3D240384 TSecr=3D0 WS=3D128
469   0.085046 n2100 -> armada388 TCP nfs=E2=86=92hcp-wismar [SYN, ACK]=
 Seq=3D1298392849 Ack=3D3766488833 Win=3D28560 Len=3D0 MSS=3D1440 SACK_=
PERM=3D1 TSval=3D869361940 TSecr=3D240384 WS=3D64
470   0.085136 armada388 -> n2100 TCP [TCP Port numbers reused] hcp-wis=
mar=E2=86=92nfs [SYN] Seq=3D3766489333 Win=3D28800 Len=3D0 MSS=3D1440 S=
ACK_PERM=3D1 TSval=3D240384 TSecr=3D0 WS=3D128
471   0.085391 n2100 -> armada388 TCP nfs=E2=86=92hcp-wismar [RST, ACK]=
 Seq=3D0 Ack=3D3766489334 Win=3D0 Len=3D0
472   0.085482 armada388 -> n2100 TCP [TCP Port numbers reused] hcp-wis=
mar=E2=86=92nfs [SYN] Seq=3D3766489762 Win=3D28800 Len=3D0 MSS=3D1440 S=
ACK_PERM=3D1 TSval=3D240384 TSecr=3D0 WS=3D128
473   0.085777 armada388 -> n2100 TCP [TCP Port numbers reused] hcp-wis=
mar=E2=86=92nfs [SYN] Seq=3D3766490263 Win=3D28800 Len=3D0 MSS=3D1440 S=
ACK_PERM=3D1 TSval=3D240384 TSecr=3D0 WS=3D128
474   0.086023 armada388 -> n2100 TCP [TCP Port numbers reused] hcp-wis=
mar=E2=86=92nfs [SYN] Seq=3D3766490694 Win=3D28800 Len=3D0 MSS=3D1440 S=
ACK_PERM=3D1 TSval=3D240384 TSecr=3D0 WS=3D128
=2E..
526   0.104063 armada388 -> n2100 TCP [TCP Port numbers reused] hcp-wis=
mar=E2=86=92nfs [SYN] Seq=3D3766514610 Win=3D28800 Len=3D0 MSS=3D1440 S=
ACK_PERM=3D1 TSval=3D240384 TSecr=3D0 WS=3D128
527   0.104308 armada388 -> n2100 TCP [TCP Port numbers reused] hcp-wis=
mar=E2=86=92nfs [SYN] Seq=3D3766515182 Win=3D28800 Len=3D0 MSS=3D1440 S=
ACK_PERM=3D1 TSval=3D240384 TSecr=3D0 WS=3D128
528   0.104560 armada388 -> n2100 TCP [TCP Port numbers reused] hcp-wis=
mar=E2=86=92nfs [SYN] Seq=3D3766515621 Win=3D28800 Len=3D0 MSS=3D1440 S=
ACK_PERM=3D1 TSval=3D240384 TSecr=3D0 WS=3D128
529   0.104799 armada388 -> n2100 TCP [TCP Port numbers reused] hcp-wis=
mar=E2=86=92nfs [SYN] Seq=3D3766516122 Win=3D28800 Len=3D0 MSS=3D1440 S=
ACK_PERM=3D1 TSval=3D240384 TSecr=3D0 WS=3D128
530   0.105052 armada388 -> n2100 TCP [TCP Port numbers reused] hcp-wis=
mar=E2=86=92nfs [SYN] Seq=3D3766516556 Win=3D28800 Len=3D0 MSS=3D1440 S=
ACK_PERM=3D1 TSval=3D240384 TSecr=3D0 WS=3D128
=2E..
550   0.110487 armada388 -> n2100 TCP [TCP Port numbers reused] hcp-wis=
mar=E2=86=92nfs [SYN] Seq=3D3766525755 Win=3D28800 Len=3D0 MSS=3D1440 S=
ACK_PERM=3D1 TSval=3D240384 TSecr=3D0 WS=3D128
551   0.114016 n2100 -> armada388 TCP nfs=E2=86=92hcp-wismar [SYN, ACK]=
 Seq=3D1298403514 Ack=3D3766489763 Win=3D28560 Len=3D0 MSS=3D1440 SACK_=
PERM=3D1 TSval=3D869361940 TSecr=3D240384 WS=3D64

followed by a storm of SYN,ACKs and resets.  This seems to happen sever=
al
times in the packet log.

At some point something starts going really crazy:

9341   2.668325 n2100 -> armada388 TCP nfs=E2=86=92hcp-wismar [ACK] Seq=
=3D1337671519 Ack=3D3802565165 Win=3D28560 Len=3D0 TSval=3D869362196 TS=
ecr=3D240615
9342   2.668413 n2100 -> armada388 TCP [TCP Dup ACK 9341#1] nfs=E2=86=92=
hcp-wismar [ACK] Seq=3D1337671519 Ack=3D3802565165 Win=3D28560 Len=3D0 =
TSval=3D869362196 TSecr=3D240615
9343   2.668423 n2100 -> armada388 TCP [TCP Dup ACK 9341#2] nfs=E2=86=92=
hcp-wismar [ACK] Seq=3D1337671519 Ack=3D3802565165 Win=3D28560 Len=3D0 =
TSval=3D869362196 TSecr=3D240615
9344   2.668433 n2100 -> armada388 TCP [TCP Dup ACK 9341#3] nfs=E2=86=92=
hcp-wismar [ACK] Seq=3D1337671519 Ack=3D3802565165 Win=3D28560 Len=3D0 =
TSval=3D869362196 TSecr=3D240615
=2E..
9419   2.669586 n2100 -> armada388 TCP [TCP Dup ACK 9341#78] nfs=E2=86=92=
hcp-wismar [ACK] Seq=3D1337671519 Ack=3D3802565165 Win=3D28560 Len=3D0 =
TSval=3D869362198 TSecr=3D240615

There's no other packets logged between any of these duplicated acks an=
d
I don't seem to have anything preceeding that with a sequence number of
380256516*, so I assume tcpdump dropped some packets.

Eventually, we get to:

31213   8.247815 armada388 -> n2100 TCP [TCP Port numbers reused] hcp-w=
ismar=E2=86=92nfs [SYN] Seq=3D3892006879 Win=3D28800 Len=3D0 MSS=3D1440=
 SACK_PERM=3D1 TSval=3D241188 TSecr=3D0 WS=3D128
=2E..
31337   8.297654 armada388 -> n2100 TCP hcp-wismar=E2=86=92nfs [RST] Se=
q=3D3891941177 Win=3D0 Len=3D0
31338   8.297753 armada388 -> n2100 TCP hcp-wismar=E2=86=92nfs [RST] Se=
q=3D3891942022 Win=3D0 Len=3D0
31339   8.297798 armada388 -> n2100 TCP hcp-wismar=E2=86=92nfs [RST] Se=
q=3D3891942867 Win=3D0 Len=3D0
31340   8.297835 armada388 -> n2100 TCP hcp-wismar=E2=86=92nfs [RST] Se=
q=3D3891943715 Win=3D0 Len=3D0
31341   8.297872 armada388 -> n2100 TCP hcp-wismar=E2=86=92nfs [RST] Se=
q=3D3891944560 Win=3D0 Len=3D0
31342   8.298076 armada388 -> n2100 TCP hcp-wismar=E2=86=92nfs [RST] Se=
q=3D3891945416 Win=3D0 Len=3D0
31343   8.300232 n2100 -> armada388 TCP nfs=E2=86=92hcp-wismar [SYN, AC=
K] Seq=3D1425940018 Ack=3D3892006880 Win=3D28560 Len=3D0 MSS=3D1440 SAC=
K_PERM=3D1 TSval=3D869362756 TSecr=3D241188 WS=3D64

31344   9.050382 armada388 -> n2100 TCP [TCP Port numbers reused] hcp-w=
ismar=E2=86=92nfs [SYN] Seq=3D3892315104 Win=3D28800 Len=3D0 MSS=3D1440=
 SACK_PERM=3D1 TSval=3D241289 TSecr=3D0 WS=3D128
31345   9.050760 n2100 -> armada388 TCP nfs=E2=86=92hcp-wismar [SYN, AC=
K] Seq=3D1438481320 Ack=3D3892315105 Win=3D28560 Len=3D0 MSS=3D1440 SAC=
K_PERM=3D1 TSval=3D869362837 TSecr=3D241289 WS=3D64
31346   9.051115 armada388 -> n2100 TCP hcp-wismar=E2=86=92nfs [ACK] Se=
q=3D3892315105 Ack=3D1438481321 Win=3D28800 Len=3D0 TSval=3D241289 TSec=
r=3D869362837
31347   9.051624 armada388 -> n2100 NFS V3 ACCESS Call, FH: 0x905379cc,=
 [Check: RD LU MD XT DL]
31348   9.051878 n2100 -> armada388 TCP nfs=E2=86=92hcp-wismar [ACK] Se=
q=3D1438481321 Ack=3D3892315225 Win=3D28608 Len=3D0 TSval=3D869362837 T=
Secr=3D241289
31349   9.052164 armada388 -> n2100 NFS V3 ACCESS Call, FH: 0x905379cc,=
 [Check: RD LU MD XT DL]

where things start working again.

It looks like 0c78789e3a030615c6650fde89546cadf40ec2cc might be relevan=
t
too, but I don't see that solving the multiple _concurrent_ connection
attempts with the same port number - presumably it's somehow trying to
make the same socket repeatedly connect despite a previous connection
being in progress, which would have nothing to do with cleaning up a
previous attempt.

To me, it looks like the sunrpc code isn't tracking whether a TCP
connection is already in progress, and waiting for the TCP connection
to either finish connecting, or fail to connect before attempting
another connection.

--=20
=46TTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
