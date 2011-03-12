From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 17/21] ixgbe: update PHY code to support 100Mbps as well as 1G/10G
Date: Sat, 12 Mar 2011 04:20:24 -0800
Message-ID: <1299932428-3114-18-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299932428-3114-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:2695 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753986Ab1CLMU7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Mar 2011 07:20:59 -0500
In-Reply-To: <1299932428-3114-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This change updates the PHY setup code to support 100Mbps capable PHYs
as well as 10G and 1Gbps.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_82598.c |    1 +
 drivers/net/ixgbe/ixgbe_phy.c   |  335 +++++++++++++++++++++++++++------------
 drivers/net/ixgbe/ixgbe_phy.h   |    1 +
 drivers/net/ixgbe/ixgbe_type.h  |    7 +
 4 files changed, 245 insertions(+), 99 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index ff23907..845c679 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -158,6 +158,7 @@ static s32 ixgbe_init_phy_ops_82598(struct ixgbe_hw *hw)
 
 	switch (hw->phy.type) {
 	case ixgbe_phy_tn:
+		phy->ops.setup_link = &ixgbe_setup_phy_link_tnx;
 		phy->ops.check_link = &ixgbe_check_phy_link_tnx;
 		phy->ops.get_firmware_version =
 		             &ixgbe_get_phy_firmware_version_tnx;
diff --git a/drivers/net/ixgbe/ixgbe_phy.c b/drivers/net/ixgbe/ixgbe_phy.c
index 9190a8f..f72f705 100644
--- a/drivers/net/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ixgbe/ixgbe_phy.c
@@ -402,49 +402,89 @@ s32 ixgbe_write_phy_reg_generic(struct ixgbe_hw *hw, u32 reg_addr,
  **/
 s32 ixgbe_setup_phy_link_generic(struct ixgbe_hw *hw)
 {
-	s32 status = IXGBE_NOT_IMPLEMENTED;
+	s32 status = 0;
 	u32 time_out;
 	u32 max_time_out = 10;
-	u16 autoneg_reg;
+	u16 autoneg_reg = IXGBE_MII_AUTONEG_REG;
+	bool autoneg = false;
+	ixgbe_link_speed speed;
 
-	/*
-	 * Set advertisement settings in PHY based on autoneg_advertised
-	 * settings. If autoneg_advertised = 0, then advertise default values
-	 * tnx devices cannot be "forced" to a autoneg 10G and fail.  But can
-	 * for a 1G.
-	 */
-	hw->phy.ops.read_reg(hw, MDIO_AN_ADVERTISE, MDIO_MMD_AN, &autoneg_reg);
+	ixgbe_get_copper_link_capabilities_generic(hw, &speed, &autoneg);
+
+	if (speed & IXGBE_LINK_SPEED_10GB_FULL) {
+		/* Set or unset auto-negotiation 10G advertisement */
+		hw->phy.ops.read_reg(hw, MDIO_AN_10GBT_CTRL,
+				     MDIO_MMD_AN,
+				     &autoneg_reg);
 
-	if (hw->phy.autoneg_advertised == IXGBE_LINK_SPEED_1GB_FULL)
 		autoneg_reg &= ~MDIO_AN_10GBT_CTRL_ADV10G;
-	else
-		autoneg_reg |= MDIO_AN_10GBT_CTRL_ADV10G;
+		if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_10GB_FULL)
+			autoneg_reg |= MDIO_AN_10GBT_CTRL_ADV10G;
 
-	hw->phy.ops.write_reg(hw, MDIO_AN_ADVERTISE, MDIO_MMD_AN, autoneg_reg);
+		hw->phy.ops.write_reg(hw, MDIO_AN_10GBT_CTRL,
+				      MDIO_MMD_AN,
+				      autoneg_reg);
+	}
+
+	if (speed & IXGBE_LINK_SPEED_1GB_FULL) {
+		/* Set or unset auto-negotiation 1G advertisement */
+		hw->phy.ops.read_reg(hw,
+				     IXGBE_MII_AUTONEG_VENDOR_PROVISION_1_REG,
+				     MDIO_MMD_AN,
+				     &autoneg_reg);
+
+		autoneg_reg &= ~IXGBE_MII_1GBASE_T_ADVERTISE;
+		if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_1GB_FULL)
+			autoneg_reg |= IXGBE_MII_1GBASE_T_ADVERTISE;
+
+		hw->phy.ops.write_reg(hw,
+				      IXGBE_MII_AUTONEG_VENDOR_PROVISION_1_REG,
+				      MDIO_MMD_AN,
+				      autoneg_reg);
+	}
+
+	if (speed & IXGBE_LINK_SPEED_100_FULL) {
+		/* Set or unset auto-negotiation 100M advertisement */
+		hw->phy.ops.read_reg(hw, MDIO_AN_ADVERTISE,
+				     MDIO_MMD_AN,
+				     &autoneg_reg);
+
+		autoneg_reg &= ~ADVERTISE_100FULL;
+		if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_100_FULL)
+			autoneg_reg |= ADVERTISE_100FULL;
+
+		hw->phy.ops.write_reg(hw, MDIO_AN_ADVERTISE,
+				      MDIO_MMD_AN,
+				      autoneg_reg);
+	}
 
 	/* Restart PHY autonegotiation and wait for completion */
-	hw->phy.ops.read_reg(hw, MDIO_CTRL1, MDIO_MMD_AN, &autoneg_reg);
+	hw->phy.ops.read_reg(hw, MDIO_CTRL1,
+			     MDIO_MMD_AN, &autoneg_reg);
 
 	autoneg_reg |= MDIO_AN_CTRL1_RESTART;
 
-	hw->phy.ops.write_reg(hw, MDIO_CTRL1, MDIO_MMD_AN, autoneg_reg);
+	hw->phy.ops.write_reg(hw, MDIO_CTRL1,
+			      MDIO_MMD_AN, autoneg_reg);
 
 	/* Wait for autonegotiation to finish */
 	for (time_out = 0; time_out < max_time_out; time_out++) {
 		udelay(10);
 		/* Restart PHY autonegotiation and wait for completion */
-		status = hw->phy.ops.read_reg(hw, MDIO_STAT1, MDIO_MMD_AN,
-		                              &autoneg_reg);
+		status = hw->phy.ops.read_reg(hw, MDIO_STAT1,
+					      MDIO_MMD_AN,
+					      &autoneg_reg);
 
 		autoneg_reg &= MDIO_AN_STAT1_COMPLETE;
 		if (autoneg_reg == MDIO_AN_STAT1_COMPLETE) {
-			status = 0;
 			break;
 		}
 	}
 
-	if (time_out == max_time_out)
+	if (time_out == max_time_out) {
 		status = IXGBE_ERR_LINK_SETUP;
+		hw_dbg(hw, "ixgbe_setup_phy_link_generic: time out");
+	}
 
 	return status;
 }
@@ -473,6 +513,9 @@ s32 ixgbe_setup_phy_link_speed_generic(struct ixgbe_hw *hw,
 	if (speed & IXGBE_LINK_SPEED_1GB_FULL)
 		hw->phy.autoneg_advertised |= IXGBE_LINK_SPEED_1GB_FULL;
 
+	if (speed & IXGBE_LINK_SPEED_100_FULL)
+		hw->phy.autoneg_advertised |= IXGBE_LINK_SPEED_100_FULL;
+
 	/* Setup link based on the new speed settings */
 	hw->phy.ops.setup_link(hw);
 
@@ -513,6 +556,180 @@ s32 ixgbe_get_copper_link_capabilities_generic(struct ixgbe_hw *hw,
 }
 
 /**
+ *  ixgbe_check_phy_link_tnx - Determine link and speed status
+ *  @hw: pointer to hardware structure
+ *
+ *  Reads the VS1 register to determine if link is up and the current speed for
+ *  the PHY.
+ **/
+s32 ixgbe_check_phy_link_tnx(struct ixgbe_hw *hw, ixgbe_link_speed *speed,
+			     bool *link_up)
+{
+	s32 status = 0;
+	u32 time_out;
+	u32 max_time_out = 10;
+	u16 phy_link = 0;
+	u16 phy_speed = 0;
+	u16 phy_data = 0;
+
+	/* Initialize speed and link to default case */
+	*link_up = false;
+	*speed = IXGBE_LINK_SPEED_10GB_FULL;
+
+	/*
+	 * Check current speed and link status of the PHY register.
+	 * This is a vendor specific register and may have to
+	 * be changed for other copper PHYs.
+	 */
+	for (time_out = 0; time_out < max_time_out; time_out++) {
+		udelay(10);
+		status = hw->phy.ops.read_reg(hw,
+					      MDIO_STAT1,
+					      MDIO_MMD_VEND1,
+					      &phy_data);
+		phy_link = phy_data &
+			    IXGBE_MDIO_VENDOR_SPECIFIC_1_LINK_STATUS;
+		phy_speed = phy_data &
+			    IXGBE_MDIO_VENDOR_SPECIFIC_1_SPEED_STATUS;
+		if (phy_link == IXGBE_MDIO_VENDOR_SPECIFIC_1_LINK_STATUS) {
+			*link_up = true;
+			if (phy_speed ==
+			    IXGBE_MDIO_VENDOR_SPECIFIC_1_SPEED_STATUS)
+				*speed = IXGBE_LINK_SPEED_1GB_FULL;
+			break;
+		}
+	}
+
+	return status;
+}
+
+/**
+ *	ixgbe_setup_phy_link_tnx - Set and restart autoneg
+ *	@hw: pointer to hardware structure
+ *
+ *	Restart autonegotiation and PHY and waits for completion.
+ **/
+s32 ixgbe_setup_phy_link_tnx(struct ixgbe_hw *hw)
+{
+	s32 status = 0;
+	u32 time_out;
+	u32 max_time_out = 10;
+	u16 autoneg_reg = IXGBE_MII_AUTONEG_REG;
+	bool autoneg = false;
+	ixgbe_link_speed speed;
+
+	ixgbe_get_copper_link_capabilities_generic(hw, &speed, &autoneg);
+
+	if (speed & IXGBE_LINK_SPEED_10GB_FULL) {
+		/* Set or unset auto-negotiation 10G advertisement */
+		hw->phy.ops.read_reg(hw, MDIO_AN_10GBT_CTRL,
+				     MDIO_MMD_AN,
+				     &autoneg_reg);
+
+		autoneg_reg &= ~MDIO_AN_10GBT_CTRL_ADV10G;
+		if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_10GB_FULL)
+			autoneg_reg |= MDIO_AN_10GBT_CTRL_ADV10G;
+
+		hw->phy.ops.write_reg(hw, MDIO_AN_10GBT_CTRL,
+				      MDIO_MMD_AN,
+				      autoneg_reg);
+	}
+
+	if (speed & IXGBE_LINK_SPEED_1GB_FULL) {
+		/* Set or unset auto-negotiation 1G advertisement */
+		hw->phy.ops.read_reg(hw, IXGBE_MII_AUTONEG_XNP_TX_REG,
+				     MDIO_MMD_AN,
+				     &autoneg_reg);
+
+		autoneg_reg &= ~IXGBE_MII_1GBASE_T_ADVERTISE_XNP_TX;
+		if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_1GB_FULL)
+			autoneg_reg |= IXGBE_MII_1GBASE_T_ADVERTISE_XNP_TX;
+
+		hw->phy.ops.write_reg(hw, IXGBE_MII_AUTONEG_XNP_TX_REG,
+				      MDIO_MMD_AN,
+				      autoneg_reg);
+	}
+
+	if (speed & IXGBE_LINK_SPEED_100_FULL) {
+		/* Set or unset auto-negotiation 100M advertisement */
+		hw->phy.ops.read_reg(hw, MDIO_AN_ADVERTISE,
+				     MDIO_MMD_AN,
+				     &autoneg_reg);
+
+		autoneg_reg &= ~ADVERTISE_100FULL;
+		if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_100_FULL)
+			autoneg_reg |= ADVERTISE_100FULL;
+
+		hw->phy.ops.write_reg(hw, MDIO_AN_ADVERTISE,
+				      MDIO_MMD_AN,
+				      autoneg_reg);
+	}
+
+	/* Restart PHY autonegotiation and wait for completion */
+	hw->phy.ops.read_reg(hw, MDIO_CTRL1,
+			     MDIO_MMD_AN, &autoneg_reg);
+
+	autoneg_reg |= MDIO_AN_CTRL1_RESTART;
+
+	hw->phy.ops.write_reg(hw, MDIO_CTRL1,
+			      MDIO_MMD_AN, autoneg_reg);
+
+	/* Wait for autonegotiation to finish */
+	for (time_out = 0; time_out < max_time_out; time_out++) {
+		udelay(10);
+		/* Restart PHY autonegotiation and wait for completion */
+		status = hw->phy.ops.read_reg(hw, MDIO_STAT1,
+					      MDIO_MMD_AN,
+					      &autoneg_reg);
+
+		autoneg_reg &= MDIO_AN_STAT1_COMPLETE;
+		if (autoneg_reg == MDIO_AN_STAT1_COMPLETE)
+			break;
+	}
+
+	if (time_out == max_time_out) {
+		status = IXGBE_ERR_LINK_SETUP;
+		hw_dbg(hw, "ixgbe_setup_phy_link_tnx: time out");
+	}
+
+	return status;
+}
+
+/**
+ *  ixgbe_get_phy_firmware_version_tnx - Gets the PHY Firmware Version
+ *  @hw: pointer to hardware structure
+ *  @firmware_version: pointer to the PHY Firmware Version
+ **/
+s32 ixgbe_get_phy_firmware_version_tnx(struct ixgbe_hw *hw,
+				       u16 *firmware_version)
+{
+	s32 status = 0;
+
+	status = hw->phy.ops.read_reg(hw, TNX_FW_REV,
+				      MDIO_MMD_VEND1,
+				      firmware_version);
+
+	return status;
+}
+
+/**
+ *  ixgbe_get_phy_firmware_version_generic - Gets the PHY Firmware Version
+ *  @hw: pointer to hardware structure
+ *  @firmware_version: pointer to the PHY Firmware Version
+ **/
+s32 ixgbe_get_phy_firmware_version_generic(struct ixgbe_hw *hw,
+					   u16 *firmware_version)
+{
+	s32 status = 0;
+
+	status = hw->phy.ops.read_reg(hw, AQ_FW_REV,
+				      MDIO_MMD_VEND1,
+				      firmware_version);
+
+	return status;
+}
+
+/**
  *  ixgbe_reset_phy_nl - Performs a PHY reset
  *  @hw: pointer to hardware structure
  **/
@@ -1477,86 +1694,6 @@ static void ixgbe_i2c_bus_clear(struct ixgbe_hw *hw)
 }
 
 /**
- *  ixgbe_check_phy_link_tnx - Determine link and speed status
- *  @hw: pointer to hardware structure
- *
- *  Reads the VS1 register to determine if link is up and the current speed for
- *  the PHY.
- **/
-s32 ixgbe_check_phy_link_tnx(struct ixgbe_hw *hw, ixgbe_link_speed *speed,
-                             bool *link_up)
-{
-	s32 status = 0;
-	u32 time_out;
-	u32 max_time_out = 10;
-	u16 phy_link = 0;
-	u16 phy_speed = 0;
-	u16 phy_data = 0;
-
-	/* Initialize speed and link to default case */
-	*link_up = false;
-	*speed = IXGBE_LINK_SPEED_10GB_FULL;
-
-	/*
-	 * Check current speed and link status of the PHY register.
-	 * This is a vendor specific register and may have to
-	 * be changed for other copper PHYs.
-	 */
-	for (time_out = 0; time_out < max_time_out; time_out++) {
-		udelay(10);
-		status = hw->phy.ops.read_reg(hw,
-		                        IXGBE_MDIO_VENDOR_SPECIFIC_1_STATUS,
-					MDIO_MMD_VEND1,
-		                        &phy_data);
-		phy_link = phy_data &
-		           IXGBE_MDIO_VENDOR_SPECIFIC_1_LINK_STATUS;
-		phy_speed = phy_data &
-		            IXGBE_MDIO_VENDOR_SPECIFIC_1_SPEED_STATUS;
-		if (phy_link == IXGBE_MDIO_VENDOR_SPECIFIC_1_LINK_STATUS) {
-			*link_up = true;
-			if (phy_speed ==
-			    IXGBE_MDIO_VENDOR_SPECIFIC_1_SPEED_STATUS)
-				*speed = IXGBE_LINK_SPEED_1GB_FULL;
-			break;
-		}
-	}
-
-	return status;
-}
-
-/**
- *  ixgbe_get_phy_firmware_version_tnx - Gets the PHY Firmware Version
- *  @hw: pointer to hardware structure
- *  @firmware_version: pointer to the PHY Firmware Version
- **/
-s32 ixgbe_get_phy_firmware_version_tnx(struct ixgbe_hw *hw,
-                                       u16 *firmware_version)
-{
-	s32 status = 0;
-
-	status = hw->phy.ops.read_reg(hw, TNX_FW_REV, MDIO_MMD_VEND1,
-	                              firmware_version);
-
-	return status;
-}
-
-/**
- *  ixgbe_get_phy_firmware_version_generic - Gets the PHY Firmware Version
- *  @hw: pointer to hardware structure
- *  @firmware_version: pointer to the PHY Firmware Version
-**/
-s32 ixgbe_get_phy_firmware_version_generic(struct ixgbe_hw *hw,
-                                           u16 *firmware_version)
-{
-	s32 status = 0;
-
-	status = hw->phy.ops.read_reg(hw, AQ_FW_REV, MDIO_MMD_VEND1,
-	                              firmware_version);
-
-	return status;
-}
-
-/**
  *  ixgbe_tn_check_overtemp - Checks if an overtemp occured.
  *  @hw: pointer to hardware structure
  *
diff --git a/drivers/net/ixgbe/ixgbe_phy.h b/drivers/net/ixgbe/ixgbe_phy.h
index 9bf2783..197bdd1 100644
--- a/drivers/net/ixgbe/ixgbe_phy.h
+++ b/drivers/net/ixgbe/ixgbe_phy.h
@@ -108,6 +108,7 @@ s32 ixgbe_get_copper_link_capabilities_generic(struct ixgbe_hw *hw,
 s32 ixgbe_check_phy_link_tnx(struct ixgbe_hw *hw,
                              ixgbe_link_speed *speed,
                              bool *link_up);
+s32 ixgbe_setup_phy_link_tnx(struct ixgbe_hw *hw);
 s32 ixgbe_get_phy_firmware_version_tnx(struct ixgbe_hw *hw,
                                        u16 *firmware_version);
 s32 ixgbe_get_phy_firmware_version_generic(struct ixgbe_hw *hw,
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index f190a4a..63d862d 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -1009,6 +1009,13 @@
 #define IXGBE_MDIO_PMA_PMD_SDA_SCL_DATA     0xC30B /* PHY_XS SDA/SCL Data Reg */
 #define IXGBE_MDIO_PMA_PMD_SDA_SCL_STAT     0xC30C /* PHY_XS SDA/SCL Status Reg */
 
+/* MII clause 22/28 definitions */
+#define IXGBE_MII_AUTONEG_VENDOR_PROVISION_1_REG 0xC400 /* 1G Provisioning 1 */
+#define IXGBE_MII_AUTONEG_XNP_TX_REG             0x17   /* 1G XNP Transmit */
+#define IXGBE_MII_1GBASE_T_ADVERTISE_XNP_TX      0x4000 /* full duplex, bit:14*/
+#define IXGBE_MII_1GBASE_T_ADVERTISE             0x8000 /* full duplex, bit:15*/
+#define IXGBE_MII_AUTONEG_REG                    0x0
+
 #define IXGBE_PHY_REVISION_MASK        0xFFFFFFF0
 #define IXGBE_MAX_PHY_ADDR             32
 
-- 
1.7.4

