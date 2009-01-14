From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Wed, 14 Jan 2009 09:54:54 +0000
Message-ID: <20090114095454.GD4234@ff.dom.local>
References: <20090113.232710.55011568.davem@davemloft.net> <20090114082630.GB16692@gondor.apana.org.au> <20090114085308.GB4234@ff.dom.local> <20090114.012919.117682429.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, zbr@ioremap.net, dada1@cosmosbay.com,
	w@1wt.eu, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f17.google.com ([209.85.219.17]:41247 "EHLO
	mail-ew0-f17.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757841AbZANJzD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 04:55:03 -0500
Content-Disposition: inline
In-Reply-To: <20090114.012919.117682429.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 14, 2009 at 01:29:19AM -0800, David Miller wrote:
...
> Therefore what I'll likely do is push Jarek's copy based cure,
> and meanwhile we can brainstorm some more on how to fix this
> properly in the long term.
> 
> So, I've put together a full commit message and Jarek's patch
> below.  One thing I notice is that the silly skb_clone() done
> by SKB splicing is no longer necessary.
> 
> We could get rid of that to offset (some) of the cost we are
> adding with this bug fix.
> 
> Comments?

Yes, this should lessen the overhead a bit.

> 
> net: Fix data corruption when splicing from sockets.
> 
> From: Jarek Poplawski <jarkao2@gmail.com>
> 
> The trick in socket splicing where we try to convert the skb->data
> into a page based reference using virt_to_page() does not work so
> well.
> 
> The idea is to pass the virt_to_page() reference via the pipe
> buffer, and refcount the buffer using a SKB reference.
> 
> But if we are splicing from a socket to a socket (via sendpage)
> this doesn't work.
> 
> The from side processing will grab the page (and SKB) references.
> The sendpage() calls will grab page references only, return, and
> then the from side processing completes and drops the SKB ref.
> 
> The page based reference to skb->data is not enough to keep the
> kmalloc() buffer backing it from being reused.  Yet, that is
> all that the socket send side has at this point.
> 
> This leads to data corruption if the skb->data buffer is reused
> by SLAB before the send side socket actually gets the TX packet
> out to the device.
> 
> The fix employed here is to simply allocate a page and copy the
> skb->data bytes into that page.
> 
> This will hurt performance, but there is no clear way to fix this
> properly without a copy at the present time, and it is important
> to get rid of the data corruption.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>

You are very brave! I'd prefer to wait for at least minimal testing
by Willy...

Thanks,
Jarek P.

BTW, an skb parameter could be removed from spd_fill_page() to make it
even faster...

...
>  static inline int spd_fill_page(struct splice_pipe_desc *spd, struct page *page,
>  				unsigned int len, unsigned int offset,
> -				struct sk_buff *skb)
> +				struct sk_buff *skb, int linear)
>  {
>  	if (unlikely(spd->nr_pages == PIPE_BUFFERS))
>  		return 1;
>  
> +	if (linear) {
> +		page = linear_to_page(page, len, offset);
> +		if (!page)
> +			return 1;
> +	}
> +
>  	spd->pages[spd->nr_pages] = page;
>  	spd->partial[spd->nr_pages].len = len;
>  	spd->partial[spd->nr_pages].offset = offset;
> -	spd->partial[spd->nr_pages].private = (unsigned long) skb_get(skb);
>  	spd->nr_pages++;
> +	get_page(page);
> +
>  	return 0;
>  }
>  
> @@ -1369,7 +1382,7 @@ static inline void __segment_seek(struct page **page, unsigned int *poff,
>  static inline int __splice_segment(struct page *page, unsigned int poff,
>  				   unsigned int plen, unsigned int *off,
>  				   unsigned int *len, struct sk_buff *skb,
> -				   struct splice_pipe_desc *spd)
> +				   struct splice_pipe_desc *spd, int linear)
>  {
>  	if (!*len)
>  		return 1;
> @@ -1392,7 +1405,7 @@ static inline int __splice_segment(struct page *page, unsigned int poff,
>  		/* the linear region may spread across several pages  */
>  		flen = min_t(unsigned int, flen, PAGE_SIZE - poff);
>  
> -		if (spd_fill_page(spd, page, flen, poff, skb))
> +		if (spd_fill_page(spd, page, flen, poff, skb, linear))
>  			return 1;
>  
>  		__segment_seek(&page, &poff, &plen, flen);
> @@ -1419,7 +1432,7 @@ static int __skb_splice_bits(struct sk_buff *skb, unsigned int *offset,
>  	if (__splice_segment(virt_to_page(skb->data),
>  			     (unsigned long) skb->data & (PAGE_SIZE - 1),
>  			     skb_headlen(skb),
> -			     offset, len, skb, spd))
> +			     offset, len, skb, spd, 1))
>  		return 1;
>  
>  	/*
> @@ -1429,7 +1442,7 @@ static int __skb_splice_bits(struct sk_buff *skb, unsigned int *offset,
>  		const skb_frag_t *f = &skb_shinfo(skb)->frags[seg];
>  
>  		if (__splice_segment(f->page, f->page_offset, f->size,
> -				     offset, len, skb, spd))
> +				     offset, len, skb, spd, 0))
>  			return 1;
>  	}
>  
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
