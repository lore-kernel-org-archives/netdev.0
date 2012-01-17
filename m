From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [net 1/5] bnx2x: Fix Super-Isolate mode for BCM84833
Date: Tue, 17 Jan 2012 14:33:25 +0200
Message-ID: <1326803609-25526-2-git-send-email-yanivr@broadcom.com>
References: <1326803609-25526-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2718 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752947Ab2AQKet (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jan 2012 05:34:49 -0500
In-Reply-To: <1326803609-25526-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Super-Isolate mode comes to isolate the BCM84833 PHY from the outside world.
Not doing it correctly, made link partner see the link before the driver was loaded.
This patch also involves SPIROM version fixes since it is used to determine whether the common init of the PHY was already executed, and the common init of this PHY is partially responsible for setting the Super-Isolate mode.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |  250 ++++++++++++----------
 1 files changed, 137 insertions(+), 113 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 4df9505..3b184c2 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -9266,62 +9266,68 @@ static void bnx2x_8727_link_reset(struct bnx2x_phy *phy,
 /*		BCM8481/BCM84823/BCM84833 PHY SECTION	          */
 /******************************************************************/
 static void bnx2x_save_848xx_spirom_version(struct bnx2x_phy *phy,
-					   struct link_params *params)
+					    struct bnx2x *bp,
+					    u8 port)
 {
 	u16 val, fw_ver1, fw_ver2, cnt;
-	u8 port;
-	struct bnx2x *bp = params->bp;
 
-	port = params->port;
+	if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833) {
+		bnx2x_cl45_read(bp, phy, MDIO_CTL_DEVAD, 0x400f, &fw_ver1);
+		bnx2x_save_spirom_version(bp, port,
+				((fw_ver1 & 0xf000)>>5) | (fw_ver1 & 0x7f),
+				phy->ver_addr);
+	} else {
+		/* For 32-bit registers in 848xx, access via MDIO2ARM i/f. */
+		/* (1) set reg 0xc200_0014(SPI_BRIDGE_CTRL_2) to 0x03000000 */
+		bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA819, 0x0014);
+		bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA81A, 0xc200);
+		bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA81B, 0x0000);
+		bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA81C, 0x0300);
+		bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA817, 0x0009);
+
+		for (cnt = 0; cnt < 100; cnt++) {
+			bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD, 0xA818, &val);
+			if (val & 1)
+				break;
+			udelay(5);
+		}
+		if (cnt == 100) {
+			DP(NETIF_MSG_LINK, "Unable to read 848xx "
+					"phy fw version(1)\n");
+			bnx2x_save_spirom_version(bp, port, 0,
+						  phy->ver_addr);
+			return;
+		}
 
-	/* For the 32 bits registers in 848xx, access via MDIO2ARM interface.*/
-	/* (1) set register 0xc200_0014(SPI_BRIDGE_CTRL_2) to 0x03000000 */
-	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA819, 0x0014);
-	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA81A, 0xc200);
-	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA81B, 0x0000);
-	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA81C, 0x0300);
-	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA817, 0x0009);
 
-	for (cnt = 0; cnt < 100; cnt++) {
-		bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD, 0xA818, &val);
-		if (val & 1)
-			break;
-		udelay(5);
-	}
-	if (cnt == 100) {
-		DP(NETIF_MSG_LINK, "Unable to read 848xx phy fw version(1)\n");
-		bnx2x_save_spirom_version(bp, port, 0,
-					  phy->ver_addr);
-		return;
-	}
+		/* 2) read register 0xc200_0000 (SPI_FW_STATUS) */
+		bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA819, 0x0000);
+		bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA81A, 0xc200);
+		bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA817, 0x000A);
+		for (cnt = 0; cnt < 100; cnt++) {
+			bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD, 0xA818, &val);
+			if (val & 1)
+				break;
+			udelay(5);
+		}
+		if (cnt == 100) {
+			DP(NETIF_MSG_LINK, "Unable to read 848xx phy fw "
+					"version(2)\n");
+			bnx2x_save_spirom_version(bp, port, 0,
+						  phy->ver_addr);
+			return;
+		}
 
+		/* lower 16 bits of the register SPI_FW_STATUS */
+		bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD, 0xA81B, &fw_ver1);
+		/* upper 16 bits of register SPI_FW_STATUS */
+		bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD, 0xA81C, &fw_ver2);
 
-	/* 2) read register 0xc200_0000 (SPI_FW_STATUS) */
-	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA819, 0x0000);
-	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA81A, 0xc200);
-	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA817, 0x000A);
-	for (cnt = 0; cnt < 100; cnt++) {
-		bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD, 0xA818, &val);
-		if (val & 1)
-			break;
-		udelay(5);
-	}
-	if (cnt == 100) {
-		DP(NETIF_MSG_LINK, "Unable to read 848xx phy fw version(2)\n");
-		bnx2x_save_spirom_version(bp, port, 0,
+		bnx2x_save_spirom_version(bp, port, (fw_ver2<<16) | fw_ver1,
 					  phy->ver_addr);
-		return;
 	}
 
-	/* lower 16 bits of the register SPI_FW_STATUS */
-	bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD, 0xA81B, &fw_ver1);
-	/* upper 16 bits of register SPI_FW_STATUS */
-	bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD, 0xA81C, &fw_ver2);
-
-	bnx2x_save_spirom_version(bp, port, (fw_ver2<<16) | fw_ver1,
-				  phy->ver_addr);
 }
-
 static void bnx2x_848xx_set_led(struct bnx2x *bp,
 				struct bnx2x_phy *phy)
 {
@@ -9392,10 +9398,13 @@ static int bnx2x_848xx_cmn_config_init(struct bnx2x_phy *phy,
 	u16 tmp_req_line_speed;
 
 	tmp_req_line_speed = phy->req_line_speed;
-	if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833)
+	if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833) {
 		if (phy->req_line_speed == SPEED_10000)
 			phy->req_line_speed = SPEED_AUTO_NEG;
-
+	} else {
+		/* Save spirom version */
+		bnx2x_save_848xx_spirom_version(phy, bp, params->port);
+	}
 	/*
 	 * This phy uses the NIG latch mechanism since link indication
 	 * arrives through its LED4 and not via its LASI signal, so we
@@ -9539,9 +9548,6 @@ static int bnx2x_848xx_cmn_config_init(struct bnx2x_phy *phy,
 				 MDIO_AN_REG_8481_10GBASE_T_AN_CTRL,
 				 1);
 
-	/* Save spirom version */
-	bnx2x_save_848xx_spirom_version(phy, params);
-
 	phy->req_line_speed = tmp_req_line_speed;
 
 	return 0;
@@ -9749,17 +9755,7 @@ static int bnx2x_848x3_config_init(struct bnx2x_phy *phy,
 
 	/* Wait for GPHY to come out of reset */
 	msleep(50);
-	if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833) {
-		/* Bring PHY out of super isolate mode */
-		bnx2x_cl45_read(bp, phy,
-				MDIO_CTL_DEVAD,
-				MDIO_84833_TOP_CFG_XGPHY_STRAP1, &val);
-		val &= ~MDIO_84833_SUPER_ISOLATE;
-		bnx2x_cl45_write(bp, phy,
-				MDIO_CTL_DEVAD,
-				MDIO_84833_TOP_CFG_XGPHY_STRAP1, val);
-		bnx2x_84833_pair_swap_cfg(phy, params, vars);
-	} else {
+	if (phy->type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833) {
 		/*
 		 * BCM84823 requires that XGXS links up first @ 10G for normal
 		 * behavior.
@@ -9816,24 +9812,27 @@ static int bnx2x_848x3_config_init(struct bnx2x_phy *phy,
 	DP(NETIF_MSG_LINK, "Multi_phy config = 0x%x, Media control = 0x%x\n",
 		   params->multi_phy_config, val);
 
-	/* AutogrEEEn */
-	if (params->feature_config_flags &
-		FEATURE_CONFIG_AUTOGREEEN_ENABLED)
-		cmd_args[0] = 0x2;
-	else
-		cmd_args[0] = 0x0;
+	if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833) {
+		bnx2x_84833_pair_swap_cfg(phy, params, vars);
 
-	cmd_args[1] = 0x0;
-	cmd_args[2] = PHY84833_CONSTANT_LATENCY + 1;
-	cmd_args[3] = PHY84833_CONSTANT_LATENCY;
-	rc = bnx2x_84833_cmd_hdlr(phy, params,
-		PHY84833_CMD_SET_EEE_MODE, cmd_args);
-	if (rc != 0)
-		DP(NETIF_MSG_LINK, "Cfg AutogrEEEn failed.\n");
+		/* AutogrEEEn */
+		if (params->feature_config_flags &
+			FEATURE_CONFIG_AUTOGREEEN_ENABLED)
+			cmd_args[0] = 0x2;
+		else
+			cmd_args[0] = 0x0;
+		cmd_args[1] = 0x0;
+		cmd_args[2] = PHY84833_CONSTANT_LATENCY + 1;
+		cmd_args[3] = PHY84833_CONSTANT_LATENCY;
+		rc = bnx2x_84833_cmd_hdlr(phy, params,
+			PHY84833_CMD_SET_EEE_MODE, cmd_args);
+		if (rc != 0)
+			DP(NETIF_MSG_LINK, "Cfg AutogrEEEn failed.\n");
+	}
 	if (initialize)
 		rc = bnx2x_848xx_cmn_config_init(phy, params, vars);
 	else
-		bnx2x_save_848xx_spirom_version(phy, params);
+		bnx2x_save_848xx_spirom_version(phy, bp, params->port);
 	/* 84833 PHY has a better feature and doesn't need to support this. */
 	if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84823) {
 		cms_enable = REG_RD(bp, params->shmem_base +
@@ -9851,6 +9850,16 @@ static int bnx2x_848x3_config_init(struct bnx2x_phy *phy,
 				 MDIO_CTL_REG_84823_USER_CTRL_REG, val);
 	}
 
+	if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833) {
+		/* Bring PHY out of super isolate mode as the final step. */
+		bnx2x_cl45_read(bp, phy,
+				MDIO_CTL_DEVAD,
+				MDIO_84833_TOP_CFG_XGPHY_STRAP1, &val);
+		val &= ~MDIO_84833_SUPER_ISOLATE;
+		bnx2x_cl45_write(bp, phy,
+				MDIO_CTL_DEVAD,
+				MDIO_84833_TOP_CFG_XGPHY_STRAP1, val);
+	}
 	return rc;
 }
 
@@ -9988,10 +9997,11 @@ static void bnx2x_848x3_link_reset(struct bnx2x_phy *phy,
 	} else {
 		bnx2x_cl45_read(bp, phy,
 				MDIO_CTL_DEVAD,
-				0x400f, &val16);
+				MDIO_84833_TOP_CFG_XGPHY_STRAP1, &val16);
+		val16 |= MDIO_84833_SUPER_ISOLATE;
 		bnx2x_cl45_write(bp, phy,
-				MDIO_PMA_DEVAD,
-				MDIO_PMA_REG_CTRL, 0x800);
+				 MDIO_CTL_DEVAD,
+				 MDIO_84833_TOP_CFG_XGPHY_STRAP1, val16);
 	}
 }
 
@@ -12333,55 +12343,69 @@ static int bnx2x_84833_common_init_phy(struct bnx2x *bp,
 						u32 chip_id)
 {
 	u8 reset_gpios;
-	struct bnx2x_phy phy;
-	u32 shmem_base, shmem2_base, cnt;
-	s8 port = 0;
-	u16 val;
-
 	reset_gpios = bnx2x_84833_get_reset_gpios(bp, shmem_base_path, chip_id);
 	bnx2x_set_mult_gpio(bp, reset_gpios, MISC_REGISTERS_GPIO_OUTPUT_LOW);
 	udelay(10);
 	bnx2x_set_mult_gpio(bp, reset_gpios, MISC_REGISTERS_GPIO_OUTPUT_HIGH);
 	DP(NETIF_MSG_LINK, "84833 reset pulse on pin values 0x%x\n",
 		reset_gpios);
-	for (port = PORT_MAX - 1; port >= PORT_0; port--) {
-		/* This PHY is for E2 and E3. */
-		shmem_base = shmem_base_path[port];
-		shmem2_base = shmem2_base_path[port];
-		/* Extract the ext phy address for the port */
-		if (bnx2x_populate_phy(bp, phy_index, shmem_base, shmem2_base,
-				       0, &phy) !=
-		    0) {
-			DP(NETIF_MSG_LINK, "populate_phy failed\n");
-			return -EINVAL;
-		}
+	return 0;
+}
 
-		/* Wait for FW completing its initialization. */
-		for (cnt = 0; cnt < 1000; cnt++) {
-			bnx2x_cl45_read(bp, &phy,
+static int bnx2x_84833_pre_init_phy(struct bnx2x *bp,
+					       struct bnx2x_phy *phy)
+{
+	u16 val, cnt;
+	/* Wait for FW completing its initialization. */
+	for (cnt = 0; cnt < 1500; cnt++) {
+		bnx2x_cl45_read(bp, phy,
 				MDIO_PMA_DEVAD,
 				MDIO_PMA_REG_CTRL, &val);
-			if (!(val & (1<<15)))
-				break;
-			msleep(1);
-		}
-		if (cnt >= 1000)
-			DP(NETIF_MSG_LINK,
-				"84833 Cmn reset timeout (%d)\n", port);
-
-		/* Put the port in super isolate mode. */
-		bnx2x_cl45_read(bp, &phy,
-				MDIO_CTL_DEVAD,
-				MDIO_84833_TOP_CFG_XGPHY_STRAP1, &val);
-		val |= MDIO_84833_SUPER_ISOLATE;
-		bnx2x_cl45_write(bp, &phy,
-				MDIO_CTL_DEVAD,
-				MDIO_84833_TOP_CFG_XGPHY_STRAP1, val);
+		if (!(val & (1<<15)))
+			break;
+		msleep(1);
+	}
+	if (cnt >= 1500) {
+		DP(NETIF_MSG_LINK, "84833 reset timeout\n");
+		return -EINVAL;
 	}
 
+	/* Put the port in super isolate mode. */
+	bnx2x_cl45_read(bp, phy,
+			MDIO_CTL_DEVAD,
+			MDIO_84833_TOP_CFG_XGPHY_STRAP1, &val);
+	val |= MDIO_84833_SUPER_ISOLATE;
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_CTL_DEVAD,
+			 MDIO_84833_TOP_CFG_XGPHY_STRAP1, val);
+
+	/* Save spirom version */
+	bnx2x_save_848xx_spirom_version(phy, bp, PORT_0);
 	return 0;
 }
 
+int bnx2x_pre_init_phy(struct bnx2x *bp,
+				  u32 shmem_base,
+				  u32 shmem2_base,
+				  u32 chip_id)
+{
+	int rc = 0;
+	struct bnx2x_phy phy;
+	bnx2x_set_mdio_clk(bp, chip_id, PORT_0);
+	if (bnx2x_populate_phy(bp, EXT_PHY1, shmem_base, shmem2_base,
+			       PORT_0, &phy)) {
+		DP(NETIF_MSG_LINK, "populate_phy failed\n");
+		return -EINVAL;
+	}
+	switch (phy.type) {
+	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833:
+		rc = bnx2x_84833_pre_init_phy(bp, &phy);
+		break;
+	default:
+		break;
+	}
+	return rc;
+}
 
 static int bnx2x_ext_phy_common_init(struct bnx2x *bp, u32 shmem_base_path[],
 				     u32 shmem2_base_path[], u8 phy_index,
-- 
1.7.7.1
