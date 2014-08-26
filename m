From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH v2 net-next] ixgbe: flush when in xmit_more mode and under descriptor pressure
Date: Tue, 26 Aug 2014 19:34:18 +0200
Message-ID: <1409074458-17989-1-git-send-email-dborkman@redhat.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36475 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751592AbaHZReW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2014 13:34:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When xmit_more mode is being used and the ring is about to
become full or the stack has stopped the ring, enforce a tail
pointer write to the hw. Otherwise, we could risk a TX hang.

Code suggested by Alexander Duyck.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 v1->v2:
  - Worked in Alex' feedback; in accordance w/ Alex, sending out v2
  - Rerun tests, looks good

 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 63 +++++++++++++++------------
 1 file changed, 34 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index ba9ceaa..53fbf06 100644
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
 
@@ -6958,10 +6988,13 @@ static void ixgbe_tx_map(struct ixgbe_ring *tx_ring,
 
 	tx_ring->next_to_use = i;
 
-	if (!skb->xmit_more) {
+	ixgbe_maybe_stop_tx(tx_ring, DESC_NEEDED);
+
+	if (netif_xmit_stopped(txring_txq(tx_ring)) || !skb->xmit_more) {
 		/* notify HW of packet */
 		ixgbe_write_tail(tx_ring, i);
 	}
+
 	return;
 dma_error:
 	dev_err(tx_ring->dev, "TX DMA map failed\n");
@@ -7068,32 +7101,6 @@ static void ixgbe_atr(struct ixgbe_ring *ring,
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
@@ -7262,8 +7269,6 @@ xmit_fcoe:
 #endif /* IXGBE_FCOE */
 	ixgbe_tx_map(tx_ring, first, hdr_len);
 
-	ixgbe_maybe_stop_tx(tx_ring, DESC_NEEDED);
-
 	return NETDEV_TX_OK;
 
 out_drop:
-- 
1.7.11.7
