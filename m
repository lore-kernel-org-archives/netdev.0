From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 2/2] bnx2: use device model DMA API
Date: Fri, 16 Jul 2010 14:29:19 -0700
Message-ID: <1279315759.18129.43.camel@nseg_linux_HP1.broadcom.com>
References: <20100715142530.12504.80404.send-patch@dhcp-lab-109.englab.brq.redhat.com>
 <20100715142544.12504.283.send-patch@dhcp-lab-109.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Stanislaw Gruszka" <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1698 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966209Ab0GPVa5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jul 2010 17:30:57 -0400
In-Reply-To: <20100715142544.12504.283.send-patch@dhcp-lab-109.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2010-07-15 at 07:25 -0700, Stanislaw Gruszka wrote:
> Use DMA API as PCI equivalents will be deprecated. This change also allow
> to allocate with GFP_KERNEL in some places.
> 
> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>

Acked-by: Michael Chan <mchan@broadcom.com>

> ---
>  drivers/net/bnx2.c |  111 +++++++++++++++++++++++++++-------------------------
>  1 files changed, 58 insertions(+), 53 deletions(-)
> 
> diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
> index 6de4cb7..98aed05 100644
> --- a/drivers/net/bnx2.c
> +++ b/drivers/net/bnx2.c
> @@ -692,9 +692,9 @@ bnx2_free_tx_mem(struct bnx2 *bp)
>  		struct bnx2_tx_ring_info *txr = &bnapi->tx_ring;
>  
>  		if (txr->tx_desc_ring) {
> -			pci_free_consistent(bp->pdev, TXBD_RING_SIZE,
> -					    txr->tx_desc_ring,
> -					    txr->tx_desc_mapping);
> +			dma_free_coherent(&bp->pdev->dev, TXBD_RING_SIZE,
> +					  txr->tx_desc_ring,
> +					  txr->tx_desc_mapping);
>  			txr->tx_desc_ring = NULL;
>  		}
>  		kfree(txr->tx_buf_ring);
> @@ -714,9 +714,9 @@ bnx2_free_rx_mem(struct bnx2 *bp)
>  
>  		for (j = 0; j < bp->rx_max_ring; j++) {
>  			if (rxr->rx_desc_ring[j])
> -				pci_free_consistent(bp->pdev, RXBD_RING_SIZE,
> -						    rxr->rx_desc_ring[j],
> -						    rxr->rx_desc_mapping[j]);
> +				dma_free_coherent(&bp->pdev->dev, RXBD_RING_SIZE,
> +						  rxr->rx_desc_ring[j],
> +						  rxr->rx_desc_mapping[j]);
>  			rxr->rx_desc_ring[j] = NULL;
>  		}
>  		vfree(rxr->rx_buf_ring);
> @@ -724,9 +724,9 @@ bnx2_free_rx_mem(struct bnx2 *bp)
>  
>  		for (j = 0; j < bp->rx_max_pg_ring; j++) {
>  			if (rxr->rx_pg_desc_ring[j])
> -				pci_free_consistent(bp->pdev, RXBD_RING_SIZE,
> -						    rxr->rx_pg_desc_ring[j],
> -						    rxr->rx_pg_desc_mapping[j]);
> +				dma_free_coherent(&bp->pdev->dev, RXBD_RING_SIZE,
> +						  rxr->rx_pg_desc_ring[j],
> +						  rxr->rx_pg_desc_mapping[j]);
>  			rxr->rx_pg_desc_ring[j] = NULL;
>  		}
>  		vfree(rxr->rx_pg_ring);
> @@ -748,8 +748,8 @@ bnx2_alloc_tx_mem(struct bnx2 *bp)
>  			return -ENOMEM;
>  
>  		txr->tx_desc_ring =
> -			pci_alloc_consistent(bp->pdev, TXBD_RING_SIZE,
> -					     &txr->tx_desc_mapping);
> +			dma_alloc_coherent(&bp->pdev->dev, TXBD_RING_SIZE,
> +					   &txr->tx_desc_mapping, GFP_KERNEL);
>  		if (txr->tx_desc_ring == NULL)
>  			return -ENOMEM;
>  	}
> @@ -776,8 +776,10 @@ bnx2_alloc_rx_mem(struct bnx2 *bp)
>  
>  		for (j = 0; j < bp->rx_max_ring; j++) {
>  			rxr->rx_desc_ring[j] =
> -				pci_alloc_consistent(bp->pdev, RXBD_RING_SIZE,
> -						     &rxr->rx_desc_mapping[j]);
> +				dma_alloc_coherent(&bp->pdev->dev,
> +						   RXBD_RING_SIZE,
> +						   &rxr->rx_desc_mapping[j],
> +						   GFP_KERNEL);
>  			if (rxr->rx_desc_ring[j] == NULL)
>  				return -ENOMEM;
>  
> @@ -795,8 +797,10 @@ bnx2_alloc_rx_mem(struct bnx2 *bp)
>  
>  		for (j = 0; j < bp->rx_max_pg_ring; j++) {
>  			rxr->rx_pg_desc_ring[j] =
> -				pci_alloc_consistent(bp->pdev, RXBD_RING_SIZE,
> -						&rxr->rx_pg_desc_mapping[j]);
> +				dma_alloc_coherent(&bp->pdev->dev,
> +						   RXBD_RING_SIZE,
> +						   &rxr->rx_pg_desc_mapping[j],
> +						   GFP_KERNEL);
>  			if (rxr->rx_pg_desc_ring[j] == NULL)
>  				return -ENOMEM;
>  
> @@ -816,16 +820,16 @@ bnx2_free_mem(struct bnx2 *bp)
>  
>  	for (i = 0; i < bp->ctx_pages; i++) {
>  		if (bp->ctx_blk[i]) {
> -			pci_free_consistent(bp->pdev, BCM_PAGE_SIZE,
> -					    bp->ctx_blk[i],
> -					    bp->ctx_blk_mapping[i]);
> +			dma_free_coherent(&bp->pdev->dev, BCM_PAGE_SIZE,
> +					  bp->ctx_blk[i],
> +					  bp->ctx_blk_mapping[i]);
>  			bp->ctx_blk[i] = NULL;
>  		}
>  	}
>  	if (bnapi->status_blk.msi) {
> -		pci_free_consistent(bp->pdev, bp->status_stats_size,
> -				    bnapi->status_blk.msi,
> -				    bp->status_blk_mapping);
> +		dma_free_coherent(&bp->pdev->dev, bp->status_stats_size,
> +				  bnapi->status_blk.msi,
> +				  bp->status_blk_mapping);
>  		bnapi->status_blk.msi = NULL;
>  		bp->stats_blk = NULL;
>  	}
> @@ -846,8 +850,8 @@ bnx2_alloc_mem(struct bnx2 *bp)
>  	bp->status_stats_size = status_blk_size +
>  				sizeof(struct statistics_block);
>  
> -	status_blk = pci_alloc_consistent(bp->pdev, bp->status_stats_size,
> -					  &bp->status_blk_mapping);
> +	status_blk = dma_alloc_coherent(&bp->pdev->dev, bp->status_stats_size,
> +					&bp->status_blk_mapping, GFP_KERNEL);
>  	if (status_blk == NULL)
>  		goto alloc_mem_err;
>  
> @@ -885,9 +889,10 @@ bnx2_alloc_mem(struct bnx2 *bp)
>  		if (bp->ctx_pages == 0)
>  			bp->ctx_pages = 1;
>  		for (i = 0; i < bp->ctx_pages; i++) {
> -			bp->ctx_blk[i] = pci_alloc_consistent(bp->pdev,
> +			bp->ctx_blk[i] = dma_alloc_coherent(&bp->pdev->dev,
>  						BCM_PAGE_SIZE,
> -						&bp->ctx_blk_mapping[i]);
> +						&bp->ctx_blk_mapping[i],
> +						GFP_KERNEL);
>  			if (bp->ctx_blk[i] == NULL)
>  				goto alloc_mem_err;
>  		}
> @@ -2674,9 +2679,9 @@ bnx2_alloc_rx_page(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr, u16 index, gf
>  
>  	if (!page)
>  		return -ENOMEM;
> -	mapping = pci_map_page(bp->pdev, page, 0, PAGE_SIZE,
> +	mapping = dma_map_page(&bp->pdev->dev, page, 0, PAGE_SIZE,
>  			       PCI_DMA_FROMDEVICE);
> -	if (pci_dma_mapping_error(bp->pdev, mapping)) {
> +	if (dma_mapping_error(&bp->pdev->dev, mapping)) {
>  		__free_page(page);
>  		return -EIO;
>  	}
> @@ -2697,8 +2702,8 @@ bnx2_free_rx_page(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr, u16 index)
>  	if (!page)
>  		return;
>  
> -	pci_unmap_page(bp->pdev, dma_unmap_addr(rx_pg, mapping), PAGE_SIZE,
> -		       PCI_DMA_FROMDEVICE);
> +	dma_unmap_page(&bp->pdev->dev, dma_unmap_addr(rx_pg, mapping),
> +		       PAGE_SIZE, PCI_DMA_FROMDEVICE);
>  
>  	__free_page(page);
>  	rx_pg->page = NULL;
> @@ -2721,9 +2726,9 @@ bnx2_alloc_rx_skb(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr, u16 index, gfp
>  	if (unlikely((align = (unsigned long) skb->data & (BNX2_RX_ALIGN - 1))))
>  		skb_reserve(skb, BNX2_RX_ALIGN - align);
>  
> -	mapping = pci_map_single(bp->pdev, skb->data, bp->rx_buf_use_size,
> -		PCI_DMA_FROMDEVICE);
> -	if (pci_dma_mapping_error(bp->pdev, mapping)) {
> +	mapping = dma_map_single(&bp->pdev->dev, skb->data, bp->rx_buf_use_size,
> +				 PCI_DMA_FROMDEVICE);
> +	if (dma_mapping_error(&bp->pdev->dev, mapping)) {
>  		dev_kfree_skb(skb);
>  		return -EIO;
>  	}
> @@ -2829,7 +2834,7 @@ bnx2_tx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
>  			}
>  		}
>  
> -		pci_unmap_single(bp->pdev, dma_unmap_addr(tx_buf, mapping),
> +		dma_unmap_single(&bp->pdev->dev, dma_unmap_addr(tx_buf, mapping),
>  			skb_headlen(skb), PCI_DMA_TODEVICE);
>  
>  		tx_buf->skb = NULL;
> @@ -2838,7 +2843,7 @@ bnx2_tx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
>  		for (i = 0; i < last; i++) {
>  			sw_cons = NEXT_TX_BD(sw_cons);
>  
> -			pci_unmap_page(bp->pdev,
> +			dma_unmap_page(&bp->pdev->dev,
>  				dma_unmap_addr(
>  					&txr->tx_buf_ring[TX_RING_IDX(sw_cons)],
>  					mapping),
> @@ -2945,7 +2950,7 @@ bnx2_reuse_rx_skb(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr,
>  	cons_rx_buf = &rxr->rx_buf_ring[cons];
>  	prod_rx_buf = &rxr->rx_buf_ring[prod];
>  
> -	pci_dma_sync_single_for_device(bp->pdev,
> +	dma_sync_single_for_device(&bp->pdev->dev,
>  		dma_unmap_addr(cons_rx_buf, mapping),
>  		BNX2_RX_OFFSET + BNX2_RX_COPY_THRESH, PCI_DMA_FROMDEVICE);
>  
> @@ -2987,7 +2992,7 @@ bnx2_rx_skb(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr, struct sk_buff *skb,
>  	}
>  
>  	skb_reserve(skb, BNX2_RX_OFFSET);
> -	pci_unmap_single(bp->pdev, dma_addr, bp->rx_buf_use_size,
> +	dma_unmap_single(&bp->pdev->dev, dma_addr, bp->rx_buf_use_size,
>  			 PCI_DMA_FROMDEVICE);
>  
>  	if (hdr_len == 0) {
> @@ -3049,7 +3054,7 @@ bnx2_rx_skb(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr, struct sk_buff *skb,
>  				return err;
>  			}
>  
> -			pci_unmap_page(bp->pdev, mapping_old,
> +			dma_unmap_page(&bp->pdev->dev, mapping_old,
>  				       PAGE_SIZE, PCI_DMA_FROMDEVICE);
>  
>  			frag_size -= frag_len;
> @@ -3120,7 +3125,7 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
>  
>  		dma_addr = dma_unmap_addr(rx_buf, mapping);
>  
> -		pci_dma_sync_single_for_cpu(bp->pdev, dma_addr,
> +		dma_sync_single_for_cpu(&bp->pdev->dev, dma_addr,
>  			BNX2_RX_OFFSET + BNX2_RX_COPY_THRESH,
>  			PCI_DMA_FROMDEVICE);
>  
> @@ -5338,7 +5343,7 @@ bnx2_free_tx_skbs(struct bnx2 *bp)
>  				continue;
>  			}
>  
> -			pci_unmap_single(bp->pdev,
> +			dma_unmap_single(&bp->pdev->dev,
>  					 dma_unmap_addr(tx_buf, mapping),
>  					 skb_headlen(skb),
>  					 PCI_DMA_TODEVICE);
> @@ -5349,7 +5354,7 @@ bnx2_free_tx_skbs(struct bnx2 *bp)
>  			j++;
>  			for (k = 0; k < last; k++, j++) {
>  				tx_buf = &txr->tx_buf_ring[TX_RING_IDX(j)];
> -				pci_unmap_page(bp->pdev,
> +				dma_unmap_page(&bp->pdev->dev,
>  					dma_unmap_addr(tx_buf, mapping),
>  					skb_shinfo(skb)->frags[k].size,
>  					PCI_DMA_TODEVICE);
> @@ -5379,7 +5384,7 @@ bnx2_free_rx_skbs(struct bnx2 *bp)
>  			if (skb == NULL)
>  				continue;
>  
> -			pci_unmap_single(bp->pdev,
> +			dma_unmap_single(&bp->pdev->dev,
>  					 dma_unmap_addr(rx_buf, mapping),
>  					 bp->rx_buf_use_size,
>  					 PCI_DMA_FROMDEVICE);
> @@ -5732,9 +5737,9 @@ bnx2_run_loopback(struct bnx2 *bp, int loopback_mode)
>  	for (i = 14; i < pkt_size; i++)
>  		packet[i] = (unsigned char) (i & 0xff);
>  
> -	map = pci_map_single(bp->pdev, skb->data, pkt_size,
> -		PCI_DMA_TODEVICE);
> -	if (pci_dma_mapping_error(bp->pdev, map)) {
> +	map = dma_map_single(&bp->pdev->dev, skb->data, pkt_size,
> +			     PCI_DMA_TODEVICE);
> +	if (dma_mapping_error(&bp->pdev->dev, map)) {
>  		dev_kfree_skb(skb);
>  		return -EIO;
>  	}
> @@ -5772,7 +5777,7 @@ bnx2_run_loopback(struct bnx2 *bp, int loopback_mode)
>  
>  	udelay(5);
>  
> -	pci_unmap_single(bp->pdev, map, pkt_size, PCI_DMA_TODEVICE);
> +	dma_unmap_single(&bp->pdev->dev, map, pkt_size, PCI_DMA_TODEVICE);
>  	dev_kfree_skb(skb);
>  
>  	if (bnx2_get_hw_tx_cons(tx_napi) != txr->tx_prod)
> @@ -5789,7 +5794,7 @@ bnx2_run_loopback(struct bnx2 *bp, int loopback_mode)
>  	rx_hdr = rx_buf->desc;
>  	skb_reserve(rx_skb, BNX2_RX_OFFSET);
>  
> -	pci_dma_sync_single_for_cpu(bp->pdev,
> +	dma_sync_single_for_cpu(&bp->pdev->dev,
>  		dma_unmap_addr(rx_buf, mapping),
>  		bp->rx_buf_size, PCI_DMA_FROMDEVICE);
>  
> @@ -6457,8 +6462,8 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	} else
>  		mss = 0;
>  
> -	mapping = pci_map_single(bp->pdev, skb->data, len, PCI_DMA_TODEVICE);
> -	if (pci_dma_mapping_error(bp->pdev, mapping)) {
> +	mapping = dma_map_single(&bp->pdev->dev, skb->data, len, PCI_DMA_TODEVICE);
> +	if (dma_mapping_error(&bp->pdev->dev, mapping)) {
>  		dev_kfree_skb(skb);
>  		return NETDEV_TX_OK;
>  	}
> @@ -6486,9 +6491,9 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  		txbd = &txr->tx_desc_ring[ring_prod];
>  
>  		len = frag->size;
> -		mapping = pci_map_page(bp->pdev, frag->page, frag->page_offset,
> -			len, PCI_DMA_TODEVICE);
> -		if (pci_dma_mapping_error(bp->pdev, mapping))
> +		mapping = dma_map_page(&bp->pdev->dev, frag->page, frag->page_offset,
> +				       len, PCI_DMA_TODEVICE);
> +		if (dma_mapping_error(&bp->pdev->dev, mapping))
>  			goto dma_error;
>  		dma_unmap_addr_set(&txr->tx_buf_ring[ring_prod], mapping,
>  				   mapping);
> @@ -6527,7 +6532,7 @@ dma_error:
>  	ring_prod = TX_RING_IDX(prod);
>  	tx_buf = &txr->tx_buf_ring[ring_prod];
>  	tx_buf->skb = NULL;
> -	pci_unmap_single(bp->pdev, dma_unmap_addr(tx_buf, mapping),
> +	dma_unmap_single(&bp->pdev->dev, dma_unmap_addr(tx_buf, mapping),
>  			 skb_headlen(skb), PCI_DMA_TODEVICE);
>  
>  	/* unmap remaining mapped pages */
> @@ -6535,7 +6540,7 @@ dma_error:
>  		prod = NEXT_TX_BD(prod);
>  		ring_prod = TX_RING_IDX(prod);
>  		tx_buf = &txr->tx_buf_ring[ring_prod];
> -		pci_unmap_page(bp->pdev, dma_unmap_addr(tx_buf, mapping),
> +		dma_unmap_page(&bp->pdev->dev, dma_unmap_addr(tx_buf, mapping),
>  			       skb_shinfo(skb)->frags[i].size,
>  			       PCI_DMA_TODEVICE);
>  	}


