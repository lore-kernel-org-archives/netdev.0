From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] ixgbe: flush when in xmit_more mode and under descriptor pressure
Date: Tue, 26 Aug 2014 17:48:25 +0200
Message-ID: <1409068105-16634-1-git-send-email-dborkman@redhat.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20951 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751607AbaHZPs3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2014 11:48:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When xmit_more mode is being used and the ring is about to become
full, enforce a tail pointer write to the hw. Otherwise, we could
risk a Tx hang as pointed out by Alex.

Suggested-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 Hi Alex, something along that lines regarding your first comment?

 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 67 +++++++++++++++------------
 1 file changed, 38 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index ba9ceaa..f851e84 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6837,6 +6837,36 @@ static void ixgbe_tx_olinfo_status(union ixgbe_adv_tx_desc *tx_desc,
 	tx_desc->read.olinfo_status = cpu_to_le32(olinfo_status);
 }
 
+static int __ixgbe_maybe_stop_tx(struct ixgbe_ring *tx_ring, u16 size)
+{
+	netif_stop_subqueue(tx_ring->netdev, tx_ring->queue_index);
+
+	/* Herbert's original patch had:
+	 *  smp_mb__after_netif_stop_queue();
+	 * but since that doesn't exist yet, just open code it.
+	 */
+	smp_mb();
+
+	/* We need to check again in a case another CPU has just
+	 * made room available.
+	 */
+	if (likely(ixgbe_desc_unused(tx_ring) < size))
+		return -EBUSY;
+
+	/* A reprieve! - use start_queue because it doesn't call schedule */
+	netif_start_subqueue(tx_ring->netdev, tx_ring->queue_index);
+	++tx_ring->tx_stats.restart_queue;
+	return 0;
+}
+
+static inline int ixgbe_maybe_stop_tx(struct ixgbe_ring *tx_ring, u16 size)
+{
+	if (likely(ixgbe_desc_unused(tx_ring) >= size))
+		return 0;
+
+	return __ixgbe_maybe_stop_tx(tx_ring, size);
+}
+
 #define IXGBE_TXD_CMD (IXGBE_TXD_CMD_EOP | \
 		       IXGBE_TXD_CMD_RS)
 
@@ -6853,6 +6883,7 @@ static void ixgbe_tx_map(struct ixgbe_ring *tx_ring,
 	u32 tx_flags = first->tx_flags;
 	u32 cmd_type = ixgbe_tx_cmd_type(skb, tx_flags);
 	u16 i = tx_ring->next_to_use;
+	bool desc_pressure;
 
 	tx_desc = IXGBE_TX_DESC(tx_ring, i);
 
@@ -6958,10 +6989,15 @@ static void ixgbe_tx_map(struct ixgbe_ring *tx_ring,
 
 	tx_ring->next_to_use = i;
 
-	if (!skb->xmit_more) {
+	desc_pressure = (ixgbe_desc_unused(tx_ring) < DESC_NEEDED);
+	if (!skb->xmit_more || unlikely(desc_pressure)) {
 		/* notify HW of packet */
 		ixgbe_write_tail(tx_ring, i);
+
+		if (unlikely(desc_pressure))
+			__ixgbe_maybe_stop_tx(tx_ring, DESC_NEEDED);
 	}
+
 	return;
 dma_error:
 	dev_err(tx_ring->dev, "TX DMA map failed\n");
@@ -6978,6 +7014,7 @@ dma_error:
 	}
 
 	tx_ring->next_to_use = i;
+	ixgbe_maybe_stop_tx(tx_ring, DESC_NEEDED);
 }
 
 static void ixgbe_atr(struct ixgbe_ring *ring,
@@ -7068,32 +7105,6 @@ static void ixgbe_atr(struct ixgbe_ring *ring,
 					      input, common, ring->queue_index);
 }
 
-static int __ixgbe_maybe_stop_tx(struct ixgbe_ring *tx_ring, u16 size)
-{
-	netif_stop_subqueue(tx_ring->netdev, tx_ring->queue_index);
-	/* Herbert's original patch had:
-	 *  smp_mb__after_netif_stop_queue();
-	 * but since that doesn't exist yet, just open code it. */
-	smp_mb();
-
-	/* We need to check again in a case another CPU has just
-	 * made room available. */
-	if (likely(ixgbe_desc_unused(tx_ring) < size))
-		return -EBUSY;
-
-	/* A reprieve! - use start_queue because it doesn't call schedule */
-	netif_start_subqueue(tx_ring->netdev, tx_ring->queue_index);
-	++tx_ring->tx_stats.restart_queue;
-	return 0;
-}
-
-static inline int ixgbe_maybe_stop_tx(struct ixgbe_ring *tx_ring, u16 size)
-{
-	if (likely(ixgbe_desc_unused(tx_ring) >= size))
-		return 0;
-	return __ixgbe_maybe_stop_tx(tx_ring, size);
-}
-
 static u16 ixgbe_select_queue(struct net_device *dev, struct sk_buff *skb,
 			      void *accel_priv, select_queue_fallback_t fallback)
 {
@@ -7262,8 +7273,6 @@ xmit_fcoe:
 #endif /* IXGBE_FCOE */
 	ixgbe_tx_map(tx_ring, first, hdr_len);
 
-	ixgbe_maybe_stop_tx(tx_ring, DESC_NEEDED);
-
 	return NETDEV_TX_OK;
 
 out_drop:
-- 
1.7.11.7
