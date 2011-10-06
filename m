From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/9] e1000e: WoL can fail on 82578DM
Date: Thu,  6 Oct 2011 04:02:31 -0700
Message-ID: <1317898959-16550-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1317898959-16550-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:30733 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756022Ab1JFLCm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Oct 2011 07:02:42 -0400
In-Reply-To: <1317898959-16550-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

During suspend, the PHY must be reset for workaround updates to take effect
without restarting auto-negotiation.  Also, set the disable GbE and enable
Low Power Link Up (LPLU) if the EEPROM is configured to do likewise in
either D0 or non-D0a instead of just the latter.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 3b063e1..4ec5a5a 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -1319,16 +1319,20 @@ static s32 e1000_oem_bits_config_ich8lan(struct e1000_hw *hw, bool d0_state)
 
 		if (mac_reg & E1000_PHY_CTRL_D0A_LPLU)
 			oem_reg |= HV_OEM_BITS_LPLU;
+
+		/* Set Restart auto-neg to activate the bits */
+		if (!e1000_check_reset_block(hw))
+			oem_reg |= HV_OEM_BITS_RESTART_AN;
 	} else {
-		if (mac_reg & E1000_PHY_CTRL_NOND0A_GBE_DISABLE)
+		if (mac_reg & (E1000_PHY_CTRL_GBE_DISABLE |
+			       E1000_PHY_CTRL_NOND0A_GBE_DISABLE))
 			oem_reg |= HV_OEM_BITS_GBE_DIS;
 
-		if (mac_reg & E1000_PHY_CTRL_NOND0A_LPLU)
+		if (mac_reg & (E1000_PHY_CTRL_D0A_LPLU |
+			       E1000_PHY_CTRL_NOND0A_LPLU))
 			oem_reg |= HV_OEM_BITS_LPLU;
 	}
-	/* Restart auto-neg to activate the bits */
-	if (!e1000_check_reset_block(hw))
-		oem_reg |= HV_OEM_BITS_RESTART_AN;
+
 	ret_val = hw->phy.ops.write_reg_locked(hw, HV_OEM_BITS, oem_reg);
 
 out:
@@ -3684,6 +3688,7 @@ void e1000_suspend_workarounds_ich8lan(struct e1000_hw *hw)
 
 	if (hw->mac.type >= e1000_pchlan) {
 		e1000_oem_bits_config_ich8lan(hw, false);
+		e1000_phy_hw_reset_ich8lan(hw);
 		ret_val = hw->phy.ops.acquire(hw);
 		if (ret_val)
 			return;
-- 
1.7.6.4
