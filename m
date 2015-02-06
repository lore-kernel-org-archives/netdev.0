From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 15/16] ixgbevf: combine all of the tasks into a single service task
Date: Thu,  5 Feb 2015 20:31:24 -0800
Message-ID: <1423197085-32270-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1423197085-32270-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	kernel-team@fb.com, Alexander Duyck <alexander.h.duyck@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:49678 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754398AbbBFEbq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Feb 2015 23:31:46 -0500
In-Reply-To: <1423197085-32270-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This change combines the reset and watchdog tasklets into a single task.

The advantage of this is that we can avoid multiple schedules of the reset
task when we have a reset event needed due to either the mailbox going down
or transmit packets being present on a link down.

CC: Alexander Duyck <alexander.h.duyck@redhat.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |  13 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 140 +++++++++++++---------
 2 files changed, 87 insertions(+), 66 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index a41ab37..3a9b356 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -367,8 +367,6 @@ struct ixgbevf_adapter {
 	/* this field must be first, see ixgbevf_process_skb_fields */
 	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
 
-	struct timer_list watchdog_timer;
-	struct work_struct reset_task;
 	struct ixgbevf_q_vector *q_vector[MAX_MSIX_Q_VECTORS];
 
 	/* Interrupt Throttle Rate */
@@ -398,8 +396,7 @@ struct ixgbevf_adapter {
 	 * thus the additional *_CAPABLE flags.
 	 */
 	u32 flags;
-#define IXGBE_FLAG_IN_WATCHDOG_TASK             (u32)(1)
-
+#define IXGBEVF_FLAG_RESET_REQUESTED		(u32)(1)
 #define IXGBEVF_FLAG_QUEUE_RESET_REQUESTED	(u32)(1 << 2)
 
 	struct msix_entry *msix_entries;
@@ -435,10 +432,11 @@ struct ixgbevf_adapter {
 	u32 link_speed;
 	bool link_up;
 
+	struct timer_list service_timer;
+	struct work_struct service_task;
+
 	spinlock_t mbx_lock;
 	unsigned long last_reset;
-
-	struct work_struct watchdog_task;
 };
 
 enum ixbgevf_state_t {
@@ -447,7 +445,8 @@ enum ixbgevf_state_t {
 	__IXGBEVF_DOWN,
 	__IXGBEVF_DISABLED,
 	__IXGBEVF_REMOVING,
-	__IXGBEVF_WORK_INIT,
+	__IXGBEVF_SERVICE_SCHED,
+	__IXGBEVF_SERVICE_INITED,
 };
 
 enum ixgbevf_boards {
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index c110065..4186981 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -98,6 +98,23 @@ static int debug = -1;
 module_param(debug, int, 0);
 MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
 
+static void ixgbevf_service_event_schedule(struct ixgbevf_adapter *adapter)
+{
+	if (!test_bit(__IXGBEVF_DOWN, &adapter->state) &&
+	    !test_bit(__IXGBEVF_REMOVING, &adapter->state) &&
+	    !test_and_set_bit(__IXGBEVF_SERVICE_SCHED, &adapter->state))
+		schedule_work(&adapter->service_task);
+}
+
+static void ixgbevf_service_event_complete(struct ixgbevf_adapter *adapter)
+{
+	BUG_ON(!test_bit(__IXGBEVF_SERVICE_SCHED, &adapter->state));
+
+	/* flush memory to make sure state is correct before next watchdog */
+	smp_mb__before_atomic();
+	clear_bit(__IXGBEVF_SERVICE_SCHED, &adapter->state);
+}
+
 /* forward decls */
 static void ixgbevf_queue_reset_subtask(struct ixgbevf_adapter *adapter);
 static void ixgbevf_set_itr(struct ixgbevf_q_vector *q_vector);
@@ -111,8 +128,8 @@ static void ixgbevf_remove_adapter(struct ixgbe_hw *hw)
 		return;
 	hw->hw_addr = NULL;
 	dev_err(&adapter->pdev->dev, "Adapter removed\n");
-	if (test_bit(__IXGBEVF_WORK_INIT, &adapter->state))
-		schedule_work(&adapter->watchdog_task);
+	if (test_bit(__IXGBEVF_SERVICE_INITED, &adapter->state))
+		ixgbevf_service_event_schedule(adapter);
 }
 
 static void ixgbevf_check_remove(struct ixgbe_hw *hw, u32 reg)
@@ -246,6 +263,15 @@ static inline bool ixgbevf_check_tx_hang(struct ixgbevf_ring *tx_ring)
 	return false;
 }
 
+static void ixgbevf_tx_timeout_reset(struct ixgbevf_adapter *adapter)
+{
+	/* Do the reset outside of interrupt context */
+	if (!test_bit(__IXGBEVF_DOWN, &adapter->state)) {
+		adapter->flags |= IXGBEVF_FLAG_RESET_REQUESTED;
+		ixgbevf_service_event_schedule(adapter);
+	}
+}
+
 /**
  * ixgbevf_tx_timeout - Respond to a Tx Hang
  * @netdev: network interface device structure
@@ -254,8 +280,7 @@ static void ixgbevf_tx_timeout(struct net_device *netdev)
 {
 	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
 
-	/* Do the reset outside of interrupt context */
-	schedule_work(&adapter->reset_task);
+	ixgbevf_tx_timeout_reset(adapter);
 }
 
 /**
@@ -387,7 +412,7 @@ static bool ixgbevf_clean_tx_irq(struct ixgbevf_q_vector *q_vector,
 		netif_stop_subqueue(tx_ring->netdev, tx_ring->queue_index);
 
 		/* schedule immediate reset if we believe we hung */
-		schedule_work(&adapter->reset_task);
+		ixgbevf_tx_timeout_reset(adapter);
 
 		return true;
 	}
@@ -1239,9 +1264,7 @@ static irqreturn_t ixgbevf_msix_other(int irq, void *data)
 
 	hw->mac.get_link_status = 1;
 
-	if (!test_bit(__IXGBEVF_DOWN, &adapter->state) &&
-	    !test_bit(__IXGBEVF_REMOVING, &adapter->state))
-		mod_timer(&adapter->watchdog_timer, jiffies);
+	ixgbevf_service_event_schedule(adapter);
 
 	IXGBE_WRITE_REG(hw, IXGBE_VTEIMS, adapter->eims_other);
 
@@ -2051,7 +2074,7 @@ static void ixgbevf_up_complete(struct ixgbevf_adapter *adapter)
 	ixgbevf_init_last_counter_stats(adapter);
 
 	hw->mac.get_link_status = 1;
-	mod_timer(&adapter->watchdog_timer, jiffies);
+	mod_timer(&adapter->service_timer, jiffies);
 }
 
 void ixgbevf_up(struct ixgbevf_adapter *adapter)
@@ -2177,13 +2200,7 @@ void ixgbevf_down(struct ixgbevf_adapter *adapter)
 
 	ixgbevf_napi_disable_all(adapter);
 
-	del_timer_sync(&adapter->watchdog_timer);
-
-	/* can't call flush scheduled work here because it can deadlock
-	 * if linkwatch_event tries to acquire the rtnl_lock which we are
-	 * holding */
-	while (adapter->flags & IXGBE_FLAG_IN_WATCHDOG_TASK)
-		msleep(1);
+	del_timer_sync(&adapter->service_timer);
 
 	/* disable transmits in the hardware now that interrupts are off */
 	for (i = 0; i < adapter->num_tx_queues; i++) {
@@ -2711,22 +2728,25 @@ void ixgbevf_update_stats(struct ixgbevf_adapter *adapter)
 }
 
 /**
- * ixgbevf_watchdog - Timer Call-back
+ * ixgbevf_service_timer - Timer Call-back
  * @data: pointer to adapter cast into an unsigned long
  **/
-static void ixgbevf_watchdog(unsigned long data)
+static void ixgbevf_service_timer(unsigned long data)
 {
 	struct ixgbevf_adapter *adapter = (struct ixgbevf_adapter *)data;
 
-	/* Do the reset outside of interrupt context */
-	schedule_work(&adapter->watchdog_task);
+	/* Reset the timer */
+	mod_timer(&adapter->service_timer, (HZ * 2) + jiffies);
+
+	ixgbevf_service_event_schedule(adapter);
 }
 
-static void ixgbevf_reset_task(struct work_struct *work)
+static void ixgbevf_reset_subtask(struct ixgbevf_adapter *adapter)
 {
-	struct ixgbevf_adapter *adapter;
+	if (!(adapter->flags & IXGBEVF_FLAG_RESET_REQUESTED))
+		return;
 
-	adapter = container_of(work, struct ixgbevf_adapter, reset_task);
+	adapter->flags &= ~IXGBEVF_FLAG_RESET_REQUESTED;
 
 	/* If we're already down or resetting, just bail */
 	if (test_bit(__IXGBEVF_DOWN, &adapter->state) ||
@@ -2766,6 +2786,7 @@ static void ixgbevf_check_hang_subtask(struct ixgbevf_adapter *adapter)
 	/* get one bit for every active tx/rx interrupt vector */
 	for (i = 0; i < adapter->num_msix_vectors - NON_Q_VECTORS; i++) {
 		struct ixgbevf_q_vector *qv = adapter->q_vector[i];
+
 		if (qv->rx.ring || qv->tx.ring)
 			eics |= 1 << i;
 	}
@@ -2793,7 +2814,7 @@ static void ixgbevf_watchdog_update_link(struct ixgbevf_adapter *adapter)
 
 	/* if check for link returns error we will need to reset */
 	if (err && time_after(jiffies, adapter->last_reset + (10 * HZ))) {
-		schedule_work(&adapter->reset_task);
+		adapter->flags |= IXGBEVF_FLAG_RESET_REQUESTED;
 		link_up = false;
 	}
 
@@ -2847,14 +2868,35 @@ static void ixgbevf_watchdog_link_is_down(struct ixgbevf_adapter *adapter)
 }
 
 /**
- * ixgbevf_watchdog_task - worker thread to bring link up
+ * ixgbevf_watchdog_subtask - worker thread to bring link up
+ * @work: pointer to work_struct containing our data
+ **/
+static void ixgbevf_watchdog_subtask(struct ixgbevf_adapter *adapter)
+{
+	/* if interface is down do nothing */
+	if (test_bit(__IXGBEVF_DOWN, &adapter->state) ||
+	    test_bit(__IXGBEVF_RESETTING, &adapter->state))
+		return;
+
+	ixgbevf_watchdog_update_link(adapter);
+
+	if (adapter->link_up)
+		ixgbevf_watchdog_link_is_up(adapter);
+	else
+		ixgbevf_watchdog_link_is_down(adapter);
+
+	ixgbevf_update_stats(adapter);
+}
+
+/**
+ * ixgbevf_service_task - manages and runs subtasks
  * @work: pointer to work_struct containing our data
  **/
-static void ixgbevf_watchdog_task(struct work_struct *work)
+static void ixgbevf_service_task(struct work_struct *work)
 {
 	struct ixgbevf_adapter *adapter = container_of(work,
 						       struct ixgbevf_adapter,
-						       watchdog_task);
+						       service_task);
 	struct ixgbe_hw *hw = &adapter->hw;
 
 	if (IXGBE_REMOVED(hw->hw_addr)) {
@@ -2867,27 +2909,11 @@ static void ixgbevf_watchdog_task(struct work_struct *work)
 	}
 
 	ixgbevf_queue_reset_subtask(adapter);
-
-	adapter->flags |= IXGBE_FLAG_IN_WATCHDOG_TASK;
-
-	ixgbevf_watchdog_update_link(adapter);
-
-	if (adapter->link_up)
-		ixgbevf_watchdog_link_is_up(adapter);
-	else
-		ixgbevf_watchdog_link_is_down(adapter);
-
-	ixgbevf_update_stats(adapter);
-
+	ixgbevf_reset_subtask(adapter);
+	ixgbevf_watchdog_subtask(adapter);
 	ixgbevf_check_hang_subtask(adapter);
 
-	/* Reset the timer */
-	if (!test_bit(__IXGBEVF_DOWN, &adapter->state) &&
-	    !test_bit(__IXGBEVF_REMOVING, &adapter->state))
-		mod_timer(&adapter->watchdog_timer,
-			  round_jiffies(jiffies + (2 * HZ)));
-
-	adapter->flags &= ~IXGBE_FLAG_IN_WATCHDOG_TASK;
+	ixgbevf_service_event_complete(adapter);
 }
 
 /**
@@ -3994,17 +4020,17 @@ static int ixgbevf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	netdev->priv_flags |= IFF_UNICAST_FLT;
 
-	init_timer(&adapter->watchdog_timer);
-	adapter->watchdog_timer.function = ixgbevf_watchdog;
-	adapter->watchdog_timer.data = (unsigned long)adapter;
-
 	if (IXGBE_REMOVED(hw->hw_addr)) {
 		err = -EIO;
 		goto err_sw_init;
 	}
-	INIT_WORK(&adapter->reset_task, ixgbevf_reset_task);
-	INIT_WORK(&adapter->watchdog_task, ixgbevf_watchdog_task);
-	set_bit(__IXGBEVF_WORK_INIT, &adapter->state);
+
+	setup_timer(&adapter->service_timer, &ixgbevf_service_timer,
+		    (unsigned long)adapter);
+
+	INIT_WORK(&adapter->service_task, ixgbevf_service_task);
+	set_bit(__IXGBEVF_SERVICE_INITED, &adapter->state);
+	clear_bit(__IXGBEVF_SERVICE_SCHED, &adapter->state);
 
 	err = ixgbevf_init_interrupt_scheme(adapter);
 	if (err)
@@ -4078,11 +4104,7 @@ static void ixgbevf_remove(struct pci_dev *pdev)
 	adapter = netdev_priv(netdev);
 
 	set_bit(__IXGBEVF_REMOVING, &adapter->state);
-
-	del_timer_sync(&adapter->watchdog_timer);
-
-	cancel_work_sync(&adapter->reset_task);
-	cancel_work_sync(&adapter->watchdog_task);
+	cancel_work_sync(&adapter->service_task);
 
 	if (netdev->reg_state == NETREG_REGISTERED)
 		unregister_netdev(netdev);
@@ -4116,7 +4138,7 @@ static pci_ers_result_t ixgbevf_io_error_detected(struct pci_dev *pdev,
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
 
-	if (!test_bit(__IXGBEVF_WORK_INIT, &adapter->state))
+	if (!test_bit(__IXGBEVF_SERVICE_INITED, &adapter->state))
 		return PCI_ERS_RESULT_DISCONNECT;
 
 	rtnl_lock();
-- 
1.9.3
