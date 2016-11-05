From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/15] ixgbe: fix link status check for copper X550em
Date: Sat,  5 Nov 2016 00:54:11 -0700
Message-ID: <1478332461-43147-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1478332461-43147-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:56205 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753175AbcKEHyZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 5 Nov 2016 03:54:25 -0400
In-Reply-To: <1478332461-43147-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Read the PHY register twice in order to get the correct value for
autoneg_status.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 21 +++++++++++++--------
 1 file changed, 13 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index e9fa83b..51b6ade 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -1556,7 +1556,7 @@ static s32 ixgbe_check_link_t_X550em(struct ixgbe_hw *hw,
 				     bool link_up_wait_to_complete)
 {
 	u32 status;
-	u16 autoneg_status;
+	u16 i, autoneg_status;
 
 	if (hw->mac.ops.get_media_type(hw) != ixgbe_media_type_copper)
 		return IXGBE_ERR_CONFIG;
@@ -1568,13 +1568,18 @@ static s32 ixgbe_check_link_t_X550em(struct ixgbe_hw *hw,
 	if (status || !(*link_up))
 		return status;
 
-	 /* MAC link is up, so check external PHY link.
-	  * Read this twice back to back to indicate current status.
-	  */
-	status = hw->phy.ops.read_reg(hw, MDIO_STAT1, MDIO_MMD_AN,
-				      &autoneg_status);
-	if (status)
-		return status;
+	/* MAC link is up, so check external PHY link.
+	 * Link status is latching low, and can only be used to detect link
+	 * drop, and not the current status of the link without performing
+	 * back-to-back reads.
+	 */
+	for (i = 0; i < 2; i++) {
+		status = hw->phy.ops.read_reg(hw, MDIO_STAT1, MDIO_MMD_AN,
+					      &autoneg_status);
+
+		if (status)
+			return status;
+	}
 
 	/* If external PHY link is not up, then indicate link not up */
 	if (!(autoneg_status & IXGBE_MDIO_AUTO_NEG_LINK_STATUS))
-- 
2.7.4
