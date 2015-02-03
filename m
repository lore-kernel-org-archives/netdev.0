From: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Subject: [PATCH net-next v2 1/2] pkt_sched: fq: avoid artificial bursts for clocked flows
Date: Tue,  3 Feb 2015 20:48:52 +0100
Message-ID: <1422992932-9893-1-git-send-email-kennetkl@ifi.uio.no>
Cc: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out4.uio.no ([129.240.10.15]:57571 "EHLO mail-out4.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966238AbbBCTtF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2015 14:49:05 -0500
Received: from mail-mx1.uio.no ([129.240.10.29])
	by mail-out4.uio.no with esmtp (Exim 4.80.1)
	(envelope-from <kennetkl@ifi.uio.no>)
	id 1YIjT5-0007pI-Cf
	for netdev@vger.kernel.org; Tue, 03 Feb 2015 20:49:03 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current pacing behavior always throttle flows for a time equal to one full
quantum, starting when a flow exhausts its credit. This is only optimal for
bursty traffic that consumes the entire credit in one sitting.

For flows with small packets, this throttling behavior can cause packets
to artificially queue and transmit in bursts, even when their sending rate
is well below their pacing rate. There is a refill mechanism in fq_enqueue()
that counteracts this in some cases, but it only works when flows space
their packets further apart than the flow refill delay.

Keep track of the time a flows credit was last filled, and use this to
approximate a full credit refill when one quantum of time passes. This is
a more fine-grained approach than the refill heuristic in fq_enqueue(),
which is removed by the next patch in this series.

Since calls to ktime are expensive, time_credit_filled is only set correctly
on dequeue. For new flows, set time_credit_filled to zero and anticipate
dequeue to refill one quantum without throttling. This approach requires
that initial_quantum >= quantum.

Increases memory footprint from 104 to 112 bytes per flow.

V2: avoids ktime_get_ns() on enqueue, as suggested by Eric Dumazet.

Signed-off-by: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
---
 net/sched/sch_fq.c | 27 ++++++++++++++++++++-------
 1 file changed, 20 insertions(+), 7 deletions(-)

diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index 313794b..43d5b74 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -71,6 +71,7 @@ struct fq_flow {
 
 	struct rb_node  rate_node;	/* anchor in q->delayed tree */
 	u64		time_next_packet;
+	u64		time_credit_filled;
 };
 
 struct fq_flow_head {
@@ -250,6 +251,7 @@ static struct fq_flow *fq_classify(struct sk_buff *skb, struct fq_sched_data *q)
 			if (unlikely(skb->sk &&
 				     f->socket_hash != sk->sk_hash)) {
 				f->credit = q->initial_quantum;
+				f->time_credit_filled = 0ULL;
 				f->socket_hash = sk->sk_hash;
 				f->time_next_packet = 0ULL;
 			}
@@ -271,6 +273,7 @@ static struct fq_flow *fq_classify(struct sk_buff *skb, struct fq_sched_data *q)
 	if (skb->sk)
 		f->socket_hash = sk->sk_hash;
 	f->credit = q->initial_quantum;
+	f->time_credit_filled = 0ULL;
 
 	rb_link_node(&f->fq_node, parent, p);
 	rb_insert_color(&f->fq_node, root);
@@ -374,8 +377,10 @@ static int fq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	qdisc_qstats_backlog_inc(sch, skb);
 	if (fq_flow_is_detached(f)) {
 		fq_flow_add_tail(&q->new_flows, f);
-		if (time_after(jiffies, f->age + q->flow_refill_delay))
-			f->credit = max_t(u32, f->credit, q->quantum);
+		if (time_after(jiffies, f->age + q->flow_refill_delay)) {
+			f->credit = max_t(int, f->credit - q->quantum, 0);
+			f->time_credit_filled = 0ULL;
+		}
 		q->inactive_flows--;
 	}
 
@@ -440,6 +445,7 @@ begin:
 
 	if (f->credit <= 0) {
 		f->credit += q->quantum;
+		f->time_credit_filled = max(now, f->time_next_packet);
 		head->first = f->next;
 		fq_flow_add_tail(&q->old_flows, f);
 		goto begin;
@@ -489,7 +495,7 @@ begin:
 			q->stat_pkts_too_long++;
 		}
 
-		f->time_next_packet = now + len;
+		f->time_next_packet = max(now, f->time_credit_filled + len);
 	}
 out:
 	qdisc_bstats_update(sch, skb);
@@ -679,8 +685,14 @@ static int fq_change(struct Qdisc *sch, struct nlattr *opt)
 			err = -EINVAL;
 	}
 
-	if (tb[TCA_FQ_INITIAL_QUANTUM])
-		q->initial_quantum = nla_get_u32(tb[TCA_FQ_INITIAL_QUANTUM]);
+	if (tb[TCA_FQ_INITIAL_QUANTUM]) {
+		u32 initial_quantum = nla_get_u32(tb[TCA_FQ_INITIAL_QUANTUM]);
+
+		if (initial_quantum > q->quantum)
+			q->initial_quantum = initial_quantum - q->quantum;
+		else
+			q->initial_quantum = 0;
+	}
 
 	if (tb[TCA_FQ_FLOW_DEFAULT_RATE])
 		pr_warn_ratelimited("sch_fq: defrate %u ignored.\n",
@@ -740,7 +752,7 @@ static int fq_init(struct Qdisc *sch, struct nlattr *opt)
 	sch->limit		= 10000;
 	q->flow_plimit		= 100;
 	q->quantum		= 2 * psched_mtu(qdisc_dev(sch));
-	q->initial_quantum	= 10 * psched_mtu(qdisc_dev(sch));
+	q->initial_quantum	= 10 * psched_mtu(qdisc_dev(sch)) - q->quantum;
 	q->flow_refill_delay	= msecs_to_jiffies(40);
 	q->flow_max_rate	= ~0U;
 	q->rate_enable		= 1;
@@ -773,7 +785,8 @@ static int fq_dump(struct Qdisc *sch, struct sk_buff *skb)
 	if (nla_put_u32(skb, TCA_FQ_PLIMIT, sch->limit) ||
 	    nla_put_u32(skb, TCA_FQ_FLOW_PLIMIT, q->flow_plimit) ||
 	    nla_put_u32(skb, TCA_FQ_QUANTUM, q->quantum) ||
-	    nla_put_u32(skb, TCA_FQ_INITIAL_QUANTUM, q->initial_quantum) ||
+	    nla_put_u32(skb, TCA_FQ_INITIAL_QUANTUM,
+		        q->initial_quantum + q->quantum) ||
 	    nla_put_u32(skb, TCA_FQ_RATE_ENABLE, q->rate_enable) ||
 	    nla_put_u32(skb, TCA_FQ_FLOW_MAX_RATE, q->flow_max_rate) ||
 	    nla_put_u32(skb, TCA_FQ_FLOW_REFILL_DELAY,
-- 
1.9.1
