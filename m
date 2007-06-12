From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [PATCH][RFC] network splice receive
Date: Tue, 12 Jun 2007 13:33:54 +0200
Message-ID: <20070612113352.GA18832@kernel.dk>
References: <20070608.010629.52902577.davem@davemloft.net> <20070608083853.GH7341@kernel.dk> <20070608085620.GC11488@2ka.mipt.ru> <20070608090439.GK7341@kernel.dk> <20070608135819.GA14302@2ka.mipt.ru> <20070608141452.GR7341@kernel.dk> <20070608145724.GA14561@2ka.mipt.ru> <20070608153011.GA2375@2ka.mipt.ru> <20070609063608.GX7341@kernel.dk> <20070612112950.GA16477@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([80.160.20.94]:29614 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754605AbXFLMIy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2007 08:08:54 -0400
Content-Disposition: inline
In-Reply-To: <20070612112950.GA16477@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 12 2007, Evgeniy Polyakov wrote:
> On Sat, Jun 09, 2007 at 08:36:09AM +0200, Jens Axboe (jens.axboe@oracle.com) wrote:
> > On Fri, Jun 08 2007, Evgeniy Polyakov wrote:
> > > On Fri, Jun 08, 2007 at 06:57:25PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> > > > I will try some things for the nearest 30-60 minutes, and then will move to
> > > > canoe trip until thuesday, so will not be able to work on this idea.
> > > 
> > > Ok, replacing in fs/splice.c every page_cache_release() with
> > > static void splice_page_release(struct page *p)
> > > {
> > > 	if (!PageSlab(p))
> > > 		page_cache_release(p);
> > > }
> > 
> > Ehm, I don't see why that should be necessary. Except in
> > splice_to_pipe(), I have considered that we need to pass in a release
> > function if mapping fails at some point. But it's probably best to do
> > that in the caller, since they have the knowledge of how to release the
> > pages.
> > 
> > The rest of the PageSlab() tests are bogus.
> 
> I had a crashdump, where page was released via splice_to_pipe() indeed,
> I did not investigate if it is possible to release provided page in
> other places. I think if in future there will other slab usage cases
> except networking receiving, that might be useful, but as is it is not
> needed.

Read the just posted code, it has moved way beyond this :-)

> > > and putting cloned skb into private field instead of 
> > > original on in spd_fill_page() ends up without kernel hung.
> > 
> > Why? Seems pointless to allocate a clone just to hold on to the skb, a
> > reference should be equally good. I would not be opposed to doing it
> > this way, I just don't see what a clone buys us as compared to just
> > holding that reference to the skb.
> 
> Receiving code does not expect shared skbs - too many fields are changed
> with assumptions that it is a private copy.

Actually the main problem is that tcp_read_sock() unconditionally frees
the skb, so it wouldn't help if we grabbed a reference to it. I've yet
to receive an explanation of why it does so, seem awkward and violates
the whole principle of reference counted objects. Davem??

So for now, skb_splice_bits() clones the incoming skb to avoid that. I'd
hope we can get rid of that by fixing tcp_read_sock(), though.

-- 
Jens Axboe

