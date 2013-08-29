From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 10/10] ixgbe: add support for older QSFP active DA cables
Date: Thu, 29 Aug 2013 03:50:06 -0700
Message-ID: <1377773406-24851-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1377773406-24851-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:40598 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756226Ab3H2Kuc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Aug 2013 06:50:32 -0400
In-Reply-To: <1377773406-24851-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch adds support for QSFP active direct attach (DA) cables which
pre-date SFF-8436 v3.6.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c | 55 +++++++++++++++++++++++-----
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h |  5 +++
 2 files changed, 50 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
index e89b34e..e4c6760 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
@@ -1175,6 +1175,10 @@ s32 ixgbe_identify_qsfp_module_generic(struct ixgbe_hw *hw)
 	u8 comp_codes_10g = 0;
 	u8 oui_bytes[3] = {0, 0, 0};
 	u16 enforce_sfp = 0;
+	u8 connector = 0;
+	u8 cable_length = 0;
+	u8 device_tech = 0;
+	bool active_cable = false;
 
 	if (hw->mac.ops.get_media_type(hw) != ixgbe_media_type_fiber_qsfp) {
 		hw->phy.sfp_type = ixgbe_sfp_type_not_present;
@@ -1217,12 +1221,6 @@ s32 ixgbe_identify_qsfp_module_generic(struct ixgbe_hw *hw)
 			hw->phy.sfp_type = ixgbe_sfp_type_da_cu_core0;
 		else
 			hw->phy.sfp_type = ixgbe_sfp_type_da_cu_core1;
-	} else if (comp_codes_10g & IXGBE_SFF_QSFP_DA_ACTIVE_CABLE) {
-		hw->phy.type = ixgbe_phy_qsfp_active_unknown;
-		if (hw->bus.lan_id == 0)
-			hw->phy.sfp_type = ixgbe_sfp_type_da_act_lmt_core0;
-		else
-			hw->phy.sfp_type = ixgbe_sfp_type_da_act_lmt_core1;
 	} else if (comp_codes_10g & (IXGBE_SFF_10GBASESR_CAPABLE |
 				     IXGBE_SFF_10GBASELR_CAPABLE)) {
 		if (hw->bus.lan_id == 0)
@@ -1230,10 +1228,47 @@ s32 ixgbe_identify_qsfp_module_generic(struct ixgbe_hw *hw)
 		else
 			hw->phy.sfp_type = ixgbe_sfp_type_srlr_core1;
 	} else {
-		/* unsupported module type */
-		hw->phy.type = ixgbe_phy_sfp_unsupported;
-		status = IXGBE_ERR_SFP_NOT_SUPPORTED;
-		goto out;
+		if (comp_codes_10g & IXGBE_SFF_QSFP_DA_ACTIVE_CABLE)
+			active_cable = true;
+
+		if (!active_cable) {
+			/* check for active DA cables that pre-date
+			 * SFF-8436 v3.6
+			 */
+			hw->phy.ops.read_i2c_eeprom(hw,
+					IXGBE_SFF_QSFP_CONNECTOR,
+					&connector);
+
+			hw->phy.ops.read_i2c_eeprom(hw,
+					IXGBE_SFF_QSFP_CABLE_LENGTH,
+					&cable_length);
+
+			hw->phy.ops.read_i2c_eeprom(hw,
+					IXGBE_SFF_QSFP_DEVICE_TECH,
+					&device_tech);
+
+			if ((connector ==
+				     IXGBE_SFF_QSFP_CONNECTOR_NOT_SEPARABLE) &&
+			    (cable_length > 0) &&
+			    ((device_tech >> 4) ==
+				     IXGBE_SFF_QSFP_TRANSMITER_850NM_VCSEL))
+				active_cable = true;
+		}
+
+		if (active_cable) {
+			hw->phy.type = ixgbe_phy_qsfp_active_unknown;
+			if (hw->bus.lan_id == 0)
+				hw->phy.sfp_type =
+						ixgbe_sfp_type_da_act_lmt_core0;
+			else
+				hw->phy.sfp_type =
+						ixgbe_sfp_type_da_act_lmt_core1;
+		} else {
+			/* unsupported module type */
+			hw->phy.type = ixgbe_phy_sfp_unsupported;
+			status = IXGBE_ERR_SFP_NOT_SUPPORTED;
+			goto out;
+		}
 	}
 
 	if (hw->phy.sfp_type != stored_sfp_type)
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h
index 138dadd..24af12e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.h
@@ -50,8 +50,11 @@
 #define IXGBE_SFF_QSFP_VENDOR_OUI_BYTE0	0xA5
 #define IXGBE_SFF_QSFP_VENDOR_OUI_BYTE1	0xA6
 #define IXGBE_SFF_QSFP_VENDOR_OUI_BYTE2	0xA7
+#define IXGBE_SFF_QSFP_CONNECTOR	0x82
 #define IXGBE_SFF_QSFP_10GBE_COMP	0x83
 #define IXGBE_SFF_QSFP_1GBE_COMP	0x86
+#define IXGBE_SFF_QSFP_CABLE_LENGTH	0x92
+#define IXGBE_SFF_QSFP_DEVICE_TECH	0x93
 
 /* Bitmasks */
 #define IXGBE_SFF_DA_PASSIVE_CABLE           0x4
@@ -68,6 +71,8 @@
 #define IXGBE_SFF_ADDRESSING_MODE	     0x4
 #define IXGBE_SFF_QSFP_DA_ACTIVE_CABLE       0x1
 #define IXGBE_SFF_QSFP_DA_PASSIVE_CABLE      0x8
+#define IXGBE_SFF_QSFP_CONNECTOR_NOT_SEPARABLE	0x23
+#define IXGBE_SFF_QSFP_TRANSMITER_850NM_VCSEL	0x0
 #define IXGBE_I2C_EEPROM_READ_MASK           0x100
 #define IXGBE_I2C_EEPROM_STATUS_MASK         0x3
 #define IXGBE_I2C_EEPROM_STATUS_NO_OPERATION 0x0
-- 
1.8.3.1
