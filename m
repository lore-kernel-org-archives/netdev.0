From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] e1000: Neaten e1000_config_dsp_after_link_change
Date: Thu, 09 Feb 2012 20:01:51 -0800
Message-ID: <1328846511.1936.4.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel <e1000-devel@lists.sourceforge.net>,
	netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:52999 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754556Ab2BJEBx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Feb 2012 23:01:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Separate a complicated bit of e1000_config_dsp_after_link_change
into a new static function e1000_1000Mb_check_cable_length.

Reduces indentation and adds a bit of clarity.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/intel/e1000/e1000_hw.c |  156 +++++++++++++--------------
 1 files changed, 73 insertions(+), 83 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_hw.c b/drivers/net/ethernet/intel/e1000/e1000_hw.c
index 36ee76b..c526279e4 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_hw.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_hw.c
@@ -5253,6 +5253,78 @@ static s32 e1000_check_downshift(struct e1000_hw *hw)
 	return E1000_SUCCESS;
 }
 
+static const u16 dsp_reg_array[IGP01E1000_PHY_CHANNEL_NUM] = {
+	IGP01E1000_PHY_AGC_PARAM_A,
+	IGP01E1000_PHY_AGC_PARAM_B,
+	IGP01E1000_PHY_AGC_PARAM_C,
+	IGP01E1000_PHY_AGC_PARAM_D
+};
+
+static s32 e1000_1000Mb_check_cable_length(struct e1000_hw *hw)
+{
+	u16 min_length, max_length;
+	u16 phy_data, i;
+	s32 ret_val;
+
+	ret_val = e1000_get_cable_length(hw, &min_length, &max_length);
+	if (ret_val)
+		return ret_val;
+
+	if (hw->dsp_config_state != e1000_dsp_config_enabled)
+		return 0;
+
+	if (min_length >= e1000_igp_cable_length_50) {
+		for (i = 0; i < IGP01E1000_PHY_CHANNEL_NUM; i++) {
+			ret_val = e1000_read_phy_reg(hw, dsp_reg_array[i],
+						     &phy_data);
+			if (ret_val)
+				return ret_val;
+
+			phy_data &= ~IGP01E1000_PHY_EDAC_MU_INDEX;
+
+			ret_val = e1000_write_phy_reg(hw, dsp_reg_array[i],
+						      phy_data);
+			if (ret_val)
+				return ret_val;
+		}
+		hw->dsp_config_state = e1000_dsp_config_activated;
+	} else {
+		u16 ffe_idle_err_timeout = FFE_IDLE_ERR_COUNT_TIMEOUT_20;
+		u32 idle_errs = 0;
+
+		/* clear previous idle error counts */
+		ret_val = e1000_read_phy_reg(hw, PHY_1000T_STATUS, &phy_data);
+		if (ret_val)
+			return ret_val;
+
+		for (i = 0; i < ffe_idle_err_timeout; i++) {
+			udelay(1000);
+			ret_val = e1000_read_phy_reg(hw, PHY_1000T_STATUS,
+						     &phy_data);
+			if (ret_val)
+				return ret_val;
+
+			idle_errs += (phy_data & SR_1000T_IDLE_ERROR_CNT);
+			if (idle_errs > SR_1000T_PHY_EXCESSIVE_IDLE_ERR_COUNT) {
+				hw->ffe_config_state = e1000_ffe_config_active;
+
+				ret_val = e1000_write_phy_reg(hw,
+					      IGP01E1000_PHY_DSP_FFE,
+					      IGP01E1000_PHY_DSP_FFE_CM_CP);
+				if (ret_val)
+					return ret_val;
+				break;
+			}
+
+			if (idle_errs)
+				ffe_idle_err_timeout =
+					    FFE_IDLE_ERR_COUNT_TIMEOUT_100;
+		}
+	}
+
+	return 0;
+}
+
 /**
  * e1000_config_dsp_after_link_change
  * @hw: Struct containing variables accessed by shared code
@@ -5269,13 +5341,6 @@ static s32 e1000_config_dsp_after_link_change(struct e1000_hw *hw, bool link_up)
 {
 	s32 ret_val;
 	u16 phy_data, phy_saved_data, speed, duplex, i;
-	static const u16 dsp_reg_array[IGP01E1000_PHY_CHANNEL_NUM] = {
-	       IGP01E1000_PHY_AGC_PARAM_A,
-	       IGP01E1000_PHY_AGC_PARAM_B,
-	       IGP01E1000_PHY_AGC_PARAM_C,
-	       IGP01E1000_PHY_AGC_PARAM_D
-	};
-	u16 min_length, max_length;
 
 	e_dbg("e1000_config_dsp_after_link_change");
 
@@ -5290,84 +5355,9 @@ static s32 e1000_config_dsp_after_link_change(struct e1000_hw *hw, bool link_up)
 		}
 
 		if (speed == SPEED_1000) {
-
-			ret_val =
-			    e1000_get_cable_length(hw, &min_length,
-						   &max_length);
+			ret_val = e1000_1000Mb_check_cable_length(hw);
 			if (ret_val)
 				return ret_val;
-
-			if ((hw->dsp_config_state == e1000_dsp_config_enabled)
-			    && min_length >= e1000_igp_cable_length_50) {
-
-				for (i = 0; i < IGP01E1000_PHY_CHANNEL_NUM; i++) {
-					ret_val =
-					    e1000_read_phy_reg(hw,
-							       dsp_reg_array[i],
-							       &phy_data);
-					if (ret_val)
-						return ret_val;
-
-					phy_data &=
-					    ~IGP01E1000_PHY_EDAC_MU_INDEX;
-
-					ret_val =
-					    e1000_write_phy_reg(hw,
-								dsp_reg_array
-								[i], phy_data);
-					if (ret_val)
-						return ret_val;
-				}
-				hw->dsp_config_state =
-				    e1000_dsp_config_activated;
-			}
-
-			if ((hw->ffe_config_state == e1000_ffe_config_enabled)
-			    && (min_length < e1000_igp_cable_length_50)) {
-
-				u16 ffe_idle_err_timeout =
-				    FFE_IDLE_ERR_COUNT_TIMEOUT_20;
-				u32 idle_errs = 0;
-
-				/* clear previous idle error counts */
-				ret_val =
-				    e1000_read_phy_reg(hw, PHY_1000T_STATUS,
-						       &phy_data);
-				if (ret_val)
-					return ret_val;
-
-				for (i = 0; i < ffe_idle_err_timeout; i++) {
-					udelay(1000);
-					ret_val =
-					    e1000_read_phy_reg(hw,
-							       PHY_1000T_STATUS,
-							       &phy_data);
-					if (ret_val)
-						return ret_val;
-
-					idle_errs +=
-					    (phy_data &
-					     SR_1000T_IDLE_ERROR_CNT);
-					if (idle_errs >
-					    SR_1000T_PHY_EXCESSIVE_IDLE_ERR_COUNT)
-					{
-						hw->ffe_config_state =
-						    e1000_ffe_config_active;
-
-						ret_val =
-						    e1000_write_phy_reg(hw,
-									IGP01E1000_PHY_DSP_FFE,
-									IGP01E1000_PHY_DSP_FFE_CM_CP);
-						if (ret_val)
-							return ret_val;
-						break;
-					}
-
-					if (idle_errs)
-						ffe_idle_err_timeout =
-						    FFE_IDLE_ERR_COUNT_TIMEOUT_100;
-				}
-			}
 		}
 	} else {
 		if (hw->dsp_config_state == e1000_dsp_config_activated) {
