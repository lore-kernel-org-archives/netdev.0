From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 07/13] ixgbe: Merge watchdog functionality into service task
Date: Sat, 14 May 2011 18:23:41 -0700
Message-ID: <1305422627-9583-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1305422627-9583-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:52581 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759520Ab1EOBXw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 May 2011 21:23:52 -0400
In-Reply-To: <1305422627-9583-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch is meant to merge the functionality of the ixgbe watchdog task
into the service task.  By doing this all link state functionality will be
controlled by a single task.  As a result the reliability of the interface
will be improved as the likelihood of any race conditions is further
reduced.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe.h      |    2 -
 drivers/net/ixgbe/ixgbe_main.c |  364 ++++++++++++++++++++++------------------
 2 files changed, 200 insertions(+), 166 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index cbb04ba..193c6c4 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -455,11 +455,9 @@ struct ixgbe_adapter {
 	unsigned long link_check_timeout;
 
 	struct work_struct reset_task;
-	struct work_struct watchdog_task;
 	struct work_struct fdir_reinit_task;
 	struct work_struct check_overtemp_task;
 	struct work_struct service_task;
-	struct timer_list watchdog_timer;
 	struct timer_list service_timer;
 	u32 fdir_pballoc;
 	u32 atr_sample_rate;
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index a5d4226..d1e52b5 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1900,7 +1900,7 @@ static void ixgbe_check_lsc(struct ixgbe_adapter *adapter)
 	if (!test_bit(__IXGBE_DOWN, &adapter->state)) {
 		IXGBE_WRITE_REG(hw, IXGBE_EIMC, IXGBE_EIMC_LSC);
 		IXGBE_WRITE_FLUSH(hw);
-		schedule_work(&adapter->watchdog_task);
+		ixgbe_service_event_schedule(adapter);
 	}
 }
 
@@ -3940,7 +3940,6 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 	 * link up interrupt but shouldn't be a problem */
 	adapter->flags |= IXGBE_FLAG_NEED_LINK_UPDATE;
 	adapter->link_check_timeout = jiffies;
-	mod_timer(&adapter->watchdog_timer, jiffies);
 	mod_timer(&adapter->service_timer, jiffies);
 
 	/* Set PF Reset Done bit so PF/VF Mail Ops can work */
@@ -4179,8 +4178,6 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 
 	netif_tx_stop_all_queues(netdev);
 
-	del_timer_sync(&adapter->watchdog_timer);
-	cancel_work_sync(&adapter->watchdog_task);
 	/* call carrier off first to avoid false dev_watchdog timeouts */
 	netif_carrier_off(netdev);
 	netif_tx_disable(netdev);
@@ -5957,23 +5954,54 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 }
 
 /**
- * ixgbe_watchdog - Timer Call-back
- * @data: pointer to adapter cast into an unsigned long
+ * ixgbe_fdir_reinit_task - worker thread to reinit FDIR filter table
+ * @work: pointer to work_struct containing our data
  **/
-static void ixgbe_watchdog(unsigned long data)
+static void ixgbe_fdir_reinit_task(struct work_struct *work)
+{
+	struct ixgbe_adapter *adapter = container_of(work,
+						     struct ixgbe_adapter,
+						     fdir_reinit_task);
+	struct ixgbe_hw *hw = &adapter->hw;
+	int i;
+
+	if (ixgbe_reinit_fdir_tables_82599(hw) == 0) {
+		for (i = 0; i < adapter->num_tx_queues; i++)
+			set_bit(__IXGBE_TX_FDIR_INIT_DONE,
+				&(adapter->tx_ring[i]->state));
+	} else {
+		e_err(probe, "failed to finish FDIR re-initialization, "
+		      "ignored adding FDIR ATR filters\n");
+	}
+	/* Done FDIR Re-initialization, enable transmits */
+	netif_tx_start_all_queues(adapter->netdev);
+}
+
+/**
+ * ixgbe_check_hang_subtask - check for hung queues and dropped interrupts
+ * @adapter - pointer to the device adapter structure
+ *
+ * This function serves two purposes.  First it strobes the interrupt lines
+ * in order to make certain interrupts are occuring.  Secondly it sets the
+ * bits needed to check for TX hangs.  As a result we should immediately
+ * determine if a hang has occured.
+ */
+static void ixgbe_check_hang_subtask(struct ixgbe_adapter *adapter)
 {
-	struct ixgbe_adapter *adapter = (struct ixgbe_adapter *)data;
 	struct ixgbe_hw *hw = &adapter->hw;
 	u64 eics = 0;
 	int i;
 
-	/*
-	 *  Do the watchdog outside of interrupt context due to the lovely
-	 * delays that some of the newer hardware requires
-	 */
+	/* If we're down or resetting, just bail */
+	if (test_bit(__IXGBE_DOWN, &adapter->state) ||
+	    test_bit(__IXGBE_RESETTING, &adapter->state))
+		return;
 
-	if (test_bit(__IXGBE_DOWN, &adapter->state))
-		goto watchdog_short_circuit;
+	/* Force detection of hung controller */
+	if (netif_carrier_ok(adapter->netdev)) {
+		for (i = 0; i < adapter->num_tx_queues; i++)
+			set_check_for_tx_hang(adapter->tx_ring[i]);
+	}
 
 	if (!(adapter->flags & IXGBE_FLAG_MSIX_ENABLED)) {
 		/*
@@ -5983,179 +6011,157 @@ static void ixgbe_watchdog(unsigned long data)
 		 */
 		IXGBE_WRITE_REG(hw, IXGBE_EICS,
 			(IXGBE_EICS_TCP_TIMER | IXGBE_EICS_OTHER));
-		goto watchdog_reschedule;
-	}
-
-	/* get one bit for every active tx/rx interrupt vector */
-	for (i = 0; i < adapter->num_msix_vectors - NON_Q_VECTORS; i++) {
-		struct ixgbe_q_vector *qv = adapter->q_vector[i];
-		if (qv->rxr_count || qv->txr_count)
-			eics |= ((u64)1 << i);
+	} else {
+		/* get one bit for every active tx/rx interrupt vector */
+		for (i = 0; i < adapter->num_msix_vectors - NON_Q_VECTORS; i++) {
+			struct ixgbe_q_vector *qv = adapter->q_vector[i];
+			if (qv->rxr_count || qv->txr_count)
+				eics |= ((u64)1 << i);
+		}
 	}
 
-	/* Cause software interrupt to ensure rx rings are cleaned */
+	/* Cause software interrupt to ensure rings are cleaned */
 	ixgbe_irq_rearm_queues(adapter, eics);
 
-watchdog_reschedule:
-	/* Reset the timer */
-	mod_timer(&adapter->watchdog_timer, round_jiffies(jiffies + 2 * HZ));
-
-watchdog_short_circuit:
-	schedule_work(&adapter->watchdog_task);
 }
 
 /**
- * ixgbe_fdir_reinit_task - worker thread to reinit FDIR filter table
- * @work: pointer to work_struct containing our data
+ * ixgbe_watchdog_update_link - update the link status
+ * @adapter - pointer to the device adapter structure
+ * @link_speed - pointer to a u32 to store the link_speed
  **/
-static void ixgbe_fdir_reinit_task(struct work_struct *work)
+static void ixgbe_watchdog_update_link(struct ixgbe_adapter *adapter)
 {
-	struct ixgbe_adapter *adapter = container_of(work,
-						     struct ixgbe_adapter,
-						     fdir_reinit_task);
 	struct ixgbe_hw *hw = &adapter->hw;
+	u32 link_speed = adapter->link_speed;
+	bool link_up = adapter->link_up;
 	int i;
 
-	if (ixgbe_reinit_fdir_tables_82599(hw) == 0) {
-		for (i = 0; i < adapter->num_tx_queues; i++)
-			set_bit(__IXGBE_TX_FDIR_INIT_DONE,
-				&(adapter->tx_ring[i]->state));
+	if (!(adapter->flags & IXGBE_FLAG_NEED_LINK_UPDATE))
+		return;
+
+	if (hw->mac.ops.check_link) {
+		hw->mac.ops.check_link(hw, &link_speed, &link_up, false);
 	} else {
-		e_err(probe, "failed to finish FDIR re-initialization, "
-		      "ignored adding FDIR ATR filters\n");
+		/* always assume link is up, if no check link function */
+		link_speed = IXGBE_LINK_SPEED_10GB_FULL;
+		link_up = true;
 	}
-	/* Done FDIR Re-initialization, enable transmits */
-	netif_tx_start_all_queues(adapter->netdev);
+	if (link_up) {
+		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
+			for (i = 0; i < MAX_TRAFFIC_CLASS; i++)
+				hw->mac.ops.fc_enable(hw, i);
+		} else {
+			hw->mac.ops.fc_enable(hw, 0);
+		}
+	}
+
+	if (link_up ||
+	    time_after(jiffies, (adapter->link_check_timeout +
+				 IXGBE_TRY_LINK_TIMEOUT))) {
+		adapter->flags &= ~IXGBE_FLAG_NEED_LINK_UPDATE;
+		IXGBE_WRITE_REG(hw, IXGBE_EIMS, IXGBE_EIMC_LSC);
+		IXGBE_WRITE_FLUSH(hw);
+	}
+
+	adapter->link_up = link_up;
+	adapter->link_speed = link_speed;
 }
 
-static void ixgbe_spoof_check(struct ixgbe_adapter *adapter)
+/**
+ * ixgbe_watchdog_link_is_up - update netif_carrier status and
+ *                             print link up message
+ * @adapter - pointer to the device adapter structure
+ **/
+static void ixgbe_watchdog_link_is_up(struct ixgbe_adapter *adapter)
 {
-	u32 ssvpc;
+	struct net_device *netdev = adapter->netdev;
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 link_speed = adapter->link_speed;
+	bool flow_rx, flow_tx;
 
-	/* Do not perform spoof check for 82598 */
-	if (adapter->hw.mac.type == ixgbe_mac_82598EB)
+	/* only continue if link was previously down */
+	if (netif_carrier_ok(netdev))
 		return;
 
-	ssvpc = IXGBE_READ_REG(&adapter->hw, IXGBE_SSVPC);
+	adapter->flags2 &= ~IXGBE_FLAG2_SEARCH_FOR_SFP;
 
-	/*
-	 * ssvpc register is cleared on read, if zero then no
-	 * spoofed packets in the last interval.
-	 */
-	if (!ssvpc)
-		return;
+	switch (hw->mac.type) {
+	case ixgbe_mac_82598EB: {
+		u32 frctl = IXGBE_READ_REG(hw, IXGBE_FCTRL);
+		u32 rmcs = IXGBE_READ_REG(hw, IXGBE_RMCS);
+		flow_rx = !!(frctl & IXGBE_FCTRL_RFCE);
+		flow_tx = !!(rmcs & IXGBE_RMCS_TFCE_802_3X);
+	}
+		break;
+	case ixgbe_mac_X540:
+	case ixgbe_mac_82599EB: {
+		u32 mflcn = IXGBE_READ_REG(hw, IXGBE_MFLCN);
+		u32 fccfg = IXGBE_READ_REG(hw, IXGBE_FCCFG);
+		flow_rx = !!(mflcn & IXGBE_MFLCN_RFCE);
+		flow_tx = !!(fccfg & IXGBE_FCCFG_TFCE_802_3X);
+	}
+		break;
+	default:
+		flow_tx = false;
+		flow_rx = false;
+		break;
+	}
+	e_info(drv, "NIC Link is Up %s, Flow Control: %s\n",
+	       (link_speed == IXGBE_LINK_SPEED_10GB_FULL ?
+	       "10 Gbps" :
+	       (link_speed == IXGBE_LINK_SPEED_1GB_FULL ?
+	       "1 Gbps" :
+	       (link_speed == IXGBE_LINK_SPEED_100_FULL ?
+	       "100 Mbps" :
+	       "unknown speed"))),
+	       ((flow_rx && flow_tx) ? "RX/TX" :
+	       (flow_rx ? "RX" :
+	       (flow_tx ? "TX" : "None"))));
 
-	e_warn(drv, "%d Spoofed packets detected\n", ssvpc);
+	netif_carrier_on(netdev);
+#ifdef HAVE_IPLINK_VF_CONFIG
+	ixgbe_check_vf_rate_limit(adapter);
+#endif /* HAVE_IPLINK_VF_CONFIG */
 }
 
-static DEFINE_MUTEX(ixgbe_watchdog_lock);
-
 /**
- * ixgbe_watchdog_task - worker thread to bring link up
- * @work: pointer to work_struct containing our data
+ * ixgbe_watchdog_link_is_down - update netif_carrier status and
+ *                               print link down message
+ * @adapter - pointer to the adapter structure
  **/
-static void ixgbe_watchdog_task(struct work_struct *work)
+static void ixgbe_watchdog_link_is_down(struct ixgbe_adapter* adapter)
 {
-	struct ixgbe_adapter *adapter = container_of(work,
-						     struct ixgbe_adapter,
-						     watchdog_task);
 	struct net_device *netdev = adapter->netdev;
 	struct ixgbe_hw *hw = &adapter->hw;
-	u32 link_speed;
-	bool link_up;
-	int i;
-	struct ixgbe_ring *tx_ring;
-	int some_tx_pending = 0;
-
-	mutex_lock(&ixgbe_watchdog_lock);
 
-	link_up = adapter->link_up;
-	link_speed = adapter->link_speed;
+	adapter->link_up = false;
+	adapter->link_speed = 0;
 
-	if (adapter->flags & IXGBE_FLAG_NEED_LINK_UPDATE) {
-		hw->mac.ops.check_link(hw, &link_speed, &link_up, false);
-		if (link_up) {
-#ifdef CONFIG_DCB
-			if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
-				for (i = 0; i < MAX_TRAFFIC_CLASS; i++)
-					hw->mac.ops.fc_enable(hw, i);
-			} else {
-				hw->mac.ops.fc_enable(hw, 0);
-			}
-#else
-			hw->mac.ops.fc_enable(hw, 0);
-#endif
-		}
+	/* only continue if link was up previously */
+	if (!netif_carrier_ok(netdev))
+		return;
 
-		if (link_up ||
-		    time_after(jiffies, (adapter->link_check_timeout +
-					 IXGBE_TRY_LINK_TIMEOUT))) {
-			adapter->flags &= ~IXGBE_FLAG_NEED_LINK_UPDATE;
-			IXGBE_WRITE_REG(hw, IXGBE_EIMS, IXGBE_EIMC_LSC);
-		}
-		adapter->link_up = link_up;
-		adapter->link_speed = link_speed;
-	}
+	/* poll for SFP+ cable when link is down */
+	if (ixgbe_is_sfp(hw) && hw->mac.type == ixgbe_mac_82598EB)
+		adapter->flags2 |= IXGBE_FLAG2_SEARCH_FOR_SFP;
 
-	if (link_up) {
-		if (!netif_carrier_ok(netdev)) {
-			bool flow_rx, flow_tx;
-
-			switch (hw->mac.type) {
-			case ixgbe_mac_82598EB: {
-				u32 frctl = IXGBE_READ_REG(hw, IXGBE_FCTRL);
-				u32 rmcs = IXGBE_READ_REG(hw, IXGBE_RMCS);
-				flow_rx = !!(frctl & IXGBE_FCTRL_RFCE);
-				flow_tx = !!(rmcs & IXGBE_RMCS_TFCE_802_3X);
-			}
-				break;
-			case ixgbe_mac_82599EB:
-			case ixgbe_mac_X540: {
-				u32 mflcn = IXGBE_READ_REG(hw, IXGBE_MFLCN);
-				u32 fccfg = IXGBE_READ_REG(hw, IXGBE_FCCFG);
-				flow_rx = !!(mflcn & IXGBE_MFLCN_RFCE);
-				flow_tx = !!(fccfg & IXGBE_FCCFG_TFCE_802_3X);
-			}
-				break;
-			default:
-				flow_tx = false;
-				flow_rx = false;
-				break;
-			}
+	e_info(drv, "NIC Link is Down\n");
+	netif_carrier_off(netdev);
+}
 
-			e_info(drv, "NIC Link is Up %s, Flow Control: %s\n",
-			       (link_speed == IXGBE_LINK_SPEED_10GB_FULL ?
-			       "10 Gbps" :
-			       (link_speed == IXGBE_LINK_SPEED_1GB_FULL ?
-			       "1 Gbps" :
-			       (link_speed == IXGBE_LINK_SPEED_100_FULL ?
-			       "100 Mbps" :
-			       "unknown speed"))),
-			       ((flow_rx && flow_tx) ? "RX/TX" :
-			       (flow_rx ? "RX" :
-			       (flow_tx ? "TX" : "None"))));
-
-			netif_carrier_on(netdev);
-			ixgbe_check_vf_rate_limit(adapter);
-		} else {
-			/* Force detection of hung controller */
-			for (i = 0; i < adapter->num_tx_queues; i++) {
-				tx_ring = adapter->tx_ring[i];
-				set_check_for_tx_hang(tx_ring);
-			}
-		}
-	} else {
-		adapter->link_up = false;
-		adapter->link_speed = 0;
-		if (netif_carrier_ok(netdev)) {
-			e_info(drv, "NIC Link is Down\n");
-			netif_carrier_off(netdev);
-		}
-	}
+/**
+ * ixgbe_watchdog_flush_tx - flush queues on link down
+ * @adapter - pointer to the device adapter structure
+ **/
+static void ixgbe_watchdog_flush_tx(struct ixgbe_adapter *adapter)
+{
+	int i;
+	int some_tx_pending = 0;
 
-	if (!netif_carrier_ok(netdev)) {
+	if (!netif_carrier_ok(adapter->netdev)) {
 		for (i = 0; i < adapter->num_tx_queues; i++) {
-			tx_ring = adapter->tx_ring[i];
+			struct ixgbe_ring *tx_ring = adapter->tx_ring[i];
 			if (tx_ring->next_to_use != tx_ring->next_to_clean) {
 				some_tx_pending = 1;
 				break;
@@ -6168,13 +6174,52 @@ static void ixgbe_watchdog_task(struct work_struct *work)
 			 * to get done, so reset controller to flush Tx.
 			 * (Do the reset outside of interrupt context).
 			 */
-			 schedule_work(&adapter->reset_task);
+			schedule_work(&adapter->reset_task);
 		}
 	}
+}
+
+static void ixgbe_spoof_check(struct ixgbe_adapter *adapter)
+{
+	u32 ssvpc;
+
+	/* Do not perform spoof check for 82598 */
+	if (adapter->hw.mac.type == ixgbe_mac_82598EB)
+		return;
+
+	ssvpc = IXGBE_READ_REG(&adapter->hw, IXGBE_SSVPC);
+
+	/*
+	 * ssvpc register is cleared on read, if zero then no
+	 * spoofed packets in the last interval.
+	 */
+	if (!ssvpc)
+		return;
+
+	e_warn(drv, "%d Spoofed packets detected\n", ssvpc);
+}
+
+/**
+ * ixgbe_watchdog_subtask - check and bring link up
+ * @adapter - pointer to the device adapter structure
+ **/
+static void ixgbe_watchdog_subtask(struct ixgbe_adapter *adapter)
+{
+	/* if interface is down do nothing */
+	if (test_bit(__IXGBE_DOWN, &adapter->state))
+		return;
+
+	ixgbe_watchdog_update_link(adapter);
+
+	if (adapter->link_up)
+		ixgbe_watchdog_link_is_up(adapter);
+	else
+		ixgbe_watchdog_link_is_down(adapter);
 
 	ixgbe_spoof_check(adapter);
 	ixgbe_update_stats(adapter);
-	mutex_unlock(&ixgbe_watchdog_lock);
+
+	ixgbe_watchdog_flush_tx(adapter);
 }
 
 /**
@@ -6308,6 +6353,8 @@ static void ixgbe_service_task(struct work_struct *work)
 
 	ixgbe_sfp_detection_subtask(adapter);
 	ixgbe_sfp_link_config_subtask(adapter);
+	ixgbe_watchdog_subtask(adapter);
+	ixgbe_check_hang_subtask(adapter);
 
 	ixgbe_service_event_complete(adapter);
 }
@@ -7485,12 +7532,8 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 
 	setup_timer(&adapter->service_timer, &ixgbe_service_timer,
 	            (unsigned long) adapter);
-	init_timer(&adapter->watchdog_timer);
-	adapter->watchdog_timer.function = ixgbe_watchdog;
-	adapter->watchdog_timer.data = (unsigned long)adapter;
 
 	INIT_WORK(&adapter->reset_task, ixgbe_reset_task);
-	INIT_WORK(&adapter->watchdog_task, ixgbe_watchdog_task);
 
 	INIT_WORK(&adapter->service_task, ixgbe_service_task);
 	clear_bit(__IXGBE_SERVICE_SCHED, &adapter->state);
@@ -7643,13 +7686,6 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
 	set_bit(__IXGBE_DOWN, &adapter->state);
 	cancel_work_sync(&adapter->service_task);
 
-	/*
-	 * The timers may be rescheduled, so explicitly disable them
-	 * from being rescheduled.
-	 */
-	del_timer_sync(&adapter->watchdog_timer);
-
-	cancel_work_sync(&adapter->watchdog_task);
 	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE ||
 	    adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE)
 		cancel_work_sync(&adapter->fdir_reinit_task);
-- 
1.7.4.4

