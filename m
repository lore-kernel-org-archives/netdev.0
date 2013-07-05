From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] net: convert mvneta to build_skb()
Date: Fri, 5 Jul 2013 09:43:30 +0200
Message-ID: <20130705074330.GB25188@1wt.eu>
References: <20130704173552.GA23370@1wt.eu> <20130705091752.675874b5@skate>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	Eric Dumazet <edumazet@google.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:34417 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757096Ab3GEHnd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Jul 2013 03:43:33 -0400
Content-Disposition: inline
In-Reply-To: <20130705091752.675874b5@skate>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Thomas,

On Fri, Jul 05, 2013 at 09:17:52AM +0200, Thomas Petazzoni wrote:
> > --- a/drivers/net/ethernet/marvell/mvneta.c
> > +++ b/drivers/net/ethernet/marvell/mvneta.c
> > @@ -225,6 +225,7 @@ struct mvneta_stats {
> >  
> >  struct mvneta_port {
> >  	int pkt_size;
> > +	unsigned int frag_size;
> >  	void __iomem *base;
> >  	struct mvneta_rx_queue *rxqs;
> >  	struct mvneta_tx_queue *txqs;
> 
> Thanks Willy. Sorry for asking such a stupid question, but I'm not very
> familiar with how this mechanism works. Can you explain why a single
> 'frag_size' field per port is sufficient? My concern is that this
> frag_size seems to be a per-packet information, but we have potentially
> multiple packets being received, and multiple RX queues. Is one single
> 'frag_size' per network interface sufficient?

I had the exact same question when Eric sent me an experimental patch to
do this on mv64xxx_eth a few months ago. Then I checked how the frag_size
is computed. As you can see below, it does not depend on a per-packet size
but on a per-port size which is in fact the MTU ("pkt_size" is the misleading
part here) :

      skb_size = SKB_DATA_ALIGN(pp->pkt_size + MVNETA_MH_SIZE + NET_SKB_PAD) +
                 SKB_DATA_ALIGN(sizeof(struct skb_shared_info));

So if skb_size depends solely on pp (struct mvneta_port), then it makes
sense to have frag_size stored at the same place.

In practice we don't really need to store the frag_size in the struct, we
just need to know if the data were allocated using netdev_alloc_frag()
or kmalloc() to know how to free them. So a single bit would be enough,
and I thought about just doing a +1 on the pointer when we need to free
using kmalloc(). But that would add unneeded extra work in the fast path
to fix the pointers. And since we need to pass frag_size to build_skb()
it was a reasonable solution in my opinion.

> For example, in mvneta_rx_refill(), you store the skb_size in
> pp->frag_size, and then you later re-use it in mvneta_rxq_drop_pkts.
> What guarantees you that mvneta_rx_refill() hasn't be called in the
> mean time for a different packet, in a different rxq, for the same
> network interface, and the value of pp->frag_size has been overridden?

It's not a problem since the refill() applies pp->pkt_size which doesn't
change between calls. It's only changed in mvneta_change_mtu() which
first stops the device. So I think it's safe.

> Again, sorry for this stupid question, this is maybe just some basic
> networking knowledge that I'm missing here, but I thought it would be
> good to ask anyway.

No it's neither stupid nor basic. It's a bit tricky to understand first
but it looks really nice once you get it. I think I will study the ability
to use +/-1 on the pointer and see if we can get rid of frag_size (eg: tg3
doesn't store it).

Hoping this clarifies some points,
Willy
