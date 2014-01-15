From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next v4 3/7] ixgbe: Use static inlines instead of macros
Date: Tue, 14 Jan 2014 18:53:13 -0800
Message-ID: <1389754397-2507-4-git-send-email-aaron.f.brown@intel.com>
References: <1389754397-2507-1-git-send-email-aaron.f.brown@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:21337 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752174AbaAOCxc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 21:53:32 -0500
In-Reply-To: <1389754397-2507-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Kernel coding standard prefers static inline functions instead
of macros, so use them for register accessors. This is to prepare
for adding LER, Live Error Recovery, checks to those accessors.

Temporarily provide macros for calling the new static inline
accessors until all references are changed.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h        |  5 ++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h | 36 ++++++++++++++++++-------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |  4 +--
 3 files changed, 33 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 19d2774..06f4ab5 100644
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
index d259dc7..449291d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
@@ -124,24 +124,40 @@ s32 ixgbe_reset_pipeline_82599(struct ixgbe_hw *hw);
 s32 ixgbe_get_thermal_sensor_data_generic(struct ixgbe_hw *hw);
 s32 ixgbe_init_thermal_sensor_thresh_generic(struct ixgbe_hw *hw);
 
-#define IXGBE_WRITE_REG(a, reg, value) writel((value), ((a)->hw_addr + (reg)))
+static inline void ixgbe_write_reg(struct ixgbe_hw *hw, u32 reg, u32 value)
+{
+	writel(value, hw->hw_addr + reg);
+}
+#define IXGBE_WRITE_REG(a, reg, value) ixgbe_write_reg((a), (reg), (value))
 
 #ifndef writeq
-#define writeq(val, addr) writel((u32) (val), addr); \
-    writel((u32) (val >> 32), (addr + 4));
+#define writeq writeq
+static inline void writeq(u64 val, void __iomem *addr)
+{
+	writel((u32)val, addr);
+	writel((u32)(val >> 32), addr + 4);
+}
 #endif
 
-#define IXGBE_WRITE_REG64(a, reg, value) writeq((value), ((a)->hw_addr + (reg)))
+static inline void ixgbe_write_reg64(struct ixgbe_hw *hw, u32 reg, u64 value)
+{
+	writeq(value, hw->hw_addr + reg);
+}
+#define IXGBE_WRITE_REG64(a, reg, value) ixgbe_write_reg64((a), (reg), (value))
 
-#define IXGBE_READ_REG(a, reg) readl((a)->hw_addr + (reg))
+static inline u32 ixgbe_read_reg(struct ixgbe_hw *hw, u32 reg)
+{
+	return readl(hw->hw_addr + reg);
+}
+#define IXGBE_READ_REG(a, reg) ixgbe_read_reg((a), (reg))
 
-#define IXGBE_WRITE_REG_ARRAY(a, reg, offset, value) (\
-    writel((value), ((a)->hw_addr + (reg) + ((offset) << 2))))
+#define IXGBE_WRITE_REG_ARRAY(a, reg, offset, value) \
+		ixgbe_write_reg((a), (reg) + ((offset) << 2), (value))
 
-#define IXGBE_READ_REG_ARRAY(a, reg, offset) (\
-    readl((a)->hw_addr + (reg) + ((offset) << 2)))
+#define IXGBE_READ_REG_ARRAY(a, reg, offset) \
+		ixgbe_read_reg((a), (reg) + ((offset) << 2))
 
-#define IXGBE_WRITE_FLUSH(a) IXGBE_READ_REG(a, IXGBE_STATUS)
+#define IXGBE_WRITE_FLUSH(a) ixgbe_read_reg((a), IXGBE_STATUS)
 
 #define ixgbe_hw_to_netdev(hw) (((struct ixgbe_adapter *)(hw)->back)->netdev)
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 44a2619..01df376 100644
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
