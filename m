From: "Yaniv Rosner" <yaniv.rosner@broadcom.com>
Subject: [PATCH net-next 03/10] bnx2x: Adjust alignment of split PHY
 functions
Date: Wed, 8 Sep 2010 00:40:58 +0300
Message-ID: <1283895658.5452.63.camel@lb-tlvb-yanivr.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3059 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932436Ab0IGSXD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Sep 2010 14:23:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In previous patch, common PHY functions were split in simple way to
allow easy diff. This patch comes to align code in the new functions. 
In addition, the non-production BCM8072 PHY was removed. 

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com> 
---
 drivers/net/bnx2x/bnx2x_link.c | 2164 +++++++++++++++++-----------------------
 drivers/net/bnx2x/bnx2x_main.c |    1 -
 2 files changed, 894 insertions(+), 1271 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index 1da8f81..758ded4 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -2096,7 +2096,7 @@ void bnx2x_ext_phy_hw_reset(struct bnx2x *bp, u8 port)
 		       MISC_REGISTERS_GPIO_OUTPUT_LOW, port);
 	msleep(1);
 	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1,
-		      MISC_REGISTERS_GPIO_OUTPUT_HIGH, port);
+		       MISC_REGISTERS_GPIO_OUTPUT_HIGH, port);
 }
 
 static void bnx2x_save_spirom_version(struct bnx2x *bp, u8 port,
@@ -2133,30 +2133,14 @@ static void bnx2x_save_8481_spirom_version(struct bnx2x_phy *phy,
 
 	/* For the 32 bits registers in 848xx, access via MDIO2ARM interface.*/
 	/* (1) set register 0xc200_0014(SPI_BRIDGE_CTRL_2) to 0x03000000 */
-	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD,
-		       0xA819, 0x0014);
-	bnx2x_cl45_write(bp, phy,
-		       MDIO_PMA_DEVAD,
-		       0xA81A,
-		       0xc200);
-	bnx2x_cl45_write(bp, phy,
-		       MDIO_PMA_DEVAD,
-		       0xA81B,
-		       0x0000);
-	bnx2x_cl45_write(bp, phy,
-		       MDIO_PMA_DEVAD,
-		       0xA81C,
-		       0x0300);
-	bnx2x_cl45_write(bp, phy,
-		       MDIO_PMA_DEVAD,
-		       0xA817,
-		       0x0009);
+	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA819, 0x0014);
+	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA81A, 0xc200);
+	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA81B, 0x0000);
+	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA81C, 0x0300);
+	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA817, 0x0009);
 
 	for (cnt = 0; cnt < 100; cnt++) {
-		bnx2x_cl45_read(bp, phy,
-			      MDIO_PMA_DEVAD,
-			      0xA818,
-			      &val);
+		bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD, 0xA818, &val);
 		if (val & 1)
 			break;
 		udelay(5);
@@ -2170,86 +2154,29 @@ static void bnx2x_save_8481_spirom_version(struct bnx2x_phy *phy,
 

 	/* 2) read register 0xc200_0000 (SPI_FW_STATUS) */
-	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD,
-		       0xA819, 0x0000);
-	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD,
-		       0xA81A, 0xc200);
-	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD,
-		       0xA817, 0x000A);
+	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA819, 0x0000);
+	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA81A, 0xc200);
+	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA817, 0x000A);
 	for (cnt = 0; cnt < 100; cnt++) {
-		bnx2x_cl45_read(bp, phy,
-			      MDIO_PMA_DEVAD,
-			      0xA818,
-			      &val);
+		bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD, 0xA818, &val);
 		if (val & 1)
 			break;
 		udelay(5);
 	}
 	if (cnt == 100) {
-		DP(NETIF_MSG_LINK, "Unable to read 8481 phy fw version(2)\n");
-		bnx2x_save_spirom_version(bp, params->port,
-					shmem_base, 0);
+		DP(NETIF_MSG_LINK, "Unable to read 848xx phy fw version(2)\n");
+		bnx2x_save_spirom_version(bp, params->port, 0,
+					  phy->ver_addr);
 		return;
 	}
 
 	/* lower 16 bits of the register SPI_FW_STATUS */
-	bnx2x_cl45_read(bp, phy,
-		      MDIO_PMA_DEVAD,
-		      0xA81B,
-		      &fw_ver1);
+	bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD, 0xA81B, &fw_ver1);
 	/* upper 16 bits of register SPI_FW_STATUS */
-	bnx2x_cl45_read(bp, phy,
-		      MDIO_PMA_DEVAD,
-		      0xA81C,
-		      &fw_ver2);
-
-	bnx2x_save_spirom_version(bp, params->port,
-				shmem_base, (fw_ver2<<16) | fw_ver1);
-}
-
-static void bnx2x_bcm8072_external_rom_boot(struct bnx2x_phy *phy,
-					    struct link_params *params)
-{
-	struct bnx2x *bp = params->bp;
-	u8 port = params->port;
-
-	/* Need to wait 200ms after reset */
-	msleep(200);
-	/* Boot port from external ROM
-	 * Set ser_boot_ctl bit in the MISC_CTRL1 register
-	 */
-	bnx2x_cl45_write(bp, phy,
-			    MDIO_PMA_DEVAD,
-			    MDIO_PMA_REG_MISC_CTRL1, 0x0001);
+	bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD, 0xA81C, &fw_ver2);
 
-	/* Reset internal microprocessor */
-	bnx2x_cl45_write(bp, phy,
-			  MDIO_PMA_DEVAD,
-			  MDIO_PMA_REG_GEN_CTRL,
-			  MDIO_PMA_REG_GEN_CTRL_ROM_RESET_INTERNAL_MP);
-	/* set micro reset = 0 */
-	bnx2x_cl45_write(bp, phy,
-			    MDIO_PMA_DEVAD,
-			    MDIO_PMA_REG_GEN_CTRL,
-			    MDIO_PMA_REG_GEN_CTRL_ROM_MICRO_RESET);
-	/* Reset internal microprocessor */
-	bnx2x_cl45_write(bp, phy,
-			  MDIO_PMA_DEVAD,
-			  MDIO_PMA_REG_GEN_CTRL,
-			  MDIO_PMA_REG_GEN_CTRL_ROM_RESET_INTERNAL_MP);
-	/* wait for 100ms for code download via SPI port */
-	msleep(100);
-
-	/* Clear ser_boot_ctl bit */
-	bnx2x_cl45_write(bp, phy,
-			    MDIO_PMA_DEVAD,
-			    MDIO_PMA_REG_MISC_CTRL1, 0x0000);
-	/* Wait 100ms */
-	msleep(100);
-
-	bnx2x_save_bcm_spirom_ver(bp, port,
-				phy,
-				params->shmem_base);
+	bnx2x_save_spirom_version(bp, params->port, (fw_ver2<<16) | fw_ver1,
+				  phy->ver_addr);
 }
 
 static u8 bnx2x_8073_is_snr_needed(struct bnx2x *bp, struct bnx2x_phy *phy)
@@ -2382,9 +2309,7 @@ static void bnx2x_8726_external_rom_boot(struct bnx2x_phy *phy,
 
 	/* Micro controller re-boot */
 	bnx2x_cl45_write(bp, phy,
-		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_GEN_CTRL,
-		       0x018B);
+			 MDIO_PMA_DEVAD, MDIO_PMA_REG_GEN_CTRL, 0x018B);
 
 	/* Set soft reset */
 	bnx2x_cl45_write(bp, phy,
@@ -2614,10 +2539,11 @@ static u8 bnx2x_get_edc_mode(struct bnx2x_phy *phy,
 	*edc_mode = EDC_MODE_LIMITING;
 
 	/* First check for copper cable */
-	if (bnx2x_read_sfp_module_eeprom(phy, params,
-				       SFP_EEPROM_CON_TYPE_ADDR,
-				       1,
-				       &val) != 0) {
+	if (bnx2x_read_sfp_module_eeprom(phy,
+					 params,
+					 SFP_EEPROM_CON_TYPE_ADDR,
+					 1,
+					 &val) != 0) {
 		DP(NETIF_MSG_LINK, "Failed to read from SFP+ module EEPROM\n");
 		return -EINVAL;
 	}
@@ -2629,7 +2555,8 @@ static u8 bnx2x_get_edc_mode(struct bnx2x_phy *phy,
 
 		/* Check if its active cable( includes SFP+ module)
 		of passive cable*/
-		if (bnx2x_read_sfp_module_eeprom(phy, params,
+		if (bnx2x_read_sfp_module_eeprom(phy,
+					       params,
 					       SFP_EEPROM_FC_TX_TECH_ADDR,
 					       1,
 					       &copper_module_type) !=
@@ -2669,10 +2596,11 @@ static u8 bnx2x_get_edc_mode(struct bnx2x_phy *phy,
 
 	if (check_limiting_mode) {
 		u8 options[SFP_EEPROM_OPTIONS_SIZE];
-		if (bnx2x_read_sfp_module_eeprom(phy, params,
-					       SFP_EEPROM_OPTIONS_ADDR,
-					       SFP_EEPROM_OPTIONS_SIZE,
-					       options) != 0) {
+		if (bnx2x_read_sfp_module_eeprom(phy,
+						 params,
+						 SFP_EEPROM_OPTIONS_ADDR,
+						 SFP_EEPROM_OPTIONS_SIZE,
+						 options) != 0) {
 			DP(NETIF_MSG_LINK, "Failed to read Option"
 				" field from module EEPROM\n");
 			return -EINVAL;
@@ -2720,14 +2648,16 @@ static u8 bnx2x_verify_sfp_module(struct bnx2x_phy *phy,
 	}
 
 	/* format the warning message */
-	if (bnx2x_read_sfp_module_eeprom(phy, params,
+	if (bnx2x_read_sfp_module_eeprom(phy,
+					 params,
 				       SFP_EEPROM_VENDOR_NAME_ADDR,
 				       SFP_EEPROM_VENDOR_NAME_SIZE,
 				       (u8 *)vendor_name))
 		vendor_name[0] = '\0';
 	else
 		vendor_name[SFP_EEPROM_VENDOR_NAME_SIZE] = '\0';
-	if (bnx2x_read_sfp_module_eeprom(phy, params,
+	if (bnx2x_read_sfp_module_eeprom(phy,
+					 params,
 				       SFP_EEPROM_PART_NO_ADDR,
 				       SFP_EEPROM_PART_NO_SIZE,
 				       (u8 *)vendor_pn))
@@ -2743,7 +2673,7 @@ static u8 bnx2x_verify_sfp_module(struct bnx2x_phy *phy,
 
 static u8 bnx2x_8726_set_limiting_mode(struct bnx2x *bp,
 				       struct bnx2x_phy *phy,
-					u16 edc_mode)
+				       u16 edc_mode)
 {
 	u16 cur_limiting_mode;
 
@@ -2758,9 +2688,9 @@ static u8 bnx2x_8726_set_limiting_mode(struct bnx2x *bp,
 		DP(NETIF_MSG_LINK,
 			 "Setting LIMITING MODE\n");
 		bnx2x_cl45_write(bp, phy,
-			       MDIO_PMA_DEVAD,
-			       MDIO_PMA_REG_ROM_VER2,
-			       EDC_MODE_LIMITING);
+				 MDIO_PMA_DEVAD,
+				 MDIO_PMA_REG_ROM_VER2,
+				 EDC_MODE_LIMITING);
 	} else { /* LRM mode ( default )*/
 
 		DP(NETIF_MSG_LINK, "Setting LRM MODE\n");
@@ -2848,7 +2778,6 @@ static u8 bnx2x_wait_for_sfp_module_initialized(struct bnx2x_phy *phy,
 }
 
 static void bnx2x_8727_power_module(struct bnx2x *bp,
-				  struct link_params *params,
 				    struct bnx2x_phy *phy,
 				    u8 is_power_up) {
 	/* Make sure GPIOs are not using for LED mode */
@@ -2880,9 +2809,9 @@ static void bnx2x_8727_power_module(struct bnx2x *bp,
 		val = ((!(is_power_up)) << 1);
 
 	bnx2x_cl45_write(bp, phy,
-		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_8727_GPIO_CTRL,
-		       val);
+			 MDIO_PMA_DEVAD,
+			 MDIO_PMA_REG_8727_GPIO_CTRL,
+			 val);
 }
 
 static u8 bnx2x_sfp_module_detection(struct bnx2x_phy *phy,
@@ -2916,7 +2845,7 @@ static u8 bnx2x_sfp_module_detection(struct bnx2x_phy *phy,
 		     PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_POWER_DOWN)) {
 			/* Shutdown SFP+ module */
 			DP(NETIF_MSG_LINK, "Shutdown SFP+ module!!\n");
-			bnx2x_8727_power_module(bp, params, phy, 0);
+			bnx2x_8727_power_module(bp, phy, 0);
 			return rc;
 		}
 	} else {
@@ -2929,7 +2858,7 @@ static u8 bnx2x_sfp_module_detection(struct bnx2x_phy *phy,
 
 	/* power up the SFP module */
 	if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727)
-		bnx2x_8727_power_module(bp, params, phy, 1);
+		bnx2x_8727_power_module(bp, phy, 1);
 
 	/* Check and set limiting mode / LRM mode on 8726.
 	On 8727 it is done automatically */
@@ -2984,8 +2913,8 @@ void bnx2x_handle_module_detect_int(struct link_params *params)
 					      config));
 
 		bnx2x_set_gpio_int(bp, MISC_REGISTERS_GPIO_3,
-				      MISC_REGISTERS_GPIO_INT_OUTPUT_SET,
-				      port);
+				   MISC_REGISTERS_GPIO_INT_OUTPUT_SET,
+				   port);
 		/* Module was plugged out. */
 		/* Disable transmit for this module */
 		if ((val & PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_MASK) ==
@@ -2998,21 +2927,13 @@ static void bnx2x_807x_force_10G(struct bnx2x *bp, struct bnx2x_phy *phy)
 {
 	/* Force KR or KX */
 	bnx2x_cl45_write(bp, phy,
-		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_CTRL,
-		       0x2040);
+			 MDIO_PMA_DEVAD, MDIO_PMA_REG_CTRL, 0x2040);
 	bnx2x_cl45_write(bp, phy,
-		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_10G_CTRL2,
-		       0x000b);
+			 MDIO_PMA_DEVAD, MDIO_PMA_REG_10G_CTRL2, 0x000b);
 	bnx2x_cl45_write(bp, phy,
-		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_BCM_CTRL,
-		       0x0000);
+			 MDIO_PMA_DEVAD, MDIO_PMA_REG_BCM_CTRL, 0x0000);
 	bnx2x_cl45_write(bp, phy,
-		       MDIO_AN_DEVAD,
-		       MDIO_AN_REG_CTRL,
-		       0x0000);
+			 MDIO_AN_DEVAD, MDIO_AN_REG_CTRL, 0x0000);
 }
 
 static void bnx2x_8073_set_xaui_low_power_mode(struct bnx2x *bp,
@@ -3020,8 +2941,7 @@ static void bnx2x_8073_set_xaui_low_power_mode(struct bnx2x *bp,
 {
 	u16 val;
 	bnx2x_cl45_read(bp, phy,
-		      MDIO_PMA_DEVAD,
-		      MDIO_PMA_REG_8073_CHIP_REV, &val);
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_8073_CHIP_REV, &val);
 
 	if (val == 0) {
 		/* Mustn't set low power mode in 8073 A0 */
@@ -3030,47 +2950,32 @@ static void bnx2x_8073_set_xaui_low_power_mode(struct bnx2x *bp,
 
 	/* Disable PLL sequencer (use read-modify-write to clear bit 13) */
 	bnx2x_cl45_read(bp, phy,
-		       MDIO_XS_DEVAD,
-		       MDIO_XS_PLL_SEQUENCER, &val);
+			MDIO_XS_DEVAD, MDIO_XS_PLL_SEQUENCER, &val);
 	val &= ~(1<<13);
 	bnx2x_cl45_write(bp, phy,
 		       MDIO_XS_DEVAD, MDIO_XS_PLL_SEQUENCER, val);
 
 	/* PLL controls */
-	bnx2x_cl45_write(bp, phy,
-		       MDIO_XS_DEVAD, 0x805E, 0x1077);
-	bnx2x_cl45_write(bp, phy,
-		       MDIO_XS_DEVAD, 0x805D, 0x0000);
-	bnx2x_cl45_write(bp, phy,
-		       MDIO_XS_DEVAD, 0x805C, 0x030B);
-	bnx2x_cl45_write(bp, phy,
-		       MDIO_XS_DEVAD, 0x805B, 0x1240);
-	bnx2x_cl45_write(bp, phy,
-		       MDIO_XS_DEVAD, 0x805A, 0x2490);
+	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, 0x805E, 0x1077);
+	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, 0x805D, 0x0000);
+	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, 0x805C, 0x030B);
+	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, 0x805B, 0x1240);
+	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, 0x805A, 0x2490);
 
 	/* Tx Controls */
-	bnx2x_cl45_write(bp, phy,
-		       MDIO_XS_DEVAD, 0x80A7, 0x0C74);
-	bnx2x_cl45_write(bp, phy,
-		       MDIO_XS_DEVAD, 0x80A6, 0x9041);
-	bnx2x_cl45_write(bp, phy,
-		       MDIO_XS_DEVAD, 0x80A5, 0x4640);
+	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, 0x80A7, 0x0C74);
+	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, 0x80A6, 0x9041);
+	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, 0x80A5, 0x4640);
 
 	/* Rx Controls */
-	bnx2x_cl45_write(bp, phy,
-		       MDIO_XS_DEVAD, 0x80FE, 0x01C4);
-	bnx2x_cl45_write(bp, phy,
-		       MDIO_XS_DEVAD, 0x80FD, 0x9249);
-	bnx2x_cl45_write(bp, phy,
-		       MDIO_XS_DEVAD, 0x80FC, 0x2015);
+	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, 0x80FE, 0x01C4);
+	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, 0x80FD, 0x9249);
+	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, 0x80FC, 0x2015);
 
 	/* Enable PLL sequencer  (use read-modify-write to set bit 13) */
-	bnx2x_cl45_read(bp, phy,
-		       MDIO_XS_DEVAD,
-		       MDIO_XS_PLL_SEQUENCER, &val);
+	bnx2x_cl45_read(bp, phy, MDIO_XS_DEVAD, MDIO_XS_PLL_SEQUENCER, &val);
 	val |= (1<<13);
-	bnx2x_cl45_write(bp, phy,
-		       MDIO_XS_DEVAD, MDIO_XS_PLL_SEQUENCER, val);
+	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, MDIO_XS_PLL_SEQUENCER, val);
 }
 
 static void bnx2x_8073_set_pause_cl37(struct link_params *params,
@@ -3080,8 +2985,7 @@ static void bnx2x_8073_set_pause_cl37(struct link_params *params,
 	u16 cl37_val;
 	struct bnx2x *bp = params->bp;
 	bnx2x_cl45_read(bp, phy,
-		      MDIO_AN_DEVAD,
-		      MDIO_AN_REG_CL37_FC_LD, &cl37_val);
+			MDIO_AN_DEVAD, MDIO_AN_REG_CL37_FC_LD, &cl37_val);
 
 	cl37_val &= ~MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH;
 	/* Please refer to Table 28B-3 of 802.3ab-1999 spec. */
@@ -3105,8 +3009,7 @@ static void bnx2x_8073_set_pause_cl37(struct link_params *params,
 		 "Ext phy AN advertize cl37 0x%x\n", cl37_val);
 
 	bnx2x_cl45_write(bp, phy,
-		       MDIO_AN_DEVAD,
-		       MDIO_AN_REG_CL37_FC_LD, cl37_val);
+			 MDIO_AN_DEVAD, MDIO_AN_REG_CL37_FC_LD, cl37_val);
 	msleep(500);
 }
 
@@ -3117,9 +3020,7 @@ static void bnx2x_ext_phy_set_pause(struct link_params *params,
 	u16 val;
 	struct bnx2x *bp = params->bp;
 	/* read modify write pause advertizing */
-	bnx2x_cl45_read(bp, phy,
-		      MDIO_AN_DEVAD,
-		      MDIO_AN_REG_ADV_PAUSE, &val);
+	bnx2x_cl45_read(bp, phy, MDIO_AN_DEVAD, MDIO_AN_REG_ADV_PAUSE, &val);
 
 	val &= ~MDIO_AN_REG_ADV_PAUSE_BOTH;
 
@@ -3133,14 +3034,10 @@ static void bnx2x_ext_phy_set_pause(struct link_params *params,
 	if ((vars->ieee_fc &
 	    MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH) ==
 	    MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH) {
-		val |=
-		 MDIO_AN_REG_ADV_PAUSE_PAUSE;
+		val |= MDIO_AN_REG_ADV_PAUSE_PAUSE;
 	}
-	DP(NETIF_MSG_LINK,
-		 "Ext phy AN advertize 0x%x\n", val);
-	bnx2x_cl45_write(bp, phy,
-		       MDIO_AN_DEVAD,
-		       MDIO_AN_REG_ADV_PAUSE, val);
+	DP(NETIF_MSG_LINK, "Ext phy AN advertize 0x%x\n", val);
+	bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD, MDIO_AN_REG_ADV_PAUSE, val);
 }
 
 static void bnx2x_set_preemphasis(struct bnx2x_phy *phy,
@@ -3153,16 +3050,16 @@ static void bnx2x_set_preemphasis(struct bnx2x_phy *phy,
 	for (bank = MDIO_REG_BANK_RX0, i = 0; bank <= MDIO_REG_BANK_RX3;
 	      bank += (MDIO_REG_BANK_RX1-MDIO_REG_BANK_RX0), i++) {
 			CL45_WR_OVER_CL22(bp, phy,
-					      bank,
-					      MDIO_RX0_RX_EQ_BOOST,
+					  bank,
+					  MDIO_RX0_RX_EQ_BOOST,
 					  phy->rx_preemphasis[i]);
 	}
 
 	for (bank = MDIO_REG_BANK_TX0, i = 0; bank <= MDIO_REG_BANK_TX3;
 		      bank += (MDIO_REG_BANK_TX1 - MDIO_REG_BANK_TX0), i++) {
 			CL45_WR_OVER_CL22(bp, phy,
-					      bank,
-					      MDIO_TX0_TX_DRIVER,
+					  bank,
+					  MDIO_TX0_TX_DRIVER,
 					  phy->tx_preemphasis[i]);
 	}
 }
@@ -3257,18 +3154,16 @@ static u16 bnx2x_wait_reset_complete(struct bnx2x *bp,
 				     struct bnx2x_phy *phy)
 {
 	u16 cnt, ctrl;
-			/* Wait for soft reset to get cleared upto 1 sec */
-			for (cnt = 0; cnt < 1000; cnt++) {
-				bnx2x_cl45_read(bp, phy,
-					      MDIO_PMA_DEVAD,
-					      MDIO_PMA_REG_CTRL, &ctrl);
-				if (!(ctrl & (1<<15)))
-					break;
-				msleep(1);
-			}
-			DP(NETIF_MSG_LINK, "control reg 0x%x (after %d ms)\n",
-				 ctrl, cnt);
-			return 0;
+	/* Wait for soft reset to get cleared upto 1 sec */
+	for (cnt = 0; cnt < 1000; cnt++) {
+		bnx2x_cl45_read(bp, phy,
+				MDIO_PMA_DEVAD, MDIO_PMA_REG_CTRL, &ctrl);
+		if (!(ctrl & (1<<15)))
+			break;
+		msleep(1);
+	}
+	DP(NETIF_MSG_LINK, "control reg 0x%x (after %d ms)\n", ctrl, cnt);
+	return cnt;
 }
 
 static u8 bnx2x_8705_config_init(struct bnx2x_phy *phy,
@@ -3284,29 +3179,18 @@ static u8 bnx2x_8705_config_init(struct bnx2x_phy *phy,
 	bnx2x_ext_phy_hw_reset(bp, params->port);
 	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, MDIO_PMA_REG_CTRL, 0xa040);
 	bnx2x_wait_reset_complete(bp, phy);
-			DP(NETIF_MSG_LINK, "XGXS 8705\n");
-
-			bnx2x_cl45_write(bp, phy,
-				       MDIO_PMA_DEVAD,
-				       MDIO_PMA_REG_MISC_CTRL,
-				       0x8288);
-			bnx2x_cl45_write(bp, phy,
-				       MDIO_PMA_DEVAD,
-				       MDIO_PMA_REG_PHY_IDENTIFIER,
-				       0x7fbf);
-			bnx2x_cl45_write(bp, phy,
-				       MDIO_PMA_DEVAD,
-				       MDIO_PMA_REG_CMU_PLL_BYPASS,
-				       0x0100);
-			bnx2x_cl45_write(bp, phy,
-				       MDIO_WIS_DEVAD,
-				       MDIO_WIS_REG_LASI_CNTL, 0x1);
 
-			/* BCM8705 doesn't have microcode, hence the 0 */
-			bnx2x_save_spirom_version(bp, params->port,
-						params->shmem_base, 0);
-
-			return 0;
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_PMA_DEVAD, MDIO_PMA_REG_MISC_CTRL, 0x8288);
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_PMA_DEVAD, MDIO_PMA_REG_PHY_IDENTIFIER, 0x7fbf);
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_PMA_DEVAD, MDIO_PMA_REG_CMU_PLL_BYPASS, 0x0100);
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_WIS_DEVAD, MDIO_WIS_REG_LASI_CNTL, 0x1);
+	/* BCM8705 doesn't have microcode, hence the 0 */
+	bnx2x_save_spirom_version(bp, params->port, params->shmem_base, 0);
+	return 0;
 }
 
 static u8 bnx2x_8706_config_init(struct bnx2x_phy *phy,
@@ -3322,95 +3206,73 @@ static u8 bnx2x_8706_config_init(struct bnx2x_phy *phy,
 	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, MDIO_PMA_REG_CTRL, 0xa040);
 
 	bnx2x_wait_reset_complete(bp, phy);
-			/* Wait until fw is loaded */
-			for (cnt = 0; cnt < 100; cnt++) {
-				bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD,
-					      MDIO_PMA_REG_ROM_VER1, &val);
-				if (val)
-					break;
-				msleep(10);
-			}
-			DP(NETIF_MSG_LINK, "XGXS 8706 is initialized "
-				"after %d ms\n", cnt);
-			if ((params->feature_config_flags &
-			     FEATURE_CONFIG_OVERRIDE_PREEMPHASIS_ENABLED)) {
-				u8 i;
-				u16 reg;
-				for (i = 0; i < 4; i++) {
-					reg = MDIO_XS_8706_REG_BANK_RX0 +
-						i*(MDIO_XS_8706_REG_BANK_RX1 -
-						   MDIO_XS_8706_REG_BANK_RX0);
-					bnx2x_cl45_read(bp, phy,
-						      MDIO_XS_DEVAD,
-						      reg, &val);
-					/* Clear first 3 bits of the control */
-					val &= ~0x7;
-					/* Set control bits according to
-					configuation */
-					val |= (phy->rx_preemphasis[i] &
-						0x7);
-					DP(NETIF_MSG_LINK, "Setting RX"
-						 "Equalizer to BCM8706 reg 0x%x"
-						 " <-- val 0x%x\n", reg, val);
-					bnx2x_cl45_write(bp, phy,
-						       MDIO_XS_DEVAD,
-						       reg, val);
-				}
-			}
-			/* Force speed */
-			if (params->req_line_speed == SPEED_10000) {
-				DP(NETIF_MSG_LINK, "XGXS 8706 force 10Gbps\n");
-
-				bnx2x_cl45_write(bp, phy,
-					       MDIO_PMA_DEVAD,
-					       MDIO_PMA_REG_DIGITAL_CTRL,
-					       0x400);
-				bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD,
-					       MDIO_PMA_REG_LASI_CTRL, 1);
-			} else {
-				/* Force 1Gbps using autoneg with 1G
-				advertisment */
-
-				/* Allow CL37 through CL73 */
-				DP(NETIF_MSG_LINK, "XGXS 8706 AutoNeg\n");
-				bnx2x_cl45_write(bp, phy,
-					       MDIO_AN_DEVAD,
-					       MDIO_AN_REG_CL37_CL73,
-					       0x040c);
-
-				/* Enable Full-Duplex advertisment on CL37 */
-				bnx2x_cl45_write(bp, phy,
-					       MDIO_AN_DEVAD,
-					       MDIO_AN_REG_CL37_FC_LP,
-					       0x0020);
-				/* Enable CL37 AN */
-				bnx2x_cl45_write(bp, phy,
-					       MDIO_AN_DEVAD,
-					       MDIO_AN_REG_CL37_AN,
-					       0x1000);
-				/* 1G support */
-				bnx2x_cl45_write(bp, phy,
-					       MDIO_AN_DEVAD,
-					       MDIO_AN_REG_ADV, (1<<5));
-
-				/* Enable clause 73 AN */
-				bnx2x_cl45_write(bp, phy,
-					       MDIO_AN_DEVAD,
-					       MDIO_AN_REG_CTRL,
-					       0x1200);
-				bnx2x_cl45_write(bp, phy,
-					       MDIO_PMA_DEVAD,
-					       MDIO_PMA_REG_RX_ALARM_CTRL,
-					       0x0400);
-				bnx2x_cl45_write(bp, phy,
-					       MDIO_PMA_DEVAD,
-					       MDIO_PMA_REG_LASI_CTRL, 0x0004);
 
-			}
-			bnx2x_save_bcm_spirom_ver(bp, params->port,
-						phy,
-						params->shmem_base);
-			return 0;
+	/* Wait until fw is loaded */
+	for (cnt = 0; cnt < 100; cnt++) {
+		bnx2x_cl45_read(bp, phy,
+				MDIO_PMA_DEVAD, MDIO_PMA_REG_ROM_VER1, &val);
+		if (val)
+			break;
+		msleep(10);
+	}
+	DP(NETIF_MSG_LINK, "XGXS 8706 is initialized after %d ms\n", cnt);
+	if ((params->feature_config_flags &
+	     FEATURE_CONFIG_OVERRIDE_PREEMPHASIS_ENABLED)) {
+		u8 i;
+		u16 reg;
+		for (i = 0; i < 4; i++) {
+			reg = MDIO_XS_8706_REG_BANK_RX0 +
+				i*(MDIO_XS_8706_REG_BANK_RX1 -
+				   MDIO_XS_8706_REG_BANK_RX0);
+			bnx2x_cl45_read(bp, phy, MDIO_XS_DEVAD, reg, &val);
+			/* Clear first 3 bits of the control */
+			val &= ~0x7;
+			/* Set control bits according to configuration */
+			val |= (phy->rx_preemphasis[i] & 0x7);
+			DP(NETIF_MSG_LINK, "Setting RX Equalizer to BCM8706"
+				   " reg 0x%x <-- val 0x%x\n", reg, val);
+			bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, reg, val);
+		}
+	}
+	/* Force speed */
+	if (phy->req_line_speed == SPEED_10000) {
+		DP(NETIF_MSG_LINK, "XGXS 8706 force 10Gbps\n");
+
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_PMA_DEVAD,
+				 MDIO_PMA_REG_DIGITAL_CTRL, 0x400);
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_PMA_DEVAD, MDIO_PMA_REG_LASI_CTRL, 1);
+	} else {
+		/* Force 1Gbps using autoneg with 1G advertisment */
+
+		/* Allow CL37 through CL73 */
+		DP(NETIF_MSG_LINK, "XGXS 8706 AutoNeg\n");
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_AN_DEVAD, MDIO_AN_REG_CL37_CL73, 0x040c);
+
+		/* Enable Full-Duplex advertisment on CL37 */
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_AN_DEVAD, MDIO_AN_REG_CL37_FC_LP, 0x0020);
+		/* Enable CL37 AN */
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_AN_DEVAD, MDIO_AN_REG_CL37_AN, 0x1000);
+		/* 1G support */
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_AN_DEVAD, MDIO_AN_REG_ADV, (1<<5));
+
+		/* Enable clause 73 AN */
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_AN_DEVAD, MDIO_AN_REG_CTRL, 0x1200);
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_PMA_DEVAD, MDIO_PMA_REG_RX_ALARM_CTRL,
+				 0x0400);
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_PMA_DEVAD, MDIO_PMA_REG_LASI_CTRL,
+				 0x0004);
+	}
+	bnx2x_save_bcm_spirom_ver(bp, params->port, phy, params->shmem_base);
+	return 0;
 }
 
 static u8 bnx2x_8726_config_init(struct bnx2x_phy *phy,
@@ -3429,86 +3291,85 @@ static u8 bnx2x_8726_config_init(struct bnx2x_phy *phy,
 	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, MDIO_PMA_REG_CTRL, 1<<15);
 	bnx2x_wait_reset_complete(bp, phy);
 
-	bnx2x_wait_reset_complete(bp, phy);
-			DP(NETIF_MSG_LINK, "Initializing BCM8726\n");
-			bnx2x_8726_external_rom_boot(phy, params);
-
-			/* Need to call module detected on initialization since
-			the module detection triggered by actual module
-			insertion might occur before driver is loaded, and when
-			driver is loaded, it reset all registers, including the
-			transmitter */
-			bnx2x_sfp_module_detection(phy, params);
+	bnx2x_8726_external_rom_boot(phy, params);
 
-			/* Set Flow control */
-			bnx2x_ext_phy_set_pause(params, phy, vars);
-			if (params->req_line_speed == SPEED_1000) {
-				DP(NETIF_MSG_LINK, "Setting 1G force\n");
-				bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD,
-					       MDIO_PMA_REG_CTRL, 0x40);
-				bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD,
-					       MDIO_PMA_REG_10G_CTRL2, 0xD);
-				bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD,
-					       MDIO_PMA_REG_LASI_CTRL, 0x5);
-				bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD,
-					       MDIO_PMA_REG_RX_ALARM_CTRL,
-					       0x400);
-			} else if ((params->req_line_speed ==
-				    SPEED_AUTO_NEG) &&
-				   ((params->speed_cap_mask &
-				     PORT_HW_CFG_SPEED_CAPABILITY_D0_1G))) {
-				DP(NETIF_MSG_LINK, "Setting 1G clause37\n");
-				bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD,
-					       MDIO_AN_REG_ADV, 0x20);
-				bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD,
-					       MDIO_AN_REG_CL37_CL73, 0x040c);
-				bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD,
-					       MDIO_AN_REG_CL37_FC_LD, 0x0020);
-				bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD,
-					       MDIO_AN_REG_CL37_AN, 0x1000);
-				bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD,
-					       MDIO_AN_REG_CTRL, 0x1200);
-
-				/* Enable RX-ALARM control to receive
-				interrupt for 1G speed change */
-				bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD,
-					       MDIO_PMA_REG_LASI_CTRL, 0x4);
-				bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD,
-					       MDIO_PMA_REG_RX_ALARM_CTRL,
-					       0x400);
-
-			} else { /* Default 10G. Set only LASI control */
-				bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD,
-					       MDIO_PMA_REG_LASI_CTRL, 1);
-			}
+	/* Need to call module detected on initialization since
+	the module detection triggered by actual module
+	insertion might occur before driver is loaded, and when
+	driver is loaded, it reset all registers, including the
+	transmitter */
+	bnx2x_sfp_module_detection(phy, params);
+
+	if (phy->req_line_speed == SPEED_1000) {
+		DP(NETIF_MSG_LINK, "Setting 1G force\n");
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_PMA_DEVAD, MDIO_PMA_REG_CTRL, 0x40);
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_PMA_DEVAD, MDIO_PMA_REG_10G_CTRL2, 0xD);
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_PMA_DEVAD, MDIO_PMA_REG_LASI_CTRL, 0x5);
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_PMA_DEVAD, MDIO_PMA_REG_RX_ALARM_CTRL,
+				 0x400);
+	} else if ((phy->req_line_speed == SPEED_AUTO_NEG) &&
+		   (phy->speed_cap_mask &
+		      PORT_HW_CFG_SPEED_CAPABILITY_D0_1G) &&
+		   ((phy->speed_cap_mask &
+		      PORT_HW_CFG_SPEED_CAPABILITY_D0_10G) !=
+		    PORT_HW_CFG_SPEED_CAPABILITY_D0_10G)) {
+		DP(NETIF_MSG_LINK, "Setting 1G clause37\n");
+		/* Set Flow control */
+		bnx2x_ext_phy_set_pause(params, phy, vars);
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_AN_DEVAD, MDIO_AN_REG_ADV, 0x20);
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_AN_DEVAD, MDIO_AN_REG_CL37_CL73, 0x040c);
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_AN_DEVAD, MDIO_AN_REG_CL37_FC_LD, 0x0020);
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_AN_DEVAD, MDIO_AN_REG_CL37_AN, 0x1000);
+		bnx2x_cl45_write(bp, phy,
+				MDIO_AN_DEVAD, MDIO_AN_REG_CTRL, 0x1200);
+		/* Enable RX-ALARM control to receive
+		interrupt for 1G speed change */
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_PMA_DEVAD, MDIO_PMA_REG_LASI_CTRL, 0x4);
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_PMA_DEVAD, MDIO_PMA_REG_RX_ALARM_CTRL,
+				 0x400);
+
+	} else { /* Default 10G. Set only LASI control */
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_PMA_DEVAD, MDIO_PMA_REG_LASI_CTRL, 1);
+	}
 
-			/* Set TX PreEmphasis if needed */
-			if ((params->feature_config_flags &
-			     FEATURE_CONFIG_OVERRIDE_PREEMPHASIS_ENABLED)) {
-				DP(NETIF_MSG_LINK, "Setting TX_CTRL1 0x%x,"
-					 "TX_CTRL2 0x%x\n",
+	/* Set TX PreEmphasis if needed */
+	if ((params->feature_config_flags &
+	     FEATURE_CONFIG_OVERRIDE_PREEMPHASIS_ENABLED)) {
+		DP(NETIF_MSG_LINK, "Setting TX_CTRL1 0x%x,"
+			 "TX_CTRL2 0x%x\n",
 			 phy->tx_preemphasis[0],
 			 phy->tx_preemphasis[1]);
-				bnx2x_cl45_write(bp, phy,
-					       MDIO_PMA_DEVAD,
-					       MDIO_PMA_REG_8726_TX_CTRL1,
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_PMA_DEVAD,
+				 MDIO_PMA_REG_8726_TX_CTRL1,
 				 phy->tx_preemphasis[0]);
 
-				bnx2x_cl45_write(bp, phy,
-					       MDIO_PMA_DEVAD,
-					       MDIO_PMA_REG_8726_TX_CTRL2,
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_PMA_DEVAD,
+				 MDIO_PMA_REG_8726_TX_CTRL2,
 				 phy->tx_preemphasis[1]);
-			}
-			return 0;
+	}
+	return 0;
 
 }
 
-static u8 bnx2x_8072_8073_config_init(struct bnx2x_phy *phy,
+static u8 bnx2x_8073_config_init(struct bnx2x_phy *phy,
 				 struct link_params *params,
 				 struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
-	u16 val = 0;
+	u16 val = 0, tmp1;
 	u8 gpio_port;
 	DP(NETIF_MSG_LINK, "Init 8073\n");
 
@@ -3520,183 +3381,117 @@ static u8 bnx2x_8072_8073_config_init(struct bnx2x_phy *phy,
 	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1,
 			    MISC_REGISTERS_GPIO_OUTPUT_HIGH, gpio_port);
 
-		{
-			u16 tmp1;
-			u16 rx_alarm_ctrl_val;
-			u16 lasi_ctrl_val;
-			if (phy->type ==
-			    PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072) {
-				rx_alarm_ctrl_val = 0x400;
-				lasi_ctrl_val = 0x0004;
-			} else {
-				rx_alarm_ctrl_val = (1<<2);
-				lasi_ctrl_val = 0x0004;
-			}
-
-			/* enable LASI */
-			bnx2x_cl45_write(bp, phy,
-				   MDIO_PMA_DEVAD,
-				   MDIO_PMA_REG_RX_ALARM_CTRL,
-				   rx_alarm_ctrl_val);
-
-			bnx2x_cl45_write(bp, phy,
-				       MDIO_PMA_DEVAD,
-				       MDIO_PMA_REG_LASI_CTRL,
-				       lasi_ctrl_val);
-
-			bnx2x_8073_set_pause_cl37(params, phy, vars);
+	/* enable LASI */
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_PMA_DEVAD, MDIO_PMA_REG_RX_ALARM_CTRL, (1<<2));
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_PMA_DEVAD, MDIO_PMA_REG_LASI_CTRL,  0x0004);
 
-			if (phy->type ==
-			    PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072)
-				bnx2x_bcm8072_external_rom_boot(phy, params);
-			else
-				/* In case of 8073 with long xaui lines,
-				don't set the 8073 xaui low power*/
-				bnx2x_8073_set_xaui_low_power_mode(bp, phy);
+	bnx2x_8073_set_pause_cl37(params, phy, vars);
 
-			bnx2x_cl45_read(bp, phy,
-				      MDIO_PMA_DEVAD,
-				      MDIO_PMA_REG_M8051_MSGOUT_REG,
-				      &tmp1);
+	bnx2x_8073_set_xaui_low_power_mode(bp, phy);
 
-			bnx2x_cl45_read(bp, phy,
-				      MDIO_PMA_DEVAD,
-				      MDIO_PMA_REG_RX_ALARM, &tmp1);
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_M8051_MSGOUT_REG, &tmp1);
 
-			DP(NETIF_MSG_LINK, "Before rom RX_ALARM(port1):"
-					     "0x%x\n", tmp1);
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_RX_ALARM, &tmp1);
 
-			/* If this is forced speed, set to KR or KX
-			 * (all other are not supported)
-			 */
-			if (params->loopback_mode == LOOPBACK_EXT) {
-				bnx2x_807x_force_10G(bp, phy);
-				DP(NETIF_MSG_LINK,
-					"Forced speed 10G on 807X\n");
-				return 0;
-			} else {
-				bnx2x_cl45_write(bp, phy,
-					       MDIO_PMA_DEVAD,
-					       MDIO_PMA_REG_BCM_CTRL,
-					       0x0002);
-			}
-			if (params->req_line_speed != SPEED_AUTO_NEG) {
-				if (params->req_line_speed == SPEED_10000) {
-					val = (1<<7);
-				} else if (params->req_line_speed ==
-					   SPEED_2500) {
-					val = (1<<5);
-					/* Note that 2.5G works only
-					when used with 1G advertisment */
-				} else
-					val = (1<<5);
-			} else {
+	DP(NETIF_MSG_LINK, "Before rom RX_ALARM(port1): 0x%x\n", tmp1);
 
-				val = 0;
-				if (params->speed_cap_mask &
-					PORT_HW_CFG_SPEED_CAPABILITY_D0_10G)
-					val |= (1<<7);
-
-				/* Note that 2.5G works only when
-				used with 1G advertisment */
-				if (params->speed_cap_mask &
-					(PORT_HW_CFG_SPEED_CAPABILITY_D0_1G |
-					 PORT_HW_CFG_SPEED_CAPABILITY_D0_2_5G))
-					val |= (1<<5);
-				DP(NETIF_MSG_LINK,
-					 "807x autoneg val = 0x%x\n", val);
-			}
+	/* Enable CL37 BAM */
+	bnx2x_cl45_read(bp, phy,
+			MDIO_AN_DEVAD,
+			MDIO_AN_REG_8073_BAM, &val);
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_AN_DEVAD,
+			 MDIO_AN_REG_8073_BAM, val | 1);
 
-			bnx2x_cl45_write(bp, phy,
-				       MDIO_AN_DEVAD,
-				       MDIO_AN_REG_ADV, val);
+	if (params->loopback_mode == LOOPBACK_EXT) {
+		bnx2x_807x_force_10G(bp, phy);
+		DP(NETIF_MSG_LINK, "Forced speed 10G on 807X\n");
+		return 0;
+	} else {
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_PMA_DEVAD, MDIO_PMA_REG_BCM_CTRL, 0x0002);
+	}
+	if (phy->req_line_speed != SPEED_AUTO_NEG) {
+		if (phy->req_line_speed == SPEED_10000) {
+			val = (1<<7);
+		} else if (phy->req_line_speed ==  SPEED_2500) {
+			val = (1<<5);
+			/* Note that 2.5G works only
+			when used with 1G advertisment */
+		} else
+			val = (1<<5);
+	} else {
+		val = 0;
+		if (phy->speed_cap_mask &
+			PORT_HW_CFG_SPEED_CAPABILITY_D0_10G)
+			val |= (1<<7);
+
+		/* Note that 2.5G works only when
+		used with 1G advertisment */
+		if (phy->speed_cap_mask &
+			(PORT_HW_CFG_SPEED_CAPABILITY_D0_1G |
+			 PORT_HW_CFG_SPEED_CAPABILITY_D0_2_5G))
+			val |= (1<<5);
+		DP(NETIF_MSG_LINK, "807x autoneg val = 0x%x\n", val);
+	}
 
-				bnx2x_cl45_read(bp, phy,
-					      MDIO_AN_DEVAD,
-					      MDIO_AN_REG_8073_2_5G, &tmp1);
-
-				if (((params->speed_cap_mask &
-				      PORT_HW_CFG_SPEED_CAPABILITY_D0_2_5G) &&
-				     (params->req_line_speed ==
-				      SPEED_AUTO_NEG)) ||
-				    (params->req_line_speed ==
-				     SPEED_2500)) {
-					u16 phy_ver;
-					/* Allow 2.5G for A1 and above */
-					bnx2x_cl45_read(bp, phy,
-					 MDIO_PMA_DEVAD,
-					 MDIO_PMA_REG_8073_CHIP_REV, &phy_ver);
-					DP(NETIF_MSG_LINK, "Add 2.5G\n");
-					if (phy_ver > 0)
-						tmp1 |= 1;
-					else
-						tmp1 &= 0xfffe;
-				} else {
-					DP(NETIF_MSG_LINK, "Disable 2.5G\n");
-					tmp1 &= 0xfffe;
-				}
-
-				bnx2x_cl45_write(bp, phy,
-					       MDIO_AN_DEVAD,
-					       MDIO_AN_REG_8073_2_5G, tmp1);
-
-			/* Add support for CL37 (passive mode) II */
+	bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD, MDIO_AN_REG_ADV, val);
+	bnx2x_cl45_read(bp, phy, MDIO_AN_DEVAD, MDIO_AN_REG_8073_2_5G, &tmp1);
 
-			bnx2x_cl45_read(bp, phy,
-				       MDIO_AN_DEVAD,
-				       MDIO_AN_REG_CL37_FC_LD,
-				       &tmp1);
+	if (((phy->speed_cap_mask & PORT_HW_CFG_SPEED_CAPABILITY_D0_2_5G) &&
+	     (phy->req_line_speed == SPEED_AUTO_NEG)) ||
+	    (phy->req_line_speed == SPEED_2500)) {
+		u16 phy_ver;
+		/* Allow 2.5G for A1 and above */
+		bnx2x_cl45_read(bp, phy,
+				MDIO_PMA_DEVAD, MDIO_PMA_REG_8073_CHIP_REV,
+				&phy_ver);
+		DP(NETIF_MSG_LINK, "Add 2.5G\n");
+		if (phy_ver > 0)
+			tmp1 |= 1;
+		else
+			tmp1 &= 0xfffe;
+	} else {
+		DP(NETIF_MSG_LINK, "Disable 2.5G\n");
+		tmp1 &= 0xfffe;
+	}
 
-			bnx2x_cl45_write(bp, phy,
-				       MDIO_AN_DEVAD,
-				       MDIO_AN_REG_CL37_FC_LD, (tmp1 |
-				       ((params->req_duplex == DUPLEX_FULL) ?
-				       0x20 : 0x40)));
+	bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD, MDIO_AN_REG_8073_2_5G, tmp1);
+	/* Add support for CL37 (passive mode) II */
 
-			/* Add support for CL37 (passive mode) III */
-			bnx2x_cl45_write(bp, phy,
-				       MDIO_AN_DEVAD,
-				       MDIO_AN_REG_CL37_AN, 0x1000);
-
-			if (phy->type ==
-			    PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073) {
-				/* The SNR will improve about 2db by changing
-				BW and FEE main tap. Rest commands are executed
-				after link is up*/
-				/*Change FFE main cursor to 5 in EDC register*/
-				if (bnx2x_8073_is_snr_needed(bp, phy))
-					bnx2x_cl45_write(bp, phy,
-						    MDIO_PMA_DEVAD,
-						    MDIO_PMA_REG_EDC_FFE_MAIN,
-						    0xFB0C);
-
-				/* Enable FEC (Forware Error Correction)
-				Request in the AN */
-				bnx2x_cl45_read(bp, phy,
-					      MDIO_AN_DEVAD,
-					      MDIO_AN_REG_ADV2, &tmp1);
+	bnx2x_cl45_read(bp, phy, MDIO_AN_DEVAD, MDIO_AN_REG_CL37_FC_LD, &tmp1);
+	bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD, MDIO_AN_REG_CL37_FC_LD,
+			 (tmp1 | ((phy->req_duplex == DUPLEX_FULL) ?
+				  0x20 : 0x40)));
 
-				tmp1 |= (1<<15);
+	/* Add support for CL37 (passive mode) III */
+	bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD, MDIO_AN_REG_CL37_AN, 0x1000);
 
-				bnx2x_cl45_write(bp, phy,
-					       MDIO_AN_DEVAD,
-					       MDIO_AN_REG_ADV2, tmp1);
+	/* The SNR will improve about 2db by changing
+	BW and FEE main tap. Rest commands are executed
+	after link is up*/
+	if (bnx2x_8073_is_snr_needed(bp, phy))
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_PMA_DEVAD, MDIO_PMA_REG_EDC_FFE_MAIN,
+				 0xFB0C);
 
-			}
+	/* Enable FEC (Forware Error Correction) Request in the AN */
+	bnx2x_cl45_read(bp, phy, MDIO_AN_DEVAD, MDIO_AN_REG_ADV2, &tmp1);
+	tmp1 |= (1<<15);
+	bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD, MDIO_AN_REG_ADV2, tmp1);
 
-			bnx2x_ext_phy_set_pause(params, phy, vars);
+	bnx2x_ext_phy_set_pause(params, phy, vars);
 
-			/* Restart autoneg */
-			msleep(500);
-			bnx2x_cl45_write(bp, phy,
-				       MDIO_AN_DEVAD,
-				       MDIO_AN_REG_CTRL, 0x1200);
-			DP(NETIF_MSG_LINK, "807x Autoneg Restart: "
-			   "Advertise 1G=%x, 10G=%x\n",
-			   ((val & (1<<5)) > 0),
-			   ((val & (1<<7)) > 0));
-			return 0;
-		}
+	/* Restart autoneg */
+	msleep(500);
+	bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD, MDIO_AN_REG_CTRL, 0x1200);
+	DP(NETIF_MSG_LINK, "807x Autoneg Restart: Advertise 1G=%x, 10G=%x\n",
+		   ((val & (1<<5)) > 0), ((val & (1<<7)) > 0));
+	return 0;
 }
 
 static u8 bnx2x_8727_config_init(struct bnx2x_phy *phy,
@@ -3709,143 +3504,120 @@ static u8 bnx2x_8727_config_init(struct bnx2x_phy *phy,
 	struct bnx2x *bp = params->bp;
 	/* Enable PMD link, MOD_ABS_FLT, and 1G link alarm */
 
-			/* Enable PMD link, MOD_ABS_FLT, and 1G link alarm */
+	bnx2x_wait_reset_complete(bp, phy);
+	rx_alarm_ctrl_val = (1<<2) | (1<<5) ;
+	lasi_ctrl_val = 0x0004;
 
-			rx_alarm_ctrl_val = (1<<2) | (1<<5) ;
-			lasi_ctrl_val = 0x0004;
-			bnx2x_wait_reset_complete(bp, phy);
-			DP(NETIF_MSG_LINK, "Initializing BCM8727\n");
-			/* enable LASI */
-			bnx2x_cl45_write(bp, phy,
-				       MDIO_PMA_DEVAD,
-				       MDIO_PMA_REG_RX_ALARM_CTRL,
-				       rx_alarm_ctrl_val);
+	DP(NETIF_MSG_LINK, "Initializing BCM8727\n");
+	/* enable LASI */
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_PMA_DEVAD, MDIO_PMA_REG_RX_ALARM_CTRL,
+			 rx_alarm_ctrl_val);
 
-			bnx2x_cl45_write(bp, phy,
-				       MDIO_PMA_DEVAD,
-				       MDIO_PMA_REG_LASI_CTRL,
-				       lasi_ctrl_val);
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_PMA_DEVAD, MDIO_PMA_REG_LASI_CTRL, lasi_ctrl_val);
 
-			/* Initially configure  MOD_ABS to interrupt when
-			module is presence( bit 8) */
-			bnx2x_cl45_read(bp, phy,
-				      MDIO_PMA_DEVAD,
-				      MDIO_PMA_REG_PHY_IDENTIFIER, &mod_abs);
-			/* Set EDC off by setting OPTXLOS signal input to low
-			(bit 9).
-			When the EDC is off it locks onto a reference clock and
-			avoids becoming 'lost'.*/
-			mod_abs &= ~((1<<8) | (1<<9));
-			bnx2x_cl45_write(bp, phy,
-				       MDIO_PMA_DEVAD,
-				       MDIO_PMA_REG_PHY_IDENTIFIER, mod_abs);
+	/* Initially configure  MOD_ABS to interrupt when
+	module is presence( bit 8) */
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_PHY_IDENTIFIER, &mod_abs);
+	/* Set EDC off by setting OPTXLOS signal input to low
+	(bit 9).
+	When the EDC is off it locks onto a reference clock and
+	avoids becoming 'lost'.*/
+	mod_abs &= ~((1<<8) | (1<<9));
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_PMA_DEVAD, MDIO_PMA_REG_PHY_IDENTIFIER, mod_abs);
 
-			/* Make MOD_ABS give interrupt on change */
-			bnx2x_cl45_read(bp, phy,
-				      MDIO_PMA_DEVAD,
-				      MDIO_PMA_REG_8727_PCS_OPT_CTRL,
-				      &val);
-			val |= (1<<12);
-			bnx2x_cl45_write(bp, phy,
-				       MDIO_PMA_DEVAD,
-				       MDIO_PMA_REG_8727_PCS_OPT_CTRL,
-				       val);
 
-			/* Set 8727 GPIOs to input to allow reading from the
-			8727 GPIO0 status which reflect SFP+ module
-			over-current */
+	/* Make MOD_ABS give interrupt on change */
+	bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD, MDIO_PMA_REG_8727_PCS_OPT_CTRL,
+			&val);
+	val |= (1<<12);
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_PMA_DEVAD, MDIO_PMA_REG_8727_PCS_OPT_CTRL, val);
+	/* Set 8727 GPIOs to input to allow reading from the
+	8727 GPIO0 status which reflect SFP+ module
+	over-current */
+
+	bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD, MDIO_PMA_REG_8727_PCS_OPT_CTRL,
+			&val);
+	val &= 0xff8f; /* Reset bits 4-6 */
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_PMA_DEVAD, MDIO_PMA_REG_8727_PCS_OPT_CTRL, val);
 
-			bnx2x_cl45_read(bp, phy,
-				       MDIO_PMA_DEVAD,
-				       MDIO_PMA_REG_8727_PCS_OPT_CTRL,
-				       &val);
-			val &= 0xff8f; /* Reset bits 4-6 */
-			bnx2x_cl45_write(bp, phy,
-				       MDIO_PMA_DEVAD,
-				       MDIO_PMA_REG_8727_PCS_OPT_CTRL,
-				       val);
+	bnx2x_8727_power_module(bp, phy, 1);
 
-			bnx2x_8727_power_module(bp, params, phy, 1);
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_M8051_MSGOUT_REG, &tmp1);
 
-			bnx2x_cl45_read(bp, phy,
-				      MDIO_PMA_DEVAD,
-				      MDIO_PMA_REG_M8051_MSGOUT_REG,
-				      &tmp1);
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_RX_ALARM, &tmp1);
 
-			bnx2x_cl45_read(bp, phy,
-				      MDIO_PMA_DEVAD,
-				      MDIO_PMA_REG_RX_ALARM, &tmp1);
-
-			/* Set option 1G speed */
-			if (params->req_line_speed == SPEED_1000) {
-
-				DP(NETIF_MSG_LINK, "Setting 1G force\n");
-				bnx2x_cl45_write(bp, phy,
-					       MDIO_PMA_DEVAD,
-					       MDIO_PMA_REG_CTRL, 0x40);
-				bnx2x_cl45_write(bp, phy,
-					       MDIO_PMA_DEVAD,
-					       MDIO_PMA_REG_10G_CTRL2, 0xD);
-				bnx2x_cl45_read(bp, phy,
-				      MDIO_PMA_DEVAD,
-				      MDIO_PMA_REG_10G_CTRL2, &tmp1);
-				DP(NETIF_MSG_LINK, "1.7 = 0x%x\n", tmp1);
-
-			} else if ((params->req_line_speed ==
-				    SPEED_AUTO_NEG) &&
-				   ((params->speed_cap_mask &
-				     PORT_HW_CFG_SPEED_CAPABILITY_D0_1G)) &&
-				   ((params->speed_cap_mask &
-				     PORT_HW_CFG_SPEED_CAPABILITY_D0_10G) !=
-				    PORT_HW_CFG_SPEED_CAPABILITY_D0_10G)) {
-				DP(NETIF_MSG_LINK, "Setting 1G clause37\n");
-				bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD,
-					       MDIO_AN_REG_8727_MISC_CTRL, 0);
-				bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD,
-					       MDIO_AN_REG_CL37_AN, 0x1300);
-			} else {
-				/* Since the 8727 has only single reset pin,
-				need to set the 10G registers although it is
-				default */
-				bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD,
-					      MDIO_AN_REG_8727_MISC_CTRL,
-					      0x0020);
-				bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD,
-					      MDIO_AN_REG_CL37_AN, 0x0100);
-				bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD,
-					      MDIO_PMA_REG_CTRL, 0x2040);
-				bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD,
-					      MDIO_PMA_REG_10G_CTRL2, 0x0008);
-			}
+	/* Set option 1G speed */
+	if (phy->req_line_speed == SPEED_1000) {
+		DP(NETIF_MSG_LINK, "Setting 1G force\n");
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_PMA_DEVAD, MDIO_PMA_REG_CTRL, 0x40);
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_PMA_DEVAD, MDIO_PMA_REG_10G_CTRL2, 0xD);
+		bnx2x_cl45_read(bp, phy,
+				MDIO_PMA_DEVAD, MDIO_PMA_REG_10G_CTRL2, &tmp1);
+		DP(NETIF_MSG_LINK, "1.7 = 0x%x\n", tmp1);
+	} else if ((phy->req_line_speed == SPEED_AUTO_NEG) &&
+		   ((phy->speed_cap_mask &
+		     PORT_HW_CFG_SPEED_CAPABILITY_D0_1G)) &&
+		   ((phy->speed_cap_mask &
+		      PORT_HW_CFG_SPEED_CAPABILITY_D0_10G) !=
+		   PORT_HW_CFG_SPEED_CAPABILITY_D0_10G)) {
+
+		DP(NETIF_MSG_LINK, "Setting 1G clause37\n");
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_AN_DEVAD, MDIO_AN_REG_8727_MISC_CTRL, 0);
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_AN_DEVAD, MDIO_AN_REG_CL37_AN, 0x1300);
+	} else {
+		/**
+		 * Since the 8727 has only single reset pin, need to set the 10G
+		 * registers although it is default
+		 */
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_AN_DEVAD, MDIO_AN_REG_8727_MISC_CTRL,
+				 0x0020);
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_AN_DEVAD, MDIO_AN_REG_CL37_AN, 0x0100);
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_PMA_DEVAD, MDIO_PMA_REG_CTRL, 0x2040);
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_PMA_DEVAD, MDIO_PMA_REG_10G_CTRL2,
+				 0x0008);
+	}
 
-			/* Set 2-wire transfer rate of SFP+ module EEPROM
-			 * to 100Khz since some DACs(direct attached cables) do
-			 * not work at 400Khz.
-			 */
-			bnx2x_cl45_write(bp, phy,
-				       MDIO_PMA_DEVAD,
-				       MDIO_PMA_REG_8727_TWO_WIRE_SLAVE_ADDR,
-				       0xa001);
-
-			/* Set TX PreEmphasis if needed */
-			if ((params->feature_config_flags &
-			     FEATURE_CONFIG_OVERRIDE_PREEMPHASIS_ENABLED)) {
-				DP(NETIF_MSG_LINK, "Setting TX_CTRL1 0x%x,"
-					 "TX_CTRL2 0x%x\n",
-					 phy->tx_preemphasis[0],
+
+	/* Set 2-wire transfer rate of SFP+ module EEPROM
+	 * to 100Khz since some DACs(direct attached cables) do
+	 * not work at 400Khz.
+	 */
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_PMA_DEVAD, MDIO_PMA_REG_8727_TWO_WIRE_SLAVE_ADDR,
+			 0xa001);
+
+	/* Set TX PreEmphasis if needed */
+	if ((params->feature_config_flags &
+	     FEATURE_CONFIG_OVERRIDE_PREEMPHASIS_ENABLED)) {
+		DP(NETIF_MSG_LINK, "Setting TX_CTRL1 0x%x, TX_CTRL2 0x%x\n",
+			   phy->tx_preemphasis[0],
 			   phy->tx_preemphasis[1]);
-				bnx2x_cl45_write(bp, phy,
-					       MDIO_PMA_DEVAD,
-					       MDIO_PMA_REG_8727_TX_CTRL1,
-					       phy->tx_preemphasis[0]);
-
-				bnx2x_cl45_write(bp, phy,
-					       MDIO_PMA_DEVAD,
-					       MDIO_PMA_REG_8727_TX_CTRL2,
-					       phy->tx_preemphasis[1]);
-			}
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_PMA_DEVAD, MDIO_PMA_REG_8727_TX_CTRL1,
+				 phy->tx_preemphasis[0]);
 
-			return 0;
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_PMA_DEVAD, MDIO_PMA_REG_8727_TX_CTRL2,
+				 phy->tx_preemphasis[1]);
+	}
+
+	return 0;
 }
 
 static u8 bnx2x_7101_config_init(struct bnx2x_phy *phy,
@@ -3861,40 +3633,31 @@ static u8 bnx2x_7101_config_init(struct bnx2x_phy *phy,
 			    MISC_REGISTERS_GPIO_OUTPUT_HIGH, params->port);
 	/* HW reset */
 	bnx2x_ext_phy_hw_reset(bp, params->port);
+	bnx2x_wait_reset_complete(bp, phy);
 
-			DP(NETIF_MSG_LINK,
-				"Setting the SFX7101 LASI indication\n");
-			bnx2x_wait_reset_complete(bp, phy);
-			bnx2x_cl45_write(bp, phy,
-				       MDIO_PMA_DEVAD,
-				       MDIO_PMA_REG_LASI_CTRL, 0x1);
-			DP(NETIF_MSG_LINK,
-			  "Setting the SFX7101 LED to blink on traffic\n");
-			bnx2x_cl45_write(bp, phy,
-				       MDIO_PMA_DEVAD,
-				       MDIO_PMA_REG_7107_LED_CNTL, (1<<3));
-
-			bnx2x_ext_phy_set_pause(params, phy, vars);
-			/* Restart autoneg */
-			bnx2x_cl45_read(bp, phy,
-				      MDIO_AN_DEVAD,
-				      MDIO_AN_REG_CTRL, &val);
-			val |= 0x200;
-			bnx2x_cl45_write(bp, phy,
-				       MDIO_AN_DEVAD,
-				       MDIO_AN_REG_CTRL, val);
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_PMA_DEVAD, MDIO_PMA_REG_LASI_CTRL, 0x1);
+	DP(NETIF_MSG_LINK, "Setting the SFX7101 LED to blink on traffic\n");
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_PMA_DEVAD, MDIO_PMA_REG_7107_LED_CNTL, (1<<3));
 
-			/* Save spirom version */
-			bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD,
-				      MDIO_PMA_REG_7101_VER1, &fw_ver1);
+	bnx2x_ext_phy_set_pause(params, phy, vars);
+	/* Restart autoneg */
+	bnx2x_cl45_read(bp, phy,
+			MDIO_AN_DEVAD, MDIO_AN_REG_CTRL, &val);
+	val |= 0x200;
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_AN_DEVAD, MDIO_AN_REG_CTRL, val);
 
-			bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD,
-				      MDIO_PMA_REG_7101_VER2, &fw_ver2);
+	/* Save spirom version */
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_7101_VER1, &fw_ver1);
 
-			bnx2x_save_spirom_version(params->bp, params->port,
-						params->shmem_base,
-						(u32)(fw_ver1<<16 | fw_ver2));
-			return 0;
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_7101_VER2, &fw_ver2);
+	bnx2x_save_spirom_version(bp, params->port,
+				  (u32)(fw_ver1<<16 | fw_ver2), phy->ver_addr);
+	return 0;
 }
 
 static u8 bnx2x_848xx_cmn_config_init(struct bnx2x_phy *phy,
@@ -3902,145 +3665,121 @@ static u8 bnx2x_848xx_cmn_config_init(struct bnx2x_phy *phy,
 				      struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
-		{
-			/* This phy uses the NIG latch mechanism since link
-				indication arrives through its LED4 and not via
-				its LASI signal, so we get steady signal
-				instead of clear on read */
-			u16 autoneg_val, an_1000_val, an_10_100_val, temp;
-			temp = vars->line_speed;
-			vars->line_speed = SPEED_10000;
-			bnx2x_wait_reset_complete(bp, phy);
-			bnx2x_set_autoneg(phy, params, vars, 0);
-			bnx2x_program_serdes(phy, params, vars);
-			vars->line_speed = temp;
+	u16 autoneg_val, an_1000_val, an_10_100_val;
+	bnx2x_wait_reset_complete(bp, phy);
+	bnx2x_bits_en(bp, NIG_REG_LATCH_BC_0 + params->port*4,
+		      1 << NIG_LATCH_BC_ENABLE_MI_INT);
+
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_PMA_DEVAD, MDIO_PMA_REG_CTRL, 0x0000);
+	bnx2x_8481_set_led(bp, phy);
+	/* set 1000 speed advertisement */
+	bnx2x_cl45_read(bp, phy,
+			MDIO_AN_DEVAD, MDIO_AN_REG_8481_1000T_CTRL,
+			&an_1000_val);
 
-			bnx2x_bits_en(bp, NIG_REG_LATCH_BC_0 + params->port*4,
-				      1 << NIG_LATCH_BC_ENABLE_MI_INT);
+	bnx2x_ext_phy_set_pause(params, phy, vars);
+	bnx2x_cl45_read(bp, phy,
+			MDIO_AN_DEVAD,
+			MDIO_AN_REG_8481_LEGACY_AN_ADV,
+			&an_10_100_val);
+	bnx2x_cl45_read(bp, phy,
+			MDIO_AN_DEVAD, MDIO_AN_REG_8481_LEGACY_MII_CTRL,
+			&autoneg_val);
+	/* Disable forced speed */
+	autoneg_val &= ~((1<<6) | (1<<8) | (1<<9) | (1<<12) | (1<<13));
+	an_10_100_val &= ~((1<<5) | (1<<6) | (1<<7) | (1<<8));
+
+	if (((phy->req_line_speed == SPEED_AUTO_NEG) &&
+	     (phy->speed_cap_mask &
+	     PORT_HW_CFG_SPEED_CAPABILITY_D0_1G)) ||
+	    (phy->req_line_speed == SPEED_1000)) {
+		an_1000_val |= (1<<8);
+		autoneg_val |= (1<<9 | 1<<12);
+		if (phy->req_duplex == DUPLEX_FULL)
+			an_1000_val |= (1<<9);
+		DP(NETIF_MSG_LINK, "Advertising 1G\n");
+	} else
+		an_1000_val &= ~((1<<8) | (1<<9));
 
-			bnx2x_cl45_write(bp, phy,
-					 MDIO_PMA_DEVAD,
-					 MDIO_PMA_REG_CTRL, 0x0000);
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_AN_DEVAD, MDIO_AN_REG_8481_1000T_CTRL,
+			 an_1000_val);
+
+	/* set 10 speed advertisement */
+	if (((phy->req_line_speed == SPEED_AUTO_NEG) &&
+	     (phy->speed_cap_mask &
+	     (PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_FULL |
+	      PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_HALF)))) {
+		an_10_100_val |= (1<<7);
+		/* Enable autoneg and restart autoneg for legacy speeds */
+		autoneg_val |= (1<<9 | 1<<12);
+
+		if (phy->req_duplex == DUPLEX_FULL)
+			an_10_100_val |= (1<<8);
+		DP(NETIF_MSG_LINK, "Advertising 100M\n");
+	}
+	/* set 10 speed advertisement */
+	if (((phy->req_line_speed == SPEED_AUTO_NEG) &&
+	    (phy->speed_cap_mask &
+	  (PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_FULL |
+	   PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_HALF)))) {
+		an_10_100_val |= (1<<5);
+		autoneg_val |= (1<<9 | 1<<12);
+		if (phy->req_duplex == DUPLEX_FULL)
+			an_10_100_val |= (1<<6);
+		DP(NETIF_MSG_LINK, "Advertising 10M\n");
+	}
 
-			bnx2x_8481_set_led(bp, phy);
+	/* Only 10/100 are allowed to work in FORCE mode */
+	if (phy->req_line_speed == SPEED_100) {
+		autoneg_val |= (1<<13);
+		/* Enabled AUTO-MDIX when autoneg is disabled */
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_AN_DEVAD, MDIO_AN_REG_8481_AUX_CTRL,
+				 (1<<15 | 1<<9 | 7<<0));
+		DP(NETIF_MSG_LINK, "Setting 100M force\n");
+	}
+	if (phy->req_line_speed == SPEED_10) {
+		/* Enabled AUTO-MDIX when autoneg is disabled */
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_AN_DEVAD, MDIO_AN_REG_8481_AUX_CTRL,
+				 (1<<15 | 1<<9 | 7<<0));
+		DP(NETIF_MSG_LINK, "Setting 10M force\n");
+	}
 
-			bnx2x_cl45_read(bp, phy,
-					MDIO_AN_DEVAD,
-					MDIO_AN_REG_8481_1000T_CTRL,
-					&an_1000_val);
-			bnx2x_ext_phy_set_pause(params, phy, vars);
-			bnx2x_cl45_read(bp, phy, MDIO_AN_DEVAD,
-					MDIO_AN_REG_8481_LEGACY_AN_ADV,
-					&an_10_100_val);
-			bnx2x_cl45_read(bp, phy, MDIO_AN_DEVAD,
-					MDIO_AN_REG_8481_LEGACY_MII_CTRL,
-					&autoneg_val);
-			/* Disable forced speed */
-			autoneg_val &= ~((1<<6) | (1<<8) | (1<<9) | (1<<12) |
-					 (1<<13));
-			an_10_100_val &= ~((1<<5) | (1<<6) | (1<<7) | (1<<8));
-
-			if (((params->req_line_speed == SPEED_AUTO_NEG) &&
-			     (params->speed_cap_mask &
-			      PORT_HW_CFG_SPEED_CAPABILITY_D0_1G)) ||
-			    (params->req_line_speed == SPEED_1000)) {
-				an_1000_val |= (1<<8);
-				autoneg_val |= (1<<9 | 1<<12);
-				if (params->req_duplex == DUPLEX_FULL)
-					an_1000_val |= (1<<9);
-				DP(NETIF_MSG_LINK, "Advertising 1G\n");
-			} else
-				an_1000_val &= ~((1<<8) | (1<<9));
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_AN_DEVAD, MDIO_AN_REG_8481_LEGACY_AN_ADV,
+			 an_10_100_val);
 
-			bnx2x_cl45_write(bp, phy,
-					 MDIO_AN_DEVAD,
-					 MDIO_AN_REG_8481_1000T_CTRL,
-					 an_1000_val);
-
-			/* set 10 speed advertisement */
-			if (((params->req_line_speed == SPEED_AUTO_NEG) &&
-			     (params->speed_cap_mask &
-			      (PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_FULL |
-			       PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_HALF)))) {
-				an_10_100_val |= (1<<7);
-				/*
-				 * Enable autoneg and restart autoneg for
-				 * legacy speeds
-				 */
-				autoneg_val |= (1<<9 | 1<<12);
-
-				if (params->req_duplex == DUPLEX_FULL)
-					an_10_100_val |= (1<<8);
-				DP(NETIF_MSG_LINK, "Advertising 100M\n");
-			}
-			/* set 10 speed advertisement */
-			if (((params->req_line_speed == SPEED_AUTO_NEG) &&
-			     (params->speed_cap_mask &
-			      (PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_FULL |
-			       PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_HALF)))) {
-				an_10_100_val |= (1<<5);
-				autoneg_val |= (1<<9 | 1<<12);
-				if (params->req_duplex == DUPLEX_FULL)
-					an_10_100_val |= (1<<6);
-				DP(NETIF_MSG_LINK, "Advertising 10M\n");
-			}
+	if (phy->req_duplex == DUPLEX_FULL)
+		autoneg_val |= (1<<8);
 
-			/* Only 10/100 are allowed to work in FORCE mode */
-			if (params->req_line_speed == SPEED_100) {
-				autoneg_val |= (1<<13);
-				/* Enabled AUTO-MDIX when autoneg is disabled */
-				bnx2x_cl45_write(bp, phy,
-						 MDIO_AN_DEVAD,
-						 MDIO_AN_REG_8481_AUX_CTRL,
-						 (1<<15 | 1<<9 | 7<<0));
-				DP(NETIF_MSG_LINK, "Setting 100M force\n");
-			}
-			if (params->req_line_speed == SPEED_10) {
-				/* Enabled AUTO-MDIX when autoneg is disabled */
-				bnx2x_cl45_write(bp, phy,
-						 MDIO_AN_DEVAD,
-						 MDIO_AN_REG_8481_AUX_CTRL,
-						 (1<<15 | 1<<9 | 7<<0));
-				DP(NETIF_MSG_LINK, "Setting 10M force\n");
-			}
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_AN_DEVAD,
+			 MDIO_AN_REG_8481_LEGACY_MII_CTRL, autoneg_val);
 
-			bnx2x_cl45_write(bp, phy,
-					 MDIO_AN_DEVAD,
-					 MDIO_AN_REG_8481_LEGACY_AN_ADV,
-					 an_10_100_val);
+	if (((phy->req_line_speed == SPEED_AUTO_NEG) &&
+	    (phy->speed_cap_mask &
+	     PORT_HW_CFG_SPEED_CAPABILITY_D0_10G)) ||
+		(phy->req_line_speed == SPEED_10000)) {
+		DP(NETIF_MSG_LINK, "Advertising 10G\n");
+		/* Restart autoneg for 10G*/
 
-			if (params->req_duplex == DUPLEX_FULL)
-				autoneg_val |= (1<<8);
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_AN_DEVAD, MDIO_AN_REG_CTRL,
+				 0x3200);
+	} else if (phy->req_line_speed != SPEED_10 &&
+		   phy->req_line_speed != SPEED_100) {
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_AN_DEVAD,
+				 MDIO_AN_REG_8481_10GBASE_T_AN_CTRL,
+				 1);
+	}
+	/* Save spirom version */
+	bnx2x_save_8481_spirom_version(phy, params, params->shmem_base);
 
-			bnx2x_cl45_write(bp, phy,
-					 MDIO_AN_DEVAD,
-					 MDIO_AN_REG_8481_LEGACY_MII_CTRL,
-					 autoneg_val);
-
-			if (((params->req_line_speed == SPEED_AUTO_NEG) &&
-			     (params->speed_cap_mask &
-			      PORT_HW_CFG_SPEED_CAPABILITY_D0_10G)) ||
-			    (params->req_line_speed == SPEED_10000)) {
-				DP(NETIF_MSG_LINK, "Advertising 10G\n");
-				/* Restart autoneg for 10G*/
-
-				bnx2x_cl45_write(bp, phy,
-						 MDIO_AN_DEVAD,
-						 MDIO_AN_REG_CTRL,
-						 0x3200);
-
-			} else if (params->req_line_speed != SPEED_10 &&
-				   params->req_line_speed != SPEED_100)
-				bnx2x_cl45_write(bp, phy,
-					     MDIO_AN_DEVAD,
-					     MDIO_AN_REG_8481_10GBASE_T_AN_CTRL,
-					     1);
-
-			/* Save spirom version */
-			bnx2x_save_8481_spirom_version(phy, params,
-						       params->shmem_base);
-			return 0;
-		}
+	return 0;
 }
 
 static u8 bnx2x_848x3_config_init(struct bnx2x_phy *phy,
@@ -4132,16 +3871,16 @@ static void bnx2x_8727_handle_mod_abs(struct bnx2x_phy *phy,
 		absence of the Rx signal. (bit 9) */
 		mod_abs |= ((1<<8)|(1<<9));
 		bnx2x_cl45_write(bp, phy,
-		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_PHY_IDENTIFIER, mod_abs);
+				 MDIO_PMA_DEVAD,
+				 MDIO_PMA_REG_PHY_IDENTIFIER, mod_abs);
 
 		/* Clear RX alarm since it stays up as long as
 		the mod_abs wasn't changed. This is need to be done
 		before calling the module detection, otherwise it will clear
 		the link update alarm */
 		bnx2x_cl45_read(bp, phy,
-			      MDIO_PMA_DEVAD,
-			      MDIO_PMA_REG_RX_ALARM, &rx_alarm_status);
+				MDIO_PMA_DEVAD,
+				MDIO_PMA_REG_RX_ALARM, &rx_alarm_status);
 

 		if ((val & PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_MASK) ==
@@ -4164,37 +3903,33 @@ static u8 bnx2x_8705_read_status(struct bnx2x_phy *phy,
 				 struct link_params *params,
 				 struct link_vars *vars)
 {
-	u8 ext_phy_link_up = 0;
+	u8 link_up = 0;
 	u16 val1, rx_sd;
 	struct bnx2x *bp = params->bp;
-			DP(NETIF_MSG_LINK, "XGXS 8705\n");
-			bnx2x_cl45_read(bp, phy,
-				      MDIO_WIS_DEVAD,
-				      MDIO_WIS_REG_LASI_STATUS, &val1);
-			DP(NETIF_MSG_LINK, "8705 LASI status 0x%x\n", val1);
+	DP(NETIF_MSG_LINK, "read status 8705\n");
+	bnx2x_cl45_read(bp, phy,
+		      MDIO_WIS_DEVAD, MDIO_WIS_REG_LASI_STATUS, &val1);
+	DP(NETIF_MSG_LINK, "8705 LASI status 0x%x\n", val1);
 
-			bnx2x_cl45_read(bp, phy,
-				      MDIO_WIS_DEVAD,
-				      MDIO_WIS_REG_LASI_STATUS, &val1);
-			DP(NETIF_MSG_LINK, "8705 LASI status 0x%x\n", val1);
+	bnx2x_cl45_read(bp, phy,
+		      MDIO_WIS_DEVAD, MDIO_WIS_REG_LASI_STATUS, &val1);
+	DP(NETIF_MSG_LINK, "8705 LASI status 0x%x\n", val1);
 
-			bnx2x_cl45_read(bp, phy,
-				      MDIO_PMA_DEVAD,
-				      MDIO_PMA_REG_RX_SD, &rx_sd);
+	bnx2x_cl45_read(bp, phy,
+		      MDIO_PMA_DEVAD, MDIO_PMA_REG_RX_SD, &rx_sd);
 
-			bnx2x_cl45_read(bp, phy,
-				      1,
-				      0xc809, &val1);
-			bnx2x_cl45_read(bp, phy,
-				      1,
-				      0xc809, &val1);
+	bnx2x_cl45_read(bp, phy,
+		      MDIO_PMA_DEVAD, 0xc809, &val1);
+	bnx2x_cl45_read(bp, phy,
+		      MDIO_PMA_DEVAD, 0xc809, &val1);
 
-			DP(NETIF_MSG_LINK, "8705 1.c809 val=0x%x\n", val1);
-			ext_phy_link_up = ((rx_sd & 0x1) && (val1 & (1<<9)) &&
-					   ((val1 & (1<<8)) == 0));
-			if (ext_phy_link_up)
-				vars->line_speed = SPEED_10000;
-			return ext_phy_link_up;
+	DP(NETIF_MSG_LINK, "8705 1.c809 val=0x%x\n", val1);
+	link_up = ((rx_sd & 0x1) && (val1 & (1<<9)) && ((val1 & (1<<8)) == 0));
+	if (link_up) {
+		vars->line_speed = SPEED_10000;
+		bnx2x_ext_phy_resolve_fc(phy, params, vars);
+	}
+	return link_up;
 }
 
 static u8 bnx2x_8706_8726_read_status(struct bnx2x_phy *phy,
@@ -4204,52 +3939,41 @@ static u8 bnx2x_8706_8726_read_status(struct bnx2x_phy *phy,
 	u8 link_up = 0;
 	u16 val1, val2, rx_sd, pcs_status;
 	struct bnx2x *bp = params->bp;
-			DP(NETIF_MSG_LINK, "XGXS 8706/8726\n");
-			/* Clear RX Alarm*/
-			bnx2x_cl45_read(bp, phy,
-				      MDIO_PMA_DEVAD, MDIO_PMA_REG_RX_ALARM,
-				      &val2);
-			/* clear LASI indication*/
-			bnx2x_cl45_read(bp, phy,
-				      MDIO_PMA_DEVAD, MDIO_PMA_REG_LASI_STATUS,
-				      &val1);
-			bnx2x_cl45_read(bp, phy,
-				      MDIO_PMA_DEVAD, MDIO_PMA_REG_LASI_STATUS,
-				      &val2);
-			DP(NETIF_MSG_LINK, "8706/8726 LASI status 0x%x-->"
-				     "0x%x\n", val1, val2);
+	DP(NETIF_MSG_LINK, "XGXS 8706/8726\n");
+	/* Clear RX Alarm*/
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_RX_ALARM, &val2);
+	/* clear LASI indication*/
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_LASI_STATUS, &val1);
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_LASI_STATUS, &val2);
+	DP(NETIF_MSG_LINK, "8706/8726 LASI status 0x%x--> 0x%x\n", val1, val2);
 
-			bnx2x_cl45_read(bp, phy,
-				      MDIO_PMA_DEVAD, MDIO_PMA_REG_RX_SD,
-				      &rx_sd);
-			bnx2x_cl45_read(bp, phy,
-				      MDIO_PCS_DEVAD, MDIO_PCS_REG_STATUS,
-				      &pcs_status);
-			bnx2x_cl45_read(bp, phy,
-				      MDIO_AN_DEVAD, MDIO_AN_REG_LINK_STATUS,
-				      &val2);
-			bnx2x_cl45_read(bp, phy,
-				      MDIO_AN_DEVAD, MDIO_AN_REG_LINK_STATUS,
-				      &val2);
-
-			DP(NETIF_MSG_LINK, "8706/8726 rx_sd 0x%x"
-			   "  pcs_status 0x%x 1Gbps link_status 0x%x\n",
-			   rx_sd, pcs_status, val2);
-			/* link is up if both bit 0 of pmd_rx_sd and
-			 * bit 0 of pcs_status are set, or if the autoneg bit
-			   1 is set
-			 */
-			link_up = ((rx_sd & pcs_status & 0x1) ||
-					(val2 & (1<<1)));
-			if (link_up) {
-				if (val2 & (1<<1))
-					vars->line_speed = SPEED_1000;
-				else
-					vars->line_speed = SPEED_10000;
-				bnx2x_ext_phy_resolve_fc(phy, params, vars);
-				return link_up;
-			}
-			return 0;
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_RX_SD, &rx_sd);
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PCS_DEVAD, MDIO_PCS_REG_STATUS, &pcs_status);
+	bnx2x_cl45_read(bp, phy,
+			MDIO_AN_DEVAD, MDIO_AN_REG_LINK_STATUS, &val2);
+	bnx2x_cl45_read(bp, phy,
+			MDIO_AN_DEVAD, MDIO_AN_REG_LINK_STATUS, &val2);
+
+	DP(NETIF_MSG_LINK, "8706/8726 rx_sd 0x%x pcs_status 0x%x 1Gbps"
+			" link_status 0x%x\n", rx_sd, pcs_status, val2);
+	/* link is up if both bit 0 of pmd_rx_sd and
+	 * bit 0 of pcs_status are set, or if the autoneg bit
+	 * 1 is set
+	 */
+	link_up = ((rx_sd & pcs_status & 0x1) || (val2 & (1<<1)));
+	if (link_up) {
+		if (val2 & (1<<1))
+			vars->line_speed = SPEED_1000;
+		else
+			vars->line_speed = SPEED_10000;
+		bnx2x_ext_phy_resolve_fc(phy, params, vars);
+	}
+	return link_up;
 }
 
 static u8 bnx2x_8706_read_status(struct bnx2x_phy *phy,
@@ -4284,312 +4008,217 @@ static u8 bnx2x_8727_read_status(struct bnx2x_phy *phy,
 
 {
 	struct bnx2x *bp = params->bp;
-	u8 ext_phy_link_up = 0;
-			u16 link_status = 0;
-			u16 rx_alarm_status, val1;
-			/* Check the LASI */
-			bnx2x_cl45_read(bp, phy,
-				      MDIO_PMA_DEVAD,
-				      MDIO_PMA_REG_RX_ALARM, &rx_alarm_status);
+	u8 link_up = 0;
+	u16 link_status = 0;
+	u16 rx_alarm_status, val1;
+	/* Check the LASI */
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_RX_ALARM,
+			&rx_alarm_status);
+	vars->line_speed = 0;
+	DP(NETIF_MSG_LINK, "8727 RX_ALARM_STATUS  0x%x\n", rx_alarm_status);
 
-			DP(NETIF_MSG_LINK, "8727 RX_ALARM_STATUS 0x%x\n",
-				 rx_alarm_status);
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_LASI_STATUS, &val1);
 
-			bnx2x_cl45_read(bp, phy,
-				      MDIO_PMA_DEVAD,
-				      MDIO_PMA_REG_LASI_STATUS, &val1);
+	DP(NETIF_MSG_LINK, "8727 LASI status 0x%x\n", val1);
 
-			DP(NETIF_MSG_LINK,
-				 "8727 LASI status 0x%x\n",
-				 val1);
+	/* Clear MSG-OUT */
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_M8051_MSGOUT_REG, &val1);
 
-			/* Clear MSG-OUT */
-			bnx2x_cl45_read(bp, phy,
-				      MDIO_PMA_DEVAD,
-				      MDIO_PMA_REG_M8051_MSGOUT_REG,
-				      &val1);
+	/**
+	 * If a module is present and there is need to check
+	 * for over current
+	 */
+	if (!(phy->flags & FLAGS_NOC) && !(rx_alarm_status & (1<<5))) {
+		/* Check over-current using 8727 GPIO0 input*/
+		bnx2x_cl45_read(bp, phy,
+				MDIO_PMA_DEVAD, MDIO_PMA_REG_8727_GPIO_CTRL,
+				&val1);
+
+		if ((val1 & (1<<8)) == 0) {
+			DP(NETIF_MSG_LINK, "8727 Power fault has been detected"
+				       " on port %d\n", params->port);
+			netdev_err(bp->dev, "Error:  Power fault on Port %d has"
+					    " been detected and the power to "
+					    "that SFP+ module has been removed"
+					    " to prevent failure of the card."
+					    " Please remove the SFP+ module and"
+					    " restart the system to clear this"
+					    " error.\n",
+				   params->port);
 
 			/*
-			 * If a module is present and there is need to check
-			 * for over current
+			 * Disable all RX_ALARMs except for
+			 * mod_abs
 			 */
-			if (!(phy->flags & FLAGS_NOC) &&
-			    !(rx_alarm_status & (1<<5))) {
-				/* Check over-current using 8727 GPIO0 input*/
-				bnx2x_cl45_read(bp, phy,
-					      MDIO_PMA_DEVAD,
-					      MDIO_PMA_REG_8727_GPIO_CTRL,
-					      &val1);
-
-				if ((val1 & (1<<8)) == 0) {
-					DP(NETIF_MSG_LINK, "8727 Power fault"
-						     " has been detected on "
-						     "port %d\n",
-						 params->port);
-					netdev_err(bp->dev, "Error:  Power fault on Port %d has been detected and the power to that SFP+ module has been removed to prevent failure of the card. Please remove the SFP+ module and restart the system to clear this error.\n",
-						   params->port);
-					/*
-					 * Disable all RX_ALARMs except for
-					 * mod_abs
-					 */
-					bnx2x_cl45_write(bp, phy,
-						     MDIO_PMA_DEVAD,
-						     MDIO_PMA_REG_RX_ALARM_CTRL,
-						     (1<<5));
-
-					bnx2x_cl45_read(bp, phy,
-						    MDIO_PMA_DEVAD,
-						    MDIO_PMA_REG_PHY_IDENTIFIER,
-						    &val1);
-					/* Wait for module_absent_event */
-					val1 |= (1<<8);
-					bnx2x_cl45_write(bp, phy,
-						    MDIO_PMA_DEVAD,
-						    MDIO_PMA_REG_PHY_IDENTIFIER,
-						    val1);
-					/* Clear RX alarm */
-					bnx2x_cl45_read(bp, phy,
-						      MDIO_PMA_DEVAD,
-						      MDIO_PMA_REG_RX_ALARM,
-						      &rx_alarm_status);
-					return ext_phy_link_up;
-				}
-			} /* Over current check */
-
-			/* When module absent bit is set, check module */
-			if (rx_alarm_status & (1<<5)) {
-				bnx2x_8727_handle_mod_abs(phy, params);
-				/* Enable all mod_abs and link detection bits */
-				bnx2x_cl45_write(bp, phy,
-					       MDIO_PMA_DEVAD,
-					       MDIO_PMA_REG_RX_ALARM_CTRL,
-					       ((1<<5) | (1<<2)));
-			}
+			bnx2x_cl45_write(bp, phy,
+					 MDIO_PMA_DEVAD,
+					 MDIO_PMA_REG_RX_ALARM_CTRL, (1<<5));
 
-			/* If transmitter is disabled,
-			ignore false link up indication */
 			bnx2x_cl45_read(bp, phy,
-				      MDIO_PMA_DEVAD,
-				      MDIO_PMA_REG_PHY_IDENTIFIER,
-				      &val1);
-			if (val1 & (1<<15)) {
-				DP(NETIF_MSG_LINK, "Tx is disabled\n");
-				ext_phy_link_up = 0;
-				return ext_phy_link_up;
-			}
-
+					MDIO_PMA_DEVAD,
+					MDIO_PMA_REG_PHY_IDENTIFIER, &val1);
+			/* Wait for module_absent_event */
+			val1 |= (1<<8);
+			bnx2x_cl45_write(bp, phy,
+					 MDIO_PMA_DEVAD,
+					 MDIO_PMA_REG_PHY_IDENTIFIER, val1);
+			/* Clear RX alarm */
 			bnx2x_cl45_read(bp, phy,
-				      MDIO_PMA_DEVAD,
-				      MDIO_PMA_REG_8073_SPEED_LINK_STATUS,
-				      &link_status);
-
-			/* Bits 0..2 --> speed detected,
-			   bits 13..15--> link is down */
-			if ((link_status & (1<<2)) &&
-			    (!(link_status & (1<<15)))) {
-				ext_phy_link_up = 1;
-				vars->line_speed = SPEED_10000;
-			} else if ((link_status & (1<<0)) &&
-				   (!(link_status & (1<<13)))) {
-				ext_phy_link_up = 1;
-				vars->line_speed = SPEED_1000;
-				DP(NETIF_MSG_LINK,
-					 "port %x: External link"
-					 " up in 1G\n", params->port);
-			} else {
-				ext_phy_link_up = 0;
-				DP(NETIF_MSG_LINK,
-					 "port %x: External link"
-					 " is down\n", params->port);
-			}
-			return ext_phy_link_up;
+				MDIO_PMA_DEVAD,
+				MDIO_PMA_REG_RX_ALARM, &rx_alarm_status);
+			return 0;
+		}
+	} /* Over current check */
 
+	/* When module absent bit is set, check module */
+	if (rx_alarm_status & (1<<5)) {
+		bnx2x_8727_handle_mod_abs(phy, params);
+		/* Enable all mod_abs and link detection bits */
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_PMA_DEVAD, MDIO_PMA_REG_RX_ALARM_CTRL,
+				 ((1<<5) | (1<<2)));
+	}
+
+	/* If transmitter is disabled, ignore false link up indication */
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_PHY_IDENTIFIER, &val1);
+	if (val1 & (1<<15)) {
+		DP(NETIF_MSG_LINK, "Tx is disabled\n");
+		return 0;
+	}
+
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD,
+			MDIO_PMA_REG_8073_SPEED_LINK_STATUS, &link_status);
+
+	/* Bits 0..2 --> speed detected,
+	   bits 13..15--> link is down */
+	if ((link_status & (1<<2)) && (!(link_status & (1<<15)))) {
+		link_up = 1;
+		vars->line_speed = SPEED_10000;
+	} else if ((link_status & (1<<0)) && (!(link_status & (1<<13)))) {
+		link_up = 1;
+		vars->line_speed = SPEED_1000;
+		DP(NETIF_MSG_LINK, "port %x: External link up in 1G\n",
+			   params->port);
+	} else {
+		link_up = 0;
+		DP(NETIF_MSG_LINK, "port %x: External link is down\n",
+			   params->port);
+	}
+	if (link_up)
+		bnx2x_ext_phy_resolve_fc(phy, params, vars);
+	return link_up;
 }
+
 static u8 bnx2x_8073_read_status(struct bnx2x_phy *phy,
 				 struct link_params *params,
 				 struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
-	u8 ext_phy_link_up = 0;
+	u8 link_up = 0;
 	u16 val1, val2;
-			u16 link_status = 0;
-			u16 an1000_status = 0;
+	u16 link_status = 0;
+	u16 an1000_status = 0;
 
-			if (phy->type ==
-			     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072) {
-				bnx2x_cl45_read(bp, phy,
-				      MDIO_PCS_DEVAD,
-				      MDIO_PCS_REG_LASI_STATUS, &val1);
-			bnx2x_cl45_read(bp, phy,
-				      MDIO_PCS_DEVAD,
-				      MDIO_PCS_REG_LASI_STATUS, &val2);
-			DP(NETIF_MSG_LINK,
-				 "870x LASI status 0x%x->0x%x\n",
-				  val1, val2);
-			} else {
-				/* In 8073, port1 is directed through emac0 and
-				 * port0 is directed through emac1
-				 */
-				bnx2x_cl45_read(bp, phy,
-					      MDIO_PMA_DEVAD,
-					      MDIO_PMA_REG_LASI_STATUS, &val1);
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_LASI_STATUS, &val1);
 
-				DP(NETIF_MSG_LINK,
-					 "8703 LASI status 0x%x\n",
-					  val1);
+	DP(NETIF_MSG_LINK, "8703 LASI status 0x%x\n", val1);
 
-			}
-			/* clear the interrupt LASI status register */
-			bnx2x_cl45_read(bp, phy,
-				      MDIO_PCS_DEVAD,
-				      MDIO_PCS_REG_STATUS, &val2);
-			bnx2x_cl45_read(bp, phy,
-				      MDIO_PCS_DEVAD,
-				      MDIO_PCS_REG_STATUS, &val1);
-			DP(NETIF_MSG_LINK, "807x PCS status 0x%x->0x%x\n",
-			   val2, val1);
-			/* Clear MSG-OUT */
-			bnx2x_cl45_read(bp, phy,
-				      MDIO_PMA_DEVAD,
-				      MDIO_PMA_REG_M8051_MSGOUT_REG,
-				      &val1);
+	/* clear the interrupt LASI status register */
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PCS_DEVAD, MDIO_PCS_REG_STATUS, &val2);
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PCS_DEVAD, MDIO_PCS_REG_STATUS, &val1);
+	DP(NETIF_MSG_LINK, "807x PCS status 0x%x->0x%x\n", val2, val1);
+	/* Clear MSG-OUT */
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_M8051_MSGOUT_REG, &val1);
 
-			/* Check the LASI */
-			bnx2x_cl45_read(bp, phy,
-				      MDIO_PMA_DEVAD,
-				      MDIO_PMA_REG_RX_ALARM, &val2);
+	/* Check the LASI */
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_RX_ALARM, &val2);
 
-			DP(NETIF_MSG_LINK, "KR 0x9003 0x%x\n", val2);
+	DP(NETIF_MSG_LINK, "KR 0x9003 0x%x\n", val2);
 
-			/* Check the link status */
-			bnx2x_cl45_read(bp, phy,
-				      MDIO_PCS_DEVAD,
-				      MDIO_PCS_REG_STATUS, &val2);
-			DP(NETIF_MSG_LINK, "KR PCS status 0x%x\n", val2);
+	/* Check the link status */
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PCS_DEVAD, MDIO_PCS_REG_STATUS, &val2);
+	DP(NETIF_MSG_LINK, "KR PCS status 0x%x\n", val2);
 
-			bnx2x_cl45_read(bp, phy,
-				      MDIO_PMA_DEVAD,
-				      MDIO_PMA_REG_STATUS, &val2);
-			bnx2x_cl45_read(bp, phy,
-				      MDIO_PMA_DEVAD,
-				      MDIO_PMA_REG_STATUS, &val1);
-			ext_phy_link_up = ((val1 & 4) == 4);
-			DP(NETIF_MSG_LINK, "PMA_REG_STATUS=0x%x\n", val1);
-			if (phy->type ==
-			    PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073) {
-
-				if (ext_phy_link_up &&
-				    ((params->req_line_speed !=
-					SPEED_10000))) {
-					if (bnx2x_8073_xaui_wa(bp, phy)
-					     != 0) {
-						ext_phy_link_up = 0;
-						return ext_phy_link_up;
-					}
-				}
-				bnx2x_cl45_read(bp, phy,
-					      MDIO_AN_DEVAD,
-					      MDIO_AN_REG_LINK_STATUS,
-					      &an1000_status);
-				bnx2x_cl45_read(bp, phy,
-					      MDIO_AN_DEVAD,
-					      MDIO_AN_REG_LINK_STATUS,
-					      &an1000_status);
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_STATUS, &val2);
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_STATUS, &val1);
+	link_up = ((val1 & 4) == 4);
+	DP(NETIF_MSG_LINK, "PMA_REG_STATUS=0x%x\n", val1);
 
-				/* Check the link status on 1.1.2 */
-				bnx2x_cl45_read(bp, phy,
-					      MDIO_PMA_DEVAD,
-					      MDIO_PMA_REG_STATUS, &val2);
-				bnx2x_cl45_read(bp, phy,
-					      MDIO_PMA_DEVAD,
-					      MDIO_PMA_REG_STATUS, &val1);
-				DP(NETIF_MSG_LINK, "KR PMA status 0x%x->0x%x,"
-					     "an_link_status=0x%x\n",
-					  val2, val1, an1000_status);
-
-				ext_phy_link_up = (((val1 & 4) == 4) ||
-						(an1000_status & (1<<1)));
-				if (ext_phy_link_up &&
-				    bnx2x_8073_is_snr_needed(bp, phy)) {
-					/* The SNR will improve about 2dbby
-					changing the BW and FEE main tap.*/
-
-					/* The 1st write to change FFE main
-					tap is set before restart AN */
-					/* Change PLL Bandwidth in EDC
-					register */
-					bnx2x_cl45_write(bp, phy,
-						    MDIO_PMA_DEVAD,
-						    MDIO_PMA_REG_PLL_BANDWIDTH,
-						    0x26BC);
-
-					/* Change CDR Bandwidth in EDC
-					register */
-					bnx2x_cl45_write(bp, phy,
-						    MDIO_PMA_DEVAD,
-						    MDIO_PMA_REG_CDR_BANDWIDTH,
-						    0x0333);
-				}
-				bnx2x_cl45_read(bp, phy,
-					   MDIO_PMA_DEVAD,
-					   MDIO_PMA_REG_8073_SPEED_LINK_STATUS,
-					   &link_status);
-
-				/* Bits 0..2 --> speed detected,
-				   bits 13..15--> link is down */
-				if ((link_status & (1<<2)) &&
-				    (!(link_status & (1<<15)))) {
-					ext_phy_link_up = 1;
-					vars->line_speed = SPEED_10000;
-					DP(NETIF_MSG_LINK,
-						 "port %x: External link"
-						 " up in 10G\n", params->port);
-				} else if ((link_status & (1<<1)) &&
-					   (!(link_status & (1<<14)))) {
-					ext_phy_link_up = 1;
-					vars->line_speed = SPEED_2500;
-					DP(NETIF_MSG_LINK,
-						 "port %x: External link"
-						 " up in 2.5G\n", params->port);
-				} else if ((link_status & (1<<0)) &&
-					   (!(link_status & (1<<13)))) {
-					ext_phy_link_up = 1;
-					vars->line_speed = SPEED_1000;
-					DP(NETIF_MSG_LINK,
-						 "port %x: External link"
-						 " up in 1G\n", params->port);
-				} else {
-					ext_phy_link_up = 0;
-					DP(NETIF_MSG_LINK,
-						 "port %x: External link"
-						 " is down\n", params->port);
-				}
-			} else {
-				/* See if 1G link is up for the 8072 */
-				bnx2x_cl45_read(bp, phy,
-					      MDIO_AN_DEVAD,
-					      MDIO_AN_REG_LINK_STATUS,
-					      &an1000_status);
-				bnx2x_cl45_read(bp, phy,
-					      MDIO_AN_DEVAD,
-					      MDIO_AN_REG_LINK_STATUS,
-					      &an1000_status);
-				if (an1000_status & (1<<1)) {
-					ext_phy_link_up = 1;
-					vars->line_speed = SPEED_1000;
-					DP(NETIF_MSG_LINK,
-						 "port %x: External link"
-						 " up in 1G\n", params->port);
-				} else if (ext_phy_link_up) {
-					ext_phy_link_up = 1;
-					vars->line_speed = SPEED_10000;
-					DP(NETIF_MSG_LINK,
-						 "port %x: External link"
-						 " up in 10G\n", params->port);
-				}
-			}
+	if (link_up &&
+	     ((phy->req_line_speed != SPEED_10000))) {
+		if (bnx2x_8073_xaui_wa(bp, phy) != 0)
+			return 0;
+	}
+	bnx2x_cl45_read(bp, phy,
+			MDIO_AN_DEVAD, MDIO_AN_REG_LINK_STATUS, &an1000_status);
+	bnx2x_cl45_read(bp, phy,
+			MDIO_AN_DEVAD, MDIO_AN_REG_LINK_STATUS, &an1000_status);
+
+	/* Check the link status on 1.1.2 */
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_STATUS, &val2);
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_STATUS, &val1);
+	DP(NETIF_MSG_LINK, "KR PMA status 0x%x->0x%x,"
+		   "an_link_status=0x%x\n", val2, val1, an1000_status);
+
+	link_up = (((val1 & 4) == 4) || (an1000_status & (1<<1)));
+	if (link_up && bnx2x_8073_is_snr_needed(bp, phy)) {
+		/* The SNR will improve about 2dbby
+		changing the BW and FEE main tap.*/
+		/* The 1st write to change FFE main
+		tap is set before restart AN */
+		/* Change PLL Bandwidth in EDC
+		register */
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_PMA_DEVAD, MDIO_PMA_REG_PLL_BANDWIDTH,
+				 0x26BC);
+
+		/* Change CDR Bandwidth in EDC register */
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_PMA_DEVAD, MDIO_PMA_REG_CDR_BANDWIDTH,
+				 0x0333);
+	}
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_8073_SPEED_LINK_STATUS,
+			&link_status);
+
+	/* Bits 0..2 --> speed detected, bits 13..15--> link is down */
+	if ((link_status & (1<<2)) && (!(link_status & (1<<15)))) {
+		link_up = 1;
+		vars->line_speed = SPEED_10000;
+		DP(NETIF_MSG_LINK, "port %x: External link up in 10G\n",
+			   params->port);
+	} else if ((link_status & (1<<1)) && (!(link_status & (1<<14)))) {
+		link_up = 1;
+		vars->line_speed = SPEED_2500;
+		DP(NETIF_MSG_LINK, "port %x: External link up in 2.5G\n",
+			   params->port);
+	} else if ((link_status & (1<<0)) && (!(link_status & (1<<13)))) {
+		link_up = 1;
+		vars->line_speed = SPEED_1000;
+		DP(NETIF_MSG_LINK, "port %x: External link up in 1G\n",
+			   params->port);
+	} else {
+		link_up = 0;
+		DP(NETIF_MSG_LINK, "port %x: External link is down\n",
+			   params->port);
+	}
 
-			return ext_phy_link_up;
+	return link_up;
 }
 
 static u8 bnx2x_7101_read_status(struct bnx2x_phy *phy,
@@ -4597,42 +4226,33 @@ static u8 bnx2x_7101_read_status(struct bnx2x_phy *phy,
 				 struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
-	u8 ext_phy_link_up;
+	u8 link_up;
 	u16 val1, val2;
-			bnx2x_cl45_read(bp, phy,
-				      MDIO_PMA_DEVAD,
-				      MDIO_PMA_REG_LASI_STATUS, &val2);
-			bnx2x_cl45_read(bp, phy,
-				      MDIO_PMA_DEVAD,
-				      MDIO_PMA_REG_LASI_STATUS, &val1);
-			DP(NETIF_MSG_LINK,
-				 "10G-base-T LASI status 0x%x->0x%x\n",
-				  val2, val1);
-			bnx2x_cl45_read(bp, phy,
-				      MDIO_PMA_DEVAD,
-				      MDIO_PMA_REG_STATUS, &val2);
-			bnx2x_cl45_read(bp, phy,
-				      MDIO_PMA_DEVAD,
-				      MDIO_PMA_REG_STATUS, &val1);
-			DP(NETIF_MSG_LINK,
-				 "10G-base-T PMA status 0x%x->0x%x\n",
-				 val2, val1);
-			ext_phy_link_up = ((val1 & 4) == 4);
-			/* if link is up
-			 * print the AN outcome of the SFX7101 PHY
-			 */
-			if (ext_phy_link_up) {
-				bnx2x_cl45_read(bp, phy,
-					      MDIO_AN_DEVAD,
-					      MDIO_AN_REG_MASTER_STATUS,
-					      &val2);
-				vars->line_speed = SPEED_10000;
-				DP(NETIF_MSG_LINK,
-					 "SFX7101 AN status 0x%x->Master=%x\n",
-					  val2,
-					 (val2 & (1<<14)));
-			}
-			return ext_phy_link_up;
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_LASI_STATUS, &val2);
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_LASI_STATUS, &val1);
+	DP(NETIF_MSG_LINK, "10G-base-T LASI status 0x%x->0x%x\n",
+		   val2, val1);
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_STATUS, &val2);
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_STATUS, &val1);
+	DP(NETIF_MSG_LINK, "10G-base-T PMA status 0x%x->0x%x\n",
+		   val2, val1);
+	link_up = ((val1 & 4) == 4);
+	/* if link is up
+	 * print the AN outcome of the SFX7101 PHY
+	 */
+	if (link_up) {
+		bnx2x_cl45_read(bp, phy,
+				MDIO_AN_DEVAD, MDIO_AN_REG_MASTER_STATUS,
+				&val2);
+		vars->line_speed = SPEED_10000;
+		DP(NETIF_MSG_LINK, "SFX7101 AN status 0x%x->Master=%x\n",
+			   val2, (val2 & (1<<14)));
+	}
+	return link_up;
 }
 
 static u8 bnx2x_848xx_read_status(struct bnx2x_phy *phy,
@@ -4640,73 +4260,78 @@ static u8 bnx2x_848xx_read_status(struct bnx2x_phy *phy,
 				       struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
-	u16 val1, val2;
-	u8 ext_phy_link_up = 0;
+	u16 val, val1, val2;
+	u8 link_up = 0;
 
-			/* Check 10G-BaseT link status */
-			/* Check PMD signal ok */
+	/* Check 10G-BaseT link status */
+	/* Check PMD signal ok */
+	bnx2x_cl45_read(bp, phy,
+			MDIO_AN_DEVAD, 0xFFFA, &val1);
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_8481_PMD_SIGNAL,
+			&val2);
+	DP(NETIF_MSG_LINK, "BCM848xx: PMD_SIGNAL 1.a811 = 0x%x\n", val2);
+
+	/* Check link 10G */
+	if (val2 & (1<<11)) {
+		vars->line_speed = SPEED_10000;
+		link_up = 1;
+	} else { /* Check Legacy speed link */
+		u16 legacy_status, legacy_speed;
+
+		/* Enable expansion register 0x42 (Operation mode status) */
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_AN_DEVAD,
+				 MDIO_AN_REG_8481_EXPANSION_REG_ACCESS, 0xf42);
+
+		/* Get legacy speed operation status */
+		bnx2x_cl45_read(bp, phy,
+				MDIO_AN_DEVAD,
+				MDIO_AN_REG_8481_EXPANSION_REG_RD_RW,
+				&legacy_status);
+
+		DP(NETIF_MSG_LINK, "Legacy speed status"
+			     " = 0x%x\n", legacy_status);
+		link_up = ((legacy_status & (1<<11)) == (1<<11));
+		if (link_up) {
+			legacy_speed = (legacy_status & (3<<9));
+			if (legacy_speed == (0<<9))
+				vars->line_speed = SPEED_10;
+			else if (legacy_speed == (1<<9))
+				vars->line_speed = SPEED_100;
+			else if (legacy_speed == (2<<9))
+				vars->line_speed = SPEED_1000;
+			else /* Should not happen */
+				vars->line_speed = 0;
+
+			if (legacy_status & (1<<8))
+				vars->duplex = DUPLEX_FULL;
+			else
+				vars->duplex = DUPLEX_HALF;
+
+			DP(NETIF_MSG_LINK, "Link is up in %dMbps,"
+				   " is_duplex_full= %d\n", vars->line_speed,
+				   (vars->duplex == DUPLEX_FULL));
+
+			/* Check legacy speed AN resolution */
 			bnx2x_cl45_read(bp, phy,
-						      MDIO_AN_DEVAD,
-						      0xFFFA,
-						      &val1);
+					MDIO_AN_DEVAD,
+					MDIO_AN_REG_8481_LEGACY_MII_STATUS,
+					&val);
+			if (val & (1<<5))
+				vars->link_status |=
+					LINK_STATUS_AUTO_NEGOTIATE_COMPLETE;
 			bnx2x_cl45_read(bp, phy,
-				      MDIO_PMA_DEVAD,
-				      MDIO_PMA_REG_8481_PMD_SIGNAL,
-				      &val2);
-			DP(NETIF_MSG_LINK, "PMD_SIGNAL 1.a811 = 0x%x\n", val2);
-
-			/* Check link 10G */
-			if (val2 & (1<<11)) {
-				vars->line_speed = SPEED_10000;
-				ext_phy_link_up = 1;
-			} else { /* Check Legacy speed link */
-				u16 legacy_status, legacy_speed;
-
-				/* Enable expansion register 0x42
-				(Operation mode status) */
-				bnx2x_cl45_write(bp, phy,
-					 MDIO_AN_DEVAD,
-					 MDIO_AN_REG_8481_EXPANSION_REG_ACCESS,
-					 0xf42);
-
-				/* Get legacy speed operation status */
-				bnx2x_cl45_read(bp, phy,
-					  MDIO_AN_DEVAD,
-					  MDIO_AN_REG_8481_EXPANSION_REG_RD_RW,
-					  &legacy_status);
-
-				DP(NETIF_MSG_LINK, "Legacy speed status"
-					     " = 0x%x\n", legacy_status);
-				ext_phy_link_up = ((legacy_status & (1<<11))
-						   == (1<<11));
-				if (ext_phy_link_up) {
-					legacy_speed = (legacy_status & (3<<9));
-					if (legacy_speed == (0<<9))
-						vars->line_speed = SPEED_10;
-					else if (legacy_speed == (1<<9))
-						vars->line_speed =
-							SPEED_100;
-					else if (legacy_speed == (2<<9))
-						vars->line_speed =
-							SPEED_1000;
-					else /* Should not happen */
-						vars->line_speed = 0;
-
-					if (legacy_status & (1<<8))
-						vars->duplex = DUPLEX_FULL;
-					else
-						vars->duplex = DUPLEX_HALF;
-
-					DP(NETIF_MSG_LINK, "Link is up "
-						     "in %dMbps, is_duplex_full"
-						     "= %d\n",
-						vars->line_speed,
-						(vars->duplex == DUPLEX_FULL));
-				}
-			}
-			return ext_phy_link_up;
+					MDIO_AN_DEVAD,
+					MDIO_AN_REG_8481_LEGACY_AN_EXPANSION,
+					&val);
+			if ((val & (1<<0)) == 0)
+				vars->link_status |=
+					LINK_STATUS_PARALLEL_DETECTION_USED;
+		}
+	}
+	return link_up;
 }
-
 static void bnx2x_link_int_enable(struct link_params *params)
 {
 	u8 port = params->port;
@@ -4847,7 +4472,6 @@ static void bnx2x_link_int_ack(struct link_params *params,
 				      NIG_STATUS_SERDES0_LINK_STATUS);
 		}
 
-	} else { /* link_down */
 	}
 }
 
@@ -4933,13 +4557,12 @@ u8 bnx2x_get_ext_phy_fw_version(struct link_params *params, u8 driver_loaded,
 }
 
 static void bnx2x_set_xgxs_loopback(struct bnx2x_phy *phy,
-				  struct link_params *params,
-				  u8 is_10g)
+				    struct link_params *params)
 {
 	u8 port = params->port;
 	struct bnx2x *bp = params->bp;
 
-	if (is_10g) {
+	if (phy->req_line_speed != SPEED_1000) {
 		u32 md_devad;
 
 		DP(NETIF_MSG_LINK, "XGXS 10G loopback enable\n");
@@ -5474,7 +5097,7 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 				if (params->phy[phy_index].config_loopback)
 					params->phy[phy_index].config_loopback(
 						&params->phy[phy_index],
-					       params);
+						params);
 			}
 		}
 
@@ -5714,7 +5337,7 @@ static u8 bnx2x_update_link_up(struct link_params *params,
  * - DUAL_MEDIA - The link between the 577xx and the first
  *   external phy needs to be up, and at least one of the 2
  *   external phy link must be up.
-*/
+ */
 u8 bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
@@ -6084,7 +5707,7 @@ static struct bnx2x_phy phy_8073 = {
 	.speed_cap_mask = 0,
 	.req_duplex	= 0,
 	.rsrv		= 0,
-	.config_init	= (config_init_t)bnx2x_8072_8073_config_init,
+	.config_init	= (config_init_t)bnx2x_8073_config_init,
 	.read_status	= (read_status_t)bnx2x_8073_read_status,
 	.link_reset	= (link_reset_t)bnx2x_8073_link_reset,
 	.config_loopback = (config_loopback_t)NULL,
@@ -6427,6 +6050,7 @@ static u8 bnx2x_populate_ext_phy(struct bnx2x *bp,
 	phy->addr = XGXS_EXT_PHY_ADDR(ext_phy_config);
 	bnx2x_populate_preemphasis(bp, shmem_base, phy, port, phy_index);
 	phy->mdio_ctrl = bnx2x_get_emac_base(bp, phy->type, port);
+
 	return 0;
 }
 
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 1ecff37..1184677 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -4348,7 +4348,6 @@ static int bnx2x_init_port(struct bnx2x *bp)
 		REG_WR(bp, reg_addr, val);
 		}
 		break;
-	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072:
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073:
 		bp->port.need_hw_lock = 1;
 		break;
-- 
1.7.1




