From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: do not deplete pfmemalloc reserve
Date: Wed, 22 Apr 2015 13:20:48 -0700
Message-ID: <1429734048.18561.142.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1429661349.18561.23.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1429666344.18561.37.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1429713216.18561.82.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150422.153532.90668848178533836.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, gthelen@google.com,
	rientjes@google.com, mgorman@suse.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:33405 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753008AbbDVUUu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 16:20:50 -0400
Received: by iecrt8 with SMTP id rt8so46494466iec.0
        for <netdev@vger.kernel.org>; Wed, 22 Apr 2015 13:20:49 -0700 (PDT)
In-Reply-To: <20150422.153532.90668848178533836.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-04-22 at 15:35 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 22 Apr 2015 07:33:36 -0700
> 
> > Also, we must refrain using high order pages from the pfmemalloc
> > reserve, so __page_frag_refill() must also use __GFP_NOMEMALLOC for
> > them. Under memory pressure, using order-0 pages is probably the best
> > strategy.
>  ...
> > @@ -348,7 +352,8 @@ static struct page *__page_frag_refill(struct netdev_alloc_cache *nc,
> >  	gfp_t gfp = gfp_mask;
> >  
> >  	if (order) {
> > -		gfp_mask |= __GFP_COMP | __GFP_NOWARN | __GFP_NORETRY;
> > +		gfp_mask |= __GFP_COMP | __GFP_NOWARN | __GFP_NORETRY |
> > +			    __GFP_NOMEMALLOC;
> >  		page = alloc_pages_node(NUMA_NO_NODE, gfp_mask, order);
> 
> Hmmm, skbuff.h says:
> 
>  * @gfp_mask: allocation priority. Set __GFP_NOMEMALLOC if not for network Rx
> 
> But that's exactly what this __page_frag_refill() code is primarily
> being used for, network RX, right?
> 
> If we believe the comment, you should not be adding the
> __GFP_NOMEMALLOC flag here.

I do not see a problem here.

We attempt high order pages allocations only if they bring a performance
gain. Under memory pressure, there is the high risk a whole order-3 page
is consumed by a tiny buffer using 200 bytes but not consumed.

Only high order pages allocation attempts should request this
__GFP_NOMEMALLOC flag set.

order-0 pages will have __GFP_MEMALLOC if requested by at least one
socket in the host.

About __dev_alloc_pages() comment / users, they have to know if they
need high order pages, or could fallback to order-0 ones.

We can update the comments in skbuff.h, but so far the only user has no
need to assert __GFP_NOMEMALLOC.
