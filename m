From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] IP: Increment INADDRERRORS if routing for a packet is
 not successful
Date: Wed, 02 Jun 2010 00:07:34 +0200
Message-ID: <1275430054.2638.115.camel@edumazet-laptop>
References: <alpine.DEB.2.00.1006011609280.9438@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:59377 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755389Ab0FAWHj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 18:07:39 -0400
Received: by wyi11 with SMTP id 11so1410310wyi.19
        for <netdev@vger.kernel.org>; Tue, 01 Jun 2010 15:07:38 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1006011609280.9438@router.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 01 juin 2010 =C3=A0 16:13 -0500, Christoph Lameter a =C3=A9cri=
t :
> Something like this would have been very helpful during recent debugg=
ing
> of multicast issues. Silent discards are bad.
>=20

>=20
> If the kernel perceives that something is wrong with an incoming pack=
et then the
> IP stack currently silently discards packets. This makes it difficult=
 to diagnose
> problems with the network configurations (such as a misbehaving kerne=
l
> subsystem discarding multicast packets because the reverse path filte=
r
> does not like multicast subscriptions on the second NIC with rp_filte=
r=3D1).
>=20
> It is also necessary to know how many inbound packets are discarded t=
o
> assess networking issues in general with a NIC.
>=20
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>
>=20

I disagree with this patch.

IPSTATS_MIB_INADDRERRORS has a strong meaning, part of RFCS.

In this path, we simulate the routing of a virtual packet, not its
delivery.

This should not affect IPSTATS SNMP entries.

You should use another MIB entry, say LINUX_MIB_INROUTEERRORS ?

Dont inet_rtm_getroute() caller gets an error status anyway ?

> ---
>  net/ipv4/route.c |    3 +++
>  1 file changed, 3 insertions(+)
>=20
> Index: linux-2.6/net/ipv4/route.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/net/ipv4/route.c	2010-06-01 11:46:10.000000000 -05=
00
> +++ linux-2.6/net/ipv4/route.c	2010-06-01 11:52:55.000000000 -0500
> @@ -2981,6 +2981,9 @@ static int inet_rtm_getroute(struct sk_b
>  		rt =3D skb_rtable(skb);
>  		if (err =3D=3D 0 && rt->u.dst.error)
>  			err =3D -rt->u.dst.error;
> +		if (err)
> +			IP_INC_STATS_BH(dev_net(skb->dev),
> +					IPSTATS_MIB_INADDRERRORS);
>  	} else {
>  		struct flowi fl =3D {
>  			.nl_u =3D {
>=20
>=20


