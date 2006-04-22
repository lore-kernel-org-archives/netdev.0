From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 09/11] ixgb: Add performance enhancements to the buffer_info struct
Date: Fri, 21 Apr 2006 18:00:50 -0700
Message-ID: <20060422010050.24255.41064.stgit@jk-desktop.jf.intel.com>
References: <20060422010016.24255.50772.stgit@jk-desktop.jf.intel.com>
Cc: John Rociak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr19.intel.com ([134.134.136.18]:35501 "EHLO
	orsfmr004.jf.intel.com") by vger.kernel.org with ESMTP
	id S1750820AbWDVA5p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Apr 2006 20:57:45 -0400
To: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
In-Reply-To: <20060422010016.24255.50772.stgit@jk-desktop.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
---

 drivers/net/ixgb/ixgb_main.c |   36 ++++++++++++++++++++----------------
 1 files changed, 20 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index be7b43b..443d675 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -922,17 +922,20 @@ ixgb_unmap_and_free_tx_resource(struct i
 					struct ixgb_buffer *buffer_info)
 {
 	struct pci_dev *pdev = adapter->pdev;
-	if(buffer_info->dma) {
-		pci_unmap_page(pdev,
-			   buffer_info->dma,
-			   buffer_info->length,
-			   PCI_DMA_TODEVICE);
-		buffer_info->dma = 0;
-	}
-	if(buffer_info->skb) {
+
+	if (buffer_info->dma)
+		pci_unmap_page(pdev, buffer_info->dma, buffer_info->length,
+					   PCI_DMA_TODEVICE);
+
+	if (buffer_info->skb)
 		dev_kfree_skb_any(buffer_info->skb);
-		buffer_info->skb = NULL;
-	}
+
+	buffer_info->skb = NULL;
+	buffer_info->dma = 0;
+	buffer_info->time_stamp = 0;
+	/* these fields must always be initialized in tx
+	 * buffer_info->length = 0;
+	 * buffer_info->next_to_watch = 0; */
 }
 
 /**
@@ -1307,6 +1310,7 @@ ixgb_tx_map(struct ixgb_adapter *adapter
 				size,
 				PCI_DMA_TODEVICE);
 		buffer_info->time_stamp = jiffies;
+		buffer_info->next_to_watch = 0;
 
 		len -= size;
 		offset += size;
@@ -1338,6 +1342,7 @@ ixgb_tx_map(struct ixgb_adapter *adapter
 					size,
 					PCI_DMA_TODEVICE);
 			buffer_info->time_stamp = jiffies;
+			buffer_info->next_to_watch = 0;
 
 			len -= size;
 			offset += size;
@@ -1909,6 +1914,7 @@ ixgb_clean_rx_irq(struct ixgb_adapter *a
 #endif
 		status = rx_desc->status;
 		skb = buffer_info->skb;
+		buffer_info->skb = NULL;
 
 		prefetch(skb->data);
 
@@ -1982,7 +1988,6 @@ ixgb_clean_rx_irq(struct ixgb_adapter *a
 rxdesc_done:
 		/* clean up descriptor, might be written over by hw */
 		rx_desc->status = 0;
-		buffer_info->skb = NULL;
 
 		/* use prefetched values */
 		rx_desc = next_rxd;
@@ -2041,11 +2046,10 @@ ixgb_alloc_rx_buffers(struct ixgb_adapte
 
 		buffer_info->skb = skb;
 		buffer_info->length = adapter->rx_buffer_len;
-		buffer_info->dma =
-			pci_map_single(pdev,
-				   skb->data,
-				   adapter->rx_buffer_len,
-				   PCI_DMA_FROMDEVICE);
+		buffer_info->dma = pci_map_single(pdev,
+										  skb->data,
+										  adapter->rx_buffer_len,
+										  PCI_DMA_FROMDEVICE);
 
 		rx_desc->buff_addr = cpu_to_le64(buffer_info->dma);
 		/* guarantee DD bit not set now before h/w gets descriptor

