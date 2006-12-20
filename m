From: Stephen Hemminger <shemminger@osdl.org>
Subject: [patch 4/6] sky2: better power state management
Date: Wed, 20 Dec 2006 13:06:36 -0800
Message-ID: <20061220210923.245868668@osdl.org>
References: <20061220210632.183204605@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:58437 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423160AbWLVAmj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Dec 2006 19:42:39 -0500
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-power-state.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Improve power management and error handling by using pci_set_power_state(),
instead of driver doing PCI PM register changes in the driver.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 drivers/net/sky2.c |  140 +++++++++++++++++++++--------------------------------
 drivers/net/sky2.h |    1 
 2 files changed, 57 insertions(+), 84 deletions(-)

--- sky2-2.6.orig/drivers/net/sky2.c	2006-12-20 12:45:37.000000000 -0800
+++ sky2-2.6/drivers/net/sky2.c	2006-12-20 12:45:40.000000000 -0800
@@ -192,76 +192,52 @@
 	return v;
 }
 
-static void sky2_set_power_state(struct sky2_hw *hw, pci_power_t state)
-{
-	u16 power_control;
-	int vaux;
-
-	pr_debug("sky2_set_power_state %d\n", state);
-	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
-
-	power_control = sky2_pci_read16(hw, hw->pm_cap + PCI_PM_PMC);
-	vaux = (sky2_read16(hw, B0_CTST) & Y2_VAUX_AVAIL) &&
-		(power_control & PCI_PM_CAP_PME_D3cold);
-
-	power_control = sky2_pci_read16(hw, hw->pm_cap + PCI_PM_CTRL);
-
-	power_control |= PCI_PM_CTRL_PME_STATUS;
-	power_control &= ~(PCI_PM_CTRL_STATE_MASK);
-
-	switch (state) {
-	case PCI_D0:
-		/* switch power to VCC (WA for VAUX problem) */
-		sky2_write8(hw, B0_POWER_CTRL,
-			    PC_VAUX_ENA | PC_VCC_ENA | PC_VAUX_OFF | PC_VCC_ON);
 
-		/* disable Core Clock Division, */
-		sky2_write32(hw, B2_Y2_CLK_CTRL, Y2_CLK_DIV_DIS);
-
-		if (hw->chip_id == CHIP_ID_YUKON_XL && hw->chip_rev > 1)
-			/* enable bits are inverted */
-			sky2_write8(hw, B2_Y2_CLK_GATE,
-				    Y2_PCI_CLK_LNK1_DIS | Y2_COR_CLK_LNK1_DIS |
-				    Y2_CLK_GAT_LNK1_DIS | Y2_PCI_CLK_LNK2_DIS |
-				    Y2_COR_CLK_LNK2_DIS | Y2_CLK_GAT_LNK2_DIS);
-		else
-			sky2_write8(hw, B2_Y2_CLK_GATE, 0);
+static void sky2_power_on(struct sky2_hw *hw)
+{
+	/* switch power to VCC (WA for VAUX problem) */
+	sky2_write8(hw, B0_POWER_CTRL,
+		    PC_VAUX_ENA | PC_VCC_ENA | PC_VAUX_OFF | PC_VCC_ON);
 
-		if (hw->chip_id == CHIP_ID_YUKON_EC_U) {
-			u32 reg1;
+	/* disable Core Clock Division, */
+	sky2_write32(hw, B2_Y2_CLK_CTRL, Y2_CLK_DIV_DIS);
 
-			sky2_pci_write32(hw, PCI_DEV_REG3, 0);
-			reg1 = sky2_pci_read32(hw, PCI_DEV_REG4);
-			reg1 &= P_ASPM_CONTROL_MSK;
-			sky2_pci_write32(hw, PCI_DEV_REG4, reg1);
-			sky2_pci_write32(hw, PCI_DEV_REG5, 0);
-		}
+	if (hw->chip_id == CHIP_ID_YUKON_XL && hw->chip_rev > 1)
+		/* enable bits are inverted */
+		sky2_write8(hw, B2_Y2_CLK_GATE,
+			    Y2_PCI_CLK_LNK1_DIS | Y2_COR_CLK_LNK1_DIS |
+			    Y2_CLK_GAT_LNK1_DIS | Y2_PCI_CLK_LNK2_DIS |
+			    Y2_COR_CLK_LNK2_DIS | Y2_CLK_GAT_LNK2_DIS);
+	else
+		sky2_write8(hw, B2_Y2_CLK_GATE, 0);
 
-		break;
+	if (hw->chip_id == CHIP_ID_YUKON_EC_U) {
+		u32 reg1;
 
-	case PCI_D3hot:
-	case PCI_D3cold:
-		if (hw->chip_id == CHIP_ID_YUKON_XL && hw->chip_rev > 1)
-			sky2_write8(hw, B2_Y2_CLK_GATE, 0);
-		else
-			/* enable bits are inverted */
-			sky2_write8(hw, B2_Y2_CLK_GATE,
-				    Y2_PCI_CLK_LNK1_DIS | Y2_COR_CLK_LNK1_DIS |
-				    Y2_CLK_GAT_LNK1_DIS | Y2_PCI_CLK_LNK2_DIS |
-				    Y2_COR_CLK_LNK2_DIS | Y2_CLK_GAT_LNK2_DIS);
-
-		/* switch power to VAUX */
-		if (vaux && state != PCI_D3cold)
-			sky2_write8(hw, B0_POWER_CTRL,
-				    (PC_VAUX_ENA | PC_VCC_ENA |
-				     PC_VAUX_ON | PC_VCC_OFF));
-		break;
-	default:
-		printk(KERN_ERR PFX "Unknown power state %d\n", state);
+		sky2_pci_write32(hw, PCI_DEV_REG3, 0);
+		reg1 = sky2_pci_read32(hw, PCI_DEV_REG4);
+		reg1 &= P_ASPM_CONTROL_MSK;
+		sky2_pci_write32(hw, PCI_DEV_REG4, reg1);
+		sky2_pci_write32(hw, PCI_DEV_REG5, 0);
 	}
+}
 
-	sky2_pci_write16(hw, hw->pm_cap + PCI_PM_CTRL, power_control);
-	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
+static void sky2_power_aux(struct sky2_hw *hw)
+{
+	if (hw->chip_id == CHIP_ID_YUKON_XL && hw->chip_rev > 1)
+		sky2_write8(hw, B2_Y2_CLK_GATE, 0);
+	else
+		/* enable bits are inverted */
+		sky2_write8(hw, B2_Y2_CLK_GATE,
+			    Y2_PCI_CLK_LNK1_DIS | Y2_COR_CLK_LNK1_DIS |
+			    Y2_CLK_GAT_LNK1_DIS | Y2_PCI_CLK_LNK2_DIS |
+			    Y2_COR_CLK_LNK2_DIS | Y2_CLK_GAT_LNK2_DIS);
+
+	/* switch power to VAUX */
+	if (sky2_read16(hw, B0_CTST) & Y2_VAUX_AVAIL)
+		sky2_write8(hw, B0_POWER_CTRL,
+			    (PC_VAUX_ENA | PC_VCC_ENA |
+			     PC_VAUX_ON | PC_VCC_OFF));
 }
 
 static void sky2_gmac_reset(struct sky2_hw *hw, unsigned port)
@@ -2480,7 +2456,7 @@
 			++hw->ports;
 	}
 
-	sky2_set_power_state(hw, PCI_D0);
+	sky2_power_on(hw);
 
 	for (i = 0; i < hw->ports; i++) {
 		sky2_write8(hw, SK_REG(i, GMAC_LINK_CTRL), GMLC_RST_SET);
@@ -3376,7 +3352,7 @@
 {
 	struct net_device *dev, *dev1 = NULL;
 	struct sky2_hw *hw;
-	int err, pm_cap, using_dac = 0;
+	int err, using_dac = 0;
 
 	err = pci_enable_device(pdev);
 	if (err) {
@@ -3394,15 +3370,6 @@
 
 	pci_set_master(pdev);
 
-	/* Find power-management capability. */
-	pm_cap = pci_find_capability(pdev, PCI_CAP_ID_PM);
-	if (pm_cap == 0) {
-		printk(KERN_ERR PFX "Cannot find PowerManagement capability, "
-		       "aborting.\n");
-		err = -EIO;
-		goto err_out_free_regions;
-	}
-
 	if (sizeof(dma_addr_t) > sizeof(u32) &&
 	    !(err = pci_set_dma_mask(pdev, DMA_64BIT_MASK))) {
 		using_dac = 1;
@@ -3438,7 +3405,6 @@
 		       pci_name(pdev));
 		goto err_out_free_hw;
 	}
-	hw->pm_cap = pm_cap;
 
 #ifdef __BIG_ENDIAN
 	/* The sk98lin vendor driver uses hardware byte swapping but
@@ -3555,7 +3521,8 @@
 		unregister_netdev(dev1);
 	unregister_netdev(dev0);
 
-	sky2_set_power_state(hw, PCI_D3hot);
+	sky2_power_aux(hw);
+
 	sky2_write16(hw, B0_Y2LED, LED_STAT_OFF);
 	sky2_write8(hw, B0_CTST, CS_RST_SET);
 	sky2_read8(hw, B0_CTST);
@@ -3581,10 +3548,6 @@
 {
 	struct sky2_hw *hw = pci_get_drvdata(pdev);
 	int i;
-	pci_power_t pstate = pci_choose_state(pdev, state);
-
-	if (!(pstate == PCI_D3hot || pstate == PCI_D3cold))
-		return -EINVAL;
 
 	del_timer_sync(&hw->idle_timer);
 	netif_poll_disable(hw->dev[0]);
@@ -3599,8 +3562,10 @@
 	}
 
 	sky2_write32(hw, B0_IMSK, 0);
+	sky2_power_aux(hw);
 	pci_save_state(pdev);
-	sky2_set_power_state(hw, pstate);
+	pci_set_power_state(pdev, pci_choose_state(pdev, state));
+
 	return 0;
 }
 
@@ -3609,9 +3574,15 @@
 	struct sky2_hw *hw = pci_get_drvdata(pdev);
 	int i, err;
 
-	pci_restore_state(pdev);
+	err = pci_set_power_state(pdev, PCI_D0);
+	if (err)
+		goto out;
+
+	err = pci_restore_state(pdev);
+	if (err)
+		goto out;
+
 	pci_enable_wake(pdev, PCI_D0, 0);
-	sky2_set_power_state(hw, PCI_D0);
 
 	err = sky2_reset(hw);
 	if (err)
@@ -3636,7 +3607,10 @@
 
 	netif_poll_enable(hw->dev[0]);
 	sky2_idle_start(hw);
+	return 0;
 out:
+	printk(KERN_ERR PFX "%s: resume failed (%d)\n", pci_name(pdev), err);
+	pci_disable_device(pdev);
 	return err;
 }
 
--- sky2-2.6.orig/drivers/net/sky2.h	2006-12-20 12:45:22.000000000 -0800
+++ sky2-2.6/drivers/net/sky2.h	2006-12-20 12:45:40.000000000 -0800
@@ -1887,7 +1887,6 @@
 	struct pci_dev	     *pdev;
 	struct net_device    *dev[2];
 
-	int		     pm_cap;
 	u8	     	     chip_id;
 	u8		     chip_rev;
 	u8		     pmd_type;

--
Stephen Hemminger <shemminger@osdl.org>

