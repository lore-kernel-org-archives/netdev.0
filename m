From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: Introduce skb_orphan_try()
Date: Thu, 22 Apr 2010 09:59:01 +0200
Message-ID: <1271923141.7895.4844.camel@edumazet-laptop>
References: <1271921637.7895.4791.camel@edumazet-laptop>
	 <20100422.004136.151480121.davem@davemloft.net>
	 <1271922423.7895.4819.camel@edumazet-laptop>
	 <20100422.005421.155629785.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:38321 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752014Ab0DVH7L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 03:59:11 -0400
Received: by bwz25 with SMTP id 25so9214354bwz.28
        for <netdev@vger.kernel.org>; Thu, 22 Apr 2010 00:59:09 -0700 (PDT)
In-Reply-To: <20100422.005421.155629785.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 22 avril 2010 =C3=A0 00:54 -0700, David Miller a =C3=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 22 Apr 2010 09:47:03 +0200
>=20
> > You could have one skb_orphan_try() call before the
> >=20
> > if (netif_needs_gso(dev, skb)) {
> >=20
> > and remove it from dev_gso_segment() ?
>=20
> Yes, that's much more concise.  This should be ready to go:
>=20
> net: Orphan and de-dst skbs earlier in xmit path.
>=20
> This way GSO packets don't get handled differently.
>=20
> With help from Eric Dumazet.
>=20
> Signed-off-by: David S. Miller <davem@davemloft.net>
>=20
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 3ba774b..a4a7c36 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1902,13 +1902,6 @@ int dev_hard_start_xmit(struct sk_buff *skb, s=
truct net_device *dev,
>  		if (!list_empty(&ptype_all))
>  			dev_queue_xmit_nit(skb, dev);
> =20
> -		if (netif_needs_gso(dev, skb)) {
> -			if (unlikely(dev_gso_segment(skb)))
> -				goto out_kfree_skb;
> -			if (skb->next)
> -				goto gso;
> -		}
> -
>  		/*
>  		 * If device doesnt need skb->dst, release it right now while
>  		 * its hot in this cpu cache
> @@ -1917,6 +1910,14 @@ int dev_hard_start_xmit(struct sk_buff *skb, s=
truct net_device *dev,
>  			skb_dst_drop(skb);
> =20
>  		skb_orphan_try(skb);
> +
> +		if (netif_needs_gso(dev, skb)) {
> +			if (unlikely(dev_gso_segment(skb)))
> +				goto out_kfree_skb;
> +			if (skb->next)
> +				goto gso;
> +		}
> +
>  		rc =3D ops->ndo_start_xmit(skb, dev);
>  		if (rc =3D=3D NETDEV_TX_OK)
>  			txq_trans_update(txq);

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks David !


