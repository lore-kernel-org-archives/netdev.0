From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/14] e1000e: cleanup: remove e1000e_commit_phy()
Date: Mon, 28 Jan 2013 01:04:21 -0800
Message-ID: <1359363869-32391-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1359363869-32391-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:32473 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754176Ab3A1JEh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2013 04:04:37 -0500
In-Reply-To: <1359363869-32391-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Remove the function e1000e_commit_phy() and replace the few calls to it
with the same function pointer that it would call.  The function pointer is
almost always set for the devices that access these code paths so there is
no risk of a NULL pointer dereference; for the few instances where the
function pointer might not be set (i.e. can be called for the few devices
which do not have this function pointer set), check for a valid function
pointer.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/80003es2lan.c |  2 +-
 drivers/net/ethernet/intel/e1000e/e1000.h       |  2 --
 drivers/net/ethernet/intel/e1000e/ethtool.c     |  5 ++--
 drivers/net/ethernet/intel/e1000e/phy.c         | 35 +++++++++----------------
 4 files changed, 16 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/80003es2lan.c b/drivers/net/ethernet/intel/e1000e/80003es2lan.c
index ae96fac..3f27546 100644
--- a/drivers/net/ethernet/intel/e1000e/80003es2lan.c
+++ b/drivers/net/ethernet/intel/e1000e/80003es2lan.c
@@ -1010,7 +1010,7 @@ static s32 e1000_copper_link_setup_gg82563_80003es2lan(struct e1000_hw *hw)
 		return ret_val;
 
 	/* SW Reset the PHY so all changes take effect */
-	ret_val = e1000e_commit_phy(hw);
+	ret_val = hw->phy.ops.commit(hw);
 	if (ret_val) {
 		e_dbg("Error Resetting the PHY\n");
 		return ret_val;
diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000.h
index 896eacc..4ffb62b 100644
--- a/drivers/net/ethernet/intel/e1000e/e1000.h
+++ b/drivers/net/ethernet/intel/e1000e/e1000.h
@@ -579,8 +579,6 @@ extern const struct e1000_info e1000_es2_info;
 extern s32 e1000_read_pba_string_generic(struct e1000_hw *hw, u8 *pba_num,
 					 u32 pba_num_size);
 
-extern s32  e1000e_commit_phy(struct e1000_hw *hw);
-
 extern bool e1000e_enable_mng_pass_thru(struct e1000_hw *hw);
 
 extern bool e1000e_get_laa_state_82571(struct e1000_hw *hw);
diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index 6ab949d..58df18c 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -1321,7 +1321,7 @@ static int e1000_integrated_phy_loopback(struct e1000_adapter *adapter)
 		phy_reg |= 0x006;
 		e1e_wphy(hw, PHY_REG(2, 21), phy_reg);
 		/* Assert SW reset for above settings to take effect */
-		e1000e_commit_phy(hw);
+		hw->phy.ops.commit(hw);
 		mdelay(1);
 		/* Force Full Duplex */
 		e1e_rphy(hw, PHY_REG(769, 16), &phy_reg);
@@ -1542,7 +1542,8 @@ static void e1000_loopback_cleanup(struct e1000_adapter *adapter)
 		if (phy_reg & MII_CR_LOOPBACK) {
 			phy_reg &= ~MII_CR_LOOPBACK;
 			e1e_wphy(hw, PHY_CONTROL, phy_reg);
-			e1000e_commit_phy(hw);
+			if (hw->phy.ops.commit)
+				hw->phy.ops.commit(hw);
 		}
 		break;
 	}
diff --git a/drivers/net/ethernet/intel/e1000e/phy.c b/drivers/net/ethernet/intel/e1000e/phy.c
index c4bfbd6..cddfc6b 100644
--- a/drivers/net/ethernet/intel/e1000e/phy.c
+++ b/drivers/net/ethernet/intel/e1000e/phy.c
@@ -788,7 +788,7 @@ s32 e1000e_copper_link_setup_m88(struct e1000_hw *hw)
 			if (ret_val)
 				return ret_val;
 			/* Commit the changes. */
-			ret_val = e1000e_commit_phy(hw);
+			ret_val = phy->ops.commit(hw);
 			if (ret_val) {
 				e_dbg("Error committing the PHY changes\n");
 				return ret_val;
@@ -844,10 +844,12 @@ s32 e1000e_copper_link_setup_m88(struct e1000_hw *hw)
 	}
 
 	/* Commit the changes. */
-	ret_val = e1000e_commit_phy(hw);
-	if (ret_val) {
-		e_dbg("Error committing the PHY changes\n");
-		return ret_val;
+	if (phy->ops.commit) {
+		ret_val = phy->ops.commit(hw);
+		if (ret_val) {
+			e_dbg("Error committing the PHY changes\n");
+			return ret_val;
+		}
 	}
 
 	if (phy->type == e1000_phy_82578) {
@@ -1324,9 +1326,11 @@ s32 e1000e_phy_force_speed_duplex_m88(struct e1000_hw *hw)
 		return ret_val;
 
 	/* Reset the phy to commit changes. */
-	ret_val = e1000e_commit_phy(hw);
-	if (ret_val)
-		return ret_val;
+	if (hw->phy.ops.commit) {
+		ret_val = hw->phy.ops.commit(hw);
+		if (ret_val)
+			return ret_val;
+	}
 
 	if (phy->autoneg_wait_to_complete) {
 		e_dbg("Waiting for forced speed/duplex link on M88 phy.\n");
@@ -2772,21 +2776,6 @@ void e1000_power_down_phy_copper(struct e1000_hw *hw)
 }
 
 /**
- *  e1000e_commit_phy - Soft PHY reset
- *  @hw: pointer to the HW structure
- *
- *  Performs a soft PHY reset on those that apply. This is a function pointer
- *  entry point called by drivers.
- **/
-s32 e1000e_commit_phy(struct e1000_hw *hw)
-{
-	if (hw->phy.ops.commit)
-		return hw->phy.ops.commit(hw);
-
-	return 0;
-}
-
-/**
  *  __e1000_read_phy_reg_hv -  Read HV PHY register
  *  @hw: pointer to the HW structure
  *  @offset: register offset to be read
-- 
1.7.11.7
