From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 09/13] bnx2x: mask CPL_OF interrupt
Date: Sun, 2 Dec 2012 16:05:53 +0200
Message-ID: <1354457157-4730-10-git-send-email-yuvalmin@broadcom.com>
References: <1354457157-4730-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2488 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753190Ab2LBOFT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Dec 2012 09:05:19 -0500
In-Reply-To: <1354457157-4730-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unmasked interrupt caused "FATAL HW block attention set2 0x20" messages
to erroneously appear, as the associated interrupt is fully recoverable.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   21 ++++++++++-----------
 1 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 5ff0bcb..983a0c8 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -6059,6 +6059,8 @@ static int bnx2x_int_mem_test(struct bnx2x *bp)
 
 static void bnx2x_enable_blocks_attention(struct bnx2x *bp)
 {
+	u32 val;
+
 	REG_WR(bp, PXP_REG_PXP_INT_MASK_0, 0);
 	if (!CHIP_IS_E1x(bp))
 		REG_WR(bp, PXP_REG_PXP_INT_MASK_1, 0x40);
@@ -6092,17 +6094,14 @@ static void bnx2x_enable_blocks_attention(struct bnx2x *bp)
 /*	REG_WR(bp, CSEM_REG_CSEM_INT_MASK_0, 0); */
 /*	REG_WR(bp, CSEM_REG_CSEM_INT_MASK_1, 0); */
 
-	if (CHIP_REV_IS_FPGA(bp))
-		REG_WR(bp, PXP2_REG_PXP2_INT_MASK_0, 0x580000);
-	else if (!CHIP_IS_E1x(bp))
-		REG_WR(bp, PXP2_REG_PXP2_INT_MASK_0,
-			   (PXP2_PXP2_INT_MASK_0_REG_PGL_CPL_OF
-				| PXP2_PXP2_INT_MASK_0_REG_PGL_CPL_AFT
-				| PXP2_PXP2_INT_MASK_0_REG_PGL_PCIE_ATTN
-				| PXP2_PXP2_INT_MASK_0_REG_PGL_READ_BLOCKED
-				| PXP2_PXP2_INT_MASK_0_REG_PGL_WRITE_BLOCKED));
-	else
-		REG_WR(bp, PXP2_REG_PXP2_INT_MASK_0, 0x480000);
+	val = PXP2_PXP2_INT_MASK_0_REG_PGL_CPL_AFT  |
+		PXP2_PXP2_INT_MASK_0_REG_PGL_CPL_OF |
+		PXP2_PXP2_INT_MASK_0_REG_PGL_PCIE_ATTN;
+	if (!CHIP_IS_E1x(bp))
+		val |= PXP2_PXP2_INT_MASK_0_REG_PGL_READ_BLOCKED |
+			PXP2_PXP2_INT_MASK_0_REG_PGL_WRITE_BLOCKED;
+	REG_WR(bp, PXP2_REG_PXP2_INT_MASK_0, val);
+
 	REG_WR(bp, TSDM_REG_TSDM_INT_MASK_0, 0);
 	REG_WR(bp, TSDM_REG_TSDM_INT_MASK_1, 0);
 	REG_WR(bp, TCM_REG_TCM_INT_MASK, 0);
-- 
1.7.1
