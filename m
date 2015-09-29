From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 2/6] i40e/i40evf: refactor tx timeout logic
Date: Mon, 28 Sep 2015 17:55:30 -0700
Message-ID: <1443488134-36387-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1443488134-36387-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Kiran Patil <kiran.patil@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Shannon Nelson <shannon.nelson@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:16566 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754609AbbI2Azh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Sep 2015 20:55:37 -0400
In-Reply-To: <1443488134-36387-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kiran Patil <kiran.patil@intel.com>

This patch modifies the driver timeout logic by issuing a writeback
request via a software interrupt to the hardware the first time the
driver detects a hang. The driver was too aggressive in resetting a hung
queue, so back that off by removing logic to down the netdevice after
too many hangs, and move the function to the service task.

Change-ID: Ife100b9d124cd08cbdb81ab659008c1b9abbedea
Signed-off-by: Kiran Patil <kiran.patil@intel.com>
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h        |   1 -
 drivers/net/ethernet/intel/i40e/i40e_main.c   | 272 +++++++++++++++-----------
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   |  75 +------
 drivers/net/ethernet/intel/i40e/i40e_txrx.h   |  10 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c |  94 +--------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h |   8 -
 6 files changed, 173 insertions(+), 287 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index e746279..4797269 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -243,7 +243,6 @@ struct i40e_pf {
 	struct pci_dev *pdev;
 	struct i40e_hw hw;
 	unsigned long state;
-	unsigned long link_check_timeout;
 	struct msix_entry *msix_entries;
 	bool fc_autoneg_status;
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 530d8b6..c246dca 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -299,25 +299,69 @@ static void i40e_tx_timeout(struct net_device *netdev)
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
 	struct i40e_pf *pf = vsi->back;
+	struct i40e_ring *tx_ring = NULL;
+	unsigned int i, hung_queue = 0;
+	u32 head, val;
 
 	pf->tx_timeout_count++;
 
+	/* find the stopped queue the same way the stack does */
+	for (i = 0; i < netdev->num_tx_queues; i++) {
+		struct netdev_queue *q;
+		unsigned long trans_start;
+
+		q = netdev_get_tx_queue(netdev, i);
+		trans_start = q->trans_start ? : netdev->trans_start;
+		if (netif_xmit_stopped(q) &&
+		    time_after(jiffies,
+			       (trans_start + netdev->watchdog_timeo))) {
+			hung_queue = i;
+			break;
+		}
+	}
+
+	if (i == netdev->num_tx_queues) {
+		netdev_info(netdev, "tx_timeout: no netdev hung queue found\n");
+	} else {
+		/* now that we have an index, find the tx_ring struct */
+		for (i = 0; i < vsi->num_queue_pairs; i++) {
+			if (vsi->tx_rings[i] && vsi->tx_rings[i]->desc) {
+				if (hung_queue ==
+				    vsi->tx_rings[i]->queue_index) {
+					tx_ring = vsi->tx_rings[i];
+					break;
+				}
+			}
+		}
+	}
+
 	if (time_after(jiffies, (pf->tx_timeout_last_recovery + HZ*20)))
-		pf->tx_timeout_recovery_level = 1;
+		pf->tx_timeout_recovery_level = 1;  /* reset after some time */
+	else if (time_before(jiffies,
+		      (pf->tx_timeout_last_recovery + netdev->watchdog_timeo)))
+		return;   /* don't do any new action before the next timeout */
+
+	if (tx_ring) {
+		head = i40e_get_head(tx_ring);
+		/* Read interrupt register */
+		if (pf->flags & I40E_FLAG_MSIX_ENABLED)
+			val = rd32(&pf->hw,
+			     I40E_PFINT_DYN_CTLN(tx_ring->q_vector->v_idx +
+						tx_ring->vsi->base_vector - 1));
+		else
+			val = rd32(&pf->hw, I40E_PFINT_DYN_CTL0);
+
+		netdev_info(netdev, "tx_timeout: VSI_seid: %d, Q %d, NTC: 0x%x, HWB: 0x%x, NTU: 0x%x, TAIL: 0x%x, INT: 0x%x\n",
+			    vsi->seid, hung_queue, tx_ring->next_to_clean,
+			    head, tx_ring->next_to_use,
+			    readl(tx_ring->tail), val);
+	}
+
 	pf->tx_timeout_last_recovery = jiffies;
-	netdev_info(netdev, "tx_timeout recovery level %d\n",
-		    pf->tx_timeout_recovery_level);
+	netdev_info(netdev, "tx_timeout recovery level %d, hung_queue %d\n",
+		    pf->tx_timeout_recovery_level, hung_queue);
 
 	switch (pf->tx_timeout_recovery_level) {
-	case 0:
-		/* disable and re-enable queues for the VSI */
-		if (in_interrupt()) {
-			set_bit(__I40E_REINIT_REQUESTED, &pf->state);
-			set_bit(__I40E_REINIT_REQUESTED, &vsi->state);
-		} else {
-			i40e_vsi_reinit_locked(vsi);
-		}
-		break;
 	case 1:
 		set_bit(__I40E_PF_RESET_REQUESTED, &pf->state);
 		break;
@@ -329,10 +373,9 @@ static void i40e_tx_timeout(struct net_device *netdev)
 		break;
 	default:
 		netdev_err(netdev, "tx_timeout recovery unsuccessful\n");
-		set_bit(__I40E_DOWN_REQUESTED, &pf->state);
-		set_bit(__I40E_DOWN_REQUESTED, &vsi->state);
 		break;
 	}
+
 	i40e_service_event_schedule(pf);
 	pf->tx_timeout_recovery_level++;
 }
@@ -754,7 +797,6 @@ static void i40e_update_link_xoff_rx(struct i40e_pf *pf)
 	struct i40e_hw_port_stats *nsd = &pf->stats;
 	struct i40e_hw *hw = &pf->hw;
 	u64 xoff = 0;
-	u16 i, v;
 
 	if ((hw->fc.current_mode != I40E_FC_FULL) &&
 	    (hw->fc.current_mode != I40E_FC_RX_PAUSE))
@@ -769,18 +811,6 @@ static void i40e_update_link_xoff_rx(struct i40e_pf *pf)
 	if (!(nsd->link_xoff_rx - xoff))
 		return;
 
-	/* Clear the __I40E_HANG_CHECK_ARMED bit for all Tx rings */
-	for (v = 0; v < pf->num_alloc_vsi; v++) {
-		struct i40e_vsi *vsi = pf->vsi[v];
-
-		if (!vsi || !vsi->tx_rings[0])
-			continue;
-
-		for (i = 0; i < vsi->num_queue_pairs; i++) {
-			struct i40e_ring *ring = vsi->tx_rings[i];
-			clear_bit(__I40E_HANG_CHECK_ARMED, &ring->state);
-		}
-	}
 }
 
 /**
@@ -796,7 +826,7 @@ static void i40e_update_prio_xoff_rx(struct i40e_pf *pf)
 	bool xoff[I40E_MAX_TRAFFIC_CLASS] = {false};
 	struct i40e_dcbx_config *dcb_cfg;
 	struct i40e_hw *hw = &pf->hw;
-	u16 i, v;
+	u16 i;
 	u8 tc;
 
 	dcb_cfg = &hw->local_dcbx_config;
@@ -821,23 +851,6 @@ static void i40e_update_prio_xoff_rx(struct i40e_pf *pf)
 		tc = dcb_cfg->etscfg.prioritytable[i];
 		xoff[tc] = true;
 	}
-
-	/* Clear the __I40E_HANG_CHECK_ARMED bit for Tx rings */
-	for (v = 0; v < pf->num_alloc_vsi; v++) {
-		struct i40e_vsi *vsi = pf->vsi[v];
-
-		if (!vsi || !vsi->tx_rings[0])
-			continue;
-
-		for (i = 0; i < vsi->num_queue_pairs; i++) {
-			struct i40e_ring *ring = vsi->tx_rings[i];
-
-			tc = ring->dcb_tc;
-			if (xoff[tc])
-				clear_bit(__I40E_HANG_CHECK_ARMED,
-					  &ring->state);
-		}
-	}
 }
 
 /**
@@ -2609,8 +2622,6 @@ static int i40e_configure_tx_ring(struct i40e_ring *ring)
 	wr32(hw, I40E_QTX_CTL(pf_q), qtx_ctl);
 	i40e_flush(hw);
 
-	clear_bit(__I40E_HANG_CHECK_ARMED, &ring->state);
-
 	/* cache tail off for easier writes later */
 	ring->tail = hw->hw_addr + I40E_QTX_TAIL(pf_q);
 
@@ -4145,6 +4156,108 @@ static int i40e_pf_wait_txq_disabled(struct i40e_pf *pf)
 }
 
 #endif
+
+/**
+ * i40e_detect_recover_hung_queue - Function to detect and recover hung_queue
+ * @q_idx: TX queue number
+ * @vsi: Pointer to VSI struct
+ *
+ * This function checks specified queue for given VSI. Detects hung condition.
+ * Sets hung bit since it is two step process. Before next run of service task
+ * if napi_poll runs, it reset 'hung' bit for respective q_vector. If not,
+ * hung condition remain unchanged and during subsequent run, this function
+ * issues SW interrupt to recover from hung condition.
+ **/
+static void i40e_detect_recover_hung_queue(int q_idx, struct i40e_vsi *vsi)
+{
+	struct i40e_ring *tx_ring = NULL;
+	struct i40e_pf	*pf;
+	u32 head, val, tx_pending;
+	int i;
+
+	pf = vsi->back;
+
+	/* now that we have an index, find the tx_ring struct */
+	for (i = 0; i < vsi->num_queue_pairs; i++) {
+		if (vsi->tx_rings[i] && vsi->tx_rings[i]->desc) {
+			if (q_idx == vsi->tx_rings[i]->queue_index) {
+				tx_ring = vsi->tx_rings[i];
+				break;
+			}
+		}
+	}
+
+	if (!tx_ring)
+		return;
+
+	/* Read interrupt register */
+	if (pf->flags & I40E_FLAG_MSIX_ENABLED)
+		val = rd32(&pf->hw,
+			   I40E_PFINT_DYN_CTLN(tx_ring->q_vector->v_idx +
+					       tx_ring->vsi->base_vector - 1));
+	else
+		val = rd32(&pf->hw, I40E_PFINT_DYN_CTL0);
+
+	head = i40e_get_head(tx_ring);
+
+	tx_pending = i40e_get_tx_pending(tx_ring);
+
+	/* Interrupts are disabled and TX pending is non-zero,
+	 * trigger the SW interrupt (don't wait). Worst case
+	 * there will be one extra interrupt which may result
+	 * into not cleaning any queues because queues are cleaned.
+	 */
+	if (tx_pending && (!(val & I40E_PFINT_DYN_CTLN_INTENA_MASK)))
+		i40e_force_wb(vsi, tx_ring->q_vector);
+}
+
+/**
+ * i40e_detect_recover_hung - Function to detect and recover hung_queues
+ * @pf:  pointer to PF struct
+ *
+ * LAN VSI has netdev and netdev has TX queues. This function is to check
+ * each of those TX queues if they are hung, trigger recovery by issuing
+ * SW interrupt.
+ **/
+static void i40e_detect_recover_hung(struct i40e_pf *pf)
+{
+	struct net_device *netdev;
+	struct i40e_vsi *vsi;
+	int i;
+
+	/* Only for LAN VSI */
+	vsi = pf->vsi[pf->lan_vsi];
+
+	if (!vsi)
+		return;
+
+	/* Make sure, VSI state is not DOWN/RECOVERY_PENDING */
+	if (test_bit(__I40E_DOWN, &vsi->back->state) ||
+	    test_bit(__I40E_RESET_RECOVERY_PENDING, &vsi->back->state))
+		return;
+
+	/* Make sure type is MAIN VSI */
+	if (vsi->type != I40E_VSI_MAIN)
+		return;
+
+	netdev = vsi->netdev;
+	if (!netdev)
+		return;
+
+	/* Bail out if netif_carrier is not OK */
+	if (!netif_carrier_ok(netdev))
+		return;
+
+	/* Go thru' TX queues for netdev */
+	for (i = 0; i < netdev->num_tx_queues; i++) {
+		struct netdev_queue *q;
+
+		q = netdev_get_tx_queue(netdev, i);
+		if (q)
+			i40e_detect_recover_hung_queue(i, vsi);
+	}
+}
+
 /**
  * i40e_get_iscsi_tc_map - Return TC map for iSCSI APP
  * @pf: pointer to PF
@@ -5759,68 +5872,6 @@ static void i40e_link_event(struct i40e_pf *pf)
 }
 
 /**
- * i40e_check_hang_subtask - Check for hung queues and dropped interrupts
- * @pf: board private structure
- *
- * Set the per-queue flags to request a check for stuck queues in the irq
- * clean functions, then force interrupts to be sure the irq clean is called.
- **/
-static void i40e_check_hang_subtask(struct i40e_pf *pf)
-{
-	int i, v;
-
-	/* If we're down or resetting, just bail */
-	if (test_bit(__I40E_DOWN, &pf->state) ||
-	    test_bit(__I40E_CONFIG_BUSY, &pf->state))
-		return;
-
-	/* for each VSI/netdev
-	 *     for each Tx queue
-	 *         set the check flag
-	 *     for each q_vector
-	 *         force an interrupt
-	 */
-	for (v = 0; v < pf->num_alloc_vsi; v++) {
-		struct i40e_vsi *vsi = pf->vsi[v];
-		int armed = 0;
-
-		if (!pf->vsi[v] ||
-		    test_bit(__I40E_DOWN, &vsi->state) ||
-		    (vsi->netdev && !netif_carrier_ok(vsi->netdev)))
-			continue;
-
-		for (i = 0; i < vsi->num_queue_pairs; i++) {
-			set_check_for_tx_hang(vsi->tx_rings[i]);
-			if (test_bit(__I40E_HANG_CHECK_ARMED,
-				     &vsi->tx_rings[i]->state))
-				armed++;
-		}
-
-		if (armed) {
-			if (!(pf->flags & I40E_FLAG_MSIX_ENABLED)) {
-				wr32(&vsi->back->hw, I40E_PFINT_DYN_CTL0,
-				     (I40E_PFINT_DYN_CTL0_INTENA_MASK |
-				      I40E_PFINT_DYN_CTL0_SWINT_TRIG_MASK |
-				      I40E_PFINT_DYN_CTL0_ITR_INDX_MASK |
-				      I40E_PFINT_DYN_CTL0_SW_ITR_INDX_ENA_MASK |
-				      I40E_PFINT_DYN_CTL0_SW_ITR_INDX_MASK));
-			} else {
-				u16 vec = vsi->base_vector - 1;
-				u32 val = (I40E_PFINT_DYN_CTLN_INTENA_MASK |
-				      I40E_PFINT_DYN_CTLN_SWINT_TRIG_MASK |
-				      I40E_PFINT_DYN_CTLN_ITR_INDX_MASK |
-				      I40E_PFINT_DYN_CTLN_SW_ITR_INDX_ENA_MASK |
-				      I40E_PFINT_DYN_CTLN_SW_ITR_INDX_MASK);
-				for (i = 0; i < vsi->num_q_vectors; i++, vec++)
-					wr32(&vsi->back->hw,
-					     I40E_PFINT_DYN_CTLN(vec), val);
-			}
-			i40e_flush(&vsi->back->hw);
-		}
-	}
-}
-
-/**
  * i40e_watchdog_subtask - periodic checks not using event driven response
  * @pf: board private structure
  **/
@@ -5839,7 +5890,6 @@ static void i40e_watchdog_subtask(struct i40e_pf *pf)
 		return;
 	pf->service_timer_previous = jiffies;
 
-	i40e_check_hang_subtask(pf);
 	i40e_link_event(pf);
 
 	/* Update the stats for active netdevs so the network stack
@@ -6807,6 +6857,7 @@ static void i40e_service_task(struct work_struct *work)
 		return;
 	}
 
+	i40e_detect_recover_hung(pf);
 	i40e_reset_subtask(pf);
 	i40e_handle_mdd_event(pf);
 	i40e_vc_process_vflr_event(pf);
@@ -10101,7 +10152,6 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	INIT_WORK(&pf->service_task, i40e_service_task);
 	clear_bit(__I40E_SERVICE_SCHED, &pf->state);
 	pf->flags |= I40E_FLAG_NEED_LINK_UPDATE;
-	pf->link_check_timeout = jiffies;
 
 	/* WoL defaults to disabled */
 	pf->wol_en = false;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 9a800f9..4f9ff89 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -600,7 +600,6 @@ void i40e_free_tx_resources(struct i40e_ring *tx_ring)
 	}
 }
 
-
 /**
  * i40e_get_tx_pending - how many tx descriptors not processed
  * @tx_ring: the ring of descriptors
@@ -608,7 +607,7 @@ void i40e_free_tx_resources(struct i40e_ring *tx_ring)
  * Since there is no access to the ring head register
  * in XL710, we need to use our local copies
  **/
-static u32 i40e_get_tx_pending(struct i40e_ring *ring)
+u32 i40e_get_tx_pending(struct i40e_ring *ring)
 {
 	u32 head, tail;
 
@@ -622,50 +621,6 @@ static u32 i40e_get_tx_pending(struct i40e_ring *ring)
 	return 0;
 }
 
-/**
- * i40e_check_tx_hang - Is there a hang in the Tx queue
- * @tx_ring: the ring of descriptors
- **/
-static bool i40e_check_tx_hang(struct i40e_ring *tx_ring)
-{
-	u32 tx_done = tx_ring->stats.packets;
-	u32 tx_done_old = tx_ring->tx_stats.tx_done_old;
-	u32 tx_pending = i40e_get_tx_pending(tx_ring);
-	struct i40e_pf *pf = tx_ring->vsi->back;
-	bool ret = false;
-
-	clear_check_for_tx_hang(tx_ring);
-
-	/* Check for a hung queue, but be thorough. This verifies
-	 * that a transmit has been completed since the previous
-	 * check AND there is at least one packet pending. The
-	 * ARMED bit is set to indicate a potential hang. The
-	 * bit is cleared if a pause frame is received to remove
-	 * false hang detection due to PFC or 802.3x frames. By
-	 * requiring this to fail twice we avoid races with
-	 * PFC clearing the ARMED bit and conditions where we
-	 * run the check_tx_hang logic with a transmit completion
-	 * pending but without time to complete it yet.
-	 */
-	if ((tx_done_old == tx_done) && tx_pending) {
-		/* make sure it is true for two checks in a row */
-		ret = test_and_set_bit(__I40E_HANG_CHECK_ARMED,
-				       &tx_ring->state);
-	} else if (tx_done_old == tx_done &&
-		   (tx_pending < I40E_MIN_DESC_PENDING) && (tx_pending > 0)) {
-		if (I40E_DEBUG_FLOW & pf->hw.debug_mask)
-			dev_info(tx_ring->dev, "HW needs some more descs to do a cacheline flush. tx_pending %d, queue %d",
-				 tx_pending, tx_ring->queue_index);
-		pf->tx_sluggish_count++;
-	} else {
-		/* update completed stats and disarm the hang check */
-		tx_ring->tx_stats.tx_done_old = tx_done;
-		clear_bit(__I40E_HANG_CHECK_ARMED, &tx_ring->state);
-	}
-
-	return ret;
-}
-
 #define WB_STRIDE 0x3
 
 /**
@@ -783,32 +738,6 @@ static bool i40e_clean_tx_irq(struct i40e_ring *tx_ring, int budget)
 	else
 		tx_ring->arm_wb = false;
 
-	if (check_for_tx_hang(tx_ring) && i40e_check_tx_hang(tx_ring)) {
-		/* schedule immediate reset if we believe we hung */
-		dev_info(tx_ring->dev, "Detected Tx Unit Hang\n"
-			 "  VSI                  <%d>\n"
-			 "  Tx Queue             <%d>\n"
-			 "  next_to_use          <%x>\n"
-			 "  next_to_clean        <%x>\n",
-			 tx_ring->vsi->seid,
-			 tx_ring->queue_index,
-			 tx_ring->next_to_use, i);
-
-		netif_stop_subqueue(tx_ring->netdev, tx_ring->queue_index);
-
-		dev_info(tx_ring->dev,
-			 "tx hang detected on queue %d, reset requested\n",
-			 tx_ring->queue_index);
-
-		/* do not fire the reset immediately, wait for the stack to
-		 * decide we are truly stuck, also prevents every queue from
-		 * simultaneously requesting a reset
-		 */
-
-		/* the adapter is about to reset, no point in enabling polling */
-		budget = 1;
-	}
-
 	netdev_tx_completed_queue(netdev_get_tx_queue(tx_ring->netdev,
 						      tx_ring->queue_index),
 				  total_packets, total_bytes);
@@ -838,7 +767,7 @@ static bool i40e_clean_tx_irq(struct i40e_ring *tx_ring, int budget)
  * @q_vector: the vector  on which to force writeback
  *
  **/
-static void i40e_force_wb(struct i40e_vsi *vsi, struct i40e_q_vector *q_vector)
+void i40e_force_wb(struct i40e_vsi *vsi, struct i40e_q_vector *q_vector)
 {
 	u16 flags = q_vector->tx.ring[0].flags;
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index 51487ef..977cb5b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -199,8 +199,6 @@ struct i40e_rx_queue_stats {
 enum i40e_ring_state_t {
 	__I40E_TX_FDIR_INIT_DONE,
 	__I40E_TX_XPS_INIT_DONE,
-	__I40E_TX_DETECT_HANG,
-	__I40E_HANG_CHECK_ARMED,
 	__I40E_RX_PS_ENABLED,
 	__I40E_RX_16BYTE_DESC_ENABLED,
 };
@@ -211,12 +209,6 @@ enum i40e_ring_state_t {
 	set_bit(__I40E_RX_PS_ENABLED, &(ring)->state)
 #define clear_ring_ps_enabled(ring) \
 	clear_bit(__I40E_RX_PS_ENABLED, &(ring)->state)
-#define check_for_tx_hang(ring) \
-	test_bit(__I40E_TX_DETECT_HANG, &(ring)->state)
-#define set_check_for_tx_hang(ring) \
-	set_bit(__I40E_TX_DETECT_HANG, &(ring)->state)
-#define clear_check_for_tx_hang(ring) \
-	clear_bit(__I40E_TX_DETECT_HANG, &(ring)->state)
 #define ring_is_16byte_desc_enabled(ring) \
 	test_bit(__I40E_RX_16BYTE_DESC_ENABLED, &(ring)->state)
 #define set_ring_16byte_desc_enabled(ring) \
@@ -326,6 +318,8 @@ int i40e_xmit_descriptor_count(struct sk_buff *skb, struct i40e_ring *tx_ring);
 int i40e_tx_prepare_vlan_flags(struct sk_buff *skb,
 			       struct i40e_ring *tx_ring, u32 *flags);
 #endif
+void i40e_force_wb(struct i40e_vsi *vsi, struct i40e_q_vector *q_vector);
+u32 i40e_get_tx_pending(struct i40e_ring *ring);
 
 /**
  * i40e_get_head - Retrieve head from head writeback
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 7e91d82..8309793 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -140,65 +140,6 @@ static inline u32 i40e_get_head(struct i40e_ring *tx_ring)
 	return le32_to_cpu(*(volatile __le32 *)head);
 }
 
-/**
- * i40e_get_tx_pending - how many tx descriptors not processed
- * @tx_ring: the ring of descriptors
- *
- * Since there is no access to the ring head register
- * in XL710, we need to use our local copies
- **/
-static u32 i40e_get_tx_pending(struct i40e_ring *ring)
-{
-	u32 head, tail;
-
-	head = i40e_get_head(ring);
-	tail = readl(ring->tail);
-
-	if (head != tail)
-		return (head < tail) ?
-			tail - head : (tail + ring->count - head);
-
-	return 0;
-}
-
-/**
- * i40e_check_tx_hang - Is there a hang in the Tx queue
- * @tx_ring: the ring of descriptors
- **/
-static bool i40e_check_tx_hang(struct i40e_ring *tx_ring)
-{
-	u32 tx_done = tx_ring->stats.packets;
-	u32 tx_done_old = tx_ring->tx_stats.tx_done_old;
-	u32 tx_pending = i40e_get_tx_pending(tx_ring);
-	bool ret = false;
-
-	clear_check_for_tx_hang(tx_ring);
-
-	/* Check for a hung queue, but be thorough. This verifies
-	 * that a transmit has been completed since the previous
-	 * check AND there is at least one packet pending. The
-	 * ARMED bit is set to indicate a potential hang. The
-	 * bit is cleared if a pause frame is received to remove
-	 * false hang detection due to PFC or 802.3x frames. By
-	 * requiring this to fail twice we avoid races with
-	 * PFC clearing the ARMED bit and conditions where we
-	 * run the check_tx_hang logic with a transmit completion
-	 * pending but without time to complete it yet.
-	 */
-	if ((tx_done_old == tx_done) && tx_pending) {
-		/* make sure it is true for two checks in a row */
-		ret = test_and_set_bit(__I40E_HANG_CHECK_ARMED,
-				       &tx_ring->state);
-	} else if (tx_done_old == tx_done &&
-		   (tx_pending < I40E_MIN_DESC_PENDING) && (tx_pending > 0)) {
-		/* update completed stats and disarm the hang check */
-		tx_ring->tx_stats.tx_done_old = tx_done;
-		clear_bit(__I40E_HANG_CHECK_ARMED, &tx_ring->state);
-	}
-
-	return ret;
-}
-
 #define WB_STRIDE 0x3
 
 /**
@@ -304,6 +245,10 @@ static bool i40e_clean_tx_irq(struct i40e_ring *tx_ring, int budget)
 	tx_ring->q_vector->tx.total_bytes += total_bytes;
 	tx_ring->q_vector->tx.total_packets += total_packets;
 
+	/* check to see if there are any non-cache aligned descriptors
+	 * waiting to be written back, and kick the hardware to force
+	 * them to be written back in case of napi polling
+	 */
 	if (budget &&
 	    !((i & WB_STRIDE) == WB_STRIDE) &&
 	    !test_bit(__I40E_DOWN, &tx_ring->vsi->state) &&
@@ -312,29 +257,6 @@ static bool i40e_clean_tx_irq(struct i40e_ring *tx_ring, int budget)
 	else
 		tx_ring->arm_wb = false;
 
-	if (check_for_tx_hang(tx_ring) && i40e_check_tx_hang(tx_ring)) {
-		/* schedule immediate reset if we believe we hung */
-		dev_info(tx_ring->dev, "Detected Tx Unit Hang\n"
-			 "  VSI                  <%d>\n"
-			 "  Tx Queue             <%d>\n"
-			 "  next_to_use          <%x>\n"
-			 "  next_to_clean        <%x>\n",
-			 tx_ring->vsi->seid,
-			 tx_ring->queue_index,
-			 tx_ring->next_to_use, i);
-
-		netif_stop_subqueue(tx_ring->netdev, tx_ring->queue_index);
-
-		dev_info(tx_ring->dev,
-			 "tx hang detected on queue %d, resetting adapter\n",
-			 tx_ring->queue_index);
-
-		tx_ring->netdev->netdev_ops->ndo_tx_timeout(tx_ring->netdev);
-
-		/* the adapter is about to reset, no point in enabling stuff */
-		return true;
-	}
-
 	netdev_tx_completed_queue(netdev_get_tx_queue(tx_ring->netdev,
 						      tx_ring->queue_index),
 				  total_packets, total_bytes);
@@ -355,16 +277,16 @@ static bool i40e_clean_tx_irq(struct i40e_ring *tx_ring, int budget)
 		}
 	}
 
-	return budget > 0;
+	return !!budget;
 }
 
 /**
- * i40e_force_wb -Arm hardware to do a wb on noncache aligned descriptors
+ * i40evf_force_wb -Arm hardware to do a wb on noncache aligned descriptors
  * @vsi: the VSI we care about
  * @q_vector: the vector  on which to force writeback
  *
  **/
-static void i40e_force_wb(struct i40e_vsi *vsi, struct i40e_q_vector *q_vector)
+static void i40evf_force_wb(struct i40e_vsi *vsi, struct i40e_q_vector *q_vector)
 {
 	u16 flags = q_vector->tx.ring[0].flags;
 
@@ -1385,7 +1307,7 @@ int i40evf_napi_poll(struct napi_struct *napi, int budget)
 	/* If work not completed, return budget and polling will return */
 	if (!clean_complete) {
 		if (arm_wb)
-			i40e_force_wb(vsi, q_vector);
+			i40evf_force_wb(vsi, q_vector);
 		return budget;
 	}
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
index 9a30f5d..d5cb7ac 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
@@ -198,8 +198,6 @@ struct i40e_rx_queue_stats {
 enum i40e_ring_state_t {
 	__I40E_TX_FDIR_INIT_DONE,
 	__I40E_TX_XPS_INIT_DONE,
-	__I40E_TX_DETECT_HANG,
-	__I40E_HANG_CHECK_ARMED,
 	__I40E_RX_PS_ENABLED,
 	__I40E_RX_16BYTE_DESC_ENABLED,
 };
@@ -210,12 +208,6 @@ enum i40e_ring_state_t {
 	set_bit(__I40E_RX_PS_ENABLED, &(ring)->state)
 #define clear_ring_ps_enabled(ring) \
 	clear_bit(__I40E_RX_PS_ENABLED, &(ring)->state)
-#define check_for_tx_hang(ring) \
-	test_bit(__I40E_TX_DETECT_HANG, &(ring)->state)
-#define set_check_for_tx_hang(ring) \
-	set_bit(__I40E_TX_DETECT_HANG, &(ring)->state)
-#define clear_check_for_tx_hang(ring) \
-	clear_bit(__I40E_TX_DETECT_HANG, &(ring)->state)
 #define ring_is_16byte_desc_enabled(ring) \
 	test_bit(__I40E_RX_16BYTE_DESC_ENABLED, &(ring)->state)
 #define set_ring_16byte_desc_enabled(ring) \
-- 
2.4.3
