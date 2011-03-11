From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 07/11] e1000e: extend EEE LPI timer to prevent dropped link
Date: Fri, 11 Mar 2011 03:06:26 -0800
Message-ID: <1299841590-30676-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299841590-30676-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:59823 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753463Ab1CKLGv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2011 06:06:51 -0500
In-Reply-To: <1299841590-30676-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The link can be unexpectedly dropped when the timer for entering EEE low-
power-idle quiet state expires too soon.  The timer needs to be extended
from 196usec to 200usec after every LCD (PHY) reset to prevent this from
happening.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/ich8lan.c |   29 ++++++++++++++++++++++++-----
 1 files changed, 24 insertions(+), 5 deletions(-)

diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 232b42b..cf18d65 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -140,6 +140,11 @@
 #define I82579_LPI_CTRL			PHY_REG(772, 20)
 #define I82579_LPI_CTRL_ENABLE_MASK	0x6000
 
+/* EMI Registers */
+#define I82579_EMI_ADDR         0x10
+#define I82579_EMI_DATA         0x11
+#define I82579_LPI_UPDATE_TIMER 0x4805	/* in 40ns units + 40 ns base value */
+
 /* Strapping Option Register - RO */
 #define E1000_STRAP                     0x0000C
 #define E1000_STRAP_SMBUS_ADDRESS_MASK  0x00FE0000
@@ -1723,11 +1728,25 @@ static s32 e1000_post_phy_reset_ich8lan(struct e1000_hw *hw)
 	/* Configure the LCD with the OEM bits in NVM */
 	ret_val = e1000_oem_bits_config_ich8lan(hw, true);
 
-	/* Ungate automatic PHY configuration on non-managed 82579 */
-	if ((hw->mac.type == e1000_pch2lan) &&
-	    !(er32(FWSM) & E1000_ICH_FWSM_FW_VALID)) {
-		msleep(10);
-		e1000_gate_hw_phy_config_ich8lan(hw, false);
+	if (hw->mac.type == e1000_pch2lan) {
+		/* Ungate automatic PHY configuration on non-managed 82579 */
+		if (!(er32(FWSM) & E1000_ICH_FWSM_FW_VALID)) {
+			msleep(10);
+			e1000_gate_hw_phy_config_ich8lan(hw, false);
+		}
+
+		/* Set EEE LPI Update Timer to 200usec */
+		ret_val = hw->phy.ops.acquire(hw);
+		if (ret_val)
+			goto out;
+		ret_val = hw->phy.ops.write_reg_locked(hw, I82579_EMI_ADDR,
+						       I82579_LPI_UPDATE_TIMER);
+		if (ret_val)
+			goto release;
+		ret_val = hw->phy.ops.write_reg_locked(hw, I82579_EMI_DATA,
+						       0x1387);
+release:
+		hw->phy.ops.release(hw);
 	}
 
 out:
-- 
1.7.4

