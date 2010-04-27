From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 5/7] ixgb: use DMA API instead of PCI DMA
	functions
Date: Tue, 27 Apr 2010 16:10:03 -0700
Message-ID: <20100427231001.26173.17582.stgit@localhost.localdomain>
References: <20100427230836.26173.59671.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Nicholas Nunley <nicholasx.d.nunley@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta15.westchester.pa.mail.comcast.net ([76.96.59.228]:41673
	"EHLO qmta15.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751501Ab0D0XK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 19:10:26 -0400
In-Reply-To: <20100427230836.26173.59671.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nick Nunley <nicholasx.d.nunley@intel.com>

Signed-off-by: Nicholas Nunley <nicholasx.d.nunley@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgb/ixgb_main.c |   70 +++++++++++++++++++++++-------------------
 1 files changed, 39 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 3cf7951..d58ca6b 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -368,16 +368,22 @@ ixgb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (err)
 		return err;
 
-	if (!(err = pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) &&
-	    !(err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64)))) {
-		pci_using_dac = 1;
+	pci_using_dac = 0;
+	err = dma_set_mask(&pdev->dev, DMA_BIT_MASK(64));
+	if (!err) {
+		err = dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(64));
+		if (!err)
+			pci_using_dac = 1;
 	} else {
-		if ((err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) ||
-		    (err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32)))) {
-			pr_err("No usable DMA configuration, aborting\n");
-			goto err_dma_mask;
+		err = dma_set_mask(&pdev->dev, DMA_BIT_MASK(32));
+		if (err) {
+			err = dma_set_coherent_mask(&pdev->dev,
+						    DMA_BIT_MASK(32));
+			if (err) {
+				pr_err("No usable DMA configuration, aborting\n");
+				goto err_dma_mask;
+			}
 		}
-		pci_using_dac = 0;
 	}
 
 	err = pci_request_regions(pdev, ixgb_driver_name);
@@ -673,7 +679,8 @@ ixgb_setup_tx_resources(struct ixgb_adapter *adapter)
 	txdr->size = txdr->count * sizeof(struct ixgb_tx_desc);
 	txdr->size = ALIGN(txdr->size, 4096);
 
-	txdr->desc = pci_alloc_consistent(pdev, txdr->size, &txdr->dma);
+	txdr->desc = dma_alloc_coherent(&pdev->dev, txdr->size, &txdr->dma,
+					GFP_KERNEL);
 	if (!txdr->desc) {
 		vfree(txdr->buffer_info);
 		netif_err(adapter, probe, adapter->netdev,
@@ -762,7 +769,8 @@ ixgb_setup_rx_resources(struct ixgb_adapter *adapter)
 	rxdr->size = rxdr->count * sizeof(struct ixgb_rx_desc);
 	rxdr->size = ALIGN(rxdr->size, 4096);
 
-	rxdr->desc = pci_alloc_consistent(pdev, rxdr->size, &rxdr->dma);
+	rxdr->desc = dma_alloc_coherent(&pdev->dev, rxdr->size, &rxdr->dma,
+					GFP_KERNEL);
 
 	if (!rxdr->desc) {
 		vfree(rxdr->buffer_info);
@@ -883,8 +891,8 @@ ixgb_free_tx_resources(struct ixgb_adapter *adapter)
 	vfree(adapter->tx_ring.buffer_info);
 	adapter->tx_ring.buffer_info = NULL;
 
-	pci_free_consistent(pdev, adapter->tx_ring.size,
-			    adapter->tx_ring.desc, adapter->tx_ring.dma);
+	dma_free_coherent(&pdev->dev, adapter->tx_ring.size,
+			  adapter->tx_ring.desc, adapter->tx_ring.dma);
 
 	adapter->tx_ring.desc = NULL;
 }
@@ -895,12 +903,11 @@ ixgb_unmap_and_free_tx_resource(struct ixgb_adapter *adapter,
 {
 	if (buffer_info->dma) {
 		if (buffer_info->mapped_as_page)
-			pci_unmap_page(adapter->pdev, buffer_info->dma,
-				       buffer_info->length, PCI_DMA_TODEVICE);
+			dma_unmap_page(&adapter->pdev->dev, buffer_info->dma,
+				       buffer_info->length, DMA_TO_DEVICE);
 		else
-			pci_unmap_single(adapter->pdev, buffer_info->dma,
-					 buffer_info->length,
-					 PCI_DMA_TODEVICE);
+			dma_unmap_single(&adapter->pdev->dev, buffer_info->dma,
+					 buffer_info->length, DMA_TO_DEVICE);
 		buffer_info->dma = 0;
 	}
 
@@ -966,7 +973,8 @@ ixgb_free_rx_resources(struct ixgb_adapter *adapter)
 	vfree(rx_ring->buffer_info);
 	rx_ring->buffer_info = NULL;
 
-	pci_free_consistent(pdev, rx_ring->size, rx_ring->desc, rx_ring->dma);
+	dma_free_coherent(&pdev->dev, rx_ring->size, rx_ring->desc,
+			  rx_ring->dma);
 
 	rx_ring->desc = NULL;
 }
@@ -990,10 +998,10 @@ ixgb_clean_rx_ring(struct ixgb_adapter *adapter)
 	for (i = 0; i < rx_ring->count; i++) {
 		buffer_info = &rx_ring->buffer_info[i];
 		if (buffer_info->dma) {
-			pci_unmap_single(pdev,
+			dma_unmap_single(&pdev->dev,
 					 buffer_info->dma,
 					 buffer_info->length,
-					 PCI_DMA_FROMDEVICE);
+					 DMA_FROM_DEVICE);
 			buffer_info->dma = 0;
 			buffer_info->length = 0;
 		}
@@ -1300,9 +1308,10 @@ ixgb_tx_map(struct ixgb_adapter *adapter, struct sk_buff *skb,
 		WARN_ON(buffer_info->dma != 0);
 		buffer_info->time_stamp = jiffies;
 		buffer_info->mapped_as_page = false;
-		buffer_info->dma = pci_map_single(pdev, skb->data + offset,
-						  size, PCI_DMA_TODEVICE);
-		if (pci_dma_mapping_error(pdev, buffer_info->dma))
+		buffer_info->dma = dma_map_single(&pdev->dev,
+						  skb->data + offset,
+						  size, DMA_TO_DEVICE);
+		if (dma_mapping_error(&pdev->dev, buffer_info->dma))
 			goto dma_error;
 		buffer_info->next_to_watch = 0;
 
@@ -1341,10 +1350,9 @@ ixgb_tx_map(struct ixgb_adapter *adapter, struct sk_buff *skb,
 			buffer_info->time_stamp = jiffies;
 			buffer_info->mapped_as_page = true;
 			buffer_info->dma =
-				pci_map_page(pdev, frag->page,
-					     offset, size,
-					     PCI_DMA_TODEVICE);
-			if (pci_dma_mapping_error(pdev, buffer_info->dma))
+				dma_map_page(&pdev->dev, frag->page,
+					     offset, size, DMA_TO_DEVICE);
+			if (dma_mapping_error(&pdev->dev, buffer_info->dma))
 				goto dma_error;
 			buffer_info->next_to_watch = 0;
 
@@ -1962,10 +1970,10 @@ ixgb_clean_rx_irq(struct ixgb_adapter *adapter, int *work_done, int work_to_do)
 		cleaned = true;
 		cleaned_count++;
 
-		pci_unmap_single(pdev,
+		dma_unmap_single(&pdev->dev,
 				 buffer_info->dma,
 				 buffer_info->length,
-				 PCI_DMA_FROMDEVICE);
+				 DMA_FROM_DEVICE);
 		buffer_info->dma = 0;
 
 		length = le16_to_cpu(rx_desc->length);
@@ -2088,10 +2096,10 @@ ixgb_alloc_rx_buffers(struct ixgb_adapter *adapter, int cleaned_count)
 		buffer_info->skb = skb;
 		buffer_info->length = adapter->rx_buffer_len;
 map_skb:
-		buffer_info->dma = pci_map_single(pdev,
+		buffer_info->dma = dma_map_single(&pdev->dev,
 		                                  skb->data,
 		                                  adapter->rx_buffer_len,
-		                                  PCI_DMA_FROMDEVICE);
+						  DMA_FROM_DEVICE);
 
 		rx_desc = IXGB_RX_DESC(*rx_ring, i);
 		rx_desc->buff_addr = cpu_to_le64(buffer_info->dma);

