From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/16] ixgbevf: Use static inlines instead of macros
Date: Fri, 21 Mar 2014 05:09:56 -0700
Message-ID: <1395403806-29302-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1395403806-29302-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:15182 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965494AbaCUMKN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Mar 2014 08:10:13 -0400
In-Reply-To: <1395403806-29302-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Kernel coding standard prefers static inline functions instead
of macros, so use them for register accessors. This is to prepare
for adding LER, Live Error Recovery, checks to those accessors.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |  5 ++++
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  4 ++--
 drivers/net/ethernet/intel/ixgbevf/regs.h         | 12 +---------
 drivers/net/ethernet/intel/ixgbevf/vf.h           | 28 ++++++++++++++++++++++-
 4 files changed, 35 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index 08fb88a..d4b1f50 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -315,6 +315,11 @@ static inline u16 ixgbevf_desc_unused(struct ixgbevf_ring *ring)
 	return ((ntc > ntu) ? 0 : ring->count) + ntc - ntu - 1;
 }
 
+static inline void ixgbevf_write_tail(struct ixgbevf_ring *ring, u32 value)
+{
+	writel(value, ring->tail);
+}
+
 #define IXGBEVF_RX_DESC(R, i)	    \
 	(&(((union ixgbe_adv_rx_desc *)((R)->desc))[i]))
 #define IXGBEVF_TX_DESC(R, i)	    \
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 592d8a6..74df8bf 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -111,7 +111,7 @@ static inline void ixgbevf_release_rx_desc(struct ixgbevf_ring *rx_ring,
 	 * such as IA-64).
 	 */
 	wmb();
-	writel(val, rx_ring->tail);
+	ixgbevf_write_tail(rx_ring, val);
 }
 
 /**
@@ -3060,7 +3060,7 @@ static void ixgbevf_tx_map(struct ixgbevf_ring *tx_ring,
 	tx_ring->next_to_use = i;
 
 	/* notify HW of packet */
-	writel(i, tx_ring->tail);
+	ixgbevf_write_tail(tx_ring, i);
 
 	return;
 dma_error:
diff --git a/drivers/net/ethernet/intel/ixgbevf/regs.h b/drivers/net/ethernet/intel/ixgbevf/regs.h
index debd8c0..09dd8f6 100644
--- a/drivers/net/ethernet/intel/ixgbevf/regs.h
+++ b/drivers/net/ethernet/intel/ixgbevf/regs.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 82599 Virtual Function driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2014 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -70,16 +70,6 @@
 #define IXGBE_VFGOTC_MSB       0x02024
 #define IXGBE_VFMPRC           0x01034
 
-#define IXGBE_WRITE_REG(a, reg, value) writel((value), ((a)->hw_addr + (reg)))
-
-#define IXGBE_READ_REG(a, reg) readl((a)->hw_addr + (reg))
-
-#define IXGBE_WRITE_REG_ARRAY(a, reg, offset, value) ( \
-    writel((value), ((a)->hw_addr + (reg) + ((offset) << 2))))
-
-#define IXGBE_READ_REG_ARRAY(a, reg, offset) ( \
-    readl((a)->hw_addr + (reg) + ((offset) << 2)))
-
 #define IXGBE_WRITE_FLUSH(a) (IXGBE_READ_REG(a, IXGBE_VFSTATUS))
 
 #endif /* _IXGBEVF_REGS_H_ */
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.h b/drivers/net/ethernet/intel/ixgbevf/vf.h
index 7b1f502..8ebed72 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 82599 Virtual Function driver
-  Copyright(c) 1999 - 2012 Intel Corporation.
+  Copyright(c) 1999 - 2014 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -172,6 +172,32 @@ struct ixgbevf_info {
 	const struct ixgbe_mac_operations *mac_ops;
 };
 
+static inline void ixgbe_write_reg(struct ixgbe_hw *hw, u32 reg, u32 value)
+{
+	writel(value, hw->hw_addr + reg);
+}
+#define IXGBE_WRITE_REG(h, r, v) ixgbe_write_reg(h, r, v)
+
+static inline u32 ixgbe_read_reg(struct ixgbe_hw *hw, u32 reg)
+{
+	return readl(hw->hw_addr + reg);
+}
+#define IXGBE_READ_REG(h, r) ixgbe_read_reg(h, r)
+
+static inline void ixgbe_write_reg_array(struct ixgbe_hw *hw, u32 reg,
+					  u32 offset, u32 value)
+{
+	ixgbe_write_reg(hw, reg + (offset << 2), value);
+}
+#define IXGBE_WRITE_REG_ARRAY(h, r, o, v) ixgbe_write_reg_array(h, r, o, v)
+
+static inline u32 ixgbe_read_reg_array(struct ixgbe_hw *hw, u32 reg,
+					u32 offset)
+{
+	return ixgbe_read_reg(hw, reg + (offset << 2));
+}
+#define IXGBE_READ_REG_ARRAY(h, r, o) ixgbe_read_reg_array(h, r, o)
+
 void ixgbevf_rlpml_set_vf(struct ixgbe_hw *hw, u16 max_size);
 int ixgbevf_negotiate_api_version(struct ixgbe_hw *hw, int api);
 int ixgbevf_get_queues(struct ixgbe_hw *hw, unsigned int *num_tcs,
-- 
1.8.3.1
