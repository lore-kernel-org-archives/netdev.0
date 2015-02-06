From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 13/16] ixgbevf: Add code to check for Tx hang
Date: Thu,  5 Feb 2015 20:31:22 -0800
Message-ID: <1423197085-32270-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1423197085-32270-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	kernel-team@fb.com, Alexander Duyck <alexander.h.duyck@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:49678 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754595AbbBFEbo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Feb 2015 23:31:44 -0500
In-Reply-To: <1423197085-32270-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch adds code to allow for Tx hang checking.  The idea is to provide
more robust debug info in the event of a transmit unit hang. Similar to the
logic in ixgbe.

CC: Alexander Duyck <alexander.h.duyck@redhat.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |  21 +++-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 113 ++++++++++++++++++----
 2 files changed, 115 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index 65cda34..65c2aee 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -43,6 +43,13 @@
 #define BP_EXTENDED_STATS
 #endif
 
+#define IXGBE_MAX_TXD_PWR	14
+#define IXGBE_MAX_DATA_PER_TXD	BIT(IXGBE_MAX_TXD_PWR)
+
+/* Tx Descriptors needed, worst case */
+#define TXD_USE_COUNT(S) DIV_ROUND_UP((S), IXGBE_MAX_DATA_PER_TXD)
+#define DESC_NEEDED (MAX_SKB_FRAGS + 4)
+
 /* wrapper around a pointer to a socket buffer,
  * so a DMA handle can be stored along with the buffer */
 struct ixgbevf_tx_buffer {
@@ -85,6 +92,18 @@ struct ixgbevf_rx_queue_stats {
 	u64 csum_err;
 };
 
+enum ixgbevf_ring_state_t {
+	__IXGBEVF_TX_DETECT_HANG,
+	__IXGBEVF_HANG_CHECK_ARMED,
+};
+
+#define check_for_tx_hang(ring) \
+	test_bit(__IXGBEVF_TX_DETECT_HANG, &(ring)->state)
+#define set_check_for_tx_hang(ring) \
+	set_bit(__IXGBEVF_TX_DETECT_HANG, &(ring)->state)
+#define clear_check_for_tx_hang(ring) \
+	clear_bit(__IXGBEVF_TX_DETECT_HANG, &(ring)->state)
+
 struct ixgbevf_ring {
 	struct ixgbevf_ring *next;
 	struct net_device *netdev;
@@ -101,7 +120,7 @@ struct ixgbevf_ring {
 		struct ixgbevf_tx_buffer *tx_buffer_info;
 		struct ixgbevf_rx_buffer *rx_buffer_info;
 	};
-
+	unsigned long state;
 	struct ixgbevf_stats stats;
 	struct u64_stats_sync syncp;
 	union {
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index a4b3d66..87f9f86 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -199,14 +199,64 @@ static void ixgbevf_unmap_and_free_tx_resource(struct ixgbevf_ring *tx_ring,
 	/* tx_buffer must be completely set up in the transmit path */
 }
 
-#define IXGBE_MAX_TXD_PWR	14
-#define IXGBE_MAX_DATA_PER_TXD	(1 << IXGBE_MAX_TXD_PWR)
+static u64 ixgbevf_get_tx_completed(struct ixgbevf_ring *ring)
+{
+	return ring->stats.packets;
+}
+
+static u32 ixgbevf_get_tx_pending(struct ixgbevf_ring *ring)
+{
+	struct ixgbevf_adapter *adapter = netdev_priv(ring->netdev);
+	struct ixgbe_hw *hw = &adapter->hw;
+
+	u32 head = IXGBE_READ_REG(hw, IXGBE_VFTDH(ring->reg_idx));
+	u32 tail = IXGBE_READ_REG(hw, IXGBE_VFTDT(ring->reg_idx));
+
+	if (head != tail)
+		return (head < tail) ?
+			tail - head : (tail + ring->count - head);
+
+	return 0;
+}
+
+static inline bool ixgbevf_check_tx_hang(struct ixgbevf_ring *tx_ring)
+{
+	u32 tx_done = ixgbevf_get_tx_completed(tx_ring);
+	u32 tx_done_old = tx_ring->tx_stats.tx_done_old;
+	u32 tx_pending = ixgbevf_get_tx_pending(tx_ring);
+
+	clear_check_for_tx_hang(tx_ring);
 
-/* Tx Descriptors needed, worst case */
-#define TXD_USE_COUNT(S) DIV_ROUND_UP((S), IXGBE_MAX_DATA_PER_TXD)
-#define DESC_NEEDED (MAX_SKB_FRAGS + 4)
+	/* Check for a hung queue, but be thorough. This verifies
+	 * that a transmit has been completed since the previous
+	 * check AND there is at least one packet pending. The
+	 * ARMED bit is set to indicate a potential hang.
+	 */
+	if ((tx_done_old == tx_done) && tx_pending) {
+		/* make sure it is true for two checks in a row */
+		return test_and_set_bit(__IXGBEVF_HANG_CHECK_ARMED,
+					&tx_ring->state);
+	}
+	/* reset the countdown */
+	clear_bit(__IXGBEVF_HANG_CHECK_ARMED, &tx_ring->state);
+
+	/* update completed stats and continue */
+	tx_ring->tx_stats.tx_done_old = tx_done;
+
+	return false;
+}
+
+/**
+ * ixgbevf_tx_timeout - Respond to a Tx Hang
+ * @netdev: network interface device structure
+ **/
+static void ixgbevf_tx_timeout(struct net_device *netdev)
+{
+	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
 
-static void ixgbevf_tx_timeout(struct net_device *netdev);
+	/* Do the reset outside of interrupt context */
+	schedule_work(&adapter->reset_task);
+}
 
 /**
  * ixgbevf_clean_tx_irq - Reclaim resources after transmit completes
@@ -311,6 +361,37 @@ static bool ixgbevf_clean_tx_irq(struct ixgbevf_q_vector *q_vector,
 	q_vector->tx.total_bytes += total_bytes;
 	q_vector->tx.total_packets += total_packets;
 
+	if (check_for_tx_hang(tx_ring) && ixgbevf_check_tx_hang(tx_ring)) {
+		struct ixgbe_hw *hw = &adapter->hw;
+		union ixgbe_adv_tx_desc *eop_desc;
+
+		eop_desc = tx_ring->tx_buffer_info[i].next_to_watch;
+
+		pr_err("Detected Tx Unit Hang\n"
+		       "  Tx Queue             <%d>\n"
+		       "  TDH, TDT             <%x>, <%x>\n"
+		       "  next_to_use          <%x>\n"
+		       "  next_to_clean        <%x>\n"
+		       "tx_buffer_info[next_to_clean]\n"
+		       "  next_to_watch        <%p>\n"
+		       "  eop_desc->wb.status  <%x>\n"
+		       "  time_stamp           <%lx>\n"
+		       "  jiffies              <%lx>\n",
+		       tx_ring->queue_index,
+		       IXGBE_READ_REG(hw, IXGBE_VFTDH(tx_ring->reg_idx)),
+		       IXGBE_READ_REG(hw, IXGBE_VFTDT(tx_ring->reg_idx)),
+		       tx_ring->next_to_use, i,
+		       eop_desc, (eop_desc ? eop_desc->wb.status : 0),
+		       tx_ring->tx_buffer_info[i].time_stamp, jiffies);
+
+		netif_stop_subqueue(tx_ring->netdev, tx_ring->queue_index);
+
+		/* schedule immediate reset if we believe we hung */
+		schedule_work(&adapter->reset_task);
+
+		return true;
+	}
+
 #define TX_WAKE_THRESHOLD (DESC_NEEDED * 2)
 	if (unlikely(total_packets && netif_carrier_ok(tx_ring->netdev) &&
 		     (ixgbevf_desc_unused(tx_ring) >= TX_WAKE_THRESHOLD))) {
@@ -1479,6 +1560,8 @@ static void ixgbevf_configure_tx_ring(struct ixgbevf_adapter *adapter,
 	txdctl |= (1 << 8) |    /* HTHRESH = 1 */
 		  32;          /* PTHRESH = 32 */
 
+	clear_bit(__IXGBEVF_HANG_CHECK_ARMED, &ring->state);
+
 	IXGBE_WRITE_REG(hw, IXGBE_VFTXDCTL(reg_idx), txdctl);
 
 	/* poll to verify queue is enabled */
@@ -2643,6 +2726,12 @@ static void ixgbevf_watchdog(unsigned long data)
 	if (test_bit(__IXGBEVF_DOWN, &adapter->state))
 		goto watchdog_short_circuit;
 
+	/* Force detection of hung controller */
+	if (netif_carrier_ok(adapter->netdev)) {
+		for (i = 0; i < adapter->num_tx_queues; i++)
+			set_check_for_tx_hang(adapter->tx_ring[i]);
+	}
+
 	/* get one bit for every active tx/rx interrupt vector */
 	for (i = 0; i < adapter->num_msix_vectors - NON_Q_VECTORS; i++) {
 		struct ixgbevf_q_vector *qv = adapter->q_vector[i];
@@ -2656,18 +2745,6 @@ watchdog_short_circuit:
 	schedule_work(&adapter->watchdog_task);
 }
 
-/**
- * ixgbevf_tx_timeout - Respond to a Tx Hang
- * @netdev: network interface device structure
- **/
-static void ixgbevf_tx_timeout(struct net_device *netdev)
-{
-	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
-
-	/* Do the reset outside of interrupt context */
-	schedule_work(&adapter->reset_task);
-}
-
 static void ixgbevf_reset_task(struct work_struct *work)
 {
 	struct ixgbevf_adapter *adapter;
-- 
1.9.3
