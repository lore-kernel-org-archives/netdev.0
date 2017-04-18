From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/15] ixgbe: Remove driver config for KX4 PHY
Date: Tue, 18 Apr 2017 16:01:53 -0700
Message-ID: <20170418230205.37223-4-jeffrey.t.kirsher@intel.com>
References: <20170418230205.37223-1-jeffrey.t.kirsher@intel.com>
Cc: Tony Nguyen <anthony.l.nguyen@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:61886 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752280AbdDRXCL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Apr 2017 19:02:11 -0400
In-Reply-To: <20170418230205.37223-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tony Nguyen <anthony.l.nguyen@intel.com>

The KX4 PHY is configured by the NVM.  Currently, the driver is overwriting
the config; remove the code associated with KX4 configuration.

Signed-off-by: Tony Nguyen <anthony.l.nguyen@intel.com>
Tested-by: Krishneil Singh  <krishneil.k.singh@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c  |  3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h | 12 --------
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 40 +--------------------------
 3 files changed, 3 insertions(+), 52 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
index e55b2602f371..654a402f0e9e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
@@ -792,7 +792,8 @@ s32 ixgbe_setup_phy_link_speed_generic(struct ixgbe_hw *hw,
 		hw->phy.autoneg_advertised |= IXGBE_LINK_SPEED_10_FULL;
 
 	/* Setup link based on the new speed settings */
-	hw->phy.ops.setup_link(hw);
+	if (hw->phy.ops.setup_link)
+		hw->phy.ops.setup_link(hw);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 1d07f2ead914..c0f6b9503439 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -3754,15 +3754,6 @@ struct ixgbe_info {
 #define IXGBE_KRM_TX_COEFF_CTRL_1_CZERO_EN		BIT(3)
 #define IXGBE_KRM_TX_COEFF_CTRL_1_OVRRD_EN		BIT(31)
 
-#define IXGBE_KX4_LINK_CNTL_1				0x4C
-#define IXGBE_KX4_LINK_CNTL_1_TETH_AN_CAP_KX		BIT(16)
-#define IXGBE_KX4_LINK_CNTL_1_TETH_AN_CAP_KX4		BIT(17)
-#define IXGBE_KX4_LINK_CNTL_1_TETH_EEE_CAP_KX		BIT(24)
-#define IXGBE_KX4_LINK_CNTL_1_TETH_EEE_CAP_KX4		BIT(25)
-#define IXGBE_KX4_LINK_CNTL_1_TETH_AN_ENABLE		BIT(29)
-#define IXGBE_KX4_LINK_CNTL_1_TETH_FORCE_LINK_UP	BIT(30)
-#define IXGBE_KX4_LINK_CNTL_1_TETH_AN_RESTART		BIT(31)
-
 #define IXGBE_SB_IOSF_INDIRECT_CTRL		0x00011144
 #define IXGBE_SB_IOSF_INDIRECT_DATA		0x00011148
 
@@ -3779,9 +3770,6 @@ struct ixgbe_info {
 #define IXGBE_SB_IOSF_CTRL_BUSY_SHIFT		31
 #define IXGBE_SB_IOSF_CTRL_BUSY		BIT(IXGBE_SB_IOSF_CTRL_BUSY_SHIFT)
 #define IXGBE_SB_IOSF_TARGET_KR_PHY	0
-#define IXGBE_SB_IOSF_TARGET_KX4_UNIPHY	1
-#define IXGBE_SB_IOSF_TARGET_KX4_PCS0	2
-#define IXGBE_SB_IOSF_TARGET_KX4_PCS1	3
 
 #define IXGBE_NW_MNG_IF_SEL		0x00011178
 #define IXGBE_NW_MNG_IF_SEL_MDIO_ACT		BIT(1)
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index 200f847fd8f3..0a2eacff7327 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -2473,44 +2473,6 @@ static s32 ixgbe_setup_kr_speed_x550em(struct ixgbe_hw *hw,
 	return ixgbe_restart_an_internal_phy_x550em(hw);
 }
 
-/** ixgbe_setup_kx4_x550em - Configure the KX4 PHY.
- *  @hw: pointer to hardware structure
- *
- *   Configures the integrated KX4 PHY.
- **/
-static s32 ixgbe_setup_kx4_x550em(struct ixgbe_hw *hw)
-{
-	s32 status;
-	u32 reg_val;
-
-	status = hw->mac.ops.read_iosf_sb_reg(hw, IXGBE_KX4_LINK_CNTL_1,
-					      IXGBE_SB_IOSF_TARGET_KX4_PCS0 +
-					      hw->bus.lan_id, &reg_val);
-	if (status)
-		return status;
-
-	reg_val &= ~(IXGBE_KX4_LINK_CNTL_1_TETH_AN_CAP_KX4 |
-		     IXGBE_KX4_LINK_CNTL_1_TETH_AN_CAP_KX);
-
-	reg_val |= IXGBE_KX4_LINK_CNTL_1_TETH_AN_ENABLE;
-
-	/* Advertise 10G support. */
-	if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_10GB_FULL)
-		reg_val |= IXGBE_KX4_LINK_CNTL_1_TETH_AN_CAP_KX4;
-
-	/* Advertise 1G support. */
-	if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_1GB_FULL)
-		reg_val |= IXGBE_KX4_LINK_CNTL_1_TETH_AN_CAP_KX;
-
-	/* Restart auto-negotiation. */
-	reg_val |= IXGBE_KX4_LINK_CNTL_1_TETH_AN_RESTART;
-	status = hw->mac.ops.write_iosf_sb_reg(hw, IXGBE_KX4_LINK_CNTL_1,
-					       IXGBE_SB_IOSF_TARGET_KX4_PCS0 +
-					       hw->bus.lan_id, reg_val);
-
-	return status;
-}
-
 /**
  * ixgbe_setup_kr_x550em - Configure the KR PHY
  * @hw: pointer to hardware structure
@@ -3134,7 +3096,7 @@ static s32 ixgbe_init_phy_ops_X550em(struct ixgbe_hw *hw)
 	/* Set functions pointers based on phy type */
 	switch (hw->phy.type) {
 	case ixgbe_phy_x550em_kx4:
-		phy->ops.setup_link = ixgbe_setup_kx4_x550em;
+		phy->ops.setup_link = NULL;
 		phy->ops.read_reg = ixgbe_read_phy_reg_x550em;
 		phy->ops.write_reg = ixgbe_write_phy_reg_x550em;
 		break;
-- 
2.12.2
