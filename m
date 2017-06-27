From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 4/6] ixgbe: Do not support flow control autonegotiation for X553
Date: Tue, 27 Jun 2017 01:51:29 -0700
Message-ID: <20170627085131.9831-5-jeffrey.t.kirsher@intel.com>
References: <20170627085131.9831-1-jeffrey.t.kirsher@intel.com>
Cc: Tony Nguyen <anthony.l.nguyen@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Emil Tantilov <emil.s.tantilov@intel.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:28455 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752603AbdF0Ivj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 27 Jun 2017 04:51:39 -0400
In-Reply-To: <20170627085131.9831-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tony Nguyen <anthony.l.nguyen@intel.com>

Flow control autonegotiation is not supported for fiber on X553.  Add
device ID checks in ixgbe_device_supports_autoneg_fc() to return the
appropriate value.

Signed-off-by: Tony Nguyen <anthony.l.nguyen@intel.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 25 +++++++++++++++++++------
 1 file changed, 19 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index 4e35e7017f3d..40ae7db468ea 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -79,13 +79,22 @@ bool ixgbe_device_supports_autoneg_fc(struct ixgbe_hw *hw)
 
 	switch (hw->phy.media_type) {
 	case ixgbe_media_type_fiber:
-		hw->mac.ops.check_link(hw, &speed, &link_up, false);
-		/* if link is down, assume supported */
-		if (link_up)
-			supported = speed == IXGBE_LINK_SPEED_1GB_FULL ?
+		/* flow control autoneg black list */
+		switch (hw->device_id) {
+		case IXGBE_DEV_ID_X550EM_A_SFP:
+		case IXGBE_DEV_ID_X550EM_A_SFP_N:
+			supported = false;
+			break;
+		default:
+			hw->mac.ops.check_link(hw, &speed, &link_up, false);
+			/* if link is down, assume supported */
+			if (link_up)
+				supported = speed == IXGBE_LINK_SPEED_1GB_FULL ?
 				true : false;
-		else
-			supported = true;
+			else
+				supported = true;
+		}
+
 		break;
 	case ixgbe_media_type_backplane:
 		supported = true;
@@ -111,6 +120,10 @@ bool ixgbe_device_supports_autoneg_fc(struct ixgbe_hw *hw)
 		break;
 	}
 
+	if (!supported)
+		hw_dbg(hw, "Device %x does not support flow control autoneg\n",
+		       hw->device_id);
+
 	return supported;
 }
 
-- 
2.12.2
