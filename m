From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Tue, 3 Feb 2009 12:36:28 +0000
Message-ID: <20090203123628.GB4639@ff.dom.local>
References: <20090202080855.GA4129@ff.dom.local> <20090202.001854.261399333.davem@davemloft.net> <20090202084358.GB4129@ff.dom.local> <20090202.235017.253437221.davem@davemloft.net> <20090203094108.GA4639@ff.dom.local> <20090203111012.GA16878@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	w@1wt.eu, dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f21.google.com ([209.85.219.21]:65350 "EHLO
	mail-ew0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751726AbZBCMgg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2009 07:36:36 -0500
Content-Disposition: inline
In-Reply-To: <20090203111012.GA16878@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 03, 2009 at 02:10:12PM +0300, Evgeniy Polyakov wrote:
> On Tue, Feb 03, 2009 at 09:41:08AM +0000, Jarek Poplawski (jarkao2@gmail.com) wrote:
> > > 1) Just like any other allocator we'll need to find a way to
> > >    handle > PAGE_SIZE allocations, and thus add handling for
> > >    compound pages etc.
> > >  
> > >    And exactly the drivers that want such huge SKB data areas
> > >    on receive should be converted to use scatter gather page
> > >    vectors in order to avoid multi-order pages and thus strains
> > >    on the page allocator.
> > 
> > I guess compound pages are handled by put_page() enough, but I don't
> > think they should be main argument here, and I agree: scatter gather
> > should be used where possible.
> 
> Problem is to allocate them, since with the time memory will be
> quite fragmented, which will not allow to find a big enough page.

Yes, it's a problem, but I don't think the main one. Since we're
currently concerned with zero-copy for splice I think we could
concentrate on most common cases, and treat jumbo frames with best
effort only: if there are free compound pages - fine, otherwise we
fallback to slab and copy in splice.

> 
> NTA tried to solve this by not allowing to free the data allocated on
> the different CPU, contrary to what SLAB does. Modulo cache coherency
> improvements, it allows to combine freed chunks back into the pages and
> combine them in turn to get bigger contiguous areas suitable for the
> drivers which were not converted to use the scatter gather approach.
> I even believe that for some hardware it is the only way to deal
> with the jumbo frames.
> 
> > > 2) Space wastage and poor packing can be an issue.
> > > 
> > >    Even with SLAB/SLUB we get poor packing, look at Evegeniy's
> > >    graphs that he made when writing his NTA patches.
> > 
> > I'm a bit lost here: could you "remind" the way page space would be
> > used/saved in your paged variant e.g. for ~1500B skbs?
> 
> At least in NTA I used cache line alignment for smaller chunks, while
> SLAB uses power of two. Thus for 1500 MTU SLAB wastes about 500 bytes
> per packet (modulo size of the shared info structure).
> 
> > Yes, this looks reasonable. On the other hand, I think it would be
> > nice to get some opinions of slab folks (incl. Evgeniy) on the expected
> > efficiency of such a solution. (It seems releasing with put_page() will
> > always have some cost with delayed reusing and/or waste of space.)
> 
> Well, my opinion is rather biased here :)

I understand NTA could be better than slabs in above-mentioned cases,
but I'm not sure you explaind enough your point on solving this
zero-copy problem vs. NTA?

Jarek P.
