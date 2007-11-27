From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/3] sky2: revert to access PCI config via device space
Date: Tue, 27 Nov 2007 10:57:27 -0800
Message-ID: <20071127105727.1bcfa56f@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:56409 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758699AbXK0WKc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 17:10:32 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using the hardware window into PCI config space is more reliable
and smaller/faster than using the pci_config routines. It avoids issues
with MMCONFIG etc.

Reverts: 167f53d05fccb47b6eeadac7f6705b3f2f042d03

Please apply for 2.6.24

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/net/sky2.c	2007-11-26 14:02:14.000000000 -0800
+++ b/drivers/net/sky2.c	2007-11-26 14:02:31.000000000 -0800
@@ -240,22 +240,21 @@ static void sky2_power_on(struct sky2_hw
 		sky2_write8(hw, B2_Y2_CLK_GATE, 0);
 
 	if (hw->flags & SKY2_HW_ADV_POWER_CTL) {
-		struct pci_dev *pdev = hw->pdev;
 		u32 reg;
 
-		pci_write_config_dword(pdev, PCI_DEV_REG3, 0);
+		sky2_pci_write32(hw, PCI_DEV_REG3, 0);
 
-		pci_read_config_dword(pdev, PCI_DEV_REG4, &reg);
+		reg = sky2_pci_read32(hw, PCI_DEV_REG4);
 		/* set all bits to 0 except bits 15..12 and 8 */
 		reg &= P_ASPM_CONTROL_MSK;
-		pci_write_config_dword(pdev, PCI_DEV_REG4, reg);
+		sky2_pci_write32(hw, PCI_DEV_REG4, reg);
 
-		pci_read_config_dword(pdev, PCI_DEV_REG5, &reg);
+		reg = sky2_pci_read32(hw, PCI_DEV_REG5);
 		/* set all bits to 0 except bits 28 & 27 */
 		reg &= P_CTL_TIM_VMAIN_AV_MSK;
-		pci_write_config_dword(pdev, PCI_DEV_REG5, reg);
+		sky2_pci_write32(hw, PCI_DEV_REG5, reg);
 
-		pci_write_config_dword(pdev, PCI_CFG_REG_1, 0);
+		sky2_pci_write32(hw, PCI_CFG_REG_1, 0);
 
 		/* Enable workaround for dev 4.107 on Yukon-Ultra & Extreme */
 		reg = sky2_read32(hw, B2_GP_IO);
@@ -619,12 +618,11 @@ static void sky2_phy_init(struct sky2_hw
 
 static void sky2_phy_power(struct sky2_hw *hw, unsigned port, int onoff)
 {
-	struct pci_dev *pdev = hw->pdev;
 	u32 reg1;
 	static const u32 phy_power[] = { PCI_Y2_PHY1_POWD, PCI_Y2_PHY2_POWD };
 	static const u32 coma_mode[] = { PCI_Y2_PHY1_COMA, PCI_Y2_PHY2_COMA };
 
-	pci_read_config_dword(pdev, PCI_DEV_REG1, &reg1);
+	reg1 = sky2_pci_read32(hw, PCI_DEV_REG1);
 	/* Turn on/off phy power saving */
 	if (onoff)
 		reg1 &= ~phy_power[port];
@@ -634,8 +632,8 @@ static void sky2_phy_power(struct sky2_h
 	if (onoff && hw->chip_id == CHIP_ID_YUKON_XL && hw->chip_rev > 1)
 		reg1 |= coma_mode[port];
 
-	pci_write_config_dword(pdev, PCI_DEV_REG1, reg1);
-	pci_read_config_dword(pdev, PCI_DEV_REG1, &reg1);
+	sky2_pci_write32(hw, PCI_DEV_REG1, reg1);
+	reg1 = sky2_pci_read32(hw, PCI_DEV_REG1);
 
 	udelay(100);
 }
@@ -704,9 +702,9 @@ static void sky2_wol_init(struct sky2_po
 	sky2_write16(hw, WOL_REGS(port, WOL_CTRL_STAT), ctrl);
 
 	/* Turn on legacy PCI-Express PME mode */
-	pci_read_config_dword(hw->pdev, PCI_DEV_REG1, &reg1);
+	reg1 = sky2_pci_read32(hw, PCI_DEV_REG1);
 	reg1 |= PCI_Y2_PME_LEGACY;
-	pci_write_config_dword(hw->pdev, PCI_DEV_REG1, reg1);
+	sky2_pci_write32(hw, PCI_DEV_REG1, reg1);
 
 	/* block receiver */
 	sky2_write8(hw, SK_REG(port, RX_GMF_CTRL_T), GMF_RST_SET);
@@ -1322,9 +1320,10 @@ static int sky2_up(struct net_device *de
  	    (cap = pci_find_capability(hw->pdev, PCI_CAP_ID_PCIX))) {
  		u16 cmd;
 
-		pci_read_config_word(hw->pdev, cap + PCI_X_CMD, &cmd);
+		cmd = sky2_pci_read16(hw, cap + PCI_X_CMD);
  		cmd &= ~PCI_X_CMD_MAX_SPLIT;
-		pci_write_config_word(hw->pdev, cap + PCI_X_CMD, cmd);
+ 		sky2_pci_write16(hw, cap + PCI_X_CMD, cmd);
+
  	}
 
 	if (netif_msg_ifup(sky2))
@@ -2422,12 +2421,12 @@ static void sky2_hw_intr(struct sky2_hw 
 	if (status & (Y2_IS_MST_ERR | Y2_IS_IRQ_STAT)) {
 		u16 pci_err;
 
-		pci_read_config_word(pdev, PCI_STATUS, &pci_err);
+		pci_err = sky2_pci_read16(hw, PCI_STATUS);
 		if (net_ratelimit())
 			dev_err(&pdev->dev, "PCI hardware error (0x%x)\n",
 			        pci_err);
 
-		pci_write_config_word(pdev, PCI_STATUS,
+		sky2_pci_write16(hw, PCI_STATUS,
 				      pci_err | PCI_STATUS_ERROR_BITS);
 	}
 
@@ -2699,13 +2698,10 @@ static inline u32 sky2_clk2us(const stru
 
 static int __devinit sky2_init(struct sky2_hw *hw)
 {
-	int rc;
 	u8 t8;
 
 	/* Enable all clocks and check for bad PCI access */
-	rc = pci_write_config_dword(hw->pdev, PCI_DEV_REG3, 0);
-	if (rc)
-		return rc;
+	sky2_pci_write32(hw, PCI_DEV_REG3, 0);
 
 	sky2_write8(hw, B0_CTST, CS_RST_CLR);
 
@@ -2802,9 +2798,9 @@ static void sky2_reset(struct sky2_hw *h
 	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_ON);
 
 	/* clear PCI errors, if any */
-	pci_read_config_word(pdev, PCI_STATUS, &status);
+	status = sky2_pci_read16(hw, PCI_STATUS);
 	status |= PCI_STATUS_ERROR_BITS;
-	pci_write_config_word(pdev, PCI_STATUS, status);
+	sky2_pci_write16(hw, PCI_STATUS, status);
 
 	sky2_write8(hw, B0_CTST, CS_MRST_CLR);
 
@@ -3668,32 +3664,33 @@ static int sky2_set_tso(struct net_devic
 static int sky2_get_eeprom_len(struct net_device *dev)
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
+	struct sky2_hw *hw = sky2->hw;
 	u16 reg2;
 
-	pci_read_config_word(sky2->hw->pdev, PCI_DEV_REG2, &reg2);
+	reg2 = sky2_pci_read16(hw, PCI_DEV_REG2);
 	return 1 << ( ((reg2 & PCI_VPD_ROM_SZ) >> 14) + 8);
 }
 
-static u32 sky2_vpd_read(struct pci_dev *pdev, int cap, u16 offset)
+static u32 sky2_vpd_read(struct sky2_hw *hw, int cap, u16 offset)
 {
 	u32 val;
 
-	pci_write_config_word(pdev, cap + PCI_VPD_ADDR, offset);
+	sky2_pci_write16(hw, cap + PCI_VPD_ADDR, offset);
 
 	do {
-		pci_read_config_word(pdev, cap + PCI_VPD_ADDR, &offset);
+		offset = sky2_pci_read16(hw, cap + PCI_VPD_ADDR);
 	} while (!(offset & PCI_VPD_ADDR_F));
 
-	pci_read_config_dword(pdev, cap + PCI_VPD_DATA, &val);
+	val = sky2_pci_read32(hw, cap + PCI_VPD_DATA);
 	return val;
 }
 
-static void sky2_vpd_write(struct pci_dev *pdev, int cap, u16 offset, u32 val)
+static void sky2_vpd_write(struct sky2_hw *hw, int cap, u16 offset, u32 val)
 {
-	pci_write_config_word(pdev, cap + PCI_VPD_DATA, val);
-	pci_write_config_dword(pdev, cap + PCI_VPD_ADDR, offset | PCI_VPD_ADDR_F);
+	sky2_pci_write16(hw, cap + PCI_VPD_DATA, val);
+	sky2_pci_write32(hw, cap + PCI_VPD_ADDR, offset | PCI_VPD_ADDR_F);
 	do {
-		pci_read_config_word(pdev, cap + PCI_VPD_ADDR, &offset);
+		offset = sky2_pci_read16(hw, cap + PCI_VPD_ADDR);
 	} while (offset & PCI_VPD_ADDR_F);
 }
 
@@ -3711,7 +3708,7 @@ static int sky2_get_eeprom(struct net_de
 	eeprom->magic = SKY2_EEPROM_MAGIC;
 
 	while (length > 0) {
-		u32 val = sky2_vpd_read(sky2->hw->pdev, cap, offset);
+		u32 val = sky2_vpd_read(sky2->hw, cap, offset);
 		int n = min_t(int, length, sizeof(val));
 
 		memcpy(data, &val, n);
@@ -3741,10 +3738,10 @@ static int sky2_set_eeprom(struct net_de
 		int n = min_t(int, length, sizeof(val));
 
 		if (n < sizeof(val))
-			val = sky2_vpd_read(sky2->hw->pdev, cap, offset);
+			val = sky2_vpd_read(sky2->hw, cap, offset);
 		memcpy(&val, data, n);
 
-		sky2_vpd_write(sky2->hw->pdev, cap, offset, val);
+		sky2_vpd_write(sky2->hw, cap, offset, val);
 
 		length -= n;
 		data += n;
@@ -4180,9 +4177,9 @@ static int __devinit sky2_probe(struct p
 	 */
 	{
 		u32 reg;
-		pci_read_config_dword(pdev,PCI_DEV_REG2, &reg);
+		reg = sky2_pci_read32(hw, PCI_DEV_REG2);
 		reg &= ~PCI_REV_DESC;
-		pci_write_config_dword(pdev, PCI_DEV_REG2, reg);
+		sky2_pci_write32(hw, PCI_DEV_REG2, reg);
 	}
 #endif
 
@@ -4373,7 +4370,7 @@ static int sky2_resume(struct pci_dev *p
 	if (hw->chip_id == CHIP_ID_YUKON_EX ||
 	    hw->chip_id == CHIP_ID_YUKON_EC_U ||
 	    hw->chip_id == CHIP_ID_YUKON_FE_P)
-		pci_write_config_dword(pdev, PCI_DEV_REG3, 0);
+		sky2_pci_write32(hw, PCI_DEV_REG3, 0);
 
 	sky2_reset(hw);
 	sky2_write32(hw, B0_IMSK, Y2_IS_BASE);
--- a/drivers/net/sky2.h	2007-11-26 13:37:36.000000000 -0800
+++ b/drivers/net/sky2.h	2007-11-26 14:02:31.000000000 -0800
@@ -2128,4 +2128,25 @@ static inline void gma_set_addr(struct s
 	gma_write16(hw, port, reg+4,(u16) addr[2] | ((u16) addr[3] << 8));
 	gma_write16(hw, port, reg+8,(u16) addr[4] | ((u16) addr[5] << 8));
 }
+
+/* PCI config space access */
+static inline u32 sky2_pci_read32(const struct sky2_hw *hw, unsigned reg)
+{
+	return sky2_read32(hw, Y2_CFG_SPC + reg);
+}
+
+static inline u16 sky2_pci_read16(const struct sky2_hw *hw, unsigned reg)
+{
+	return sky2_read16(hw, Y2_CFG_SPC + reg);
+}
+
+static inline void sky2_pci_write32(struct sky2_hw *hw, unsigned reg, u32 val)
+{
+	sky2_write32(hw, Y2_CFG_SPC + reg, val);
+}
+
+static inline void sky2_pci_write16(struct sky2_hw *hw, unsigned reg, u16 val)
+{
+	sky2_write16(hw, Y2_CFG_SPC + reg, val);
+}
 #endif
