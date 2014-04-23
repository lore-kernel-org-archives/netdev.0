From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/14] ixgbe: Use out-of-line function for register reads
Date: Wed, 23 Apr 2014 04:15:14 -0700
Message-ID: <1398251726-13638-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1398251726-13638-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:15123 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752984AbaDWLPd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2014 07:15:33 -0400
In-Reply-To: <1398251726-13638-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Register reads are slow, so don't inline them.

Size before:
   text	   data	    bss	    dec	    hex	filename
 226337	   8280	    552	 235169	  396a1	ixgbe.ko

Size after:
   text	   data	    bss	    dec	    hex	filename
 194578	   8280	    552	 203410	  31a92	ixgbe.ko

for about a 14% reduction in text size.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h | 15 +------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   | 28 ++++++++++++++++++++++++-
 2 files changed, 28 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
index f12c40f..d15ff2e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
@@ -141,8 +141,6 @@ static inline bool ixgbe_removed(void __iomem *addr)
 	return unlikely(!addr);
 }
 
-void ixgbe_check_remove(struct ixgbe_hw *hw, u32 reg);
-
 static inline void ixgbe_write_reg(struct ixgbe_hw *hw, u32 reg, u32 value)
 {
 	u8 __iomem *reg_addr = ACCESS_ONCE(hw->hw_addr);
@@ -172,18 +170,7 @@ static inline void ixgbe_write_reg64(struct ixgbe_hw *hw, u32 reg, u64 value)
 }
 #define IXGBE_WRITE_REG64(a, reg, value) ixgbe_write_reg64((a), (reg), (value))
 
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
+u32 ixgbe_read_reg(struct ixgbe_hw *hw, u32 reg);
 #define IXGBE_READ_REG(a, reg) ixgbe_read_reg((a), (reg))
 
 #define IXGBE_WRITE_REG_ARRAY(a, reg, offset, value) \
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 147efec..7a67a9f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -301,7 +301,7 @@ static void ixgbe_remove_adapter(struct ixgbe_hw *hw)
 		ixgbe_service_event_schedule(adapter);
 }
 
-void ixgbe_check_remove(struct ixgbe_hw *hw, u32 reg)
+static void ixgbe_check_remove(struct ixgbe_hw *hw, u32 reg)
 {
 	u32 value;
 
@@ -320,6 +320,32 @@ void ixgbe_check_remove(struct ixgbe_hw *hw, u32 reg)
 		ixgbe_remove_adapter(hw);
 }
 
+/**
+ * ixgbe_read_reg - Read from device register
+ * @hw: hw specific details
+ * @reg: offset of register to read
+ *
+ * Returns : value read or IXGBE_FAILED_READ_REG if removed
+ *
+ * This function is used to read device registers. It checks for device
+ * removal by confirming any read that returns all ones by checking the
+ * status register value for all ones. This function avoids reading from
+ * the hardware if a removal was previously detected in which case it
+ * returns IXGBE_FAILED_READ_REG (all ones).
+ */
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
 static bool ixgbe_check_cfg_remove(struct ixgbe_hw *hw, struct pci_dev *pdev)
 {
 	u16 value;
-- 
1.9.0
