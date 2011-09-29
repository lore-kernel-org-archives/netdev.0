From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/8] ixgbe: Cleanup q_vector interrupt throttle rate logic
Date: Wed, 28 Sep 2011 23:30:11 -0700
Message-ID: <1317277816-6024-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1317277816-6024-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:37696 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751636Ab1I2GaU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Sep 2011 02:30:20 -0400
In-Reply-To: <1317277816-6024-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch is meant to help cleanup the interrupt throttle rate logic by
storing the interrupt throttle rate as a value in microseconds instead of
interrupts per second.  The advantage to this approach is that the value
can now be stored in an 16 bit field and doesn't require as much math to
flip the value back and forth since the hardware already used microseconds
when setting the rate.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |   25 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |  153 +++++++---------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |   77 +++++------
 3 files changed, 96 insertions(+), 159 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 1f4a4ca..38940d7 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -301,26 +301,29 @@ struct ixgbe_ring_container {
  */
 struct ixgbe_q_vector {
 	struct ixgbe_adapter *adapter;
-	unsigned int v_idx; /* index of q_vector within array, also used for
-	                     * finding the bit in EICR and friends that
-	                     * represents the vector for this ring */
 #ifdef CONFIG_IXGBE_DCA
 	int cpu;	    /* CPU for DCA */
 #endif
-	struct napi_struct napi;
+	u16 v_idx;		/* index of q_vector within array, also used for
+				 * finding the bit in EICR and friends that
+				 * represents the vector for this ring */
+	u16 itr;		/* Interrupt throttle rate written to EITR */
 	struct ixgbe_ring_container rx, tx;
-	u32 eitr;
+
+	struct napi_struct napi;
 	cpumask_var_t affinity_mask;
 	char name[IFNAMSIZ + 9];
 };
 
-/* Helper macros to switch between ints/sec and what the register uses.
- * And yes, it's the same math going both ways.  The lowest value
- * supported by all of the ixgbe hardware is 8.
+/*
+ * microsecond values for various ITR rates shifted by 2 to fit itr register
+ * with the first 3 bits reserved 0
  */
-#define EITR_INTS_PER_SEC_TO_REG(_eitr) \
-	((_eitr) ? (1000000000 / ((_eitr) * 256)) : 8)
-#define EITR_REG_TO_INTS_PER_SEC EITR_INTS_PER_SEC_TO_REG
+#define IXGBE_MIN_RSC_ITR	24
+#define IXGBE_100K_ITR		40
+#define IXGBE_20K_ITR		200
+#define IXGBE_10K_ITR		400
+#define IXGBE_8K_ITR		500
 
 static inline u16 ixgbe_desc_unused(struct ixgbe_ring *ring)
 {
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index debcf5f..ae9fba5 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -2026,39 +2026,20 @@ static int ixgbe_get_coalesce(struct net_device *netdev,
 	ec->tx_max_coalesced_frames_irq = adapter->tx_work_limit;
 
 	/* only valid if in constant ITR mode */
-	switch (adapter->rx_itr_setting) {
-	case 0:
-		/* throttling disabled */
-		ec->rx_coalesce_usecs = 0;
-		break;
-	case 1:
-		/* dynamic ITR mode */
-		ec->rx_coalesce_usecs = 1;
-		break;
-	default:
-		/* fixed interrupt rate mode */
-		ec->rx_coalesce_usecs = 1000000/adapter->rx_eitr_param;
-		break;
-	}
+	if (adapter->rx_itr_setting <= 1)
+		ec->rx_coalesce_usecs = adapter->rx_itr_setting;
+	else
+		ec->rx_coalesce_usecs = adapter->rx_itr_setting >> 2;
 
 	/* if in mixed tx/rx queues per vector mode, report only rx settings */
 	if (adapter->q_vector[0]->tx.count && adapter->q_vector[0]->rx.count)
 		return 0;
 
 	/* only valid if in constant ITR mode */
-	switch (adapter->tx_itr_setting) {
-	case 0:
-		/* throttling disabled */
-		ec->tx_coalesce_usecs = 0;
-		break;
-	case 1:
-		/* dynamic ITR mode */
-		ec->tx_coalesce_usecs = 1;
-		break;
-	default:
-		ec->tx_coalesce_usecs = 1000000/adapter->tx_eitr_param;
-		break;
-	}
+	if (adapter->tx_itr_setting <= 1)
+		ec->tx_coalesce_usecs = adapter->tx_itr_setting;
+	else
+		ec->tx_coalesce_usecs = adapter->tx_itr_setting >> 2;
 
 	return 0;
 }
@@ -2077,10 +2058,9 @@ static bool ixgbe_update_rsc(struct ixgbe_adapter *adapter,
 
 	/* if interrupt rate is too high then disable RSC */
 	if (ec->rx_coalesce_usecs != 1 &&
-	    ec->rx_coalesce_usecs <= 1000000/IXGBE_MAX_RSC_INT_RATE) {
+	    ec->rx_coalesce_usecs <= (IXGBE_MIN_RSC_ITR >> 2)) {
 		if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED) {
-			e_info(probe, "rx-usecs set too low, "
-				      "disabling RSC\n");
+			e_info(probe, "rx-usecs set too low, disabling RSC\n");
 			adapter->flags2 &= ~IXGBE_FLAG2_RSC_ENABLED;
 			return true;
 		}
@@ -2088,8 +2068,7 @@ static bool ixgbe_update_rsc(struct ixgbe_adapter *adapter,
 		/* check the feature flag value and enable RSC if necessary */
 		if ((netdev->features & NETIF_F_LRO) &&
 		    !(adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED)) {
-			e_info(probe, "rx-usecs set to %d, "
-				      "re-enabling RSC\n",
+			e_info(probe, "rx-usecs set to %d, re-enabling RSC\n",
 			       ec->rx_coalesce_usecs);
 			adapter->flags2 |= IXGBE_FLAG2_RSC_ENABLED;
 			return true;
@@ -2104,97 +2083,59 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_q_vector *q_vector;
 	int i;
+	int num_vectors;
+	u16 tx_itr_param, rx_itr_param;
 	bool need_reset = false;
 
 	/* don't accept tx specific changes if we've got mixed RxTx vectors */
 	if (adapter->q_vector[0]->tx.count && adapter->q_vector[0]->rx.count
-	   && ec->tx_coalesce_usecs)
+	    && ec->tx_coalesce_usecs)
 		return -EINVAL;
 
 	if (ec->tx_max_coalesced_frames_irq)
 		adapter->tx_work_limit = ec->tx_max_coalesced_frames_irq;
 
-	if (ec->rx_coalesce_usecs > 1) {
-		/* check the limits */
-		if ((1000000/ec->rx_coalesce_usecs > IXGBE_MAX_INT_RATE) ||
-		    (1000000/ec->rx_coalesce_usecs < IXGBE_MIN_INT_RATE))
-			return -EINVAL;
-
-		/* check the old value and enable RSC if necessary */
-		need_reset = ixgbe_update_rsc(adapter, ec);
-
-		/* store the value in ints/second */
-		adapter->rx_eitr_param = 1000000/ec->rx_coalesce_usecs;
+	if ((ec->rx_coalesce_usecs > (IXGBE_MAX_EITR >> 2)) ||
+	    (ec->tx_coalesce_usecs > (IXGBE_MAX_EITR >> 2)))
+		return -EINVAL;
 
-		/* static value of interrupt rate */
-		adapter->rx_itr_setting = adapter->rx_eitr_param;
-		/* clear the lower bit as its used for dynamic state */
-		adapter->rx_itr_setting &= ~1;
-	} else if (ec->rx_coalesce_usecs == 1) {
-		/* check the old value and enable RSC if necessary */
-		need_reset = ixgbe_update_rsc(adapter, ec);
+	/* check the old value and enable RSC if necessary */
+	need_reset = ixgbe_update_rsc(adapter, ec);
 
-		/* 1 means dynamic mode */
-		adapter->rx_eitr_param = 20000;
-		adapter->rx_itr_setting = 1;
-	} else {
-		/* check the old value and enable RSC if necessary */
-		need_reset = ixgbe_update_rsc(adapter, ec);
-		/*
-		 * any other value means disable eitr, which is best
-		 * served by setting the interrupt rate very high
-		 */
-		adapter->rx_eitr_param = IXGBE_MAX_INT_RATE;
-		adapter->rx_itr_setting = 0;
-	}
+	if (ec->rx_coalesce_usecs > 1)
+		adapter->rx_itr_setting = ec->rx_coalesce_usecs << 2;
+	else
+		adapter->rx_itr_setting = ec->rx_coalesce_usecs;
 
-	if (ec->tx_coalesce_usecs > 1) {
-		/*
-		 * don't have to worry about max_int as above because
-		 * tx vectors don't do hardware RSC (an rx function)
-		 */
-		/* check the limits */
-		if ((1000000/ec->tx_coalesce_usecs > IXGBE_MAX_INT_RATE) ||
-		    (1000000/ec->tx_coalesce_usecs < IXGBE_MIN_INT_RATE))
-			return -EINVAL;
+	if (adapter->rx_itr_setting == 1)
+		rx_itr_param = IXGBE_20K_ITR;
+	else
+		rx_itr_param = adapter->rx_itr_setting;
 
-		/* store the value in ints/second */
-		adapter->tx_eitr_param = 1000000/ec->tx_coalesce_usecs;
+	if (ec->tx_coalesce_usecs > 1)
+		adapter->tx_itr_setting = ec->tx_coalesce_usecs << 2;
+	else
+		adapter->tx_itr_setting = ec->tx_coalesce_usecs;
 
-		/* static value of interrupt rate */
-		adapter->tx_itr_setting = adapter->tx_eitr_param;
+	if (adapter->tx_itr_setting == 1)
+		tx_itr_param = IXGBE_10K_ITR;
+	else
+		tx_itr_param = adapter->tx_itr_setting;
 
-		/* clear the lower bit as its used for dynamic state */
-		adapter->tx_itr_setting &= ~1;
-	} else if (ec->tx_coalesce_usecs == 1) {
-		/* 1 means dynamic mode */
-		adapter->tx_eitr_param = 10000;
-		adapter->tx_itr_setting = 1;
-	} else {
-		adapter->tx_eitr_param = IXGBE_MAX_INT_RATE;
-		adapter->tx_itr_setting = 0;
-	}
+	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED)
+		num_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
+	else
+		num_vectors = 1;
 
-	/* MSI/MSIx Interrupt Mode */
-	if (adapter->flags &
-	    (IXGBE_FLAG_MSIX_ENABLED | IXGBE_FLAG_MSI_ENABLED)) {
-		int num_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
-		for (i = 0; i < num_vectors; i++) {
-			q_vector = adapter->q_vector[i];
-			if (q_vector->tx.count && !q_vector->rx.count)
-				/* tx only */
-				q_vector->eitr = adapter->tx_eitr_param;
-			else
-				/* rx only or mixed */
-				q_vector->eitr = adapter->rx_eitr_param;
-			q_vector->tx.work_limit = adapter->tx_work_limit;
-			ixgbe_write_eitr(q_vector);
-		}
-	/* Legacy Interrupt Mode */
-	} else {
-		q_vector = adapter->q_vector[0];
-		q_vector->eitr = adapter->rx_eitr_param;
+	for (i = 0; i < num_vectors; i++) {
+		q_vector = adapter->q_vector[i];
 		q_vector->tx.work_limit = adapter->tx_work_limit;
+		if (q_vector->tx.count && !q_vector->rx.count)
+			/* tx only */
+			q_vector->itr = tx_itr_param;
+		else
+			/* rx only or mixed */
+			q_vector->itr = rx_itr_param;
 		ixgbe_write_eitr(q_vector);
 	}
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index c26ea94..3594b09 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1500,12 +1500,19 @@ static void ixgbe_configure_msix(struct ixgbe_adapter *adapter)
 		for (ring = q_vector->tx.ring; ring != NULL; ring = ring->next)
 			ixgbe_set_ivar(adapter, 1, ring->reg_idx, v_idx);
 
-		if (q_vector->tx.ring && !q_vector->rx.ring)
-			/* tx only */
-			q_vector->eitr = adapter->tx_eitr_param;
-		else if (q_vector->rx.ring)
-			/* rx or mixed */
-			q_vector->eitr = adapter->rx_eitr_param;
+		if (q_vector->tx.ring && !q_vector->rx.ring) {
+			/* tx only vector */
+			if (adapter->tx_itr_setting == 1)
+				q_vector->itr = IXGBE_10K_ITR;
+			else
+				q_vector->itr = adapter->tx_itr_setting;
+		} else {
+			/* rx or rx/tx vector */
+			if (adapter->rx_itr_setting == 1)
+				q_vector->itr = IXGBE_20K_ITR;
+			else
+				q_vector->itr = adapter->rx_itr_setting;
+		}
 
 		ixgbe_write_eitr(q_vector);
 	}
@@ -1519,7 +1526,6 @@ static void ixgbe_configure_msix(struct ixgbe_adapter *adapter)
 	case ixgbe_mac_X540:
 		ixgbe_set_ivar(adapter, -1, 1, v_idx);
 		break;
-
 	default:
 		break;
 	}
@@ -1527,12 +1533,10 @@ static void ixgbe_configure_msix(struct ixgbe_adapter *adapter)
 
 	/* set up to autoclear timer, and the vectors */
 	mask = IXGBE_EIMS_ENABLE_MASK;
-	if (adapter->num_vfs)
-		mask &= ~(IXGBE_EIMS_OTHER |
-			  IXGBE_EIMS_MAILBOX |
-			  IXGBE_EIMS_LSC);
-	else
-		mask &= ~(IXGBE_EIMS_OTHER | IXGBE_EIMS_LSC);
+	mask &= ~(IXGBE_EIMS_OTHER |
+		  IXGBE_EIMS_MAILBOX |
+		  IXGBE_EIMS_LSC);
+
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIAC, mask);
 }
 
@@ -1577,7 +1581,7 @@ static void ixgbe_update_itr(struct ixgbe_q_vector *q_vector,
 	 *  100-1249MB/s bulk (8000 ints/s)
 	 */
 	/* what was last interrupt timeslice? */
-	timepassed_us = 1000000/q_vector->eitr;
+	timepassed_us = q_vector->itr >> 2;
 	bytes_perint = bytes / timepassed_us; /* bytes/usec */
 
 	switch (itr_setting) {
@@ -1618,7 +1622,7 @@ void ixgbe_write_eitr(struct ixgbe_q_vector *q_vector)
 	struct ixgbe_adapter *adapter = q_vector->adapter;
 	struct ixgbe_hw *hw = &adapter->hw;
 	int v_idx = q_vector->v_idx;
-	u32 itr_reg = EITR_INTS_PER_SEC_TO_REG(q_vector->eitr);
+	u32 itr_reg = q_vector->itr;
 
 	switch (adapter->hw.mac.type) {
 	case ixgbe_mac_82598EB:
@@ -1628,15 +1632,6 @@ void ixgbe_write_eitr(struct ixgbe_q_vector *q_vector)
 	case ixgbe_mac_82599EB:
 	case ixgbe_mac_X540:
 		/*
-		 * 82599 and X540 can support a value of zero, so allow it for
-		 * max interrupt rate, but there is an errata where it can
-		 * not be zero with RSC
-		 */
-		if (itr_reg == 8 &&
-		    !(adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED))
-			itr_reg = 0;
-
-		/*
 		 * set the WDIS bit to not clear the timer bits and cause an
 		 * immediate assertion of the interrupt
 		 */
@@ -1650,7 +1645,7 @@ void ixgbe_write_eitr(struct ixgbe_q_vector *q_vector)
 
 static void ixgbe_set_itr(struct ixgbe_q_vector *q_vector)
 {
-	u32 new_itr = q_vector->eitr;
+	u32 new_itr = q_vector->itr;
 	u8 current_itr;
 
 	ixgbe_update_itr(q_vector, &q_vector->tx);
@@ -1661,24 +1656,25 @@ static void ixgbe_set_itr(struct ixgbe_q_vector *q_vector)
 	switch (current_itr) {
 	/* counts and packets in update_itr are dependent on these numbers */
 	case lowest_latency:
-		new_itr = 100000;
+		new_itr = IXGBE_100K_ITR;
 		break;
 	case low_latency:
-		new_itr = 20000; /* aka hwitr = ~200 */
+		new_itr = IXGBE_20K_ITR;
 		break;
 	case bulk_latency:
-		new_itr = 8000;
+		new_itr = IXGBE_8K_ITR;
 		break;
 	default:
 		break;
 	}
 
-	if (new_itr != q_vector->eitr) {
+	if (new_itr != q_vector->itr) {
 		/* do an exponential smoothing */
-		new_itr = ((q_vector->eitr * 9) + new_itr)/10;
+		new_itr = (10 * new_itr * q_vector->itr) /
+			  ((9 * new_itr) + q_vector->itr);
 
 		/* save the algorithm value here */
-		q_vector->eitr = new_itr;
+		q_vector->itr = new_itr & IXGBE_MAX_EITR;
 
 		ixgbe_write_eitr(q_vector);
 	}
@@ -2301,10 +2297,15 @@ static inline void ixgbe_irq_disable(struct ixgbe_adapter *adapter)
  **/
 static void ixgbe_configure_msi_and_legacy(struct ixgbe_adapter *adapter)
 {
-	struct ixgbe_hw *hw = &adapter->hw;
+	struct ixgbe_q_vector *q_vector = adapter->q_vector[0];
 
-	IXGBE_WRITE_REG(hw, IXGBE_EITR(0),
-			EITR_INTS_PER_SEC_TO_REG(adapter->rx_eitr_param));
+	/* rx/tx vector */
+	if (adapter->rx_itr_setting == 1)
+		q_vector->itr = IXGBE_20K_ITR;
+	else
+		q_vector->itr = adapter->rx_itr_setting;
+
+	ixgbe_write_eitr(q_vector);
 
 	ixgbe_set_ivar(adapter, 0, 0, 0);
 	ixgbe_set_ivar(adapter, 1, 0, 0);
@@ -4613,12 +4614,6 @@ static int ixgbe_alloc_q_vectors(struct ixgbe_adapter *adapter)
 		if (!alloc_cpumask_var(&q_vector->affinity_mask, GFP_KERNEL))
 			goto err_out;
 		cpumask_set_cpu(v_idx, q_vector->affinity_mask);
-
-		if (q_vector->tx.count && !q_vector->rx.count)
-			q_vector->eitr = adapter->tx_eitr_param;
-		else
-			q_vector->eitr = adapter->rx_eitr_param;
-
 		netif_napi_add(adapter->netdev, &q_vector->napi,
 			       ixgbe_poll, 64);
 		adapter->q_vector[v_idx] = q_vector;
@@ -4864,9 +4859,7 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 
 	/* enable itr by default in dynamic mode */
 	adapter->rx_itr_setting = 1;
-	adapter->rx_eitr_param = 20000;
 	adapter->tx_itr_setting = 1;
-	adapter->tx_eitr_param = 10000;
 
 	/* set defaults for eitr in MegaBytes */
 	adapter->eitr_low = 10;
-- 
1.7.6.2
