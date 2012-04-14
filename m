From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/2] e1000e: issues in Sx on 82577/8/9
Date: Sat, 14 Apr 2012 01:51:17 -0700
Message-ID: <1334393478-31885-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1334393478-31885-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:49685 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750734Ab2DNIvW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Apr 2012 04:51:22 -0400
In-Reply-To: <1334393478-31885-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

A workaround was previously put in the driver to reset the device when
transitioning to Sx in order to activate the changed settings of the PHY
OEM bits (Low Power Link Up, or LPLU, and GbE disable configuration) for
82577/8/9 devices.  After further review, it was found such a reset can
cause the 82579 to confuse which version of 82579 it actually is and broke
LPLU on all 82577/8/9 devices.  The workaround during an S0->Sx transition
on 82579 (instead of resetting the PHY) is to restart auto-negotiation
after the OEM bits are configured; the restart of auto-negotiation
activates the new OEM bits as does the reset.  With 82577/8, the reset is
changed to a generic reset which fixes the LPLU bits getting set wrong.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 64c7644..b461c24 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -1310,10 +1310,6 @@ static s32 e1000_oem_bits_config_ich8lan(struct e1000_hw *hw, bool d0_state)
 
 		if (mac_reg & E1000_PHY_CTRL_D0A_LPLU)
 			oem_reg |= HV_OEM_BITS_LPLU;
-
-		/* Set Restart auto-neg to activate the bits */
-		if (!hw->phy.ops.check_reset_block(hw))
-			oem_reg |= HV_OEM_BITS_RESTART_AN;
 	} else {
 		if (mac_reg & (E1000_PHY_CTRL_GBE_DISABLE |
 			       E1000_PHY_CTRL_NOND0A_GBE_DISABLE))
@@ -1324,6 +1320,11 @@ static s32 e1000_oem_bits_config_ich8lan(struct e1000_hw *hw, bool d0_state)
 			oem_reg |= HV_OEM_BITS_LPLU;
 	}
 
+	/* Set Restart auto-neg to activate the bits */
+	if ((d0_state || (hw->mac.type != e1000_pchlan)) &&
+	    !hw->phy.ops.check_reset_block(hw))
+		oem_reg |= HV_OEM_BITS_RESTART_AN;
+
 	ret_val = hw->phy.ops.write_reg_locked(hw, HV_OEM_BITS, oem_reg);
 
 release:
@@ -3682,7 +3683,11 @@ void e1000_suspend_workarounds_ich8lan(struct e1000_hw *hw)
 
 	if (hw->mac.type >= e1000_pchlan) {
 		e1000_oem_bits_config_ich8lan(hw, false);
-		e1000_phy_hw_reset_ich8lan(hw);
+
+		/* Reset PHY to activate OEM bits on 82577/8 */
+		if (hw->mac.type == e1000_pchlan)
+			e1000e_phy_hw_reset_generic(hw);
+
 		ret_val = hw->phy.ops.acquire(hw);
 		if (ret_val)
 			return;
-- 
1.7.7.6
