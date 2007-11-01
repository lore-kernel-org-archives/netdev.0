From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] - e1000_ethtool.c - convert macros to functions
Date: Wed, 31 Oct 2007 17:34:23 -0700
Message-ID: <1193877263.11020.48.camel@localhost>
References: <1193865488.11020.11.camel@localhost>
	 <4728F3E1.1040908@intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, e1000-devel@lists.sourceforge.net,
	Jeff Garzik <jgarzik@pobox.com>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:3490 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752181AbXKAAed (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2007 20:34:33 -0400
In-Reply-To: <4728F3E1.1040908@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-10-31 at 14:30 -0700, Kok, Auke wrote:
> Joe Perches wrote:
> > Convert REG_PATTERN_TEST and REG_SET_AND_CHECK macros to functions
> > Reduces x86 defconfig image by about 3k

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

Changed since last submission:

Fixed existing controler->controller typo
Added E1000_REG_ADDR macro
Added E1000_FLASH_ADDR macro
The #define E1000_PHY_CTRL conflicted with the PHY_CTRL
expansion when using the E1000_REG_ADDR macro and was
renamed to E1000_PHY_CTRL_CSR

Signed-off-by: Joe Perches <joe@perches.com>

---

 drivers/net/e1000/e1000_ethtool.c |  185 +++++++++++++++++++++++++------------
 drivers/net/e1000/e1000_hw.c      |   20 ++--
 drivers/net/e1000/e1000_hw.h      |    6 +-
 drivers/net/e1000/e1000_osdep.h   |   70 +++++++--------
 4 files changed, 170 insertions(+), 111 deletions(-)

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
diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 7c6888c..7af6b6f 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -3947,8 +3947,8 @@ e1000_phy_powerdown_workaround(struct e1000_hw *hw)
 
     do {
         /* Disable link */
-        reg = E1000_READ_REG(hw, PHY_CTRL);
-        E1000_WRITE_REG(hw, PHY_CTRL, reg | E1000_PHY_CTRL_GBE_DISABLE |
+        reg = E1000_READ_REG(hw, PHY_CTRL_CSR);
+        E1000_WRITE_REG(hw, PHY_CTRL_CSR, reg | E1000_PHY_CTRL_GBE_DISABLE |
                         E1000_PHY_CTRL_NOND0A_GBE_DISABLE);
 
         /* Write VR power-down enable - bits 9:8 should be 10b */
@@ -4023,8 +4023,8 @@ e1000_kumeran_lock_loss_workaround(struct e1000_hw *hw)
             mdelay(5);
         }
         /* Disable GigE link negotiation */
-        reg = E1000_READ_REG(hw, PHY_CTRL);
-        E1000_WRITE_REG(hw, PHY_CTRL, reg | E1000_PHY_CTRL_GBE_DISABLE |
+        reg = E1000_READ_REG(hw, PHY_CTRL_CSR);
+        E1000_WRITE_REG(hw, PHY_CTRL_CSR, reg | E1000_PHY_CTRL_GBE_DISABLE |
                         E1000_PHY_CTRL_NOND0A_GBE_DISABLE);
 
         /* unable to acquire PCS lock */
@@ -7243,7 +7243,7 @@ e1000_set_d3_lplu_state(struct e1000_hw *hw,
         /* MAC writes into PHY register based on the state transition
          * and start auto-negotiation. SW driver can overwrite the settings
          * in CSR PHY power control E1000_PHY_CTRL register. */
-        phy_ctrl = E1000_READ_REG(hw, PHY_CTRL);
+        phy_ctrl = E1000_READ_REG(hw, PHY_CTRL_CSR);
     } else {
         ret_val = e1000_read_phy_reg(hw, IGP02E1000_PHY_POWER_MGMT, &phy_data);
         if (ret_val)
@@ -7260,7 +7260,7 @@ e1000_set_d3_lplu_state(struct e1000_hw *hw,
         } else {
             if (hw->mac_type == e1000_ich8lan) {
                 phy_ctrl &= ~E1000_PHY_CTRL_NOND0A_LPLU;
-                E1000_WRITE_REG(hw, PHY_CTRL, phy_ctrl);
+                E1000_WRITE_REG(hw, PHY_CTRL_CSR, phy_ctrl);
             } else {
                 phy_data &= ~IGP02E1000_PM_D3_LPLU;
                 ret_val = e1000_write_phy_reg(hw, IGP02E1000_PHY_POWER_MGMT,
@@ -7311,7 +7311,7 @@ e1000_set_d3_lplu_state(struct e1000_hw *hw,
         } else {
             if (hw->mac_type == e1000_ich8lan) {
                 phy_ctrl |= E1000_PHY_CTRL_NOND0A_LPLU;
-                E1000_WRITE_REG(hw, PHY_CTRL, phy_ctrl);
+                E1000_WRITE_REG(hw, PHY_CTRL_CSR, phy_ctrl);
             } else {
                 phy_data |= IGP02E1000_PM_D3_LPLU;
                 ret_val = e1000_write_phy_reg(hw, IGP02E1000_PHY_POWER_MGMT,
@@ -7362,7 +7362,7 @@ e1000_set_d0_lplu_state(struct e1000_hw *hw,
         return E1000_SUCCESS;
 
     if (hw->mac_type == e1000_ich8lan) {
-        phy_ctrl = E1000_READ_REG(hw, PHY_CTRL);
+        phy_ctrl = E1000_READ_REG(hw, PHY_CTRL_CSR);
     } else {
         ret_val = e1000_read_phy_reg(hw, IGP02E1000_PHY_POWER_MGMT, &phy_data);
         if (ret_val)
@@ -7372,7 +7372,7 @@ e1000_set_d0_lplu_state(struct e1000_hw *hw,
     if (!active) {
         if (hw->mac_type == e1000_ich8lan) {
             phy_ctrl &= ~E1000_PHY_CTRL_D0A_LPLU;
-            E1000_WRITE_REG(hw, PHY_CTRL, phy_ctrl);
+            E1000_WRITE_REG(hw, PHY_CTRL_CSR, phy_ctrl);
         } else {
             phy_data &= ~IGP02E1000_PM_D0_LPLU;
             ret_val = e1000_write_phy_reg(hw, IGP02E1000_PHY_POWER_MGMT, phy_data);
@@ -7413,7 +7413,7 @@ e1000_set_d0_lplu_state(struct e1000_hw *hw,
 
         if (hw->mac_type == e1000_ich8lan) {
             phy_ctrl |= E1000_PHY_CTRL_D0A_LPLU;
-            E1000_WRITE_REG(hw, PHY_CTRL, phy_ctrl);
+            E1000_WRITE_REG(hw, PHY_CTRL_CSR, phy_ctrl);
         } else {
             phy_data |= IGP02E1000_PM_D0_LPLU;
             ret_val = e1000_write_phy_reg(hw, IGP02E1000_PHY_POWER_MGMT, phy_data);
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index a2a86c5..7fa4b60 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -41,7 +41,7 @@ struct e1000_hw;
 struct e1000_hw_stats;
 
 /* Enumerated types specific to the e1000 hardware */
-/* Media Access Controlers */
+/* Media Access Controllers */
 typedef enum {
     e1000_undefined = 0,
     e1000_82542_rev2_0,
@@ -922,7 +922,7 @@ struct e1000_ffvt_entry {
 #define E1000_LEDCTL   0x00E00  /* LED Control - RW */
 #define E1000_EXTCNF_CTRL  0x00F00  /* Extended Configuration Control */
 #define E1000_EXTCNF_SIZE  0x00F08  /* Extended Configuration Size */
-#define E1000_PHY_CTRL     0x00F10  /* PHY Control Register in CSR */
+#define E1000_PHY_CTRL_CSR 0x00F10  /* PHY Control Register in CSR */
 #define FEXTNVM_SW_CONFIG  0x0001
 #define E1000_PBA      0x01000  /* Packet Buffer Allocation - RW */
 #define E1000_PBS      0x01008  /* Packet Buffer Size */
@@ -1178,7 +1178,7 @@ struct e1000_ffvt_entry {
 #define E1000_82542_FLOP     E1000_FLOP
 #define E1000_82542_EXTCNF_CTRL  E1000_EXTCNF_CTRL
 #define E1000_82542_EXTCNF_SIZE  E1000_EXTCNF_SIZE
-#define E1000_82542_PHY_CTRL E1000_PHY_CTRL
+#define E1000_82542_PHY_CTRL_CSR E1000_PHY_CTRL_CSR
 #define E1000_82542_ERT      E1000_ERT
 #define E1000_82542_RXDCTL   E1000_RXDCTL
 #define E1000_82542_RXDCTL1  E1000_RXDCTL1
diff --git a/drivers/net/e1000/e1000_osdep.h b/drivers/net/e1000/e1000_osdep.h
index 10af742..9453adc 100644
--- a/drivers/net/e1000/e1000_osdep.h
+++ b/drivers/net/e1000/e1000_osdep.h
@@ -61,60 +61,54 @@ typedef enum {
 #define DEBUGOUT3 DEBUGOUT2
 #define DEBUGOUT7 DEBUGOUT3
 
+#define E1000_REG(a, reg) \
+	(((a)->mac_type >= e1000_82543) ? (E1000_##reg) : (E1000_82542_##reg))
 
-#define E1000_WRITE_REG(a, reg, value) ( \
-    writel((value), ((a)->hw_addr + \
-        (((a)->mac_type >= e1000_82543) ? E1000_##reg : E1000_82542_##reg))))
+#define E1000_REG_ADDR(a, reg) \
+	((a)->hw_addr + E1000_REG((a), reg))
 
-#define E1000_READ_REG(a, reg) ( \
-    readl((a)->hw_addr + \
-        (((a)->mac_type >= e1000_82543) ? E1000_##reg : E1000_82542_##reg)))
+#define E1000_WRITE_REG(a, reg, value) \
+	(writel((value), E1000_REG_ADDR((a), reg)))
 
-#define E1000_WRITE_REG_ARRAY(a, reg, offset, value) ( \
-    writel((value), ((a)->hw_addr + \
-        (((a)->mac_type >= e1000_82543) ? E1000_##reg : E1000_82542_##reg) + \
-        ((offset) << 2))))
+#define E1000_READ_REG(a, reg) \
+	(readl(E1000_REG_ADDR((a), reg)))
 
-#define E1000_READ_REG_ARRAY(a, reg, offset) ( \
-    readl((a)->hw_addr + \
-        (((a)->mac_type >= e1000_82543) ? E1000_##reg : E1000_82542_##reg) + \
-        ((offset) << 2)))
+#define E1000_WRITE_REG_ARRAY(a, reg, offset, value) \
+	(writel((value), E1000_REG_ADDR((a), reg) + ((offset) << 2)))
+
+#define E1000_READ_REG_ARRAY(a, reg, offset) \
+	(readl(E1000_REG_ADDR((a), reg) + ((offset) << 2)))
 
 #define E1000_READ_REG_ARRAY_DWORD E1000_READ_REG_ARRAY
 #define E1000_WRITE_REG_ARRAY_DWORD E1000_WRITE_REG_ARRAY
 
-#define E1000_WRITE_REG_ARRAY_WORD(a, reg, offset, value) ( \
-    writew((value), ((a)->hw_addr + \
-        (((a)->mac_type >= e1000_82543) ? E1000_##reg : E1000_82542_##reg) + \
-        ((offset) << 1))))
+#define E1000_WRITE_REG_ARRAY_WORD(a, reg, offset, value) \
+	(writew((value), E1000_REG_ADDR((a), reg) + ((offset) << 1)))
 
-#define E1000_READ_REG_ARRAY_WORD(a, reg, offset) ( \
-    readw((a)->hw_addr + \
-        (((a)->mac_type >= e1000_82543) ? E1000_##reg : E1000_82542_##reg) + \
-        ((offset) << 1)))
+#define E1000_READ_REG_ARRAY_WORD(a, reg, offset) \
+	(readw(E1000_REG_ADDR((a), reg) + ((offset) << 1)))
 
-#define E1000_WRITE_REG_ARRAY_BYTE(a, reg, offset, value) ( \
-    writeb((value), ((a)->hw_addr + \
-        (((a)->mac_type >= e1000_82543) ? E1000_##reg : E1000_82542_##reg) + \
-        (offset))))
+#define E1000_WRITE_REG_ARRAY_BYTE(a, reg, offset, value) \
+	(writeb((value), E1000_REG_ADDR((a), reg) + (offset)))
 
-#define E1000_READ_REG_ARRAY_BYTE(a, reg, offset) ( \
-    readb((a)->hw_addr + \
-        (((a)->mac_type >= e1000_82543) ? E1000_##reg : E1000_82542_##reg) + \
-        (offset)))
+#define E1000_READ_REG_ARRAY_BYTE(a, reg, offset) \
+	(readb(E1000_REG_ADDR((a), reg) + (offset)))
 
 #define E1000_WRITE_FLUSH(a) E1000_READ_REG(a, STATUS)
 
-#define E1000_WRITE_ICH_FLASH_REG(a, reg, value) ( \
-    writel((value), ((a)->flash_address + reg)))
+#define E1000_FLASH_ADDR(a, reg) \
+	((a)->flash_address + reg)
+
+#define E1000_WRITE_ICH_FLASH_REG(a, reg, value) \
+	(writel((value), E1000_FLASH_ADDR((a), (reg))))
 
-#define E1000_READ_ICH_FLASH_REG(a, reg) ( \
-    readl((a)->flash_address + reg))
+#define E1000_READ_ICH_FLASH_REG(a, reg) \
+	(readl(E1000_FLASH_ADDR((a), (reg))))
 
-#define E1000_WRITE_ICH_FLASH_REG16(a, reg, value) ( \
-    writew((value), ((a)->flash_address + reg)))
+#define E1000_WRITE_ICH_FLASH_REG16(a, reg, value) \
+	(writew((value), E1000_FLASH_ADDR((a), (reg))))
 
-#define E1000_READ_ICH_FLASH_REG16(a, reg) ( \
-    readw((a)->flash_address + reg))
+#define E1000_READ_ICH_FLASH_REG16(a, reg) \
+	(readw(E1000_FLASH_ADDR((a), (reg))))
 
 #endif /* _E1000_OSDEP_H_ */


