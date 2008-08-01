From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 4/8] igb: fix 82576 register translation
Date: Fri, 01 Aug 2008 16:11:25 -0700
Message-ID: <20080801231125.393.55373.stgit@localhost.localdomain>
References: <20080801231106.393.46174.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:31360 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751913AbYHAXL1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Aug 2008 19:11:27 -0400
In-Reply-To: <20080801231106.393.46174.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The previous patchset that added 82576 support did not add full support for
the 82576 nics and left several registers not correctly translated

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_hw.h    |    2 ++
 drivers/net/igb/e1000_regs.h  |   10 +++++-----
 drivers/net/igb/igb_ethtool.c |    9 ++++++---
 3 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/drivers/net/igb/e1000_hw.h b/drivers/net/igb/e1000_hw.h
index 19fa4ee..aca3b11 100644
--- a/drivers/net/igb/e1000_hw.h
+++ b/drivers/net/igb/e1000_hw.h
@@ -592,6 +592,8 @@ struct e1000_hw {
 	u8  revision_id;
 };
 
+#include "e1000_82575.h"
+
 #ifdef DEBUG
 extern char *igb_get_hw_dev_name(struct e1000_hw *hw);
 #define hw_dbg(format, arg...) \
diff --git a/drivers/net/igb/e1000_regs.h b/drivers/net/igb/e1000_regs.h
index b95093d..34f11b4 100644
--- a/drivers/net/igb/e1000_regs.h
+++ b/drivers/net/igb/e1000_regs.h
@@ -263,15 +263,15 @@
 #define E1000_RSSRK(_i) (0x05C80 + ((_i) * 4)) /* RSS Random Key - RW Array */
 
 #define E1000_REGISTER(a, reg) (((a)->mac.type < e1000_82576) \
-                               ? reg : e1000_translate_register_82576(reg))
+                               ? reg : igb_translate_register_82576(reg))
 
-#define wr32(reg, value) (writel(value, hw->hw_addr + reg))
-#define rd32(reg) (readl(hw->hw_addr + reg))
+#define wr32(reg, value) (writel(value, hw->hw_addr + E1000_REGISTER(hw, reg)))
+#define rd32(reg) (readl(hw->hw_addr + E1000_REGISTER(hw, reg)))
 #define wrfl() ((void)rd32(E1000_STATUS))
 
 #define array_wr32(reg, offset, value) \
-	(writel(value, hw->hw_addr + reg + ((offset) << 2)))
+	(writel(value, hw->hw_addr + E1000_REGISTER(hw, reg) + ((offset) << 2)))
 #define array_rd32(reg, offset) \
-	(readl(hw->hw_addr + reg + ((offset) << 2)))
+	(readl(hw->hw_addr + E1000_REGISTER(hw, reg) + ((offset) << 2)))
 
 #endif
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index 11aee13..1eeab4f 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -928,6 +928,7 @@ static struct igb_reg_test reg_test_82575[] = {
 static bool reg_pattern_test(struct igb_adapter *adapter, u64 *data,
 			     int reg, u32 mask, u32 write)
 {
+	struct e1000_hw *hw = &adapter->hw;
 	u32 pat, val;
 	u32 _test[] =
 		{0x5A5A5A5A, 0xA5A5A5A5, 0x00000000, 0xFFFFFFFF};
@@ -937,8 +938,9 @@ static bool reg_pattern_test(struct igb_adapter *adapter, u64 *data,
 		if (val != (_test[pat] & write & mask)) {
 			dev_err(&adapter->pdev->dev, "pattern test reg %04X "
 				"failed: got 0x%08X expected 0x%08X\n",
-				reg, val, (_test[pat] & write & mask));
-			*data = reg;
+				E1000_REGISTER(hw, reg), val,
+				(_test[pat] & write & mask));
+			*data = E1000_REGISTER(hw, reg);
 			return 1;
 		}
 	}
@@ -948,6 +950,7 @@ static bool reg_pattern_test(struct igb_adapter *adapter, u64 *data,
 static bool reg_set_and_check(struct igb_adapter *adapter, u64 *data,
 			      int reg, u32 mask, u32 write)
 {
+	struct e1000_hw *hw = &adapter->hw;
 	u32 val;
 	writel((write & mask), (adapter->hw.hw_addr + reg));
 	val = readl(adapter->hw.hw_addr + reg);
@@ -955,7 +958,7 @@ static bool reg_set_and_check(struct igb_adapter *adapter, u64 *data,
 		dev_err(&adapter->pdev->dev, "set/check reg %04X test failed:"
 			" got 0x%08X expected 0x%08X\n", reg,
 			(val & mask), (write & mask));
-		*data = reg;
+		*data = E1000_REGISTER(hw, reg);
 		return 1;
 	}
 	return 0;

