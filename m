From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2.6.22 1/4]S2IO: Adding checks to check the return value of pci mapping function
Date: Sat, 14 Jul 2007 00:19:25 +0200
Message-ID: <20070713221925.GC18669@electric-eye.fr.zoreil.com>
References: <Pine.GSO.4.10.10707120559500.16507-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jeff@garzik.org, ssuport@neterion.com
To: Veena Parat <Veena.Parat@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:39801 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759755AbXGMWVO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jul 2007 18:21:14 -0400
Content-Disposition: inline
In-Reply-To: <Pine.GSO.4.10.10707120559500.16507-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Veena Parat <Veena.Parat@neterion.com> :
>  - Adding checks to check the return value of pci mapping function
> 
> Signed-off-by: Veena Parat <veena.parat@neterion.com>
> ---
> diff -Nurp 2.0.23.1/drivers/net/s2io.c 2.0.23.1P1/drivers/net/s2io.c
> --- 2.0.23.1/drivers/net/s2io.c	2007-07-03 08:54:02.000000000 -0700
> +++ 2.0.23.1P1/drivers/net/s2io.c	2007-07-03 11:39:24.000000000 -0700
[...]
> @@ -2236,10 +2237,19 @@ static int fill_rxd_3buf(struct s2io_nic
>  			(nic->pdev, skb->data, l3l4hdr_size + 4,
>  			PCI_DMA_FROMDEVICE);
>  
> +	if ((((struct RxD3*)rxdp)->Buffer1_ptr == 0) ||
> +		(((struct RxD3*)rxdp)->Buffer1_ptr == DMA_ERROR_CODE)) {
                                                      ^^^^^^^^^^^^^^
It does not seem to compile against current git kernel.

> @@ -2256,6 +2266,11 @@ static int fill_rxd_3buf(struct s2io_nic
>  	((struct RxD3*)rxdp)->Buffer2_ptr = pci_map_single(nic->pdev,
>  				frag_list->data, dev->mtu,
>  				PCI_DMA_FROMDEVICE);
> +	if ((((struct RxD3*)rxdp)->Buffer2_ptr == 0) ||
> +		(((struct RxD3*)rxdp)->Buffer2_ptr == DMA_ERROR_CODE)) {
> +		nic->mac_control.stats_info->sw_stat.pci_map_fail_cnt++;
> +		return -ENOMEM;
> +	}

Please sprinkle a few 'struct RxD3 *rd = (struct RxD3 *) rxdp;' here and
there. The code will look better.

>  	rxdp->Control_2 |= SET_BUFFER1_SIZE_3(l3l4hdr_size + 4);
>  	rxdp->Control_2 |= SET_BUFFER2_SIZE_3(dev->mtu);
>  
> @@ -2388,6 +2403,16 @@ static int fill_rx_buffers(struct s2io_n
>  			((struct RxD1*)rxdp)->Buffer0_ptr = pci_map_single
>  			    (nic->pdev, skb->data, size - NET_IP_ALIGN,
>  				PCI_DMA_FROMDEVICE);
> +			if ((((struct RxD1*)rxdp)->Buffer0_ptr == 0) ||
> +				(((struct RxD1*)rxdp)->Buffer0_ptr == 
> +				DMA_ERROR_CODE)) {
> +				nic->mac_control.stats_info->sw_stat.
> +					pci_map_fail_cnt++;
> +				nic->mac_control.stats_info->sw_stat.mem_freed
> +					+= skb->truesize;

A 'struct swStat *stats = &nic->mac_control.stats_info->sw_stat;' would
not hurt either.

[...]
> @@ -2644,7 +2696,8 @@ static int s2io_poll(struct net_device *
>  
>  	for (i = 0; i < config->rx_ring_num; i++) {
>  		if (fill_rx_buffers(nic, i) == -ENOMEM) {
> -			DBG_PRINT(INFO_DBG, "%s:Out of memory", dev->name);
> +			DBG_PRINT(INFO_DBG, "%s - %s:Out of memory",
> +				__FUNCTION__, dev->name);
>  			DBG_PRINT(INFO_DBG, " in Rx Poll!!\n");
>  			break;
>  		}
> @@ -2661,7 +2714,8 @@ no_rx:
>  
>  	for (i = 0; i < config->rx_ring_num; i++) {
>  		if (fill_rx_buffers(nic, i) == -ENOMEM) {
> -			DBG_PRINT(INFO_DBG, "%s:Out of memory", dev->name);
> +			DBG_PRINT(INFO_DBG, "%s - %s:Out of memory",
> +				__FUNCTION__,  dev->name);
>  			DBG_PRINT(INFO_DBG, " in Rx Poll!!\n");
>  			break;
>  		}
> @@ -2711,7 +2765,8 @@ static void s2io_netpoll(struct net_devi
>  
>  	for (i = 0; i < config->rx_ring_num; i++) {
>  		if (fill_rx_buffers(nic, i) == -ENOMEM) {
> -			DBG_PRINT(INFO_DBG, "%s:Out of memory", dev->name);
> +			DBG_PRINT(INFO_DBG, "%s - %s:Out of memory",
> +				 __FUNCTION__, dev->name);
>  			DBG_PRINT(INFO_DBG, " in Rx Netpoll!!\n");
>  			break;
>  		}

Unrelated changes.

> @@ -2792,24 +2847,27 @@ static void rx_intr_handler(struct ring_
>  				 HEADER_SNAP_SIZE,
>  				 PCI_DMA_FROMDEVICE);
>  		} else if (nic->rxd_mode == RXD_MODE_3B) {
> -			pci_dma_sync_single_for_cpu(nic->pdev, (dma_addr_t)
> +			pci_unmap_single(nic->pdev, (dma_addr_t)
>  				 ((struct RxD3*)rxdp)->Buffer0_ptr,
>  				 BUF0_LEN, PCI_DMA_FROMDEVICE);
>  			pci_unmap_single(nic->pdev, (dma_addr_t)
> +				 ((struct RxD3*)rxdp)->Buffer1_ptr,
> +				 BUF1_LEN, PCI_DMA_FROMDEVICE);
> +			pci_unmap_single(nic->pdev, (dma_addr_t)
>  				 ((struct RxD3*)rxdp)->Buffer2_ptr,
>  				 dev->mtu + 4,
>  				 PCI_DMA_FROMDEVICE);
>  		} else {
> -			pci_dma_sync_single_for_cpu(nic->pdev, (dma_addr_t)
> -					 ((struct RxD3*)rxdp)->Buffer0_ptr, BUF0_LEN,
> -					 PCI_DMA_FROMDEVICE);
>  			pci_unmap_single(nic->pdev, (dma_addr_t)
> -					 ((struct RxD3*)rxdp)->Buffer1_ptr,
> -					 l3l4hdr_size + 4,
> -					 PCI_DMA_FROMDEVICE);
> +				 ((struct RxD3*)rxdp)->Buffer0_ptr, BUF0_LEN,
> +				 PCI_DMA_FROMDEVICE);
>  			pci_unmap_single(nic->pdev, (dma_addr_t)
> -					 ((struct RxD3*)rxdp)->Buffer2_ptr,
> -					 dev->mtu, PCI_DMA_FROMDEVICE);
> +				 ((struct RxD3*)rxdp)->Buffer1_ptr,
> +				 l3l4hdr_size + 4,
> +				 PCI_DMA_FROMDEVICE);
> +			pci_unmap_single(nic->pdev, (dma_addr_t)
> +				 ((struct RxD3*)rxdp)->Buffer2_ptr,
> +				 dev->mtu, PCI_DMA_FROMDEVICE);
>  		}
>  		prefetch(skb->data);
>  		rx_osm_handler(ring_data, rxdp);
> @@ -4072,11 +4130,33 @@ static int s2io_xmit(struct sk_buff *skb
>  		txdp->Buffer_Pointer = pci_map_single(sp->pdev,
>  					sp->ufo_in_band_v,
>  					sizeof(u64), PCI_DMA_TODEVICE);
> +		if ((txdp->Buffer_Pointer == 0) ||
> +			(txdp->Buffer_Pointer == DMA_ERROR_CODE)) {
> +			sp->mac_control.stats_info->sw_stat.pci_map_fail_cnt++;
> +			netif_stop_queue(dev);
> +			sp->mac_control.stats_info->sw_stat.mem_freed += 
> +				skb->truesize;
> +			dev_kfree_skb(skb);
> +			spin_unlock_irqrestore(&sp->tx_lock, flags);
> +			return 0;
> +		}
>  		txdp++;
>  	}
>  
>  	txdp->Buffer_Pointer = pci_map_single
>  	    (sp->pdev, skb->data, frg_len, PCI_DMA_TODEVICE);
> +
> +	if ((txdp->Buffer_Pointer == 0) ||
> +		(txdp->Buffer_Pointer == DMA_ERROR_CODE)) {
> +		sp->mac_control.stats_info->sw_stat.pci_map_fail_cnt++;
> +		netif_stop_queue(dev);
> +		sp->mac_control.stats_info->sw_stat.mem_freed +=
> +			skb->truesize;
> +		dev_kfree_skb(skb);
> +		spin_unlock_irqrestore(&sp->tx_lock, flags);
> +		return 0;
> +	}

Code duplication ?

[...]
> @@ -6305,15 +6398,51 @@ static int set_rxd_buffer_pointer(struct
>  				pci_map_single(sp->pdev, (*skb)->data,
>  					       dev->mtu + 4,
>  					       PCI_DMA_FROMDEVICE);
> +			if ((((struct RxD3*)rxdp)->Buffer2_ptr == 0) ||
> +				(((struct RxD3*)rxdp)->Buffer2_ptr ==
> +				DMA_ERROR_CODE)) {
> +				sp->mac_control.stats_info->sw_stat.
> +					pci_map_fail_cnt++;
> +				sp->mac_control.stats_info->sw_stat.mem_freed +=
> +					(*skb)->truesize;
> +				dev_kfree_skb(*skb);
> +				return -ENOMEM;
> +			}
>  			((struct RxD3*)rxdp)->Buffer0_ptr = *temp0 =
>  				pci_map_single( sp->pdev, ba->ba_0, BUF0_LEN,
>  						PCI_DMA_FROMDEVICE);
> +			if ((((struct RxD3*)rxdp)->Buffer0_ptr == 0) ||
> +				(((struct RxD3*)rxdp)->Buffer0_ptr == 
> +				DMA_ERROR_CODE)) {
> +				sp->mac_control.stats_info->sw_stat.
> +					pci_map_fail_cnt++;
> +				sp->mac_control.stats_info->sw_stat.mem_freed +=
> +					(*skb)->truesize;
> +				pci_unmap_single (sp->pdev, 
> +					(dma_addr_t)(*skb)->data,
> +					dev->mtu + 4, PCI_DMA_FROMDEVICE);
> +				dev_kfree_skb(*skb);
> +				return -ENOMEM;
> +			}
>  			rxdp->Host_Control = (unsigned long) (*skb);
>  
>  			/* Buffer-1 will be dummy buffer not used */
>  			((struct RxD3*)rxdp)->Buffer1_ptr = *temp1 =
>  				pci_map_single(sp->pdev, ba->ba_1, BUF1_LEN,
>  					       PCI_DMA_FROMDEVICE);
> +			if ((((struct RxD3*)rxdp)->Buffer0_ptr == 0) ||
> +				(((struct RxD3*)rxdp)->Buffer0_ptr == 
> +				DMA_ERROR_CODE)) {
> +				sp->mac_control.stats_info->sw_stat.
> +					pci_map_fail_cnt++;
> +				sp->mac_control.stats_info->sw_stat.mem_freed +=
> +					(*skb)->truesize;
> +				pci_unmap_single (sp->pdev, 
> +					(dma_addr_t)(*skb)->data,
> +					dev->mtu + 4, PCI_DMA_FROMDEVICE);
> +				dev_kfree_skb(*skb);
> +				return -ENOMEM;
> +			}

This part should probably use gotos.

-- 
Ueimor
