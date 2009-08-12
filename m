From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 23/36] bnx2x: Remove the init_dmae field from bp
Date: Wed, 12 Aug 2009 21:23:44 +0300
Message-ID: <1250101424.27379.175.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Benjamin Li" <benli@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3470 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753251AbZHLSYk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2009 14:24:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moved the dmae_command from the heap to the stack.  This will save 56
bytes per bnx2x structure.   As a side benefit, we can also reduce the
time the dmae_mutex is held.  This is because do we not need to hold
this mutex when setting up the dmae command.  The memory where is dmae
command is stored is not a shared resource and doesn not need to be
protected.

Signed-off-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |    1 -
 drivers/net/bnx2x_main.c |   94 +++++++++++++++++++++++-----------------------
 2 files changed, 47 insertions(+), 48 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 633acca..a231780 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -973,7 +973,6 @@ struct bnx2x {
 	int			dmae_ready;
 	/* used to synchronize dmae accesses */
 	struct mutex		dmae_mutex;
-	struct dmae_command	init_dmae;
 
 	/* used to synchronize stats collecting */
 	int			stats_state;
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index dd9a77f..cfcc4ee 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -203,7 +203,7 @@ static void bnx2x_post_dmae(struct bnx2x *bp, struct dmae_command *dmae,
 void bnx2x_write_dmae(struct bnx2x *bp, dma_addr_t dma_addr, u32 dst_addr,
 		      u32 len32)
 {
-	struct dmae_command *dmae = &bp->init_dmae;
+	struct dmae_command dmae;
 	u32 *wb_comp = bnx2x_sp(bp, wb_comp);
 	int cnt = 200;
 
@@ -216,43 +216,43 @@ void bnx2x_write_dmae(struct bnx2x *bp, dma_addr_t dma_addr, u32 dst_addr,
 		return;
 	}
 
-	mutex_lock(&bp->dmae_mutex);
-
-	memset(dmae, 0, sizeof(struct dmae_command));
+	memset(&dmae, 0, sizeof(struct dmae_command));
 
-	dmae->opcode = (DMAE_CMD_SRC_PCI | DMAE_CMD_DST_GRC |
-			DMAE_CMD_C_DST_PCI | DMAE_CMD_C_ENABLE |
-			DMAE_CMD_SRC_RESET | DMAE_CMD_DST_RESET |
+	dmae.opcode = (DMAE_CMD_SRC_PCI | DMAE_CMD_DST_GRC |
+		       DMAE_CMD_C_DST_PCI | DMAE_CMD_C_ENABLE |
+		       DMAE_CMD_SRC_RESET | DMAE_CMD_DST_RESET |
 #ifdef __BIG_ENDIAN
-			DMAE_CMD_ENDIANITY_B_DW_SWAP |
+		       DMAE_CMD_ENDIANITY_B_DW_SWAP |
 #else
-			DMAE_CMD_ENDIANITY_DW_SWAP |
+		       DMAE_CMD_ENDIANITY_DW_SWAP |
 #endif
-			(BP_PORT(bp) ? DMAE_CMD_PORT_1 : DMAE_CMD_PORT_0) |
-			(BP_E1HVN(bp) << DMAE_CMD_E1HVN_SHIFT));
-	dmae->src_addr_lo = U64_LO(dma_addr);
-	dmae->src_addr_hi = U64_HI(dma_addr);
-	dmae->dst_addr_lo = dst_addr >> 2;
-	dmae->dst_addr_hi = 0;
-	dmae->len = len32;
-	dmae->comp_addr_lo = U64_LO(bnx2x_sp_mapping(bp, wb_comp));
-	dmae->comp_addr_hi = U64_HI(bnx2x_sp_mapping(bp, wb_comp));
-	dmae->comp_val = DMAE_COMP_VAL;
+		       (BP_PORT(bp) ? DMAE_CMD_PORT_1 : DMAE_CMD_PORT_0) |
+		       (BP_E1HVN(bp) << DMAE_CMD_E1HVN_SHIFT));
+	dmae.src_addr_lo = U64_LO(dma_addr);
+	dmae.src_addr_hi = U64_HI(dma_addr);
+	dmae.dst_addr_lo = dst_addr >> 2;
+	dmae.dst_addr_hi = 0;
+	dmae.len = len32;
+	dmae.comp_addr_lo = U64_LO(bnx2x_sp_mapping(bp, wb_comp));
+	dmae.comp_addr_hi = U64_HI(bnx2x_sp_mapping(bp, wb_comp));
+	dmae.comp_val = DMAE_COMP_VAL;
 
 	DP(BNX2X_MSG_OFF, "DMAE: opcode 0x%08x\n"
 	   DP_LEVEL "src_addr  [%x:%08x]  len [%d *4]  "
 		    "dst_addr [%x:%08x (%08x)]\n"
 	   DP_LEVEL "comp_addr [%x:%08x]  comp_val 0x%08x\n",
-	   dmae->opcode, dmae->src_addr_hi, dmae->src_addr_lo,
-	   dmae->len, dmae->dst_addr_hi, dmae->dst_addr_lo, dst_addr,
-	   dmae->comp_addr_hi, dmae->comp_addr_lo, dmae->comp_val);
+	   dmae.opcode, dmae.src_addr_hi, dmae.src_addr_lo,
+	   dmae.len, dmae.dst_addr_hi, dmae.dst_addr_lo, dst_addr,
+	   dmae.comp_addr_hi, dmae.comp_addr_lo, dmae.comp_val);
 	DP(BNX2X_MSG_OFF, "data [0x%08x 0x%08x 0x%08x 0x%08x]\n",
 	   bp->slowpath->wb_data[0], bp->slowpath->wb_data[1],
 	   bp->slowpath->wb_data[2], bp->slowpath->wb_data[3]);
 
+	mutex_lock(&bp->dmae_mutex);
+
 	*wb_comp = 0;
 
-	bnx2x_post_dmae(bp, dmae, INIT_DMAE_C(bp));
+	bnx2x_post_dmae(bp, &dmae, INIT_DMAE_C(bp));
 
 	udelay(5);
 
@@ -276,7 +276,7 @@ void bnx2x_write_dmae(struct bnx2x *bp, dma_addr_t dma_addr, u32 dst_addr,
 
 void bnx2x_read_dmae(struct bnx2x *bp, u32 src_addr, u32 len32)
 {
-	struct dmae_command *dmae = &bp->init_dmae;
+	struct dmae_command dmae;
 	u32 *wb_comp = bnx2x_sp(bp, wb_comp);
 	int cnt = 200;
 
@@ -291,41 +291,41 @@ void bnx2x_read_dmae(struct bnx2x *bp, u32 src_addr, u32 len32)
 		return;
 	}
 
-	mutex_lock(&bp->dmae_mutex);
-
-	memset(bnx2x_sp(bp, wb_data[0]), 0, sizeof(u32) * 4);
-	memset(dmae, 0, sizeof(struct dmae_command));
+	memset(&dmae, 0, sizeof(struct dmae_command));
 
-	dmae->opcode = (DMAE_CMD_SRC_GRC | DMAE_CMD_DST_PCI |
-			DMAE_CMD_C_DST_PCI | DMAE_CMD_C_ENABLE |
-			DMAE_CMD_SRC_RESET | DMAE_CMD_DST_RESET |
+	dmae.opcode = (DMAE_CMD_SRC_GRC | DMAE_CMD_DST_PCI |
+		       DMAE_CMD_C_DST_PCI | DMAE_CMD_C_ENABLE |
+		       DMAE_CMD_SRC_RESET | DMAE_CMD_DST_RESET |
 #ifdef __BIG_ENDIAN
-			DMAE_CMD_ENDIANITY_B_DW_SWAP |
+		       DMAE_CMD_ENDIANITY_B_DW_SWAP |
 #else
-			DMAE_CMD_ENDIANITY_DW_SWAP |
+		       DMAE_CMD_ENDIANITY_DW_SWAP |
 #endif
-			(BP_PORT(bp) ? DMAE_CMD_PORT_1 : DMAE_CMD_PORT_0) |
-			(BP_E1HVN(bp) << DMAE_CMD_E1HVN_SHIFT));
-	dmae->src_addr_lo = src_addr >> 2;
-	dmae->src_addr_hi = 0;
-	dmae->dst_addr_lo = U64_LO(bnx2x_sp_mapping(bp, wb_data));
-	dmae->dst_addr_hi = U64_HI(bnx2x_sp_mapping(bp, wb_data));
-	dmae->len = len32;
-	dmae->comp_addr_lo = U64_LO(bnx2x_sp_mapping(bp, wb_comp));
-	dmae->comp_addr_hi = U64_HI(bnx2x_sp_mapping(bp, wb_comp));
-	dmae->comp_val = DMAE_COMP_VAL;
+		       (BP_PORT(bp) ? DMAE_CMD_PORT_1 : DMAE_CMD_PORT_0) |
+		       (BP_E1HVN(bp) << DMAE_CMD_E1HVN_SHIFT));
+	dmae.src_addr_lo = src_addr >> 2;
+	dmae.src_addr_hi = 0;
+	dmae.dst_addr_lo = U64_LO(bnx2x_sp_mapping(bp, wb_data));
+	dmae.dst_addr_hi = U64_HI(bnx2x_sp_mapping(bp, wb_data));
+	dmae.len = len32;
+	dmae.comp_addr_lo = U64_LO(bnx2x_sp_mapping(bp, wb_comp));
+	dmae.comp_addr_hi = U64_HI(bnx2x_sp_mapping(bp, wb_comp));
+	dmae.comp_val = DMAE_COMP_VAL;
 
 	DP(BNX2X_MSG_OFF, "DMAE: opcode 0x%08x\n"
 	   DP_LEVEL "src_addr  [%x:%08x]  len [%d *4]  "
 		    "dst_addr [%x:%08x (%08x)]\n"
 	   DP_LEVEL "comp_addr [%x:%08x]  comp_val 0x%08x\n",
-	   dmae->opcode, dmae->src_addr_hi, dmae->src_addr_lo,
-	   dmae->len, dmae->dst_addr_hi, dmae->dst_addr_lo, src_addr,
-	   dmae->comp_addr_hi, dmae->comp_addr_lo, dmae->comp_val);
+	   dmae.opcode, dmae.src_addr_hi, dmae.src_addr_lo,
+	   dmae.len, dmae.dst_addr_hi, dmae.dst_addr_lo, src_addr,
+	   dmae.comp_addr_hi, dmae.comp_addr_lo, dmae.comp_val);
 
+	mutex_lock(&bp->dmae_mutex);
+
+	memset(bnx2x_sp(bp, wb_data[0]), 0, sizeof(u32) * 4);
 	*wb_comp = 0;
 
-	bnx2x_post_dmae(bp, dmae, INIT_DMAE_C(bp));
+	bnx2x_post_dmae(bp, &dmae, INIT_DMAE_C(bp));
 
 	udelay(5);
 
-- 
1.5.4.3




