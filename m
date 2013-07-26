From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [net PATCH v2] 8139cp: Add dma_mapping_error checking
Date: Fri, 26 Jul 2013 16:42:46 -0400
Message-ID: <20130726204245.GD11633@hmsreliant.think-freely.org>
References: <1374516882-19131-1-git-send-email-nhorman@tuxdriver.com>
 <1374848918-17183-1-git-send-email-nhorman@tuxdriver.com>
 <20130726200630.GA20690@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:56293 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756470Ab3GZUm6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 16:42:58 -0400
Content-Disposition: inline
In-Reply-To: <20130726200630.GA20690@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 26, 2013 at 10:06:30PM +0200, Francois Romieu wrote:
> Neil Horman <nhorman@tuxdriver.com> :
> [...]
> > diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
> > index 0352345..ba0570a 100644
> > --- a/drivers/net/ethernet/realtek/8139cp.c
> > +++ b/drivers/net/ethernet/realtek/8139cp.c
> > @@ -533,6 +533,11 @@ rx_status_loop:
> >  
> >  		mapping = dma_map_single(&cp->pdev->dev, new_skb->data, buflen,
> >  					 PCI_DMA_FROMDEVICE);
> > +		if (dma_mapping_error(&cp->pdev->dev, mapping)) {
> > +			kfree_skb(skb);
> 
> 			dev->stats.rx_dropped++;
> 
> Sorry, I did not notice that skb contained newly received data :o/
> 
Yeah, this isn't needed.  The skb being mapped in is newly allocated, and
contains no data.  We haven't dropped anything here, so theres no need for the
stats bump.

> > +			break;
> > +		}
> > +
> [...]
> > @@ -749,6 +754,12 @@ static netdev_tx_t cp_start_xmit (struct sk_buff *skb,
> >  
> >  		len = skb->len;
> >  		mapping = dma_map_single(&cp->pdev->dev, skb->data, len, PCI_DMA_TODEVICE);
> > +		if (dma_mapping_error(&cp->pdev->dev, mapping)) {
> > +			kfree_skb(skb);
> > +			cp->dev->stats.tx_dropped++;
> > +			goto out_unlock;
> 
> These lines appear several times. You may factor them out with a
> goto out_drop or such.
> 
I may, I'm not sure its worth it.  If the item below results in a respin, then
I'l work this in as well.

> > @@ -799,6 +816,21 @@ static netdev_tx_t cp_start_xmit (struct sk_buff *skb,
> >  			mapping = dma_map_single(&cp->pdev->dev,
> >  						 skb_frag_address(this_frag),
> >  						 len, PCI_DMA_TODEVICE);
> > +			if (dma_mapping_error(&cp->pdev->dev, mapping)) {
> > +				/* Unwind the mappnigs we have */
>                                                   ^^
> 
> > +				for (frag = 0; frag+first_entry < entry; frag++) {
> > +					cp->tx_skb[frag+first_entry] = NULL;
> > +					txd = &cp->tx_ring[frag+first_entry];
> > +					this_frag = &skb_shinfo(skb)->frags[frag];
> > +					dma_unmap_single(&cp->pdev->dev, le64_to_cpu(txd->addr),
> > +							 skb_frag_size(this_frag), PCI_DMA_TODEVICE);
> > +				}
> 
> Imho, even with local &cp->pdev->dev and removal of whitespaces, it
> calls for a separate xmit_frag helper or an out of line unwinder.
> 
I'm not 100% sure its actually going to be more readable with an extra function
there.  We still have to pass in all the start points and descriptor counts, do
the machinations of iterating over two separately biased lists, and undo what
was done in this function.  I honestly kind of like it better in line, as you
can see where the values originated from, and the mapping/unmapping looks
balanced.

Thoughts?
Neil

> -- 
> Ueimor
> 
