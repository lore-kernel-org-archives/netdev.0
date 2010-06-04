From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: check for refcount if pop a stacked dst_entry
Date: Fri, 04 Jun 2010 12:51:19 +0200
Message-ID: <1275648679.2482.43.camel@edumazet-laptop>
References: <20100604104012.GA13408@secunet.com>
	 <20100604104115.GB13408@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:63656 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754326Ab0FDKvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jun 2010 06:51:23 -0400
Received: by wwb28 with SMTP id 28so760110wwb.19
        for <netdev@vger.kernel.org>; Fri, 04 Jun 2010 03:51:21 -0700 (PDT)
In-Reply-To: <20100604104115.GB13408@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 04 juin 2010 =C3=A0 12:41 +0200, Steffen Klassert a =C3=A9c=
rit :
> xfrm triggers a warning if dst_pop() drops a refcount
> on a noref dst. This patch changes dst_pop() to
> skb_dst_pop(). skb_dst_pop() drops the refcnt only
> on a refcounted dst.
>=20
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---
>  include/net/dst.h      |    6 +++---
>  net/xfrm/xfrm_output.c |    2 +-
>  2 files changed, 4 insertions(+), 4 deletions(-)
>=20
> diff --git a/include/net/dst.h b/include/net/dst.h
> index 612069b..acd1538 100644
> --- a/include/net/dst.h
> +++ b/include/net/dst.h
> @@ -250,11 +250,11 @@ static inline void skb_tunnel_rx(struct sk_buff=
 *skb, struct net_device *dev)
>   * Linux networking.  Thus, destinations are stackable.
>   */
> =20
> -static inline struct dst_entry *dst_pop(struct dst_entry *dst)
> +static inline struct dst_entry *skb_dst_pop(struct sk_buff *skb)
>  {
> -	struct dst_entry *child =3D dst_clone(dst->child);
> +	struct dst_entry *child =3D dst_clone(skb_dst(skb)->child);
> =20



> -	dst_release(dst);
> +	skb_dst_drop(skb);
>  	return child;
>  }

Hmm, this might fix the thing, but we probably can do it without the
dst_clone(), if you replace the=20

skb_dst_set(skb, dst);

by=20

skb_dst_set_noref(skb, dst);

in xfrm_output_one() ?

> =20
> diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
> index 6a32915..db62a06 100644
> --- a/net/xfrm/xfrm_output.c
> +++ b/net/xfrm/xfrm_output.c
> @@ -95,7 +95,7 @@ resume:
>  			goto error_nolock;
>  		}
> =20
> -		dst =3D dst_pop(dst);
> +		dst =3D skb_dst_pop(skb);
>  		if (!dst) {
>  			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTERROR);
>  			err =3D -EHOSTUNREACH;


