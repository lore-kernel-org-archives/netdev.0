From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 01/15] ixgbe: Prevent KR PHY reset in ixgbe_init_phy_ops_x550em
Date: Thu,  3 Dec 2015 03:07:09 -0800
Message-ID: <1449140843-118580-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449140843-118580-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:63144 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759866AbbLCLH0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 06:07:26 -0500
In-Reply-To: <1449140843-118580-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

This patch removes KR PHY reset from ixgbe_init_phy_ops_x550em,
since this function is meant to initialize function pointers for
the detected PHY type. Internal PHY reset was moved to
ixgbe_setup_internal_phy_t_x550em which will now detect which
mode the internal PHY operates in and set it up as required.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Darin Miller <darin.j.miller@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 21 ++++++++-------------
 1 file changed, 8 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index bf2ae8d..a9c73b7 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -1727,6 +1727,12 @@ static s32 ixgbe_setup_internal_phy_t_x550em(struct ixgbe_hw *hw)
 	if (hw->mac.ops.get_media_type(hw) != ixgbe_media_type_copper)
 		return IXGBE_ERR_CONFIG;
 
+	if (hw->phy.nw_mng_if_sel & IXGBE_NW_MNG_IF_SEL_INT_PHY_MODE) {
+		speed = IXGBE_LINK_SPEED_10GB_FULL |
+			IXGBE_LINK_SPEED_1GB_FULL;
+		return ixgbe_setup_kr_speed_x550em(hw, speed);
+	}
+
 	/* If link is not up, then there is no setup necessary so return  */
 	status = ixgbe_ext_phy_t_x550em_get_link(hw, &link_up);
 	if (status)
@@ -1931,7 +1937,6 @@ static s32 ixgbe_enter_lplu_t_x550em(struct ixgbe_hw *hw)
 static s32 ixgbe_init_phy_ops_X550em(struct ixgbe_hw *hw)
 {
 	struct ixgbe_phy_info *phy = &hw->phy;
-	ixgbe_link_speed speed;
 	s32 ret_val;
 
 	hw->mac.ops.set_lan_id(hw);
@@ -1944,10 +1949,6 @@ static s32 ixgbe_init_phy_ops_X550em(struct ixgbe_hw *hw)
 		 * to determine internal PHY mode.
 		 */
 		phy->nw_mng_if_sel = IXGBE_READ_REG(hw, IXGBE_NW_MNG_IF_SEL);
-		if (phy->nw_mng_if_sel & IXGBE_NW_MNG_IF_SEL_INT_PHY_MODE) {
-			speed = IXGBE_LINK_SPEED_10GB_FULL |
-				IXGBE_LINK_SPEED_1GB_FULL;
-		}
 	}
 
 	/* Identify the PHY or SFP module */
@@ -1979,14 +1980,8 @@ static s32 ixgbe_init_phy_ops_X550em(struct ixgbe_hw *hw)
 		/* If internal link mode is XFI, then setup iXFI internal link,
 		 * else setup KR now.
 		 */
-		if (!(phy->nw_mng_if_sel & IXGBE_NW_MNG_IF_SEL_INT_PHY_MODE)) {
-			phy->ops.setup_internal_link =
-					ixgbe_setup_internal_phy_t_x550em;
-		} else {
-			speed = IXGBE_LINK_SPEED_10GB_FULL |
-				IXGBE_LINK_SPEED_1GB_FULL;
-			ret_val = ixgbe_setup_kr_speed_x550em(hw, speed);
-		}
+		phy->ops.setup_internal_link =
+					      ixgbe_setup_internal_phy_t_x550em;
 
 		/* setup SW LPLU only for first revision */
 		if (!(IXGBE_FUSES0_REV1 & IXGBE_READ_REG(hw,
-- 
2.5.0
