From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 06/11] ixgbe: Check for adapter removal on register writes
Date: Thu,  2 Jan 2014 21:18:25 -0800
Message-ID: <1388726310-2996-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1388726310-2996-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, bhutchings@solarflare.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:30860 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750869AbaACFSi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jan 2014 00:18:38 -0500
In-Reply-To: <1388726310-2996-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Prevent writes to an adapter that has been detected as removed
by a previous failing read. This also fixes some include file
ordering confusion that this patch revealed.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h        |  5 +++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h | 12 ++++++++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |  6 ++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.c    |  3 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c    |  2 +-
 5 files changed, 23 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 002c9e2..8a4b03b 100644
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
index 551025a..b07a887 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
@@ -135,7 +135,11 @@ void ixgbe_check_remove(struct ixgbe_hw *hw, u32 reg);
 
 static inline void IXGBE_WRITE_REG(struct ixgbe_hw *hw, u32 reg, u32 value)
 {
-	writel(value, hw->hw_addr + reg);
+	u8 __iomem *reg_addr = ACCESS_ONCE(hw->hw_addr);
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
+	u8 __iomem *reg_addr = ACCESS_ONCE(hw->hw_addr);
+
+	if (IXGBE_REMOVED(reg_addr))
+		return;
+	writeq(value, reg_addr + reg);
 }
 
 static inline u32 IXGBE_READ_REG(struct ixgbe_hw *hw, u32 reg)
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 0f0ca66..22e51d1 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3001,6 +3001,9 @@ void ixgbe_configure_tx_ring(struct ixgbe_adapter *adapter,
 			ring->count * sizeof(union ixgbe_adv_tx_desc));
 	IXGBE_WRITE_REG(hw, IXGBE_TDH(reg_idx), 0);
 	IXGBE_WRITE_REG(hw, IXGBE_TDT(reg_idx), 0);
+#ifdef CONFIG_IXGBE_LER
+	ring->adapter_present = &hw->hw_addr;
+#endif /* CONFIG_IXGBE_LER */
 	ring->tail = adapter->io_addr + IXGBE_TDT(reg_idx);
 
 	/*
@@ -3404,6 +3407,9 @@ void ixgbe_configure_rx_ring(struct ixgbe_adapter *adapter,
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
