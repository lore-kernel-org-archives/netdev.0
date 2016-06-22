From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/4] net_sched: fq_codel: cache skb->truesize into skb->cb
Date: Tue, 21 Jun 2016 23:16:50 -0700
Message-ID: <1466576212-15012-3-git-send-email-edumazet@google.com>
References: <1466576212-15012-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35727 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750721AbcFVGWt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 02:22:49 -0400
Received: by mail-pa0-f41.google.com with SMTP id hl6so13789441pac.2
        for <netdev@vger.kernel.org>; Tue, 21 Jun 2016 23:22:49 -0700 (PDT)
In-Reply-To: <1466576212-15012-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now we defer skb drops, it makes sense to keep a copy
of skb->truesize in struct codel_skb_cb to avoid one
cache line miss per dropped skb in fq_codel_drop(),
to reduce latencies a bit further.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/codel_qdisc.h | 1 +
 net/sched/sch_fq_codel.c  | 7 ++++---
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/include/net/codel_qdisc.h b/include/net/codel_qdisc.h
index 8144d9cd2908..098630f83a55 100644
--- a/include/net/codel_qdisc.h
+++ b/include/net/codel_qdisc.h
@@ -52,6 +52,7 @@
 /* Qdiscs using codel plugin must use codel_skb_cb in their own cb[] */
 struct codel_skb_cb {
 	codel_time_t enqueue_time;
+	unsigned int mem_usage;
 };
 
 static struct codel_skb_cb *get_codel_cb(const struct sk_buff *skb)
diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index f715195459c9..a5ea0e9b6be4 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -172,7 +172,7 @@ static unsigned int fq_codel_drop(struct Qdisc *sch, unsigned int max_packets,
 	do {
 		skb = dequeue_head(flow);
 		len += qdisc_pkt_len(skb);
-		mem += skb->truesize;
+		mem += get_codel_cb(skb)->mem_usage;
 		__qdisc_drop(skb, to_free);
 	} while (++i < max_packets && len < threshold);
 
@@ -216,7 +216,8 @@ static int fq_codel_enqueue(struct sk_buff *skb, struct Qdisc *sch,
 		flow->deficit = q->quantum;
 		flow->dropped = 0;
 	}
-	q->memory_usage += skb->truesize;
+	get_codel_cb(skb)->mem_usage = skb->truesize;
+	q->memory_usage += get_codel_cb(skb)->mem_usage;
 	memory_limited = q->memory_usage > q->memory_limit;
 	if (++sch->q.qlen <= sch->limit && !memory_limited)
 		return NET_XMIT_SUCCESS;
@@ -267,7 +268,7 @@ static struct sk_buff *dequeue_func(struct codel_vars *vars, void *ctx)
 	if (flow->head) {
 		skb = dequeue_head(flow);
 		q->backlogs[flow - q->flows] -= qdisc_pkt_len(skb);
-		q->memory_usage -= skb->truesize;
+		q->memory_usage -= get_codel_cb(skb)->mem_usage;
 		sch->q.qlen--;
 		sch->qstats.backlog -= qdisc_pkt_len(skb);
 	}
-- 
2.8.0.rc3.226.g39d4020
