From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/12] e1000e: long access timeouts when I217/I218 MAC and PHY are out of sync
Date: Thu, 28 Mar 2013 02:00:07 -0700
Message-ID: <1364461215-7793-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1364461215-7793-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:31739 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751479Ab3C1JAW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Mar 2013 05:00:22 -0400
In-Reply-To: <1364461215-7793-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

When the MAC and PHY are in two different modes (different power levels
and interconnect speeds), it could take a long time before a PHY register
access timed out using the existing MAC-PHY interconnect configuration
coded into the driver for ICH- and PCH-based LOMs.  Introduce an I217/I218-
specific .setup_physical_interface operation which does not override the
interconnect configuration in the NVM.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c | 29 ++++++++++++++++++++++++++++-
 1 file changed, 28 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 4f2f0f6..3b1c1a7 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -142,6 +142,7 @@ static void e1000_rar_set_pch2lan(struct e1000_hw *hw, u8 *addr, u32 index);
 static void e1000_rar_set_pch_lpt(struct e1000_hw *hw, u8 *addr, u32 index);
 static s32 e1000_k1_workaround_lv(struct e1000_hw *hw);
 static void e1000_gate_hw_phy_config_ich8lan(struct e1000_hw *hw, bool gate);
+static s32 e1000_setup_copper_link_pch_lpt(struct e1000_hw *hw);
 
 static inline u16 __er16flash(struct e1000_hw *hw, unsigned long reg)
 {
@@ -636,6 +637,8 @@ static s32 e1000_init_mac_params_ich8lan(struct e1000_hw *hw)
 	if (mac->type == e1000_pch_lpt) {
 		mac->rar_entry_count = E1000_PCH_LPT_RAR_ENTRIES;
 		mac->ops.rar_set = e1000_rar_set_pch_lpt;
+		mac->ops.setup_physical_interface =
+		    e1000_setup_copper_link_pch_lpt;
 	}
 
 	/* Enable PCS Lock-loss workaround for ICH8 */
@@ -3788,7 +3791,6 @@ static s32 e1000_setup_copper_link_ich8lan(struct e1000_hw *hw)
 		break;
 	case e1000_phy_82577:
 	case e1000_phy_82579:
-	case e1000_phy_i217:
 		ret_val = e1000_copper_link_setup_82577(hw);
 		if (ret_val)
 			return ret_val;
@@ -3824,6 +3826,31 @@ static s32 e1000_setup_copper_link_ich8lan(struct e1000_hw *hw)
 }
 
 /**
+ *  e1000_setup_copper_link_pch_lpt - Configure MAC/PHY interface
+ *  @hw: pointer to the HW structure
+ *
+ *  Calls the PHY specific link setup function and then calls the
+ *  generic setup_copper_link to finish configuring the link for
+ *  Lynxpoint PCH devices
+ **/
+static s32 e1000_setup_copper_link_pch_lpt(struct e1000_hw *hw)
+{
+	u32 ctrl;
+	s32 ret_val;
+
+	ctrl = er32(CTRL);
+	ctrl |= E1000_CTRL_SLU;
+	ctrl &= ~(E1000_CTRL_FRCSPD | E1000_CTRL_FRCDPX);
+	ew32(CTRL, ctrl);
+
+	ret_val = e1000_copper_link_setup_82577(hw);
+	if (ret_val)
+		return ret_val;
+
+	return e1000e_setup_copper_link(hw);
+}
+
+/**
  *  e1000_get_link_up_info_ich8lan - Get current link speed and duplex
  *  @hw: pointer to the HW structure
  *  @speed: pointer to store current link speed
-- 
1.7.11.7
