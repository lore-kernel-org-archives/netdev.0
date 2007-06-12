From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH][RFC] network splice receive
Date: Tue, 12 Jun 2007 16:35:41 +0400
Message-ID: <20070612123540.GB16477@2ka.mipt.ru>
References: <20070608083853.GH7341@kernel.dk> <20070608085620.GC11488@2ka.mipt.ru> <20070608090439.GK7341@kernel.dk> <20070608135819.GA14302@2ka.mipt.ru> <20070608141452.GR7341@kernel.dk> <20070608145724.GA14561@2ka.mipt.ru> <20070608153011.GA2375@2ka.mipt.ru> <20070609063608.GX7341@kernel.dk> <20070612112950.GA16477@2ka.mipt.ru> <20070612113352.GA18832@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:50136 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751614AbXFLMgJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2007 08:36:09 -0400
Content-Disposition: inline
In-Reply-To: <20070612113352.GA18832@kernel.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 12, 2007 at 01:33:54PM +0200, Jens Axboe (jens.axboe@oracle.com) wrote:
> > I had a crashdump, where page was released via splice_to_pipe() indeed,
> > I did not investigate if it is possible to release provided page in
> > other places. I think if in future there will other slab usage cases
> > except networking receiving, that might be useful, but as is it is not
> > needed.
> 
> Read the just posted code, it has moved way beyond this :-)

It is just a side result of traditional optimization technique called 
"vim ':%s/page_cache_release/splice_page_release'" :)

> > > > and putting cloned skb into private field instead of 
> > > > original on in spd_fill_page() ends up without kernel hung.
> > > 
> > > Why? Seems pointless to allocate a clone just to hold on to the skb, a
> > > reference should be equally good. I would not be opposed to doing it
> > > this way, I just don't see what a clone buys us as compared to just
> > > holding that reference to the skb.
> > 
> > Receiving code does not expect shared skbs - too many fields are changed
> > with assumptions that it is a private copy.
> 
> Actually the main problem is that tcp_read_sock() unconditionally frees
> the skb, so it wouldn't help if we grabbed a reference to it. I've yet
> to receive an explanation of why it does so, seem awkward and violates
> the whole principle of reference counted objects. Davem??
> 
> So for now, skb_splice_bits() clones the incoming skb to avoid that. I'd
> hope we can get rid of that by fixing tcp_read_sock(), though.

It does that because it knows, that skb is not allowed to be shared
there. Similar things are being done in udp for example - code changes
internal mebers of skb, since it knows skb is not shared.

For example generic_make_request() is not allowed to change, say, 
bio->bi_sector or bi_destructor, since it does not own a block request, 
not matter what bi_cnt is. From another side, ->bi_destructor() can do
whatever it wants with bio without any check for its reference counter.

According to sk_eat_skb() - it is an optimisation to remove atomic
check.

> -- 
> Jens Axboe

-- 
	Evgeniy Polyakov
