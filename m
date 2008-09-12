From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RESEND][NET-NEXT PATCH 11/29][UPDATED] ixgbe: fix initial interrupt
	throttle settings
Date: Thu, 11 Sep 2008 19:58:14 -0700
Message-ID: <20080912025730.6234.19994.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080912025404.6234.83037.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.176]:45474 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756702AbYILC6R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 22:58:17 -0400
Received: by wa-out-1112.google.com with SMTP id j37so392897waf.23
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 19:58:17 -0700 (PDT)
In-Reply-To: <20080912025404.6234.83037.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

ixgbe was incorrectly setting the throttle rate setting for all tx
queues and the driver has been refreshed to better handle a dynamic
interrupt mode as well as multiple queues.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
---

 drivers/net/ixgbe/ixgbe.h         |   23 +++-------
 drivers/net/ixgbe/ixgbe_ethtool.c |   86 ++++++++++++++++++++-----------------
 drivers/net/ixgbe/ixgbe_main.c    |   80 +++++++++++++++++++---------------
 3 files changed, 100 insertions(+), 89 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 2b827a6..5ba0384 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -62,11 +62,6 @@
 #define IXGBE_MAX_RXQ				   1
 #define IXGBE_MIN_RXQ				   1
 
-#define IXGBE_DEFAULT_ITR_RX_USECS	    125  /*   8k irqs/sec */
-#define IXGBE_DEFAULT_ITR_TX_USECS	    250  /*   4k irqs/sec */
-#define IXGBE_MIN_ITR_USECS		    100  /* 500k irqs/sec */
-#define IXGBE_MAX_ITR_USECS		  10000  /* 100  irqs/sec */
-
 /* flow control */
 #define IXGBE_DEFAULT_FCRTL		0x10000
 #define IXGBE_MIN_FCRTL			   0x40
@@ -161,10 +156,7 @@ struct ixgbe_ring {
 		   * vector array, can also be used for finding the bit in EICR
 		   * and friends that represents the vector for this ring */
 
-	u32 eims_value;
-	u16 itr_register;
 
-	char name[IFNAMSIZ + 5];
 	u16 work_limit;                /* max work per interrupt */
 	u16 rx_buf_len;
 };
@@ -191,8 +183,8 @@ struct ixgbe_q_vector {
 	DECLARE_BITMAP(txr_idx, MAX_TX_QUEUES); /* Tx ring indices */
 	u8 rxr_count;     /* Rx ring count assigned to this vector */
 	u8 txr_count;     /* Tx ring count assigned to this vector */
-	u8 tx_eitr;
-	u8 rx_eitr;
+	u8 tx_itr;
+	u8 rx_itr;
 	u32 eitr;
 };
 
@@ -240,7 +232,9 @@ struct ixgbe_adapter {
 
 	/* TX */
 	struct ixgbe_ring *tx_ring;	/* One per active queue */
+	int num_tx_queues;
 	u64 restart_queue;
+	u64 hw_csum_tx_good;
 	u64 lsc_int;
 	u64 hw_tso_ctxt;
 	u64 hw_tso6_ctxt;
@@ -249,12 +243,10 @@ struct ixgbe_adapter {
 
 	/* RX */
 	struct ixgbe_ring *rx_ring;	/* One per active queue */
-	u64 hw_csum_tx_good;
+	int num_rx_queues;
 	u64 hw_csum_rx_error;
 	u64 hw_csum_rx_good;
 	u64 non_eop_descs;
-	int num_tx_queues;
-	int num_rx_queues;
 	int num_msix_vectors;
 	struct ixgbe_ring_feature ring_feature[3];
 	struct msix_entry *msix_entries;
@@ -301,14 +293,15 @@ struct ixgbe_adapter {
 	struct ixgbe_hw_stats stats;
 
 	/* Interrupt Throttle Rate */
-	u32 rx_eitr;
-	u32 tx_eitr;
+	u32 eitr_param;
 
 	unsigned long state;
 	u64 tx_busy;
 	u64 lro_aggregated;
 	u64 lro_flushed;
 	u64 lro_no_desc;
+	unsigned int tx_ring_count;
+	unsigned int rx_ring_count;
 
 	u32 link_speed;
 	bool link_up;
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 2506f9e..f18e3da 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -880,17 +880,23 @@ static int ixgbe_get_coalesce(struct net_device *netdev,
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
-	if (adapter->rx_eitr < IXGBE_MIN_ITR_USECS)
-		ec->rx_coalesce_usecs = adapter->rx_eitr;
-	else
-		ec->rx_coalesce_usecs = 1000000 / adapter->rx_eitr;
-
-	if (adapter->tx_eitr < IXGBE_MIN_ITR_USECS)
-		ec->tx_coalesce_usecs = adapter->tx_eitr;
-	else
-		ec->tx_coalesce_usecs = 1000000 / adapter->tx_eitr;
-
 	ec->tx_max_coalesced_frames_irq = adapter->tx_ring[0].work_limit;
+
+	/* only valid if in constant ITR mode */
+	switch (adapter->itr_setting) {
+	case 0:
+		/* throttling disabled */
+		ec->rx_coalesce_usecs = 0;
+		break;
+	case 1:
+		/* dynamic ITR mode */
+		ec->rx_coalesce_usecs = 1;
+		break;
+	default:
+		/* fixed interrupt rate mode */
+		ec->rx_coalesce_usecs = 1000000/adapter->eitr_param;
+		break;
+	}
 	return 0;
 }
 
@@ -898,38 +904,40 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
 			      struct ethtool_coalesce *ec)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-
-	if ((ec->rx_coalesce_usecs > IXGBE_MAX_ITR_USECS) ||
-	    ((ec->rx_coalesce_usecs != 0) &&
-	     (ec->rx_coalesce_usecs != 1) &&
-	     (ec->rx_coalesce_usecs != 3) &&
-	     (ec->rx_coalesce_usecs < IXGBE_MIN_ITR_USECS)))
-		return -EINVAL;
-	if ((ec->tx_coalesce_usecs > IXGBE_MAX_ITR_USECS) ||
-	    ((ec->tx_coalesce_usecs != 0) &&
-	     (ec->tx_coalesce_usecs != 1) &&
-	     (ec->tx_coalesce_usecs != 3) &&
-	     (ec->tx_coalesce_usecs < IXGBE_MIN_ITR_USECS)))
-		return -EINVAL;
-
-	/* convert to rate of irq's per second */
-	if (ec->rx_coalesce_usecs < IXGBE_MIN_ITR_USECS)
-		adapter->rx_eitr = ec->rx_coalesce_usecs;
-	else
-		adapter->rx_eitr = (1000000 / ec->rx_coalesce_usecs);
-
-	if (ec->tx_coalesce_usecs < IXGBE_MIN_ITR_USECS)
-		adapter->tx_eitr = ec->rx_coalesce_usecs;
-	else
-		adapter->tx_eitr = (1000000 / ec->tx_coalesce_usecs);
+	struct ixgbe_hw *hw = &adapter->hw;
+	int i;
 
 	if (ec->tx_max_coalesced_frames_irq)
-		adapter->tx_ring[0].work_limit =
-					ec->tx_max_coalesced_frames_irq;
+		adapter->tx_ring[0].work_limit = ec->tx_max_coalesced_frames_irq;
+
+	if (ec->rx_coalesce_usecs > 1) {
+		/* store the value in ints/second */
+		adapter->eitr_param = 1000000/ec->rx_coalesce_usecs;
+
+		/* static value of interrupt rate */
+		adapter->itr_setting = adapter->eitr_param;
+		/* clear the lower bit */
+		adapter->itr_setting &= ~1;
+	} else if (ec->rx_coalesce_usecs == 1) {
+		/* 1 means dynamic mode */
+		adapter->eitr_param = 20000;
+		adapter->itr_setting = 1;
+	} else {
+		/* any other value means disable eitr, which is best
+		 * served by setting the interrupt rate very high */
+		adapter->eitr_param = 3000000;
+		adapter->itr_setting = 0;
+	}
 
-	if (netif_running(netdev)) {
-		ixgbe_down(adapter);
-		ixgbe_up(adapter);
+	for (i = 0; i < adapter->num_msix_vectors - NON_Q_VECTORS; i++) {
+		struct ixgbe_q_vector *q_vector = &adapter->q_vector[i];
+		if (q_vector->txr_count && !q_vector->rxr_count)
+			q_vector->eitr = (adapter->eitr_param >> 1);
+		else
+			/* rx only or mixed */
+			q_vector->eitr = adapter->eitr_param;
+		IXGBE_WRITE_REG(hw, IXGBE_EITR(i),
+		                EITR_INTS_PER_SEC_TO_REG(q_vector->eitr));
 	}
 
 	return 0;
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 0269115..ef965c9 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -744,12 +744,12 @@ static void ixgbe_configure_msix(struct ixgbe_adapter *adapter)
 					      r_idx + 1);
 		}
 
-		/* if this is a tx only vector use half the irq (tx) rate */
+		/* if this is a tx only vector halve the interrupt rate */
 		if (q_vector->txr_count && !q_vector->rxr_count)
-			q_vector->eitr = adapter->tx_eitr;
+			q_vector->eitr = (adapter->eitr_param >> 1);
 		else
-			/* rx only or mixed */
-			q_vector->eitr = adapter->rx_eitr;
+			/* rx only */
+			q_vector->eitr = adapter->eitr_param;
 
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EITR(v_idx),
 				EITR_INTS_PER_SEC_TO_REG(q_vector->eitr));
@@ -845,13 +845,13 @@ static void ixgbe_set_itr_msix(struct ixgbe_q_vector *q_vector)
 	for (i = 0; i < q_vector->txr_count; i++) {
 		tx_ring = &(adapter->tx_ring[r_idx]);
 		ret_itr = ixgbe_update_itr(adapter, q_vector->eitr,
-					   q_vector->tx_eitr,
+					   q_vector->tx_itr,
 					   tx_ring->total_packets,
 					   tx_ring->total_bytes);
 		/* if the result for this queue would decrease interrupt
 		 * rate for this vector then use that result */
-		q_vector->tx_eitr = ((q_vector->tx_eitr > ret_itr) ?
-				    q_vector->tx_eitr - 1 : ret_itr);
+		q_vector->tx_itr = ((q_vector->tx_itr > ret_itr) ?
+				    q_vector->tx_itr - 1 : ret_itr);
 		r_idx = find_next_bit(q_vector->txr_idx, adapter->num_tx_queues,
 				      r_idx + 1);
 	}
@@ -860,18 +860,18 @@ static void ixgbe_set_itr_msix(struct ixgbe_q_vector *q_vector)
 	for (i = 0; i < q_vector->rxr_count; i++) {
 		rx_ring = &(adapter->rx_ring[r_idx]);
 		ret_itr = ixgbe_update_itr(adapter, q_vector->eitr,
-					   q_vector->rx_eitr,
+					   q_vector->rx_itr,
 					   rx_ring->total_packets,
 					   rx_ring->total_bytes);
 		/* if the result for this queue would decrease interrupt
 		 * rate for this vector then use that result */
-		q_vector->rx_eitr = ((q_vector->rx_eitr > ret_itr) ?
-				    q_vector->rx_eitr - 1 : ret_itr);
+		q_vector->rx_itr = ((q_vector->rx_itr > ret_itr) ?
+				    q_vector->rx_itr - 1 : ret_itr);
 		r_idx = find_next_bit(q_vector->rxr_idx, adapter->num_rx_queues,
 				      r_idx + 1);
 	}
 
-	current_itr = max(q_vector->rx_eitr, q_vector->tx_eitr);
+	current_itr = max(q_vector->rx_itr, q_vector->tx_itr);
 
 	switch (current_itr) {
 	/* counts and packets in update_itr are dependent on these numbers */
@@ -970,16 +970,24 @@ static irqreturn_t ixgbe_msix_clean_rx(int irq, void *data)
 	struct ixgbe_adapter  *adapter = q_vector->adapter;
 	struct ixgbe_ring  *rx_ring;
 	int r_idx;
+	int i;
 
 	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
+	for (i = 0;  i < q_vector->rxr_count; i++) {
+		rx_ring = &(adapter->rx_ring[r_idx]);
+		rx_ring->total_bytes = 0;
+		rx_ring->total_packets = 0;
+		r_idx = find_next_bit(q_vector->rxr_idx, adapter->num_rx_queues,
+		                      r_idx + 1);
+	}
+
 	if (!q_vector->rxr_count)
 		return IRQ_HANDLED;
 
+	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
 	rx_ring = &(adapter->rx_ring[r_idx]);
 	/* disable interrupts on this vector only */
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, rx_ring->v_idx);
-	rx_ring->total_bytes = 0;
-	rx_ring->total_packets = 0;
 	netif_rx_schedule(adapter->netdev, &q_vector->napi);
 
 	return IRQ_HANDLED;
@@ -1020,7 +1028,7 @@ static int ixgbe_clean_rxonly(struct napi_struct *napi, int budget)
 	/* If all Rx work done, exit the polling mode */
 	if (work_done < budget) {
 		netif_rx_complete(adapter->netdev, napi);
-		if (adapter->rx_eitr < IXGBE_MIN_ITR_USECS)
+		if (adapter->itr_setting & 3)
 			ixgbe_set_itr_msix(q_vector);
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
 			IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS, rx_ring->v_idx);
@@ -1187,16 +1195,16 @@ static void ixgbe_set_itr(struct ixgbe_adapter *adapter)
 	struct ixgbe_ring *rx_ring = &adapter->rx_ring[0];
 	struct ixgbe_ring *tx_ring = &adapter->tx_ring[0];
 
-	q_vector->tx_eitr = ixgbe_update_itr(adapter, new_itr,
-					     q_vector->tx_eitr,
-					     tx_ring->total_packets,
-					     tx_ring->total_bytes);
-	q_vector->rx_eitr = ixgbe_update_itr(adapter, new_itr,
-					     q_vector->rx_eitr,
-					     rx_ring->total_packets,
-					     rx_ring->total_bytes);
+	q_vector->tx_itr = ixgbe_update_itr(adapter, new_itr,
+					    q_vector->tx_itr,
+					    tx_ring->total_packets,
+					    tx_ring->total_bytes);
+	q_vector->rx_itr = ixgbe_update_itr(adapter, new_itr,
+					    q_vector->rx_itr,
+					    rx_ring->total_packets,
+					    rx_ring->total_bytes);
 
-	current_itr = max(q_vector->rx_eitr, q_vector->tx_eitr);
+	current_itr = max(q_vector->rx_itr, q_vector->tx_itr);
 
 	switch (current_itr) {
 	/* counts and packets in update_itr are dependent on these numbers */
@@ -1371,7 +1379,7 @@ static void ixgbe_configure_msi_and_legacy(struct ixgbe_adapter *adapter)
 	struct ixgbe_hw *hw = &adapter->hw;
 
 	IXGBE_WRITE_REG(hw, IXGBE_EITR(0),
-			EITR_INTS_PER_SEC_TO_REG(adapter->rx_eitr));
+	                EITR_INTS_PER_SEC_TO_REG(adapter->eitr_param));
 
 	ixgbe_set_ivar(adapter, IXGBE_IVAR_RX_QUEUE(0), 0);
 	ixgbe_set_ivar(adapter, IXGBE_IVAR_TX_QUEUE(0), 0);
@@ -2209,7 +2217,7 @@ static int ixgbe_poll(struct napi_struct *napi, int budget)
 	/* If budget not fully consumed, exit the polling mode */
 	if (work_done < budget) {
 		netif_rx_complete(adapter->netdev, napi);
-		if (adapter->rx_eitr < IXGBE_MIN_ITR_USECS)
+		if (adapter->itr_setting & 3)
 			ixgbe_set_itr(adapter);
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
 			ixgbe_irq_enable(adapter);
@@ -2421,12 +2429,6 @@ static int __devinit ixgbe_set_interrupt_capability(struct ixgbe_adapter
 	int vector, v_budget;
 
 	/*
-	 * Set the default interrupt throttle rate.
-	 */
-	adapter->rx_eitr = (1000000 / IXGBE_DEFAULT_ITR_RX_USECS);
-	adapter->tx_eitr = (1000000 / IXGBE_DEFAULT_ITR_TX_USECS);
-
-	/*
 	 * It's easy to be greedy for MSI-X vectors, but it really
 	 * doesn't do us much good if we have a lot more vectors
 	 * than CPU's.  So let's be conservative and only ask for
@@ -2567,10 +2569,6 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	adapter->ring_feature[RING_F_RSS].indices = rss;
 	adapter->flags |= IXGBE_FLAG_RSS_ENABLED;
 
-	/* Enable Dynamic interrupt throttling by default */
-	adapter->rx_eitr = 1;
-	adapter->tx_eitr = 1;
-
 	/* default flow control settings */
 	hw->fc.original_type = ixgbe_fc_none;
 	hw->fc.type = ixgbe_fc_none;
@@ -2591,6 +2589,18 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 		return -EIO;
 	}
 
+	/* enable itr by default in dynamic mode */
+	adapter->itr_setting = 1;
+	adapter->eitr_param = 20000;
+
+	/* set defaults for eitr in MegaBytes */
+	adapter->eitr_low = 10;
+	adapter->eitr_high = 20;
+
+	/* set default ring sizes */
+	adapter->tx_ring_count = IXGBE_DEFAULT_TXD;
+	adapter->rx_ring_count = IXGBE_DEFAULT_RXD;
+
 	/* initialize eeprom parameters */
 	if (ixgbe_init_eeprom(hw)) {
 		dev_err(&pdev->dev, "EEPROM initialization failed\n");

