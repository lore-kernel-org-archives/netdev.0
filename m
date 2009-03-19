From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 2/3] e1000e: fix dma error handling issues
Date: Thu, 19 Mar 2009 04:12:50 -0700
Message-ID: <20090319111250.11601.23708.stgit@lost.foo-projects.org>
References: <20090319111226.11601.40603.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.westchester.pa.mail.comcast.net ([76.96.59.211]:50523
	"EHLO QMTA11.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754936AbZCSLNK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 07:13:10 -0400
In-Reply-To: <20090319111226.11601.40603.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

There were a few issues I noticed in e1000e. These include a double free
of the skb if mapping fails, and the fact that context descriptors appear
to be left in the descriptor ring after the failure.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c |   76 ++++++++++++++++++-------------------------
 1 files changed, 32 insertions(+), 44 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 402d2dd..da876d5 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -574,6 +574,7 @@ static void e1000_put_txbuf(struct e1000_adapter *adapter,
 		dev_kfree_skb_any(buffer_info->skb);
 		buffer_info->skb = NULL;
 	}
+	buffer_info->time_stamp = 0;
 }
 
 static void e1000_print_tx_hang(struct e1000_adapter *adapter)
@@ -678,17 +679,10 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter)
 	}
 
 	if (adapter->detect_tx_hung) {
-		/*
-		 * Detect a transmit hang in hardware, this serializes the
-		 * check with the clearing of time_stamp and movement of i
-		 */
+		/* Detect a transmit hang in hardware, this serializes the
+		 * check with the clearing of time_stamp and movement of i */
 		adapter->detect_tx_hung = 0;
-		/*
-		 * read barrier to make sure that the ->dma member and time
-		 * stamp are updated fully
-		 */
-		smp_rmb();
-		if (tx_ring->buffer_info[eop].dma &&
+		if (tx_ring->buffer_info[eop].time_stamp &&
 		    time_after(jiffies, tx_ring->buffer_info[eop].time_stamp
 			       + (adapter->tx_timeout_factor * HZ))
 		    && !(er32(STATUS) & E1000_STATUS_TXOFF)) {
@@ -3824,39 +3818,41 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 			unsigned int mss)
 {
 	struct e1000_ring *tx_ring = adapter->tx_ring;
+	struct e1000_buffer *buffer_info;
 	unsigned int len = skb_headlen(skb);
 	unsigned int offset, size, count = 0, i;
 	unsigned int f;
-	dma_addr_t map;
+	dma_addr_t *map;
 
 	i = tx_ring->next_to_use;
 
 	if (skb_dma_map(&adapter->pdev->dev, skb, DMA_TO_DEVICE)) {
 		dev_err(&adapter->pdev->dev, "TX DMA map failed\n");
 		adapter->tx_dma_failed++;
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
 
 		buffer_info->length = size;
-		/* set time_stamp *before* dma to help avoid a possible race */
 		buffer_info->time_stamp = jiffies;
-		buffer_info->dma = map + offset;
 		buffer_info->next_to_watch = i;
+		buffer_info->dma = map[0] + offset;
+		count++;
 
 		len -= size;
 		offset += size;
-		count++;
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
@@ -3864,37 +3860,29 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 
 		frag = &skb_shinfo(skb)->frags[f];
 		len = frag->size;
-		map = skb_shinfo(skb)->dma_maps[f + 1];
 		offset = 0;
 
 		while (len) {
-			struct e1000_buffer *buffer_info;
+			i++;
+			if (i == tx_ring->count)
+				i = 0;
+
 			buffer_info = &tx_ring->buffer_info[i];
 			size = min(len, max_per_txd);
 
 			buffer_info->length = size;
 			buffer_info->time_stamp = jiffies;
-			buffer_info->dma = map + offset;
 			buffer_info->next_to_watch = i;
+			buffer_info->dma = map[f + 1] + offset;
 
 			len -= size;
 			offset += size;
 			count++;
-
-			i++;
-			if (i == tx_ring->count)
-				i = 0;
 		}
 	}
 
-	if (i == 0)
-		i = tx_ring->count - 1;
-	else
-		i--;
-
 	tx_ring->buffer_info[i].skb = skb;
 	tx_ring->buffer_info[first].next_to_watch = i;
-	smp_wmb();
 
 	return count;
 }
@@ -4145,20 +4133,20 @@ static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	if (skb->protocol == htons(ETH_P_IP))
 		tx_flags |= E1000_TX_FLAGS_IPV4;
 
+	/* if count is 0 then mapping error has occured */
 	count = e1000_tx_map(adapter, skb, first, max_per_txd, nr_frags, mss);
-	if (count < 0) {
-		/* handle pci_map_single() error in e1000_tx_map */
+	if (count) {
+		e1000_tx_queue(adapter, tx_flags, count);
+		netdev->trans_start = jiffies;
+		/* Make sure there is space in the ring for the next send. */
+		e1000_maybe_stop_tx(netdev, MAX_SKB_FRAGS + 2);
+
+	} else {
 		dev_kfree_skb_any(skb);
-		return NETDEV_TX_OK;
+		tx_ring->buffer_info[first].time_stamp = 0;
+		tx_ring->next_to_use = first;
 	}
 
-	e1000_tx_queue(adapter, tx_flags, count);
-
-	netdev->trans_start = jiffies;
-
-	/* Make sure there is space in the ring for the next send. */
-	e1000_maybe_stop_tx(netdev, MAX_SKB_FRAGS + 2);
-
 	return NETDEV_TX_OK;
 }
 

