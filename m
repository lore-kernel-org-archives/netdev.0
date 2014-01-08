From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 3/7] ixgbe: Use static inlines instead of macros
Date: Tue,  7 Jan 2014 23:40:43 -0800
Message-ID: <1389166847-3780-4-git-send-email-aaron.f.brown@intel.com>
References: <1389166847-3780-1-git-send-email-aaron.f.brown@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:44149 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754987AbaAHHkM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jan 2014 02:40:12 -0500
In-Reply-To: <1389166847-3780-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Kernel coding standard prefers static inline functions instead
of macros, so use them for register accessors. This is to prepare
for adding LER, Live Error Recovery, checks to those accessors.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h        |  5 +++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h | 30 +++++++++++++++++--------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |  4 ++--
 3 files changed, 28 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 8da263a..199cf74 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -585,6 +585,11 @@ static inline u16 ixgbe_desc_unused(struct ixgbe_ring *ring)
 	return ((ntc > ntu) ? 0 : ring->count) + ntc - ntu - 1;
 }
 
+static inline void ixgbe_write_tail(struct ixgbe_ring *ring, u32 value)
+{
+	writel(value, ring->tail);
+}
+
 #define IXGBE_RX_DESC(R, i)	    \
 	(&(((union ixgbe_adv_rx_desc *)((R)->desc))[i]))
 #define IXGBE_TX_DESC(R, i)	    \
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
index d259dc7..5e157ac 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
@@ -124,22 +124,34 @@ s32 ixgbe_reset_pipeline_82599(struct ixgbe_hw *hw);
 s32 ixgbe_get_thermal_sensor_data_generic(struct ixgbe_hw *hw);
 s32 ixgbe_init_thermal_sensor_thresh_generic(struct ixgbe_hw *hw);
 
-#define IXGBE_WRITE_REG(a, reg, value) writel((value), ((a)->hw_addr + (reg)))
+static inline void IXGBE_WRITE_REG(struct ixgbe_hw *hw, u32 reg, u32 value)
+{
+	writel(value, hw->hw_addr + reg);
+}
 
 #ifndef writeq
-#define writeq(val, addr) writel((u32) (val), addr); \
-    writel((u32) (val >> 32), (addr + 4));
+static inline void writeq(u64 val, void __iomem *addr)
+{
+	writel((u32)val, addr);
+	writel((u32)(val >> 32), addr + 4);
+}
 #endif
 
-#define IXGBE_WRITE_REG64(a, reg, value) writeq((value), ((a)->hw_addr + (reg)))
+static inline void IXGBE_WRITE_REG64(struct ixgbe_hw *hw, u32 reg, u64 value)
+{
+	writeq(value, hw->hw_addr + reg);
+}
 
-#define IXGBE_READ_REG(a, reg) readl((a)->hw_addr + (reg))
+static inline u32 IXGBE_READ_REG(struct ixgbe_hw *hw, u32 reg)
+{
+	return readl(hw->hw_addr + reg);
+}
 
-#define IXGBE_WRITE_REG_ARRAY(a, reg, offset, value) (\
-    writel((value), ((a)->hw_addr + (reg) + ((offset) << 2))))
+#define IXGBE_WRITE_REG_ARRAY(a, reg, offset, value) \
+		IXGBE_WRITE_REG((a), (reg) + ((offset) << 2), (value))
 
-#define IXGBE_READ_REG_ARRAY(a, reg, offset) (\
-    readl((a)->hw_addr + (reg) + ((offset) << 2)))
+#define IXGBE_READ_REG_ARRAY(a, reg, offset) \
+		IXGBE_READ_REG((a), (reg) + ((offset) << 2))
 
 #define IXGBE_WRITE_FLUSH(a) IXGBE_READ_REG(a, IXGBE_STATUS)
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 923b0fa..4d71277 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1315,7 +1315,7 @@ static inline void ixgbe_release_rx_desc(struct ixgbe_ring *rx_ring, u32 val)
 	 * such as IA-64).
 	 */
 	wmb();
-	writel(val, rx_ring->tail);
+	ixgbe_write_tail(rx_ring, val);
 }
 
 static bool ixgbe_alloc_mapped_page(struct ixgbe_ring *rx_ring,
@@ -6699,7 +6699,7 @@ static void ixgbe_tx_map(struct ixgbe_ring *tx_ring,
 	tx_ring->next_to_use = i;
 
 	/* notify HW of packet */
-	writel(i, tx_ring->tail);
+	ixgbe_write_tail(tx_ring, i);
 
 	return;
 dma_error:
-- 
1.8.5.GIT
