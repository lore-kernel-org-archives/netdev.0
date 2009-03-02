From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 10/18] bnx2x: Supporting new BCM8726 FW
Date: Mon, 02 Mar 2009 20:00:03 +0200
Message-ID: <1236016803.7723.81.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Yaniv Rosner" <yanivr@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2740 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755851AbZCBSBE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2009 13:01:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 10/18] bnx2x: Supporting new BCM8726 FW

Microcode download requires write of another register and read from
"Limiting/LRM mode" register before setting

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_link.c |   30 +++++++++++++++++++-----------
 drivers/net/bnx2x_reg.h  |    1 +
 2 files changed, 20 insertions(+), 11 deletions(-)

diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index 73b52f1..35f3b5a 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -2258,6 +2258,11 @@ static void bnx2x_bcm8726_external_rom_boot(struct link_params *params)
 		       MDIO_PMA_REG_GEN_CTRL,
 		       MDIO_PMA_REG_GEN_CTRL_ROM_MICRO_RESET);
 
+	bnx2x_cl45_write(bp, port, ext_phy_type, ext_phy_addr,
+		       MDIO_PMA_DEVAD,
+		       MDIO_PMA_REG_GEN_CTRL2,
+		       0x73A0);
+
 	/* Clear soft reset.
 	Will automatically reset micro-controller re-boot */
 	bnx2x_cl45_write(bp, port, ext_phy_type, ext_phy_addr,
@@ -2265,8 +2270,8 @@ static void bnx2x_bcm8726_external_rom_boot(struct link_params *params)
 		       MDIO_PMA_REG_GEN_CTRL,
 		       MDIO_PMA_REG_GEN_CTRL_ROM_RESET_INTERNAL_MP);
 
-	/* wait for 100ms for microcode load */
-	msleep(100);
+	/* wait for 150ms for microcode load */
+	msleep(150);
 
 	/* Disable serial boot control, tristates pins SS_N, SCK, MOSI, MISO */
 	bnx2x_cl45_write(bp, port, ext_phy_type, ext_phy_addr,
@@ -2524,7 +2529,7 @@ static u8 bnx2x_bcm8726_set_limiting_mode(struct link_params *params,
 	u8 ext_phy_addr = ((params->ext_phy_config &
 			    PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
 			   PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
-
+	u16 cur_limiting_mode;
 	if (bnx2x_read_sfp_module_eeprom(params,
 				       SFP_EEPROM_OPTIONS_ADDR,
 				       SFP_EEPROM_OPTIONS_SIZE,
@@ -2535,6 +2540,16 @@ static u8 bnx2x_bcm8726_set_limiting_mode(struct link_params *params,
 	}
 	limiting_mode = !(options[0] &
 			  SFP_EEPROM_OPTIONS_LINEAR_RX_OUT_MASK);
+
+	bnx2x_cl45_read(bp, port,
+		      PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726,
+		      ext_phy_addr,
+		      MDIO_PMA_DEVAD,
+		      MDIO_PMA_REG_ROM_VER2,
+		      &cur_limiting_mode);
+	DP(NETIF_MSG_LINK, "Current Limiting mode is 0x%x\n",
+		 cur_limiting_mode);
+
 	if (limiting_mode &&
 	    (module_type != SFP_MODULE_TYPE_PASSIVE_COPPER_CABLE)) {
 		DP(NETIF_MSG_LINK,
@@ -2547,17 +2562,10 @@ static u8 bnx2x_bcm8726_set_limiting_mode(struct link_params *params,
 			       MDIO_PMA_REG_ROM_VER2,
 			       SFP_LIMITING_MODE_VALUE);
 	} else { /* LRM mode ( default )*/
-		u16 cur_limiting_mode;
+
 		DP(NETIF_MSG_LINK, "Module options = 0x%x.Setting LRM MODE\n",
 			 options[0]);
 
-		bnx2x_cl45_read(bp, port,
-			       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726,
-			       ext_phy_addr,
-			       MDIO_PMA_DEVAD,
-			       MDIO_PMA_REG_ROM_VER2,
-			       &cur_limiting_mode);
-
 		/* Changing to LRM mode takes quite few seconds.
 		So do it only if current mode is limiting
 		( default is LRM )*/
diff --git a/drivers/net/bnx2x_reg.h b/drivers/net/bnx2x_reg.h
index 8de80cc..b8ce6fc 100644
--- a/drivers/net/bnx2x_reg.h
+++ b/drivers/net/bnx2x_reg.h
@@ -5843,6 +5843,7 @@ Theotherbitsarereservedandshouldbezero*/
 #define MDIO_PMA_REG_ROM_VER2		0xca1a
 #define MDIO_PMA_REG_EDC_FFE_MAIN	0xca1b
 #define MDIO_PMA_REG_PLL_BANDWIDTH	0xca1d
+#define MDIO_PMA_REG_GEN_CTRL2		0xca1e
 #define MDIO_PMA_REG_MISC_CTRL0 	0xca23
 #define MDIO_PMA_REG_LRM_MODE		0xca3f
 #define MDIO_PMA_REG_CDR_BANDWIDTH	0xca46
-- 
1.5.4.3




