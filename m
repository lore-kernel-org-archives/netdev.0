From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 12/12] net: sched: pfifo_fast new option to deque
 multiple pkts
Date: Wed, 30 Dec 2015 09:55:30 -0800
Message-ID: <20151230175530.26257.2642.stgit@john-Precision-Tower-5810>
References: <20151230175000.26257.41532.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	john.fastabend@gmail.com
To: daniel@iogearbox.net, eric.dumazet@gmail.com, jhs@mojatatu.com,
	aduyck@mirantis.com, brouer@redhat.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36664 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753007AbbL3Rzt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 12:55:49 -0500
Received: by mail-pa0-f44.google.com with SMTP id yy13so48745014pab.3
        for <netdev@vger.kernel.org>; Wed, 30 Dec 2015 09:55:49 -0800 (PST)
In-Reply-To: <20151230175000.26257.41532.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that pfifo_fast is using the alf_queue data structures we can
dequeue multiple skbs and save some overhead.

This works because the bulk dequeue logic accepts skb lists already.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/net/sch_generic.h |    2 +-
 net/sched/sch_generic.c   |   30 ++++++++++++++++++++----------
 2 files changed, 21 insertions(+), 11 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 2c57278..95c11ed 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -128,7 +128,7 @@ static inline void qdisc_run_end(struct Qdisc *qdisc)
 
 static inline bool qdisc_may_bulk(const struct Qdisc *qdisc)
 {
-	return qdisc->flags & TCQ_F_ONETXQUEUE;
+	return (qdisc->flags & TCQ_F_ONETXQUEUE) & !(qdisc->flags & TCQ_F_NOLOCK);
 }
 
 static inline int qdisc_avail_bulklimit(const struct netdev_queue *txq)
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 480cf63..ec5e78e 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -507,25 +507,35 @@ static int pfifo_fast_enqueue(struct sk_buff *skb, struct Qdisc *qdisc)
 static struct sk_buff *pfifo_fast_dequeue(struct Qdisc *qdisc)
 {
 	struct pfifo_fast_priv *priv = qdisc_priv(qdisc);
-	struct sk_buff *skb = NULL;
-	int band;
+	struct sk_buff *skb[8+1] = {NULL};
+	int band, i, elems = 0;
 
-	for (band = 0; band < PFIFO_FAST_BANDS && !skb; band++) {
+	if (this_cpu_ptr(qdisc->cpu_qstats)->qlen < 8)
+		return NULL;
+
+	for (band = 0; band < PFIFO_FAST_BANDS && !skb[0]; band++) {
 		struct alf_queue *q = band2list(priv, band);
 
 		if (alf_queue_empty(q))
 			continue;
 
-		alf_mc_dequeue(q, &skb, 1);
+		elems = alf_mc_dequeue(q, skb, 8);
+
+		/* link array of skbs for driver to process */
+		for (i = 0; i < elems; i++)
+			skb[i]->next = skb[i+1];
 	}
 
-	if (likely(skb)) {
-		qdisc_qstats_cpu_backlog_dec(qdisc, skb);
-		qdisc_bstats_cpu_update(qdisc, skb);
-		qdisc_qstats_cpu_qlen_dec(qdisc);
+	if (likely(skb[0])) {
+		for (i = 0; i < elems; i++) {
+			qdisc_qstats_cpu_backlog_dec(qdisc, skb[i]);
+			qdisc_bstats_cpu_update(qdisc, skb[i]);
+		}
+
+		this_cpu_ptr(qdisc->cpu_qstats)->qlen -= elems;
 	}
 
-	return skb;
+	return skb[0];
 }
 
 static void pfifo_fast_reset(struct Qdisc *qdisc)
@@ -579,7 +589,7 @@ static int pfifo_fast_init(struct Qdisc *qdisc, struct nlattr *opt)
 	}
 
 	/* Can by-pass the queue discipline */
-	qdisc->flags |= TCQ_F_CAN_BYPASS;
+	//qdisc->flags |= TCQ_F_CAN_BYPASS;
 	qdisc->flags |= TCQ_F_NOLOCK;
 	qdisc->flags |= TCQ_F_CPUSTATS;
 
