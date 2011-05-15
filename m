From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 06/13] ixgbe: Combine SFP and multi-speed fiber task into single service task
Date: Sat, 14 May 2011 18:23:40 -0700
Message-ID: <1305422627-9583-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1305422627-9583-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:1031 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759514Ab1EOBXv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 May 2011 21:23:51 -0400
In-Reply-To: <1305422627-9583-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change is meant to address several race conditions with multi-speed
fiber SFP+ modules in 82599 adapters.  Specifically issues have been seen
in which both the SFP configuration and the multi-speed fiber configuration
are running simultaneously which will result in the device getting into an
erroneous link down state.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Evan Swanson <evan.swanson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe.h      |   26 ++--
 drivers/net/ixgbe/ixgbe_main.c |  388 +++++++++++++++++++++-------------------
 2 files changed, 213 insertions(+), 201 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index ec948ff..cbb04ba 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -367,19 +367,20 @@ struct ixgbe_adapter {
 #define IXGBE_FLAG_VMDQ_ENABLED                 (u32)(1 << 19)
 #define IXGBE_FLAG_FAN_FAIL_CAPABLE             (u32)(1 << 20)
 #define IXGBE_FLAG_NEED_LINK_UPDATE             (u32)(1 << 22)
-#define IXGBE_FLAG_IN_SFP_LINK_TASK             (u32)(1 << 23)
-#define IXGBE_FLAG_IN_SFP_MOD_TASK              (u32)(1 << 24)
-#define IXGBE_FLAG_FDIR_HASH_CAPABLE            (u32)(1 << 25)
-#define IXGBE_FLAG_FDIR_PERFECT_CAPABLE         (u32)(1 << 26)
-#define IXGBE_FLAG_FCOE_CAPABLE                 (u32)(1 << 27)
-#define IXGBE_FLAG_FCOE_ENABLED                 (u32)(1 << 28)
-#define IXGBE_FLAG_SRIOV_CAPABLE                (u32)(1 << 29)
-#define IXGBE_FLAG_SRIOV_ENABLED                (u32)(1 << 30)
+#define IXGBE_FLAG_NEED_LINK_CONFIG             (u32)(1 << 23)
+#define IXGBE_FLAG_FDIR_HASH_CAPABLE            (u32)(1 << 24)
+#define IXGBE_FLAG_FDIR_PERFECT_CAPABLE         (u32)(1 << 25)
+#define IXGBE_FLAG_FCOE_CAPABLE                 (u32)(1 << 26)
+#define IXGBE_FLAG_FCOE_ENABLED                 (u32)(1 << 27)
+#define IXGBE_FLAG_SRIOV_CAPABLE                (u32)(1 << 28)
+#define IXGBE_FLAG_SRIOV_ENABLED                (u32)(1 << 29)
 
 	u32 flags2;
 #define IXGBE_FLAG2_RSC_CAPABLE                 (u32)(1)
 #define IXGBE_FLAG2_RSC_ENABLED                 (u32)(1 << 1)
 #define IXGBE_FLAG2_TEMP_SENSOR_CAPABLE         (u32)(1 << 2)
+#define IXGBE_FLAG2_SEARCH_FOR_SFP              (u32)(1 << 4)
+#define IXGBE_FLAG2_SFP_NEEDS_RESET             (u32)(1 << 5)
 
 	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
 	u16 bd_number;
@@ -455,13 +456,11 @@ struct ixgbe_adapter {
 
 	struct work_struct reset_task;
 	struct work_struct watchdog_task;
-	struct work_struct sfp_task;
-	struct work_struct multispeed_fiber_task;
-	struct work_struct sfp_config_module_task;
 	struct work_struct fdir_reinit_task;
 	struct work_struct check_overtemp_task;
+	struct work_struct service_task;
 	struct timer_list watchdog_timer;
-	struct timer_list sfp_timer;
+	struct timer_list service_timer;
 	u32 fdir_pballoc;
 	u32 atr_sample_rate;
 	spinlock_t fdir_perfect_lock;
@@ -492,7 +491,8 @@ enum ixbge_state_t {
 	__IXGBE_TESTING,
 	__IXGBE_RESETTING,
 	__IXGBE_DOWN,
-	__IXGBE_SFP_MODULE_NOT_FOUND
+	__IXGBE_SERVICE_SCHED,
+	__IXGBE_IN_SFP_INIT,
 };
 
 struct ixgbe_rsc_cb {
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index f8196e0..a5d4226 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -191,6 +191,22 @@ static inline void ixgbe_disable_sriov(struct ixgbe_adapter *adapter)
 	adapter->flags &= ~IXGBE_FLAG_SRIOV_ENABLED;
 }
 
+static void ixgbe_service_event_schedule(struct ixgbe_adapter *adapter)
+{
+	if (!test_bit(__IXGBE_DOWN, &adapter->state) &&
+	    !test_and_set_bit(__IXGBE_SERVICE_SCHED, &adapter->state))
+		schedule_work(&adapter->service_task);
+}
+
+static void ixgbe_service_event_complete(struct ixgbe_adapter *adapter)
+{
+	BUG_ON(!test_bit(__IXGBE_SERVICE_SCHED, &adapter->state));
+
+	/* flush memory to make sure state is correct before next watchog */
+	smp_mb__before_clear_bit();
+	clear_bit(__IXGBE_SERVICE_SCHED, &adapter->state);
+}
+
 struct ixgbe_reg_info {
 	u32 ofs;
 	char *name;
@@ -1858,15 +1874,19 @@ static void ixgbe_check_sfp_event(struct ixgbe_adapter *adapter, u32 eicr)
 	if (eicr & IXGBE_EICR_GPI_SDP2) {
 		/* Clear the interrupt */
 		IXGBE_WRITE_REG(hw, IXGBE_EICR, IXGBE_EICR_GPI_SDP2);
-		if (!test_bit(__IXGBE_DOWN, &adapter->state))
-			schedule_work(&adapter->sfp_config_module_task);
+		if (!test_bit(__IXGBE_DOWN, &adapter->state)) {
+			adapter->flags2 |= IXGBE_FLAG2_SFP_NEEDS_RESET;
+			ixgbe_service_event_schedule(adapter);
+		}
 	}
 
 	if (eicr & IXGBE_EICR_GPI_SDP1) {
 		/* Clear the interrupt */
 		IXGBE_WRITE_REG(hw, IXGBE_EICR, IXGBE_EICR_GPI_SDP1);
-		if (!test_bit(__IXGBE_DOWN, &adapter->state))
-			schedule_work(&adapter->multispeed_fiber_task);
+		if (!test_bit(__IXGBE_DOWN, &adapter->state)) {
+			adapter->flags |= IXGBE_FLAG_NEED_LINK_CONFIG;
+			ixgbe_service_event_schedule(adapter);
+		}
 	}
 }
 
@@ -1937,8 +1957,10 @@ static irqreturn_t ixgbe_msix_lsc(int irq, void *data)
 
 	ixgbe_check_fan_failure(adapter, eicr);
 
+	/* re-enable the original interrupt state, no lsc, no queues */
 	if (!test_bit(__IXGBE_DOWN, &adapter->state))
-		IXGBE_WRITE_REG(hw, IXGBE_EIMS, IXGBE_EIMS_OTHER);
+		IXGBE_WRITE_REG(hw, IXGBE_EIMS, eicr &
+		                ~(IXGBE_EIMS_LSC | IXGBE_EIMS_RTX_QUEUE));
 
 	return IRQ_HANDLED;
 }
@@ -3772,31 +3794,16 @@ static inline bool ixgbe_is_sfp(struct ixgbe_hw *hw)
  **/
 static void ixgbe_sfp_link_config(struct ixgbe_adapter *adapter)
 {
-	struct ixgbe_hw *hw = &adapter->hw;
+	/*
+	 * We are assuming the worst case scenerio here, and that
+	 * is that an SFP was inserted/removed after the reset
+	 * but before SFP detection was enabled.  As such the best
+	 * solution is to just start searching as soon as we start
+	 */
+	if (adapter->hw.mac.type == ixgbe_mac_82598EB)
+		adapter->flags2 |= IXGBE_FLAG2_SEARCH_FOR_SFP;
 
-		if (hw->phy.multispeed_fiber) {
-			/*
-			 * In multispeed fiber setups, the device may not have
-			 * had a physical connection when the driver loaded.
-			 * If that's the case, the initial link configuration
-			 * couldn't get the MAC into 10G or 1G mode, so we'll
-			 * never have a link status change interrupt fire.
-			 * We need to try and force an autonegotiation
-			 * session, then bring up link.
-			 */
-			if (hw->mac.ops.setup_sfp)
-				hw->mac.ops.setup_sfp(hw);
-			if (!(adapter->flags & IXGBE_FLAG_IN_SFP_LINK_TASK))
-				schedule_work(&adapter->multispeed_fiber_task);
-		} else {
-			/*
-			 * Direct Attach Cu and non-multispeed fiber modules
-			 * still need to be configured properly prior to
-			 * attempting link.
-			 */
-			if (!(adapter->flags & IXGBE_FLAG_IN_SFP_MOD_TASK))
-				schedule_work(&adapter->sfp_config_module_task);
-		}
+	adapter->flags2 |= IXGBE_FLAG2_SFP_NEEDS_RESET;
 }
 
 /**
@@ -3926,17 +3933,6 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 			e_crit(drv, "Fan has stopped, replace the adapter\n");
 	}
 
-	/*
-	 * For hot-pluggable SFP+ devices, a new SFP+ module may have
-	 * arrived before interrupts were enabled but after probe.  Such
-	 * devices wouldn't have their type identified yet. We need to
-	 * kick off the SFP+ module setup first, then try to bring up link.
-	 * If we're not hot-pluggable SFP+, we just need to configure link
-	 * and bring it up.
-	 */
-	if (hw->phy.type == ixgbe_phy_none)
-		schedule_work(&adapter->sfp_config_module_task);
-
 	/* enable transmits */
 	netif_tx_start_all_queues(adapter->netdev);
 
@@ -3945,6 +3941,7 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 	adapter->flags |= IXGBE_FLAG_NEED_LINK_UPDATE;
 	adapter->link_check_timeout = jiffies;
 	mod_timer(&adapter->watchdog_timer, jiffies);
+	mod_timer(&adapter->service_timer, jiffies);
 
 	/* Set PF Reset Done bit so PF/VF Mail Ops can work */
 	ctrl_ext = IXGBE_READ_REG(hw, IXGBE_CTRL_EXT);
@@ -3957,6 +3954,9 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 void ixgbe_reinit_locked(struct ixgbe_adapter *adapter)
 {
 	WARN_ON(in_interrupt());
+	/* put off any impending NetWatchDogTimeout */
+	adapter->netdev->trans_start = jiffies;
+
 	while (test_and_set_bit(__IXGBE_RESETTING, &adapter->state))
 		usleep_range(1000, 2000);
 	ixgbe_down(adapter);
@@ -3985,10 +3985,20 @@ void ixgbe_reset(struct ixgbe_adapter *adapter)
 	struct ixgbe_hw *hw = &adapter->hw;
 	int err;
 
+	/* lock SFP init bit to prevent race conditions with the watchdog */
+	while (test_and_set_bit(__IXGBE_IN_SFP_INIT, &adapter->state))
+		usleep_range(1000, 2000);
+
+	/* clear all SFP and link config related flags while holding SFP_INIT */
+	adapter->flags2 &= ~(IXGBE_FLAG2_SEARCH_FOR_SFP |
+			     IXGBE_FLAG2_SFP_NEEDS_RESET);
+	adapter->flags &= ~IXGBE_FLAG_NEED_LINK_CONFIG;
+
 	err = hw->mac.ops.init_hw(hw);
 	switch (err) {
 	case 0:
 	case IXGBE_ERR_SFP_NOT_PRESENT:
+	case IXGBE_ERR_SFP_NOT_SUPPORTED:
 		break;
 	case IXGBE_ERR_MASTER_REQUESTS_PENDING:
 		e_dev_err("master disable timed out\n");
@@ -4006,6 +4016,8 @@ void ixgbe_reset(struct ixgbe_adapter *adapter)
 		e_dev_err("Hardware Error: %d\n", err);
 	}
 
+	clear_bit(__IXGBE_IN_SFP_INIT, &adapter->state);
+
 	/* reprogram the RAR[0] in case user changed it. */
 	hw->mac.ops.set_rar(hw, 0, hw->mac.addr, adapter->num_vfs,
 			    IXGBE_RAH_AV);
@@ -4167,11 +4179,9 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 
 	netif_tx_stop_all_queues(netdev);
 
-	clear_bit(__IXGBE_SFP_MODULE_NOT_FOUND, &adapter->state);
-	del_timer_sync(&adapter->sfp_timer);
 	del_timer_sync(&adapter->watchdog_timer);
 	cancel_work_sync(&adapter->watchdog_task);
-
+	/* call carrier off first to avoid false dev_watchdog timeouts */
 	netif_carrier_off(netdev);
 	netif_tx_disable(netdev);
 
@@ -4179,6 +4189,10 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 
 	ixgbe_napi_disable_all(adapter);
 
+	adapter->flags &= ~IXGBE_FLAG_NEED_LINK_UPDATE;
+
+	del_timer_sync(&adapter->service_timer);
+
 	/* Cleanup the affinity_hint CPU mask memory and callback */
 	for (i = 0; i < num_q_vectors; i++) {
 		struct ixgbe_q_vector *q_vector = adapter->q_vector[i];
@@ -5148,57 +5162,6 @@ void ixgbe_clear_interrupt_scheme(struct ixgbe_adapter *adapter)
 }
 
 /**
- * ixgbe_sfp_timer - worker thread to find a missing module
- * @data: pointer to our adapter struct
- **/
-static void ixgbe_sfp_timer(unsigned long data)
-{
-	struct ixgbe_adapter *adapter = (struct ixgbe_adapter *)data;
-
-	/*
-	 * Do the sfp_timer outside of interrupt context due to the
-	 * delays that sfp+ detection requires
-	 */
-	schedule_work(&adapter->sfp_task);
-}
-
-/**
- * ixgbe_sfp_task - worker thread to find a missing module
- * @work: pointer to work_struct containing our data
- **/
-static void ixgbe_sfp_task(struct work_struct *work)
-{
-	struct ixgbe_adapter *adapter = container_of(work,
-						     struct ixgbe_adapter,
-						     sfp_task);
-	struct ixgbe_hw *hw = &adapter->hw;
-
-	if ((hw->phy.type == ixgbe_phy_nl) &&
-	    (hw->phy.sfp_type == ixgbe_sfp_type_not_present)) {
-		s32 ret = hw->phy.ops.identify_sfp(hw);
-		if (ret == IXGBE_ERR_SFP_NOT_PRESENT)
-			goto reschedule;
-		ret = hw->phy.ops.reset(hw);
-		if (ret == IXGBE_ERR_SFP_NOT_SUPPORTED) {
-			e_dev_err("failed to initialize because an unsupported "
-				  "SFP+ module type was detected.\n");
-			e_dev_err("Reload the driver after installing a "
-				  "supported module.\n");
-			unregister_netdev(adapter->netdev);
-		} else {
-			e_info(probe, "detected SFP+: %d\n", hw->phy.sfp_type);
-		}
-		/* don't need this routine any more */
-		clear_bit(__IXGBE_SFP_MODULE_NOT_FOUND, &adapter->state);
-	}
-	return;
-reschedule:
-	if (test_bit(__IXGBE_SFP_MODULE_NOT_FOUND, &adapter->state))
-		mod_timer(&adapter->sfp_timer,
-			  round_jiffies(jiffies + (2 * HZ)));
-}
-
-/**
  * ixgbe_sw_init - Initialize general software structures (struct ixgbe_adapter)
  * @adapter: board private structure to initialize
  *
@@ -6042,65 +6005,6 @@ watchdog_short_circuit:
 }
 
 /**
- * ixgbe_multispeed_fiber_task - worker thread to configure multispeed fiber
- * @work: pointer to work_struct containing our data
- **/
-static void ixgbe_multispeed_fiber_task(struct work_struct *work)
-{
-	struct ixgbe_adapter *adapter = container_of(work,
-						     struct ixgbe_adapter,
-						     multispeed_fiber_task);
-	struct ixgbe_hw *hw = &adapter->hw;
-	u32 autoneg;
-	bool negotiation;
-
-	adapter->flags |= IXGBE_FLAG_IN_SFP_LINK_TASK;
-	autoneg = hw->phy.autoneg_advertised;
-	if ((!autoneg) && (hw->mac.ops.get_link_capabilities))
-		hw->mac.ops.get_link_capabilities(hw, &autoneg, &negotiation);
-	hw->mac.autotry_restart = false;
-	if (hw->mac.ops.setup_link)
-		hw->mac.ops.setup_link(hw, autoneg, negotiation, true);
-	adapter->flags |= IXGBE_FLAG_NEED_LINK_UPDATE;
-	adapter->flags &= ~IXGBE_FLAG_IN_SFP_LINK_TASK;
-}
-
-/**
- * ixgbe_sfp_config_module_task - worker thread to configure a new SFP+ module
- * @work: pointer to work_struct containing our data
- **/
-static void ixgbe_sfp_config_module_task(struct work_struct *work)
-{
-	struct ixgbe_adapter *adapter = container_of(work,
-						     struct ixgbe_adapter,
-						     sfp_config_module_task);
-	struct ixgbe_hw *hw = &adapter->hw;
-	u32 err;
-
-	adapter->flags |= IXGBE_FLAG_IN_SFP_MOD_TASK;
-
-	/* Time for electrical oscillations to settle down */
-	msleep(100);
-	err = hw->phy.ops.identify_sfp(hw);
-
-	if (err == IXGBE_ERR_SFP_NOT_SUPPORTED) {
-		e_dev_err("failed to initialize because an unsupported SFP+ "
-			  "module type was detected.\n");
-		e_dev_err("Reload the driver after installing a supported "
-			  "module.\n");
-		unregister_netdev(adapter->netdev);
-		return;
-	}
-	if (hw->mac.ops.setup_sfp)
-		hw->mac.ops.setup_sfp(hw);
-
-	if (!(adapter->flags & IXGBE_FLAG_IN_SFP_LINK_TASK))
-		/* This will also work for DA Twinax connections */
-		schedule_work(&adapter->multispeed_fiber_task);
-	adapter->flags &= ~IXGBE_FLAG_IN_SFP_MOD_TASK;
-}
-
-/**
  * ixgbe_fdir_reinit_task - worker thread to reinit FDIR filter table
  * @work: pointer to work_struct containing our data
  **/
@@ -6273,6 +6177,141 @@ static void ixgbe_watchdog_task(struct work_struct *work)
 	mutex_unlock(&ixgbe_watchdog_lock);
 }
 
+/**
+ * ixgbe_sfp_detection_subtask - poll for SFP+ cable
+ * @adapter - the ixgbe adapter structure
+ **/
+static void ixgbe_sfp_detection_subtask(struct ixgbe_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	s32 err;
+
+	/* not searching for SFP so there is nothing to do here */
+	if (!(adapter->flags2 & IXGBE_FLAG2_SEARCH_FOR_SFP) &&
+	    !(adapter->flags2 & IXGBE_FLAG2_SFP_NEEDS_RESET))
+		return;
+
+	/* someone else is in init, wait until next service event */
+	if (test_and_set_bit(__IXGBE_IN_SFP_INIT, &adapter->state))
+		return;
+
+	err = hw->phy.ops.identify_sfp(hw);
+	if (err == IXGBE_ERR_SFP_NOT_SUPPORTED)
+		goto sfp_out;
+
+	if (err == IXGBE_ERR_SFP_NOT_PRESENT) {
+		/* If no cable is present, then we need to reset
+		 * the next time we find a good cable. */
+		adapter->flags2 |= IXGBE_FLAG2_SFP_NEEDS_RESET;
+	}
+
+	/* exit on error */
+	if (err)
+		goto sfp_out;
+
+	/* exit if reset not needed */
+	if (!(adapter->flags2 & IXGBE_FLAG2_SFP_NEEDS_RESET))
+		goto sfp_out;
+
+	adapter->flags2 &= ~IXGBE_FLAG2_SFP_NEEDS_RESET;
+
+	/*
+	 * A module may be identified correctly, but the EEPROM may not have
+	 * support for that module.  setup_sfp() will fail in that case, so
+	 * we should not allow that module to load.
+	 */
+	if (hw->mac.type == ixgbe_mac_82598EB)
+		err = hw->phy.ops.reset(hw);
+	else
+		err = hw->mac.ops.setup_sfp(hw);
+
+	if (err == IXGBE_ERR_SFP_NOT_SUPPORTED)
+		goto sfp_out;
+
+	adapter->flags |= IXGBE_FLAG_NEED_LINK_CONFIG;
+	e_info(probe, "detected SFP+: %d\n", hw->phy.sfp_type);
+
+sfp_out:
+	clear_bit(__IXGBE_IN_SFP_INIT, &adapter->state);
+
+	if ((err == IXGBE_ERR_SFP_NOT_SUPPORTED) &&
+	    (adapter->netdev->reg_state == NETREG_REGISTERED)) {
+		e_dev_err("failed to initialize because an unsupported "
+			  "SFP+ module type was detected.\n");
+		e_dev_err("Reload the driver after installing a "
+			  "supported module.\n");
+		unregister_netdev(adapter->netdev);
+	}
+}
+
+/**
+ * ixgbe_sfp_link_config_subtask - set up link SFP after module install
+ * @adapter - the ixgbe adapter structure
+ **/
+static void ixgbe_sfp_link_config_subtask(struct ixgbe_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 autoneg;
+	bool negotiation;
+
+	if (!(adapter->flags & IXGBE_FLAG_NEED_LINK_CONFIG))
+		return;
+
+	/* someone else is in init, wait until next service event */
+	if (test_and_set_bit(__IXGBE_IN_SFP_INIT, &adapter->state))
+		return;
+
+	adapter->flags &= ~IXGBE_FLAG_NEED_LINK_CONFIG;
+
+	autoneg = hw->phy.autoneg_advertised;
+	if ((!autoneg) && (hw->mac.ops.get_link_capabilities))
+		hw->mac.ops.get_link_capabilities(hw, &autoneg, &negotiation);
+	hw->mac.autotry_restart = false;
+	if (hw->mac.ops.setup_link)
+		hw->mac.ops.setup_link(hw, autoneg, negotiation, true);
+
+	adapter->flags |= IXGBE_FLAG_NEED_LINK_UPDATE;
+	adapter->link_check_timeout = jiffies;
+	clear_bit(__IXGBE_IN_SFP_INIT, &adapter->state);
+}
+
+/**
+ * ixgbe_service_timer - Timer Call-back
+ * @data: pointer to adapter cast into an unsigned long
+ **/
+static void ixgbe_service_timer(unsigned long data)
+{
+	struct ixgbe_adapter *adapter = (struct ixgbe_adapter *)data;
+	unsigned long next_event_offset;
+
+	/* poll faster when waiting for link */
+	if (adapter->flags & IXGBE_FLAG_NEED_LINK_UPDATE)
+		next_event_offset = HZ / 10;
+	else
+		next_event_offset = HZ * 2;
+
+	/* Reset the timer */
+	mod_timer(&adapter->service_timer, next_event_offset + jiffies);
+
+	ixgbe_service_event_schedule(adapter);
+}
+
+/**
+ * ixgbe_service_task - manages and runs subtasks
+ * @work: pointer to work_struct containing our data
+ **/
+static void ixgbe_service_task(struct work_struct *work)
+{
+	struct ixgbe_adapter *adapter = container_of(work,
+						     struct ixgbe_adapter,
+						     service_task);
+
+	ixgbe_sfp_detection_subtask(adapter);
+	ixgbe_sfp_link_config_subtask(adapter);
+
+	ixgbe_service_event_complete(adapter);
+}
+
 static int ixgbe_tso(struct ixgbe_adapter *adapter,
 		     struct ixgbe_ring *tx_ring, struct sk_buff *skb,
 		     u32 tx_flags, u8 *hdr_len, __be16 protocol)
@@ -7317,22 +7356,6 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	hw->phy.mdio.mdio_read = ixgbe_mdio_read;
 	hw->phy.mdio.mdio_write = ixgbe_mdio_write;
 
-	/* set up this timer and work struct before calling get_invariants
-	 * which might start the timer
-	 */
-	init_timer(&adapter->sfp_timer);
-	adapter->sfp_timer.function = ixgbe_sfp_timer;
-	adapter->sfp_timer.data = (unsigned long) adapter;
-
-	INIT_WORK(&adapter->sfp_task, ixgbe_sfp_task);
-
-	/* multispeed fiber has its own tasklet, called from GPI SDP1 context */
-	INIT_WORK(&adapter->multispeed_fiber_task, ixgbe_multispeed_fiber_task);
-
-	/* a new SFP+ module arrival, called from GPI SDP2 context */
-	INIT_WORK(&adapter->sfp_config_module_task,
-		  ixgbe_sfp_config_module_task);
-
 	ii->get_invariants(hw);
 
 	/* setup the private structure */
@@ -7366,17 +7389,9 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	hw->phy.reset_if_overtemp = false;
 	if (err == IXGBE_ERR_SFP_NOT_PRESENT &&
 	    hw->mac.type == ixgbe_mac_82598EB) {
-		/*
-		 * Start a kernel thread to watch for a module to arrive.
-		 * Only do this for 82598, since 82599 will generate
-		 * interrupts on module arrival.
-		 */
-		set_bit(__IXGBE_SFP_MODULE_NOT_FOUND, &adapter->state);
-		mod_timer(&adapter->sfp_timer,
-			  round_jiffies(jiffies + (2 * HZ)));
 		err = 0;
 	} else if (err == IXGBE_ERR_SFP_NOT_SUPPORTED) {
-		e_dev_err("failed to initialize because an unsupported SFP+ "
+		e_dev_err("failed to load because an unsupported SFP+ "
 			  "module type was detected.\n");
 		e_dev_err("Reload the driver after installing a supported "
 			  "module.\n");
@@ -7468,6 +7483,8 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	      (hw->mac.type == ixgbe_mac_82599EB))))
 		hw->mac.ops.disable_tx_laser(hw);
 
+	setup_timer(&adapter->service_timer, &ixgbe_service_timer,
+	            (unsigned long) adapter);
 	init_timer(&adapter->watchdog_timer);
 	adapter->watchdog_timer.function = ixgbe_watchdog;
 	adapter->watchdog_timer.data = (unsigned long)adapter;
@@ -7475,6 +7492,9 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	INIT_WORK(&adapter->reset_task, ixgbe_reset_task);
 	INIT_WORK(&adapter->watchdog_task, ixgbe_watchdog_task);
 
+	INIT_WORK(&adapter->service_task, ixgbe_service_task);
+	clear_bit(__IXGBE_SERVICE_SCHED, &adapter->state);
+
 	err = ixgbe_init_interrupt_scheme(adapter);
 	if (err)
 		goto err_sw_init;
@@ -7593,11 +7613,7 @@ err_sw_init:
 err_eeprom:
 	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)
 		ixgbe_disable_sriov(adapter);
-	clear_bit(__IXGBE_SFP_MODULE_NOT_FOUND, &adapter->state);
-	del_timer_sync(&adapter->sfp_timer);
-	cancel_work_sync(&adapter->sfp_task);
-	cancel_work_sync(&adapter->multispeed_fiber_task);
-	cancel_work_sync(&adapter->sfp_config_module_task);
+	adapter->flags2 &= ~IXGBE_FLAG2_SEARCH_FOR_SFP;
 	iounmap(hw->hw_addr);
 err_ioremap:
 	free_netdev(netdev);
@@ -7625,19 +7641,15 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
 	struct net_device *netdev = adapter->netdev;
 
 	set_bit(__IXGBE_DOWN, &adapter->state);
+	cancel_work_sync(&adapter->service_task);
 
 	/*
 	 * The timers may be rescheduled, so explicitly disable them
 	 * from being rescheduled.
 	 */
-	clear_bit(__IXGBE_SFP_MODULE_NOT_FOUND, &adapter->state);
 	del_timer_sync(&adapter->watchdog_timer);
-	del_timer_sync(&adapter->sfp_timer);
 
 	cancel_work_sync(&adapter->watchdog_task);
-	cancel_work_sync(&adapter->sfp_task);
-	cancel_work_sync(&adapter->multispeed_fiber_task);
-	cancel_work_sync(&adapter->sfp_config_module_task);
 	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE ||
 	    adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE)
 		cancel_work_sync(&adapter->fdir_reinit_task);
-- 
1.7.4.4

