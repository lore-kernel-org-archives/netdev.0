From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [PATCH 3/4] tg3: Adapt tg3 to use reworked PCI PM code
Date: Sat, 19 Jul 2008 14:40:38 +0200
Message-ID: <200807191440.39243.rjw@sisk.pl>
References: <200807191436.40726.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jeff@garzik.org>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	pm list <linux-pm@lists.linux-foundation.org>,
	netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:44362 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754203AbYGSMmI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Jul 2008 08:42:08 -0400
In-Reply-To: <200807191436.40726.rjw@sisk.pl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafael J. Wysocki <rjw@sisk.pl>

Adapt tg3 to use reworked PCI PM code

Adapt the tg3 driver to use the reworked PCI PM and make it use
the exported PCI PM core functions instead of accessing the PCI PM
registers directly by itself.

Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
---
 drivers/net/tg3.c |   68 +++++++++++++++++++++++-------------------------------
 1 file changed, 29 insertions(+), 39 deletions(-)

Index: linux-2.6/drivers/net/tg3.c
===================================================================
--- linux-2.6.orig/drivers/net/tg3.c
+++ linux-2.6/drivers/net/tg3.c
@@ -1449,8 +1449,6 @@ static void tg3_power_down_phy(struct tg
 static int tg3_set_power_state(struct tg3 *tp, pci_power_t state)
 {
 	u32 misc_host_ctrl;
-	u16 power_control, power_caps;
-	int pm = tp->pm_cap;
 
 	/* Make sure register accesses (indirect or otherwise)
 	 * will function correctly.
@@ -1459,18 +1457,10 @@ static int tg3_set_power_state(struct tg
 			       TG3PCI_MISC_HOST_CTRL,
 			       tp->misc_host_ctrl);
 
-	pci_read_config_word(tp->pdev,
-			     pm + PCI_PM_CTRL,
-			     &power_control);
-	power_control |= PCI_PM_CTRL_PME_STATUS;
-	power_control &= ~(PCI_PM_CTRL_STATE_MASK);
 	switch (state) {
 	case PCI_D0:
-		power_control |= 0;
-		pci_write_config_word(tp->pdev,
-				      pm + PCI_PM_CTRL,
-				      power_control);
-		udelay(100);	/* Delay after power state change */
+		pci_enable_wake(tp->pdev, state, false);
+		pci_set_power_state(tp->pdev, PCI_D0);
 
 		/* Switch out of Vaux if it is a NIC */
 		if (tp->tg3_flags2 & TG3_FLG2_IS_NIC)
@@ -1479,25 +1469,15 @@ static int tg3_set_power_state(struct tg
 		return 0;
 
 	case PCI_D1:
-		power_control |= 1;
-		break;
-
 	case PCI_D2:
-		power_control |= 2;
-		break;
-
 	case PCI_D3hot:
-		power_control |= 3;
 		break;
 
 	default:
-		printk(KERN_WARNING PFX "%s: Invalid power state (%d) "
-		       "requested.\n",
-		       tp->dev->name, state);
+		printk(KERN_ERR PFX "%s: Invalid power state (D%d) requested\n",
+			tp->dev->name, state);
 		return -EINVAL;
-	};
-
-	power_control |= PCI_PM_CTRL_PME_ENABLE;
+	}
 
 	misc_host_ctrl = tr32(TG3PCI_MISC_HOST_CTRL);
 	tw32(TG3PCI_MISC_HOST_CTRL,
@@ -1539,8 +1519,6 @@ static int tg3_set_power_state(struct tg
 						     WOL_DRV_WOL |
 						     WOL_SET_MAGIC_PKT);
 
-	pci_read_config_word(tp->pdev, pm + PCI_PM_PMC, &power_caps);
-
 	if (tp->tg3_flags & TG3_FLAG_WOL_ENABLE) {
 		u32 mac_mode;
 
@@ -1571,8 +1549,8 @@ static int tg3_set_power_state(struct tg
 		if (!(tp->tg3_flags2 & TG3_FLG2_5750_PLUS))
 			tw32(MAC_LED_CTRL, tp->led_ctrl);
 
-		if (((power_caps & PCI_PM_CAP_PME_D3cold) &&
-		     (tp->tg3_flags & TG3_FLAG_WOL_ENABLE)))
+		if (pci_pme_capable(tp->pdev, state) &&
+		     (tp->tg3_flags & TG3_FLAG_WOL_ENABLE))
 			mac_mode |= MAC_MODE_MAGIC_PKT_ENABLE;
 
 		tw32_f(MAC_MODE, mac_mode);
@@ -1664,9 +1642,11 @@ static int tg3_set_power_state(struct tg
 
 	tg3_write_sig_post_reset(tp, RESET_KIND_SHUTDOWN);
 
+	if (tp->tg3_flags & TG3_FLAG_WOL_ENABLE)
+		pci_enable_wake(tp->pdev, state, true);
+
 	/* Finally, set the new power state. */
-	pci_write_config_word(tp->pdev, pm + PCI_PM_CTRL, power_control);
-	udelay(100);	/* Delay after power state change */
+	pci_set_power_state(tp->pdev, state);
 
 	return 0;
 }
@@ -8656,7 +8636,8 @@ static void tg3_get_wol(struct net_devic
 {
 	struct tg3 *tp = netdev_priv(dev);
 
-	if (tp->tg3_flags & TG3_FLAG_WOL_CAP)
+	if ((tp->tg3_flags & TG3_FLAG_WOL_CAP) &&
+	    device_can_wakeup(&tp->pdev->dev))
 		wol->supported = WAKE_MAGIC;
 	else
 		wol->supported = 0;
@@ -8669,18 +8650,22 @@ static void tg3_get_wol(struct net_devic
 static int tg3_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
 	struct tg3 *tp = netdev_priv(dev);
+	struct device *dp = &tp->pdev->dev;
 
 	if (wol->wolopts & ~WAKE_MAGIC)
 		return -EINVAL;
 	if ((wol->wolopts & WAKE_MAGIC) &&
-	    !(tp->tg3_flags & TG3_FLAG_WOL_CAP))
+	    !((tp->tg3_flags & TG3_FLAG_WOL_CAP) && device_can_wakeup(dp)))
 		return -EINVAL;
 
 	spin_lock_bh(&tp->lock);
-	if (wol->wolopts & WAKE_MAGIC)
+	if (wol->wolopts & WAKE_MAGIC) {
 		tp->tg3_flags |= TG3_FLAG_WOL_ENABLE;
-	else
+		device_set_wakeup_enable(dp, true);
+	} else {
 		tp->tg3_flags &= ~TG3_FLAG_WOL_ENABLE;
+		device_set_wakeup_enable(dp, false);
+	}
 	spin_unlock_bh(&tp->lock);
 
 	return 0;
@@ -10799,7 +10784,8 @@ static void __devinit tg3_get_eeprom_hw_
 		if (val & VCPU_CFGSHDW_ASPM_DBNC)
 			tp->tg3_flags |= TG3_FLAG_ASPM_WORKAROUND;
 		if ((val & VCPU_CFGSHDW_WOL_ENABLE) &&
-		    (val & VCPU_CFGSHDW_WOL_MAGPKT))
+		    (val & VCPU_CFGSHDW_WOL_MAGPKT) &&
+		    device_may_wakeup(&tp->pdev->dev))
 			tp->tg3_flags |= TG3_FLAG_WOL_ENABLE;
 		return;
 	}
@@ -10926,8 +10912,9 @@ static void __devinit tg3_get_eeprom_hw_
 		    !(nic_cfg & NIC_SRAM_DATA_CFG_FIBER_WOL))
 			tp->tg3_flags &= ~TG3_FLAG_WOL_CAP;
 
-		if (tp->tg3_flags & TG3_FLAG_WOL_CAP &&
-		    nic_cfg & NIC_SRAM_DATA_CFG_WOL_ENABLE)
+		if ((tp->tg3_flags & TG3_FLAG_WOL_CAP) &&
+		    (nic_cfg & NIC_SRAM_DATA_CFG_WOL_ENABLE) &&
+		    device_may_wakeup(&tp->pdev->dev))
 			tp->tg3_flags |= TG3_FLAG_WOL_ENABLE;
 
 		if (cfg2 & (1 << 17))
@@ -13091,6 +13078,7 @@ static int tg3_suspend(struct pci_dev *p
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct tg3 *tp = netdev_priv(dev);
+	pci_power_t target_state;
 	int err;
 
 	/* PCI register 4 needs to be saved whether netif_running() or not.
@@ -13118,7 +13106,9 @@ static int tg3_suspend(struct pci_dev *p
 	tp->tg3_flags &= ~TG3_FLAG_INIT_COMPLETE;
 	tg3_full_unlock(tp);
 
-	err = tg3_set_power_state(tp, pci_choose_state(pdev, state));
+	target_state = pdev->pm_cap ? pci_target_state(pdev) : PCI_D3hot;
+
+	err = tg3_set_power_state(tp, target_state);
 	if (err) {
 		tg3_full_lock(tp, 0);
 

