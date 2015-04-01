From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net 2/2] bnx2x: Fix kdump when iommu=on
Date: Wed, 1 Apr 2015 10:02:20 +0300
Message-ID: <1427871740-26271-3-git-send-email-Yuval.Mintz@qlogic.com>
References: <1427871740-26271-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:30419 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752228AbbDAHDE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 03:03:04 -0400
In-Reply-To: <1427871740-26271-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When IOMM-vtd is active, once main kernel crashes unfinished DMAE transactions
will be blocked, putting the HW in an error state which will cause further
transactions to timeout.

Current employed logic uses wrong macros, causing the first function to be the
only function that cleanups that error state during its probe/load.

This patch allows all the functions to successfully re-load in kdump kernel.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 39 ++++++++++--------------
 1 file changed, 16 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index f391edb..16b56b1 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -7866,6 +7866,20 @@ int bnx2x_init_hw_func_cnic(struct bnx2x *bp)
 	return 0;
 }
 
+/* previous driver DMAE transaction may have occurred when pre-boot stage ended
+ * and boot began, or when kdump kernel was loaded. Either case would invalidate
+ * the addresses of the transaction, resulting in was-error bit set in the pci
+ * causing all hw-to-host pcie transactions to timeout. If this happened we want
+ * to clear the interrupt which detected this from the pglueb and the was done
+ * bit
+ */
+static void bnx2x_clean_pglue_errors(struct bnx2x *bp)
+{
+	if (!CHIP_IS_E1x(bp))
+		REG_WR(bp, PGLUE_B_REG_WAS_ERROR_PF_7_0_CLR,
+		       1 << BP_ABS_FUNC(bp));
+}
+
 static int bnx2x_init_hw_func(struct bnx2x *bp)
 {
 	int port = BP_PORT(bp);
@@ -7958,8 +7972,7 @@ static int bnx2x_init_hw_func(struct bnx2x *bp)
 
 	bnx2x_init_block(bp, BLOCK_PGLUE_B, init_phase);
 
-	if (!CHIP_IS_E1x(bp))
-		REG_WR(bp, PGLUE_B_REG_WAS_ERROR_PF_7_0_CLR, func);
+	bnx2x_clean_pglue_errors(bp);
 
 	bnx2x_init_block(bp, BLOCK_ATC, init_phase);
 	bnx2x_init_block(bp, BLOCK_DMAE, init_phase);
@@ -10588,26 +10601,6 @@ static int bnx2x_prev_unload_common(struct bnx2x *bp)
 	return bnx2x_prev_mcp_done(bp);
 }
 
-/* previous driver DMAE transaction may have occurred when pre-boot stage ended
- * and boot began, or when kdump kernel was loaded. Either case would invalidate
- * the addresses of the transaction, resulting in was-error bit set in the pci
- * causing all hw-to-host pcie transactions to timeout. If this happened we want
- * to clear the interrupt which detected this from the pglueb and the was done
- * bit
- */
-static void bnx2x_prev_interrupted_dmae(struct bnx2x *bp)
-{
-	if (!CHIP_IS_E1x(bp)) {
-		u32 val = REG_RD(bp, PGLUE_B_REG_PGLUE_B_INT_STS);
-		if (val & PGLUE_B_PGLUE_B_INT_STS_REG_WAS_ERROR_ATTN) {
-			DP(BNX2X_MSG_SP,
-			   "'was error' bit was found to be set in pglueb upon startup. Clearing\n");
-			REG_WR(bp, PGLUE_B_REG_WAS_ERROR_PF_7_0_CLR,
-			       1 << BP_FUNC(bp));
-		}
-	}
-}
-
 static int bnx2x_prev_unload(struct bnx2x *bp)
 {
 	int time_counter = 10;
@@ -10617,7 +10610,7 @@ static int bnx2x_prev_unload(struct bnx2x *bp)
 	/* clear hw from errors which may have resulted from an interrupted
 	 * dmae transaction.
 	 */
-	bnx2x_prev_interrupted_dmae(bp);
+	bnx2x_clean_pglue_errors(bp);
 
 	/* Release previously held locks */
 	hw_lock_reg = (BP_FUNC(bp) <= 5) ?
-- 
1.9.3
