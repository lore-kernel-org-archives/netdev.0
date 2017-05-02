From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH v2 12/17] net: sched: add support for TCQ_F_NOLOCK
 subqueues to sch_mq
Date: Tue, 02 May 2017 08:39:55 -0700
Message-ID: <20170502153955.9304.75647.stgit@john-Precision-Tower-5810>
References: <20170502153518.9304.17904.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33470 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750769AbdEBPkI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 11:40:08 -0400
Received: by mail-pf0-f194.google.com with SMTP id b23so17917497pfc.0
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 08:40:08 -0700 (PDT)
In-Reply-To: <20170502153518.9304.17904.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sch_mq qdisc creates a sub-qdisc per tx queue which are then
called independently for enqueue and dequeue operations. However
statistics are aggregated and pushed up to the "master" qdisc.

This patch adds support for any of the sub-qdiscs to be per cpu
statistic qdiscs. To handle this case add a check when calculating
stats and aggregate the per cpu stats if needed.

Also exports __gnet_stats_copy_queue() to use as a helper function.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/net/gen_stats.h |    3 +++
 net/core/gen_stats.c    |    9 +++++----
 net/sched/sch_mq.c      |   25 ++++++++++++++++++-------
 3 files changed, 26 insertions(+), 11 deletions(-)

diff --git a/include/net/gen_stats.h b/include/net/gen_stats.h
index 8b7aa37..2bf0ec2 100644
--- a/include/net/gen_stats.h
+++ b/include/net/gen_stats.h
@@ -48,6 +48,9 @@ int gnet_stats_copy_rate_est(struct gnet_dump *d,
 int gnet_stats_copy_queue(struct gnet_dump *d,
 			  struct gnet_stats_queue __percpu *cpu_q,
 			  struct gnet_stats_queue *q, __u32 qlen);
+void __gnet_stats_copy_queue(struct gnet_stats_queue *qstats,
+			     const struct gnet_stats_queue __percpu *cpu_q,
+			     const struct gnet_stats_queue *q, __u32 qlen);
 int gnet_stats_copy_app(struct gnet_dump *d, void *st, int len);
 
 int gnet_stats_finish_copy(struct gnet_dump *d);
diff --git a/net/core/gen_stats.c b/net/core/gen_stats.c
index 87f2855..b2b2323b 100644
--- a/net/core/gen_stats.c
+++ b/net/core/gen_stats.c
@@ -252,10 +252,10 @@
 	}
 }
 
-static void __gnet_stats_copy_queue(struct gnet_stats_queue *qstats,
-				    const struct gnet_stats_queue __percpu *cpu,
-				    const struct gnet_stats_queue *q,
-				    __u32 qlen)
+void __gnet_stats_copy_queue(struct gnet_stats_queue *qstats,
+			     const struct gnet_stats_queue __percpu *cpu,
+			     const struct gnet_stats_queue *q,
+			     __u32 qlen)
 {
 	if (cpu) {
 		__gnet_stats_copy_queue_cpu(qstats, cpu);
@@ -269,6 +269,7 @@ static void __gnet_stats_copy_queue(struct gnet_stats_queue *qstats,
 
 	qstats->qlen = qlen;
 }
+EXPORT_SYMBOL(__gnet_stats_copy_queue);
 
 /**
  * gnet_stats_copy_queue - copy queue statistics into statistics TLV
diff --git a/net/sched/sch_mq.c b/net/sched/sch_mq.c
index cadfdd4..7871db4 100644
--- a/net/sched/sch_mq.c
+++ b/net/sched/sch_mq.c
@@ -17,6 +17,7 @@
 #include <linux/skbuff.h>
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
+#include <net/sch_generic.h>
 
 struct mq_sched {
 	struct Qdisc		**qdiscs;
@@ -103,15 +104,25 @@ static int mq_dump(struct Qdisc *sch, struct sk_buff *skb)
 	memset(&sch->qstats, 0, sizeof(sch->qstats));
 
 	for (ntx = 0; ntx < dev->num_tx_queues; ntx++) {
+		struct gnet_stats_basic_cpu __percpu *cpu_bstats = NULL;
+		struct gnet_stats_queue __percpu *cpu_qstats = NULL;
+		__u32 qlen = 0;
+
 		qdisc = netdev_get_tx_queue(dev, ntx)->qdisc_sleeping;
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
 	return 0;
