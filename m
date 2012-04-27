From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/6] e1000e: 82579 packet drop workaround
Date: Fri, 27 Apr 2012 02:36:50 -0700
Message-ID: <1335519413-1892-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1335519413-1892-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:58063 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759926Ab2D0Jg4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2012 05:36:56 -0400
In-Reply-To: <1335519413-1892-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

In K1 mode (a MAC/PHY interconnect power mode), the 82579 device shuts down
the Phase Lock Loop (PLL) of the interconnect to save power.  When the PLL
starts working, the 82579 device may start to transfer the packet through
the interconnect before it is fully functional causing packet drops.  This
workaround disables shutting down the PLL in K1 mode for 1G link speed.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 14af3e2..d7fd1e8 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -135,6 +135,7 @@
 
 /* PHY Power Management Control */
 #define HV_PM_CTRL		PHY_REG(770, 17)
+#define HV_PM_CTRL_PLL_STOP_IN_K1_GIGA	0x100
 
 /* PHY Low Power Idle Control */
 #define I82579_LPI_CTRL				PHY_REG(772, 20)
@@ -1708,8 +1709,18 @@ static s32 e1000_k1_workaround_lv(struct e1000_hw *hw)
 			return ret_val;
 
 		if (status_reg & HV_M_STATUS_SPEED_1000) {
+			u16 pm_phy_reg;
+
 			mac_reg |= E1000_FEXTNVM4_BEACON_DURATION_8USEC;
 			phy_reg &= ~I82579_LPI_CTRL_FORCE_PLL_LOCK_COUNT;
+			/* LV 1G Packet drop issue wa  */
+			ret_val = e1e_rphy(hw, HV_PM_CTRL, &pm_phy_reg);
+			if (ret_val)
+				return ret_val;
+			pm_phy_reg &= ~HV_PM_CTRL_PLL_STOP_IN_K1_GIGA;
+			ret_val = e1e_wphy(hw, HV_PM_CTRL, pm_phy_reg);
+			if (ret_val)
+				return ret_val;
 		} else {
 			mac_reg |= E1000_FEXTNVM4_BEACON_DURATION_16USEC;
 			phy_reg |= I82579_LPI_CTRL_FORCE_PLL_LOCK_COUNT;
-- 
1.7.7.6
