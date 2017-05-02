From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH v2 13/17] net: sched: add support for TCQ_F_NOLOCK
 subqueues to sch_mqprio
Date: Tue, 02 May 2017 08:40:13 -0700
Message-ID: <20170502154013.9304.60.stgit@john-Precision-Tower-5810>
References: <20170502153518.9304.17904.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34850 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750733AbdEBPk0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 11:40:26 -0400
Received: by mail-pf0-f194.google.com with SMTP id o68so14762620pfj.2
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 08:40:26 -0700 (PDT)
In-Reply-To: <20170502153518.9304.17904.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sch_mqprio qdisc creates a sub-qdisc per tx queue which are then
called independently for enqueue and dequeue operations. However
statistics are aggregated and pushed up to the "master" qdisc.

This patch adds support for any of the sub-qdiscs to be per cpu
statistic qdiscs. To handle this case add a check when calculating
stats and aggregate the per cpu stats if needed.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 net/sched/sch_mqprio.c |   61 +++++++++++++++++++++++++++++++-----------------
 1 file changed, 39 insertions(+), 22 deletions(-)

diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
index 0a4cf27..d2f33ac 100644
--- a/net/sched/sch_mqprio.c
+++ b/net/sched/sch_mqprio.c
@@ -233,22 +233,32 @@ static int mqprio_dump(struct Qdisc *sch, struct sk_buff *skb)
 	unsigned char *b = skb_tail_pointer(skb);
 	struct tc_mqprio_qopt opt = { 0 };
 	struct Qdisc *qdisc;
-	unsigned int i;
+	unsigned int ntx, tc;
 
 	sch->q.qlen = 0;
 	memset(&sch->bstats, 0, sizeof(sch->bstats));
 	memset(&sch->qstats, 0, sizeof(sch->qstats));
 
-	for (i = 0; i < dev->num_tx_queues; i++) {
-		qdisc = rtnl_dereference(netdev_get_tx_queue(dev, i)->qdisc);
+	for (ntx = 0; ntx < dev->num_tx_queues; ntx++) {
+		struct gnet_stats_basic_cpu __percpu *cpu_bstats = NULL;
+		struct gnet_stats_queue __percpu *cpu_qstats = NULL;
+		__u32 qlen = 0;
+
+		qdisc = netdev_get_tx_queue(dev, ntx)->qdisc_sleeping;
 		spin_lock_bh(qdisc_lock(qdisc));
-		sch->q.qlen		+= qdisc->q.qlen;
-		sch->bstats.bytes	+= qdisc->bstats.bytes;
-		sch->bstats.packets	+= qdisc->bstats.packets;
-		sch->qstats.backlog	+= qdisc->qstats.backlog;
-		sch->qstats.drops	+= qdisc->qstats.drops;
-		sch->qstats.requeues	+= qdisc->qstats.requeues;
-		sch->qstats.overlimits	+= qdisc->qstats.overlimits;
+
+		if (qdisc_is_percpu_stats(qdisc)) {
+			cpu_bstats = qdisc->cpu_bstats;
+			cpu_qstats = qdisc->cpu_qstats;
+		}
+
+		qlen = qdisc_qlen_sum(qdisc);
+
+		__gnet_stats_copy_basic(NULL, &sch->bstats,
+					cpu_bstats, &qdisc->bstats);
+		__gnet_stats_copy_queue(&sch->qstats,
+					cpu_qstats, &qdisc->qstats, qlen);
+
 		spin_unlock_bh(qdisc_lock(qdisc));
 	}
 
@@ -256,9 +266,9 @@ static int mqprio_dump(struct Qdisc *sch, struct sk_buff *skb)
 	memcpy(opt.prio_tc_map, dev->prio_tc_map, sizeof(opt.prio_tc_map));
 	opt.hw = priv->hw_offload;
 
-	for (i = 0; i < netdev_get_num_tc(dev); i++) {
-		opt.count[i] = dev->tc_to_txq[i].count;
-		opt.offset[i] = dev->tc_to_txq[i].offset;
+	for (tc = 0; tc < netdev_get_num_tc(dev); tc++) {
+		opt.count[tc] = dev->tc_to_txq[tc].count;
+		opt.offset[tc] = dev->tc_to_txq[tc].offset;
 	}
 
 	if (nla_put(skb, TCA_OPTIONS, sizeof(opt), &opt))
@@ -336,7 +346,6 @@ static int mqprio_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 	if (cl <= netdev_get_num_tc(dev)) {
 		int i;
 		__u32 qlen = 0;
-		struct Qdisc *qdisc;
 		struct gnet_stats_queue qstats = {0};
 		struct gnet_stats_basic_packed bstats = {0};
 		struct netdev_tc_txq tc = dev->tc_to_txq[cl - 1];
@@ -351,18 +360,26 @@ static int mqprio_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 
 		for (i = tc.offset; i < tc.offset + tc.count; i++) {
 			struct netdev_queue *q = netdev_get_tx_queue(dev, i);
+			struct Qdisc *qdisc = rtnl_dereference(q->qdisc);
+			struct gnet_stats_basic_cpu __percpu *cpu_bstats = NULL;
+			struct gnet_stats_queue __percpu *cpu_qstats = NULL;
 
-			qdisc = rtnl_dereference(q->qdisc);
 			spin_lock_bh(qdisc_lock(qdisc));
-			qlen		  += qdisc->q.qlen;
-			bstats.bytes      += qdisc->bstats.bytes;
-			bstats.packets    += qdisc->bstats.packets;
-			qstats.backlog    += qdisc->qstats.backlog;
-			qstats.drops      += qdisc->qstats.drops;
-			qstats.requeues   += qdisc->qstats.requeues;
-			qstats.overlimits += qdisc->qstats.overlimits;
+			if (qdisc_is_percpu_stats(qdisc)) {
+				cpu_bstats = qdisc->cpu_bstats;
+				cpu_qstats = qdisc->cpu_qstats;
+			}
+
+			qlen = qdisc_qlen_sum(qdisc);
+			__gnet_stats_copy_basic(NULL, &sch->bstats,
+						cpu_bstats, &qdisc->bstats);
+			__gnet_stats_copy_queue(&sch->qstats,
+						cpu_qstats,
+						&qdisc->qstats,
+						qlen);
 			spin_unlock_bh(qdisc_lock(qdisc));
 		}
+
 		/* Reclaim root sleeping lock before completing stats */
 		if (d->lock)
 			spin_lock_bh(d->lock);
