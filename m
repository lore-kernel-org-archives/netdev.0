From: "Ariel Elior" <ariele@broadcom.com>
Subject: [PATCH net-next 06/10] bnx2x: Lock PF-common resources
Date: Thu, 26 Jan 2012 18:01:50 +0200
Message-ID: <1327593714-18358-7-git-send-email-ariele@broadcom.com>
References: <1327593714-18358-1-git-send-email-ariele@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Ariel Elior" <ariele@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1867 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752694Ab2AZQB6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jan 2012 11:01:58 -0500
In-Reply-To: <1327593714-18358-1-git-send-email-ariele@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use hardware locks to protect resources common to several Physical Functions. In
a virtualized environment the RTNL lock only protects a PF's driver against
the PFs sharing it's VMs with regard to device resources. Other PFs may reside
in other VMs under other OSs, and are not subject to the lock. Such resources
which were previously protected implicitly by the RTNL lock must now be
protected explicitly with dedicated HW locks.

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h    |    4 +-
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |   22 ++++++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |   73 +++++++++++---------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h    |    7 ++-
 4 files changed, 68 insertions(+), 38 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index 0dd22bb..bd990c2 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -1540,7 +1540,7 @@ static inline void bnx2x_update_drv_flags(struct bnx2x *bp, u32 flags, u32 set)
 {
 	if (SHMEM2_HAS(bp, drv_flags)) {
 		u32 drv_flags;
-		bnx2x_acquire_hw_lock(bp, HW_LOCK_DRV_FLAGS);
+		bnx2x_acquire_hw_lock(bp, HW_LOCK_RESOURCE_DRV_FLAGS);
 		drv_flags = SHMEM2_RD(bp, drv_flags);
 
 		if (set)
@@ -1550,7 +1550,7 @@ static inline void bnx2x_update_drv_flags(struct bnx2x *bp, u32 flags, u32 set)
 
 		SHMEM2_WR(bp, drv_flags, drv_flags);
 		DP(NETIF_MSG_HW, "drv_flags 0x%08x\n", drv_flags);
-		bnx2x_release_hw_lock(bp, HW_LOCK_DRV_FLAGS);
+		bnx2x_release_hw_lock(bp, HW_LOCK_RESOURCE_DRV_FLAGS);
 	}
 }
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 31a8b38..37a5c52 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -882,11 +882,27 @@ static int bnx2x_get_eeprom_len(struct net_device *dev)
 	return bp->common.flash_size;
 }
 
+/* Per pf misc lock must be aquired before the per port mcp lock. Otherwise, had
+ * we done things the other way around, if two pfs from the same port would
+ * attempt to access nvram at the same time, we could run into a scenario such
+ * as:
+ * pf A takes the port lock.
+ * pf B succeeds in taking the same lock since they are from the same port.
+ * pf A takes the per pf misc lock. Performs eeprom access.
+ * pf A finishes. Unlocks the per pf misc lock.
+ * Pf B takes the lock and proceeds to perform it's own access.
+ * pf A unlocks the per port lock, while pf B is still working (!).
+ * mcp takes the per port lock and corrupts pf B's access (and/or has it's own
+ * acess corrupted by pf B).*
+ */
 static int bnx2x_acquire_nvram_lock(struct bnx2x *bp)
 {
 	int port = BP_PORT(bp);
 	int count, i;
-	u32 val = 0;
+	u32 val;
+
+	/* acquire HW lock: protect against other PFs in PF Direct Assignment */
+	bnx2x_acquire_hw_lock(bp, HW_LOCK_RESOURCE_NVRAM);
 
 	/* adjust timeout for emulation/FPGA */
 	count = BNX2X_NVRAM_TIMEOUT_COUNT;
@@ -917,7 +933,7 @@ static int bnx2x_release_nvram_lock(struct bnx2x *bp)
 {
 	int port = BP_PORT(bp);
 	int count, i;
-	u32 val = 0;
+	u32 val;
 
 	/* adjust timeout for emulation/FPGA */
 	count = BNX2X_NVRAM_TIMEOUT_COUNT;
@@ -941,6 +957,8 @@ static int bnx2x_release_nvram_lock(struct bnx2x *bp)
 		return -EBUSY;
 	}
 
+	/* release HW lock: protect against other PFs in PF Direct Assignment */
+	bnx2x_release_hw_lock(bp, HW_LOCK_RESOURCE_NVRAM);
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 9a1c450..4824b0f 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -3724,11 +3724,11 @@ static inline void bnx2x_attn_int_deasserted3(struct bnx2x *bp, u32 attn)
  */
 void bnx2x_set_reset_global(struct bnx2x *bp)
 {
-	u32 val	= REG_RD(bp, BNX2X_RECOVERY_GLOB_REG);
-
+	u32 val;
+	bnx2x_acquire_hw_lock(bp, HW_LOCK_RESOURCE_RECOVERY_REG);
+	val = REG_RD(bp, BNX2X_RECOVERY_GLOB_REG);
 	REG_WR(bp, BNX2X_RECOVERY_GLOB_REG, val | BNX2X_GLOBAL_RESET_BIT);
-	barrier();
-	mmiowb();
+	bnx2x_release_hw_lock(bp, HW_LOCK_RESOURCE_RECOVERY_REG);
 }
 
 /*
@@ -3738,11 +3738,11 @@ void bnx2x_set_reset_global(struct bnx2x *bp)
  */
 static inline void bnx2x_clear_reset_global(struct bnx2x *bp)
 {
-	u32 val	= REG_RD(bp, BNX2X_RECOVERY_GLOB_REG);
-
+	u32 val;
+	bnx2x_acquire_hw_lock(bp, HW_LOCK_RESOURCE_RECOVERY_REG);
+	val = REG_RD(bp, BNX2X_RECOVERY_GLOB_REG);
 	REG_WR(bp, BNX2X_RECOVERY_GLOB_REG, val & (~BNX2X_GLOBAL_RESET_BIT));
-	barrier();
-	mmiowb();
+	bnx2x_release_hw_lock(bp, HW_LOCK_RESOURCE_RECOVERY_REG);
 }
 
 /*
@@ -3765,15 +3765,17 @@ static inline bool bnx2x_reset_is_global(struct bnx2x *bp)
  */
 static inline void bnx2x_set_reset_done(struct bnx2x *bp)
 {
-	u32 val	= REG_RD(bp, BNX2X_RECOVERY_GLOB_REG);
+	u32 val;
 	u32 bit = BP_PATH(bp) ?
 		BNX2X_PATH1_RST_IN_PROG_BIT : BNX2X_PATH0_RST_IN_PROG_BIT;
+	bnx2x_acquire_hw_lock(bp, HW_LOCK_RESOURCE_RECOVERY_REG);
+	val = REG_RD(bp, BNX2X_RECOVERY_GLOB_REG);
 
 	/* Clear the bit */
 	val &= ~bit;
 	REG_WR(bp, BNX2X_RECOVERY_GLOB_REG, val);
-	barrier();
-	mmiowb();
+
+	bnx2x_release_hw_lock(bp, HW_LOCK_RESOURCE_RECOVERY_REG);
 }
 
 /*
@@ -3783,15 +3785,16 @@ static inline void bnx2x_set_reset_done(struct bnx2x *bp)
  */
 void bnx2x_set_reset_in_progress(struct bnx2x *bp)
 {
-	u32 val	= REG_RD(bp, BNX2X_RECOVERY_GLOB_REG);
+	u32 val;
 	u32 bit = BP_PATH(bp) ?
 		BNX2X_PATH1_RST_IN_PROG_BIT : BNX2X_PATH0_RST_IN_PROG_BIT;
+	bnx2x_acquire_hw_lock(bp, HW_LOCK_RESOURCE_RECOVERY_REG);
+	val = REG_RD(bp, BNX2X_RECOVERY_GLOB_REG);
 
 	/* Set the bit */
 	val |= bit;
 	REG_WR(bp, BNX2X_RECOVERY_GLOB_REG, val);
-	barrier();
-	mmiowb();
+	bnx2x_release_hw_lock(bp, HW_LOCK_RESOURCE_RECOVERY_REG);
 }
 
 /*
@@ -3815,12 +3818,15 @@ bool bnx2x_reset_is_done(struct bnx2x *bp, int engine)
  */
 void bnx2x_inc_load_cnt(struct bnx2x *bp)
 {
-	u32 val1, val = REG_RD(bp, BNX2X_RECOVERY_GLOB_REG);
+	u32 val1, val;
 	u32 mask = BP_PATH(bp) ? BNX2X_PATH1_LOAD_CNT_MASK :
 			     BNX2X_PATH0_LOAD_CNT_MASK;
 	u32 shift = BP_PATH(bp) ? BNX2X_PATH1_LOAD_CNT_SHIFT :
 			     BNX2X_PATH0_LOAD_CNT_SHIFT;
 
+	bnx2x_acquire_hw_lock(bp, HW_LOCK_RESOURCE_RECOVERY_REG);
+	val = REG_RD(bp, BNX2X_RECOVERY_GLOB_REG);
+
 	DP(NETIF_MSG_HW, "Old GEN_REG_VAL=0x%08x\n", val);
 
 	/* get the current counter value */
@@ -3836,8 +3842,7 @@ void bnx2x_inc_load_cnt(struct bnx2x *bp)
 	val |= ((val1 << shift) & mask);
 
 	REG_WR(bp, BNX2X_RECOVERY_GLOB_REG, val);
-	barrier();
-	mmiowb();
+	bnx2x_release_hw_lock(bp, HW_LOCK_RESOURCE_RECOVERY_REG);
 }
 
 /**
@@ -3851,12 +3856,14 @@ void bnx2x_inc_load_cnt(struct bnx2x *bp)
  */
 u32 bnx2x_dec_load_cnt(struct bnx2x *bp)
 {
-	u32 val1, val = REG_RD(bp, BNX2X_RECOVERY_GLOB_REG);
+	u32 val1, val;
 	u32 mask = BP_PATH(bp) ? BNX2X_PATH1_LOAD_CNT_MASK :
 			     BNX2X_PATH0_LOAD_CNT_MASK;
 	u32 shift = BP_PATH(bp) ? BNX2X_PATH1_LOAD_CNT_SHIFT :
 			     BNX2X_PATH0_LOAD_CNT_SHIFT;
 
+	bnx2x_acquire_hw_lock(bp, HW_LOCK_RESOURCE_RECOVERY_REG);
+	val = REG_RD(bp, BNX2X_RECOVERY_GLOB_REG);
 	DP(NETIF_MSG_HW, "Old GEN_REG_VAL=0x%08x\n", val);
 
 	/* get the current counter value */
@@ -3872,10 +3879,8 @@ u32 bnx2x_dec_load_cnt(struct bnx2x *bp)
 	val |= ((val1 << shift) & mask);
 
 	REG_WR(bp, BNX2X_RECOVERY_GLOB_REG, val);
-	barrier();
-	mmiowb();
-
-	return val1;
+	bnx2x_release_hw_lock(bp, HW_LOCK_RESOURCE_RECOVERY_REG);
+	return val1 != 0;
 }
 
 /*
@@ -3907,11 +3912,13 @@ static inline u32 bnx2x_get_load_cnt(struct bnx2x *bp, int engine)
  */
 static inline void bnx2x_clear_load_cnt(struct bnx2x *bp)
 {
-	u32 val = REG_RD(bp, BNX2X_RECOVERY_GLOB_REG);
+	u32 val;
 	u32 mask = (BP_PATH(bp) ? BNX2X_PATH1_LOAD_CNT_MASK :
-			     BNX2X_PATH0_LOAD_CNT_MASK);
-
+		    BNX2X_PATH0_LOAD_CNT_MASK);
+	bnx2x_acquire_hw_lock(bp, HW_LOCK_RESOURCE_RECOVERY_REG);
+	val = REG_RD(bp, BNX2X_RECOVERY_GLOB_REG);
 	REG_WR(bp, BNX2X_RECOVERY_GLOB_REG, val & (~mask));
+	bnx2x_release_hw_lock(bp, HW_LOCK_RESOURCE_RECOVERY_REG);
 }
 
 static inline void _print_next_block(int idx, const char *blk)
@@ -8809,11 +8816,13 @@ static void __devinit bnx2x_undi_unload(struct bnx2x *bp)
 {
 	u32 val;
 
-	/* Check if there is any driver already loaded */
-	val = REG_RD(bp, MISC_REG_UNPREPARED);
-	if (val == 0x1) {
+	/* possibly another driver is trying to reset the chip */
+	bnx2x_acquire_hw_lock(bp, HW_LOCK_RESOURCE_RESET);
+
+	/* check if doorbell queue is reset */
+	if (REG_RD(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_1_SET)
+	    & MISC_REGISTERS_RESET_REG_1_RST_DORQ) {
 
-		bnx2x_acquire_hw_lock(bp, HW_LOCK_RESOURCE_RESET);
 		/*
 		 * Check if it is the UNDI driver
 		 * UNDI driver initializes CID offset for normal bell to 0x7
@@ -8905,10 +8914,10 @@ static void __devinit bnx2x_undi_unload(struct bnx2x *bp)
 			      (SHMEM_RD(bp, func_mb[bp->pf_num].drv_mb_header) &
 				DRV_MSG_SEQ_NUMBER_MASK);
 		}
-
-		/* now it's safe to release the lock */
-		bnx2x_release_hw_lock(bp, HW_LOCK_RESOURCE_RESET);
 	}
+
+	/* now it's safe to release the lock */
+	bnx2x_release_hw_lock(bp, HW_LOCK_RESOURCE_RESET);
 }
 
 static void __devinit bnx2x_get_common_hwinfo(struct bnx2x *bp)
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
index 8c79e00..8ade7bd 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
@@ -5731,6 +5731,7 @@
 #define MISC_REGISTERS_GPIO_PORT_SHIFT				 4
 #define MISC_REGISTERS_GPIO_SET_POS				 8
 #define MISC_REGISTERS_RESET_REG_1_CLEAR			 0x588
+#define MISC_REGISTERS_RESET_REG_1_RST_DORQ			 (0x1<<19)
 #define MISC_REGISTERS_RESET_REG_1_RST_HC			 (0x1<<29)
 #define MISC_REGISTERS_RESET_REG_1_RST_NIG			 (0x1<<7)
 #define MISC_REGISTERS_RESET_REG_1_RST_PXP			 (0x1<<26)
@@ -5783,15 +5784,17 @@
 #define MISC_REGISTERS_SPIO_OUTPUT_HIGH 			 1
 #define MISC_REGISTERS_SPIO_OUTPUT_LOW				 0
 #define MISC_REGISTERS_SPIO_SET_POS				 8
-#define HW_LOCK_DRV_FLAGS					 10
 #define HW_LOCK_MAX_RESOURCE_VALUE				 31
+#define HW_LOCK_RESOURCE_DRV_FLAGS				 10
 #define HW_LOCK_RESOURCE_GPIO					 1
 #define HW_LOCK_RESOURCE_MDIO					 0
+#define HW_LOCK_RESOURCE_NVRAM					 12
 #define HW_LOCK_RESOURCE_PORT0_ATT_MASK				 3
 #define HW_LOCK_RESOURCE_RECOVERY_LEADER_0			 8
 #define HW_LOCK_RESOURCE_RECOVERY_LEADER_1			 9
-#define HW_LOCK_RESOURCE_SPIO					 2
+#define HW_LOCK_RESOURCE_RECOVERY_REG				 11
 #define HW_LOCK_RESOURCE_RESET					 5
+#define HW_LOCK_RESOURCE_SPIO					 2
 #define AEU_INPUTS_ATTN_BITS_ATC_HW_INTERRUPT			 (0x1<<4)
 #define AEU_INPUTS_ATTN_BITS_ATC_PARITY_ERROR			 (0x1<<5)
 #define AEU_INPUTS_ATTN_BITS_BRB_PARITY_ERROR			 (0x1<<18)
-- 
1.7.1
