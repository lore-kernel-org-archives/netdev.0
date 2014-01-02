From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/9] ixgbe: Check for adapter removal on register writes
Date: Thu,  2 Jan 2014 01:33:36 -0800
Message-ID: <1388655221-25428-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1388655221-25428-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:49542 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750746AbaABJdt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jan 2014 04:33:49 -0500
In-Reply-To: <1388655221-25428-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Prevent writes to an adapter that has been detected as removed
by a previous failing read. This also fixes some include file
ordering confusion that this patch revealed.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h        |  5 +++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h | 12 ++++++++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |  6 ++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.c    |  3 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c    |  2 +-
 5 files changed, 23 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index ad34757..d0a514b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -257,6 +257,9 @@ struct ixgbe_ring {
 	};
 	unsigned long last_rx_timestamp;
 	unsigned long state;
+#ifdef CONFIG_IXGBE_LER
+	u8 __iomem **adapter_present;	/* Points to hw_addr in ixgbe_hw */
+#endif /* CONFIG_IXGBE_LER */
 	u8 __iomem *tail;
 	dma_addr_t dma;			/* phys. address of descriptor ring */
 	unsigned int size;		/* length in bytes */
@@ -587,6 +590,8 @@ static inline u16 ixgbe_desc_unused(struct ixgbe_ring *ring)
 
 static inline void ixgbe_write_tail(struct ixgbe_ring *ring, u32 value)
 {
+	if (IXGBE_REMOVED(*ring->adapter_present))
+		return;
 	writel(value, ring->tail);
 }
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
index 7626c84..e426fe2 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
@@ -135,7 +135,11 @@ void ixgbe_check_remove(struct ixgbe_hw *hw, u32 reg);
 
 static inline void IXGBE_WRITE_REG(struct ixgbe_hw *hw, u32 reg, u32 value)
 {
-	writel(value, hw->hw_addr + reg);
+	u8 __iomem *reg_addr = hw->hw_addr;
+
+	if (IXGBE_REMOVED(reg_addr))
+		return;
+	writel(value, reg_addr + reg);
 }
 
 #ifndef writeq
@@ -145,7 +149,11 @@ static inline void IXGBE_WRITE_REG(struct ixgbe_hw *hw, u32 reg, u32 value)
 
 static inline void IXGBE_WRITE_REG64(struct ixgbe_hw *hw, u32 reg, u64 value)
 {
-	writeq(value, hw->hw_addr + reg);
+	u8 __iomem *reg_addr = hw->hw_addr;
+
+	if (IXGBE_REMOVED(reg_addr))
+		return;
+	writeq(value, reg_addr + reg);
 }
 
 static inline u32 IXGBE_READ_REG(struct ixgbe_hw *hw, u32 reg)
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 1100315..c415d71 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3000,6 +3000,9 @@ void ixgbe_configure_tx_ring(struct ixgbe_adapter *adapter,
 			ring->count * sizeof(union ixgbe_adv_tx_desc));
 	IXGBE_WRITE_REG(hw, IXGBE_TDH(reg_idx), 0);
 	IXGBE_WRITE_REG(hw, IXGBE_TDT(reg_idx), 0);
+#ifdef CONFIG_IXGBE_LER
+	ring->adapter_present = &hw->hw_addr;
+#endif /* CONFIG_IXGBE_LER */
 	ring->tail = adapter->io_addr + IXGBE_TDT(reg_idx);
 
 	/*
@@ -3403,6 +3406,9 @@ void ixgbe_configure_rx_ring(struct ixgbe_adapter *adapter,
 			ring->count * sizeof(union ixgbe_adv_rx_desc));
 	IXGBE_WRITE_REG(hw, IXGBE_RDH(reg_idx), 0);
 	IXGBE_WRITE_REG(hw, IXGBE_RDT(reg_idx), 0);
+#ifdef CONFIG_IXGBE_LER
+	ring->adapter_present = &hw->hw_addr;
+#endif /* CONFIG_IXGBE_LER */
 	ring->tail = adapter->io_addr + IXGBE_RDT(reg_idx);
 
 	ixgbe_configure_srrctl(adapter, ring);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.c
index d4a64e6..cc3101a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.c
@@ -27,8 +27,7 @@
 
 #include <linux/pci.h>
 #include <linux/delay.h>
-#include "ixgbe_type.h"
-#include "ixgbe_common.h"
+#include "ixgbe.h"
 #include "ixgbe_mbx.h"
 
 /**
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
index 39217e5..132557c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
@@ -29,7 +29,7 @@
 #include <linux/delay.h>
 #include <linux/sched.h>
 
-#include "ixgbe_common.h"
+#include "ixgbe.h"
 #include "ixgbe_phy.h"
 
 static void ixgbe_i2c_start(struct ixgbe_hw *hw);
-- 
1.8.3.1
