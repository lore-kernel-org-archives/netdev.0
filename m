From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] net: convert mvneta to build_skb()
Date: Fri, 5 Jul 2013 10:09:59 +0200
Message-ID: <20130705080959.GD25188@1wt.eu>
References: <20130704173552.GA23370@1wt.eu> <20130705091752.675874b5@skate> <20130705074330.GB25188@1wt.eu> <20130705095038.018de378@skate>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	Eric Dumazet <edumazet@google.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:34421 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757169Ab3GEIKB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Jul 2013 04:10:01 -0400
Content-Disposition: inline
In-Reply-To: <20130705095038.018de378@skate>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 05, 2013 at 09:50:38AM +0200, Thomas Petazzoni wrote:
> > In practice we don't really need to store the frag_size in the struct, we
> > just need to know if the data were allocated using netdev_alloc_frag()
> > or kmalloc() to know how to free them. So a single bit would be enough,
> > and I thought about just doing a +1 on the pointer when we need to free
> > using kmalloc(). But that would add unneeded extra work in the fast path
> > to fix the pointers. And since we need to pass frag_size to build_skb()
> > it was a reasonable solution in my opinion.
> 
> Aah, okay makes sense. So now, the question that comes up is why this
> skb_size calculation is done in every call of mvneta_rx_refill() ? It
> should be computed once, at the same time pkt_size is calculated, and
> stored in the mvneta_port structure? Then you just need to test whether
> it is smaller or larger than PAGE_SIZE to decide whether to use
> netdev_alloc_frag() vs. kmalloc().
> 
> I.e, I would turn all the:
> 
> 	if (pp->frag_size)
> 		...
> 	else
> 		...
> 
> into:
> 
> 	if (pp->skb_size <= PAGE_SIZE)
> 		...
> 	else
> 		...

I was concerned by the same thing and saw that tg3 does the same. Then
I realized that we're only using constants here, so there isn't much
calculation (basically it's skb_size = pkt_size + something). However
it would probably make the code less confusing, especially if we were
two different readers concerned about this frag_size not changing per
packet.

> Of course, you can always hide this test behind a small macro or inline
> function, to make it something like:
> 
> 	if (mvneta_uses_small_skbs(pp))
> 		...
> 	else
> 		...
> 
> A better name than mvneta_uses_small_skbs() would of course be useful.
> 
> > > For example, in mvneta_rx_refill(), you store the skb_size in
> > > pp->frag_size, and then you later re-use it in mvneta_rxq_drop_pkts.
> > > What guarantees you that mvneta_rx_refill() hasn't be called in the
> > > mean time for a different packet, in a different rxq, for the same
> > > network interface, and the value of pp->frag_size has been overridden?
> > 
> > It's not a problem since the refill() applies pp->pkt_size which doesn't
> > change between calls. It's only changed in mvneta_change_mtu() which
> > first stops the device. So I think it's safe.
> 
> Yeah, sure, now that I see that pp->frag_size is constant for a given
> MTU configuration, it looks safe. But I find the current code that
> retests and reassigns pp->frag_size at every call of rxq_refill() to be
> very confusing.

Yes I agree. I think I'll experiment with the +/-1 on the pointer to
see the impact on the rest of the code, because probably that with a
few macros we could make that more transparent this way.

Best regards,
Willy
