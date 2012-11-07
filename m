From: Li Yu <raise.sail@gmail.com>
Subject: Re: [PATCH 1/4 net-next] net: allow skb->head to be a page fragment
Date: Wed, 07 Nov 2012 16:20:54 +0800
Message-ID: <509A19E6.4040707@gmail.com>
References: <1335522818.2775.227.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:54053 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750768Ab2KGIVE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 03:21:04 -0500
Received: by mail-pa0-f46.google.com with SMTP id hz1so983309pad.19
        for <netdev@vger.kernel.org>; Wed, 07 Nov 2012 00:21:04 -0800 (PST)
In-Reply-To: <1335522818.2775.227.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B404=E6=9C=8827=E6=97=A5 18:33, Eric Dumazet =E5=86=
=99=E9=81=93:
> From: Eric Dumazet <edumazet@google.com>
>
> skb->head is currently allocated from kmalloc(). This is convenient b=
ut
> has the drawback the data cannot be converted to a page fragment if
> needed.
>

Hi, Eric,

I have a question about this patch, why data are allocated from=20
kmalloc() can not be converted to page fragment ? We have its kernel
mapped address and length, so we can get its page and offset in the=20
page. If the skb is not cloned (shared with others), such page and its
offset should be can use safely, in my words.

I suspected that I may lost important something in slab internals, is r=
ight?

Thanks

Yu

> We have three spots were it hurts :
>
> 1) GRO aggregation
>
>   When a linear skb must be appended to another skb, GRO uses the
> frag_list fallback, very inefficient since we keep all struct sk_buff
> around. So drivers enabling GRO but delivering linear skbs to network
> stack aren't enabling full GRO power.
>
> 2) splice(socket -> pipe).
>
>   We must copy the linear part to a page fragment.
>   This kind of defeats splice() purpose (zero copy claim)
>
> 3) TCP coalescing.
>
>   Recently introduced, this permits to group several contiguous segme=
nts
> into a single skb. This shortens queue lengths and save kernel memory=
,
> and greatly reduce probabilities of TCP collapses. This coalescing
> doesnt work on linear skbs (or we would need to copy data, this would=
 be
> too slow)
>
> Given all these issues, the following patch introduces the possibilit=
y
> of having skb->head be a fragment in itself. We use a new skb flag,
> skb->head_frag to carry this information.
>
> build_skb() is changed to accept a frag_size argument. Drivers willin=
g
> to provide a page fragment instead of kmalloc() data will set a non z=
ero
> value, set to the fragment size.
>
> Then, on situations we need to convert the skb head to a frag in itse=
lf,
> we can check if skb->head_frag is set and avoid the copies or various
> fallbacks we have.
>
> This means drivers currently using frags could be updated to avoid th=
e
> current skb->head allocation and reduce their memory footprint (aka s=
kb
> truesize). (thats 512 or 1024 bytes saved per skb). This also makes
> bpf/netfilter faster since the 'first frag' will be part of skb linea=
r
> part, no need to copy data.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: Maciej =C5=BBenczykowski <maze@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Tom Herbert <therbert@google.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: Ben Hutchings <bhutchings@solarflare.com>
> Cc: Matt Carlson <mcarlson@broadcom.com>
> Cc: Michael Chan <mchan@broadcom.com>
> ---
>   drivers/net/ethernet/broadcom/bnx2.c            |    2 -
>   drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |    4 +-
>   drivers/net/ethernet/broadcom/tg3.c             |    2 -
>   include/linux/skbuff.h                          |    5 +-
>   net/core/skbuff.c                               |   24 ++++++++++--=
--
>   5 files changed, 25 insertions(+), 12 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ether=
net/broadcom/bnx2.c
> index ab55979..ac7b744 100644
> --- a/drivers/net/ethernet/broadcom/bnx2.c
> +++ b/drivers/net/ethernet/broadcom/bnx2.c
> @@ -3006,7 +3006,7 @@ error:
>
>   	dma_unmap_single(&bp->pdev->dev, dma_addr, bp->rx_buf_use_size,
>   			 PCI_DMA_FROMDEVICE);
> -	skb =3D build_skb(data);
> +	skb =3D build_skb(data, 0);
>   	if (!skb) {
>   		kfree(data);
>   		goto error;
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/driver=
s/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> index 60d5b54..9c5bc5d 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> @@ -513,7 +513,7 @@ static inline void bnx2x_tpa_stop(struct bnx2x *b=
p, struct bnx2x_fastpath *fp,
>   	dma_unmap_single(&bp->pdev->dev, dma_unmap_addr(rx_buf, mapping),
>   			 fp->rx_buf_size, DMA_FROM_DEVICE);
>   	if (likely(new_data))
> -		skb =3D build_skb(data);
> +		skb =3D build_skb(data, 0);
>
>   	if (likely(skb)) {
>   #ifdef BNX2X_STOP_ON_ERROR
> @@ -721,7 +721,7 @@ int bnx2x_rx_int(struct bnx2x_fastpath *fp, int b=
udget)
>   						 dma_unmap_addr(rx_buf, mapping),
>   						 fp->rx_buf_size,
>   						 DMA_FROM_DEVICE);
> -				skb =3D build_skb(data);
> +				skb =3D build_skb(data, 0);
>   				if (unlikely(!skb)) {
>   					kfree(data);
>   					fp->eth_q_stats.rx_skb_alloc_failed++;
> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethern=
et/broadcom/tg3.c
> index 0c3e7c7..d481b0a 100644
> --- a/drivers/net/ethernet/broadcom/tg3.c
> +++ b/drivers/net/ethernet/broadcom/tg3.c
> @@ -5844,7 +5844,7 @@ static int tg3_rx(struct tg3_napi *tnapi, int b=
udget)
>   			pci_unmap_single(tp->pdev, dma_addr, skb_size,
>   					 PCI_DMA_FROMDEVICE);
>
> -			skb =3D build_skb(data);
> +			skb =3D build_skb(data, 0);
>   			if (!skb) {
>   				kfree(data);
>   				goto drop_it_no_recycle;
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 4a656b5..9d28a22 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -470,7 +470,8 @@ struct sk_buff {
>   	__u8			wifi_acked_valid:1;
>   	__u8			wifi_acked:1;
>   	__u8			no_fcs:1;
> -	/* 9/11 bit hole (depending on ndisc_nodetype presence) */
> +	__u8			head_frag:1;
> +	/* 8/10 bit hole (depending on ndisc_nodetype presence) */
>   	kmemcheck_bitfield_end(flags2);
>
>   #ifdef CONFIG_NET_DMA
> @@ -562,7 +563,7 @@ extern void consume_skb(struct sk_buff *skb);
>   extern void	       __kfree_skb(struct sk_buff *skb);
>   extern struct sk_buff *__alloc_skb(unsigned int size,
>   				   gfp_t priority, int fclone, int node);
> -extern struct sk_buff *build_skb(void *data);
> +extern struct sk_buff *build_skb(void *data, unsigned int frag_size)=
;
>   static inline struct sk_buff *alloc_skb(unsigned int size,
>   					gfp_t priority)
>   {
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 2342a72..effa75d 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -245,6 +245,7 @@ EXPORT_SYMBOL(__alloc_skb);
>   /**
>    * build_skb - build a network buffer
>    * @data: data buffer provided by caller
> + * @frag_size: size of fragment, or 0 if head was kmalloced
>    *
>    * Allocate a new &sk_buff. Caller provides space holding head and
>    * skb_shared_info. @data must have been allocated by kmalloc()
> @@ -258,20 +259,21 @@ EXPORT_SYMBOL(__alloc_skb);
>    *  before giving packet to stack.
>    *  RX rings only contains data buffers, not full skbs.
>    */
> -struct sk_buff *build_skb(void *data)
> +struct sk_buff *build_skb(void *data, unsigned int frag_size)
>   {
>   	struct skb_shared_info *shinfo;
>   	struct sk_buff *skb;
> -	unsigned int size;
> +	unsigned int size =3D frag_size ? : ksize(data);
>
>   	skb =3D kmem_cache_alloc(skbuff_head_cache, GFP_ATOMIC);
>   	if (!skb)
>   		return NULL;
>
> -	size =3D ksize(data) - SKB_DATA_ALIGN(sizeof(struct skb_shared_info=
));
> +	size -=3D SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
>
>   	memset(skb, 0, offsetof(struct sk_buff, tail));
>   	skb->truesize =3D SKB_TRUESIZE(size);
> +	skb->head_frag =3D frag_size !=3D 0;
>   	atomic_set(&skb->users, 1);
>   	skb->head =3D data;
>   	skb->data =3D data;
> @@ -376,6 +378,14 @@ static void skb_clone_fraglist(struct sk_buff *s=
kb)
>   		skb_get(list);
>   }
>
> +static void skb_free_head(struct sk_buff *skb)
> +{
> +	if (skb->head_frag)
> +		put_page(virt_to_head_page(skb->head));
> +	else
> +		kfree(skb->head);
> +}
> +
>   static void skb_release_data(struct sk_buff *skb)
>   {
>   	if (!skb->cloned ||
> @@ -402,7 +412,7 @@ static void skb_release_data(struct sk_buff *skb)
>   		if (skb_has_frag_list(skb))
>   			skb_drop_fraglist(skb);
>
> -		kfree(skb->head);
> +		skb_free_head(skb);
>   	}
>   }
>
> @@ -644,6 +654,7 @@ static struct sk_buff *__skb_clone(struct sk_buff=
 *n, struct sk_buff *skb)
>   	C(tail);
>   	C(end);
>   	C(head);
> +	C(head_frag);
>   	C(data);
>   	C(truesize);
>   	atomic_set(&n->users, 1);
> @@ -940,7 +951,7 @@ int pskb_expand_head(struct sk_buff *skb, int nhe=
ad, int ntail,
>   		fastpath =3D atomic_read(&skb_shinfo(skb)->dataref) =3D=3D delta;
>   	}
>
> -	if (fastpath &&
> +	if (fastpath && !skb->head_frag &&
>   	    size + sizeof(struct skb_shared_info) <=3D ksize(skb->head)) {
>   		memmove(skb->head + size, skb_shinfo(skb),
>   			offsetof(struct skb_shared_info,
> @@ -967,7 +978,7 @@ int pskb_expand_head(struct sk_buff *skb, int nhe=
ad, int ntail,
>   	       offsetof(struct skb_shared_info, frags[skb_shinfo(skb)->nr_=
frags]));
>
>   	if (fastpath) {
> -		kfree(skb->head);
> +		skb_free_head(skb);
>   	} else {
>   		/* copy this zero copy skb frags */
>   		if (skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) {
> @@ -985,6 +996,7 @@ int pskb_expand_head(struct sk_buff *skb, int nhe=
ad, int ntail,
>   	off =3D (data + nhead) - skb->head;
>
>   	skb->head     =3D data;
> +	skb->head_frag =3D 0;
>   adjust_others:
>   	skb->data    +=3D off;
>   #ifdef NET_SKBUFF_DATA_USES_OFFSET
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
