From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [net PATCH] atl1e: fix dma mapping warnings
Date: Tue, 16 Jul 2013 07:12:08 -0400
Message-ID: <20130716111208.GA8940@hmsreliant.think-freely.org>
References: <1373641128-13634-1-git-send-email-nhorman@tuxdriver.com>
 <1373932877.3745.32.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59107 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753087Ab3GPLMU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jul 2013 07:12:20 -0400
Content-Disposition: inline
In-Reply-To: <1373932877.3745.32.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 16, 2013 at 01:01:17AM +0100, Ben Hutchings wrote:
> On Fri, 2013-07-12 at 10:58 -0400, Neil Horman wrote:
> [...]
> > The usual straighforward failure to check for dma_mapping_error after a map
> > operation is completed.
> [...]
> > --- a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
> > +++ b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
> > @@ -1665,7 +1665,7 @@ check_sum:
> >  	return 0;
> >  }
> >  
> > -static void atl1e_tx_map(struct atl1e_adapter *adapter,
> > +static int atl1e_tx_map(struct atl1e_adapter *adapter,
> >  		      struct sk_buff *skb, struct atl1e_tpd_desc *tpd)
> >  {
> >  	struct atl1e_tpd_desc *use_tpd = NULL;
> > @@ -1677,6 +1677,7 @@ static void atl1e_tx_map(struct atl1e_adapter *adapter,
> >  	u16 nr_frags;
> >  	u16 f;
> >  	int segment;
> > +	int ring_start = adapter->tx_ring.next_to_use;
> >  
> >  	nr_frags = skb_shinfo(skb)->nr_frags;
> >  	segment = (tpd->word3 >> TPD_SEGMENT_EN_SHIFT) & TPD_SEGMENT_EN_MASK;
> > @@ -1689,6 +1690,9 @@ static void atl1e_tx_map(struct atl1e_adapter *adapter,
> >  		tx_buffer->length = map_len;
> >  		tx_buffer->dma = pci_map_single(adapter->pdev,
> >  					skb->data, hdr_len, PCI_DMA_TODEVICE);
> > +		if (dma_mapping_error(&adapter->pdev->dev, tx_buffer->dma))
> > +			return -ENOSPC;
> > +
> 
> Odd choice of error code.
Seems fine to me, especially since its handled internally to the driver
(atl1e_xmit_frame still returns NETDEV_TX_OK to the stack).

> 
> >  		ATL1E_SET_PCIMAP_TYPE(tx_buffer, ATL1E_TX_PCIMAP_SINGLE);
> >  		mapped_len += map_len;
> >  		use_tpd->buffer_addr = cpu_to_le64(tx_buffer->dma);
> > @@ -1715,6 +1719,13 @@ static void atl1e_tx_map(struct atl1e_adapter *adapter,
> >  		tx_buffer->dma =
> >  			pci_map_single(adapter->pdev, skb->data + mapped_len,
> >  					map_len, PCI_DMA_TODEVICE);
> > +
> > +		if (dma_mapping_error(&adapter->pdev->dev, tx_buffer->dma)) {
> > +			/* Reset the tx rings next pointer */
> > +			adapter->tx_ring.next_to_use = ring_start;
> > +			return -ENOSPC;
> > +		}
> [...]
> 
> This is not enough; you also need to unmap the DMA mappings that have
> already been made.
> 
Yep, you're right, thanks for pointing that out, I'll send a followon patch.
Neil

> Ben.
> 
> -- 
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
> 
> 
