From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 01/11] tg3: fix DMA sync_single length error
Date: Wed, 20 Jan 2010 12:45:00 -0800
Message-ID: <20100120204558.832256811@vyatta.com>
References: <20100120204459.820265084@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:53912 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753659Ab0ATVW7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jan 2010 16:22:59 -0500
Content-Disposition: inline; filename=tg3-dma-fix.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The DMA api requires that the full mapping be sync'd when
copying frame. First found by Jarek on sky2.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/tg3.c	2010-01-19 21:38:07.680163220 -0800
+++ b/drivers/net/tg3.c	2010-01-20 10:03:52.598977275 -0800
@@ -4653,9 +4653,13 @@ static int tg3_rx(struct tg3_napi *tnapi
 
 			skb_reserve(copy_skb, TG3_RAW_IP_ALIGN);
 			skb_put(copy_skb, len);
-			pci_dma_sync_single_for_cpu(tp->pdev, dma_addr, len, PCI_DMA_FROMDEVICE);
+			pci_dma_sync_single_for_cpu(tp->pdev, dma_addr,
+						    tp->rx_pkt_map_sz,
+						    PCI_DMA_FROMDEVICE);
 			skb_copy_from_linear_data(skb, copy_skb->data, len);
-			pci_dma_sync_single_for_device(tp->pdev, dma_addr, len, PCI_DMA_FROMDEVICE);
+			pci_dma_sync_single_for_device(tp->pdev, dma_addr,
+						       tp->rx_pkt_map_sz,
+						       PCI_DMA_FROMDEVICE);
 
 			/* We'll reuse the original ring buffer. */
 			skb = copy_skb;

-- 

