From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 8/8] ixgbe: remove global reset to the MAC
Date: Fri, 23 Sep 2011 09:12:47 -0700
Message-ID: <1316794367-23265-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1316794367-23265-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:35028 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752147Ab1IWQTC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Sep 2011 12:19:02 -0400
In-Reply-To: <1316794367-23265-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Reloading FW during resets can cause issues. Remove the full reset
as it is not needed.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c |   19 ++-----------------
 1 files changed, 2 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
index 84bb51d..96e0b20 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
@@ -93,10 +93,8 @@ static s32 ixgbe_setup_mac_link_X540(struct ixgbe_hw *hw,
  **/
 static s32 ixgbe_reset_hw_X540(struct ixgbe_hw *hw)
 {
-	ixgbe_link_speed link_speed;
 	s32 status;
 	u32 ctrl, i;
-	bool link_up = false;
 
 	/* Call adapter stop to disable tx/rx and clear interrupts */
 	status = hw->mac.ops.stop_adapter(hw);
@@ -107,19 +105,7 @@ static s32 ixgbe_reset_hw_X540(struct ixgbe_hw *hw)
 	ixgbe_clear_tx_pending(hw);
 
 mac_reset_top:
-	/*
-	 * Issue global reset to the MAC.  Needs to be SW reset if link is up.
-	 * If link reset is used when link is up, it might reset the PHY when
-	 * mng is using it.  If link is down or the flag to force full link
-	 * reset is set, then perform link reset.
-	 */
-	ctrl = IXGBE_CTRL_LNK_RST;
-	if (!hw->force_full_reset) {
-		hw->mac.ops.check_link(hw, &link_speed, &link_up, false);
-		if (link_up)
-			ctrl = IXGBE_CTRL_RST;
-	}
-
+	ctrl = IXGBE_CTRL_RST;
 	ctrl |= IXGBE_READ_REG(hw, IXGBE_CTRL);
 	IXGBE_WRITE_REG(hw, IXGBE_CTRL, ctrl);
 	IXGBE_WRITE_FLUSH(hw);
@@ -136,8 +122,7 @@ mac_reset_top:
 		status = IXGBE_ERR_RESET_FAILED;
 		hw_dbg(hw, "Reset polling failed to complete.\n");
 	}
-
-	msleep(50);
+	msleep(100);
 
 	/*
 	 * Double resets are required for recovery from certain error
-- 
1.7.6.2
