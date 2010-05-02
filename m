From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: eth_type_trans() should inline
 skb_pull()
Date: Sun, 02 May 2010 08:50:32 +0200
Message-ID: <1272783032.2173.8.camel@edumazet-laptop>
References: <1272696145.2230.101.camel@edumazet-laptop>
	 <20100501.181558.141243424.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, therbert@google.com, hadi@cyberus.ca
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:53221 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750980Ab0EBGuh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 May 2010 02:50:37 -0400
Received: by bwz19 with SMTP id 19so779810bwz.21
        for <netdev@vger.kernel.org>; Sat, 01 May 2010 23:50:36 -0700 (PDT)
In-Reply-To: <20100501.181558.141243424.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 01 mai 2010 =C3=A0 18:15 -0700, David Miller a =C3=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sat, 01 May 2010 08:42:25 +0200
>=20
> > [PATCH net-next-2.6] net: eth_type_trans() should inline skb_pull()
> >=20
> > With RPS, this patch can give a 5 % boost in performance.
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Awesome, but let's do this in a way that allows us to easily annotate
> where inlining makes sense in other places, not just here.
>=20
> Something like this, ok?
>=20
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 82f5116..746a652 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -1128,6 +1128,11 @@ static inline unsigned char *__skb_pull(struct=
 sk_buff *skb, unsigned int len)
>  	return skb->data +=3D len;
>  }
> =20
> +static inline unsigned char *skb_pull_inline(struct sk_buff *skb, un=
signed int len)
> +{
> +	return unlikely(len > skb->len) ? NULL : __skb_pull(skb, len);
> +}
> +
>  extern unsigned char *__pskb_pull_tail(struct sk_buff *skb, int delt=
a);
> =20
>  static inline unsigned char *__pskb_pull(struct sk_buff *skb, unsign=
ed int len)
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 4218ff4..8b9c109 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -1051,7 +1051,7 @@ EXPORT_SYMBOL(skb_push);
>   */
>  unsigned char *skb_pull(struct sk_buff *skb, unsigned int len)
>  {
> -	return unlikely(len > skb->len) ? NULL : __skb_pull(skb, len);
> +	return skb_pull_inline(skb, len);
>  }
>  EXPORT_SYMBOL(skb_pull);
> =20
> diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
> index 0c0d272..61ec032 100644
> --- a/net/ethernet/eth.c
> +++ b/net/ethernet/eth.c
> @@ -162,7 +162,7 @@ __be16 eth_type_trans(struct sk_buff *skb, struct=
 net_device *dev)
> =20
>  	skb->dev =3D dev;
>  	skb_reset_mac_header(skb);
> -	skb_pull(skb, ETH_HLEN);
> +	skb_pull_inline(skb, ETH_HLEN);
>  	eth =3D eth_hdr(skb);
> =20
>  	if (unlikely(is_multicast_ether_addr(eth->h_dest))) {

Excellent !

Changli privately asked me why we were ignoring cases where skb->len <
ETH_HLEN.
I replied that minimum frame size was 46+12, then he asked me why we
were testing another time :

if (skb->len >=3D 2 && *(unsigned short *)rawp =3D=3D 0xFFFF)
	return htons(ETH_P_802_3);


Could we assume all eth_type_trans() must call it with initial skb->len
>=3D (46 + 12) or not ?
(According to ethernet specs, all frames should have a minimum payload
of 46 bytes)

If not sure, maybe we should issue a WARN_ON_ONCE()

If yes, tests could be removed and we could gain two cycles ;)



