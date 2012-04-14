From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/6] e1000e: cleanup boolean logic
Date: Sat, 14 Apr 2012 02:16:29 -0700
Message-ID: <1334394991-5839-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1334394991-5839-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:14898 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753293Ab2DNJQg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Apr 2012 05:16:36 -0400
In-Reply-To: <1334394991-5839-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Replace occurrences of 'if (<bool expr> == <1|0>)' with
'if ([!]<bool expr>)'

Replace occurrences of '<bool var> = (<non-bool expr>) ? true : false'
with '<bool var> = <non-bool expr>'.

Replace occurrence of '<bool var> = <non-bool expr>' with
'<bool var> = !!<non-bool expr>'

While the latter replacement is not really necessary, it is done here for
consistency and clarity.  No functional changes.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/80003es2lan.c |    4 +--
 drivers/net/ethernet/intel/e1000e/82571.c       |    9 +++----
 drivers/net/ethernet/intel/e1000e/ich8lan.c     |   26 +++++++++++-----------
 drivers/net/ethernet/intel/e1000e/mac.c         |    2 +-
 drivers/net/ethernet/intel/e1000e/manage.c      |    2 +-
 drivers/net/ethernet/intel/e1000e/phy.c         |   23 +++++++++----------
 6 files changed, 31 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/80003es2lan.c b/drivers/net/ethernet/intel/e1000e/80003es2lan.c
index bac9dda..fbc84d4 100644
--- a/drivers/net/ethernet/intel/e1000e/80003es2lan.c
+++ b/drivers/net/ethernet/intel/e1000e/80003es2lan.c
@@ -228,9 +228,7 @@ static s32 e1000_init_mac_params_80003es2lan(struct e1000_hw *hw)
 	/* FWSM register */
 	mac->has_fwsm = true;
 	/* ARC supported; valid only if manageability features are enabled. */
-	mac->arc_subsystem_valid =
-	        (er32(FWSM) & E1000_FWSM_MODE_MASK)
-	                ? true : false;
+	mac->arc_subsystem_valid = !!(er32(FWSM) & E1000_FWSM_MODE_MASK);
 	/* Adaptive IFS not supported */
 	mac->adaptive_ifs = false;
 
diff --git a/drivers/net/ethernet/intel/e1000e/82571.c b/drivers/net/ethernet/intel/e1000e/82571.c
index b3fdc69..609c18c 100644
--- a/drivers/net/ethernet/intel/e1000e/82571.c
+++ b/drivers/net/ethernet/intel/e1000e/82571.c
@@ -295,9 +295,8 @@ static s32 e1000_init_mac_params_82571(struct e1000_hw *hw)
 		 * ARC supported; valid only if manageability features are
 		 * enabled.
 		 */
-		mac->arc_subsystem_valid =
-			(er32(FWSM) & E1000_FWSM_MODE_MASK)
-			? true : false;
+		mac->arc_subsystem_valid = !!(er32(FWSM) &
+					      E1000_FWSM_MODE_MASK);
 		break;
 	case e1000_82574:
 	case e1000_82583:
@@ -798,7 +797,7 @@ static s32 e1000_update_nvm_checksum_82571(struct e1000_hw *hw)
 	/* Check for pending operations. */
 	for (i = 0; i < E1000_FLASH_UPDATES; i++) {
 		usleep_range(1000, 2000);
-		if ((er32(EECD) & E1000_EECD_FLUPD) == 0)
+		if (!(er32(EECD) & E1000_EECD_FLUPD))
 			break;
 	}
 
@@ -822,7 +821,7 @@ static s32 e1000_update_nvm_checksum_82571(struct e1000_hw *hw)
 
 	for (i = 0; i < E1000_FLASH_UPDATES; i++) {
 		usleep_range(1000, 2000);
-		if ((er32(EECD) & E1000_EECD_FLUPD) == 0)
+		if (!(er32(EECD) & E1000_EECD_FLUPD))
 			break;
 	}
 
diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 64c7644..0f158a9 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -2212,7 +2212,7 @@ static s32 e1000_flash_cycle_init_ich8lan(struct e1000_hw *hw)
 	hsfsts.regval = er16flash(ICH_FLASH_HSFSTS);
 
 	/* Check if the flash descriptor is valid */
-	if (hsfsts.hsf_status.fldesvalid == 0) {
+	if (!hsfsts.hsf_status.fldesvalid) {
 		e_dbg("Flash descriptor invalid.  SW Sequencing must be used.\n");
 		return -E1000_ERR_NVM;
 	}
@@ -2232,7 +2232,7 @@ static s32 e1000_flash_cycle_init_ich8lan(struct e1000_hw *hw)
 	 * completed.
 	 */
 
-	if (hsfsts.hsf_status.flcinprog == 0) {
+	if (!hsfsts.hsf_status.flcinprog) {
 		/*
 		 * There is no cycle running at present,
 		 * so we can start a cycle.
@@ -2250,7 +2250,7 @@ static s32 e1000_flash_cycle_init_ich8lan(struct e1000_hw *hw)
 		 */
 		for (i = 0; i < ICH_FLASH_READ_COMMAND_TIMEOUT; i++) {
 			hsfsts.regval = er16flash(ICH_FLASH_HSFSTS);
-			if (hsfsts.hsf_status.flcinprog == 0) {
+			if (!hsfsts.hsf_status.flcinprog) {
 				ret_val = 0;
 				break;
 			}
@@ -2292,12 +2292,12 @@ static s32 e1000_flash_cycle_ich8lan(struct e1000_hw *hw, u32 timeout)
 	/* wait till FDONE bit is set to 1 */
 	do {
 		hsfsts.regval = er16flash(ICH_FLASH_HSFSTS);
-		if (hsfsts.hsf_status.flcdone == 1)
+		if (hsfsts.hsf_status.flcdone)
 			break;
 		udelay(1);
 	} while (i++ < timeout);
 
-	if (hsfsts.hsf_status.flcdone == 1 && hsfsts.hsf_status.flcerr == 0)
+	if (hsfsts.hsf_status.flcdone && !hsfsts.hsf_status.flcerr)
 		return 0;
 
 	return -E1000_ERR_NVM;
@@ -2408,10 +2408,10 @@ static s32 e1000_read_flash_data_ich8lan(struct e1000_hw *hw, u32 offset,
 			 * ICH_FLASH_CYCLE_REPEAT_COUNT times.
 			 */
 			hsfsts.regval = er16flash(ICH_FLASH_HSFSTS);
-			if (hsfsts.hsf_status.flcerr == 1) {
+			if (hsfsts.hsf_status.flcerr) {
 				/* Repeat for some time before giving up. */
 				continue;
-			} else if (hsfsts.hsf_status.flcdone == 0) {
+			} else if (!hsfsts.hsf_status.flcdone) {
 				e_dbg("Timeout error - flash cycle did not complete.\n");
 				break;
 			}
@@ -2641,7 +2641,7 @@ static s32 e1000_validate_nvm_checksum_ich8lan(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
-	if ((data & 0x40) == 0) {
+	if (!(data & 0x40)) {
 		data |= 0x40;
 		ret_val = e1000_write_nvm(hw, 0x19, 1, &data);
 		if (ret_val)
@@ -2759,10 +2759,10 @@ static s32 e1000_write_flash_data_ich8lan(struct e1000_hw *hw, u32 offset,
 		 * try...ICH_FLASH_CYCLE_REPEAT_COUNT times.
 		 */
 		hsfsts.regval = er16flash(ICH_FLASH_HSFSTS);
-		if (hsfsts.hsf_status.flcerr == 1)
+		if (hsfsts.hsf_status.flcerr)
 			/* Repeat for some time before giving up. */
 			continue;
-		if (hsfsts.hsf_status.flcdone == 0) {
+		if (!hsfsts.hsf_status.flcdone) {
 			e_dbg("Timeout error - flash cycle did not complete.\n");
 			break;
 		}
@@ -2914,10 +2914,10 @@ static s32 e1000_erase_flash_bank_ich8lan(struct e1000_hw *hw, u32 bank)
 			 * a few more times else Done
 			 */
 			hsfsts.regval = er16flash(ICH_FLASH_HSFSTS);
-			if (hsfsts.hsf_status.flcerr == 1)
+			if (hsfsts.hsf_status.flcerr)
 				/* repeat for some time before giving up */
 				continue;
-			else if (hsfsts.hsf_status.flcdone == 0)
+			else if (!hsfsts.hsf_status.flcdone)
 				return ret_val;
 		} while (++count < ICH_FLASH_CYCLE_REPEAT_COUNT);
 	}
@@ -3916,7 +3916,7 @@ static s32 e1000_get_cfg_done_ich8lan(struct e1000_hw *hw)
 
 	/* If EEPROM is not marked present, init the IGP 3 PHY manually */
 	if (hw->mac.type <= e1000_ich9lan) {
-		if (((er32(EECD) & E1000_EECD_PRES) == 0) &&
+		if (!(er32(EECD) & E1000_EECD_PRES) &&
 		    (hw->phy.type == e1000_phy_igp_3)) {
 			e1000e_phy_init_script_igp3(hw);
 		}
diff --git a/drivers/net/ethernet/intel/e1000e/mac.c b/drivers/net/ethernet/intel/e1000e/mac.c
index decad98..d832749 100644
--- a/drivers/net/ethernet/intel/e1000e/mac.c
+++ b/drivers/net/ethernet/intel/e1000e/mac.c
@@ -681,7 +681,7 @@ static s32 e1000_set_default_fc_generic(struct e1000_hw *hw)
 		return ret_val;
 	}
 
-	if ((nvm_data & NVM_WORD0F_PAUSE_MASK) == 0)
+	if (!(nvm_data & NVM_WORD0F_PAUSE_MASK))
 		hw->fc.requested_mode = e1000_fc_none;
 	else if ((nvm_data & NVM_WORD0F_PAUSE_MASK) == NVM_WORD0F_ASM_DIR)
 		hw->fc.requested_mode = e1000_fc_tx_pause;
diff --git a/drivers/net/ethernet/intel/e1000e/manage.c b/drivers/net/ethernet/intel/e1000e/manage.c
index 473f8e7..bacc950 100644
--- a/drivers/net/ethernet/intel/e1000e/manage.c
+++ b/drivers/net/ethernet/intel/e1000e/manage.c
@@ -85,7 +85,7 @@ static s32 e1000_mng_enable_host_if(struct e1000_hw *hw)
 
 	/* Check that the host interface is enabled. */
 	hicr = er32(HICR);
-	if ((hicr & E1000_HICR_EN) == 0) {
+	if (!(hicr & E1000_HICR_EN)) {
 		e_dbg("E1000_HOST_EN bit disabled.\n");
 		return -E1000_ERR_HOST_INTERFACE_COMMAND;
 	}
diff --git a/drivers/net/ethernet/intel/e1000e/phy.c b/drivers/net/ethernet/intel/e1000e/phy.c
index 35b4557..bd5ef64 100644
--- a/drivers/net/ethernet/intel/e1000e/phy.c
+++ b/drivers/net/ethernet/intel/e1000e/phy.c
@@ -718,7 +718,7 @@ s32 e1000e_copper_link_setup_m88(struct e1000_hw *hw)
 	 *   1 - Enabled
 	 */
 	phy_data &= ~M88E1000_PSCR_POLARITY_REVERSAL;
-	if (phy->disable_polarity_correction == 1)
+	if (phy->disable_polarity_correction)
 		phy_data |= M88E1000_PSCR_POLARITY_REVERSAL;
 
 	/* Enable downshift on BM (disabled by default) */
@@ -1090,7 +1090,7 @@ static s32 e1000_copper_link_autoneg(struct e1000_hw *hw)
 	 * If autoneg_advertised is zero, we assume it was not defaulted
 	 * by the calling code so we set to advertise full capability.
 	 */
-	if (phy->autoneg_advertised == 0)
+	if (!phy->autoneg_advertised)
 		phy->autoneg_advertised = phy->autoneg_mask;
 
 	e_dbg("Reconfiguring auto-neg advertisement params\n");
@@ -1596,7 +1596,7 @@ s32 e1000e_check_downshift(struct e1000_hw *hw)
 	ret_val = e1e_rphy(hw, offset, &phy_data);
 
 	if (!ret_val)
-		phy->speed_downgraded = (phy_data & mask);
+		phy->speed_downgraded = !!(phy_data & mask);
 
 	return ret_val;
 }
@@ -1925,8 +1925,8 @@ s32 e1000e_get_phy_info_m88(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
-	phy->polarity_correction = (phy_data &
-				    M88E1000_PSCR_POLARITY_REVERSAL);
+	phy->polarity_correction = !!(phy_data &
+				      M88E1000_PSCR_POLARITY_REVERSAL);
 
 	ret_val = e1000_check_polarity_m88(hw);
 	if (ret_val)
@@ -1936,7 +1936,7 @@ s32 e1000e_get_phy_info_m88(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
-	phy->is_mdix = (phy_data & M88E1000_PSSR_MDIX);
+	phy->is_mdix = !!(phy_data & M88E1000_PSSR_MDIX);
 
 	if ((phy_data & M88E1000_PSSR_SPEED) == M88E1000_PSSR_1000MBS) {
 		ret_val = e1000_get_cable_length(hw);
@@ -1999,7 +1999,7 @@ s32 e1000e_get_phy_info_igp(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
-	phy->is_mdix = (data & IGP01E1000_PSSR_MDIX);
+	phy->is_mdix = !!(data & IGP01E1000_PSSR_MDIX);
 
 	if ((data & IGP01E1000_PSSR_SPEED_MASK) ==
 	    IGP01E1000_PSSR_SPEED_1000MBPS) {
@@ -2052,8 +2052,7 @@ s32 e1000_get_phy_info_ife(struct e1000_hw *hw)
 	ret_val = e1e_rphy(hw, IFE_PHY_SPECIAL_CONTROL, &data);
 	if (ret_val)
 		return ret_val;
-	phy->polarity_correction = (data & IFE_PSC_AUTO_POLARITY_DISABLE)
-	                           ? false : true;
+	phy->polarity_correction = !(data & IFE_PSC_AUTO_POLARITY_DISABLE);
 
 	if (phy->polarity_correction) {
 		ret_val = e1000_check_polarity_ife(hw);
@@ -2070,7 +2069,7 @@ s32 e1000_get_phy_info_ife(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
-	phy->is_mdix = (data & IFE_PMC_MDIX_STATUS) ? true : false;
+	phy->is_mdix = !!(data & IFE_PMC_MDIX_STATUS);
 
 	/* The following parameters are undefined for 10/100 operation. */
 	phy->cable_length = E1000_CABLE_LENGTH_UNDEFINED;
@@ -2979,7 +2978,7 @@ static s32 __e1000_write_phy_reg_hv(struct e1000_hw *hw, u32 offset, u16 data,
 		if ((hw->phy.type == e1000_phy_82578) &&
 		    (hw->phy.revision >= 1) &&
 		    (hw->phy.addr == 2) &&
-		    ((MAX_PHY_REG_ADDRESS & reg) == 0) && (data & (1 << 11))) {
+		    !(MAX_PHY_REG_ADDRESS & reg) && (data & (1 << 11))) {
 			u16 data2 = 0x7EFF;
 			ret_val = e1000_access_phy_debug_regs_hv(hw,
 								 (1 << 6) | 0x3,
@@ -3265,7 +3264,7 @@ s32 e1000_get_phy_info_82577(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
-	phy->is_mdix = (data & I82577_PHY_STATUS2_MDIX) ? true : false;
+	phy->is_mdix = !!(data & I82577_PHY_STATUS2_MDIX);
 
 	if ((data & I82577_PHY_STATUS2_SPEED_MASK) ==
 	    I82577_PHY_STATUS2_SPEED_1000MBPS) {
-- 
1.7.7.6
