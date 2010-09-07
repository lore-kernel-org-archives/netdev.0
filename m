From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: pskb_expand_head() optimization
Date: Tue, 07 Sep 2010 07:02:09 +0200
Message-ID: <1283835729.2585.499.camel@edumazet-laptop>
References: <1283492880.3699.1437.camel@edumazet-laptop>
	 <1283504972.2453.257.camel@edumazet-laptop>
	 <20100903.064633.27806839.davem@davemloft.net>
	 <20100906.192003.232914158.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39801 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751061Ab0IGFCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 01:02:14 -0400
Received: by wyf22 with SMTP id 22so3794286wyf.19
        for <netdev@vger.kernel.org>; Mon, 06 Sep 2010 22:02:13 -0700 (PDT)
In-Reply-To: <20100906.192003.232914158.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 06 septembre 2010 =C3=A0 19:20 -0700, David Miller a =C3=A9cri=
t :

> Eric, this goes on top of your patch and demonstrates the idea.
>=20
> Please review if you have a chance:
>=20
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 2d1bc76..aeb56af 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -327,6 +327,32 @@ static void skb_clone_fraglist(struct sk_buff *s=
kb)
>  		skb_get(list);
>  }
> =20
> +static struct sk_buff *skb_copy_fraglist(struct sk_buff *parent,
> +					 gfp_t gfp_mask)
> +{
> +	struct sk_buff *first_skb =3D NULL;
> +	struct sk_buff *prev_skb =3D NULL;
> +	struct sk_buff *skb;
> +
> +	skb_walk_frags(parent, skb) {
> +		struct sk_buff *nskb =3D pskb_copy(skb, gfp_mask);
> +
> +		if (!nskb)
> +			goto fail;
> +		if (!first_skb)
> +			first_skb =3D skb;
> +		else
> +			prev_skb->next =3D skb;
> +		prev_skb =3D skb;
> +	}
> +
> +	return first_skb;
> +
> +fail:
> +	skb_drop_list(&first_skb);
> +	return NULL;
> +}
> +
>  static void skb_release_data(struct sk_buff *skb)
>  {
>  	if (!skb->cloned ||
> @@ -812,17 +838,22 @@ int pskb_expand_head(struct sk_buff *skb, int n=
head, int ntail,
>  		fastpath =3D atomic_read(&skb_shinfo(skb)->dataref) =3D=3D delta;
>  	}
> =20
> -	if (fastpath) {
> -		kfree(skb->head);
> -	} else {
> +	if (!fastpath) {
> +		if (skb_has_frag_list(skb)) {
> +			struct sk_buff *new_list;
> +
> +			new_list =3D skb_copy_fraglist(skb, gfp_mask);
> +			if (!new_list)
> +				goto free_data;
> +			skb_shinfo(skb)->frag_list =3D new_list;

Here, skb_shinfo(skb) still points to old shinfo, you should not touch
it. An other user might need it :)

> +		}
>  		for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++)
>  			get_page(skb_shinfo(skb)->frags[i].page);
> =20
> -		if (skb_has_frag_list(skb))
> -			skb_clone_fraglist(skb);
> -
> -		skb_release_data(skb);
>  	}

I believe you cannot remove skb_release_data() call, we really need to
perform the atomic operation, and test the result on it, or a double
free could happen.

> +
> +	kfree(skb->head);
> +
>  	off =3D (data + nhead) - skb->head;
> =20
>  	skb->head     =3D data;
> @@ -848,6 +879,8 @@ int pskb_expand_head(struct sk_buff *skb, int nhe=
ad, int ntail,
>  	atomic_set(&skb_shinfo(skb)->dataref, 1);
>  	return 0;
> =20
> +free_data:
> +	kfree(data);

is it a leftover ?

>  nodata:
>  	return -ENOMEM;
>  }

I understand what you want to do, but problem is we need to perform a
CAS2 operation : atomically changes two values (dataref and frag_list)



