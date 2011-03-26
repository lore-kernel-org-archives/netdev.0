From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [PATCH] Net / jme: Do not use legacy PCI power management
Date: Sat, 26 Mar 2011 12:34:06 +0100
Message-ID: <201103261234.06274.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	Linux PM mailing list <linux-pm@lists.linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rafael J. Wysocki <rjw@sisk.pl>

The jme driver uses the legacy PCI power management, so it has to do
some PCI-specific things in its ->suspend() and ->resume() callbacks,
which isn't necessary and should better be done by the PCI
sybsystem-level power management code.  It also doesn't use device
wakeup flags correctly.

Convert jme to the new PCI power management framework and make it
let the PCI subsystem take care of all the PCI-specific aspects of
device handling during system power transitions.

Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
---
 drivers/net/jme.c |   30 ++++++++++++++++--------------
 1 file changed, 16 insertions(+), 14 deletions(-)

Index: linux-2.6/drivers/net/jme.c
===================================================================
--- linux-2.6.orig/drivers/net/jme.c
+++ linux-2.6/drivers/net/jme.c
@@ -273,7 +273,7 @@ jme_clear_pm(struct jme_adapter *jme)
 {
 	jwrite32(jme, JME_PMCS, 0xFFFF0000 | jme->reg_pmcs);
 	pci_set_power_state(jme->pdev, PCI_D0);
-	pci_enable_wake(jme->pdev, PCI_D0, false);
+	device_set_wakeup_enable(&jme->pdev->dev, false);
 }
 
 static int
@@ -2538,6 +2538,8 @@ jme_set_wol(struct net_device *netdev,
 
 	jwrite32(jme, JME_PMCS, jme->reg_pmcs);
 
+	device_set_wakeup_enable(&jme->pdev->dev, jme->reg_pmcs);
+
 	return 0;
 }
 
@@ -3172,9 +3174,9 @@ jme_shutdown(struct pci_dev *pdev)
 }
 
 #ifdef CONFIG_PM
-static int
-jme_suspend(struct pci_dev *pdev, pm_message_t state)
+static int jme_suspend(struct device *dev)
 {
+	struct pci_dev *pdev = to_pci_dev(dev);
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct jme_adapter *jme = netdev_priv(netdev);
 
@@ -3206,22 +3208,18 @@ jme_suspend(struct pci_dev *pdev, pm_mes
 	tasklet_hi_enable(&jme->rxclean_task);
 	tasklet_hi_enable(&jme->rxempty_task);
 
-	pci_save_state(pdev);
 	jme_powersave_phy(jme);
-	pci_enable_wake(jme->pdev, PCI_D3hot, true);
-	pci_set_power_state(pdev, PCI_D3hot);
 
 	return 0;
 }
 
-static int
-jme_resume(struct pci_dev *pdev)
+static int jme_resume(struct device *dev)
 {
+	struct pci_dev *pdev = to_pci_dev(dev);
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct jme_adapter *jme = netdev_priv(netdev);
 
-	jme_clear_pm(jme);
-	pci_restore_state(pdev);
+	jwrite32(jme, JME_PMCS, 0xFFFF0000 | jme->reg_pmcs);
 
 	jme_phy_on(jme);
 	if (test_bit(JME_FLAG_SSET, &jme->flags))
@@ -3238,6 +3236,13 @@ jme_resume(struct pci_dev *pdev)
 
 	return 0;
 }
+
+static SIMPLE_DEV_PM_OPS(jme_pm_ops, jme_suspend, jme_resume);
+#define JME_PM_OPS (&jme_pm_ops)
+
+#else
+
+#define JME_PM_OPS NULL
 #endif
 
 static DEFINE_PCI_DEVICE_TABLE(jme_pci_tbl) = {
@@ -3251,11 +3256,8 @@ static struct pci_driver jme_driver = {
 	.id_table       = jme_pci_tbl,
 	.probe          = jme_init_one,
 	.remove         = __devexit_p(jme_remove_one),
-#ifdef CONFIG_PM
-	.suspend        = jme_suspend,
-	.resume         = jme_resume,
-#endif /* CONFIG_PM */
 	.shutdown       = jme_shutdown,
+	.driver.pm	= JME_PM_OPS,
 };
 
 static int __init
