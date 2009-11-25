From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [RFC PATCH 02/10] e1000: remove use of skb_dma_map from e1000 driver
Date: Tue, 24 Nov 2009 17:20:23 -0800
Message-ID: <20091125012023.32704.43402.stgit@gitlad.jf.intel.com>
References: <20091125011111.32704.3009.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mcarlson@broadcom.com, mchan@broadcom.com,
	sathyap@serverengines.com, subbus@serverengines.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:62053 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933891AbZKYBUR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Nov 2009 20:20:17 -0500
In-Reply-To: <20091125011111.32704.3009.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the use of skb_dma_map from the e1000 driver in order to avoid
issues when HW iommu are in use.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 drivers/net/e1000/e1000.h      |    1 +
 drivers/net/e1000/e1000_main.c |   56 +++++++++++++++++++++++++++++-----------
 2 files changed, 41 insertions(+), 16 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index a566528..2a567df 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -167,6 +167,7 @@ struct e1000_buffer {
 	unsigned long time_stamp;
 	u16 length;
 	u16 next_to_watch;
+	u16 mapped_as_page;
 };
 
 struct e1000_tx_ring {
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index c938114..b9d86f8 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1839,10 +1839,17 @@ void e1000_free_all_tx_resources(struct e1000_adapter *adapter)
 static void e1000_unmap_and_free_tx_resource(struct e1000_adapter *adapter,
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
@@ -2683,22 +2690,14 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 			unsigned int mss)
 {
 	struct e1000_hw *hw = &adapter->hw;
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
-		return 0;
-	}
-
-	map = skb_shinfo(skb)->dma_maps;
-	offset = 0;
-
 	while (len) {
 		buffer_info = &tx_ring->buffer_info[i];
 		size = min(len, max_per_txd);
@@ -2735,7 +2734,11 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 		buffer_info->length = size;
 		/* set time_stamp *before* dma to help avoid a possible race */
 		buffer_info->time_stamp = jiffies;
-		buffer_info->dma = skb_shinfo(skb)->dma_head + offset;
+		buffer_info->mapped_as_page = false;
+		buffer_info->dma = pci_map_single(pdev,	skb->data + offset,
+						  size,	PCI_DMA_TODEVICE);
+		if (pci_dma_mapping_error(pdev, buffer_info->dma))
+			goto dma_error;
 		buffer_info->next_to_watch = i;
 
 		len -= size;
@@ -2753,7 +2756,7 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 
 		frag = &skb_shinfo(skb)->frags[f];
 		len = frag->size;
-		offset = 0;
+		offset = frag->page_offset;
 
 		while (len) {
 			i++;
@@ -2777,7 +2780,12 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 
 			buffer_info->length = size;
 			buffer_info->time_stamp = jiffies;
-			buffer_info->dma = map[f] + offset;
+			buffer_info->mapped_as_page = true;
+			buffer_info->dma = pci_map_page(pdev, frag->page,
+							offset,	size,
+							PCI_DMA_TODEVICE);
+			if (pci_dma_mapping_error(pdev, buffer_info->dma))
+				goto dma_error;
 			buffer_info->next_to_watch = i;
 
 			len -= size;
@@ -2790,6 +2798,22 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
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
+		e1000_unmap_and_free_tx_resource(adapter, buffer_info);
+	}
+
+	return 0;
 }
 
 static void e1000_tx_queue(struct e1000_adapter *adapter,

