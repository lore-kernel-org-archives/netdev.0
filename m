From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Frag list lost on head expansion.
Date: Fri, 03 Sep 2010 07:48:00 +0200
Message-ID: <1283492880.3699.1437.camel@edumazet-laptop>
References: <20100902.204332.02275687.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:50179 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750845Ab0ICFsI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Sep 2010 01:48:08 -0400
Received: by wwj40 with SMTP id 40so2005801wwj.1
        for <netdev@vger.kernel.org>; Thu, 02 Sep 2010 22:48:07 -0700 (PDT)
In-Reply-To: <20100902.204332.02275687.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 02 septembre 2010 =C3=A0 20:43 -0700, David Miller a =C3=A9cri=
t :
> When pskb_expand_head() releases the data, with skb_release_data(), i=
t
> tries to properly preserve any fragment list using
> skb_clone_fraglist().
>=20
> Although skb_clone_fraglist() will properly grab a reference to all o=
f
> the fragment list SKBs, it will not block skb_release_data() from
> NULL'ing out the ->frag_list pointer when it calls skb_drop_list() vi=
a
> skb_drop_fraglist().
>=20
> As a result we lose the fragment SKBs and they are leaked forever.
>=20
> Instead, hide the fragment list pointer around the skb_release_data()
> call and restore it afterwards.  This fixes the bug and also makes
> it cheaper since we won't grab and release every single fragment
> list SKB reference.
>=20
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>=20
> I found this via pure code inspection, please review.
>=20
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 26396ff..def2e49 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -789,6 +789,7 @@ EXPORT_SYMBOL(pskb_copy);
>  int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
>  		     gfp_t gfp_mask)
>  {
> +	struct sk_buff *frag_list;
>  	int i;
>  	u8 *data;
>  #ifdef NET_SKBUFF_DATA_USES_OFFSET
> @@ -822,11 +823,13 @@ int pskb_expand_head(struct sk_buff *skb, int n=
head, int ntail,
>  	for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++)
>  		get_page(skb_shinfo(skb)->frags[i].page);
> =20
> -	if (skb_has_frags(skb))
> -		skb_clone_fraglist(skb);
> +	frag_list =3D skb_shinfo(skb)->frag_list;
> +	skb_shinfo(skb)->frag_list =3D NULL;
> =20
>  	skb_release_data(skb);
> =20
> +	skb_shinfo(skb)->frag_list =3D frag_list;
> +
>  	off =3D (data + nhead) - skb->head;
> =20
>  	skb->head     =3D data;

David, I had this same idea some days ago when reviewing this code,
but when I came to conclusion we could not avoid the get_page /
put_page() on skb_shinfo(skb)->frags[i].page. I thought it was not wort=
h
trying to avoid the frag_list grab/release operation.

But we are the only user of this skb and skb_shinfo(skb)->frag_list, so
your patch seems good to me.

Please note you are not fixing a bug, because the new frag_list pointer
was correctly copied in the

memcpy(data + size, skb_end_pointer(skb),=20
	offsetof(struct skb_shared_info,
		frags[skb_shinfo(skb)->nr_frags]));

Please rewrite the changelog to say this patch is an optimization, to
avoid the atomic ops on each skb found in frag_list ?

Thanks !


