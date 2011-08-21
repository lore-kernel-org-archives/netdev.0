From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/10] ixgbe: Drop the TX work limit and instead just leave it to budget
Date: Sun, 21 Aug 2011 00:29:14 -0700
Message-ID: <1313911761-11709-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1313911761-11709-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:61333 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750878Ab1HUH31 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Aug 2011 03:29:27 -0400
In-Reply-To: <1313911761-11709-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change makes it so that the TX work limit is now obsolete.  Instead of
using it we can instead rely on the NAPI budget for the number of packets
we should clean per interrupt.  The advantage to this approach is that it
results in a much more balanced work flow since the same number of RX and
TX packets should be cleaned per interrupts.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |    4 ----
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |    7 -------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |   16 +++++++---------
 3 files changed, 7 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index dc3b12e..b85312f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -281,7 +281,6 @@ struct ixgbe_ring_container {
 	struct ixgbe_ring *ring;	/* pointer to linked list of rings */
 	unsigned int total_bytes;	/* total bytes processed this int */
 	unsigned int total_packets;	/* total packets processed this int */
-	u16 work_limit;			/* total work allowed per interrupt */
 	u8 count;			/* total number of rings in vector */
 	u8 itr;				/* current ITR setting for ring */
 };
@@ -416,9 +415,6 @@ struct ixgbe_adapter {
 	u16 eitr_low;
 	u16 eitr_high;
 
-	/* Work limits */
-	u16 tx_work_limit;
-
 	/* TX */
 	struct ixgbe_ring *tx_ring[MAX_TX_QUEUES] ____cacheline_aligned_in_smp;
 	int num_tx_queues;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 82d4244..16835cc 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -2005,8 +2005,6 @@ static int ixgbe_get_coalesce(struct net_device *netdev,
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
-	ec->tx_max_coalesced_frames_irq = adapter->tx_work_limit;
-
 	/* only valid if in constant ITR mode */
 	switch (adapter->rx_itr_setting) {
 	case 0:
@@ -2093,9 +2091,6 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
 	   && ec->tx_coalesce_usecs)
 		return -EINVAL;
 
-	if (ec->tx_max_coalesced_frames_irq)
-		adapter->tx_work_limit = ec->tx_max_coalesced_frames_irq;
-
 	if (ec->rx_coalesce_usecs > 1) {
 		/* check the limits */
 		if ((1000000/ec->rx_coalesce_usecs > IXGBE_MAX_INT_RATE) ||
@@ -2169,14 +2164,12 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
 			else
 				/* rx only or mixed */
 				q_vector->eitr = adapter->rx_eitr_param;
-			q_vector->tx.work_limit = adapter->tx_work_limit;
 			ixgbe_write_eitr(q_vector);
 		}
 	/* Legacy Interrupt Mode */
 	} else {
 		q_vector = adapter->q_vector[0];
 		q_vector->eitr = adapter->rx_eitr_param;
-		q_vector->tx.work_limit = adapter->tx_work_limit;
 		ixgbe_write_eitr(q_vector);
 	}
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index bb54d3d..2450279 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -796,15 +796,16 @@ static void ixgbe_tx_timeout_reset(struct ixgbe_adapter *adapter)
  * ixgbe_clean_tx_irq - Reclaim resources after transmit completes
  * @q_vector: structure containing interrupt and ring information
  * @tx_ring: tx ring to clean
+ * @budget: amount of work driver is allowed to do this pass, in packets
  **/
 static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
-			       struct ixgbe_ring *tx_ring)
+			       struct ixgbe_ring *tx_ring,
+			       int budget)
 {
 	struct ixgbe_adapter *adapter = q_vector->adapter;
 	struct ixgbe_tx_buffer *tx_buffer;
 	union ixgbe_adv_tx_desc *tx_desc;
 	unsigned int total_bytes = 0, total_packets = 0;
-	u16 budget = q_vector->tx.work_limit;
 	u16 i = tx_ring->next_to_clean;
 
 	tx_buffer = &tx_ring->tx_buffer_info[i];
@@ -2082,7 +2083,7 @@ static int ixgbe_clean_rxtx_many(struct napi_struct *napi, int budget)
 #endif
 
 	for (ring = q_vector->tx.ring; ring != NULL; ring = ring->next)
-		clean_complete &= ixgbe_clean_tx_irq(q_vector, ring);
+		clean_complete &= ixgbe_clean_tx_irq(q_vector, ring, budget);
 
 	/* attempt to distribute budget to each queue fairly, but don't allow
 	 * the budget to go below 1 because we'll exit polling */
@@ -2128,7 +2129,7 @@ static int ixgbe_clean_txonly(struct napi_struct *napi, int budget)
 		ixgbe_update_dca(q_vector);
 #endif
 
-	if (!ixgbe_clean_tx_irq(q_vector, q_vector->tx.ring))
+	if (!ixgbe_clean_tx_irq(q_vector, q_vector->tx.ring, budget))
 		return budget;
 
 	/* If all Tx work done, exit the polling mode */
@@ -2163,7 +2164,6 @@ static inline void map_vector_to_txq(struct ixgbe_adapter *a, int v_idx,
 	tx_ring->next = q_vector->tx.ring;
 	q_vector->tx.ring = tx_ring;
 	q_vector->tx.count++;
-	q_vector->tx.work_limit = a->tx_work_limit;
 }
 
 /**
@@ -4155,7 +4155,8 @@ static int ixgbe_poll(struct napi_struct *napi, int budget)
 		ixgbe_update_dca(q_vector);
 #endif
 
-	tx_clean_complete = ixgbe_clean_tx_irq(q_vector, adapter->tx_ring[0]);
+	tx_clean_complete = ixgbe_clean_tx_irq(q_vector, adapter->tx_ring[0],
+					       budget);
 	ixgbe_clean_rx_irq(q_vector, adapter->rx_ring[0], &work_done, budget);
 
 	if (!tx_clean_complete)
@@ -5090,9 +5091,6 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	adapter->tx_ring_count = IXGBE_DEFAULT_TXD;
 	adapter->rx_ring_count = IXGBE_DEFAULT_RXD;
 
-	/* set default work limits */
-	adapter->tx_work_limit = adapter->tx_ring_count;
-
 	/* initialize eeprom parameters */
 	if (ixgbe_init_eeprom_params_generic(hw)) {
 		e_dev_err("EEPROM initialization failed\n");
-- 
1.7.6

