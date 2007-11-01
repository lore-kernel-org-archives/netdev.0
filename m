From: Joe Perches <joe@perches.com>
Subject: [PATCH] - e1000_ethtool.c - convert macros to functions
Date: Thu, 01 Nov 2007 14:16:53 -0700
Message-ID: <1193951813.17956.3.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, e1000-devel@lists.sourceforge.net,
	Jeff Garzik <jgarzik@pobox.com>
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:4030 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753316AbXKAVRB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Nov 2007 17:17:01 -0400
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

---

 drivers/net/e1000/e1000_ethtool.c |   80 +++++++++++++++++++++++-------------
 1 files changed, 51 insertions(+), 29 deletions(-)

diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index 667f18b..830f0fb 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -728,39 +728,61 @@ err_setup:
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
+	if (reg_pattern_test(adapter, data,			     \
+			     (adapter->hw.mac_type >= e1000_82543)   \
+			     ? E1000_##reg : E1000_82542_##reg,	     \
+			     mask, write))			     \
+		return 1;
+
+#define REG_SET_AND_CHECK(reg, mask, write)			     \
+	if (reg_set_and_check(adapter, data,			     \
+			      (adapter->hw.mac_type >= e1000_82543)  \
+			      ? E1000_##reg : E1000_82542_##reg,     \
+			      mask, write))			     \
+		return 1;
+
 static int
 e1000_reg_test(struct e1000_adapter *adapter, uint64_t *data)
 {


