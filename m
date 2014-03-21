From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/16] ixgbevf: Make the ethtool register test use accessors
Date: Fri, 21 Mar 2014 05:09:57 -0700
Message-ID: <1395403806-29302-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1395403806-29302-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:20076 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965459AbaCUMKN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Mar 2014 08:10:13 -0400
In-Reply-To: <1395403806-29302-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Make the ethtool register test use the normal register accessor
functions. Also eliminate macros used for calling register test
functions to make error exits clearer.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ethtool.c | 119 +++++++++++++++------------
 1 file changed, 67 insertions(+), 52 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ethtool.c b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
index f68b78c..c769a8d 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 82599 Virtual Function driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2014 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -530,41 +530,47 @@ static const u32 register_test_patterns[] = {
 	0x5A5A5A5A, 0xA5A5A5A5, 0x00000000, 0xFFFFFFFF
 };
 
-#define REG_PATTERN_TEST(R, M, W)                                             \
-{                                                                             \
-	u32 pat, val, before;                                                 \
-	for (pat = 0; pat < ARRAY_SIZE(register_test_patterns); pat++) {      \
-		before = readl(adapter->hw.hw_addr + R);                      \
-		writel((register_test_patterns[pat] & W),                     \
-		       (adapter->hw.hw_addr + R));                            \
-		val = readl(adapter->hw.hw_addr + R);                         \
-		if (val != (register_test_patterns[pat] & W & M)) {           \
-			hw_dbg(&adapter->hw,                                  \
-			"pattern test reg %04X failed: got "                  \
-			"0x%08X expected 0x%08X\n",                           \
-			R, val, (register_test_patterns[pat] & W & M));       \
-			*data = R;                                            \
-			writel(before, adapter->hw.hw_addr + R);              \
-			return 1;                                             \
-		}                                                             \
-		writel(before, adapter->hw.hw_addr + R);                      \
-	}                                                                     \
+static bool reg_pattern_test(struct ixgbevf_adapter *adapter, u64 *data,
+			     int reg, u32 mask, u32 write)
+{
+	u32 pat, val, before;
+
+	for (pat = 0; pat < ARRAY_SIZE(register_test_patterns); pat++) {
+		before = ixgbe_read_reg(&adapter->hw, reg);
+		ixgbe_write_reg(&adapter->hw, reg,
+				register_test_patterns[pat] & write);
+		val = ixgbe_read_reg(&adapter->hw, reg);
+		if (val != (register_test_patterns[pat] & write & mask)) {
+			hw_dbg(&adapter->hw,
+			       "pattern test reg %04X failed: got 0x%08X expected 0x%08X\n",
+			       reg, val,
+			       register_test_patterns[pat] & write & mask);
+			*data = reg;
+			ixgbe_write_reg(&adapter->hw, reg, before);
+			return true;
+		}
+		ixgbe_write_reg(&adapter->hw, reg, before);
+	}
+	return false;
 }
 
-#define REG_SET_AND_CHECK(R, M, W)                                            \
-{                                                                             \
-	u32 val, before;                                                      \
-	before = readl(adapter->hw.hw_addr + R);                              \
-	writel((W & M), (adapter->hw.hw_addr + R));                           \
-	val = readl(adapter->hw.hw_addr + R);                                 \
-	if ((W & M) != (val & M)) {                                           \
-		pr_err("set/check reg %04X test failed: got 0x%08X expected " \
-		       "0x%08X\n", R, (val & M), (W & M));                    \
-		*data = R;                                                    \
-		writel(before, (adapter->hw.hw_addr + R));                    \
-		return 1;                                                     \
-	}                                                                     \
-	writel(before, (adapter->hw.hw_addr + R));                            \
+static bool reg_set_and_check(struct ixgbevf_adapter *adapter, u64 *data,
+			      int reg, u32 mask, u32 write)
+{
+	u32 val, before;
+
+	before = ixgbe_read_reg(&adapter->hw, reg);
+	ixgbe_write_reg(&adapter->hw, reg, write & mask);
+	val = ixgbe_read_reg(&adapter->hw, reg);
+	if ((write & mask) != (val & mask)) {
+		pr_err("set/check reg %04X test failed: got 0x%08X expected 0x%08X\n",
+		       reg, (val & mask), write & mask);
+		*data = reg;
+		ixgbe_write_reg(&adapter->hw, reg, before);
+		return true;
+	}
+	ixgbe_write_reg(&adapter->hw, reg, before);
+	return false;
 }
 
 static int ixgbevf_reg_test(struct ixgbevf_adapter *adapter, u64 *data)
@@ -580,38 +586,47 @@ static int ixgbevf_reg_test(struct ixgbevf_adapter *adapter, u64 *data)
 	 */
 	while (test->reg) {
 		for (i = 0; i < test->array_len; i++) {
+			bool b = false;
+
 			switch (test->test_type) {
 			case PATTERN_TEST:
-				REG_PATTERN_TEST(test->reg + (i * 0x40),
-						test->mask,
-						test->write);
+				b = reg_pattern_test(adapter, data,
+						     test->reg + (i * 0x40),
+						     test->mask,
+						     test->write);
 				break;
 			case SET_READ_TEST:
-				REG_SET_AND_CHECK(test->reg + (i * 0x40),
-						test->mask,
-						test->write);
+				b = reg_set_and_check(adapter, data,
+						      test->reg + (i * 0x40),
+						      test->mask,
+						      test->write);
 				break;
 			case WRITE_NO_TEST:
-				writel(test->write,
-				       (adapter->hw.hw_addr + test->reg)
-				       + (i * 0x40));
+				ixgbe_write_reg(&adapter->hw,
+						  test->reg + (i * 0x40),
+						  test->write);
 				break;
 			case TABLE32_TEST:
-				REG_PATTERN_TEST(test->reg + (i * 4),
-						test->mask,
-						test->write);
+				b = reg_pattern_test(adapter, data,
+						     test->reg + (i * 4),
+						     test->mask,
+						     test->write);
 				break;
 			case TABLE64_TEST_LO:
-				REG_PATTERN_TEST(test->reg + (i * 8),
-						test->mask,
-						test->write);
+				b = reg_pattern_test(adapter, data,
+						     test->reg + (i * 8),
+						     test->mask,
+						     test->write);
 				break;
 			case TABLE64_TEST_HI:
-				REG_PATTERN_TEST((test->reg + 4) + (i * 8),
-						test->mask,
-						test->write);
+				b = reg_pattern_test(adapter, data,
+						     test->reg + 4 + (i * 8),
+						     test->mask,
+						     test->write);
 				break;
 			}
+			if (b)
+				return 1;
 		}
 		test++;
 	}
-- 
1.8.3.1
