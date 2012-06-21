From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH] net: Update netdev_alloc_frag to work more efficiently
 with TCP and GRO
Date: Wed, 20 Jun 2012 21:07:00 -0700
Message-ID: <4FE29DE4.1010705@gmail.com>
References: <20120620004306.17814.58369.stgit@gitlad.jf.intel.com>  <1340170590.4604.784.camel@edumazet-glaptop>  <1340180223.4604.828.camel@edumazet-glaptop> <1340198514.4604.970.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:36665 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750980Ab2FUEHK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2012 00:07:10 -0400
Received: by dady13 with SMTP id y13so275226dad.19
        for <netdev@vger.kernel.org>; Wed, 20 Jun 2012 21:07:10 -0700 (PDT)
In-Reply-To: <1340198514.4604.970.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/20/2012 6:21 AM, Eric Dumazet wrote:
> On Wed, 2012-06-20 at 10:17 +0200, Eric Dumazet wrote:
>
>> Strange, I did again benchs with order-2 allocations and got good
>> results this time, but with latest net-next, maybe things have changed
>> since last time I did this.
>>
>> (netdev_alloc_frag(), get_page_from_freelist() and put_page() less
>> prevalent in perf results)
>>
> In fact, since SLUB uses order-3 for kmalloc-2048, I felt lucky to try
> this as well, and results are really good, on ixgbe at least.
>
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 5b21522..ffd2cba 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -299,6 +299,9 @@ struct netdev_alloc_cache {
>   };
>   static DEFINE_PER_CPU(struct netdev_alloc_cache, netdev_alloc_cache);
>
> +#define MAX_NETDEV_FRAGSIZE	max_t(unsigned int, PAGE_SIZE, 32768)
> +#define NETDEV_FRAG_ORDER	get_order(MAX_NETDEV_FRAGSIZE)
> +
>   /**
>    * netdev_alloc_frag - allocate a page fragment
>    * @fragsz: fragment size
> @@ -316,11 +319,13 @@ void *netdev_alloc_frag(unsigned int fragsz)
>   	nc =&__get_cpu_var(netdev_alloc_cache);
>   	if (unlikely(!nc->page)) {
>   refill:
> -		nc->page = alloc_page(GFP_ATOMIC | __GFP_COLD);
> +		nc->page = alloc_pages(GFP_ATOMIC | __GFP_COLD |
> +				       (NETDEV_FRAG_ORDER ? __GFP_COMP : 0),
> +				       NETDEV_FRAG_ORDER);
>   		nc->offset = 0;
>   	}
I was wondering if you needed the check for NETDEV_FRAG_ORDER here.  
 From what I can tell setting __GFP_COMP for an order 0 page has no 
effect since it only seems to get checked in prep_new_page and that is 
after a check to verify if the page is order 0 or not.

Thanks,

Alex
