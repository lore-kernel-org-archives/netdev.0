From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 3/5] ixgbe: Introduce adaptive interrupt moderation
Date: Mon, 03 Mar 2008 15:03:57 -0800
Message-ID: <20080303230357.25151.35450.stgit@localhost.localdomain>
References: <20080303230345.25151.48298.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:27430 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755977AbYCCXG1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2008 18:06:27 -0500
In-Reply-To: <20080303230345.25151.48298.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>

82598 can produce a formidable interrupt rate, and is largely
unusable without some form of moderation. The default behaviour
before this patch is to limit irq's to a reasonable number.
However, just like our other drivers we can reduce latency
for small packet-type traffic considerably by allowing the
irq rate to go up dynamically.

This patch introduces a simple irq moderation algorithm based
on traffic analysis. The driver will use more CPU to service
small packets quicker but will perform the same on bulk traffic
as the old code.

Signed-off-by: Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgbe/ixgbe.h         |    9 ++
 drivers/net/ixgbe/ixgbe_ethtool.c |   24 ++--
 drivers/net/ixgbe/ixgbe_main.c    |  211 +++++++++++++++++++++++++++++++++++++
 3 files changed, 232 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 2077477..79f5519 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -136,6 +136,8 @@ struct ixgbe_ring {
 	u16 head;
 	u16 tail;
 
+	unsigned int total_bytes;
+	unsigned int total_packets;
 
 	u16 reg_idx; /* holds the special value that gets the hardware register
 		      * offset associated with this ring, which is different
@@ -174,6 +176,8 @@ struct ixgbe_q_vector {
 	DECLARE_BITMAP(txr_idx, MAX_TX_QUEUES); /* Tx ring indices */
 	u8 rxr_count;     /* Rx ring count assigned to this vector */
 	u8 txr_count;     /* Tx ring count assigned to this vector */
+	u8 tx_eitr;
+	u8 rx_eitr;
 	u32 eitr;
 };
 
@@ -215,6 +219,11 @@ struct ixgbe_adapter {
 	struct ixgbe_q_vector q_vector[MAX_MSIX_Q_VECTORS];
 	char name[MAX_MSIX_COUNT][IFNAMSIZ + 5];
 
+	/* Interrupt Throttle Rate */
+	u32 itr_setting;
+	u16 eitr_low;
+	u16 eitr_high;
+
 	/* TX */
 	struct ixgbe_ring *tx_ring;	/* One per active queue */
 	u64 restart_queue;
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 85b7d15..4e46377 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -886,13 +886,13 @@ static int ixgbe_get_coalesce(struct net_device *netdev,
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
-	if (adapter->rx_eitr == 0)
-		ec->rx_coalesce_usecs = 0;
+	if (adapter->rx_eitr < IXGBE_MIN_ITR_USECS)
+		ec->rx_coalesce_usecs = adapter->rx_eitr;
 	else
 		ec->rx_coalesce_usecs = 1000000 / adapter->rx_eitr;
 
-	if (adapter->tx_eitr == 0)
-		ec->tx_coalesce_usecs = 0;
+	if (adapter->tx_eitr < IXGBE_MIN_ITR_USECS)
+		ec->tx_coalesce_usecs = adapter->tx_eitr;
 	else
 		ec->tx_coalesce_usecs = 1000000 / adapter->tx_eitr;
 
@@ -906,22 +906,26 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
 	if ((ec->rx_coalesce_usecs > IXGBE_MAX_ITR_USECS) ||
-	    ((ec->rx_coalesce_usecs > 0) &&
+	    ((ec->rx_coalesce_usecs != 0) &&
+	     (ec->rx_coalesce_usecs != 1) &&
+	     (ec->rx_coalesce_usecs != 3) &&
 	     (ec->rx_coalesce_usecs < IXGBE_MIN_ITR_USECS)))
 		return -EINVAL;
 	if ((ec->tx_coalesce_usecs > IXGBE_MAX_ITR_USECS) ||
-	    ((ec->tx_coalesce_usecs > 0) &&
+	    ((ec->tx_coalesce_usecs != 0) &&
+	     (ec->tx_coalesce_usecs != 1) &&
+	     (ec->tx_coalesce_usecs != 3) &&
 	     (ec->tx_coalesce_usecs < IXGBE_MIN_ITR_USECS)))
 		return -EINVAL;
 
 	/* convert to rate of irq's per second */
-	if (ec->rx_coalesce_usecs == 0)
-		adapter->rx_eitr = 0;
+	if (ec->rx_coalesce_usecs < IXGBE_MIN_ITR_USECS)
+		adapter->rx_eitr = ec->rx_coalesce_usecs;
 	else
 		adapter->rx_eitr = (1000000 / ec->rx_coalesce_usecs);
 
-	if (ec->tx_coalesce_usecs == 0)
-		adapter->tx_eitr = 0;
+	if (ec->tx_coalesce_usecs < IXGBE_MIN_ITR_USECS)
+		adapter->tx_eitr = ec->rx_coalesce_usecs;
 	else
 		adapter->tx_eitr = (1000000 / ec->tx_coalesce_usecs);
 
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index fc1c226..e1f11e6 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -282,6 +282,8 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_adapter *adapter,
 	if (total_tx_packets >= tx_ring->work_limit)
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EICS, tx_ring->eims_value);
 
+	tx_ring->total_bytes += total_tx_bytes;
+	tx_ring->total_packets += total_tx_packets;
 	adapter->net_stats.tx_bytes += total_tx_bytes;
 	adapter->net_stats.tx_packets += total_tx_packets;
 	cleaned = total_tx_packets ? true : false;
@@ -568,6 +570,11 @@ next_desc:
 	adapter->net_stats.rx_bytes += total_rx_bytes;
 	adapter->net_stats.rx_packets += total_rx_packets;
 
+	rx_ring->total_packets += total_rx_packets;
+	rx_ring->total_bytes += total_rx_bytes;
+	adapter->net_stats.rx_bytes += total_rx_bytes;
+	adapter->net_stats.rx_packets += total_rx_packets;
+
 	return cleaned;
 }
 
@@ -634,6 +641,144 @@ static void ixgbe_configure_msix(struct ixgbe_adapter *adapter)
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIAC, mask);
 }
 
+enum latency_range {
+	lowest_latency = 0,
+	low_latency = 1,
+	bulk_latency = 2,
+	latency_invalid = 255
+};
+
+/**
+ * ixgbe_update_itr - update the dynamic ITR value based on statistics
+ * @adapter: pointer to adapter
+ * @eitr: eitr setting (ints per sec) to give last timeslice
+ * @itr_setting: current throttle rate in ints/second
+ * @packets: the number of packets during this measurement interval
+ * @bytes: the number of bytes during this measurement interval
+ *
+ *      Stores a new ITR value based on packets and byte
+ *      counts during the last interrupt.  The advantage of per interrupt
+ *      computation is faster updates and more accurate ITR for the current
+ *      traffic pattern.  Constants in this function were computed
+ *      based on theoretical maximum wire speed and thresholds were set based
+ *      on testing data as well as attempting to minimize response time
+ *      while increasing bulk throughput.
+ *      this functionality is controlled by the InterruptThrottleRate module
+ *      parameter (see ixgbe_param.c)
+ **/
+static u8 ixgbe_update_itr(struct ixgbe_adapter *adapter,
+			   u32 eitr, u8 itr_setting,
+			   int packets, int bytes)
+{
+	unsigned int retval = itr_setting;
+	u32 timepassed_us;
+	u64 bytes_perint;
+
+	if (packets == 0)
+		goto update_itr_done;
+
+
+	/* simple throttlerate management
+	 *    0-20MB/s lowest (100000 ints/s)
+	 *   20-100MB/s low   (20000 ints/s)
+	 *  100-1249MB/s bulk (8000 ints/s)
+	 */
+	/* what was last interrupt timeslice? */
+	timepassed_us = 1000000/eitr;
+	bytes_perint = bytes / timepassed_us; /* bytes/usec */
+
+	switch (itr_setting) {
+	case lowest_latency:
+		if (bytes_perint > adapter->eitr_low)
+			retval = low_latency;
+		break;
+	case low_latency:
+		if (bytes_perint > adapter->eitr_high)
+			retval = bulk_latency;
+		else if (bytes_perint <= adapter->eitr_low)
+			retval = lowest_latency;
+		break;
+	case bulk_latency:
+		if (bytes_perint <= adapter->eitr_high)
+			retval = low_latency;
+		break;
+	}
+
+update_itr_done:
+	return retval;
+}
+
+static void ixgbe_set_itr_msix(struct ixgbe_q_vector *q_vector)
+{
+	struct ixgbe_adapter *adapter = q_vector->adapter;
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 new_itr;
+	u8 current_itr, ret_itr;
+	int i, r_idx, v_idx = ((void *)q_vector - (void *)(adapter->q_vector)) /
+			      sizeof(struct ixgbe_q_vector);
+	struct ixgbe_ring *rx_ring, *tx_ring;
+
+	r_idx = find_first_bit(q_vector->txr_idx, adapter->num_tx_queues);
+	for (i = 0; i < q_vector->txr_count; i++) {
+		tx_ring = &(adapter->tx_ring[r_idx]);
+		ret_itr = ixgbe_update_itr(adapter, q_vector->eitr,
+					   q_vector->tx_eitr,
+					   tx_ring->total_packets,
+					   tx_ring->total_bytes);
+		/* if the result for this queue would decrease interrupt
+		 * rate for this vector then use that result */
+		q_vector->tx_eitr = ((q_vector->tx_eitr > ret_itr) ?
+				    q_vector->tx_eitr - 1 : ret_itr);
+		r_idx = find_next_bit(q_vector->txr_idx, adapter->num_tx_queues,
+				      r_idx + 1);
+	}
+
+	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
+	for (i = 0; i < q_vector->rxr_count; i++) {
+		rx_ring = &(adapter->rx_ring[r_idx]);
+		ret_itr = ixgbe_update_itr(adapter, q_vector->eitr,
+					   q_vector->rx_eitr,
+					   rx_ring->total_packets,
+					   rx_ring->total_bytes);
+		/* if the result for this queue would decrease interrupt
+		 * rate for this vector then use that result */
+		q_vector->rx_eitr = ((q_vector->rx_eitr > ret_itr) ?
+				    q_vector->rx_eitr - 1 : ret_itr);
+		r_idx = find_next_bit(q_vector->rxr_idx, adapter->num_rx_queues,
+				      r_idx + 1);
+	}
+
+	current_itr = max(q_vector->rx_eitr, q_vector->tx_eitr);
+
+	switch (current_itr) {
+	/* counts and packets in update_itr are dependent on these numbers */
+	case lowest_latency:
+		new_itr = 100000;
+		break;
+	case low_latency:
+		new_itr = 20000; /* aka hwitr = ~200 */
+		break;
+	case bulk_latency:
+	default:
+		new_itr = 8000;
+		break;
+	}
+
+	if (new_itr != q_vector->eitr) {
+		u32 itr_reg;
+		/* do an exponential smoothing */
+		new_itr = ((q_vector->eitr * 90)/100) + ((new_itr * 10)/100);
+		q_vector->eitr = new_itr;
+		itr_reg = EITR_INTS_PER_SEC_TO_REG(new_itr);
+		/* must write high and low 16 bits to reset counter */
+		DPRINTK(TX_ERR, DEBUG, "writing eitr(%d): %08X\n", v_idx,
+			itr_reg);
+		IXGBE_WRITE_REG(hw, IXGBE_EITR(v_idx), itr_reg | (itr_reg)<<16);
+	}
+
+	return;
+}
+
 static irqreturn_t ixgbe_msix_lsc(int irq, void *data)
 {
 	struct net_device *netdev = data;
@@ -666,12 +811,13 @@ static irqreturn_t ixgbe_msix_clean_tx(int irq, void *data)
 	r_idx = find_first_bit(q_vector->txr_idx, adapter->num_tx_queues);
 	for (i = 0; i < q_vector->txr_count; i++) {
 		txr = &(adapter->tx_ring[r_idx]);
+		txr->total_bytes = 0;
+		txr->total_packets = 0;
 		ixgbe_clean_tx_irq(adapter, txr);
 		r_idx = find_next_bit(q_vector->txr_idx, adapter->num_tx_queues,
 				      r_idx + 1);
 	}
 
-
 	return IRQ_HANDLED;
 }
 
@@ -694,6 +840,8 @@ static irqreturn_t ixgbe_msix_clean_rx(int irq, void *data)
 	rxr = &(adapter->rx_ring[r_idx]);
 	/* disable interrupts on this vector only */
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, rxr->v_idx);
+	rxr->total_bytes = 0;
+	rxr->total_packets = 0;
 	netif_rx_schedule(adapter->netdev, &q_vector->napi);
 
 	return IRQ_HANDLED;
@@ -730,6 +878,8 @@ static int ixgbe_clean_rxonly(struct napi_struct *napi, int budget)
 	/* If all Rx work done, exit the polling mode */
 	if (work_done < budget) {
 		netif_rx_complete(adapter->netdev, napi);
+		if (adapter->rx_eitr < IXGBE_MIN_ITR_USECS)
+			ixgbe_set_itr_msix(q_vector);
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
 			IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS, rxr->v_idx);
 	}
@@ -886,6 +1036,54 @@ out:
 	return err;
 }
 
+static void ixgbe_set_itr(struct ixgbe_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	struct ixgbe_q_vector *q_vector = adapter->q_vector;
+	u8 current_itr;
+	u32 new_itr = q_vector->eitr;
+	struct ixgbe_ring *rx_ring = &adapter->rx_ring[0];
+	struct ixgbe_ring *tx_ring = &adapter->tx_ring[0];
+
+	q_vector->tx_eitr = ixgbe_update_itr(adapter, new_itr,
+					     q_vector->tx_eitr,
+					     tx_ring->total_packets,
+					     tx_ring->total_bytes);
+	q_vector->rx_eitr = ixgbe_update_itr(adapter, new_itr,
+					     q_vector->rx_eitr,
+					     rx_ring->total_packets,
+					     rx_ring->total_bytes);
+
+	current_itr = max(q_vector->rx_eitr, q_vector->tx_eitr);
+
+	switch (current_itr) {
+	/* counts and packets in update_itr are dependent on these numbers */
+	case lowest_latency:
+		new_itr = 100000;
+		break;
+	case low_latency:
+		new_itr = 20000; /* aka hwitr = ~200 */
+		break;
+	case bulk_latency:
+		new_itr = 8000;
+		break;
+	default:
+		break;
+	}
+
+	if (new_itr != q_vector->eitr) {
+		u32 itr_reg;
+		/* do an exponential smoothing */
+		new_itr = ((q_vector->eitr * 90)/100) + ((new_itr * 10)/100);
+		q_vector->eitr = new_itr;
+		itr_reg = EITR_INTS_PER_SEC_TO_REG(new_itr);
+		/* must write high and low 16 bits to reset counter */
+		IXGBE_WRITE_REG(hw, IXGBE_EITR(0), itr_reg | (itr_reg)<<16);
+	}
+
+	return;
+}
+
 static inline void ixgbe_irq_enable(struct ixgbe_adapter *adapter);
 
 /**
@@ -916,6 +1114,10 @@ static irqreturn_t ixgbe_intr(int irq, void *data)
 
 
 	if (netif_rx_schedule_prep(netdev, &adapter->q_vector[0].napi)) {
+		adapter->tx_ring[0].total_packets = 0;
+		adapter->tx_ring[0].total_bytes = 0;
+		adapter->rx_ring[0].total_packets = 0;
+		adapter->rx_ring[0].total_bytes = 0;
 		/* would disable interrupts here but EIAM disabled it */
 		__netif_rx_schedule(netdev, &adapter->q_vector[0].napi);
 	}
@@ -1367,7 +1569,6 @@ static void ixgbe_napi_disable_all(struct ixgbe_adapter *adapter)
 	}
 }
 
-
 static void ixgbe_configure(struct ixgbe_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
@@ -1732,6 +1933,8 @@ static int ixgbe_poll(struct napi_struct *napi, int budget)
 	/* If budget not fully consumed, exit the polling mode */
 	if (work_done < budget) {
 		netif_rx_complete(adapter->netdev, napi);
+		if (adapter->rx_eitr < IXGBE_MIN_ITR_USECS)
+			ixgbe_set_itr(adapter);
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
 			ixgbe_irq_enable(adapter);
 	}
@@ -2088,6 +2291,10 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	adapter->ring_feature[RING_F_RSS].indices = rss;
 	adapter->flags |= IXGBE_FLAG_RSS_ENABLED;
 
+	/* Enable Dynamic interrupt throttling by default */
+	adapter->rx_eitr = 1;
+	adapter->tx_eitr = 1;
+
 	/* default flow control settings */
 	hw->fc.original_type = ixgbe_fc_full;
 	hw->fc.type = ixgbe_fc_full;

