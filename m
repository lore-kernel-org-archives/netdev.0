From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/15] ixgbe: Add KR mode support for CS4227 chip
Date: Mon, 23 Nov 2015 11:36:09 -0800
Message-ID: <1448307376-20063-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1448307376-20063-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:44986 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754808AbbKWTgX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2015 14:36:23 -0500
In-Reply-To: <1448307376-20063-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

KR auto-neg mode is what we will be using going forward. The SW
interface for this mode is different that what was used for iXFI.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 85 +++++++++++++++++++--------
 1 file changed, 62 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index ebe0ac9..005f01b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -26,6 +26,8 @@
 #include "ixgbe_common.h"
 #include "ixgbe_phy.h"
 
+static s32 ixgbe_setup_kr_speed_x550em(struct ixgbe_hw *, ixgbe_link_speed);
+
 static s32 ixgbe_get_invariants_X550_x(struct ixgbe_hw *hw)
 {
 	struct ixgbe_mac_info *mac = &hw->mac;
@@ -1257,31 +1259,71 @@ ixgbe_setup_mac_link_sfp_x550em(struct ixgbe_hw *hw,
 	if (status)
 		return status;
 
-	/* Configure CS4227 LINE side to 10G SR. */
-	slice = IXGBE_CS4227_LINE_SPARE22_MSB + (hw->bus.lan_id << 12);
-	value = IXGBE_CS4227_SPEED_10G;
-	status = ixgbe_write_i2c_combined_generic(hw, IXGBE_CS4227, slice,
-						  value);
-
-	/* Configure CS4227 for HOST connection rate then type. */
-	slice = IXGBE_CS4227_HOST_SPARE22_MSB + (hw->bus.lan_id << 12);
-	value = speed & IXGBE_LINK_SPEED_10GB_FULL ?
-		IXGBE_CS4227_SPEED_10G : IXGBE_CS4227_SPEED_1G;
-	status = ixgbe_write_i2c_combined_generic(hw, IXGBE_CS4227, slice,
-						  value);
+	if (!(hw->phy.nw_mng_if_sel & IXGBE_NW_MNG_IF_SEL_INT_PHY_MODE)) {
+		/* Configure CS4227 LINE side to 10G SR. */
+		slice = IXGBE_CS4227_LINE_SPARE22_MSB + (hw->bus.lan_id << 12);
+		value = IXGBE_CS4227_SPEED_10G;
+		status = ixgbe_write_i2c_combined_generic(hw, IXGBE_CS4227,
+							  slice, value);
+		if (status)
+			goto i2c_err;
 
-	slice = IXGBE_CS4227_HOST_SPARE24_LSB + (hw->bus.lan_id << 12);
-	if (setup_linear)
-		value = (IXGBE_CS4227_EDC_MODE_CX1 << 1) | 1;
-	else
+		slice = IXGBE_CS4227_LINE_SPARE24_LSB + (hw->bus.lan_id << 12);
 		value = (IXGBE_CS4227_EDC_MODE_SR << 1) | 1;
-	status = ixgbe_write_i2c_combined_generic(hw, IXGBE_CS4227, slice,
-						  value);
+		status = ixgbe_write_i2c_combined_generic(hw, IXGBE_CS4227,
+							  slice, value);
+		if (status)
+			goto i2c_err;
+
+		/* Configure CS4227 for HOST connection rate then type. */
+		slice = IXGBE_CS4227_HOST_SPARE22_MSB + (hw->bus.lan_id << 12);
+		value = speed & IXGBE_LINK_SPEED_10GB_FULL ?
+			IXGBE_CS4227_SPEED_10G : IXGBE_CS4227_SPEED_1G;
+		status = ixgbe_write_i2c_combined_generic(hw, IXGBE_CS4227,
+							  slice, value);
+		if (status)
+			goto i2c_err;
 
-	/* If internal link mode is XFI, then setup XFI internal link. */
-	if (!(hw->phy.nw_mng_if_sel & IXGBE_NW_MNG_IF_SEL_INT_PHY_MODE))
+		slice = IXGBE_CS4227_HOST_SPARE24_LSB + (hw->bus.lan_id << 12);
+		if (setup_linear)
+			value = (IXGBE_CS4227_EDC_MODE_CX1 << 1) | 1;
+		else
+			value = (IXGBE_CS4227_EDC_MODE_SR << 1) | 1;
+		status = ixgbe_write_i2c_combined_generic(hw, IXGBE_CS4227,
+							  slice, value);
+		if (status)
+			goto i2c_err;
+
+		/* Setup XFI internal link. */
 		status = ixgbe_setup_ixfi_x550em(hw, &speed);
+		if (status) {
+			hw_dbg(hw, "setup_ixfi failed with %d\n", status);
+			return status;
+		}
+	} else {
+		/* Configure internal PHY for KR/KX. */
+		status = ixgbe_setup_kr_speed_x550em(hw, speed);
+		if (status) {
+			hw_dbg(hw, "setup_kr_speed failed with %d\n", status);
+			return status;
+		}
 
+		/* Configure CS4227 LINE side to proper mode. */
+		slice = IXGBE_CS4227_LINE_SPARE24_LSB + (hw->bus.lan_id << 12);
+		if (setup_linear)
+			value = (IXGBE_CS4227_EDC_MODE_CX1 << 1) | 1;
+		else
+			value = (IXGBE_CS4227_EDC_MODE_SR << 1) | 1;
+		status = ixgbe_write_i2c_combined_generic(hw, IXGBE_CS4227,
+							  slice, value);
+		if (status)
+			goto i2c_err;
+	}
+
+	return 0;
+
+i2c_err:
+	hw_dbg(hw, "combined i2c access failed with %d\n", status);
 	return status;
 }
 
@@ -1982,12 +2024,9 @@ static s32 ixgbe_init_phy_ops_X550em(struct ixgbe_hw *hw)
 		 * to determine internal PHY mode.
 		 */
 		phy->nw_mng_if_sel = IXGBE_READ_REG(hw, IXGBE_NW_MNG_IF_SEL);
-
-		/* If internal PHY mode is KR, then initialize KR link */
 		if (phy->nw_mng_if_sel & IXGBE_NW_MNG_IF_SEL_INT_PHY_MODE) {
 			speed = IXGBE_LINK_SPEED_10GB_FULL |
 				IXGBE_LINK_SPEED_1GB_FULL;
-			ret_val = ixgbe_setup_kr_speed_x550em(hw, speed);
 		}
 	}
 
-- 
2.5.0
