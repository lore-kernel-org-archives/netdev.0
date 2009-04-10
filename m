From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 09/10] ixgbe: Update get_physical_layer() calls,
	plus a version bump
Date: Fri, 10 Apr 2009 01:28:50 -0700
Message-ID: <20090410082850.14372.91271.stgit@localhost.localdomain>
References: <20090410082618.14372.86091.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.westchester.pa.mail.comcast.net ([76.96.62.80]:52460
	"EHLO QMTA08.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S938706AbZDJQ5U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2009 12:57:20 -0400
In-Reply-To: <20090410082618.14372.86091.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

Not all physical connection types are being correctly identified.  This
fixes that issue, and cleans up the logic to make it more maintainable.

Also clean up the code for device capabilities from the EEPROM to support
multiple SKUs of the same hardware.

Bump the version to reflect all the updates since the 82599 merge.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82598.c |   85 +++++++++++++++++--------
 drivers/net/ixgbe/ixgbe_82599.c |  134 +++++++++++++++++++++++++++++----------
 drivers/net/ixgbe/ixgbe_main.c  |    2 -
 drivers/net/ixgbe/ixgbe_phy.c   |    8 +-
 drivers/net/ixgbe/ixgbe_type.h  |   10 ++-
 5 files changed, 169 insertions(+), 70 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index 89bc87a..03eb54f 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -1034,35 +1034,56 @@ out:
 static u32 ixgbe_get_supported_physical_layer_82598(struct ixgbe_hw *hw)
 {
 	u32 physical_layer = IXGBE_PHYSICAL_LAYER_UNKNOWN;
+	u32 autoc = IXGBE_READ_REG(hw, IXGBE_AUTOC);
+	u32 pma_pmd_10g = autoc & IXGBE_AUTOC_10G_PMA_PMD_MASK;
+	u32 pma_pmd_1g = autoc & IXGBE_AUTOC_1G_PMA_PMD_MASK;
+	u16 ext_ability = 0;
+
+	hw->phy.ops.identify(hw);
+
+	/* Copper PHY must be checked before AUTOC LMS to determine correct
+	 * physical layer because 10GBase-T PHYs use LMS = KX4/KX */
+	if (hw->phy.type == ixgbe_phy_tn ||
+	    hw->phy.type == ixgbe_phy_cu_unknown) {
+		hw->phy.ops.read_reg(hw, IXGBE_MDIO_PHY_EXT_ABILITY,
+		IXGBE_MDIO_PMA_PMD_DEV_TYPE, &ext_ability);
+		if (ext_ability & IXGBE_MDIO_PHY_10GBASET_ABILITY)
+			physical_layer |= IXGBE_PHYSICAL_LAYER_10GBASE_T;
+		if (ext_ability & IXGBE_MDIO_PHY_1000BASET_ABILITY)
+			physical_layer |= IXGBE_PHYSICAL_LAYER_1000BASE_T;
+		if (ext_ability & IXGBE_MDIO_PHY_100BASETX_ABILITY)
+			physical_layer |= IXGBE_PHYSICAL_LAYER_100BASE_TX;
+		goto out;
+	}
 
-	switch (hw->device_id) {
-	case IXGBE_DEV_ID_82598:
-		/* Default device ID is mezzanine card KX/KX4 */
-		physical_layer = (IXGBE_PHYSICAL_LAYER_10GBASE_KX4 |
-				  IXGBE_PHYSICAL_LAYER_1000BASE_KX);
-		break;
-	case IXGBE_DEV_ID_82598_BX:
-		physical_layer = IXGBE_PHYSICAL_LAYER_1000BASE_BX;
-	case IXGBE_DEV_ID_82598EB_CX4:
-	case IXGBE_DEV_ID_82598_CX4_DUAL_PORT:
-		physical_layer = IXGBE_PHYSICAL_LAYER_10GBASE_CX4;
-		break;
-	case IXGBE_DEV_ID_82598_DA_DUAL_PORT:
-		physical_layer = IXGBE_PHYSICAL_LAYER_SFP_PLUS_CU;
+	switch (autoc & IXGBE_AUTOC_LMS_MASK) {
+	case IXGBE_AUTOC_LMS_1G_AN:
+	case IXGBE_AUTOC_LMS_1G_LINK_NO_AN:
+		if (pma_pmd_1g == IXGBE_AUTOC_1G_KX)
+			physical_layer = IXGBE_PHYSICAL_LAYER_1000BASE_KX;
+		else
+			physical_layer = IXGBE_PHYSICAL_LAYER_1000BASE_BX;
 		break;
-	case IXGBE_DEV_ID_82598AF_DUAL_PORT:
-	case IXGBE_DEV_ID_82598AF_SINGLE_PORT:
-	case IXGBE_DEV_ID_82598_SR_DUAL_PORT_EM:
-		physical_layer = IXGBE_PHYSICAL_LAYER_10GBASE_SR;
+	case IXGBE_AUTOC_LMS_10G_LINK_NO_AN:
+		if (pma_pmd_10g == IXGBE_AUTOC_10G_CX4)
+			physical_layer = IXGBE_PHYSICAL_LAYER_10GBASE_CX4;
+		else if (pma_pmd_10g == IXGBE_AUTOC_10G_KX4)
+			physical_layer = IXGBE_PHYSICAL_LAYER_10GBASE_KX4;
+		else /* XAUI */
+			physical_layer = IXGBE_PHYSICAL_LAYER_UNKNOWN;
 		break;
-	case IXGBE_DEV_ID_82598EB_XF_LR:
-		physical_layer = IXGBE_PHYSICAL_LAYER_10GBASE_LR;
+	case IXGBE_AUTOC_LMS_KX4_AN:
+	case IXGBE_AUTOC_LMS_KX4_AN_1G_AN:
+		if (autoc & IXGBE_AUTOC_KX_SUPP)
+			physical_layer |= IXGBE_PHYSICAL_LAYER_1000BASE_KX;
+		if (autoc & IXGBE_AUTOC_KX4_SUPP)
+			physical_layer |= IXGBE_PHYSICAL_LAYER_10GBASE_KX4;
 		break;
-	case IXGBE_DEV_ID_82598AT:
-		physical_layer = (IXGBE_PHYSICAL_LAYER_10GBASE_T |
-		                  IXGBE_PHYSICAL_LAYER_1000BASE_T);
+	default:
 		break;
-	case IXGBE_DEV_ID_82598EB_SFP_LOM:
+	}
+
+	if (hw->phy.type == ixgbe_phy_nl) {
 		hw->phy.ops.identify_sfp(hw);
 
 		switch (hw->phy.sfp_type) {
@@ -1079,13 +1100,25 @@ static u32 ixgbe_get_supported_physical_layer_82598(struct ixgbe_hw *hw)
 			physical_layer = IXGBE_PHYSICAL_LAYER_UNKNOWN;
 			break;
 		}
-		break;
+	}
 
+	switch (hw->device_id) {
+	case IXGBE_DEV_ID_82598_DA_DUAL_PORT:
+		physical_layer = IXGBE_PHYSICAL_LAYER_SFP_PLUS_CU;
+		break;
+	case IXGBE_DEV_ID_82598AF_DUAL_PORT:
+	case IXGBE_DEV_ID_82598AF_SINGLE_PORT:
+	case IXGBE_DEV_ID_82598_SR_DUAL_PORT_EM:
+		physical_layer = IXGBE_PHYSICAL_LAYER_10GBASE_SR;
+		break;
+	case IXGBE_DEV_ID_82598EB_XF_LR:
+		physical_layer = IXGBE_PHYSICAL_LAYER_10GBASE_LR;
+		break;
 	default:
-		physical_layer = IXGBE_PHYSICAL_LAYER_UNKNOWN;
 		break;
 	}
 
+out:
 	return physical_layer;
 }
 
diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 2faf190..9e824b4 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -1141,53 +1141,98 @@ s32 ixgbe_identify_phy_82599(struct ixgbe_hw *hw)
 u32 ixgbe_get_supported_physical_layer_82599(struct ixgbe_hw *hw)
 {
 	u32 physical_layer = IXGBE_PHYSICAL_LAYER_UNKNOWN;
+	u32 autoc = IXGBE_READ_REG(hw, IXGBE_AUTOC);
+	u32 autoc2 = IXGBE_READ_REG(hw, IXGBE_AUTOC2);
+	u32 pma_pmd_10g_serial = autoc2 & IXGBE_AUTOC2_10G_SERIAL_PMA_PMD_MASK;
+	u32 pma_pmd_10g_parallel = autoc & IXGBE_AUTOC_10G_PMA_PMD_MASK;
+	u32 pma_pmd_1g = autoc & IXGBE_AUTOC_1G_PMA_PMD_MASK;
+	u16 ext_ability = 0;
 	u8 comp_codes_10g = 0;
 
-	switch (hw->device_id) {
-	case IXGBE_DEV_ID_82599:
-	case IXGBE_DEV_ID_82599_KX4:
-		/* Default device ID is mezzanine card KX/KX4 */
-		physical_layer = (IXGBE_PHYSICAL_LAYER_10GBASE_KX4 |
-		                  IXGBE_PHYSICAL_LAYER_1000BASE_KX);
+	hw->phy.ops.identify(hw);
+
+	if (hw->phy.type == ixgbe_phy_tn ||
+	    hw->phy.type == ixgbe_phy_cu_unknown) {
+		hw->phy.ops.read_reg(hw, IXGBE_MDIO_PHY_EXT_ABILITY,
+		IXGBE_MDIO_PMA_PMD_DEV_TYPE, &ext_ability);
+		if (ext_ability & IXGBE_MDIO_PHY_10GBASET_ABILITY)
+			physical_layer |= IXGBE_PHYSICAL_LAYER_10GBASE_T;
+		if (ext_ability & IXGBE_MDIO_PHY_1000BASET_ABILITY)
+			physical_layer |= IXGBE_PHYSICAL_LAYER_1000BASE_T;
+		if (ext_ability & IXGBE_MDIO_PHY_100BASETX_ABILITY)
+			physical_layer |= IXGBE_PHYSICAL_LAYER_100BASE_TX;
+		goto out;
+	}
+
+	switch (autoc & IXGBE_AUTOC_LMS_MASK) {
+	case IXGBE_AUTOC_LMS_1G_AN:
+	case IXGBE_AUTOC_LMS_1G_LINK_NO_AN:
+		if (pma_pmd_1g == IXGBE_AUTOC_1G_KX_BX) {
+			physical_layer = IXGBE_PHYSICAL_LAYER_1000BASE_KX |
+			    IXGBE_PHYSICAL_LAYER_1000BASE_BX;
+			goto out;
+		} else
+			/* SFI mode so read SFP module */
+			goto sfp_check;
 		break;
-	case IXGBE_DEV_ID_82599_SFP:
-		hw->phy.ops.identify_sfp(hw);
+	case IXGBE_AUTOC_LMS_10G_LINK_NO_AN:
+		if (pma_pmd_10g_parallel == IXGBE_AUTOC_10G_CX4)
+			physical_layer = IXGBE_PHYSICAL_LAYER_10GBASE_CX4;
+		else if (pma_pmd_10g_parallel == IXGBE_AUTOC_10G_KX4)
+			physical_layer = IXGBE_PHYSICAL_LAYER_10GBASE_KX4;
+		goto out;
+		break;
+	case IXGBE_AUTOC_LMS_10G_SERIAL:
+		if (pma_pmd_10g_serial == IXGBE_AUTOC2_10G_KR) {
+			physical_layer = IXGBE_PHYSICAL_LAYER_10GBASE_KR;
+			goto out;
+		} else if (pma_pmd_10g_serial == IXGBE_AUTOC2_10G_SFI)
+			goto sfp_check;
+		break;
+	case IXGBE_AUTOC_LMS_KX4_KX_KR:
+	case IXGBE_AUTOC_LMS_KX4_KX_KR_1G_AN:
+		if (autoc & IXGBE_AUTOC_KX_SUPP)
+			physical_layer |= IXGBE_PHYSICAL_LAYER_1000BASE_KX;
+		if (autoc & IXGBE_AUTOC_KX4_SUPP)
+			physical_layer |= IXGBE_PHYSICAL_LAYER_10GBASE_KX4;
+		if (autoc & IXGBE_AUTOC_KR_SUPP)
+			physical_layer |= IXGBE_PHYSICAL_LAYER_10GBASE_KR;
+		goto out;
+		break;
+	default:
+		goto out;
+		break;
+	}
 
-		switch (hw->phy.sfp_type) {
-		case ixgbe_sfp_type_da_cu:
-		case ixgbe_sfp_type_da_cu_core0:
-		case ixgbe_sfp_type_da_cu_core1:
-			physical_layer = IXGBE_PHYSICAL_LAYER_SFP_PLUS_CU;
-			break;
-		case ixgbe_sfp_type_sr:
+sfp_check:
+	/* SFP check must be done last since DA modules are sometimes used to
+	 * test KR mode -  we need to id KR mode correctly before SFP module.
+	 * Call identify_sfp because the pluggable module may have changed */
+	hw->phy.ops.identify_sfp(hw);
+	if (hw->phy.sfp_type == ixgbe_sfp_type_not_present)
+		goto out;
+
+	switch (hw->phy.type) {
+	case ixgbe_phy_tw_tyco:
+	case ixgbe_phy_tw_unknown:
+		physical_layer = IXGBE_PHYSICAL_LAYER_SFP_PLUS_CU;
+		break;
+	case ixgbe_phy_sfp_avago:
+	case ixgbe_phy_sfp_ftl:
+	case ixgbe_phy_sfp_intel:
+	case ixgbe_phy_sfp_unknown:
+		hw->phy.ops.read_i2c_eeprom(hw,
+		      IXGBE_SFF_10GBE_COMP_CODES, &comp_codes_10g);
+		if (comp_codes_10g & IXGBE_SFF_10GBASESR_CAPABLE)
 			physical_layer = IXGBE_PHYSICAL_LAYER_10GBASE_SR;
-			break;
-		case ixgbe_sfp_type_lr:
+		else if (comp_codes_10g & IXGBE_SFF_10GBASELR_CAPABLE)
 			physical_layer = IXGBE_PHYSICAL_LAYER_10GBASE_LR;
-			break;
-		case ixgbe_sfp_type_srlr_core0:
-		case ixgbe_sfp_type_srlr_core1:
-			hw->phy.ops.read_i2c_eeprom(hw,
-			                            IXGBE_SFF_10GBE_COMP_CODES,
-			                            &comp_codes_10g);
-			if (comp_codes_10g & IXGBE_SFF_10GBASESR_CAPABLE)
-				physical_layer =
-				                IXGBE_PHYSICAL_LAYER_10GBASE_SR;
-			else if (comp_codes_10g & IXGBE_SFF_10GBASELR_CAPABLE)
-				physical_layer =
-				                IXGBE_PHYSICAL_LAYER_10GBASE_LR;
-			else
-				physical_layer = IXGBE_PHYSICAL_LAYER_UNKNOWN;
-		default:
-			physical_layer = IXGBE_PHYSICAL_LAYER_UNKNOWN;
-			break;
-		}
 		break;
 	default:
-		physical_layer = IXGBE_PHYSICAL_LAYER_UNKNOWN;
 		break;
 	}
 
+out:
 	return physical_layer;
 }
 
@@ -1235,6 +1280,22 @@ s32 ixgbe_enable_rx_dma_82599(struct ixgbe_hw *hw, u32 regval)
 	return 0;
 }
 
+/**
+ *  ixgbe_get_device_caps_82599 - Get additional device capabilities
+ *  @hw: pointer to hardware structure
+ *  @device_caps: the EEPROM word with the extra device capabilities
+ *
+ *  This function will read the EEPROM location for the device capabilities,
+ *  and return the word through device_caps.
+ **/
+s32 ixgbe_get_device_caps_82599(struct ixgbe_hw *hw, u16 *device_caps)
+{
+	hw->eeprom.ops.read(hw, IXGBE_DEVICE_CAPS, device_caps);
+
+	return 0;
+}
+
+
 static struct ixgbe_mac_operations mac_ops_82599 = {
 	.init_hw                = &ixgbe_init_hw_generic,
 	.reset_hw               = &ixgbe_reset_hw_82599,
@@ -1244,6 +1305,7 @@ static struct ixgbe_mac_operations mac_ops_82599 = {
 	.get_supported_physical_layer = &ixgbe_get_supported_physical_layer_82599,
 	.enable_rx_dma          = &ixgbe_enable_rx_dma_82599,
 	.get_mac_addr           = &ixgbe_get_mac_addr_generic,
+	.get_device_caps        = &ixgbe_get_device_caps_82599,
 	.stop_adapter           = &ixgbe_stop_adapter_generic,
 	.get_bus_info           = &ixgbe_get_bus_info_generic,
 	.set_lan_id             = &ixgbe_set_lan_id_multi_port_pcie,
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 936a3ef..2856486 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -47,7 +47,7 @@ char ixgbe_driver_name[] = "ixgbe";
 static const char ixgbe_driver_string[] =
                               "Intel(R) 10 Gigabit PCI Express Network Driver";
 
-#define DRV_VERSION "2.0.8-k2"
+#define DRV_VERSION "2.0.16-k2"
 const char ixgbe_driver_version[] = DRV_VERSION;
 static char ixgbe_copyright[] = "Copyright (c) 1999-2009 Intel Corporation.";
 
diff --git a/drivers/net/ixgbe/ixgbe_phy.c b/drivers/net/ixgbe/ixgbe_phy.c
index 6f11df7..f3258ec 100644
--- a/drivers/net/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ixgbe/ixgbe_phy.c
@@ -632,7 +632,7 @@ s32 ixgbe_identify_sfp_module_generic(struct ixgbe_hw *hw)
 			hw->phy.multispeed_fiber = true;
 
 		/* Determine PHY vendor */
-		if (hw->phy.type == ixgbe_phy_unknown) {
+		if (hw->phy.type != ixgbe_phy_nl) {
 			hw->phy.id = identifier;
 			hw->phy.ops.read_i2c_eeprom(hw,
 			                            IXGBE_SFF_VENDOR_OUI_BYTE0,
@@ -682,9 +682,9 @@ s32 ixgbe_identify_sfp_module_generic(struct ixgbe_hw *hw)
 			goto out;
 		}
 
-		hw->eeprom.ops.read(hw, IXGBE_PHY_ENFORCE_INTEL_SFP_OFFSET,
-		                    &enforce_sfp);
-		if (!(enforce_sfp & IXGBE_PHY_ALLOW_ANY_SFP)) {
+		/* This is guaranteed to be 82599, no need to check for NULL */
+		hw->mac.ops.get_device_caps(hw, &enforce_sfp);
+		if (!(enforce_sfp & IXGBE_DEVICE_CAPS_ALLOW_ANY_SFP)) {
 			/* Make sure we're a supported PHY type */
 			if (hw->phy.type == ixgbe_phy_sfp_intel) {
 				status = 0;
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index db65c05..a3317d8 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -862,6 +862,7 @@
 #define IXGBE_MDIO_PHY_EXT_ABILITY        0xB /* Ext Ability Reg */
 #define IXGBE_MDIO_PHY_10GBASET_ABILITY   0x0004 /* 10GBaseT capable */
 #define IXGBE_MDIO_PHY_1000BASET_ABILITY  0x0020 /* 1000BaseT capable */
+#define IXGBE_MDIO_PHY_100BASETX_ABILITY  0x0080 /* 100BaseTX capable */
 
 #define IXGBE_MDIO_PMA_PMD_SDA_SCL_ADDR     0xC30A /* PHY_XS SDA/SCL Addr Reg */
 #define IXGBE_MDIO_PMA_PMD_SDA_SCL_DATA     0xC30B /* PHY_XS SDA/SCL Data Reg */
@@ -898,8 +899,6 @@
 #define IXGBE_CONTROL_NL         0x000F
 #define IXGBE_CONTROL_EOL_NL     0x0FFF
 #define IXGBE_CONTROL_SOL_NL     0x0000
-#define IXGBE_PHY_ENFORCE_INTEL_SFP_OFFSET 0x002C
-#define IXGBE_PHY_ALLOW_ANY_SFP            0x1
 
 /* General purpose Interrupt Enable */
 #define IXGBE_SDP0_GPIEN         0x00000001 /* SDP0 */
@@ -1385,6 +1384,7 @@
 #define IXGBE_FW_PTR            0x0F
 #define IXGBE_PBANUM0_PTR       0x15
 #define IXGBE_PBANUM1_PTR       0x16
+#define IXGBE_DEVICE_CAPS       0x2C
 #define IXGBE_PCIE_MSIX_82599_CAPS  0x72
 #define IXGBE_PCIE_MSIX_82598_CAPS  0x62
 
@@ -1428,6 +1428,8 @@
 #define IXGBE_EERD_ATTEMPTS 100000
 #endif
 
+#define IXGBE_DEVICE_CAPS_ALLOW_ANY_SFP  0x1
+
 /* PCI Bus Info */
 #define IXGBE_PCI_LINK_STATUS     0xB2
 #define IXGBE_PCI_LINK_WIDTH      0x3F0
@@ -1865,7 +1867,7 @@ typedef u32 ixgbe_physical_layer;
 #define IXGBE_PHYSICAL_LAYER_UNKNOWN      0
 #define IXGBE_PHYSICAL_LAYER_10GBASE_T    0x0001
 #define IXGBE_PHYSICAL_LAYER_1000BASE_T   0x0002
-#define IXGBE_PHYSICAL_LAYER_100BASE_T    0x0004
+#define IXGBE_PHYSICAL_LAYER_100BASE_TX   0x0004
 #define IXGBE_PHYSICAL_LAYER_SFP_PLUS_CU  0x0008
 #define IXGBE_PHYSICAL_LAYER_10GBASE_LR   0x0010
 #define IXGBE_PHYSICAL_LAYER_10GBASE_LRM  0x0020
@@ -1874,6 +1876,7 @@ typedef u32 ixgbe_physical_layer;
 #define IXGBE_PHYSICAL_LAYER_10GBASE_CX4  0x0100
 #define IXGBE_PHYSICAL_LAYER_1000BASE_KX  0x0200
 #define IXGBE_PHYSICAL_LAYER_1000BASE_BX  0x0400
+#define IXGBE_PHYSICAL_LAYER_10GBASE_KR   0x0800
 
 enum ixgbe_eeprom_type {
 	ixgbe_eeprom_uninitialized = 0,
@@ -2105,6 +2108,7 @@ struct ixgbe_mac_operations {
 	enum ixgbe_media_type (*get_media_type)(struct ixgbe_hw *);
 	u32 (*get_supported_physical_layer)(struct ixgbe_hw *);
 	s32 (*get_mac_addr)(struct ixgbe_hw *, u8 *);
+	s32 (*get_device_caps)(struct ixgbe_hw *, u16 *);
 	s32 (*stop_adapter)(struct ixgbe_hw *);
 	s32 (*get_bus_info)(struct ixgbe_hw *);
 	void (*set_lan_id)(struct ixgbe_hw *);

