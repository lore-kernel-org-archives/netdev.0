From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [RFC PATCH 01/10] e1000e: remove use of skb_dma_map from e1000e driver
Date: Tue, 24 Nov 2009 17:20:18 -0800
Message-ID: <20091125012018.32704.46978.stgit@gitlad.jf.intel.com>
References: <20091125011111.32704.3009.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mcarlson@broadcom.com, mchan@broadcom.com,
	sathyap@serverengines.com, subbus@serverengines.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:33553 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933665AbZKYBUQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Nov 2009 20:20:16 -0500
In-Reply-To: <20091125011111.32704.3009.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In testing we have found that skb_dma_map/unmap is incompatible with HW
IOMMU due to the fact that multiple mappings will return different results.
In order to correct this we need to remove skb_dma_map/unmap calls from the
e1000e driver.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 drivers/net/e1000e/e1000.h  |    9 ++++---
 drivers/net/e1000e/netdev.c |   59 ++++++++++++++++++++++++++++++-------------
 2 files changed, 47 insertions(+), 21 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index c9fcef7..1be8218 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -192,12 +192,15 @@ struct e1000_buffer {
 			unsigned long time_stamp;
 			u16 length;
 			u16 next_to_watch;
+			u16 mapped_as_page;
 		};
 		/* Rx */
-		/* arrays of page information for packet split */
-		struct e1000_ps_page *ps_pages;
+		struct {
+			/* arrays of page information for packet split */
+			struct e1000_ps_page *ps_pages;
+			struct page *page;
+		};
 	};
-	struct page *page;
 };
 
 struct e1000_ring {
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 11a5274..406d51b 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -534,10 +534,17 @@ next_desc:
 static void e1000_put_txbuf(struct e1000_adapter *adapter,
 			     struct e1000_buffer *buffer_info)
 {
-	buffer_info->dma = 0;
+	if (buffer_info->dma) {
+		if (buffer_info->mapped_as_page)
+			pci_unmap_page(adapter->pdev, buffer_info->dma,
+				       buffer_info->length, PCI_DMA_TODEVICE);
+		else
+			pci_unmap_single(adapter->pdev,	buffer_info->dma,
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
@@ -3890,23 +3897,14 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 			unsigned int mss)
 {
 	struct e1000_ring *tx_ring = adapter->tx_ring;
+	struct pci_dev *pdev = adapter->pdev;
 	struct e1000_buffer *buffer_info;
 	unsigned int len = skb_headlen(skb);
-	unsigned int offset, size, count = 0, i;
+	unsigned int offset = 0, size, count = 0, i;
 	unsigned int f;
-	dma_addr_t *map;
 
 	i = tx_ring->next_to_use;
 
-	if (skb_dma_map(&adapter->pdev->dev, skb, DMA_TO_DEVICE)) {
-		dev_err(&adapter->pdev->dev, "TX DMA map failed\n");
-		adapter->tx_dma_failed++;
-		return 0;
-	}
-
-	map = skb_shinfo(skb)->dma_maps;
-	offset = 0;
-
 	while (len) {
 		buffer_info = &tx_ring->buffer_info[i];
 		size = min(len, max_per_txd);
@@ -3914,11 +3912,15 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 		buffer_info->length = size;
 		buffer_info->time_stamp = jiffies;
 		buffer_info->next_to_watch = i;
-		buffer_info->dma = skb_shinfo(skb)->dma_head + offset;
-		count++;
+		buffer_info->dma = pci_map_single(pdev,	skb->data + offset,
+						  size,	PCI_DMA_TODEVICE);
+		buffer_info->mapped_as_page = false;
+		if (pci_dma_mapping_error(pdev, buffer_info->dma))
+			goto dma_error;
 
 		len -= size;
 		offset += size;
+		count++;
 
 		if (len) {
 			i++;
@@ -3932,7 +3934,7 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 
 		frag = &skb_shinfo(skb)->frags[f];
 		len = frag->size;
-		offset = 0;
+		offset = frag->page_offset;
 
 		while (len) {
 			i++;
@@ -3945,7 +3947,12 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 			buffer_info->length = size;
 			buffer_info->time_stamp = jiffies;
 			buffer_info->next_to_watch = i;
-			buffer_info->dma = map[f] + offset;
+			buffer_info->dma = pci_map_page(pdev, frag->page,
+							offset, size,
+							PCI_DMA_TODEVICE);
+			buffer_info->mapped_as_page = true;
+			if (pci_dma_mapping_error(pdev, buffer_info->dma))
+				goto dma_error;
 
 			len -= size;
 			offset += size;
@@ -3957,6 +3964,22 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
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
+		e1000_put_txbuf(adapter, buffer_info);;
+	}
+
+	return 0;
 }
 
 static void e1000_tx_queue(struct e1000_adapter *adapter,

