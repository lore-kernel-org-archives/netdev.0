From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/12] e1000e: Clear host wakeup bit on 82577/8 without touching PHY page 800
Date: Wed,  8 Jun 2011 15:56:34 -0700
Message-ID: <1307573800-24868-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1307573800-24868-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:3611 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755011Ab1FHW4r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jun 2011 18:56:47 -0400
In-Reply-To: <1307573800-24868-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The Host Wakeup Active bit in the PHY Port General Configuration register
(page 769 register 17) must be cleared after every PHY reset to prevent an
unexpected wake signal from the PHY. Originally, this was accomplished by
simply reading the PHY Wakeup Control register on page 800 which clears the
Host Wakeup Active bit as a side-effect. Unfortunately, a hardware bug on
the 82577 and 82578 PHY can cause unexpected behavior when registers on
page 800 are accessed while in gigabit mode.

This patch changes the remaining instances when the Host Wakeup Active bit
needs to be cleared while possibly in gigabit mode by accessing the Port
General Configuration register directly instead of accessing any register
on page 800.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/e1000.h   |    1 +
 drivers/net/e1000e/ich8lan.c |   24 +++++++++++++-----------
 2 files changed, 14 insertions(+), 11 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 2c05b4f..c1e7f94 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -104,6 +104,7 @@ struct e1000_info;
 	 (((reg) & ~MAX_PHY_REG_ADDRESS) << (PHY_UPPER_SHIFT - PHY_PAGE_SHIFT)))
 
 /* PHY Wakeup Registers and defines */
+#define BM_PORT_GEN_CFG PHY_REG(BM_PORT_CTRL_PAGE, 17)
 #define BM_RCTL         PHY_REG(BM_WUC_PAGE, 0)
 #define BM_WUC          PHY_REG(BM_WUC_PAGE, 1)
 #define BM_WUFC         PHY_REG(BM_WUC_PAGE, 2)
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 1ede6e0..c175212 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -1391,14 +1391,11 @@ static s32 e1000_hv_phy_workarounds_ich8lan(struct e1000_hw *hw)
 	ret_val = hw->phy.ops.acquire(hw);
 	if (ret_val)
 		goto out;
-	ret_val = hw->phy.ops.read_reg_locked(hw,
-	                                      PHY_REG(BM_PORT_CTRL_PAGE, 17),
-	                                      &phy_data);
+	ret_val = hw->phy.ops.read_reg_locked(hw, BM_PORT_GEN_CFG, &phy_data);
 	if (ret_val)
 		goto release;
-	ret_val = hw->phy.ops.write_reg_locked(hw,
-	                                       PHY_REG(BM_PORT_CTRL_PAGE, 17),
-	                                       phy_data & 0x00FF);
+	ret_val = hw->phy.ops.write_reg_locked(hw, BM_PORT_GEN_CFG,
+					       phy_data & 0x00FF);
 release:
 	hw->phy.ops.release(hw);
 out:
@@ -1760,9 +1757,12 @@ static s32 e1000_post_phy_reset_ich8lan(struct e1000_hw *hw)
 		break;
 	}
 
-	/* Dummy read to clear the phy wakeup bit after lcd reset */
-	if (hw->mac.type >= e1000_pchlan)
-		e1e_rphy(hw, BM_WUC, &reg);
+	/* Clear the host wakeup bit after lcd reset */
+	if (hw->mac.type >= e1000_pchlan) {
+		e1e_rphy(hw, BM_PORT_GEN_CFG, &reg);
+		reg &= ~BM_WUC_HOST_WU_BIT;
+		e1e_wphy(hw, BM_PORT_GEN_CFG, reg);
+	}
 
 	/* Configure the LCD with the extended configuration region in NVM */
 	ret_val = e1000_sw_lcd_config_ich8lan(hw);
@@ -3161,11 +3161,13 @@ static s32 e1000_init_hw_ich8lan(struct e1000_hw *hw)
 
 	/*
 	 * The 82578 Rx buffer will stall if wakeup is enabled in host and
-	 * the ME.  Reading the BM_WUC register will clear the host wakeup bit.
+	 * the ME.  Disable wakeup by clearing the host wakeup bit.
 	 * Reset the phy after disabling host wakeup to reset the Rx buffer.
 	 */
 	if (hw->phy.type == e1000_phy_82578) {
-		e1e_rphy(hw, BM_WUC, &i);
+		e1e_rphy(hw, BM_PORT_GEN_CFG, &i);
+		i &= ~BM_WUC_HOST_WU_BIT;
+		e1e_wphy(hw, BM_PORT_GEN_CFG, i);
 		ret_val = e1000_phy_hw_reset_ich8lan(hw);
 		if (ret_val)
 			return ret_val;
-- 
1.7.5.2

