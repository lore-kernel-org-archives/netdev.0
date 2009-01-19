From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Sun, 18 Jan 2009 22:16:03 -0800 (PST)
Message-ID: <20090118.221603.177818343.davem@davemloft.net>
References: <20090115.152608.89323697.davem@davemloft.net>
	<20090115233205.GA8474@gondor.apana.org.au>
	<20090115.153449.204259387.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: w@1wt.eu, jarkao2@gmail.com, zbr@ioremap.net, dada1@cosmosbay.com,
	ben@zeus.com, mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41522
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756964AbZASGQC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 01:16:02 -0500
In-Reply-To: <20090115.153449.204259387.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Thu, 15 Jan 2009 15:34:49 -0800 (PST)

> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Fri, 16 Jan 2009 10:32:05 +1100
> 
> > On Thu, Jan 15, 2009 at 03:26:08PM -0800, David Miller wrote:
> > > +static inline struct page *linear_to_page(struct page *page, unsigned int len,
> > > +					  unsigned int offset)
> > > +{
> > > +	struct page *p = alloc_pages(GFP_KERNEL, 0);
> > > +
> > > +	if (!p)
> > > +		return NULL;
> > > +	memcpy(page_address(p) + offset, page_address(page) + offset, len);
> > 
> > This won't work very well if skb->head is longer than a page.
> > 
> > We'll need to divide it up into individual pages.
> 
> Oh yes the same bug I pointed out the other day.
> 
> But Willy can test this patch as-is, since he is not using
> jumbo frames in linear SKBs.

Actually, Herbert, it turns out this case should be OK.

Look a level or two higher, at __splice_segment(), it even has a
comment :-)

--------------------
	do {
		unsigned int flen = min(*len, plen);

		/* the linear region may spread across several pages  */
		flen = min_t(unsigned int, flen, PAGE_SIZE - poff);

		if (spd_fill_page(spd, page, flen, poff, skb, linear))
			return 1;

		__segment_seek(&page, &poff, &plen, flen);
		*len -= flen;

	} while (*len && plen);
--------------------

That code should work and do what we need.
