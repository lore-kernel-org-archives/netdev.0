From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 4/6] e1000e: convert register test macros to functions
Date: Tue, 13 Nov 2007 15:11:28 -0800
Message-ID: <20071113231128.13177.76095.stgit@localhost.localdomain>
References: <20071113231110.13177.27339.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com
To: davem@davemloft.net, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:62489 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760563AbXKMXLo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2007 18:11:44 -0500
In-Reply-To: <20071113231110.13177.27339.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>

Add functions for reg_pattern_test and reg_set_and check
Changed macros to use these functions

Compiled x86, untested

Size decreased ~2K

old:

$ size drivers/net/e1000e/ethtool.o
   text    data     bss     dec     hex filename
  14461       0       0   14461    387d drivers/net/e1000e/ethtool.o

new:

$ size drivers/net/e1000e/ethtool.o
   text    data     bss     dec     hex filename
  12498       0       0   12498    30d2 drivers/net/e1000e/ethtool.o


Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/ethtool.c |   84 +++++++++++++++++++++++++++---------------
 1 files changed, 53 insertions(+), 31 deletions(-)

diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 6a39784..bc1115d 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -691,41 +691,63 @@ err_setup:
 	return err;
 }
 
-#define REG_PATTERN_TEST(R, M, W) REG_PATTERN_TEST_ARRAY(R, 0, M, W)
-#define REG_PATTERN_TEST_ARRAY(reg, offset, mask, writeable)		      \
-{									      \
-	u32 _pat;							      \
-	u32 _value;							      \
-	u32 _test[] = {0x5A5A5A5A, 0xA5A5A5A5, 0x00000000, 0xFFFFFFFF};	      \
-	for (_pat = 0; _pat < ARRAY_SIZE(_test); _pat++) {		      \
-		E1000_WRITE_REG_ARRAY(hw, reg, offset,	      \
-				      (_test[_pat] & writeable));	      \
-		_value = E1000_READ_REG_ARRAY(hw, reg, offset);     \
-		if (_value != (_test[_pat] & writeable & mask)) {	      \
-			ndev_err(netdev, "pattern test reg %04X "             \
-				 "failed: got 0x%08X expected 0x%08X\n",      \
-				 reg + offset,  \
-				 value, (_test[_pat] & writeable & mask));    \
-			*data = reg;					      \
-			return 1;					      \
-		}							      \
-	}								      \
+bool reg_pattern_test_array(struct e1000_adapter *adapter, u64 *data, 
+			    int reg, int offset, u32 mask, u32 write)
+{
+	int i;
+	u32 read;
+	static const u32 test[] = 
+		{0x5A5A5A5A, 0xA5A5A5A5, 0x00000000, 0xFFFFFFFF};
+	for (i = 0; i < ARRAY_SIZE(test); i++) {
+		E1000_WRITE_REG_ARRAY(&adapter->hw, reg, offset,
+				      (test[i] & write));
+		read = E1000_READ_REG_ARRAY(&adapter->hw, reg, offset);
+		if (read != (test[i] & write & mask)) {
+			ndev_err(adapter->netdev, "pattern test reg %04X "
+				 "failed: got 0x%08X expected 0x%08X\n",
+				 reg + offset,
+				 read, (test[i] & write & mask));
+			*data = reg;
+			return true;
+		}
+	}
+	return false;
 }
 
-#define REG_SET_AND_CHECK(R, M, W)					      \
-{									      \
-	u32 _value;							      \
-	__ew32(hw, R, W & M);						\
-	_value = __er32(hw, R);						\
-	if ((W & M) != (_value & M)) {					      \
-		ndev_err(netdev, "set/check reg %04X test failed: "           \
-			 "got 0x%08X expected 0x%08X\n", R, (_value & M),     \
-			 (W & M));					      \
-		*data = R;						      \
-		return 1;						      \
-	}								      \
+static bool reg_set_and_check(struct e1000_adapter *adapter, u64 *data,
+			      int reg, u32 mask, u32 write)
+{
+	u32 read;
+	__ew32(&adapter->hw, reg, write & mask);
+	read = __er32(&adapter->hw, reg);
+	if ((write & mask) != (read & mask)) {
+		ndev_err(adapter->netdev, "set/check reg %04X test failed: "
+			 "got 0x%08X expected 0x%08X\n", reg, (read & mask),
+			 (write & mask));
+		*data = reg;
+		return true;
+	}
+	return false;
 }
 
+#define REG_PATTERN_TEST(R, M, W) \
+	do { \
+		if (reg_pattern_test_array(adapter, data, R, 0, M, W)) \
+			return 1; \
+	} while (0)
+
+#define REG_PATTERN_TEST_ARRAY(R, offset, M, W) \
+	do { \
+		if (reg_pattern_test_array(adapter, data, R, offset, M, W)) \
+			return 1; \
+	} while (0)
+
+#define REG_SET_AND_CHECK(R, M, W) \
+	do { \
+		if (reg_set_and_check(adapter, data, R, M, W)) \
+			return 1; \
+	} while (0)
+
 static int e1000_reg_test(struct e1000_adapter *adapter, u64 *data)
 {
 	struct e1000_hw *hw = &adapter->hw;
