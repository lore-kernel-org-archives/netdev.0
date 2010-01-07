From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/5] ixgbe: Make descriptor ring allocations
	NUMA-aware
Date: Wed, 06 Jan 2010 20:48:46 -0800
Message-ID: <20100107044845.28605.42794.stgit@localhost.localdomain>
References: <20100107044741.28605.31414.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.emeryville.ca.mail.comcast.net ([76.96.30.40]:50587 "EHLO
	QMTA04.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932609Ab0AGEtF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 23:49:05 -0500
In-Reply-To: <20100107044741.28605.31414.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

This patch allocates the ring structures themselves on each
NUMA node along with the buffer_info structures.  This way we
don't allocate the entire ring memory on a single node in one
big block, thus reducing NUMA node memory crosstalk.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h         |    7 +
 drivers/net/ixgbe/ixgbe_ethtool.c |   71 +++++-----
 drivers/net/ixgbe/ixgbe_fcoe.c    |    4 -
 drivers/net/ixgbe/ixgbe_main.c    |  270 +++++++++++++++++++------------------
 4 files changed, 185 insertions(+), 167 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 998b8d9..5e60358 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -147,7 +147,7 @@ struct ixgbe_ring {
 
 #ifdef CONFIG_IXGBE_DCA
 	/* cpu for tx queue */
-	int cpu;
+	u8 cpu;
 #endif
 
 	u16 work_limit;			/* max work per interrupt */
@@ -156,6 +156,7 @@ struct ixgbe_ring {
 					 * associated with this ring, which is
 					 * different for DCB and RSS modes
 					 */
+	u8 numa_node;
 
 	struct ixgbe_queue_stats stats;
 	unsigned long reinit_state;
@@ -277,7 +278,7 @@ struct ixgbe_adapter {
 	u16 eitr_high;
 
 	/* TX */
-	struct ixgbe_ring *tx_ring ____cacheline_aligned_in_smp; /* One per active queue */
+	struct ixgbe_ring *tx_ring[MAX_TX_QUEUES] ____cacheline_aligned_in_smp;
 	int num_tx_queues;
 	u32 tx_timeout_count;
 	bool detect_tx_hung;
@@ -286,7 +287,7 @@ struct ixgbe_adapter {
 	u64 lsc_int;
 
 	/* RX */
-	struct ixgbe_ring *rx_ring ____cacheline_aligned_in_smp; /* One per active queue */
+	struct ixgbe_ring *rx_ring[MAX_RX_QUEUES] ____cacheline_aligned_in_smp;
 	int num_rx_queues;
 	u64 hw_csum_rx_error;
 	u64 hw_rx_no_dma_resources;
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 0bd49d3..d468c03 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -834,8 +834,8 @@ static void ixgbe_get_ringparam(struct net_device *netdev,
                                 struct ethtool_ringparam *ring)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	struct ixgbe_ring *tx_ring = adapter->tx_ring;
-	struct ixgbe_ring *rx_ring = adapter->rx_ring;
+	struct ixgbe_ring *tx_ring = adapter->tx_ring[0];
+	struct ixgbe_ring *rx_ring = adapter->rx_ring[0];
 
 	ring->rx_max_pending = IXGBE_MAX_RXD;
 	ring->tx_max_pending = IXGBE_MAX_TXD;
@@ -867,8 +867,8 @@ static int ixgbe_set_ringparam(struct net_device *netdev,
 	new_tx_count = min(new_tx_count, (u32)IXGBE_MAX_TXD);
 	new_tx_count = ALIGN(new_tx_count, IXGBE_REQ_TX_DESCRIPTOR_MULTIPLE);
 
-	if ((new_tx_count == adapter->tx_ring->count) &&
-	    (new_rx_count == adapter->rx_ring->count)) {
+	if ((new_tx_count == adapter->tx_ring[0]->count) &&
+	    (new_rx_count == adapter->rx_ring[0]->count)) {
 		/* nothing to do */
 		return 0;
 	}
@@ -878,25 +878,24 @@ static int ixgbe_set_ringparam(struct net_device *netdev,
 
 	if (!netif_running(adapter->netdev)) {
 		for (i = 0; i < adapter->num_tx_queues; i++)
-			adapter->tx_ring[i].count = new_tx_count;
+			adapter->tx_ring[i]->count = new_tx_count;
 		for (i = 0; i < adapter->num_rx_queues; i++)
-			adapter->rx_ring[i].count = new_rx_count;
+			adapter->rx_ring[i]->count = new_rx_count;
 		adapter->tx_ring_count = new_tx_count;
 		adapter->rx_ring_count = new_rx_count;
-		goto err_setup;
+		goto clear_reset;
 	}
 
-	temp_tx_ring = kcalloc(adapter->num_tx_queues,
-	                       sizeof(struct ixgbe_ring), GFP_KERNEL);
+	temp_tx_ring = vmalloc(adapter->num_tx_queues * sizeof(struct ixgbe_ring));
 	if (!temp_tx_ring) {
 		err = -ENOMEM;
-		goto err_setup;
+		goto clear_reset;
 	}
 
 	if (new_tx_count != adapter->tx_ring_count) {
-		memcpy(temp_tx_ring, adapter->tx_ring,
-		       adapter->num_tx_queues * sizeof(struct ixgbe_ring));
 		for (i = 0; i < adapter->num_tx_queues; i++) {
+			memcpy(&temp_tx_ring[i], adapter->tx_ring[i],
+			       sizeof(struct ixgbe_ring));
 			temp_tx_ring[i].count = new_tx_count;
 			err = ixgbe_setup_tx_resources(adapter,
 			                               &temp_tx_ring[i]);
@@ -904,28 +903,24 @@ static int ixgbe_set_ringparam(struct net_device *netdev,
 				while (i) {
 					i--;
 					ixgbe_free_tx_resources(adapter,
-					                        &temp_tx_ring[i]);
+					                      &temp_tx_ring[i]);
 				}
-				goto err_setup;
+				goto clear_reset;
 			}
 		}
 		need_update = true;
 	}
 
-	temp_rx_ring = kcalloc(adapter->num_rx_queues,
-	                       sizeof(struct ixgbe_ring), GFP_KERNEL);
-	if ((!temp_rx_ring) && (need_update)) {
-		for (i = 0; i < adapter->num_tx_queues; i++)
-			ixgbe_free_tx_resources(adapter, &temp_tx_ring[i]);
-		kfree(temp_tx_ring);
+	temp_rx_ring = vmalloc(adapter->num_rx_queues * sizeof(struct ixgbe_ring));
+	if (!temp_rx_ring) {
 		err = -ENOMEM;
 		goto err_setup;
 	}
 
 	if (new_rx_count != adapter->rx_ring_count) {
-		memcpy(temp_rx_ring, adapter->rx_ring,
-		       adapter->num_rx_queues * sizeof(struct ixgbe_ring));
 		for (i = 0; i < adapter->num_rx_queues; i++) {
+			memcpy(&temp_rx_ring[i], adapter->rx_ring[i],
+			       sizeof(struct ixgbe_ring));
 			temp_rx_ring[i].count = new_rx_count;
 			err = ixgbe_setup_rx_resources(adapter,
 			                               &temp_rx_ring[i]);
@@ -947,22 +942,32 @@ static int ixgbe_set_ringparam(struct net_device *netdev,
 
 		/* tx */
 		if (new_tx_count != adapter->tx_ring_count) {
-			kfree(adapter->tx_ring);
-			adapter->tx_ring = temp_tx_ring;
-			temp_tx_ring = NULL;
+			for (i = 0; i < adapter->num_tx_queues; i++) {
+				ixgbe_free_tx_resources(adapter,
+				                        adapter->tx_ring[i]);
+				memcpy(adapter->tx_ring[i], &temp_tx_ring[i],
+				       sizeof(struct ixgbe_ring));
+			}
 			adapter->tx_ring_count = new_tx_count;
 		}
 
 		/* rx */
 		if (new_rx_count != adapter->rx_ring_count) {
-			kfree(adapter->rx_ring);
-			adapter->rx_ring = temp_rx_ring;
-			temp_rx_ring = NULL;
+			for (i = 0; i < adapter->num_rx_queues; i++) {
+				ixgbe_free_rx_resources(adapter,
+				                        adapter->rx_ring[i]);
+				memcpy(adapter->rx_ring[i], &temp_rx_ring[i],
+				       sizeof(struct ixgbe_ring));
+			}
 			adapter->rx_ring_count = new_rx_count;
 		}
 		ixgbe_up(adapter);
 	}
+
+	vfree(temp_rx_ring);
 err_setup:
+	vfree(temp_tx_ring);
+clear_reset:
 	clear_bit(__IXGBE_RESETTING, &adapter->state);
 	return err;
 }
@@ -1007,13 +1012,13 @@ static void ixgbe_get_ethtool_stats(struct net_device *netdev,
 		           sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
 	}
 	for (j = 0; j < adapter->num_tx_queues; j++) {
-		queue_stat = (u64 *)&adapter->tx_ring[j].stats;
+		queue_stat = (u64 *)&adapter->tx_ring[j]->stats;
 		for (k = 0; k < stat_count; k++)
 			data[i + k] = queue_stat[k];
 		i += k;
 	}
 	for (j = 0; j < adapter->num_rx_queues; j++) {
-		queue_stat = (u64 *)&adapter->rx_ring[j].stats;
+		queue_stat = (u64 *)&adapter->rx_ring[j]->stats;
 		for (k = 0; k < stat_count; k++)
 			data[i + k] = queue_stat[k];
 		i += k;
@@ -1627,7 +1632,7 @@ static int ixgbe_setup_desc_rings(struct ixgbe_adapter *adapter)
 	reg_data |= IXGBE_RXDCTL_ENABLE;
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_RXDCTL(0), reg_data);
 	if (adapter->hw.mac.type == ixgbe_mac_82599EB) {
-		int j = adapter->rx_ring[0].reg_idx;
+		int j = adapter->rx_ring[0]->reg_idx;
 		u32 k;
 		for (k = 0; k < 10; k++) {
 			if (IXGBE_READ_REG(&adapter->hw,
@@ -2000,7 +2005,7 @@ static int ixgbe_get_coalesce(struct net_device *netdev,
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
-	ec->tx_max_coalesced_frames_irq = adapter->tx_ring[0].work_limit;
+	ec->tx_max_coalesced_frames_irq = adapter->tx_ring[0]->work_limit;
 
 	/* only valid if in constant ITR mode */
 	switch (adapter->rx_itr_setting) {
@@ -2053,7 +2058,7 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
 		return -EINVAL;
 
 	if (ec->tx_max_coalesced_frames_irq)
-		adapter->tx_ring[0].work_limit = ec->tx_max_coalesced_frames_irq;
+		adapter->tx_ring[0]->work_limit = ec->tx_max_coalesced_frames_irq;
 
 	if (ec->rx_coalesce_usecs > 1) {
 		/* check the limits */
diff --git a/drivers/net/ixgbe/ixgbe_fcoe.c b/drivers/net/ixgbe/ixgbe_fcoe.c
index da32a10..ff09706 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ixgbe/ixgbe_fcoe.c
@@ -525,7 +525,7 @@ void ixgbe_configure_fcoe(struct ixgbe_adapter *adapter)
 		for (i = 0; i < IXGBE_FCRETA_SIZE; i++) {
 			fcoe_i = f->mask + i % f->indices;
 			fcoe_i &= IXGBE_FCRETA_ENTRY_MASK;
-			fcoe_q = adapter->rx_ring[fcoe_i].reg_idx;
+			fcoe_q = adapter->rx_ring[fcoe_i]->reg_idx;
 			IXGBE_WRITE_REG(hw, IXGBE_FCRETA(i), fcoe_q);
 		}
 		IXGBE_WRITE_REG(hw, IXGBE_FCRECTL, IXGBE_FCRECTL_ENA);
@@ -533,7 +533,7 @@ void ixgbe_configure_fcoe(struct ixgbe_adapter *adapter)
 	} else  {
 		/* Use single rx queue for FCoE */
 		fcoe_i = f->mask;
-		fcoe_q = adapter->rx_ring[fcoe_i].reg_idx;
+		fcoe_q = adapter->rx_ring[fcoe_i]->reg_idx;
 		IXGBE_WRITE_REG(hw, IXGBE_FCRECTL, 0);
 		IXGBE_WRITE_REG(hw, IXGBE_ETQS(IXGBE_ETQF_FILTER_FCOE),
 				IXGBE_ETQS_QUEUE_EN |
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 6895de7..ceeef52 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -451,7 +451,7 @@ static void ixgbe_update_rx_dca(struct ixgbe_adapter *adapter,
 {
 	u32 rxctrl;
 	int cpu = get_cpu();
-	int q = rx_ring - adapter->rx_ring;
+	int q = rx_ring->reg_idx;
 
 	if (rx_ring->cpu != cpu) {
 		rxctrl = IXGBE_READ_REG(&adapter->hw, IXGBE_DCA_RXCTRL(q));
@@ -479,7 +479,7 @@ static void ixgbe_update_tx_dca(struct ixgbe_adapter *adapter,
 {
 	u32 txctrl;
 	int cpu = get_cpu();
-	int q = tx_ring - adapter->tx_ring;
+	int q = tx_ring->reg_idx;
 	struct ixgbe_hw *hw = &adapter->hw;
 
 	if (tx_ring->cpu != cpu) {
@@ -513,12 +513,12 @@ static void ixgbe_setup_dca(struct ixgbe_adapter *adapter)
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_DCA_CTRL, 2);
 
 	for (i = 0; i < adapter->num_tx_queues; i++) {
-		adapter->tx_ring[i].cpu = -1;
-		ixgbe_update_tx_dca(adapter, &adapter->tx_ring[i]);
+		adapter->tx_ring[i]->cpu = -1;
+		ixgbe_update_tx_dca(adapter, adapter->tx_ring[i]);
 	}
 	for (i = 0; i < adapter->num_rx_queues; i++) {
-		adapter->rx_ring[i].cpu = -1;
-		ixgbe_update_rx_dca(adapter, &adapter->rx_ring[i]);
+		adapter->rx_ring[i]->cpu = -1;
+		ixgbe_update_rx_dca(adapter, adapter->rx_ring[i]);
 	}
 }
 
@@ -989,7 +989,7 @@ static void ixgbe_configure_msix(struct ixgbe_adapter *adapter)
 		                       adapter->num_rx_queues);
 
 		for (i = 0; i < q_vector->rxr_count; i++) {
-			j = adapter->rx_ring[r_idx].reg_idx;
+			j = adapter->rx_ring[r_idx]->reg_idx;
 			ixgbe_set_ivar(adapter, 0, j, v_idx);
 			r_idx = find_next_bit(q_vector->rxr_idx,
 			                      adapter->num_rx_queues,
@@ -999,7 +999,7 @@ static void ixgbe_configure_msix(struct ixgbe_adapter *adapter)
 		                       adapter->num_tx_queues);
 
 		for (i = 0; i < q_vector->txr_count; i++) {
-			j = adapter->tx_ring[r_idx].reg_idx;
+			j = adapter->tx_ring[r_idx]->reg_idx;
 			ixgbe_set_ivar(adapter, 1, j, v_idx);
 			r_idx = find_next_bit(q_vector->txr_idx,
 			                      adapter->num_tx_queues,
@@ -1134,7 +1134,7 @@ static void ixgbe_set_itr_msix(struct ixgbe_q_vector *q_vector)
 
 	r_idx = find_first_bit(q_vector->txr_idx, adapter->num_tx_queues);
 	for (i = 0; i < q_vector->txr_count; i++) {
-		tx_ring = &(adapter->tx_ring[r_idx]);
+		tx_ring = adapter->tx_ring[r_idx];
 		ret_itr = ixgbe_update_itr(adapter, q_vector->eitr,
 		                           q_vector->tx_itr,
 		                           tx_ring->total_packets,
@@ -1149,7 +1149,7 @@ static void ixgbe_set_itr_msix(struct ixgbe_q_vector *q_vector)
 
 	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
 	for (i = 0; i < q_vector->rxr_count; i++) {
-		rx_ring = &(adapter->rx_ring[r_idx]);
+		rx_ring = adapter->rx_ring[r_idx];
 		ret_itr = ixgbe_update_itr(adapter, q_vector->eitr,
 		                           q_vector->rx_itr,
 		                           rx_ring->total_packets,
@@ -1268,7 +1268,7 @@ static irqreturn_t ixgbe_msix_lsc(int irq, void *data)
 			netif_tx_stop_all_queues(netdev);
 			for (i = 0; i < adapter->num_tx_queues; i++) {
 				struct ixgbe_ring *tx_ring =
-				                           &adapter->tx_ring[i];
+				                            adapter->tx_ring[i];
 				if (test_and_clear_bit(__IXGBE_FDIR_INIT_DONE,
 				                       &tx_ring->reinit_state))
 					schedule_work(&adapter->fdir_reinit_task);
@@ -1327,7 +1327,7 @@ static irqreturn_t ixgbe_msix_clean_tx(int irq, void *data)
 
 	r_idx = find_first_bit(q_vector->txr_idx, adapter->num_tx_queues);
 	for (i = 0; i < q_vector->txr_count; i++) {
-		tx_ring = &(adapter->tx_ring[r_idx]);
+		tx_ring = adapter->tx_ring[r_idx];
 		tx_ring->total_bytes = 0;
 		tx_ring->total_packets = 0;
 		r_idx = find_next_bit(q_vector->txr_idx, adapter->num_tx_queues,
@@ -1355,7 +1355,7 @@ static irqreturn_t ixgbe_msix_clean_rx(int irq, void *data)
 
 	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
 	for (i = 0;  i < q_vector->rxr_count; i++) {
-		rx_ring = &(adapter->rx_ring[r_idx]);
+		rx_ring = adapter->rx_ring[r_idx];
 		rx_ring->total_bytes = 0;
 		rx_ring->total_packets = 0;
 		r_idx = find_next_bit(q_vector->rxr_idx, adapter->num_rx_queues,
@@ -1385,7 +1385,7 @@ static irqreturn_t ixgbe_msix_clean_many(int irq, void *data)
 
 	r_idx = find_first_bit(q_vector->txr_idx, adapter->num_tx_queues);
 	for (i = 0; i < q_vector->txr_count; i++) {
-		ring = &(adapter->tx_ring[r_idx]);
+		ring = adapter->tx_ring[r_idx];
 		ring->total_bytes = 0;
 		ring->total_packets = 0;
 		r_idx = find_next_bit(q_vector->txr_idx, adapter->num_tx_queues,
@@ -1394,7 +1394,7 @@ static irqreturn_t ixgbe_msix_clean_many(int irq, void *data)
 
 	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
 	for (i = 0; i < q_vector->rxr_count; i++) {
-		ring = &(adapter->rx_ring[r_idx]);
+		ring = adapter->rx_ring[r_idx];
 		ring->total_bytes = 0;
 		ring->total_packets = 0;
 		r_idx = find_next_bit(q_vector->rxr_idx, adapter->num_rx_queues,
@@ -1425,7 +1425,7 @@ static int ixgbe_clean_rxonly(struct napi_struct *napi, int budget)
 	long r_idx;
 
 	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
-	rx_ring = &(adapter->rx_ring[r_idx]);
+	rx_ring = adapter->rx_ring[r_idx];
 #ifdef CONFIG_IXGBE_DCA
 	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
 		ixgbe_update_rx_dca(adapter, rx_ring);
@@ -1466,7 +1466,7 @@ static int ixgbe_clean_rxtx_many(struct napi_struct *napi, int budget)
 
 	r_idx = find_first_bit(q_vector->txr_idx, adapter->num_tx_queues);
 	for (i = 0; i < q_vector->txr_count; i++) {
-		ring = &(adapter->tx_ring[r_idx]);
+		ring = adapter->tx_ring[r_idx];
 #ifdef CONFIG_IXGBE_DCA
 		if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
 			ixgbe_update_tx_dca(adapter, ring);
@@ -1482,7 +1482,7 @@ static int ixgbe_clean_rxtx_many(struct napi_struct *napi, int budget)
 	budget = max(budget, 1);
 	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
 	for (i = 0; i < q_vector->rxr_count; i++) {
-		ring = &(adapter->rx_ring[r_idx]);
+		ring = adapter->rx_ring[r_idx];
 #ifdef CONFIG_IXGBE_DCA
 		if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
 			ixgbe_update_rx_dca(adapter, ring);
@@ -1493,7 +1493,7 @@ static int ixgbe_clean_rxtx_many(struct napi_struct *napi, int budget)
 	}
 
 	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
-	ring = &(adapter->rx_ring[r_idx]);
+	ring = adapter->rx_ring[r_idx];
 	/* If all Rx work done, exit the polling mode */
 	if (work_done < budget) {
 		napi_complete(napi);
@@ -1526,7 +1526,7 @@ static int ixgbe_clean_txonly(struct napi_struct *napi, int budget)
 	long r_idx;
 
 	r_idx = find_first_bit(q_vector->txr_idx, adapter->num_tx_queues);
-	tx_ring = &(adapter->tx_ring[r_idx]);
+	tx_ring = adapter->tx_ring[r_idx];
 #ifdef CONFIG_IXGBE_DCA
 	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
 		ixgbe_update_tx_dca(adapter, tx_ring);
@@ -1711,8 +1711,8 @@ static void ixgbe_set_itr(struct ixgbe_adapter *adapter)
 	struct ixgbe_q_vector *q_vector = adapter->q_vector[0];
 	u8 current_itr;
 	u32 new_itr = q_vector->eitr;
-	struct ixgbe_ring *rx_ring = &adapter->rx_ring[0];
-	struct ixgbe_ring *tx_ring = &adapter->tx_ring[0];
+	struct ixgbe_ring *rx_ring = adapter->rx_ring[0];
+	struct ixgbe_ring *tx_ring = adapter->tx_ring[0];
 
 	q_vector->tx_itr = ixgbe_update_itr(adapter, new_itr,
 	                                    q_vector->tx_itr,
@@ -1817,10 +1817,10 @@ static irqreturn_t ixgbe_intr(int irq, void *data)
 	ixgbe_check_fan_failure(adapter, eicr);
 
 	if (napi_schedule_prep(&(q_vector->napi))) {
-		adapter->tx_ring[0].total_packets = 0;
-		adapter->tx_ring[0].total_bytes = 0;
-		adapter->rx_ring[0].total_packets = 0;
-		adapter->rx_ring[0].total_bytes = 0;
+		adapter->tx_ring[0]->total_packets = 0;
+		adapter->tx_ring[0]->total_bytes = 0;
+		adapter->rx_ring[0]->total_packets = 0;
+		adapter->rx_ring[0]->total_bytes = 0;
 		/* would disable interrupts here but EIAM disabled it */
 		__napi_schedule(&(q_vector->napi));
 	}
@@ -1950,7 +1950,7 @@ static void ixgbe_configure_tx(struct ixgbe_adapter *adapter)
 
 	/* Setup the HW Tx Head and Tail descriptor pointers */
 	for (i = 0; i < adapter->num_tx_queues; i++) {
-		struct ixgbe_ring *ring = &adapter->tx_ring[i];
+		struct ixgbe_ring *ring = adapter->tx_ring[i];
 		j = ring->reg_idx;
 		tdba = ring->dma;
 		tdlen = ring->count * sizeof(union ixgbe_adv_tx_desc);
@@ -1960,8 +1960,8 @@ static void ixgbe_configure_tx(struct ixgbe_adapter *adapter)
 		IXGBE_WRITE_REG(hw, IXGBE_TDLEN(j), tdlen);
 		IXGBE_WRITE_REG(hw, IXGBE_TDH(j), 0);
 		IXGBE_WRITE_REG(hw, IXGBE_TDT(j), 0);
-		adapter->tx_ring[i].head = IXGBE_TDH(j);
-		adapter->tx_ring[i].tail = IXGBE_TDT(j);
+		adapter->tx_ring[i]->head = IXGBE_TDH(j);
+		adapter->tx_ring[i]->tail = IXGBE_TDT(j);
 		/*
 		 * Disable Tx Head Writeback RO bit, since this hoses
 		 * bookkeeping if things aren't delivered in order.
@@ -2090,7 +2090,7 @@ static void ixgbe_configure_rscctl(struct ixgbe_adapter *adapter, int index)
 	u32 rscctrl;
 	int rx_buf_len;
 
-	rx_ring = &adapter->rx_ring[index];
+	rx_ring = adapter->rx_ring[index];
 	j = rx_ring->reg_idx;
 	rx_buf_len = rx_ring->rx_buf_len;
 	rscctrl = IXGBE_READ_REG(hw, IXGBE_RSCCTL(j));
@@ -2184,7 +2184,7 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 #endif
 	IXGBE_WRITE_REG(hw, IXGBE_HLREG0, hlreg0);
 
-	rdlen = adapter->rx_ring[0].count * sizeof(union ixgbe_adv_rx_desc);
+	rdlen = adapter->rx_ring[0]->count * sizeof(union ixgbe_adv_rx_desc);
 	/* disable receives while setting up the descriptors */
 	rxctrl = IXGBE_READ_REG(hw, IXGBE_RXCTRL);
 	IXGBE_WRITE_REG(hw, IXGBE_RXCTRL, rxctrl & ~IXGBE_RXCTRL_RXEN);
@@ -2194,7 +2194,7 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 	 * the Base and Length of the Rx Descriptor Ring
 	 */
 	for (i = 0; i < adapter->num_rx_queues; i++) {
-		rx_ring = &adapter->rx_ring[i];
+		rx_ring = adapter->rx_ring[i];
 		rdba = rx_ring->dma;
 		j = rx_ring->reg_idx;
 		IXGBE_WRITE_REG(hw, IXGBE_RDBAL(j), (rdba & DMA_BIT_MASK(32)));
@@ -2361,7 +2361,7 @@ static void ixgbe_vlan_rx_register(struct net_device *netdev,
 	} else if (adapter->hw.mac.type == ixgbe_mac_82599EB) {
 		for (i = 0; i < adapter->num_rx_queues; i++) {
 			u32 ctrl;
-			j = adapter->rx_ring[i].reg_idx;
+			j = adapter->rx_ring[i]->reg_idx;
 			ctrl = IXGBE_READ_REG(&adapter->hw, IXGBE_RXDCTL(j));
 			ctrl |= IXGBE_RXDCTL_VME;
 			IXGBE_WRITE_REG(&adapter->hw, IXGBE_RXDCTL(j), ctrl);
@@ -2522,7 +2522,7 @@ static void ixgbe_configure_dcb(struct ixgbe_adapter *adapter)
 	ixgbe_dcb_hw_config(&adapter->hw, &adapter->dcb_cfg);
 
 	for (i = 0; i < adapter->num_tx_queues; i++) {
-		j = adapter->tx_ring[i].reg_idx;
+		j = adapter->tx_ring[i]->reg_idx;
 		txdctl = IXGBE_READ_REG(hw, IXGBE_TXDCTL(j));
 		/* PThresh workaround for Tx hang with DFP enabled. */
 		txdctl |= 32;
@@ -2539,7 +2539,7 @@ static void ixgbe_configure_dcb(struct ixgbe_adapter *adapter)
 		vlnctrl &= ~IXGBE_VLNCTRL_CFIEN;
 		IXGBE_WRITE_REG(hw, IXGBE_VLNCTRL, vlnctrl);
 		for (i = 0; i < adapter->num_rx_queues; i++) {
-			j = adapter->rx_ring[i].reg_idx;
+			j = adapter->rx_ring[i]->reg_idx;
 			vlnctrl = IXGBE_READ_REG(hw, IXGBE_RXDCTL(j));
 			vlnctrl |= IXGBE_RXDCTL_VME;
 			IXGBE_WRITE_REG(hw, IXGBE_RXDCTL(j), vlnctrl);
@@ -2579,7 +2579,7 @@ static void ixgbe_configure(struct ixgbe_adapter *adapter)
 #endif /* IXGBE_FCOE */
 	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) {
 		for (i = 0; i < adapter->num_tx_queues; i++)
-			adapter->tx_ring[i].atr_sample_rate =
+			adapter->tx_ring[i]->atr_sample_rate =
 			                               adapter->atr_sample_rate;
 		ixgbe_init_fdir_signature_82599(hw, adapter->fdir_pballoc);
 	} else if (adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE) {
@@ -2589,8 +2589,8 @@ static void ixgbe_configure(struct ixgbe_adapter *adapter)
 	ixgbe_configure_tx(adapter);
 	ixgbe_configure_rx(adapter);
 	for (i = 0; i < adapter->num_rx_queues; i++)
-		ixgbe_alloc_rx_buffers(adapter, &adapter->rx_ring[i],
-		                       (adapter->rx_ring[i].count - 1));
+		ixgbe_alloc_rx_buffers(adapter, adapter->rx_ring[i],
+		                       (adapter->rx_ring[i]->count - 1));
 }
 
 static inline bool ixgbe_is_sfp(struct ixgbe_hw *hw)
@@ -2673,7 +2673,7 @@ link_cfg_out:
 static inline void ixgbe_rx_desc_queue_enable(struct ixgbe_adapter *adapter,
 	                                      int rxr)
 {
-	int j = adapter->rx_ring[rxr].reg_idx;
+	int j = adapter->rx_ring[rxr]->reg_idx;
 	int k;
 
 	for (k = 0; k < IXGBE_MAX_RX_DESC_POLL; k++) {
@@ -2687,8 +2687,8 @@ static inline void ixgbe_rx_desc_queue_enable(struct ixgbe_adapter *adapter,
 		DPRINTK(DRV, ERR, "RXDCTL.ENABLE on Rx queue %d "
 		        "not set within the polling period\n", rxr);
 	}
-	ixgbe_release_rx_desc(&adapter->hw, &adapter->rx_ring[rxr],
-	                      (adapter->rx_ring[rxr].count - 1));
+	ixgbe_release_rx_desc(&adapter->hw, adapter->rx_ring[rxr],
+	                      (adapter->rx_ring[rxr]->count - 1));
 }
 
 static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
@@ -2770,7 +2770,7 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 	}
 
 	for (i = 0; i < adapter->num_tx_queues; i++) {
-		j = adapter->tx_ring[i].reg_idx;
+		j = adapter->tx_ring[i]->reg_idx;
 		txdctl = IXGBE_READ_REG(hw, IXGBE_TXDCTL(j));
 		/* enable WTHRESH=8 descriptors, to encourage burst writeback */
 		txdctl |= (8 << 16);
@@ -2784,14 +2784,14 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 		IXGBE_WRITE_REG(hw, IXGBE_DMATXCTL, dmatxctl);
 	}
 	for (i = 0; i < adapter->num_tx_queues; i++) {
-		j = adapter->tx_ring[i].reg_idx;
+		j = adapter->tx_ring[i]->reg_idx;
 		txdctl = IXGBE_READ_REG(hw, IXGBE_TXDCTL(j));
 		txdctl |= IXGBE_TXDCTL_ENABLE;
 		IXGBE_WRITE_REG(hw, IXGBE_TXDCTL(j), txdctl);
 	}
 
 	for (i = 0; i < num_rx_rings; i++) {
-		j = adapter->rx_ring[i].reg_idx;
+		j = adapter->rx_ring[i]->reg_idx;
 		rxdctl = IXGBE_READ_REG(hw, IXGBE_RXDCTL(j));
 		/* enable PTHRESH=32 descriptors (half the internal cache)
 		 * and HTHRESH=0 descriptors (to minimize latency on fetch),
@@ -2865,7 +2865,7 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 
 	for (i = 0; i < adapter->num_tx_queues; i++)
 		set_bit(__IXGBE_FDIR_INIT_DONE,
-		        &(adapter->tx_ring[i].reinit_state));
+		        &(adapter->tx_ring[i]->reinit_state));
 
 	/* enable transmits */
 	netif_tx_start_all_queues(netdev);
@@ -3029,7 +3029,7 @@ static void ixgbe_clean_all_rx_rings(struct ixgbe_adapter *adapter)
 	int i;
 
 	for (i = 0; i < adapter->num_rx_queues; i++)
-		ixgbe_clean_rx_ring(adapter, &adapter->rx_ring[i]);
+		ixgbe_clean_rx_ring(adapter, adapter->rx_ring[i]);
 }
 
 /**
@@ -3041,7 +3041,7 @@ static void ixgbe_clean_all_tx_rings(struct ixgbe_adapter *adapter)
 	int i;
 
 	for (i = 0; i < adapter->num_tx_queues; i++)
-		ixgbe_clean_tx_ring(adapter, &adapter->tx_ring[i]);
+		ixgbe_clean_tx_ring(adapter, adapter->tx_ring[i]);
 }
 
 void ixgbe_down(struct ixgbe_adapter *adapter)
@@ -3081,7 +3081,7 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 
 	/* disable transmits in the hardware now that interrupts are off */
 	for (i = 0; i < adapter->num_tx_queues; i++) {
-		j = adapter->tx_ring[i].reg_idx;
+		j = adapter->tx_ring[i]->reg_idx;
 		txdctl = IXGBE_READ_REG(hw, IXGBE_TXDCTL(j));
 		IXGBE_WRITE_REG(hw, IXGBE_TXDCTL(j),
 		                (txdctl & ~IXGBE_TXDCTL_ENABLE));
@@ -3121,13 +3121,13 @@ static int ixgbe_poll(struct napi_struct *napi, int budget)
 
 #ifdef CONFIG_IXGBE_DCA
 	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED) {
-		ixgbe_update_tx_dca(adapter, adapter->tx_ring);
-		ixgbe_update_rx_dca(adapter, adapter->rx_ring);
+		ixgbe_update_tx_dca(adapter, adapter->tx_ring[0]);
+		ixgbe_update_rx_dca(adapter, adapter->rx_ring[0]);
 	}
 #endif
 
-	tx_clean_complete = ixgbe_clean_tx_irq(q_vector, adapter->tx_ring);
-	ixgbe_clean_rx_irq(q_vector, adapter->rx_ring, &work_done, budget);
+	tx_clean_complete = ixgbe_clean_tx_irq(q_vector, adapter->tx_ring[0]);
+	ixgbe_clean_rx_irq(q_vector, adapter->rx_ring[0], &work_done, budget);
 
 	if (!tx_clean_complete)
 		work_done = budget;
@@ -3393,9 +3393,9 @@ static inline bool ixgbe_cache_ring_rss(struct ixgbe_adapter *adapter)
 
 	if (adapter->flags & IXGBE_FLAG_RSS_ENABLED) {
 		for (i = 0; i < adapter->num_rx_queues; i++)
-			adapter->rx_ring[i].reg_idx = i;
+			adapter->rx_ring[i]->reg_idx = i;
 		for (i = 0; i < adapter->num_tx_queues; i++)
-			adapter->tx_ring[i].reg_idx = i;
+			adapter->tx_ring[i]->reg_idx = i;
 		ret = true;
 	} else {
 		ret = false;
@@ -3422,8 +3422,8 @@ static inline bool ixgbe_cache_ring_dcb(struct ixgbe_adapter *adapter)
 		if (adapter->hw.mac.type == ixgbe_mac_82598EB) {
 			/* the number of queues is assumed to be symmetric */
 			for (i = 0; i < dcb_i; i++) {
-				adapter->rx_ring[i].reg_idx = i << 3;
-				adapter->tx_ring[i].reg_idx = i << 2;
+				adapter->rx_ring[i]->reg_idx = i << 3;
+				adapter->tx_ring[i]->reg_idx = i << 2;
 			}
 			ret = true;
 		} else if (adapter->hw.mac.type == ixgbe_mac_82599EB) {
@@ -3441,18 +3441,18 @@ static inline bool ixgbe_cache_ring_dcb(struct ixgbe_adapter *adapter)
 				 * Rx TC0-TC7 are offset by 16 queues each
 				 */
 				for (i = 0; i < 3; i++) {
-					adapter->tx_ring[i].reg_idx = i << 5;
-					adapter->rx_ring[i].reg_idx = i << 4;
+					adapter->tx_ring[i]->reg_idx = i << 5;
+					adapter->rx_ring[i]->reg_idx = i << 4;
 				}
 				for ( ; i < 5; i++) {
-					adapter->tx_ring[i].reg_idx =
+					adapter->tx_ring[i]->reg_idx =
 					                         ((i + 2) << 4);
-					adapter->rx_ring[i].reg_idx = i << 4;
+					adapter->rx_ring[i]->reg_idx = i << 4;
 				}
 				for ( ; i < dcb_i; i++) {
-					adapter->tx_ring[i].reg_idx =
+					adapter->tx_ring[i]->reg_idx =
 					                         ((i + 8) << 3);
-					adapter->rx_ring[i].reg_idx = i << 4;
+					adapter->rx_ring[i]->reg_idx = i << 4;
 				}
 
 				ret = true;
@@ -3465,12 +3465,12 @@ static inline bool ixgbe_cache_ring_dcb(struct ixgbe_adapter *adapter)
 				 *
 				 * Rx TC0-TC3 are offset by 32 queues each
 				 */
-				adapter->tx_ring[0].reg_idx = 0;
-				adapter->tx_ring[1].reg_idx = 64;
-				adapter->tx_ring[2].reg_idx = 96;
-				adapter->tx_ring[3].reg_idx = 112;
+				adapter->tx_ring[0]->reg_idx = 0;
+				adapter->tx_ring[1]->reg_idx = 64;
+				adapter->tx_ring[2]->reg_idx = 96;
+				adapter->tx_ring[3]->reg_idx = 112;
 				for (i = 0 ; i < dcb_i; i++)
-					adapter->rx_ring[i].reg_idx = i << 5;
+					adapter->rx_ring[i]->reg_idx = i << 5;
 
 				ret = true;
 			} else {
@@ -3503,9 +3503,9 @@ static bool inline ixgbe_cache_ring_fdir(struct ixgbe_adapter *adapter)
 	    ((adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) ||
 	     (adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE))) {
 		for (i = 0; i < adapter->num_rx_queues; i++)
-			adapter->rx_ring[i].reg_idx = i;
+			adapter->rx_ring[i]->reg_idx = i;
 		for (i = 0; i < adapter->num_tx_queues; i++)
-			adapter->tx_ring[i].reg_idx = i;
+			adapter->tx_ring[i]->reg_idx = i;
 		ret = true;
 	}
 
@@ -3533,8 +3533,8 @@ static inline bool ixgbe_cache_ring_fcoe(struct ixgbe_adapter *adapter)
 
 			ixgbe_cache_ring_dcb(adapter);
 			/* find out queues in TC for FCoE */
-			fcoe_rx_i = adapter->rx_ring[fcoe->tc].reg_idx + 1;
-			fcoe_tx_i = adapter->tx_ring[fcoe->tc].reg_idx + 1;
+			fcoe_rx_i = adapter->rx_ring[fcoe->tc]->reg_idx + 1;
+			fcoe_tx_i = adapter->tx_ring[fcoe->tc]->reg_idx + 1;
 			/*
 			 * In 82599, the number of Tx queues for each traffic
 			 * class for both 8-TC and 4-TC modes are:
@@ -3565,8 +3565,8 @@ static inline bool ixgbe_cache_ring_fcoe(struct ixgbe_adapter *adapter)
 			fcoe_tx_i = f->mask;
 		}
 		for (i = 0; i < f->indices; i++, fcoe_rx_i++, fcoe_tx_i++) {
-			adapter->rx_ring[f->mask + i].reg_idx = fcoe_rx_i;
-			adapter->tx_ring[f->mask + i].reg_idx = fcoe_tx_i;
+			adapter->rx_ring[f->mask + i]->reg_idx = fcoe_rx_i;
+			adapter->tx_ring[f->mask + i]->reg_idx = fcoe_tx_i;
 		}
 		ret = true;
 	}
@@ -3588,8 +3588,8 @@ static inline bool ixgbe_cache_ring_fcoe(struct ixgbe_adapter *adapter)
 static void ixgbe_cache_ring_register(struct ixgbe_adapter *adapter)
 {
 	/* start with default case */
-	adapter->rx_ring[0].reg_idx = 0;
-	adapter->tx_ring[0].reg_idx = 0;
+	adapter->rx_ring[0]->reg_idx = 0;
+	adapter->tx_ring[0]->reg_idx = 0;
 
 #ifdef IXGBE_FCOE
 	if (ixgbe_cache_ring_fcoe(adapter))
@@ -3619,33 +3619,59 @@ static void ixgbe_cache_ring_register(struct ixgbe_adapter *adapter)
 static int ixgbe_alloc_queues(struct ixgbe_adapter *adapter)
 {
 	int i;
-
-	adapter->tx_ring = kcalloc(adapter->num_tx_queues,
-	                           sizeof(struct ixgbe_ring), GFP_KERNEL);
-	if (!adapter->tx_ring)
-		goto err_tx_ring_allocation;
-
-	adapter->rx_ring = kcalloc(adapter->num_rx_queues,
-	                           sizeof(struct ixgbe_ring), GFP_KERNEL);
-	if (!adapter->rx_ring)
-		goto err_rx_ring_allocation;
+	int orig_node = adapter->node;
 
 	for (i = 0; i < adapter->num_tx_queues; i++) {
-		adapter->tx_ring[i].count = adapter->tx_ring_count;
-		adapter->tx_ring[i].queue_index = i;
+		struct ixgbe_ring *ring = adapter->tx_ring[i];
+		if (orig_node == -1) {
+			int cur_node = next_online_node(adapter->node);
+			if (cur_node == MAX_NUMNODES)
+				cur_node = first_online_node;
+			adapter->node = cur_node;
+		}
+		ring = kzalloc_node(sizeof(struct ixgbe_ring), GFP_KERNEL,
+		                    adapter->node);
+		if (!ring)
+			goto err_tx_ring_allocation;
+		ring->count = adapter->tx_ring_count;
+		ring->queue_index = i;
+		ring->numa_node = adapter->node;
+
+		adapter->tx_ring[i] = ring;
 	}
 
+	/* Restore the adapter's original node */
+	adapter->node = orig_node;
+
 	for (i = 0; i < adapter->num_rx_queues; i++) {
-		adapter->rx_ring[i].count = adapter->rx_ring_count;
-		adapter->rx_ring[i].queue_index = i;
+		struct ixgbe_ring *ring = adapter->rx_ring[i];
+		if (orig_node == -1) {
+			int cur_node = next_online_node(adapter->node);
+			if (cur_node == MAX_NUMNODES)
+				cur_node = first_online_node;
+			adapter->node = cur_node;
+		}
+		ring = kzalloc_node(sizeof(struct ixgbe_ring), GFP_KERNEL,
+		                    adapter->node);
+		if (!ring)
+			goto err_rx_ring_allocation;
+		ring->count = adapter->rx_ring_count;
+		ring->queue_index = i;
+		ring->numa_node = adapter->node;
+
+		adapter->rx_ring[i] = ring;
 	}
 
+	/* Restore the adapter's original node */
+	adapter->node = orig_node;
+
 	ixgbe_cache_ring_register(adapter);
 
 	return 0;
 
 err_rx_ring_allocation:
-	kfree(adapter->tx_ring);
+	for (i = 0; i < adapter->num_tx_queues; i++)
+		kfree(adapter->tx_ring[i]);
 err_tx_ring_allocation:
 	return -ENOMEM;
 }
@@ -3869,10 +3895,16 @@ err_set_interrupt:
  **/
 void ixgbe_clear_interrupt_scheme(struct ixgbe_adapter *adapter)
 {
-	kfree(adapter->tx_ring);
-	kfree(adapter->rx_ring);
-	adapter->tx_ring = NULL;
-	adapter->rx_ring = NULL;
+	int i;
+
+	for (i = 0; i < adapter->num_tx_queues; i++) {
+		kfree(adapter->tx_ring[i]);
+		adapter->tx_ring[i] = NULL;
+	}
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		kfree(adapter->rx_ring[i]);
+		adapter->rx_ring[i] = NULL;
+	}
 
 	ixgbe_free_q_vectors(adapter);
 	ixgbe_reset_interrupt_capability(adapter);
@@ -4064,7 +4096,7 @@ int ixgbe_setup_tx_resources(struct ixgbe_adapter *adapter,
 	int size;
 
 	size = sizeof(struct ixgbe_tx_buffer) * tx_ring->count;
-	tx_ring->tx_buffer_info = vmalloc_node(size, adapter->node);
+	tx_ring->tx_buffer_info = vmalloc_node(size, tx_ring->numa_node);
 	if (!tx_ring->tx_buffer_info)
 		goto err;
 	memset(tx_ring->tx_buffer_info, 0, size);
@@ -4104,25 +4136,15 @@ err:
 static int ixgbe_setup_all_tx_resources(struct ixgbe_adapter *adapter)
 {
 	int i, err = 0;
-	int orig_node = adapter->node;
 
 	for (i = 0; i < adapter->num_tx_queues; i++) {
-		if (orig_node == -1) {
-			int cur_node = next_online_node(adapter->node);
-			if (cur_node == MAX_NUMNODES)
-				cur_node = first_online_node;
-			adapter->node = cur_node;
-		}
-		err = ixgbe_setup_tx_resources(adapter, &adapter->tx_ring[i]);
+		err = ixgbe_setup_tx_resources(adapter, adapter->tx_ring[i]);
 		if (!err)
 			continue;
 		DPRINTK(PROBE, ERR, "Allocation for Tx Queue %u failed\n", i);
 		break;
 	}
 
-	/* reset the node back to its starting value */
-	adapter->node = orig_node;
-
 	return err;
 }
 
@@ -4140,7 +4162,7 @@ int ixgbe_setup_rx_resources(struct ixgbe_adapter *adapter,
 	int size;
 
 	size = sizeof(struct ixgbe_rx_buffer) * rx_ring->count;
-	rx_ring->rx_buffer_info = vmalloc_node(size, adapter->node);
+	rx_ring->rx_buffer_info = vmalloc_node(size, rx_ring->numa_node);
 	if (!rx_ring->rx_buffer_info) {
 		DPRINTK(PROBE, ERR,
 		        "vmalloc allocation failed for the rx desc ring\n");
@@ -4184,25 +4206,15 @@ alloc_failed:
 static int ixgbe_setup_all_rx_resources(struct ixgbe_adapter *adapter)
 {
 	int i, err = 0;
-	int orig_node = adapter->node;
 
 	for (i = 0; i < adapter->num_rx_queues; i++) {
-		if (orig_node == -1) {
-			int cur_node = next_online_node(adapter->node);
-			if (cur_node == MAX_NUMNODES)
-				cur_node = first_online_node;
-			adapter->node = cur_node;
-		}
-		err = ixgbe_setup_rx_resources(adapter, &adapter->rx_ring[i]);
+		err = ixgbe_setup_rx_resources(adapter, adapter->rx_ring[i]);
 		if (!err)
 			continue;
 		DPRINTK(PROBE, ERR, "Allocation for Rx Queue %u failed\n", i);
 		break;
 	}
 
-	/* reset the node back to its starting value */
-	adapter->node = orig_node;
-
 	return err;
 }
 
@@ -4239,8 +4251,8 @@ static void ixgbe_free_all_tx_resources(struct ixgbe_adapter *adapter)
 	int i;
 
 	for (i = 0; i < adapter->num_tx_queues; i++)
-		if (adapter->tx_ring[i].desc)
-			ixgbe_free_tx_resources(adapter, &adapter->tx_ring[i]);
+		if (adapter->tx_ring[i]->desc)
+			ixgbe_free_tx_resources(adapter, adapter->tx_ring[i]);
 }
 
 /**
@@ -4276,8 +4288,8 @@ static void ixgbe_free_all_rx_resources(struct ixgbe_adapter *adapter)
 	int i;
 
 	for (i = 0; i < adapter->num_rx_queues; i++)
-		if (adapter->rx_ring[i].desc)
-			ixgbe_free_rx_resources(adapter, &adapter->rx_ring[i]);
+		if (adapter->rx_ring[i]->desc)
+			ixgbe_free_rx_resources(adapter, adapter->rx_ring[i]);
 }
 
 /**
@@ -4554,8 +4566,8 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 			adapter->hw_rx_no_dma_resources +=
 			                     IXGBE_READ_REG(hw, IXGBE_QPRDC(i));
 		for (i = 0; i < adapter->num_rx_queues; i++) {
-			rsc_count += adapter->rx_ring[i].rsc_count;
-			rsc_flush += adapter->rx_ring[i].rsc_flush;
+			rsc_count += adapter->rx_ring[i]->rsc_count;
+			rsc_flush += adapter->rx_ring[i]->rsc_flush;
 		}
 		adapter->rsc_total_count = rsc_count;
 		adapter->rsc_total_flush = rsc_flush;
@@ -4563,11 +4575,11 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 
 	/* gather some stats to the adapter struct that are per queue */
 	for (i = 0; i < adapter->num_tx_queues; i++)
-		restart_queue += adapter->tx_ring[i].restart_queue;
+		restart_queue += adapter->tx_ring[i]->restart_queue;
 	adapter->restart_queue = restart_queue;
 
 	for (i = 0; i < adapter->num_rx_queues; i++)
-		non_eop_descs += adapter->rx_ring[i].non_eop_descs;
+		non_eop_descs += adapter->rx_ring[i]->non_eop_descs;
 	adapter->non_eop_descs = non_eop_descs;
 
 	adapter->stats.crcerrs += IXGBE_READ_REG(hw, IXGBE_CRCERRS);
@@ -4806,7 +4818,7 @@ static void ixgbe_fdir_reinit_task(struct work_struct *work)
 	if (ixgbe_reinit_fdir_tables_82599(hw) == 0) {
 		for (i = 0; i < adapter->num_tx_queues; i++)
 			set_bit(__IXGBE_FDIR_INIT_DONE,
-			        &(adapter->tx_ring[i].reinit_state));
+			        &(adapter->tx_ring[i]->reinit_state));
 	} else {
 		DPRINTK(PROBE, ERR, "failed to finish FDIR re-initialization, "
 		        "ignored adding FDIR ATR filters \n");
@@ -4903,7 +4915,7 @@ static void ixgbe_watchdog_task(struct work_struct *work)
 
 	if (!netif_carrier_ok(netdev)) {
 		for (i = 0; i < adapter->num_tx_queues; i++) {
-			tx_ring = &adapter->tx_ring[i];
+			tx_ring = adapter->tx_ring[i];
 			if (tx_ring->next_to_use != tx_ring->next_to_clean) {
 				some_tx_pending = 1;
 				break;
@@ -5402,7 +5414,7 @@ static netdev_tx_t ixgbe_xmit_frame(struct sk_buff *skb,
 		}
 	}
 
-	tx_ring = &adapter->tx_ring[skb->queue_mapping];
+	tx_ring = adapter->tx_ring[skb->queue_mapping];
 
 	if ((adapter->flags & IXGBE_FLAG_FCOE_ENABLED) &&
 	    (skb->protocol == htons(ETH_P_FCOE))) {

