From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Wed, 14 Jan 2009 12:15:03 +0000
Message-ID: <20090114121503.GA6063@ff.dom.local>
References: <20090113.232710.55011568.davem@davemloft.net> <20090114082630.GB16692@gondor.apana.org.au> <20090114085308.GB4234@ff.dom.local> <20090114.012919.117682429.davem@davemloft.net> <20090114095454.GD4234@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, zbr@ioremap.net, dada1@cosmosbay.com,
	w@1wt.eu, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com, Changli Gao <xiaosuo@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f17.google.com ([209.85.219.17]:46098 "EHLO
	mail-ew0-f17.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753356AbZANMP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 07:15:28 -0500
Content-Disposition: inline
In-Reply-To: <20090114095454.GD4234@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry: take 2:

On Wed, Jan 14, 2009 at 09:54:54AM +0000, Jarek Poplawski wrote:
> On Wed, Jan 14, 2009 at 01:29:19AM -0800, David Miller wrote:
...
> > net: Fix data corruption when splicing from sockets.
> > 
> > From: Jarek Poplawski <jarkao2@gmail.com>
...
> > 
> > Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> You are very brave! I'd prefer to wait for at least minimal testing
> by Willy...

On the other hand, I can't waste your trust like this (plus I'm not
suicidal), so a little update:

Based on a review by Changli Gao <xiaosuo@gmail.com>:
http://lkml.org/lkml/2008/2/26/210

Foreseen-by: Changli Gao <xiaosuo@gmail.com>
Diagnosed-by: Willy Tarreau <w@1wt.eu>
Reported-by: Willy Tarreau <w@1wt.eu>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
Fixed-by: Jens Axboe <jens.axboe@oracle.com>

> 
> Thanks,
> Jarek P.
> 
> BTW, an skb parameter could be removed from spd_fill_page() to make it
> even faster...
> 
> ...
> >  static inline int spd_fill_page(struct splice_pipe_desc *spd, struct page *page,
> >  				unsigned int len, unsigned int offset,
> > -				struct sk_buff *skb)
> > +				struct sk_buff *skb, int linear)
> >  {
> >  	if (unlikely(spd->nr_pages == PIPE_BUFFERS))
> >  		return 1;
> >  
> > +	if (linear) {
> > +		page = linear_to_page(page, len, offset);
> > +		if (!page)
> > +			return 1;
> > +	}
> > +
> >  	spd->pages[spd->nr_pages] = page;
> >  	spd->partial[spd->nr_pages].len = len;
> >  	spd->partial[spd->nr_pages].offset = offset;
> > -	spd->partial[spd->nr_pages].private = (unsigned long) skb_get(skb);
> >  	spd->nr_pages++;
> > +	get_page(page);
> > +
> >  	return 0;
> >  }
> >  
> > @@ -1369,7 +1382,7 @@ static inline void __segment_seek(struct page **page, unsigned int *poff,
> >  static inline int __splice_segment(struct page *page, unsigned int poff,
> >  				   unsigned int plen, unsigned int *off,
> >  				   unsigned int *len, struct sk_buff *skb,
> > -				   struct splice_pipe_desc *spd)
> > +				   struct splice_pipe_desc *spd, int linear)
> >  {
> >  	if (!*len)
> >  		return 1;
> > @@ -1392,7 +1405,7 @@ static inline int __splice_segment(struct page *page, unsigned int poff,
> >  		/* the linear region may spread across several pages  */
> >  		flen = min_t(unsigned int, flen, PAGE_SIZE - poff);
> >  
> > -		if (spd_fill_page(spd, page, flen, poff, skb))
> > +		if (spd_fill_page(spd, page, flen, poff, skb, linear))
> >  			return 1;
> >  
> >  		__segment_seek(&page, &poff, &plen, flen);
> > @@ -1419,7 +1432,7 @@ static int __skb_splice_bits(struct sk_buff *skb, unsigned int *offset,
> >  	if (__splice_segment(virt_to_page(skb->data),
> >  			     (unsigned long) skb->data & (PAGE_SIZE - 1),
> >  			     skb_headlen(skb),
> > -			     offset, len, skb, spd))
> > +			     offset, len, skb, spd, 1))
> >  		return 1;
> >  
> >  	/*
> > @@ -1429,7 +1442,7 @@ static int __skb_splice_bits(struct sk_buff *skb, unsigned int *offset,
> >  		const skb_frag_t *f = &skb_shinfo(skb)->frags[seg];
> >  
> >  		if (__splice_segment(f->page, f->page_offset, f->size,
> > -				     offset, len, skb, spd))
> > +				     offset, len, skb, spd, 0))
> >  			return 1;
> >  	}
> >  
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
