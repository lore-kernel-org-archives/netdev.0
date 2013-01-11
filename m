From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/15] e1000e: 82577: workaround for link drop issue
Date: Fri, 11 Jan 2013 02:23:41 -0800
Message-ID: <1357899831-4168-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1357899831-4168-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:8893 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753556Ab3AKKYA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jan 2013 05:24:00 -0500
In-Reply-To: <1357899831-4168-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

When connected to certain switches, the 82577 PHY might drop link
unexpectedly.  Work around the issue by setting the Mean Square Error
higher than the hardware default.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 8004d71..a7d6c87 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -157,7 +157,8 @@
 #define I82579_EMI_ADDR         0x10
 #define I82579_EMI_DATA         0x11
 #define I82579_LPI_UPDATE_TIMER 0x4805	/* in 40ns units + 40 ns base value */
-#define I82579_MSE_THRESHOLD    0x084F	/* Mean Square Error Threshold */
+#define I82579_MSE_THRESHOLD    0x084F	/* 82579 Mean Square Error Threshold */
+#define I82577_MSE_THRESHOLD    0x0887	/* 82577 Mean Square Error Threshold */
 #define I82579_MSE_LINK_DOWN    0x2411	/* MSE count before dropping link */
 #define I217_EEE_ADVERTISEMENT  0x8001	/* IEEE MMD Register 7.60 */
 #define I217_EEE_LP_ABILITY     0x8002	/* IEEE MMD Register 7.61 */
@@ -1809,6 +1810,11 @@ static s32 e1000_hv_phy_workarounds_ich8lan(struct e1000_hw *hw)
 	if (ret_val)
 		goto release;
 	ret_val = e1e_wphy_locked(hw, BM_PORT_GEN_CFG, phy_data & 0x00FF);
+	if (ret_val)
+		goto release;
+
+	/* set MSE higher to enable link to stay up when noise is high */
+	ret_val = e1000_write_emi_reg_locked(hw, I82577_MSE_THRESHOLD, 0x0034);
 release:
 	hw->phy.ops.release(hw);
 
-- 
1.7.11.7
