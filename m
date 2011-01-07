From: jeffrey.t.kirsher@intel.com
Subject: [net-next 01/12] e1000e: cleanup variables set but not used
Date: Thu,  6 Jan 2011 16:29:48 -0800
Message-ID: <1294360199-9860-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1294360199-9860-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gosp@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:19337 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753345Ab1AGAaq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jan 2011 19:30:46 -0500
To: davem@davemloft.net
In-Reply-To: <1294360199-9860-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The ICR register is clear on read and we don't care what the returned value
is when resetting the hardware so the icr variable(s) can be removed.  We
should not ignore the return from e1000_lv_jumbo_workaround_ich8lan() and
from e1000_get_phy_id_82571() (dump a debug message when it fails and when
an unknown Phy id is returned).

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/82571.c   |   21 ++++++++++++++-------
 drivers/net/e1000e/es2lan.c  |    4 ++--
 drivers/net/e1000e/ich8lan.c |    4 ++--
 drivers/net/e1000e/netdev.c  |    3 +++
 4 files changed, 21 insertions(+), 11 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index e57e409..11a273e 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -121,29 +121,36 @@ static s32 e1000_init_phy_params_82571(struct e1000_hw *hw)
 
 	/* This can only be done after all function pointers are setup. */
 	ret_val = e1000_get_phy_id_82571(hw);
+	if (ret_val) {
+		e_dbg("Error getting PHY ID\n");
+		return ret_val;
+	}
 
 	/* Verify phy id */
 	switch (hw->mac.type) {
 	case e1000_82571:
 	case e1000_82572:
 		if (phy->id != IGP01E1000_I_PHY_ID)
-			return -E1000_ERR_PHY;
+			ret_val = -E1000_ERR_PHY;
 		break;
 	case e1000_82573:
 		if (phy->id != M88E1111_I_PHY_ID)
-			return -E1000_ERR_PHY;
+			ret_val = -E1000_ERR_PHY;
 		break;
 	case e1000_82574:
 	case e1000_82583:
 		if (phy->id != BME1000_E_PHY_ID_R2)
-			return -E1000_ERR_PHY;
+			ret_val = -E1000_ERR_PHY;
 		break;
 	default:
-		return -E1000_ERR_PHY;
+		ret_val = -E1000_ERR_PHY;
 		break;
 	}
 
-	return 0;
+	if (ret_val)
+		e_dbg("PHY ID unknown: type = 0x%08x\n", phy->id);
+
+	return ret_val;
 }
 
 /**
@@ -956,7 +963,7 @@ static s32 e1000_set_d0_lplu_state_82571(struct e1000_hw *hw, bool active)
  **/
 static s32 e1000_reset_hw_82571(struct e1000_hw *hw)
 {
-	u32 ctrl, ctrl_ext, icr;
+	u32 ctrl, ctrl_ext;
 	s32 ret_val;
 
 	/*
@@ -1040,7 +1047,7 @@ static s32 e1000_reset_hw_82571(struct e1000_hw *hw)
 
 	/* Clear any pending interrupt events. */
 	ew32(IMC, 0xffffffff);
-	icr = er32(ICR);
+	er32(ICR);
 
 	if (hw->mac.type == e1000_82571) {
 		/* Install any alternate MAC address into RAR0 */
diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index b18c644..e45a61c 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -784,7 +784,7 @@ static s32 e1000_get_link_up_info_80003es2lan(struct e1000_hw *hw, u16 *speed,
  **/
 static s32 e1000_reset_hw_80003es2lan(struct e1000_hw *hw)
 {
-	u32 ctrl, icr;
+	u32 ctrl;
 	s32 ret_val;
 
 	/*
@@ -818,7 +818,7 @@ static s32 e1000_reset_hw_80003es2lan(struct e1000_hw *hw)
 
 	/* Clear any pending interrupt events. */
 	ew32(IMC, 0xffffffff);
-	icr = er32(ICR);
+	er32(ICR);
 
 	ret_val = e1000_check_alt_mac_addr_generic(hw);
 
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index d86cc08..754590d 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -2977,7 +2977,7 @@ static s32 e1000_reset_hw_ich8lan(struct e1000_hw *hw)
 {
 	struct e1000_dev_spec_ich8lan *dev_spec = &hw->dev_spec.ich8lan;
 	u16 reg;
-	u32 ctrl, icr, kab;
+	u32 ctrl, kab;
 	s32 ret_val;
 
 	/*
@@ -3067,7 +3067,7 @@ static s32 e1000_reset_hw_ich8lan(struct e1000_hw *hw)
 		ew32(CRC_OFFSET, 0x65656565);
 
 	ew32(IMC, 0xffffffff);
-	icr = er32(ICR);
+	er32(ICR);
 
 	kab = er32(KABGTXD);
 	kab |= E1000_KABGTXD_BGSQLBIAS;
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index fe50242..5498689 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -2734,6 +2734,9 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 			ret_val = e1000_lv_jumbo_workaround_ich8lan(hw, true);
 		else
 			ret_val = e1000_lv_jumbo_workaround_ich8lan(hw, false);
+
+		if (ret_val)
+			e_dbg("failed to enable jumbo frame workaround mode\n");
 	}
 
 	/* Program MC offset vector base */
-- 
1.7.3.4

