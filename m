From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH] r8169: Fix rtl8169_rx_interrupt()
Date: Tue, 16 Mar 2010 08:50:15 +0200
Message-ID: <20100316065015.GA3336@swordfish.minsk.epam.com>
References: <20100307192305.GA598@elte.hu>
 <20100308125122.GA11242@redhat.com>
 <1268686865.2824.4.camel@edumazet-laptop>
 <1268699602.2824.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ew6BAiZeqk4r7MaW"
Cc: Oleg Nesterov <oleg@redhat.com>,
	David Miller <davem@davemloft.net>,
	Ingo Molnar <mingo@elte.hu>,
	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	netdev@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:54755 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755734Ab0CPGt0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Mar 2010 02:49:26 -0400
Content-Disposition: inline
In-Reply-To: <1268699602.2824.14.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--ew6BAiZeqk4r7MaW
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello,

Sure. Give me a couple of days. By the way, should I test against .34
or .33?

	Sergey


On (03/16/10 01:33), Eric Dumazet wrote:
> Le lundi 15 mars 2010 =E0 22:01 +0100, Eric Dumazet a =E9crit :
>=20
> > Yes, this is wrong. In this context (process context, not softirq), we
> > should use netif_rx() or just drop frames if we are in reset phase.
> >=20
>=20
> Sergey,
>=20
> Here is a compiled but untested patch (I dont have the hardware), could
> you please test it ?
>=20
> Thanks
>=20
> [PATCH] r8169: Fix rtl8169_rx_interrupt()
>=20
> In case a reset is performed, rtl8169_rx_interrupt() is called from
> process context instead of softirq context. Special care must be taken
> to call appropriate network core services (netif_rx() instead of
> netif_receive_skb()). VLAN handling also corrected.
>=20
> Reported-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Diagnosed-by: Oleg Nesterov <oleg@redhat.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index 9d3ebf3..d873639 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -1038,14 +1038,14 @@ static void rtl8169_vlan_rx_register(struct net_d=
evice *dev,
>  }
> =20
>  static int rtl8169_rx_vlan_skb(struct rtl8169_private *tp, struct RxDesc=
 *desc,
> -			       struct sk_buff *skb)
> +			       struct sk_buff *skb, int polling)
>  {
>  	u32 opts2 =3D le32_to_cpu(desc->opts2);
>  	struct vlan_group *vlgrp =3D tp->vlgrp;
>  	int ret;
> =20
>  	if (vlgrp && (opts2 & RxVlanTag)) {
> -		vlan_hwaccel_receive_skb(skb, vlgrp, swab16(opts2 & 0xffff));
> +		__vlan_hwaccel_rx(skb, vlgrp, swab16(opts2 & 0xffff), polling);
>  		ret =3D 0;
>  	} else
>  		ret =3D -1;
> @@ -1062,7 +1062,7 @@ static inline u32 rtl8169_tx_vlan_tag(struct rtl816=
9_private *tp,
>  }
> =20
>  static int rtl8169_rx_vlan_skb(struct rtl8169_private *tp, struct RxDesc=
 *desc,
> -			       struct sk_buff *skb)
> +			       struct sk_buff *skb, int polling)
>  {
>  	return -1;
>  }
> @@ -4429,12 +4429,20 @@ out:
>  	return done;
>  }
> =20
> +/*
> + * Warning : rtl8169_rx_interrupt() might be called :
> + * 1) from NAPI (softirq) context
> + *	(polling =3D 1 : we should call netif_receive_skb())
> + * 2) from process context (rtl8169_reset_task())
> + *	(polling =3D 0 : we must call netif_rx() instead)
> + */	=09
>  static int rtl8169_rx_interrupt(struct net_device *dev,
>  				struct rtl8169_private *tp,
>  				void __iomem *ioaddr, u32 budget)
>  {
>  	unsigned int cur_rx, rx_left;
>  	unsigned int delta, count;
> +	int polling =3D (budget !=3D ~(u32)0) ? 1 : 0;
> =20
>  	cur_rx =3D tp->cur_rx;
>  	rx_left =3D NUM_RX_DESC + tp->dirty_rx - cur_rx;
> @@ -4496,8 +4504,12 @@ static int rtl8169_rx_interrupt(struct net_device =
*dev,
>  			skb_put(skb, pkt_size);
>  			skb->protocol =3D eth_type_trans(skb, dev);
> =20
> -			if (rtl8169_rx_vlan_skb(tp, desc, skb) < 0)
> -				netif_receive_skb(skb);
> +			if (rtl8169_rx_vlan_skb(tp, desc, skb, polling) < 0) {
> +				if (likely(polling))
> +					netif_receive_skb(skb);
> +				else
> +					netif_rx(skb);
> +			}
> =20
>  			dev->stats.rx_bytes +=3D pkt_size;
>  			dev->stats.rx_packets++;
>=20
>=20

--ew6BAiZeqk4r7MaW
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iJwEAQECAAYFAkufKicACgkQfKHnntdSXjTDyAQAs7YJYfZNOlIVlYwzqk6HJC6W
gokxXZMA2U/0OFfRZTAaItL54aPd6WXdbKCuaLz2wpD6m+15TeQHDL6Tqkyd8Fr8
0M5N3LQTUB3BLa0NEsRXqnZGQjcnwHesXEdg4247Y9ZtzrNwXhHEHYJDwryZZv81
EhScS0B0FVmT5uaEeaQ=
=VK+s
-----END PGP SIGNATURE-----

--ew6BAiZeqk4r7MaW--
