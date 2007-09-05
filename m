From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] 3c59x: sparse warning fix
Date: Wed, 5 Sep 2007 23:46:18 +0100
Message-ID: <20070905234618.4427616e@oldman>
References: <20070905152359.26215f89@oldman>
	<1189011425.13308.30.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: klassert@mathematik.tu-chemnitz.de, Jeff Garzik <jeff@garzik.org>,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:43540 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755140AbXIEWqZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2007 18:46:25 -0400
In-Reply-To: <1189011425.13308.30.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 05 Sep 2007 09:57:05 -0700
Joe Perches <joe@perches.com> wrote:

> On Wed, 2007-09-05 at 15:23 +0100, Stephen Hemminger wrote:
> > --- a/drivers/net/3c59x.c	2007-09-05 15:15:16.000000000 +0100
> > +++ b/drivers/net/3c59x.c	2007-09-05 15:16:29.000000000 +0100
> > @@ -1122,7 +1122,7 @@ static int __devinit vortex_probe1(struc
> >  					   + sizeof(struct boom_tx_desc) * TX_RING_SIZE,
> >  					   &vp->rx_ring_dma);
> >  	retval = -ENOMEM;
> > -	if (vp->rx_ring == 0)
> > +	if (!vp->rx_ring)
> >  		goto free_region;
> >  
> >  	vp->tx_ring = (struct boom_tx_desc *)(vp->rx_ring + RX_RING_SIZE);
> > @@ -2476,7 +2476,8 @@ boomerang_rx(struct net_device *dev)
> >  
> >  			/* Check if the packet is long enough to just accept without
> >  			   copying to a properly sized skbuff. */
> > -			if (pkt_len < rx_copybreak && (skb = dev_alloc_skb(pkt_len + 2)) != 0) {
> > +			if (pkt_len < rx_copybreak &&
> > +			    (skb = dev_alloc_skb(pkt_len + 2)) ) {
> >  				skb_reserve(skb, 2);	/* Align IP on 16 byte boundaries */
> >  				pci_dma_sync_single_for_cpu(VORTEX_PCI(vp), dma, PKT_BUF_SZ, PCI_DMA_FROMDEVICE);
> >  				/* 'skb_put()' points to the start of sk_buff data area. */
> 
> Shouldn't this be:
> 
> 	if (pkt_len < rx_copybreak) {
> 		skb = dev_alloc_skb(pkt_len + 2);
> 		if (!skb) {
> 			bad_news! (like the refill rx ring buffers block)
> 		}

No, the existing code path does the right thing, and if skb can't be allocated
it just reuses the existing one. Having a single error recovery path (for out of
memory) is preferable to two paths.
