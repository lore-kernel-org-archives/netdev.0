From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: TCP and reordering
Date: Wed, 28 Nov 2012 11:19:30 -0500
Message-ID: <20121128161930.GB19042@kvack.org>
References: <20121127.210611.1127622873924794001.davem@davemloft.net> <1354089566.21562.20.camel@shinybook.infradead.org> <CAGK4HS8=NfcyvcNjC3h1wEjgQFCYoNeuWXj8n5Ruukeg+6j=SQ@mail.gmail.com> <1354093703.21562.23.camel@shinybook.infradead.org> <1354100552.14302.78.camel@edumazet-glaptop> <1354103355.21562.46.camel@shinybook.infradead.org> <1354105619.14302.89.camel@edumazet-glaptop> <1354106362.21562.51.camel@shinybook.infradead.org> <1354107140.14302.140.camel@edumazet-glaptop> <1354117635.21562.63.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Vijay Subramanian <subramanian.vijay@gmail.com>,
	David Miller <davem@davemloft.net>, saku@ytti.fi,
	rick.jones2@hp.com, netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:60950 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751036Ab2K1QTc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Nov 2012 11:19:32 -0500
Content-Disposition: inline
In-Reply-To: <1354117635.21562.63.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 28, 2012 at 03:47:15PM +0000, David Woodhouse wrote:
> On Wed, 2012-11-28 at 04:52 -0800, Eric Dumazet wrote:
> > BQL is nice for high speed adapters.
> 
> For adapters with hugely deep queues, surely? There's a massive
> correlation between the two, of course ??? but PPP over L2TP or PPPoE
> ought to be included in the classification, right?

Possibly, but there are many setups where PPPoE/L2TP do not connect to 
the congested link directly.

> > For slow one, you always can stop the queue for each packet given to
> > start_xmit()
> > 
> > And restart the queue at TX completion.
> 
> Well yes, but only if we get notified of TX completion.
> 
> It's simple enough for the tty-based channels, and we can do it with a
> vcc->pop() function for PPPoATM. But for PPPoE and L2TP, how do we do
> it? We can install a skb destructor... but then we're stomping on TSQ's
> use of the destructor by orphaning it too soon.
> 
> I'm pondering something along the lines of
> 
> 	if (skb->destructor) {
> 		newskb = skb_clone(skb, GFP_KERNEL);
> 		if (newskb) {
> 	             skb_shinfo(newskb) = skb;
> 		     skb = newskb;
> 	        } 
> 	 }
> 	 skb_orphan(skb);
> 	 skb->destructor = ppp_chan_tx_completed;
> 
> 
> ... and then ppp_chan_tx_completed can also destroy the original skb
> (and hence invoke TSQ's destructor too) when the time comes. And in the
> (common?) case where we don't have an existing destructor, we don't
> bother with the skb_clone.

This sort of chaining of destructors is going to be very expensive in 
terms of CPU cycles.  If this does get implemented, please ensure there is 
a way to turn it off.  Specifically, I'm thinking of the access concetrator 
roles for BRAS.  In many wholesale ISP setups, there are many incoming 
sessions coming in over a high speed link (gigabit or greater) for which 
the access concentrator (LAC/LNS in L2TP speak) has no idea of the 
bandwidth of the link actually facing the customer.  Such systems are 
usually operated in a way to avoid ever congesting the aggregation network.  
In such setups, BQL on the L2TP/PPPoE interface only serves to increase CPU 
overhead.

That said, if there is local congestion, the benefits of BQL would be 
worthwhile to have.

> But I wish there was a nicer way to chain destructors. And no, I don't
> count what GSO does. We can't use the cb here anyway since we're passing
> it down the stack.

I think all the tunneling protocols are going to have the same problem 
here, so it deserves some thought about how to tackle the issue in a 
generic way without incurring a large amount of overhead.  This exact 
problem is one of the reasons multilink PPP often doesn't work well over 
L2TP or PPPoE as compared to its behaviour over ttys.

		-ben
-- 
"Thought is the essence of where you are now."
