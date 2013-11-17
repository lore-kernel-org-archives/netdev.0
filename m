From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net 2/4] bnx2x: Prevent panic during DMAE timeout
Date: Sun, 17 Nov 2013 08:59:27 +0200
Message-ID: <1384671569-30105-3-git-send-email-yuvalmin@broadcom.com>
References: <1384671569-30105-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, dmitry@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3131 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750790Ab3KQG7n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Nov 2013 01:59:43 -0500
In-Reply-To: <1384671569-30105-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

If chip enters a recovery flow just after the driver issues a DMAE request
the DMAE will timeout. Current code will cause a bnx2x_panic() as a result,
which means interface will no longer be usable (regardless of the recovery
results), as bnx2x_panic() is irreversible for the driver.

As this is a possible flow, the panic should be reached only when driver
is compiled with STOP_ON_ERROR.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |  8 ++++++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h  | 11 +++++++++++
 2 files changed, 19 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index b42f89c..1d799ee 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -577,7 +577,9 @@ void bnx2x_write_dmae(struct bnx2x *bp, dma_addr_t dma_addr, u32 dst_addr,
 	rc = bnx2x_issue_dmae_with_comp(bp, &dmae, bnx2x_sp(bp, wb_comp));
 	if (rc) {
 		BNX2X_ERR("DMAE returned failure %d\n", rc);
+#ifdef BNX2X_STOP_ON_ERROR
 		bnx2x_panic();
+#endif
 	}
 }
 
@@ -614,7 +616,9 @@ void bnx2x_read_dmae(struct bnx2x *bp, u32 src_addr, u32 len32)
 	rc = bnx2x_issue_dmae_with_comp(bp, &dmae, bnx2x_sp(bp, wb_comp));
 	if (rc) {
 		BNX2X_ERR("DMAE returned failure %d\n", rc);
+#ifdef BNX2X_STOP_ON_ERROR
 		bnx2x_panic();
+#endif
 	}
 }
 
@@ -9352,6 +9356,10 @@ static int bnx2x_process_kill(struct bnx2x *bp, bool global)
 	bnx2x_process_kill_chip_reset(bp, global);
 	barrier();
 
+	/* clear errors in PGB */
+	if (!CHIP_IS_E1x(bp))
+		REG_WR(bp, PGLUE_B_REG_LATCHED_ERRORS_CLR, 0x7f);
+
 	/* Recover after reset: */
 	/* MCP */
 	if (global && bnx2x_reset_mcp_comp(bp, val))
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
index 5ecf267..3efbb35 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
@@ -2864,6 +2864,17 @@
 #define PGLUE_B_REG_INTERNAL_PFID_ENABLE_TARGET_READ		 0x9430
 #define PGLUE_B_REG_INTERNAL_PFID_ENABLE_TARGET_WRITE		 0x9434
 #define PGLUE_B_REG_INTERNAL_VFID_ENABLE			 0x9438
+/* [W 7] Writing 1 to each bit in this register clears a corresponding error
+ * details register and enables logging new error details. Bit 0 - clears
+ * INCORRECT_RCV_DETAILS; Bit 1 - clears RX_ERR_DETAILS; Bit 2 - clears
+ * TX_ERR_WR_ADD_31_0 TX_ERR_WR_ADD_63_32 TX_ERR_WR_DETAILS
+ * TX_ERR_WR_DETAILS2 TX_ERR_RD_ADD_31_0 TX_ERR_RD_ADD_63_32
+ * TX_ERR_RD_DETAILS TX_ERR_RD_DETAILS2 TX_ERR_WR_DETAILS_ICPL; Bit 3 -
+ * clears VF_LENGTH_VIOLATION_DETAILS. Bit 4 - clears
+ * VF_GRC_SPACE_VIOLATION_DETAILS. Bit 5 - clears RX_TCPL_ERR_DETAILS. Bit 6
+ * - clears TCPL_IN_TWO_RCBS_DETAILS. */
+#define PGLUE_B_REG_LATCHED_ERRORS_CLR				 0x943c
+
 /* [R 9] Interrupt register #0 read */
 #define PGLUE_B_REG_PGLUE_B_INT_STS				 0x9298
 /* [RC 9] Interrupt register #0 read clear */
-- 
1.8.1.227.g44fe835
