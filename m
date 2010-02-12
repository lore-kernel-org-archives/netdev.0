From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 02/10] sky2: WoL changes
Date: Fri, 12 Feb 2010 08:57:59 -0800
Message-ID: <20100212165937.653629696@vyatta.com>
References: <20100212165757.767062851@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49487 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757265Ab0BLRHt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Feb 2010 12:07:49 -0500
Content-Disposition: inline; filename=sky2-wol-alt.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change Wake On Lan code to be similar to vendor driver. The definition
of Y2_HW_WOL_ON is confusing; what it means is transition to firmware SPI
setting when doing power change.

Since same code is done for both shutdown and suspend, use common
code path.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sky2.c	2010-02-10 20:05:09.850493345 -0800
+++ b/drivers/net/sky2.c	2010-02-10 20:05:20.711411236 -0800
@@ -251,6 +251,8 @@ static void sky2_power_on(struct sky2_hw
 
 		sky2_pci_write32(hw, PCI_CFG_REG_1, 0);
 
+		sky2_write16(hw, B0_CTST, Y2_HW_WOL_ON);
+
 		/* Enable workaround for dev 4.107 on Yukon-Ultra & Extreme */
 		reg = sky2_read32(hw, B2_GP_IO);
 		reg |= GLB_GPIO_STAT_RACE_DIS;
@@ -782,6 +784,9 @@ static void sky2_wol_init(struct sky2_po
 	ctrl |= WOL_CTL_DIS_PME_ON_PATTERN|WOL_CTL_DIS_PATTERN_UNIT;
 	sky2_write16(hw, WOL_REGS(port, WOL_CTRL_STAT), ctrl);
 
+	/* Disable PiG firmware */
+	sky2_write16(hw, B0_CTST, Y2_HW_WOL_OFF);
+
 	/* Turn on legacy PCI-Express PME mode */
 	reg1 = sky2_pci_read32(hw, PCI_DEV_REG1);
 	reg1 |= PCI_Y2_PME_LEGACY;
@@ -789,7 +794,6 @@ static void sky2_wol_init(struct sky2_po
 
 	/* block receiver */
 	sky2_write8(hw, SK_REG(port, RX_GMF_CTRL_T), GMF_RST_SET);
-
 }
 
 static void sky2_set_tx_stfwd(struct sky2_hw *hw, unsigned port)
@@ -3272,27 +3276,6 @@ static inline u8 sky2_wol_supported(cons
 	return sky2_is_copper(hw) ? (WAKE_PHY | WAKE_MAGIC) : 0;
 }
 
-static void sky2_hw_set_wol(struct sky2_hw *hw)
-{
-	int wol = 0;
-	int i;
-
-	for (i = 0; i < hw->ports; i++) {
-		struct net_device *dev = hw->dev[i];
-		struct sky2_port *sky2 = netdev_priv(dev);
-
-		if (sky2->wol)
-			wol = 1;
-	}
-
-	if (hw->chip_id == CHIP_ID_YUKON_EC_U ||
-	    hw->chip_id == CHIP_ID_YUKON_EX ||
-	    hw->chip_id == CHIP_ID_YUKON_FE_P)
-		sky2_write32(hw, B0_CTST, wol ? Y2_HW_WOL_ON : Y2_HW_WOL_OFF);
-
-	device_set_wakeup_enable(&hw->pdev->dev, wol);
-}
-
 static void sky2_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
 	const struct sky2_port *sky2 = netdev_priv(dev);
@@ -3311,11 +3294,6 @@ static int sky2_set_wol(struct net_devic
 		return -EOPNOTSUPP;
 
 	sky2->wol = wol->wolopts;
-
-	sky2_hw_set_wol(hw);
-
-	if (!netif_running(dev))
-		sky2_wol_init(sky2);
 	return 0;
 }
 
@@ -4809,7 +4787,6 @@ static void __devexit sky2_remove(struct
 	pci_set_drvdata(pdev, NULL);
 }
 
-#ifdef CONFIG_PM
 static int sky2_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct sky2_hw *hw = pci_get_drvdata(pdev);
@@ -4834,6 +4811,8 @@ static int sky2_suspend(struct pci_dev *
 		wol |= sky2->wol;
 	}
 
+	device_set_wakeup_enable(&pdev->dev, wol != 0);
+
 	sky2_write32(hw, B0_IMSK, 0);
 	napi_disable(&hw->napi);
 	sky2_power_aux(hw);
@@ -4846,6 +4825,7 @@ static int sky2_suspend(struct pci_dev *
 	return 0;
 }
 
+#ifdef CONFIG_PM
 static int sky2_resume(struct pci_dev *pdev)
 {
 	struct sky2_hw *hw = pci_get_drvdata(pdev);
@@ -4895,34 +4875,7 @@ out:
 
 static void sky2_shutdown(struct pci_dev *pdev)
 {
-	struct sky2_hw *hw = pci_get_drvdata(pdev);
-	int i, wol = 0;
-
-	if (!hw)
-		return;
-
-	rtnl_lock();
-	del_timer_sync(&hw->watchdog_timer);
-
-	for (i = 0; i < hw->ports; i++) {
-		struct net_device *dev = hw->dev[i];
-		struct sky2_port *sky2 = netdev_priv(dev);
-
-		if (sky2->wol) {
-			wol = 1;
-			sky2_wol_init(sky2);
-		}
-	}
-
-	if (wol)
-		sky2_power_aux(hw);
-	rtnl_unlock();
-
-	pci_enable_wake(pdev, PCI_D3hot, wol);
-	pci_enable_wake(pdev, PCI_D3cold, wol);
-
-	pci_disable_device(pdev);
-	pci_set_power_state(pdev, PCI_D3hot);
+	sky2_suspend(pdev, PMSG_SUSPEND);
 }
 
 static struct pci_driver sky2_driver = {

-- 

