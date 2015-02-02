From: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Subject: [PATCH net-next 2/2] pkt_sched: fq: remove redundant flow credit refill
Date: Mon,  2 Feb 2015 19:59:16 +0100
Message-ID: <1422903556-30393-2-git-send-email-kennetkl@ifi.uio.no>
References: <1422903556-30393-1-git-send-email-kennetkl@ifi.uio.no>
Cc: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out4.uio.no ([129.240.10.15]:38356 "EHLO mail-out4.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754680AbbBBS7x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Feb 2015 13:59:53 -0500
Received: from mail-mx4.uio.no ([129.240.10.45])
	by mail-out4.uio.no with esmtp (Exim 4.80.1)
	(envelope-from <kennetkl@ifi.uio.no>)
	id 1YIMDv-0003Z2-KF
	for netdev@vger.kernel.org; Mon, 02 Feb 2015 19:59:51 +0100
In-Reply-To: <1422903556-30393-1-git-send-email-kennetkl@ifi.uio.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current behavior explicitly refills flow credit after idle. But following
the first patch in this series, regular refill no longer throttles a flow
if idle_time >= quantum_time.

Remove redundant refill, and warn possible users of the refill delay knob.

Updates f52ed89971ad ("pkt_sched: fq: fix pacing for small frames").
Inspired by 65c5189a2b57 ("pkt_sched: fq: warn users using defrate").

Signed-off-by: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
---
 include/uapi/linux/pkt_sched.h |  2 +-
 net/sched/sch_fq.c             | 20 ++++++--------------
 2 files changed, 7 insertions(+), 15 deletions(-)

diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_sched.h
index d62316b..5a9afb4 100644
--- a/include/uapi/linux/pkt_sched.h
+++ b/include/uapi/linux/pkt_sched.h
@@ -772,7 +772,7 @@ enum {
 
 	TCA_FQ_BUCKETS_LOG,	/* log2(number of buckets) */
 
-	TCA_FQ_FLOW_REFILL_DELAY,	/* flow credit refill delay in usec */
+	TCA_FQ_FLOW_REFILL_DELAY,	/* obsolete, do not use */
 
 	__TCA_FQ_MAX
 };
diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index 6f0c45e..81695ac 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -90,7 +90,6 @@ struct fq_sched_data {
 	struct fq_flow	internal;	/* for non classified or high prio packets */
 	u32		quantum;
 	u32		initial_quantum;
-	u32		flow_refill_delay;
 	u32		flow_max_rate;	/* optional max rate per flow */
 	u32		flow_plimit;	/* max packets per flow */
 	struct rb_root	*fq_root;
@@ -377,10 +376,6 @@ static int fq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	qdisc_qstats_backlog_inc(sch, skb);
 	if (fq_flow_is_detached(f)) {
 		fq_flow_add_tail(&q->new_flows, f);
-		if (time_after(jiffies, f->age + q->flow_refill_delay)) {
-			f->credit = max_t(u32, f->credit, q->quantum);
-			f->time_credit_filled = ktime_get_ns();
-		}
 		q->inactive_flows--;
 	}
 
@@ -701,11 +696,9 @@ static int fq_change(struct Qdisc *sch, struct nlattr *opt)
 			err = -EINVAL;
 	}
 
-	if (tb[TCA_FQ_FLOW_REFILL_DELAY]) {
-		u32 usecs_delay = nla_get_u32(tb[TCA_FQ_FLOW_REFILL_DELAY]) ;
-
-		q->flow_refill_delay = usecs_to_jiffies(usecs_delay);
-	}
+	if (tb[TCA_FQ_FLOW_REFILL_DELAY])
+		pr_warn_ratelimited("sch_fq: refill delay %u ignored.\n",
+				    nla_get_u32(tb[TCA_FQ_FLOW_REFILL_DELAY]));
 
 	if (!err) {
 		sch_tree_unlock(sch);
@@ -744,7 +737,6 @@ static int fq_init(struct Qdisc *sch, struct nlattr *opt)
 	q->flow_plimit		= 100;
 	q->quantum		= 2 * psched_mtu(qdisc_dev(sch));
 	q->initial_quantum	= 10 * psched_mtu(qdisc_dev(sch));
-	q->flow_refill_delay	= msecs_to_jiffies(40);
 	q->flow_max_rate	= ~0U;
 	q->rate_enable		= 1;
 	q->new_flows.first	= NULL;
@@ -771,7 +763,9 @@ static int fq_dump(struct Qdisc *sch, struct sk_buff *skb)
 	if (opts == NULL)
 		goto nla_put_failure;
 
-	/* TCA_FQ_FLOW_DEFAULT_RATE is not used anymore */
+	/* TCA_FQ_FLOW_DEFAULT_RATE and TCA_FQ_FLOW_REFILL_DELAY
+	 * is not used anymore.
+	 */
 
 	if (nla_put_u32(skb, TCA_FQ_PLIMIT, sch->limit) ||
 	    nla_put_u32(skb, TCA_FQ_FLOW_PLIMIT, q->flow_plimit) ||
@@ -779,8 +773,6 @@ static int fq_dump(struct Qdisc *sch, struct sk_buff *skb)
 	    nla_put_u32(skb, TCA_FQ_INITIAL_QUANTUM, q->initial_quantum) ||
 	    nla_put_u32(skb, TCA_FQ_RATE_ENABLE, q->rate_enable) ||
 	    nla_put_u32(skb, TCA_FQ_FLOW_MAX_RATE, q->flow_max_rate) ||
-	    nla_put_u32(skb, TCA_FQ_FLOW_REFILL_DELAY,
-			jiffies_to_usecs(q->flow_refill_delay)) ||
 	    nla_put_u32(skb, TCA_FQ_BUCKETS_LOG, q->fq_trees_log))
 		goto nla_put_failure;
 
-- 
1.9.1
