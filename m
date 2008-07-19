From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [PATCH 1/4] skge: Adapt skge to use reworked PCI PM
Date: Sat, 19 Jul 2008 14:38:18 +0200
Message-ID: <200807191438.19832.rjw@sisk.pl>
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
Received: from ogre.sisk.pl ([217.79.144.158]:44354 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753968AbYGSMmH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Jul 2008 08:42:07 -0400
In-Reply-To: <200807191436.40726.rjw@sisk.pl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafael J. Wysocki <rjw@sisk.pl>

Adapt the skge driver to use the reworked PCI PM.

Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
---
 drivers/net/skge.c |   38 +++++++++++---------------------------
 1 file changed, 11 insertions(+), 27 deletions(-)

Index: linux-next/drivers/net/skge.c
===================================================================
--- linux-next.orig/drivers/net/skge.c
+++ linux-next/drivers/net/skge.c
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

