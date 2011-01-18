From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [BUG] bnx2 + vlan + TSO : doesnt work
Date: Tue, 18 Jan 2011 00:09:25 +0000
Message-ID: <1295309365.6264.23.camel@bwh-desktop>
References: <1295307669.3362.106.camel@edumazet-laptop>
	 <1295308041.6264.22.camel@bwh-desktop>
	 <1295308844.3362.135.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jesse Gross <jesse@nicira.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:29452 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753215Ab1ARAJ2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jan 2011 19:09:28 -0500
In-Reply-To: <1295308844.3362.135.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-01-18 at 01:00 +0100, Eric Dumazet wrote:
> Le lundi 17 janvier 2011 =C3=A0 23:47 +0000, Ben Hutchings a =C3=A9cr=
it :
> > On Tue, 2011-01-18 at 00:41 +0100, Eric Dumazet wrote:
> > > Oh well, my dev machine, with bnx2 and tg3 NICs, isnt working at =
all
> > > with current linux-2.6 tree (I need vlans on my setup)
> > >=20
> > > tg3 : vlan not working
> > >=20
> > > bnx2 : vlan + TSO not working (or very slowly, since only non GSO=
 frames
> > > are OK)
> > >=20
> > > I suspect recent commits from Jesse are the problem.
> > > (bnx2_xmit() is feeded with zeroed vlan_tci skbs)
> > >=20
> > > Maybe f01a5236bd4b1401 (net offloading: Generalize
> > > netif_get_vlan_features().) ?
> > >=20
> > > I dont see NETIF_F_HW_VLAN_TX being set in vlan_features in net d=
rivers.
> > > They only set this flag in dev->features
> > >=20
> > > I dont think changing all drivers to also set vlan_features makes=
 sense.
> > >=20
> > > Is following patch the right path ? (It does solve my problem)
> >=20
> > This isn't right.  NETIF_F_HW_VLAN_TX in vlan_features would mean t=
hat
> > the hardware can do two levels of VLAN tag insertion, which is gene=
rally
> > not true.
> >=20
>=20
> So should we revert part of Jesse patch ? I want my vlan back ;)

Yeah, that looks right.

Ben.

> diff --git a/net/core/dev.c b/net/core/dev.c
> index 54277df..8209d93 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2076,7 +2076,7 @@ int dev_hard_start_xmit(struct sk_buff *skb, st=
ruct net_device *dev,
>  		features =3D netif_skb_features(skb);
> =20
>  		if (vlan_tx_tag_present(skb) &&
> -		    !(features & NETIF_F_HW_VLAN_TX)) {
> +		    !(dev->features & NETIF_F_HW_VLAN_TX)) {
>  			skb =3D __vlan_put_tag(skb, vlan_tx_tag_get(skb));
>  			if (unlikely(!skb))
>  				goto out;
>=20
>=20

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

