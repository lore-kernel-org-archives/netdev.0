From: jeffrey.t.kirsher@intel.com
Subject: [net-next 07/12] e1000: Add support for the CE4100 reference platform
Date: Thu,  6 Jan 2011 16:29:54 -0800
Message-ID: <1294360199-9860-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1294360199-9860-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Dirk Brandewie <dirk.j.brandewie@intel.com>,
	netdev@vger.kernel.org, gosp@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:63414 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753345Ab1AGAat (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jan 2011 19:30:49 -0500
To: davem@davemloft.net
In-Reply-To: <1294360199-9860-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dirk Brandewie <dirk.j.brandewie@intel.com>

This patch adds support for the gigabit phys present on the CE4100 reference
platforms.

Signed-off-by:  Dirk Brandewie <dirk.j.brandewie@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000/e1000_hw.c    |  328 +++++++++++++++++++++++++++++++--------
 drivers/net/e1000/e1000_hw.h    |   59 +++++++-
 drivers/net/e1000/e1000_main.c  |   35 ++++
 drivers/net/e1000/e1000_osdep.h |   19 ++-
 4 files changed, 365 insertions(+), 76 deletions(-)

diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 77d08e6..aed223b 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -130,10 +130,15 @@ static s32 e1000_set_phy_type(struct e1000_hw *hw)
 		if (hw->mac_type == e1000_82541 ||
 		    hw->mac_type == e1000_82541_rev_2 ||
 		    hw->mac_type == e1000_82547 ||
-		    hw->mac_type == e1000_82547_rev_2) {
+		    hw->mac_type == e1000_82547_rev_2)
 			hw->phy_type = e1000_phy_igp;
-			break;
-		}
+		break;
+	case RTL8211B_PHY_ID:
+		hw->phy_type = e1000_phy_8211;
+		break;
+	case RTL8201N_PHY_ID:
+		hw->phy_type = e1000_phy_8201;
+		break;
 	default:
 		/* Should never have loaded on this device */
 		hw->phy_type = e1000_phy_undefined;
@@ -318,6 +323,9 @@ s32 e1000_set_mac_type(struct e1000_hw *hw)
 	case E1000_DEV_ID_82547GI:
 		hw->mac_type = e1000_82547_rev_2;
 		break;
+	case E1000_DEV_ID_INTEL_CE4100_GBE:
+		hw->mac_type = e1000_ce4100;
+		break;
 	default:
 		/* Should never have loaded on this device */
 		return -E1000_ERR_MAC_TYPE;
@@ -372,6 +380,9 @@ void e1000_set_media_type(struct e1000_hw *hw)
 		case e1000_82542_rev2_1:
 			hw->media_type = e1000_media_type_fiber;
 			break;
+		case e1000_ce4100:
+			hw->media_type = e1000_media_type_copper;
+			break;
 		default:
 			status = er32(STATUS);
 			if (status & E1000_STATUS_TBIMODE) {
@@ -460,6 +471,7 @@ s32 e1000_reset_hw(struct e1000_hw *hw)
 		/* Reset is performed on a shadow of the control register */
 		ew32(CTRL_DUP, (ctrl | E1000_CTRL_RST));
 		break;
+	case e1000_ce4100:
 	default:
 		ew32(CTRL, (ctrl | E1000_CTRL_RST));
 		break;
@@ -952,6 +964,67 @@ static s32 e1000_setup_fiber_serdes_link(struct e1000_hw *hw)
 }
 
 /**
+ * e1000_copper_link_rtl_setup - Copper link setup for e1000_phy_rtl series.
+ * @hw: Struct containing variables accessed by shared code
+ *
+ * Commits changes to PHY configuration by calling e1000_phy_reset().
+ */
+static s32 e1000_copper_link_rtl_setup(struct e1000_hw *hw)
+{
+	s32 ret_val;
+
+	/* SW reset the PHY so all changes take effect */
+	ret_val = e1000_phy_reset(hw);
+	if (ret_val) {
+		e_dbg("Error Resetting the PHY\n");
+		return ret_val;
+	}
+
+	return E1000_SUCCESS;
+}
+
+static s32 gbe_dhg_phy_setup(struct e1000_hw *hw)
+{
+	s32 ret_val;
+	u32 ctrl_aux;
+
+	switch (hw->phy_type) {
+	case e1000_phy_8211:
+		ret_val = e1000_copper_link_rtl_setup(hw);
+		if (ret_val) {
+			e_dbg("e1000_copper_link_rtl_setup failed!\n");
+			return ret_val;
+		}
+		break;
+	case e1000_phy_8201:
+		/* Set RMII mode */
+		ctrl_aux = er32(CTL_AUX);
+		ctrl_aux |= E1000_CTL_AUX_RMII;
+		ew32(CTL_AUX, ctrl_aux);
+		E1000_WRITE_FLUSH();
+
+		/* Disable the J/K bits required for receive */
+		ctrl_aux = er32(CTL_AUX);
+		ctrl_aux |= 0x4;
+		ctrl_aux &= ~0x2;
+		ew32(CTL_AUX, ctrl_aux);
+		E1000_WRITE_FLUSH();
+		ret_val = e1000_copper_link_rtl_setup(hw);
+
+		if (ret_val) {
+			e_dbg("e1000_copper_link_rtl_setup failed!\n");
+			return ret_val;
+		}
+		break;
+	default:
+		e_dbg("Error Resetting the PHY\n");
+		return E1000_ERR_PHY_TYPE;
+	}
+
+	return E1000_SUCCESS;
+}
+
+/**
  * e1000_copper_link_preconfig - early configuration for copper
  * @hw: Struct containing variables accessed by shared code
  *
@@ -1286,6 +1359,10 @@ static s32 e1000_copper_link_autoneg(struct e1000_hw *hw)
 	if (hw->autoneg_advertised == 0)
 		hw->autoneg_advertised = AUTONEG_ADVERTISE_SPEED_DEFAULT;
 
+	/* IFE/RTL8201N PHY only supports 10/100 */
+	if (hw->phy_type == e1000_phy_8201)
+		hw->autoneg_advertised &= AUTONEG_ADVERTISE_10_100_ALL;
+
 	e_dbg("Reconfiguring auto-neg advertisement params\n");
 	ret_val = e1000_phy_setup_autoneg(hw);
 	if (ret_val) {
@@ -1341,7 +1418,7 @@ static s32 e1000_copper_link_postconfig(struct e1000_hw *hw)
 	s32 ret_val;
 	e_dbg("e1000_copper_link_postconfig");
 
-	if (hw->mac_type >= e1000_82544) {
+	if ((hw->mac_type >= e1000_82544) && (hw->mac_type != e1000_ce4100)) {
 		e1000_config_collision_dist(hw);
 	} else {
 		ret_val = e1000_config_mac_to_phy(hw);
@@ -1395,6 +1472,12 @@ static s32 e1000_setup_copper_link(struct e1000_hw *hw)
 		ret_val = e1000_copper_link_mgp_setup(hw);
 		if (ret_val)
 			return ret_val;
+	} else {
+		ret_val = gbe_dhg_phy_setup(hw);
+		if (ret_val) {
+			e_dbg("gbe_dhg_phy_setup failed!\n");
+			return ret_val;
+		}
 	}
 
 	if (hw->autoneg) {
@@ -1461,10 +1544,11 @@ s32 e1000_phy_setup_autoneg(struct e1000_hw *hw)
 		return ret_val;
 
 	/* Read the MII 1000Base-T Control Register (Address 9). */
-	ret_val =
-	    e1000_read_phy_reg(hw, PHY_1000T_CTRL, &mii_1000t_ctrl_reg);
+	ret_val = e1000_read_phy_reg(hw, PHY_1000T_CTRL, &mii_1000t_ctrl_reg);
 	if (ret_val)
 		return ret_val;
+	else if (hw->phy_type == e1000_phy_8201)
+		mii_1000t_ctrl_reg &= ~REG9_SPEED_MASK;
 
 	/* Need to parse both autoneg_advertised and fc and set up
 	 * the appropriate PHY registers.  First we will parse for
@@ -1577,9 +1661,14 @@ s32 e1000_phy_setup_autoneg(struct e1000_hw *hw)
 
 	e_dbg("Auto-Neg Advertising %x\n", mii_autoneg_adv_reg);
 
-	ret_val = e1000_write_phy_reg(hw, PHY_1000T_CTRL, mii_1000t_ctrl_reg);
-	if (ret_val)
-		return ret_val;
+	if (hw->phy_type == e1000_phy_8201) {
+		mii_1000t_ctrl_reg = 0;
+	} else {
+		ret_val = e1000_write_phy_reg(hw, PHY_1000T_CTRL,
+		                              mii_1000t_ctrl_reg);
+		if (ret_val)
+			return ret_val;
+	}
 
 	return E1000_SUCCESS;
 }
@@ -1860,7 +1949,7 @@ static s32 e1000_config_mac_to_phy(struct e1000_hw *hw)
 
 	/* 82544 or newer MAC, Auto Speed Detection takes care of
 	 * MAC speed/duplex configuration.*/
-	if (hw->mac_type >= e1000_82544)
+	if ((hw->mac_type >= e1000_82544) && (hw->mac_type != e1000_ce4100))
 		return E1000_SUCCESS;
 
 	/* Read the Device Control Register and set the bits to Force Speed
@@ -1870,27 +1959,49 @@ static s32 e1000_config_mac_to_phy(struct e1000_hw *hw)
 	ctrl |= (E1000_CTRL_FRCSPD | E1000_CTRL_FRCDPX);
 	ctrl &= ~(E1000_CTRL_SPD_SEL | E1000_CTRL_ILOS);
 
-	/* Set up duplex in the Device Control and Transmit Control
-	 * registers depending on negotiated values.
-	 */
-	ret_val = e1000_read_phy_reg(hw, M88E1000_PHY_SPEC_STATUS, &phy_data);
-	if (ret_val)
-		return ret_val;
+	switch (hw->phy_type) {
+	case e1000_phy_8201:
+		ret_val = e1000_read_phy_reg(hw, PHY_CTRL, &phy_data);
+		if (ret_val)
+			return ret_val;
 
-	if (phy_data & M88E1000_PSSR_DPLX)
-		ctrl |= E1000_CTRL_FD;
-	else
-		ctrl &= ~E1000_CTRL_FD;
+		if (phy_data & RTL_PHY_CTRL_FD)
+			ctrl |= E1000_CTRL_FD;
+		else
+			ctrl &= ~E1000_CTRL_FD;
 
-	e1000_config_collision_dist(hw);
+		if (phy_data & RTL_PHY_CTRL_SPD_100)
+			ctrl |= E1000_CTRL_SPD_100;
+		else
+			ctrl |= E1000_CTRL_SPD_10;
 
-	/* Set up speed in the Device Control register depending on
-	 * negotiated values.
-	 */
-	if ((phy_data & M88E1000_PSSR_SPEED) == M88E1000_PSSR_1000MBS)
-		ctrl |= E1000_CTRL_SPD_1000;
-	else if ((phy_data & M88E1000_PSSR_SPEED) == M88E1000_PSSR_100MBS)
-		ctrl |= E1000_CTRL_SPD_100;
+		e1000_config_collision_dist(hw);
+		break;
+	default:
+		/* Set up duplex in the Device Control and Transmit Control
+		 * registers depending on negotiated values.
+		 */
+		ret_val = e1000_read_phy_reg(hw, M88E1000_PHY_SPEC_STATUS,
+		                             &phy_data);
+		if (ret_val)
+			return ret_val;
+
+		if (phy_data & M88E1000_PSSR_DPLX)
+			ctrl |= E1000_CTRL_FD;
+		else
+			ctrl &= ~E1000_CTRL_FD;
+
+		e1000_config_collision_dist(hw);
+
+		/* Set up speed in the Device Control register depending on
+		 * negotiated values.
+		 */
+		if ((phy_data & M88E1000_PSSR_SPEED) == M88E1000_PSSR_1000MBS)
+			ctrl |= E1000_CTRL_SPD_1000;
+		else if ((phy_data & M88E1000_PSSR_SPEED) ==
+		         M88E1000_PSSR_100MBS)
+			ctrl |= E1000_CTRL_SPD_100;
+	}
 
 	/* Write the configured values back to the Device Control Reg. */
 	ew32(CTRL, ctrl);
@@ -2401,7 +2512,8 @@ s32 e1000_check_for_link(struct e1000_hw *hw)
 		 * speed/duplex on the MAC to the current PHY speed/duplex
 		 * settings.
 		 */
-		if (hw->mac_type >= e1000_82544)
+		if ((hw->mac_type >= e1000_82544) &&
+		    (hw->mac_type != e1000_ce4100))
 			e1000_config_collision_dist(hw);
 		else {
 			ret_val = e1000_config_mac_to_phy(hw);
@@ -2738,7 +2850,7 @@ static s32 e1000_read_phy_reg_ex(struct e1000_hw *hw, u32 reg_addr,
 {
 	u32 i;
 	u32 mdic = 0;
-	const u32 phy_addr = 1;
+	const u32 phy_addr = (hw->mac_type == e1000_ce4100) ? hw->phy_addr : 1;
 
 	e_dbg("e1000_read_phy_reg_ex");
 
@@ -2752,28 +2864,61 @@ static s32 e1000_read_phy_reg_ex(struct e1000_hw *hw, u32 reg_addr,
 		 * Control register.  The MAC will take care of interfacing with the
 		 * PHY to retrieve the desired data.
 		 */
-		mdic = ((reg_addr << E1000_MDIC_REG_SHIFT) |
-			(phy_addr << E1000_MDIC_PHY_SHIFT) |
-			(E1000_MDIC_OP_READ));
+		if (hw->mac_type == e1000_ce4100) {
+			mdic = ((reg_addr << E1000_MDIC_REG_SHIFT) |
+				(phy_addr << E1000_MDIC_PHY_SHIFT) |
+				(INTEL_CE_GBE_MDIC_OP_READ) |
+				(INTEL_CE_GBE_MDIC_GO));
 
-		ew32(MDIC, mdic);
+			writel(mdic, E1000_MDIO_CMD);
 
-		/* Poll the ready bit to see if the MDI read completed */
-		for (i = 0; i < 64; i++) {
-			udelay(50);
-			mdic = er32(MDIC);
-			if (mdic & E1000_MDIC_READY)
-				break;
-		}
-		if (!(mdic & E1000_MDIC_READY)) {
-			e_dbg("MDI Read did not complete\n");
-			return -E1000_ERR_PHY;
-		}
-		if (mdic & E1000_MDIC_ERROR) {
-			e_dbg("MDI Error\n");
-			return -E1000_ERR_PHY;
+			/* Poll the ready bit to see if the MDI read
+			 * completed
+			 */
+			for (i = 0; i < 64; i++) {
+				udelay(50);
+				mdic = readl(E1000_MDIO_CMD);
+				if (!(mdic & INTEL_CE_GBE_MDIC_GO))
+					break;
+			}
+
+			if (mdic & INTEL_CE_GBE_MDIC_GO) {
+				e_dbg("MDI Read did not complete\n");
+				return -E1000_ERR_PHY;
+			}
+
+			mdic = readl(E1000_MDIO_STS);
+			if (mdic & INTEL_CE_GBE_MDIC_READ_ERROR) {
+				e_dbg("MDI Read Error\n");
+				return -E1000_ERR_PHY;
+			}
+			*phy_data = (u16) mdic;
+		} else {
+			mdic = ((reg_addr << E1000_MDIC_REG_SHIFT) |
+				(phy_addr << E1000_MDIC_PHY_SHIFT) |
+				(E1000_MDIC_OP_READ));
+
+			ew32(MDIC, mdic);
+
+			/* Poll the ready bit to see if the MDI read
+			 * completed
+			 */
+			for (i = 0; i < 64; i++) {
+				udelay(50);
+				mdic = er32(MDIC);
+				if (mdic & E1000_MDIC_READY)
+					break;
+			}
+			if (!(mdic & E1000_MDIC_READY)) {
+				e_dbg("MDI Read did not complete\n");
+				return -E1000_ERR_PHY;
+			}
+			if (mdic & E1000_MDIC_ERROR) {
+				e_dbg("MDI Error\n");
+				return -E1000_ERR_PHY;
+			}
+			*phy_data = (u16) mdic;
 		}
-		*phy_data = (u16) mdic;
 	} else {
 		/* We must first send a preamble through the MDIO pin to signal the
 		 * beginning of an MII instruction.  This is done by sending 32
@@ -2840,7 +2985,7 @@ static s32 e1000_write_phy_reg_ex(struct e1000_hw *hw, u32 reg_addr,
 {
 	u32 i;
 	u32 mdic = 0;
-	const u32 phy_addr = 1;
+	const u32 phy_addr = (hw->mac_type == e1000_ce4100) ? hw->phy_addr : 1;
 
 	e_dbg("e1000_write_phy_reg_ex");
 
@@ -2850,27 +2995,54 @@ static s32 e1000_write_phy_reg_ex(struct e1000_hw *hw, u32 reg_addr,
 	}
 
 	if (hw->mac_type > e1000_82543) {
-		/* Set up Op-code, Phy Address, register address, and data intended
-		 * for the PHY register in the MDI Control register.  The MAC will take
-		 * care of interfacing with the PHY to send the desired data.
+		/* Set up Op-code, Phy Address, register address, and data
+		 * intended for the PHY register in the MDI Control register.
+		 * The MAC will take care of interfacing with the PHY to send
+		 * the desired data.
 		 */
-		mdic = (((u32) phy_data) |
-			(reg_addr << E1000_MDIC_REG_SHIFT) |
-			(phy_addr << E1000_MDIC_PHY_SHIFT) |
-			(E1000_MDIC_OP_WRITE));
+		if (hw->mac_type == e1000_ce4100) {
+			mdic = (((u32) phy_data) |
+				(reg_addr << E1000_MDIC_REG_SHIFT) |
+				(phy_addr << E1000_MDIC_PHY_SHIFT) |
+				(INTEL_CE_GBE_MDIC_OP_WRITE) |
+				(INTEL_CE_GBE_MDIC_GO));
 
-		ew32(MDIC, mdic);
+			writel(mdic, E1000_MDIO_CMD);
 
-		/* Poll the ready bit to see if the MDI read completed */
-		for (i = 0; i < 641; i++) {
-			udelay(5);
-			mdic = er32(MDIC);
-			if (mdic & E1000_MDIC_READY)
-				break;
-		}
-		if (!(mdic & E1000_MDIC_READY)) {
-			e_dbg("MDI Write did not complete\n");
-			return -E1000_ERR_PHY;
+			/* Poll the ready bit to see if the MDI read
+			 * completed
+			 */
+			for (i = 0; i < 640; i++) {
+				udelay(5);
+				mdic = readl(E1000_MDIO_CMD);
+				if (!(mdic & INTEL_CE_GBE_MDIC_GO))
+					break;
+			}
+			if (mdic & INTEL_CE_GBE_MDIC_GO) {
+				e_dbg("MDI Write did not complete\n");
+				return -E1000_ERR_PHY;
+			}
+		} else {
+			mdic = (((u32) phy_data) |
+				(reg_addr << E1000_MDIC_REG_SHIFT) |
+				(phy_addr << E1000_MDIC_PHY_SHIFT) |
+				(E1000_MDIC_OP_WRITE));
+
+			ew32(MDIC, mdic);
+
+			/* Poll the ready bit to see if the MDI read
+			 * completed
+			 */
+			for (i = 0; i < 641; i++) {
+				udelay(5);
+				mdic = er32(MDIC);
+				if (mdic & E1000_MDIC_READY)
+					break;
+			}
+			if (!(mdic & E1000_MDIC_READY)) {
+				e_dbg("MDI Write did not complete\n");
+				return -E1000_ERR_PHY;
+			}
 		}
 	} else {
 		/* We'll need to use the SW defined pins to shift the write command
@@ -3048,6 +3220,11 @@ static s32 e1000_detect_gig_phy(struct e1000_hw *hw)
 		if (hw->phy_id == M88E1011_I_PHY_ID)
 			match = true;
 		break;
+	case e1000_ce4100:
+		if ((hw->phy_id == RTL8211B_PHY_ID) ||
+		    (hw->phy_id == RTL8201N_PHY_ID))
+			match = true;
+		break;
 	case e1000_82541:
 	case e1000_82541_rev_2:
 	case e1000_82547:
@@ -3291,6 +3468,9 @@ s32 e1000_phy_get_info(struct e1000_hw *hw, struct e1000_phy_info *phy_info)
 
 	if (hw->phy_type == e1000_phy_igp)
 		return e1000_phy_igp_get_info(hw, phy_info);
+	else if ((hw->phy_type == e1000_phy_8211) ||
+	         (hw->phy_type == e1000_phy_8201))
+		return E1000_SUCCESS;
 	else
 		return e1000_phy_m88_get_info(hw, phy_info);
 }
@@ -3742,6 +3922,12 @@ static s32 e1000_do_read_eeprom(struct e1000_hw *hw, u16 offset, u16 words,
 
 	e_dbg("e1000_read_eeprom");
 
+	if (hw->mac_type == e1000_ce4100) {
+		GBE_CONFIG_FLASH_READ(GBE_CONFIG_BASE_VIRT, offset, words,
+		                      data);
+		return E1000_SUCCESS;
+	}
+
 	/* If eeprom is not yet detected, do so now */
 	if (eeprom->word_size == 0)
 		e1000_init_eeprom_params(hw);
@@ -3904,6 +4090,12 @@ static s32 e1000_do_write_eeprom(struct e1000_hw *hw, u16 offset, u16 words,
 
 	e_dbg("e1000_write_eeprom");
 
+	if (hw->mac_type == e1000_ce4100) {
+		GBE_CONFIG_FLASH_WRITE(GBE_CONFIG_BASE_VIRT, offset, words,
+		                       data);
+		return E1000_SUCCESS;
+	}
+
 	/* If eeprom is not yet detected, do so now */
 	if (eeprom->word_size == 0)
 		e1000_init_eeprom_params(hw);
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index ecd9f6c..f5514a0 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -52,6 +52,7 @@ typedef enum {
 	e1000_82545,
 	e1000_82545_rev_3,
 	e1000_82546,
+	e1000_ce4100,
 	e1000_82546_rev_3,
 	e1000_82541,
 	e1000_82541_rev_2,
@@ -209,9 +210,11 @@ typedef enum {
 } e1000_1000t_rx_status;
 
 typedef enum {
-    e1000_phy_m88 = 0,
-    e1000_phy_igp,
-    e1000_phy_undefined = 0xFF
+	e1000_phy_m88 = 0,
+	e1000_phy_igp,
+	e1000_phy_8211,
+	e1000_phy_8201,
+	e1000_phy_undefined = 0xFF
 } e1000_phy_type;
 
 typedef enum {
@@ -442,6 +445,7 @@ void e1000_io_write(struct e1000_hw *hw, unsigned long port, u32 value);
 #define E1000_DEV_ID_82547EI             0x1019
 #define E1000_DEV_ID_82547EI_MOBILE      0x101A
 #define E1000_DEV_ID_82546GB_QUAD_COPPER_KSP3 0x10B5
+#define E1000_DEV_ID_INTEL_CE4100_GBE    0x2E6E
 
 #define NODE_ADDRESS_SIZE 6
 #define ETH_LENGTH_OF_ADDRESS 6
@@ -808,6 +812,16 @@ struct e1000_ffvt_entry {
 #define E1000_CTRL_EXT 0x00018	/* Extended Device Control - RW */
 #define E1000_FLA      0x0001C	/* Flash Access - RW */
 #define E1000_MDIC     0x00020	/* MDI Control - RW */
+
+extern void __iomem *ce4100_gbe_mdio_base_virt;
+#define INTEL_CE_GBE_MDIO_RCOMP_BASE    (ce4100_gbe_mdio_base_virt)
+#define E1000_MDIO_STS  (INTEL_CE_GBE_MDIO_RCOMP_BASE + 0)
+#define E1000_MDIO_CMD  (INTEL_CE_GBE_MDIO_RCOMP_BASE + 4)
+#define E1000_MDIO_DRV  (INTEL_CE_GBE_MDIO_RCOMP_BASE + 8)
+#define E1000_MDC_CMD   (INTEL_CE_GBE_MDIO_RCOMP_BASE + 0xC)
+#define E1000_RCOMP_CTL (INTEL_CE_GBE_MDIO_RCOMP_BASE + 0x20)
+#define E1000_RCOMP_STS (INTEL_CE_GBE_MDIO_RCOMP_BASE + 0x24)
+
 #define E1000_SCTL     0x00024	/* SerDes Control - RW */
 #define E1000_FEXTNVM  0x00028	/* Future Extended NVM register */
 #define E1000_FCAL     0x00028	/* Flow Control Address Low - RW */
@@ -820,6 +834,34 @@ struct e1000_ffvt_entry {
 #define E1000_IMS      0x000D0	/* Interrupt Mask Set - RW */
 #define E1000_IMC      0x000D8	/* Interrupt Mask Clear - WO */
 #define E1000_IAM      0x000E0	/* Interrupt Acknowledge Auto Mask */
+
+/* Auxiliary Control Register. This register is CE4100 specific,
+ * RMII/RGMII function is switched by this register - RW
+ * Following are bits definitions of the Auxiliary Control Register
+ */
+#define E1000_CTL_AUX  0x000E0
+#define E1000_CTL_AUX_END_SEL_SHIFT     10
+#define E1000_CTL_AUX_ENDIANESS_SHIFT   8
+#define E1000_CTL_AUX_RGMII_RMII_SHIFT  0
+
+/* descriptor and packet transfer use CTL_AUX.ENDIANESS */
+#define E1000_CTL_AUX_DES_PKT   (0x0 << E1000_CTL_AUX_END_SEL_SHIFT)
+/* descriptor use CTL_AUX.ENDIANESS, packet use default */
+#define E1000_CTL_AUX_DES       (0x1 << E1000_CTL_AUX_END_SEL_SHIFT)
+/* descriptor use default, packet use CTL_AUX.ENDIANESS */
+#define E1000_CTL_AUX_PKT       (0x2 << E1000_CTL_AUX_END_SEL_SHIFT)
+/* all use CTL_AUX.ENDIANESS */
+#define E1000_CTL_AUX_ALL       (0x3 << E1000_CTL_AUX_END_SEL_SHIFT)
+
+#define E1000_CTL_AUX_RGMII     (0x0 << E1000_CTL_AUX_RGMII_RMII_SHIFT)
+#define E1000_CTL_AUX_RMII      (0x1 << E1000_CTL_AUX_RGMII_RMII_SHIFT)
+
+/* LW little endian, Byte big endian */
+#define E1000_CTL_AUX_LWLE_BBE  (0x0 << E1000_CTL_AUX_ENDIANESS_SHIFT)
+#define E1000_CTL_AUX_LWLE_BLE  (0x1 << E1000_CTL_AUX_ENDIANESS_SHIFT)
+#define E1000_CTL_AUX_LWBE_BBE  (0x2 << E1000_CTL_AUX_ENDIANESS_SHIFT)
+#define E1000_CTL_AUX_LWBE_BLE  (0x3 << E1000_CTL_AUX_ENDIANESS_SHIFT)
+
 #define E1000_RCTL     0x00100	/* RX Control - RW */
 #define E1000_RDTR1    0x02820	/* RX Delay Timer (1) - RW */
 #define E1000_RDBAL1   0x02900	/* RX Descriptor Base Address Low (1) - RW */
@@ -1011,6 +1053,7 @@ struct e1000_ffvt_entry {
  * in more current versions of the 8254x. Despite the difference in location,
  * the registers function in the same manner.
  */
+#define E1000_82542_CTL_AUX  E1000_CTL_AUX
 #define E1000_82542_CTRL     E1000_CTRL
 #define E1000_82542_CTRL_DUP E1000_CTRL_DUP
 #define E1000_82542_STATUS   E1000_STATUS
@@ -1571,6 +1614,11 @@ struct e1000_hw {
 #define E1000_MDIC_INT_EN    0x20000000
 #define E1000_MDIC_ERROR     0x40000000
 
+#define INTEL_CE_GBE_MDIC_OP_WRITE      0x04000000
+#define INTEL_CE_GBE_MDIC_OP_READ       0x00000000
+#define INTEL_CE_GBE_MDIC_GO            0x80000000
+#define INTEL_CE_GBE_MDIC_READ_ERROR    0x80000000
+
 #define E1000_KUMCTRLSTA_MASK           0x0000FFFF
 #define E1000_KUMCTRLSTA_OFFSET         0x001F0000
 #define E1000_KUMCTRLSTA_OFFSET_SHIFT   16
@@ -2871,6 +2919,11 @@ struct e1000_host_command_info {
 #define M88E1111_I_PHY_ID  0x01410CC0
 #define L1LXT971A_PHY_ID   0x001378E0
 
+#define RTL8211B_PHY_ID    0x001CC910
+#define RTL8201N_PHY_ID    0x8200
+#define RTL_PHY_CTRL_FD    0x0100 /* Full duplex.0=half; 1=full */
+#define RTL_PHY_CTRL_SPD_100    0x200000 /* Force 100Mb */
+
 /* Bits...
  * 15-5: page
  * 4-0: register offset
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 340e12d..4ff88a6 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -28,6 +28,12 @@
 
 #include "e1000.h"
 #include <net/ip6_checksum.h>
+#include <linux/io.h>
+
+/* Intel Media SOC GbE MDIO physical base address */
+static unsigned long ce4100_gbe_mdio_base_phy;
+/* Intel Media SOC GbE MDIO virtual base address */
+void __iomem *ce4100_gbe_mdio_base_virt;
 
 char e1000_driver_name[] = "e1000";
 static char e1000_driver_string[] = "Intel(R) PRO/1000 Network Driver";
@@ -79,6 +85,7 @@ static DEFINE_PCI_DEVICE_TABLE(e1000_pci_tbl) = {
 	INTEL_E1000_ETHERNET_DEVICE(0x108A),
 	INTEL_E1000_ETHERNET_DEVICE(0x1099),
 	INTEL_E1000_ETHERNET_DEVICE(0x10B5),
+	INTEL_E1000_ETHERNET_DEVICE(0x2E6E),
 	/* required last entry */
 	{0,}
 };
@@ -459,6 +466,7 @@ static void e1000_power_down_phy(struct e1000_adapter *adapter)
 		case e1000_82545:
 		case e1000_82545_rev_3:
 		case e1000_82546:
+		case e1000_ce4100:
 		case e1000_82546_rev_3:
 		case e1000_82541:
 		case e1000_82541_rev_2:
@@ -573,6 +581,7 @@ void e1000_reset(struct e1000_adapter *adapter)
 	case e1000_82545:
 	case e1000_82545_rev_3:
 	case e1000_82546:
+	case e1000_ce4100:
 	case e1000_82546_rev_3:
 		pba = E1000_PBA_48K;
 		break;
@@ -894,6 +903,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	static int global_quad_port_a = 0; /* global ksp3 port a indication */
 	int i, err, pci_using_dac;
 	u16 eeprom_data = 0;
+	u16 tmp = 0;
 	u16 eeprom_apme_mask = E1000_EEPROM_APME;
 	int bars, need_ioport;
 
@@ -996,6 +1006,14 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 		goto err_sw_init;
 
 	err = -EIO;
+	if (hw->mac_type == e1000_ce4100) {
+		ce4100_gbe_mdio_base_phy = pci_resource_start(pdev, BAR_1);
+		ce4100_gbe_mdio_base_virt = ioremap(ce4100_gbe_mdio_base_phy,
+		                                pci_resource_len(pdev, BAR_1));
+
+		if (!ce4100_gbe_mdio_base_virt)
+			goto err_mdio_ioremap;
+	}
 
 	if (hw->mac_type >= e1000_82543) {
 		netdev->features = NETIF_F_SG |
@@ -1135,6 +1153,20 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	adapter->wol = adapter->eeprom_wol;
 	device_set_wakeup_enable(&adapter->pdev->dev, adapter->wol);
 
+	/* Auto detect PHY address */
+	if (hw->mac_type == e1000_ce4100) {
+		for (i = 0; i < 32; i++) {
+			hw->phy_addr = i;
+			e1000_read_phy_reg(hw, PHY_ID2, &tmp);
+			if (tmp == 0 || tmp == 0xFF) {
+				if (i == 31)
+					goto err_eeprom;
+				continue;
+			} else
+				break;
+		}
+	}
+
 	/* reset the hardware with the new settings */
 	e1000_reset(adapter);
 
@@ -1171,6 +1203,8 @@ err_eeprom:
 	kfree(adapter->rx_ring);
 err_dma:
 err_sw_init:
+err_mdio_ioremap:
+	iounmap(ce4100_gbe_mdio_base_virt);
 	iounmap(hw->hw_addr);
 err_ioremap:
 	free_netdev(netdev);
@@ -1409,6 +1443,7 @@ static bool e1000_check_64k_bound(struct e1000_adapter *adapter, void *start,
 	/* First rev 82545 and 82546 need to not allow any memory
 	 * write location to cross 64k boundary due to errata 23 */
 	if (hw->mac_type == e1000_82545 ||
+	    hw->mac_type == e1000_ce4100 ||
 	    hw->mac_type == e1000_82546) {
 		return ((begin ^ (end - 1)) >> 16) != 0 ? false : true;
 	}
diff --git a/drivers/net/e1000/e1000_osdep.h b/drivers/net/e1000/e1000_osdep.h
index edd1c75..55c1711 100644
--- a/drivers/net/e1000/e1000_osdep.h
+++ b/drivers/net/e1000/e1000_osdep.h
@@ -34,12 +34,21 @@
 #ifndef _E1000_OSDEP_H_
 #define _E1000_OSDEP_H_
 
-#include <linux/types.h>
-#include <linux/pci.h>
-#include <linux/delay.h>
 #include <asm/io.h>
-#include <linux/interrupt.h>
-#include <linux/sched.h>
+
+#define CONFIG_RAM_BASE         0x60000
+#define GBE_CONFIG_OFFSET       0x0
+
+#define GBE_CONFIG_RAM_BASE \
+	((unsigned int)(CONFIG_RAM_BASE + GBE_CONFIG_OFFSET))
+
+#define GBE_CONFIG_BASE_VIRT    phys_to_virt(GBE_CONFIG_RAM_BASE)
+
+#define GBE_CONFIG_FLASH_WRITE(base, offset, count, data) \
+	(iowrite16_rep(base + offset, data, count))
+
+#define GBE_CONFIG_FLASH_READ(base, offset, count, data) \
+	(ioread16_rep(base + (offset << 1), data, count))
 
 #define er32(reg)							\
 	(readl(hw->hw_addr + ((hw->mac_type >= e1000_82543)		\
-- 
1.7.3.4

