From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 5/6] e1000e: error handling for pci_map_single calls.
Date: Tue, 14 Aug 2007 01:15:37 -0400
Message-ID: <46C13A79.6050009@garzik.org>
References: <20070810200038.21509.77815.stgit@localhost.localdomain> <20070810200102.21509.97953.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	andi@firstfloor.org
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41947 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753767AbXHNFPi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 01:15:38 -0400
In-Reply-To: <20070810200102.21509.97953.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> index d14cc4b..0e80406 100644
> --- a/drivers/net/e1000e/ethtool.c
> +++ b/drivers/net/e1000e/ethtool.c
> @@ -1042,6 +1044,10 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
>  		tx_ring->buffer_info[i].dma =
>  			pci_map_single(pdev, skb->data, skb->len,
>  				       PCI_DMA_TODEVICE);
> +		if (pci_dma_mapping_error(tx_ring->buffer_info[i].dma)) {
> +			ret_val = 4;
> +			goto err_nomem;
> +		}
>  		tx_desc->buffer_addr = cpu_to_le64(
>  					 tx_ring->buffer_info[i].dma);
>  		tx_desc->lower.data = cpu_to_le32(skb->len);
> @@ -1059,7 +1065,7 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
>  	size = rx_ring->count * sizeof(struct e1000_buffer);
>  	rx_ring->buffer_info = kmalloc(size, GFP_KERNEL);
>  	if (!rx_ring->buffer_info) {
> -		ret_val = 4;
> +		ret_val = 5;
>  		goto err_nomem;
>  	}
>  	memset(rx_ring->buffer_info, 0, size);
> @@ -1068,7 +1074,7 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
>  	rx_ring->desc = dma_alloc_coherent(&pdev->dev, rx_ring->size,
>  					   &rx_ring->dma, GFP_KERNEL);
>  	if (!rx_ring->desc) {
> -		ret_val = 5;
> +		ret_val = 6;
>  		goto err_nomem;
>  	}
>  	memset(rx_ring->desc, 0, rx_ring->size);
> @@ -1093,7 +1099,7 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
>  
>  		skb = alloc_skb(2048 + NET_IP_ALIGN, GFP_KERNEL);
>  		if (!skb) {
> -			ret_val = 6;
> +			ret_val = 7;
>  			goto err_nomem;
>  		}
>  		skb_reserve(skb, NET_IP_ALIGN);
> @@ -1101,6 +1107,10 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
>  		rx_ring->buffer_info[i].dma =
>  			pci_map_single(pdev, skb->data, 2048,
>  				       PCI_DMA_FROMDEVICE);
> +		if (pci_dma_mapping_error(rx_ring->buffer_info[i].dma)) {
> +			ret_val = 8;
> +			goto err_nomem;
> +		}
>  		rx_desc->buffer_addr =
>  			cpu_to_le64(rx_ring->buffer_info[i].dma);
>  		memset(skb->data, 0x00, skb->len);


this function is a bit fragile if two additional error checks cause a 
'ret_val' ripple effect throughout the function.


> diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
> index 51c9024..8ebe238 100644
> --- a/drivers/net/e1000e/netdev.c
> +++ b/drivers/net/e1000e/netdev.c
> @@ -195,6 +195,11 @@ map_skb:
>  		buffer_info->dma = pci_map_single(pdev, skb->data,
>  						  adapter->rx_buffer_len,
>  						  PCI_DMA_FROMDEVICE);
> +		if (pci_dma_mapping_error(buffer_info->dma)) {
> +			dev_err(&pdev->dev, "RX DMA map failed\n");
> +			adapter->rx_dma_failed++;
> +			break;
> +		}
>  
>  		rx_desc = E1000_RX_DESC(*rx_ring, i);
>  		rx_desc->buffer_addr = cpu_to_le64(buffer_info->dma);
> @@ -255,6 +260,13 @@ static void e1000_alloc_rx_buffers_ps(struct e1000_adapter *adapter,
>  							   ps_page->page,
>  							   0, PAGE_SIZE,
>  							   PCI_DMA_FROMDEVICE);
> +					if (pci_dma_mapping_error(
> +							ps_page->dma)) {
> +						dev_err(&adapter->pdev->dev,
> +						  "RX DMA page map failed\n");
> +						adapter->rx_dma_failed++;
> +						goto no_buffers;
> +					}
>  				}
>  				/*
>  				 * Refresh the desc even if buffer_addrs
> @@ -286,6 +298,14 @@ static void e1000_alloc_rx_buffers_ps(struct e1000_adapter *adapter,
>  		buffer_info->dma = pci_map_single(pdev, skb->data,
>  						  adapter->rx_ps_bsize0,
>  						  PCI_DMA_FROMDEVICE);
> +		if (pci_dma_mapping_error(buffer_info->dma)) {
> +			dev_err(&pdev->dev, "RX DMA map failed\n");
> +			adapter->rx_dma_failed++;
> +			/* cleanup skb */
> +			dev_kfree_skb_any(skb);
> +			buffer_info->skb = NULL;
> +			break;
> +		}
>  
>  		rx_desc->read.buffer_addr[0] = cpu_to_le64(buffer_info->dma);
>  
> @@ -374,6 +394,11 @@ check_page:
>  							buffer_info->page, 0,
>  							PAGE_SIZE,
>  							PCI_DMA_FROMDEVICE);
> +		if (pci_dma_mapping_error(buffer_info->dma)) {
> +			dev_err(&adapter->pdev->dev, "RX DMA page map failed\n");
> +			adapter->rx_dma_failed++;
> +			break;
> +		}
>  
>  		rx_desc = E1000_RX_DESC(*rx_ring, i);
>  		rx_desc->buffer_addr = cpu_to_le64(buffer_info->dma);
> @@ -3214,6 +3239,11 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
>  				skb->data + offset,
>  				size,
>  				PCI_DMA_TODEVICE);
> +		if (pci_dma_mapping_error(buffer_info->dma)) {
> +			dev_err(&adapter->pdev->dev, "TX DMA map failed\n");
> +			adapter->tx_dma_failed++;
> +			return -1;
> +		}
>  		buffer_info->next_to_watch = i;
>  
>  		len -= size;
> @@ -3247,6 +3277,13 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
>  					offset,
>  					size,
>  					PCI_DMA_TODEVICE);
> +			if (pci_dma_mapping_error(buffer_info->dma)) {
> +				dev_err(&adapter->pdev->dev,
> +					"TX DMA page map failed\n");
> +				adapter->tx_dma_failed++;
> +				return -1;
> +			}
> +
>  			buffer_info->next_to_watch = i;
>  
>  			len -= size;
> @@ -3512,9 +3549,15 @@ static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
>  	if (skb->protocol == htons(ETH_P_IP))
>  		tx_flags |= E1000_TX_FLAGS_IPV4;
>  
> -	e1000_tx_queue(adapter, tx_flags,
> -		       e1000_tx_map(adapter, skb, first,
> -				    max_per_txd, nr_frags, mss));
> +	count = e1000_tx_map(adapter, skb, first, max_per_txd, nr_frags, mss);
> +	if (count < 0) {
> +		/* handle pci_map_single() error in e1000_tx_map */
> +		dev_kfree_skb_any(skb);
> +		spin_unlock_irqrestore(&adapter->tx_queue_lock, irq_flags);
> +		return NETDEV_TX_BUSY;
> +	}
> +
> +	e1000_tx_queue(adapter, tx_flags, count);

are you really supposed to free the skb, if you are returning 
NETDEV_TX_BUSY?  My memory is rusty but that seems strange

