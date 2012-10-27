From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/12] igb: Enable auto-crossover during forced operation on 82580 and above.
Date: Fri, 26 Oct 2012 17:08:36 -0700
Message-ID: <1351296518-31174-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1351296518-31174-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Matthew Vick <matthew.vick@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:24439 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966900Ab2J0AIo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2012 20:08:44 -0400
In-Reply-To: <1351296518-31174-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Vick <matthew.vick@intel.com>

Newer devices supported by igb can support auto-crossover detection in
forced operation modes. Enable this in the driver, rather than clobbering
this functionality in forced operation.

Signed-off-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_mac.c |  4 ++++
 drivers/net/ethernet/intel/igb/e1000_phy.c | 29 +++++++++++++++++------------
 2 files changed, 21 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_mac.c b/drivers/net/ethernet/intel/igb/e1000_mac.c
index 819c145..7acddfe 100644
--- a/drivers/net/ethernet/intel/igb/e1000_mac.c
+++ b/drivers/net/ethernet/intel/igb/e1000_mac.c
@@ -1391,6 +1391,10 @@ s32 igb_validate_mdi_setting(struct e1000_hw *hw)
 {
 	s32 ret_val = 0;
 
+	/* All MDI settings are supported on 82580 and newer. */
+	if (hw->mac.type >= e1000_82580)
+		goto out;
+
 	if (!hw->mac.autoneg && (hw->phy.mdix == 0 || hw->phy.mdix == 3)) {
 		hw_dbg("Invalid MDI setting detected\n");
 		hw->phy.mdix = 1;
diff --git a/drivers/net/ethernet/intel/igb/e1000_phy.c b/drivers/net/ethernet/intel/igb/e1000_phy.c
index c62a4c3..fe76004 100644
--- a/drivers/net/ethernet/intel/igb/e1000_phy.c
+++ b/drivers/net/ethernet/intel/igb/e1000_phy.c
@@ -1207,20 +1207,25 @@ s32 igb_phy_force_speed_duplex_m88(struct e1000_hw *hw)
 	u16 phy_data;
 	bool link;
 
-	/*
-	 * Clear Auto-Crossover to force MDI manually.  M88E1000 requires MDI
-	 * forced whenever speed and duplex are forced.
-	 */
-	ret_val = phy->ops.read_reg(hw, M88E1000_PHY_SPEC_CTRL, &phy_data);
-	if (ret_val)
-		goto out;
+	/* I210 and I211 devices support Auto-Crossover in forced operation. */
+	if (phy->type != e1000_phy_i210) {
+		/*
+		 * Clear Auto-Crossover to force MDI manually.  M88E1000
+		 * requires MDI forced whenever speed and duplex are forced.
+		 */
+		ret_val = phy->ops.read_reg(hw, M88E1000_PHY_SPEC_CTRL,
+					    &phy_data);
+		if (ret_val)
+			goto out;
 
-	phy_data &= ~M88E1000_PSCR_AUTO_X_MODE;
-	ret_val = phy->ops.write_reg(hw, M88E1000_PHY_SPEC_CTRL, phy_data);
-	if (ret_val)
-		goto out;
+		phy_data &= ~M88E1000_PSCR_AUTO_X_MODE;
+		ret_val = phy->ops.write_reg(hw, M88E1000_PHY_SPEC_CTRL,
+					     phy_data);
+		if (ret_val)
+			goto out;
 
-	hw_dbg("M88E1000 PSCR: %X\n", phy_data);
+		hw_dbg("M88E1000 PSCR: %X\n", phy_data);
+	}
 
 	ret_val = phy->ops.read_reg(hw, PHY_CONTROL, &phy_data);
 	if (ret_val)
-- 
1.7.11.7
