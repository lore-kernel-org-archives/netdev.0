From: "Yaniv Rosner" <yaniv.rosner@broadcom.com>
Subject: [PATCH net-next 06/10] bnx2x: Apply logic changes for the new
 scheme
Date: Wed, 8 Sep 2010 00:41:07 +0300
Message-ID: <1283895667.5452.66.camel@lb-tlvb-yanivr.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3059 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932437Ab0IGSXH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Sep 2010 14:23:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the needed changes for the new scheme especially around PHY
initialization, and link detection.
- The get_emac_base function was changed to enable setting different MAC
access setting for each PHY based of external configuration.
- As a part of the dual-media preparation, the save_spirom_version was
modified to accept a PHY specific version address to be saved in the
shmem. This will enable to save more than single spirom version in
different locations.
- The test_link function was changed also as a preparation for the
dual-media upcoming changes
- Duplicate initialization logic was removed from the
link_setting_status and link_initialize functions

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com> 
---
 drivers/net/bnx2x/bnx2x_link.c |  331 +++++++++++++++++++---------------------
 drivers/net/bnx2x/bnx2x_link.h |    1 +
 2 files changed, 155 insertions(+), 177 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index 895ae00..469e0e4 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -195,24 +195,6 @@ static void bnx2x_set_serdes_access(struct bnx2x *bp, u8 port)
 	REG_WR(bp, NIG_REG_SERDES0_CTRL_MD_ST + port*0x10, 0);
 }
 
-static void bnx2x_set_phy_mdio(struct link_params *params, u8 phy_flags)
-{
-	struct bnx2x *bp = params->bp;
-
-	if (phy_flags & PHY_XGXS_FLAG) {
-		REG_WR(bp, NIG_REG_XGXS0_CTRL_MD_ST +
-			   params->port*0x18, 0);
-		REG_WR(bp, NIG_REG_XGXS0_CTRL_MD_DEVAD + params->port*0x18,
-			   DEFAULT_PHY_DEV_ADDR);
-	} else {
-		bnx2x_set_serdes_access(bp, params->port);
-
-		REG_WR(bp, NIG_REG_SERDES0_CTRL_MD_DEVAD +
-			   params->port*0x10,
-			   DEFAULT_PHY_DEV_ADDR);
-	}
-}
-
 static u32 bnx2x_bits_en(struct bnx2x *bp, u32 reg, u32 bits)
 {
 	u32 val = REG_RD(bp, reg);
@@ -528,31 +510,46 @@ static u8 bnx2x_bmac_enable(struct link_params *params, struct link_vars *vars,
 	return 0;
 }
 
-static void bnx2x_phy_deassert(struct link_params *params, u8 phy_flags)
+static void bnx2x_serdes_deassert(struct bnx2x *bp, u8 port)
 {
-	struct bnx2x *bp = params->bp;
 	u32 val;
 
-	if (phy_flags & PHY_XGXS_FLAG) {
-		DP(NETIF_MSG_LINK, "bnx2x_phy_deassert:XGXS\n");
-		val = XGXS_RESET_BITS;
+	DP(NETIF_MSG_LINK, "bnx2x_serdes_deassert\n");
 
-	} else { /* SerDes */
-		DP(NETIF_MSG_LINK, "bnx2x_phy_deassert:SerDes\n");
-		val = SERDES_RESET_BITS;
-	}
-
-	val = val << (params->port*16);
+	val = SERDES_RESET_BITS << (port*16);
 
 	/* reset and unreset the SerDes/XGXS */
-	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_3_CLEAR,
-		    val);
+	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_3_CLEAR, val);
 	udelay(500);
-	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_3_SET,
-		    val);
-	bnx2x_set_phy_mdio(params, phy_flags);
+	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_3_SET, val);
+
+	bnx2x_set_serdes_access(bp, port);
+
+	REG_WR(bp, NIG_REG_SERDES0_CTRL_MD_DEVAD +
+		     port*0x10,
+		     DEFAULT_PHY_DEV_ADDR);
 }
 
+static void bnx2x_xgxs_deassert(struct link_params *params)
+{
+	struct bnx2x *bp = params->bp;
+	u8 port;
+	u32 val;
+	DP(NETIF_MSG_LINK, "bnx2x_xgxs_deassert\n");
+	port = params->port;
+
+	val = XGXS_RESET_BITS << (port*16);
+
+	/* reset and unreset the SerDes/XGXS */
+	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_3_CLEAR, val);
+	udelay(500);
+	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_3_SET, val);
+
+	REG_WR(bp, NIG_REG_XGXS0_CTRL_MD_ST +
+		     port*0x18, 0);
+	REG_WR(bp, NIG_REG_XGXS0_CTRL_MD_DEVAD + port*0x18,
+		     params->phy[INT_PHY].def_md_devad);
+}
 void bnx2x_link_status_update(struct link_params *params,
 			    struct link_vars   *vars)
 {
@@ -799,25 +796,32 @@ static u8 bnx2x_pbf_update(struct link_params *params, u32 flow_ctrl,
 	return 0;
 }
 
-static u32 bnx2x_get_emac_base(struct bnx2x *bp, u32 ext_phy_type, u8 port)
+static u32 bnx2x_get_emac_base(struct bnx2x *bp,
+			       u32 mdc_mdio_access, u8 port)
 {
-	u32 emac_base;
-
-	switch (ext_phy_type) {
-	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072:
-	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726:
-	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727:
-		/* All MDC/MDIO is directed through single EMAC */
+	u32 emac_base = 0;
+	switch (mdc_mdio_access) {
+	case SHARED_HW_CFG_MDC_MDIO_ACCESS1_PHY_TYPE:
+		break;
+	case SHARED_HW_CFG_MDC_MDIO_ACCESS1_EMAC0:
+		if (REG_RD(bp, NIG_REG_PORT_SWAP))
+			emac_base = GRCBASE_EMAC1;
+		else
+			emac_base = GRCBASE_EMAC0;
+		break;
+	case SHARED_HW_CFG_MDC_MDIO_ACCESS1_EMAC1:
 		if (REG_RD(bp, NIG_REG_PORT_SWAP))
 			emac_base = GRCBASE_EMAC0;
 		else
 			emac_base = GRCBASE_EMAC1;
 		break;
-	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073:
+	case SHARED_HW_CFG_MDC_MDIO_ACCESS1_BOTH:
+		emac_base = (port) ? GRCBASE_EMAC1 : GRCBASE_EMAC0;
+		break;
+	case SHARED_HW_CFG_MDC_MDIO_ACCESS1_SWAPPED:
 		emac_base = (port) ? GRCBASE_EMAC0 : GRCBASE_EMAC1;
 		break;
 	default:
-		emac_base = (port) ? GRCBASE_EMAC1 : GRCBASE_EMAC0;
 		break;
 	}
 	return emac_base;
@@ -1147,7 +1151,7 @@ static void bnx2x_set_parallel_detection(struct bnx2x_phy *phy,
 			      control2);
 
 	if ((phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT) &&
-	     (params->speed_cap_mask &
+	     (phy->speed_cap_mask &
 		    PORT_HW_CFG_SPEED_CAPABILITY_D0_10G)) {
 		DP(NETIF_MSG_LINK, "XGXS\n");
 
@@ -1777,7 +1781,7 @@ static u8 bnx2x_link_settings_status(struct bnx2x_phy *phy,
 	struct bnx2x *bp = params->bp;
 	u16 new_line_speed , gp_status;
 	u8 rc = 0;
-	u32 ext_phy_type;
+
 	/* Read gp_status */
 	CL45_RD_OVER_CL22(bp, phy,
 				MDIO_REG_BANK_GP_STATUS,
@@ -1885,30 +1889,7 @@ static u8 bnx2x_link_settings_status(struct bnx2x_phy *phy,
 		}
 
 		vars->line_speed = new_line_speed;
-		vars->link_status |= LINK_STATUS_SERDES_LINK;
-		ext_phy_type = params->phy[EXT_PHY1].type;
-		if ((params->req_line_speed == SPEED_AUTO_NEG) &&
-		    ((ext_phy_type ==
-		     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT) ||
-		    (ext_phy_type ==
-		     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705) ||
-		    (ext_phy_type ==
-		     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706) ||
-		    (ext_phy_type ==
-		     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726))) {
-			vars->autoneg = AUTO_NEG_ENABLED;
-
-			if (gp_status & MDIO_AN_CL73_OR_37_COMPLETE) {
-				vars->autoneg |= AUTO_NEG_COMPLETE;
-				vars->link_status |=
-					LINK_STATUS_AUTO_NEGOTIATE_COMPLETE;
-			}
 
-			vars->autoneg |= AUTO_NEG_PARALLEL_DETECTION_USED;
-			vars->link_status |=
-				LINK_STATUS_PARALLEL_DETECTION_USED;
-
-		}
 
 	} else { /* link_down */
 		DP(NETIF_MSG_LINK, "phy link down\n");
@@ -1917,14 +1898,12 @@ static u8 bnx2x_link_settings_status(struct bnx2x_phy *phy,
 
 		vars->duplex = DUPLEX_FULL;
 		vars->flow_ctrl = BNX2X_FLOW_CTRL_NONE;
-		vars->autoneg = AUTO_NEG_DISABLED;
 		vars->mac_type = MAC_TYPE_NONE;
 
-		if ((params->req_line_speed == SPEED_AUTO_NEG) &&
-		    (SINGLE_MEDIA_DIRECT(params))) {
+		if ((phy->req_line_speed == SPEED_AUTO_NEG) &&
+		    SINGLE_MEDIA_DIRECT(params)) {
 			/* Check signal is detected */
-			bnx2x_check_fallback_to_cl37(&params->phy[INT_PHY],
-						     params);
+			bnx2x_check_fallback_to_cl37(phy, params);
 		}
 	}
 
@@ -2078,6 +2057,7 @@ static u8 bnx2x_init_xgxs(struct bnx2x_phy *phy,
 
 	return rc;
 }
+
 /*****************************************************************************/
 /*			    External Phy section			     */
 /*****************************************************************************/
@@ -2091,19 +2071,18 @@ void bnx2x_ext_phy_hw_reset(struct bnx2x *bp, u8 port)
 }
 
 static void bnx2x_save_spirom_version(struct bnx2x *bp, u8 port,
-				    u32 shmem_base, u32 spirom_ver)
+				      u32 spirom_ver, u32 ver_addr)
 {
 	DP(NETIF_MSG_LINK, "FW version 0x%x:0x%x for port %d\n",
 		 (u16)(spirom_ver>>16), (u16)spirom_ver, port);
-	REG_WR(bp, shmem_base +
-		   offsetof(struct shmem_region,
-			    port_mb[port].ext_phy_fw_version),
-			spirom_ver);
+
+	if (ver_addr)
+		REG_WR(bp, ver_addr, spirom_ver);
 }
 
-static void bnx2x_save_bcm_spirom_ver(struct bnx2x *bp, u8 port,
+static void bnx2x_save_bcm_spirom_ver(struct bnx2x *bp,
 				      struct bnx2x_phy *phy,
-				      u32 shmem_base)
+				      u8 port)
 {
 	u16 fw_ver1, fw_ver2;
 
@@ -2111,13 +2090,12 @@ static void bnx2x_save_bcm_spirom_ver(struct bnx2x *bp, u8 port,
 		      MDIO_PMA_REG_ROM_VER1, &fw_ver1);
 	bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD,
 		      MDIO_PMA_REG_ROM_VER2, &fw_ver2);
-	bnx2x_save_spirom_version(bp, port, shmem_base,
-				(u32)(fw_ver1<<16 | fw_ver2));
+	bnx2x_save_spirom_version(bp, port, (u32)(fw_ver1<<16 | fw_ver2),
+				  phy->ver_addr);
 }
 
-static void bnx2x_save_8481_spirom_version(struct bnx2x_phy *phy,
-					   struct link_params *params,
-					   u32 shmem_base)
+static void bnx2x_save_848xx_spirom_version(struct bnx2x_phy *phy,
+					   struct link_params *params)
 {
 	u16 val, fw_ver1, fw_ver2, cnt;
 	struct bnx2x *bp = params->bp;
@@ -2137,9 +2115,9 @@ static void bnx2x_save_8481_spirom_version(struct bnx2x_phy *phy,
 		udelay(5);
 	}
 	if (cnt == 100) {
-		DP(NETIF_MSG_LINK, "Unable to read 8481 phy fw version(1)\n");
-		bnx2x_save_spirom_version(bp, params->port,
-					shmem_base, 0);
+		DP(NETIF_MSG_LINK, "Unable to read 848xx phy fw version(1)\n");
+		bnx2x_save_spirom_version(bp, params->port, 0,
+					  phy->ver_addr);
 		return;
 	}
 
@@ -2169,7 +2147,6 @@ static void bnx2x_save_8481_spirom_version(struct bnx2x_phy *phy,
 	bnx2x_save_spirom_version(bp, params->port, (fw_ver2<<16) | fw_ver1,
 				  phy->ver_addr);
 }
-
 static u8 bnx2x_8073_is_snr_needed(struct bnx2x *bp, struct bnx2x_phy *phy)
 {
 	/* This is only required for 8073A1, version 102 only */
@@ -2250,7 +2227,7 @@ static u8 bnx2x_8073_xaui_wa(struct bnx2x *bp, struct bnx2x_phy *phy)
 
 static void bnx2x_8073_8727_external_rom_boot(struct bnx2x *bp,
 					      struct bnx2x_phy *phy,
-					      u8 port, u32 shmem_base)
+					      u8 port)
 {
 	/* Boot port from external ROM  */
 	/* EDC grst */
@@ -2288,7 +2265,7 @@ static void bnx2x_8073_8727_external_rom_boot(struct bnx2x *bp,
 	bnx2x_cl45_write(bp, phy,
 		       MDIO_PMA_DEVAD,
 		       MDIO_PMA_REG_MISC_CTRL1, 0x0000);
-	bnx2x_save_bcm_spirom_ver(bp, port, phy, shmem_base);
+	bnx2x_save_bcm_spirom_ver(bp, phy, port);
 }
 
 static void bnx2x_8726_external_rom_boot(struct bnx2x_phy *phy,
@@ -2326,9 +2303,7 @@ static void bnx2x_8726_external_rom_boot(struct bnx2x_phy *phy,
 		       MDIO_PMA_REG_MISC_CTRL1, 0x0000);
 
 	msleep(200);
-	bnx2x_save_bcm_spirom_ver(bp, params->port,
-				phy,
-				params->shmem_base);
+	bnx2x_save_bcm_spirom_ver(bp, phy, params->port);
 }
 
 static void bnx2x_sfp_set_transmitter(struct bnx2x *bp,
@@ -3055,7 +3030,7 @@ static void bnx2x_set_preemphasis(struct bnx2x_phy *phy,
 	}
 }
 
-static void bnx2x_8481_set_led(struct bnx2x *bp,
+static void bnx2x_848xx_set_led(struct bnx2x *bp,
 				struct bnx2x_phy *phy)
 {
 	u16 val;
@@ -3195,7 +3170,6 @@ static u8 bnx2x_8706_config_init(struct bnx2x_phy *phy,
 	/* HW reset */
 	bnx2x_ext_phy_hw_reset(bp, params->port);
 	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, MDIO_PMA_REG_CTRL, 0xa040);
-
 	bnx2x_wait_reset_complete(bp, phy);
 
 	/* Wait until fw is loaded */
@@ -3262,7 +3236,7 @@ static u8 bnx2x_8706_config_init(struct bnx2x_phy *phy,
 				 MDIO_PMA_DEVAD, MDIO_PMA_REG_LASI_CTRL,
 				 0x0004);
 	}
-	bnx2x_save_bcm_spirom_ver(bp, params->port, phy, params->shmem_base);
+	bnx2x_save_bcm_spirom_ver(bp, phy, params->port);
 	return 0;
 }
 
@@ -3512,6 +3486,7 @@ static u8 bnx2x_8073_config_init(struct bnx2x_phy *phy,
 	return 0;
 }
 
+
 static u8 bnx2x_8727_config_init(struct bnx2x_phy *phy,
 				 struct link_params *params,
 				 struct link_vars *vars)
@@ -3690,7 +3665,7 @@ static u8 bnx2x_848xx_cmn_config_init(struct bnx2x_phy *phy,
 
 	bnx2x_cl45_write(bp, phy,
 			 MDIO_PMA_DEVAD, MDIO_PMA_REG_CTRL, 0x0000);
-	bnx2x_8481_set_led(bp, phy);
+	bnx2x_848xx_set_led(bp, phy);
 	/* set 1000 speed advertisement */
 	bnx2x_cl45_read(bp, phy,
 			MDIO_AN_DEVAD, MDIO_AN_REG_8481_1000T_CTRL,
@@ -3795,7 +3770,7 @@ static u8 bnx2x_848xx_cmn_config_init(struct bnx2x_phy *phy,
 				 1);
 	}
 	/* Save spirom version */
-	bnx2x_save_8481_spirom_version(phy, params, params->shmem_base);
+	bnx2x_save_848xx_spirom_version(phy, params);
 
 	return 0;
 }
@@ -3935,6 +3910,7 @@ static void bnx2x_8727_handle_mod_abs(struct bnx2x_phy *phy,
 	module plugged in/out */
 }
 
+
 static u8 bnx2x_8705_read_status(struct bnx2x_phy *phy,
 				 struct link_params *params,
 				 struct link_vars *vars)
@@ -4011,7 +3987,6 @@ static u8 bnx2x_8706_8726_read_status(struct bnx2x_phy *phy,
 	}
 	return link_up;
 }
-
 static u8 bnx2x_8706_read_status(struct bnx2x_phy *phy,
 				 struct link_params *params,
 				 struct link_vars *vars)
@@ -4038,6 +4013,7 @@ static u8 bnx2x_8726_read_status(struct bnx2x_phy *phy,
 	}
 	return link_up;
 }
+
 static u8 bnx2x_8727_read_status(struct bnx2x_phy *phy,
 				 struct link_params *params,
 				 struct link_vars *vars)
@@ -4183,7 +4159,6 @@ static void bnx2x_8073_resolve_fc(struct bnx2x_phy *phy,
 			   pause_result);
 	}
 }
-
 static u8 bnx2x_8073_read_status(struct bnx2x_phy *phy,
 				 struct link_params *params,
 				 struct link_vars *vars)
@@ -4415,6 +4390,7 @@ static u8 bnx2x_848xx_read_status(struct bnx2x_phy *phy,
 
 	return link_up;
 }
+
 static void bnx2x_link_int_enable(struct link_params *params)
 {
 	u8 port = params->port;
@@ -4616,7 +4592,6 @@ static u8 bnx2x_null_format_ver(u32 spirom_ver, u8 *str, u16 *len)
 	(*len)--;
 	return 0;
 }
-
 u8 bnx2x_get_ext_phy_fw_version(struct link_params *params, u8 driver_loaded,
 			      u8 *version, u16 len)
 {
@@ -4706,6 +4681,7 @@ static void bnx2x_7101_config_loopback(struct bnx2x_phy *phy,
 	bnx2x_cl45_write(bp, phy,
 			 MDIO_XS_DEVAD, MDIO_XS_SFX7101_XGXS_TEST1, 0x100);
 }
+
 /*
  *------------------------------------------------------------------------
  * bnx2x_override_led_value -
@@ -4892,7 +4868,7 @@ u8 bnx2x_set_led(struct link_params *params, u8 mode, u32 speed)
 u8 bnx2x_test_link(struct link_params *params, struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
-	u16 gp_status = 0;
+	u16 gp_status = 0, phy_index = 0;
 
 	CL45_RD_OVER_CL22(bp, &params->phy[INT_PHY],
 			      MDIO_REG_BANK_GP_STATUS,
@@ -4902,86 +4878,59 @@ u8 bnx2x_test_link(struct link_params *params, struct link_vars *vars)
 	if (gp_status & MDIO_GP_STATUS_TOP_AN_STATUS1_LINK_STATUS) {
 		u8 ext_phy_link_up = 1;
 		struct link_vars temp_vars;
-		if (params->phy[EXT_PHY1].read_status)
-			ext_phy_link_up &=
-				params->phy[EXT_PHY1].read_status(
-						&params->phy[EXT_PHY1],
+		for (phy_index = EXT_PHY1; phy_index < params->num_phys;
+		      phy_index++) {
+			if (params->phy[phy_index].read_status)
+				ext_phy_link_up &=
+					params->phy[phy_index].read_status(
+						&params->phy[phy_index],
 						params, &temp_vars);
+		}
 		if (ext_phy_link_up)
 			return 0;
 	}
-
 	return -ESRCH;
 }
 
 static u8 bnx2x_link_initialize(struct link_params *params,
 				struct link_vars *vars)
 {
-	struct bnx2x *bp = params->bp;
 	u8 rc = 0;
 	u8 phy_index, non_ext_phy;
-	struct bnx2x_phy *ext_phy = &params->phy[EXT_PHY1];
-	struct bnx2x_phy *int_phy = &params->phy[INT_PHY];
-	/* Activate the external PHY */
-
-	bnx2x_set_aer_mmd(params, int_phy);
-
-	if (vars->phy_flags & PHY_XGXS_FLAG)
-		bnx2x_set_master_ln(params, int_phy);
-
-	rc = bnx2x_reset_unicore(params, int_phy,
-				 int_phy->type ==
-				 PORT_HW_CFG_SERDES_EXT_PHY_TYPE_DIRECT);
-	/* reset the SerDes and wait for reset bit return low */
-	if (rc != 0)
-		return rc;
-
-	bnx2x_set_aer_mmd(params, int_phy);
-
-	/* setting the masterLn_def again after the reset */
-	if (vars->phy_flags & PHY_XGXS_FLAG) {
-		bnx2x_set_master_ln(params, int_phy);
-		bnx2x_set_swap_lanes(params, int_phy);
-	}
+	struct bnx2x *bp = params->bp;
+	/**
+	* In case of external phy existence, the line speed would be the
+	* line speed linked up by the external phy. In case it is direct
+	* only, then the line_speed during initialization will be
+	* equal to the req_line_speed
+	*/
+	vars->line_speed = params->phy[INT_PHY].req_line_speed;
 
-	if (vars->phy_flags & PHY_XGXS_FLAG) {
-		if ((params->req_line_speed &&
-		    ((params->req_line_speed == SPEED_100) ||
-		     (params->req_line_speed == SPEED_10))) ||
-		    (!params->req_line_speed &&
-		     (params->speed_cap_mask >=
-		       PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_FULL) &&
-		     (params->speed_cap_mask <
-		       PORT_HW_CFG_SPEED_CAPABILITY_D0_1G)
-		     ))  {
-			vars->phy_flags |= PHY_SGMII_FLAG;
-		} else {
-			vars->phy_flags &= ~PHY_SGMII_FLAG;
-		}
-	}
-	/* In case of external phy existance, the line speed would be the
-	 line speed linked up by the external phy. In case it is direct only,
-	  then the line_speed during initialization will be equal to the
-	   req_line_speed*/
-	vars->line_speed = params->req_line_speed;
+	/**
+	 * Initialize the internal phy in case this is a direct board
+	 * (no external phys), or this board has external phy which requires
+	 * to first.
+	 */
 
-	bnx2x_calc_ieee_aneg_adv(int_phy, params, &vars->ieee_fc);
+	if (params->phy[INT_PHY].config_init)
+		params->phy[INT_PHY].config_init(
+			&params->phy[INT_PHY],
+			params, vars);
 
 	/* init ext phy and enable link state int */
-	non_ext_phy = ((ext_phy->type ==
-			PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT) ||
+	non_ext_phy = (SINGLE_MEDIA_DIRECT(params) ||
 		       (params->loopback_mode == LOOPBACK_XGXS_10));
 
 	if (non_ext_phy ||
-	    (ext_phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705) ||
-	    (ext_phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706) ||
-	    (ext_phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726) ||
+	    (params->phy[EXT_PHY1].flags & FLAGS_INIT_XGXS_FIRST) ||
 	    (params->loopback_mode == LOOPBACK_EXT_PHY)) {
+		struct bnx2x_phy *phy = &params->phy[INT_PHY];
 		if (vars->line_speed == SPEED_AUTO_NEG)
-			bnx2x_set_parallel_detection(int_phy, params);
-		bnx2x_init_internal_phy(int_phy, params, vars);
+			bnx2x_set_parallel_detection(phy, params);
+		bnx2x_init_internal_phy(phy, params, vars);
 	}
 
+	/* Init external phy*/
 	if (!non_ext_phy)
 		for (phy_index = EXT_PHY1; phy_index < params->num_phys;
 		      phy_index++) {
@@ -4997,7 +4946,6 @@ static u8 bnx2x_link_initialize(struct link_params *params,
 			NIG_STATUS_XGXS0_LINK_STATUS |
 			NIG_STATUS_SERDES0_LINK_STATUS |
 			NIG_MASK_MI_INT));
-
 	return rc;
 }
 
@@ -5122,7 +5070,7 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 
 		vars->phy_flags = PHY_XGXS_FLAG;
 
-		bnx2x_phy_deassert(params, vars->phy_flags);
+		bnx2x_xgxs_deassert(params);
 
 		/* set bmac loopback */
 		bnx2x_bmac_enable(params, vars, 1);
@@ -5140,7 +5088,7 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 
 		vars->phy_flags = PHY_XGXS_FLAG;
 
-		bnx2x_phy_deassert(params, vars->phy_flags);
+		bnx2x_xgxs_deassert(params);
 		/* set bmac loopback */
 		bnx2x_emac_enable(params, vars, 1);
 		bnx2x_emac_program(params, vars);
@@ -5161,7 +5109,7 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 				 NIG_REG_XGXS0_CTRL_PHY_ADDR+
 				 params->port*0x18);
 
-		bnx2x_phy_deassert(params, vars->phy_flags);
+		bnx2x_xgxs_deassert(params);
 		bnx2x_link_initialize(params, vars);
 
 		vars->mac_type = MAC_TYPE_BMAC;
@@ -5194,8 +5142,9 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 	/* No loopback */
 	{
 		if (params->switch_cfg == SWITCH_CFG_10G)
-			vars->phy_flags = PHY_XGXS_FLAG;
-		bnx2x_phy_deassert(params, vars->phy_flags);
+			bnx2x_xgxs_deassert(params);
+		else
+			bnx2x_serdes_deassert(bp, params->port);
 		bnx2x_link_initialize(params, vars);
 		msleep(30);
 		bnx2x_link_int_enable(params);
@@ -5282,9 +5231,7 @@ u8 bnx2x_link_reset(struct link_params *params, struct link_vars *vars,
 		  u8 reset_ext_phy)
 {
 	struct bnx2x *bp = params->bp;
-
 	u8 phy_index, port = params->port;
-
 	DP(NETIF_MSG_LINK, "Resetting the link of port %d\n", port);
 	/* disable attentions */
 	vars->link_status = 0;
@@ -5340,7 +5287,6 @@ u8 bnx2x_link_reset(struct link_params *params, struct link_vars *vars,
 	return 0;
 }
 
-
 static u8 bnx2x_update_link_down(struct link_params *params,
 			       struct link_vars *vars)
 {
@@ -6078,7 +6024,7 @@ static u8 bnx2x_populate_int_phy(struct bnx2x *bp, u32 shmem_base, u8 port,
 	}
 	phy->addr = (u8)phy_addr;
 	phy->mdio_ctrl = bnx2x_get_emac_base(bp,
-					    phy->type,
+					    SHARED_HW_CFG_MDC_MDIO_ACCESS1_BOTH,
 					    port);
 	phy->def_md_devad = DEFAULT_PHY_DEV_ADDR;
 
@@ -6095,14 +6041,15 @@ static u8 bnx2x_populate_ext_phy(struct bnx2x *bp,
 				 u8 port,
 				 struct bnx2x_phy *phy)
 {
-	u32 ext_phy_config, phy_type;
-
+	u32 ext_phy_config, phy_type, config2;
+	u32 mdc_mdio_access = SHARED_HW_CFG_MDC_MDIO_ACCESS1_BOTH;
 	ext_phy_config = bnx2x_get_ext_phy_config(bp, shmem_base,
 						  phy_index, port);
 	phy_type = XGXS_EXT_PHY_TYPE(ext_phy_config);
 	/* Select the phy type */
 	switch (phy_type) {
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073:
+		mdc_mdio_access = SHARED_HW_CFG_MDC_MDIO_ACCESS1_SWAPPED;
 		*phy = phy_8073;
 		break;
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705:
@@ -6112,14 +6059,17 @@ static u8 bnx2x_populate_ext_phy(struct bnx2x *bp,
 		*phy = phy_8706;
 		break;
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726:
+		mdc_mdio_access = SHARED_HW_CFG_MDC_MDIO_ACCESS1_EMAC1;
 		*phy = phy_8726;
 		break;
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727_NOC:
 		/* BCM8727_NOC => BCM8727 no over current */
+		mdc_mdio_access = SHARED_HW_CFG_MDC_MDIO_ACCESS1_EMAC1;
 		*phy = phy_8727;
 		phy->flags |= FLAGS_NOC;
 		break;
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727:
+		mdc_mdio_access = SHARED_HW_CFG_MDC_MDIO_ACCESS1_EMAC1;
 		*phy = phy_8727;
 		break;
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481:
@@ -6141,8 +6091,36 @@ static u8 bnx2x_populate_ext_phy(struct bnx2x *bp,
 
 	phy->addr = XGXS_EXT_PHY_ADDR(ext_phy_config);
 	bnx2x_populate_preemphasis(bp, shmem_base, phy, port, phy_index);
-	phy->mdio_ctrl = bnx2x_get_emac_base(bp, phy->type, port);
 
+	/**
+	* The shmem address of the phy version is located on different
+	* structures. In case this structure is too old, do not set
+	* the address
+	*/
+	config2 = REG_RD(bp, shmem_base + offsetof(struct shmem_region,
+					dev_info.shared_hw_config.config2));
+
+	phy->ver_addr = shmem_base + offsetof(struct shmem_region,
+			port_mb[port].ext_phy_fw_version);
+
+	/* Check specific mdc mdio settings */
+	if (config2 & SHARED_HW_CFG_MDC_MDIO_ACCESS1_MASK)
+		mdc_mdio_access = config2 &
+		SHARED_HW_CFG_MDC_MDIO_ACCESS1_MASK;
+
+	phy->mdio_ctrl = bnx2x_get_emac_base(bp, mdc_mdio_access, port);
+
+	/**
+	 * In case mdc/mdio_access of the external phy is different than the
+	 * mdc/mdio access of the XGXS, a HW lock must be taken in each access
+	 * to prevent one port interfere with another port's CL45 operations.
+	 */
+	if (mdc_mdio_access != SHARED_HW_CFG_MDC_MDIO_ACCESS1_BOTH)
+		phy->flags |= FLAGS_HW_LOCK_REQUIRED;
+	DP(NETIF_MSG_LINK, "phy_type 0x%x port %d found in index %d\n",
+		   phy_type, port, phy_index);
+	DP(NETIF_MSG_LINK, "             addr=0x%x, mdio_ctl=0x%x\n",
+		   phy->addr, phy->mdio_ctrl);
 	return 0;
 }
 
@@ -6262,7 +6240,6 @@ u32 bnx2x_supported_attr(struct link_params *params, u8 phy_idx)
 	return 0;
 }
 
-
 static u8 bnx2x_8073_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 {
 	struct bnx2x_phy phy[PORT_MAX];
@@ -6314,7 +6291,7 @@ static u8 bnx2x_8073_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 		u16 fw_ver1;
 
 		bnx2x_8073_8727_external_rom_boot(bp, phy_blk[port],
-						  port, shmem_base);
+						  port);
 
 		bnx2x_cl45_read(bp, phy_blk[port],
 			      MDIO_PMA_DEVAD,
@@ -6427,7 +6404,7 @@ static u8 bnx2x_8727_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 		u16 fw_ver1;
 
 		bnx2x_8073_8727_external_rom_boot(bp, phy_blk[port],
-						  port, shmem_base);
+						  port);
 		bnx2x_cl45_read(bp, phy_blk[port],
 			      MDIO_PMA_DEVAD,
 			      MDIO_PMA_REG_ROM_VER1, &fw_ver1);
diff --git a/drivers/net/bnx2x/bnx2x_link.h b/drivers/net/bnx2x/bnx2x_link.h
index d663c4f..99e1157 100644
--- a/drivers/net/bnx2x/bnx2x_link.h
+++ b/drivers/net/bnx2x/bnx2x_link.h
@@ -268,6 +268,7 @@ u8 bnx2x_phy_read(struct link_params *params, u8 phy_addr,
 
 u8 bnx2x_phy_write(struct link_params *params, u8 phy_addr,
 		   u8 devad, u16 reg, u16 val);
+
 u8 bnx2x_cl45_read(struct bnx2x *bp, struct bnx2x_phy *phy,
 		   u8 devad, u16 reg, u16 *ret_val);
 
-- 
1.7.1




