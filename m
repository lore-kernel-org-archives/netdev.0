From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/8] e1000e: cleanup e1000_sw_lcd_config_ich8lan()
Date: Wed, 16 Jun 2010 16:26:17 -0700
Message-ID: <20100616232615.4834.11982.stgit@localhost.localdomain>
References: <20100616232523.4834.84849.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.westchester.pa.mail.comcast.net ([76.96.62.96]:48650
	"EHLO qmta09.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759156Ab0FPX0j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 19:26:39 -0400
In-Reply-To: <20100616232523.4834.84849.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Do not acquire and release the PHY unnecessarily for parts that return
from this workaround without actually accessing the PHY registers.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/ich8lan.c |   32 +++++++++++++++++++-------------
 1 files changed, 19 insertions(+), 13 deletions(-)

diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index b2507d9..5d8fad3 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -820,14 +820,6 @@ static s32 e1000_sw_lcd_config_ich8lan(struct e1000_hw *hw)
 	s32 ret_val = 0;
 	u16 word_addr, reg_data, reg_addr, phy_page = 0;
 
-	if (!(hw->mac.type == e1000_ich8lan && phy->type == e1000_phy_igp_3) &&
-		!(hw->mac.type == e1000_pchlan))
-		return ret_val;
-
-	ret_val = hw->phy.ops.acquire(hw);
-	if (ret_val)
-		return ret_val;
-
 	/*
 	 * Initialize the PHY from the NVM on ICH platforms.  This
 	 * is needed due to an issue where the NVM configuration is
@@ -835,12 +827,26 @@ static s32 e1000_sw_lcd_config_ich8lan(struct e1000_hw *hw)
 	 * Therefore, after each PHY reset, we will load the
 	 * configuration data out of the NVM manually.
 	 */
-	if ((adapter->pdev->device == E1000_DEV_ID_ICH8_IGP_M_AMT) ||
-	    (adapter->pdev->device == E1000_DEV_ID_ICH8_IGP_M) ||
-	    (hw->mac.type == e1000_pchlan))
+	switch (hw->mac.type) {
+	case e1000_ich8lan:
+		if (phy->type != e1000_phy_igp_3)
+			return ret_val;
+
+		if (adapter->pdev->device == E1000_DEV_ID_ICH8_IGP_AMT) {
+			sw_cfg_mask = E1000_FEXTNVM_SW_CONFIG;
+			break;
+		}
+		/* Fall-thru */
+	case e1000_pchlan:
 		sw_cfg_mask = E1000_FEXTNVM_SW_CONFIG_ICH8M;
-	else
-		sw_cfg_mask = E1000_FEXTNVM_SW_CONFIG;
+		break;
+	default:
+		return ret_val;
+	}
+
+	ret_val = hw->phy.ops.acquire(hw);
+	if (ret_val)
+		return ret_val;
 
 	data = er32(FEXTNVM);
 	if (!(data & sw_cfg_mask))

