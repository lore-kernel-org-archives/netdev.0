From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: TCP and reordering
Date: Wed, 28 Nov 2012 12:08:24 -0500
Message-ID: <20121128170824.GC19042@kvack.org>
References: <CAGK4HS8=NfcyvcNjC3h1wEjgQFCYoNeuWXj8n5Ruukeg+6j=SQ@mail.gmail.com> <1354093703.21562.23.camel@shinybook.infradead.org> <1354100552.14302.78.camel@edumazet-glaptop> <1354103355.21562.46.camel@shinybook.infradead.org> <1354105619.14302.89.camel@edumazet-glaptop> <1354106362.21562.51.camel@shinybook.infradead.org> <1354107140.14302.140.camel@edumazet-glaptop> <1354117635.21562.63.camel@shinybook.infradead.org> <20121128161930.GB19042@kvack.org> <1354120887.21562.87.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Vijay Subramanian <subramanian.vijay@gmail.com>,
	David Miller <davem@davemloft.net>, saku@ytti.fi,
	rick.jones2@hp.com, netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:35781 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754263Ab2K1RIZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Nov 2012 12:08:25 -0500
Content-Disposition: inline
In-Reply-To: <1354120887.21562.87.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 28, 2012 at 04:41:27PM +0000, David Woodhouse wrote:
> Absolutely. But in the cases where they *do* connect to the congested
> link, and the packets are backing up on the *same* host, there's no
> excuse for not actually knowing that and behaving appropriately :)

Agreed.

> And even if the congested link is somewhere upstream, you'd hope that
> something exists (like ECN) to let you know about it.
> 
> In the LNS case that I'm most familiar with, the LNS *does* know about
> the bandwidth of each customer's ADSL line, and limits the bandwidth of
> each session appropriately. It's much better to decide at the LNS which
> packets to drop, than to let the telco decide. Or worse, to have the
> ADSL link drop one ATM cell out of *every* packet when it's
> overloaded...

I'm speaking from experience: the telcos I've dealt with (2 different 
companies here in Canada) do *not* know the speed of the ADSL link being 
fed with PPPoE at the customer premises that a LAC receives as an incoming 
session.  The issue is that the aggregation network does not propagate 
that information from the DSLAM to the LAC.  It's a big mess where the 
aggregation network has a mix of ATM and L2 ethernet switches, and much 
of the gear has no support for protocols that can carry that information.

> > This sort of chaining of destructors is going to be very expensive in 
> > terms of CPU cycles.  If this does get implemented, please ensure there is 
> > a way to turn it off.
> 
> You asked that before, and I think we agreed that it would be acceptable
> to use the existing CONFIG_BQL option?

No, that would not be sufficient, as otherwise there is no means to control 
the behaviour of distribution vendor kernels -- they would most likely 
default to on.

> I'm looking at adding ppp-channel equivalents of
> netdev_{reset,sent,completed}_queue, and having the PPP channels call
> them as appropriate. For some it's trivial, but in the PPPoE/L2TP cases
> because we want to install destructors without stomping on TSQ it'll be
> substantial enough that it should be compiled out if CONFIG_BQL isn't
> enabled.

This sounds like overhead.  That said, I'd like to measure it to see what 
sort of actual effect this has on performance before passing any judgement.  
I'd be happy to put together a test setup to run anything you've come up 
with through.

> > That said, if there is local congestion, the benefits of BQL would be 
> > worthwhile to have.
> 
> If there is local congestion... *or* if you have proper bandwidth
> management on the link to the clients; either by knowing the bandwidth
> and voluntarily limiting to it, or by something like ECN.

Improved ECN support is a very good idea.

> > > But I wish there was a nicer way to chain destructors. And no, I don't
> > > count what GSO does. We can't use the cb here anyway since we're passing
> > > it down the stack.
> > 
> > I think all the tunneling protocols are going to have the same problem 
> > here, so it deserves some thought about how to tackle the issue in a 
> > generic way without incurring a large amount of overhead. 
> 
> Right. There are a few cases of skb->destructor being used at different
> levels of the stack where I suspect this might already be an issue, in
> fact. And things like TSQ will silently be losing track of packets
> because of skb_orphan, even before they've left the box.
> 
> Hah, and I note that l2tp is *already* stomping on skb->destructor for
> its own purposes. So I could potentially just use its existing callback
> and pretend I hadn't seen that it screws up TSQ, and leave the issue of
> chaining destructors to be Someone Else's Problem???.

*nod*

> Actually, I think it overwrites the destructor without calling
> skb_orphan() first ??? which will *really* upset TSQ, won't it?

Yes, that would defeat things.

> >  This exact 
> > problem is one of the reasons multilink PPP often doesn't work well over 
> > L2TP or PPPoE as compared to its behaviour over ttys.
> 
> Another fun issue with tunnelling protocols and BQL... packets tend to
> *grow* as they get encapsulated. So you might end up calling
> netdev_sent_queue() with a given size, then netdev_completed_queue()
> with a bigger packet later...

Oh fun!

Ultimately, we want to know about congestion as early as possible in the 
packet processing.  In the case of L2TP, it would be helpful to use the 
knowledge of the path the packet will be sent out on to correclty set the 
ECN bits on the packet inside the L2TP encapsulation.  The L2TP code does 
not appear to do this at present, so this needs work.

		-ben

> -- 
> dwmw2
> 



-- 
"Thought is the essence of where you are now."
