From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 02/11] sky2: fix DMA sync_single length error
Date: Wed, 20 Jan 2010 12:45:01 -0800
Message-ID: <20100120204558.901334592@vyatta.com>
References: <20100120204459.820265084@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:53912 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754623Ab0ATVW6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jan 2010 16:22:58 -0500
Content-Disposition: inline; filename=sky2-dmar-error.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>

Using pci_unmap_len(), with the same length as pci_map_single(), with
pci_dma_sync_single_for_cpu()/_device() fixes this warning (2.6.32.4):

> Jan 19 10:43:50 mail kernel: WARNING: at lib/dma-debug.c:902 
> check_sync+0xc1/0x43f()
> Jan 19 10:43:50 mail kernel: Hardware name: System Product Name
> Jan 19 10:43:50 mail kernel: sky2 0000:04:00.0: DMA-API: device driver 
> tries to sync DMA memory it has not allocated [device 
> address=0x0000000320a0b022] [size=60 bytes]  

Reported-by: Michael Breuer <mbreuer@majjas.com>
Tested-by: Michael Breuer <mbreuer@majjas.com>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
Acked-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sky2.c	2010-01-20 10:04:08.629387601 -0800
+++ b/drivers/net/sky2.c	2010-01-20 10:05:39.333941031 -0800
@@ -2252,12 +2252,14 @@ static struct sk_buff *receive_copy(stru
 	skb = netdev_alloc_skb_ip_align(sky2->netdev, length);
 	if (likely(skb)) {
 		pci_dma_sync_single_for_cpu(sky2->hw->pdev, re->data_addr,
-					    length, PCI_DMA_FROMDEVICE);
+					    pci_unmap_len(re, data_size),
+					    PCI_DMA_FROMDEVICE);
 		skb_copy_from_linear_data(re->skb, skb->data, length);
 		skb->ip_summed = re->skb->ip_summed;
 		skb->csum = re->skb->csum;
 		pci_dma_sync_single_for_device(sky2->hw->pdev, re->data_addr,
-					       length, PCI_DMA_FROMDEVICE);
+					       pci_unmap_len(re, data_size),
+					       PCI_DMA_FROMDEVICE);
 		re->skb->ip_summed = CHECKSUM_NONE;
 		skb_put(skb, length);
 	}

-- 

