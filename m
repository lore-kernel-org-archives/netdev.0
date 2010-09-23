From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 6/6] e1000e: 82579 do not gate auto config of PHY by
	hardware during nominal use
Date: Wed, 22 Sep 2010 20:17:01 -0700
Message-ID: <20100923031700.10976.38.stgit@localhost.localdomain>
References: <20100923031432.10976.81909.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.westchester.pa.mail.comcast.net ([76.96.62.64]:43504
	"EHLO qmta07.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752804Ab0IWDRV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 23:17:21 -0400
In-Reply-To: <20100923031432.10976.81909.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

For non-managed versions of 82579, set the bit that prevents the hardware
from automatically configuring the PHY after resets only when the driver
performs a reset, clear the bit after resets.  This is so the hardware can
configure the PHY automatically when the part is reset in a manner that is
not controlled by the driver (e.g. in a virtual environment via PCI FLR)
otherwise the PHY will be mis-configured causing issues such as failing to
link at 1000Mbps.
For managed versions of 82579, keep the previous behavior since the
manageability firmware will handle the PHY configuration.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/ich8lan.c |   77 +++++++++++++++++++++++++++++++++++++-----
 1 files changed, 68 insertions(+), 9 deletions(-)

diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index bb346ae..57b5435 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -243,6 +243,7 @@ static s32 e1000_set_mdio_slow_mode_hv(struct e1000_hw *hw);
 static bool e1000_check_mng_mode_ich8lan(struct e1000_hw *hw);
 static bool e1000_check_mng_mode_pchlan(struct e1000_hw *hw);
 static s32 e1000_k1_workaround_lv(struct e1000_hw *hw);
+static void e1000_gate_hw_phy_config_ich8lan(struct e1000_hw *hw, bool gate);
 
 static inline u16 __er16flash(struct e1000_hw *hw, unsigned long reg)
 {
@@ -278,7 +279,7 @@ static inline void __ew32flash(struct e1000_hw *hw, unsigned long reg, u32 val)
 static s32 e1000_init_phy_params_pchlan(struct e1000_hw *hw)
 {
 	struct e1000_phy_info *phy = &hw->phy;
-	u32 ctrl;
+	u32 ctrl, fwsm;
 	s32 ret_val = 0;
 
 	phy->addr                     = 1;
@@ -300,7 +301,8 @@ static s32 e1000_init_phy_params_pchlan(struct e1000_hw *hw)
 	 * disabled, then toggle the LANPHYPC Value bit to force
 	 * the interconnect to PCIe mode.
 	 */
-	if (!(er32(FWSM) & E1000_ICH_FWSM_FW_VALID)) {
+	fwsm = er32(FWSM);
+	if (!(fwsm & E1000_ICH_FWSM_FW_VALID)) {
 		ctrl = er32(CTRL);
 		ctrl |=  E1000_CTRL_LANPHYPC_OVERRIDE;
 		ctrl &= ~E1000_CTRL_LANPHYPC_VALUE;
@@ -309,6 +311,13 @@ static s32 e1000_init_phy_params_pchlan(struct e1000_hw *hw)
 		ctrl &= ~E1000_CTRL_LANPHYPC_OVERRIDE;
 		ew32(CTRL, ctrl);
 		msleep(50);
+
+		/*
+		 * Gate automatic PHY configuration by hardware on
+		 * non-managed 82579
+		 */
+		if (hw->mac.type == e1000_pch2lan)
+			e1000_gate_hw_phy_config_ich8lan(hw, true);
 	}
 
 	/*
@@ -321,6 +330,13 @@ static s32 e1000_init_phy_params_pchlan(struct e1000_hw *hw)
 	if (ret_val)
 		goto out;
 
+	/* Ungate automatic PHY configuration on non-managed 82579 */
+	if ((hw->mac.type == e1000_pch2lan)  &&
+	    !(fwsm & E1000_ICH_FWSM_FW_VALID)) {
+		msleep(10);
+		e1000_gate_hw_phy_config_ich8lan(hw, false);
+	}
+
 	phy->id = e1000_phy_unknown;
 	ret_val = e1000e_get_phy_id(hw);
 	if (ret_val)
@@ -567,13 +583,10 @@ static s32 e1000_init_mac_params_ich8lan(struct e1000_adapter *adapter)
 	if (mac->type == e1000_ich8lan)
 		e1000e_set_kmrn_lock_loss_workaround_ich8lan(hw, true);
 
-	/* Disable PHY configuration by hardware, config by software */
-	if (mac->type == e1000_pch2lan) {
-		u32 extcnf_ctrl = er32(EXTCNF_CTRL);
-
-		extcnf_ctrl |= E1000_EXTCNF_CTRL_GATE_PHY_CFG;
-		ew32(EXTCNF_CTRL, extcnf_ctrl);
-	}
+	/* Gate automatic PHY configuration by hardware on managed 82579 */
+	if ((mac->type == e1000_pch2lan) &&
+	    (er32(FWSM) & E1000_ICH_FWSM_FW_VALID))
+		e1000_gate_hw_phy_config_ich8lan(hw, true);
 
 	return 0;
 }
@@ -1621,6 +1634,32 @@ out:
 }
 
 /**
+ *  e1000_gate_hw_phy_config_ich8lan - disable PHY config via hardware
+ *  @hw:   pointer to the HW structure
+ *  @gate: boolean set to true to gate, false to ungate
+ *
+ *  Gate/ungate the automatic PHY configuration via hardware; perform
+ *  the configuration via software instead.
+ **/
+static void e1000_gate_hw_phy_config_ich8lan(struct e1000_hw *hw, bool gate)
+{
+	u32 extcnf_ctrl;
+
+	if (hw->mac.type != e1000_pch2lan)
+		return;
+
+	extcnf_ctrl = er32(EXTCNF_CTRL);
+
+	if (gate)
+		extcnf_ctrl |= E1000_EXTCNF_CTRL_GATE_PHY_CFG;
+	else
+		extcnf_ctrl &= ~E1000_EXTCNF_CTRL_GATE_PHY_CFG;
+
+	ew32(EXTCNF_CTRL, extcnf_ctrl);
+	return;
+}
+
+/**
  *  e1000_lan_init_done_ich8lan - Check for PHY config completion
  *  @hw: pointer to the HW structure
  *
@@ -1695,6 +1734,13 @@ static s32 e1000_post_phy_reset_ich8lan(struct e1000_hw *hw)
 	/* Configure the LCD with the OEM bits in NVM */
 	ret_val = e1000_oem_bits_config_ich8lan(hw, true);
 
+	/* Ungate automatic PHY configuration on non-managed 82579 */
+	if ((hw->mac.type == e1000_pch2lan) &&
+	    !(er32(FWSM) & E1000_ICH_FWSM_FW_VALID)) {
+		msleep(10);
+		e1000_gate_hw_phy_config_ich8lan(hw, false);
+	}
+
 out:
 	return ret_val;
 }
@@ -1711,6 +1757,11 @@ static s32 e1000_phy_hw_reset_ich8lan(struct e1000_hw *hw)
 {
 	s32 ret_val = 0;
 
+	/* Gate automatic PHY configuration by hardware on non-managed 82579 */
+	if ((hw->mac.type == e1000_pch2lan) &&
+	    !(er32(FWSM) & E1000_ICH_FWSM_FW_VALID))
+		e1000_gate_hw_phy_config_ich8lan(hw, true);
+
 	ret_val = e1000e_phy_hw_reset_generic(hw);
 	if (ret_val)
 		goto out;
@@ -2975,6 +3026,14 @@ static s32 e1000_reset_hw_ich8lan(struct e1000_hw *hw)
 		 * external PHY is reset.
 		 */
 		ctrl |= E1000_CTRL_PHY_RST;
+
+		/*
+		 * Gate automatic PHY configuration by hardware on
+		 * non-managed 82579
+		 */
+		if ((hw->mac.type == e1000_pch2lan) &&
+		    !(er32(FWSM) & E1000_ICH_FWSM_FW_VALID))
+			e1000_gate_hw_phy_config_ich8lan(hw, true);
 	}
 	ret_val = e1000_acquire_swflag_ich8lan(hw);
 	e_dbg("Issuing a global reset to ich8lan\n");

