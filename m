From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [PATCH 2/3] Adapt the sky2 driver to the reworked PCI PM
Date: Thu, 14 Aug 2008 23:38:17 +0200
Message-ID: <200808142338.18361.rjw@sisk.pl>
References: <200808142335.56644.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jeff@garzik.org>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	LKML <linux-kernel@vger.kernel.org>,
	pm list <linux-pm@lists.linux-foundation.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:56445 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751052AbYHNVh5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2008 17:37:57 -0400
In-Reply-To: <200808142335.56644.rjw@sisk.pl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adapt the sky2 driver to the reworked PCI PM

* Use device_set_wakeup_enable() and friends as needed
* Remove an open-coded reference to the standard PCI PM registers
* Use pci_prepare_to_sleep() and pci_back_from_sleep() in the
  ->suspend() and ->resume() callbacks
* Use the observation that it is sufficient to call pci_enable_wake()
  once, unless it fails

Tested on Asus M3A32-MVP (Yukon-2 EC Ultra rev 3).

Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
---
 drivers/net/sky2.c |   34 ++++++++++------------------------
 1 file changed, 10 insertions(+), 24 deletions(-)

Index: linux-2.6/drivers/net/sky2.c
===================================================================
--- linux-2.6.orig/drivers/net/sky2.c
+++ linux-2.6/drivers/net/sky2.c
@@ -3035,7 +3035,8 @@ static int sky2_set_wol(struct net_devic
 	struct sky2_port *sky2 = netdev_priv(dev);
 	struct sky2_hw *hw = sky2->hw;
 
-	if (wol->wolopts & ~sky2_wol_supported(sky2->hw))
+	if ((wol->wolopts & ~sky2_wol_supported(sky2->hw))
+	    || !device_can_wakeup(&hw->pdev->dev))
 		return -EOPNOTSUPP;
 
 	sky2->wol = wol->wolopts;
@@ -3046,6 +3047,8 @@ static int sky2_set_wol(struct net_devic
 		sky2_write32(hw, B0_CTST, sky2->wol
 			     ? Y2_HW_WOL_ON : Y2_HW_WOL_OFF);
 
+	device_set_wakeup_enable(&hw->pdev->dev, sky2->wol);
+
 	if (!netif_running(dev))
 		sky2_wol_init(sky2);
 	return 0;
@@ -4167,18 +4170,6 @@ static int __devinit sky2_test_msi(struc
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
@@ -4239,7 +4230,7 @@ static int __devinit sky2_probe(struct p
 		}
 	}
 
-	wol_default = pci_wake_enabled(pdev) ? WAKE_MAGIC : 0;
+	wol_default = device_may_wakeup(&pdev->dev) ? WAKE_MAGIC : 0;
 
 	err = -ENOMEM;
 	hw = kzalloc(sizeof(*hw), GFP_KERNEL);
@@ -4404,7 +4395,7 @@ static void __devexit sky2_remove(struct
 static int sky2_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct sky2_hw *hw = pci_get_drvdata(pdev);
-	int i, wol = 0;
+	int i;
 
 	if (!hw)
 		return 0;
@@ -4422,8 +4413,6 @@ static int sky2_suspend(struct pci_dev *
 
 		if (sky2->wol)
 			sky2_wol_init(sky2);
-
-		wol |= sky2->wol;
 	}
 
 	sky2_write32(hw, B0_IMSK, 0);
@@ -4431,8 +4420,7 @@ static int sky2_suspend(struct pci_dev *
 	sky2_power_aux(hw);
 
 	pci_save_state(pdev);
-	pci_enable_wake(pdev, pci_choose_state(pdev, state), wol);
-	pci_set_power_state(pdev, pci_choose_state(pdev, state));
+	pci_prepare_to_sleep(pdev);
 
 	return 0;
 }
@@ -4445,7 +4433,7 @@ static int sky2_resume(struct pci_dev *p
 	if (!hw)
 		return 0;
 
-	err = pci_set_power_state(pdev, PCI_D0);
+	err = pci_back_from_sleep(pdev);
 	if (err)
 		goto out;
 
@@ -4453,8 +4441,6 @@ static int sky2_resume(struct pci_dev *p
 	if (err)
 		goto out;
 
-	pci_enable_wake(pdev, PCI_D0, 0);
-
 	/* Re-enable all clocks */
 	if (hw->chip_id == CHIP_ID_YUKON_EX ||
 	    hw->chip_id == CHIP_ID_YUKON_EC_U ||
@@ -4513,8 +4499,8 @@ static void sky2_shutdown(struct pci_dev
 	if (wol)
 		sky2_power_aux(hw);
 
-	pci_enable_wake(pdev, PCI_D3hot, wol);
-	pci_enable_wake(pdev, PCI_D3cold, wol);
+	if (pci_enable_wake(pdev, PCI_D3cold, wol))
+		pci_enable_wake(pdev, PCI_D3hot, wol);
 
 	pci_disable_device(pdev);
 	pci_set_power_state(pdev, PCI_D3hot);
