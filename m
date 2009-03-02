From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 2/2] e1000: fix unmap bug
Date: Mon, 02 Mar 2009 15:49:53 -0800
Message-ID: <20090302234953.12507.91320.stgit@lost.foo-projects.org>
References: <20090302234929.12507.51437.stgit@lost.foo-projects.org>
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
	by vger.kernel.org with ESMTP id S1758142AbZCBXuS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 18:50:18 -0500
In-Reply-To: <20090302234929.12507.51437.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

This is in reference to the issue shown in kerneloops (search e1000 unmap)

The e1000 transmit code was calling pci_unmap_page on dma handles that it
might have called pci_map_single on.

Same bug as e1000e

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Acked-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_main.c |   51 +++++++++++++++++++++-------------------
 1 files changed, 27 insertions(+), 24 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 61b56ca..1f390ce 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2049,14 +2049,10 @@ void e1000_free_all_tx_resources(struct e1000_adapter *adapter)
 static void e1000_unmap_and_free_tx_resource(struct e1000_adapter *adapter,
 					     struct e1000_buffer *buffer_info)
 {
-	if (buffer_info->dma) {
-		pci_unmap_page(adapter->pdev,
-				buffer_info->dma,
-				buffer_info->length,
-				PCI_DMA_TODEVICE);
-		buffer_info->dma = 0;
-	}
+	buffer_info->dma = 0;
 	if (buffer_info->skb) {
+		skb_dma_unmap(&adapter->pdev->dev, buffer_info->skb,
+		              DMA_TO_DEVICE);
 		dev_kfree_skb_any(buffer_info->skb);
 		buffer_info->skb = NULL;
 	}
@@ -2907,16 +2903,24 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 			unsigned int mss)
 {
 	struct e1000_hw *hw = &adapter->hw;
-	struct e1000_buffer *buffer_info;
-	unsigned int len = skb->len;
-	unsigned int offset = 0, size, count = 0, i;
+	unsigned int len = skb_headlen(skb);
+	unsigned int offset, size, count = 0, i;
 	unsigned int f;
-	len -= skb->data_len;
+	dma_addr_t map;
 
 	i = tx_ring->next_to_use;
 
+	if (skb_dma_map(&adapter->pdev->dev, skb, DMA_TO_DEVICE)) {
+		dev_err(&adapter->pdev->dev, "TX DMA map failed\n");
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
 		/* Workaround for Controller erratum --
 		 * descriptor for non-tso packet in a linear SKB that follows a
@@ -2949,11 +2953,7 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 			size -= 4;
 
 		buffer_info->length = size;
-		buffer_info->dma =
-			pci_map_single(adapter->pdev,
-				skb->data + offset,
-				size,
-				PCI_DMA_TODEVICE);
+		buffer_info->dma = map + offset;
 		buffer_info->time_stamp = jiffies;
 		buffer_info->next_to_watch = i;
 
@@ -2968,9 +2968,11 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 
 		frag = &skb_shinfo(skb)->frags[f];
 		len = frag->size;
-		offset = frag->page_offset;
+		map = skb_shinfo(skb)->dma_maps[f + 1];
+		offset = 0;
 
 		while (len) {
+			struct e1000_buffer *buffer_info;
 			buffer_info = &tx_ring->buffer_info[i];
 			size = min(len, max_per_txd);
 			/* Workaround for premature desc write-backs
@@ -2986,12 +2988,7 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 				size -= 4;
 
 			buffer_info->length = size;
-			buffer_info->dma =
-				pci_map_page(adapter->pdev,
-					frag->page,
-					offset,
-					size,
-					PCI_DMA_TODEVICE);
+			buffer_info->dma = map + offset;
 			buffer_info->time_stamp = jiffies;
 			buffer_info->next_to_watch = i;
 
@@ -3005,6 +3002,7 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 	i = (i == 0) ? tx_ring->count - 1 : i - 1;
 	tx_ring->buffer_info[i].skb = skb;
 	tx_ring->buffer_info[first].next_to_watch = i;
+	smp_wmb();
 
 	return count;
 }
@@ -3844,6 +3842,11 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
 		/* Detect a transmit hang in hardware, this serializes the
 		 * check with the clearing of time_stamp and movement of i */
 		adapter->detect_tx_hung = false;
+		/*
+		 * read barrier to make sure that the ->dma member and time
+		 * stamp are updated fully
+		 */
+		smp_rmb();
 		if (tx_ring->buffer_info[eop].dma &&
 		    time_after(jiffies, tx_ring->buffer_info[eop].time_stamp +
 		               (adapter->tx_timeout_factor * HZ))

