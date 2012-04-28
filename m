From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH 1/4 net-next] net: allow skb->head to be a page fragment
Date: Fri, 27 Apr 2012 17:27:44 -0700
Message-ID: <4F9B3980.1080605@intel.com>
References: <1335522818.2775.227.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SWxwbyBKw6RydmluZW4=?= <ilpo.jarvinen@helsinki.fi>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	=?UTF-8?B?TWFjaWVqIMW7ZW5jenlrb3dza2k=?= <maze@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:7049 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758207Ab2D1A1p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2012 20:27:45 -0400
In-Reply-To: <1335522818.2775.227.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/27/2012 03:33 AM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> skb->head is currently allocated from kmalloc(). This is convenient but
> has the drawback the data cannot be converted to a page fragment if
> needed.
>
> We have three spots were it hurts :
>
> 1) GRO aggregation
>
>  When a linear skb must be appended to another skb, GRO uses the
> frag_list fallback, very inefficient since we keep all struct sk_buff
> around. So drivers enabling GRO but delivering linear skbs to network
> stack aren't enabling full GRO power.
>
> 2) splice(socket -> pipe).
>
>  We must copy the linear part to a page fragment.
>  This kind of defeats splice() purpose (zero copy claim)
>
> 3) TCP coalescing.
>
>  Recently introduced, this permits to group several contiguous segments
> into a single skb. This shortens queue lengths and save kernel memory,
> and greatly reduce probabilities of TCP collapses. This coalescing
> doesnt work on linear skbs (or we would need to copy data, this would be
> too slow)
>
> Given all these issues, the following patch introduces the possibility
> of having skb->head be a fragment in itself. We use a new skb flag,
> skb->head_frag to carry this information.
>
> build_skb() is changed to accept a frag_size argument. Drivers willing
> to provide a page fragment instead of kmalloc() data will set a non zero
> value, set to the fragment size.
>
> Then, on situations we need to convert the skb head to a frag in itself,
> we can check if skb->head_frag is set and avoid the copies or various
> fallbacks we have.
>
> This means drivers currently using frags could be updated to avoid the
> current skb->head allocation and reduce their memory footprint (aka skb
> truesize). (thats 512 or 1024 bytes saved per skb). This also makes
> bpf/netfilter faster since the 'first frag' will be part of skb linear
> part, no need to copy data.
[...]
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 2342a72..effa75d 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -245,6 +245,7 @@ EXPORT_SYMBOL(__alloc_skb);
>  /**
>   * build_skb - build a network buffer
>   * @data: data buffer provided by caller
> + * @frag_size: size of fragment, or 0 if head was kmalloced
>   *
>   * Allocate a new &sk_buff. Caller provides space holding head and
>   * skb_shared_info. @data must have been allocated by kmalloc()
> @@ -258,20 +259,21 @@ EXPORT_SYMBOL(__alloc_skb);
>   *  before giving packet to stack.
>   *  RX rings only contains data buffers, not full skbs.
>   */
> -struct sk_buff *build_skb(void *data)
> +struct sk_buff *build_skb(void *data, unsigned int frag_size)
>  {
>  	struct skb_shared_info *shinfo;
>  	struct sk_buff *skb;
> -	unsigned int size;
> +	unsigned int size = frag_size ? : ksize(data);
>  
>  	skb = kmem_cache_alloc(skbuff_head_cache, GFP_ATOMIC);
>  	if (!skb)
>  		return NULL;
>  
> -	size = ksize(data) - SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
> +	size -= SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
>  
>  	memset(skb, 0, offsetof(struct sk_buff, tail));
>  	skb->truesize = SKB_TRUESIZE(size);
> +	skb->head_frag = frag_size != 0;
>  	atomic_set(&skb->users, 1);
>  	skb->head = data;
>  	skb->data = data;

This doesn't seem right to me.  You are only counting the piece of the
page that got filled with data and the piece that will get overwritten
with the shared info.  What about the rest of the page?  It looks like
in the tg3 patch you have the driver using a half page.  Based on this
function I suspect the resultant truesize would be something like 64 +
256 + 320 for an ack.  Shouldn't your truesize in that case be 2048 + 256?

Thanks,

Alex
