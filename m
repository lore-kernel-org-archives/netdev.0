From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC V3] net: don't wait for order-3 page allocation
Date: Wed, 17 Jun 2015 16:02:59 -0700 (PDT)
Message-ID: <alpine.DEB.2.10.1506171602300.8203@chino.kir.corp.google.com>
References: <0099265406c32b9b9057de100404a4148d602cdd.1434066549.git.shli@fb.com> <557AA834.8070503@suse.cz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Shaohua Li <shli@fb.com>, netdev@vger.kernel.org,
	davem@davemloft.net, Kernel-team@fb.com, clm@fb.com,
	linux-mm@kvack.org, dbavatar@gmail.com,
	Eric Dumazet <edumazet@google.com>
To: Vlastimil Babka <vbabka@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:35715 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751120AbbFQXDD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 19:03:03 -0400
Received: by igbzc4 with SMTP id zc4so114821464igb.0
        for <netdev@vger.kernel.org>; Wed, 17 Jun 2015 16:03:02 -0700 (PDT)
In-Reply-To: <557AA834.8070503@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 12 Jun 2015, Vlastimil Babka wrote:

> > diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> > index 3cfff2a..41ec022 100644
> > --- a/net/core/skbuff.c
> > +++ b/net/core/skbuff.c
> > @@ -4398,7 +4398,7 @@ struct sk_buff *alloc_skb_with_frags(unsigned long
> > header_len,
> > 
> >   		while (order) {
> >   			if (npages >= 1 << order) {
> > -				page = alloc_pages(gfp_mask |
> > +				page = alloc_pages((gfp_mask & ~__GFP_WAIT) |
> >   						   __GFP_COMP |
> >   						   __GFP_NOWARN |
> >   						   __GFP_NORETRY,
> 
> Note that __GFP_NORETRY is weaker than ~__GFP_WAIT and thus redundant. But it
> won't hurt anything leaving it there. And you might consider __GFP_NO_KSWAPD
> instead, as I said in the other thread.
> 

Yeah, I agreed with __GFP_NO_KSWAPD to avoid utilizing memory reserves for 
this.

> > diff --git a/net/core/sock.c b/net/core/sock.c
> > index 292f422..e9855a4 100644
> > --- a/net/core/sock.c
> > +++ b/net/core/sock.c
> > @@ -1883,7 +1883,7 @@ bool skb_page_frag_refill(unsigned int sz, struct
> > page_frag *pfrag, gfp_t gfp)
> > 
> >   	pfrag->offset = 0;
> >   	if (SKB_FRAG_PAGE_ORDER) {
> > -		pfrag->page = alloc_pages(gfp | __GFP_COMP |
> > +		pfrag->page = alloc_pages((gfp & ~__GFP_WAIT) | __GFP_COMP |
> >   					  __GFP_NOWARN | __GFP_NORETRY,
> >   					  SKB_FRAG_PAGE_ORDER);
> >   		if (likely(pfrag->page)) {
> > 
