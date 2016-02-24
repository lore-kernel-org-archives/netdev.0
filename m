From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/20] e1000e: Increase PHY PLL clock gate timing
Date: Tue, 23 Feb 2016 20:26:06 -0800
Message-ID: <1456287984-10459-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1456287984-10459-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Raanan Avargil <raanan.avargil@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:51525 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757336AbcBXE03 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2016 23:26:29 -0500
In-Reply-To: <1456287984-10459-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raanan Avargil <raanan.avargil@intel.com>

Several packet loss issues were reported for which the root cause for
them was an incorrect configuration of internal HW PHY clock gating
mechanism by SW.
This patch provides the correct mechanism.

Signed-off-by: Raanan Avargil <raanan.avargil@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c | 12 ++++++++++++
 drivers/net/ethernet/intel/e1000e/ich8lan.h |  3 +++
 2 files changed, 15 insertions(+)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index c731465..786d214 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -1433,6 +1433,18 @@ static s32 e1000_check_for_copper_link_ich8lan(struct e1000_hw *hw)
 			emi_addr = I217_RX_CONFIG;
 		ret_val = e1000_write_emi_reg_locked(hw, emi_addr, emi_val);
 
+		if (hw->mac.type == e1000_pch_lpt ||
+		    hw->mac.type == e1000_pch_spt) {
+			u16 phy_reg;
+
+			e1e_rphy_locked(hw, I217_PLL_CLOCK_GATE_REG, &phy_reg);
+			phy_reg &= ~I217_PLL_CLOCK_GATE_MASK;
+			if (speed == SPEED_100 || speed == SPEED_10)
+				phy_reg |= 0x3E8;
+			else
+				phy_reg |= 0xFA;
+			e1e_wphy_locked(hw, I217_PLL_CLOCK_GATE_REG, phy_reg);
+		}
 		hw->phy.ops.release(hw);
 
 		if (ret_val)
diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.h b/drivers/net/ethernet/intel/e1000e/ich8lan.h
index 34c551e..7d85f00 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.h
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.h
@@ -226,6 +226,9 @@
 #define HV_PM_CTRL_PLL_STOP_IN_K1_GIGA	0x100
 #define HV_PM_CTRL_K1_ENABLE		0x4000
 
+#define I217_PLL_CLOCK_GATE_REG	PHY_REG(772, 28)
+#define I217_PLL_CLOCK_GATE_MASK	0x07FF
+
 #define SW_FLAG_TIMEOUT		1000	/* SW Semaphore flag timeout in ms */
 
 /* Inband Control */
-- 
2.5.0
