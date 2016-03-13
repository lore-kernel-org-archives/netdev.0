From: Rana Shahout <rana.shahot@gmail.com>
Subject: Re: [net-next PATCH 3/7] net: bulk alloc and reuse of SKBs in NAPI context
Date: Sun, 13 Mar 2016 16:06:17 +0200
Message-ID: <CALYk33gF_qLuBpYLX4xLpekVJX9okUqaxdMnFgWpyDrRwu5e5w@mail.gmail.com>
References: <20160304130054.32651.51776.stgit@firesoul>
	<20160304130143.32651.33813.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	eugenia@mellanox.com, Alexander Duyck <alexander.duyck@gmail.com>,
	alexei.starovoitov@gmail.com, saeedm@mellanox.com,
	gerlitz.or@gmail.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:34290 "EHLO
	mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751124AbcCMOGS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2016 10:06:18 -0400
Received: by mail-oi0-f68.google.com with SMTP id m82so9384073oif.1
        for <netdev@vger.kernel.org>; Sun, 13 Mar 2016 07:06:18 -0700 (PDT)
In-Reply-To: <20160304130143.32651.33813.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 4, 2016 at 3:01 PM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:

>  /* build_skb() is wrapper over __build_skb(), that specifically
>   * takes care of skb->head and skb->pfmemalloc
>   * This means that if @frag_size is not zero, then @data must be backed
> @@ -490,8 +500,8 @@ struct sk_buff *__napi_alloc_skb(struct napi_struct *napi, unsigned int len,
>
>         len += NET_SKB_PAD + NET_IP_ALIGN;
>
> -       if ((len > SKB_WITH_OVERHEAD(PAGE_SIZE)) ||
> -           (gfp_mask & (__GFP_DIRECT_RECLAIM | GFP_DMA))) {
> +       if (unlikely((len > SKB_WITH_OVERHEAD(PAGE_SIZE)) ||
> +                    (gfp_mask & (__GFP_DIRECT_RECLAIM | GFP_DMA)))) {

Why unlikely? I know it is better for the common case where most
likely linear SKBs are << SKB_WITH_OVERHEAD(PAGE_SIZE)), but what
about the case of Hardware LRO,  where linear SKB is likely to be >>
SKB_WITH_OVERHEAD(PAGE_SIZE)).


>                 skb = __alloc_skb(len, gfp_mask, SKB_ALLOC_RX, NUMA_NO_NODE);
>                 if (!skb)
>                         goto skb_fail;
> @@ -508,11 +518,20 @@ struct sk_buff *__napi_alloc_skb(struct napi_struct *napi, unsigned int len,
>         if (unlikely(!data))
>                 return NULL;
>
> -       skb = __build_skb(data, len);
> -       if (unlikely(!skb)) {
> +#define BULK_ALLOC_SIZE 8
> +       if (!nc->skb_count) {
> +               nc->skb_count = kmem_cache_alloc_bulk(skbuff_head_cache,
> +                                                     gfp_mask, BULK_ALLOC_SIZE,
> +                                                     nc->skb_cache);
> +       }
> +       if (likely(nc->skb_count)) {
> +               skb = (struct sk_buff *)nc->skb_cache[--nc->skb_count];
> +       } else {
> +               /* alloc bulk failed */
>                 skb_free_frag(data);
>                 return NULL;
>         }
> +       skb = ___build_skb(data, len, skb);
>
>         /* use OR instead of assignment to avoid clearing of bits in mask */
>         if (nc->page.pfmemalloc)
>
