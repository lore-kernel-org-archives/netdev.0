From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/2] e1000e: fix test for PHY being accessible on 82577/8/9 and I217
Date: Sat, 14 Jul 2012 00:47:43 -0700
Message-ID: <1342252063-27023-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1342252063-27023-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:58028 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756626Ab2GNHrr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Jul 2012 03:47:47 -0400
In-Reply-To: <1342252063-27023-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Occasionally, the PHY can be initially inaccessible when the first read of
a PHY register, e.g. PHY_ID1, happens (signified by the returned value
0xFFFF) but subsequent accesses of the PHY work as expected.  Add a retry
counter similar to how it is done in the generic e1000_get_phy_id().

Also, when the PHY is completely inaccessible (i.e. when subsequent reads
of the PHY_IDx registers returns all F's) and the MDIO access mode must be
set to slow before attempting to read the PHY ID again, the functions that
do these latter two actions expect the SW/FW/HW semaphore is not already
set so the semaphore must be released before and re-acquired after calling
them otherwise there is an unnecessarily inordinate amount of delay during
device initialization.

Reported-by: Heikki Krogerus <heikki.krogerus@linux.intel.com>
Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Heikki Krogerus <heikki.krogerus@linux.intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c |   42 ++++++++++++++++++++-------
 1 file changed, 32 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 238ab2f..e3a7b07 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -325,24 +325,46 @@ static inline void __ew32flash(struct e1000_hw *hw, unsigned long reg, u32 val)
  **/
 static bool e1000_phy_is_accessible_pchlan(struct e1000_hw *hw)
 {
-	u16 phy_reg;
-	u32 phy_id;
+	u16 phy_reg = 0;
+	u32 phy_id = 0;
+	s32 ret_val;
+	u16 retry_count;
+
+	for (retry_count = 0; retry_count < 2; retry_count++) {
+		ret_val = e1e_rphy_locked(hw, PHY_ID1, &phy_reg);
+		if (ret_val || (phy_reg == 0xFFFF))
+			continue;
+		phy_id = (u32)(phy_reg << 16);
 
-	e1e_rphy_locked(hw, PHY_ID1, &phy_reg);
-	phy_id = (u32)(phy_reg << 16);
-	e1e_rphy_locked(hw, PHY_ID2, &phy_reg);
-	phy_id |= (u32)(phy_reg & PHY_REVISION_MASK);
+		ret_val = e1e_rphy_locked(hw, PHY_ID2, &phy_reg);
+		if (ret_val || (phy_reg == 0xFFFF)) {
+			phy_id = 0;
+			continue;
+		}
+		phy_id |= (u32)(phy_reg & PHY_REVISION_MASK);
+		break;
+	}
 
 	if (hw->phy.id) {
 		if (hw->phy.id == phy_id)
 			return true;
-	} else {
-		if ((phy_id != 0) && (phy_id != PHY_REVISION_MASK))
-			hw->phy.id = phy_id;
+	} else if (phy_id) {
+		hw->phy.id = phy_id;
+		hw->phy.revision = (u32)(phy_reg & ~PHY_REVISION_MASK);
 		return true;
 	}
 
-	return false;
+	/*
+	 * In case the PHY needs to be in mdio slow mode,
+	 * set slow mode and try to get the PHY id again.
+	 */
+	hw->phy.ops.release(hw);
+	ret_val = e1000_set_mdio_slow_mode_hv(hw);
+	if (!ret_val)
+		ret_val = e1000e_get_phy_id(hw);
+	hw->phy.ops.acquire(hw);
+
+	return !ret_val;
 }
 
 /**
-- 
1.7.10.4
