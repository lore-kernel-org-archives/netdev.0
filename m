From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2] net: sysctl for RA default route MTU
Date: Wed, 25 Mar 2015 19:14:15 +0100
Message-ID: <1427307255.3555533.245187845.14A187CD@webmail.messagingengine.com>
References: <20150324.152705.921124268458994532.davem@davemloft.net>
 <1427281679-13007-1-git-send-email-klamm@yandex-team.ru>
 <1427298721.2344863.245111901.25E46F85@webmail.messagingengine.com>
 <39171427301187@webcorp02f.yandex-team.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org
To: Roman Gushchin <klamm@yandex-team.ru>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:55780 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751740AbbCYSOP convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Mar 2015 14:14:15 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 8C3EF209F1
	for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 14:14:12 -0400 (EDT)
In-Reply-To: <39171427301187@webcorp02f.yandex-team.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, Mar 25, 2015, at 17:33, Roman Gushchin wrote:
> 25.03.2015, 18:52, "Hannes Frederic Sowa" <hannes@stressinduktion.org=
>:
> > On Wed, Mar 25, 2015, at 12:07, Roman Gushchin wrote:
> >> =C2=A0--- a/net/ipv6/route.c
> >> =C2=A0+++ b/net/ipv6/route.c
> >> =C2=A0@@ -1714,6 +1714,14 @@ int ip6_route_add(struct fib6_config =
*cfg)
> >>
> >> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0rt->rt=
6i_flags =3D cfg->fc_flags;
> >>
> >> =C2=A0+ =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0if ((cfg->fc_flags & (=
RTF_ADDRCONF | RTF_DEFAULT | RTF_GATEWAY))
> >> =C2=A0=3D=3D
> >> =C2=A0+ =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
(RTF_ADDRCONF | RTF_DEFAULT | RTF_GATEWAY)) {
> >> =C2=A0+ =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0u32 mtu =3D idev->cnf.ra_default_route_mtu;
> >> =C2=A0+
> >> =C2=A0+ =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0if (mtu && mtu >=3D IPV6_MIN_MTU && mtu <=3D id=
ev->cnf.mtu6)
> >> =C2=A0+ =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
dst_metric_set(&rt->dst, RTAX_MTU, mtu);
> >> =C2=A0+ =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0}
> >> =C2=A0+
> >
> > Could you move this RA specific snippet over to ndisc.c?
>=20
> Ok, no problem.

Thanks!

> >
> > Hmm
> >
> > How do you use this option?
>=20
> We want to set and keep normal (~1500) MTU on default route for exter=
nal
> connections
> without an additional userspace effort, while link MTU is 9000 to sup=
port
> jumbo frames
> on other routes.
>=20
> > You use jumbo frames on the on-link network and announce all routes=
 via
> > route options where you also want to communicate to with jumbo fram=
es?
>=20
> Yes, exactly.
>=20
> >
> > I wonder if an offlink_mtu parameter would be more suitable?
>=20
> If I understand you correctly, the difference is which MTU will have
> routes, announced via RIO.
> Am I right?
> If so, it will not help in our case, because only default route shoul=
d
> have "small" MTU,
> and there is no way to announce per-route MTUs for RIO routes.
> I thought about two separate knobs (ra_default_route_mtu and
> ra_rt_info_route_mtu, for example),
> but it seemed to me too excessive.

Hmm. I revert my opinion on offlink_mtu parameter.

So the approach would be to just basically leave your patch as-is and i=
f
another segment can be talked to with jumbo frames one could just let
the RA speaker add another route announcement which should get a more
specific route into the tables with the jumbo MTU from the RA packet.
Only default routes will get the overwritten MTU value from the new
knob. Am I correct? So your approach seems to be the most flexible
option.

Thanks and looking forward to the new patch,
Hannes
