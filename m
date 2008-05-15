From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 5/5] sky2: pci power savings
Date: Wed, 14 May 2008 17:04:17 -0700
Message-ID: <20080515000433.212572503@vyatta.com>
References: <20080515000412.984337700@vyatta.com>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([69.59.150.140]:49971 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760281AbYEOAIX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2008 20:08:23 -0400
Content-Disposition: inline; filename=pci-power.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Turn on special bits to save more power when device is shutdown.
Tested on a limited range of hardware, some of the bits are for hardware
that probably isn't even in production (like Yukon Supreme) and was ported
from the vendor driver.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
This is experimental so wait for 2.6.27 (#upstream) and go in -mm


--- a/drivers/net/sky2.c	2008-05-14 16:29:48.000000000 -0700
+++ b/drivers/net/sky2.c	2008-05-14 16:29:50.000000000 -0700
@@ -284,6 +284,86 @@ static void sky2_power_aux(struct sky2_h
 			     PC_VAUX_ON | PC_VCC_OFF));
 }
 
+static void sky2_power_state(struct sky2_hw *hw, pci_power_t state)
+{
+	u16 power_control = sky2_pci_read16(hw, hw->pm_cap + PCI_PM_CTRL);
+	int pex = pci_find_capability(hw->pdev, PCI_CAP_ID_EXP);
+	u32 reg;
+
+	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
+
+	switch (state) {
+	case PCI_D0:
+		break;
+
+	case PCI_D1:
+		power_control |= 1;
+		break;
+
+	case PCI_D2:
+		power_control |= 2;
+		break;
+
+	case PCI_D3hot:
+	case PCI_D3cold:
+		power_control |= 3;
+		if (hw->flags & SKY2_HW_ADV_POWER_CTL) {
+			/* additional power saving measurements */
+			reg = sky2_pci_read32(hw, PCI_DEV_REG4);
+
+			/* set gating core clock for LTSSM in L1 state */
+			reg |= P_PEX_LTSSM_STAT(P_PEX_LTSSM_L1_STAT) |
+				/* auto clock gated scheme controlled by CLKREQ */
+				P_ASPM_A1_MODE_SELECT |
+				/* enable Gate Root Core Clock */
+				P_CLK_GATE_ROOT_COR_ENA;
+
+			if (pex && (hw->flags & SKY2_HW_CLK_POWER)) {
+				/* enable Clock Power Management (CLKREQ) */
+				u16 ctrl = sky2_pci_read16(hw, pex + PCI_EXP_DEVCTL);
+
+				ctrl |= PCI_EXP_DEVCTL_AUX_PME;
+				sky2_pci_write16(hw, pex + PCI_EXP_DEVCTL, ctrl);
+			} else
+				/* force CLKREQ Enable in Our4 (A1b only) */
+				reg |= P_ASPM_FORCE_CLKREQ_ENA;
+
+			/* set Mask Register for Release/Gate Clock */
+			sky2_pci_write32(hw, PCI_DEV_REG5,
+					 P_REL_PCIE_EXIT_L1_ST | P_GAT_PCIE_ENTER_L1_ST |
+					 P_REL_PCIE_RX_EX_IDLE | P_GAT_PCIE_RX_EL_IDLE |
+					 P_REL_GPHY_LINK_UP | P_GAT_GPHY_LINK_DOWN);
+		} else
+			sky2_write8(hw, B28_Y2_ASF_STAT_CMD, Y2_ASF_CLK_HALT);
+
+		/* put CPU into reset state */
+		sky2_write8(hw,  B28_Y2_ASF_STAT_CMD, HCU_CCSR_ASF_RESET);
+		if (hw->chip_id == CHIP_ID_YUKON_SUPR && hw->chip_rev == CHIP_REV_YU_SU_A0)
+			/* put CPU into halt state */
+			sky2_write8(hw, B28_Y2_ASF_STAT_CMD, HCU_CCSR_ASF_HALTED);
+
+		if (pex && !(hw->flags & SKY2_HW_RAM_BUFFER)) {
+			reg = sky2_pci_read32(hw, PCI_DEV_REG1);
+			/* force to PCIe L1 */
+			reg |= PCI_FORCE_PEX_L1;
+			sky2_pci_write32(hw, PCI_DEV_REG1, reg);
+		}
+		break;
+
+	default:
+		dev_warn(&hw->pdev->dev, PFX "Invalid power state (%d) ",
+		       state);
+		return;
+	}
+
+	power_control |= PCI_PM_CTRL_PME_ENABLE;
+	/* Finally, set the new power state. */
+	sky2_pci_write32(hw, hw->pm_cap + PCI_PM_CTRL, power_control);
+
+	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
+	sky2_pci_read32(hw, B0_CTST);
+}
+
 static void sky2_gmac_reset(struct sky2_hw *hw, unsigned port)
 {
 	u16 reg;
@@ -2786,6 +2866,10 @@ static int __devinit sky2_init(struct sk
 		hw->flags = SKY2_HW_GIGABIT
 			| SKY2_HW_NEWER_PHY
 			| SKY2_HW_ADV_POWER_CTL;
+
+		/* check for Rev. A1 dev 4200 */
+		if (sky2_read16(hw, Q_ADDR(Q_XA1, Q_WM)) == 0)
+			hw->flags |= SKY2_HW_CLK_POWER;
 		break;
 
 	case CHIP_ID_YUKON_EX:
@@ -2836,6 +2920,11 @@ static int __devinit sky2_init(struct sk
 	if (hw->pmd_type == 'L' || hw->pmd_type == 'S' || hw->pmd_type == 'P')
 		hw->flags |= SKY2_HW_FIBRE_PHY;
 
+	hw->pm_cap = pci_find_capability(hw->pdev, PCI_CAP_ID_PM);
+	if (hw->pm_cap == 0) {
+		dev_err(&hw->pdev->dev, "cannot find PowerManagement capability\n");
+		return -EIO;
+	}
 
 	hw->ports = 1;
 	t8 = sky2_read8(hw, B2_Y2_HW_RES);
@@ -4407,7 +4496,7 @@ static int sky2_suspend(struct pci_dev *
 
 	pci_save_state(pdev);
 	pci_enable_wake(pdev, pci_choose_state(pdev, state), wol);
-	pci_set_power_state(pdev, pci_choose_state(pdev, state));
+	sky2_power_state(hw, pci_choose_state(pdev, state));
 
 	return 0;
 }
@@ -4420,9 +4509,7 @@ static int sky2_resume(struct pci_dev *p
 	if (!hw)
 		return 0;
 
-	err = pci_set_power_state(pdev, PCI_D0);
-	if (err)
-		goto out;
+	sky2_power_state(hw, PCI_D0);
 
 	err = pci_restore_state(pdev);
 	if (err)
@@ -4490,8 +4577,7 @@ static void sky2_shutdown(struct pci_dev
 	pci_enable_wake(pdev, PCI_D3cold, wol);
 
 	pci_disable_device(pdev);
-	pci_set_power_state(pdev, PCI_D3hot);
-
+	sky2_power_state(hw, PCI_D3hot);
 }
 
 static struct pci_driver sky2_driver = {
--- a/drivers/net/sky2.h	2008-05-14 16:29:48.000000000 -0700
+++ b/drivers/net/sky2.h	2008-05-14 16:29:50.000000000 -0700
@@ -28,6 +28,11 @@ enum pci_dev_reg_1 {
 	PCI_Y2_PHY2_POWD = 1<<27, /* Set PHY 2 to Power Down (YUKON-2) */
 	PCI_Y2_PHY1_POWD = 1<<26, /* Set PHY 1 to Power Down (YUKON-2) */
 	PCI_Y2_PME_LEGACY= 1<<15, /* PCI Express legacy power management mode */
+
+	PCI_PHY_LNK_TIM_MSK= 3L<<8,/* Bit  9.. 8:	GPHY Link Trigger Timer */
+	PCI_ENA_L1_EVENT = 1<<7, /* Enable PEX L1 Event */
+	PCI_ENA_GPHY_LNK = 1<<6, /* Enable PEX L1 on GPHY Link down */
+	PCI_FORCE_PEX_L1 = 1<<5, /* Force to PEX L1 */
 };
 
 enum pci_dev_reg_2 {
@@ -45,7 +50,11 @@ enum pci_dev_reg_2 {
 
 /*	PCI_OUR_REG_4		32 bit	Our Register 4 (Yukon-ECU only) */
 enum pci_dev_reg_4 {
-					/* (Link Training & Status State Machine) */
+				/* (Link Training & Status State Machine) */
+	P_PEX_LTSSM_STAT_MSK	= 0x7fL<<25,	/* Bit 31..25:	PEX LTSSM Mask */
+#define P_PEX_LTSSM_STAT(x)	((x << 25) & P_PEX_LTSSM_STAT_MSK)
+	P_PEX_LTSSM_L1_STAT	= 0x34,
+	P_PEX_LTSSM_DET_STAT	= 0x01,
 	P_TIMER_VALUE_MSK	= 0xffL<<16,	/* Bit 23..16:	Timer Value Mask */
 					/* (Active State Power Management) */
 	P_FORCE_ASPM_REQUEST	= 1<<15, /* Force ASPM Request (A1 only) */
@@ -454,6 +463,9 @@ enum yukon_ex_rev {
 	CHIP_REV_YU_EX_A0    = 1,
 	CHIP_REV_YU_EX_B0    = 2,
 };
+enum yukon_supr_rev {
+	CHIP_REV_YU_SU_A0    = 0,
+};
 
 
 /*	B2_Y2_CLK_GATE	 8 bit	Clock Gating (Yukon-2 only) */
@@ -2059,7 +2071,9 @@ struct sky2_hw {
 #define SKY2_HW_NEW_LE		0x00000020	/* new LSOv2 format */
 #define SKY2_HW_AUTO_TX_SUM	0x00000040	/* new IP decode for Tx */
 #define SKY2_HW_ADV_POWER_CTL	0x00000080	/* additional PHY power regs */
+#define SKY2_HW_CLK_POWER	0x00000100	/* clock power management */
 
+	int		     pm_cap;
 	u8	     	     chip_id;
 	u8		     chip_rev;
 	u8		     pmd_type;

-- 

