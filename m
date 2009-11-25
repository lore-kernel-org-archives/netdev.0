From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [RFC PATCH 06/10] igbvf: remove skb_dma_map/unmap call from drivers
Date: Tue, 24 Nov 2009 17:20:43 -0800
Message-ID: <20091125012043.32704.15951.stgit@gitlad.jf.intel.com>
References: <20091125011111.32704.3009.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mcarlson@broadcom.com, mchan@broadcom.com,
	sathyap@serverengines.com, subbus@serverengines.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:1588 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934156AbZKYBUu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Nov 2009 20:20:50 -0500
In-Reply-To: <20091125011111.32704.3009.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the skb_dma_map/unmap calls from the igbvf driver due to
the fact that it does not play well with HW IOMMU when combined with
transmitting cloned skbs.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 drivers/net/igbvf/igbvf.h  |    1 +
 drivers/net/igbvf/netdev.c |   65 +++++++++++++++++++++++++++++++++++---------
 2 files changed, 52 insertions(+), 14 deletions(-)

diff --git a/drivers/net/igbvf/igbvf.h b/drivers/net/igbvf/igbvf.h
index 8e9b67e..3d1ee7a 100644
--- a/drivers/net/igbvf/igbvf.h
+++ b/drivers/net/igbvf/igbvf.h
@@ -117,6 +117,7 @@ struct igbvf_buffer {
 			unsigned long time_stamp;
 			u16 length;
 			u16 next_to_watch;
+			u16 mapped_as_page;
 		};
 		/* Rx */
 		struct {
diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index e01f445..cf26f92 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -366,10 +366,20 @@ next_desc:
 static void igbvf_put_txbuf(struct igbvf_adapter *adapter,
                             struct igbvf_buffer *buffer_info)
 {
-	buffer_info->dma = 0;
+	if (buffer_info->dma) {
+		if (buffer_info->mapped_as_page)
+			pci_unmap_page(adapter->pdev,
+				       buffer_info->dma,
+				       buffer_info->length,
+				       PCI_DMA_TODEVICE);
+		else
+			pci_unmap_single(adapter->pdev,
+					 buffer_info->dma,
+					 buffer_info->length,
+					 PCI_DMA_TODEVICE);
+		buffer_info->dma = 0;
+	}
 	if (buffer_info->skb) {
-		skb_dma_unmap(&adapter->pdev->dev, buffer_info->skb,
-		              DMA_TO_DEVICE);
 		dev_kfree_skb_any(buffer_info->skb);
 		buffer_info->skb = NULL;
 	}
@@ -2088,27 +2098,24 @@ static inline int igbvf_tx_map_adv(struct igbvf_adapter *adapter,
                                    unsigned int first)
 {
 	struct igbvf_buffer *buffer_info;
+	struct pci_dev *pdev = adapter->pdev;
 	unsigned int len = skb_headlen(skb);
 	unsigned int count = 0, i;
 	unsigned int f;
-	dma_addr_t *map;
 
 	i = tx_ring->next_to_use;
 
-	if (skb_dma_map(&adapter->pdev->dev, skb, DMA_TO_DEVICE)) {
-		dev_err(&adapter->pdev->dev, "TX DMA map failed\n");
-		return 0;
-	}
-
-	map = skb_shinfo(skb)->dma_maps;
-
 	buffer_info = &tx_ring->buffer_info[i];
 	BUG_ON(len >= IGBVF_MAX_DATA_PER_TXD);
 	buffer_info->length = len;
 	/* set time_stamp *before* dma to help avoid a possible race */
 	buffer_info->time_stamp = jiffies;
 	buffer_info->next_to_watch = i;
-	buffer_info->dma = skb_shinfo(skb)->dma_head;
+	buffer_info->dma = pci_map_single(pdev, skb->data, len,
+					  PCI_DMA_TODEVICE);
+	if (pci_dma_mapping_error(pdev, buffer_info->dma))
+		goto dma_error;
+
 
 	for (f = 0; f < skb_shinfo(skb)->nr_frags; f++) {
 		struct skb_frag_struct *frag;
@@ -2125,14 +2132,44 @@ static inline int igbvf_tx_map_adv(struct igbvf_adapter *adapter,
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
 		count++;
 	}
 
 	tx_ring->buffer_info[i].skb = skb;
 	tx_ring->buffer_info[first].next_to_watch = i;
 
-	return count + 1;
+	return ++count;
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
+		igbvf_put_txbuf(adapter, buffer_info);
+	}
+
+	return 0;
 }
 
 static inline void igbvf_tx_queue_adv(struct igbvf_adapter *adapter,

