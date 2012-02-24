From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/16] e1000: Neaten e1000_config_dsp_after_link_change
Date: Fri, 24 Feb 2012 02:13:08 -0800
Message-ID: <1330078389-8203-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1330078389-8203-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:43469 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756847Ab2BXKNT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Feb 2012 05:13:19 -0500
In-Reply-To: <1330078389-8203-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

Separate a complicated bit of e1000_config_dsp_after_link_change
into a new static function e1000_1000Mb_check_cable_length.

Reduces indentation and adds a bit of clarity.

Signed-off-by: Joe Perches <joe@perches.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
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
-- 
1.7.7.6
