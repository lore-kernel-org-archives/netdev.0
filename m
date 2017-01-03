From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 03/21] ixgbe: Fix check for ixgbe_phy_x550em_ext_t reset
Date: Tue,  3 Jan 2017 13:07:39 -0800
Message-ID: <20170103210757.38847-4-jeffrey.t.kirsher@intel.com>
References: <20170103210757.38847-1-jeffrey.t.kirsher@intel.com>
Cc: Tony Nguyen <anthony.l.nguyen@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:25260 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934984AbdACVIB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 16:08:01 -0500
In-Reply-To: <20170103210757.38847-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tony Nguyen <anthony.l.nguyen@intel.com>

The generic PHY reset check we had previously is not sufficient for the
ixgbe_phy_x550em_ext_t PHY type.  Check 1.CC02.0 instead - same as
ixgbe_init_ext_t_x550().

Signed-off-by: Tony Nguyen <anthony.l.nguyen@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c | 25 +++++++++++++++++++++----
 1 file changed, 21 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
index 3b83620..b272938 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
@@ -452,10 +452,27 @@ s32 ixgbe_reset_phy_generic(struct ixgbe_hw *hw)
 	 */
 	for (i = 0; i < 30; i++) {
 		msleep(100);
-		hw->phy.ops.read_reg(hw, MDIO_CTRL1, MDIO_MMD_PHYXS, &ctrl);
-		if (!(ctrl & MDIO_CTRL1_RESET)) {
-			udelay(2);
-			break;
+		if (hw->phy.type == ixgbe_phy_x550em_ext_t) {
+			status = hw->phy.ops.read_reg(hw,
+						  IXGBE_MDIO_TX_VENDOR_ALARMS_3,
+						  MDIO_MMD_PMAPMD, &ctrl);
+			if (status)
+				return status;
+
+			if (ctrl & IXGBE_MDIO_TX_VENDOR_ALARMS_3_RST_MASK) {
+				udelay(2);
+				break;
+			}
+		} else {
+			status = hw->phy.ops.read_reg(hw, MDIO_CTRL1,
+						      MDIO_MMD_PHYXS, &ctrl);
+			if (status)
+				return status;
+
+			if (!(ctrl & MDIO_CTRL1_RESET)) {
+				udelay(2);
+				break;
+			}
 		}
 	}
 
-- 
2.9.3
