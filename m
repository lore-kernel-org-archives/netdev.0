From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH] net: Update netdev_alloc_frag to work more efficiently
 with TCP and GRO
Date: Fri, 22 Jun 2012 17:17:26 -0700
Message-ID: <4FE50B16.6020606@intel.com>
References: <20120620004306.17814.58369.stgit@gitlad.jf.intel.com>  <1340170590.4604.784.camel@edumazet-glaptop>  <1340180223.4604.828.camel@edumazet-glaptop>  <1340198514.4604.970.camel@edumazet-glaptop>  <4FE29DE4.1010705@gmail.com>  <1340255226.4604.3774.camel@edumazet-glaptop> <1340368430.4604.10280.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:50038 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756380Ab2FWAR0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jun 2012 20:17:26 -0400
In-Reply-To: <1340368430.4604.10280.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/22/2012 05:33 AM, Eric Dumazet wrote:
> On Thu, 2012-06-21 at 07:07 +0200, Eric Dumazet wrote:
>> On Wed, 2012-06-20 at 21:07 -0700, Alexander Duyck wrote:
>>> On 6/20/2012 6:21 AM, Eric Dumazet wrote:
>>>> +		nc->page = alloc_pages(GFP_ATOMIC | __GFP_COLD |
>>>> +				       (NETDEV_FRAG_ORDER ? __GFP_COMP : 0),
>>>> +				       NETDEV_FRAG_ORDER);
>>> I was wondering if you needed the check for NETDEV_FRAG_ORDER here.  
>>>  From what I can tell setting __GFP_COMP for an order 0 page has no 
>>> effect since it only seems to get checked in prep_new_page and that is 
>>> after a check to verify if the page is order 0 or not.
>> Good point, it seems some net drivers could be changed to remove
>> useless tests.
>>
>> I'll post some performance data as well.
> Here is the patch I tested here.
>
> Using 32768 bytes allocations is actually nice for MTU=9000 traffic,
> since we can fit 3 frames per 32KB instead of only 2 frames (using
> kmalloc-16384 slab))
>
> Also, I prefill page->_count with a high bias value, to avoid the
> get_page() we did for each allocated frag.
>
> In my profiles, the get_page() cost was dominant, because of false
> sharing with skb consumers (as they might run on different cpus)
>
> This way, when 32768 bytes are filled, we perform a single
> atomic_sub_return() and can recycle the page if we find we are the last
> user (this is what you did in your patch, when testing page->_count
> being 1)
This is working really nicely.  On my system put_page dropped to
somewhere near the bottom of the perf top runs I was doing.  In addition
netdev_alloc_frag dropped from about 4% CPU to 2%.

>
> Note : If I used max(PAGE_SIZE, 32678) for MAX_NETDEV_FRAGSIZE,
> gcc was not able to optimise get_order(MAX_NETDEV_FRAGSIZE), strange...
The issue is probably the type checking in the max macro.  You might
have better luck using max_t and specifying a type.

> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 5b21522..d31efa2 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -296,9 +296,18 @@ EXPORT_SYMBOL(build_skb);
>  struct netdev_alloc_cache {
>  	struct page *page;
>  	unsigned int offset;
> +	unsigned int pagecnt_bias;
>  };
>  static DEFINE_PER_CPU(struct netdev_alloc_cache, netdev_alloc_cache);
>  
> +#if PAGE_SIZE > 32768
> +#define MAX_NETDEV_FRAGSIZE	PAGE_SIZE
> +#else
> +#define MAX_NETDEV_FRAGSIZE	32768
> +#endif
> +
> +#define NETDEV_PAGECNT_BIAS	(MAX_NETDEV_FRAGSIZE /		\
> +				 SKB_DATA_ALIGN(sizeof(struct skb_shared_info)))
>  /**
>   * netdev_alloc_frag - allocate a page fragment
>   * @fragsz: fragment size
I'm assuming the reason for using the size of skb_shared_info here is
because you don't expect any requests to be smaller than that?  I
suppose that is reasonable, but is there any reason why this couldn't be
a smaller value such as SMP_CACHE_BYTES?

> @@ -316,18 +325,25 @@ void *netdev_alloc_frag(unsigned int fragsz)
>  	nc = &__get_cpu_var(netdev_alloc_cache);
>  	if (unlikely(!nc->page)) {
>  refill:
> -		nc->page = alloc_page(GFP_ATOMIC | __GFP_COLD);
> +		nc->page = alloc_pages(GFP_ATOMIC | __GFP_COLD | __GFP_COMP,
> +				       get_order(MAX_NETDEV_FRAGSIZE));
> +		if (unlikely(!nc->page))
> +			goto end;
> +recycle:
> +		atomic_set(&nc->page->_count, NETDEV_PAGECNT_BIAS);
> +		nc->pagecnt_bias = NETDEV_PAGECNT_BIAS;
>  		nc->offset = 0;
>  	}
> -	if (likely(nc->page)) {
> -		if (nc->offset + fragsz > PAGE_SIZE) {
> -			put_page(nc->page);
> -			goto refill;
> -		}
> -		data = page_address(nc->page) + nc->offset;
> -		nc->offset += fragsz;
> -		get_page(nc->page);
> +	if (nc->offset + fragsz > MAX_NETDEV_FRAGSIZE) {
> +		if (!atomic_sub_return(nc->pagecnt_bias,
> +				       &nc->page->_count))
> +			goto recycle;
> +		goto refill;
>  	}
> +	data = page_address(nc->page) + nc->offset;
> +	nc->offset += fragsz;
> +	nc->pagecnt_bias--; /* avoid get_page()/get_page() false sharing */
> +end:
>  	local_irq_restore(flags);
>  	return data;
>  }
> @@ -353,7 +369,7 @@ struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
>  	unsigned int fragsz = SKB_DATA_ALIGN(length + NET_SKB_PAD) +
>  			      SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
>  
> -	if (fragsz <= PAGE_SIZE && !(gfp_mask & __GFP_WAIT)) {
> +	if (fragsz <= MAX_NETDEV_FRAGSIZE && !(gfp_mask & __GFP_WAIT)) {
>  		void *data = netdev_alloc_frag(fragsz);
>  
>  		if (likely(data)) {
>
>
One idea I had that I have been trying to figure out how make work would
be to actually run the offset in the reverse direction so that you start
it at MAX_NETDEV_FRAGSIZE and work your way back down to 0.  The
advantage to that approach is that you then only have to perform one
check instead of two and you can drop a goto.  The only problem I have
been running into is that it doesn't seem to perform as well as your
patch but I am still working the details out.

Thanks,

Alex
