From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: Introduce skb_orphan_try()
Date: Thu, 22 Apr 2010 09:47:03 +0200
Message-ID: <1271922423.7895.4819.camel@edumazet-laptop>
References: <1271921045.7895.4763.camel@edumazet-laptop>
	 <20100422.002623.00784210.davem@davemloft.net>
	 <1271921637.7895.4791.camel@edumazet-laptop>
	 <20100422.004136.151480121.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:47497 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752691Ab0DVHrM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 03:47:12 -0400
Received: by bwz25 with SMTP id 25so9200262bwz.28
        for <netdev@vger.kernel.org>; Thu, 22 Apr 2010 00:47:11 -0700 (PDT)
In-Reply-To: <20100422.004136.151480121.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 22 avril 2010 =C3=A0 00:41 -0700, David Miller a =C3=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 22 Apr 2010 09:33:57 +0200
>=20
> > Le jeudi 22 avril 2010 =C3=A0 00:26 -0700, David Miller a =C3=A9cri=
t :
> >> @@ -1865,6 +1865,7 @@ static int dev_gso_segment(struct sk_buff *s=
kb)
> >>  	int features =3D dev->features & ~(illegal_highdma(dev, skb) ?
> >>  					 NETIF_F_SG : 0);
> >> =20
> >> +	skb_orphan_try(skb);
> >>  	segs =3D skb_gso_segment(skb, features);
> >> =20
> >>  	/* Verifying header integrity only. */
> >=20
> > Yes, it seems better.
> >=20
> > What about the=20
> >=20
> > if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
> > 	skb_dst_drop(skb);
> >=20
> > This thing might also be moved before the split, since split probab=
ly
> > clone all dst ?
>=20
> Good catch, agreed.
>=20
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 3ba774b..4f897e2 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1851,6 +1851,17 @@ static void dev_gso_skb_destructor(struct sk_b=
uff *skb)
>  		cb->destructor(skb);
>  }
> =20
> +/*
> + * Try to orphan skb early, right before transmission by the device.
> + * We cannot orphan skb if tx timestamp is requested, since
> + * drivers need to call skb_tstamp_tx() to send the timestamp.
> + */
> +static inline void skb_orphan_try(struct sk_buff *skb)
> +{
> +	if (!skb_tx(skb)->flags)
> +		skb_orphan(skb);
> +}
> +
>  /**
>   *	dev_gso_segment - Perform emulated hardware segmentation on skb.
>   *	@skb: buffer to segment
> @@ -1865,6 +1876,7 @@ static int dev_gso_segment(struct sk_buff *skb)
>  	int features =3D dev->features & ~(illegal_highdma(dev, skb) ?
>  					 NETIF_F_SG : 0);
> =20
> +	skb_orphan_try(skb);
>  	segs =3D skb_gso_segment(skb, features);
> =20
>  	/* Verifying header integrity only. */
> @@ -1881,17 +1893,6 @@ static int dev_gso_segment(struct sk_buff *skb=
)
>  	return 0;
>  }
> =20
> -/*
> - * Try to orphan skb early, right before transmission by the device.
> - * We cannot orphan skb if tx timestamp is requested, since
> - * drivers need to call skb_tstamp_tx() to send the timestamp.
> - */
> -static inline void skb_orphan_try(struct sk_buff *skb)
> -{
> -	if (!skb_tx(skb)->flags)
> -		skb_orphan(skb);
> -}
> -
>  int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
>  			struct netdev_queue *txq)
>  {
> @@ -1902,13 +1903,6 @@ int dev_hard_start_xmit(struct sk_buff *skb, s=
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
> @@ -1916,6 +1910,13 @@ int dev_hard_start_xmit(struct sk_buff *skb, s=
truct net_device *dev,
>  		if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
>  			skb_dst_drop(skb);
> =20
> +		if (netif_needs_gso(dev, skb)) {
> +			if (unlikely(dev_gso_segment(skb)))
> +				goto out_kfree_skb;
> +			if (skb->next)
> +				goto gso;
> +		}
> +
>  		skb_orphan_try(skb);
>  		rc =3D ops->ndo_start_xmit(skb, dev);
>  		if (rc =3D=3D NETDEV_TX_OK)

You could have one skb_orphan_try() call before the

if (netif_needs_gso(dev, skb)) {

and remove it from dev_gso_segment() ?


