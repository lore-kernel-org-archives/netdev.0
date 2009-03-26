From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 1/3] e1000: fix tx hang detect logic and address dma
	mapping issues
Date: Thu, 26 Mar 2009 00:58:45 -0700
Message-ID: <20090326075844.30121.48999.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.westchester.pa.mail.comcast.net ([76.96.62.64]:59483
	"EHLO QMTA07.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753124AbZCZH7G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 03:59:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch changes the dma mapping to better support
skb_dma_map/skb_dma_unmap and addresses and redefines the tx hang logic to
be based off of time stamp instead of if the dma field is populated

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_main.c |   55 ++++++++++++++++++++++------------------
 1 files changed, 30 insertions(+), 25 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 1f390ce..e60faab 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2056,6 +2056,7 @@ static void e1000_unmap_and_free_tx_resource(struct e1000_adapter *adapter,
 		dev_kfree_skb_any(buffer_info->skb);
 		buffer_info->skb = NULL;
 	}
+	buffer_info->time_stamp = 0;
 	/* buffer_info must be completely set up in the transmit path */
 }
 
@@ -2903,24 +2904,24 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 			unsigned int mss)
 {
 	struct e1000_hw *hw = &adapter->hw;
+	struct e1000_buffer *buffer_info;
 	unsigned int len = skb_headlen(skb);
 	unsigned int offset, size, count = 0, i;
 	unsigned int f;
-	dma_addr_t map;
+	dma_addr_t *map;
 
 	i = tx_ring->next_to_use;
 
 	if (skb_dma_map(&adapter->pdev->dev, skb, DMA_TO_DEVICE)) {
 		dev_err(&adapter->pdev->dev, "TX DMA map failed\n");
-		dev_kfree_skb(skb);
-		return -2;
+		return 0;
 	}
 
-	map = skb_shinfo(skb)->dma_maps[0];
+	map = skb_shinfo(skb)->dma_maps;
 	offset = 0;
 
 	while (len) {
-		struct e1000_buffer *buffer_info = &tx_ring->buffer_info[i];
+		buffer_info = &tx_ring->buffer_info[i];
 		size = min(len, max_per_txd);
 		/* Workaround for Controller erratum --
 		 * descriptor for non-tso packet in a linear SKB that follows a
@@ -2953,14 +2954,18 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 			size -= 4;
 
 		buffer_info->length = size;
-		buffer_info->dma = map + offset;
+		buffer_info->dma = map[0] + offset;
 		buffer_info->time_stamp = jiffies;
 		buffer_info->next_to_watch = i;
 
 		len -= size;
 		offset += size;
 		count++;
-		if (unlikely(++i == tx_ring->count)) i = 0;
+		if (len) {
+			i++;
+			if (unlikely(i == tx_ring->count))
+				i = 0;
+		}
 	}
 
 	for (f = 0; f < nr_frags; f++) {
@@ -2968,11 +2973,13 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 
 		frag = &skb_shinfo(skb)->frags[f];
 		len = frag->size;
-		map = skb_shinfo(skb)->dma_maps[f + 1];
 		offset = 0;
 
 		while (len) {
-			struct e1000_buffer *buffer_info;
+			i++;
+			if (unlikely(i == tx_ring->count))
+				i = 0;
+
 			buffer_info = &tx_ring->buffer_info[i];
 			size = min(len, max_per_txd);
 			/* Workaround for premature desc write-backs
@@ -2988,21 +2995,18 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 				size -= 4;
 
 			buffer_info->length = size;
-			buffer_info->dma = map + offset;
+			buffer_info->dma = map[f + 1] + offset;
 			buffer_info->time_stamp = jiffies;
 			buffer_info->next_to_watch = i;
 
 			len -= size;
 			offset += size;
 			count++;
-			if (unlikely(++i == tx_ring->count)) i = 0;
 		}
 	}
 
-	i = (i == 0) ? tx_ring->count - 1 : i - 1;
 	tx_ring->buffer_info[i].skb = skb;
 	tx_ring->buffer_info[first].next_to_watch = i;
-	smp_wmb();
 
 	return count;
 }
@@ -3318,14 +3322,20 @@ static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	if (likely(skb->protocol == htons(ETH_P_IP)))
 		tx_flags |= E1000_TX_FLAGS_IPV4;
 
-	e1000_tx_queue(adapter, tx_ring, tx_flags,
-	               e1000_tx_map(adapter, tx_ring, skb, first,
-	                            max_per_txd, nr_frags, mss));
+	count = e1000_tx_map(adapter, tx_ring, skb, first, max_per_txd,
+	                     nr_frags, mss);
 
-	netdev->trans_start = jiffies;
+	if (count) {
+		e1000_tx_queue(adapter, tx_ring, tx_flags, count);
+		netdev->trans_start = jiffies;
+		/* Make sure there is space in the ring for the next send. */
+		e1000_maybe_stop_tx(netdev, tx_ring, MAX_SKB_FRAGS + 2);
 
-	/* Make sure there is space in the ring for the next send. */
-	e1000_maybe_stop_tx(netdev, tx_ring, MAX_SKB_FRAGS + 2);
+	} else {
+		dev_kfree_skb_any(skb);
+		tx_ring->buffer_info[first].time_stamp = 0;
+		tx_ring->next_to_use = first;
+	}
 
 	return NETDEV_TX_OK;
 }
@@ -3842,12 +3852,7 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
 		/* Detect a transmit hang in hardware, this serializes the
 		 * check with the clearing of time_stamp and movement of i */
 		adapter->detect_tx_hung = false;
-		/*
-		 * read barrier to make sure that the ->dma member and time
-		 * stamp are updated fully
-		 */
-		smp_rmb();
-		if (tx_ring->buffer_info[eop].dma &&
+		if (tx_ring->buffer_info[eop].time_stamp &&
 		    time_after(jiffies, tx_ring->buffer_info[eop].time_stamp +
 		               (adapter->tx_timeout_factor * HZ))
 		    && !(er32(STATUS) & E1000_STATUS_TXOFF)) {

