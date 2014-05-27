From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/15] e1000e: Out of line __ew32_prepare/__ew32
Date: Tue, 27 May 2014 02:12:28 -0700
Message-ID: <1401181951-31358-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1401181951-31358-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Andi Kleen <ak@linux.intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:17019 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752182AbaE0JMq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2014 05:12:46 -0400
In-Reply-To: <1401181951-31358-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <ak@linux.intel.com>

Out of lining these two common inlines saves about 30k text size,
due to their errata workarounds.

14131431	2008136	1507328	17646895	10d452f	vmlinux-before-e1000e
14101415	2004040	1507328	17612783	10cbfef	vmlinux-e1000e

Signed-off-by: Andi Kleen <ak@linux.intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/e1000.h  | 31 ++----------------------------
 drivers/net/ethernet/intel/e1000e/netdev.c | 30 +++++++++++++++++++++++++++++
 2 files changed, 32 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000.h
index 63bde99..7785240 100644
--- a/drivers/net/ethernet/intel/e1000e/e1000.h
+++ b/drivers/net/ethernet/intel/e1000e/e1000.h
@@ -575,35 +575,8 @@ static inline u32 __er32(struct e1000_hw *hw, unsigned long reg)
 
 #define er32(reg)	__er32(hw, E1000_##reg)
 
-/**
- * __ew32_prepare - prepare to write to MAC CSR register on certain parts
- * @hw: pointer to the HW structure
- *
- * When updating the MAC CSR registers, the Manageability Engine (ME) could
- * be accessing the registers at the same time.  Normally, this is handled in
- * h/w by an arbiter but on some parts there is a bug that acknowledges Host
- * accesses later than it should which could result in the register to have
- * an incorrect value.  Workaround this by checking the FWSM register which
- * has bit 24 set while ME is accessing MAC CSR registers, wait if it is set
- * and try again a number of times.
- **/
-static inline s32 __ew32_prepare(struct e1000_hw *hw)
-{
-	s32 i = E1000_ICH_FWSM_PCIM2PCI_COUNT;
-
-	while ((er32(FWSM) & E1000_ICH_FWSM_PCIM2PCI) && --i)
-		udelay(50);
-
-	return i;
-}
-
-static inline void __ew32(struct e1000_hw *hw, unsigned long reg, u32 val)
-{
-	if (hw->adapter->flags2 & FLAG2_PCIM2PCI_ARBITER_WA)
-		__ew32_prepare(hw);
-
-	writel(val, hw->hw_addr + reg);
-}
+s32 __ew32_prepare(struct e1000_hw *hw);
+void __ew32(struct e1000_hw *hw, unsigned long reg, u32 val);
 
 #define ew32(reg, val)	__ew32(hw, E1000_##reg, (val))
 
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index e00144a..201cc93 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -124,6 +124,36 @@ static const struct e1000_reg_info e1000_reg_info_tbl[] = {
 };
 
 /**
+ * __ew32_prepare - prepare to write to MAC CSR register on certain parts
+ * @hw: pointer to the HW structure
+ *
+ * When updating the MAC CSR registers, the Manageability Engine (ME) could
+ * be accessing the registers at the same time.  Normally, this is handled in
+ * h/w by an arbiter but on some parts there is a bug that acknowledges Host
+ * accesses later than it should which could result in the register to have
+ * an incorrect value.  Workaround this by checking the FWSM register which
+ * has bit 24 set while ME is accessing MAC CSR registers, wait if it is set
+ * and try again a number of times.
+ **/
+s32 __ew32_prepare(struct e1000_hw *hw)
+{
+	s32 i = E1000_ICH_FWSM_PCIM2PCI_COUNT;
+
+	while ((er32(FWSM) & E1000_ICH_FWSM_PCIM2PCI) && --i)
+		udelay(50);
+
+	return i;
+}
+
+void __ew32(struct e1000_hw *hw, unsigned long reg, u32 val)
+{
+	if (hw->adapter->flags2 & FLAG2_PCIM2PCI_ARBITER_WA)
+		__ew32_prepare(hw);
+
+	writel(val, hw->hw_addr + reg);
+}
+
+/**
  * e1000_regdump - register printout routine
  * @hw: pointer to the HW structure
  * @reginfo: pointer to the register info table
-- 
1.9.3
