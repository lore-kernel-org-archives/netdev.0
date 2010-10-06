From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next 09/19] bnx2x: change type of spq_left to atomic
Date: Wed, 6 Oct 2010 15:27:41 +0200
Message-ID: <1286371661.30552.40.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, mchan@broadcom.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1170 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758927Ab0JFNj6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Oct 2010 09:39:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The field is now accessed from different contexts.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x.h       |    2 +-
 drivers/net/bnx2x/bnx2x_main.c  |   17 +++++++++--------
 drivers/net/bnx2x/bnx2x_stats.c |    5 +----
 3 files changed, 11 insertions(+), 13 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index d7b24f9..09fb7ff 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -860,7 +860,7 @@ struct bnx2x {
 	struct eth_spe		*spq_prod_bd;
 	struct eth_spe		*spq_last_bd;
 	__le16			*dsb_sp_prod;
-	u16			spq_left; /* serialize spq */
+	atomic_t		spq_left; /* serialize spq */
 	/* used to synchronize spq accesses */
 	spinlock_t		spq_lock;
 
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 238e38f..2c04b97 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -1161,8 +1161,8 @@ void bnx2x_sp_event(struct bnx2x_fastpath *fp,
 		break;
 	}
 
-	bp->spq_left++;
-
+	smp_mb__before_atomic_inc();
+	atomic_inc(&bp->spq_left);
 	/* push the change in fp->state and towards the memory */
 	smp_wmb();
 
@@ -2432,7 +2432,7 @@ int bnx2x_sp_post(struct bnx2x *bp, int command, int cid,
 
 	spin_lock_bh(&bp->spq_lock);
 
-	if (!bp->spq_left) {
+	if (!atomic_read(&bp->spq_left)) {
 		BNX2X_ERR("BUG! SPQ ring full!\n");
 		spin_unlock_bh(&bp->spq_lock);
 		bnx2x_panic();
@@ -2472,7 +2472,7 @@ int bnx2x_sp_post(struct bnx2x *bp, int command, int cid,
 		 * somewhere between the spin_lock and spin_unlock. Thus no
 		 * more explict memory barrier is needed.
 		 */
-		bp->spq_left--;
+		atomic_dec(&bp->spq_left);
 
 	DP(BNX2X_MSG_SP/*NETIF_MSG_TIMER*/,
 	   "SPQE[%x] (%x:%x)  command %d  hw_cid %x  data (%x:%x) "
@@ -2480,7 +2480,7 @@ int bnx2x_sp_post(struct bnx2x *bp, int command, int cid,
 	   bp->spq_prod_idx, (u32)U64_HI(bp->spq_mapping),
 	   (u32)(U64_LO(bp->spq_mapping) +
 	   (void *)bp->spq_prod_bd - (void *)bp->spq), command,
-	   HW_CID(bp, cid), data_hi, data_lo, type, bp->spq_left);
+	   HW_CID(bp, cid), data_hi, data_lo, type, atomic_read(&bp->spq_left));
 
 	bnx2x_sp_prod_update(bp);
 	spin_unlock_bh(&bp->spq_lock);
@@ -3290,7 +3290,7 @@ static void bnx2x_eq_int(struct bnx2x *bp)
 	sw_prod = bp->eq_prod;
 
 	DP(BNX2X_MSG_SP, "EQ:  hw_cons %u  sw_cons %u bp->spq_left %u\n",
-			hw_cons, sw_cons, bp->spq_left);
+			hw_cons, sw_cons, atomic_read(&bp->spq_left));
 
 	for (; sw_cons != hw_cons;
 	      sw_prod = NEXT_EQ_IDX(sw_prod), sw_cons = NEXT_EQ_IDX(sw_cons)) {
@@ -3360,7 +3360,8 @@ next_spqe:
 		spqe_cnt++;
 	} /* for */
 
-	bp->spq_left++;
+	smp_mb__before_atomic_inc();
+	atomic_add(spqe_cnt, &bp->spq_left);
 
 	bp->eq_cons = sw_cons;
 	bp->eq_prod = sw_prod;
@@ -3737,8 +3738,8 @@ void bnx2x_update_coalesce(struct bnx2x *bp)
 static void bnx2x_init_sp_ring(struct bnx2x *bp)
 {
 	spin_lock_init(&bp->spq_lock);
+	atomic_set(&bp->spq_left, MAX_SPQ_PENDING);
 
-	bp->spq_left = MAX_SPQ_PENDING;
 	bp->spq_prod_idx = 0;
 	bp->dsb_sp_prod = BNX2X_SP_DSB_INDEX;
 	bp->spq_prod_bd = bp->spq;
diff --git a/drivers/net/bnx2x/bnx2x_stats.c b/drivers/net/bnx2x/bnx2x_stats.c
index c271fc5..32b6b10 100644
--- a/drivers/net/bnx2x/bnx2x_stats.c
+++ b/drivers/net/bnx2x/bnx2x_stats.c
@@ -166,11 +166,8 @@ static void bnx2x_storm_stats_post(struct bnx2x *bp)
 		rc = bnx2x_sp_post(bp, RAMROD_CMD_ID_COMMON_STAT_QUERY, 0,
 				   ((u32 *)&ramrod_data)[1],
 				   ((u32 *)&ramrod_data)[0], 1);
-		if (rc == 0) {
-			/* stats ramrod has it's own slot on the spq */
-			bp->spq_left++;
+		if (rc == 0)
 			bp->stats_pending = 1;
-		}
 
 		spin_unlock_bh(&bp->stats_lock);
 	}
-- 
1.7.1




