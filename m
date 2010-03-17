From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: e1000e: Fix build with CONFIG_PM disabled.
Date: Wed, 17 Mar 2010 23:39:15 +0100
Message-ID: <201003172339.15494.rjw@sisk.pl>
References: <20100316.234100.133957798.davem@davemloft.net> <EA929A9653AAE14F841771FB1DE5A1365FE4909419@rrsmsx501.amr.corp.intel.com> <20100317.111717.85209898.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: emil.s.tantilov@intel.com, netdev@vger.kernel.org,
	bruce.w.allan@intel.com, jesse.brandeburg@intel.com,
	jeffrey.t.kirsher@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:47375 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756160Ab0CQWg1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Mar 2010 18:36:27 -0400
In-Reply-To: <20100317.111717.85209898.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 17 March 2010, David Miller wrote:
> From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
> Date: Wed, 17 Mar 2010 11:57:59 -0600
> 
> > But then the driver build fails again when CONFIG_PM_RUNTIME is not set.
> > 
> > drivers/net/e1000e/netdev.c: In function `e1000_runtime_resume`:
> > drivers/net/e1000e/netdev.c:4807: error: `struct dev_pm_info` has no member named `runtime_auto`
> 
> Ugh, can someone send me a fix for that?

Appended, on top of your patch.  It only moves the code around and adds
#ifdefs.

Thanks,
Rafael

---
From: Rafael J. Wysocki <rjw@sisk.pl>
Subject: Net / e1000e: Fix build issue introduced by runtime PM patch

The recent PCI runtime PM patch broke build for CONFIG_PM_RUNTIME
and CONFIG_PM_SLEEP undefined.  Fix that by moving the PM callbacks
under suitable #ifdefs.

Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
---
 drivers/net/e1000e/netdev.c |  116 +++++++++++++++++++++-----------------------
 1 file changed, 57 insertions(+), 59 deletions(-)

Index: linux-2.6/drivers/net/e1000e/netdev.c
===================================================================
--- linux-2.6.orig/drivers/net/e1000e/netdev.c
+++ linux-2.6/drivers/net/e1000e/netdev.c
@@ -4664,58 +4664,12 @@ static void e1000e_disable_l1aspm(struct
 	}
 }
 
-#ifdef CONFIG_PM
+#ifdef CONFIG_PM_OPS
 static bool e1000e_pm_ready(struct e1000_adapter *adapter)
 {
 	return !!adapter->tx_ring->buffer_info;
 }
 
-static int e1000_idle(struct device *dev)
-{
-	struct pci_dev *pdev = to_pci_dev(dev);
-	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct e1000_adapter *adapter = netdev_priv(netdev);
-
-	if (!e1000e_pm_ready(adapter))
-		return 0;
-
-	if (adapter->idle_check) {
-		adapter->idle_check = false;
-		if (!e1000e_has_link(adapter))
-			pm_schedule_suspend(dev, MSEC_PER_SEC);
-	}
-
-	return -EBUSY;
-}
-
-static int e1000_suspend(struct device *dev)
-{
-	struct pci_dev *pdev = to_pci_dev(dev);
-	int retval;
-	bool wake;
-
-	retval = __e1000_shutdown(pdev, &wake, false);
-	if (!retval)
-		e1000_complete_shutdown(pdev, true, wake);
-
-	return retval;
-}
-
-static int e1000_runtime_suspend(struct device *dev)
-{
-	struct pci_dev *pdev = to_pci_dev(dev);
-	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct e1000_adapter *adapter = netdev_priv(netdev);
-
-	if (e1000e_pm_ready(adapter)) {
-		bool wake;
-
-		__e1000_shutdown(pdev, &wake, true);
-	}
-
-	return 0;
-}
-
 static int __e1000_resume(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
@@ -4783,6 +4737,20 @@ static int __e1000_resume(struct pci_dev
 	return 0;
 }
 
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
 static int e1000_resume(struct device *dev)
 {
 	struct pci_dev *pdev = to_pci_dev(dev);
@@ -4794,6 +4762,41 @@ static int e1000_resume(struct device *d
 
 	return __e1000_resume(pdev);
 }
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
 
 static int e1000_runtime_resume(struct device *dev)
 {
@@ -4807,7 +4810,8 @@ static int e1000_runtime_resume(struct d
 	adapter->idle_check = !dev->power.runtime_auto;
 	return __e1000_resume(pdev);
 }
-#endif
+#endif /* CONFIG_PM_RUNTIME */
+#endif /* CONFIG_PM_OPS */
 
 static void e1000_shutdown(struct pci_dev *pdev)
 {
@@ -5475,17 +5479,11 @@ static DEFINE_PCI_DEVICE_TABLE(e1000_pci
 };
 MODULE_DEVICE_TABLE(pci, e1000_pci_tbl);
 
-#ifdef CONFIG_PM
+#ifdef CONFIG_PM_OPS
 static const struct dev_pm_ops e1000_pm_ops = {
-	.suspend  = e1000_suspend,
-	.resume   = e1000_resume,
-	.freeze = e1000_suspend,
-	.thaw = e1000_resume,
-	.poweroff = e1000_suspend,
-	.restore = e1000_resume,
-	.runtime_suspend = e1000_runtime_suspend,
-	.runtime_resume = e1000_runtime_resume,
-	.runtime_idle = e1000_idle,
+	SET_SYSTEM_SLEEP_PM_OPS(e1000_suspend, e1000_resume)
+	SET_RUNTIME_PM_OPS(e1000_runtime_suspend,
+				e1000_runtime_resume, e1000_idle)
 };
 #endif
 
@@ -5495,7 +5493,7 @@ static struct pci_driver e1000_driver = 
 	.id_table = e1000_pci_tbl,
 	.probe    = e1000_probe,
 	.remove   = __devexit_p(e1000_remove),
-#ifdef CONFIG_PM
+#ifdef CONFIG_PM_OPS
 	.driver.pm = &e1000_pm_ops,
 #endif
 	.shutdown = e1000_shutdown,
