From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: e1000e: Fix build with CONFIG_PM disabled.
Date: Wed, 17 Mar 2010 16:37:16 -0700
Message-ID: <1268869036.19191.92.camel@jbrandeb-mobl3.amr.corp.intel.com>
References: <20100316.234100.133957798.davem@davemloft.net>
	 <EA929A9653AAE14F841771FB1DE5A1365FE4909419@rrsmsx501.amr.corp.intel.com>
	 <20100317.111717.85209898.davem@davemloft.net>
	 <201003172339.15494.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:22213 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752073Ab0CQXgl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Mar 2010 19:36:41 -0400
In-Reply-To: <201003172339.15494.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-03-17 at 15:39 -0700, Rafael J. Wysocki wrote:
> On Wednesday 17 March 2010, David Miller wrote:
> > From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
> > Date: Wed, 17 Mar 2010 11:57:59 -0600
> > 
> > > But then the driver build fails again when CONFIG_PM_RUNTIME is not set.
> > > 
> > > drivers/net/e1000e/netdev.c: In function `e1000_runtime_resume`:
> > > drivers/net/e1000e/netdev.c:4807: error: `struct dev_pm_info` has no member named `runtime_auto`
> > 
> > Ugh, can someone send me a fix for that?
> 
> Appended, on top of your patch.  It only moves the code around and adds
> #ifdefs.

I know this is throwing a wrench in things, but won't this series of
changes break a clean bisect (due to the compile errors?)

so, revert
e50208a080a8abdfa6c85865362a1cf329e9fe31
and
23606cf5d1192c2b17912cb2ef6e62f9b11de133

and this is a mashup of the three:

---

e1000e: Add basic runtime PM support (rev 5)

From: Rafael J. Wysocki <rjw@sisk.pl>

these two commits should be reverted, and this patch applied in their
place.

this patch applies based on a tree with the below two commits reverted,
and should include the ifdefs necessary to compile with/without
PM/PM_RUNTIME support.

I compile tested it very briefly by compiling without CONFIG_PM, with
CONFIG_PM only and WITH CONFIG_PM_RUNTIME


commit e50208a080a8abdfa6c85865362a1cf329e9fe31
Author: David S. Miller <davem@davemloft.net>
Date:   Tue Mar 16 23:36:24 2010 -0700

    e1000e: Fix build with CONFIG_PM disabled.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

:100644 100644 79b33c5... b96532a... M  drivers/net/e1000e/netdev.c

commit 23606cf5d1192c2b17912cb2ef6e62f9b11de133
Author: Rafael J. Wysocki <rjw@sisk.pl>
Date:   Sun Mar 14 14:35:17 2010 +0000

    e1000e / PCI / PM: Add basic runtime PM support (rev. 4)
    
    Use the PCI runtime power management framework to add basic PCI
    runtime PM support to the e1000e driver.  Namely, make the driver
    suspend the device when the link is off and set it up for generating
    a wakeup event after the link has been detected again.  [This
    feature is disabled until the user space enables it with the help of
    the /sys/devices/.../power/contol device attribute.]
    
    Based on a patch from Matthew Garrett.
    
    Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
    Signed-off-by: David S. Miller <davem@davemloft.net>

:100644 100644 c2ec095... 8da190b... M  drivers/net/e1000e/e1000.h
:100644 100644 88d54d3... 79b33c5... M  drivers/net/e1000e/netdev.c

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
---

 drivers/net/e1000e/e1000.h  |    5 +
 drivers/net/e1000e/netdev.c |  182
++++++++++++++++++++++++++++++++++---------
 2 files changed, 149 insertions(+), 38 deletions(-)


diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index c2ec095..8da190b 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -158,6 +158,9 @@ struct e1000_info;
 #define HV_M_STATUS_SPEED_1000            0x0200
 #define HV_M_STATUS_LINK_UP               0x0040
 
+/* Time to wait before putting the device into D3 if there's no link
(in ms). */
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
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 88d54d3..06ba46a 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -44,6 +44,7 @@
 #include <linux/cpu.h>
 #include <linux/smp.h>
 #include <linux/pm_qos_params.h>
+#include <linux/pm_runtime.h>
 #include <linux/aer.h>
 
 #include "e1000.h"
@@ -3083,12 +3084,15 @@ static int e1000_open(struct net_device *netdev)
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
@@ -3149,6 +3153,9 @@ static int e1000_open(struct net_device *netdev)
 
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
@@ -3206,6 +3220,8 @@ static int e1000_close(struct net_device *netdev)
 	if (adapter->flags & FLAG_HAS_AMT)
 		e1000_release_hw_control(adapter);
 
+	pm_runtime_put_sync(&pdev->dev);
+
 	return 0;
 }
 /**
@@ -3550,6 +3566,9 @@ static void e1000_watchdog_task(struct work_struct
*work)
 
 	link = e1000e_has_link(adapter);
 	if ((netif_carrier_ok(netdev)) && link) {
+		/* Cancel scheduled suspend requests. */
+		pm_runtime_resume(netdev->dev.parent);
+
 		e1000e_enable_receives(adapter);
 		goto link_up;
 	}
@@ -3561,6 +3580,10 @@ static void e1000_watchdog_task(struct
work_struct *work)
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
@@ -3676,6 +3699,9 @@ static void e1000_watchdog_task(struct work_struct
*work)
 
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
@@ -4636,43 +4664,21 @@ static void e1000e_disable_l1aspm(struct pci_dev
*pdev)
 	}
 }
 
-#ifdef CONFIG_PM
-static int e1000_suspend(struct pci_dev *pdev, pm_message_t state)
+#ifdef CONFIG_PM_OPS
+static bool e1000e_pm_ready(struct e1000_adapter *adapter)
 {
-	int retval;
-	bool wake;
-
-	retval = __e1000_shutdown(pdev, &wake);
-	if (!retval)
-		e1000_complete_shutdown(pdev, true, wake);
-
-	return retval;
+	return !!adapter->tx_ring->buffer_info;
 }
 
-static int e1000_resume(struct pci_dev *pdev)
+static int __e1000_resume(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 	u32 err;
 
-	pci_set_power_state(pdev, PCI_D0);
-	pci_restore_state(pdev);
-	pci_save_state(pdev);
 	e1000e_disable_l1aspm(pdev);
 
-	err = pci_enable_device_mem(pdev);
-	if (err) {
-		dev_err(&pdev->dev,
-			"Cannot enable PCI device from suspend\n");
-		return err;
-	}
-
-	pci_set_master(pdev);
-
-	pci_enable_wake(pdev, PCI_D3hot, 0);
-	pci_enable_wake(pdev, PCI_D3cold, 0);
-
 	e1000e_set_interrupt_capability(adapter);
 	if (netif_running(netdev)) {
 		err = e1000_request_irq(adapter);
@@ -4730,13 +4736,88 @@ static int e1000_resume(struct pci_dev *pdev)
 
 	return 0;
 }
-#endif
+
+#ifdef CONFIG_PM_SLEEP
+static int e1000_suspend(struct device *dev)
+{
+	struct pci_dev *pdev = to_pci_dev(dev);
+	int retval;
+	bool wake;
+
+	retval = __e1000_shutdown(pdev, &wake, false);
+	if (!retval)
+		e1000_complete_shutdown(pdev, true, wake);
+
+	return retval;
+}
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
+#endif /* CONFIG_PM_SLEEP */
+
+#ifdef CONFIG_PM_RUNTIME
+static int e1000_runtime_suspend(struct device *dev)
+{
+	struct pci_dev *pdev = to_pci_dev(dev);
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+
+	if (e1000e_pm_ready(adapter)) {
+		bool wake;
+
+		__e1000_shutdown(pdev, &wake, true);
+	}
+
+	return 0;
+}
+
+static int e1000_idle(struct device *dev)
+{
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
+#endif /* CONFIG_PM_RUNTIME */
+#endif /* CONFIG_PM_OPS */
 
 static void e1000_shutdown(struct pci_dev *pdev)
 {
 	bool wake = false;
 
-	__e1000_shutdown(pdev, &wake);
+	__e1000_shutdown(pdev, &wake, false);
 
 	if (system_state == SYSTEM_POWER_OFF)
 		e1000_complete_shutdown(pdev, false, wake);
@@ -4809,8 +4890,8 @@ static pci_ers_result_t e1000_io_slot_reset(struct
pci_dev *pdev)
 		result = PCI_ERS_RESULT_DISCONNECT;
 	} else {
 		pci_set_master(pdev);
+		pdev->state_saved = true;
 		pci_restore_state(pdev);
-		pci_save_state(pdev);
 
 		pci_enable_wake(pdev, PCI_D3hot, 0);
 		pci_enable_wake(pdev, PCI_D3cold, 0);
@@ -5217,6 +5298,12 @@ static int __devinit e1000_probe(struct pci_dev
*pdev,
 
 	e1000_print_device_info(adapter);
 
+	if (pci_dev_run_wake(pdev)) {
+		pm_runtime_set_active(&pdev->dev);
+		pm_runtime_enable(&pdev->dev);
+	}
+	pm_schedule_suspend(&pdev->dev, MSEC_PER_SEC);
+
 	return 0;
 
 err_register:
@@ -5259,12 +5346,16 @@ static void __devexit e1000_remove(struct
pci_dev *pdev)
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
 
@@ -5278,8 +5369,17 @@ static void __devexit e1000_remove(struct pci_dev
*pdev)
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
@@ -5379,16 +5479,22 @@ static DEFINE_PCI_DEVICE_TABLE(e1000_pci_tbl) =
{
 };
 MODULE_DEVICE_TABLE(pci, e1000_pci_tbl);
 
+#ifdef CONFIG_PM_OPS
+static const struct dev_pm_ops e1000_pm_ops = {
+	SET_SYSTEM_SLEEP_PM_OPS(e1000_suspend, e1000_resume)
+	SET_RUNTIME_PM_OPS(e1000_runtime_suspend,
+				e1000_runtime_resume, e1000_idle)
+};
+#endif
+
 /* PCI Device API Driver */
 static struct pci_driver e1000_driver = {
 	.name     = e1000e_driver_name,
 	.id_table = e1000_pci_tbl,
 	.probe    = e1000_probe,
 	.remove   = __devexit_p(e1000_remove),
-#ifdef CONFIG_PM
-	/* Power Management Hooks */
-	.suspend  = e1000_suspend,
-	.resume   = e1000_resume,
+#ifdef CONFIG_PM_OPS
+	.driver.pm = &e1000_pm_ops,
 #endif
 	.shutdown = e1000_shutdown,
 	.err_handler = &e1000_err_handler


-- 
Jesse Brandeburg
This email sent via Evolution, powered by Linux

