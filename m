From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [RFC PATCH 04/10] ixgbe: remove skb_dma_map/unmap calls from driver
Date: Tue, 24 Nov 2009 17:20:33 -0800
Message-ID: <20091125012033.32704.89085.stgit@gitlad.jf.intel.com>
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
	id S934108AbZKYBUc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Nov 2009 20:20:32 -0500
In-Reply-To: <20091125011111.32704.3009.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes skb_dma_map/unmap calls from the ixgbe driver due to the
fact that the calls don't work with HW IOMMU enabled systems.  The problem
is that multiple mappings will give different results when HW IOMMU is
enabled and the skb_dma_map/unmap calls only have one location to store
mappings.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 drivers/net/ixgbe/ixgbe.h      |    1 +
 drivers/net/ixgbe/ixgbe_main.c |   63 +++++++++++++++++++++++++++++++---------
 2 files changed, 50 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 6ebcc2c..4e7d1fc 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -123,6 +123,7 @@ struct ixgbe_tx_buffer {
 	unsigned long time_stamp;
 	u16 length;
 	u16 next_to_watch;
+	u16 mapped_as_page;
 };
 
 struct ixgbe_rx_buffer {
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 9335352..d274d64 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -262,10 +262,20 @@ static void ixgbe_unmap_and_free_tx_resource(struct ixgbe_adapter *adapter,
                                              struct ixgbe_tx_buffer
                                              *tx_buffer_info)
 {
-	tx_buffer_info->dma = 0;
+	if (tx_buffer_info->dma) {
+		if (tx_buffer_info->mapped_as_page)
+			pci_unmap_page(adapter->pdev,
+				       tx_buffer_info->dma,
+				       tx_buffer_info->length,
+				       PCI_DMA_TODEVICE);
+		else
+			pci_unmap_single(adapter->pdev,
+					 tx_buffer_info->dma,
+					 tx_buffer_info->length,
+					 PCI_DMA_TODEVICE);
+		tx_buffer_info->dma = 0;
+	}
 	if (tx_buffer_info->skb) {
-		skb_dma_unmap(&adapter->pdev->dev, tx_buffer_info->skb,
-		              DMA_TO_DEVICE);
 		dev_kfree_skb_any(tx_buffer_info->skb);
 		tx_buffer_info->skb = NULL;
 	}
@@ -5210,23 +5220,16 @@ static int ixgbe_tx_map(struct ixgbe_adapter *adapter,
                         struct sk_buff *skb, u32 tx_flags,
                         unsigned int first)
 {
+	struct pci_dev *pdev = adapter->pdev;
 	struct ixgbe_tx_buffer *tx_buffer_info;
 	unsigned int len;
 	unsigned int total = skb->len;
 	unsigned int offset = 0, size, count = 0, i;
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
 	if (tx_flags & IXGBE_TX_FLAGS_FCOE)
 		/* excluding fcoe_crc_eof for FCoE */
 		total -= sizeof(struct fcoe_crc_eof);
@@ -5237,7 +5240,12 @@ static int ixgbe_tx_map(struct ixgbe_adapter *adapter,
 		size = min(len, (uint)IXGBE_MAX_DATA_PER_TXD);
 
 		tx_buffer_info->length = size;
-		tx_buffer_info->dma = skb_shinfo(skb)->dma_head + offset;
+		tx_buffer_info->mapped_as_page = false;
+		tx_buffer_info->dma = pci_map_single(pdev,
+						     skb->data + offset,
+						     size, PCI_DMA_TODEVICE);
+		if (pci_dma_mapping_error(pdev, tx_buffer_info->dma))
+			goto dma_error;
 		tx_buffer_info->time_stamp = jiffies;
 		tx_buffer_info->next_to_watch = i;
 
@@ -5258,7 +5266,7 @@ static int ixgbe_tx_map(struct ixgbe_adapter *adapter,
 
 		frag = &skb_shinfo(skb)->frags[f];
 		len = min((unsigned int)frag->size, total);
-		offset = 0;
+		offset = frag->page_offset;
 
 		while (len) {
 			i++;
@@ -5269,7 +5277,13 @@ static int ixgbe_tx_map(struct ixgbe_adapter *adapter,
 			size = min(len, (uint)IXGBE_MAX_DATA_PER_TXD);
 
 			tx_buffer_info->length = size;
-			tx_buffer_info->dma = map[f] + offset;
+			tx_buffer_info->dma = pci_map_page(adapter->pdev,
+							   frag->page,
+							   offset, size,
+							   PCI_DMA_TODEVICE);
+			tx_buffer_info->mapped_as_page = true;
+			if (pci_dma_mapping_error(pdev, tx_buffer_info->dma))
+				goto dma_error;
 			tx_buffer_info->time_stamp = jiffies;
 			tx_buffer_info->next_to_watch = i;
 
@@ -5286,6 +5300,27 @@ static int ixgbe_tx_map(struct ixgbe_adapter *adapter,
 	tx_ring->tx_buffer_info[first].next_to_watch = i;
 
 	return count;
+
+dma_error:
+	dev_err(&pdev->dev, "TX DMA map failed\n");
+
+	/* clear timestamp and dma mappings for failed tx_buffer_info map */
+	tx_buffer_info->dma = 0;
+	tx_buffer_info->time_stamp = 0;
+	tx_buffer_info->next_to_watch = 0;
+	count--;
+
+	/* clear timestamp and dma mappings for remaining portion of packet */
+	while (count >= 0) {
+		count--;
+		i--;
+		if (i < 0)
+			i += tx_ring->count;
+		tx_buffer_info = &tx_ring->tx_buffer_info[i];
+		ixgbe_unmap_and_free_tx_resource(adapter, tx_buffer_info);
+	}
+
+	return count;
 }
 
 static void ixgbe_tx_queue(struct ixgbe_adapter *adapter,

