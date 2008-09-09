From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 17/24] ixgbe: add clean rx many routine
Date: Mon, 08 Sep 2008 21:48:17 -0700
Message-ID: <20080909044817.18904.24592.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080909044734.18904.93208.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:34578 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752653AbYIIEsU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 00:48:20 -0400
Received: by yx-out-2324.google.com with SMTP id 8so1027474yxm.1
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2008 21:48:19 -0700 (PDT)
In-Reply-To: <20080909044734.18904.93208.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

in some configurations there can be more than one rx queue per vector
in msi-x mode.  Add functionality to be able to clean this without
changing the performance path single-rx-queue cleanup.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   62 +++++++++++++++++++++++++++++++++++++++-
 1 files changed, 60 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 27d69e4..49e0987 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1024,13 +1024,15 @@ static irqreturn_t ixgbe_msix_clean_many(int irq, void *data)
  * @napi: napi struct with our devices info in it
  * @budget: amount of work driver is allowed to do this pass, in packets
  *
+ * This function is optimized for cleaning one queue only on a single
+ * q_vector!!!
  **/
 static int ixgbe_clean_rxonly(struct napi_struct *napi, int budget)
 {
 	struct ixgbe_q_vector *q_vector =
 			       container_of(napi, struct ixgbe_q_vector, napi);
 	struct ixgbe_adapter *adapter = q_vector->adapter;
-	struct ixgbe_ring *rx_ring;
+	struct ixgbe_ring *rx_ring = NULL;
 	int work_done = 0;
 	long r_idx;
 
@@ -1055,6 +1057,56 @@ static int ixgbe_clean_rxonly(struct napi_struct *napi, int budget)
 	return work_done;
 }
 
+/**
+ * ixgbe_clean_rxonly_many - msix (aka one shot) rx clean routine
+ * @napi: napi struct with our devices info in it
+ * @budget: amount of work driver is allowed to do this pass, in packets
+ *
+ * This function will clean more than one rx queue associated with a
+ * q_vector.
+ **/
+static int ixgbe_clean_rxonly_many(struct napi_struct *napi, int budget)
+{
+	struct ixgbe_q_vector *q_vector =
+	                       container_of(napi, struct ixgbe_q_vector, napi);
+	struct ixgbe_adapter *adapter = q_vector->adapter;
+	struct net_device *netdev = adapter->netdev;
+	struct ixgbe_ring *rx_ring = NULL;
+	int work_done = 0, i;
+	long r_idx;
+	u16 enable_mask = 0;
+
+	/* attempt to distribute budget to each queue fairly, but don't allow
+	 * the budget to go below 1 because we'll exit polling */
+	budget /= (q_vector->rxr_count ?: 1);
+	budget = max(budget, 1);
+	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
+	for (i = 0; i < q_vector->rxr_count; i++) {
+		rx_ring = &(adapter->rx_ring[r_idx]);
+#if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
+		if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
+			ixgbe_update_rx_dca(adapter, rx_ring);
+#endif
+		ixgbe_clean_rx_irq(adapter, rx_ring, &work_done, budget);
+		enable_mask |= rx_ring->v_idx;
+		r_idx = find_next_bit(q_vector->rxr_idx, adapter->num_rx_queues,
+		                      r_idx + 1);
+	}
+
+	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
+	rx_ring = &(adapter->rx_ring[r_idx]);
+	/* If all Rx work done, exit the polling mode */
+	if ((work_done == 0) || !netif_running(netdev)) {
+		netif_rx_complete(netdev, napi);
+		if (adapter->itr_setting & 3)
+			ixgbe_set_itr_msix(q_vector);
+		if (!test_bit(__IXGBE_DOWN, &adapter->state))
+			IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS, enable_mask);
+		return 0;
+	}
+
+	return work_done;
+}
 static inline void map_vector_to_rxq(struct ixgbe_adapter *a, int v_idx,
 				     int r_idx)
 {
@@ -1813,10 +1865,16 @@ static void ixgbe_napi_enable_all(struct ixgbe_adapter *adapter)
 		q_vectors = 1;
 
 	for (q_idx = 0; q_idx < q_vectors; q_idx++) {
+		struct napi_struct *napi;
 		q_vector = &adapter->q_vector[q_idx];
 		if (!q_vector->rxr_count)
 			continue;
-		napi_enable(&q_vector->napi);
+		napi = &q_vector->napi;
+		if ((adapter->flags & IXGBE_FLAG_MSIX_ENABLED) &&
+		    (q_vector->rxr_count > 1))
+			napi->poll = &ixgbe_clean_rxonly_many;
+
+		napi_enable(napi);
 	}
 }
 

