From: "Yan, Zheng" <zheng.z.yan@intel.com>
Subject: [PATCH net-next V2] igb: add basic runtime PM support
Date: Wed, 21 Dec 2011 13:21:06 +0800
Message-ID: <4EF16CC2.80806@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	peter.p.waskiewicz.jr@intel.com, alexander.h.duyck@intel.com,
	john.ronciak@intel.com, rjw@sisk.pl
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:45358 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751097Ab1LUFVJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Dec 2011 00:21:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the runtime power management framework to add basic runtime PM support
to the igb driver. Namely, make the driver suspend the device when the link
is off and set it up for generating a wakeup event after the link has been
detected again. This feature is disabled by default.

Based on e1000e's runtime PM code.

Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>
---
Changes since v1:
Don't suspend the device when shutting down the interface.
Avoid race between runtime suspending and ethtool operations.

 drivers/net/ethernet/intel/igb/igb_ethtool.c |   16 +++
 drivers/net/ethernet/intel/igb/igb_main.c    |  136 ++++++++++++++++++++++----
 2 files changed, 133 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index e9335ef..3411073 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -36,6 +36,7 @@
 #include <linux/ethtool.h>
 #include <linux/sched.h>
 #include <linux/slab.h>
+#include <linux/pm_runtime.h>
 
 #include "igb.h"
 
@@ -2159,6 +2160,19 @@ static void igb_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
 	}
 }
 
+static int igb_ethtool_begin(struct net_device *netdev)
+{
+	struct igb_adapter *adapter = netdev_priv(netdev);
+	pm_runtime_get_sync(&adapter->pdev->dev);
+	return 0;
+}
+
+static void igb_ethtool_complete(struct net_device *netdev)
+{
+	struct igb_adapter *adapter = netdev_priv(netdev);
+	pm_runtime_put(&adapter->pdev->dev);
+}
+
 static const struct ethtool_ops igb_ethtool_ops = {
 	.get_settings           = igb_get_settings,
 	.set_settings           = igb_set_settings,
@@ -2185,6 +2199,8 @@ static const struct ethtool_ops igb_ethtool_ops = {
 	.get_ethtool_stats      = igb_get_ethtool_stats,
 	.get_coalesce           = igb_get_coalesce,
 	.set_coalesce           = igb_set_coalesce,
+	.begin			= igb_ethtool_begin,
+	.complete		= igb_ethtool_complete,
 };
 
 void igb_set_ethtool_ops(struct net_device *netdev)
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 143cfeb..aecfbf5 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -53,6 +53,7 @@
 #include <linux/if_ether.h>
 #include <linux/aer.h>
 #include <linux/prefetch.h>
+#include <linux/pm_runtime.h>
 #ifdef CONFIG_IGB_DCA
 #include <linux/dca.h>
 #endif
@@ -172,8 +173,18 @@ static int igb_check_vf_assignment(struct igb_adapter *adapter);
 #endif
 
 #ifdef CONFIG_PM
-static int igb_suspend(struct pci_dev *, pm_message_t);
-static int igb_resume(struct pci_dev *);
+static int igb_suspend(struct device *);
+static int igb_resume(struct device *);
+#ifdef CONFIG_PM_RUNTIME
+static int igb_runtime_suspend(struct device *dev);
+static int igb_runtime_resume(struct device *dev);
+static int igb_runtime_idle(struct device *dev);
+#endif
+static const struct dev_pm_ops igb_pm_ops = {
+	SET_SYSTEM_SLEEP_PM_OPS(igb_suspend, igb_resume)
+	SET_RUNTIME_PM_OPS(igb_runtime_suspend, igb_runtime_resume,
+			igb_runtime_idle)
+};
 #endif
 static void igb_shutdown(struct pci_dev *);
 #ifdef CONFIG_IGB_DCA
@@ -214,9 +225,7 @@ static struct pci_driver igb_driver = {
 	.probe    = igb_probe,
 	.remove   = __devexit_p(igb_remove),
 #ifdef CONFIG_PM
-	/* Power Management Hooks */
-	.suspend  = igb_suspend,
-	.resume   = igb_resume,
+	.driver.pm = &igb_pm_ops,
 #endif
 	.shutdown = igb_shutdown,
 	.err_handler = &igb_err_handler
@@ -2111,6 +2120,8 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	default:
 		break;
 	}
+
+	pm_runtime_put_noidle(&pdev->dev);
 	return 0;
 
 err_register:
@@ -2150,6 +2161,8 @@ static void __devexit igb_remove(struct pci_dev *pdev)
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 
+	pm_runtime_get_noresume(&pdev->dev);
+
 	/*
 	 * The watchdog timer may be rescheduled, so explicitly
 	 * disable watchdog from being rescheduled.
@@ -2472,16 +2485,22 @@ static int __devinit igb_sw_init(struct igb_adapter *adapter)
  * handler is registered with the OS, the watchdog timer is started,
  * and the stack is notified that the interface is ready.
  **/
-static int igb_open(struct net_device *netdev)
+static int __igb_open(struct net_device *netdev, bool resuming)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
+	struct pci_dev *pdev = adapter->pdev;
 	int err;
 	int i;
 
 	/* disallow open during test */
-	if (test_bit(__IGB_TESTING, &adapter->state))
+	if (test_bit(__IGB_TESTING, &adapter->state)) {
+		WARN_ON(resuming);
 		return -EBUSY;
+	}
+
+	if (!resuming)
+		pm_runtime_get_sync(&pdev->dev);
 
 	netif_carrier_off(netdev);
 
@@ -2527,6 +2546,9 @@ static int igb_open(struct net_device *netdev)
 
 	netif_tx_start_all_queues(netdev);
 
+	if (!resuming)
+		pm_runtime_put(&pdev->dev);
+
 	/* start the watchdog. */
 	hw->mac.get_link_status = 1;
 	schedule_work(&adapter->watchdog_task);
@@ -2541,10 +2563,17 @@ err_setup_rx:
 	igb_free_all_tx_resources(adapter);
 err_setup_tx:
 	igb_reset(adapter);
+	if (!resuming)
+		pm_runtime_put(&pdev->dev);
 
 	return err;
 }
 
+static int igb_open(struct net_device *netdev)
+{
+	return __igb_open(netdev, false);
+}
+
 /**
  * igb_close - Disables a network interface
  * @netdev: network interface device structure
@@ -2556,21 +2585,32 @@ err_setup_tx:
  * needs to be disabled.  A global MAC reset is issued to stop the
  * hardware, and all transmit and receive resources are freed.
  **/
-static int igb_close(struct net_device *netdev)
+static int __igb_close(struct net_device *netdev, bool suspending)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
+	struct pci_dev *pdev = adapter->pdev;
 
 	WARN_ON(test_bit(__IGB_RESETTING, &adapter->state));
-	igb_down(adapter);
 
+	if (!suspending)
+		pm_runtime_get_sync(&pdev->dev);
+
+	igb_down(adapter);
 	igb_free_irq(adapter);
 
 	igb_free_all_tx_resources(adapter);
 	igb_free_all_rx_resources(adapter);
 
+	if (!suspending)
+		pm_runtime_put_sync(&pdev->dev);
 	return 0;
 }
 
+static int igb_close(struct net_device *netdev)
+{
+	return __igb_close(netdev, false);
+}
+
 /**
  * igb_setup_tx_resources - allocate Tx resources (Descriptors)
  * @tx_ring: tx descriptor ring (for a specific queue) to setup
@@ -3630,6 +3670,9 @@ static void igb_watchdog_task(struct work_struct *work)
 
 	link = igb_has_link(adapter);
 	if (link) {
+		/* Cancel scheduled suspend requests. */
+		pm_runtime_resume(netdev->dev.parent);
+
 		if (!netif_carrier_ok(netdev)) {
 			u32 ctrl;
 			hw->mac.ops.get_speed_and_duplex(hw,
@@ -3701,6 +3744,9 @@ static void igb_watchdog_task(struct work_struct *work)
 			if (!test_bit(__IGB_DOWN, &adapter->state))
 				mod_timer(&adapter->phy_info_timer,
 					  round_jiffies(jiffies + 2 * HZ));
+
+			pm_schedule_suspend(netdev->dev.parent,
+					    MSEC_PER_SEC * 5);
 		}
 	}
 
@@ -6579,13 +6625,14 @@ err_inval:
 	return -EINVAL;
 }
 
-static int __igb_shutdown(struct pci_dev *pdev, bool *enable_wake)
+static int __igb_shutdown(struct pci_dev *pdev, bool *enable_wake,
+			  bool runtime)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 	u32 ctrl, rctl, status;
-	u32 wufc = adapter->wol;
+	u32 wufc = runtime ? E1000_WUFC_LNKC : adapter->wol;
 #ifdef CONFIG_PM
 	int retval = 0;
 #endif
@@ -6593,7 +6640,7 @@ static int __igb_shutdown(struct pci_dev *pdev, bool *enable_wake)
 	netif_device_detach(netdev);
 
 	if (netif_running(netdev))
-		igb_close(netdev);
+		__igb_close(netdev, true);
 
 	igb_clear_interrupt_scheme(adapter);
 
@@ -6652,12 +6699,13 @@ static int __igb_shutdown(struct pci_dev *pdev, bool *enable_wake)
 }
 
 #ifdef CONFIG_PM
-static int igb_suspend(struct pci_dev *pdev, pm_message_t state)
+static int igb_suspend(struct device *dev)
 {
 	int retval;
 	bool wake;
+	struct pci_dev *pdev = to_pci_dev(dev);
 
-	retval = __igb_shutdown(pdev, &wake);
+	retval = __igb_shutdown(pdev, &wake, 0);
 	if (retval)
 		return retval;
 
@@ -6671,8 +6719,9 @@ static int igb_suspend(struct pci_dev *pdev, pm_message_t state)
 	return 0;
 }
 
-static int igb_resume(struct pci_dev *pdev)
+static int igb_resume(struct device *dev)
 {
+	struct pci_dev *pdev = to_pci_dev(dev);
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
@@ -6693,7 +6742,18 @@ static int igb_resume(struct pci_dev *pdev)
 	pci_enable_wake(pdev, PCI_D3hot, 0);
 	pci_enable_wake(pdev, PCI_D3cold, 0);
 
-	if (igb_init_interrupt_scheme(adapter)) {
+	if (!rtnl_is_locked()) {
+		/*
+		 * shut up ASSERT_RTNL() warning in
+		 * netif_set_real_num_tx/rx_queues.
+		 */
+		rtnl_lock();
+		err = igb_init_interrupt_scheme(adapter);
+		rtnl_unlock();
+	} else {
+		err = igb_init_interrupt_scheme(adapter);
+	}
+	if (err) {
 		dev_err(&pdev->dev, "Unable to allocate memory for queues\n");
 		return -ENOMEM;
 	}
@@ -6706,23 +6766,61 @@ static int igb_resume(struct pci_dev *pdev)
 
 	wr32(E1000_WUS, ~0);
 
-	if (netif_running(netdev)) {
-		err = igb_open(netdev);
+	if (netdev->flags & IFF_UP) {
+		err = __igb_open(netdev, true);
 		if (err)
 			return err;
 	}
 
 	netif_device_attach(netdev);
+	return 0;
+}
+
+#ifdef CONFIG_PM_RUNTIME
+static int igb_runtime_idle(struct device *dev)
+{
+	struct pci_dev *pdev = to_pci_dev(dev);
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct igb_adapter *adapter = netdev_priv(netdev);
+
+	if (!igb_has_link(adapter))
+		pm_schedule_suspend(dev, MSEC_PER_SEC * 5);
+
+	return -EBUSY;
+}
+
+static int igb_runtime_suspend(struct device *dev)
+{
+	struct pci_dev *pdev = to_pci_dev(dev);
+	int retval;
+	bool wake;
+
+	retval = __igb_shutdown(pdev, &wake, 1);
+	if (retval)
+		return retval;
+
+	if (wake) {
+		pci_prepare_to_sleep(pdev);
+	} else {
+		pci_wake_from_d3(pdev, false);
+		pci_set_power_state(pdev, PCI_D3hot);
+	}
 
 	return 0;
 }
+
+static int igb_runtime_resume(struct device *dev)
+{
+	return igb_resume(dev);
+}
+#endif /* CONFIG_PM_RUNTIME */
 #endif
 
 static void igb_shutdown(struct pci_dev *pdev)
 {
 	bool wake;
 
-	__igb_shutdown(pdev, &wake);
+	__igb_shutdown(pdev, &wake, 0);
 
 	if (system_state == SYSTEM_POWER_OFF) {
 		pci_wake_from_d3(pdev, wake);
-- 
1.7.7.4
