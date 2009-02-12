From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 14/41]bnx2x: Supporting BCM8726 PHY
Date: Thu, 12 Feb 2009 20:36:55 +0200
Message-ID: <1234463815.1863.146.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2944 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756963AbZBLSpI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 13:45:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 14/41]bnx2x: Supporting BCM8726 PHY
Also adding the ability to recognize the optic module and disable it if it is
not authorized for safety reasons - since this feature might upset some users
which are willing to take the risk, it is optional and can be disabled by
setting an nvram bit (or a trivial driver patch to set this bit).
This dual port PHY requires special handling if the ports are swapped.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_hsi.h  |   13 +-
 drivers/net/bnx2x_link.c |  776 +++++++++++++++++++++++++++++++++++++++++++---
 drivers/net/bnx2x_link.h |   14 +-
 drivers/net/bnx2x_main.c |   90 +++++-
 drivers/net/bnx2x_reg.h  |   22 ++
 5 files changed, 851 insertions(+), 64 deletions(-)

diff --git a/drivers/net/bnx2x_hsi.h b/drivers/net/bnx2x_hsi.h
index 85e4df6..7b9acb3 100644
--- a/drivers/net/bnx2x_hsi.h
+++ b/drivers/net/bnx2x_hsi.h
@@ -245,7 +245,7 @@ struct port_hw_cfg {			    /* port 0: 0x12c  port 1: 0x2bc */
 #define PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073	    0x00000300
 #define PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705	    0x00000400
 #define PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706	    0x00000500
-#define PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8276	    0x00000600
+#define PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726	    0x00000600
 #define PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481	    0x00000700
 #define PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101	    0x00000800
 #define PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE	    0x0000fd00
@@ -299,6 +299,12 @@ struct shared_feat_cfg {				 /* NVRAM Offset */
 
 	u32 config;						/* 0x450 */
 #define SHARED_FEATURE_BMC_ECHO_MODE_EN 	    0x00000001
+
+	/*  Use the values from options 47 and 48 instead of the HW default
+	  values */
+#define SHARED_FEAT_CFG_OVERRIDE_PREEMPHASIS_CFG_DISABLED     0x00000000
+#define SHARED_FEAT_CFG_OVERRIDE_PREEMPHASIS_CFG_ENABLED      0x00000002
+
 #define SHARED_FEATURE_MF_MODE_DISABLED 	    0x00000100
 
 };
@@ -352,6 +358,11 @@ struct port_feat_cfg {			    /* port 0: 0x454  port 1: 0x4c8 */
 #define PORT_FEATURE_MBA_ENABLED		    0x02000000
 #define PORT_FEATURE_MFW_ENABLED		    0x04000000
 
+	/*  Check the optic vendor via i2c before allowing it to be used by
+	  SW */
+#define PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_DISABLED 	      0x00000000
+#define PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_ENABLED		      0x08000000
+
 	u32 wol_config;
 	/* Default is used when driver sets to "auto" mode */
 #define PORT_FEATURE_WOL_DEFAULT_MASK		    0x00000003
diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index aea26b4..55f50c7 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -139,6 +139,26 @@
 #define PHY_SGMII_FLAG			0x2
 #define PHY_SERDES_FLAG			0x4
 
+/* */
+#define SFP_EEPROM_CON_TYPE_ADDR		0x2
+	#define SFP_EEPROM_CON_TYPE_VAL_LC 		0x7
+	#define SFP_EEPROM_CON_TYPE_VAL_COPPER	0x21
+
+#define SFP_EEPROM_FC_TX_TECH_ADDR		0x8
+	#define SFP_EEPROM_FC_TX_TECH_BITMASK_COPPER_PASSIVE 0x4
+	#define SFP_EEPROM_FC_TX_TECH_BITMASK_COPPER_ACTIVE	 0x8
+#define SFP_EEPROM_VENDOR_NAME_ADDR		0x14
+#define SFP_EEPROM_VENDOR_NAME_SIZE 	16
+#define SFP_EEPROM_OPTIONS_ADDR 		0x40
+	#define SFP_EEPROM_OPTIONS_LINEAR_RX_OUT_MASK 0x1
+#define SFP_EEPROM_OPTIONS_SIZE 		2
+
+#define SFP_MODULE_TYPE_UNKNOWN 			0x0
+#define SFP_MODULE_TYPE_LC   			0x1
+#define SFP_MODULE_TYPE_ACTIVE_COPPER_CABLE		0x2
+#define SFP_MODULE_TYPE_PASSIVE_COPPER_CABLE	0x3
+
+#define SFP_LIMITING_MODE_VALUE 			0x0044
 /**********************************************************/
 /*                     INTERFACE                          */
 /**********************************************************/
@@ -749,12 +769,17 @@ static u8 bnx2x_pbf_update(struct link_params *params, u32 flow_ctrl,
 	return 0;
 }
 
-static u32 bnx2x_get_emac_base(u32 ext_phy_type, u8 port)
+static u32 bnx2x_get_emac_base(struct bnx2x *bp, u32 ext_phy_type, u8 port)
 {
 	u32 emac_base;
 	switch (ext_phy_type) {
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072:
-		emac_base = GRCBASE_EMAC0;
+	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726:
+		/* All MDC/MDIO is directed through single EMAC */
+		if (REG_RD(bp, NIG_REG_PORT_SWAP))
+			emac_base = GRCBASE_EMAC0;
+		else
+			emac_base = GRCBASE_EMAC1;
 		break;
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073:
 		emac_base = (port) ? GRCBASE_EMAC0 : GRCBASE_EMAC1;
@@ -772,11 +797,12 @@ u8 bnx2x_cl45_write(struct bnx2x *bp, u8 port, u32 ext_phy_type,
 {
 	u32 tmp, saved_mode;
 	u8 i, rc = 0;
-	u32 mdio_ctrl = bnx2x_get_emac_base(ext_phy_type, port);
+	u32 mdio_ctrl = bnx2x_get_emac_base(bp, ext_phy_type, port);
 
 	/* set clause 45 mode, slow down the MDIO clock to 2.5MHz
 	 * (a value of 49==0x31) and make sure that the AUTO poll is off
 	 */
+
 	saved_mode = REG_RD(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE);
 	tmp = saved_mode & ~(EMAC_MDIO_MODE_AUTO_POLL |
 			     EMAC_MDIO_MODE_CLOCK_CNT);
@@ -841,10 +867,11 @@ u8 bnx2x_cl45_read(struct bnx2x *bp, u8 port, u32 ext_phy_type,
 	u16 i;
 	u8 rc = 0;
 
-	u32 mdio_ctrl = bnx2x_get_emac_base(ext_phy_type, port);
+	u32 mdio_ctrl = bnx2x_get_emac_base(bp, ext_phy_type, port);
 	/* set clause 45 mode, slow down the MDIO clock to 2.5MHz
 	 * (a value of 49==0x31) and make sure that the AUTO poll is off
 	 */
+
 	saved_mode = REG_RD(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE);
 	val = saved_mode & ((EMAC_MDIO_MODE_AUTO_POLL |
 			     EMAC_MDIO_MODE_CLOCK_CNT));
@@ -1726,7 +1753,9 @@ static u8 bnx2x_link_settings_status(struct link_params *params,
 		    ((XGXS_EXT_PHY_TYPE(params->ext_phy_config) ==
 		     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT) ||
 		    (XGXS_EXT_PHY_TYPE(params->ext_phy_config) ==
-		     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705))) {
+		     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705) ||
+		    (XGXS_EXT_PHY_TYPE(params->ext_phy_config) ==
+		     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726))) {
 			vars->autoneg = AUTO_NEG_ENABLED;
 
 			if (gp_status & MDIO_AN_CL73_OR_37_COMPLETE) {
@@ -1902,6 +1931,25 @@ static void bnx2x_ext_phy_reset(struct link_params *params,
 				       MDIO_PMA_DEVAD,
 				       MDIO_PMA_REG_CTRL, 0xa040);
 			break;
+		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726:
+
+			/* Restore normal power mode*/
+			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
+					  MISC_REGISTERS_GPIO_OUTPUT_HIGH,
+					  params->port);
+
+			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1,
+					  MISC_REGISTERS_GPIO_OUTPUT_HIGH,
+					  params->port);
+
+			bnx2x_cl45_write(bp, params->port,
+				       ext_phy_type,
+				       ext_phy_addr,
+				       MDIO_PMA_DEVAD,
+				       MDIO_PMA_REG_CTRL,
+				       1<<15);
+
+			break;
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072:
 			/* Unset Low Power Mode and SW reset */
 			/* Restore normal power mode*/
@@ -2198,6 +2246,484 @@ static void bnx2x_bcm8073_external_rom_boot(struct bnx2x *bp, u8 port,
 
 }
 
+static void bnx2x_bcm8726_external_rom_boot(struct link_params *params)
+{
+	struct bnx2x *bp = params->bp;
+	u8 port = params->port;
+	u8 ext_phy_addr = ((params->ext_phy_config &
+			     PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
+			    PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
+	u32 ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
+
+	/* Need to wait 100ms after reset */
+	msleep(100);
+
+	/* Set serial boot control for external load */
+	bnx2x_cl45_write(bp, port, ext_phy_type, ext_phy_addr,
+		       MDIO_PMA_DEVAD,
+		       MDIO_PMA_REG_MISC_CTRL1, 0x0001);
+
+	/* Micro controller re-boot */
+	bnx2x_cl45_write(bp, port, ext_phy_type, ext_phy_addr,
+		       MDIO_PMA_DEVAD,
+		       MDIO_PMA_REG_GEN_CTRL,
+		       MDIO_PMA_REG_GEN_CTRL_ROM_RESET_INTERNAL_MP);
+
+	/* Set soft reset */
+	bnx2x_cl45_write(bp, port, ext_phy_type, ext_phy_addr,
+		       MDIO_PMA_DEVAD,
+		       MDIO_PMA_REG_GEN_CTRL,
+		       MDIO_PMA_REG_GEN_CTRL_ROM_MICRO_RESET);
+
+	/* Clear soft reset.
+	Will automatically reset micro-controller re-boot */
+	bnx2x_cl45_write(bp, port, ext_phy_type, ext_phy_addr,
+		       MDIO_PMA_DEVAD,
+		       MDIO_PMA_REG_GEN_CTRL,
+		       MDIO_PMA_REG_GEN_CTRL_ROM_RESET_INTERNAL_MP);
+
+	/* wait for 100ms for microcode load */
+	msleep(100);
+
+	/* Disable serial boot control, tristates pins SS_N, SCK, MOSI, MISO */
+	bnx2x_cl45_write(bp, port, ext_phy_type, ext_phy_addr,
+		       MDIO_PMA_DEVAD,
+		       MDIO_PMA_REG_MISC_CTRL1, 0x0000);
+
+	msleep(200);
+}
+
+static void bnx2x_bcm8726_set_transmitter(struct bnx2x *bp, u8 port,
+					u8 ext_phy_addr, u8 tx_en)
+{
+	u16 val;
+	DP(NETIF_MSG_LINK, "Setting transmitter tx_en=%x for port %x\n",
+		 tx_en, port);
+	/* Disable/Enable transmitter ( TX laser of the SFP+ module.)*/
+	bnx2x_cl45_read(bp, port,
+		      PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726,
+		      ext_phy_addr,
+		      MDIO_PMA_DEVAD,
+		      MDIO_PMA_REG_PHY_IDENTIFIER,
+		      &val);
+
+	if (tx_en)
+		val &= ~(1<<15);
+	else
+		val |= (1<<15);
+
+	bnx2x_cl45_write(bp, port,
+		       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726,
+		       ext_phy_addr,
+		       MDIO_PMA_DEVAD,
+		       MDIO_PMA_REG_PHY_IDENTIFIER,
+		       val);
+}
+
+
+static u8 bnx2x_read_sfp_module_eeprom(struct link_params *params, u16 addr,
+				     u8 byte_cnt, u8 *o_buf) {
+	struct bnx2x *bp = params->bp;
+	u16 val, i;
+	u8 port = params->port;
+	u8 ext_phy_addr = ((params->ext_phy_config &
+			    PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
+			   PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
+	u32 ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
+	if (byte_cnt > 16) {
+		DP(NETIF_MSG_LINK, "Reading from eeprom is"
+			    " is limited to 0xf\n");
+		return -EINVAL;
+	}
+	/* Set the read command byte count */
+	bnx2x_cl45_write(bp, port,
+		       ext_phy_type,
+		       ext_phy_addr,
+		       MDIO_PMA_DEVAD,
+		       MDIO_PMA_REG_8726_TWO_WIRE_BYTE_CNT,
+		       (byte_cnt | 0xa000));
+
+	/* Set the read command address */
+	bnx2x_cl45_write(bp, port,
+		       ext_phy_type,
+		       ext_phy_addr,
+		       MDIO_PMA_DEVAD,
+		       MDIO_PMA_REG_8726_TWO_WIRE_MEM_ADDR,
+		       addr);
+
+	/* Activate read command */
+	bnx2x_cl45_write(bp, port,
+		       ext_phy_type,
+		       ext_phy_addr,
+		       MDIO_PMA_DEVAD,
+		       MDIO_PMA_REG_8726_TWO_WIRE_CTRL,
+		       0x2c0f);
+
+	/* Wait up to 500us for command complete status */
+	for (i = 0; i < 100; i++) {
+		bnx2x_cl45_read(bp, port,
+			      ext_phy_type,
+			      ext_phy_addr,
+			      MDIO_PMA_DEVAD,
+			      MDIO_PMA_REG_8726_TWO_WIRE_CTRL, &val);
+		if ((val & MDIO_PMA_REG_8726_TWO_WIRE_CTRL_STATUS_MASK) ==
+		    MDIO_PMA_REG_8726_TWO_WIRE_STATUS_COMPLETE)
+			break;
+		udelay(5);
+	}
+
+	if ((val & MDIO_PMA_REG_8726_TWO_WIRE_CTRL_STATUS_MASK) !=
+		    MDIO_PMA_REG_8726_TWO_WIRE_STATUS_COMPLETE) {
+		DP(NETIF_MSG_LINK,
+			 "Got bad status 0x%x when reading from SFP+ EEPROM\n",
+			 (val & MDIO_PMA_REG_8726_TWO_WIRE_CTRL_STATUS_MASK));
+		return -EINVAL;
+	}
+
+	/* Read the buffer */
+	for (i = 0; i < byte_cnt; i++) {
+		bnx2x_cl45_read(bp, port,
+			      ext_phy_type,
+			      ext_phy_addr,
+			      MDIO_PMA_DEVAD,
+			      MDIO_PMA_REG_8726_TWO_WIRE_DATA_BUF + i, &val);
+		o_buf[i] = (u8)(val & MDIO_PMA_REG_8726_TWO_WIRE_DATA_MASK);
+	}
+
+	for (i = 0; i < 100; i++) {
+		bnx2x_cl45_read(bp, port,
+			      ext_phy_type,
+			      ext_phy_addr,
+			      MDIO_PMA_DEVAD,
+			      MDIO_PMA_REG_8726_TWO_WIRE_CTRL, &val);
+		if ((val & MDIO_PMA_REG_8726_TWO_WIRE_CTRL_STATUS_MASK) ==
+		    MDIO_PMA_REG_8726_TWO_WIRE_STATUS_IDLE)
+			return 0;;
+		msleep(1);
+	}
+	return -EINVAL;
+}
+
+
+static u8 bnx2x_get_sfp_module_type(struct link_params *params,
+				  u8 *module_type)
+{
+	struct bnx2x *bp = params->bp;
+	u8 val;
+	*module_type = SFP_MODULE_TYPE_UNKNOWN;
+
+	/* First check for copper cable */
+	if (bnx2x_read_sfp_module_eeprom(params,
+				       SFP_EEPROM_CON_TYPE_ADDR,
+				       1,
+				       &val) != 0) {
+		DP(NETIF_MSG_LINK, "Failed to read from SFP+ module EEPROM");
+		return -EINVAL;
+	}
+
+	switch (val) {
+	case SFP_EEPROM_CON_TYPE_VAL_COPPER:
+	{
+		u8 copper_module_type;
+		/* Check if its active cable( includes SFP+ module)
+		of passive cable*/
+		if (bnx2x_read_sfp_module_eeprom(params,
+					       SFP_EEPROM_FC_TX_TECH_ADDR,
+					       1,
+					       &copper_module_type) !=
+		    0) {
+			DP(NETIF_MSG_LINK,
+				"Failed to read copper-cable-type"
+				" from SFP+ EEPROM\n");
+			return -EINVAL;
+		}
+
+		if (copper_module_type &
+		    SFP_EEPROM_FC_TX_TECH_BITMASK_COPPER_ACTIVE) {
+			DP(NETIF_MSG_LINK, "Active Copper cable detected\n");
+			*module_type = SFP_MODULE_TYPE_ACTIVE_COPPER_CABLE;
+		} else if (copper_module_type &
+			SFP_EEPROM_FC_TX_TECH_BITMASK_COPPER_PASSIVE) {
+				DP(NETIF_MSG_LINK, "Passive Copper"
+					    " cable detected\n");
+				*module_type =
+				      SFP_MODULE_TYPE_PASSIVE_COPPER_CABLE;
+		} else {
+			DP(NETIF_MSG_LINK, "Unknown copper-cable-"
+				     "type 0x%x !!!\n", copper_module_type);
+			return -EINVAL;
+		}
+		break;
+	}
+	case SFP_EEPROM_CON_TYPE_VAL_LC:
+		DP(NETIF_MSG_LINK, "Optic module detected\n");
+		*module_type = SFP_MODULE_TYPE_LC;
+		break;
+
+	default:
+		DP(NETIF_MSG_LINK, "Unable to determine module type 0x%x !!!\n",
+			 val);
+		return -EINVAL;
+	}
+	return 0;
+}
+
+
+/* This function read the relevant field from the module ( SFP+ ),
+	and verify it is compliant with this board */
+static u8 bnx2x_verify_sfp_module(struct link_params *params,
+				u8 module_type)
+{
+	struct bnx2x *bp = params->bp;
+	u8 *str_p, *tmp_buf;
+	u16 i;
+
+#define COMPLIANCE_STR_CNT 6
+	u8 *compliance_str[] = {"Broadcom", "JDSU", "Molex Inc", "PICOLIGHT",
+		"FINISAR CORP.   ", "Amphenol"};
+	u8 buf[SFP_EEPROM_VENDOR_NAME_SIZE];
+	/* Passive Copper cables are allowed to participate,
+	since the module is hardwired to the copper cable */
+
+	if (!(params->feature_config_flags &
+	     FEATURE_CONFIG_MODULE_ENFORCMENT_ENABLED)) {
+		DP(NETIF_MSG_LINK, "NOT enforcing module verification\n");
+		return 0;
+	}
+
+	if (module_type != SFP_MODULE_TYPE_LC) {
+		DP(NETIF_MSG_LINK, "No need to verify copper cable\n");
+		return 0;
+	}
+
+	/* In case of non copper cable or Active copper cable,
+		verify that the SFP+ module is compliant with this board*/
+	if (bnx2x_read_sfp_module_eeprom(params,
+				       SFP_EEPROM_VENDOR_NAME_ADDR,
+				       SFP_EEPROM_VENDOR_NAME_SIZE,
+				       buf) != 0) {
+		DP(NETIF_MSG_LINK, "Failed to read Vendor-Name from"
+			    " module EEPROM\n");
+		return -EINVAL;
+	}
+	for (i = 0; i < COMPLIANCE_STR_CNT; i++) {
+		str_p = compliance_str[i];
+		tmp_buf = buf;
+		while (*str_p) {
+			if ((u8)(*tmp_buf) != (u8)(*str_p))
+				break;
+			str_p++;
+			tmp_buf++;
+		}
+
+		if (!(*str_p)) {
+			DP(NETIF_MSG_LINK, "SFP+ Module verified, "
+				     "index=%x\n", i);
+			return 0;
+		}
+	}
+	DP(NETIF_MSG_LINK, "Incompliant SFP+ module. Disable module !!!\n");
+	return -EINVAL;
+}
+
+
+static u8 bnx2x_bcm8726_set_limiting_mode(struct link_params *params,
+					u8 module_type)
+{
+	struct bnx2x *bp = params->bp;
+	u8 port = params->port;
+	u8 options[SFP_EEPROM_OPTIONS_SIZE];
+	u8 limiting_mode;
+	u8 ext_phy_addr = ((params->ext_phy_config &
+			    PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
+			   PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
+
+	if (bnx2x_read_sfp_module_eeprom(params,
+				       SFP_EEPROM_OPTIONS_ADDR,
+				       SFP_EEPROM_OPTIONS_SIZE,
+				       options) != 0) {
+		DP(NETIF_MSG_LINK, "Failed to read Option field from"
+			    " module EEPROM\n");
+		return -EINVAL;
+	}
+	limiting_mode = !(options[0] &
+			  SFP_EEPROM_OPTIONS_LINEAR_RX_OUT_MASK);
+	if (limiting_mode &&
+	    (module_type != SFP_MODULE_TYPE_PASSIVE_COPPER_CABLE)) {
+		DP(NETIF_MSG_LINK,
+			 "Module options = 0x%x.Setting LIMITING MODE\n",
+			 options[0]);
+		bnx2x_cl45_write(bp, port,
+			       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726,
+			       ext_phy_addr,
+			       MDIO_PMA_DEVAD,
+			       MDIO_PMA_REG_ROM_VER2,
+			       SFP_LIMITING_MODE_VALUE);
+	} else { /* LRM mode ( default )*/
+		u16 cur_limiting_mode;
+		DP(NETIF_MSG_LINK, "Module options = 0x%x.Setting LRM MODE\n",
+			 options[0]);
+
+		bnx2x_cl45_read(bp, port,
+			       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726,
+			       ext_phy_addr,
+			       MDIO_PMA_DEVAD,
+			       MDIO_PMA_REG_ROM_VER2,
+			       &cur_limiting_mode);
+
+		/* Changing to LRM mode takes quite few seconds.
+		So do it only if current mode is limiting
+		( default is LRM )*/
+		if (cur_limiting_mode != SFP_LIMITING_MODE_VALUE)
+			return 0;
+
+		bnx2x_cl45_write(bp, port,
+			       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726,
+			       ext_phy_addr,
+			       MDIO_PMA_DEVAD,
+			       MDIO_PMA_REG_LRM_MODE,
+			       0);
+		bnx2x_cl45_write(bp, port,
+			       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726,
+			       ext_phy_addr,
+			       MDIO_PMA_DEVAD,
+			       MDIO_PMA_REG_ROM_VER2,
+			       0x128);
+		bnx2x_cl45_write(bp, port,
+			       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726,
+			       ext_phy_addr,
+			       MDIO_PMA_DEVAD,
+			       MDIO_PMA_REG_MISC_CTRL0,
+			       0x4008);
+		bnx2x_cl45_write(bp, port,
+			       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726,
+			       ext_phy_addr,
+			       MDIO_PMA_DEVAD,
+			       MDIO_PMA_REG_LRM_MODE,
+			       0xaaaa);
+	}
+	return 0;
+}
+
+static u8 bnx2x_wait_for_sfp_module_initialized(struct link_params *params)
+{
+	u8 val;
+	struct bnx2x *bp = params->bp;
+	u16 timeout;
+	/* Initialization time after hot-plug may take up to 300ms for some
+	phys type ( e.g. JDSU ) */
+	for (timeout = 0; timeout < 60; timeout++) {
+		if (bnx2x_read_sfp_module_eeprom(params, 1, 1, &val)
+		    == 0) {
+			DP(NETIF_MSG_LINK, "SFP+ module initialization "
+				     "took %d ms\n", timeout * 5);
+			return 0;
+		}
+		msleep(5);
+	}
+	return -EINVAL;
+}
+
+static u8 bnx2x_sfp_module_detection(struct link_params *params)
+{
+	struct bnx2x *bp = params->bp;
+	u8 module_type;
+	u8 ext_phy_addr = ((params->ext_phy_config &
+				PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
+				PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
+	u32 ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
+
+	if (ext_phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726) {
+		DP(NETIF_MSG_LINK, "Module detection is not required "
+			    "for this phy\n");
+		return 0;
+	}
+
+	DP(NETIF_MSG_LINK, "SFP+ module plugged in/out detected on port %d\n",
+		 params->port);
+
+	if (bnx2x_get_sfp_module_type(params,
+				    &module_type) != 0) {
+		DP(NETIF_MSG_LINK, "Failed to get valid module type\n");
+		if (!(params->feature_config_flags &
+		      FEATURE_CONFIG_MODULE_ENFORCMENT_ENABLED)) {
+			/* In case module detection is disabled, it trys to
+			link up. The issue that can happen here is LRM /
+			LIMITING mode which set according to the module-type*/
+			DP(NETIF_MSG_LINK, "Unable to read module-type."
+				    "Probably due to Bit Stretching."
+				    " Proceeding...\n");
+		} else {
+			return -EINVAL;
+		}
+	} else if (bnx2x_verify_sfp_module(params, module_type) !=
+		   0) {
+		/* check SFP+ module compatibility */
+		DP(NETIF_MSG_LINK, "Module verification failed!!\n");
+		/* Turn on fault module-detected led */
+		bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_0,
+				  MISC_REGISTERS_GPIO_HIGH,
+				  params->port);
+		return -EINVAL;
+	}
+
+	/* Turn off fault module-detected led */
+	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_0,
+			  MISC_REGISTERS_GPIO_LOW,
+			  params->port);
+
+	/* Check and set limiting mode / LRM mode */
+	if (bnx2x_bcm8726_set_limiting_mode(params, module_type)
+	     != 0) {
+		DP(NETIF_MSG_LINK, "Setting limiting mode failed!!\n");
+		return -EINVAL;
+	}
+
+	/* Enable transmit for this module */
+	bnx2x_bcm8726_set_transmitter(bp, params->port,
+				    ext_phy_addr, 1);
+	return 0;
+}
+
+void bnx2x_handle_module_detect_int(struct link_params *params)
+{
+	struct bnx2x *bp = params->bp;
+	u32 gpio_val;
+	u8 port = params->port;
+	/* Set valid module led off */
+	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_0,
+			  MISC_REGISTERS_GPIO_HIGH,
+			  params->port);
+
+	/* Get current gpio val refelecting module plugged in / out*/
+	gpio_val = bnx2x_get_gpio(bp,  MISC_REGISTERS_GPIO_3, port);
+
+	/* Call the handling function in case module is detected */
+	if (gpio_val == 0) {
+
+		bnx2x_set_gpio_int(bp, MISC_REGISTERS_GPIO_3,
+				      MISC_REGISTERS_GPIO_INT_OUTPUT_CLR,
+				      port);
+
+		if (bnx2x_wait_for_sfp_module_initialized(params)
+		    == 0)
+			bnx2x_sfp_module_detection(params);
+		else
+			DP(NETIF_MSG_LINK, "SFP+ module is not initialized\n");
+	} else {
+		u8 ext_phy_addr = ((params->ext_phy_config &
+				    PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
+				   PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
+		bnx2x_set_gpio_int(bp, MISC_REGISTERS_GPIO_3,
+				      MISC_REGISTERS_GPIO_INT_OUTPUT_SET,
+				      port);
+		/* Module was plugged out. */
+		/* Disable transmit for this module */
+		bnx2x_bcm8726_set_transmitter(bp, params->port,
+					    ext_phy_addr, 0);
+	}
+}
+
 static void bnx2x_bcm807x_force_10G(struct link_params *params)
 {
 	struct bnx2x *bp = params->bp;
@@ -2580,7 +3106,68 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 			}
 
 			break;
+		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726:
+			DP(NETIF_MSG_LINK, "Initializing BCM8726\n");
+			bnx2x_bcm8726_external_rom_boot(params);
+
+			/* Need to call module detected on initialization since
+			the module detection triggered by actual module
+			insertion might occur before driver is loaded, and when
+			driver is loaded, it reset all registers, including the
+			transmitter */
+			bnx2x_sfp_module_detection(params);
+			if (params->req_line_speed == SPEED_1000) {
+				DP(NETIF_MSG_LINK, "Setting 1G force\n");
+				bnx2x_cl45_write(bp, params->port, ext_phy_type,
+					       ext_phy_addr, MDIO_PMA_DEVAD,
+					       MDIO_PMA_REG_CTRL, 0x40);
+				bnx2x_cl45_write(bp, params->port, ext_phy_type,
+					       ext_phy_addr, MDIO_PMA_DEVAD,
+					       MDIO_PMA_REG_10G_CTRL2, 0xD);
+				bnx2x_cl45_write(bp, params->port, ext_phy_type,
+					       ext_phy_addr, MDIO_PMA_DEVAD,
+					       MDIO_PMA_REG_LASI_CTRL, 0x5);
+				bnx2x_cl45_write(bp, params->port, ext_phy_type,
+					       ext_phy_addr, MDIO_PMA_DEVAD,
+					       MDIO_PMA_REG_RX_ALARM_CTRL,
+					       0x400);
+			} else if ((params->req_line_speed ==
+				    SPEED_AUTO_NEG) &&
+				   ((params->speed_cap_mask &
+				     PORT_HW_CFG_SPEED_CAPABILITY_D0_1G))) {
+				DP(NETIF_MSG_LINK, "Setting 1G clause37 \n");
+				bnx2x_cl45_write(bp, params->port, ext_phy_type,
+					       ext_phy_addr, MDIO_AN_DEVAD,
+					       MDIO_AN_REG_ADV, 0x20);
+				bnx2x_cl45_write(bp, params->port, ext_phy_type,
+					       ext_phy_addr, MDIO_AN_DEVAD,
+					       MDIO_AN_REG_CL37_CL73, 0x040c);
+				bnx2x_cl45_write(bp, params->port, ext_phy_type,
+					       ext_phy_addr, MDIO_AN_DEVAD,
+					       MDIO_AN_REG_CL37_FC_LD, 0x0020);
+				bnx2x_cl45_write(bp, params->port, ext_phy_type,
+					       ext_phy_addr, MDIO_AN_DEVAD,
+					       MDIO_AN_REG_CL37_AN, 0x1000);
+				bnx2x_cl45_write(bp, params->port, ext_phy_type,
+					       ext_phy_addr, MDIO_AN_DEVAD,
+					       MDIO_AN_REG_CTRL, 0x1200);
+
+				/* Enable RX-ALARM control to receive
+				interrupt for 1G speed change */
+				bnx2x_cl45_write(bp, params->port, ext_phy_type,
+					       ext_phy_addr, MDIO_PMA_DEVAD,
+					       MDIO_PMA_REG_LASI_CTRL, 0x4);
+				bnx2x_cl45_write(bp, params->port, ext_phy_type,
+					       ext_phy_addr, MDIO_PMA_DEVAD,
+					       MDIO_PMA_REG_RX_ALARM_CTRL,
+					       0x400);
 
+			} else { /* Default 10G. Set only LASI control */
+				bnx2x_cl45_write(bp, params->port, ext_phy_type,
+					       ext_phy_addr, MDIO_PMA_DEVAD,
+					       MDIO_PMA_REG_LASI_CTRL, 1);
+			}
+			break;
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072:
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073:
 		{
@@ -2910,38 +3497,43 @@ static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
 			break;
 
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706:
-			DP(NETIF_MSG_LINK, "XGXS 8706\n");
+		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726:
+			DP(NETIF_MSG_LINK, "XGXS 8706/8726\n");
+			/* Clear RX Alarm*/
 			bnx2x_cl45_read(bp, params->port, ext_phy_type,
 				      ext_phy_addr,
-				      MDIO_PMA_DEVAD,
-				      MDIO_PMA_REG_LASI_STATUS, &val1);
-			DP(NETIF_MSG_LINK, "8706 LASI status 0x%x\n", val1);
-
+				      MDIO_PMA_DEVAD, MDIO_PMA_REG_RX_ALARM,
+				      &val2);
+			/* clear LASI indication*/
 			bnx2x_cl45_read(bp, params->port, ext_phy_type,
 				      ext_phy_addr,
-				      MDIO_PMA_DEVAD,
-				      MDIO_PMA_REG_LASI_STATUS, &val1);
-			DP(NETIF_MSG_LINK, "8706 LASI status 0x%x\n", val1);
+				      MDIO_PMA_DEVAD, MDIO_PMA_REG_LASI_STATUS,
+				      &val1);
+			bnx2x_cl45_read(bp, params->port, ext_phy_type,
+				      ext_phy_addr,
+				      MDIO_PMA_DEVAD, MDIO_PMA_REG_LASI_STATUS,
+				      &val2);
+			DP(NETIF_MSG_LINK, "8706/8726 LASI status 0x%x-->"
+				     "0x%x\n", val1, val2);
 
 			bnx2x_cl45_read(bp, params->port, ext_phy_type,
 				      ext_phy_addr,
-				      MDIO_PMA_DEVAD,
-				      MDIO_PMA_REG_RX_SD, &rx_sd);
+				      MDIO_PMA_DEVAD, MDIO_PMA_REG_RX_SD,
+				      &rx_sd);
 			bnx2x_cl45_read(bp, params->port, ext_phy_type,
 				      ext_phy_addr,
-				      MDIO_PCS_DEVAD,
-				      MDIO_PCS_REG_STATUS, &pcs_status);
-
+				      MDIO_PCS_DEVAD, MDIO_PCS_REG_STATUS,
+				      &pcs_status);
 			bnx2x_cl45_read(bp, params->port, ext_phy_type,
 				      ext_phy_addr,
-				      MDIO_AN_DEVAD,
-				      MDIO_AN_REG_LINK_STATUS, &val2);
+				      MDIO_AN_DEVAD, MDIO_AN_REG_LINK_STATUS,
+				      &val2);
 			bnx2x_cl45_read(bp, params->port, ext_phy_type,
 				      ext_phy_addr,
-				      MDIO_AN_DEVAD,
-				      MDIO_AN_REG_LINK_STATUS, &val2);
+				      MDIO_AN_DEVAD, MDIO_AN_REG_LINK_STATUS,
+				      &val2);
 
-			DP(NETIF_MSG_LINK, "8706 rx_sd 0x%x"
+			DP(NETIF_MSG_LINK, "8706/8726 rx_sd 0x%x"
 			   "  pcs_status 0x%x 1Gbps link_status 0x%x\n",
 			   rx_sd, pcs_status, val2);
 			/* link is up if both bit 0 of pmd_rx_sd and
@@ -2951,19 +3543,31 @@ static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
 			ext_phy_link_up = ((rx_sd & pcs_status & 0x1) ||
 					   (val2 & (1<<1)));
 			if (ext_phy_link_up) {
+				if (ext_phy_type ==
+				     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726) {
+					/* If transmitter is disabled,
+					ignore false link up indication */
+					bnx2x_cl45_read(bp, params->port,
+						   ext_phy_type,
+						   ext_phy_addr,
+						   MDIO_PMA_DEVAD,
+						   MDIO_PMA_REG_PHY_IDENTIFIER,
+						   &val1);
+					if (val1 & (1<<15)) {
+						DP(NETIF_MSG_LINK, "Tx is "
+							    "disabled\n");
+						ext_phy_link_up = 0;
+						break;
+					}
+				}
+
 				if (val2 & (1<<1))
 					vars->line_speed = SPEED_1000;
 				else
 					vars->line_speed = SPEED_10000;
 			}
 
-			/* clear LASI indication*/
-			bnx2x_cl45_read(bp, params->port, ext_phy_type,
-				      ext_phy_addr,
-				      MDIO_PMA_DEVAD,
-				      MDIO_PMA_REG_RX_ALARM, &val2);
 			break;
-
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072:
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073:
 		{
@@ -3523,7 +4127,7 @@ u8 bnx2x_get_ext_phy_fw_version(struct link_params *params, u8 driver_loaded,
 	}
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705:
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706:
-
+	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726:
 		bnx2x_cl45_read(bp, params->port, ext_phy_type,
 			      ext_phy_addr,
 			      MDIO_PMA_DEVAD,
@@ -3636,6 +4240,14 @@ static void bnx2x_ext_phy_loopback(struct link_params *params)
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706:
 			DP(NETIF_MSG_LINK, "ext_phy_loopback: 8706\n");
 			break;
+		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726:
+			DP(NETIF_MSG_LINK, "PMA/PMD ext_phy_loopback: 8726\n");
+			bnx2x_cl45_write(bp, params->port, ext_phy_type,
+				       ext_phy_addr,
+				       MDIO_PMA_DEVAD,
+				       MDIO_PMA_REG_CTRL,
+				       0x0001);
+			break;
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101:
 			/* SFX7101_XGXS_TEST1 */
 			bnx2x_cl45_write(bp, params->port, ext_phy_type,
@@ -3910,7 +4522,8 @@ static u8 bnx2x_link_initialize(struct link_params *params,
 		       (params->loopback_mode == LOOPBACK_EXT_PHY));
 
 	if (non_ext_phy ||
-	    (ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705)) {
+	    (ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705) ||
+	    (ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726)) {
 		if (params->req_line_speed == SPEED_AUTO_NEG)
 			bnx2x_set_parallel_detection(params, vars->phy_flags);
 		bnx2x_init_internal_phy(params, vars);
@@ -4112,7 +4725,23 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 	return 0;
 }
 
-u8 bnx2x_link_reset(struct link_params *params, struct link_vars *vars)
+static void bnx2x_8726_reset_phy(struct bnx2x *bp, u8 port, u8 ext_phy_addr)
+{
+	DP(NETIF_MSG_LINK, "bnx2x_8726_reset_phy port %d\n", port);
+
+	/* Set serial boot control for external load */
+	bnx2x_cl45_write(bp, port,
+		       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726, ext_phy_addr,
+		       MDIO_PMA_DEVAD,
+		       MDIO_PMA_REG_GEN_CTRL, 0x0001);
+
+	/* Disable Transmitter */
+	bnx2x_bcm8726_set_transmitter(bp, port, ext_phy_addr, 0);
+
+}
+
+u8 bnx2x_link_reset(struct link_params *params, struct link_vars *vars,
+		  u8 reset_ext_phy)
 {
 
 	struct bnx2x *bp = params->bp;
@@ -4150,28 +4779,37 @@ u8 bnx2x_link_reset(struct link_params *params, struct link_vars *vars)
 	 */
 	 /* clear link led */
 	bnx2x_set_led(bp, port, LED_MODE_OFF, 0, hw_led_mode, chip_id);
-	if (ext_phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT) {
-		if ((ext_phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072) &&
-		    (ext_phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073)) {
+	if (reset_ext_phy) {
+		switch (ext_phy_type) {
+		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT:
+		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072:
+			break;
+		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073:
+			DP(NETIF_MSG_LINK, "Setting 8073 port %d into "
+				 "low power mode\n",
+				 port);
+			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
+					  MISC_REGISTERS_GPIO_OUTPUT_LOW,
+					  port);
+			break;
+		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726:
+		{
+			u8 ext_phy_addr = ((params->ext_phy_config &
+					 PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
+					 PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
+			/* Set soft reset */
+			bnx2x_8726_reset_phy(bp, params->port, ext_phy_addr);
+			break;
+		}
+		default:
 			/* HW reset */
-
 			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1,
 					  MISC_REGISTERS_GPIO_OUTPUT_LOW,
 					  port);
-
 			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
 					  MISC_REGISTERS_GPIO_OUTPUT_LOW,
 					  port);
-
 			DP(NETIF_MSG_LINK, "reset external PHY\n");
-		} else if (ext_phy_type ==
-			   PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073) {
-				DP(NETIF_MSG_LINK, "Setting 8073 port %d into "
-					 "low power mode\n",
-					 port);
-				bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
-					MISC_REGISTERS_GPIO_OUTPUT_LOW,
-						  port);
 		}
 	}
 	/* reset the SerDes/XGXS */
@@ -4337,6 +4975,7 @@ u8 bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 
 	if ((ext_phy_type != PORT_HW_CFG_SERDES_EXT_PHY_TYPE_DIRECT) &&
 	    (ext_phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705) &&
+	    (ext_phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726) &&
 	    (ext_phy_link_up && !vars->phy_link_up))
 		bnx2x_init_internal_phy(params, vars);
 
@@ -4469,6 +5108,45 @@ static u8 bnx2x_8073_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 
 }
 
+
+static u8 bnx2x_8726_common_init_phy(struct bnx2x *bp, u32 shmem_base)
+{
+	u8 ext_phy_addr;
+	u32 val;
+	s8 port;
+	/* Use port1 because of the static port-swap */
+	/* Enable the module detection interrupt */
+	val = REG_RD(bp, MISC_REG_GPIO_EVENT_EN);
+	val |= ((1<<MISC_REGISTERS_GPIO_3)|
+		(1<<(MISC_REGISTERS_GPIO_3 + MISC_REGISTERS_GPIO_PORT_SHIFT)));
+	REG_WR(bp, MISC_REG_GPIO_EVENT_EN, val);
+
+	bnx2x_hw_reset(bp, 1);
+	msleep(5);
+	for (port = 0; port < PORT_MAX; port++) {
+		/* Extract the ext phy address for the port */
+		u32 ext_phy_config = REG_RD(bp, shmem_base +
+					offsetof(struct shmem_region,
+			dev_info.port_hw_config[port].external_phy_config));
+
+		ext_phy_addr =
+			((ext_phy_config &
+			      PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
+			      PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
+		DP(NETIF_MSG_LINK, "8726_common_init : ext_phy_addr = 0x%x\n",
+			 ext_phy_addr);
+
+		bnx2x_8726_reset_phy(bp, port, ext_phy_addr);
+
+		/* Set fault module detected LED on */
+		bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_0,
+				  MISC_REGISTERS_GPIO_HIGH,
+				  port);
+	}
+
+	return 0;
+}
+
 u8 bnx2x_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 {
 	u8 rc = 0;
@@ -4488,6 +5166,12 @@ u8 bnx2x_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 		rc = bnx2x_8073_common_init_phy(bp, shmem_base);
 		break;
 	}
+	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726:
+		/* GPIO1 affects both ports, so there's need to pull
+		it for single port alone */
+		rc = bnx2x_8726_common_init_phy(bp, shmem_base);
+
+		break;
 	default:
 		DP(NETIF_MSG_LINK,
 			 "bnx2x_common_init_phy: ext_phy 0x%x not required\n",
diff --git a/drivers/net/bnx2x_link.h b/drivers/net/bnx2x_link.h
index 47cb585..1318683 100644
--- a/drivers/net/bnx2x_link.h
+++ b/drivers/net/bnx2x_link.h
@@ -89,6 +89,9 @@ struct link_params {
 
 	/* phy_addr populated by the CLC */
 	u8 phy_addr;
+	u32 feature_config_flags;
+#define FEATURE_CONFIG_OVERRIDE_PREEMPHASIS_ENABLED (1<<0)
+#define FEATURE_CONFIG_MODULE_ENFORCMENT_ENABLED	(2<<0)
 	/* Device pointer passed to all callback functions */
 	struct bnx2x *bp;
 };
@@ -125,8 +128,11 @@ struct link_vars {
 /* Initialize the phy */
 u8 bnx2x_phy_init(struct link_params *input, struct link_vars *output);
 
-/* Reset the link. Should be called when driver or interface goes down */
-u8 bnx2x_link_reset(struct link_params *params, struct link_vars *vars);
+/* Reset the link. Should be called when driver or interface goes down
+   Before calling phy firmware upgrade, the reset_ext_phy should be set
+   to 0 */
+u8 bnx2x_link_reset(struct link_params *params, struct link_vars *vars,
+		  u8 reset_ext_phy);
 
 /* bnx2x_link_update should be called upon link interrupt */
 u8 bnx2x_link_update(struct link_params *input, struct link_vars *output);
@@ -163,6 +169,10 @@ u8 bnx2x_override_led_value(struct bnx2x *bp, u8 port, u32 led_idx, u32 value);
 
 u8 bnx2x_flash_download(struct bnx2x *bp, u8 port, u32 ext_phy_config,
 		      u8 driver_loaded, char data[], u32 size);
+/* bnx2x_handle_module_detect_int should be called upon module detection
+   interrupt */
+void bnx2x_handle_module_detect_int(struct link_params *params);
+
 /* Get the actual link status. In case it returns 0, link is up,
 	otherwise link is down*/
 u8 bnx2x_test_link(struct link_params *input, struct link_vars *vars);
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 95f8e58..5acbd98 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -2112,7 +2112,7 @@ static void bnx2x__link_reset(struct bnx2x *bp)
 {
 	if (!BP_NOMCP(bp)) {
 		bnx2x_acquire_phy_lock(bp);
-		bnx2x_link_reset(&bp->link_params, &bp->link_vars);
+		bnx2x_link_reset(&bp->link_params, &bp->link_vars, 1);
 		bnx2x_release_phy_lock(bp);
 	} else
 		BNX2X_ERR("Bootcode is missing -not resetting link\n");
@@ -2613,6 +2613,13 @@ static inline void bnx2x_attn_int_deasserted0(struct bnx2x *bp, u32 attn)
 		}
 	}
 
+	if (attn & (AEU_INPUTS_ATTN_BITS_GPIO3_FUNCTION_0 |
+		    AEU_INPUTS_ATTN_BITS_GPIO3_FUNCTION_1)) {
+		bnx2x_acquire_phy_lock(bp);
+		bnx2x_handle_module_detect_int(&bp->link_params);
+		bnx2x_release_phy_lock(bp);
+	}
+
 	if (attn & HW_INTERRUT_ASSERT_SET_0) {
 
 		val = REG_RD(bp, reg_offset);
@@ -5905,6 +5912,37 @@ static int bnx2x_init_port(struct bnx2x *bp)
 	/* Port DMAE comes here */
 
 	switch (XGXS_EXT_PHY_TYPE(bp->link_params.ext_phy_config)) {
+	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726:
+		{
+		u32 swap_val, swap_override, aeu_gpio_mask, offset;
+
+		bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_3,
+			       MISC_REGISTERS_GPIO_INPUT_HI_Z, port);
+
+		/* The GPIO should be swapped if the swap register is
+		   set and active */
+		swap_val = REG_RD(bp, NIG_REG_PORT_SWAP);
+		swap_override = REG_RD(bp, NIG_REG_STRAP_OVERRIDE);
+
+		/* Select function upon port-swap configuration */
+		if (port == 0) {
+			offset = MISC_REG_AEU_ENABLE1_FUNC_0_OUT_0;
+			aeu_gpio_mask = (swap_val && swap_override) ?
+				AEU_INPUTS_ATTN_BITS_GPIO3_FUNCTION_1 :
+				AEU_INPUTS_ATTN_BITS_GPIO3_FUNCTION_0;
+		} else {
+			offset = MISC_REG_AEU_ENABLE1_FUNC_1_OUT_0;
+			aeu_gpio_mask = (swap_val && swap_override) ?
+				AEU_INPUTS_ATTN_BITS_GPIO3_FUNCTION_0 :
+				AEU_INPUTS_ATTN_BITS_GPIO3_FUNCTION_1;
+		}
+		val = REG_RD(bp, offset);
+		/* add GPIO3 to group */
+		val |= aeu_gpio_mask;
+		REG_WR(bp, offset, val);
+		}
+		break;
+
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101:
 		/* add SPIO 5 to group 0 */
 		val = REG_RD(bp, MISC_REG_AEU_ENABLE1_FUNC_0_OUT_0);
@@ -7623,48 +7661,60 @@ static void __devinit bnx2x_link_settings_supported(struct bnx2x *bp,
 					       SUPPORTED_Asym_Pause);
 			break;
 
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705:
-			BNX2X_DEV_INFO("ext_phy_type 0x%x (8705)\n",
+		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072:
+			BNX2X_DEV_INFO("ext_phy_type 0x%x (8072)\n",
 				       ext_phy_type);
 
 			bp->port.supported |= (SUPPORTED_10000baseT_Full |
+					       SUPPORTED_1000baseT_Full |
 					       SUPPORTED_FIBRE |
+					       SUPPORTED_Autoneg |
 					       SUPPORTED_Pause |
 					       SUPPORTED_Asym_Pause);
 			break;
 
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706:
-			BNX2X_DEV_INFO("ext_phy_type 0x%x (8706)\n",
+		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073:
+			BNX2X_DEV_INFO("ext_phy_type 0x%x (8073)\n",
 				       ext_phy_type);
 
 			bp->port.supported |= (SUPPORTED_10000baseT_Full |
+					       SUPPORTED_2500baseX_Full |
 					       SUPPORTED_1000baseT_Full |
 					       SUPPORTED_FIBRE |
+					       SUPPORTED_Autoneg |
+					       SUPPORTED_Pause |
+					       SUPPORTED_Asym_Pause);
+			break;
+
+		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705:
+			BNX2X_DEV_INFO("ext_phy_type 0x%x (8705)\n",
+				       ext_phy_type);
+
+			bp->port.supported |= (SUPPORTED_10000baseT_Full |
+					       SUPPORTED_FIBRE |
 					       SUPPORTED_Pause |
 					       SUPPORTED_Asym_Pause);
 			break;
 
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072:
-			BNX2X_DEV_INFO("ext_phy_type 0x%x (8072)\n",
+		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706:
+			BNX2X_DEV_INFO("ext_phy_type 0x%x (8706)\n",
 				       ext_phy_type);
 
 			bp->port.supported |= (SUPPORTED_10000baseT_Full |
 					       SUPPORTED_1000baseT_Full |
 					       SUPPORTED_FIBRE |
-					       SUPPORTED_Autoneg |
 					       SUPPORTED_Pause |
 					       SUPPORTED_Asym_Pause);
 			break;
 
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073:
-			BNX2X_DEV_INFO("ext_phy_type 0x%x (8073)\n",
+		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726:
+			BNX2X_DEV_INFO("ext_phy_type 0x%x (8726)\n",
 				       ext_phy_type);
 
 			bp->port.supported |= (SUPPORTED_10000baseT_Full |
-					       SUPPORTED_2500baseX_Full |
 					       SUPPORTED_1000baseT_Full |
-					       SUPPORTED_FIBRE |
 					       SUPPORTED_Autoneg |
+					       SUPPORTED_FIBRE |
 					       SUPPORTED_Pause |
 					       SUPPORTED_Asym_Pause);
 			break;
@@ -7905,6 +7955,7 @@ static void __devinit bnx2x_get_port_hwinfo(struct bnx2x *bp)
 {
 	int port = BP_PORT(bp);
 	u32 val, val2;
+	u32 config;
 
 	bp->link_params.bp = bp;
 	bp->link_params.port = port;
@@ -7923,6 +7974,14 @@ static void __devinit bnx2x_get_port_hwinfo(struct bnx2x *bp)
 	bp->port.link_config =
 		SHMEM_RD(bp, dev_info.port_feature_config[port].link_config);
 
+	config = SHMEM_RD(bp, dev_info.port_feature_config[port].config);
+	if (config & PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_ENABLED)
+		bp->link_params.feature_config_flags |=
+				FEATURE_CONFIG_MODULE_ENFORCMENT_ENABLED;
+	else
+		bp->link_params.feature_config_flags &=
+				~FEATURE_CONFIG_MODULE_ENFORCMENT_ENABLED;
+
 	BNX2X_DEV_INFO("serdes_config 0x%08x  lane_config 0x%08x\n"
 	     KERN_INFO "  ext_phy_config 0x%08x  speed_cap_mask 0x%08x"
 		       "  link_config 0x%08x\n",
@@ -8121,10 +8180,11 @@ static int bnx2x_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 		switch (ext_phy_type) {
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT:
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705:
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706:
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072:
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073:
+		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705:
+		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706:
+		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726:
 			cmd->port = PORT_FIBRE;
 			break;
 
@@ -8807,7 +8867,7 @@ static int bnx2x_set_eeprom(struct net_device *dev,
 			if ((bp->state == BNX2X_STATE_OPEN) ||
 			    (bp->state == BNX2X_STATE_DISABLED)) {
 				rc |= bnx2x_link_reset(&bp->link_params,
-						       &bp->link_vars);
+						       &bp->link_vars, 1);
 				rc |= bnx2x_phy_init(&bp->link_params,
 						     &bp->link_vars);
 			}
diff --git a/drivers/net/bnx2x_reg.h b/drivers/net/bnx2x_reg.h
index 6fc1d0d..520bf69 100644
--- a/drivers/net/bnx2x_reg.h
+++ b/drivers/net/bnx2x_reg.h
@@ -5800,9 +5800,25 @@ Theotherbitsarereservedandshouldbezero*/
 #define MDIO_PMA_REG_ROM_VER2		0xca1a
 #define MDIO_PMA_REG_EDC_FFE_MAIN	0xca1b
 #define MDIO_PMA_REG_PLL_BANDWIDTH	0xca1d
+#define MDIO_PMA_REG_MISC_CTRL0 	0xca23
+#define MDIO_PMA_REG_LRM_MODE		0xca3f
 #define MDIO_PMA_REG_CDR_BANDWIDTH	0xca46
 #define MDIO_PMA_REG_MISC_CTRL1 	0xca85
 
+#define MDIO_PMA_REG_8726_TWO_WIRE_CTRL 	0x8000
+#define MDIO_PMA_REG_8726_TWO_WIRE_CTRL_STATUS_MASK	0x000c
+#define MDIO_PMA_REG_8726_TWO_WIRE_STATUS_IDLE		0x0000
+#define MDIO_PMA_REG_8726_TWO_WIRE_STATUS_COMPLETE	0x0004
+#define MDIO_PMA_REG_8726_TWO_WIRE_STATUS_IN_PROGRESS	0x0008
+#define MDIO_PMA_REG_8726_TWO_WIRE_STATUS_FAILED	0x000c
+#define MDIO_PMA_REG_8726_TWO_WIRE_BYTE_CNT	0x8002
+#define MDIO_PMA_REG_8726_TWO_WIRE_MEM_ADDR	0x8003
+#define MDIO_PMA_REG_8726_TWO_WIRE_DATA_BUF	0xc820
+#define MDIO_PMA_REG_8726_TWO_WIRE_DATA_MASK 0xff
+#define MDIO_PMA_REG_8726_TX_CTRL1		0xca01
+#define MDIO_PMA_REG_8726_TX_CTRL2		0xca05
+
+
 #define MDIO_PMA_REG_7101_RESET 	0xc000
 #define MDIO_PMA_REG_7107_LED_CNTL	0xc007
 #define MDIO_PMA_REG_7101_VER1		0xc026
@@ -5832,6 +5848,12 @@ Theotherbitsarereservedandshouldbezero*/
 #define MDIO_XS_PLL_SEQUENCER		0x8000
 #define MDIO_XS_SFX7101_XGXS_TEST1	0xc00a
 
+#define MDIO_XS_8706_REG_BANK_RX0	0x80bc
+#define MDIO_XS_8706_REG_BANK_RX1	0x80cc
+#define MDIO_XS_8706_REG_BANK_RX2	0x80dc
+#define MDIO_XS_8706_REG_BANK_RX3	0x80ec
+#define MDIO_XS_8706_REG_BANK_RXA	0x80fc
+
 #define MDIO_AN_DEVAD			0x7
 /*ieee*/
 #define MDIO_AN_REG_CTRL		0x0000
-- 
1.5.4.3




