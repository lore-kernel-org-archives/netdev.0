From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFT 1/5] sky2: suspend/resume patchlets
Date: Tue, 13 Jun 2006 17:17:27 +0900
Message-ID: <20060613081929.922127000@localhost.localdomain>
References: <20060613081726.695812000@localhost.localdomain>
Cc: linus@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:17899 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750746AbWFMIUd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2006 04:20:33 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-set-power-state.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Subject: [RFT 1/5] sky2: set_power_state should be void

The set power state function is cleaner if it doesn't return anything.
The only caller that could fail is in suspend() and it can check the argument
there.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- test.orig/drivers/net/sky2.c
+++ test/drivers/net/sky2.c
@@ -187,12 +187,11 @@ static u16 gm_phy_read(struct sky2_hw *h
 	return v;
 }
 
-static int sky2_set_power_state(struct sky2_hw *hw, pci_power_t state)
+static void sky2_set_power_state(struct sky2_hw *hw, pci_power_t state)
 {
 	u16 power_control;
 	u32 reg1;
 	int vaux;
-	int ret = 0;
 
 	pr_debug("sky2_set_power_state %d\n", state);
 	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
@@ -275,12 +274,10 @@ static int sky2_set_power_state(struct s
 		break;
 	default:
 		printk(KERN_ERR PFX "Unknown power state %d\n", state);
-		ret = -1;
 	}
 
 	sky2_pci_write16(hw, hw->pm_cap + PCI_PM_CTRL, power_control);
 	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
-	return ret;
 }
 
 static void sky2_phy_reset(struct sky2_hw *hw, unsigned port)
@@ -3428,6 +3425,10 @@ static int sky2_suspend(struct pci_dev *
 {
 	struct sky2_hw *hw = pci_get_drvdata(pdev);
 	int i;
+	pci_power_t pstate = pci_choose_state(pdev, state);
+
+	if (!(pstate == PCI_D3hot || pstate == PCI_D3cold))
+		return -EINVAL;
 
 	for (i = 0; i < 2; i++) {
 		struct net_device *dev = hw->dev[i];
@@ -3442,7 +3443,8 @@ static int sky2_suspend(struct pci_dev *
 	}
 
 	pci_save_state(pdev);
-	return sky2_set_power_state(hw, pci_choose_state(pdev, state));
+	sky2_set_power_state(hw, pstate);
+	return 0;
 }
 
 static int sky2_resume(struct pci_dev *pdev)
@@ -3452,9 +3454,7 @@ static int sky2_resume(struct pci_dev *p
 
 	pci_restore_state(pdev);
 	pci_enable_wake(pdev, PCI_D0, 0);
-	err = sky2_set_power_state(hw, PCI_D0);
-	if (err)
-		goto out;
+	sky2_set_power_state(hw, PCI_D0);
 
 	err = sky2_reset(hw);
 	if (err)

--

