From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 3/6] e1000: convert regtest macro's to functions
Date: Tue, 13 Nov 2007 15:11:23 -0800
Message-ID: <20071113231123.13177.75051.stgit@localhost.localdomain>
References: <20071113231110.13177.27339.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com
To: davem@davemloft.net, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:18197 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755779AbXKMXNL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2007 18:13:11 -0500
In-Reply-To: <20071113231110.13177.27339.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Minimal macro to function conversion in e1000_ethtool.c

Adds functions reg_pattern_test and reg_set_and_check
Changes REG_PATTERN_TEST and REG_SET_AND_CHECK macros
to call these functions.

Saves ~2.5KB

Compiled x86, untested (no hardware)

old:

$ size drivers/net/e1000/e1000_ethtool.o
   text    data     bss     dec     hex filename
  16778       0       0   16778    418a drivers/net/e1000/e1000_ethtool.o

new:

$ size drivers/net/e1000/e1000_ethtool.o
   text    data     bss     dec     hex filename
  14128       0       0   14128    3730 drivers/net/e1000/e1000_ethtool.o

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_ethtool.c |   84 ++++++++++++++++++++++++-------------
 1 files changed, 55 insertions(+), 29 deletions(-)

diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index 667f18b..ec67ea9 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -728,39 +728,65 @@ err_setup:
 	return err;
 }
 
-#define REG_PATTERN_TEST(R, M, W)                                              \
-{                                                                              \
-	uint32_t pat, val;                                                     \
-	const uint32_t test[] = 					       \
-		{0x5A5A5A5A, 0xA5A5A5A5, 0x00000000, 0xFFFFFFFF};              \
-	for (pat = 0; pat < ARRAY_SIZE(test); pat++) {           	       \
-		E1000_WRITE_REG(&adapter->hw, R, (test[pat] & W));             \
-		val = E1000_READ_REG(&adapter->hw, R);                         \
-		if (val != (test[pat] & W & M)) {                              \
-			DPRINTK(DRV, ERR, "pattern test reg %04X failed: got " \
-			        "0x%08X expected 0x%08X\n",                    \
-			        E1000_##R, val, (test[pat] & W & M));          \
-			*data = (adapter->hw.mac_type < e1000_82543) ?         \
-				E1000_82542_##R : E1000_##R;                   \
-			return 1;                                              \
-		}                                                              \
-	}                                                                      \
+static bool reg_pattern_test(struct e1000_adapter *adapter, uint64_t *data,
+			     int reg, uint32_t mask, uint32_t write)
+{
+	static const uint32_t test[] =
+		{0x5A5A5A5A, 0xA5A5A5A5, 0x00000000, 0xFFFFFFFF};
+	uint8_t __iomem *address = adapter->hw.hw_addr + reg;
+	uint32_t read;
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(test); i++) {
+		writel(write & test[i], address);
+		read = readl(address);
+		if (read != (write & test[i] & mask)) {
+			DPRINTK(DRV, ERR, "pattern test reg %04X failed: "
+				"got 0x%08X expected 0x%08X\n",
+			        reg, read, (write & test[i] & mask));
+			*data = reg;
+			return true;
+		}
+	}
+	return false;
 }
 
-#define REG_SET_AND_CHECK(R, M, W)                                             \
-{                                                                              \
-	uint32_t val;                                                          \
-	E1000_WRITE_REG(&adapter->hw, R, W & M);                               \
-	val = E1000_READ_REG(&adapter->hw, R);                                 \
-	if ((W & M) != (val & M)) {                                            \
-		DPRINTK(DRV, ERR, "set/check reg %04X test failed: got 0x%08X "\
-		        "expected 0x%08X\n", E1000_##R, (val & M), (W & M));   \
-		*data = (adapter->hw.mac_type < e1000_82543) ?                 \
-			E1000_82542_##R : E1000_##R;                           \
-		return 1;                                                      \
-	}                                                                      \
+static bool reg_set_and_check(struct e1000_adapter *adapter, uint64_t *data,
+			      int reg, uint32_t mask, uint32_t write)
+{
+	uint8_t __iomem *address = adapter->hw.hw_addr + reg;
+	uint32_t read;
+
+	writel(write & mask, address);
+	read = readl(address);
+	if ((read & mask) != (write & mask)) {
+		DPRINTK(DRV, ERR, "set/check reg %04X test failed: "
+			"got 0x%08X expected 0x%08X\n",
+			reg, (read & mask), (write & mask));
+		*data = reg;
+		return true;
+	}
+	return false;
 }
 
+#define REG_PATTERN_TEST(reg, mask, write)			     \
+	do {							     \
+		if (reg_pattern_test(adapter, data,		     \
+			     (adapter->hw.mac_type >= e1000_82543)   \
+			     ? E1000_##reg : E1000_82542_##reg,	     \
+			     mask, write))			     \
+			return 1;				     \
+	} while (0)
+
+#define REG_SET_AND_CHECK(reg, mask, write)			     \
+	do {							     \
+		if (reg_set_and_check(adapter, data,		     \
+			      (adapter->hw.mac_type >= e1000_82543)  \
+			      ? E1000_##reg : E1000_82542_##reg,     \
+			      mask, write))			     \
+			return 1;				     \
+	} while (0)
+
 static int
 e1000_reg_test(struct e1000_adapter *adapter, uint64_t *data)
 {
