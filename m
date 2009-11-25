From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [RFC PATCH 03/10] ixgb: remove use of skb_dma_map from ixgb
Date: Tue, 24 Nov 2009 17:20:28 -0800
Message-ID: <20091125012028.32704.83695.stgit@gitlad.jf.intel.com>
References: <20091125011111.32704.3009.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mcarlson@broadcom.com, mchan@broadcom.com,
	sathyap@serverengines.com, subbus@serverengines.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:5941 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933966AbZKYBUW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Nov 2009 20:20:22 -0500
In-Reply-To: <20091125011111.32704.3009.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_dma_map is incompatible with HW iommu due to the fact that multiple
mappings can result in different results each time.  For this reason it is
best to just remove use of these function calls.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 drivers/net/ixgb/ixgb.h      |    1 +
 drivers/net/ixgb/ixgb_main.c |   60 +++++++++++++++++++++++++++++-------------
 2 files changed, 42 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
index e95d9b6..5257ae0 100644
--- a/drivers/net/ixgb/ixgb.h
+++ b/drivers/net/ixgb/ixgb.h
@@ -117,6 +117,7 @@ struct ixgb_buffer {
 	unsigned long time_stamp;
 	u16 length;
 	u16 next_to_watch;
+	u16 mapped_as_page;
 };
 
 struct ixgb_desc_ring {
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 7364606..b955ce8 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -892,10 +892,18 @@ static void
 ixgb_unmap_and_free_tx_resource(struct ixgb_adapter *adapter,
                                 struct ixgb_buffer *buffer_info)
 {
-	buffer_info->dma = 0;
+	if (buffer_info->dma) {
+		if (buffer_info->mapped_as_page)
+			pci_unmap_page(adapter->pdev, buffer_info->dma,
+				       buffer_info->length, PCI_DMA_TODEVICE);
+		else
+			pci_unmap_single(adapter->pdev, buffer_info->dma,
+					 buffer_info->length,
+					 PCI_DMA_TODEVICE);
+		buffer_info->dma = 0;
+	}
+
 	if (buffer_info->skb) {
-		skb_dma_unmap(&adapter->pdev->dev, buffer_info->skb,
-		              DMA_TO_DEVICE);
 		dev_kfree_skb_any(buffer_info->skb);
 		buffer_info->skb = NULL;
 	}
@@ -1272,24 +1280,16 @@ ixgb_tx_map(struct ixgb_adapter *adapter, struct sk_buff *skb,
 	    unsigned int first)
 {
 	struct ixgb_desc_ring *tx_ring = &adapter->tx_ring;
+	struct pci_dev *pdev = adapter->pdev;
 	struct ixgb_buffer *buffer_info;
 	int len = skb_headlen(skb);
 	unsigned int offset = 0, size, count = 0, i;
 	unsigned int mss = skb_shinfo(skb)->gso_size;
-
 	unsigned int nr_frags = skb_shinfo(skb)->nr_frags;
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
 	while (len) {
 		buffer_info = &tx_ring->buffer_info[i];
 		size = min(len, IXGB_MAX_DATA_PER_TXD);
@@ -1301,11 +1301,11 @@ ixgb_tx_map(struct ixgb_adapter *adapter, struct sk_buff *skb,
 		buffer_info->length = size;
 		WARN_ON(buffer_info->dma != 0);
 		buffer_info->time_stamp = jiffies;
-		buffer_info->dma = skb_shinfo(skb)->dma_head + offset;
-			pci_map_single(adapter->pdev,
-				skb->data + offset,
-				size,
-				PCI_DMA_TODEVICE);
+		buffer_info->mapped_as_page = false;
+		buffer_info->dma = pci_map_single(pdev, skb->data + offset,
+						  size, PCI_DMA_TODEVICE);
+		if (pci_dma_mapping_error(pdev, buffer_info->dma))
+			goto dma_error;
 		buffer_info->next_to_watch = 0;
 
 		len -= size;
@@ -1323,7 +1323,7 @@ ixgb_tx_map(struct ixgb_adapter *adapter, struct sk_buff *skb,
 
 		frag = &skb_shinfo(skb)->frags[f];
 		len = frag->size;
-		offset = 0;
+		offset = frag->page_offset;
 
 		while (len) {
 			i++;
@@ -1341,7 +1341,13 @@ ixgb_tx_map(struct ixgb_adapter *adapter, struct sk_buff *skb,
 
 			buffer_info->length = size;
 			buffer_info->time_stamp = jiffies;
-			buffer_info->dma = map[f] + offset;
+			buffer_info->mapped_as_page = true;
+			buffer_info->dma =
+				pci_map_page(pdev, frag->page,
+					     frag->page_offset + offset, size,
+					     PCI_DMA_TODEVICE);
+			if (pci_dma_mapping_error(pdev, buffer_info->dma))
+				goto dma_error;
 			buffer_info->next_to_watch = 0;
 
 			len -= size;
@@ -1353,6 +1359,22 @@ ixgb_tx_map(struct ixgb_adapter *adapter, struct sk_buff *skb,
 	tx_ring->buffer_info[first].next_to_watch = i;
 
 	return count;
+
+dma_error:
+	dev_err(&pdev->dev, "TX DMA map failed\n");
+	buffer_info->dma = 0;
+	count--;
+
+	while (count >= 0) {
+		count--;
+		i--;
+		if (i < 0)
+			i += tx_ring->count;
+		buffer_info = &tx_ring->buffer_info[i];
+		ixgb_unmap_and_free_tx_resource(adapter, buffer_info);
+	}
+
+	return 0;
 }
 
 static void

