From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 4/4] e1000e: Restrict MDIO Slow Mode workaround to relevant parts
Date: Mon,  5 May 2014 13:07:40 -0700
Message-ID: <1399320460-21774-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1399320460-21774-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: David Ertman <davidx.m.ertman@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:59533 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752797AbaEEUHu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 May 2014 16:07:50 -0400
In-Reply-To: <1399320460-21774-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ertman <davidx.m.ertman@intel.com>

It has been determined that the workaround of putting the PHY into MDIO
slow mode to access the PHY id is not necessary with Lynx Point and newer
parts.  The issue that necessitated the workaround has been fixed on the
newer hardware.

We will maintains, as a last ditch attempt, the conversion to MDIO Slow
Mode in the failure branch when attempting to access the PHY id so as to
cover all contingencies.

Signed-off-by: Dave Ertman <davidx.m.ertman@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index e8587b9..f0bbd42 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -186,7 +186,7 @@ static bool e1000_phy_is_accessible_pchlan(struct e1000_hw *hw)
 {
 	u16 phy_reg = 0;
 	u32 phy_id = 0;
-	s32 ret_val;
+	s32 ret_val = 0;
 	u16 retry_count;
 	u32 mac_reg = 0;
 
@@ -217,11 +217,13 @@ static bool e1000_phy_is_accessible_pchlan(struct e1000_hw *hw)
 	/* In case the PHY needs to be in mdio slow mode,
 	 * set slow mode and try to get the PHY id again.
 	 */
-	hw->phy.ops.release(hw);
-	ret_val = e1000_set_mdio_slow_mode_hv(hw);
-	if (!ret_val)
-		ret_val = e1000e_get_phy_id(hw);
-	hw->phy.ops.acquire(hw);
+	if (hw->mac.type < e1000_pch_lpt) {
+		hw->phy.ops.release(hw);
+		ret_val = e1000_set_mdio_slow_mode_hv(hw);
+		if (!ret_val)
+			ret_val = e1000e_get_phy_id(hw);
+		hw->phy.ops.acquire(hw);
+	}
 
 	if (ret_val)
 		return false;
-- 
1.9.0
