From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 17/41]bnx2x: Saving PHY FW version
Date: Thu, 12 Feb 2009 20:37:02 +0200
Message-ID: <1234463822.1863.149.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3738 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758282AbZBLShc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 13:37:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 17/41]bnx2x: Saving PHY FW version
Some PHYs (like the BCM8726) FW version cannot be read after activating the
PHY, so we need to save this information

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_hsi.h  |    2 +
 drivers/net/bnx2x_link.c |  180 +++++++++++++++++++++++-----------------------
 2 files changed, 92 insertions(+), 90 deletions(-)

diff --git a/drivers/net/bnx2x_hsi.h b/drivers/net/bnx2x_hsi.h
index 7b9acb3..7a62bfd 100644
--- a/drivers/net/bnx2x_hsi.h
+++ b/drivers/net/bnx2x_hsi.h
@@ -634,6 +634,8 @@ struct drv_port_mb {
 
 	u32 stat_nig_timer;
 
+	/* MCP firmware does not use this field */
+	u32 ext_phy_fw_version;
 
 };
 
diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index bed11b9..ffa412f 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -2047,6 +2047,31 @@ static void bnx2x_ext_phy_reset(struct link_params *params,
 	}
 }
 
+
+static void bnx2x_save_spirom_version(struct bnx2x *bp, u8 port,
+				    u32 shmem_base, u32 spirom_ver)
+{
+	DP(NETIF_MSG_LINK, "FW version 0x%x:0x%x\n",
+		 (u16)(spirom_ver>>16), (u16)spirom_ver);
+	REG_WR(bp, shmem_base +
+		   offsetof(struct shmem_region,
+			    port_mb[port].ext_phy_fw_version),
+			spirom_ver);
+}
+
+static void bnx2x_save_bcm_spirom_ver(struct bnx2x *bp, u8 port,
+				    u32 ext_phy_type, u8 ext_phy_addr,
+				    u32 shmem_base)
+{
+	u16 fw_ver1, fw_ver2;
+	bnx2x_cl45_read(bp, port, ext_phy_type, ext_phy_addr, MDIO_PMA_DEVAD,
+		      MDIO_PMA_REG_ROM_VER1, &fw_ver1);
+	bnx2x_cl45_read(bp, port, ext_phy_type, ext_phy_addr, MDIO_PMA_DEVAD,
+		      MDIO_PMA_REG_ROM_VER2, &fw_ver2);
+	bnx2x_save_spirom_version(bp, port, shmem_base,
+				(u32)(fw_ver1<<16 | fw_ver2));
+}
+
 static void bnx2x_bcm8072_external_rom_boot(struct link_params *params)
 {
 	struct bnx2x *bp = params->bp;
@@ -2055,7 +2080,6 @@ static void bnx2x_bcm8072_external_rom_boot(struct link_params *params)
 			     PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
 			    PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
 	u32 ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
-	u16 fw_ver1, fw_ver2;
 
 	/* Need to wait 200ms after reset */
 	msleep(200);
@@ -2091,14 +2115,10 @@ static void bnx2x_bcm8072_external_rom_boot(struct link_params *params)
 	/* Wait 100ms */
 	msleep(100);
 
-	/* Print the PHY FW version */
-	bnx2x_cl45_read(bp, port, ext_phy_type, ext_phy_addr,
-			    MDIO_PMA_DEVAD,
-			    MDIO_PMA_REG_ROM_VER1, &fw_ver1);
-	bnx2x_cl45_read(bp, port, ext_phy_type, ext_phy_addr,
-			    MDIO_PMA_DEVAD,
-			    MDIO_PMA_REG_ROM_VER2, &fw_ver2);
-	DP(NETIF_MSG_LINK, "8072 FW version 0x%x:0x%x\n", fw_ver1, fw_ver2);
+	bnx2x_save_bcm_spirom_ver(bp, port,
+				ext_phy_type,
+				ext_phy_addr,
+				params->shmem_base);
 }
 
 static u8 bnx2x_8073_is_snr_needed(struct link_params *params)
@@ -2200,9 +2220,8 @@ static u8 bnx2x_bcm8073_xaui_wa(struct link_params *params)
 }
 
 static void bnx2x_bcm8073_external_rom_boot(struct bnx2x *bp, u8 port,
-					  u8 ext_phy_addr)
+					  u8 ext_phy_addr, u32 shmem_base)
 {
-	u16 fw_ver1, fw_ver2;
 	/* Boot port from external ROM  */
 	/* EDC grst */
 	bnx2x_cl45_write(bp, port,
@@ -2252,17 +2271,10 @@ static void bnx2x_bcm8073_external_rom_boot(struct bnx2x *bp, u8 port,
 		       MDIO_PMA_DEVAD,
 		       MDIO_PMA_REG_MISC_CTRL1, 0x0000);
 
-	bnx2x_cl45_read(bp, port, PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073,
-		      ext_phy_addr,
-		      MDIO_PMA_DEVAD,
-		      MDIO_PMA_REG_ROM_VER1, &fw_ver1);
-	bnx2x_cl45_read(bp, port,
-		      PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073,
-		      ext_phy_addr,
-		      MDIO_PMA_DEVAD,
-		      MDIO_PMA_REG_ROM_VER2, &fw_ver2);
-	DP(NETIF_MSG_LINK, "8073 FW version 0x%x:0x%x\n", fw_ver1, fw_ver2);
-
+	bnx2x_save_bcm_spirom_ver(bp, port,
+				PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073,
+				ext_phy_addr,
+				shmem_base);
 }
 
 static void bnx2x_bcm8726_external_rom_boot(struct link_params *params)
@@ -2310,6 +2322,10 @@ static void bnx2x_bcm8726_external_rom_boot(struct link_params *params)
 		       MDIO_PMA_REG_MISC_CTRL1, 0x0000);
 
 	msleep(200);
+	bnx2x_save_bcm_spirom_ver(bp, port,
+				ext_phy_type,
+				ext_phy_addr,
+				params->shmem_base);
 }
 
 static void bnx2x_bcm8726_set_transmitter(struct bnx2x *bp, u8 port,
@@ -3051,12 +3067,25 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 				       ext_phy_addr,
 				       MDIO_WIS_DEVAD,
 				       MDIO_WIS_REG_LASI_CNTL, 0x1);
+
+			bnx2x_save_bcm_spirom_ver(bp, params->port,
+						ext_phy_type,
+						ext_phy_addr,
+						params->shmem_base);
 			break;
 
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706:
-			DP(NETIF_MSG_LINK, "XGXS 8706\n");
-
-			msleep(10);
+			/* Wait until fw is loaded */
+			for (cnt = 0; cnt < 100; cnt++) {
+				bnx2x_cl45_read(bp, params->port, ext_phy_type,
+					      ext_phy_addr, MDIO_PMA_DEVAD,
+					      MDIO_PMA_REG_ROM_VER1, &val);
+				if (val)
+					break;
+				msleep(10);
+			}
+			DP(NETIF_MSG_LINK, "XGXS 8706 is initialized "
+				"after %d ms\n", cnt);
 			/* Force speed */
 			/* First enable LASI */
 			bnx2x_cl45_write(bp, params->port,
@@ -3123,7 +3152,10 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 					       0x1200);
 
 			}
-
+			bnx2x_save_bcm_spirom_ver(bp, params->port,
+						ext_phy_type,
+						ext_phy_addr,
+						params->shmem_base);
 			break;
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726:
 			DP(NETIF_MSG_LINK, "Initializing BCM8726\n");
@@ -3404,6 +3436,8 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 			break;
 		}
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101:
+		{
+			u16 fw_ver1, fw_ver2;
 			DP(NETIF_MSG_LINK,
 				"Setting the SFX7101 LASI indication\n");
 
@@ -3434,7 +3468,21 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 				       MDIO_AN_DEVAD,
 				       MDIO_AN_REG_CTRL, val);
 
+			/* Save spirom version */
+			bnx2x_cl45_read(bp, params->port, ext_phy_type,
+				      ext_phy_addr, MDIO_PMA_DEVAD,
+				      MDIO_PMA_REG_7101_VER1, &fw_ver1);
+
+			bnx2x_cl45_read(bp, params->port, ext_phy_type,
+				      ext_phy_addr, MDIO_PMA_DEVAD,
+				      MDIO_PMA_REG_7101_VER2, &fw_ver2);
+
+			bnx2x_save_spirom_version(params->bp, params->port,
+						params->shmem_base,
+						(u32)(fw_ver1<<16 | fw_ver2));
+
 			break;
+		}
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481:
 			DP(NETIF_MSG_LINK,
 				"Setting the BCM8481 LASI control\n");
@@ -3458,6 +3506,11 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 				       MDIO_AN_DEVAD,
 				       MDIO_AN_REG_CTRL, val);
 
+			bnx2x_save_bcm_spirom_ver(bp, params->port,
+						ext_phy_type,
+						ext_phy_addr,
+						params->shmem_base);
+
 			break;
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE:
 			DP(NETIF_MSG_LINK,
@@ -4146,91 +4199,38 @@ u8 bnx2x_get_ext_phy_fw_version(struct link_params *params, u8 driver_loaded,
 {
 	struct bnx2x *bp = params->bp;
 	u32 ext_phy_type = 0;
-	u16 val = 0;
-	u8 ext_phy_addr = 0 ;
+	u32 spirom_ver = 0;
 	u8 status = 0 ;
-	u32 ver_num;
 
 	if (version == NULL || params == NULL)
 		return -EINVAL;
 
+	spirom_ver = REG_RD(bp, params->shmem_base +
+		   offsetof(struct shmem_region,
+			    port_mb[params->port].ext_phy_fw_version));
+
 	/* reset the returned value to zero */
 	ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
-	ext_phy_addr = ((params->ext_phy_config &
-				PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
-				PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
-
 	switch (ext_phy_type) {
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101:
 
 		if (len < 5)
 			return -EINVAL;
 
-		/* Take ext phy out of reset */
-		if (!driver_loaded)
-			bnx2x_turn_on_ef(bp, params->port, ext_phy_addr,
-				       ext_phy_type);
-
-		/*  wait for 1ms */
-		msleep(1);
-
-		bnx2x_cl45_read(bp, params->port,
-			      ext_phy_type,
-			      ext_phy_addr,
-			      MDIO_PMA_DEVAD,
-			      MDIO_PMA_REG_7101_VER1, &val);
-		version[2] = (val & 0xFF);
-		version[3] = ((val & 0xFF00)>>8);
-
-		bnx2x_cl45_read(bp, params->port,
-			      ext_phy_type,
-			      ext_phy_addr,
-			      MDIO_PMA_DEVAD, MDIO_PMA_REG_7101_VER2,
-			      &val);
-		version[0] = (val & 0xFF);
-		version[1] = ((val & 0xFF00)>>8);
+		version[0] = (spirom_ver & 0xFF);
+		version[1] = (spirom_ver & 0xFF00) >> 8;
+		version[2] = (spirom_ver & 0xFF0000) >> 16;
+		version[3] = (spirom_ver & 0xFF000000) >> 24;
 		version[4] = '\0';
 
-		if (!driver_loaded)
-			bnx2x_turn_off_sf(bp, params->port);
 		break;
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072:
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073:
-	{
-		/* Take ext phy out of reset */
-		if (!driver_loaded)
-			bnx2x_turn_on_ef(bp, params->port, ext_phy_addr,
-				       ext_phy_type);
-
-		bnx2x_cl45_read(bp, params->port, ext_phy_type,
-			      ext_phy_addr,
-			      MDIO_PMA_DEVAD,
-			      MDIO_PMA_REG_ROM_VER1, &val);
-		ver_num = val<<16;
-		bnx2x_cl45_read(bp, params->port, ext_phy_type,
-			      ext_phy_addr,
-			      MDIO_PMA_DEVAD,
-			      MDIO_PMA_REG_ROM_VER2, &val);
-		ver_num |= val;
-		status = bnx2x_format_ver(ver_num, version, len);
-		break;
-	}
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705:
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706:
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726:
-		bnx2x_cl45_read(bp, params->port, ext_phy_type,
-			      ext_phy_addr,
-			      MDIO_PMA_DEVAD,
-			      MDIO_PMA_REG_ROM_VER1, &val);
-		ver_num = val<<16;
-		bnx2x_cl45_read(bp, params->port, ext_phy_type,
-			      ext_phy_addr,
-			      MDIO_PMA_DEVAD,
-			      MDIO_PMA_REG_ROM_VER2, &val);
-		ver_num |= val;
-		status = bnx2x_format_ver(ver_num, version, len);
+		status = bnx2x_format_ver(spirom_ver, version, len);
 		break;
-
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT:
 		break;
 
@@ -5128,7 +5128,7 @@ static u8 bnx2x_8073_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 		u16 fw_ver1;
 
 		bnx2x_bcm8073_external_rom_boot(bp, port,
-						      ext_phy_addr[port]);
+					      ext_phy_addr[port], shmem_base);
 
 		bnx2x_cl45_read(bp, port, PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073,
 			      ext_phy_addr[port],
-- 
1.5.4.3




