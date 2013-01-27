From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/14] e1000e: prevent hardware from automatically configuring PHY on I217/I218
Date: Sun, 27 Jan 2013 02:39:44 -0800
Message-ID: <1359283193-2043-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1359283193-2043-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:43564 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756479Ab3A0Kj6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Jan 2013 05:39:58 -0500
In-Reply-To: <1359283193-2043-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

As done with the previous generation managed 82579, prevent the PHY from
being put into an unknown state by blocking the hardware from automatically
configuring the PHY as done with the previous generation managed 82579.
Instead, the driver should configure the PHY with contents of the EEPROM
image.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c | 22 +++++++---------------
 1 file changed, 7 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 56cbfa7..9a93223 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -363,10 +363,15 @@ static s32 e1000_init_phy_workarounds_pchlan(struct e1000_hw *hw)
 	s32 ret_val;
 	u16 phy_reg;
 
+	/* Gate automatic PHY configuration by hardware on managed and
+	 * non-managed 82579 and newer adapters.
+	 */
+	e1000_gate_hw_phy_config_ich8lan(hw, true);
+
 	ret_val = hw->phy.ops.acquire(hw);
 	if (ret_val) {
 		e_dbg("Failed to initialize PHY flow\n");
-		return ret_val;
+		goto out;
 	}
 
 	/* The MAC-PHY interconnect may be in SMBus mode.  If the PHY is
@@ -387,13 +392,6 @@ static s32 e1000_init_phy_workarounds_pchlan(struct e1000_hw *hw)
 
 		/* fall-through */
 	case e1000_pch2lan:
-		/* Gate automatic PHY configuration by hardware on
-		 * non-managed 82579
-		 */
-		if ((hw->mac.type == e1000_pch2lan) &&
-		    !(fwsm & E1000_ICH_FWSM_FW_VALID))
-			e1000_gate_hw_phy_config_ich8lan(hw, true);
-
 		if (e1000_phy_is_accessible_pchlan(hw)) {
 			if (hw->mac.type == e1000_pch_lpt) {
 				/* Unforce SMBus mode in PHY */
@@ -461,6 +459,7 @@ static s32 e1000_init_phy_workarounds_pchlan(struct e1000_hw *hw)
 	 */
 	ret_val = e1000e_phy_hw_reset_generic(hw);
 
+out:
 	/* Ungate automatic PHY configuration on non-managed 82579 */
 	if ((hw->mac.type == e1000_pch2lan) &&
 	    !(fwsm & E1000_ICH_FWSM_FW_VALID)) {
@@ -763,13 +762,6 @@ static s32 e1000_init_mac_params_ich8lan(struct e1000_hw *hw)
 	if (mac->type == e1000_ich8lan)
 		e1000e_set_kmrn_lock_loss_workaround_ich8lan(hw, true);
 
-	/* Gate automatic PHY configuration by hardware on managed
-	 * 82579 and i217
-	 */
-	if ((mac->type == e1000_pch2lan || mac->type == e1000_pch_lpt) &&
-	    (er32(FWSM) & E1000_ICH_FWSM_FW_VALID))
-		e1000_gate_hw_phy_config_ich8lan(hw, true);
-
 	return 0;
 }
 
-- 
1.7.11.7
