From: Joe Perches <joe@perches.com>
Subject: [PATCH] - e1000_ethtool.c - convert macros to functions
Date: Wed, 31 Oct 2007 14:18:08 -0700
Message-ID: <1193865488.11020.11.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net,
	Auke Kok <auke-jan.h.kok@intel.com>,
	Jeff Garzik <jgarzik@pobox.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:3358 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754673AbXJaVSL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2007 17:18:11 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert REG_PATTERN_TEST and REG_SET_AND_CHECK macros to functions
Reduces x86 defconfig image by about 3k

compiled, untested (no hardware)

Signed-off-by: Joe Perches <joe@perches.com>

New:

$ size vmlinux
   text    data     bss     dec     hex filename
4792735  490626  606208 5889569  59de21 vmlinux

Current:

$ size vmlinux
   text    data     bss     dec     hex filename
4795759  490626  606208 5892593  59e9f1 vmlinux

---

 drivers/net/e1000/e1000_ethtool.c |  185 +++++++++++++++++++++++++------------
 drivers/net/e1000/e1000_osdep.h   |   42 +++++----
 2 files changed, 149 insertions(+), 78 deletions(-)

diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index 667f18b..2627395 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -728,37 +728,45 @@ err_setup:
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
 
 static int
@@ -800,58 +808,115 @@ e1000_reg_test(struct e1000_adapter *adapter, uint64_t *data)
 	E1000_WRITE_REG(&adapter->hw, STATUS, before);
 
 	if (adapter->hw.mac_type != e1000_ich8lan) {
-		REG_PATTERN_TEST(FCAL, 0xFFFFFFFF, 0xFFFFFFFF);
-		REG_PATTERN_TEST(FCAH, 0x0000FFFF, 0xFFFFFFFF);
-		REG_PATTERN_TEST(FCT, 0x0000FFFF, 0xFFFFFFFF);
-		REG_PATTERN_TEST(VET, 0x0000FFFF, 0xFFFFFFFF);
+		if (reg_pattern_test(adapter, data,
+				     E1000_REG(&adapter->hw, FCAL),
+				     0xFFFFFFFF, 0xFFFFFFFF) ||
+		    reg_pattern_test(adapter, data,
+				     E1000_REG(&adapter->hw, FCAH),
+				     0x0000FFFF, 0xFFFFFFFF) ||
+		    reg_pattern_test(adapter, data,
+				     E1000_REG(&adapter->hw, FCT),
+				     0x0000FFFF, 0xFFFFFFFF) ||
+		    reg_pattern_test(adapter, data,
+				     E1000_REG(&adapter->hw, VET),
+				     0x0000FFFF, 0xFFFFFFFF))
+			return 1;
 	}
 
-	REG_PATTERN_TEST(RDTR, 0x0000FFFF, 0xFFFFFFFF);
-	REG_PATTERN_TEST(RDBAH, 0xFFFFFFFF, 0xFFFFFFFF);
-	REG_PATTERN_TEST(RDLEN, 0x000FFF80, 0x000FFFFF);
-	REG_PATTERN_TEST(RDH, 0x0000FFFF, 0x0000FFFF);
-	REG_PATTERN_TEST(RDT, 0x0000FFFF, 0x0000FFFF);
-	REG_PATTERN_TEST(FCRTH, 0x0000FFF8, 0x0000FFF8);
-	REG_PATTERN_TEST(FCTTV, 0x0000FFFF, 0x0000FFFF);
-	REG_PATTERN_TEST(TIPG, 0x3FFFFFFF, 0x3FFFFFFF);
-	REG_PATTERN_TEST(TDBAH, 0xFFFFFFFF, 0xFFFFFFFF);
-	REG_PATTERN_TEST(TDLEN, 0x000FFF80, 0x000FFFFF);
+	if (reg_pattern_test(adapter, data, E1000_REG(&adapter->hw, RDTR),
+			     0x0000FFFF, 0xFFFFFFFF) ||
+	    reg_pattern_test(adapter, data, E1000_REG(&adapter->hw, RDBAH),
+			     0xFFFFFFFF, 0xFFFFFFFF) ||
+	    reg_pattern_test(adapter, data, E1000_REG(&adapter->hw, RDLEN),
+			     0x000FFF80, 0x000FFFFF) ||
+	    reg_pattern_test(adapter, data, E1000_REG(&adapter->hw, RDH),
+			     0x0000FFFF, 0x0000FFFF) ||
+	    reg_pattern_test(adapter, data, E1000_REG(&adapter->hw, RDT),
+			     0x0000FFFF, 0x0000FFFF) ||
+	    reg_pattern_test(adapter, data, E1000_REG(&adapter->hw, FCRTH),
+			     0x0000FFF8, 0x0000FFF8) ||
+	    reg_pattern_test(adapter, data, E1000_REG(&adapter->hw, FCTTV),
+			     0x0000FFFF, 0x0000FFFF) ||
+	    reg_pattern_test(adapter, data, E1000_REG(&adapter->hw, TIPG),
+			     0x3FFFFFFF, 0x3FFFFFFF) ||
+	    reg_pattern_test(adapter, data, E1000_REG(&adapter->hw, TDBAH),
+			     0xFFFFFFFF, 0xFFFFFFFF) ||
+	    reg_pattern_test(adapter, data, E1000_REG(&adapter->hw, TDLEN),
+			     0x000FFF80, 0x000FFFFF))
+		return 1;
 
-	REG_SET_AND_CHECK(RCTL, 0xFFFFFFFF, 0x00000000);
+	if (reg_set_and_check(adapter, data, E1000_REG(&adapter->hw, RCTL),
+			      0xFFFFFFFF, 0x00000000))
+		return 1;
 
 	before = (adapter->hw.mac_type == e1000_ich8lan ?
 	          0x06C3B33E : 0x06DFB3FE);
-	REG_SET_AND_CHECK(RCTL, before, 0x003FFFFB);
-	REG_SET_AND_CHECK(TCTL, 0xFFFFFFFF, 0x00000000);
+	if (reg_set_and_check(adapter, data, E1000_REG(&adapter->hw, RCTL),
+			      before, 0x003FFFFB) ||
+	    reg_set_and_check(adapter, data, E1000_REG(&adapter->hw, TCTL),
+			      0xFFFFFFFF, 0x00000000))
+		return 1;
 
 	if (adapter->hw.mac_type >= e1000_82543) {
 
-		REG_SET_AND_CHECK(RCTL, before, 0xFFFFFFFF);
-		REG_PATTERN_TEST(RDBAL, 0xFFFFFFF0, 0xFFFFFFFF);
-		if (adapter->hw.mac_type != e1000_ich8lan)
-			REG_PATTERN_TEST(TXCW, 0xC000FFFF, 0x0000FFFF);
-		REG_PATTERN_TEST(TDBAL, 0xFFFFFFF0, 0xFFFFFFFF);
-		REG_PATTERN_TEST(TIDV, 0x0000FFFF, 0x0000FFFF);
+		if (reg_set_and_check(adapter, data,
+				      E1000_REG(&adapter->hw, RCTL),
+				      before, 0xFFFFFFFF))
+			return 1;
+		if (reg_pattern_test(adapter, data,
+				     E1000_REG(&adapter->hw, RDBAL),
+				     0xFFFFFFF0, 0xFFFFFFFF))
+			return 1;
+		if (adapter->hw.mac_type != e1000_ich8lan) {
+			if (reg_pattern_test(adapter, data,
+					     E1000_REG(&adapter->hw, TXCW),
+					     0xC000FFFF, 0x0000FFFF))
+				return 1;
+		}
+		if (reg_pattern_test(adapter, data,
+				     E1000_REG(&adapter->hw, TDBAL),
+				     0xFFFFFFF0, 0xFFFFFFFF) ||
+		    reg_pattern_test(adapter, data,
+				     E1000_REG(&adapter->hw, TIDV),
+				     0x0000FFFF, 0x0000FFFF))
+			return 1;
 		value = (adapter->hw.mac_type == e1000_ich8lan ?
 		         E1000_RAR_ENTRIES_ICH8LAN : E1000_RAR_ENTRIES);
 		for (i = 0; i < value; i++) {
-			REG_PATTERN_TEST(RA + (((i << 1) + 1) << 2), 0x8003FFFF,
-			                 0xFFFFFFFF);
+			if (reg_pattern_test(adapter, data,
+					     E1000_REG(&adapter->hw, RA) +
+					     (((i << 1) + 1) << 2),
+					     0x8003FFFF, 0xFFFFFFFF))
+				return 1;
 		}
 
 	} else {
 
-		REG_SET_AND_CHECK(RCTL, 0xFFFFFFFF, 0x01FFFFFF);
-		REG_PATTERN_TEST(RDBAL, 0xFFFFF000, 0xFFFFFFFF);
-		REG_PATTERN_TEST(TXCW, 0x0000FFFF, 0x0000FFFF);
-		REG_PATTERN_TEST(TDBAL, 0xFFFFF000, 0xFFFFFFFF);
+		if (reg_set_and_check(adapter, data,
+				      E1000_REG(&adapter->hw, RCTL),
+				      0xFFFFFFFF, 0x01FFFFFF))
+			return 1;
+		if (reg_pattern_test(adapter, data,
+				     E1000_REG(&adapter->hw, RDBAL),
+				     0xFFFFF000, 0xFFFFFFFF) ||
+		    reg_pattern_test(adapter, data,
+				     E1000_REG(&adapter->hw, TXCW),
+				     0x0000FFFF, 0x0000FFFF) ||
+		    reg_pattern_test(adapter, data,
+				     E1000_REG(&adapter->hw, TDBAL),
+				     0xFFFFF000, 0xFFFFFFFF))
+			return 1;
 
 	}
 
 	value = (adapter->hw.mac_type == e1000_ich8lan ?
 			E1000_MC_TBL_SIZE_ICH8LAN : E1000_MC_TBL_SIZE);
-	for (i = 0; i < value; i++)
-		REG_PATTERN_TEST(MTA + (i << 2), 0xFFFFFFFF, 0xFFFFFFFF);
+	for (i = 0; i < value; i++) {
+		if (reg_pattern_test(adapter, data,
+				     E1000_REG(&adapter->hw, MTA) + (i << 2),
+				     0xFFFFFFFF, 0xFFFFFFFF))
+			return 1;
+	}
 
 	*data = 0;
 	return 0;
diff --git a/drivers/net/e1000/e1000_osdep.h b/drivers/net/e1000/e1000_osdep.h
index 10af742..7d70eb6 100644
--- a/drivers/net/e1000/e1000_osdep.h
+++ b/drivers/net/e1000/e1000_osdep.h
@@ -61,24 +61,30 @@ typedef enum {
 #define DEBUGOUT3 DEBUGOUT2
 #define DEBUGOUT7 DEBUGOUT3
 
-
-#define E1000_WRITE_REG(a, reg, value) ( \
-    writel((value), ((a)->hw_addr + \
-        (((a)->mac_type >= e1000_82543) ? E1000_##reg : E1000_82542_##reg))))
-
-#define E1000_READ_REG(a, reg) ( \
-    readl((a)->hw_addr + \
-        (((a)->mac_type >= e1000_82543) ? E1000_##reg : E1000_82542_##reg)))
-
-#define E1000_WRITE_REG_ARRAY(a, reg, offset, value) ( \
-    writel((value), ((a)->hw_addr + \
-        (((a)->mac_type >= e1000_82543) ? E1000_##reg : E1000_82542_##reg) + \
-        ((offset) << 2))))
-
-#define E1000_READ_REG_ARRAY(a, reg, offset) ( \
-    readl((a)->hw_addr + \
-        (((a)->mac_type >= e1000_82543) ? E1000_##reg : E1000_82542_##reg) + \
-        ((offset) << 2)))
+#define E1000_REG(a, reg) \
+	(((a)->mac_type >= e1000_82543) ? E1000_##reg : E1000_82542_##reg)
+
+#define E1000_WRITE_REG(a, reg, value)					\
+	(writel((value), ((a)->hw_addr +				\
+			  (((a)->mac_type >= e1000_82543)		\
+			   ? E1000_##reg : E1000_82542_##reg))))
+
+#define E1000_READ_REG(a, reg)				\
+	(readl((a)->hw_addr +				\
+	       (((a)->mac_type >= e1000_82543)		\
+		? E1000_##reg : E1000_82542_##reg)))
+
+#define E1000_WRITE_REG_ARRAY(a, reg, offset, value)	       \
+	(writel((value), ((a)->hw_addr +		       \
+			  (((a)->mac_type >= e1000_82543)      \
+			   ? E1000_##reg : E1000_82542_##reg) +\
+			  ((offset) << 2))))
+
+#define E1000_READ_REG_ARRAY(a, reg, offset)		\
+	(readl((a)->hw_addr +				\
+	       (((a)->mac_type >= e1000_82543)		\
+		? E1000_##reg : E1000_82542_##reg) +	\
+	       ((offset) << 2)))
 
 #define E1000_READ_REG_ARRAY_DWORD E1000_READ_REG_ARRAY
 #define E1000_WRITE_REG_ARRAY_DWORD E1000_WRITE_REG_ARRAY


