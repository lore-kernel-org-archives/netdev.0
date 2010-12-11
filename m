From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] rfc: ethtool: early-orphan control
Date: Sun, 12 Dec 2010 07:40:20 +0900
Message-ID: <20101211224018.GA2547@verge.net.au>
References: <1292040815-10439-1-git-send-email-horms@verge.net.au>
 <20101211042434.GB32453@verge.net.au>
 <1292054618.2746.48.camel@edumazet-laptop>
 <1292087480.2746.54.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:43473 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751675Ab0LKWk0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Dec 2010 17:40:26 -0500
Content-Disposition: inline
In-Reply-To: <1292087480.2746.54.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 11, 2010 at 06:11:20PM +0100, Eric Dumazet wrote:
> Le samedi 11 d=C3=A9cembre 2010 =C3=A0 09:03 +0100, Eric Dumazet a =C3=
=A9crit :
> > Le samedi 11 d=C3=A9cembre 2010 =C3=A0 13:24 +0900, Simon Horman a =
=C3=A9crit :
> > > On Sat, Dec 11, 2010 at 01:13:35PM +0900, Simon Horman wrote:
> > > > Early orphaning is an optimisation which avoids unnecessary cac=
he misses by
> > > > orphaning an skb just before it is handed to a device for trans=
mit thus
> > > > avoiding the case where the orphaning occurs on a different CPU=
=2E
> > > >=20
> > > > In the case of bonded devices this has the unfortunate side-eff=
ect of
> > > > breaking down flow control allowing a socket to send UDP packet=
s as fast as
> > > > the CPU will allow. This is particularly undesirable in virtual=
ised
> > > > network environments.
> > > >=20
> > > > This patch introduces ethtool control of early orphaning.
> > > > It remains on by default by it now may be disabled on a per-int=
erface basis.
> > > >=20
> > > > I have implemented this as a generic flag.
> > > > As it seems to be the first generic flag that requires
> > > > no driver awareness I also supplied a default flag handler.
> > > > I am unsure if any aspect of this approach is acceptable.
> > > >=20
> > > > I believe Eric has it in mind that some of the calls
> > > > to skb_orphan() in drivers can be removed with the addition
> > > > of this feature. I need to discuss that with him further.
> > > >=20
> > > > A patch for the ethtool user-space utility accompanies this pat=
ch.
> > >=20
> > > The following results were measured using kvm using virto without=
 vhost net.
> > > The virtio device is bridged to a bond device which has one gigab=
it slave.
> > >=20
> >=20
> > As you know, vhost net does the orphaning, as well as some NIC driv=
ers,
> > so one UDP flood would have same problem.
> >=20
> > I wonder if this problem could not be solved in other ways.
> >=20
> >=20
> > We might do early orphaning only for sockets with SOCK_USE_WRITE_QU=
EUE
> > flag asserted. (tcp sets it)
> >=20
> > Then, we could also say : Why tcp use sock_wfree() at all...
> >=20
>=20
> I removed skb_orphan_try() and did a quick test, with bonding or not,
> same results on a Gigabit interface.
>=20
> $ netperf -C -c -4 -t UDP_STREAM -H 55.225.18.57 -- -m 1000
> UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to=
 55.225.18.57 (55.225.18.57) port 0 AF_INET
> Socket  Message  Elapsed      Messages                   CPU      Ser=
vice
> Size    Size     Time         Okay Errors   Throughput   Util     Dem=
and
> bytes   bytes    secs            #      #   10^6bits/sec % SS     us/=
KB
>=20
> 10000000    1000   10.00     6611385      0     5289.0     13.18    9=
=2E278=20
> 1000000           10.00     1163454             930.7     4.58     6.=
456=20
>=20
>=20
> As soon as 'socket size' is big enough, UDP flow control is ineffecti=
ve,
> and no error is reported to user. sendto() says all frames were prope=
rly sent.
>=20

Yes, I've done that test too (as you suggested previously). But my thou=
ght
was that in a virtualised environment the administrator of the host can=
 set
the socket size to be small enough and the guest can't change it.

However, I now realise that the same effect can be produced
in the guest's network stack by increasing wmem_default there.
So I'm not sure that this change is useful after all. And I've
got a worse flow control problem than I previously realised.

