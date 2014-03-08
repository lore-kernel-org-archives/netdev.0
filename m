From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/15] e1000e: Refactor PM flows
Date: Sat,  8 Mar 2014 01:25:33 -0800
Message-ID: <1394270741-29926-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394270741-29926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: David Ertman <davidx.m.ertman@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:23968 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751512AbaCHJZs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Mar 2014 04:25:48 -0500
In-Reply-To: <1394270741-29926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ertman <davidx.m.ertman@intel.com>

Refactor the system power management flows to prevent the suspend path from
being executed twice when hibernating since both the freeze and
poweroff callbacks were set to e1000_suspend() via SET_SYSTEM_SLEEP_PM_OPS.
There are HW workarounds that are performed during this flow and calling
them twice was causing erroneous behavior.

Re-arrange the code to take advantage of common code paths and explicitly
set the individual dev_pm_ops callbacks for suspend, resume, freeze,
thaw, poweroff and restore.

Add a boolean parameter (reset) to the e1000e_down function to allow
for cases when the HW should not be reset when downed during a PM event.

Now that all suspend/shutdown paths result in a call to __e1000_shutdown()
that checks Wake on Lan status, removing redundant check for WoL in
e1000_power_down_phy().

Signed-off-by: Dave Ertman <davidx.m.ertman@intel.com>
Acked-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/e1000.h   |   2 +-
 drivers/net/ethernet/intel/e1000e/ethtool.c |   6 +-
 drivers/net/ethernet/intel/e1000e/netdev.c  | 125 ++++++++++++++++------------
 3 files changed, 78 insertions(+), 55 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000.h
index 4b8e88f..129a9c3 100644
--- a/drivers/net/ethernet/intel/e1000e/e1000.h
+++ b/drivers/net/ethernet/intel/e1000e/e1000.h
@@ -469,7 +469,7 @@ void e1000e_check_options(struct e1000_adapter *adapter);
 void e1000e_set_ethtool_ops(struct net_device *netdev);
 
 int e1000e_up(struct e1000_adapter *adapter);
-void e1000e_down(struct e1000_adapter *adapter);
+void e1000e_down(struct e1000_adapter *adapter, bool reset);
 void e1000e_reinit_locked(struct e1000_adapter *adapter);
 void e1000e_reset(struct e1000_adapter *adapter);
 void e1000e_power_up_phy(struct e1000_adapter *adapter);
diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index 0a075f7..7a47902 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -325,7 +325,7 @@ static int e1000_set_settings(struct net_device *netdev,
 
 	/* reset the link */
 	if (netif_running(adapter->netdev)) {
-		e1000e_down(adapter);
+		e1000e_down(adapter, true);
 		e1000e_up(adapter);
 	} else {
 		e1000e_reset(adapter);
@@ -373,7 +373,7 @@ static int e1000_set_pauseparam(struct net_device *netdev,
 	if (adapter->fc_autoneg == AUTONEG_ENABLE) {
 		hw->fc.requested_mode = e1000_fc_default;
 		if (netif_running(adapter->netdev)) {
-			e1000e_down(adapter);
+			e1000e_down(adapter, true);
 			e1000e_up(adapter);
 		} else {
 			e1000e_reset(adapter);
@@ -719,7 +719,7 @@ static int e1000_set_ringparam(struct net_device *netdev,
 
 	pm_runtime_get_sync(netdev->dev.parent);
 
-	e1000e_down(adapter);
+	e1000e_down(adapter, true);
 
 	/* We can't just free everything and then setup again, because the
 	 * ISRs in MSI-X mode get passed pointers to the Tx and Rx ring
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index a69388c..2669fdc 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -3687,10 +3687,6 @@ void e1000e_power_up_phy(struct e1000_adapter *adapter)
  */
 static void e1000_power_down_phy(struct e1000_adapter *adapter)
 {
-	/* WoL is enabled */
-	if (adapter->wol)
-		return;
-
 	if (adapter->hw.phy.ops.power_down)
 		adapter->hw.phy.ops.power_down(&adapter->hw);
 }
@@ -3907,10 +3903,8 @@ void e1000e_reset(struct e1000_adapter *adapter)
 	}
 
 	if (!netif_running(adapter->netdev) &&
-	    !test_bit(__E1000_TESTING, &adapter->state)) {
+	    !test_bit(__E1000_TESTING, &adapter->state))
 		e1000_power_down_phy(adapter);
-		return;
-	}
 
 	e1000_get_phy_info(hw);
 
@@ -3977,7 +3971,12 @@ static void e1000e_flush_descriptors(struct e1000_adapter *adapter)
 
 static void e1000e_update_stats(struct e1000_adapter *adapter);
 
-void e1000e_down(struct e1000_adapter *adapter)
+/**
+ * e1000e_down - quiesce the device and optionally reset the hardware
+ * @adapter: board private structure
+ * @reset: boolean flag to reset the hardware or not
+ */
+void e1000e_down(struct e1000_adapter *adapter, bool reset)
 {
 	struct net_device *netdev = adapter->netdev;
 	struct e1000_hw *hw = &adapter->hw;
@@ -4031,12 +4030,8 @@ void e1000e_down(struct e1000_adapter *adapter)
 	    e1000_lv_jumbo_workaround_ich8lan(hw, false))
 		e_dbg("failed to disable jumbo frame workaround mode\n");
 
-	if (!pci_channel_offline(adapter->pdev))
+	if (reset && !pci_channel_offline(adapter->pdev))
 		e1000e_reset(adapter);
-
-	/* TODO: for power management, we could drop the link and
-	 * pci_disable_device here.
-	 */
 }
 
 void e1000e_reinit_locked(struct e1000_adapter *adapter)
@@ -4044,7 +4039,7 @@ void e1000e_reinit_locked(struct e1000_adapter *adapter)
 	might_sleep();
 	while (test_and_set_bit(__E1000_RESETTING, &adapter->state))
 		usleep_range(1000, 2000);
-	e1000e_down(adapter);
+	e1000e_down(adapter, true);
 	e1000e_up(adapter);
 	clear_bit(__E1000_RESETTING, &adapter->state);
 }
@@ -4372,14 +4367,12 @@ static int e1000_close(struct net_device *netdev)
 	pm_runtime_get_sync(&pdev->dev);
 
 	if (!test_bit(__E1000_DOWN, &adapter->state)) {
-		e1000e_down(adapter);
+		e1000e_down(adapter, true);
 		e1000_free_irq(adapter);
 	}
 
 	napi_disable(&adapter->napi);
 
-	e1000_power_down_phy(adapter);
-
 	e1000e_free_tx_resources(adapter->tx_ring);
 	e1000e_free_rx_resources(adapter->rx_ring);
 
@@ -5686,7 +5679,7 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 	e_info("changing MTU from %d to %d\n", netdev->mtu, new_mtu);
 	netdev->mtu = new_mtu;
 	if (netif_running(netdev))
-		e1000e_down(adapter);
+		e1000e_down(adapter, true);
 
 	/* NOTE: netdev_alloc_skb reserves 16 bytes, and typically NET_IP_ALIGN
 	 * means we reserve 2 more, this pushes us to allocate from the next
@@ -5919,15 +5912,10 @@ release:
 	return retval;
 }
 
-static int __e1000_shutdown(struct pci_dev *pdev, bool runtime)
+static int e1000e_pm_freeze(struct device *dev)
 {
-	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct net_device *netdev = pci_get_drvdata(to_pci_dev(dev));
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	struct e1000_hw *hw = &adapter->hw;
-	u32 ctrl, ctrl_ext, rctl, status;
-	/* Runtime suspend should only enable wakeup for link changes */
-	u32 wufc = runtime ? E1000_WUFC_LNKC : adapter->wol;
-	int retval = 0;
 
 	netif_device_detach(netdev);
 
@@ -5938,11 +5926,29 @@ static int __e1000_shutdown(struct pci_dev *pdev, bool runtime)
 			usleep_range(10000, 20000);
 
 		WARN_ON(test_bit(__E1000_RESETTING, &adapter->state));
-		e1000e_down(adapter);
+
+		/* Quiesce the device without resetting the hardware */
+		e1000e_down(adapter, false);
 		e1000_free_irq(adapter);
 	}
 	e1000e_reset_interrupt_capability(adapter);
 
+	/* Allow time for pending master requests to run */
+	e1000e_disable_pcie_master(&adapter->hw);
+
+	return 0;
+}
+
+static int __e1000_shutdown(struct pci_dev *pdev, bool runtime)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
+	u32 ctrl, ctrl_ext, rctl, status;
+	/* Runtime suspend should only enable wakeup for link changes */
+	u32 wufc = runtime ? E1000_WUFC_LNKC : adapter->wol;
+	int retval = 0;
+
 	status = er32(STATUS);
 	if (status & E1000_STATUS_LU)
 		wufc &= ~E1000_WUFC_LNKC;
@@ -5976,9 +5982,6 @@ static int __e1000_shutdown(struct pci_dev *pdev, bool runtime)
 		if (adapter->flags & FLAG_IS_ICH)
 			e1000_suspend_workarounds_ich8lan(&adapter->hw);
 
-		/* Allow time for pending master requests to run */
-		e1000e_disable_pcie_master(&adapter->hw);
-
 		if (adapter->flags2 & FLAG2_HAS_PHY_WAKEUP) {
 			/* enable wakeup by the PHY */
 			retval = e1000_init_phy_wakeup(adapter, wufc);
@@ -5992,6 +5995,8 @@ static int __e1000_shutdown(struct pci_dev *pdev, bool runtime)
 	} else {
 		ew32(WUC, 0);
 		ew32(WUFC, 0);
+
+		e1000_power_down_phy(adapter);
 	}
 
 	if (adapter->hw.phy.type == e1000_phy_igp_3)
@@ -6114,7 +6119,6 @@ static int __e1000_resume(struct pci_dev *pdev)
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 	u16 aspm_disable_flag = 0;
-	u32 err;
 
 	if (adapter->flags2 & FLAG2_DISABLE_ASPM_L0S)
 		aspm_disable_flag = PCIE_LINK_STATE_L0S;
@@ -6125,13 +6129,6 @@ static int __e1000_resume(struct pci_dev *pdev)
 
 	pci_set_master(pdev);
 
-	e1000e_set_interrupt_capability(adapter);
-	if (netif_running(netdev)) {
-		err = e1000_request_irq(adapter);
-		if (err)
-			return err;
-	}
-
 	if (hw->mac.type >= e1000_pch2lan)
 		e1000_resume_workarounds_pchlan(&adapter->hw);
 
@@ -6185,24 +6182,46 @@ static int __e1000_resume(struct pci_dev *pdev)
 	return 0;
 }
 
+static int e1000e_pm_thaw(struct device *dev)
+{
+	struct net_device *netdev = pci_get_drvdata(to_pci_dev(dev));
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+
+	e1000e_set_interrupt_capability(adapter);
+	if (netif_running(netdev)) {
+		u32 err = e1000_request_irq(adapter);
+
+		if (err)
+			return err;
+
+		e1000e_up(adapter);
+	}
+
+	netif_device_attach(netdev);
+
+	return 0;
+}
+
 #ifdef CONFIG_PM_SLEEP
-static int e1000_suspend(struct device *dev)
+static int e1000e_pm_suspend(struct device *dev)
 {
 	struct pci_dev *pdev = to_pci_dev(dev);
 
+	e1000e_pm_freeze(dev);
+
 	return __e1000_shutdown(pdev, false);
 }
 
-static int e1000_resume(struct device *dev)
+static int e1000e_pm_resume(struct device *dev)
 {
 	struct pci_dev *pdev = to_pci_dev(dev);
-	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct e1000_adapter *adapter = netdev_priv(netdev);
+	int rc;
 
-	if (e1000e_pm_ready(adapter))
-		adapter->idle_check = true;
+	rc = __e1000_resume(pdev);
+	if (rc)
+		return rc;
 
-	return __e1000_resume(pdev);
+	return e1000e_pm_thaw(dev);
 }
 #endif /* CONFIG_PM_SLEEP */
 
@@ -6254,6 +6273,8 @@ static int e1000_runtime_resume(struct device *dev)
 
 static void e1000_shutdown(struct pci_dev *pdev)
 {
+	e1000e_pm_freeze(&pdev->dev);
+
 	__e1000_shutdown(pdev, false);
 }
 
@@ -6339,7 +6360,7 @@ static pci_ers_result_t e1000_io_error_detected(struct pci_dev *pdev,
 		return PCI_ERS_RESULT_DISCONNECT;
 
 	if (netif_running(netdev))
-		e1000e_down(adapter);
+		e1000e_down(adapter, true);
 	pci_disable_device(pdev);
 
 	/* Request a slot slot reset. */
@@ -6351,7 +6372,7 @@ static pci_ers_result_t e1000_io_error_detected(struct pci_dev *pdev,
  * @pdev: Pointer to PCI device
  *
  * Restart the card from scratch, as if from a cold-boot. Implementation
- * resembles the first-half of the e1000_resume routine.
+ * resembles the first-half of the e1000e_pm_resume routine.
  */
 static pci_ers_result_t e1000_io_slot_reset(struct pci_dev *pdev)
 {
@@ -6398,7 +6419,7 @@ static pci_ers_result_t e1000_io_slot_reset(struct pci_dev *pdev)
  *
  * This callback is called when the error recovery driver tells us that
  * its OK to resume normal operation. Implementation resembles the
- * second-half of the e1000_resume routine.
+ * second-half of the e1000e_pm_resume routine.
  */
 static void e1000_io_resume(struct pci_dev *pdev)
 {
@@ -6903,9 +6924,6 @@ static void e1000_remove(struct pci_dev *pdev)
 		}
 	}
 
-	if (!(netdev->flags & IFF_UP))
-		e1000_power_down_phy(adapter);
-
 	/* Don't lie to e1000_close() down the road. */
 	if (!down)
 		clear_bit(__E1000_DOWN, &adapter->state);
@@ -7027,7 +7045,12 @@ static DEFINE_PCI_DEVICE_TABLE(e1000_pci_tbl) = {
 MODULE_DEVICE_TABLE(pci, e1000_pci_tbl);
 
 static const struct dev_pm_ops e1000_pm_ops = {
-	SET_SYSTEM_SLEEP_PM_OPS(e1000_suspend, e1000_resume)
+	.suspend	= e1000e_pm_suspend,
+	.resume		= e1000e_pm_resume,
+	.freeze		= e1000e_pm_freeze,
+	.thaw		= e1000e_pm_thaw,
+	.poweroff	= e1000e_pm_suspend,
+	.restore	= e1000e_pm_resume,
 	SET_RUNTIME_PM_OPS(e1000_runtime_suspend, e1000_runtime_resume,
 			   e1000_idle)
 };
-- 
1.8.3.1
