From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH] forcedeth: Do not use legacy PCI power management
Date: Fri, 7 Jan 2011 22:12:05 +0100
Message-ID: <201101072212.05449.rjw@sisk.pl>
References: <201101070049.16833.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	"Linux-pm mailing list" <linux-pm@lists.linux-foundation.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201101070049.16833.rjw@sisk.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday, January 07, 2011, Rafael J. Wysocki wrote:
> From: Rafael J. Wysocki <rjw@sisk.pl>
> 
> The forcedeth driver uses the legacy PCI power management, so it has
> to do PCI-specific things in its ->suspend() and ->resume() callbacks
> and some of them are not done correctly.
> 
> Convert forcedeth to the new PCI power management framework and make
> it let the PCI subsystem take care of all the PCI-specific aspects of
> device handling during system power transitions.
> 
> Tested with nVidia Corporation MCP55 Ethernet (rev a2).

This version of the patch contains a mistake (nv_shutdown should be #defined
as NULL if !CONFIG_PM, not nv_resume), please disregard it.

Fixed patch is appended.

Thanks,
Rafael


---
From: Rafael J. Wysocki <rjw@sisk.pl>
Subject: forcedeth: Do not use legacy PCI power management (v2)

The forcedeth driver uses the legacy PCI power management, so it has
to do PCI-specific things in its ->suspend() and ->resume() callbacks
and some of them are not done correctly.

Convert forcedeth to the new PCI power management framework and make
it let the PCI subsystem take care of all the PCI-specific aspects of
device handling during system power transitions.

Tested with nVidia Corporation MCP55 Ethernet (rev a2).

Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
---
 drivers/net/forcedeth.c |   34 ++++++++++++----------------------
 1 file changed, 12 insertions(+), 22 deletions(-)

Index: linux-2.6/drivers/net/forcedeth.c
===================================================================
--- linux-2.6.orig/drivers/net/forcedeth.c
+++ linux-2.6/drivers/net/forcedeth.c
@@ -4082,6 +4082,7 @@ static int nv_set_wol(struct net_device
 		writel(flags, base + NvRegWakeUpFlags);
 		spin_unlock_irq(&np->lock);
 	}
+	device_set_wakeup_enable(&np->pci_dev->dev, np->wolenabled);
 	return 0;
 }
 
@@ -5643,14 +5644,10 @@ static int __devinit nv_probe(struct pci
 	/* set mac address */
 	nv_copy_mac_to_hw(dev);
 
-	/* Workaround current PCI init glitch:  wakeup bits aren't
-	 * being set from PCI PM capability.
-	 */
-	device_init_wakeup(&pci_dev->dev, 1);
-
 	/* disable WOL */
 	writel(0, base + NvRegWakeUpFlags);
 	np->wolenabled = 0;
+	device_set_wakeup_enable(&pci_dev->dev, false);
 
 	if (id->driver_data & DEV_HAS_POWER_CNTRL) {
 
@@ -5923,8 +5920,9 @@ static void __devexit nv_remove(struct p
 }
 
 #ifdef CONFIG_PM
-static int nv_suspend(struct pci_dev *pdev, pm_message_t state)
+static int nv_suspend(struct device *device)
 {
+	struct pci_dev *pdev = to_pci_dev(device);
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
@@ -5940,25 +5938,17 @@ static int nv_suspend(struct pci_dev *pd
 	for (i = 0;i <= np->register_size/sizeof(u32); i++)
 		np->saved_config_space[i] = readl(base + i*sizeof(u32));
 
-	pci_save_state(pdev);
-	pci_enable_wake(pdev, pci_choose_state(pdev, state), np->wolenabled);
-	pci_disable_device(pdev);
-	pci_set_power_state(pdev, pci_choose_state(pdev, state));
 	return 0;
 }
 
-static int nv_resume(struct pci_dev *pdev)
+static int nv_resume(struct device *device)
 {
+	struct pci_dev *pdev = to_pci_dev(device);
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
 	int i, rc = 0;
 
-	pci_set_power_state(pdev, PCI_D0);
-	pci_restore_state(pdev);
-	/* ack any pending wake events, disable PME */
-	pci_enable_wake(pdev, PCI_D0, 0);
-
 	/* restore non-pci configuration space */
 	for (i = 0;i <= np->register_size/sizeof(u32); i++)
 		writel(np->saved_config_space[i], base+i*sizeof(u32));
@@ -5977,6 +5967,9 @@ static int nv_resume(struct pci_dev *pde
 	return rc;
 }
 
+static SIMPLE_DEV_PM_OPS(nv_pm_ops, nv_suspend, nv_resume);
+#define NV_PM_OPS (&nv_pm_ops)
+
 static void nv_shutdown(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
@@ -6000,15 +5993,13 @@ static void nv_shutdown(struct pci_dev *
 	 * only put the device into D3 if we really go for poweroff.
 	 */
 	if (system_state == SYSTEM_POWER_OFF) {
-		if (pci_enable_wake(pdev, PCI_D3cold, np->wolenabled))
-			pci_enable_wake(pdev, PCI_D3hot, np->wolenabled);
+		pci_wake_from_d3(pdev, np->wolenabled);
 		pci_set_power_state(pdev, PCI_D3hot);
 	}
 }
 #else
-#define nv_suspend NULL
+#define NV_PM_OPS NULL
 #define nv_shutdown NULL
-#define nv_resume NULL
 #endif /* CONFIG_PM */
 
 static DEFINE_PCI_DEVICE_TABLE(pci_tbl) = {
@@ -6180,9 +6171,8 @@ static struct pci_driver driver = {
 	.id_table	= pci_tbl,
 	.probe		= nv_probe,
 	.remove		= __devexit_p(nv_remove),
-	.suspend	= nv_suspend,
-	.resume		= nv_resume,
 	.shutdown	= nv_shutdown,
+	.driver.pm	= NV_PM_OPS,
 };
 
 static int __init init_nic(void)
