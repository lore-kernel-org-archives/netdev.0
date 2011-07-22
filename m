From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/10] ixgbe: Move interrupt related values out of ring and into q_vector
Date: Thu, 21 Jul 2011 19:01:14 -0700
Message-ID: <1311300078-12876-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1311300078-12876-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:56055 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753097Ab1GVCBY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jul 2011 22:01:24 -0400
In-Reply-To: <1311300078-12876-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change moves work_limit, total_packets, and total_bytes into the ring
container struct of the q_vector.  The advantage of this is that it should
reduce the size of memory used in the event of multiple rings being
assigned to a single q_vector.  In addition it should help to reduce the
total workload for calculating itr since now total_packets and total_bytes
will be the total work done of the interrupt instead of for the ring.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe.h         |   24 +++---
 drivers/net/ixgbe/ixgbe_ethtool.c |    6 +-
 drivers/net/ixgbe/ixgbe_main.c    |  170 ++++++++++---------------------------
 3 files changed, 62 insertions(+), 138 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index a5ed9fd..fbae735 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -214,12 +214,10 @@ struct ixgbe_ring {
 		struct ixgbe_rx_buffer *rx_buffer_info;
 	};
 	unsigned long state;
-	u8 atr_sample_rate;
-	u8 atr_count;
+	u8 __iomem *tail;
+
 	u16 count;			/* amount of descriptors */
 	u16 rx_buf_len;
-	u16 next_to_use;
-	u16 next_to_clean;
 
 	u8 queue_index; /* needed for multiqueue queue management */
 	u8 reg_idx;			/* holds the special value that gets
@@ -227,15 +225,13 @@ struct ixgbe_ring {
 					 * associated with this ring, which is
 					 * different for DCB and RSS modes
 					 */
-	u8 dcb_tc;
-
-	u16 work_limit;			/* max work per interrupt */
-
-	u8 __iomem *tail;
+	u8 atr_sample_rate;
+	u8 atr_count;
 
-	unsigned int total_bytes;
-	unsigned int total_packets;
+	u16 next_to_use;
+	u16 next_to_clean;
 
+	u8 dcb_tc;
 	struct ixgbe_queue_stats stats;
 	struct u64_stats_sync syncp;
 	union {
@@ -283,6 +279,9 @@ struct ixgbe_ring_container {
 #else
 	DECLARE_BITMAP(idx, MAX_TX_QUEUES);
 #endif
+	unsigned int total_bytes;	/* total bytes processed this int */
+	unsigned int total_packets;	/* total packets processed this int */
+	u16 work_limit;			/* total work allowed per interrupt */
 	u8 count;			/* total number of rings in vector */
 	u8 itr;				/* current ITR setting for ring */
 };
@@ -417,6 +416,9 @@ struct ixgbe_adapter {
 	u16 eitr_low;
 	u16 eitr_high;
 
+	/* Work limits */
+	u16 tx_work_limit;
+
 	/* TX */
 	struct ixgbe_ring *tx_ring[MAX_TX_QUEUES] ____cacheline_aligned_in_smp;
 	int num_tx_queues;
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index cd842f9..6035cfa 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -2103,7 +2103,7 @@ static int ixgbe_get_coalesce(struct net_device *netdev,
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
-	ec->tx_max_coalesced_frames_irq = adapter->tx_ring[0]->work_limit;
+	ec->tx_max_coalesced_frames_irq = adapter->tx_work_limit;
 
 	/* only valid if in constant ITR mode */
 	switch (adapter->rx_itr_setting) {
@@ -2192,7 +2192,7 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
 		return -EINVAL;
 
 	if (ec->tx_max_coalesced_frames_irq)
-		adapter->tx_ring[0]->work_limit = ec->tx_max_coalesced_frames_irq;
+		adapter->tx_work_limit = ec->tx_max_coalesced_frames_irq;
 
 	if (ec->rx_coalesce_usecs > 1) {
 		/* check the limits */
@@ -2267,12 +2267,14 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
 			else
 				/* rx only or mixed */
 				q_vector->eitr = adapter->rx_eitr_param;
+			q_vector->tx.work_limit = adapter->tx_work_limit;
 			ixgbe_write_eitr(q_vector);
 		}
 	/* Legacy Interrupt Mode */
 	} else {
 		q_vector = adapter->q_vector[0];
 		q_vector->eitr = adapter->rx_eitr_param;
+		q_vector->tx.work_limit = adapter->tx_work_limit;
 		ixgbe_write_eitr(q_vector);
 	}
 
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index bd1fd8f..298c95b 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -805,7 +805,7 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 	eop_desc = IXGBE_TX_DESC_ADV(tx_ring, eop);
 
 	while ((eop_desc->wb.status & cpu_to_le32(IXGBE_TXD_STAT_DD)) &&
-	       (count < tx_ring->work_limit)) {
+	       (count < q_vector->tx.work_limit)) {
 		bool cleaned = false;
 		rmb(); /* read buffer_info after eop_desc */
 		for ( ; !cleaned; count++) {
@@ -834,11 +834,11 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 	}
 
 	tx_ring->next_to_clean = i;
-	tx_ring->total_bytes += total_bytes;
-	tx_ring->total_packets += total_packets;
-	u64_stats_update_begin(&tx_ring->syncp);
-	tx_ring->stats.packets += total_packets;
 	tx_ring->stats.bytes += total_bytes;
+	tx_ring->stats.packets += total_packets;
+	u64_stats_update_begin(&tx_ring->syncp);
+	q_vector->tx.total_bytes += total_bytes;
+	q_vector->tx.total_packets += total_packets;
 	u64_stats_update_end(&tx_ring->syncp);
 
 	if (check_for_tx_hang(tx_ring) && ixgbe_check_tx_hang(tx_ring)) {
@@ -886,7 +886,7 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 		}
 	}
 
-	return count < tx_ring->work_limit;
+	return count < q_vector->tx.work_limit;
 }
 
 #ifdef CONFIG_IXGBE_DCA
@@ -1486,12 +1486,12 @@ next_desc:
 	}
 #endif /* IXGBE_FCOE */
 
-	rx_ring->total_packets += total_rx_packets;
-	rx_ring->total_bytes += total_rx_bytes;
 	u64_stats_update_begin(&rx_ring->syncp);
 	rx_ring->stats.packets += total_rx_packets;
 	rx_ring->stats.bytes += total_rx_bytes;
 	u64_stats_update_end(&rx_ring->syncp);
+	q_vector->rx.total_packets += total_rx_packets;
+	q_vector->rx.total_bytes += total_rx_bytes;
 }
 
 static int ixgbe_clean_rxonly(struct napi_struct *, int);
@@ -1597,11 +1597,8 @@ enum latency_range {
 
 /**
  * ixgbe_update_itr - update the dynamic ITR value based on statistics
- * @adapter: pointer to adapter
- * @eitr: eitr setting (ints per sec) to give last timeslice
- * @itr_setting: current throttle rate in ints/second
- * @packets: the number of packets during this measurement interval
- * @bytes: the number of bytes during this measurement interval
+ * @q_vector: structure containing interrupt and ring information
+ * @ring_container: structure containing ring performance data
  *
  *      Stores a new ITR value based on packets and byte
  *      counts during the last interrupt.  The advantage of per interrupt
@@ -1613,17 +1610,18 @@ enum latency_range {
  *      this functionality is controlled by the InterruptThrottleRate module
  *      parameter (see ixgbe_param.c)
  **/
-static u8 ixgbe_update_itr(struct ixgbe_adapter *adapter,
-			   u32 eitr, u8 itr_setting,
-			   int packets, int bytes)
+static void ixgbe_update_itr(struct ixgbe_q_vector *q_vector,
+			     struct ixgbe_ring_container *ring_container)
 {
-	unsigned int retval = itr_setting;
-	u32 timepassed_us;
 	u64 bytes_perint;
+	struct ixgbe_adapter *adapter = q_vector->adapter;
+	int bytes = ring_container->total_bytes;
+	int packets = ring_container->total_packets;
+	u32 timepassed_us;
+	u8 itr_setting = ring_container->itr;
 
 	if (packets == 0)
-		goto update_itr_done;
-
+		return;
 
 	/* simple throttlerate management
 	 *    0-20MB/s lowest (100000 ints/s)
@@ -1631,28 +1629,32 @@ static u8 ixgbe_update_itr(struct ixgbe_adapter *adapter,
 	 *  100-1249MB/s bulk (8000 ints/s)
 	 */
 	/* what was last interrupt timeslice? */
-	timepassed_us = 1000000/eitr;
+	timepassed_us = 1000000/q_vector->eitr;
 	bytes_perint = bytes / timepassed_us; /* bytes/usec */
 
 	switch (itr_setting) {
 	case lowest_latency:
 		if (bytes_perint > adapter->eitr_low)
-			retval = low_latency;
+			itr_setting = low_latency;
 		break;
 	case low_latency:
 		if (bytes_perint > adapter->eitr_high)
-			retval = bulk_latency;
+			itr_setting = bulk_latency;
 		else if (bytes_perint <= adapter->eitr_low)
-			retval = lowest_latency;
+			itr_setting = lowest_latency;
 		break;
 	case bulk_latency:
 		if (bytes_perint <= adapter->eitr_high)
-			retval = low_latency;
+			itr_setting = low_latency;
 		break;
 	}
 
-update_itr_done:
-	return retval;
+	/* clear work counters since we have the values we need */
+	ring_container->total_bytes = 0;
+	ring_container->total_packets = 0;
+
+	/* write updated itr to ring container */
+	ring_container->itr = itr_setting;
 }
 
 /**
@@ -1698,42 +1700,13 @@ void ixgbe_write_eitr(struct ixgbe_q_vector *q_vector)
 	IXGBE_WRITE_REG(hw, IXGBE_EITR(v_idx), itr_reg);
 }
 
-static void ixgbe_set_itr_msix(struct ixgbe_q_vector *q_vector)
+static void ixgbe_set_itr(struct ixgbe_q_vector *q_vector)
 {
-	struct ixgbe_adapter *adapter = q_vector->adapter;
-	int i, r_idx;
-	u32 new_itr;
-	u8 current_itr, ret_itr;
-
-	r_idx = find_first_bit(q_vector->tx.idx, adapter->num_tx_queues);
-	for (i = 0; i < q_vector->tx.count; i++) {
-		struct ixgbe_ring *tx_ring = adapter->tx_ring[r_idx];
-		ret_itr = ixgbe_update_itr(adapter, q_vector->eitr,
-					   q_vector->tx.itr,
-					   tx_ring->total_packets,
-					   tx_ring->total_bytes);
-		/* if the result for this queue would decrease interrupt
-		 * rate for this vector then use that result */
-		q_vector->tx.itr = ((q_vector->tx.itr > ret_itr) ?
-				    q_vector->tx.itr - 1 : ret_itr);
-		r_idx = find_next_bit(q_vector->tx.idx, adapter->num_tx_queues,
-				      r_idx + 1);
-	}
+	u32 new_itr = q_vector->eitr;
+	u8 current_itr;
 
-	r_idx = find_first_bit(q_vector->rx.idx, adapter->num_rx_queues);
-	for (i = 0; i < q_vector->rx.count; i++) {
-		struct ixgbe_ring *rx_ring = adapter->rx_ring[r_idx];
-		ret_itr = ixgbe_update_itr(adapter, q_vector->eitr,
-					   q_vector->rx.itr,
-					   rx_ring->total_packets,
-					   rx_ring->total_bytes);
-		/* if the result for this queue would decrease interrupt
-		 * rate for this vector then use that result */
-		q_vector->rx.itr = ((q_vector->rx.itr > ret_itr) ?
-				    q_vector->rx.itr - 1 : ret_itr);
-		r_idx = find_next_bit(q_vector->rx.idx, adapter->num_rx_queues,
-				      r_idx + 1);
-	}
+	ixgbe_update_itr(q_vector, &q_vector->tx);
+	ixgbe_update_itr(q_vector, &q_vector->rx);
 
 	current_itr = max(q_vector->rx.itr, q_vector->tx.itr);
 
@@ -1746,16 +1719,17 @@ static void ixgbe_set_itr_msix(struct ixgbe_q_vector *q_vector)
 		new_itr = 20000; /* aka hwitr = ~200 */
 		break;
 	case bulk_latency:
-	default:
 		new_itr = 8000;
 		break;
+	default:
+		break;
 	}
 
 	if (new_itr != q_vector->eitr) {
 		/* do an exponential smoothing */
 		new_itr = ((q_vector->eitr * 9) + new_itr)/10;
 
-		/* save the algorithm value here, not the smoothed one */
+		/* save the algorithm value here */
 		q_vector->eitr = new_itr;
 
 		ixgbe_write_eitr(q_vector);
@@ -2001,8 +1975,6 @@ static irqreturn_t ixgbe_msix_clean_tx(int irq, void *data)
 	r_idx = find_first_bit(q_vector->tx.idx, adapter->num_tx_queues);
 	for (i = 0; i < q_vector->tx.count; i++) {
 		tx_ring = adapter->tx_ring[r_idx];
-		tx_ring->total_bytes = 0;
-		tx_ring->total_packets = 0;
 		r_idx = find_next_bit(q_vector->tx.idx, adapter->num_tx_queues,
 				      r_idx + 1);
 	}
@@ -2034,8 +2006,6 @@ static irqreturn_t ixgbe_msix_clean_rx(int irq, void *data)
 	r_idx = find_first_bit(q_vector->rx.idx, adapter->num_rx_queues);
 	for (i = 0; i < q_vector->rx.count; i++) {
 		rx_ring = adapter->rx_ring[r_idx];
-		rx_ring->total_bytes = 0;
-		rx_ring->total_packets = 0;
 		r_idx = find_next_bit(q_vector->rx.idx, adapter->num_rx_queues,
 				      r_idx + 1);
 	}
@@ -2063,8 +2033,6 @@ static irqreturn_t ixgbe_msix_clean_many(int irq, void *data)
 	r_idx = find_first_bit(q_vector->tx.idx, adapter->num_tx_queues);
 	for (i = 0; i < q_vector->tx.count; i++) {
 		ring = adapter->tx_ring[r_idx];
-		ring->total_bytes = 0;
-		ring->total_packets = 0;
 		r_idx = find_next_bit(q_vector->tx.idx, adapter->num_tx_queues,
 				      r_idx + 1);
 	}
@@ -2072,8 +2040,6 @@ static irqreturn_t ixgbe_msix_clean_many(int irq, void *data)
 	r_idx = find_first_bit(q_vector->rx.idx, adapter->num_rx_queues);
 	for (i = 0; i < q_vector->rx.count; i++) {
 		ring = adapter->rx_ring[r_idx];
-		ring->total_bytes = 0;
-		ring->total_packets = 0;
 		r_idx = find_next_bit(q_vector->rx.idx, adapter->num_rx_queues,
 				      r_idx + 1);
 	}
@@ -2115,7 +2081,7 @@ static int ixgbe_clean_rxonly(struct napi_struct *napi, int budget)
 	if (work_done < budget) {
 		napi_complete(napi);
 		if (adapter->rx_itr_setting & 1)
-			ixgbe_set_itr_msix(q_vector);
+			ixgbe_set_itr(q_vector);
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
 			ixgbe_irq_enable_queues(adapter,
 						((u64)1 << q_vector->v_idx));
@@ -2173,7 +2139,7 @@ static int ixgbe_clean_rxtx_many(struct napi_struct *napi, int budget)
 	if (work_done < budget) {
 		napi_complete(napi);
 		if (adapter->rx_itr_setting & 1)
-			ixgbe_set_itr_msix(q_vector);
+			ixgbe_set_itr(q_vector);
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
 			ixgbe_irq_enable_queues(adapter,
 						((u64)1 << q_vector->v_idx));
@@ -2215,7 +2181,7 @@ static int ixgbe_clean_txonly(struct napi_struct *napi, int budget)
 	if (work_done < budget) {
 		napi_complete(napi);
 		if (adapter->tx_itr_setting & 1)
-			ixgbe_set_itr_msix(q_vector);
+			ixgbe_set_itr(q_vector);
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
 			ixgbe_irq_enable_queues(adapter,
 						((u64)1 << q_vector->v_idx));
@@ -2244,6 +2210,7 @@ static inline void map_vector_to_txq(struct ixgbe_adapter *a, int v_idx,
 	set_bit(t_idx, q_vector->tx.idx);
 	q_vector->tx.count++;
 	tx_ring->q_vector = q_vector;
+	q_vector->tx.work_limit = a->tx_work_limit;
 }
 
 /**
@@ -2386,51 +2353,6 @@ free_queue_irqs:
 	return err;
 }
 
-static void ixgbe_set_itr(struct ixgbe_adapter *adapter)
-{
-	struct ixgbe_q_vector *q_vector = adapter->q_vector[0];
-	struct ixgbe_ring *rx_ring = adapter->rx_ring[0];
-	struct ixgbe_ring *tx_ring = adapter->tx_ring[0];
-	u32 new_itr = q_vector->eitr;
-	u8 current_itr;
-
-	q_vector->tx.itr = ixgbe_update_itr(adapter, new_itr,
-					    q_vector->tx.itr,
-					    tx_ring->total_packets,
-					    tx_ring->total_bytes);
-	q_vector->rx.itr = ixgbe_update_itr(adapter, new_itr,
-					    q_vector->rx.itr,
-					    rx_ring->total_packets,
-					    rx_ring->total_bytes);
-
-	current_itr = max(q_vector->rx.itr, q_vector->tx.itr);
-
-	switch (current_itr) {
-	/* counts and packets in update_itr are dependent on these numbers */
-	case lowest_latency:
-		new_itr = 100000;
-		break;
-	case low_latency:
-		new_itr = 20000; /* aka hwitr = ~200 */
-		break;
-	case bulk_latency:
-		new_itr = 8000;
-		break;
-	default:
-		break;
-	}
-
-	if (new_itr != q_vector->eitr) {
-		/* do an exponential smoothing */
-		new_itr = ((q_vector->eitr * 9) + new_itr)/10;
-
-		/* save the algorithm value here */
-		q_vector->eitr = new_itr;
-
-		ixgbe_write_eitr(q_vector);
-	}
-}
-
 /**
  * ixgbe_irq_enable - Enable default interrupt generation settings
  * @adapter: board private structure
@@ -2528,10 +2450,6 @@ static irqreturn_t ixgbe_intr(int irq, void *data)
 	ixgbe_check_fan_failure(adapter, eicr);
 
 	if (napi_schedule_prep(&(q_vector->napi))) {
-		adapter->tx_ring[0]->total_packets = 0;
-		adapter->tx_ring[0]->total_bytes = 0;
-		adapter->rx_ring[0]->total_packets = 0;
-		adapter->rx_ring[0]->total_bytes = 0;
 		/* would disable interrupts here but EIAM disabled it */
 		__napi_schedule(&(q_vector->napi));
 	}
@@ -4299,7 +4217,7 @@ static int ixgbe_poll(struct napi_struct *napi, int budget)
 	if (work_done < budget) {
 		napi_complete(napi);
 		if (adapter->rx_itr_setting & 1)
-			ixgbe_set_itr(adapter);
+			ixgbe_set_itr(q_vector);
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
 			ixgbe_irq_enable_queues(adapter, IXGBE_EIMS_RTX_QUEUE);
 	}
@@ -5224,6 +5142,9 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	adapter->tx_ring_count = IXGBE_DEFAULT_TXD;
 	adapter->rx_ring_count = IXGBE_DEFAULT_RXD;
 
+	/* set default work limits */
+	adapter->tx_work_limit = adapter->tx_ring_count;
+
 	/* initialize eeprom parameters */
 	if (ixgbe_init_eeprom_params_generic(hw)) {
 		e_dev_err("EEPROM initialization failed\n");
@@ -5270,7 +5191,6 @@ int ixgbe_setup_tx_resources(struct ixgbe_ring *tx_ring)
 
 	tx_ring->next_to_use = 0;
 	tx_ring->next_to_clean = 0;
-	tx_ring->work_limit = tx_ring->count;
 	return 0;
 
 err:
-- 
1.7.6

