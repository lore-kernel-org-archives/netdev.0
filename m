From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 6/9] ixgbe: refactor tx buffer processing to use
	skb_dma_map/unmap
Date: Wed, 01 Apr 2009 00:34:23 -0700
Message-ID: <20090401073423.3749.21206.stgit@lost.foo-projects.org>
References: <20090401073241.3749.36391.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.emeryville.ca.mail.comcast.net ([76.96.27.212]:33580
	"EHLO QMTA14.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752255AbZDAHep (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 03:34:45 -0400
In-Reply-To: <20090401073241.3749.36391.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch resolves an issue with map single being used to map a buffer and
then unmap page being used to unmap it.  In addition it handles any error
conditions that may be detected using skb_dma_map.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Acked-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   79 +++++++++++++++++++++-------------------
 1 files changed, 41 insertions(+), 38 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 63c0f19..f36cff5 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -187,15 +187,14 @@ static void ixgbe_unmap_and_free_tx_resource(struct ixgbe_adapter *adapter,
                                              struct ixgbe_tx_buffer
                                              *tx_buffer_info)
 {
-	if (tx_buffer_info->dma) {
-		pci_unmap_page(adapter->pdev, tx_buffer_info->dma,
-		               tx_buffer_info->length, PCI_DMA_TODEVICE);
-		tx_buffer_info->dma = 0;
-	}
+	tx_buffer_info->dma = 0;
 	if (tx_buffer_info->skb) {
+		skb_dma_unmap(&adapter->pdev->dev, tx_buffer_info->skb,
+		              DMA_TO_DEVICE);
 		dev_kfree_skb_any(tx_buffer_info->skb);
 		tx_buffer_info->skb = NULL;
 	}
+	tx_buffer_info->time_stamp = 0;
 	/* tx_buffer_info must be completely set up in the transmit path */
 }
 
@@ -204,15 +203,11 @@ static inline bool ixgbe_check_tx_hang(struct ixgbe_adapter *adapter,
                                        unsigned int eop)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
-	u32 head, tail;
 
 	/* Detect a transmit hang in hardware, this serializes the
 	 * check with the clearing of time_stamp and movement of eop */
-	head = IXGBE_READ_REG(hw, tx_ring->head);
-	tail = IXGBE_READ_REG(hw, tx_ring->tail);
 	adapter->detect_tx_hung = false;
-	if ((head != tail) &&
-	    tx_ring->tx_buffer_info[eop].time_stamp &&
+	if (tx_ring->tx_buffer_info[eop].time_stamp &&
 	    time_after(jiffies, tx_ring->tx_buffer_info[eop].time_stamp + HZ) &&
 	    !(IXGBE_READ_REG(&adapter->hw, IXGBE_TFCS) & IXGBE_TFCS_TXOFF)) {
 		/* detected Tx unit hang */
@@ -227,7 +222,8 @@ static inline bool ixgbe_check_tx_hang(struct ixgbe_adapter *adapter,
 			"  time_stamp           <%lx>\n"
 			"  jiffies              <%lx>\n",
 			tx_ring->queue_index,
-			head, tail,
+			IXGBE_READ_REG(hw, tx_ring->head),
+			IXGBE_READ_REG(hw, tx_ring->tail),
 			tx_ring->next_to_use, eop,
 			tx_ring->tx_buffer_info[eop].time_stamp, jiffies);
 		return true;
@@ -4164,32 +4160,39 @@ static int ixgbe_tx_map(struct ixgbe_adapter *adapter,
                         struct sk_buff *skb, unsigned int first)
 {
 	struct ixgbe_tx_buffer *tx_buffer_info;
-	unsigned int len = skb->len;
+	unsigned int len = skb_headlen(skb);
 	unsigned int offset = 0, size, count = 0, i;
 	unsigned int nr_frags = skb_shinfo(skb)->nr_frags;
 	unsigned int f;
-
-	len -= skb->data_len;
+	dma_addr_t *map;
 
 	i = tx_ring->next_to_use;
 
+	if (skb_dma_map(&adapter->pdev->dev, skb, DMA_TO_DEVICE)) {
+		dev_err(&adapter->pdev->dev, "TX DMA map failed\n");
+		return 0;
+	}
+
+	map = skb_shinfo(skb)->dma_maps;
+
 	while (len) {
 		tx_buffer_info = &tx_ring->tx_buffer_info[i];
 		size = min(len, (uint)IXGBE_MAX_DATA_PER_TXD);
 
 		tx_buffer_info->length = size;
-		tx_buffer_info->dma = pci_map_single(adapter->pdev,
-		                                     skb->data + offset,
-		                                     size, PCI_DMA_TODEVICE);
+		tx_buffer_info->dma = map[0] + offset;
 		tx_buffer_info->time_stamp = jiffies;
 		tx_buffer_info->next_to_watch = i;
 
 		len -= size;
 		offset += size;
 		count++;
-		i++;
-		if (i == tx_ring->count)
-			i = 0;
+
+		if (len) {
+			i++;
+			if (i == tx_ring->count)
+				i = 0;
+		}
 	}
 
 	for (f = 0; f < nr_frags; f++) {
@@ -4197,33 +4200,27 @@ static int ixgbe_tx_map(struct ixgbe_adapter *adapter,
 
 		frag = &skb_shinfo(skb)->frags[f];
 		len = frag->size;
-		offset = frag->page_offset;
+		offset = 0;
 
 		while (len) {
+			i++;
+			if (i == tx_ring->count)
+				i = 0;
+
 			tx_buffer_info = &tx_ring->tx_buffer_info[i];
 			size = min(len, (uint)IXGBE_MAX_DATA_PER_TXD);
 
 			tx_buffer_info->length = size;
-			tx_buffer_info->dma = pci_map_page(adapter->pdev,
-			                                   frag->page,
-			                                   offset,
-			                                   size,
-			                                   PCI_DMA_TODEVICE);
+			tx_buffer_info->dma = map[f + 1] + offset;
 			tx_buffer_info->time_stamp = jiffies;
 			tx_buffer_info->next_to_watch = i;
 
 			len -= size;
 			offset += size;
 			count++;
-			i++;
-			if (i == tx_ring->count)
-				i = 0;
 		}
 	}
-	if (i == 0)
-		i = tx_ring->count - 1;
-	else
-		i = i - 1;
+
 	tx_ring->tx_buffer_info[i].skb = skb;
 	tx_ring->tx_buffer_info[first].next_to_watch = i;
 
@@ -4389,13 +4386,19 @@ static int ixgbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	         (skb->ip_summed == CHECKSUM_PARTIAL))
 		tx_flags |= IXGBE_TX_FLAGS_CSUM;
 
-	ixgbe_tx_queue(adapter, tx_ring, tx_flags,
-	               ixgbe_tx_map(adapter, tx_ring, skb, first),
-	               skb->len, hdr_len);
+	count = ixgbe_tx_map(adapter, tx_ring, skb, first);
 
-	netdev->trans_start = jiffies;
+	if (count) {
+		ixgbe_tx_queue(adapter, tx_ring, tx_flags, count, skb->len,
+		               hdr_len);
+		netdev->trans_start = jiffies;
+		ixgbe_maybe_stop_tx(netdev, tx_ring, DESC_NEEDED);
 
-	ixgbe_maybe_stop_tx(netdev, tx_ring, DESC_NEEDED);
+	} else {
+		dev_kfree_skb_any(skb);
+		tx_ring->tx_buffer_info[first].time_stamp = 0;
+		tx_ring->next_to_use = first;
+	}
 
 	return NETDEV_TX_OK;
 }

