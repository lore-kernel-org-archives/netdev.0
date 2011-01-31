From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net-next 06/10] bnx2x: Enhance SFP+ module control
Date: Mon, 31 Jan 2011 16:22:28 +0200
Message-ID: <1296483748.17181.116.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3424 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755246Ab1AaOZ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jan 2011 09:25:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add flexible support to control various SFP+ module features either throughout MDIO registers or GPIO pins according to NVRAM configuration

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_hsi.h  |   82 +++++++++++++-
 drivers/net/bnx2x/bnx2x_link.c |  251 +++++++++++++++++++++++++++++++++-------
 drivers/net/bnx2x/bnx2x_reg.h  |    1 +
 3 files changed, 289 insertions(+), 45 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_hsi.h b/drivers/net/bnx2x/bnx2x_hsi.h
index 548f563..34e313c 100644
--- a/drivers/net/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/bnx2x/bnx2x_hsi.h
@@ -237,8 +237,26 @@ struct port_hw_cfg {			    /* port 0: 0x12c  port 1: 0x2bc */
 #define PORT_HW_CFG_SERDES_RX_DRV_EQUALIZER_SHIFT	      16
 

-	u32 Reserved0[16];				    /* 0x158 */
-
+	u32 Reserved0[3];				    /* 0x158 */
+	/*	Controls the TX laser of the SFP+ module */
+	u32 sfp_ctrl;					/* 0x164 */
+#define PORT_HW_CFG_TX_LASER_MASK			      0x000000FF
+#define PORT_HW_CFG_TX_LASER_SHIFT			      0
+#define PORT_HW_CFG_TX_LASER_MDIO			      0x00000000
+#define PORT_HW_CFG_TX_LASER_GPIO0			      0x00000001
+#define PORT_HW_CFG_TX_LASER_GPIO1			      0x00000002
+#define PORT_HW_CFG_TX_LASER_GPIO2			      0x00000003
+#define PORT_HW_CFG_TX_LASER_GPIO3			      0x00000004
+
+    /*	Controls the fault module LED of the SFP+ */
+#define PORT_HW_CFG_FAULT_MODULE_LED_MASK		      0x0000FF00
+#define PORT_HW_CFG_FAULT_MODULE_LED_SHIFT		      8
+#define PORT_HW_CFG_FAULT_MODULE_LED_GPIO0		      0x00000000
+#define PORT_HW_CFG_FAULT_MODULE_LED_GPIO1		      0x00000100
+#define PORT_HW_CFG_FAULT_MODULE_LED_GPIO2		      0x00000200
+#define PORT_HW_CFG_FAULT_MODULE_LED_GPIO3		      0x00000300
+#define PORT_HW_CFG_FAULT_MODULE_LED_DISABLED		      0x00000400
+	u32 Reserved01[12];				    /* 0x158 */
 	/*  for external PHY, or forced mode or during AN */
 	u16 xgxs_config_rx[4];				    /* 0x198 */
 
@@ -246,6 +264,66 @@ struct port_hw_cfg {			    /* port 0: 0x12c  port 1: 0x2bc */
 
 	u32 Reserved1[56];				    /* 0x1A8 */
 	u32 default_cfg;				    /* 0x288 */
+#define PORT_HW_CFG_GPIO0_CONFIG_MASK			      0x00000003
+#define PORT_HW_CFG_GPIO0_CONFIG_SHIFT			      0
+#define PORT_HW_CFG_GPIO0_CONFIG_NA			      0x00000000
+#define PORT_HW_CFG_GPIO0_CONFIG_LOW			      0x00000001
+#define PORT_HW_CFG_GPIO0_CONFIG_HIGH			      0x00000002
+#define PORT_HW_CFG_GPIO0_CONFIG_INPUT			      0x00000003
+
+#define PORT_HW_CFG_GPIO1_CONFIG_MASK			      0x0000000C
+#define PORT_HW_CFG_GPIO1_CONFIG_SHIFT			      2
+#define PORT_HW_CFG_GPIO1_CONFIG_NA			      0x00000000
+#define PORT_HW_CFG_GPIO1_CONFIG_LOW			      0x00000004
+#define PORT_HW_CFG_GPIO1_CONFIG_HIGH			      0x00000008
+#define PORT_HW_CFG_GPIO1_CONFIG_INPUT			      0x0000000c
+
+#define PORT_HW_CFG_GPIO2_CONFIG_MASK			      0x00000030
+#define PORT_HW_CFG_GPIO2_CONFIG_SHIFT			      4
+#define PORT_HW_CFG_GPIO2_CONFIG_NA			      0x00000000
+#define PORT_HW_CFG_GPIO2_CONFIG_LOW			      0x00000010
+#define PORT_HW_CFG_GPIO2_CONFIG_HIGH			      0x00000020
+#define PORT_HW_CFG_GPIO2_CONFIG_INPUT			      0x00000030
+
+#define PORT_HW_CFG_GPIO3_CONFIG_MASK			      0x000000C0
+#define PORT_HW_CFG_GPIO3_CONFIG_SHIFT			      6
+#define PORT_HW_CFG_GPIO3_CONFIG_NA			      0x00000000
+#define PORT_HW_CFG_GPIO3_CONFIG_LOW			      0x00000040
+#define PORT_HW_CFG_GPIO3_CONFIG_HIGH			      0x00000080
+#define PORT_HW_CFG_GPIO3_CONFIG_INPUT			      0x000000c0
+
+	/*
+	 * When KR link is required to be set to force which is not
+	 * KR-compliant, this parameter determine what is the trigger for it.
+	 * When GPIO is selected, low input will force the speed. Currently
+	 * default speed is 1G. In the future, it may be widen to select the
+	 * forced speed in with another parameter. Note when force-1G is
+	 * enabled, it override option 56: Link Speed option.
+	 */
+#define PORT_HW_CFG_FORCE_KR_ENABLER_MASK		      0x00000F00
+#define PORT_HW_CFG_FORCE_KR_ENABLER_SHIFT		      8
+#define PORT_HW_CFG_FORCE_KR_ENABLER_NOT_FORCED		      0x00000000
+#define PORT_HW_CFG_FORCE_KR_ENABLER_GPIO0_P0		      0x00000100
+#define PORT_HW_CFG_FORCE_KR_ENABLER_GPIO1_P0		      0x00000200
+#define PORT_HW_CFG_FORCE_KR_ENABLER_GPIO2_P0		      0x00000300
+#define PORT_HW_CFG_FORCE_KR_ENABLER_GPIO3_P0		      0x00000400
+#define PORT_HW_CFG_FORCE_KR_ENABLER_GPIO0_P1		      0x00000500
+#define PORT_HW_CFG_FORCE_KR_ENABLER_GPIO1_P1		      0x00000600
+#define PORT_HW_CFG_FORCE_KR_ENABLER_GPIO2_P1		      0x00000700
+#define PORT_HW_CFG_FORCE_KR_ENABLER_GPIO3_P1		      0x00000800
+#define PORT_HW_CFG_FORCE_KR_ENABLER_FORCED		      0x00000900
+    /*	Enable to determine with which GPIO to reset the external phy */
+#define PORT_HW_CFG_EXT_PHY_GPIO_RST_MASK		      0x000F0000
+#define PORT_HW_CFG_EXT_PHY_GPIO_RST_SHIFT		      16
+#define PORT_HW_CFG_EXT_PHY_GPIO_RST_PHY_TYPE		      0x00000000
+#define PORT_HW_CFG_EXT_PHY_GPIO_RST_GPIO0_P0		      0x00010000
+#define PORT_HW_CFG_EXT_PHY_GPIO_RST_GPIO1_P0		      0x00020000
+#define PORT_HW_CFG_EXT_PHY_GPIO_RST_GPIO2_P0		      0x00030000
+#define PORT_HW_CFG_EXT_PHY_GPIO_RST_GPIO3_P0		      0x00040000
+#define PORT_HW_CFG_EXT_PHY_GPIO_RST_GPIO0_P1		      0x00050000
+#define PORT_HW_CFG_EXT_PHY_GPIO_RST_GPIO1_P1		      0x00060000
+#define PORT_HW_CFG_EXT_PHY_GPIO_RST_GPIO2_P1		      0x00070000
+#define PORT_HW_CFG_EXT_PHY_GPIO_RST_GPIO3_P1		      0x00080000
 	/*  Enable BAM on KR */
 #define PORT_HW_CFG_ENABLE_BAM_ON_KR_MASK		      0x00100000
 #define PORT_HW_CFG_ENABLE_BAM_ON_KR_SHIFT		      20
diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index c02f744..6007dce 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -4508,30 +4508,74 @@ static u8 bnx2x_8705_read_status(struct bnx2x_phy *phy,
 /******************************************************************/
 /*			SFP+ module Section			  */
 /******************************************************************/
-static void bnx2x_sfp_set_transmitter(struct bnx2x *bp,
+static u8 bnx2x_get_gpio_port(struct link_params *params)
+{
+	u8 gpio_port;
+	u32 swap_val, swap_override;
+	struct bnx2x *bp = params->bp;
+	if (CHIP_IS_E2(bp))
+		gpio_port = BP_PATH(bp);
+	else
+		gpio_port = params->port;
+	swap_val = REG_RD(bp, NIG_REG_PORT_SWAP);
+	swap_override = REG_RD(bp, NIG_REG_STRAP_OVERRIDE);
+	return gpio_port ^ (swap_val && swap_override);
+}
+static void bnx2x_sfp_set_transmitter(struct link_params *params,
 				      struct bnx2x_phy *phy,
-				      u8 port,
 				      u8 tx_en)
 {
 	u16 val;
+	u8 port = params->port;
+	struct bnx2x *bp = params->bp;
+	u32 tx_en_mode;
 
-	DP(NETIF_MSG_LINK, "Setting transmitter tx_en=%x for port %x\n",
-		 tx_en, port);
 	/* Disable/Enable transmitter ( TX laser of the SFP+ module.)*/
-	bnx2x_cl45_read(bp, phy,
-		      MDIO_PMA_DEVAD,
-		      MDIO_PMA_REG_PHY_IDENTIFIER,
-		      &val);
+	tx_en_mode = REG_RD(bp, params->shmem_base +
+			    offsetof(struct shmem_region,
+				     dev_info.port_hw_config[port].sfp_ctrl)) &
+		PORT_HW_CFG_TX_LASER_MASK;
+	DP(NETIF_MSG_LINK, "Setting transmitter tx_en=%x for port %x "
+			   "mode = %x\n", tx_en, port, tx_en_mode);
+	switch (tx_en_mode) {
+	case PORT_HW_CFG_TX_LASER_MDIO:
 
-	if (tx_en)
-		val &= ~(1<<15);
-	else
-		val |= (1<<15);
+		bnx2x_cl45_read(bp, phy,
+				MDIO_PMA_DEVAD,
+				MDIO_PMA_REG_PHY_IDENTIFIER,
+				&val);
 
-	bnx2x_cl45_write(bp, phy,
-		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_PHY_IDENTIFIER,
-		       val);
+		if (tx_en)
+			val &= ~(1<<15);
+		else
+			val |= (1<<15);
+
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_PMA_DEVAD,
+				 MDIO_PMA_REG_PHY_IDENTIFIER,
+				 val);
+	break;
+	case PORT_HW_CFG_TX_LASER_GPIO0:
+	case PORT_HW_CFG_TX_LASER_GPIO1:
+	case PORT_HW_CFG_TX_LASER_GPIO2:
+	case PORT_HW_CFG_TX_LASER_GPIO3:
+	{
+		u16 gpio_pin;
+		u8 gpio_port, gpio_mode;
+		if (tx_en)
+			gpio_mode = MISC_REGISTERS_GPIO_OUTPUT_HIGH;
+		else
+			gpio_mode = MISC_REGISTERS_GPIO_OUTPUT_LOW;
+
+		gpio_pin = tx_en_mode - PORT_HW_CFG_TX_LASER_GPIO0;
+		gpio_port = bnx2x_get_gpio_port(params);
+		bnx2x_set_gpio(bp, gpio_pin, gpio_mode, gpio_port);
+		break;
+	}
+	default:
+		DP(NETIF_MSG_LINK, "Invalid TX_LASER_MDIO 0x%x\n", tx_en_mode);
+		break;
+	}
 }
 
 static u8 bnx2x_8726_read_sfp_module_eeprom(struct bnx2x_phy *phy,
@@ -5010,11 +5054,11 @@ static void bnx2x_8727_specific_func(struct bnx2x_phy *phy,
 
 	switch (action) {
 	case DISABLE_TX:
-		bnx2x_sfp_set_transmitter(bp, phy, params->port, 0);
+		bnx2x_sfp_set_transmitter(params, phy, 0);
 		break;
 	case ENABLE_TX:
 		if (!(phy->flags & FLAGS_SFP_NOT_APPROVED))
-			bnx2x_sfp_set_transmitter(bp, phy, params->port, 1);
+			bnx2x_sfp_set_transmitter(params, phy, 1);
 		break;
 	default:
 		DP(NETIF_MSG_LINK, "Function 0x%x not supported by 8727\n",
@@ -5023,6 +5067,38 @@ static void bnx2x_8727_specific_func(struct bnx2x_phy *phy,
 	}
 }
 
+static void bnx2x_set_sfp_module_fault_led(struct link_params *params,
+					   u8 gpio_mode)
+{
+	struct bnx2x *bp = params->bp;
+
+	u32 fault_led_gpio = REG_RD(bp, params->shmem_base +
+			    offsetof(struct shmem_region,
+			dev_info.port_hw_config[params->port].sfp_ctrl)) &
+		PORT_HW_CFG_FAULT_MODULE_LED_MASK;
+	switch (fault_led_gpio) {
+	case PORT_HW_CFG_FAULT_MODULE_LED_DISABLED:
+		return;
+	case PORT_HW_CFG_FAULT_MODULE_LED_GPIO0:
+	case PORT_HW_CFG_FAULT_MODULE_LED_GPIO1:
+	case PORT_HW_CFG_FAULT_MODULE_LED_GPIO2:
+	case PORT_HW_CFG_FAULT_MODULE_LED_GPIO3:
+	{
+		u8 gpio_port = bnx2x_get_gpio_port(params);
+		u16 gpio_pin = fault_led_gpio -
+			PORT_HW_CFG_FAULT_MODULE_LED_GPIO0;
+		DP(NETIF_MSG_LINK, "Set fault module-detected led "
+				   "pin %x port %x mode %x\n",
+			       gpio_pin, gpio_port, gpio_mode);
+		bnx2x_set_gpio(bp, gpio_pin, gpio_mode, gpio_port);
+	}
+	break;
+	default:
+		DP(NETIF_MSG_LINK, "Error: Invalid fault led mode 0x%x\n",
+			       fault_led_gpio);
+	}
+}
+
 static u8 bnx2x_sfp_module_detection(struct bnx2x_phy *phy,
 				     struct link_params *params)
 {
@@ -5045,9 +5121,9 @@ static u8 bnx2x_sfp_module_detection(struct bnx2x_phy *phy,
 		DP(NETIF_MSG_LINK, "Module verification failed!!\n");
 		rc = -EINVAL;
 		/* Turn on fault module-detected led */
-		bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_0,
-				  MISC_REGISTERS_GPIO_HIGH,
-				  params->port);
+		bnx2x_set_sfp_module_fault_led(params,
+					       MISC_REGISTERS_GPIO_HIGH);
+
 		if ((phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727) &&
 		    ((val & PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_MASK) ==
 		     PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_POWER_DOWN)) {
@@ -5058,10 +5134,7 @@ static u8 bnx2x_sfp_module_detection(struct bnx2x_phy *phy,
 		}
 	} else {
 		/* Turn off fault module-detected led */
-		DP(NETIF_MSG_LINK, "Turn off fault module-detected led\n");
-		bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_0,
-					  MISC_REGISTERS_GPIO_LOW,
-					  params->port);
+		bnx2x_set_sfp_module_fault_led(params, MISC_REGISTERS_GPIO_LOW);
 	}
 
 	/* power up the SFP module */
@@ -5083,9 +5156,9 @@ static u8 bnx2x_sfp_module_detection(struct bnx2x_phy *phy,
 	if (rc == 0 ||
 	    (val & PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_MASK) !=
 	    PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_DISABLE_TX_LASER)
-		bnx2x_sfp_set_transmitter(bp, phy, params->port, 1);
+		bnx2x_sfp_set_transmitter(params, phy, 1);
 	else
-		bnx2x_sfp_set_transmitter(bp, phy, params->port, 0);
+		bnx2x_sfp_set_transmitter(params, phy, 0);
 
 	return rc;
 }
@@ -5098,9 +5171,7 @@ void bnx2x_handle_module_detect_int(struct link_params *params)
 	u8 port = params->port;
 
 	/* Set valid module led off */
-	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_0,
-			  MISC_REGISTERS_GPIO_HIGH,
-			  params->port);
+	bnx2x_set_sfp_module_fault_led(params, MISC_REGISTERS_GPIO_HIGH);
 
 	/* Get current gpio val reflecting module plugged in / out*/
 	gpio_val = bnx2x_get_gpio(bp, MISC_REGISTERS_GPIO_3, port);
@@ -5131,7 +5202,7 @@ void bnx2x_handle_module_detect_int(struct link_params *params)
 		 */
 		if ((val & PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_MASK) ==
 		    PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_DISABLE_TX_LASER)
-			bnx2x_sfp_set_transmitter(bp, phy, params->port, 0);
+			bnx2x_sfp_set_transmitter(params, phy, 0);
 	}
 }
 
@@ -5190,7 +5261,8 @@ static u8 bnx2x_8706_config_init(struct bnx2x_phy *phy,
 				 struct link_params *params,
 				 struct link_vars *vars)
 {
-	u16 cnt, val;
+	u32 tx_en_mode;
+	u16 cnt, val, tmp1;
 	struct bnx2x *bp = params->bp;
 	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
 		       MISC_REGISTERS_GPIO_OUTPUT_HIGH, params->port);
@@ -5264,6 +5336,26 @@ static u8 bnx2x_8706_config_init(struct bnx2x_phy *phy,
 				 0x0004);
 	}
 	bnx2x_save_bcm_spirom_ver(bp, phy, params->port);
+
+	/*
+	 * If TX Laser is controlled by GPIO_0, do not let PHY go into low
+	 * power mode, if TX Laser is disabled
+	 */
+
+	tx_en_mode = REG_RD(bp, params->shmem_base +
+			    offsetof(struct shmem_region,
+				dev_info.port_hw_config[params->port].sfp_ctrl))
+			& PORT_HW_CFG_TX_LASER_MASK;
+
+	if (tx_en_mode == PORT_HW_CFG_TX_LASER_GPIO0) {
+		DP(NETIF_MSG_LINK, "Enabling TXONOFF_PWRDN_DIS\n");
+		bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_DIGITAL_CTRL, &tmp1);
+		tmp1 |= 0x1;
+		bnx2x_cl45_write(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_DIGITAL_CTRL, tmp1);
+	}
+
 	return 0;
 }
 
@@ -5352,12 +5444,6 @@ static u8 bnx2x_8726_config_init(struct bnx2x_phy *phy,
 	u32 val;
 	u32 swap_val, swap_override, aeu_gpio_mask, offset;
 	DP(NETIF_MSG_LINK, "Initializing BCM8726\n");
-	/* Restore normal power mode*/
-	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
-			    MISC_REGISTERS_GPIO_OUTPUT_HIGH, params->port);
-
-	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1,
-			    MISC_REGISTERS_GPIO_OUTPUT_HIGH, params->port);
 
 	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, MDIO_PMA_REG_CTRL, 1<<15);
 	bnx2x_wait_reset_complete(bp, phy, params);
@@ -5544,7 +5630,8 @@ static u8 bnx2x_8727_config_init(struct bnx2x_phy *phy,
 				 struct link_params *params,
 				 struct link_vars *vars)
 {
-	u16 tmp1, val, mod_abs;
+	u32 tx_en_mode;
+	u16 tmp1, val, mod_abs, tmp2;
 	u16 rx_alarm_ctrl_val;
 	u16 lasi_ctrl_val;
 	struct bnx2x *bp = params->bp;
@@ -5681,6 +5768,26 @@ static u8 bnx2x_8727_config_init(struct bnx2x_phy *phy,
 				 phy->tx_preemphasis[1]);
 	}
 
+	/*
+	 * If TX Laser is controlled by GPIO_0, do not let PHY go into low
+	 * power mode, if TX Laser is disabled
+	 */
+	tx_en_mode = REG_RD(bp, params->shmem_base +
+			    offsetof(struct shmem_region,
+				dev_info.port_hw_config[params->port].sfp_ctrl))
+			& PORT_HW_CFG_TX_LASER_MASK;
+
+	if (tx_en_mode == PORT_HW_CFG_TX_LASER_GPIO0) {
+
+		DP(NETIF_MSG_LINK, "Enabling TXONOFF_PWRDN_DIS\n");
+		bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_8727_OPT_CFG_REG, &tmp2);
+		tmp2 |= 0x1000;
+		tmp2 &= 0xFFEF;
+		bnx2x_cl45_write(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_8727_OPT_CFG_REG, tmp2);
+	}
+
 	return 0;
 }
 
@@ -5757,7 +5864,7 @@ static void bnx2x_8727_handle_mod_abs(struct bnx2x_phy *phy,
 
 		if ((val & PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_MASK) ==
 		    PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_DISABLE_TX_LASER)
-			bnx2x_sfp_set_transmitter(bp, phy, params->port, 0);
+			bnx2x_sfp_set_transmitter(params, phy, 0);
 
 		if (bnx2x_wait_for_sfp_module_initialized(phy, params) == 0)
 			bnx2x_sfp_module_detection(phy, params);
@@ -5917,7 +6024,7 @@ static void bnx2x_8727_link_reset(struct bnx2x_phy *phy,
 {
 	struct bnx2x *bp = params->bp;
 	/* Disable Transmitter */
-	bnx2x_sfp_set_transmitter(bp, phy, params->port, 0);
+	bnx2x_sfp_set_transmitter(params, phy, 0);
 	/* Clear LASI */
 	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, MDIO_PMA_REG_LASI_CTRL, 0);
 
@@ -7918,12 +8025,57 @@ static u8 bnx2x_8726_common_init_phy(struct bnx2x *bp,
 
 	return 0;
 }
+static void bnx2x_get_ext_phy_reset_gpio(struct bnx2x *bp, u32 shmem_base,
+					 u8 *io_gpio, u8 *io_port)
+{
+
+	u32 phy_gpio_reset = REG_RD(bp, shmem_base +
+					  offsetof(struct shmem_region,
+				dev_info.port_hw_config[PORT_0].default_cfg));
+	switch (phy_gpio_reset) {
+	case PORT_HW_CFG_EXT_PHY_GPIO_RST_GPIO0_P0:
+		*io_gpio = 0;
+		*io_port = 0;
+		break;
+	case PORT_HW_CFG_EXT_PHY_GPIO_RST_GPIO1_P0:
+		*io_gpio = 1;
+		*io_port = 0;
+		break;
+	case PORT_HW_CFG_EXT_PHY_GPIO_RST_GPIO2_P0:
+		*io_gpio = 2;
+		*io_port = 0;
+		break;
+	case PORT_HW_CFG_EXT_PHY_GPIO_RST_GPIO3_P0:
+		*io_gpio = 3;
+		*io_port = 0;
+		break;
+	case PORT_HW_CFG_EXT_PHY_GPIO_RST_GPIO0_P1:
+		*io_gpio = 0;
+		*io_port = 1;
+		break;
+	case PORT_HW_CFG_EXT_PHY_GPIO_RST_GPIO1_P1:
+		*io_gpio = 1;
+		*io_port = 1;
+		break;
+	case PORT_HW_CFG_EXT_PHY_GPIO_RST_GPIO2_P1:
+		*io_gpio = 2;
+		*io_port = 1;
+		break;
+	case PORT_HW_CFG_EXT_PHY_GPIO_RST_GPIO3_P1:
+		*io_gpio = 3;
+		*io_port = 1;
+		break;
+	default:
+		/* Don't override the io_gpio and io_port */
+		break;
+	}
+}
 static u8 bnx2x_8727_common_init_phy(struct bnx2x *bp,
 				     u32 shmem_base_path[],
 				     u32 shmem2_base_path[], u8 phy_index,
 				     u32 chip_id)
 {
-	s8 port;
+	s8 port, reset_gpio;
 	u32 swap_val, swap_override;
 	struct bnx2x_phy phy[PORT_MAX];
 	struct bnx2x_phy *phy_blk[PORT_MAX];
@@ -7931,13 +8083,26 @@ static u8 bnx2x_8727_common_init_phy(struct bnx2x *bp,
 	swap_val = REG_RD(bp, NIG_REG_PORT_SWAP);
 	swap_override = REG_RD(bp, NIG_REG_STRAP_OVERRIDE);
 
+	reset_gpio = MISC_REGISTERS_GPIO_1;
 	port = 1;
 
-	bnx2x_ext_phy_hw_reset(bp, port ^ (swap_val && swap_override));
+	/*
+	 * Retrieve the reset gpio/port which control the reset.
+	 * Default is GPIO1, PORT1
+	 */
+	bnx2x_get_ext_phy_reset_gpio(bp, shmem_base_path[0],
+				     (u8 *)&reset_gpio, (u8 *)&port);
 
 	/* Calculate the port based on port swap */
 	port ^= (swap_val && swap_override);
 
+	/* Initiate PHY reset*/
+	bnx2x_set_gpio(bp, reset_gpio, MISC_REGISTERS_GPIO_OUTPUT_LOW,
+		       port);
+	msleep(1);
+	bnx2x_set_gpio(bp, reset_gpio, MISC_REGISTERS_GPIO_OUTPUT_HIGH,
+		       port);
+
 	msleep(5);
 
 	/* PART1 - Reset both phys */
diff --git a/drivers/net/bnx2x/bnx2x_reg.h b/drivers/net/bnx2x/bnx2x_reg.h
index e01330b..1c89f19 100644
--- a/drivers/net/bnx2x/bnx2x_reg.h
+++ b/drivers/net/bnx2x/bnx2x_reg.h
@@ -6083,6 +6083,7 @@ Theotherbitsarereservedandshouldbezero*/
 #define MDIO_PMA_REG_8727_PCS_OPT_CTRL		0xc808
 #define MDIO_PMA_REG_8727_GPIO_CTRL		0xc80e
 #define MDIO_PMA_REG_8727_PCS_GP		0xc842
+#define MDIO_PMA_REG_8727_OPT_CFG_REG		0xc8e4
 
 #define MDIO_AN_REG_8727_MISC_CTRL		0x8309
 
-- 
1.7.1





