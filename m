From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/3] ixgbe: Change Direct Attach Twinax cable
	detection for SFP+ NICs
Date: Tue, 19 May 2009 12:18:51 -0700
Message-ID: <20090519191851.5063.42840.stgit@localhost.localdomain>
References: <20090519191819.5063.28388.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.emeryville.ca.mail.comcast.net ([76.96.30.17]:43667 "EHLO
	QMTA10.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753127AbZESTTI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 15:19:08 -0400
In-Reply-To: <20090519191819.5063.28388.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

The SFF specification for Direct Attach cable detection has now been
ratified.  Previously, DA cable detect was looking at the Twinaxial bit in
byte 9 of the SFP+ EEPROM.  The spec now defines active and passive DA
cables in byte 8 of the SFP+ EEPROM.  This patch changes the cable
detection for both 82598 and 82599 SFP+ adapters to conform to the new
spec.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_phy.c |   20 +++++++++-----------
 drivers/net/ixgbe/ixgbe_phy.h |    4 ++--
 2 files changed, 11 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_phy.c b/drivers/net/ixgbe/ixgbe_phy.c
index 6d385ea..8210b49 100644
--- a/drivers/net/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ixgbe/ixgbe_phy.c
@@ -527,7 +527,7 @@ s32 ixgbe_identify_sfp_module_generic(struct ixgbe_hw *hw)
 	u8 comp_codes_1g = 0;
 	u8 comp_codes_10g = 0;
 	u8 oui_bytes[3] = {0, 0, 0};
-	u8 transmission_media = 0;
+	u8 cable_tech = 0;
 	u16 enforce_sfp = 0;
 
 	status = hw->phy.ops.read_i2c_eeprom(hw, IXGBE_SFF_IDENTIFIER,
@@ -543,8 +543,8 @@ s32 ixgbe_identify_sfp_module_generic(struct ixgbe_hw *hw)
 		                            &comp_codes_1g);
 		hw->phy.ops.read_i2c_eeprom(hw, IXGBE_SFF_10GBE_COMP_CODES,
 		                            &comp_codes_10g);
-		hw->phy.ops.read_i2c_eeprom(hw, IXGBE_SFF_TRANSMISSION_MEDIA,
-		                            &transmission_media);
+		hw->phy.ops.read_i2c_eeprom(hw, IXGBE_SFF_CABLE_TECHNOLOGY,
+		                            &cable_tech);
 
 		/* ID Module
 		 * =========
@@ -557,7 +557,7 @@ s32 ixgbe_identify_sfp_module_generic(struct ixgbe_hw *hw)
 		 * 6    SFP_SR/LR_CORE1 - 82599-specific
 		 */
 		if (hw->mac.type == ixgbe_mac_82598EB) {
-			if (transmission_media & IXGBE_SFF_TWIN_AX_CAPABLE)
+			if (cable_tech & IXGBE_SFF_DA_PASSIVE_CABLE)
 				hw->phy.sfp_type = ixgbe_sfp_type_da_cu;
 			else if (comp_codes_10g & IXGBE_SFF_10GBASESR_CAPABLE)
 				hw->phy.sfp_type = ixgbe_sfp_type_sr;
@@ -566,7 +566,7 @@ s32 ixgbe_identify_sfp_module_generic(struct ixgbe_hw *hw)
 			else
 				hw->phy.sfp_type = ixgbe_sfp_type_unknown;
 		} else if (hw->mac.type == ixgbe_mac_82599EB) {
-			if (transmission_media & IXGBE_SFF_TWIN_AX_CAPABLE)
+			if (cable_tech & IXGBE_SFF_DA_PASSIVE_CABLE)
 				if (hw->bus.lan_id == 0)
 					hw->phy.sfp_type =
 					             ixgbe_sfp_type_da_cu_core0;
@@ -621,8 +621,7 @@ s32 ixgbe_identify_sfp_module_generic(struct ixgbe_hw *hw)
 
 			switch (vendor_oui) {
 			case IXGBE_SFF_VENDOR_OUI_TYCO:
-				if (transmission_media &
-				    IXGBE_SFF_TWIN_AX_CAPABLE)
+				if (cable_tech & IXGBE_SFF_DA_PASSIVE_CABLE)
 					hw->phy.type = ixgbe_phy_tw_tyco;
 				break;
 			case IXGBE_SFF_VENDOR_OUI_FTL:
@@ -635,8 +634,7 @@ s32 ixgbe_identify_sfp_module_generic(struct ixgbe_hw *hw)
 				hw->phy.type = ixgbe_phy_sfp_intel;
 				break;
 			default:
-				if (transmission_media &
-				    IXGBE_SFF_TWIN_AX_CAPABLE)
+				if (cable_tech & IXGBE_SFF_DA_PASSIVE_CABLE)
 					hw->phy.type = ixgbe_phy_tw_unknown;
 				else
 					hw->phy.type = ixgbe_phy_sfp_unknown;
@@ -644,8 +642,8 @@ s32 ixgbe_identify_sfp_module_generic(struct ixgbe_hw *hw)
 			}
 		}
 
-		/* All DA cables are supported */
-		if (transmission_media & IXGBE_SFF_TWIN_AX_CAPABLE) {
+		/* All passive DA cables are supported */
+		if (cable_tech & IXGBE_SFF_DA_PASSIVE_CABLE) {
 			status = 0;
 			goto out;
 		}
diff --git a/drivers/net/ixgbe/ixgbe_phy.h b/drivers/net/ixgbe/ixgbe_phy.h
index c9964b7..9b700f5 100644
--- a/drivers/net/ixgbe/ixgbe_phy.h
+++ b/drivers/net/ixgbe/ixgbe_phy.h
@@ -39,10 +39,10 @@
 #define IXGBE_SFF_VENDOR_OUI_BYTE2   0x27
 #define IXGBE_SFF_1GBE_COMP_CODES    0x6
 #define IXGBE_SFF_10GBE_COMP_CODES   0x3
-#define IXGBE_SFF_TRANSMISSION_MEDIA 0x9
+#define IXGBE_SFF_CABLE_TECHNOLOGY   0x8
 
 /* Bitmasks */
-#define IXGBE_SFF_TWIN_AX_CAPABLE            0x80
+#define IXGBE_SFF_DA_PASSIVE_CABLE           0x4
 #define IXGBE_SFF_1GBASESX_CAPABLE           0x1
 #define IXGBE_SFF_1GBASELX_CAPABLE           0x2
 #define IXGBE_SFF_10GBASESR_CAPABLE          0x10

