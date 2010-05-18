From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: avoid one atomic op per cloned skb
Date: Tue, 18 May 2010 20:58:44 +0200
Message-ID: <1274209124.8274.41.camel@edumazet-laptop>
References: <1274190047.8274.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:35567 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756669Ab0ERS6t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 14:58:49 -0400
Received: by fxm10 with SMTP id 10so1485332fxm.19
        for <netdev@vger.kernel.org>; Tue, 18 May 2010 11:58:47 -0700 (PDT)
In-Reply-To: <1274190047.8274.1.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 18 mai 2010 =C3=A0 15:40 +0200, Eric Dumazet a =C3=A9crit :
> Hi David
>=20
> I know you said 'only patches', but I found following patch small
> enough ?
>=20

> Thanks
>=20
> [PATCH] net: avoid one atomic op per cloned skb
>=20
> skb_clone() can use atomic_set(clone_ref, 2) safely, because only
> current thread can possibly touch clone_ref at this point.
>   =20
> Add a WARN_ON_ONCE() for a while, to catch wrong assumptions.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  net/core/skbuff.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletion(-)
>=20
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index c543dd2..4444f15 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -628,7 +628,8 @@ struct sk_buff *skb_clone(struct sk_buff *skb, gf=
p_t gfp_mask)
>  	    n->fclone =3D=3D SKB_FCLONE_UNAVAILABLE) {
>  		atomic_t *fclone_ref =3D (atomic_t *) (n + 1);
>  		n->fclone =3D SKB_FCLONE_CLONE;
> -		atomic_inc(fclone_ref);
> +		WARN_ON_ONCE(atomic_read(fclone_ref) !=3D 1);
> +		atomic_set(fclone_ref, 2);
>  	} else {
>  		n =3D kmem_cache_alloc(skbuff_head_cache, gfp_mask);
>  		if (!n)
>=20
>=20

Oops, it needs more thinking, definitely not a 2.6.35 thing...

There would be a race between skb_clone() and kfree_skbmem()

kfree_skbmem() must perform the atomic_dec_and_test() before setting
skb->fclone to SKB_FCLONE_UNAVAILABLE.

Doing so avoids dirtying skb->fclone right before kmem_cache_free()...


V2 would be :

[RFC v2] net: avoid one atomic op per cloned skb

skb_clone() can use atomic_set(clone_ref, 2) safely, because only
current thread can possibly touch clone_ref at this point.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index c543dd2..77d5a6b 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -370,13 +370,13 @@ static void kfree_skbmem(struct sk_buff *skb)
 		fclone_ref =3D (atomic_t *) (skb + 1);
 		other =3D skb - 1;
=20
-		/* The clone portion is available for
-		 * fast-cloning again.
-		 */
-		skb->fclone =3D SKB_FCLONE_UNAVAILABLE;
-
 		if (atomic_dec_and_test(fclone_ref))
 			kmem_cache_free(skbuff_fclone_cache, other);
+		else
+			/* The clone portion is available for fast-cloning.=20
+			 * Note this must be done after the fclone_ref change.
+			 */
+			skb->fclone =3D SKB_FCLONE_UNAVAILABLE;
 		break;
 	}
 }
@@ -628,7 +628,7 @@ struct sk_buff *skb_clone(struct sk_buff *skb, gfp_=
t gfp_mask)
 	    n->fclone =3D=3D SKB_FCLONE_UNAVAILABLE) {
 		atomic_t *fclone_ref =3D (atomic_t *) (n + 1);
 		n->fclone =3D SKB_FCLONE_CLONE;
-		atomic_inc(fclone_ref);
+		atomic_set(fclone_ref, 2);
 	} else {
 		n =3D kmem_cache_alloc(skbuff_head_cache, gfp_mask);
 		if (!n)


