From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH net-next 1/10] cxgb3: ring rx door bell less frequently
Date: Fri, 13 Mar 2009 00:13:43 -0700
Message-ID: <20090313071343.21994.85719.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:27583 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752270AbZCMHNr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 03:13:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

Ring free lists door bell less frequently,
specifically every quarter of the active FL
size.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/adapter.h |    1 +
 drivers/net/cxgb3/sge.c     |   32 ++++++++++++++++++++++++--------
 2 files changed, 25 insertions(+), 8 deletions(-)

diff --git a/drivers/net/cxgb3/adapter.h b/drivers/net/cxgb3/adapter.h
index fbe1569..95dce48 100644
--- a/drivers/net/cxgb3/adapter.h
+++ b/drivers/net/cxgb3/adapter.h
@@ -91,6 +91,7 @@ struct rx_sw_desc;
 struct sge_fl {                     /* SGE per free-buffer list state */
 	unsigned int buf_size;      /* size of each Rx buffer */
 	unsigned int credits;       /* # of available Rx buffers */
+	unsigned int pend_cred;     /* new buffers since last FL DB ring */
 	unsigned int size;          /* capacity of free list */
 	unsigned int cidx;          /* consumer index */
 	unsigned int pidx;          /* producer index */
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 8205aa4..882beaf 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -63,6 +63,10 @@
 #define SGE_RX_DROP_THRES 16
 
 /*
+ * Max number of Rx buffers we replenish at a time.
+ */
+#define MAX_RX_REFILL 16U
+/*
  * Period of the Tx buffer reclaim timer.  This timer does not need to run
  * frequently as Tx buffers are usually reclaimed by new Tx packets.
  */
@@ -423,6 +427,14 @@ static int alloc_pg_chunk(struct sge_fl *q, struct rx_sw_desc *sd, gfp_t gfp,
 	return 0;
 }
 
+static inline void ring_fl_db(struct adapter *adap, struct sge_fl *q)
+{
+	if (q->pend_cred >= q->credits / 4) {
+		q->pend_cred = 0;
+		t3_write_reg(adap, A_SG_KDOORBELL, V_EGRCNTX(q->cntxt_id));
+	}
+}
+
 /**
  *	refill_fl - refill an SGE free-buffer list
  *	@adapter: the adapter
@@ -478,19 +490,19 @@ nomem:				q->alloc_failed++;
 			sd = q->sdesc;
 			d = q->desc;
 		}
-		q->credits++;
 		count++;
 	}
-	wmb();
-	if (likely(count))
-		t3_write_reg(adap, A_SG_KDOORBELL, V_EGRCNTX(q->cntxt_id));
+
+	q->credits += count;
+	q->pend_cred += count;
+	ring_fl_db(adap, q);
 
 	return count;
 }
 
 static inline void __refill_fl(struct adapter *adap, struct sge_fl *fl)
 {
-	refill_fl(adap, fl, min(16U, fl->size - fl->credits),
+	refill_fl(adap, fl, min(MAX_RX_REFILL, fl->size - fl->credits),
 		  GFP_ATOMIC | __GFP_COMP);
 }
 
@@ -515,13 +527,15 @@ static void recycle_rx_buf(struct adapter *adap, struct sge_fl *q,
 	wmb();
 	to->len_gen = cpu_to_be32(V_FLD_GEN1(q->gen));
 	to->gen2 = cpu_to_be32(V_FLD_GEN2(q->gen));
-	q->credits++;
 
 	if (++q->pidx == q->size) {
 		q->pidx = 0;
 		q->gen ^= 1;
 	}
-	t3_write_reg(adap, A_SG_KDOORBELL, V_EGRCNTX(q->cntxt_id));
+
+	q->credits++;
+	q->pend_cred++;
+	ring_fl_db(adap, q);
 }
 
 /**
@@ -732,7 +746,9 @@ recycle:
 		return skb;
 	}
 
-	if (unlikely(fl->credits < drop_thres))
+	if (unlikely(fl->credits < drop_thres) &&
+	    refill_fl(adap, fl, min(MAX_RX_REFILL, fl->size - fl->credits - 1),
+		      GFP_ATOMIC | __GFP_COMP) == 0)
 		goto recycle;
 
 use_orig_buf:

