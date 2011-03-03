From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 08/24] ixgbe: set media type for 82599 T3 LOM
Date: Thu,  3 Mar 2011 05:03:33 -0800
Message-ID: <1299157429-15878-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299157429-15878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:24647 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758195Ab1CCNEV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2011 08:04:21 -0500
In-Reply-To: <1299157429-15878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

The media type was not being set for the 82599 T3 LAN on motherboard.  This
change corrects that.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_82599.c |   50 +++++++++++++++++++++++++++++++-------
 drivers/net/ixgbe/ixgbe_main.c  |    2 +-
 drivers/net/ixgbe/ixgbe_type.h  |    1 +
 3 files changed, 42 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index a21f581..b45a491 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -329,11 +329,14 @@ static enum ixgbe_media_type ixgbe_get_media_type_82599(struct ixgbe_hw *hw)
 	enum ixgbe_media_type media_type;
 
 	/* Detect if there is a copper PHY attached. */
-	if (hw->phy.type == ixgbe_phy_cu_unknown ||
-	    hw->phy.type == ixgbe_phy_tn ||
-	    hw->phy.type == ixgbe_phy_aq) {
+	switch (hw->phy.type) {
+	case ixgbe_phy_cu_unknown:
+	case ixgbe_phy_tn:
+	case ixgbe_phy_aq:
 		media_type = ixgbe_media_type_copper;
 		goto out;
+	default:
+		break;
 	}
 
 	switch (hw->device_id) {
@@ -354,6 +357,9 @@ static enum ixgbe_media_type ixgbe_get_media_type_82599(struct ixgbe_hw *hw)
 	case IXGBE_DEV_ID_82599_CX4:
 		media_type = ixgbe_media_type_cx4;
 		break;
+	case IXGBE_DEV_ID_82599_T3_LOM:
+		media_type = ixgbe_media_type_copper;
+		break;
 	default:
 		media_type = ixgbe_media_type_unknown;
 		break;
@@ -1733,13 +1739,34 @@ static s32 ixgbe_start_hw_82599(struct ixgbe_hw *hw)
  *  @hw: pointer to hardware structure
  *
  *  Determines the physical layer module found on the current adapter.
+ *  If PHY already detected, maintains current PHY type in hw struct,
+ *  otherwise executes the PHY detection routine.
  **/
-static s32 ixgbe_identify_phy_82599(struct ixgbe_hw *hw)
+s32 ixgbe_identify_phy_82599(struct ixgbe_hw *hw)
 {
 	s32 status = IXGBE_ERR_PHY_ADDR_INVALID;
+
+	/* Detect PHY if not unknown - returns success if already detected. */
 	status = ixgbe_identify_phy_generic(hw);
-	if (status != 0)
-		status = ixgbe_identify_sfp_module_generic(hw);
+	if (status != 0) {
+		/* 82599 10GBASE-T requires an external PHY */
+		if (hw->mac.ops.get_media_type(hw) == ixgbe_media_type_copper)
+			goto out;
+		else
+			status = ixgbe_identify_sfp_module_generic(hw);
+	}
+
+	/* Set PHY type none if no PHY detected */
+	if (hw->phy.type == ixgbe_phy_unknown) {
+		hw->phy.type = ixgbe_phy_none;
+		status = 0;
+	}
+
+	/* Return error if SFP module has been detected but is not supported */
+	if (hw->phy.type == ixgbe_phy_sfp_unsupported)
+		status = IXGBE_ERR_SFP_NOT_SUPPORTED;
+
+out:
 	return status;
 }
 
@@ -1763,11 +1790,12 @@ static u32 ixgbe_get_supported_physical_layer_82599(struct ixgbe_hw *hw)
 
 	hw->phy.ops.identify(hw);
 
-	if (hw->phy.type == ixgbe_phy_tn ||
-	    hw->phy.type == ixgbe_phy_aq ||
-	    hw->phy.type == ixgbe_phy_cu_unknown) {
+	switch (hw->phy.type) {
+	case ixgbe_phy_tn:
+	case ixgbe_phy_aq:
+	case ixgbe_phy_cu_unknown:
 		hw->phy.ops.read_reg(hw, MDIO_PMA_EXTABLE, MDIO_MMD_PMAPMD,
-				     &ext_ability);
+							 &ext_ability);
 		if (ext_ability & MDIO_PMA_EXTABLE_10GBT)
 			physical_layer |= IXGBE_PHYSICAL_LAYER_10GBASE_T;
 		if (ext_ability & MDIO_PMA_EXTABLE_1000BT)
@@ -1775,6 +1803,8 @@ static u32 ixgbe_get_supported_physical_layer_82599(struct ixgbe_hw *hw)
 		if (ext_ability & MDIO_PMA_EXTABLE_100BTX)
 			physical_layer |= IXGBE_PHYSICAL_LAYER_100BASE_TX;
 		goto out;
+	default:
+		break;
 	}
 
 	switch (autoc & IXGBE_AUTOC_LMS_MASK) {
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 588661b..9877719 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3889,7 +3889,7 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 	 * If we're not hot-pluggable SFP+, we just need to configure link
 	 * and bring it up.
 	 */
-	if (hw->phy.type == ixgbe_phy_unknown)
+	if (hw->phy.type == ixgbe_phy_none)
 		schedule_work(&adapter->sfp_config_module_task);
 
 	/* enable transmits */
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 18780d0..af5ad40 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -2242,6 +2242,7 @@ enum ixgbe_mac_type {
 
 enum ixgbe_phy_type {
 	ixgbe_phy_unknown = 0,
+	ixgbe_phy_none,
 	ixgbe_phy_tn,
 	ixgbe_phy_aq,
 	ixgbe_phy_cu_unknown,
-- 
1.7.4

