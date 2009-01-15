From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Fri, 16 Jan 2009 10:19:35 +1100
Message-ID: <20090115231934.GA8328@gondor.apana.org.au>
References: <20090113.232710.55011568.davem@davemloft.net> <20090114082630.GB16692@gondor.apana.org.au> <20090114085308.GB4234@ff.dom.local> <20090114.012919.117682429.davem@davemloft.net> <20090115230331.GB1123@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jarkao2@gmail.com,
	zbr@ioremap.net, dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53579 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753782AbZAOXUR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 18:20:17 -0500
Content-Disposition: inline
In-Reply-To: <20090115230331.GB1123@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 16, 2009 at 12:03:31AM +0100, Willy Tarreau wrote:
> 
> I'm leaving the patch below for comments, maybe someone will spot
> something ? Don't we need at least one kfree() somewhere to match
> alloc_pages() ?

Indeed.

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

This get_page needs to be moved into an else clause of the previous
if block.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
