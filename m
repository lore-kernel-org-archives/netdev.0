From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH 1/8] ixgbe: Out of line ixgbe_read/write_reg
Date: Fri, 16 May 2014 14:43:08 -0700
Message-ID: <1400276595-6965-2-git-send-email-andi@firstfloor.org>
References: <1400276595-6965-1-git-send-email-andi@firstfloor.org>
Cc: akpm@linux-foundation.org, Andi Kleen <ak@linux.intel.com>,
	netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400276595-6965-1-git-send-email-andi@firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@linux.intel.com>

ixgbe_read_reg and ixgbe_write_reg are frequently called and are very big
because they have complex error handling code.

Moving them out of line saves ~27k text in the ixgbe driver.

   text	   data	    bss	    dec	    hex	filename
14220873	2008072	1507328	17736273	10ea251	vmlinux-before-ixgbe
14193673	2003976	1507328	17704977	10e2811	vmlinux-ixgbe

Cc: netdev@vger.kernel.org
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h | 22 ++--------------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   | 22 ++++++++++++++++++++++
 2 files changed, 24 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
index f12c40f..05f094d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
@@ -162,28 +162,10 @@ static inline void writeq(u64 val, void __iomem *addr)
 }
 #endif
 
-static inline void ixgbe_write_reg64(struct ixgbe_hw *hw, u32 reg, u64 value)
-{
-	u8 __iomem *reg_addr = ACCESS_ONCE(hw->hw_addr);
+void ixgbe_write_reg64(struct ixgbe_hw *hw, u32 reg, u64 value);
+u32 ixgbe_read_reg(struct ixgbe_hw *hw, u32 reg);
 
-	if (ixgbe_removed(reg_addr))
-		return;
-	writeq(value, reg_addr + reg);
-}
 #define IXGBE_WRITE_REG64(a, reg, value) ixgbe_write_reg64((a), (reg), (value))
-
-static inline u32 ixgbe_read_reg(struct ixgbe_hw *hw, u32 reg)
-{
-	u8 __iomem *reg_addr = ACCESS_ONCE(hw->hw_addr);
-	u32 value;
-
-	if (ixgbe_removed(reg_addr))
-		return IXGBE_FAILED_READ_REG;
-	value = readl(reg_addr + reg);
-	if (unlikely(value == IXGBE_FAILED_READ_REG))
-		ixgbe_check_remove(hw, reg);
-	return value;
-}
 #define IXGBE_READ_REG(a, reg) ixgbe_read_reg((a), (reg))
 
 #define IXGBE_WRITE_REG_ARRAY(a, reg, offset, value) \
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index d62e7a2..5f81f62 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -371,6 +371,28 @@ void ixgbe_write_pci_cfg_word(struct ixgbe_hw *hw, u32 reg, u16 value)
 	pci_write_config_word(adapter->pdev, reg, value);
 }
 
+void ixgbe_write_reg64(struct ixgbe_hw *hw, u32 reg, u64 value)
+{
+	u8 __iomem *reg_addr = ACCESS_ONCE(hw->hw_addr);
+
+	if (ixgbe_removed(reg_addr))
+		return;
+	writeq(value, reg_addr + reg);
+}
+
+u32 ixgbe_read_reg(struct ixgbe_hw *hw, u32 reg)
+{
+	u8 __iomem *reg_addr = ACCESS_ONCE(hw->hw_addr);
+	u32 value;
+
+	if (ixgbe_removed(reg_addr))
+		return IXGBE_FAILED_READ_REG;
+	value = readl(reg_addr + reg);
+	if (unlikely(value == IXGBE_FAILED_READ_REG))
+		ixgbe_check_remove(hw, reg);
+	return value;
+}
+
 static void ixgbe_service_event_complete(struct ixgbe_adapter *adapter)
 {
 	BUG_ON(!test_bit(__IXGBE_SERVICE_SCHED, &adapter->state));
-- 
1.9.0
