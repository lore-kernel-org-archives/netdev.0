From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH] sky2: Serialize access to PCI config space
Date: Thu, 06 Aug 2009 20:10:27 +0900
Message-ID: <4A7ABA23.6060201@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Rene Mayrhofer <rene@mayrhofer.eu.org>,
	Richard Leitner <leitner@esys.at>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f196.google.com ([209.85.222.196]:42795 "EHLO
	mail-pz0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753176AbZHFLUN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 07:20:13 -0400
Received: by pzk34 with SMTP id 34so826093pzk.4
        for <netdev@vger.kernel.org>; Thu, 06 Aug 2009 04:20:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PCI config space may be shared across two device instances,
 or accessed from an interrupt
 , so serialize access so
 read-update-write operations do not interfere with each other.

Only tested on a single port card, as my sky2 doesn't have dual ports.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |   23 ++++++++++++++++-------
 drivers/net/sky2.h |    1 +
 2 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 1415a83..4d09632 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -618,6 +618,7 @@ static void sky2_phy_power_up(struct sky2_hw *hw, unsigned port)
 {
 	u32 reg1;
 
+	spin_lock(&hw->pci_cfg_lock);
 	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
 	reg1 = sky2_pci_read32(hw, PCI_DEV_REG1);
 	reg1 &= ~phy_power[port];
@@ -628,6 +629,7 @@ static void sky2_phy_power_up(struct sky2_hw *hw, unsigned port)
 	sky2_pci_write32(hw, PCI_DEV_REG1, reg1);
 	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
 	sky2_pci_read32(hw, PCI_DEV_REG1);
+	spin_unlock(&hw->pci_cfg_lock);
 
 	if (hw->chip_id == CHIP_ID_YUKON_FE)
 		gm_phy_write(hw, port, PHY_MARV_CTRL, PHY_CT_ANE);
@@ -681,11 +683,13 @@ static void sky2_phy_power_down(struct sky2_hw *hw, unsigned port)
 		gm_phy_write(hw, port, PHY_MARV_CTRL, PHY_CT_PDOWN);
 	}
 
+	spin_lock(&hw->pci_cfg_lock);
 	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
 	reg1 = sky2_pci_read32(hw, PCI_DEV_REG1);
 	reg1 |= phy_power[port];		/* set PHY to PowerDown/COMA Mode */
 	sky2_pci_write32(hw, PCI_DEV_REG1, reg1);
 	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
+	spin_unlock(&hw->pci_cfg_lock);
 }
 
 /* Force a renegotiation */
@@ -2596,30 +2600,34 @@ static void sky2_hw_intr(struct sky2_hw *hw)
 	if (status & (Y2_IS_MST_ERR | Y2_IS_IRQ_STAT)) {
 		u16 pci_err;
 
+		spin_lock(&hw->pci_cfg_lock);
 		sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
 		pci_err = sky2_pci_read16(hw, PCI_STATUS);
-		if (net_ratelimit())
-			dev_err(&pdev->dev, "PCI hardware error (0x%x)\n",
-			        pci_err);
-
 		sky2_pci_write16(hw, PCI_STATUS,
 				      pci_err | PCI_STATUS_ERROR_BITS);
 		sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
+		spin_unlock(&hw->pci_cfg_lock);
+
+		if (net_ratelimit())
+			dev_err(&pdev->dev, "PCI hardware error (0x%x)\n",
+			        pci_err);
 	}
 
 	if (status & Y2_IS_PCI_EXP) {
 		/* PCI-Express uncorrectable Error occurred */
 		u32 err;
 
+		spin_lock(&hw->pci_cfg_lock);
 		sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
 		err = sky2_read32(hw, Y2_CFG_AER + PCI_ERR_UNCOR_STATUS);
 		sky2_write32(hw, Y2_CFG_AER + PCI_ERR_UNCOR_STATUS,
 			     0xfffffffful);
-		if (net_ratelimit())
-			dev_err(&pdev->dev, "PCI Express error (0x%x)\n", err);
-
 		sky2_read32(hw, Y2_CFG_AER + PCI_ERR_UNCOR_STATUS);
 		sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
+		spin_unlock(&hw->pci_cfg_lock);
+
+		if (net_ratelimit())
+			dev_err(&pdev->dev, "PCI Express error (0x%x)\n", err);
 	}
 
 	if (status & Y2_HWE_L1_MASK)
@@ -4485,6 +4493,7 @@ static int __devinit sky2_probe(struct pci_dev *pdev,
 	}
 
 	hw->pdev = pdev;
+	spin_lock_init(&hw->pci_cfg_lock);
 
 	hw->regs = ioremap_nocache(pci_resource_start(pdev, 0), 0x4000);
 	if (!hw->regs) {
diff --git a/drivers/net/sky2.h b/drivers/net/sky2.h
index 4486b06..5a9b0cf 100644
--- a/drivers/net/sky2.h
+++ b/drivers/net/sky2.h
@@ -2087,6 +2087,7 @@ struct sky2_hw {
 	struct timer_list    watchdog_timer;
 	struct work_struct   restart_work;
 	wait_queue_head_t    msi_wait;
+	spinlock_t	     pci_cfg_lock;
 };
 
 static inline int sky2_is_copper(const struct sky2_hw *hw)
-- 
1.5.6.5

