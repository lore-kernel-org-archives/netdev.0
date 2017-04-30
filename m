From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/4] e1000e: Add Support for CannonLake
Date: Sun, 30 Apr 2017 05:36:13 -0700
Message-ID: <20170430123614.67897-4-jeffrey.t.kirsher@intel.com>
References: <20170430123614.67897-1-jeffrey.t.kirsher@intel.com>
Cc: Sasha Neftin <sasha.neftin@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:38083 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S936442AbdD3MgU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 30 Apr 2017 08:36:20 -0400
In-Reply-To: <20170430123614.67897-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sasha Neftin <sasha.neftin@intel.com>

The propagation of CannonLake mac type to driver functionality

Signed-off-by: Sasha Neftin <sasha.neftin@intel.com>
Reviewed-by: Raanan Avargil <raanan.avargil@intel.com>
Reviewed-by: Dima Ruinskiy <dima.ruinskiy@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ethtool.c | 10 ++--
 drivers/net/ethernet/intel/e1000e/ich8lan.c | 82 +++++++++++++++--------------
 drivers/net/ethernet/intel/e1000e/netdev.c  | 29 +++++-----
 drivers/net/ethernet/intel/e1000e/ptp.c     |  4 +-
 4 files changed, 63 insertions(+), 62 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index e70b1ebff60d..e23dbd9190d6 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -911,19 +911,20 @@ static int e1000_reg_test(struct e1000_adapter *adapter, u64 *data)
 	case e1000_pch2lan:
 	case e1000_pch_lpt:
 	case e1000_pch_spt:
+		/* fall through */
+	case e1000_pch_cnp:
 		mask |= BIT(18);
 		break;
 	default:
 		break;
 	}
 
-	if ((mac->type == e1000_pch_lpt) || (mac->type == e1000_pch_spt))
+	if (mac->type >= e1000_pch_lpt)
 		wlock_mac = (er32(FWSM) & E1000_FWSM_WLOCK_MAC_MASK) >>
 		    E1000_FWSM_WLOCK_MAC_SHIFT;
 
 	for (i = 0; i < mac->rar_entry_count; i++) {
-		if ((mac->type == e1000_pch_lpt) ||
-		    (mac->type == e1000_pch_spt)) {
+		if (mac->type >= e1000_pch_lpt) {
 			/* Cannot test write-protected SHRAL[n] registers */
 			if ((wlock_mac == 1) || (wlock_mac && (i > wlock_mac)))
 				continue;
@@ -1532,7 +1533,7 @@ static int e1000_setup_loopback_test(struct e1000_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 	u32 rctl, fext_nvm11, tarc0;
 
-	if (hw->mac.type == e1000_pch_spt) {
+	if (hw->mac.type >= e1000_pch_spt) {
 		fext_nvm11 = er32(FEXTNVM11);
 		fext_nvm11 |= E1000_FEXTNVM11_DISABLE_MULR_FIX;
 		ew32(FEXTNVM11, fext_nvm11);
@@ -1576,6 +1577,7 @@ static void e1000_loopback_cleanup(struct e1000_adapter *adapter)
 
 	switch (hw->mac.type) {
 	case e1000_pch_spt:
+	case e1000_pch_cnp:
 		fext_nvm11 = er32(FEXTNVM11);
 		fext_nvm11 &= ~E1000_FEXTNVM11_DISABLE_MULR_FIX;
 		ew32(FEXTNVM11, fext_nvm11);
diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index c0cd2874cba6..68ea8b4555ab 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -237,7 +237,7 @@ static bool e1000_phy_is_accessible_pchlan(struct e1000_hw *hw)
 	if (ret_val)
 		return false;
 out:
-	if ((hw->mac.type == e1000_pch_lpt) || (hw->mac.type == e1000_pch_spt)) {
+	if (hw->mac.type >= e1000_pch_lpt) {
 		/* Only unforce SMBus if ME is not active */
 		if (!(er32(FWSM) & E1000_ICH_FWSM_FW_VALID)) {
 			/* Unforce SMBus mode in PHY */
@@ -333,6 +333,7 @@ static s32 e1000_init_phy_workarounds_pchlan(struct e1000_hw *hw)
 	switch (hw->mac.type) {
 	case e1000_pch_lpt:
 	case e1000_pch_spt:
+	case e1000_pch_cnp:
 		if (e1000_phy_is_accessible_pchlan(hw))
 			break;
 
@@ -474,6 +475,7 @@ static s32 e1000_init_phy_params_pchlan(struct e1000_hw *hw)
 		case e1000_pch2lan:
 		case e1000_pch_lpt:
 		case e1000_pch_spt:
+		case e1000_pch_cnp:
 			/* In case the PHY needs to be in mdio slow mode,
 			 * set slow mode and try to get the PHY id again.
 			 */
@@ -607,7 +609,7 @@ static s32 e1000_init_nvm_params_ich8lan(struct e1000_hw *hw)
 
 	nvm->type = e1000_nvm_flash_sw;
 
-	if (hw->mac.type == e1000_pch_spt) {
+	if (hw->mac.type >= e1000_pch_spt) {
 		/* in SPT, gfpreg doesn't exist. NVM size is taken from the
 		 * STRAP register. This is because in SPT the GbE Flash region
 		 * is no longer accessed through the flash registers. Instead,
@@ -715,6 +717,7 @@ static s32 e1000_init_mac_params_ich8lan(struct e1000_hw *hw)
 		/* fall-through */
 	case e1000_pch_lpt:
 	case e1000_pch_spt:
+	case e1000_pch_cnp:
 	case e1000_pchlan:
 		/* check management mode */
 		mac->ops.check_mng_mode = e1000_check_mng_mode_pchlan;
@@ -732,7 +735,7 @@ static s32 e1000_init_mac_params_ich8lan(struct e1000_hw *hw)
 		break;
 	}
 
-	if ((mac->type == e1000_pch_lpt) || (mac->type == e1000_pch_spt)) {
+	if (mac->type >= e1000_pch_lpt) {
 		mac->rar_entry_count = E1000_PCH_LPT_RAR_ENTRIES;
 		mac->ops.rar_set = e1000_rar_set_pch_lpt;
 		mac->ops.setup_physical_interface =
@@ -1399,9 +1402,7 @@ static s32 e1000_check_for_copper_link_ich8lan(struct e1000_hw *hw)
 	 * aggressive resulting in many collisions. To avoid this, increase
 	 * the IPG and reduce Rx latency in the PHY.
 	 */
-	if (((hw->mac.type == e1000_pch2lan) ||
-	     (hw->mac.type == e1000_pch_lpt) ||
-	     (hw->mac.type == e1000_pch_spt)) && link) {
+	if ((hw->mac.type >= e1000_pch2lan) && link) {
 		u16 speed, duplex;
 
 		e1000e_get_speed_and_duplex_copper(hw, &speed, &duplex);
@@ -1412,7 +1413,7 @@ static s32 e1000_check_for_copper_link_ich8lan(struct e1000_hw *hw)
 			tipg_reg |= 0xFF;
 			/* Reduce Rx latency in analog PHY */
 			emi_val = 0;
-		} else if (hw->mac.type == e1000_pch_spt &&
+		} else if (hw->mac.type >= e1000_pch_spt &&
 			   duplex == FULL_DUPLEX && speed != SPEED_1000) {
 			tipg_reg |= 0xC;
 			emi_val = 1;
@@ -1435,8 +1436,7 @@ static s32 e1000_check_for_copper_link_ich8lan(struct e1000_hw *hw)
 			emi_addr = I217_RX_CONFIG;
 		ret_val = e1000_write_emi_reg_locked(hw, emi_addr, emi_val);
 
-		if (hw->mac.type == e1000_pch_lpt ||
-		    hw->mac.type == e1000_pch_spt) {
+		if (hw->mac.type >= e1000_pch_lpt) {
 			u16 phy_reg;
 
 			e1e_rphy_locked(hw, I217_PLL_CLOCK_GATE_REG, &phy_reg);
@@ -1452,7 +1452,7 @@ static s32 e1000_check_for_copper_link_ich8lan(struct e1000_hw *hw)
 		if (ret_val)
 			return ret_val;
 
-		if (hw->mac.type == e1000_pch_spt) {
+		if (hw->mac.type >= e1000_pch_spt) {
 			u16 data;
 			u16 ptr_gap;
 
@@ -1502,7 +1502,7 @@ static s32 e1000_check_for_copper_link_ich8lan(struct e1000_hw *hw)
 	 * on power up.
 	 * Set the Beacon Duration for I217 to 8 usec
 	 */
-	if ((hw->mac.type == e1000_pch_lpt) || (hw->mac.type == e1000_pch_spt)) {
+	if (hw->mac.type >= e1000_pch_lpt) {
 		u32 mac_reg;
 
 		mac_reg = er32(FEXTNVM4);
@@ -1520,8 +1520,7 @@ static s32 e1000_check_for_copper_link_ich8lan(struct e1000_hw *hw)
 		if (ret_val)
 			return ret_val;
 	}
-	if ((hw->mac.type == e1000_pch_lpt) ||
-	    (hw->mac.type == e1000_pch_spt)) {
+	if (hw->mac.type >= e1000_pch_lpt) {
 		/* Set platform power management values for
 		 * Latency Tolerance Reporting (LTR)
 		 */
@@ -1533,15 +1532,18 @@ static s32 e1000_check_for_copper_link_ich8lan(struct e1000_hw *hw)
 	/* Clear link partner's EEE ability */
 	hw->dev_spec.ich8lan.eee_lp_ability = 0;
 
-	/* FEXTNVM6 K1-off workaround */
-	if (hw->mac.type == e1000_pch_spt) {
-		u32 pcieanacfg = er32(PCIEANACFG);
+	if (hw->mac.type >= e1000_pch_lpt) {
 		u32 fextnvm6 = er32(FEXTNVM6);
 
-		if (pcieanacfg & E1000_FEXTNVM6_K1_OFF_ENABLE)
-			fextnvm6 |= E1000_FEXTNVM6_K1_OFF_ENABLE;
-		else
-			fextnvm6 &= ~E1000_FEXTNVM6_K1_OFF_ENABLE;
+		if (hw->mac.type == e1000_pch_spt) {
+			/* FEXTNVM6 K1-off workaround - for SPT only */
+			u32 pcieanacfg = er32(PCIEANACFG);
+
+			if (pcieanacfg & E1000_FEXTNVM6_K1_OFF_ENABLE)
+				fextnvm6 |= E1000_FEXTNVM6_K1_OFF_ENABLE;
+			else
+				fextnvm6 &= ~E1000_FEXTNVM6_K1_OFF_ENABLE;
+		}
 
 		ew32(FEXTNVM6, fextnvm6);
 	}
@@ -1640,6 +1642,7 @@ static s32 e1000_get_variants_ich8lan(struct e1000_adapter *adapter)
 	case e1000_pch2lan:
 	case e1000_pch_lpt:
 	case e1000_pch_spt:
+	case e1000_pch_cnp:
 		rc = e1000_init_phy_params_pchlan(hw);
 		break;
 	default:
@@ -2091,6 +2094,7 @@ static s32 e1000_sw_lcd_config_ich8lan(struct e1000_hw *hw)
 	case e1000_pch2lan:
 	case e1000_pch_lpt:
 	case e1000_pch_spt:
+	case e1000_pch_cnp:
 		sw_cfg_mask = E1000_FEXTNVM_SW_CONFIG_ICH8M;
 		break;
 	default:
@@ -3125,6 +3129,7 @@ static s32 e1000_valid_nvm_bank_detect_ich8lan(struct e1000_hw *hw, u32 *bank)
 
 	switch (hw->mac.type) {
 	case e1000_pch_spt:
+	case e1000_pch_cnp:
 		bank1_offset = nvm->flash_bank_size;
 		act_offset = E1000_ICH_NVM_SIG_WORD;
 
@@ -3380,7 +3385,7 @@ static s32 e1000_flash_cycle_init_ich8lan(struct e1000_hw *hw)
 	/* Clear FCERR and DAEL in hw status by writing 1 */
 	hsfsts.hsf_status.flcerr = 1;
 	hsfsts.hsf_status.dael = 1;
-	if (hw->mac.type == e1000_pch_spt)
+	if (hw->mac.type >= e1000_pch_spt)
 		ew32flash(ICH_FLASH_HSFSTS, hsfsts.regval & 0xFFFF);
 	else
 		ew16flash(ICH_FLASH_HSFSTS, hsfsts.regval);
@@ -3399,7 +3404,7 @@ static s32 e1000_flash_cycle_init_ich8lan(struct e1000_hw *hw)
 		 * Begin by setting Flash Cycle Done.
 		 */
 		hsfsts.hsf_status.flcdone = 1;
-		if (hw->mac.type == e1000_pch_spt)
+		if (hw->mac.type >= e1000_pch_spt)
 			ew32flash(ICH_FLASH_HSFSTS, hsfsts.regval & 0xFFFF);
 		else
 			ew16flash(ICH_FLASH_HSFSTS, hsfsts.regval);
@@ -3423,7 +3428,7 @@ static s32 e1000_flash_cycle_init_ich8lan(struct e1000_hw *hw)
 			 * now set the Flash Cycle Done.
 			 */
 			hsfsts.hsf_status.flcdone = 1;
-			if (hw->mac.type == e1000_pch_spt)
+			if (hw->mac.type >= e1000_pch_spt)
 				ew32flash(ICH_FLASH_HSFSTS,
 					  hsfsts.regval & 0xFFFF);
 			else
@@ -3450,13 +3455,13 @@ static s32 e1000_flash_cycle_ich8lan(struct e1000_hw *hw, u32 timeout)
 	u32 i = 0;
 
 	/* Start a cycle by writing 1 in Flash Cycle Go in Hw Flash Control */
-	if (hw->mac.type == e1000_pch_spt)
+	if (hw->mac.type >= e1000_pch_spt)
 		hsflctl.regval = er32flash(ICH_FLASH_HSFSTS) >> 16;
 	else
 		hsflctl.regval = er16flash(ICH_FLASH_HSFCTL);
 	hsflctl.hsf_ctrl.flcgo = 1;
 
-	if (hw->mac.type == e1000_pch_spt)
+	if (hw->mac.type >= e1000_pch_spt)
 		ew32flash(ICH_FLASH_HSFSTS, hsflctl.regval << 16);
 	else
 		ew16flash(ICH_FLASH_HSFCTL, hsflctl.regval);
@@ -3527,7 +3532,7 @@ static s32 e1000_read_flash_byte_ich8lan(struct e1000_hw *hw, u32 offset,
 	/* In SPT, only 32 bits access is supported,
 	 * so this function should not be called.
 	 */
-	if (hw->mac.type == e1000_pch_spt)
+	if (hw->mac.type >= e1000_pch_spt)
 		return -E1000_ERR_NVM;
 	else
 		ret_val = e1000_read_flash_data_ich8lan(hw, offset, 1, &word);
@@ -3634,8 +3639,7 @@ static s32 e1000_read_flash_data32_ich8lan(struct e1000_hw *hw, u32 offset,
 	s32 ret_val = -E1000_ERR_NVM;
 	u8 count = 0;
 
-	if (offset > ICH_FLASH_LINEAR_ADDR_MASK ||
-	    hw->mac.type != e1000_pch_spt)
+	if (offset > ICH_FLASH_LINEAR_ADDR_MASK || hw->mac.type < e1000_pch_spt)
 		return -E1000_ERR_NVM;
 	flash_linear_addr = ((ICH_FLASH_LINEAR_ADDR_MASK & offset) +
 			     hw->nvm.flash_base_addr);
@@ -4068,6 +4072,7 @@ static s32 e1000_validate_nvm_checksum_ich8lan(struct e1000_hw *hw)
 	switch (hw->mac.type) {
 	case e1000_pch_lpt:
 	case e1000_pch_spt:
+	case e1000_pch_cnp:
 		word = NVM_COMPAT;
 		valid_csum_mask = NVM_COMPAT_VALID_CSUM;
 		break;
@@ -4153,7 +4158,7 @@ static s32 e1000_write_flash_data_ich8lan(struct e1000_hw *hw, u32 offset,
 	s32 ret_val;
 	u8 count = 0;
 
-	if (hw->mac.type == e1000_pch_spt) {
+	if (hw->mac.type >= e1000_pch_spt) {
 		if (size != 4 || offset > ICH_FLASH_LINEAR_ADDR_MASK)
 			return -E1000_ERR_NVM;
 	} else {
@@ -4173,7 +4178,7 @@ static s32 e1000_write_flash_data_ich8lan(struct e1000_hw *hw, u32 offset,
 		/* In SPT, This register is in Lan memory space, not
 		 * flash.  Therefore, only 32 bit access is supported
 		 */
-		if (hw->mac.type == e1000_pch_spt)
+		if (hw->mac.type >= e1000_pch_spt)
 			hsflctl.regval = er32flash(ICH_FLASH_HSFSTS) >> 16;
 		else
 			hsflctl.regval = er16flash(ICH_FLASH_HSFCTL);
@@ -4185,7 +4190,7 @@ static s32 e1000_write_flash_data_ich8lan(struct e1000_hw *hw, u32 offset,
 		 * not flash.  Therefore, only 32 bit access is
 		 * supported
 		 */
-		if (hw->mac.type == e1000_pch_spt)
+		if (hw->mac.type >= e1000_pch_spt)
 			ew32flash(ICH_FLASH_HSFSTS, hsflctl.regval << 16);
 		else
 			ew16flash(ICH_FLASH_HSFCTL, hsflctl.regval);
@@ -4243,7 +4248,7 @@ static s32 e1000_write_flash_data32_ich8lan(struct e1000_hw *hw, u32 offset,
 	s32 ret_val;
 	u8 count = 0;
 
-	if (hw->mac.type == e1000_pch_spt) {
+	if (hw->mac.type >= e1000_pch_spt) {
 		if (offset > ICH_FLASH_LINEAR_ADDR_MASK)
 			return -E1000_ERR_NVM;
 	}
@@ -4259,7 +4264,7 @@ static s32 e1000_write_flash_data32_ich8lan(struct e1000_hw *hw, u32 offset,
 		/* In SPT, This register is in Lan memory space, not
 		 * flash.  Therefore, only 32 bit access is supported
 		 */
-		if (hw->mac.type == e1000_pch_spt)
+		if (hw->mac.type >= e1000_pch_spt)
 			hsflctl.regval = er32flash(ICH_FLASH_HSFSTS)
 			    >> 16;
 		else
@@ -4272,7 +4277,7 @@ static s32 e1000_write_flash_data32_ich8lan(struct e1000_hw *hw, u32 offset,
 		 * not flash.  Therefore, only 32 bit access is
 		 * supported
 		 */
-		if (hw->mac.type == e1000_pch_spt)
+		if (hw->mac.type >= e1000_pch_spt)
 			ew32flash(ICH_FLASH_HSFSTS, hsflctl.regval << 16);
 		else
 			ew16flash(ICH_FLASH_HSFCTL, hsflctl.regval);
@@ -4464,14 +4469,14 @@ static s32 e1000_erase_flash_bank_ich8lan(struct e1000_hw *hw, u32 bank)
 			/* Write a value 11 (block Erase) in Flash
 			 * Cycle field in hw flash control
 			 */
-			if (hw->mac.type == e1000_pch_spt)
+			if (hw->mac.type >= e1000_pch_spt)
 				hsflctl.regval =
 				    er32flash(ICH_FLASH_HSFSTS) >> 16;
 			else
 				hsflctl.regval = er16flash(ICH_FLASH_HSFCTL);
 
 			hsflctl.hsf_ctrl.flcycle = ICH_CYCLE_ERASE;
-			if (hw->mac.type == e1000_pch_spt)
+			if (hw->mac.type >= e1000_pch_spt)
 				ew32flash(ICH_FLASH_HSFSTS,
 					  hsflctl.regval << 16);
 			else
@@ -4894,8 +4899,7 @@ static void e1000_initialize_hw_bits_ich8lan(struct e1000_hw *hw)
 	ew32(RFCTL, reg);
 
 	/* Enable ECC on Lynxpoint */
-	if ((hw->mac.type == e1000_pch_lpt) ||
-	    (hw->mac.type == e1000_pch_spt)) {
+	if (hw->mac.type >= e1000_pch_lpt) {
 		reg = er32(PBECCSTS);
 		reg |= E1000_PBECCSTS_ECC_ENABLE;
 		ew32(PBECCSTS, reg);
@@ -5299,7 +5303,7 @@ void e1000_suspend_workarounds_ich8lan(struct e1000_hw *hw)
 		    (device_id == E1000_DEV_ID_PCH_LPTLP_I218_V) ||
 		    (device_id == E1000_DEV_ID_PCH_I218_LM3) ||
 		    (device_id == E1000_DEV_ID_PCH_I218_V3) ||
-		    (hw->mac.type == e1000_pch_spt)) {
+		    (hw->mac.type >= e1000_pch_spt)) {
 			u32 fextnvm6 = er32(FEXTNVM6);
 
 			ew32(FEXTNVM6, fextnvm6 & ~E1000_FEXTNVM6_REQ_PLL_CLK);
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 974fda2dd663..256a8a014583 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -1792,8 +1792,7 @@ static irqreturn_t e1000_intr_msi(int __always_unused irq, void *data)
 	}
 
 	/* Reset on uncorrectable ECC error */
-	if ((icr & E1000_ICR_ECCER) && ((hw->mac.type == e1000_pch_lpt) ||
-					(hw->mac.type == e1000_pch_spt))) {
+	if ((icr & E1000_ICR_ECCER) && (hw->mac.type >= e1000_pch_lpt)) {
 		u32 pbeccsts = er32(PBECCSTS);
 
 		adapter->corr_errors +=
@@ -1873,8 +1872,7 @@ static irqreturn_t e1000_intr(int __always_unused irq, void *data)
 	}
 
 	/* Reset on uncorrectable ECC error */
-	if ((icr & E1000_ICR_ECCER) && ((hw->mac.type == e1000_pch_lpt) ||
-					(hw->mac.type == e1000_pch_spt))) {
+	if ((icr & E1000_ICR_ECCER) && (hw->mac.type >= e1000_pch_lpt)) {
 		u32 pbeccsts = er32(PBECCSTS);
 
 		adapter->corr_errors +=
@@ -2242,8 +2240,7 @@ static void e1000_irq_enable(struct e1000_adapter *adapter)
 	if (adapter->msix_entries) {
 		ew32(EIAC_82574, adapter->eiac_mask & E1000_EIAC_MASK_82574);
 		ew32(IMS, adapter->eiac_mask | E1000_IMS_LSC);
-	} else if ((hw->mac.type == e1000_pch_lpt) ||
-		   (hw->mac.type == e1000_pch_spt)) {
+	} else if (hw->mac.type >= e1000_pch_lpt) {
 		ew32(IMS, IMS_ENABLE_MASK | E1000_IMS_ECCER);
 	} else {
 		ew32(IMS, IMS_ENABLE_MASK);
@@ -3001,8 +2998,8 @@ static void e1000_configure_tx(struct e1000_adapter *adapter)
 
 	hw->mac.ops.config_collision_dist(hw);
 
-	/* SPT Si errata workaround to avoid data corruption */
-	if (hw->mac.type == e1000_pch_spt) {
+	/* SPT and CNP Si errata workaround to avoid data corruption */
+	if (hw->mac.type >= e1000_pch_spt) {
 		u32 reg_val;
 
 		reg_val = er32(IOSFPC);
@@ -3498,8 +3495,7 @@ s32 e1000e_get_base_timinca(struct e1000_adapter *adapter, u32 *timinca)
 	/* Make sure clock is enabled on I217/I218/I219  before checking
 	 * the frequency
 	 */
-	if (((hw->mac.type == e1000_pch_lpt) ||
-	     (hw->mac.type == e1000_pch_spt)) &&
+	if ((hw->mac.type >= e1000_pch_lpt) &&
 	    !(er32(TSYNCTXCTL) & E1000_TSYNCTXCTL_ENABLED) &&
 	    !(er32(TSYNCRXCTL) & E1000_TSYNCRXCTL_ENABLED)) {
 		u32 fextnvm7 = er32(FEXTNVM7);
@@ -4039,6 +4035,7 @@ void e1000e_reset(struct e1000_adapter *adapter)
 	case e1000_pch2lan:
 	case e1000_pch_lpt:
 	case e1000_pch_spt:
+	case e1000_pch_cnp:
 		fc->refresh_time = 0x0400;
 
 		if (adapter->netdev->mtu <= ETH_DATA_LEN) {
@@ -4083,7 +4080,7 @@ void e1000e_reset(struct e1000_adapter *adapter)
 		}
 	}
 
-	if (hw->mac.type == e1000_pch_spt)
+	if (hw->mac.type >= e1000_pch_spt)
 		e1000_flush_desc_rings(adapter);
 	/* Allow time for pending master requests to run */
 	mac->ops.reset_hw(hw);
@@ -4158,7 +4155,7 @@ void e1000e_reset(struct e1000_adapter *adapter)
 		phy_data &= ~IGP02E1000_PM_SPD;
 		e1e_wphy(hw, IGP02E1000_PHY_POWER_MGMT, phy_data);
 	}
-	if (hw->mac.type == e1000_pch_spt && adapter->int_mode == 0) {
+	if (hw->mac.type >= e1000_pch_spt && adapter->int_mode == 0) {
 		u32 reg;
 
 		/* Fextnvm7 @ 0xe4[2] = 1 */
@@ -4292,7 +4289,7 @@ void e1000e_down(struct e1000_adapter *adapter, bool reset)
 	if (!pci_channel_offline(adapter->pdev)) {
 		if (reset)
 			e1000e_reset(adapter);
-		else if (hw->mac.type == e1000_pch_spt)
+		else if (hw->mac.type >= e1000_pch_spt)
 			e1000_flush_desc_rings(adapter);
 	}
 	e1000_clean_tx_ring(adapter->tx_ring);
@@ -4980,8 +4977,7 @@ static void e1000e_update_stats(struct e1000_adapter *adapter)
 	adapter->stats.mgpdc += er32(MGTPDC);
 
 	/* Correctable ECC Errors */
-	if ((hw->mac.type == e1000_pch_lpt) ||
-	    (hw->mac.type == e1000_pch_spt)) {
+	if (hw->mac.type >= e1000_pch_lpt) {
 		u32 pbeccsts = er32(PBECCSTS);
 
 		adapter->corr_errors +=
@@ -6355,8 +6351,7 @@ static int __e1000_shutdown(struct pci_dev *pdev, bool runtime)
 
 	if (adapter->hw.phy.type == e1000_phy_igp_3) {
 		e1000e_igp3_phy_powerdown_workaround_ich8lan(&adapter->hw);
-	} else if ((hw->mac.type == e1000_pch_lpt) ||
-		   (hw->mac.type == e1000_pch_spt)) {
+	} else if (hw->mac.type >= e1000_pch_lpt) {
 		if (!(wufc & (E1000_WUFC_EX | E1000_WUFC_MC | E1000_WUFC_BC)))
 			/* ULP does not support wake from unicast, multicast
 			 * or broadcast.
diff --git a/drivers/net/ethernet/intel/e1000e/ptp.c b/drivers/net/ethernet/intel/e1000e/ptp.c
index 34cc3be0df8e..b366885487a8 100644
--- a/drivers/net/ethernet/intel/e1000e/ptp.c
+++ b/drivers/net/ethernet/intel/e1000e/ptp.c
@@ -301,8 +301,8 @@ void e1000e_ptp_init(struct e1000_adapter *adapter)
 	case e1000_pch2lan:
 	case e1000_pch_lpt:
 	case e1000_pch_spt:
-		if (((hw->mac.type != e1000_pch_lpt) &&
-		     (hw->mac.type != e1000_pch_spt)) ||
+	case e1000_pch_cnp:
+		if ((hw->mac.type < e1000_pch_lpt) ||
 		    (er32(TSYNCRXCTL) & E1000_TSYNCRXCTL_SYSCFI)) {
 			adapter->ptp_clock_info.max_adj = 24000000 - 1;
 			break;
-- 
2.12.2
