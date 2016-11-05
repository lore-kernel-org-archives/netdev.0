From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/15] ixgbe: Add X552 iXFI configuration helper function
Date: Sat,  5 Nov 2016 00:54:07 -0700
Message-ID: <1478332461-43147-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1478332461-43147-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:56205 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752193AbcKEHyY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 5 Nov 2016 03:54:24 -0400
In-Reply-To: <1478332461-43147-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

X553 doesn't need all the initialization that X552 did for iXFI. This
patch will allow native SPI SFP+ to work with X553 devices.  Future
patches will add additional configuration as needed.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 86 ++++++++++++++++-----------
 1 file changed, 52 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index 7e6b926..3e3458e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -1128,47 +1128,17 @@ static s32 ixgbe_write_iosf_sb_reg_x550(struct ixgbe_hw *hw, u32 reg_addr,
 	return ret;
 }
 
-/** ixgbe_setup_ixfi_x550em - Configure the KR PHY for iXFI mode.
+/**
+ *  ixgbe_setup_ixfi_x550em_x - MAC specific iXFI configuration
  *  @hw: pointer to hardware structure
- *  @speed: the link speed to force
  *
- *  Configures the integrated KR PHY to use iXFI mode. Used to connect an
- *  internal and external PHY at a specific speed, without autonegotiation.
+ *  iXfI configuration needed for ixgbe_mac_X550EM_x devices.
  **/
-static s32 ixgbe_setup_ixfi_x550em(struct ixgbe_hw *hw, ixgbe_link_speed *speed)
+static s32 ixgbe_setup_ixfi_x550em_x(struct ixgbe_hw *hw)
 {
 	s32 status;
 	u32 reg_val;
 
-	/* Disable AN and force speed to 10G Serial. */
-	status = ixgbe_read_iosf_sb_reg_x550(hw,
-					IXGBE_KRM_LINK_CTRL_1(hw->bus.lan_id),
-					IXGBE_SB_IOSF_TARGET_KR_PHY, &reg_val);
-	if (status)
-		return status;
-
-	reg_val &= ~IXGBE_KRM_LINK_CTRL_1_TETH_AN_ENABLE;
-	reg_val &= ~IXGBE_KRM_LINK_CTRL_1_TETH_FORCE_SPEED_MASK;
-
-	/* Select forced link speed for internal PHY. */
-	switch (*speed) {
-	case IXGBE_LINK_SPEED_10GB_FULL:
-		reg_val |= IXGBE_KRM_LINK_CTRL_1_TETH_FORCE_SPEED_10G;
-		break;
-	case IXGBE_LINK_SPEED_1GB_FULL:
-		reg_val |= IXGBE_KRM_LINK_CTRL_1_TETH_FORCE_SPEED_1G;
-		break;
-	default:
-		/* Other link speeds are not supported by internal KR PHY. */
-		return IXGBE_ERR_LINK_SETUP;
-	}
-
-	status = ixgbe_write_iosf_sb_reg_x550(hw,
-				IXGBE_KRM_LINK_CTRL_1(hw->bus.lan_id),
-				IXGBE_SB_IOSF_TARGET_KR_PHY, reg_val);
-	if (status)
-		return status;
-
 	/* Disable training protocol FSM. */
 	status = ixgbe_read_iosf_sb_reg_x550(hw,
 				IXGBE_KRM_RX_TRN_LINKUP_CTRL(hw->bus.lan_id),
@@ -1228,9 +1198,57 @@ static s32 ixgbe_setup_ixfi_x550em(struct ixgbe_hw *hw, ixgbe_link_speed *speed)
 	status = ixgbe_write_iosf_sb_reg_x550(hw,
 				IXGBE_KRM_TX_COEFF_CTRL_1(hw->bus.lan_id),
 				IXGBE_SB_IOSF_TARGET_KR_PHY, reg_val);
+	return status;
+}
+
+/** ixgbe_setup_ixfi_x550em - Configure the KR PHY for iXFI mode.
+ *  @hw: pointer to hardware structure
+ *  @speed: the link speed to force
+ *
+ *  Configures the integrated KR PHY to use iXFI mode. Used to connect an
+ *  internal and external PHY at a specific speed, without autonegotiation.
+ **/
+static s32 ixgbe_setup_ixfi_x550em(struct ixgbe_hw *hw, ixgbe_link_speed *speed)
+{
+	s32 status;
+	u32 reg_val;
+
+	/* Disable AN and force speed to 10G Serial. */
+	status = ixgbe_read_iosf_sb_reg_x550(hw,
+					IXGBE_KRM_LINK_CTRL_1(hw->bus.lan_id),
+					IXGBE_SB_IOSF_TARGET_KR_PHY, &reg_val);
+	if (status)
+		return status;
+
+	reg_val &= ~IXGBE_KRM_LINK_CTRL_1_TETH_AN_ENABLE;
+	reg_val &= ~IXGBE_KRM_LINK_CTRL_1_TETH_FORCE_SPEED_MASK;
+
+	/* Select forced link speed for internal PHY. */
+	switch (*speed) {
+	case IXGBE_LINK_SPEED_10GB_FULL:
+		reg_val |= IXGBE_KRM_LINK_CTRL_1_TETH_FORCE_SPEED_10G;
+		break;
+	case IXGBE_LINK_SPEED_1GB_FULL:
+		reg_val |= IXGBE_KRM_LINK_CTRL_1_TETH_FORCE_SPEED_1G;
+		break;
+	default:
+		/* Other link speeds are not supported by internal KR PHY. */
+		return IXGBE_ERR_LINK_SETUP;
+	}
+
+	status = ixgbe_write_iosf_sb_reg_x550(hw,
+				IXGBE_KRM_LINK_CTRL_1(hw->bus.lan_id),
+				IXGBE_SB_IOSF_TARGET_KR_PHY, reg_val);
 	if (status)
 		return status;
 
+	/* Additional configuration needed for x550em_x */
+	if (hw->mac.type == ixgbe_mac_X550EM_x) {
+		status = ixgbe_setup_ixfi_x550em_x(hw);
+		if (status)
+			return status;
+	}
+
 	/* Toggle port SW reset by AN reset. */
 	status = ixgbe_read_iosf_sb_reg_x550(hw,
 				IXGBE_KRM_LINK_CTRL_1(hw->bus.lan_id),
-- 
2.7.4
