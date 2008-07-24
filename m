From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH 4/4] sky2: Adapt sky2 to use reworked PCI PM
Date: Thu, 24 Jul 2008 22:50:50 +0200
Message-ID: <200807242250.51119.rjw@sisk.pl>
References: <200807191436.40726.rjw@sisk.pl> <200807191442.52759.rjw@sisk.pl> <20080720190742.84258d7e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, Jeff Garzik <jeff@garzik.org>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	pm list <linux-pm@lists.linux-foundation.org>,
	netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:44530 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751350AbYGXUs7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2008 16:48:59 -0400
In-Reply-To: <20080720190742.84258d7e.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Sorry for the delayed response, I'm at OLS.]

On Monday, 21 of July 2008, Andrew Morton wrote:
> On Sat, 19 Jul 2008 14:42:51 +0200 "Rafael J. Wysocki" <rjw@sisk.pl> wrote:
> 
> > Adapt the sky2 driver to use the reworked PCI PM.
> 
> I fixed the rejects in "[PATCH 3/4] tg3: Adapt tg3 to use reworked PCI
> PM code" but this patch has too many for me to want to fix them.
> 
> As usual, please at least take a look at what's in linux-next before
> going and bypassing all that queued work.

Sorry for that.

Appended is a version of the patch applying to the current mainline on top of
patches 1/4 - 3/4 without rejects.

BTW, the sky2's WOL is broken on my test box because of commit
db99b98885e717454feef1c6868b27d3f23c2e7c ("sky2: put PHY in sleep when down")
that causes the box to hang solid in sky2_suspend() and sky2_shutdown() after
WOL has been enabled with 'ethtool -s eth0 wol g'.

This has already been reported to Stephen and Jeff.

Thanks,
Rafael

---
From: Rafael J. Wysocki <rjw@sisk.pl>

Adapt sky2 to use reworked PCI PM code

Adapt the sky2 driver to use the reworked PCI PM and make it use
the exported PCI PM core functions instead of accessing the PCI PM
registers directly by itself.

Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
---
 drivers/net/sky2.c |   55 ++++++++++++++++++-----------------------------------
 1 file changed, 19 insertions(+), 36 deletions(-)

Index: linux-2.6/drivers/net/sky2.c
===================================================================
--- linux-2.6.orig/drivers/net/sky2.c
+++ linux-2.6/drivers/net/sky2.c
@@ -277,7 +277,6 @@ static void sky2_power_aux(struct sky2_h
 
 static void sky2_power_state(struct sky2_hw *hw, pci_power_t state)
 {
-	u16 power_control = sky2_pci_read16(hw, hw->pm_cap + PCI_PM_CTRL);
 	int pex = pci_find_capability(hw->pdev, PCI_CAP_ID_EXP);
 	u32 reg;
 
@@ -285,19 +284,12 @@ static void sky2_power_state(struct sky2
 
 	switch (state) {
 	case PCI_D0:
-		break;
-
 	case PCI_D1:
-		power_control |= 1;
-		break;
-
 	case PCI_D2:
-		power_control |= 2;
 		break;
 
 	case PCI_D3hot:
 	case PCI_D3cold:
-		power_control |= 3;
 		if (hw->flags & SKY2_HW_ADV_POWER_CTL) {
 			/* additional power saving measurements */
 			reg = sky2_pci_read32(hw, PCI_DEV_REG4);
@@ -347,9 +339,8 @@ static void sky2_power_state(struct sky2
 		return;
 	}
 
-	power_control |= PCI_PM_CTRL_PME_ENABLE;
 	/* Finally, set the new power state. */
-	sky2_pci_write32(hw, hw->pm_cap + PCI_PM_CTRL, power_control);
+	pci_set_power_state(hw->pdev, state);
 
 	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
 	sky2_pci_read32(hw, B0_CTST);
@@ -3084,7 +3075,8 @@ static int sky2_set_wol(struct net_devic
 	struct sky2_port *sky2 = netdev_priv(dev);
 	struct sky2_hw *hw = sky2->hw;
 
-	if (wol->wolopts & ~sky2_wol_supported(sky2->hw))
+	if ((wol->wolopts & ~sky2_wol_supported(sky2->hw))
+	    || !device_can_wakeup(&hw->pdev->dev))
 		return -EOPNOTSUPP;
 
 	sky2->wol = wol->wolopts;
@@ -3095,8 +3087,8 @@ static int sky2_set_wol(struct net_devic
 		sky2_write32(hw, B0_CTST, sky2->wol
 			     ? Y2_HW_WOL_ON : Y2_HW_WOL_OFF);
 
-	if (!netif_running(dev))
-		sky2_wol_init(sky2);
+	device_set_wakeup_enable(&hw->pdev->dev, sky2->wol);
+
 	return 0;
 }
 
@@ -4216,18 +4208,6 @@ static int __devinit sky2_test_msi(struc
 	return err;
 }
 
-static int __devinit pci_wake_enabled(struct pci_dev *dev)
-{
-	int pm  = pci_find_capability(dev, PCI_CAP_ID_PM);
-	u16 value;
-
-	if (!pm)
-		return 0;
-	if (pci_read_config_word(dev, pm + PCI_PM_CTRL, &value))
-		return 0;
-	return value & PCI_PM_CTRL_PME_ENABLE;
-}
-
 /* This driver supports yukon2 chipset only */
 static const char *sky2_name(u8 chipid, char *buf, int sz)
 {
@@ -4288,7 +4268,7 @@ static int __devinit sky2_probe(struct p
 		}
 	}
 
-	wol_default = pci_wake_enabled(pdev) ? WAKE_MAGIC : 0;
+	wol_default = device_may_wakeup(&pdev->dev) ? WAKE_MAGIC : 0;
 
 	err = -ENOMEM;
 	hw = kzalloc(sizeof(*hw), GFP_KERNEL);
@@ -4453,7 +4433,9 @@ static void __devexit sky2_remove(struct
 static int sky2_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct sky2_hw *hw = pci_get_drvdata(pdev);
-	int i, wol = 0;
+	pci_power_t target_state;
+	int i;
+	bool wol = false;
 
 	if (!hw)
 		return 0;
@@ -4469,10 +4451,10 @@ static int sky2_suspend(struct pci_dev *
 		if (netif_running(dev))
 			sky2_down(dev);
 
-		if (sky2->wol)
+		if (sky2->wol) {
+			wol = true;
 			sky2_wol_init(sky2);
-
-		wol |= sky2->wol;
+		}
 	}
 
 	sky2_write32(hw, B0_IMSK, 0);
@@ -4480,8 +4462,10 @@ static int sky2_suspend(struct pci_dev *
 	sky2_power_aux(hw);
 
 	pci_save_state(pdev);
-	pci_enable_wake(pdev, pci_choose_state(pdev, state), wol);
-	sky2_power_state(hw, pci_choose_state(pdev, state));
+
+	target_state = pci_target_state(pdev);
+	pci_enable_wake(pdev, target_state, wol);
+	sky2_power_state(hw, target_state);
 
 	return 0;
 }
@@ -4494,14 +4478,13 @@ static int sky2_resume(struct pci_dev *p
 	if (!hw)
 		return 0;
 
+	pci_enable_wake(pdev, PCI_D0, false);
 	sky2_power_state(hw, PCI_D0);
 
 	err = pci_restore_state(pdev);
 	if (err)
 		goto out;
 
-	pci_enable_wake(pdev, PCI_D0, 0);
-
 	/* Re-enable all clocks */
 	if (hw->chip_id == CHIP_ID_YUKON_EX ||
 	    hw->chip_id == CHIP_ID_YUKON_EC_U ||
@@ -4560,8 +4543,8 @@ static void sky2_shutdown(struct pci_dev
 	if (wol)
 		sky2_power_aux(hw);
 
-	pci_enable_wake(pdev, PCI_D3hot, wol);
-	pci_enable_wake(pdev, PCI_D3cold, wol);
+	if (pci_enable_wake(pdev, PCI_D3cold, wol))
+		pci_enable_wake(pdev, PCI_D3hot, wol);
 
 	pci_disable_device(pdev);
 	sky2_power_state(hw, PCI_D3hot);
