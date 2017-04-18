From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/15] ixgbe: Complete support for X553 sgmii
Date: Tue, 18 Apr 2017 16:01:54 -0700
Message-ID: <20170418230205.37223-5-jeffrey.t.kirsher@intel.com>
References: <20170418230205.37223-1-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:58032 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755228AbdDRXCM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Apr 2017 19:02:12 -0400
In-Reply-To: <20170418230205.37223-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

The initial patches supporting X553 sgmii forgot some details.  This patch
should cover those missing spots.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 29 +++++++++++++++++++++++++--
 1 file changed, 27 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index 0a2eacff7327..633079eaf8fb 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -334,6 +334,16 @@ static s32 ixgbe_identify_phy_x550em(struct ixgbe_hw *hw)
 	case IXGBE_DEV_ID_X550EM_X_1G_T:
 	case IXGBE_DEV_ID_X550EM_X_10G_T:
 		return ixgbe_identify_phy_generic(hw);
+	case IXGBE_DEV_ID_X550EM_A_1G_T:
+	case IXGBE_DEV_ID_X550EM_A_1G_T_L:
+		hw->phy.type = ixgbe_phy_fw;
+		hw->phy.ops.read_reg = NULL;
+		hw->phy.ops.write_reg = NULL;
+		if (hw->bus.lan_id)
+			hw->phy.phy_semaphore_mask |= IXGBE_GSSR_PHY1_SM;
+		else
+			hw->phy.phy_semaphore_mask |= IXGBE_GSSR_PHY0_SM;
+		break;
 	default:
 		break;
 	}
@@ -2215,8 +2225,20 @@ static s32 ixgbe_get_link_capabilities_X550em(struct ixgbe_hw *hw,
 		else
 			*speed = IXGBE_LINK_SPEED_10GB_FULL;
 	} else {
-		*speed = IXGBE_LINK_SPEED_10GB_FULL |
-			 IXGBE_LINK_SPEED_1GB_FULL;
+		switch (hw->phy.type) {
+		case ixgbe_phy_x550em_kx4:
+			*speed = IXGBE_LINK_SPEED_1GB_FULL |
+				 IXGBE_LINK_SPEED_2_5GB_FULL |
+				 IXGBE_LINK_SPEED_10GB_FULL;
+			break;
+		case ixgbe_phy_sgmii:
+			*speed = IXGBE_LINK_SPEED_1GB_FULL;
+			break;
+		default:
+			*speed = IXGBE_LINK_SPEED_10GB_FULL |
+				 IXGBE_LINK_SPEED_1GB_FULL;
+			break;
+		}
 		*autoneg = true;
 	}
 	return 0;
@@ -3126,6 +3148,9 @@ static s32 ixgbe_init_phy_ops_X550em(struct ixgbe_hw *hw)
 		phy->ops.handle_lasi = ixgbe_handle_lasi_ext_t_x550em;
 		phy->ops.reset = ixgbe_reset_phy_t_X550em;
 		break;
+	case ixgbe_phy_sgmii:
+		phy->ops.setup_link = NULL;
+		break;
 	case ixgbe_phy_fw:
 		phy->ops.setup_link = ixgbe_setup_fw_link;
 		phy->ops.reset = ixgbe_reset_phy_fw;
-- 
2.12.2
