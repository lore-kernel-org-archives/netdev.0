From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net-next 4/9] bnx2x: Fix SFP+ current leakage
Date: Tue, 27 Nov 2012 15:46:31 +0200
Message-ID: <1354023996-3512-5-git-send-email-yanivr@broadcom.com>
References: <1354023996-3512-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1906 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754812Ab2K0LrW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2012 06:47:22 -0500
In-Reply-To: <1354023996-3512-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Per measurements, the SFP+ suffered from small current leakage in two cases:
 - When no module was plugged and TX laser was disabled. The fix was to enable
   it, and when module is plugged in, check if it needs to be disabled.
 - When over-current event occurs due to invalid SFP+ module, the HW basically
   shuts down the current for this module, but the SW needs to complete this
   by issuing a power down via a GPIO.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |   91 +++++++++++-----------
 1 files changed, 45 insertions(+), 46 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index e054921..a5fe2b9 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -4414,6 +4414,27 @@ static void bnx2x_warpcore_config_sfi(struct bnx2x_phy *phy,
 	}
 }
 
+static void bnx2x_sfp_e3_set_transmitter(struct link_params *params,
+					 struct bnx2x_phy *phy,
+					 u8 tx_en)
+{
+	struct bnx2x *bp = params->bp;
+	u32 cfg_pin;
+	u8 port = params->port;
+
+	cfg_pin = REG_RD(bp, params->shmem_base +
+			 offsetof(struct shmem_region,
+				  dev_info.port_hw_config[port].e3_sfp_ctrl)) &
+		PORT_HW_CFG_E3_TX_LASER_MASK;
+	/* Set the !tx_en since this pin is DISABLE_TX_LASER */
+	DP(NETIF_MSG_LINK, "Setting WC TX to %d\n", tx_en);
+
+	/* For 20G, the expected pin to be used is 3 pins after the current */
+	bnx2x_set_cfg_pin(bp, cfg_pin, tx_en ^ 1);
+	if (phy->speed_cap_mask & PORT_HW_CFG_SPEED_CAPABILITY_D0_20G)
+		bnx2x_set_cfg_pin(bp, cfg_pin + 3, tx_en ^ 1);
+}
+
 static void bnx2x_warpcore_config_init(struct bnx2x_phy *phy,
 				       struct link_params *params,
 				       struct link_vars *vars)
@@ -4474,9 +4495,14 @@ static void bnx2x_warpcore_config_init(struct bnx2x_phy *phy,
 			break;
 
 		case PORT_HW_CFG_NET_SERDES_IF_SFI:
-			/* Issue Module detection */
+			/* Issue Module detection if module is plugged, or
+			 * enabled transmitter to avoid current leakage in case
+			 * no module is connected
+			 */
 			if (bnx2x_is_sfp_module_plugged(phy, params))
 				bnx2x_sfp_module_detection(phy, params);
+			else
+				bnx2x_sfp_e3_set_transmitter(params, phy, 1);
 
 			bnx2x_warpcore_config_sfi(phy, params);
 			break;
@@ -4513,27 +4539,6 @@ static void bnx2x_warpcore_config_init(struct bnx2x_phy *phy,
 	DP(NETIF_MSG_LINK, "Exit config init\n");
 }
 
-static void bnx2x_sfp_e3_set_transmitter(struct link_params *params,
-					 struct bnx2x_phy *phy,
-					 u8 tx_en)
-{
-	struct bnx2x *bp = params->bp;
-	u32 cfg_pin;
-	u8 port = params->port;
-
-	cfg_pin = REG_RD(bp, params->shmem_base +
-				offsetof(struct shmem_region,
-				dev_info.port_hw_config[port].e3_sfp_ctrl)) &
-				PORT_HW_CFG_TX_LASER_MASK;
-	/* Set the !tx_en since this pin is DISABLE_TX_LASER */
-	DP(NETIF_MSG_LINK, "Setting WC TX to %d\n", tx_en);
-	/* For 20G, the expected pin to be used is 3 pins after the current */
-
-	bnx2x_set_cfg_pin(bp, cfg_pin, tx_en ^ 1);
-	if (phy->speed_cap_mask & PORT_HW_CFG_SPEED_CAPABILITY_D0_20G)
-		bnx2x_set_cfg_pin(bp, cfg_pin + 3, tx_en ^ 1);
-}
-
 static void bnx2x_warpcore_link_reset(struct bnx2x_phy *phy,
 				      struct link_params *params)
 {
@@ -7833,7 +7838,6 @@ static int bnx2x_8726_read_sfp_module_eeprom(struct bnx2x_phy *phy,
 }
 
 static void bnx2x_warpcore_power_module(struct link_params *params,
-					struct bnx2x_phy *phy,
 					u8 power)
 {
 	u32 pin_cfg;
@@ -7875,10 +7879,10 @@ static int bnx2x_warpcore_read_sfp_module_eeprom(struct bnx2x_phy *phy,
 	addr32 = addr & (~0x3);
 	do {
 		if ((!is_init) && (cnt == I2C_WA_PWR_ITER)) {
-			bnx2x_warpcore_power_module(params, phy, 0);
+			bnx2x_warpcore_power_module(params, 0);
 			/* Note that 100us are not enough here */
 			usleep_range(1000, 2000);
-			bnx2x_warpcore_power_module(params, phy, 1);
+			bnx2x_warpcore_power_module(params, 1);
 		}
 		rc = bnx2x_bsc_read(params, phy, 0xa0, addr32, 0, byte_cnt,
 				    data_array);
@@ -8464,7 +8468,7 @@ static void bnx2x_warpcore_hw_reset(struct bnx2x_phy *phy,
 				    struct link_params *params)
 {
 	struct bnx2x *bp = params->bp;
-	bnx2x_warpcore_power_module(params, phy, 0);
+	bnx2x_warpcore_power_module(params, 0);
 	/* Put Warpcore in low power mode */
 	REG_WR(bp, MISC_REG_WC0_RESET, 0x0c0e);
 
@@ -8487,7 +8491,7 @@ static void bnx2x_power_sfp_module(struct link_params *params,
 		bnx2x_8727_power_module(params->bp, phy, power);
 		break;
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT:
-		bnx2x_warpcore_power_module(params, phy, power);
+		bnx2x_warpcore_power_module(params, power);
 		break;
 	default:
 		break;
@@ -8560,7 +8564,8 @@ int bnx2x_sfp_module_detection(struct bnx2x_phy *phy,
 	u32 val = REG_RD(bp, params->shmem_base +
 			     offsetof(struct shmem_region, dev_info.
 				     port_feature_config[params->port].config));
-
+	/* Enabled transmitter by default */
+	bnx2x_sfp_set_transmitter(params, phy, 1);
 	DP(NETIF_MSG_LINK, "SFP+ module plugged in/out detected on port %d\n",
 		 params->port);
 	/* Power up module */
@@ -8593,14 +8598,12 @@ int bnx2x_sfp_module_detection(struct bnx2x_phy *phy,
 	 */
 	bnx2x_set_limiting_mode(params, phy, edc_mode);
 
-	/* Enable transmit for this module if the module is approved, or
-	 * if unapproved modules should also enable the Tx laser
+	/* Disable transmit for this module if the module is not approved, and
+	 * laser needs to be disabled.
 	 */
-	if (rc == 0 ||
-	    (val & PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_MASK) !=
-	    PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_DISABLE_TX_LASER)
-		bnx2x_sfp_set_transmitter(params, phy, 1);
-	else
+	if ((rc) &&
+	    ((val & PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_MASK) ==
+	     PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_DISABLE_TX_LASER))
 		bnx2x_sfp_set_transmitter(params, phy, 0);
 
 	return rc;
@@ -8612,11 +8615,13 @@ void bnx2x_handle_module_detect_int(struct link_params *params)
 	struct bnx2x_phy *phy;
 	u32 gpio_val;
 	u8 gpio_num, gpio_port;
-	if (CHIP_IS_E3(bp))
+	if (CHIP_IS_E3(bp)) {
 		phy = &params->phy[INT_PHY];
-	else
+		/* Always enable TX laser,will be disabled in case of fault */
+		bnx2x_sfp_set_transmitter(params, phy, 1);
+	} else {
 		phy = &params->phy[EXT_PHY1];
-
+	}
 	if (bnx2x_get_mod_abs_int_cfg(bp, params->chip_id, params->shmem_base,
 				      params->port, &gpio_num, &gpio_port) ==
 	    -EINVAL) {
@@ -8661,10 +8666,6 @@ void bnx2x_handle_module_detect_int(struct link_params *params)
 			DP(NETIF_MSG_LINK, "SFP+ module is not initialized\n");
 		}
 	} else {
-		u32 val = REG_RD(bp, params->shmem_base +
-				 offsetof(struct shmem_region, dev_info.
-					  port_feature_config[params->port].
-					  config));
 		bnx2x_set_gpio_int(bp, gpio_num,
 				   MISC_REGISTERS_GPIO_INT_OUTPUT_SET,
 				   gpio_port);
@@ -8672,10 +8673,6 @@ void bnx2x_handle_module_detect_int(struct link_params *params)
 		 * Disable transmit for this module
 		 */
 		phy->media_type = ETH_PHY_NOT_PRESENT;
-		if (((val & PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_MASK) ==
-		     PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_DISABLE_TX_LASER) ||
-		    CHIP_IS_E3(bp))
-			bnx2x_sfp_set_transmitter(params, phy, 0);
 	}
 }
 
@@ -9415,6 +9412,7 @@ static u8 bnx2x_8727_read_status(struct bnx2x_phy *phy,
 			bnx2x_cl45_read(bp, phy,
 				MDIO_PMA_DEVAD,
 				MDIO_PMA_LASI_RXSTAT, &rx_alarm_status);
+			bnx2x_8727_power_module(params->bp, phy, 0);
 			return 0;
 		}
 	} /* Over current check */
@@ -13194,6 +13192,7 @@ static void bnx2x_check_over_curr(struct link_params *params,
 					    " error.\n",
 			 params->port);
 			vars->phy_flags |= PHY_OVER_CURRENT_FLAG;
+			bnx2x_warpcore_power_module(params, 0);
 		}
 	} else
 		vars->phy_flags &= ~PHY_OVER_CURRENT_FLAG;
-- 
1.7.1
