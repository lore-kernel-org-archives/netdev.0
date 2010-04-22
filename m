From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: Introduce skb_orphan_try()
Date: Thu, 22 Apr 2010 09:24:05 +0200
Message-ID: <1271921045.7895.4763.camel@edumazet-laptop>
References: <1271830116.7895.1316.camel@edumazet-laptop>
	 <20100421.225625.177238009.davem@davemloft.net>
	 <1271920233.7895.4723.camel@edumazet-laptop>
	 <20100422.001625.200862474.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:41648 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751695Ab0DVHYQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 03:24:16 -0400
Received: by bwz25 with SMTP id 25so9173571bwz.28
        for <netdev@vger.kernel.org>; Thu, 22 Apr 2010 00:24:14 -0700 (PDT)
In-Reply-To: <20100422.001625.200862474.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 22 avril 2010 =C3=A0 00:16 -0700, David Miller a =C3=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 22 Apr 2010 09:10:33 +0200
>=20
> > Le mercredi 21 avril 2010 =C3=A0 22:56 -0700, David Miller a =C3=A9=
crit :
> >=20
> >> Right, I've applied this, thanks.
> >>=20
> >> What we should probably do instead is call and NULL out the
> >> DEV_GSO_CB() destructor.  Right?
> >=20
> > Yes, probably, I'll take a look at this if you want.
>=20
> It might look something like this:
>=20
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 9bf1ccc..13241da 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1892,6 +1892,20 @@ static inline void skb_orphan_try(struct sk_bu=
ff *skb)
>  		skb_orphan(skb);
>  }
> =20
> +/*
> + * GSO packets need to be handled specially because such packets
> + * hold the normal SKB destructor in a backup pointer.
> + */
> +static inline void skb_orphan_try_gso(struct sk_buff *skb)
> +{
> +	if (!skb_tx(skb)->flags) {
> +		if (DEV_GSO_CB(skb)->destructor)
> +			DEV_GSO_CB(skb)->destructor(skb);
> +		DEV_GSO_CB(skb)->destructor =3D NULL;
> +		skb->sk =3D NULL;
> +	}
> +}
> +
>  int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
>  			struct netdev_queue *txq)
>  {
> @@ -1937,6 +1951,7 @@ gso:
>  		if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
>  			skb_dst_drop(nskb);
> =20
> +		skb_orphan_try_gso(skb);
>  		rc =3D ops->ndo_start_xmit(nskb, dev);
>  		if (unlikely(rc !=3D NETDEV_TX_OK)) {
>  			if (rc & ~NETDEV_TX_MASK)

Hmm... are you sure we want to call destructor for each skb ?

Should'nt we do it before initial skb is split ?



