From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 7/9] ixgbe: fix sparse warning
Date: Wed,  4 May 2011 12:30:39 -0700
Message-ID: <1304537441-2056-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1304537441-2056-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:65291 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755336Ab1EDTat (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2011 15:30:49 -0400
In-Reply-To: <1304537441-2056-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

warning: symbol 'before' shadows an earlier one

Convert large macros to functions similar to e1000e.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Acked-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Evan Swanson <evan.swanson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_ethtool.c |  108 +++++++++++++++++++++----------------
 1 files changed, 62 insertions(+), 46 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index bcba057..410c298 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -1236,46 +1236,62 @@ static const struct ixgbe_reg_test reg_test_82598[] = {
 	{ 0, 0, 0, 0 }
 };
 
-static const u32 register_test_patterns[] = {
-	0x5A5A5A5A, 0xA5A5A5A5, 0x00000000, 0xFFFFFFFF
-};
-
-#define REG_PATTERN_TEST(R, M, W)                                             \
-{                                                                             \
-	u32 pat, val, before;                                                 \
-	for (pat = 0; pat < ARRAY_SIZE(register_test_patterns); pat++) {      \
-		before = readl(adapter->hw.hw_addr + R);                      \
-		writel((register_test_patterns[pat] & W),                     \
-		       (adapter->hw.hw_addr + R));                            \
-		val = readl(adapter->hw.hw_addr + R);                         \
-		if (val != (register_test_patterns[pat] & W & M)) {           \
-			e_err(drv, "pattern test reg %04X failed: got "       \
-			      "0x%08X expected 0x%08X\n",                     \
-			      R, val, (register_test_patterns[pat] & W & M)); \
-			*data = R;                                            \
-			writel(before, adapter->hw.hw_addr + R);              \
-			return 1;                                             \
-		}                                                             \
-		writel(before, adapter->hw.hw_addr + R);                      \
-	}                                                                     \
+static bool reg_pattern_test(struct ixgbe_adapter *adapter, u64 *data, int reg,
+			     u32 mask, u32 write)
+{
+	u32 pat, val, before;
+	static const u32 test_pattern[] = {
+		0x5A5A5A5A, 0xA5A5A5A5, 0x00000000, 0xFFFFFFFF};
+
+	for (pat = 0; pat < ARRAY_SIZE(test_pattern); pat++) {
+		before = readl(adapter->hw.hw_addr + reg);
+		writel((test_pattern[pat] & write),
+		       (adapter->hw.hw_addr + reg));
+		val = readl(adapter->hw.hw_addr + reg);
+		if (val != (test_pattern[pat] & write & mask)) {
+			e_err(drv, "pattern test reg %04X failed: got "
+			      "0x%08X expected 0x%08X\n",
+			      reg, val, (test_pattern[pat] & write & mask));
+			*data = reg;
+			writel(before, adapter->hw.hw_addr + reg);
+			return 1;
+		}
+		writel(before, adapter->hw.hw_addr + reg);
+	}
+	return 0;
 }
 
-#define REG_SET_AND_CHECK(R, M, W)                                            \
-{                                                                             \
-	u32 val, before;                                                      \
-	before = readl(adapter->hw.hw_addr + R);                              \
-	writel((W & M), (adapter->hw.hw_addr + R));                           \
-	val = readl(adapter->hw.hw_addr + R);                                 \
-	if ((W & M) != (val & M)) {                                           \
-		e_err(drv, "set/check reg %04X test failed: got 0x%08X "  \
-		      "expected 0x%08X\n", R, (val & M), (W & M));        \
-		*data = R;                                                    \
-		writel(before, (adapter->hw.hw_addr + R));                    \
-		return 1;                                                     \
-	}                                                                     \
-	writel(before, (adapter->hw.hw_addr + R));                            \
+static bool reg_set_and_check(struct ixgbe_adapter *adapter, u64 *data, int reg,
+			      u32 mask, u32 write)
+{
+	u32 val, before;
+	before = readl(adapter->hw.hw_addr + reg);
+	writel((write & mask), (adapter->hw.hw_addr + reg));
+	val = readl(adapter->hw.hw_addr + reg);
+	if ((write & mask) != (val & mask)) {
+		e_err(drv, "set/check reg %04X test failed: got 0x%08X "
+		      "expected 0x%08X\n", reg, (val & mask), (write & mask));
+		*data = reg;
+		writel(before, (adapter->hw.hw_addr + reg));
+		return 1;
+	}
+	writel(before, (adapter->hw.hw_addr + reg));
+	return 0;
 }
 
+#define REG_PATTERN_TEST(reg, mask, write)				      \
+	do {								      \
+		if (reg_pattern_test(adapter, data, reg, mask, write))	      \
+			return 1;					      \
+	} while (0)							      \
+
+
+#define REG_SET_AND_CHECK(reg, mask, write)				      \
+	do {								      \
+		if (reg_set_and_check(adapter, data, reg, mask, write))	      \
+			return 1;					      \
+	} while (0)							      \
+
 static int ixgbe_reg_test(struct ixgbe_adapter *adapter, u64 *data)
 {
 	const struct ixgbe_reg_test *test;
@@ -1326,13 +1342,13 @@ static int ixgbe_reg_test(struct ixgbe_adapter *adapter, u64 *data)
 			switch (test->test_type) {
 			case PATTERN_TEST:
 				REG_PATTERN_TEST(test->reg + (i * 0x40),
-						test->mask,
-						test->write);
+						 test->mask,
+						 test->write);
 				break;
 			case SET_READ_TEST:
 				REG_SET_AND_CHECK(test->reg + (i * 0x40),
-						test->mask,
-						test->write);
+						  test->mask,
+						  test->write);
 				break;
 			case WRITE_NO_TEST:
 				writel(test->write,
@@ -1341,18 +1357,18 @@ static int ixgbe_reg_test(struct ixgbe_adapter *adapter, u64 *data)
 				break;
 			case TABLE32_TEST:
 				REG_PATTERN_TEST(test->reg + (i * 4),
-						test->mask,
-						test->write);
+						 test->mask,
+						 test->write);
 				break;
 			case TABLE64_TEST_LO:
 				REG_PATTERN_TEST(test->reg + (i * 8),
-						test->mask,
-						test->write);
+						 test->mask,
+						 test->write);
 				break;
 			case TABLE64_TEST_HI:
 				REG_PATTERN_TEST((test->reg + 4) + (i * 8),
-						test->mask,
-						test->write);
+						 test->mask,
+						 test->write);
 				break;
 			}
 		}
-- 
1.7.4.4

