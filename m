From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [PATCH] tg3: Do not use legacy PCI power management
Date: Sat, 25 Dec 2010 23:56:23 +0100
Message-ID: <201012252356.23424.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	David Miller <davem@davemloft.net>,
	"Linux-pm mailing list" <linux-pm@lists.linux-foundation.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:52137 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751103Ab0LYW5T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Dec 2010 17:57:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafael J. Wysocki <rjw@sisk.pl>

The tg3 driver uses the legacy PCI power management, so it has to do
some PCI-specific things in its ->suspend() and ->resume() callbacks,
which isn't necessary and should better be done by the PCI
sybsystem-level power management code.

Convert tg3 to the new PCI power management framework and make it
let the PCI subsystem take care of all the PCI-specific aspects of
device handling during system power transitions.

Tested on HP nx6325 with a NetXtreme BCM5788 adapter.

Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
---
 drivers/net/tg3.c |  101 ++++++++++++++++++++++--------------------------------
 1 file changed, 43 insertions(+), 58 deletions(-)

Index: linux-2.6/drivers/net/tg3.c
===================================================================
--- linux-2.6.orig/drivers/net/tg3.c
+++ linux-2.6/drivers/net/tg3.c
@@ -2549,39 +2549,35 @@ static void __tg3_set_mac_addr(struct tg
 	tw32(MAC_TX_BACKOFF_SEED, addr_high);
 }
 
-static int tg3_set_power_state(struct tg3 *tp, pci_power_t state)
+static void tg3_enable_register_access(struct tg3 *tp)
 {
-	u32 misc_host_ctrl;
-	bool device_should_wake, do_low_power;
-
-	/* Make sure register accesses (indirect or otherwise)
-	 * will function correctly.
+	/*
+	 * Make sure register accesses (indirect or otherwise) will function
+	 * correctly.
 	 */
 	pci_write_config_dword(tp->pdev,
-			       TG3PCI_MISC_HOST_CTRL,
-			       tp->misc_host_ctrl);
+			       TG3PCI_MISC_HOST_CTRL, tp->misc_host_ctrl);
+}
 
-	switch (state) {
-	case PCI_D0:
-		pci_enable_wake(tp->pdev, state, false);
-		pci_set_power_state(tp->pdev, PCI_D0);
+static int tg3_power_up(struct tg3 *tp)
+{
+	tg3_enable_register_access(tp);
 
-		/* Switch out of Vaux if it is a NIC */
-		if (tp->tg3_flags2 & TG3_FLG2_IS_NIC)
-			tw32_wait_f(GRC_LOCAL_CTRL, tp->grc_local_ctrl, 100);
+	pci_set_power_state(tp->pdev, PCI_D0);
 
-		return 0;
+	/* Switch out of Vaux if it is a NIC */
+	if (tp->tg3_flags2 & TG3_FLG2_IS_NIC)
+		tw32_wait_f(GRC_LOCAL_CTRL, tp->grc_local_ctrl, 100);
 
-	case PCI_D1:
-	case PCI_D2:
-	case PCI_D3hot:
-		break;
+	return 0;
+}
 
-	default:
-		netdev_err(tp->dev, "Invalid power state (D%d) requested\n",
-			   state);
-		return -EINVAL;
-	}
+static int tg3_power_down_prepare(struct tg3 *tp)
+{
+	u32 misc_host_ctrl;
+	bool device_should_wake, do_low_power;
+
+	tg3_enable_register_access(tp);
 
 	/* Restore the CLKREQ setting. */
 	if (tp->tg3_flags3 & TG3_FLG3_CLKREQ_BUG) {
@@ -2600,8 +2596,7 @@ static int tg3_set_power_state(struct tg
 	tw32(TG3PCI_MISC_HOST_CTRL,
 	     misc_host_ctrl | MISC_HOST_CTRL_MASK_PCI_INT);
 
-	device_should_wake = pci_pme_capable(tp->pdev, state) &&
-			     device_may_wakeup(&tp->pdev->dev) &&
+	device_should_wake = device_may_wakeup(&tp->pdev->dev) &&
 			     (tp->tg3_flags & TG3_FLAG_WOL_ENABLE);
 
 	if (tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB) {
@@ -2823,13 +2818,15 @@ static int tg3_set_power_state(struct tg
 
 	tg3_write_sig_post_reset(tp, RESET_KIND_SHUTDOWN);
 
-	if (device_should_wake)
-		pci_enable_wake(tp->pdev, state, true);
+	return 0;
+}
 
-	/* Finally, set the new power state. */
-	pci_set_power_state(tp->pdev, state);
+static void tg3_power_down(struct tg3 *tp)
+{
+	tg3_power_down_prepare(tp);
 
-	return 0;
+	pci_wake_from_d3(tp->pdev, tp->tg3_flags & TG3_FLAG_WOL_ENABLE);
+	pci_set_power_state(tp->pdev, PCI_D3hot);
 }
 
 static void tg3_aux_stat_to_speed_duplex(struct tg3 *tp, u32 val, u16 *speed, u8 *duplex)
@@ -9101,7 +9098,7 @@ static int tg3_open(struct net_device *d
 
 	netif_carrier_off(tp->dev);
 
-	err = tg3_set_power_state(tp, PCI_D0);
+	err = tg3_power_up(tp);
 	if (err)
 		return err;
 
@@ -9266,7 +9263,7 @@ static int tg3_close(struct net_device *
 
 	tg3_free_consistent(tp);
 
-	tg3_set_power_state(tp, PCI_D3hot);
+	tg3_power_down(tp);
 
 	netif_carrier_off(tp->dev);
 
@@ -11068,7 +11065,7 @@ static void tg3_self_test(struct net_dev
 	struct tg3 *tp = netdev_priv(dev);
 
 	if (tp->phy_flags & TG3_PHYFLG_IS_LOW_POWER)
-		tg3_set_power_state(tp, PCI_D0);
+		tg3_power_up(tp);
 
 	memset(data, 0, sizeof(u64) * TG3_NUM_TEST);
 
@@ -11136,7 +11133,7 @@ static void tg3_self_test(struct net_dev
 			tg3_phy_start(tp);
 	}
 	if (tp->phy_flags & TG3_PHYFLG_IS_LOW_POWER)
-		tg3_set_power_state(tp, PCI_D3hot);
+		tg3_power_down(tp);
 
 }
 
@@ -13546,7 +13543,7 @@ static int __devinit tg3_get_invariants(
 	    (tp->tg3_flags3 & TG3_FLG3_5717_PLUS))
 		tp->tg3_flags |= TG3_FLAG_CPMU_PRESENT;
 
-	/* Set up tp->grc_local_ctrl before calling tg3_set_power_state().
+	/* Set up tp->grc_local_ctrl before calling tg_power_up().
 	 * GPIO1 driven high will bring 5700's external PHY out of reset.
 	 * It is also used as eeprom write protect on LOMs.
 	 */
@@ -13577,7 +13574,7 @@ static int __devinit tg3_get_invariants(
 	}
 
 	/* Force the chip into D0. */
-	err = tg3_set_power_state(tp, PCI_D0);
+	err = tg3_power_up(tp);
 	if (err) {
 		dev_err(&tp->pdev->dev, "Transition to D0 failed\n");
 		return err;
@@ -14980,19 +14977,13 @@ static void __devexit tg3_remove_one(str
 	}
 }
 
-static int tg3_suspend(struct pci_dev *pdev, pm_message_t state)
+static int tg3_suspend(struct device *device)
 {
+	struct pci_dev *pdev = to_pci_dev(device);
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct tg3 *tp = netdev_priv(dev);
-	pci_power_t target_state;
 	int err;
 
-	/* PCI register 4 needs to be saved whether netif_running() or not.
-	 * MSI address and data need to be saved if using MSI and
-	 * netif_running().
-	 */
-	pci_save_state(pdev);
-
 	if (!netif_running(dev))
 		return 0;
 
@@ -15013,9 +15004,7 @@ static int tg3_suspend(struct pci_dev *p
 	tp->tg3_flags &= ~TG3_FLAG_INIT_COMPLETE;
 	tg3_full_unlock(tp);
 
-	target_state = pdev->pm_cap ? pci_target_state(pdev) : PCI_D3hot;
-
-	err = tg3_set_power_state(tp, target_state);
+	err = tg3_power_down_prepare(tp);
 	if (err) {
 		int err2;
 
@@ -15042,21 +15031,16 @@ out:
 	return err;
 }
 
-static int tg3_resume(struct pci_dev *pdev)
+static int tg3_resume(struct device *device)
 {
+	struct pci_dev *pdev = to_pci_dev(device);
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct tg3 *tp = netdev_priv(dev);
 	int err;
 
-	pci_restore_state(tp->pdev);
-
 	if (!netif_running(dev))
 		return 0;
 
-	err = tg3_set_power_state(tp, PCI_D0);
-	if (err)
-		return err;
-
 	netif_device_attach(dev);
 
 	tg3_full_lock(tp, 0);
@@ -15080,13 +15064,14 @@ out:
 	return err;
 }
 
+static SIMPLE_DEV_PM_OPS(tg3_pm_ops, tg3_suspend, tg3_resume);
+
 static struct pci_driver tg3_driver = {
 	.name		= DRV_MODULE_NAME,
 	.id_table	= tg3_pci_tbl,
 	.probe		= tg3_init_one,
 	.remove		= __devexit_p(tg3_remove_one),
-	.suspend	= tg3_suspend,
-	.resume		= tg3_resume
+	.driver.pm	= &tg3_pm_ops,
 };
 
 static int __init tg3_init(void)
