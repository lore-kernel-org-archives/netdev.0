From: akpm@linux-foundation.org
Subject: [patch 07/12] skge: adapt skge to use reworked PCI PM
Date: Wed, 30 Jul 2008 12:39:00 -0700
Message-ID: <200807301939.m6UJd0VN012518@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, rjw@sisk.pl,
	jbarnes@virtuousgeek.org, shemminger@linux-foundation.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49746 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754899AbYG3Tk3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 15:40:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafael J. Wysocki <rjw@sisk.pl>

Adapt the skge driver to use the reworked PCI PM.

Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
Cc: Stephen Hemminger <shemminger@linux-foundation.org>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: Jesse Barnes <jbarnes@virtuousgeek.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/skge.c |   38 +++++++++++---------------------------
 1 file changed, 11 insertions(+), 27 deletions(-)

diff -puN drivers/net/skge.c~skge-adapt-skge-to-use-reworked-pci-pm drivers/net/skge.c
--- a/drivers/net/skge.c~skge-adapt-skge-to-use-reworked-pci-pm
+++ a/drivers/net/skge.c
@@ -149,24 +149,6 @@ static u32 wol_supported(const struct sk
 	return WAKE_MAGIC | WAKE_PHY;
 }
 
-static u32 pci_wake_enabled(struct pci_dev *dev)
-{
-	int pm = pci_find_capability(dev, PCI_CAP_ID_PM);
-	u16 value;
-
-	/* If device doesn't support PM Capabilities, but request is to disable
-	 * wake events, it's a nop; otherwise fail */
-	if (!pm)
-		return 0;
-
-	pci_read_config_word(dev, pm + PCI_PM_PMC, &value);
-
-	value &= PCI_PM_CAP_PME_MASK;
-	value >>= ffs(PCI_PM_CAP_PME_MASK) - 1;   /* First bit of mask */
-
-	return value != 0;
-}
-
 static void skge_wol_init(struct skge_port *skge)
 {
 	struct skge_hw *hw = skge->hw;
@@ -254,10 +236,14 @@ static int skge_set_wol(struct net_devic
 	struct skge_port *skge = netdev_priv(dev);
 	struct skge_hw *hw = skge->hw;
 
-	if (wol->wolopts & ~wol_supported(hw))
+	if ((wol->wolopts & ~wol_supported(hw))
+	    || !device_can_wakeup(&hw->pdev->dev))
 		return -EOPNOTSUPP;
 
 	skge->wol = wol->wolopts;
+
+	device_set_wakeup_enable(&hw->pdev->dev, skge->wol);
+
 	return 0;
 }
 
@@ -3842,7 +3828,7 @@ static struct net_device *skge_devinit(s
 	skge->speed = -1;
 	skge->advertising = skge_supported_modes(hw);
 
-	if (pci_wake_enabled(hw->pdev))
+	if (device_may_wakeup(&hw->pdev->dev))
 		skge->wol = wol_supported(hw) & WAKE_MAGIC;
 
 	hw->dev[port] = dev;
@@ -4068,8 +4054,8 @@ static int skge_suspend(struct pci_dev *
 	}
 
 	skge_write32(hw, B0_IMSK, 0);
-	pci_enable_wake(pdev, pci_choose_state(pdev, state), wol);
-	pci_set_power_state(pdev, pci_choose_state(pdev, state));
+
+	pci_prepare_to_sleep(pdev);
 
 	return 0;
 }
@@ -4082,7 +4068,7 @@ static int skge_resume(struct pci_dev *p
 	if (!hw)
 		return 0;
 
-	err = pci_set_power_state(pdev, PCI_D0);
+	err = pci_back_from_sleep(pdev);
 	if (err)
 		goto out;
 
@@ -4090,8 +4076,6 @@ static int skge_resume(struct pci_dev *p
 	if (err)
 		goto out;
 
-	pci_enable_wake(pdev, PCI_D0, 0);
-
 	err = skge_reset(hw);
 	if (err)
 		goto out;
@@ -4132,8 +4116,8 @@ static void skge_shutdown(struct pci_dev
 		wol |= skge->wol;
 	}
 
-	pci_enable_wake(pdev, PCI_D3hot, wol);
-	pci_enable_wake(pdev, PCI_D3cold, wol);
+	if (pci_enable_wake(pdev, PCI_D3cold, wol))
+		pci_enable_wake(pdev, PCI_D3hot, wol);
 
 	pci_disable_device(pdev);
 	pci_set_power_state(pdev, PCI_D3hot);
_
