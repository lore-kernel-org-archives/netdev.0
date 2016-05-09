From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH V1 1/3] net: bulk alloc and reuse of SKBs in NAPI context
Date: Mon, 9 May 2016 09:20:41 -0700
Message-ID: <CAKgT0Uftr643AR9n2=_aQmaGJO3eEyKTuaCfXwEKbYj1rVruRw@mail.gmail.com>
References: <20160509134352.3573.37044.stgit@firesoul>
	<20160509134429.3573.4048.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:35782 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751207AbcEIQUm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 12:20:42 -0400
Received: by mail-ig0-f175.google.com with SMTP id bi2so108917794igb.0
        for <netdev@vger.kernel.org>; Mon, 09 May 2016 09:20:42 -0700 (PDT)
In-Reply-To: <20160509134429.3573.4048.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 9, 2016 at 6:44 AM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
> This patch introduce bulk alloc of SKBs and allow reuse of SKBs
> free'ed in same softirq cycle.  SKBs are normally free'ed during TX
> completion, but most high speed drivers also cleanup TX ring during
> NAPI RX poll cycle.  Thus, if using napi_consume_skb/__kfree_skb_defer,
> SKBs will be avail in the napi_alloc_cache->skb_cache.
>
> If no SKBs are avail for reuse, then only bulk alloc 8 SKBs, to limit
> the potential overshooting unused SKBs needed to free'ed when NAPI
> cycle ends (flushed in net_rx_action via __kfree_skb_flush()).
>
> Generalize ___build_skb() to allow passing it a preallocated SKB.
>
> I've previously demonstrated a 1% speedup for IPv4 forwarding, when
> used on the ixgbe driver.  If SKB alloc and free happens on different
> CPUs (like in RPS use-case) the performance benefit is expected to
> increase.

Really I am not sure this patch series is worth the effort.  For
freeing buffers in Tx it was an obvious win.  But adding all this
complexity for a 1% gain just doesn't seen worth the effort.

> All drivers using the napi_alloc_skb() call will benefit from
> this change automatically.

Yes, but a 1% improvement is essentially just noise.  I'd say we need
to show a better gain or be able to more precisely show that this is a
definite gain and not just a test fluctuation resulting in the
improvement.  For all I know all of the gain could be due to a
function shifting around so that some loop is now 16 byte aligned.

> Joint work with Alexander Duyck.
>
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>

The fact that this is still using my redhat.com address says volumes.
If I recall I think we were working on this code around 9 months ago
and had similar issues with it showing either negative performance or
no gain.  My advice then was to push the bulk free code and try to
find a way to fix the bulk allocation.  If we are still at this state
for bulk allocation then maybe we need to drop the bulk allocation and
start looking at other avenues to pursue.

> ---
>  net/core/skbuff.c |   71 ++++++++++++++++++++++++++++++++++-------------------
>  1 file changed, 45 insertions(+), 26 deletions(-)
>
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 5586be93632f..e85f1065b263 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -281,32 +281,14 @@ nodata:
>  }
>  EXPORT_SYMBOL(__alloc_skb);
>
> -/**
> - * __build_skb - build a network buffer
> - * @data: data buffer provided by caller
> - * @frag_size: size of data, or 0 if head was kmalloced
> - *
> - * Allocate a new &sk_buff. Caller provides space holding head and
> - * skb_shared_info. @data must have been allocated by kmalloc() only if
> - * @frag_size is 0, otherwise data should come from the page allocator
> - *  or vmalloc()
> - * The return is the new skb buffer.
> - * On a failure the return is %NULL, and @data is not freed.
> - * Notes :
> - *  Before IO, driver allocates only data buffer where NIC put incoming frame
> - *  Driver should add room at head (NET_SKB_PAD) and
> - *  MUST add room at tail (SKB_DATA_ALIGN(skb_shared_info))
> - *  After IO, driver calls build_skb(), to allocate sk_buff and populate it
> - *  before giving packet to stack.
> - *  RX rings only contains data buffers, not full skbs.
> - */
> -struct sk_buff *__build_skb(void *data, unsigned int frag_size)
> +/* Allows skb being (pre)allocated by caller */
> +static inline
> +struct sk_buff *___build_skb(void *data, unsigned int frag_size,
> +                            struct sk_buff *skb)
>  {
>         struct skb_shared_info *shinfo;
> -       struct sk_buff *skb;
>         unsigned int size = frag_size ? : ksize(data);
>
> -       skb = kmem_cache_alloc(skbuff_head_cache, GFP_ATOMIC);
>         if (!skb)
>                 return NULL;
>
> @@ -331,6 +313,34 @@ struct sk_buff *__build_skb(void *data, unsigned int frag_size)
>         return skb;
>  }
>
> +/**
> + * __build_skb - build a network buffer
> + * @data: data buffer provided by caller
> + * @frag_size: size of data, or 0 if head was kmalloced
> + *
> + * Allocate a new &sk_buff. Caller provides space holding head and
> + * skb_shared_info. @data must have been allocated by kmalloc() only if
> + * @frag_size is 0, otherwise data should come from the page allocator
> + *  or vmalloc()
> + * The return is the new skb buffer.
> + * On a failure the return is %NULL, and @data is not freed.
> + * Notes :
> + *  Before IO, driver allocates only data buffer where NIC put incoming frame
> + *  Driver should add room at head (NET_SKB_PAD) and
> + *  MUST add room at tail (SKB_DATA_ALIGN(skb_shared_info))
> + *  After IO, driver calls build_skb(), to allocate sk_buff and populate it
> + *  before giving packet to stack.
> + *  RX rings only contains data buffers, not full skbs.
> + */
> +struct sk_buff *__build_skb(void *data, unsigned int frag_size)
> +{
> +       struct sk_buff *skb;
> +       unsigned int size = frag_size ? : ksize(data);
> +
> +       skb = kmem_cache_alloc(skbuff_head_cache, GFP_ATOMIC);
> +       return ___build_skb(data, size, skb);
> +}
> +
>  /* build_skb() is wrapper over __build_skb(), that specifically
>   * takes care of skb->head and skb->pfmemalloc
>   * This means that if @frag_size is not zero, then @data must be backed

If we can avoid having to break up build_skb into more functions that
would be preferred.  I realize I probably wrote this code in order to
enable the bulk allocation approach, but really I don't want to add
more complexity unless we can show a strong gain which we haven't been
able to demonstrate.

> @@ -490,8 +500,8 @@ struct sk_buff *__napi_alloc_skb(struct napi_struct *napi, unsigned int len,
>
>         len += NET_SKB_PAD + NET_IP_ALIGN;
>
> -       if ((len > SKB_WITH_OVERHEAD(PAGE_SIZE)) ||
> -           (gfp_mask & (__GFP_DIRECT_RECLAIM | GFP_DMA))) {
> +       if (unlikely((len > SKB_WITH_OVERHEAD(PAGE_SIZE)) ||
> +                    (gfp_mask & (__GFP_DIRECT_RECLAIM | GFP_DMA)))) {
>                 skb = __alloc_skb(len, gfp_mask, SKB_ALLOC_RX, NUMA_NO_NODE);
>                 if (!skb)
>                         goto skb_fail;

Does this unlikely really make a difference?  If so you might want to
move it into a patch all on its own.

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

So did you try doing a low latency socket test with this patch?  I'm
guessing not as I am certain there is a negative impact from having to
allocate 8 buffers, and then free back 7 every time you call the NAPI
polling routine with just one buffer in the ring.

>                 skb_free_frag(data);
>                 return NULL;
>         }
> +       skb = ___build_skb(data, len, skb);
>
>         /* use OR instead of assignment to avoid clearing of bits in mask */
>         if (nc->page.pfmemalloc)
>
