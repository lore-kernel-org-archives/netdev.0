From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 10/13] bnx2x: Handle a rarely missed interrupt
Date: Sun, 2 Dec 2012 16:05:54 +0200
Message-ID: <1354457157-4730-11-git-send-email-yuvalmin@broadcom.com>
References: <1354457157-4730-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yaniv Rosner" <yaniv.rosner@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2561 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753190Ab2LBOFP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Dec 2012 09:05:15 -0500
In-Reply-To: <1354457157-4730-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yaniv Rosner <yaniv.rosner@broadcom.com>

A rare case of no link due to a missed interrupt may occur due to a
race condition between acknowledging the IGU via the BAR and restoring the NIG
interrupt mask via the GRC.
To solve it, we wait for the IGU ack command to finish prior to restoring the
NIG interrupt mask.

Signed-off-by: Yaniv Rosner <yaniv.rosner@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |    1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   15 +++++++++++++++
 2 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 03647bf..02ea644 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -915,6 +915,7 @@ struct bnx2x_common {
 #define BNX2X_IGU_STAS_MSG_VF_CNT 64
 #define BNX2X_IGU_STAS_MSG_PF_CNT 4
 
+#define MAX_IGU_ATTN_ACK_TO       100
 /* end of common */
 
 /* port */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 983a0c8..d76ca90 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -3588,6 +3588,21 @@ static void bnx2x_attn_int_asserted(struct bnx2x *bp, u32 asserted)
 
 	/* now set back the mask */
 	if (asserted & ATTN_NIG_FOR_FUNC) {
+		/* Verify that IGU ack through BAR was written before restoring
+		 * NIG mask. This loop should exit after 2-3 iterations max.
+		 */
+		if (bp->common.int_block != INT_BLOCK_HC) {
+			u32 cnt = 0, igu_acked;
+			do {
+				igu_acked = REG_RD(bp,
+						   IGU_REG_ATTENTION_ACK_BITS);
+			} while (((igu_acked & ATTN_NIG_FOR_FUNC) == 0) &&
+				 (++cnt < MAX_IGU_ATTN_ACK_TO));
+			if (!igu_acked)
+				DP(NETIF_MSG_HW,
+				   "Failed to verify IGU ack on time\n");
+			barrier();
+		}
 		REG_WR(bp, nig_int_mask_addr, nig_mask);
 		bnx2x_release_phy_lock(bp);
 	}
-- 
1.7.1
