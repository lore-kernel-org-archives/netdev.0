From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: avoid one atomic op per cloned skb
Date: Wed, 19 May 2010 07:18:58 +0200
Message-ID: <1274246338.2485.38.camel@edumazet-laptop>
References: <1274190047.8274.1.camel@edumazet-laptop>
	 <1274209124.8274.41.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:53683 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751273Ab0ESFTE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 May 2010 01:19:04 -0400
Received: by wwb22 with SMTP id 22so305908wwb.19
        for <netdev@vger.kernel.org>; Tue, 18 May 2010 22:19:01 -0700 (PDT)
In-Reply-To: <1274209124.8274.41.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 18 mai 2010 =C3=A0 20:58 +0200, Eric Dumazet a =C3=A9crit :

> Oops, it needs more thinking, definitely not a 2.6.35 thing...
>=20
> There would be a race between skb_clone() and kfree_skbmem()
>=20
> kfree_skbmem() must perform the atomic_dec_and_test() before setting
> skb->fclone to SKB_FCLONE_UNAVAILABLE.
>=20
> Doing so avoids dirtying skb->fclone right before kmem_cache_free()..=
=2E
>=20
>=20
> V2 would be :
>=20
> [RFC v2] net: avoid one atomic op per cloned skb
>=20
> skb_clone() can use atomic_set(clone_ref, 2) safely, because only
> current thread can possibly touch clone_ref at this point.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index c543dd2..77d5a6b 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -370,13 +370,13 @@ static void kfree_skbmem(struct sk_buff *skb)
>  		fclone_ref =3D (atomic_t *) (skb + 1);
>  		other =3D skb - 1;
> =20
> -		/* The clone portion is available for
> -		 * fast-cloning again.
> -		 */
> -		skb->fclone =3D SKB_FCLONE_UNAVAILABLE;
> -
>  		if (atomic_dec_and_test(fclone_ref))
>  			kmem_cache_free(skbuff_fclone_cache, other);
> +		else
> +			/* The clone portion is available for fast-cloning.=20
> +			 * Note this must be done after the fclone_ref change.
> +			 */
> +			skb->fclone =3D SKB_FCLONE_UNAVAILABLE;

This still is racy, because we are not allowed to access skb after the
atomic_dec_and_test() :

Other thread can now go past the final refcount decrement and free skb
under us.

Hmm...

>  		break;
>  	}
>  }
> @@ -628,7 +628,7 @@ struct sk_buff *skb_clone(struct sk_buff *skb, gf=
p_t gfp_mask)
>  	    n->fclone =3D=3D SKB_FCLONE_UNAVAILABLE) {
>  		atomic_t *fclone_ref =3D (atomic_t *) (n + 1);
>  		n->fclone =3D SKB_FCLONE_CLONE;
> -		atomic_inc(fclone_ref);
> +		atomic_set(fclone_ref, 2);
>  	} else {
>  		n =3D kmem_cache_alloc(skbuff_head_cache, gfp_mask);
>  		if (!n)
>=20



