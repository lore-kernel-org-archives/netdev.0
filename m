From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC V3] net: don't wait for order-3 page allocation
Date: Thu, 18 Jun 2015 16:30:19 +0200
Message-ID: <20150618143019.GE5858@dhcp22.suse.cz>
References: <0099265406c32b9b9057de100404a4148d602cdd.1434066549.git.shli@fb.com>
 <557AA834.8070503@suse.cz>
 <alpine.DEB.2.10.1506171602300.8203@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlastimil Babka <vbabka@suse.cz>, Shaohua Li <shli@fb.com>,
	netdev@vger.kernel.org, davem@davemloft.net, Kernel-team@fb.com,
	clm@fb.com, linux-mm@kvack.org, dbavatar@gmail.com,
	Eric Dumazet <edumazet@google.com>
To: David Rientjes <rientjes@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:48019 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753000AbbFROaY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jun 2015 10:30:24 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1506171602300.8203@chino.kir.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed 17-06-15 16:02:59, David Rientjes wrote:
> On Fri, 12 Jun 2015, Vlastimil Babka wrote:
> 
> > > diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> > > index 3cfff2a..41ec022 100644
> > > --- a/net/core/skbuff.c
> > > +++ b/net/core/skbuff.c
> > > @@ -4398,7 +4398,7 @@ struct sk_buff *alloc_skb_with_frags(unsigned long
> > > header_len,
> > > 
> > >   		while (order) {
> > >   			if (npages >= 1 << order) {
> > > -				page = alloc_pages(gfp_mask |
> > > +				page = alloc_pages((gfp_mask & ~__GFP_WAIT) |
> > >   						   __GFP_COMP |
> > >   						   __GFP_NOWARN |
> > >   						   __GFP_NORETRY,
> > 
> > Note that __GFP_NORETRY is weaker than ~__GFP_WAIT and thus redundant. But it
> > won't hurt anything leaving it there. And you might consider __GFP_NO_KSWAPD
> > instead, as I said in the other thread.
> > 
> 
> Yeah, I agreed with __GFP_NO_KSWAPD to avoid utilizing memory reserves for 
> this.

Abusing __GFP_NO_KSWAPD is a wrong way to go IMHO. It is true that the
_current_ implementation of the allocator has this nasty and very subtle
side effect but that doesn't mean it should be abused outside of the mm
proper. Why shouldn't this path wake the kswapd and let it compact
memory on the background to increase the success rate for the later
high order allocations?

-- 
Michal Hocko
SUSE Labs
