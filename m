From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/6] ixgbe: Enable LASI interrupts for X552 devices
Date: Mon, 26 Jun 2017 14:39:29 -0700
Message-ID: <20170626213933.9635-3-jeffrey.t.kirsher@intel.com>
References: <20170626213933.9635-1-jeffrey.t.kirsher@intel.com>
Cc: Tony Nguyen <anthony.l.nguyen@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:39969 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751739AbdFZVjl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 26 Jun 2017 17:39:41 -0400
In-Reply-To: <20170626213933.9635-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tony Nguyen <anthony.l.nguyen@intel.com>

Enable LASI interrupts on X552 devices in order to receive notifications of
link configurations of the external PHY and support the configuration of
the internal iXFI link since iXFI does not support auto-negotiation.  This
is not required for X553 devices; add a check to avoid enabling LASI
interrupts for X553 devices.

Signed-off-by: Tony Nguyen <anthony.l.nguyen@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 31 +++++++++++++++++++--------
 1 file changed, 22 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index 72d84a065e34..aa34e0b131bb 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -2404,17 +2404,30 @@ static s32 ixgbe_enable_lasi_ext_t_x550em(struct ixgbe_hw *hw)
 	status = ixgbe_get_lasi_ext_t_x550em(hw, &lsc);
 
 	/* Enable link status change alarm */
-	status = hw->phy.ops.read_reg(hw, IXGBE_MDIO_PMA_TX_VEN_LASI_INT_MASK,
-				      MDIO_MMD_AN, &reg);
-	if (status)
-		return status;
 
-	reg |= IXGBE_MDIO_PMA_TX_VEN_LASI_INT_EN;
+	/* Enable the LASI interrupts on X552 devices to receive notifications
+	 * of the link configurations of the external PHY and correspondingly
+	 * support the configuration of the internal iXFI link, since iXFI does
+	 * not support auto-negotiation. This is not required for X553 devices
+	 * having KR support, which performs auto-negotiations and which is used
+	 * as the internal link to the external PHY. Hence adding a check here
+	 * to avoid enabling LASI interrupts for X553 devices.
+	 */
+	if (hw->mac.type != ixgbe_mac_x550em_a) {
+		status = hw->phy.ops.read_reg(hw,
+					    IXGBE_MDIO_PMA_TX_VEN_LASI_INT_MASK,
+					    MDIO_MMD_AN, &reg);
+		if (status)
+			return status;
+
+		reg |= IXGBE_MDIO_PMA_TX_VEN_LASI_INT_EN;
 
-	status = hw->phy.ops.write_reg(hw, IXGBE_MDIO_PMA_TX_VEN_LASI_INT_MASK,
-				       MDIO_MMD_AN, reg);
-	if (status)
-		return status;
+		status = hw->phy.ops.write_reg(hw,
+					    IXGBE_MDIO_PMA_TX_VEN_LASI_INT_MASK,
+					    MDIO_MMD_AN, reg);
+		if (status)
+			return status;
+	}
 
 	/* Enable high temperature failure and global fault alarms */
 	status = hw->phy.ops.read_reg(hw, IXGBE_MDIO_GLOBAL_INT_MASK,
-- 
2.12.2
