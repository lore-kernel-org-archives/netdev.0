From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 07/25] bnx2x: HW attention lock
Date: Wed, 13 Aug 2008 17:13:37 +0300
Message-ID: <1218636817.547.83.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4376 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756010AbYHMONw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2008 10:13:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HW attention lock
Making sure that only one function will handle the HW attention. This
makes the device parameter aeu_mask redundant so it is removed

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |    1 -
 drivers/net/bnx2x_main.c |   42 ++++++++++++++++++++++++------------------
 drivers/net/bnx2x_reg.h  |    1 +
 3 files changed, 25 insertions(+), 19 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index b9aa6f4..3b09ae6 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -774,7 +774,6 @@ struct bnx2x {
 	u16			def_att_idx;
 	u32			attn_state;
 	struct attn_route	attn_group[MAX_DYNAMIC_ATTN_GRPS];
-	u32			aeu_mask;
 	u32			nig_mask;
 
 	/* slow path ring */
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 3e86ff4..c8b6178 100755
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -2450,20 +2450,25 @@ static void bnx2x_attn_int_asserted(struct bnx2x *bp, u32 asserted)
 			      MISC_REG_AEU_MASK_ATTN_FUNC_0;
 	u32 nig_int_mask_addr = port ? NIG_REG_MASK_INTERRUPT_PORT1 :
 				       NIG_REG_MASK_INTERRUPT_PORT0;
+	u32 aeu_mask;
 
-	if (~bp->aeu_mask & (asserted & 0xff))
-		BNX2X_ERR("IGU ERROR\n");
 	if (bp->attn_state & asserted)
 		BNX2X_ERR("IGU ERROR\n");
 
+	bnx2x_acquire_hw_lock(bp, HW_LOCK_RESOURCE_PORT0_ATT_MASK + port);
+	aeu_mask = REG_RD(bp, aeu_addr);
+
 	DP(NETIF_MSG_HW, "aeu_mask %x  newly asserted %x\n",
-	   bp->aeu_mask, asserted);
-	bp->aeu_mask &= ~(asserted & 0xff);
-	DP(NETIF_MSG_HW, "after masking: aeu_mask %x\n", bp->aeu_mask);
+	   aeu_mask, asserted);
+	aeu_mask &= ~(asserted & 0xff);
+	DP(NETIF_MSG_HW, "new mask %x\n", aeu_mask);
 
-	REG_WR(bp, aeu_addr, bp->aeu_mask);
+	REG_WR(bp, aeu_addr, aeu_mask);
+	bnx2x_release_hw_lock(bp, HW_LOCK_RESOURCE_PORT0_ATT_MASK + port);
 
+	DP(NETIF_MSG_HW, "attn_state %x\n", bp->attn_state);
 	bp->attn_state |= asserted;
+	DP(NETIF_MSG_HW, "new state %x\n", bp->attn_state);
 
 	if (asserted & ATTN_HARD_WIRED_MASK) {
 		if (asserted & ATTN_NIG_FOR_FUNC) {
@@ -2717,6 +2722,7 @@ static void bnx2x_attn_int_deasserted(struct bnx2x *bp, u32 deasserted)
 	int index;
 	u32 reg_addr;
 	u32 val;
+	u32 aeu_mask;
 
 	/* need to take HW lock because MCP or other port might also
 	   try to handle this event */
@@ -2761,23 +2767,26 @@ static void bnx2x_attn_int_deasserted(struct bnx2x *bp, u32 deasserted)
 	reg_addr = (IGU_ADDR_ATTN_BITS_CLR + IGU_FUNC_BASE * BP_FUNC(bp)) * 8;
 
 	val = ~deasserted;
-/*	DP(NETIF_MSG_INTR, "write 0x%08x to IGU addr 0x%x\n",
-	   val, BAR_IGU_INTMEM + reg_addr); */
+	DP(NETIF_MSG_HW, "about to mask 0x%08x at HC addr 0x%x\n",
+	   val, reg_addr);
 	REG_WR(bp, BAR_IGU_INTMEM + reg_addr, val);
 
-	if (bp->aeu_mask & (deasserted & 0xff))
-		BNX2X_ERR("IGU BUG!\n");
 	if (~bp->attn_state & deasserted)
-		BNX2X_ERR("IGU BUG!\n");
+		BNX2X_ERR("IGU ERROR\n");
 
 	reg_addr = port ? MISC_REG_AEU_MASK_ATTN_FUNC_1 :
 			  MISC_REG_AEU_MASK_ATTN_FUNC_0;
 
-	DP(NETIF_MSG_HW, "aeu_mask %x\n", bp->aeu_mask);
-	bp->aeu_mask |= (deasserted & 0xff);
+	bnx2x_acquire_hw_lock(bp, HW_LOCK_RESOURCE_PORT0_ATT_MASK + port);
+	aeu_mask = REG_RD(bp, reg_addr);
+
+	DP(NETIF_MSG_HW, "aeu_mask %x  newly deasserted %x\n",
+	   aeu_mask, deasserted);
+	aeu_mask |= (deasserted & 0xff);
+	DP(NETIF_MSG_HW, "new mask %x\n", aeu_mask);
 
-	DP(NETIF_MSG_HW, "new mask %x\n", bp->aeu_mask);
-	REG_WR(bp, reg_addr, bp->aeu_mask);
+	REG_WR(bp, reg_addr, aeu_mask);
+	bnx2x_release_hw_lock(bp, HW_LOCK_RESOURCE_PORT0_ATT_MASK + port);
 
 	DP(NETIF_MSG_HW, "attn_state %x\n", bp->attn_state);
 	bp->attn_state &= ~deasserted;
@@ -4083,9 +4092,6 @@ static void bnx2x_init_def_sb(struct bnx2x *bp,
 					       reg_offset + 0xc + 0x10*index);
 	}
 
-	bp->aeu_mask = REG_RD(bp, (port ? MISC_REG_AEU_MASK_ATTN_FUNC_1 :
-					  MISC_REG_AEU_MASK_ATTN_FUNC_0));
-
 	reg_offset = (port ? HC_REG_ATTN_MSG1_ADDR_L :
 			     HC_REG_ATTN_MSG0_ADDR_L);
 
diff --git a/drivers/net/bnx2x_reg.h b/drivers/net/bnx2x_reg.h
index 3f65dff..f72ffd2 100644
--- a/drivers/net/bnx2x_reg.h
+++ b/drivers/net/bnx2x_reg.h
@@ -5015,6 +5015,7 @@
 #define HW_LOCK_MAX_RESOURCE_VALUE				 31
 #define HW_LOCK_RESOURCE_8072_MDIO				 0
 #define HW_LOCK_RESOURCE_GPIO					 1
+#define HW_LOCK_RESOURCE_PORT0_ATT_MASK 			 3
 #define HW_LOCK_RESOURCE_SPIO					 2
 #define HW_LOCK_RESOURCE_UNDI					 5
 #define AEU_INPUTS_ATTN_BITS_BRB_PARITY_ERROR		      (1<<18)
-- 
1.5.3.2




