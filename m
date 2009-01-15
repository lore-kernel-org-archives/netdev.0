From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Fri, 16 Jan 2009 00:03:31 +0100
Message-ID: <20090115230331.GB1123@1wt.eu>
References: <20090113.232710.55011568.davem@davemloft.net> <20090114082630.GB16692@gondor.apana.org.au> <20090114085308.GB4234@ff.dom.local> <20090114.012919.117682429.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jarkao2@gmail.com, herbert@gondor.apana.org.au, zbr@ioremap.net,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1511 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936283AbZAOXEL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2009 18:04:11 -0500
Content-Disposition: inline
In-Reply-To: <20090114.012919.117682429.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 14, 2009 at 01:29:19AM -0800, David Miller wrote:
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

David,

please don't merge it as-is. I've just tried it and got an OOM
in __alloc_pages_internal after a few seconds of data transfer.

I'm leaving the patch below for comments, maybe someone will spot
something ? Don't we need at least one kfree() somewhere to match
alloc_pages() ?

Regards,
Willy

--

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
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 5110b35..6e43d52 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -73,17 +73,13 @@ static struct kmem_cache *skbuff_fclone_cache __read_mostly;
>  static void sock_pipe_buf_release(struct pipe_inode_info *pipe,
>  				  struct pipe_buffer *buf)
>  {
> -	struct sk_buff *skb = (struct sk_buff *) buf->private;
> -
> -	kfree_skb(skb);
> +	put_page(buf->page);
>  }
>  
>  static void sock_pipe_buf_get(struct pipe_inode_info *pipe,
>  				struct pipe_buffer *buf)
>  {
> -	struct sk_buff *skb = (struct sk_buff *) buf->private;
> -
> -	skb_get(skb);
> +	get_page(buf->page);
>  }
>  
>  static int sock_pipe_buf_steal(struct pipe_inode_info *pipe,
> @@ -1334,9 +1330,19 @@ fault:
>   */
>  static void sock_spd_release(struct splice_pipe_desc *spd, unsigned int i)
>  {
> -	struct sk_buff *skb = (struct sk_buff *) spd->partial[i].private;
> +	put_page(spd->pages[i]);
> +}
>  
> -	kfree_skb(skb);
> +static inline struct page *linear_to_page(struct page *page, unsigned int len,
> +					  unsigned int offset)
> +{
> +	struct page *p = alloc_pages(GFP_KERNEL, 0);
> +
> +	if (!p)
> +		return NULL;
> +	memcpy(page_address(p) + offset, page_address(page) + offset, len);
> +
> +	return p;
>  }
>  
>  /*
> @@ -1344,16 +1350,23 @@ static void sock_spd_release(struct splice_pipe_desc *spd, unsigned int i)
>   */
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
