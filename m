From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH] net: convert mvneta to build_skb()
Date: Fri, 5 Jul 2013 09:50:38 +0200
Message-ID: <20130705095038.018de378@skate>
References: <20130704173552.GA23370@1wt.eu>
	<20130705091752.675874b5@skate>
	<20130705074330.GB25188@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	Eric Dumazet <edumazet@google.com>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([94.23.35.102]:49060 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757099Ab3GEHuo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jul 2013 03:50:44 -0400
In-Reply-To: <20130705074330.GB25188@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Willy Tarreau,

On Fri, 5 Jul 2013 09:43:30 +0200, Willy Tarreau wrote:

> > Thanks Willy. Sorry for asking such a stupid question, but I'm not very
> > familiar with how this mechanism works. Can you explain why a single
> > 'frag_size' field per port is sufficient? My concern is that this
> > frag_size seems to be a per-packet information, but we have potentially
> > multiple packets being received, and multiple RX queues. Is one single
> > 'frag_size' per network interface sufficient?
> 
> I had the exact same question when Eric sent me an experimental patch to
> do this on mv64xxx_eth a few months ago. Then I checked how the frag_size
> is computed. As you can see below, it does not depend on a per-packet size
> but on a per-port size which is in fact the MTU ("pkt_size" is the misleading
> part here) :
> 
>       skb_size = SKB_DATA_ALIGN(pp->pkt_size + MVNETA_MH_SIZE + NET_SKB_PAD) +
>                  SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
> 
> So if skb_size depends solely on pp (struct mvneta_port), then it makes
> sense to have frag_size stored at the same place.
> 
> In practice we don't really need to store the frag_size in the struct, we
> just need to know if the data were allocated using netdev_alloc_frag()
> or kmalloc() to know how to free them. So a single bit would be enough,
> and I thought about just doing a +1 on the pointer when we need to free
> using kmalloc(). But that would add unneeded extra work in the fast path
> to fix the pointers. And since we need to pass frag_size to build_skb()
> it was a reasonable solution in my opinion.

Aah, okay makes sense. So now, the question that comes up is why this
skb_size calculation is done in every call of mvneta_rx_refill() ? It
should be computed once, at the same time pkt_size is calculated, and
stored in the mvneta_port structure? Then you just need to test whether
it is smaller or larger than PAGE_SIZE to decide whether to use
netdev_alloc_frag() vs. kmalloc().

I.e, I would turn all the:

	if (pp->frag_size)
		...
	else
		...

into:

	if (pp->skb_size <= PAGE_SIZE)
		...
	else
		...

Of course, you can always hide this test behind a small macro or inline
function, to make it something like:

	if (mvneta_uses_small_skbs(pp))
		...
	else
		...

A better name than mvneta_uses_small_skbs() would of course be useful.

> > For example, in mvneta_rx_refill(), you store the skb_size in
> > pp->frag_size, and then you later re-use it in mvneta_rxq_drop_pkts.
> > What guarantees you that mvneta_rx_refill() hasn't be called in the
> > mean time for a different packet, in a different rxq, for the same
> > network interface, and the value of pp->frag_size has been overridden?
> 
> It's not a problem since the refill() applies pp->pkt_size which doesn't
> change between calls. It's only changed in mvneta_change_mtu() which
> first stops the device. So I think it's safe.

Yeah, sure, now that I see that pp->frag_size is constant for a given
MTU configuration, it looks safe. But I find the current code that
retests and reassigns pp->frag_size at every call of rxq_refill() to be
very confusing.

Thanks!

Thomas
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
