From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/18] ixgbe: add link check for X550 copper
Date: Tue,  9 Jun 2015 18:10:26 -0700
Message-ID: <1433898629-76729-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1433898629-76729-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:59836 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933185AbbFJBKx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jun 2015 21:10:53 -0400
In-Reply-To: <1433898629-76729-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

This patch adds ixgbe_check_link_t_X550em for checking copper PHY
link.  We check that both the MAC and external PHY have link. This
is to avoid a false link up between the internal and external PHY
when  the external PHY doesn't have link.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 43 +++++++++++++++++++++++++++
 1 file changed, 43 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index 886bef5..dc320af 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -914,6 +914,48 @@ static s32 ixgbe_setup_mac_link_t_X550em(struct ixgbe_hw *hw,
 	return hw->phy.ops.setup_link_speed(hw, speed, autoneg_wait);
 }
 
+/** ixgbe_check_link_t_X550em - Determine link and speed status
+  * @hw: pointer to hardware structure
+  * @speed: pointer to link speed
+  * @link_up: true when link is up
+  * @link_up_wait_to_complete: bool used to wait for link up or not
+  *
+  * Check that both the MAC and X557 external PHY have link.
+  **/
+static s32 ixgbe_check_link_t_X550em(struct ixgbe_hw *hw,
+				     ixgbe_link_speed *speed,
+				     bool *link_up,
+				     bool link_up_wait_to_complete)
+{
+	u32 status;
+	u16 autoneg_status;
+
+	if (hw->mac.ops.get_media_type(hw) != ixgbe_media_type_copper)
+		return IXGBE_ERR_CONFIG;
+
+	status = ixgbe_check_mac_link_generic(hw, speed, link_up,
+					      link_up_wait_to_complete);
+
+	/* If check link fails or MAC link is not up, then return */
+	if (status || !(*link_up))
+		return status;
+
+	 /* MAC link is up, so check external PHY link.
+	  * Read this twice back to back to indicate current status.
+	  */
+	status = hw->phy.ops.read_reg(hw, IXGBE_MDIO_AUTO_NEG_STATUS,
+				      IXGBE_MDIO_AUTO_NEG_DEV_TYPE,
+				      &autoneg_status);
+	if (status)
+		return status;
+
+	/* If external PHY link is not up, then indicate link not up */
+	if (!(autoneg_status & IXGBE_MDIO_AUTO_NEG_LINK_STATUS))
+		*link_up = false;
+
+	return 0;
+}
+
 /** ixgbe_init_mac_link_ops_X550em - init mac link function pointers
  *  @hw: pointer to hardware structure
  **/
@@ -932,6 +974,7 @@ static void ixgbe_init_mac_link_ops_X550em(struct ixgbe_hw *hw)
 		break;
 	case ixgbe_media_type_copper:
 		mac->ops.setup_link = ixgbe_setup_mac_link_t_X550em;
+		mac->ops.check_link = ixgbe_check_link_t_X550em;
 		break;
 	default:
 		break;
-- 
2.4.2
