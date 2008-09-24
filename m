From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: Regression in 2.6.27-rc7: Wake On LAN with sky2 broken
Date: Wed, 24 Sep 2008 21:13:51 +0200
Message-ID: <200809242113.52256.rjw@sisk.pl>
References: <20080924080546.GA21108@x61>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Tino Keitel <tino.keitel@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:48886 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752040AbYIXTIQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2008 15:08:16 -0400
In-Reply-To: <20080924080546.GA21108@x61>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, 24 of September 2008, Tino Keitel wrote:
> Hi,
> 
> Wake On LAN from suspend to RAM doesn't work on my Mac mini Core Duo
> with 2.6.27-rc7. I tested the same configuration with 2.6.26.3, and it
> worked. With 2.6.27-rc7, the computer stays in suspended state. I can
> still wake it up using the keyboard or power switch.
> 
> In my suspend script, I use the command "ethtool -s eth0 wol g" to
> enable WOL even if it was disabled before.
> 
> Any hints what commit I should try to revert, before I start bisecting?

Please try the appended patch.

Thanks,
Rafael

---
From: Rafael J. Wysocki <rjw@sisk.pl>

sky2: Fix wake-on-LAN regression

* Since dev->power.should_wakeup bit is used by the PCI core to
  decide whether the device should wake up the system from sleep
  states, set/unset this bit whenever WOL is enabled/disabled using
  sky2_set_wol().

* Use pci_prepare_to_sleep() and pci_back_from_sleep() in
  ->sky2_suspend() and ->sky2_resume(), respectively, instead of the
  older less suitable interfaces.

* Prevent pci_enable_wake() from being called twice unnecessarily in
  sky2_shutdown().

Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
---

 drivers/net/sky2.c |   34 ++++++++++------------------------
 1 file changed, 10 insertions(+), 24 deletions(-)

diff -puN drivers/net/sky2.c~skty2-adapt-to-the-reworked-pci-pm drivers/net/sky2.c
--- a/drivers/net/sky2.c~skty2-adapt-to-the-reworked-pci-pm
+++ a/drivers/net/sky2.c
@@ -3034,7 +3034,8 @@ static int sky2_set_wol(struct net_devic
 	struct sky2_port *sky2 = netdev_priv(dev);
 	struct sky2_hw *hw = sky2->hw;
 
-	if (wol->wolopts & ~sky2_wol_supported(sky2->hw))
+	if ((wol->wolopts & ~sky2_wol_supported(sky2->hw))
+	    || !device_can_wakeup(&hw->pdev->dev))
 		return -EOPNOTSUPP;
 
 	sky2->wol = wol->wolopts;
@@ -3045,6 +3046,8 @@ static int sky2_set_wol(struct net_devic
 		sky2_write32(hw, B0_CTST, sky2->wol
 			     ? Y2_HW_WOL_ON : Y2_HW_WOL_OFF);
 
+	device_set_wakeup_enable(&hw->pdev->dev, sky2->wol);
+
 	if (!netif_running(dev))
 		sky2_wol_init(sky2);
 	return 0;
@@ -4179,18 +4182,6 @@ static int __devinit sky2_test_msi(struc
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
@@ -4314,7 +4305,7 @@ static int __devinit sky2_probe(struct p
 		}
 	}
 
-	wol_default = pci_wake_enabled(pdev) ? WAKE_MAGIC : 0;
+	wol_default = device_may_wakeup(&pdev->dev) ? WAKE_MAGIC : 0;
 
 	err = -ENOMEM;
 	hw = kzalloc(sizeof(*hw), GFP_KERNEL);
@@ -4479,7 +4470,7 @@ static void __devexit sky2_remove(struct
 static int sky2_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct sky2_hw *hw = pci_get_drvdata(pdev);
-	int i, wol = 0;
+	int i;
 
 	if (!hw)
 		return 0;
@@ -4497,8 +4488,6 @@ static int sky2_suspend(struct pci_dev *
 
 		if (sky2->wol)
 			sky2_wol_init(sky2);
-
-		wol |= sky2->wol;
 	}
 
 	sky2_write32(hw, B0_IMSK, 0);
@@ -4506,8 +4495,7 @@ static int sky2_suspend(struct pci_dev *
 	sky2_power_aux(hw);
 
 	pci_save_state(pdev);
-	pci_enable_wake(pdev, pci_choose_state(pdev, state), wol);
-	pci_set_power_state(pdev, pci_choose_state(pdev, state));
+	pci_prepare_to_sleep(pdev);
 
 	return 0;
 }
@@ -4520,7 +4508,7 @@ static int sky2_resume(struct pci_dev *p
 	if (!hw)
 		return 0;
 
-	err = pci_set_power_state(pdev, PCI_D0);
+	err = pci_back_from_sleep(pdev);
 	if (err)
 		goto out;
 
@@ -4528,8 +4516,6 @@ static int sky2_resume(struct pci_dev *p
 	if (err)
 		goto out;
 
-	pci_enable_wake(pdev, PCI_D0, 0);
-
 	/* Re-enable all clocks */
 	if (hw->chip_id == CHIP_ID_YUKON_EX ||
 	    hw->chip_id == CHIP_ID_YUKON_EC_U ||
@@ -4588,8 +4574,8 @@ static void sky2_shutdown(struct pci_dev
 	if (wol)
 		sky2_power_aux(hw);
 
-	pci_enable_wake(pdev, PCI_D3hot, wol);
-	pci_enable_wake(pdev, PCI_D3cold, wol);
+	if (pci_enable_wake(pdev, PCI_D3cold, wol))
+		pci_enable_wake(pdev, PCI_D3hot, wol);
 
 	pci_disable_device(pdev);
 	pci_set_power_state(pdev, PCI_D3hot);
_


