From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: Re: [PATCH] solos-pci: don't call vcc->pop() after pclose()
Date: Thu, 29 Nov 2012 14:20:21 +0100
Message-ID: <20121129132021.GA15425@shrek.podlesie.net>
References: <1354036592.2534.6.camel@shinybook.infradead.org>
 <20121127173906.GA11390@shrek.podlesie.net>
 <1354039349.2534.11.camel@shinybook.infradead.org>
 <20121127135434.0728cd4f@thirdoffive.cmf.nrl.navy.mil>
 <AE90C24D6B3A694183C094C60CF0A2F6026B70C9@saturn3.aculab.com>
 <1354141115.21562.101.camel@shinybook.infradead.org>
 <20121129105715.GA10226@shrek.podlesie.net>
 <1354190143.21562.145.camel@shinybook.infradead.org>
 <20121129124344.GA7704@shrek.podlesie.net>
 <1354193837.21562.159.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@ACULAB.COM>,
	chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, nathan@traverse.com.au
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shrek-wifi.podlesie.net ([93.179.225.50]:59239 "EHLO
	shrek.podlesie.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751155Ab2K2NUZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 08:20:25 -0500
Content-Disposition: inline
In-Reply-To: <1354193837.21562.159.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 29, 2012 at 12:57:17PM +0000, David Woodhouse wrote:
> On Thu, 2012-11-29 at 13:43 +0100, Krzysztof Mazur wrote:
> > 
> > Removing packets from tx_queue is not needed. We can transmit packets
> > also after close. We just can't call vcc->pop() after close,
> > so we can just set SKB_CB(skb)->vcc of such packets to NULL so
> > fpga_tx() won't call vcc->pop().
> 
> Your patch doesn't do that, does it? You'd want something like
> 
>  if (card->tx_skb[port] && SKB_CB(card->tx_skb[port]->vcc) == vcc)
>     SKB_CB(card->tx_skb[port]->vcc) = NULL;

No, I want to process all queued packets, not just only those that
were already sent do card.

In that case we will need to remove other packets with that vcc
from queue, of couse we can still do that in the same loop, something
like:

	if (SKB_CB(skb)->vcc == vcc) {
		if (card->tx_skb[port] == skb) {
			skb_get(skb);
			solos_pop(SKB_CB(skb)->vcc, skb);
			SKB_CB(skb)->vcc = NULL;
		} else {
			skb_unlink(skb, &card->tx_queue[port]);
			solos_pop(SKB_CB(skb)->vcc, skb);
		}
	}

But I don't think that this optization is needed.

> 
> Under card->tx_lock should suffice.
> 
> And do we just *not* call the ->pop() on that skb ever? And hope that it
> doesn't screw up some other state somewhere? Like if we're doing MLPPP
> and I've implemented BQL for PPP... we might never call
> ppp_completed_queue() for that skb, so even though this *channel* is
> going away, it might still contribute towards the perceived queue on the
> overall PPP netdev?
> 
> Failing to call ->pop() could cause memory leaks and other issues; I
> don't think it's reasonable. I think we *have* to wait for
> card->tx_skb[port] if it's for the VCC we're closing.

We are calling ->pop() in solos_pop() just before SKB_CB(skb)->vcc = NULL,
but we are doing that before we really finish processing that packet,
that's why we do skb_get(skb).

Krzysiek
