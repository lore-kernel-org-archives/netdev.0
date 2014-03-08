From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/15] e1000e Refactor of Runtime Power Management
Date: Sat,  8 Mar 2014 01:25:34 -0800
Message-ID: <1394270741-29926-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394270741-29926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: David Ertman <davidx.m.ertman@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:51114 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751103AbaCHJZt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Mar 2014 04:25:49 -0500
In-Reply-To: <1394270741-29926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ertman <davidx.m.ertman@intel.com>

Fix issues with:
RuntimePM causing the device to repeatedly flip between suspend and resume
with the interface administratively downed.
Having RuntimePM enabled interfering with the functionality of Energy
Efficient Ethernet.

Added checks to disallow functions that should not be executed if the
device is currently runtime suspended

Make runtime_idle callback to use same deterministic behavior as the igb
driver.

Signed-off-by: Dave Ertman <davidx.m.ertman@intel.com>
Acked-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/e1000.h  |  1 -
 drivers/net/ethernet/intel/e1000e/netdev.c | 77 ++++++++++++++++++------------
 2 files changed, 46 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000.h
index 129a9c3..5325e3e 100644
--- a/drivers/net/ethernet/intel/e1000e/e1000.h
+++ b/drivers/net/ethernet/intel/e1000e/e1000.h
@@ -326,7 +326,6 @@ struct e1000_adapter {
 	struct work_struct update_phy_task;
 	struct work_struct print_hang_task;
 
-	bool idle_check;
 	int phy_hang_count;
 
 	u16 tx_ring_count;
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 2669fdc..7fd1fea 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -3327,6 +3327,9 @@ static void e1000e_set_rx_mode(struct net_device *netdev)
 	struct e1000_hw *hw = &adapter->hw;
 	u32 rctl;
 
+	if (pm_runtime_suspended(netdev->dev.parent))
+		return;
+
 	/* Check for Promiscuous and All Multicast modes */
 	rctl = er32(RCTL);
 
@@ -4317,7 +4320,6 @@ static int e1000_open(struct net_device *netdev)
 	adapter->tx_hang_recheck = false;
 	netif_start_queue(netdev);
 
-	adapter->idle_check = true;
 	hw->mac.get_link_status = true;
 	pm_runtime_put(&pdev->dev);
 
@@ -4369,6 +4371,9 @@ static int e1000_close(struct net_device *netdev)
 	if (!test_bit(__E1000_DOWN, &adapter->state)) {
 		e1000e_down(adapter, true);
 		e1000_free_irq(adapter);
+
+		/* Link status message must follow this format */
+		pr_info("%s NIC Link is Down\n", adapter->netdev->name);
 	}
 
 	napi_disable(&adapter->napi);
@@ -5678,6 +5683,9 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 	adapter->max_frame_size = max_frame;
 	e_info("changing MTU from %d to %d\n", netdev->mtu, new_mtu);
 	netdev->mtu = new_mtu;
+
+	pm_runtime_get_sync(netdev->dev.parent);
+
 	if (netif_running(netdev))
 		e1000e_down(adapter, true);
 
@@ -5705,6 +5713,8 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 	else
 		e1000e_reset(adapter);
 
+	pm_runtime_put_sync(netdev->dev.parent);
+
 	clear_bit(__E1000_RESETTING, &adapter->state);
 
 	return 0;
@@ -5979,6 +5989,9 @@ static int __e1000_shutdown(struct pci_dev *pdev, bool runtime)
 			ew32(CTRL_EXT, ctrl_ext);
 		}
 
+		if (!runtime)
+			e1000e_power_up_phy(adapter);
+
 		if (adapter->flags & FLAG_IS_ICH)
 			e1000_suspend_workarounds_ich8lan(&adapter->hw);
 
@@ -6108,11 +6121,6 @@ static void e1000e_disable_aspm(struct pci_dev *pdev, u16 state)
 }
 
 #ifdef CONFIG_PM
-static bool e1000e_pm_ready(struct e1000_adapter *adapter)
-{
-	return !!adapter->tx_ring->buffer_info;
-}
-
 static int __e1000_resume(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
@@ -6167,11 +6175,6 @@ static int __e1000_resume(struct pci_dev *pdev)
 
 	e1000_init_manageability_pt(adapter);
 
-	if (netif_running(netdev))
-		e1000e_up(adapter);
-
-	netif_device_attach(netdev);
-
 	/* If the controller has AMT, do not set DRV_LOAD until the interface
 	 * is up.  For all other cases, let the f/w know that the h/w is now
 	 * under the control of the driver.
@@ -6226,47 +6229,59 @@ static int e1000e_pm_resume(struct device *dev)
 #endif /* CONFIG_PM_SLEEP */
 
 #ifdef CONFIG_PM_RUNTIME
-static int e1000_runtime_suspend(struct device *dev)
+static int e1000e_pm_runtime_idle(struct device *dev)
 {
 	struct pci_dev *pdev = to_pci_dev(dev);
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 
-	if (!e1000e_pm_ready(adapter))
-		return 0;
+	if (!e1000e_has_link(adapter))
+		pm_schedule_suspend(dev, 5 * MSEC_PER_SEC);
 
-	return __e1000_shutdown(pdev, true);
+	return -EBUSY;
 }
 
-static int e1000_idle(struct device *dev)
+static int e1000e_pm_runtime_resume(struct device *dev)
 {
 	struct pci_dev *pdev = to_pci_dev(dev);
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev_priv(netdev);
+	int rc;
 
-	if (!e1000e_pm_ready(adapter))
-		return 0;
+	rc = __e1000_resume(pdev);
+	if (rc)
+		return rc;
 
-	if (adapter->idle_check) {
-		adapter->idle_check = false;
-		if (!e1000e_has_link(adapter))
-			pm_schedule_suspend(dev, MSEC_PER_SEC);
-	}
+	if (netdev->flags & IFF_UP)
+		rc = e1000e_up(adapter);
 
-	return -EBUSY;
+	return rc;
 }
 
-static int e1000_runtime_resume(struct device *dev)
+static int e1000e_pm_runtime_suspend(struct device *dev)
 {
 	struct pci_dev *pdev = to_pci_dev(dev);
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 
-	if (!e1000e_pm_ready(adapter))
-		return 0;
+	if (netdev->flags & IFF_UP) {
+		int count = E1000_CHECK_RESET_COUNT;
+
+		while (test_bit(__E1000_RESETTING, &adapter->state) && count--)
+			usleep_range(10000, 20000);
 
-	adapter->idle_check = !dev->power.runtime_auto;
-	return __e1000_resume(pdev);
+		WARN_ON(test_bit(__E1000_RESETTING, &adapter->state));
+
+		/* Down the device without resetting the hardware */
+		e1000e_down(adapter, false);
+	}
+
+	if (__e1000_shutdown(pdev, true)) {
+		e1000e_pm_runtime_resume(dev);
+		return -EBUSY;
+	}
+
+	return 0;
 }
 #endif /* CONFIG_PM_RUNTIME */
 #endif /* CONFIG_PM */
@@ -7051,8 +7066,8 @@ static const struct dev_pm_ops e1000_pm_ops = {
 	.thaw		= e1000e_pm_thaw,
 	.poweroff	= e1000e_pm_suspend,
 	.restore	= e1000e_pm_resume,
-	SET_RUNTIME_PM_OPS(e1000_runtime_suspend, e1000_runtime_resume,
-			   e1000_idle)
+	SET_RUNTIME_PM_OPS(e1000e_pm_runtime_suspend, e1000e_pm_runtime_resume,
+			   e1000e_pm_runtime_idle)
 };
 
 /* PCI Device API Driver */
-- 
1.8.3.1
