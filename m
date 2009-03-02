From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 1/2] e1000e: fix unmap bug
Date: Mon, 02 Mar 2009 15:49:29 -0800
Message-ID: <20090302234929.12507.51437.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, stable@kernel.org,
	linux-kernel@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.emeryville.ca.mail.comcast.net ([76.96.30.16]:39265 "EHLO
	QMTA01.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754455AbZCBXty (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 18:49:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

This is in reference to https://bugzilla.redhat.com/show_bug.cgi?id=484494
Also addresses issue show in kerneloops

The e1000e transmit code was calling pci_unmap_page on dma handles that it
might have called pci_map_single on.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Acked-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c |   62 +++++++++++++++++++------------------------
 1 files changed, 28 insertions(+), 34 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 1b5a0c8..e74eb3c 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -566,12 +566,10 @@ next_desc:
 static void e1000_put_txbuf(struct e1000_adapter *adapter,
 			     struct e1000_buffer *buffer_info)
 {
-	if (buffer_info->dma) {
-		pci_unmap_page(adapter->pdev, buffer_info->dma,
-			       buffer_info->length, PCI_DMA_TODEVICE);
-		buffer_info->dma = 0;
-	}
+	buffer_info->dma = 0;
 	if (buffer_info->skb) {
+		skb_dma_unmap(&adapter->pdev->dev, buffer_info->skb,
+		              DMA_TO_DEVICE);
 		dev_kfree_skb_any(buffer_info->skb);
 		buffer_info->skb = NULL;
 	}
@@ -684,6 +682,11 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter)
 		 * check with the clearing of time_stamp and movement of i
 		 */
 		adapter->detect_tx_hung = 0;
+		/*
+		 * read barrier to make sure that the ->dma member and time
+		 * stamp are updated fully
+		 */
+		smp_rmb();
 		if (tx_ring->buffer_info[eop].dma &&
 		    time_after(jiffies, tx_ring->buffer_info[eop].time_stamp
 			       + (adapter->tx_timeout_factor * HZ))
@@ -3820,30 +3823,31 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 			unsigned int mss)
 {
 	struct e1000_ring *tx_ring = adapter->tx_ring;
-	struct e1000_buffer *buffer_info;
-	unsigned int len = skb->len - skb->data_len;
-	unsigned int offset = 0, size, count = 0, i;
+	unsigned int len = skb_headlen(skb);
+	unsigned int offset, size, count = 0, i;
 	unsigned int f;
+	dma_addr_t map;
 
 	i = tx_ring->next_to_use;
 
+	if (skb_dma_map(&adapter->pdev->dev, skb, DMA_TO_DEVICE)) {
+		dev_err(&adapter->pdev->dev, "TX DMA map failed\n");
+		adapter->tx_dma_failed++;
+		dev_kfree_skb(skb);
+		return -2;
+	}
+
+	map = skb_shinfo(skb)->dma_maps[0];
+	offset = 0;
+
 	while (len) {
-		buffer_info = &tx_ring->buffer_info[i];
+		struct e1000_buffer *buffer_info = &tx_ring->buffer_info[i];
 		size = min(len, max_per_txd);
 
 		buffer_info->length = size;
 		/* set time_stamp *before* dma to help avoid a possible race */
 		buffer_info->time_stamp = jiffies;
-		buffer_info->dma =
-			pci_map_single(adapter->pdev,
-				skb->data + offset,
-				size,
-				PCI_DMA_TODEVICE);
-		if (pci_dma_mapping_error(adapter->pdev, buffer_info->dma)) {
-			dev_err(&adapter->pdev->dev, "TX DMA map failed\n");
-			adapter->tx_dma_failed++;
-			return -1;
-		}
+		buffer_info->dma = map + offset;
 		buffer_info->next_to_watch = i;
 
 		len -= size;
@@ -3859,28 +3863,17 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 
 		frag = &skb_shinfo(skb)->frags[f];
 		len = frag->size;
-		offset = frag->page_offset;
+		map = skb_shinfo(skb)->dma_maps[f + 1];
+		offset = 0;
 
 		while (len) {
+			struct e1000_buffer *buffer_info;
 			buffer_info = &tx_ring->buffer_info[i];
 			size = min(len, max_per_txd);
 
 			buffer_info->length = size;
 			buffer_info->time_stamp = jiffies;
-			buffer_info->dma =
-				pci_map_page(adapter->pdev,
-					frag->page,
-					offset,
-					size,
-					PCI_DMA_TODEVICE);
-			if (pci_dma_mapping_error(adapter->pdev,
-						  buffer_info->dma)) {
-				dev_err(&adapter->pdev->dev,
-					"TX DMA page map failed\n");
-				adapter->tx_dma_failed++;
-				return -1;
-			}
-
+			buffer_info->dma = map + offset;
 			buffer_info->next_to_watch = i;
 
 			len -= size;
@@ -3900,6 +3893,7 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 
 	tx_ring->buffer_info[i].skb = skb;
 	tx_ring->buffer_info[first].next_to_watch = i;
+	smp_wmb();
 
 	return count;
 }

