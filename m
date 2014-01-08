From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 6/7] ixgbe: Check for adapter removal on register writes
Date: Tue,  7 Jan 2014 23:40:46 -0800
Message-ID: <1389166847-3780-7-git-send-email-aaron.f.brown@intel.com>
References: <1389166847-3780-1-git-send-email-aaron.f.brown@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:8243 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755193AbaAHHkR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jan 2014 02:40:17 -0500
In-Reply-To: <1389166847-3780-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Prevent writes to an adapter that has been detected as removed
by a previous failing read. This also fixes some include file
ordering confusion that this patch revealed.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h | 12 ++++++++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.c    |  3 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c    |  2 +-
 3 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
index 480c5c1..5320586 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.h
@@ -131,7 +131,11 @@ void ixgbe_check_remove(struct ixgbe_hw *hw, u32 reg);
 
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
@@ -144,7 +148,11 @@ static inline void writeq(u64 val, void __iomem *addr)
 
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
1.8.5.GIT
