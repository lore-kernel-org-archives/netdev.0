From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [RFC PATCH 05/10] igb: remove use of skb_dma_map from driver
Date: Tue, 24 Nov 2009 17:20:38 -0800
Message-ID: <20091125012038.32704.71806.stgit@gitlad.jf.intel.com>
References: <20091125011111.32704.3009.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mcarlson@broadcom.com, mchan@broadcom.com,
	sathyap@serverengines.com, subbus@serverengines.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:54991 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934162AbZKYBUc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Nov 2009 20:20:32 -0500
In-Reply-To: <20091125011111.32704.3009.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change removes skb_dma_map/unmap calls from the igb driver due to the
fact that the call is incompatible with iommu enabled kernels.  In order to
prevent warnings about using the wrong unmap call I have added a
mapped_as_page value to the buffer_info structure to track if the mapped
region is a page or a buffer.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 drivers/net/igb/igb.h      |    5 ++-
 drivers/net/igb/igb_main.c |   69 ++++++++++++++++++++++++++++++++++----------
 2 files changed, 56 insertions(+), 18 deletions(-)

diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index c458d9b..b1c1eb8 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -137,12 +137,13 @@ struct igb_buffer {
 			unsigned long time_stamp;
 			u16 length;
 			u16 next_to_watch;
+			u16 mapped_as_page;
 		};
 		/* RX */
 		struct {
 			struct page *page;
-			u64 page_dma;
-			unsigned int page_offset;
+			dma_addr_t page_dma;
+			u16 page_offset;
 		};
 	};
 };
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index bb1a6ee..e57b32d 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -2654,16 +2654,27 @@ static void igb_free_all_tx_resources(struct igb_adapter *adapter)
 void igb_unmap_and_free_tx_resource(struct igb_ring *tx_ring,
 				    struct igb_buffer *buffer_info)
 {
-	buffer_info->dma = 0;
+	if (buffer_info->dma) {
+		if (buffer_info->mapped_as_page)
+			pci_unmap_page(tx_ring->pdev,
+					buffer_info->dma,
+					buffer_info->length,
+					PCI_DMA_TODEVICE);
+		else
+			pci_unmap_single(tx_ring->pdev,
+					buffer_info->dma,
+					buffer_info->length,
+					PCI_DMA_TODEVICE);
+		buffer_info->dma = 0;
+	}
 	if (buffer_info->skb) {
-		skb_dma_unmap(&tx_ring->pdev->dev,
-		              buffer_info->skb,
-		              DMA_TO_DEVICE);
 		dev_kfree_skb_any(buffer_info->skb);
 		buffer_info->skb = NULL;
 	}
 	buffer_info->time_stamp = 0;
-	/* buffer_info must be completely set up in the transmit path */
+	buffer_info->length = 0;
+	buffer_info->next_to_watch = 0;
+	buffer_info->mapped_as_page = false;
 }
 
 /**
@@ -3561,24 +3572,19 @@ static inline int igb_tx_map_adv(struct igb_ring *tx_ring, struct sk_buff *skb,
 	unsigned int len = skb_headlen(skb);
 	unsigned int count = 0, i;
 	unsigned int f;
-	dma_addr_t *map;
 
 	i = tx_ring->next_to_use;
 
-	if (skb_dma_map(&pdev->dev, skb, DMA_TO_DEVICE)) {
-		dev_err(&pdev->dev, "TX DMA map failed\n");
-		return 0;
-	}
-
-	map = skb_shinfo(skb)->dma_maps;
-
 	buffer_info = &tx_ring->buffer_info[i];
 	BUG_ON(len >= IGB_MAX_DATA_PER_TXD);
 	buffer_info->length = len;
 	/* set time_stamp *before* dma to help avoid a possible race */
 	buffer_info->time_stamp = jiffies;
 	buffer_info->next_to_watch = i;
-	buffer_info->dma = skb_shinfo(skb)->dma_head;
+	buffer_info->dma = pci_map_single(pdev, skb->data, len,
+					  PCI_DMA_TODEVICE);
+	if (pci_dma_mapping_error(pdev, buffer_info->dma))
+		goto dma_error;
 
 	for (f = 0; f < skb_shinfo(skb)->nr_frags; f++) {
 		struct skb_frag_struct *frag;
@@ -3595,7 +3601,15 @@ static inline int igb_tx_map_adv(struct igb_ring *tx_ring, struct sk_buff *skb,
 		buffer_info->length = len;
 		buffer_info->time_stamp = jiffies;
 		buffer_info->next_to_watch = i;
-		buffer_info->dma = map[count];
+		buffer_info->mapped_as_page = true;
+		buffer_info->dma = pci_map_page(pdev,
+						frag->page,
+						frag->page_offset,
+						len,
+						PCI_DMA_TODEVICE);
+		if (pci_dma_mapping_error(pdev, buffer_info->dma))
+			goto dma_error;
+
 		count++;
 	}
 
@@ -3603,6 +3617,29 @@ static inline int igb_tx_map_adv(struct igb_ring *tx_ring, struct sk_buff *skb,
 	tx_ring->buffer_info[first].next_to_watch = i;
 
 	return ++count;
+
+dma_error:
+	dev_err(&pdev->dev, "TX DMA map failed\n");
+
+	/* clear timestamp and dma mappings for failed buffer_info mapping */
+	buffer_info->dma = 0;
+	buffer_info->time_stamp = 0;
+	buffer_info->length = 0;
+	buffer_info->next_to_watch = 0;
+	buffer_info->mapped_as_page = false;
+	count--;
+
+	/* clear timestamp and dma mappings for remaining portion of packet */
+	while (count >= 0) {
+		count--;
+		i--;
+		if (i < 0)
+			i += tx_ring->count;
+		buffer_info = &tx_ring->buffer_info[i];
+		igb_unmap_and_free_tx_resource(tx_ring, buffer_info);
+	}
+
+	return 0;
 }
 
 static inline void igb_tx_queue_adv(struct igb_ring *tx_ring,
@@ -3755,7 +3792,7 @@ netdev_tx_t igb_xmit_frame_ring_adv(struct sk_buff *skb,
 	 * has occured and we need to rewind the descriptor queue
 	 */
 	count = igb_tx_map_adv(tx_ring, skb, first);
-	if (count <= 0) {
+	if (!count) {
 		dev_kfree_skb_any(skb);
 		tx_ring->buffer_info[first].time_stamp = 0;
 		tx_ring->next_to_use = first;

