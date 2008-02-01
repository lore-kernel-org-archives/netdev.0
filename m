From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 2/8] ixbge: remove TX lock and redo TX accounting.
Date: Fri, 01 Feb 2008 15:58:49 -0800
Message-ID: <20080201235849.31474.98597.stgit@localhost.localdomain>
References: <20080201235841.31474.49421.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:13742 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760623AbYBAX7X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2008 18:59:23 -0500
In-Reply-To: <20080201235841.31474.49421.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>

This ports Herbert Xu's "maybe_stop_tx" code and removes the tx_lock
which is not needed.

Signed-off-by: Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgbe/ixgbe.h      |    2 -
 drivers/net/ixgbe/ixgbe_main.c |  110 ++++++++++++++++++++++++++++------------
 2 files changed, 76 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 7dd9a03..d0bf206 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -136,8 +136,6 @@ struct ixgbe_ring {
 	u16 head;
 	u16 tail;
 
-	/* To protect race between sender and clean_tx_irq */
-	spinlock_t tx_lock;
 
 	struct ixgbe_queue_stats stats;
 
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 28bb203..b4c9c77 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -165,6 +165,15 @@ static inline bool ixgbe_check_tx_hang(struct ixgbe_adapter *adapter,
 	return false;
 }
 
+#define IXGBE_MAX_TXD_PWR	14
+#define IXGBE_MAX_DATA_PER_TXD	(1 << IXGBE_MAX_TXD_PWR)
+
+/* Tx Descriptors needed, worst case */
+#define TXD_USE_COUNT(S) (((S) >> IXGBE_MAX_TXD_PWR) + \
+			 (((S) & (IXGBE_MAX_DATA_PER_TXD - 1)) ? 1 : 0))
+#define DESC_NEEDED (TXD_USE_COUNT(IXGBE_MAX_DATA_PER_TXD) /* skb->data */ + \
+	MAX_SKB_FRAGS * TXD_USE_COUNT(PAGE_SIZE) + 1)	/* for context */
+
 /**
  * ixgbe_clean_tx_irq - Reclaim resources after transmit completes
  * @adapter: board private structure
@@ -177,18 +186,34 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_adapter *adapter,
 	struct ixgbe_tx_buffer *tx_buffer_info;
 	unsigned int i, eop;
 	bool cleaned = false;
-	int count = 0;
+	unsigned int total_tx_bytes = 0, total_tx_packets = 0;
 
 	i = tx_ring->next_to_clean;
 	eop = tx_ring->tx_buffer_info[i].next_to_watch;
 	eop_desc = IXGBE_TX_DESC_ADV(*tx_ring, eop);
 	while (eop_desc->wb.status & cpu_to_le32(IXGBE_TXD_STAT_DD)) {
-		for (cleaned = false; !cleaned;) {
+		cleaned = false;
+		while (!cleaned) {
 			tx_desc = IXGBE_TX_DESC_ADV(*tx_ring, i);
 			tx_buffer_info = &tx_ring->tx_buffer_info[i];
 			cleaned = (i == eop);
 
 			tx_ring->stats.bytes += tx_buffer_info->length;
+			if (cleaned) {
+				struct sk_buff *skb = tx_buffer_info->skb;
+#ifdef NETIF_F_TSO
+				unsigned int segs, bytecount;
+				segs = skb_shinfo(skb)->gso_segs ?: 1;
+				/* multiply data chunks by size of headers */
+				bytecount = ((segs - 1) * skb_headlen(skb)) +
+					    skb->len;
+				total_tx_packets += segs;
+				total_tx_bytes += bytecount;
+#else
+				total_tx_packets++;
+				total_tx_bytes += skb->len;
+#endif
+			}
 			ixgbe_unmap_and_free_tx_resource(adapter,
 							 tx_buffer_info);
 			tx_desc->wb.status = 0;
@@ -204,29 +229,34 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_adapter *adapter,
 		eop_desc = IXGBE_TX_DESC_ADV(*tx_ring, eop);
 
 		/* weight of a sort for tx, avoid endless transmit cleanup */
-		if (count++ >= tx_ring->work_limit)
+		if (total_tx_packets >= tx_ring->work_limit)
 			break;
 	}
 
 	tx_ring->next_to_clean = i;
 
-#define TX_WAKE_THRESHOLD 32
-	spin_lock(&tx_ring->tx_lock);
-
-	if (cleaned && netif_carrier_ok(netdev) &&
-	    (IXGBE_DESC_UNUSED(tx_ring) >= TX_WAKE_THRESHOLD) &&
-	    !test_bit(__IXGBE_DOWN, &adapter->state))
-		netif_wake_queue(netdev);
-
-	spin_unlock(&tx_ring->tx_lock);
+#define TX_WAKE_THRESHOLD (DESC_NEEDED * 2)
+	if (total_tx_packets && netif_carrier_ok(netdev) &&
+	    (IXGBE_DESC_UNUSED(tx_ring) >= TX_WAKE_THRESHOLD)) {
+		/* Make sure that anybody stopping the queue after this
+		 * sees the new next_to_clean.
+		 */
+		smp_mb();
+		if (netif_queue_stopped(netdev) &&
+		    !test_bit(__IXGBE_DOWN, &adapter->state)) {
+			netif_wake_queue(netdev);
+			adapter->restart_queue++;
+		}
+	}
 
 	if (adapter->detect_tx_hung)
 		if (ixgbe_check_tx_hang(adapter, tx_ring, eop, eop_desc))
 			netif_stop_queue(netdev);
 
-	if (count >= tx_ring->work_limit)
+	if (total_tx_packets >= tx_ring->work_limit)
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EICS, tx_ring->eims_value);
 
+	cleaned = total_tx_packets ? true : false;
 	return cleaned;
 }
 
@@ -1646,7 +1676,6 @@ int ixgbe_setup_tx_resources(struct ixgbe_adapter *adapter,
 	txdr->next_to_use = 0;
 	txdr->next_to_clean = 0;
 	txdr->work_limit = txdr->count;
-	spin_lock_init(&txdr->tx_lock);
 
 	return 0;
 }
@@ -2086,15 +2115,6 @@ static void ixgbe_watchdog(unsigned long data)
 			  round_jiffies(jiffies + 2 * HZ));
 }
 
-#define IXGBE_MAX_TXD_PWR	14
-#define IXGBE_MAX_DATA_PER_TXD	(1 << IXGBE_MAX_TXD_PWR)
-
-/* Tx Descriptors needed, worst case */
-#define TXD_USE_COUNT(S) (((S) >> IXGBE_MAX_TXD_PWR) + \
-			 (((S) & (IXGBE_MAX_DATA_PER_TXD - 1)) ? 1 : 0))
-#define DESC_NEEDED (TXD_USE_COUNT(IXGBE_MAX_DATA_PER_TXD) /* skb->data */ + \
-	MAX_SKB_FRAGS * TXD_USE_COUNT(PAGE_SIZE) + 1)	/* for context */
-
 static int ixgbe_tso(struct ixgbe_adapter *adapter,
 			 struct ixgbe_ring *tx_ring, struct sk_buff *skb,
 			 u32 tx_flags, u8 *hdr_len)
@@ -2366,6 +2386,37 @@ static void ixgbe_tx_queue(struct ixgbe_adapter *adapter,
 	writel(i, adapter->hw.hw_addr + tx_ring->tail);
 }
 
+static int __ixgbe_maybe_stop_tx(struct net_device *netdev,
+				 struct ixgbe_ring *tx_ring, int size)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+
+	netif_stop_queue(netdev);
+	/* Herbert's original patch had:
+	 *  smp_mb__after_netif_stop_queue();
+	 * but since that doesn't exist yet, just open code it. */
+	smp_mb();
+
+	/* We need to check again in a case another CPU has just
+	 * made room available. */
+	if (likely(IXGBE_DESC_UNUSED(tx_ring) < size))
+		return -EBUSY;
+
+	/* A reprieve! - use start_queue because it doesn't call schedule */
+	netif_wake_queue(netdev);
+	++adapter->restart_queue;
+	return 0;
+}
+
+static int ixgbe_maybe_stop_tx(struct net_device *netdev,
+			       struct ixgbe_ring *tx_ring, int size)
+{
+	if (likely(IXGBE_DESC_UNUSED(tx_ring) >= size))
+		return 0;
+	return __ixgbe_maybe_stop_tx(netdev, tx_ring, size);
+}
+
+
 static int ixgbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
@@ -2373,7 +2424,6 @@ static int ixgbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	unsigned int len = skb->len;
 	unsigned int first;
 	unsigned int tx_flags = 0;
-	unsigned long flags = 0;
 	u8 hdr_len;
 	int tso;
 	unsigned int mss = 0;
@@ -2399,14 +2449,10 @@ static int ixgbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	for (f = 0; f < nr_frags; f++)
 		count += TXD_USE_COUNT(skb_shinfo(skb)->frags[f].size);
 
-	spin_lock_irqsave(&tx_ring->tx_lock, flags);
-	if (IXGBE_DESC_UNUSED(tx_ring) < (count + 2)) {
+	if (ixgbe_maybe_stop_tx(netdev, tx_ring, count)) {
 		adapter->tx_busy++;
-		netif_stop_queue(netdev);
-		spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
 		return NETDEV_TX_BUSY;
 	}
-	spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
 	if (adapter->vlgrp && vlan_tx_tag_present(skb)) {
 		tx_flags |= IXGBE_TX_FLAGS_VLAN;
 		tx_flags |= (vlan_tx_tag_get(skb) << IXGBE_TX_FLAGS_VLAN_SHIFT);
@@ -2433,11 +2479,7 @@ static int ixgbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 	netdev->trans_start = jiffies;
 
-	spin_lock_irqsave(&tx_ring->tx_lock, flags);
-	/* Make sure there is space in the ring for the next send. */
-	if (IXGBE_DESC_UNUSED(tx_ring) < DESC_NEEDED)
-		netif_stop_queue(netdev);
-	spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
+	ixgbe_maybe_stop_tx(netdev, tx_ring, DESC_NEEDED);
 
 	return NETDEV_TX_OK;
 }

