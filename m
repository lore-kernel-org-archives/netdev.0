From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 12/24] ixgbe: add polling test to end of PHY reset
Date: Thu,  3 Mar 2011 05:03:37 -0800
Message-ID: <1299157429-15878-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299157429-15878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:49621 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758203Ab1CCNEW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2011 08:04:22 -0500
In-Reply-To: <1299157429-15878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Some PHYs require that we poll the reset bit and wait for it to clear
before continuing initialization.  As such we should add this check to the
end of the ixgbe_reset_phy_generic routine.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_phy.c |   40 +++++++++++++++++++++++++++++++++++++---
 1 files changed, 37 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_phy.c b/drivers/net/ixgbe/ixgbe_phy.c
index f8a60ca..ebd6e44 100644
--- a/drivers/net/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ixgbe/ixgbe_phy.c
@@ -138,17 +138,51 @@ static enum ixgbe_phy_type ixgbe_get_phy_type_from_id(u32 phy_id)
  **/
 s32 ixgbe_reset_phy_generic(struct ixgbe_hw *hw)
 {
+	u32 i;
+	u16 ctrl = 0;
+	s32 status = 0;
+
+	if (hw->phy.type == ixgbe_phy_unknown)
+		status = ixgbe_identify_phy_generic(hw);
+
+	if (status != 0 || hw->phy.type == ixgbe_phy_none)
+		goto out;
+
 	/* Don't reset PHY if it's shut down due to overtemp. */
 	if (!hw->phy.reset_if_overtemp &&
 	    (IXGBE_ERR_OVERTEMP == hw->phy.ops.check_overtemp(hw)))
-		return 0;
+		goto out;
 
 	/*
 	 * Perform soft PHY reset to the PHY_XS.
 	 * This will cause a soft reset to the PHY
 	 */
-	return hw->phy.ops.write_reg(hw, MDIO_CTRL1, MDIO_MMD_PHYXS,
-				     MDIO_CTRL1_RESET);
+	hw->phy.ops.write_reg(hw, MDIO_CTRL1,
+			      MDIO_MMD_PHYXS,
+			      MDIO_CTRL1_RESET);
+
+	/*
+	 * Poll for reset bit to self-clear indicating reset is complete.
+	 * Some PHYs could take up to 3 seconds to complete and need about
+	 * 1.7 usec delay after the reset is complete.
+	 */
+	for (i = 0; i < 30; i++) {
+		msleep(100);
+		hw->phy.ops.read_reg(hw, MDIO_CTRL1,
+				     MDIO_MMD_PHYXS, &ctrl);
+		if (!(ctrl & MDIO_CTRL1_RESET)) {
+			udelay(2);
+			break;
+		}
+	}
+
+	if (ctrl & MDIO_CTRL1_RESET) {
+		status = IXGBE_ERR_RESET_FAILED;
+		hw_dbg(hw, "PHY reset polling failed to complete.\n");
+	}
+
+out:
+	return status;
 }
 
 /**
-- 
1.7.4

