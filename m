From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 02/12] e1000e: 82579 intermittently disabled during S0->Sx
Date: Thu,  9 Jun 2011 20:47:46 -0700
Message-ID: <1307677676-26690-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1307677676-26690-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:56870 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753423Ab1FJDsA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2011 23:48:00 -0400
In-Reply-To: <1307677676-26690-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

When repeatedly cycling Sx->S0 states with the network cable unplugged,
the 82579 PHY may not initialize as expected and may require a full power
cycle to recover functionality to the device.  Workaround this by testing
access of the PHY registers after resuming; if that returns unexpected
results toggle the LANPHYPC signal to power cycle the PHY.

This is implemented in the new function e1000_resume_workarounds_pchlan()
which calls another new function, e1000_toggle_lanphypc_value_ich8lan(),
which has been created to reduce code duplication (same functionality
required by a previous workaround).  Also, e1000e_disable_gig_wol_ich8lan
is now e1000_suspend_workarounds_ich8lan to better reflect what it does.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/e1000.h   |    3 +-
 drivers/net/e1000e/ich8lan.c |   86 +++++++++++++++++++++++++++++++++++------
 drivers/net/e1000e/netdev.c  |    5 ++-
 3 files changed, 79 insertions(+), 15 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 9549879..f8cd56a 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -533,7 +533,8 @@ extern void e1000e_set_kmrn_lock_loss_workaround_ich8lan(struct e1000_hw *hw,
 						 bool state);
 extern void e1000e_igp3_phy_powerdown_workaround_ich8lan(struct e1000_hw *hw);
 extern void e1000e_gig_downshift_workaround_ich8lan(struct e1000_hw *hw);
-extern void e1000e_disable_gig_wol_ich8lan(struct e1000_hw *hw);
+extern void e1000_suspend_workarounds_ich8lan(struct e1000_hw *hw);
+extern void e1000_resume_workarounds_pchlan(struct e1000_hw *hw);
 extern s32 e1000_configure_k1_ich8lan(struct e1000_hw *hw, bool k1_enable);
 extern s32 e1000_lv_jumbo_workaround_ich8lan(struct e1000_hw *hw, bool enable);
 extern void e1000_copy_rx_addrs_to_phy_ich8lan(struct e1000_hw *hw);
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 3369d1f..dcd5db5 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -275,6 +275,19 @@ static inline void __ew32flash(struct e1000_hw *hw, unsigned long reg, u32 val)
 #define ew16flash(reg,val)	__ew16flash(hw, (reg), (val))
 #define ew32flash(reg,val)	__ew32flash(hw, (reg), (val))
 
+static void e1000_toggle_lanphypc_value_ich8lan(struct e1000_hw *hw)
+{
+	u32 ctrl;
+
+	ctrl = er32(CTRL);
+	ctrl |= E1000_CTRL_LANPHYPC_OVERRIDE;
+	ctrl &= ~E1000_CTRL_LANPHYPC_VALUE;
+	ew32(CTRL, ctrl);
+	udelay(10);
+	ctrl &= ~E1000_CTRL_LANPHYPC_OVERRIDE;
+	ew32(CTRL, ctrl);
+}
+
 /**
  *  e1000_init_phy_params_pchlan - Initialize PHY function pointers
  *  @hw: pointer to the HW structure
@@ -284,7 +297,7 @@ static inline void __ew32flash(struct e1000_hw *hw, unsigned long reg, u32 val)
 static s32 e1000_init_phy_params_pchlan(struct e1000_hw *hw)
 {
 	struct e1000_phy_info *phy = &hw->phy;
-	u32 ctrl, fwsm;
+	u32 fwsm;
 	s32 ret_val = 0;
 
 	phy->addr                     = 1;
@@ -308,13 +321,7 @@ static s32 e1000_init_phy_params_pchlan(struct e1000_hw *hw)
 	 */
 	fwsm = er32(FWSM);
 	if (!(fwsm & E1000_ICH_FWSM_FW_VALID) && !e1000_check_reset_block(hw)) {
-		ctrl = er32(CTRL);
-		ctrl |= E1000_CTRL_LANPHYPC_OVERRIDE;
-		ctrl &= ~E1000_CTRL_LANPHYPC_VALUE;
-		ew32(CTRL, ctrl);
-		udelay(10);
-		ctrl &= ~E1000_CTRL_LANPHYPC_OVERRIDE;
-		ew32(CTRL, ctrl);
+		e1000_toggle_lanphypc_value_ich8lan(hw);
 		msleep(50);
 
 		/*
@@ -3586,17 +3593,16 @@ void e1000e_gig_downshift_workaround_ich8lan(struct e1000_hw *hw)
 }
 
 /**
- *  e1000e_disable_gig_wol_ich8lan - disable gig during WoL
+ *  e1000_suspend_workarounds_ich8lan - workarounds needed during S0->Sx
  *  @hw: pointer to the HW structure
  *
  *  During S0 to Sx transition, it is possible the link remains at gig
  *  instead of negotiating to a lower speed.  Before going to Sx, set
  *  'LPLU Enabled' and 'Gig Disable' to force link speed negotiation
- *  to a lower speed.
- *
- *  Should only be called for applicable parts.
+ *  to a lower speed.  For PCH and newer parts, the OEM bits PHY register
+ *  (LED, GbE disable and LPLU configurations) also needs to be written.
  **/
-void e1000e_disable_gig_wol_ich8lan(struct e1000_hw *hw)
+void e1000_suspend_workarounds_ich8lan(struct e1000_hw *hw)
 {
 	u32 phy_ctrl;
 	s32 ret_val;
@@ -3616,6 +3622,60 @@ void e1000e_disable_gig_wol_ich8lan(struct e1000_hw *hw)
 }
 
 /**
+ *  e1000_resume_workarounds_pchlan - workarounds needed during Sx->S0
+ *  @hw: pointer to the HW structure
+ *
+ *  During Sx to S0 transitions on non-managed devices or managed devices
+ *  on which PHY resets are not blocked, if the PHY registers cannot be
+ *  accessed properly by the s/w toggle the LANPHYPC value to power cycle
+ *  the PHY.
+ **/
+void e1000_resume_workarounds_pchlan(struct e1000_hw *hw)
+{
+	u32 fwsm;
+
+	if (hw->mac.type != e1000_pch2lan)
+		return;
+
+	fwsm = er32(FWSM);
+	if (!(fwsm & E1000_ICH_FWSM_FW_VALID) || !e1000_check_reset_block(hw)) {
+		u16 phy_id1, phy_id2;
+		s32 ret_val;
+
+		ret_val = hw->phy.ops.acquire(hw);
+		if (ret_val) {
+			e_dbg("Failed to acquire PHY semaphore in resume\n");
+			return;
+		}
+
+		/* Test access to the PHY registers by reading the ID regs */
+		ret_val = hw->phy.ops.read_reg_locked(hw, PHY_ID1, &phy_id1);
+		if (ret_val)
+			goto release;
+		ret_val = hw->phy.ops.read_reg_locked(hw, PHY_ID2, &phy_id2);
+		if (ret_val)
+			goto release;
+
+		if (hw->phy.id == ((u32)(phy_id1 << 16) |
+				   (u32)(phy_id2 & PHY_REVISION_MASK)))
+			goto release;
+
+		e1000_toggle_lanphypc_value_ich8lan(hw);
+
+		hw->phy.ops.release(hw);
+		msleep(50);
+		e1000_phy_hw_reset(hw);
+		msleep(50);
+		return;
+	}
+
+release:
+	hw->phy.ops.release(hw);
+
+	return;
+}
+
+/**
  *  e1000_cleanup_led_ich8lan - Restore the default LED operation
  *  @hw: pointer to the HW structure
  *
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 888bd9c..c4a23c7 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -5278,7 +5278,7 @@ static int __e1000_shutdown(struct pci_dev *pdev, bool *enable_wake,
 		}
 
 		if (adapter->flags & FLAG_IS_ICH)
-			e1000e_disable_gig_wol_ich8lan(&adapter->hw);
+			e1000_suspend_workarounds_ich8lan(&adapter->hw);
 
 		/* Allow time for pending master requests to run */
 		e1000e_disable_pcie_master(&adapter->hw);
@@ -5429,6 +5429,9 @@ static int __e1000_resume(struct pci_dev *pdev)
 			return err;
 	}
 
+	if (hw->mac.type == e1000_pch2lan)
+		e1000_resume_workarounds_pchlan(&adapter->hw);
+
 	e1000e_power_up_phy(adapter);
 
 	/* report the system wakeup cause from S3/S4 */
-- 
1.7.5.2

