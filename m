From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH][RFC] network splice receive
Date: Tue, 12 Jun 2007 17:11:53 +0400
Message-ID: <20070612131153.GC16477@2ka.mipt.ru>
References: <20070608090439.GK7341@kernel.dk> <20070608135819.GA14302@2ka.mipt.ru> <20070608141452.GR7341@kernel.dk> <20070608145724.GA14561@2ka.mipt.ru> <20070608153011.GA2375@2ka.mipt.ru> <20070609063608.GX7341@kernel.dk> <20070612112950.GA16477@2ka.mipt.ru> <20070612113352.GA18832@kernel.dk> <20070612123540.GB16477@2ka.mipt.ru> <20070612124005.GC18832@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:36217 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755230AbXFLNMX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2007 09:12:23 -0400
Content-Disposition: inline
In-Reply-To: <20070612124005.GC18832@kernel.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 12, 2007 at 02:40:05PM +0200, Jens Axboe (jens.axboe@oracle.com) wrote:
> On Tue, Jun 12 2007, Evgeniy Polyakov wrote:
> > > > > > and putting cloned skb into private field instead of 
> > > > > > original on in spd_fill_page() ends up without kernel hung.
> > > > > 
> > > > > Why? Seems pointless to allocate a clone just to hold on to the skb, a
> > > > > reference should be equally good. I would not be opposed to doing it
> > > > > this way, I just don't see what a clone buys us as compared to just
> > > > > holding that reference to the skb.
> > > > 
> > > > Receiving code does not expect shared skbs - too many fields are changed
> > > > with assumptions that it is a private copy.
> > > 
> > > Actually the main problem is that tcp_read_sock() unconditionally frees
> > > the skb, so it wouldn't help if we grabbed a reference to it. I've yet
> > > to receive an explanation of why it does so, seem awkward and violates
> > > the whole principle of reference counted objects. Davem??
> > > 
> > > So for now, skb_splice_bits() clones the incoming skb to avoid that. I'd
> > > hope we can get rid of that by fixing tcp_read_sock(), though.
> > 
> > It does that because it knows, that skb is not allowed to be shared
> > there. Similar things are being done in udp for example - code changes
> > internal mebers of skb, since it knows skb is not shared.
> > 
> > For example generic_make_request() is not allowed to change, say, 
> > bio->bi_sector or bi_destructor, since it does not own a block request, 
> > not matter what bi_cnt is. From another side, ->bi_destructor() can do
> > whatever it wants with bio without any check for its reference counter.
> 
> But generic_make_request() DOES change ->bi_sector, that's how partition
> remapping works :-). The destructor can of course do whatever it wants,
> by definition the bio is not referenced at that point (or it would not
> have been called). So while I think your analogy is quite poor, I do now
> follow the code (even if I think it's ugly). There's quite a big

Yeah, that was quite long time ago I hacked block layer :)
Good we found a way to explain the issue.

> difference between changing parts of the elements of a structure to just
> grabbing a reference to it. If the skb cannot be referenced, skb_get()
> should return NULL.
> 
> But that aside, I see the issue. I'll just stick to the clone, it works
> fine as-is (well almost, there's a leak there, but functionally it's
> ok!).

Btw, is it allowed to use splice from network with, say, nfs?
Since RPC code uses sk_user_data as long as network splice.

> -- 
> Jens Axboe

-- 
	Evgeniy Polyakov
