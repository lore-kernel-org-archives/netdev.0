From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/19] ixgbe: Avoid needless PHY access on copper phys
Date: Tue,  1 Sep 2015 18:13:58 -0700
Message-ID: <1441156443-33381-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1441156443-33381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:59488 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754614AbbIBBON (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2015 21:14:13 -0400
In-Reply-To: <1441156443-33381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Avoid a needless PHY access on copper phys to save the 10ms wait
time for each PHY access. A helper function is introduced to
actually do the register access and process the contents.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c  | 64 ++++++++++++++++++---------
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h |  1 +
 2 files changed, 44 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
index 97275dc..597d0b1 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
@@ -730,39 +730,61 @@ s32 ixgbe_setup_phy_link_speed_generic(struct ixgbe_hw *hw,
 }
 
 /**
- * ixgbe_get_copper_link_capabilities_generic - Determines link capabilities
+ * ixgbe_get_copper_speeds_supported - Get copper link speed from phy
  * @hw: pointer to hardware structure
- * @speed: pointer to link speed
- * @autoneg: boolean auto-negotiation value
  *
- * Determines the link capabilities by reading the AUTOC register.
+ * Determines the supported link capabilities by reading the PHY auto
+ * negotiation register.
  */
-s32 ixgbe_get_copper_link_capabilities_generic(struct ixgbe_hw *hw,
-					       ixgbe_link_speed *speed,
-					       bool *autoneg)
+static s32 ixgbe_get_copper_speeds_supported(struct ixgbe_hw *hw)
 {
-	s32 status;
 	u16 speed_ability;
-
-	*speed = 0;
-	*autoneg = true;
+	s32 status;
 
 	status = hw->phy.ops.read_reg(hw, MDIO_SPEED, MDIO_MMD_PMAPMD,
 				      &speed_ability);
+	if (status)
+		return status;
 
-	if (status == 0) {
-		if (speed_ability & MDIO_SPEED_10G)
-			*speed |= IXGBE_LINK_SPEED_10GB_FULL;
-		if (speed_ability & MDIO_PMA_SPEED_1000)
-			*speed |= IXGBE_LINK_SPEED_1GB_FULL;
-		if (speed_ability & MDIO_PMA_SPEED_100)
-			*speed |= IXGBE_LINK_SPEED_100_FULL;
+	if (speed_ability & MDIO_SPEED_10G)
+		hw->phy.speeds_supported |= IXGBE_LINK_SPEED_10GB_FULL;
+	if (speed_ability & MDIO_PMA_SPEED_1000)
+		hw->phy.speeds_supported |= IXGBE_LINK_SPEED_1GB_FULL;
+	if (speed_ability & MDIO_PMA_SPEED_100)
+		hw->phy.speeds_supported |= IXGBE_LINK_SPEED_100_FULL;
+
+	switch (hw->mac.type) {
+	case ixgbe_mac_X550:
+		hw->phy.speeds_supported |= IXGBE_LINK_SPEED_2_5GB_FULL;
+		hw->phy.speeds_supported |= IXGBE_LINK_SPEED_5GB_FULL;
+		break;
+	case ixgbe_mac_X550EM_x:
+		hw->phy.speeds_supported &= ~IXGBE_LINK_SPEED_100_FULL;
+		break;
+	default:
+		break;
 	}
 
-	/* Internal PHY does not support 100 Mbps */
-	if (hw->mac.type == ixgbe_mac_X550EM_x)
-		*speed &= ~IXGBE_LINK_SPEED_100_FULL;
+	return 0;
+}
+
+/**
+ * ixgbe_get_copper_link_capabilities_generic - Determines link capabilities
+ * @hw: pointer to hardware structure
+ * @speed: pointer to link speed
+ * @autoneg: boolean auto-negotiation value
+ */
+s32 ixgbe_get_copper_link_capabilities_generic(struct ixgbe_hw *hw,
+					       ixgbe_link_speed *speed,
+					       bool *autoneg)
+{
+	s32 status = 0;
+
+	*autoneg = true;
+	if (!hw->phy.speeds_supported)
+		status = ixgbe_get_copper_speeds_supported(hw);
 
+	*speed = hw->phy.speeds_supported;
 	return status;
 }
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index a3eec19..6368919 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -3384,6 +3384,7 @@ struct ixgbe_phy_info {
 	u32				phy_semaphore_mask;
 	bool                            reset_disable;
 	ixgbe_autoneg_advertised        autoneg_advertised;
+	ixgbe_link_speed		speeds_supported;
 	enum ixgbe_smart_speed          smart_speed;
 	bool                            smart_speed_active;
 	bool                            multispeed_fiber;
-- 
2.4.3
