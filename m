From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 04/10] ixgbe: remove skb_dma_map/unmap calls from
	driver
Date: Wed, 02 Dec 2009 18:46:56 -0800
Message-ID: <20091203024655.2232.44592.stgit@localhost.localdomain>
References: <20091203024519.2232.6084.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta12.westchester.pa.mail.comcast.net ([76.96.59.227]:47381
	"EHLO QMTA12.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754800AbZLCCrK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 21:47:10 -0500
In-Reply-To: <20091203024519.2232.6084.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch removes skb_dma_map/unmap calls from the ixgbe driver due to the
fact that the calls don't work with HW IOMMU enabled systems.  The problem
is that multiple mappings will give different results when HW IOMMU is
enabled and the skb_dma_map/unmap calls only have one location to store
mappings.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h      |    1 +
 drivers/net/ixgbe/ixgbe_main.c |   63 +++++++++++++++++++++++++++++++---------
 2 files changed, 50 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 76b052f..7e35e97 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -106,6 +106,7 @@ struct ixgbe_tx_buffer {
 	unsigned long time_stamp;
 	u16 length;
 	u16 next_to_watch;
+	u16 mapped_as_page;
 };
 
 struct ixgbe_rx_buffer {
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 5c56f2a..9ba506f 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -218,10 +218,20 @@ static void ixgbe_unmap_and_free_tx_resource(struct ixgbe_adapter *adapter,
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
@@ -5024,23 +5034,16 @@ static int ixgbe_tx_map(struct ixgbe_adapter *adapter,
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
@@ -5051,7 +5054,12 @@ static int ixgbe_tx_map(struct ixgbe_adapter *adapter,
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
 
@@ -5072,7 +5080,7 @@ static int ixgbe_tx_map(struct ixgbe_adapter *adapter,
 
 		frag = &skb_shinfo(skb)->frags[f];
 		len = min((unsigned int)frag->size, total);
-		offset = 0;
+		offset = frag->page_offset;
 
 		while (len) {
 			i++;
@@ -5083,7 +5091,13 @@ static int ixgbe_tx_map(struct ixgbe_adapter *adapter,
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
 
@@ -5100,6 +5114,27 @@ static int ixgbe_tx_map(struct ixgbe_adapter *adapter,
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

