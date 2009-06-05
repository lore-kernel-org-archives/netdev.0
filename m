From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 02/10] ixgbe: move v_idx into q_vector and use as
	index only
Date: Thu, 04 Jun 2009 19:00:09 -0700
Message-ID: <20090605020008.8468.91524.stgit@localhost.localdomain>
References: <20090605015948.8468.25862.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.emeryville.ca.mail.comcast.net ([76.96.30.96]:34758 "EHLO
	QMTA09.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752968AbZFECAY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 22:00:24 -0400
In-Reply-To: <20090605015948.8468.25862.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The v_idx value was being used as both a bitmask and an index.  This change
makes it so that the q_vector contains the index and allows for much of the
code to be simplified since disabling a q_vector involves only clearing one
bit in the interrupt bitmask.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h         |   11 +-
 drivers/net/ixgbe/ixgbe_ethtool.c |    5 -
 drivers/net/ixgbe/ixgbe_main.c    |  227 ++++++++++++++++++-------------------
 3 files changed, 117 insertions(+), 126 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index c5f73ed..00c303a 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -148,10 +148,6 @@ struct ixgbe_ring {
 	int cpu;
 #endif
 	struct ixgbe_queue_stats stats;
-	u64 v_idx; /* maps directly to the index for this ring in the hardware
-	            * vector array, can also be used for finding the bit in EICR
-	            * and friends that represents the vector for this ring */
-
 
 	u16 work_limit;                /* max work per interrupt */
 	u16 rx_buf_len;
@@ -193,6 +189,9 @@ struct ixgbe_ring_feature {
  */
 struct ixgbe_q_vector {
 	struct ixgbe_adapter *adapter;
+	unsigned int v_idx; /* index of q_vector within array, also used for
+	                     * finding the bit in EICR and friends that
+	                     * represents the vector for this ring */
 	struct napi_struct napi;
 	DECLARE_BITMAP(rxr_idx, MAX_RX_QUEUES); /* Rx ring indices */
 	DECLARE_BITMAP(txr_idx, MAX_TX_QUEUES); /* Tx ring indices */
@@ -201,7 +200,6 @@ struct ixgbe_q_vector {
 	u8 tx_itr;
 	u8 rx_itr;
 	u32 eitr;
-	u32 v_idx;        /* vector index in list */
 };
 
 /* Helper macros to switch between ints/sec and what the register uses.
@@ -401,7 +399,8 @@ extern void ixgbe_free_tx_resources(struct ixgbe_adapter *, struct ixgbe_ring *)
 extern void ixgbe_update_stats(struct ixgbe_adapter *adapter);
 extern int ixgbe_init_interrupt_scheme(struct ixgbe_adapter *adapter);
 extern void ixgbe_clear_interrupt_scheme(struct ixgbe_adapter *adapter);
-extern void ixgbe_write_eitr(struct ixgbe_adapter *, int, u32);
+extern void ixgbe_write_eitr(struct ixgbe_q_vector *);
+extern int ethtool_ioctl(struct ifreq *ifr);
 #ifdef IXGBE_FCOE
 extern void ixgbe_configure_fcoe(struct ixgbe_adapter *adapter);
 extern int ixgbe_fso(struct ixgbe_adapter *adapter,
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index e0feaf5..003b6e5 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -840,7 +840,6 @@ static int ixgbe_set_ringparam(struct net_device *netdev,
 				}
 				goto err_setup;
 			}
-			temp_tx_ring[i].v_idx = adapter->tx_ring[i].v_idx;
 		}
 		need_update = true;
 	}
@@ -870,7 +869,6 @@ static int ixgbe_set_ringparam(struct net_device *netdev,
 				}
 				goto err_setup;
 			}
-			temp_rx_ring[i].v_idx = adapter->rx_ring[i].v_idx;
 		}
 		need_update = true;
 	}
@@ -1987,8 +1985,7 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
 		else
 			/* rx only or mixed */
 			q_vector->eitr = adapter->eitr_param;
-		ixgbe_write_eitr(adapter, i,
-		                 EITR_INTS_PER_SEC_TO_REG(q_vector->eitr));
+		ixgbe_write_eitr(q_vector);
 	}
 
 	return 0;
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index e1efa1d..2500e8b 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -186,6 +186,22 @@ static void ixgbe_set_ivar(struct ixgbe_adapter *adapter, s8 direction,
 	}
 }
 
+static inline void ixgbe_irq_rearm_queues(struct ixgbe_adapter *adapter,
+                                          u64 qmask)
+{
+	u32 mask;
+
+	if (adapter->hw.mac.type == ixgbe_mac_82598EB) {
+		mask = (IXGBE_EIMS_RTX_QUEUE & qmask);
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EICS, mask);
+	} else {
+		mask = (qmask & 0xFFFFFFFF);
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EICS_EX(0), mask);
+		mask = (qmask >> 32);
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EICS_EX(1), mask);
+	}
+}
+
 static void ixgbe_unmap_and_free_tx_resource(struct ixgbe_adapter *adapter,
                                              struct ixgbe_tx_buffer
                                              *tx_buffer_info)
@@ -248,14 +264,13 @@ static void ixgbe_tx_timeout(struct net_device *netdev);
 
 /**
  * ixgbe_clean_tx_irq - Reclaim resources after transmit completes
- * @adapter: board private structure
+ * @q_vector: structure containing interrupt and ring information
  * @tx_ring: tx ring to clean
- *
- * returns true if transmit work is done
  **/
-static bool ixgbe_clean_tx_irq(struct ixgbe_adapter *adapter,
+static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
                                struct ixgbe_ring *tx_ring)
 {
+	struct ixgbe_adapter *adapter = q_vector->adapter;
 	struct net_device *netdev = adapter->netdev;
 	union ixgbe_adv_tx_desc *tx_desc, *eop_desc;
 	struct ixgbe_tx_buffer *tx_buffer_info;
@@ -329,18 +344,8 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_adapter *adapter,
 	}
 
 	/* re-arm the interrupt */
-	if (count >= tx_ring->work_limit) {
-		if (adapter->hw.mac.type == ixgbe_mac_82598EB)
-			IXGBE_WRITE_REG(&adapter->hw, IXGBE_EICS,
-					tx_ring->v_idx);
-		else if (tx_ring->v_idx & 0xFFFFFFFF)
-			IXGBE_WRITE_REG(&adapter->hw, IXGBE_EICS_EX(0),
-					tx_ring->v_idx);
-		else
-			IXGBE_WRITE_REG(&adapter->hw, IXGBE_EICS_EX(1),
-					(tx_ring->v_idx >> 32));
-	}
-
+	if (count >= tx_ring->work_limit)
+		ixgbe_irq_rearm_queues(adapter, ((u64)1 << q_vector->v_idx));
 
 	tx_ring->total_bytes += total_bytes;
 	tx_ring->total_packets += total_packets;
@@ -875,12 +880,7 @@ static void ixgbe_configure_msix(struct ixgbe_adapter *adapter)
 			/* rx only */
 			q_vector->eitr = adapter->eitr_param;
 
-		/*
-		 * since this is initial set up don't need to call
-		 * ixgbe_write_eitr helper
-		 */
-		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EITR(v_idx),
-		                EITR_INTS_PER_SEC_TO_REG(q_vector->eitr));
+		ixgbe_write_eitr(q_vector);
 	}
 
 	if (adapter->hw.mac.type == ixgbe_mac_82598EB)
@@ -965,17 +965,19 @@ update_itr_done:
 
 /**
  * ixgbe_write_eitr - write EITR register in hardware specific way
- * @adapter: pointer to adapter struct
- * @v_idx: vector index into q_vector array
- * @itr_reg: new value to be written in *register* format, not ints/s
+ * @q_vector: structure containing interrupt and ring information
  *
  * This function is made to be called by ethtool and by the driver
  * when it needs to update EITR registers at runtime.  Hardware
  * specific quirks/differences are taken care of here.
  */
-void ixgbe_write_eitr(struct ixgbe_adapter *adapter, int v_idx, u32 itr_reg)
+void ixgbe_write_eitr(struct ixgbe_q_vector *q_vector)
 {
+	struct ixgbe_adapter *adapter = q_vector->adapter;
 	struct ixgbe_hw *hw = &adapter->hw;
+	int v_idx = q_vector->v_idx;
+	u32 itr_reg = EITR_INTS_PER_SEC_TO_REG(q_vector->eitr);
+
 	if (adapter->hw.mac.type == ixgbe_mac_82598EB) {
 		/* must write high and low 16 bits to reset counter */
 		itr_reg |= (itr_reg << 16);
@@ -994,7 +996,7 @@ static void ixgbe_set_itr_msix(struct ixgbe_q_vector *q_vector)
 	struct ixgbe_adapter *adapter = q_vector->adapter;
 	u32 new_itr;
 	u8 current_itr, ret_itr;
-	int i, r_idx, v_idx = q_vector->v_idx;
+	int i, r_idx;
 	struct ixgbe_ring *rx_ring, *tx_ring;
 
 	r_idx = find_first_bit(q_vector->txr_idx, adapter->num_tx_queues);
@@ -1044,14 +1046,13 @@ static void ixgbe_set_itr_msix(struct ixgbe_q_vector *q_vector)
 	}
 
 	if (new_itr != q_vector->eitr) {
-		u32 itr_reg;
+		/* do an exponential smoothing */
+		new_itr = ((q_vector->eitr * 90)/100) + ((new_itr * 10)/100);
 
 		/* save the algorithm value here, not the smoothed one */
 		q_vector->eitr = new_itr;
-		/* do an exponential smoothing */
-		new_itr = ((q_vector->eitr * 90)/100) + ((new_itr * 10)/100);
-		itr_reg = EITR_INTS_PER_SEC_TO_REG(new_itr);
-		ixgbe_write_eitr(adapter, v_idx, itr_reg);
+
+		ixgbe_write_eitr(q_vector);
 	}
 
 	return;
@@ -1130,6 +1131,40 @@ static irqreturn_t ixgbe_msix_lsc(int irq, void *data)
 	return IRQ_HANDLED;
 }
 
+static inline void ixgbe_irq_enable_queues(struct ixgbe_adapter *adapter,
+					   u64 qmask)
+{
+	u32 mask;
+
+	if (adapter->hw.mac.type == ixgbe_mac_82598EB) {
+		mask = (IXGBE_EIMS_RTX_QUEUE & qmask);
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS, mask);
+	} else {
+		mask = (qmask & 0xFFFFFFFF);
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS_EX(0), mask);
+		mask = (qmask >> 32);
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS_EX(1), mask);
+	}
+	/* skip the flush */
+}
+
+static inline void ixgbe_irq_disable_queues(struct ixgbe_adapter *adapter,
+                                            u64 qmask)
+{
+	u32 mask;
+
+	if (adapter->hw.mac.type == ixgbe_mac_82598EB) {
+		mask = (IXGBE_EIMS_RTX_QUEUE & qmask);
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, mask);
+	} else {
+		mask = (qmask & 0xFFFFFFFF);
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC_EX(0), mask);
+		mask = (qmask >> 32);
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC_EX(1), mask);
+	}
+	/* skip the flush */
+}
+
 static irqreturn_t ixgbe_msix_clean_tx(int irq, void *data)
 {
 	struct ixgbe_q_vector *q_vector = data;
@@ -1149,7 +1184,7 @@ static irqreturn_t ixgbe_msix_clean_tx(int irq, void *data)
 #endif
 		tx_ring->total_bytes = 0;
 		tx_ring->total_packets = 0;
-		ixgbe_clean_tx_irq(adapter, tx_ring);
+		ixgbe_clean_tx_irq(q_vector, tx_ring);
 		r_idx = find_next_bit(q_vector->txr_idx, adapter->num_tx_queues,
 		                      r_idx + 1);
 	}
@@ -1185,13 +1220,7 @@ static irqreturn_t ixgbe_msix_clean_rx(int irq, void *data)
 	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
 	rx_ring = &(adapter->rx_ring[r_idx]);
 	/* disable interrupts on this vector only */
-	if (adapter->hw.mac.type == ixgbe_mac_82598EB)
-		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, rx_ring->v_idx);
-	else if (rx_ring->v_idx & 0xFFFFFFFF)
-		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC_EX(0), rx_ring->v_idx);
-	else
-		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC_EX(1),
-				(rx_ring->v_idx >> 32));
+	ixgbe_irq_disable_queues(adapter, ((u64)1 << q_vector->v_idx));
 	napi_schedule(&q_vector->napi);
 
 	return IRQ_HANDLED;
@@ -1205,23 +1234,6 @@ static irqreturn_t ixgbe_msix_clean_many(int irq, void *data)
 	return IRQ_HANDLED;
 }
 
-static inline void ixgbe_irq_enable_queues(struct ixgbe_adapter *adapter,
-					   u64 qmask)
-{
-	u32 mask;
-
-	if (adapter->hw.mac.type == ixgbe_mac_82598EB) {
-		mask = (IXGBE_EIMS_RTX_QUEUE & qmask);
-		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS, mask);
-	} else {
-		mask = (qmask & 0xFFFFFFFF);
-		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS_EX(0), mask);
-		mask = (qmask >> 32);
-		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS_EX(1), mask);
-	}
-	/* skip the flush */
-}
-
 /**
  * ixgbe_clean_rxonly - msix (aka one shot) rx clean routine
  * @napi: napi struct with our devices info in it
@@ -1254,7 +1266,8 @@ static int ixgbe_clean_rxonly(struct napi_struct *napi, int budget)
 		if (adapter->itr_setting & 1)
 			ixgbe_set_itr_msix(q_vector);
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
-			ixgbe_irq_enable_queues(adapter, rx_ring->v_idx);
+			ixgbe_irq_enable_queues(adapter,
+			                        ((u64)1 << q_vector->v_idx));
 	}
 
 	return work_done;
@@ -1276,7 +1289,6 @@ static int ixgbe_clean_rxonly_many(struct napi_struct *napi, int budget)
 	struct ixgbe_ring *rx_ring = NULL;
 	int work_done = 0, i;
 	long r_idx;
-	u64 enable_mask = 0;
 
 	/* attempt to distribute budget to each queue fairly, but don't allow
 	 * the budget to go below 1 because we'll exit polling */
@@ -1290,7 +1302,6 @@ static int ixgbe_clean_rxonly_many(struct napi_struct *napi, int budget)
 			ixgbe_update_rx_dca(adapter, rx_ring);
 #endif
 		ixgbe_clean_rx_irq(q_vector, rx_ring, &work_done, budget);
-		enable_mask |= rx_ring->v_idx;
 		r_idx = find_next_bit(q_vector->rxr_idx, adapter->num_rx_queues,
 		                      r_idx + 1);
 	}
@@ -1303,7 +1314,8 @@ static int ixgbe_clean_rxonly_many(struct napi_struct *napi, int budget)
 		if (adapter->itr_setting & 1)
 			ixgbe_set_itr_msix(q_vector);
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
-			ixgbe_irq_enable_queues(adapter, enable_mask);
+			ixgbe_irq_enable_queues(adapter,
+			                        ((u64)1 << q_vector->v_idx));
 		return 0;
 	}
 
@@ -1316,7 +1328,6 @@ static inline void map_vector_to_rxq(struct ixgbe_adapter *a, int v_idx,
 
 	set_bit(r_idx, q_vector->rxr_idx);
 	q_vector->rxr_count++;
-	a->rx_ring[r_idx].v_idx = (u64)1 << v_idx;
 }
 
 static inline void map_vector_to_txq(struct ixgbe_adapter *a, int v_idx,
@@ -1326,7 +1337,6 @@ static inline void map_vector_to_txq(struct ixgbe_adapter *a, int v_idx,
 
 	set_bit(t_idx, q_vector->txr_idx);
 	q_vector->txr_count++;
-	a->tx_ring[t_idx].v_idx = (u64)1 << v_idx;
 }
 
 /**
@@ -1505,14 +1515,13 @@ static void ixgbe_set_itr(struct ixgbe_adapter *adapter)
 	}
 
 	if (new_itr != q_vector->eitr) {
-		u32 itr_reg;
+		/* do an exponential smoothing */
+		new_itr = ((q_vector->eitr * 90)/100) + ((new_itr * 10)/100);
 
 		/* save the algorithm value here, not the smoothed one */
 		q_vector->eitr = new_itr;
-		/* do an exponential smoothing */
-		new_itr = ((q_vector->eitr * 90)/100) + ((new_itr * 10)/100);
-		itr_reg = EITR_INTS_PER_SEC_TO_REG(new_itr);
-		ixgbe_write_eitr(adapter, 0, itr_reg);
+
+		ixgbe_write_eitr(q_vector);
 	}
 
 	return;
@@ -2805,7 +2814,7 @@ static int ixgbe_poll(struct napi_struct *napi, int budget)
 	}
 #endif
 
-	tx_clean_complete = ixgbe_clean_tx_irq(adapter, adapter->tx_ring);
+	tx_clean_complete = ixgbe_clean_tx_irq(q_vector, adapter->tx_ring);
 	ixgbe_clean_rx_irq(q_vector, adapter->rx_ring, &work_done, budget);
 
 	if (!tx_clean_complete)
@@ -3324,8 +3333,8 @@ static int ixgbe_alloc_q_vectors(struct ixgbe_adapter *adapter)
 		if (!q_vector)
 			goto err_out;
 		q_vector->adapter = adapter;
-		q_vector->v_idx = q_idx;
 		q_vector->eitr = adapter->eitr_param;
+		q_vector->v_idx = q_idx;
 		if (q_idx < napi_vectors)
 			netif_napi_add(adapter->netdev, &q_vector->napi,
 			               (*poll), 64);
@@ -4216,57 +4225,43 @@ static void ixgbe_watchdog(unsigned long data)
 {
 	struct ixgbe_adapter *adapter = (struct ixgbe_adapter *)data;
 	struct ixgbe_hw *hw = &adapter->hw;
+	u64 eics = 0;
+	int i;
 
-	/* Do the watchdog outside of interrupt context due to the lovely
-	 * delays that some of the newer hardware requires */
-	if (!test_bit(__IXGBE_DOWN, &adapter->state)) {
-		u64 eics = 0;
-		int i;
+	/*
+	 *  Do the watchdog outside of interrupt context due to the lovely
+	 * delays that some of the newer hardware requires
+	 */
 
-		for (i = 0; i < adapter->num_msix_vectors - NON_Q_VECTORS; i++)
-			eics |= ((u64)1 << i);
+	if (test_bit(__IXGBE_DOWN, &adapter->state))
+		goto watchdog_short_circuit;
 
-		/* Cause software interrupt to ensure rx rings are cleaned */
-		switch (hw->mac.type) {
-		case ixgbe_mac_82598EB:
-			if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
-				IXGBE_WRITE_REG(hw, IXGBE_EICS, (u32)eics);
-			} else {
-				/*
-				 * for legacy and MSI interrupts don't set any
-				 * bits that are enabled for EIAM, because this
-				 * operation would set *both* EIMS and EICS for
-				 * any bit in EIAM
-				 */
-				IXGBE_WRITE_REG(hw, IXGBE_EICS,
-				     (IXGBE_EICS_TCP_TIMER | IXGBE_EICS_OTHER));
-			}
-			break;
-		case ixgbe_mac_82599EB:
-			if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
-				IXGBE_WRITE_REG(hw, IXGBE_EICS_EX(0),
-				                (u32)(eics & 0xFFFFFFFF));
-				IXGBE_WRITE_REG(hw, IXGBE_EICS_EX(1),
-				                (u32)(eics >> 32));
-			} else {
-				/*
-				 * for legacy and MSI interrupts don't set any
-				 * bits that are enabled for EIAM, because this
-				 * operation would set *both* EIMS and EICS for
-				 * any bit in EIAM
-				 */
-				IXGBE_WRITE_REG(hw, IXGBE_EICS,
-				     (IXGBE_EICS_TCP_TIMER | IXGBE_EICS_OTHER));
-			}
-			break;
-		default:
-			break;
-		}
-		/* Reset the timer */
-		mod_timer(&adapter->watchdog_timer,
-		          round_jiffies(jiffies + 2 * HZ));
+	if (!(adapter->flags & IXGBE_FLAG_MSIX_ENABLED)) {
+		/*
+		 * for legacy and MSI interrupts don't set any bits
+		 * that are enabled for EIAM, because this operation
+		 * would set *both* EIMS and EICS for any bit in EIAM
+		 */
+		IXGBE_WRITE_REG(hw, IXGBE_EICS,
+			(IXGBE_EICS_TCP_TIMER | IXGBE_EICS_OTHER));
+		goto watchdog_reschedule;
+	}
+
+	/* get one bit for every active tx/rx interrupt vector */
+	for (i = 0; i < adapter->num_msix_vectors - NON_Q_VECTORS; i++) {
+		struct ixgbe_q_vector *qv = adapter->q_vector[i];
+		if (qv->rxr_count || qv->txr_count)
+			eics |= ((u64)1 << i);
 	}
 
+	/* Cause software interrupt to ensure rx rings are cleaned */
+	ixgbe_irq_rearm_queues(adapter, eics);
+
+watchdog_reschedule:
+	/* Reset the timer */
+	mod_timer(&adapter->watchdog_timer, round_jiffies(jiffies + 2 * HZ));
+
+watchdog_short_circuit:
 	schedule_work(&adapter->watchdog_task);
 }
 

