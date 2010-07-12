From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH net-next] cxgb4vf: fix TX Queue restart
Date: Mon, 12 Jul 2010 15:02:53 -0700
Message-ID: <201007121502.54176.leedom@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:15103 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753754Ab0GLWCz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jul 2010 18:02:55 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o6CM2tEs031682
	for <netdev@vger.kernel.org>; Mon, 12 Jul 2010 15:02:55 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From e1c7a6e339a47c42aaf3e425fa3228b33a425a8f Mon Sep 17 00:00:00 2001
From: Casey Leedom <leedom@chelsio.com>
Date: Mon, 12 Jul 2010 14:39:07 -0700
Subject: [PATCH net-next] cxgb4vf: fix TX Queue restart

Fix up TX Queue Host Flow Control to cause an Egress Queue Status Update to
be generated when we run out of TX Queue Descriptors.  This will, in turn,
allow us to restart a stopped TX Queue.

Signed-off-by: Casey Leedom <leedom@chelsio.com>
---
 drivers/net/cxgb4vf/cxgb4vf_main.c |   32 +++++++-------------------------
 drivers/net/cxgb4vf/sge.c          |   12 +++++++++---
 2 files changed, 16 insertions(+), 28 deletions(-)

diff --git a/drivers/net/cxgb4vf/cxgb4vf_main.c b/drivers/net/cxgb4vf/cxgb4vf_main.c
index e988031..d065516 100644
--- a/drivers/net/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/cxgb4vf/cxgb4vf_main.c
@@ -423,12 +423,13 @@ static int fwevtq_handler(struct sge_rspq *rspq, const __be64 *rsp,
 
 	case CPL_SGE_EGR_UPDATE: {
 		/*
-		 * We've received an Egress Queue status update message.
-		 * We get these, as the SGE is currently configured, when
-		 * the firmware passes certain points in processing our
-		 * TX Ethernet Queue.  We use these updates to determine
-		 * when we may need to restart a TX Ethernet Queue which
-		 * was stopped for lack of free slots ...
+		 * We've received an Egress Queue Status Update message.  We
+		 * get these, if the SGE is configured to send these when the
+		 * firmware passes certain points in processing our TX
+		 * Ethernet Queue or if we make an explicit request for one.
+		 * We use these updates to determine when we may need to
+		 * restart a TX Ethernet Queue which was stopped for lack of
+		 * free TX Queue Descriptors ...
 		 */
 		const struct cpl_sge_egr_update *p = (void *)cpl;
 		unsigned int qid = EGR_QID(be32_to_cpu(p->opcode_qid));
@@ -436,7 +437,6 @@ static int fwevtq_handler(struct sge_rspq *rspq, const __be64 *rsp,
 		struct sge_txq *tq;
 		struct sge_eth_txq *txq;
 		unsigned int eq_idx;
-		int hw_cidx, reclaimable, in_use;
 
 		/*
 		 * Perform sanity checking on the Queue ID to make sure it
@@ -466,24 +466,6 @@ static int fwevtq_handler(struct sge_rspq *rspq, const __be64 *rsp,
 		}
 
 		/*
-		 * Skip TX Queues which aren't stopped.
-		 */
-		if (likely(!netif_tx_queue_stopped(txq->txq)))
-			break;
-
-		/*
-		 * Skip stopped TX Queues which have more than half of their
-		 * DMA rings occupied with unacknowledged writes.
-		 */
-		hw_cidx = be16_to_cpu(txq->q.stat->cidx);
-		reclaimable = hw_cidx - txq->q.cidx;
-		if (reclaimable < 0)
-			reclaimable += txq->q.size;
-		in_use = txq->q.in_use - reclaimable;
-		if (in_use >= txq->q.size/2)
-			break;
-
-		/*
 		 * Restart a stopped TX Queue which has less than half of its
 		 * TX ring in use ...
 		 */
diff --git a/drivers/net/cxgb4vf/sge.c b/drivers/net/cxgb4vf/sge.c
index 37c6354..f2ee9b0 100644
--- a/drivers/net/cxgb4vf/sge.c
+++ b/drivers/net/cxgb4vf/sge.c
@@ -1070,6 +1070,7 @@ static inline void txq_advance(struct sge_txq *tq, unsigned int n)
  */
 int t4vf_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 {
+	u32 wr_mid;
 	u64 cntrl, *end;
 	int qidx, credits;
 	unsigned int flits, ndesc;
@@ -1143,14 +1144,19 @@ int t4vf_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto out_free;
 	}
 
+	wr_mid = FW_WR_LEN16(DIV_ROUND_UP(flits, 2));
 	if (unlikely(credits < ETHTXQ_STOP_THRES)) {
 		/*
 		 * After we're done injecting the Work Request for this
 		 * packet, we'll be below our "stop threshhold" so stop the TX
-		 * Queue now.  The queue will get started later on when the
-		 * firmware informs us that space has opened up.
+		 * Queue now and schedule a request for an SGE Egress Queue
+		 * Update message.  The queue will get started later on when
+		 * the firmware processes this Work Request and sends us an
+		 * Egress Queue Status Update message indicating that space
+		 * has opened up.
 		 */
 		txq_stop(txq);
+		wr_mid |= FW_WR_EQUEQ | FW_WR_EQUIQ;
 	}
 
 	/*
@@ -1161,7 +1167,7 @@ int t4vf_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 	 */
 	BUG_ON(DIV_ROUND_UP(ETHTXQ_MAX_HDR, TXD_PER_EQ_UNIT) > 1);
 	wr = (void *)&txq->q.desc[txq->q.pidx];
-	wr->equiq_to_len16 = cpu_to_be32(FW_WR_LEN16(DIV_ROUND_UP(flits, 2)));
+	wr->equiq_to_len16 = cpu_to_be32(wr_mid);
 	wr->r3[0] = cpu_to_be64(0);
 	wr->r3[1] = cpu_to_be64(0);
 	skb_copy_from_linear_data(skb, (void *)wr->ethmacdst, fw_hdr_copy_len);
-- 
1.7.0.4

