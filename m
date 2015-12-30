From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 11/12] net: sched: add support for TCQ_F_NOLOCK
 subqueues to sch_mq
Date: Wed, 30 Dec 2015 09:55:08 -0800
Message-ID: <20151230175508.26257.56482.stgit@john-Precision-Tower-5810>
References: <20151230175000.26257.41532.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	john.fastabend@gmail.com
To: daniel@iogearbox.net, eric.dumazet@gmail.com, jhs@mojatatu.com,
	aduyck@mirantis.com, brouer@redhat.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33543 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752973AbbL3RzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 12:55:25 -0500
Received: by mail-pa0-f44.google.com with SMTP id cy9so141198295pac.0
        for <netdev@vger.kernel.org>; Wed, 30 Dec 2015 09:55:25 -0800 (PST)
In-Reply-To: <20151230175000.26257.41532.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sch_mq qdisc creates a sub-qdisc per tx queue which are then
called for independently for enqueue and dequeue operations. However
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
index cbafa37..a902061 100644
--- a/include/net/gen_stats.h
+++ b/include/net/gen_stats.h
@@ -43,6 +43,9 @@ int gnet_stats_copy_rate_est(struct gnet_dump *d,
 int gnet_stats_copy_queue(struct gnet_dump *d,
 			  struct gnet_stats_queue __percpu *cpu_q,
 			  struct gnet_stats_queue *q, __u32 qlen);
+void __gnet_stats_copy_queue(struct gnet_stats_queue *qstats,
+			     const struct gnet_stats_queue __percpu *cpu_q,
+			     const struct gnet_stats_queue *q, __u32 qlen);
 int gnet_stats_copy_app(struct gnet_dump *d, void *st, int len);
 
 int gnet_stats_finish_copy(struct gnet_dump *d);
diff --git a/net/core/gen_stats.c b/net/core/gen_stats.c
index 1e2f46a..b653a56 100644
--- a/net/core/gen_stats.c
+++ b/net/core/gen_stats.c
@@ -235,10 +235,10 @@ __gnet_stats_copy_queue_cpu(struct gnet_stats_queue *qstats,
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
@@ -252,6 +252,7 @@ static void __gnet_stats_copy_queue(struct gnet_stats_queue *qstats,
 
 	qstats->qlen = qlen;
 }
+EXPORT_SYMBOL(__gnet_stats_copy_queue);
 
 /**
  * gnet_stats_copy_queue - copy queue statistics into statistics TLV
diff --git a/net/sched/sch_mq.c b/net/sched/sch_mq.c
index 3e82f04..3468317 100644
--- a/net/sched/sch_mq.c
+++ b/net/sched/sch_mq.c
@@ -17,6 +17,7 @@
 #include <linux/skbuff.h>
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
+#include <net/sch_generic.h>
 
 struct mq_sched {
 	struct Qdisc		**qdiscs;
@@ -107,15 +108,25 @@ static int mq_dump(struct Qdisc *sch, struct sk_buff *skb)
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
+		__gnet_stats_copy_basic(&sch->bstats,
+					cpu_bstats, &qdisc->bstats);
+		__gnet_stats_copy_queue(&sch->qstats,
+					cpu_qstats, &qdisc->qstats, qlen);
+
 		spin_unlock_bh(qdisc_lock(qdisc));
 	}
 	return 0;
