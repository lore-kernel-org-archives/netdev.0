From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NFS/TCP/IPv6 acting strangely in 4.2
Date: Fri, 11 Sep 2015 08:18:43 -0700
Message-ID: <1441984723.4619.61.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150911113839.GO21084@n2100.arm.linux.org.uk>
	 <1441976691.4619.58.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150911143347.GQ21084@n2100.arm.linux.org.uk>
	 <20150911150613.GR21084@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-nfs@vger.kernel.org,
	Trond Myklebust <trond.myklebust@primarydata.com>,
	Anna Schumaker <anna.schumaker@netapp.com>,
	linux-arm-kernel@lists.infradead.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35473 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752444AbbIKPSp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2015 11:18:45 -0400
In-Reply-To: <20150911150613.GR21084@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-09-11 at 16:06 +0100, Russell King - ARM Linux wrote:
> On Fri, Sep 11, 2015 at 03:33:47PM +0100, Russell King - ARM Linux wr=
ote:
> > It looks like 0c78789e3a030615c6650fde89546cadf40ec2cc might be rel=
evant
> > too, but I don't see that solving the multiple _concurrent_ connect=
ion
> > attempts with the same port number - presumably it's somehow trying=
 to
> > make the same socket repeatedly connect despite a previous connecti=
on
> > being in progress, which would have nothing to do with cleaning up =
a
> > previous attempt.
>=20
> As I suspected, applying the above commit in addition does not solve =
the
> problem, I still see the same behaviour: SYN SYNACK SYN RSTACK, SYN
> SYNACK SYN RSTACK, and eventual SYN storms.
>=20
> I do have this captured as well:
>=20
> 2558   0.834316 armada388 -> n2100 TCP [TCP Port numbers reused] rpas=
swd=E2=86=92nfs [SYN] Seq=3D1053655487 Win=3D28800 Len=3D0 MSS=3D1440 S=
ACK_PERM=3D1 TSval=3D60001 TSecr=3D0 WS=3D128
> 2559   0.834572 n2100 -> armada388 TCP nfs=E2=86=92rpasswd [SYN, ACK]=
 Seq=3D3076611574 Ack=3D1053655488 Win=3D28560 Len=3D0 MSS=3D1440 SACK_=
PERM=3D1 TSval=3D869622246 TSecr=3D60001 WS=3D64
> 2560   0.834666 armada388 -> n2100 TCP [TCP Port numbers reused] rpas=
swd=E2=86=92nfs [SYN] Seq=3D1054228544 Win=3D28800 Len=3D0 MSS=3D1440 S=
ACK_PERM=3D1 TSval=3D60005 TSecr=3D0 WS=3D128
> 2561   0.834895 n2100 -> armada388 TCP nfs=E2=86=92rpasswd [ACK] Seq=3D=
3076611575 Ack=3D1053655488 Win=3D28560 Len=3D0 TSval=3D869622246 TSecr=
=3D60001
>=20
> The packet at 2561 looks wrong to me - this doesn't follow what I kno=
w
> would be the standard TCP setup of syn, synack, ack, because that fin=
al
> ack is in the wrong direction.
>=20

This 2561 packet is an ACK packet, because n2100 has a SYN_RECV socket
created by packet 2558.

It receives a SYN packet (2560) that it interprets as a packet slightly
out of sequence (1054228544 being above 1053655487) for this SYN_RECV

The wrong packet is 2560, not 2561
