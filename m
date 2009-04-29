From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 07/16] ixgbe: Use generic MDIO definitions and functions
Date: Wed, 29 Apr 2009 19:08:58 +0100
Message-ID: <1241028538.3246.46.camel@achroite>
References: <1241028086.3246.30.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	e1000-devel@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:58595 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751957AbZD2SJD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 14:09:03 -0400
In-Reply-To: <1241028086.3246.30.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Compile-tested only.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/Kconfig             |    1 +
 drivers/net/ixgbe/ixgbe_82598.c |   33 +++++++-------
 drivers/net/ixgbe/ixgbe_82599.c |   17 +++----
 drivers/net/ixgbe/ixgbe_main.c  |   42 +++++++++++++++++
 drivers/net/ixgbe/ixgbe_phy.c   |   95 +++++++++++++--------------------------
 drivers/net/ixgbe/ixgbe_type.h  |   33 +------------
 6 files changed, 102 insertions(+), 119 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 435bbc9..b8727d5 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2519,6 +2519,7 @@ config ENIC
 config IXGBE
 	tristate "Intel(R) 10GbE PCI Express adapters support"
 	depends on PCI && INET
+	select MDIO
 	---help---
 	  This driver supports Intel(R) 10GbE PCI Express family of
 	  adapters.  For more information on how to identify your adapter, go
diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index 03eb54f..e051964 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -229,14 +229,13 @@ static s32 ixgbe_get_copper_link_capabilities_82598(struct ixgbe_hw *hw,
 	*speed = 0;
 	*autoneg = true;
 
-	status = hw->phy.ops.read_reg(hw, IXGBE_MDIO_PHY_SPEED_ABILITY,
-	                              IXGBE_MDIO_PMA_PMD_DEV_TYPE,
+	status = hw->phy.ops.read_reg(hw, MDIO_SPEED, MDIO_MMD_PMAPMD,
 	                              &speed_ability);
 
 	if (status == 0) {
-		if (speed_ability & IXGBE_MDIO_PHY_SPEED_10G)
+		if (speed_ability & MDIO_SPEED_10G)
 		    *speed |= IXGBE_LINK_SPEED_10GB_FULL;
-		if (speed_ability & IXGBE_MDIO_PHY_SPEED_1G)
+		if (speed_ability & MDIO_PMA_SPEED_1000)
 		    *speed |= IXGBE_LINK_SPEED_1GB_FULL;
 	}
 
@@ -526,9 +525,9 @@ static s32 ixgbe_check_mac_link_82598(struct ixgbe_hw *hw,
 	 * clear indicates active; set indicates inactive.
 	 */
 	if (hw->phy.type == ixgbe_phy_nl) {
-		hw->phy.ops.read_reg(hw, 0xC79F, IXGBE_TWINAX_DEV, &link_reg);
-		hw->phy.ops.read_reg(hw, 0xC79F, IXGBE_TWINAX_DEV, &link_reg);
-		hw->phy.ops.read_reg(hw, 0xC00C, IXGBE_TWINAX_DEV,
+		hw->phy.ops.read_reg(hw, 0xC79F, MDIO_MMD_PMAPMD, &link_reg);
+		hw->phy.ops.read_reg(hw, 0xC79F, MDIO_MMD_PMAPMD, &link_reg);
+		hw->phy.ops.read_reg(hw, 0xC00C, MDIO_MMD_PMAPMD,
 		                     &adapt_comp_reg);
 		if (link_up_wait_to_complete) {
 			for (i = 0; i < IXGBE_LINK_UP_TIME; i++) {
@@ -541,10 +540,10 @@ static s32 ixgbe_check_mac_link_82598(struct ixgbe_hw *hw,
 				}
 				msleep(100);
 				hw->phy.ops.read_reg(hw, 0xC79F,
-				                     IXGBE_TWINAX_DEV,
+				                     MDIO_MMD_PMAPMD,
 				                     &link_reg);
 				hw->phy.ops.read_reg(hw, 0xC00C,
-				                     IXGBE_TWINAX_DEV,
+				                     MDIO_MMD_PMAPMD,
 				                     &adapt_comp_reg);
 			}
 		} else {
@@ -990,14 +989,14 @@ static s32 ixgbe_read_i2c_eeprom_82598(struct ixgbe_hw *hw, u8 byte_offset,
 		sfp_addr = (sfp_addr | IXGBE_I2C_EEPROM_READ_MASK);
 		hw->phy.ops.write_reg(hw,
 		                      IXGBE_MDIO_PMA_PMD_SDA_SCL_ADDR,
-		                      IXGBE_MDIO_PMA_PMD_DEV_TYPE,
+		                      MDIO_MMD_PMAPMD,
 		                      sfp_addr);
 
 		/* Poll status */
 		for (i = 0; i < 100; i++) {
 			hw->phy.ops.read_reg(hw,
 			                     IXGBE_MDIO_PMA_PMD_SDA_SCL_STAT,
-			                     IXGBE_MDIO_PMA_PMD_DEV_TYPE,
+			                     MDIO_MMD_PMAPMD,
 			                     &sfp_stat);
 			sfp_stat = sfp_stat & IXGBE_I2C_EEPROM_STATUS_MASK;
 			if (sfp_stat != IXGBE_I2C_EEPROM_STATUS_IN_PROGRESS)
@@ -1013,7 +1012,7 @@ static s32 ixgbe_read_i2c_eeprom_82598(struct ixgbe_hw *hw, u8 byte_offset,
 
 		/* Read data */
 		hw->phy.ops.read_reg(hw, IXGBE_MDIO_PMA_PMD_SDA_SCL_DATA,
-		                     IXGBE_MDIO_PMA_PMD_DEV_TYPE, &sfp_data);
+		                     MDIO_MMD_PMAPMD, &sfp_data);
 
 		*eeprom_data = (u8)(sfp_data >> 8);
 	} else {
@@ -1045,13 +1044,13 @@ static u32 ixgbe_get_supported_physical_layer_82598(struct ixgbe_hw *hw)
 	 * physical layer because 10GBase-T PHYs use LMS = KX4/KX */
 	if (hw->phy.type == ixgbe_phy_tn ||
 	    hw->phy.type == ixgbe_phy_cu_unknown) {
-		hw->phy.ops.read_reg(hw, IXGBE_MDIO_PHY_EXT_ABILITY,
-		IXGBE_MDIO_PMA_PMD_DEV_TYPE, &ext_ability);
-		if (ext_ability & IXGBE_MDIO_PHY_10GBASET_ABILITY)
+		hw->phy.ops.read_reg(hw, MDIO_PMA_EXTABLE, MDIO_MMD_PMAPMD,
+				     &ext_ability);
+		if (ext_ability & MDIO_PMA_EXTABLE_10GBT)
 			physical_layer |= IXGBE_PHYSICAL_LAYER_10GBASE_T;
-		if (ext_ability & IXGBE_MDIO_PHY_1000BASET_ABILITY)
+		if (ext_ability & MDIO_PMA_EXTABLE_1000BT)
 			physical_layer |= IXGBE_PHYSICAL_LAYER_1000BASE_T;
-		if (ext_ability & IXGBE_MDIO_PHY_100BASETX_ABILITY)
+		if (ext_ability & MDIO_PMA_EXTABLE_100BTX)
 			physical_layer |= IXGBE_PHYSICAL_LAYER_100BASE_TX;
 		goto out;
 	}
diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 9e824b4..6038ed1 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -314,14 +314,13 @@ static s32 ixgbe_get_copper_link_capabilities_82599(struct ixgbe_hw *hw,
 	*speed = 0;
 	*autoneg = true;
 
-	status = hw->phy.ops.read_reg(hw, IXGBE_MDIO_PHY_SPEED_ABILITY,
-	                              IXGBE_MDIO_PMA_PMD_DEV_TYPE,
+	status = hw->phy.ops.read_reg(hw, MDIO_SPEED, MDIO_MMD_PMAPMD,
 	                              &speed_ability);
 
 	if (status == 0) {
-		if (speed_ability & IXGBE_MDIO_PHY_SPEED_10G)
+		if (speed_ability & MDIO_SPEED_10G)
 		    *speed |= IXGBE_LINK_SPEED_10GB_FULL;
-		if (speed_ability & IXGBE_MDIO_PHY_SPEED_1G)
+		if (speed_ability & MDIO_PMA_SPEED_1000)
 		    *speed |= IXGBE_LINK_SPEED_1GB_FULL;
 	}
 
@@ -1153,13 +1152,13 @@ u32 ixgbe_get_supported_physical_layer_82599(struct ixgbe_hw *hw)
 
 	if (hw->phy.type == ixgbe_phy_tn ||
 	    hw->phy.type == ixgbe_phy_cu_unknown) {
-		hw->phy.ops.read_reg(hw, IXGBE_MDIO_PHY_EXT_ABILITY,
-		IXGBE_MDIO_PMA_PMD_DEV_TYPE, &ext_ability);
-		if (ext_ability & IXGBE_MDIO_PHY_10GBASET_ABILITY)
+		hw->phy.ops.read_reg(hw, MDIO_PMA_EXTABLE, MDIO_MMD_PMAPMD,
+				     &ext_ability);
+		if (ext_ability & MDIO_PMA_EXTABLE_10GBT)
 			physical_layer |= IXGBE_PHYSICAL_LAYER_10GBASE_T;
-		if (ext_ability & IXGBE_MDIO_PHY_1000BASET_ABILITY)
+		if (ext_ability & MDIO_PMA_EXTABLE_1000BT)
 			physical_layer |= IXGBE_PHYSICAL_LAYER_1000BASE_T;
-		if (ext_ability & IXGBE_MDIO_PHY_100BASETX_ABILITY)
+		if (ext_ability & MDIO_PMA_EXTABLE_100BTX)
 			physical_layer |= IXGBE_PHYSICAL_LAYER_100BASE_TX;
 		goto out;
 	}
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 5020f11..a84f980 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -4646,6 +4646,40 @@ static int ixgbe_set_mac(struct net_device *netdev, void *p)
 	return 0;
 }
 
+static int
+ixgbe_mdio_read(struct net_device *netdev, int prtad, int devad, u16 addr)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_hw *hw = &adapter->hw;
+	u16 value;
+	int rc;
+
+	if (prtad != hw->phy.mdio.prtad)
+		return -EINVAL;
+	rc = hw->phy.ops.read_reg(hw, addr, devad, &value);
+	if (!rc)
+		rc = value;
+	return rc;
+}
+
+static int ixgbe_mdio_write(struct net_device *netdev, int prtad, int devad,
+			    u16 addr, u16 value)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_hw *hw = &adapter->hw;
+
+	if (prtad != hw->phy.mdio.prtad)
+		return -EINVAL;
+	return hw->phy.ops.write_reg(hw, addr, devad, value);
+}
+
+static int ixgbe_ioctl(struct net_device *netdev, struct ifreq *req, int cmd)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+
+	return mdio_mii_ioctl(&adapter->hw.phy.mdio, if_mii(req), cmd);
+}
+
 #ifdef CONFIG_NET_POLL_CONTROLLER
 /*
  * Polling 'interrupt' - used by things like netconsole to send skbs
@@ -4679,6 +4713,7 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_vlan_rx_register	= ixgbe_vlan_rx_register,
 	.ndo_vlan_rx_add_vid	= ixgbe_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	= ixgbe_vlan_rx_kill_vid,
+	.ndo_do_ioctl		= ixgbe_ioctl,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= ixgbe_netpoll,
 #endif
@@ -4793,6 +4828,13 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	/* PHY */
 	memcpy(&hw->phy.ops, ii->phy_ops, sizeof(hw->phy.ops));
 	hw->phy.sfp_type = ixgbe_sfp_type_unknown;
+	/* ixgbe_identify_phy_generic will set prtad and mmds properly */
+	hw->phy.mdio.prtad = MDIO_PRTAD_NONE;
+	hw->phy.mdio.mmds = 0;
+	hw->phy.mdio.mode_support = MDIO_SUPPORTS_C45 | MDIO_EMULATE_C22;
+	hw->phy.mdio.dev = netdev;
+	hw->phy.mdio.mdio_read = ixgbe_mdio_read;
+	hw->phy.mdio.mdio_write = ixgbe_mdio_write;
 
 	/* set up this timer and work struct before calling get_invariants
 	 * which might start the timer
diff --git a/drivers/net/ixgbe/ixgbe_phy.c b/drivers/net/ixgbe/ixgbe_phy.c
index 2543c32..6d385ea 100644
--- a/drivers/net/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ixgbe/ixgbe_phy.c
@@ -44,7 +44,6 @@ static void ixgbe_lower_i2c_clk(struct ixgbe_hw *hw, u32 *i2cctl);
 static s32 ixgbe_set_i2c_data(struct ixgbe_hw *hw, u32 *i2cctl, bool data);
 static bool ixgbe_get_i2c_data(u32 *i2cctl);
 static void ixgbe_i2c_bus_clear(struct ixgbe_hw *hw);
-static bool ixgbe_validate_phy_addr(struct ixgbe_hw *hw, u32 phy_addr);
 static enum ixgbe_phy_type ixgbe_get_phy_type_from_id(u32 phy_id);
 static s32 ixgbe_get_phy_id(struct ixgbe_hw *hw);
 
@@ -61,8 +60,7 @@ s32 ixgbe_identify_phy_generic(struct ixgbe_hw *hw)
 
 	if (hw->phy.type == ixgbe_phy_unknown) {
 		for (phy_addr = 0; phy_addr < IXGBE_MAX_PHY_ADDR; phy_addr++) {
-			if (ixgbe_validate_phy_addr(hw, phy_addr)) {
-				hw->phy.addr = phy_addr;
+			if (mdio45_probe(&hw->phy.mdio, phy_addr) == 0) {
 				ixgbe_get_phy_id(hw);
 				hw->phy.type =
 				        ixgbe_get_phy_type_from_id(hw->phy.id);
@@ -78,26 +76,6 @@ s32 ixgbe_identify_phy_generic(struct ixgbe_hw *hw)
 }
 
 /**
- *  ixgbe_validate_phy_addr - Determines phy address is valid
- *  @hw: pointer to hardware structure
- *
- **/
-static bool ixgbe_validate_phy_addr(struct ixgbe_hw *hw, u32 phy_addr)
-{
-	u16 phy_id = 0;
-	bool valid = false;
-
-	hw->phy.addr = phy_addr;
-	hw->phy.ops.read_reg(hw, IXGBE_MDIO_PHY_ID_HIGH,
-	                     IXGBE_MDIO_PMA_PMD_DEV_TYPE, &phy_id);
-
-	if (phy_id != 0xFFFF && phy_id != 0x0)
-		valid = true;
-
-	return valid;
-}
-
-/**
  *  ixgbe_get_phy_id - Get the phy type
  *  @hw: pointer to hardware structure
  *
@@ -108,14 +86,12 @@ static s32 ixgbe_get_phy_id(struct ixgbe_hw *hw)
 	u16 phy_id_high = 0;
 	u16 phy_id_low = 0;
 
-	status = hw->phy.ops.read_reg(hw, IXGBE_MDIO_PHY_ID_HIGH,
-	                              IXGBE_MDIO_PMA_PMD_DEV_TYPE,
+	status = hw->phy.ops.read_reg(hw, MDIO_DEVID1, MDIO_MMD_PMAPMD,
 	                              &phy_id_high);
 
 	if (status == 0) {
 		hw->phy.id = (u32)(phy_id_high << 16);
-		status = hw->phy.ops.read_reg(hw, IXGBE_MDIO_PHY_ID_LOW,
-		                              IXGBE_MDIO_PMA_PMD_DEV_TYPE,
+		status = hw->phy.ops.read_reg(hw, MDIO_DEVID2, MDIO_MMD_PMAPMD,
 		                              &phy_id_low);
 		hw->phy.id |= (u32)(phy_id_low & IXGBE_PHY_REVISION_MASK);
 		hw->phy.revision = (u32)(phy_id_low & ~IXGBE_PHY_REVISION_MASK);
@@ -160,9 +136,8 @@ s32 ixgbe_reset_phy_generic(struct ixgbe_hw *hw)
 	 * Perform soft PHY reset to the PHY_XS.
 	 * This will cause a soft reset to the PHY
 	 */
-	return hw->phy.ops.write_reg(hw, IXGBE_MDIO_PHY_XS_CONTROL,
-	                             IXGBE_MDIO_PHY_XS_DEV_TYPE,
-	                             IXGBE_MDIO_PHY_XS_RESET);
+	return hw->phy.ops.write_reg(hw, MDIO_CTRL1, MDIO_MMD_PHYXS,
+				     MDIO_CTRL1_RESET);
 }
 
 /**
@@ -192,7 +167,7 @@ s32 ixgbe_read_phy_reg_generic(struct ixgbe_hw *hw, u32 reg_addr,
 		/* Setup and write the address cycle command */
 		command = ((reg_addr << IXGBE_MSCA_NP_ADDR_SHIFT)  |
 		           (device_type << IXGBE_MSCA_DEV_TYPE_SHIFT) |
-		           (hw->phy.addr << IXGBE_MSCA_PHY_ADDR_SHIFT) |
+		           (hw->phy.mdio.prtad << IXGBE_MSCA_PHY_ADDR_SHIFT) |
 		           (IXGBE_MSCA_ADDR_CYCLE | IXGBE_MSCA_MDI_COMMAND));
 
 		IXGBE_WRITE_REG(hw, IXGBE_MSCA, command);
@@ -223,7 +198,8 @@ s32 ixgbe_read_phy_reg_generic(struct ixgbe_hw *hw, u32 reg_addr,
 			 */
 			command = ((reg_addr << IXGBE_MSCA_NP_ADDR_SHIFT)  |
 			           (device_type << IXGBE_MSCA_DEV_TYPE_SHIFT) |
-			           (hw->phy.addr << IXGBE_MSCA_PHY_ADDR_SHIFT) |
+			           (hw->phy.mdio.prtad <<
+				    IXGBE_MSCA_PHY_ADDR_SHIFT) |
 			           (IXGBE_MSCA_READ | IXGBE_MSCA_MDI_COMMAND));
 
 			IXGBE_WRITE_REG(hw, IXGBE_MSCA, command);
@@ -292,7 +268,7 @@ s32 ixgbe_write_phy_reg_generic(struct ixgbe_hw *hw, u32 reg_addr,
 		/* Setup and write the address cycle command */
 		command = ((reg_addr << IXGBE_MSCA_NP_ADDR_SHIFT)  |
 		           (device_type << IXGBE_MSCA_DEV_TYPE_SHIFT) |
-		           (hw->phy.addr << IXGBE_MSCA_PHY_ADDR_SHIFT) |
+		           (hw->phy.mdio.prtad << IXGBE_MSCA_PHY_ADDR_SHIFT) |
 		           (IXGBE_MSCA_ADDR_CYCLE | IXGBE_MSCA_MDI_COMMAND));
 
 		IXGBE_WRITE_REG(hw, IXGBE_MSCA, command);
@@ -323,7 +299,8 @@ s32 ixgbe_write_phy_reg_generic(struct ixgbe_hw *hw, u32 reg_addr,
 			 */
 			command = ((reg_addr << IXGBE_MSCA_NP_ADDR_SHIFT)  |
 			           (device_type << IXGBE_MSCA_DEV_TYPE_SHIFT) |
-			           (hw->phy.addr << IXGBE_MSCA_PHY_ADDR_SHIFT) |
+			           (hw->phy.mdio.prtad <<
+				    IXGBE_MSCA_PHY_ADDR_SHIFT) |
 			           (IXGBE_MSCA_WRITE | IXGBE_MSCA_MDI_COMMAND));
 
 			IXGBE_WRITE_REG(hw, IXGBE_MSCA, command);
@@ -365,7 +342,7 @@ s32 ixgbe_setup_phy_link_generic(struct ixgbe_hw *hw)
 	s32 status = IXGBE_NOT_IMPLEMENTED;
 	u32 time_out;
 	u32 max_time_out = 10;
-	u16 autoneg_reg = IXGBE_MII_AUTONEG_REG;
+	u16 autoneg_reg;
 
 	/*
 	 * Set advertisement settings in PHY based on autoneg_advertised
@@ -373,36 +350,31 @@ s32 ixgbe_setup_phy_link_generic(struct ixgbe_hw *hw)
 	 * tnx devices cannot be "forced" to a autoneg 10G and fail.  But can
 	 * for a 1G.
 	 */
-	hw->phy.ops.read_reg(hw, IXGBE_MII_SPEED_SELECTION_REG,
-	                     IXGBE_MDIO_AUTO_NEG_DEV_TYPE, &autoneg_reg);
+	hw->phy.ops.read_reg(hw, MDIO_AN_ADVERTISE, MDIO_MMD_AN, &autoneg_reg);
 
 	if (hw->phy.autoneg_advertised == IXGBE_LINK_SPEED_1GB_FULL)
-		autoneg_reg &= 0xEFFF; /* 0 in bit 12 is 1G operation */
+		autoneg_reg &= ~MDIO_AN_10GBT_CTRL_ADV10G;
 	else
-		autoneg_reg |= 0x1000; /* 1 in bit 12 is 10G/1G operation */
+		autoneg_reg |= MDIO_AN_10GBT_CTRL_ADV10G;
 
-	hw->phy.ops.write_reg(hw, IXGBE_MII_SPEED_SELECTION_REG,
-	                      IXGBE_MDIO_AUTO_NEG_DEV_TYPE, autoneg_reg);
+	hw->phy.ops.write_reg(hw, MDIO_AN_ADVERTISE, MDIO_MMD_AN, autoneg_reg);
 
 	/* Restart PHY autonegotiation and wait for completion */
-	hw->phy.ops.read_reg(hw, IXGBE_MDIO_AUTO_NEG_CONTROL,
-	                     IXGBE_MDIO_AUTO_NEG_DEV_TYPE, &autoneg_reg);
+	hw->phy.ops.read_reg(hw, MDIO_CTRL1, MDIO_MMD_AN, &autoneg_reg);
 
-	autoneg_reg |= IXGBE_MII_RESTART;
+	autoneg_reg |= MDIO_AN_CTRL1_RESTART;
 
-	hw->phy.ops.write_reg(hw, IXGBE_MDIO_AUTO_NEG_CONTROL,
-	                      IXGBE_MDIO_AUTO_NEG_DEV_TYPE, autoneg_reg);
+	hw->phy.ops.write_reg(hw, MDIO_CTRL1, MDIO_MMD_AN, autoneg_reg);
 
 	/* Wait for autonegotiation to finish */
 	for (time_out = 0; time_out < max_time_out; time_out++) {
 		udelay(10);
 		/* Restart PHY autonegotiation and wait for completion */
-		status = hw->phy.ops.read_reg(hw, IXGBE_MDIO_AUTO_NEG_STATUS,
-		                              IXGBE_MDIO_AUTO_NEG_DEV_TYPE,
+		status = hw->phy.ops.read_reg(hw, MDIO_STAT1, MDIO_MMD_AN,
 		                              &autoneg_reg);
 
-		autoneg_reg &= IXGBE_MII_AUTONEG_COMPLETE;
-		if (autoneg_reg == IXGBE_MII_AUTONEG_COMPLETE) {
+		autoneg_reg &= MDIO_AN_STAT1_COMPLETE;
+		if (autoneg_reg == MDIO_AN_STAT1_COMPLETE) {
 			status = 0;
 			break;
 		}
@@ -457,23 +429,21 @@ s32 ixgbe_reset_phy_nl(struct ixgbe_hw *hw)
 	s32 ret_val = 0;
 	u32 i;
 
-	hw->phy.ops.read_reg(hw, IXGBE_MDIO_PHY_XS_CONTROL,
-	                     IXGBE_MDIO_PHY_XS_DEV_TYPE, &phy_data);
+	hw->phy.ops.read_reg(hw, MDIO_CTRL1, MDIO_MMD_PHYXS, &phy_data);
 
 	/* reset the PHY and poll for completion */
-	hw->phy.ops.write_reg(hw, IXGBE_MDIO_PHY_XS_CONTROL,
-	                      IXGBE_MDIO_PHY_XS_DEV_TYPE,
-	                      (phy_data | IXGBE_MDIO_PHY_XS_RESET));
+	hw->phy.ops.write_reg(hw, MDIO_CTRL1, MDIO_MMD_PHYXS,
+	                      (phy_data | MDIO_CTRL1_RESET));
 
 	for (i = 0; i < 100; i++) {
-		hw->phy.ops.read_reg(hw, IXGBE_MDIO_PHY_XS_CONTROL,
-		                     IXGBE_MDIO_PHY_XS_DEV_TYPE, &phy_data);
-		if ((phy_data & IXGBE_MDIO_PHY_XS_RESET) == 0)
+		hw->phy.ops.read_reg(hw, MDIO_CTRL1, MDIO_MMD_PHYXS,
+		                     &phy_data);
+		if ((phy_data & MDIO_CTRL1_RESET) == 0)
 			break;
 		msleep(10);
 	}
 
-	if ((phy_data & IXGBE_MDIO_PHY_XS_RESET) != 0) {
+	if ((phy_data & MDIO_CTRL1_RESET) != 0) {
 		hw_dbg(hw, "PHY reset did not complete.\n");
 		ret_val = IXGBE_ERR_PHY;
 		goto out;
@@ -509,7 +479,7 @@ s32 ixgbe_reset_phy_nl(struct ixgbe_hw *hw)
 			for (i = 0; i < edata; i++) {
 				hw->eeprom.ops.read(hw, data_offset, &eword);
 				hw->phy.ops.write_reg(hw, phy_offset,
-				                      IXGBE_TWINAX_DEV, eword);
+				                      MDIO_MMD_PMAPMD, eword);
 				hw_dbg(hw, "Wrote %4.4x to %4.4x\n", eword,
 				       phy_offset);
 				data_offset++;
@@ -1302,7 +1272,7 @@ s32 ixgbe_check_phy_link_tnx(struct ixgbe_hw *hw, ixgbe_link_speed *speed,
 		udelay(10);
 		status = hw->phy.ops.read_reg(hw,
 		                        IXGBE_MDIO_VENDOR_SPECIFIC_1_STATUS,
-		                        IXGBE_MDIO_VENDOR_SPECIFIC_1_DEV_TYPE,
+					MDIO_MMD_VEND1,
 		                        &phy_data);
 		phy_link = phy_data &
 		           IXGBE_MDIO_VENDOR_SPECIFIC_1_LINK_STATUS;
@@ -1330,8 +1300,7 @@ s32 ixgbe_get_phy_firmware_version_tnx(struct ixgbe_hw *hw,
 {
 	s32 status = 0;
 
-	status = hw->phy.ops.read_reg(hw, TNX_FW_REV,
-	                              IXGBE_MDIO_VENDOR_SPECIFIC_1_DEV_TYPE,
+	status = hw->phy.ops.read_reg(hw, TNX_FW_REV, MDIO_MMD_VEND1,
 	                              firmware_version);
 
 	return status;
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index bdfdf3b..e49e8af 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -29,6 +29,7 @@
 #define _IXGBE_TYPE_H_
 
 #include <linux/types.h>
+#include <linux/mdio.h>
 
 /* Vendor ID */
 #define IXGBE_INTEL_VENDOR_ID   0x8086
@@ -848,13 +849,7 @@
 /* Omer bit masks */
 #define IXGBE_CORECTL_WRITE_CMD         0x00010000
 
-/* Device Type definitions for new protocol MDIO commands */
-#define IXGBE_MDIO_PMA_PMD_DEV_TYPE               0x1
-#define IXGBE_MDIO_PCS_DEV_TYPE                   0x3
-#define IXGBE_MDIO_PHY_XS_DEV_TYPE                0x4
-#define IXGBE_MDIO_AUTO_NEG_DEV_TYPE              0x7
-#define IXGBE_MDIO_VENDOR_SPECIFIC_1_DEV_TYPE     0x1E   /* Device 30 */
-#define IXGBE_TWINAX_DEV                          1
+/* MDIO definitions */
 
 #define IXGBE_MDIO_COMMAND_TIMEOUT     100 /* PHY Timeout for 1 GB mode */
 
@@ -865,32 +860,10 @@
 #define IXGBE_MDIO_VENDOR_SPECIFIC_1_10G_SPEED    0x0018
 #define IXGBE_MDIO_VENDOR_SPECIFIC_1_1G_SPEED     0x0010
 
-#define IXGBE_MDIO_AUTO_NEG_CONTROL    0x0 /* AUTO_NEG Control Reg */
-#define IXGBE_MDIO_AUTO_NEG_STATUS     0x1 /* AUTO_NEG Status Reg */
-#define IXGBE_MDIO_PHY_XS_CONTROL      0x0 /* PHY_XS Control Reg */
-#define IXGBE_MDIO_PHY_XS_RESET        0x8000 /* PHY_XS Reset */
-#define IXGBE_MDIO_PHY_ID_HIGH         0x2 /* PHY ID High Reg*/
-#define IXGBE_MDIO_PHY_ID_LOW          0x3 /* PHY ID Low Reg*/
-#define IXGBE_MDIO_PHY_SPEED_ABILITY   0x4 /* Speed Ability Reg */
-#define IXGBE_MDIO_PHY_SPEED_10G       0x0001 /* 10G capable */
-#define IXGBE_MDIO_PHY_SPEED_1G        0x0010 /* 1G capable */
-#define IXGBE_MDIO_PHY_EXT_ABILITY        0xB /* Ext Ability Reg */
-#define IXGBE_MDIO_PHY_10GBASET_ABILITY   0x0004 /* 10GBaseT capable */
-#define IXGBE_MDIO_PHY_1000BASET_ABILITY  0x0020 /* 1000BaseT capable */
-#define IXGBE_MDIO_PHY_100BASETX_ABILITY  0x0080 /* 100BaseTX capable */
-
 #define IXGBE_MDIO_PMA_PMD_SDA_SCL_ADDR     0xC30A /* PHY_XS SDA/SCL Addr Reg */
 #define IXGBE_MDIO_PMA_PMD_SDA_SCL_DATA     0xC30B /* PHY_XS SDA/SCL Data Reg */
 #define IXGBE_MDIO_PMA_PMD_SDA_SCL_STAT     0xC30C /* PHY_XS SDA/SCL Status Reg */
 
-/* MII clause 22/28 definitions */
-#define IXGBE_MDIO_PHY_LOW_POWER_MODE  0x0800
-
-#define IXGBE_MII_SPEED_SELECTION_REG  0x10
-#define IXGBE_MII_RESTART              0x200
-#define IXGBE_MII_AUTONEG_COMPLETE     0x20
-#define IXGBE_MII_AUTONEG_REG          0x0
-
 #define IXGBE_PHY_REVISION_MASK        0xFFFFFFF0
 #define IXGBE_MAX_PHY_ADDR             32
 
@@ -2214,8 +2187,8 @@ struct ixgbe_mac_info {
 
 struct ixgbe_phy_info {
 	struct ixgbe_phy_operations     ops;
+	struct mdio_if_info		mdio;
 	enum ixgbe_phy_type             type;
-	u32                             addr;
 	u32                             id;
 	enum ixgbe_sfp_type             sfp_type;
 	bool                            sfp_setup_needed;

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

