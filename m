From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/18] ixgbe: Use method pointer to access IOSF devices
Date: Thu,  7 Apr 2016 20:21:04 -0700
Message-ID: <1460085673-87056-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1460085673-87056-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:9519 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756954AbcDHDVU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2016 23:21:20 -0400
In-Reply-To: <1460085673-87056-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Provide method pointers and use them to access IOSF-attached
devices. A new MAC will introduce a new access method.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h |  2 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 32 +++++++++++++++------------
 2 files changed, 20 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index b505da3..fef2264 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -3332,6 +3332,8 @@ struct ixgbe_mac_operations {
 	s32 (*dmac_config)(struct ixgbe_hw *hw);
 	s32 (*dmac_update_tcs)(struct ixgbe_hw *hw);
 	s32 (*dmac_config_tcs)(struct ixgbe_hw *hw);
+	s32 (*read_iosf_sb_reg)(struct ixgbe_hw *, u32, u32, u32 *);
+	s32 (*write_iosf_sb_reg)(struct ixgbe_hw *, u32, u32, u32);
 };
 
 struct ixgbe_phy_operations {
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index 65832fa..878ea1e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -1615,7 +1615,7 @@ static s32 ixgbe_setup_kr_speed_x550em(struct ixgbe_hw *hw,
 	s32 status;
 	u32 reg_val;
 
-	status = ixgbe_read_iosf_sb_reg_x550(hw,
+	status = hw->mac.ops.read_iosf_sb_reg(hw,
 					IXGBE_KRM_LINK_CTRL_1(hw->bus.lan_id),
 					IXGBE_SB_IOSF_TARGET_KR_PHY, &reg_val);
 	if (status)
@@ -1637,7 +1637,7 @@ static s32 ixgbe_setup_kr_speed_x550em(struct ixgbe_hw *hw,
 
 	/* Restart auto-negotiation. */
 	reg_val |= IXGBE_KRM_LINK_CTRL_1_TETH_AN_RESTART;
-	status = ixgbe_write_iosf_sb_reg_x550(hw,
+	status = hw->mac.ops.write_iosf_sb_reg(hw,
 					IXGBE_KRM_LINK_CTRL_1(hw->bus.lan_id),
 					IXGBE_SB_IOSF_TARGET_KR_PHY, reg_val);
 
@@ -1654,9 +1654,9 @@ static s32 ixgbe_setup_kx4_x550em(struct ixgbe_hw *hw)
 	s32 status;
 	u32 reg_val;
 
-	status = ixgbe_read_iosf_sb_reg_x550(hw, IXGBE_KX4_LINK_CNTL_1,
-					     IXGBE_SB_IOSF_TARGET_KX4_PCS0 +
-					     hw->bus.lan_id, &reg_val);
+	status = hw->mac.ops.read_iosf_sb_reg(hw, IXGBE_KX4_LINK_CNTL_1,
+					      IXGBE_SB_IOSF_TARGET_KX4_PCS0 +
+					      hw->bus.lan_id, &reg_val);
 	if (status)
 		return status;
 
@@ -1675,9 +1675,9 @@ static s32 ixgbe_setup_kx4_x550em(struct ixgbe_hw *hw)
 
 	/* Restart auto-negotiation. */
 	reg_val |= IXGBE_KX4_LINK_CNTL_1_TETH_AN_RESTART;
-	status = ixgbe_write_iosf_sb_reg_x550(hw, IXGBE_KX4_LINK_CNTL_1,
-					      IXGBE_SB_IOSF_TARGET_KX4_PCS0 +
-					      hw->bus.lan_id, reg_val);
+	status = hw->mac.ops.write_iosf_sb_reg(hw, IXGBE_KX4_LINK_CNTL_1,
+					       IXGBE_SB_IOSF_TARGET_KX4_PCS0 +
+					       hw->bus.lan_id, reg_val);
 
 	return status;
 }
@@ -1897,9 +1897,10 @@ static s32 ixgbe_setup_fc_x550em(struct ixgbe_hw *hw)
 	if (hw->device_id != IXGBE_DEV_ID_X550EM_X_KR)
 		return 0;
 
-	rc = ixgbe_read_iosf_sb_reg_x550(hw,
-					 IXGBE_KRM_AN_CNTL_1(hw->bus.lan_id),
-					 IXGBE_SB_IOSF_TARGET_KR_PHY, &reg_val);
+	rc = hw->mac.ops.read_iosf_sb_reg(hw,
+					  IXGBE_KRM_AN_CNTL_1(hw->bus.lan_id),
+					  IXGBE_SB_IOSF_TARGET_KR_PHY,
+					  &reg_val);
 	if (rc)
 		return rc;
 
@@ -1909,9 +1910,10 @@ static s32 ixgbe_setup_fc_x550em(struct ixgbe_hw *hw)
 		reg_val |= IXGBE_KRM_AN_CNTL_1_SYM_PAUSE;
 	if (asm_dir)
 		reg_val |= IXGBE_KRM_AN_CNTL_1_ASM_PAUSE;
-	rc = ixgbe_write_iosf_sb_reg_x550(hw,
-					  IXGBE_KRM_AN_CNTL_1(hw->bus.lan_id),
-					  IXGBE_SB_IOSF_TARGET_KR_PHY, reg_val);
+	rc = hw->mac.ops.write_iosf_sb_reg(hw,
+					   IXGBE_KRM_AN_CNTL_1(hw->bus.lan_id),
+					   IXGBE_SB_IOSF_TARGET_KR_PHY,
+					   reg_val);
 
 	/* This device does not fully support AN. */
 	hw->fc.disable_fc_autoneg = true;
@@ -2449,6 +2451,8 @@ static const struct ixgbe_mac_operations mac_ops_X550EM_x = {
 	.release_swfw_sync	= &ixgbe_release_swfw_sync_X550em,
 	.init_swfw_sync		= &ixgbe_init_swfw_sync_X540,
 	.setup_fc		= NULL, /* defined later */
+	.read_iosf_sb_reg	= ixgbe_read_iosf_sb_reg_x550,
+	.write_iosf_sb_reg	= ixgbe_write_iosf_sb_reg_x550,
 };
 
 #define X550_COMMON_EEP \
-- 
2.5.5
