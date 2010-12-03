From: Simon Horman <horms@verge.net.au>
Subject: Re: TSO/GRO/LRO/somethingO breaks LVS on 2.6.36
Date: Fri, 3 Dec 2010 21:36:19 +0900
Message-ID: <20101203123617.GA6993@verge.net.au>
References: <20101203103447.GA29714@hostway.ca>
 <1291375743.2897.141.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Simon Kirby <sim@hostway.ca>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:43774 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755364Ab0LCMgZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Dec 2010 07:36:25 -0500
Content-Disposition: inline
In-Reply-To: <1291375743.2897.141.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 03, 2010 at 12:29:03PM +0100, Eric Dumazet wrote:
> Le vendredi 03 d=C3=A9cembre 2010 =C3=A0 02:34 -0800, Simon Kirby a =C3=
=A9crit :
> > Hello!
> >=20
> > We upgraded some LVS (DR) servers from 2.6.35 to 2.6.36 on tg3 card=
s
> > (partno(BCM95721) rev 4201) with VLAN tags in use, to think that
> > everything looked great, but in fact...
> >=20
> > LVS was receiving magically-merged TCP packets which it tried to fo=
rward
> > on to the real server, only to get annoyed at itself for trying to
> > forward a packet bigger than the device MTU:
> >=20
> > IP A.47376 > B.529: . 175488:176936(1448) ack 1 win 92 <nop,nop,tim=
estamp 52737308 29656081>
> > IP A.47376 > B.529: . 176936:179832(2896) ack 1 win 92 <nop,nop,tim=
estamp 52737325 29656098>
> > IP B > A: ICMP B unreachable - need to frag (mtu 1500), length 556
> >=20
>=20
> Hi Simon
>=20
> This is a tcpdump on A ?
> Could you take it also on B ?
>=20
> tcpdump displays large buffers, but they should be split (of course)
> when sent on wire.
>=20
> > This caused packet loss for any merged frames, which caused abysmal
> > performance for uploads via the LVS server.  Local performance to o=
r
> > from the box is still fine, because the stack doesn't care, only th=
e
> > forwarding part of LVS is running into the problem.
> >=20
> > Furthermore, disabling _everything_ reported by ethtool -k doesn't =
seem
> > to change the result, even if I down/up the interface after, and ev=
en if
> > I try on every single interface including the VLANned ones.  This s=
eems
> > to be another bug.  Reverting to 2.6.35 makes it all work again.
> >=20
> > Possibly related to commit 7fe876af921d1d2bc8353e0062c10ff35e902653
> >=20
> > So how should this be fixed?  Should LVS be taught to fragment, or =
must
> > we disable the merging in this case?  It seems like it would work w=
ell if
> > the sending side could do the same offload in reverse, but I'm not =
sure
> > if that would be possible.
> >=20
> > Simon-
>=20
>=20
> I believe Simon Horman has some patches for GRO and LVS.
>=20
> Please send the results of "ethtool -k eth0" on all your nics / vlans=
 ?
>=20
> For TSO, I am not sure why and where it could matter...

There is a patch to teach LVS how to cope with GRO in nf-next-2.6
and I expect it to be included in 2.6.38. The patch is "ipvs: allow
transmit of GRO aggregated skbs" and perhaps it should be considered
for 2.6.37 and stable. In general the work around is to disable GRO.

The patch does not resolve the incompatibility of LVS with LRO.
The work around there is to disable LRO. I'm not entirely sure
how to teach LVS to disable LRO automatically, or if its desirable.

Simon, you mention that you disabled everything with ethtool, but the
tcpdump above shows a 2896 byte packet, which seems that GRO (or LRO?) =
is
active. So perhaps as you speculate that is a bug

I will prepare a backport of the "ipvs: allow transmit of GRO aggregate=
d
skbs" patch to v2.6.36 and post it shortly.  Testing to see if that
resolves the problem that you are seeing would probably be a good start=
=2E

