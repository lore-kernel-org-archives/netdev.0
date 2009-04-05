From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [PATCH] NET/r8169: Rework suspend and resume
Date: Sun, 5 Apr 2009 20:40:04 +0200
Message-ID: <200904052040.04752.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	pm list <linux-pm@lists.linux-foundation.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:41085 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751966AbZDESkG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Apr 2009 14:40:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafael J. Wysocki <rjw@sisk.pl>

The recent changes of the PCI PM core allow us to simplify the
suspend and resume handling in a number of device drivers, since they
don't need to carry out the general PCI PM operations, such as
changing the power state of the device, during suspend and resume any
more.

Simplify the suspend and resume callbacks of r8169 using the
observation that the PCI PM core can take care of some operations
carried out by the driver.

Additionally, make the shutdown callback of r8169 only put the device
into a low power state if the system is going to be powered off
(kexec is known to have problems with network adapters that are put
into low power states on shutdown).

This patch has been tested on MSI Wind U100.

Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
---
 drivers/net/r8169.c |   61 +++++++++++++++++++++++++++++++++-------------------
 1 file changed, 39 insertions(+), 22 deletions(-)

Index: linux-2.6/drivers/net/r8169.c
===================================================================
--- linux-2.6.orig/drivers/net/r8169.c
+++ linux-2.6/drivers/net/r8169.c
@@ -3791,16 +3791,13 @@ static struct net_device_stats *rtl8169_
 	return &dev->stats;
 }
 
-#ifdef CONFIG_PM
-
-static int rtl8169_suspend(struct pci_dev *pdev, pm_message_t state)
+static void rtl8169_net_suspend(struct net_device *dev)
 {
-	struct net_device *dev = pci_get_drvdata(pdev);
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
 
 	if (!netif_running(dev))
-		goto out_pci_suspend;
+		return;
 
 	netif_device_detach(dev);
 	netif_stop_queue(dev);
@@ -3812,24 +3809,25 @@ static int rtl8169_suspend(struct pci_de
 	rtl8169_rx_missed(dev, ioaddr);
 
 	spin_unlock_irq(&tp->lock);
+}
 
-out_pci_suspend:
-	pci_save_state(pdev);
-	pci_enable_wake(pdev, pci_choose_state(pdev, state),
-		(tp->features & RTL_FEATURE_WOL) ? 1 : 0);
-	pci_set_power_state(pdev, pci_choose_state(pdev, state));
+#ifdef CONFIG_PM
+
+static int rtl8169_suspend(struct device *device)
+{
+	struct pci_dev *pdev = to_pci_dev(device);
+	struct net_device *dev = pci_get_drvdata(pdev);
+
+	rtl8169_net_suspend(dev);
 
 	return 0;
 }
 
-static int rtl8169_resume(struct pci_dev *pdev)
+static int rtl8169_resume(struct device *device)
 {
+	struct pci_dev *pdev = to_pci_dev(device);
 	struct net_device *dev = pci_get_drvdata(pdev);
 
-	pci_set_power_state(pdev, PCI_D0);
-	pci_restore_state(pdev);
-	pci_enable_wake(pdev, PCI_D0, 0);
-
 	if (!netif_running(dev))
 		goto out;
 
@@ -3840,23 +3838,42 @@ out:
 	return 0;
 }
 
+static struct dev_pm_ops rtl8169_pm_ops = {
+	.suspend = rtl8169_suspend,
+	.resume = rtl8169_resume,
+	.freeze = rtl8169_suspend,
+	.thaw = rtl8169_resume,
+	.poweroff = rtl8169_suspend,
+	.restore = rtl8169_resume,
+};
+
+#define RTL8169_PM_OPS	(&rtl8169_pm_ops)
+
+#else /* !CONFIG_PM */
+
+#define RTL8169_PM_OPS	NULL
+
+#endif /* !CONFIG_PM */
+
 static void rtl_shutdown(struct pci_dev *pdev)
 {
-	rtl8169_suspend(pdev, PMSG_SUSPEND);
-}
+	struct net_device *dev = pci_get_drvdata(pdev);
 
-#endif /* CONFIG_PM */
+	rtl8169_net_suspend(dev);
+
+	if (system_state == SYSTEM_POWER_OFF) {
+		pci_wake_from_d3(pdev, true);
+		pci_set_power_state(pdev, PCI_D3hot);
+	}
+}
 
 static struct pci_driver rtl8169_pci_driver = {
 	.name		= MODULENAME,
 	.id_table	= rtl8169_pci_tbl,
 	.probe		= rtl8169_init_one,
 	.remove		= __devexit_p(rtl8169_remove_one),
-#ifdef CONFIG_PM
-	.suspend	= rtl8169_suspend,
-	.resume		= rtl8169_resume,
 	.shutdown	= rtl_shutdown,
-#endif
+	.driver.pm	= RTL8169_PM_OPS,
 };
 
 static int __init rtl8169_init_module(void)
