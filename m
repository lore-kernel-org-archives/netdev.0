From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: do not deplete pfmemalloc reserve
Date: Wed, 22 Apr 2015 16:24:28 -0400 (EDT)
Message-ID: <20150422.162428.953715808502824913.davem@davemloft.net>
References: <1429713216.18561.82.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150422.153532.90668848178533836.davem@davemloft.net>
	<1429734048.18561.142.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, gthelen@google.com,
	rientjes@google.com, mgorman@suse.de
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35510 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751429AbbDVUYa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 16:24:30 -0400
In-Reply-To: <1429734048.18561.142.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 22 Apr 2015 13:20:48 -0700

> On Wed, 2015-04-22 at 15:35 -0400, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Wed, 22 Apr 2015 07:33:36 -0700
>> 
>> > Also, we must refrain using high order pages from the pfmemalloc
>> > reserve, so __page_frag_refill() must also use __GFP_NOMEMALLOC for
>> > them. Under memory pressure, using order-0 pages is probably the best
>> > strategy.
>>  ...
>> > @@ -348,7 +352,8 @@ static struct page *__page_frag_refill(struct netdev_alloc_cache *nc,
>> >  	gfp_t gfp = gfp_mask;
>> >  
>> >  	if (order) {
>> > -		gfp_mask |= __GFP_COMP | __GFP_NOWARN | __GFP_NORETRY;
>> > +		gfp_mask |= __GFP_COMP | __GFP_NOWARN | __GFP_NORETRY |
>> > +			    __GFP_NOMEMALLOC;
>> >  		page = alloc_pages_node(NUMA_NO_NODE, gfp_mask, order);
>> 
>> Hmmm, skbuff.h says:
>> 
>>  * @gfp_mask: allocation priority. Set __GFP_NOMEMALLOC if not for network Rx
>> 
>> But that's exactly what this __page_frag_refill() code is primarily
>> being used for, network RX, right?
>> 
>> If we believe the comment, you should not be adding the
>> __GFP_NOMEMALLOC flag here.
> 
> I do not see a problem here.
> 
> We attempt high order pages allocations only if they bring a performance
> gain. Under memory pressure, there is the high risk a whole order-3 page
> is consumed by a tiny buffer using 200 bytes but not consumed.
> 
> Only high order pages allocation attempts should request this
> __GFP_NOMEMALLOC flag set.
> 
> order-0 pages will have __GFP_MEMALLOC if requested by at least one
> socket in the host.
> 
> About __dev_alloc_pages() comment / users, they have to know if they
> need high order pages, or could fallback to order-0 ones.
> 
> We can update the comments in skbuff.h, but so far the only user has no
> need to assert __GFP_NOMEMALLOC.

Ok, thanks for explaining.   The 'order' test guarding this change didn't
register fully when I first read your patch.

I'll apply this and queue up for -stable, thanks Eric.
