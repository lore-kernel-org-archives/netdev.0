From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TSO/GRO/LRO/somethingO breaks LVS on 2.6.36
Date: Thu, 27 Jan 2011 08:42:05 +0100
Message-ID: <1296114125.1783.139.camel@edumazet-laptop>
References: <20101203103447.GA29714@hostway.ca>
	 <1291375743.2897.141.camel@edumazet-laptop>
	 <20101203123617.GA6993@verge.net.au> <20101209023509.GA21216@hostway.ca>
	 <1291863119.2795.29.camel@edumazet-laptop>
	 <20101222233948.GC17581@hostway.ca> <20110113063422.GB14643@verge.net.au>
	 <20110127004805.GB11578@hostway.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org
To: Simon Kirby <sim@hostway.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:36635 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751501Ab1A0HmL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jan 2011 02:42:11 -0500
Received: by wyb28 with SMTP id 28so1792509wyb.19
        for <netdev@vger.kernel.org>; Wed, 26 Jan 2011 23:42:10 -0800 (PST)
In-Reply-To: <20110127004805.GB11578@hostway.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 26 janvier 2011 =C3=A0 16:48 -0800, Simon Kirby a =C3=A9cri=
t :
> On Thu, Jan 13, 2011 at 03:34:22PM +0900, Simon Horman wrote:
>=20
> > Hi Simon,
> >=20
> > thanks for prodding me to respond to this post offline and sorry fo=
r not
> > responding earlier.
> >=20
> > Firstly, I think that this is a receive-side problem so I don't bel=
ieve
> > that GSO (generic segmentation offload) or other transmit-side opti=
ons are
> > likely to have any affect.
> >=20
> > My understanding is that on the receive-side there are two options =
which
> > when enabled can result in the behaviour that you describe.
> >=20
> > * LRO (large receive offload)
> >=20
> >   You have this disabled, and assuming it really is disabled it
> >   shouldn't be causing a problem.
> >=20
> > * GRO (generic receive offload)
> >=20
> >   This does not seem to be in the output of your ethtool commands a=
t all.
> >   So I wonder if your ethtool is too old to support this option?
>=20
> So, this was the case.  Our ethtool (lenny) was too old to see the GR=
O
> option, only GSO.  Disabling GRO on eth1.39 has no effect, but disabl=
ing
> it on eth1 caused it to stop receiving the merged frames, fixing the =
LVS
> packet loss (due to no sending GSO support from LVS/IPVS).
>=20
> Speaking of this, did your patch for LVS/IPVS GSO support go anywhere=
?=20
>=20
> >   In any case, I was able to reproduce the problem that you describ=
e (or at
> >   least something very similar) using 2.6.36 with GRO enabled on et=
h1.1 and
> >   the problem did not manifest when I disabled GRO on eth1.1.
>=20
> It worked for you to do ethtool -K eth1.1 gro off, then?  For me on
> 2.6.37, it seemed to be that "ethtool -K eth1 gro off" was needed, ev=
en
> though packets arrive on eth1.39.
>=20
> Also, strangely, 2.6.35.4's default state (with no received merged fr=
ames)
> has GRO on for eth1 but off for eth1.39:
>=20
> # ethtool -k eth1
> Offload parameters for eth1:
> rx-checksumming: on
> tx-checksumming: on
> scatter-gather: on
> tcp-segmentation-offload: on
> udp-fragmentation-offload: off
> generic-segmentation-offload: on
> generic-receive-offload: on
> large-receive-offload: off
> ntuple-filters: off
> receive-hashing: off
>=20
> # ethtool -k eth1.39
> Offload parameters for eth1.39:
> rx-checksumming: on
> tx-checksumming: off
> scatter-gather: off
> tcp-segmentation-offload: off
> udp-fragmentation-offload: off
> generic-segmentation-offload: off
> generic-receive-offload: off
> large-receive-offload: off
> ntuple-filters: off
> receive-hashing: off
>=20
> If I set 2.6.37 to have all of the same options, I still see GRO fram=
es
> on 2.6.37 (tg3), which is weird.
>=20

Weird maybe, but GRO check/handling is done in dev_gro_receive(), on
eth1 receive path.

=46rames are assembled by GRO layer using tg3 NAPI structure (holding G=
RO
machine state) before being delivered to eth1.39

It would be useless/expensive to add another GRO layer on eth1.39

We might not report GRO state on vlan/bonding (or reflect real device
GRO state)



