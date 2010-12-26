From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [PATCH] sky2: Do not use legacy PCI power management
Date: Sun, 26 Dec 2010 19:44:32 +0100
Message-ID: <201012261944.32517.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	"Linux-pm mailing list" <linux-pm@lists.linux-foundation.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:52591 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752331Ab0LZSo6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Dec 2010 13:44:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafael J. Wysocki <rjw@sisk.pl>

The sky2 driver uses the legacy PCI power management, so it has to do
some PCI-specific things in its ->suspend() and ->resume() callbacks,
which isn't necessary and should better be done by the PCI
sybsystem-level power management code.  Moreover, it uses
device_set_wakeup_enable() incorrectly (that function should be
used when the WoL setting is changed rather than during suspend).

Convert sky2 to the new PCI power management framework and make it
let the PCI subsystem take care of all the PCI-specific aspects of
device handling during system power transitions.

Tested on a desktop machine with a Marvell 88E8056 PCI-E adapter.

Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
---
 drivers/net/sky2.c |   54 +++++++++++++++++++++++++++--------------------------
 1 file changed, 28 insertions(+), 26 deletions(-)

Index: linux-2.6/drivers/net/sky2.c
===================================================================
--- linux-2.6.orig/drivers/net/sky2.c
+++ linux-2.6/drivers/net/sky2.c
@@ -3398,12 +3398,24 @@ static int sky2_set_wol(struct net_devic
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
 	struct sky2_hw *hw = sky2->hw;
+	bool enable_wakeup = false;
+	int i;
 
 	if ((wol->wolopts & ~sky2_wol_supported(sky2->hw)) ||
 	    !device_can_wakeup(&hw->pdev->dev))
 		return -EOPNOTSUPP;
 
 	sky2->wol = wol->wolopts;
+
+	for (i = 0; i < hw->ports; i++) {
+		struct net_device *dev = hw->dev[i];
+		struct sky2_port *sky2 = netdev_priv(dev);
+
+		if (sky2->wol)
+			enable_wakeup = true;
+	}
+	device_set_wakeup_enable(&hw->pdev->dev, enable_wakeup);
+
 	return 0;
 }
 
@@ -4920,10 +4932,11 @@ static void __devexit sky2_remove(struct
 	pci_set_drvdata(pdev, NULL);
 }
 
-static int sky2_suspend(struct pci_dev *pdev, pm_message_t state)
+static int sky2_suspend(struct device *dev)
 {
+	struct pci_dev *pdev = to_pci_dev(dev);
 	struct sky2_hw *hw = pci_get_drvdata(pdev);
-	int i, wol = 0;
+	int i;
 
 	if (!hw)
 		return 0;
@@ -4940,41 +4953,24 @@ static int sky2_suspend(struct pci_dev *
 
 		if (sky2->wol)
 			sky2_wol_init(sky2);
-
-		wol |= sky2->wol;
 	}
 
-	device_set_wakeup_enable(&pdev->dev, wol != 0);
-
 	sky2_power_aux(hw);
 	rtnl_unlock();
 
-	pci_save_state(pdev);
-	pci_enable_wake(pdev, pci_choose_state(pdev, state), wol);
-	pci_set_power_state(pdev, pci_choose_state(pdev, state));
-
 	return 0;
 }
 
 #ifdef CONFIG_PM
-static int sky2_resume(struct pci_dev *pdev)
+static int sky2_resume(struct device *dev)
 {
+	struct pci_dev *pdev = to_pci_dev(dev);
 	struct sky2_hw *hw = pci_get_drvdata(pdev);
 	int err;
 
 	if (!hw)
 		return 0;
 
-	err = pci_set_power_state(pdev, PCI_D0);
-	if (err)
-		goto out;
-
-	err = pci_restore_state(pdev);
-	if (err)
-		goto out;
-
-	pci_enable_wake(pdev, PCI_D0, 0);
-
 	/* Re-enable all clocks */
 	err = pci_write_config_dword(pdev, PCI_DEV_REG3, 0);
 	if (err) {
@@ -4994,11 +4990,20 @@ out:
 	pci_disable_device(pdev);
 	return err;
 }
+
+static SIMPLE_DEV_PM_OPS(sky2_pm_ops, sky2_suspend, sky2_resume);
+#define SKY2_PM_OPS (&sky2_pm_ops)
+
+#else
+
+#define SKY2_PM_OPS NULL
 #endif
 
 static void sky2_shutdown(struct pci_dev *pdev)
 {
-	sky2_suspend(pdev, PMSG_SUSPEND);
+	sky2_suspend(&pdev->dev);
+	pci_wake_from_d3(pdev, device_may_wakeup(&pdev->dev));
+	pci_set_power_state(pdev, PCI_D3hot);
 }
 
 static struct pci_driver sky2_driver = {
@@ -5006,11 +5011,8 @@ static struct pci_driver sky2_driver = {
 	.id_table = sky2_id_table,
 	.probe = sky2_probe,
 	.remove = __devexit_p(sky2_remove),
-#ifdef CONFIG_PM
-	.suspend = sky2_suspend,
-	.resume = sky2_resume,
-#endif
 	.shutdown = sky2_shutdown,
+	.driver.pm = SKY2_PM_OPS,
 };
 
 static int __init sky2_init_module(void)
