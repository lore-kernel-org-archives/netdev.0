From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/6] net: pad skb data and shinfo as a whole rather than
 individually
Date: Thu, 05 Jan 2012 18:46:47 +0100
Message-ID: <1325785607.4759.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1325783399.25206.413.camel@zakaz.uk.xensource.com>
	 <1325783624-14601-2-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:46016 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751647Ab2AERqy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 12:46:54 -0500
Received: by wgbdr13 with SMTP id dr13so898286wgb.1
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2012 09:46:53 -0800 (PST)
In-Reply-To: <1325783624-14601-2-git-send-email-ian.campbell@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 05 janvier 2012 =C3=A0 17:13 +0000, Ian Campbell a =C3=A9crit =
:
> We already push the shinfo to the very end of the actual allocation w=
hich is
> already cache-line aligned.
>=20
> This reduces the minimum overhead required for this allocation such t=
hat the
> shinfo can be grown in the following patch without overflowing 2048 b=
ytes for a
> 1500 byte frame. Reducing this overhead means that sometimes the tail=
 end of
> the data can end up in the same cache line as the beginning of the sh=
info but
> in many cases the allocation slop means that there is no overlap.
>=20
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> ---
>  include/linux/skbuff.h |    4 ++--
>  net/core/skbuff.c      |    3 +--
>  2 files changed, 3 insertions(+), 4 deletions(-)
>=20
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 50db9b0..f04333b 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -41,7 +41,7 @@
>  #define SKB_DATA_ALIGN(X)	(((X) + (SMP_CACHE_BYTES - 1)) & \
>  				 ~(SMP_CACHE_BYTES - 1))
>  #define SKB_WITH_OVERHEAD(X)	\
> -	((X) - SKB_DATA_ALIGN(sizeof(struct skb_shared_info)))
> +	((X) - sizeof(struct skb_shared_info))
>  #define SKB_MAX_ORDER(X, ORDER) \
>  	SKB_WITH_OVERHEAD((PAGE_SIZE << (ORDER)) - (X))
>  #define SKB_MAX_HEAD(X)		(SKB_MAX_ORDER((X), 0))
> @@ -50,7 +50,7 @@
>  /* return minimum truesize of one skb containing X bytes of data */
>  #define SKB_TRUESIZE(X) ((X) +						\
>  			 SKB_DATA_ALIGN(sizeof(struct sk_buff)) +	\
> -			 SKB_DATA_ALIGN(sizeof(struct skb_shared_info)))
> +			 sizeof(struct skb_shared_info))
> =20
>  /* A. Checksumming of received packets by device.
>   *
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index da0c97f..b6de604 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -189,8 +189,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gf=
p_t gfp_mask,
>  	 * aligned memory blocks, unless SLUB/SLAB debug is enabled.
>  	 * Both skb->head and skb_shared_info are cache line aligned.
>  	 */
> -	size =3D SKB_DATA_ALIGN(size);
> -	size +=3D SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
> +	size =3D SKB_DATA_ALIGN(size + sizeof(struct skb_shared_info));
>  	data =3D kmalloc_node_track_caller(size, gfp_mask, node);
>  	if (!data)
>  		goto nodata;

Unfortunately this makes the frequently use part of skb_shared_info not
any more in a single cache line.

This will slow down many operations like kfree_skb() of cold skbs (TX
completion for example)
