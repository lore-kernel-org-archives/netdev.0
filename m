From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/15] ixgbe: add write flush when configuring CS4223/7
Date: Wed, 31 May 2017 14:19:33 -0700
Message-ID: <20170531211936.63417-13-jeffrey.t.kirsher@intel.com>
References: <20170531211936.63417-1-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:17444 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751129AbdEaVTy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 May 2017 17:19:54 -0400
In-Reply-To: <20170531211936.63417-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Make sure the writes are processed immediately. Without the flush it
is possible for operations on one port to spill over the other as the
resource is shared.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 20 ++++++++++++++++++--
 1 file changed, 18 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index 32b35efde2df..80824fec15d2 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -1824,12 +1824,28 @@ ixgbe_setup_mac_link_sfp_x550a(struct ixgbe_hw *hw, ixgbe_link_speed speed,
 
 	/* Configure CS4227/CS4223 LINE side to proper mode. */
 	reg_slice = IXGBE_CS4227_LINE_SPARE24_LSB + slice_offset;
+
+	ret_val = hw->phy.ops.read_reg(hw, reg_slice,
+				       IXGBE_MDIO_ZERO_DEV_TYPE, &reg_phy_ext);
+	if (ret_val)
+		return ret_val;
+
+	reg_phy_ext &= ~((IXGBE_CS4227_EDC_MODE_CX1 << 1) |
+			 (IXGBE_CS4227_EDC_MODE_SR << 1));
+
 	if (setup_linear)
 		reg_phy_ext = (IXGBE_CS4227_EDC_MODE_CX1 << 1) | 1;
 	else
 		reg_phy_ext = (IXGBE_CS4227_EDC_MODE_SR << 1) | 1;
-	return hw->phy.ops.write_reg(hw, reg_slice, IXGBE_MDIO_ZERO_DEV_TYPE,
-				     reg_phy_ext);
+
+	ret_val = hw->phy.ops.write_reg(hw, reg_slice,
+					IXGBE_MDIO_ZERO_DEV_TYPE, reg_phy_ext);
+	if (ret_val)
+		return ret_val;
+
+	/* Flush previous write with a read */
+	return hw->phy.ops.read_reg(hw, reg_slice,
+				    IXGBE_MDIO_ZERO_DEV_TYPE, &reg_phy_ext);
 }
 
 /**
-- 
2.12.2
