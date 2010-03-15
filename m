From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [PATCH 2/2] e1000e / PCI / PM: Add basic runtime PM
	support (rev. 4)
Date: Mon, 15 Mar 2010 01:35:17 +0100
Message-ID: <201003150135.17564.rjw@sisk.pl>
References: <201003150131.59619.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Matthew Garrett <mjg59@srcf.ucam.org>, e1000-devel@lists.sourceforge.net,
	Linux PCI <linux-pci@vger.kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	pm list <linux-pm@lists.linux-foundation.org>
To: NetDev <netdev@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <201003150131.59619.rjw@sisk.pl>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Rafael J. Wysocki <rjw@sisk.pl>

Use the PCI runtime power management framework to add basic PCI
runtime PM support to the e1000e driver.  Namely, make the driver
suspend the device when the link is off and set it up for generating
a wakeup event after the link has been detected again.  [This
feature is disabled until the user space enables it with the help of
the /sys/devices/.../power/contol device attribute.]

Based on a patch from Matthew Garrett.

Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
---
 drivers/net/e1000e/e1000.h  |    5 +
 drivers/net/e1000e/netdev.c |  160 ++++++++++++++++++++++++++++++++++++--------
 2 files changed, 138 insertions(+), 27 deletions(-)

Index: linux-2.6/drivers/net/e1000e/netdev.c
===================================================================
--- linux-2.6.orig/drivers/net/e1000e/netdev.c
+++ linux-2.6/drivers/net/e1000e/netdev.c
@@ -44,6 +44,7 @@
 #include <linux/cpu.h>
 #include <linux/smp.h>
 #include <linux/pm_qos_params.h>
+#include <linux/pm_runtime.h>
 #include <linux/aer.h>
 
 #include "e1000.h"
@@ -3083,12 +3084,15 @@ static int e1000_open(struct net_device 
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
+	struct pci_dev *pdev = adapter->pdev;
 	int err;
 
 	/* disallow open during test */
 	if (test_bit(__E1000_TESTING, &adapter->state))
 		return -EBUSY;
 
+	pm_runtime_get_sync(&pdev->dev);
+
 	netif_carrier_off(netdev);
 
 	/* allocate transmit descriptors */
@@ -3149,6 +3153,9 @@ static int e1000_open(struct net_device 
 
 	netif_start_queue(netdev);
 
+	adapter->idle_check = true;
+	pm_runtime_put(&pdev->dev);
+
 	/* fire a link status change interrupt to start the watchdog */
 	ew32(ICS, E1000_ICS_LSC);
 
@@ -3162,6 +3169,7 @@ err_setup_rx:
 	e1000e_free_tx_resources(adapter);
 err_setup_tx:
 	e1000e_reset(adapter);
+	pm_runtime_put_sync(&pdev->dev);
 
 	return err;
 }
@@ -3180,11 +3188,17 @@ err_setup_tx:
 static int e1000_close(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct pci_dev *pdev = adapter->pdev;
 
 	WARN_ON(test_bit(__E1000_RESETTING, &adapter->state));
-	e1000e_down(adapter);
+
+	pm_runtime_get_sync(&pdev->dev);
+
+	if (!test_bit(__E1000_DOWN, &adapter->state)) {
+		e1000e_down(adapter);
+		e1000_free_irq(adapter);
+	}
 	e1000_power_down_phy(adapter);
-	e1000_free_irq(adapter);
 
 	e1000e_free_tx_resources(adapter);
 	e1000e_free_rx_resources(adapter);
@@ -3206,6 +3220,8 @@ static int e1000_close(struct net_device
 	if (adapter->flags & FLAG_HAS_AMT)
 		e1000_release_hw_control(adapter);
 
+	pm_runtime_put_sync(&pdev->dev);
+
 	return 0;
 }
 /**
@@ -3550,6 +3566,9 @@ static void e1000_watchdog_task(struct w
 
 	link = e1000e_has_link(adapter);
 	if ((netif_carrier_ok(netdev)) && link) {
+		/* Cancel scheduled suspend requests. */
+		pm_runtime_resume(netdev->dev.parent);
+
 		e1000e_enable_receives(adapter);
 		goto link_up;
 	}
@@ -3561,6 +3580,10 @@ static void e1000_watchdog_task(struct w
 	if (link) {
 		if (!netif_carrier_ok(netdev)) {
 			bool txb2b = 1;
+
+			/* Cancel scheduled suspend requests. */
+			pm_runtime_resume(netdev->dev.parent);
+
 			/* update snapshot of PHY registers on LSC */
 			e1000_phy_read_status(adapter);
 			mac->ops.get_link_up_info(&adapter->hw,
@@ -3676,6 +3699,9 @@ static void e1000_watchdog_task(struct w
 
 			if (adapter->flags & FLAG_RX_NEEDS_RESTART)
 				schedule_work(&adapter->reset_task);
+			else
+				pm_schedule_suspend(netdev->dev.parent,
+							LINK_TIMEOUT);
 		}
 	}
 
@@ -4473,13 +4499,15 @@ out:
 	return retval;
 }
 
-static int __e1000_shutdown(struct pci_dev *pdev, bool *enable_wake)
+static int __e1000_shutdown(struct pci_dev *pdev, bool *enable_wake,
+			    bool runtime)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 	u32 ctrl, ctrl_ext, rctl, status;
-	u32 wufc = adapter->wol;
+	/* Runtime suspend should only enable wakeup for link changes */
+	u32 wufc = runtime ? E1000_WUFC_LNKC : adapter->wol;
 	int retval = 0;
 
 	netif_device_detach(netdev);
@@ -4637,41 +4665,65 @@ static void e1000e_disable_l1aspm(struct
 }
 
 #ifdef CONFIG_PM
-static int e1000_suspend(struct pci_dev *pdev, pm_message_t state)
+static bool e1000e_pm_ready(struct e1000_adapter *adapter)
+{
+	return !!adapter->tx_ring->buffer_info;
+}
+
+static int e1000_idle(struct device *dev)
 {
+	struct pci_dev *pdev = to_pci_dev(dev);
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+
+	if (!e1000e_pm_ready(adapter))
+		return 0;
+
+	if (adapter->idle_check) {
+		adapter->idle_check = false;
+		if (!e1000e_has_link(adapter))
+			pm_schedule_suspend(dev, MSEC_PER_SEC);
+	}
+
+	return -EBUSY;
+}
+
+static int e1000_suspend(struct device *dev)
+{
+	struct pci_dev *pdev = to_pci_dev(dev);
 	int retval;
 	bool wake;
 
-	retval = __e1000_shutdown(pdev, &wake);
+	retval = __e1000_shutdown(pdev, &wake, false);
 	if (!retval)
 		e1000_complete_shutdown(pdev, true, wake);
 
 	return retval;
 }
 
-static int e1000_resume(struct pci_dev *pdev)
+static int e1000_runtime_suspend(struct device *dev)
 {
+	struct pci_dev *pdev = to_pci_dev(dev);
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	struct e1000_hw *hw = &adapter->hw;
-	u32 err;
 
-	pci_set_power_state(pdev, PCI_D0);
-	pci_restore_state(pdev);
-	pci_save_state(pdev);
-	e1000e_disable_l1aspm(pdev);
+	if (e1000e_pm_ready(adapter)) {
+		bool wake;
 
-	err = pci_enable_device_mem(pdev);
-	if (err) {
-		dev_err(&pdev->dev,
-			"Cannot enable PCI device from suspend\n");
-		return err;
+		__e1000_shutdown(pdev, &wake, true);
 	}
 
-	pci_set_master(pdev);
+	return 0;
+}
 
-	pci_enable_wake(pdev, PCI_D3hot, 0);
-	pci_enable_wake(pdev, PCI_D3cold, 0);
+static int __e1000_resume(struct pci_dev *pdev)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
+	u32 err;
+
+	e1000e_disable_l1aspm(pdev);
 
 	e1000e_set_interrupt_capability(adapter);
 	if (netif_running(netdev)) {
@@ -4730,13 +4782,38 @@ static int e1000_resume(struct pci_dev *
 
 	return 0;
 }
+
+static int e1000_resume(struct device *dev)
+{
+	struct pci_dev *pdev = to_pci_dev(dev);
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+
+	if (e1000e_pm_ready(adapter))
+		adapter->idle_check = true;
+
+	return __e1000_resume(pdev);
+}
+
+static int e1000_runtime_resume(struct device *dev)
+{
+	struct pci_dev *pdev = to_pci_dev(dev);
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+
+	if (!e1000e_pm_ready(adapter))
+		return 0;
+
+	adapter->idle_check = !dev->power.runtime_auto;
+	return __e1000_resume(pdev);
+}
 #endif
 
 static void e1000_shutdown(struct pci_dev *pdev)
 {
 	bool wake = false;
 
-	__e1000_shutdown(pdev, &wake);
+	__e1000_shutdown(pdev, &wake, false);
 
 	if (system_state == SYSTEM_POWER_OFF)
 		e1000_complete_shutdown(pdev, false, wake);
@@ -4809,8 +4886,8 @@ static pci_ers_result_t e1000_io_slot_re
 		result = PCI_ERS_RESULT_DISCONNECT;
 	} else {
 		pci_set_master(pdev);
+		pdev->state_saved = true;
 		pci_restore_state(pdev);
-		pci_save_state(pdev);
 
 		pci_enable_wake(pdev, PCI_D3hot, 0);
 		pci_enable_wake(pdev, PCI_D3cold, 0);
@@ -5217,6 +5294,12 @@ static int __devinit e1000_probe(struct 
 
 	e1000_print_device_info(adapter);
 
+	if (pci_dev_run_wake(pdev)) {
+		pm_runtime_set_active(&pdev->dev);
+		pm_runtime_enable(&pdev->dev);
+	}
+	pm_schedule_suspend(&pdev->dev, MSEC_PER_SEC);
+
 	return 0;
 
 err_register:
@@ -5259,12 +5342,16 @@ static void __devexit e1000_remove(struc
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev_priv(netdev);
+	bool down = test_bit(__E1000_DOWN, &adapter->state);
+
+	pm_runtime_get_sync(&pdev->dev);
 
 	/*
 	 * flush_scheduled work may reschedule our watchdog task, so
 	 * explicitly disable watchdog tasks from being rescheduled
 	 */
-	set_bit(__E1000_DOWN, &adapter->state);
+	if (!down)
+		set_bit(__E1000_DOWN, &adapter->state);
 	del_timer_sync(&adapter->watchdog_timer);
 	del_timer_sync(&adapter->phy_info_timer);
 
@@ -5278,8 +5365,17 @@ static void __devexit e1000_remove(struc
 	if (!(netdev->flags & IFF_UP))
 		e1000_power_down_phy(adapter);
 
+	/* Don't lie to e1000_close() down the road. */
+	if (!down)
+		clear_bit(__E1000_DOWN, &adapter->state);
 	unregister_netdev(netdev);
 
+	if (pci_dev_run_wake(pdev)) {
+		pm_runtime_disable(&pdev->dev);
+		pm_runtime_set_suspended(&pdev->dev);
+	}
+	pm_runtime_put_noidle(&pdev->dev);
+
 	/*
 	 * Release control of h/w to f/w.  If f/w is AMT enabled, this
 	 * would have already happened in close and is redundant.
@@ -5379,6 +5475,18 @@ static DEFINE_PCI_DEVICE_TABLE(e1000_pci
 };
 MODULE_DEVICE_TABLE(pci, e1000_pci_tbl);
 
+static const struct dev_pm_ops e1000_pm_ops = {
+	.suspend  = e1000_suspend,
+	.resume   = e1000_resume,
+	.freeze = e1000_suspend,
+	.thaw = e1000_resume,
+	.poweroff = e1000_suspend,
+	.restore = e1000_resume,
+	.runtime_suspend = e1000_runtime_suspend,
+	.runtime_resume = e1000_runtime_resume,
+	.runtime_idle = e1000_idle,
+};
+
 /* PCI Device API Driver */
 static struct pci_driver e1000_driver = {
 	.name     = e1000e_driver_name,
@@ -5386,9 +5494,7 @@ static struct pci_driver e1000_driver = 
 	.probe    = e1000_probe,
 	.remove   = __devexit_p(e1000_remove),
 #ifdef CONFIG_PM
-	/* Power Management Hooks */
-	.suspend  = e1000_suspend,
-	.resume   = e1000_resume,
+	.driver.pm = &e1000_pm_ops,
 #endif
 	.shutdown = e1000_shutdown,
 	.err_handler = &e1000_err_handler
Index: linux-2.6/drivers/net/e1000e/e1000.h
===================================================================
--- linux-2.6.orig/drivers/net/e1000e/e1000.h
+++ linux-2.6/drivers/net/e1000e/e1000.h
@@ -158,6 +158,9 @@ struct e1000_info;
 #define HV_M_STATUS_SPEED_1000            0x0200
 #define HV_M_STATUS_LINK_UP               0x0040
 
+/* Time to wait before putting the device into D3 if there's no link (in ms). */
+#define LINK_TIMEOUT		100
+
 enum e1000_boards {
 	board_82571,
 	board_82572,
@@ -370,6 +373,8 @@ struct e1000_adapter {
 	struct work_struct update_phy_task;
 	struct work_struct led_blink_task;
 	struct work_struct print_hang_task;
+
+	bool idle_check;
 };
 
 struct e1000_info {


------------------------------------------------------------------------------
Download Intel&#174; Parallel Studio Eval
Try the new software tools for yourself. Speed compiling, find bugs
proactively, and fine-tune applications for parallel performance.
See why Intel Parallel Studio got high marks during beta.
http://p.sf.net/sfu/intel-sw-dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
