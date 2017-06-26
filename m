From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/6] ixgbe: Disable flow control for XFI
Date: Mon, 26 Jun 2017 14:39:32 -0700
Message-ID: <20170626213933.9635-6-jeffrey.t.kirsher@intel.com>
References: <20170626213933.9635-1-jeffrey.t.kirsher@intel.com>
Cc: Tony Nguyen <anthony.l.nguyen@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Emil Tantilov <emil.s.tantilov@intel.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:39969 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751982AbdFZVjm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 26 Jun 2017 17:39:42 -0400
In-Reply-To: <20170626213933.9635-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tony Nguyen <anthony.l.nguyen@intel.com>

Flow control autonegotiation is not supported for XFI.  Make sure that
ixgbe_device_supports_autoneg_fc() returns false and
hw->fc.disable_fc_autoneg is set to true to avoid running the fc_autoneg
function for that device.

Signed-off-by: Tony Nguyen <anthony.l.nguyen@intel.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c |  5 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c   | 57 ++++++++++++++-----------
 2 files changed, 35 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index 40ae7db468ea..2c19070d2a0b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -97,7 +97,10 @@ bool ixgbe_device_supports_autoneg_fc(struct ixgbe_hw *hw)
 
 		break;
 	case ixgbe_media_type_backplane:
-		supported = true;
+		if (hw->device_id == IXGBE_DEV_ID_X550EM_X_XFI)
+			supported = false;
+		else
+			supported = true;
 		break;
 	case ixgbe_media_type_copper:
 		/* only some copper devices support flow control autoneg */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index 95adbda36235..19fbb2f28ea4 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -2843,7 +2843,7 @@ static s32 ixgbe_setup_fc_x550em(struct ixgbe_hw *hw)
 {
 	bool pause, asm_dir;
 	u32 reg_val;
-	s32 rc;
+	s32 rc = 0;
 
 	/* Validate the requested mode */
 	if (hw->fc.strict_ieee && hw->fc.requested_mode == ixgbe_fc_rx_pause) {
@@ -2886,32 +2886,37 @@ static s32 ixgbe_setup_fc_x550em(struct ixgbe_hw *hw)
 		return IXGBE_ERR_CONFIG;
 	}
 
-	if (hw->device_id != IXGBE_DEV_ID_X550EM_X_KR &&
-	    hw->device_id != IXGBE_DEV_ID_X550EM_A_KR &&
-	    hw->device_id != IXGBE_DEV_ID_X550EM_A_KR_L)
-		return 0;
-
-	rc = hw->mac.ops.read_iosf_sb_reg(hw,
-					  IXGBE_KRM_AN_CNTL_1(hw->bus.lan_id),
-					  IXGBE_SB_IOSF_TARGET_KR_PHY,
-					  &reg_val);
-	if (rc)
-		return rc;
-
-	reg_val &= ~(IXGBE_KRM_AN_CNTL_1_SYM_PAUSE |
-		     IXGBE_KRM_AN_CNTL_1_ASM_PAUSE);
-	if (pause)
-		reg_val |= IXGBE_KRM_AN_CNTL_1_SYM_PAUSE;
-	if (asm_dir)
-		reg_val |= IXGBE_KRM_AN_CNTL_1_ASM_PAUSE;
-	rc = hw->mac.ops.write_iosf_sb_reg(hw,
-					   IXGBE_KRM_AN_CNTL_1(hw->bus.lan_id),
-					   IXGBE_SB_IOSF_TARGET_KR_PHY,
-					   reg_val);
-
-	/* This device does not fully support AN. */
-	hw->fc.disable_fc_autoneg = true;
+	switch (hw->device_id) {
+	case IXGBE_DEV_ID_X550EM_X_KR:
+	case IXGBE_DEV_ID_X550EM_A_KR:
+	case IXGBE_DEV_ID_X550EM_A_KR_L:
+		rc = hw->mac.ops.read_iosf_sb_reg(hw,
+					    IXGBE_KRM_AN_CNTL_1(hw->bus.lan_id),
+					    IXGBE_SB_IOSF_TARGET_KR_PHY,
+					    &reg_val);
+		if (rc)
+			return rc;
 
+		reg_val &= ~(IXGBE_KRM_AN_CNTL_1_SYM_PAUSE |
+			     IXGBE_KRM_AN_CNTL_1_ASM_PAUSE);
+		if (pause)
+			reg_val |= IXGBE_KRM_AN_CNTL_1_SYM_PAUSE;
+		if (asm_dir)
+			reg_val |= IXGBE_KRM_AN_CNTL_1_ASM_PAUSE;
+		rc = hw->mac.ops.write_iosf_sb_reg(hw,
+					    IXGBE_KRM_AN_CNTL_1(hw->bus.lan_id),
+					    IXGBE_SB_IOSF_TARGET_KR_PHY,
+					    reg_val);
+
+		/* This device does not fully support AN. */
+		hw->fc.disable_fc_autoneg = true;
+		break;
+	case IXGBE_DEV_ID_X550EM_X_XFI:
+		hw->fc.disable_fc_autoneg = true;
+		break;
+	default:
+		break;
+	}
 	return rc;
 }
 
-- 
2.12.2
