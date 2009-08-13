From: Dave Jones <davej@redhat.com>
Subject: Re: 8139cp dma-debug warning.
Date: Thu, 13 Aug 2009 09:45:49 -0400
Message-ID: <20090813134549.GA2845@redhat.com>
References: <20090806215702.GA17555@redhat.com> <20090812171333.GD3116@redhat.com> <20090812.222046.60033759.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:49712 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754535AbZHMNpx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Aug 2009 09:45:53 -0400
Content-Disposition: inline
In-Reply-To: <20090812.222046.60033759.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 12, 2009 at 10:20:46PM -0700, David Miller wrote:
 > From: Dave Jones <davej@redhat.com>
 > Date: Wed, 12 Aug 2009 13:13:33 -0400
 > 
 > > There's another instance of the same further in the file.
 > > 
 > > Does this look right?
 > 
 > Dave, Francois posted the following fix to lkml (he forgot
 > to CC: netdev and the people reporting this bug, oh well)

Ah, I missed it (disk crashed on friday, so I've been backlogged
since then). Thanks for the forward.

 > Did you see it?  It should fix the bug.
 > 
 > 8139cp: balance dma_map_single vs dma_unmap_single pair
 > 
 > The driver always:
 > 1. allocate cp->rx_buf_sz + NET_IP_ALIGN
 > 2. map cp->rx_buf_sz
 > 
 > Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
 > Signed-off-by: David S. Miller <davem@davemloft.net>
 > ---
 >  drivers/net/8139cp.c |    5 ++---
 >  1 files changed, 2 insertions(+), 3 deletions(-)
 > 
 > diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
 > index 50efde1..d0dbbf3 100644
 > --- a/drivers/net/8139cp.c
 > +++ b/drivers/net/8139cp.c
 > @@ -515,7 +515,7 @@ rx_status_loop:
 >  		dma_addr_t mapping;
 >  		struct sk_buff *skb, *new_skb;
 >  		struct cp_desc *desc;
 > -		unsigned buflen;
 > +		const unsigned buflen = cp->rx_buf_sz;
 >  
 >  		skb = cp->rx_skb[rx_tail];
 >  		BUG_ON(!skb);
 > @@ -549,8 +549,7 @@ rx_status_loop:
 >  			pr_debug("%s: rx slot %d status 0x%x len %d\n",
 >  			       dev->name, rx_tail, status, len);
 >  
 > -		buflen = cp->rx_buf_sz + NET_IP_ALIGN;
 > -		new_skb = netdev_alloc_skb(dev, buflen);
 > +		new_skb = netdev_alloc_skb(dev, buflen + NET_IP_ALIGN);
 >  		if (!new_skb) {
 >  			dev->stats.rx_dropped++;
 >  			goto rx_next;

Below this, we're still doing an skb_reserve(NET_IP_ALIGN) on new_skb.
Although the mapping is now constantly sized, aren't we still wastefully
bumping the data/tail of the skb twice ?

	Dave

