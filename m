From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/9] fm10k: prepare_for_reset() when we lose PCIe Link
Date: Tue,  3 Oct 2017 09:31:30 -0700
Message-ID: <20171003163138.47569-2-jeffrey.t.kirsher@intel.com>
References: <20171003163138.47569-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:17001 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751184AbdJCQb7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Oct 2017 12:31:59 -0400
In-Reply-To: <20171003163138.47569-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

If we lose PCIe link, such as when an unannounced PFLR event occurs, or
when a device is surprise removed, we currently detach the device and
close the netdev. This unfortunately leaves a lot of things still
active, such as the msix_mbx_pf IRQ, and Tx/Rx resources.

This can cause problems because the register reads will return
potentially invalid values which may result in unknown driver behavior.

Begin the process of resetting using fm10k_prepare_for_reset(), much in
the same way as the suspend and resume cycle does. This will attempt to
shutdown as much as possible, in order to prevent possible issues.

A naive implementation for this has issues, because there are now
multiple flows calling the reset logic and setting a reset bit. This
would cause problems, because the "re-attach" routine might call
fm10k_handle_reset() prior to the reset actually finishing. Instead,
we'll add state bits to indicate which flow actually initiated the
reset.

For the general reset flow, we'll assume that if someone else is
resetting that we do not need to handle it at all, so it does not need
its own state bit. For the suspend case, we will simply issue a warning
indicating that we are attempting to recover from this case when
resuming.

For the detached subtask, we'll simply refuse to re-attach until we've
actually initiated a reset as part of that flow.

Finally, we'll stop attempting to manage the mailbox subtask when we're
detached, since there's nothing we can do if we don't have a PCIe
address.

Overall this produces a much cleaner shutdown and recovery cycle for
a PCIe surprise remove event.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k.h     |   2 +
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 103 ++++++++++++++++++++-------
 2 files changed, 79 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index 689c413b7782..ba70c58ca920 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -270,6 +270,8 @@ enum fm10k_flags_t {
 
 enum fm10k_state_t {
 	__FM10K_RESETTING,
+	__FM10K_RESET_DETACHED,
+	__FM10K_RESET_SUSPENDED,
 	__FM10K_DOWN,
 	__FM10K_SERVICE_SCHED,
 	__FM10K_SERVICE_REQUEST,
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 9575f7c1862d..4e5e3e64beda 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -153,7 +153,15 @@ static void fm10k_service_timer(unsigned long data)
 	fm10k_service_event_schedule(interface);
 }
 
-static void fm10k_prepare_for_reset(struct fm10k_intfc *interface)
+/**
+ * fm10k_prepare_for_reset - Prepare the driver and device for a pending reset
+ * @interface: fm10k private data structure
+ *
+ * This function prepares for a device reset by shutting as much down as we
+ * can. It does nothing and returns false if __FM10K_RESETTING was already set
+ * prior to calling this function. It returns true if it actually did work.
+ */
+static bool fm10k_prepare_for_reset(struct fm10k_intfc *interface)
 {
 	struct net_device *netdev = interface->netdev;
 
@@ -162,8 +170,9 @@ static void fm10k_prepare_for_reset(struct fm10k_intfc *interface)
 	/* put off any impending NetWatchDogTimeout */
 	netif_trans_update(netdev);
 
-	while (test_and_set_bit(__FM10K_RESETTING, interface->state))
-		usleep_range(1000, 2000);
+	/* Nothing to do if a reset is already in progress */
+	if (test_and_set_bit(__FM10K_RESETTING, interface->state))
+		return false;
 
 	rtnl_lock();
 
@@ -181,6 +190,8 @@ static void fm10k_prepare_for_reset(struct fm10k_intfc *interface)
 	interface->last_reset = jiffies + (10 * HZ);
 
 	rtnl_unlock();
+
+	return true;
 }
 
 static int fm10k_handle_reset(struct fm10k_intfc *interface)
@@ -189,6 +200,8 @@ static int fm10k_handle_reset(struct fm10k_intfc *interface)
 	struct fm10k_hw *hw = &interface->hw;
 	int err;
 
+	WARN_ON(!test_bit(__FM10K_RESETTING, interface->state));
+
 	rtnl_lock();
 
 	pci_set_master(interface->pdev);
@@ -267,51 +280,75 @@ static void fm10k_detach_subtask(struct fm10k_intfc *interface)
 	struct net_device *netdev = interface->netdev;
 	u32 __iomem *hw_addr;
 	u32 value;
+	int err;
 
-	/* do nothing if device is still present or hw_addr is set */
+	/* do nothing if netdev is still present or hw_addr is set */
 	if (netif_device_present(netdev) || interface->hw.hw_addr)
 		return;
 
+	/* We've lost the PCIe register space, and can no longer access the
+	 * device. Shut everything except the detach subtask down and prepare
+	 * to reset the device in case we recover. If we actually prepare for
+	 * reset, indicate that we're detached.
+	 */
+	if (fm10k_prepare_for_reset(interface))
+		set_bit(__FM10K_RESET_DETACHED, interface->state);
+
 	/* check the real address space to see if we've recovered */
 	hw_addr = READ_ONCE(interface->uc_addr);
 	value = readl(hw_addr);
 	if (~value) {
+		/* Make sure the reset was initiated because we detached,
+		 * otherwise we might race with a different reset flow.
+		 */
+		if (!test_and_clear_bit(__FM10K_RESET_DETACHED,
+					interface->state))
+			return;
+
+		/* Restore the hardware address */
 		interface->hw.hw_addr = interface->uc_addr;
+
+		/* PCIe link has been restored, and the device is active
+		 * again. Restore everything and reset the device.
+		 */
+		err = fm10k_handle_reset(interface);
+		if (err) {
+			netdev_err(netdev, "Unable to reset device: %d\n", err);
+			interface->hw.hw_addr = NULL;
+			return;
+		}
+
+		/* Re-attach the netdev */
 		netif_device_attach(netdev);
-		set_bit(FM10K_FLAG_RESET_REQUESTED, interface->flags);
 		netdev_warn(netdev, "PCIe link restored, device now attached\n");
 		return;
 	}
-
-	rtnl_lock();
-
-	if (netif_running(netdev))
-		dev_close(netdev);
-
-	rtnl_unlock();
 }
 
-static void fm10k_reinit(struct fm10k_intfc *interface)
+static void fm10k_reset_subtask(struct fm10k_intfc *interface)
 {
 	int err;
 
-	fm10k_prepare_for_reset(interface);
-
-	err = fm10k_handle_reset(interface);
-	if (err)
-		dev_err(&interface->pdev->dev,
-			"fm10k_handle_reset failed: %d\n", err);
-}
-
-static void fm10k_reset_subtask(struct fm10k_intfc *interface)
-{
 	if (!test_and_clear_bit(FM10K_FLAG_RESET_REQUESTED,
 				interface->flags))
 		return;
 
+	/* If another thread has already prepared to reset the device, we
+	 * should not attempt to handle a reset here, since we'd race with
+	 * that thread. This may happen if we suspend the device or if the
+	 * PCIe link is lost. In this case, we'll just ignore the RESET
+	 * request, as it will (eventually) be taken care of when the thread
+	 * which actually started the reset is finished.
+	 */
+	if (!fm10k_prepare_for_reset(interface))
+		return;
+
 	netdev_err(interface->netdev, "Reset interface\n");
 
-	fm10k_reinit(interface);
+	err = fm10k_handle_reset(interface);
+	if (err)
+		dev_err(&interface->pdev->dev,
+			"fm10k_handle_reset failed: %d\n", err);
 }
 
 /**
@@ -381,6 +418,10 @@ static void fm10k_watchdog_update_host_state(struct fm10k_intfc *interface)
  **/
 static void fm10k_mbx_subtask(struct fm10k_intfc *interface)
 {
+	/* If we're resetting, bail out */
+	if (test_bit(__FM10K_RESETTING, interface->state))
+		return;
+
 	/* process upstream mailbox and update device state */
 	fm10k_watchdog_update_host_state(interface);
 
@@ -630,9 +671,11 @@ static void fm10k_service_task(struct work_struct *work)
 
 	interface = container_of(work, struct fm10k_intfc, service_task);
 
+	/* Check whether we're detached first */
+	fm10k_detach_subtask(interface);
+
 	/* tasks run even when interface is down */
 	fm10k_mbx_subtask(interface);
-	fm10k_detach_subtask(interface);
 	fm10k_reset_subtask(interface);
 
 	/* tasks only run when interface is up */
@@ -2177,7 +2220,8 @@ static void fm10k_prepare_suspend(struct fm10k_intfc *interface)
 	 */
 	fm10k_stop_service_event(interface);
 
-	fm10k_prepare_for_reset(interface);
+	if (fm10k_prepare_for_reset(interface))
+		set_bit(__FM10K_RESET_SUSPENDED, interface->state);
 }
 
 static int fm10k_handle_resume(struct fm10k_intfc *interface)
@@ -2185,6 +2229,13 @@ static int fm10k_handle_resume(struct fm10k_intfc *interface)
 	struct fm10k_hw *hw = &interface->hw;
 	int err;
 
+	/* Even if we didn't properly prepare for reset in
+	 * fm10k_prepare_suspend, we'll attempt to resume anyways.
+	 */
+	if (!test_and_clear_bit(__FM10K_RESET_SUSPENDED, interface->state))
+		dev_warn(&interface->pdev->dev,
+			 "Device was shut down as part of suspend... Attempting to recover\n");
+
 	/* reset statistics starting values */
 	hw->mac.ops.rebind_hw_stats(hw, &interface->stats);
 
-- 
2.14.2
