From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 3/4] e1000e: workaround for packet drop on 82579 at 100Mbps
Date: Sat, 13 Aug 2011 02:23:39 -0700
Message-ID: <1313227420-9974-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1313227420-9974-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:12891 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751008Ab1HMJXo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Aug 2011 05:23:44 -0400
In-Reply-To: <1313227420-9974-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The MAC can drop short packets when the PHY detects noise on the line at
100Mbps due to a timing issue.  Workaround the issue by increasing the PLL
counter so the PHY properly recognizes the synchronization pattern from the
MAC.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/ich8lan.c |   19 ++++++++++++++-----
 1 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 7525e37..46a5277 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -137,8 +137,9 @@
 #define HV_PM_CTRL		PHY_REG(770, 17)
 
 /* PHY Low Power Idle Control */
-#define I82579_LPI_CTRL			PHY_REG(772, 20)
-#define I82579_LPI_CTRL_ENABLE_MASK	0x6000
+#define I82579_LPI_CTRL				PHY_REG(772, 20)
+#define I82579_LPI_CTRL_ENABLE_MASK		0x6000
+#define I82579_LPI_CTRL_FORCE_PLL_LOCK_COUNT	0x80
 
 /* EMI Registers */
 #define I82579_EMI_ADDR         0x10
@@ -1670,6 +1671,7 @@ static s32 e1000_k1_workaround_lv(struct e1000_hw *hw)
 	s32 ret_val = 0;
 	u16 status_reg = 0;
 	u32 mac_reg;
+	u16 phy_reg;
 
 	if (hw->mac.type != e1000_pch2lan)
 		goto out;
@@ -1684,12 +1686,19 @@ static s32 e1000_k1_workaround_lv(struct e1000_hw *hw)
 		mac_reg = er32(FEXTNVM4);
 		mac_reg &= ~E1000_FEXTNVM4_BEACON_DURATION_MASK;
 
-		if (status_reg & HV_M_STATUS_SPEED_1000)
+		ret_val = e1e_rphy(hw, I82579_LPI_CTRL, &phy_reg);
+		if (ret_val)
+			goto out;
+
+		if (status_reg & HV_M_STATUS_SPEED_1000) {
 			mac_reg |= E1000_FEXTNVM4_BEACON_DURATION_8USEC;
-		else
+			phy_reg &= ~I82579_LPI_CTRL_FORCE_PLL_LOCK_COUNT;
+		} else {
 			mac_reg |= E1000_FEXTNVM4_BEACON_DURATION_16USEC;
-
+			phy_reg |= I82579_LPI_CTRL_FORCE_PLL_LOCK_COUNT;
+		}
 		ew32(FEXTNVM4, mac_reg);
+		ret_val = e1e_wphy(hw, I82579_LPI_CTRL, phy_reg);
 	}
 
 out:
-- 
1.7.6

