From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/12] e1000e: 82579: workaround for link drop issue
Date: Wed, 25 Jan 2012 23:21:52 -0800
Message-ID: <1327562515-29664-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1327562515-29664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:54466 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751660Ab2AZHWC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jan 2012 02:22:02 -0500
In-Reply-To: <1327562515-29664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

When connected to certain switches, the 82579 PHY might drop link
unexpectedly.  Work around the issue by setting the Mean Square Error
higher than the hardware default.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c |   22 ++++++++++++++++++++++
 1 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index e2a80a2..1b69c2d 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -145,6 +145,8 @@
 #define I82579_EMI_ADDR         0x10
 #define I82579_EMI_DATA         0x11
 #define I82579_LPI_UPDATE_TIMER 0x4805	/* in 40ns units + 40 ns base value */
+#define I82579_MSE_THRESHOLD    0x084F	/* Mean Square Error Threshold */
+#define I82579_MSE_LINK_DOWN    0x2411	/* MSE count before dropping link */
 
 /* Strapping Option Register - RO */
 #define E1000_STRAP                     0x0000C
@@ -1669,6 +1671,26 @@ static s32 e1000_lv_phy_workarounds_ich8lan(struct e1000_hw *hw)
 	/* Set MDIO slow mode before any other MDIO access */
 	ret_val = e1000_set_mdio_slow_mode_hv(hw);
 
+	ret_val = hw->phy.ops.acquire(hw);
+	if (ret_val)
+		goto out;
+	ret_val = hw->phy.ops.write_reg_locked(hw, I82579_EMI_ADDR,
+					       I82579_MSE_THRESHOLD);
+	if (ret_val)
+		goto release;
+	/* set MSE higher to enable link to stay up when noise is high */
+	ret_val = hw->phy.ops.write_reg_locked(hw, I82579_EMI_DATA, 0x0034);
+	if (ret_val)
+		goto release;
+	ret_val = hw->phy.ops.write_reg_locked(hw, I82579_EMI_ADDR,
+					       I82579_MSE_LINK_DOWN);
+	if (ret_val)
+		goto release;
+	/* drop link after 5 times MSE threshold was reached */
+	ret_val = hw->phy.ops.write_reg_locked(hw, I82579_EMI_DATA, 0x0005);
+release:
+	hw->phy.ops.release(hw);
+
 out:
 	return ret_val;
 }
-- 
1.7.7.6
