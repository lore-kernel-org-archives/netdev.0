From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/10] ixgbe: Move poll routine in order to improve readability
Date: Mon, 19 Mar 2012 14:22:32 -0700
Message-ID: <1332192158-14771-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1332192158-14771-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:57948 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755461Ab2CSVWn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Mar 2012 17:22:43 -0400
In-Reply-To: <1332192158-14771-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change relocates the ixgbe_poll routine so it is right next to the
interrupt routine that schedules and calls it.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   98 ++++++++++++------------
 1 files changed, 49 insertions(+), 49 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 6453e3a5..73bba8b4 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2308,6 +2308,55 @@ static irqreturn_t ixgbe_msix_clean_rings(int irq, void *data)
 }
 
 /**
+ * ixgbe_poll - NAPI Rx polling callback
+ * @napi: structure for representing this polling device
+ * @budget: how many packets driver is allowed to clean
+ *
+ * This function is used for legacy and MSI, NAPI mode
+ **/
+static int ixgbe_poll(struct napi_struct *napi, int budget)
+{
+	struct ixgbe_q_vector *q_vector =
+				container_of(napi, struct ixgbe_q_vector, napi);
+	struct ixgbe_adapter *adapter = q_vector->adapter;
+	struct ixgbe_ring *ring;
+	int per_ring_budget;
+	bool clean_complete = true;
+
+#ifdef CONFIG_IXGBE_DCA
+	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
+		ixgbe_update_dca(q_vector);
+#endif
+
+	ixgbe_for_each_ring(ring, q_vector->tx)
+		clean_complete &= !!ixgbe_clean_tx_irq(q_vector, ring);
+
+	/* attempt to distribute budget to each queue fairly, but don't allow
+	 * the budget to go below 1 because we'll exit polling */
+	if (q_vector->rx.count > 1)
+		per_ring_budget = max(budget/q_vector->rx.count, 1);
+	else
+		per_ring_budget = budget;
+
+	ixgbe_for_each_ring(ring, q_vector->rx)
+		clean_complete &= ixgbe_clean_rx_irq(q_vector, ring,
+						     per_ring_budget);
+
+	/* If all work not completed, return budget and keep polling */
+	if (!clean_complete)
+		return budget;
+
+	/* all work done, exit the polling mode */
+	napi_complete(napi);
+	if (adapter->rx_itr_setting & 1)
+		ixgbe_set_itr(q_vector);
+	if (!test_bit(__IXGBE_DOWN, &adapter->state))
+		ixgbe_irq_enable_queues(adapter, ((u64)1 << q_vector->v_idx));
+
+	return 0;
+}
+
+/**
  * ixgbe_request_msix_irqs - Initialize MSI-X interrupts
  * @adapter: board private structure
  *
@@ -4254,55 +4303,6 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 }
 
 /**
- * ixgbe_poll - NAPI Rx polling callback
- * @napi: structure for representing this polling device
- * @budget: how many packets driver is allowed to clean
- *
- * This function is used for legacy and MSI, NAPI mode
- **/
-static int ixgbe_poll(struct napi_struct *napi, int budget)
-{
-	struct ixgbe_q_vector *q_vector =
-				container_of(napi, struct ixgbe_q_vector, napi);
-	struct ixgbe_adapter *adapter = q_vector->adapter;
-	struct ixgbe_ring *ring;
-	int per_ring_budget;
-	bool clean_complete = true;
-
-#ifdef CONFIG_IXGBE_DCA
-	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
-		ixgbe_update_dca(q_vector);
-#endif
-
-	ixgbe_for_each_ring(ring, q_vector->tx)
-		clean_complete &= !!ixgbe_clean_tx_irq(q_vector, ring);
-
-	/* attempt to distribute budget to each queue fairly, but don't allow
-	 * the budget to go below 1 because we'll exit polling */
-	if (q_vector->rx.count > 1)
-		per_ring_budget = max(budget/q_vector->rx.count, 1);
-	else
-		per_ring_budget = budget;
-
-	ixgbe_for_each_ring(ring, q_vector->rx)
-		clean_complete &= ixgbe_clean_rx_irq(q_vector, ring,
-						     per_ring_budget);
-
-	/* If all work not completed, return budget and keep polling */
-	if (!clean_complete)
-		return budget;
-
-	/* all work done, exit the polling mode */
-	napi_complete(napi);
-	if (adapter->rx_itr_setting & 1)
-		ixgbe_set_itr(q_vector);
-	if (!test_bit(__IXGBE_DOWN, &adapter->state))
-		ixgbe_irq_enable_queues(adapter, ((u64)1 << q_vector->v_idx));
-
-	return 0;
-}
-
-/**
  * ixgbe_tx_timeout - Respond to a Tx Hang
  * @netdev: network interface device structure
  **/
-- 
1.7.7.6
