From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 24/26] atl1: update wake-on-lan
Date: Mon, 31 Dec 2007 20:22:51 -0600
Message-ID: <1199154173-4058-25-git-send-email-jacliburn@bellsouth.net>
References: <1199154173-4058-1-git-send-email-jacliburn@bellsouth.net>
Cc: Jay Cliburn <jacliburn@bellsouth.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost02.isp.att.net ([207.115.11.52]:63857 "EHLO
	fmailhost02.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752671AbYAAC2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 21:28:17 -0500
In-Reply-To: <1199154173-4058-1-git-send-email-jacliburn@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update wake-on-lan to conform with the current vendor driver version
1.2.40.2.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---
 drivers/net/atlx/atl1.c |  140 ++++++++++++++++++++++++++++-------------------
 1 files changed, 84 insertions(+), 56 deletions(-)

diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index b89201e..237622e 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -1457,22 +1457,6 @@ static u32 atl1_configure(struct atl1_adapter *adapter)
 	return value;
 }
 
-/*
- * When ACPI resume on some VIA MotherBoard, the Interrupt Disable bit/0x400
- * on PCI Command register is disable.
- * The function enable this bit.
- * Brackett, 2006/03/15
- */
-static void atl1_via_workaround(struct atl1_adapter *adapter)
-{
-	unsigned long value;
-
-	value = ioread16(adapter->hw.hw_addr + PCI_COMMAND);
-	if (value & PCI_COMMAND_INTX_DISABLE)
-		value &= ~PCI_COMMAND_INTX_DISABLE;
-	iowrite32(value, adapter->hw.hw_addr + PCI_COMMAND);
-}
-
 static void atl1_inc_smb(struct atl1_adapter *adapter)
 {
 	struct stats_msg_block *smb = adapter->smb.smb;
@@ -2607,65 +2591,97 @@ static int atl1_suspend(struct pci_dev *pdev, pm_message_t state)
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct atl1_adapter *adapter = netdev_priv(netdev);
 	struct atl1_hw *hw = &adapter->hw;
+	u16 speed, duplex;
 	u32 ctrl = 0;
 	u32 wufc = adapter->wol;
+	int retval;
 
 	netif_device_detach(netdev);
-	if (netif_running(netdev))
+	if (netif_running(netdev)) {
+		WARN_ON(test_bit(__ATL1_RESETTING, &adapter->flags));
 		atl1_down(adapter);
+	}
+
+	retval = pci_save_state(pdev);
+	if (retval)
+		return retval;
 
-	atl1_read_phy_reg(hw, MII_BMSR, (u16 *) & ctrl);
-	atl1_read_phy_reg(hw, MII_BMSR, (u16 *) & ctrl);
+	atl1_read_phy_reg(hw, MII_BMSR, (u16 *) &ctrl);
+	atl1_read_phy_reg(hw, MII_BMSR, (u16 *) &ctrl);
 	if (ctrl & BMSR_LSTATUS)
 		wufc &= ~ATLX_WUFC_LNKC;
 
-	/* reduce speed to 10/100M */
-	if (wufc) {
-		/* if resume, let driver to re- setup link */
-		hw->phy_configured = false;
-		atl1_set_mac_addr(hw);
-		atlx_set_multi(netdev);
+	if ((ctrl & BMSR_LSTATUS) && wufc) {
+		retval = atl1_get_speed_and_duplex(hw, &speed, &duplex);
+		if (retval) {
+			dev_printk(KERN_DEBUG, &adapter->pdev->dev,
+				"speed/duplex error during suspend\n");
+			goto wol_dis;
+		}
 
 		ctrl = 0;
 		/* turn on magic packet wol */
 		if (wufc & ATLX_WUFC_MAG)
 			ctrl = WOL_MAGIC_EN | WOL_MAGIC_PME_EN;
 
-		/* turn on Link change WOL */
-		if (wufc & ATLX_WUFC_LNKC)
-			ctrl |= (WOL_LINK_CHG_EN | WOL_LINK_CHG_PME_EN);
 		iowrite32(ctrl, hw->hw_addr + REG_WOL_CTRL);
 
-		/* turn on all-multi mode if wake on multicast is enabled */
-		ctrl = ioread32(hw->hw_addr + REG_MAC_CTRL);
-		ctrl &= ~MAC_CTRL_DBG;
-		ctrl &= ~MAC_CTRL_PROMIS_EN;
-		if (wufc & ATLX_WUFC_MC)
-			ctrl |= MAC_CTRL_MC_ALL_EN;
-		else
-			ctrl &= ~MAC_CTRL_MC_ALL_EN;
+		ctrl = MAC_CTRL_RX_EN;
+		ctrl |= ((u32) ((speed == SPEED_1000) ?	MAC_CTRL_SPEED_1000 :
+			MAC_CTRL_SPEED_10_100) << MAC_CTRL_SPEED_SHIFT);
+
+		if (duplex == FULL_DUPLEX)
+			ctrl |= (((u32) adapter->hw.preamble_len &
+				MAC_CTRL_PRMLEN_MASK) <<
+				MAC_CTRL_PRMLEN_SHIFT);
 
-		/* turn on broadcast mode if wake on-BC is enabled */
-		if (wufc & ATLX_WUFC_BC)
+		if (adapter->vlgrp)
+			ctrl |= MAC_CTRL_RMV_VLAN;
+
+		if (wufc & ATLX_WUFC_MAG)
 			ctrl |= MAC_CTRL_BC_EN;
-		else
-			ctrl &= ~MAC_CTRL_BC_EN;
 
-		/* enable RX */
-		ctrl |= MAC_CTRL_RX_EN;
 		iowrite32(ctrl, hw->hw_addr + REG_MAC_CTRL);
-		pci_enable_wake(pdev, PCI_D3hot, 1);
-		pci_enable_wake(pdev, PCI_D3cold, 1);
-	} else {
-		iowrite32(0, hw->hw_addr + REG_WOL_CTRL);
-		pci_enable_wake(pdev, PCI_D3hot, 0);
-		pci_enable_wake(pdev, PCI_D3cold, 0);
+
+		ctrl = ioread32(hw->hw_addr + REG_PCIE_PHY_MISC1);
+		ctrl |= PCIE_PHY_MISC1_FORCE_RCV_DET;
+		iowrite32(ctrl, hw->hw_addr + REG_PCIE_PHY_MISC1);
+		ioread32(hw->hw_addr + REG_PCIE_PHY_MISC1);
+		hw->phy_configured = false;
+		pci_enable_wake(pdev, pci_choose_state(pdev, state), 1);
+		goto suspend_exit;
 	}
 
-	pci_save_state(pdev);
-	pci_disable_device(pdev);
+	if (!(ctrl & BMSR_LSTATUS) && (wufc & ATLX_WUFC_LNKC)) {
+		ctrl |= WOL_LINK_CHG_EN | WOL_LINK_CHG_PME_EN;
+		iowrite32(ctrl, hw->hw_addr + REG_WOL_CTRL);
+		iowrite32(0, hw->hw_addr + REG_MAC_CTRL);
+
+		ctrl = ioread32(hw->hw_addr + REG_PCIE_PHY_MISC1);
+		ctrl |= PCIE_PHY_MISC1_FORCE_RCV_DET;
+		iowrite32(ctrl, hw->hw_addr + REG_PCIE_PHY_MISC1);
+		ioread32(hw->hw_addr + REG_PCIE_PHY_MISC1);
+		hw->phy_configured = false;
+		pci_enable_wake(pdev, pci_choose_state(pdev, state), 1);
+		goto suspend_exit;
+	}
+
+wol_dis:
+	iowrite32(0, hw->hw_addr + REG_WOL_CTRL);
+	ctrl = ioread32(hw->hw_addr + REG_PCIE_PHY_MISC1);
+	ctrl |= PCIE_PHY_MISC1_FORCE_RCV_DET;
+	iowrite32(ctrl, hw->hw_addr + REG_PCIE_PHY_MISC1);
+	ioread32(hw->hw_addr + REG_PCIE_PHY_MISC1);
+	atl1_force_ps(hw);
+	hw->phy_configured = false;
+	pci_enable_wake(pdev, pci_choose_state(pdev, state), 0);
+
+suspend_exit:
+	if (netif_running(netdev))
+		atl1_free_irq(adapter);
 
-	pci_set_power_state(pdev, PCI_D3hot);
+	pci_disable_device(pdev);
+	pci_set_power_state(pdev, pci_choose_state(pdev, state));
 
 	return 0;
 }
@@ -2674,24 +2690,36 @@ static int atl1_resume(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct atl1_adapter *adapter = netdev_priv(netdev);
+	struct atl1_hw *hw = &adapter->hw;
 	u32 err;
 
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
 
-	/* FIXME: check and handle */
 	err = pci_enable_device(pdev);
+	if (err) {
+		dev_printk(KERN_DEBUG, &adapter->pdev->dev,
+			"pci enable device error on resume\n");
+		return err;
+	}
+
+	pci_set_master(pdev);
+	ioread32(hw->hw_addr + REG_WOL_CTRL);
 	pci_enable_wake(pdev, PCI_D3hot, 0);
 	pci_enable_wake(pdev, PCI_D3cold, 0);
+	iowrite32(0, hw->hw_addr + REG_WOL_CTRL);
+
+	err = atl1_request_irq(adapter);
+	if (netif_running(netdev) && err)
+		return err;
 
-	iowrite32(0, adapter->hw.hw_addr + REG_WOL_CTRL);
-	atl1_reset(adapter);
+	atl1_reset_hw(hw);
+	adapter->cmb.cmb->int_stats = 0;
 
 	if (netif_running(netdev))
 		atl1_up(adapter);
-	netif_device_attach(netdev);
 
-	atl1_via_workaround(adapter);
+	netif_device_attach(netdev);
 
 	return 0;
 }
-- 
1.5.3.3

