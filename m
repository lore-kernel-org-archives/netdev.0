From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 10/11] cxgb3: fix DMA sync_single length error
Date: Wed, 20 Jan 2010 12:45:09 -0800
Message-ID: <20100120204559.449735359@vyatta.com>
References: <20100120204459.820265084@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:53912 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754594Ab0ATVXA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jan 2010 16:23:00 -0500
Content-Disposition: inline; filename=sge.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The DMA api requires that the full mapping be sync'd when
copying frame. First found by Jarek on sky2.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/cxgb3/sge.c	2010-01-20 11:57:01.479387584 -0800
+++ b/drivers/net/cxgb3/sge.c	2010-01-20 11:59:02.740012122 -0800
@@ -788,12 +788,15 @@ static struct sk_buff *get_packet(struct
 		if (likely(skb != NULL)) {
 			__skb_put(skb, len);
 			pci_dma_sync_single_for_cpu(adap->pdev,
-					    pci_unmap_addr(sd, dma_addr), len,
-					    PCI_DMA_FROMDEVICE);
+						    pci_unmap_addr(sd, dma_addr),
+						    fl->alloc_size,
+
+						    PCI_DMA_FROMDEVICE);
 			memcpy(skb->data, sd->skb->data, len);
 			pci_dma_sync_single_for_device(adap->pdev,
-					    pci_unmap_addr(sd, dma_addr), len,
-					    PCI_DMA_FROMDEVICE);
+						       pci_unmap_addr(sd, dma_addr),
+						       fl->alloc_size,
+						       PCI_DMA_FROMDEVICE);
 		} else if (!drop_thres)
 			goto use_orig_buf;
 recycle:

-- 

