From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 1/7] bnx2x: Refactor bnx2x_sp_post().
Date: Sat, 10 Oct 2009 16:46:53 -0700
Message-ID: <1255218419-17320-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, michaelc@cs.wisc.edu,
	shmulikr@broadcom.com, eilong@broadcom.com,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1960 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755479AbZJJXjH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Oct 2009 19:39:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some of the SPQ (slow-path queue) operations will be used
by the cnic code in later patches.

Signed-off-by: Shmulik Ravid - Rabinovitz <shmulikr@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
Acked-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |   62 ++++++++++++++++++++++++++++-----------------
 1 files changed, 38 insertions(+), 24 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index c0abfc4..713d669 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -2638,11 +2638,40 @@ static void bnx2x_dcc_event(struct bnx2x *bp, u32 dcc_event)
 		bnx2x_fw_command(bp, DRV_MSG_CODE_DCC_OK);
 }
 
+/* must be called under the spq lock */
+static inline struct eth_spe *bnx2x_sp_get_next(struct bnx2x *bp)
+{
+	struct eth_spe *next_spe = bp->spq_prod_bd;
+
+	if (bp->spq_prod_bd == bp->spq_last_bd) {
+		bp->spq_prod_bd = bp->spq;
+		bp->spq_prod_idx = 0;
+		DP(NETIF_MSG_TIMER, "end of spq\n");
+	} else {
+		bp->spq_prod_bd++;
+		bp->spq_prod_idx++;
+	}
+	return next_spe;
+}
+
+/* must be called under the spq lock */
+static inline void bnx2x_sp_prod_update(struct bnx2x *bp)
+{
+	int func = BP_FUNC(bp);
+
+	/* Make sure that BD data is updated before writing the producer */
+	wmb();
+
+	REG_WR(bp, BAR_XSTRORM_INTMEM + XSTORM_SPQ_PROD_OFFSET(func),
+	       bp->spq_prod_idx);
+	mmiowb();
+}
+
 /* the slow path queue is odd since completions arrive on the fastpath ring */
 static int bnx2x_sp_post(struct bnx2x *bp, int command, int cid,
 			 u32 data_hi, u32 data_lo, int common)
 {
-	int func = BP_FUNC(bp);
+	struct eth_spe *spe;
 
 	DP(BNX2X_MSG_SP/*NETIF_MSG_TIMER*/,
 	   "SPQE (%x:%x)  command %d  hw_cid %x  data (%x:%x)  left %x\n",
@@ -2664,38 +2693,23 @@ static int bnx2x_sp_post(struct bnx2x *bp, int command, int cid,
 		return -EBUSY;
 	}
 
+	spe = bnx2x_sp_get_next(bp);
+
 	/* CID needs port number to be encoded int it */
-	bp->spq_prod_bd->hdr.conn_and_cmd_data =
+	spe->hdr.conn_and_cmd_data =
 			cpu_to_le32(((command << SPE_HDR_CMD_ID_SHIFT) |
 				     HW_CID(bp, cid)));
-	bp->spq_prod_bd->hdr.type = cpu_to_le16(ETH_CONNECTION_TYPE);
+	spe->hdr.type = cpu_to_le16(ETH_CONNECTION_TYPE);
 	if (common)
-		bp->spq_prod_bd->hdr.type |=
+		spe->hdr.type |=
 			cpu_to_le16((1 << SPE_HDR_COMMON_RAMROD_SHIFT));
 
-	bp->spq_prod_bd->data.mac_config_addr.hi = cpu_to_le32(data_hi);
-	bp->spq_prod_bd->data.mac_config_addr.lo = cpu_to_le32(data_lo);
+	spe->data.mac_config_addr.hi = cpu_to_le32(data_hi);
+	spe->data.mac_config_addr.lo = cpu_to_le32(data_lo);
 
 	bp->spq_left--;
 
-	if (bp->spq_prod_bd == bp->spq_last_bd) {
-		bp->spq_prod_bd = bp->spq;
-		bp->spq_prod_idx = 0;
-		DP(NETIF_MSG_TIMER, "end of spq\n");
-
-	} else {
-		bp->spq_prod_bd++;
-		bp->spq_prod_idx++;
-	}
-
-	/* Make sure that BD data is updated before writing the producer */
-	wmb();
-
-	REG_WR(bp, BAR_XSTRORM_INTMEM + XSTORM_SPQ_PROD_OFFSET(func),
-	       bp->spq_prod_idx);
-
-	mmiowb();
-
+	bnx2x_sp_prod_update(bp);
 	spin_unlock_bh(&bp->spq_lock);
 	return 0;
 }
-- 
1.6.4.GIT


