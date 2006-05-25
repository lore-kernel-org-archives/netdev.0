From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 1/3] ixgb: add performance enhancements to the buffer_info struct
Date: Thu, 25 May 2006 13:26:31 -0700
Message-ID: <20060525202630.25618.85997.stgit@gitlost.site>
References: <20060525202532.25618.58162.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:14342 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1751231AbWEYUV2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 May 2006 16:21:28 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060525202532.25618.58162.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


o modify the rx refill logic and tail bump
o add counter for failures

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
---

 drivers/net/ixgb/ixgb.h      |    1 +
 drivers/net/ixgb/ixgb_main.c |   74 +++++++++++++++++++++++++-----------------
 2 files changed, 45 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
index b9c37fd..bdbaf5a 100644
--- a/drivers/net/ixgb/ixgb.h
+++ b/drivers/net/ixgb/ixgb.h
@@ -200,6 +200,7 @@ struct ixgb_adapter {
 	struct ixgb_hw hw;
 	u16 msg_enable;
 	struct ixgb_hw_stats stats;
+	uint32_t alloc_rx_buff_failed;
 #ifdef CONFIG_PCI_MSI
 	boolean_t have_msi;
 #endif
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 0905a82..27034b3 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -929,17 +929,20 @@ ixgb_unmap_and_free_tx_resource(struct i
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
+		               PCI_DMA_TODEVICE);
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
@@ -1314,6 +1317,7 @@ ixgb_tx_map(struct ixgb_adapter *adapter
 				size,
 				PCI_DMA_TODEVICE);
 		buffer_info->time_stamp = jiffies;
+		buffer_info->next_to_watch = 0;
 
 		len -= size;
 		offset += size;
@@ -1345,6 +1349,7 @@ ixgb_tx_map(struct ixgb_adapter *adapter
 					size,
 					PCI_DMA_TODEVICE);
 			buffer_info->time_stamp = jiffies;
+			buffer_info->next_to_watch = 0;
 
 			len -= size;
 			offset += size;
@@ -1940,6 +1945,7 @@ ixgb_clean_rx_irq(struct ixgb_adapter *a
 #endif
 		status = rx_desc->status;
 		skb = buffer_info->skb;
+		buffer_info->skb = NULL;
 
 		prefetch(skb->data);
 
@@ -2013,7 +2019,6 @@ ixgb_clean_rx_irq(struct ixgb_adapter *a
 rxdesc_done:
 		/* clean up descriptor, might be written over by hw */
 		rx_desc->status = 0;
-		buffer_info->skb = NULL;
 
 		/* use prefetched values */
 		rx_desc = next_rxd;
@@ -2053,12 +2058,18 @@ ixgb_alloc_rx_buffers(struct ixgb_adapte
 
 	/* leave three descriptors unused */
 	while(--cleancount > 2) {
-		rx_desc = IXGB_RX_DESC(*rx_ring, i);
-
-		skb = dev_alloc_skb(adapter->rx_buffer_len + NET_IP_ALIGN);
+		/* recycle! its good for you */
+		if (!(skb = buffer_info->skb))
+			skb = dev_alloc_skb(adapter->rx_buffer_len
+			                    + NET_IP_ALIGN);
+		else {
+			skb_trim(skb, 0);
+			goto map_skb;
+		}
 
-		if(unlikely(!skb)) {
+		if (unlikely(!skb)) {
 			/* Better luck next round */
+			adapter->alloc_rx_buff_failed++;
 			break;
 		}
 
@@ -2072,33 +2083,36 @@ ixgb_alloc_rx_buffers(struct ixgb_adapte
 
 		buffer_info->skb = skb;
 		buffer_info->length = adapter->rx_buffer_len;
-		buffer_info->dma =
-			pci_map_single(pdev,
-				   skb->data,
-				   adapter->rx_buffer_len,
-				   PCI_DMA_FROMDEVICE);
+map_skb:
+		buffer_info->dma = pci_map_single(pdev,
+		                                  skb->data,
+		                                  adapter->rx_buffer_len,
+		                                  PCI_DMA_FROMDEVICE);
 
+		rx_desc = IXGB_RX_DESC(*rx_ring, i);
 		rx_desc->buff_addr = cpu_to_le64(buffer_info->dma);
 		/* guarantee DD bit not set now before h/w gets descriptor
 		 * this is the rest of the workaround for h/w double 
 		 * writeback. */
 		rx_desc->status = 0;
 
-		if((i & ~(num_group_tail_writes- 1)) == i) {
-			/* Force memory writes to complete before letting h/w
-			 * know there are new descriptors to fetch.  (Only
-			 * applicable for weak-ordered memory model archs,
-			 * such as IA-64). */
-			wmb();
-
-			IXGB_WRITE_REG(&adapter->hw, RDT, i);
-		}
 
 		if(++i == rx_ring->count) i = 0;
 		buffer_info = &rx_ring->buffer_info[i];
 	}
 
-	rx_ring->next_to_use = i;
+	if (likely(rx_ring->next_to_use != i)) {
+		rx_ring->next_to_use = i;
+		if (unlikely(i-- == 0))
+			i = (rx_ring->count - 1);
+
+		/* Force memory writes to complete before letting h/w
+		 * know there are new descriptors to fetch.  (Only
+		 * applicable for weak-ordered memory model archs, such
+		 * as IA-64). */
+		wmb();
+		IXGB_WRITE_REG(&adapter->hw, RDT, i);
+	}
 }
 
 /**



--
Auke Kok <auke-jan.h.kok@intel.com>
