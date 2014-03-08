From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/15] e1000e: Fix 82579 sets LPI too early.
Date: Sat,  8 Mar 2014 01:25:30 -0800
Message-ID: <1394270741-29926-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394270741-29926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: David Ertman <davidx.m.ertman@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:51114 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751116AbaCHJZp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Mar 2014 04:25:45 -0500
In-Reply-To: <1394270741-29926-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ertman <davidx.m.ertman@intel.com>

Enabling EEE LPI sooner than one second after link up on 82579 causes link
issues with some switches.

Remove EEE enablement for 82579 parts from the link initialization flow to
avoid initializing too early.  EEE initialization for 82579 will be done
in e1000e_update_phy_task.

Signed-off-by: Dave Ertman <davidx.m.ertman@intel.com>
Acked-by: Bruce W Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c | 16 ++++++++++++----
 drivers/net/ethernet/intel/e1000e/ich8lan.h |  1 +
 drivers/net/ethernet/intel/e1000e/netdev.c  |  7 ++++++-
 3 files changed, 19 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 4f3da87..42cc537 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -744,8 +744,14 @@ s32 e1000_write_emi_reg_locked(struct e1000_hw *hw, u16 addr, u16 data)
  *  Enable/disable EEE based on setting in dev_spec structure, the duplex of
  *  the link and the EEE capabilities of the link partner.  The LPI Control
  *  register bits will remain set only if/when link is up.
+ *
+ *  EEE LPI must not be asserted earlier than one second after link is up.
+ *  On 82579, EEE LPI should not be enabled until such time otherwise there
+ *  can be link issues with some switches.  Other devices can have EEE LPI
+ *  enabled immediately upon link up since they have a timer in hardware which
+ *  prevents LPI from being asserted too early.
  **/
-static s32 e1000_set_eee_pchlan(struct e1000_hw *hw)
+s32 e1000_set_eee_pchlan(struct e1000_hw *hw)
 {
 	struct e1000_dev_spec_ich8lan *dev_spec = &hw->dev_spec.ich8lan;
 	s32 ret_val;
@@ -1126,9 +1132,11 @@ static s32 e1000_check_for_copper_link_ich8lan(struct e1000_hw *hw)
 	e1000e_check_downshift(hw);
 
 	/* Enable/Disable EEE after link up */
-	ret_val = e1000_set_eee_pchlan(hw);
-	if (ret_val)
-		return ret_val;
+	if (hw->phy.type > e1000_phy_82579) {
+		ret_val = e1000_set_eee_pchlan(hw);
+		if (ret_val)
+			return ret_val;
+	}
 
 	/* If we are forcing speed/duplex, then we simply return since
 	 * we have already determined whether we have link or not.
diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.h b/drivers/net/ethernet/intel/e1000e/ich8lan.h
index 217090d..707bf4d 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.h
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.h
@@ -268,4 +268,5 @@ void e1000_copy_rx_addrs_to_phy_ich8lan(struct e1000_hw *hw);
 s32 e1000_lv_jumbo_workaround_ich8lan(struct e1000_hw *hw, bool enable);
 s32 e1000_read_emi_reg_locked(struct e1000_hw *hw, u16 addr, u16 *data);
 s32 e1000_write_emi_reg_locked(struct e1000_hw *hw, u16 addr, u16 data);
+s32 e1000_set_eee_pchlan(struct e1000_hw *hw);
 #endif /* _E1000E_ICH8LAN_H_ */
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 1f144e9..94bd92d 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -4463,11 +4463,16 @@ static void e1000e_update_phy_task(struct work_struct *work)
 	struct e1000_adapter *adapter = container_of(work,
 						     struct e1000_adapter,
 						     update_phy_task);
+	struct e1000_hw *hw = &adapter->hw;
 
 	if (test_bit(__E1000_DOWN, &adapter->state))
 		return;
 
-	e1000_get_phy_info(&adapter->hw);
+	e1000_get_phy_info(hw);
+
+	/* Enable EEE on 82579 after link up */
+	if (hw->phy.type == e1000_phy_82579)
+		e1000_set_eee_pchlan(hw);
 }
 
 /**
-- 
1.8.3.1
