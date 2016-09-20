From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH v4 net-next 04/16] net_sched: sch_fq: add low_rate_threshold parameter
Date: Mon, 19 Sep 2016 23:39:11 -0400
Message-ID: <1474342763-16715-5-git-send-email-ncardwell@google.com>
References: <1474342763-16715-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
        Van Jacobson <vanj@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Nandita Dukkipati <nanditad@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:35199 "EHLO
        mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753214AbcITDjf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 23:39:35 -0400
Received: by mail-qk0-f182.google.com with SMTP id t7so4310236qkh.2
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 20:39:34 -0700 (PDT)
In-Reply-To: <1474342763-16715-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

This commit adds to the fq module a low_rate_threshold parameter to
insert a delay after all packets if the socket requests a pacing rate
below the threshold.

This helps achieve more precise control of the sending rate with
low-rate paths, especially policers. The basic issue is that if a
congestion control module detects a policer at a certain rate, it may
want fq to be able to shape to that policed rate. That way the sender
can avoid policer drops by having the packets arrive at the policer at
or just under the policed rate.

The default threshold of 550Kbps was chosen analytically so that for
policers or links at 500Kbps or 512Kbps fq would very likely invoke
this mechanism, even if the pacing rate was briefly slightly above the
available bandwidth. This value was then empirically validated with
two years of production testing on YouTube video servers.

Signed-off-by: Van Jacobson <vanj@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Nandita Dukkipati <nanditad@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
---
 include/uapi/linux/pkt_sched.h |  2 ++
 net/sched/sch_fq.c             | 22 +++++++++++++++++++---
 2 files changed, 21 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_sched.h
index 2382eed..f8e39db 100644
--- a/include/uapi/linux/pkt_sched.h
+++ b/include/uapi/linux/pkt_sched.h
@@ -792,6 +792,8 @@ enum {
 
 	TCA_FQ_ORPHAN_MASK,	/* mask applied to orphaned skb hashes */
 
+	TCA_FQ_LOW_RATE_THRESHOLD, /* per packet delay under this rate */
+
 	__TCA_FQ_MAX
 };
 
diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index e5458b9..40ad4fc 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -94,6 +94,7 @@ struct fq_sched_data {
 	u32		flow_max_rate;	/* optional max rate per flow */
 	u32		flow_plimit;	/* max packets per flow */
 	u32		orphan_mask;	/* mask for orphaned skb */
+	u32		low_rate_threshold;
 	struct rb_root	*fq_root;
 	u8		rate_enable;
 	u8		fq_trees_log;
@@ -433,7 +434,7 @@ static struct sk_buff *fq_dequeue(struct Qdisc *sch)
 	struct fq_flow_head *head;
 	struct sk_buff *skb;
 	struct fq_flow *f;
-	u32 rate;
+	u32 rate, plen;
 
 	skb = fq_dequeue_head(sch, &q->internal);
 	if (skb)
@@ -482,7 +483,7 @@ begin:
 	prefetch(&skb->end);
 	f->credit -= qdisc_pkt_len(skb);
 
-	if (f->credit > 0 || !q->rate_enable)
+	if (!q->rate_enable)
 		goto out;
 
 	/* Do not pace locally generated ack packets */
@@ -493,8 +494,15 @@ begin:
 	if (skb->sk)
 		rate = min(skb->sk->sk_pacing_rate, rate);
 
+	if (rate <= q->low_rate_threshold) {
+		f->credit = 0;
+		plen = qdisc_pkt_len(skb);
+	} else {
+		plen = max(qdisc_pkt_len(skb), q->quantum);
+		if (f->credit > 0)
+			goto out;
+	}
 	if (rate != ~0U) {
-		u32 plen = max(qdisc_pkt_len(skb), q->quantum);
 		u64 len = (u64)plen * NSEC_PER_SEC;
 
 		if (likely(rate))
@@ -662,6 +670,7 @@ static const struct nla_policy fq_policy[TCA_FQ_MAX + 1] = {
 	[TCA_FQ_FLOW_MAX_RATE]		= { .type = NLA_U32 },
 	[TCA_FQ_BUCKETS_LOG]		= { .type = NLA_U32 },
 	[TCA_FQ_FLOW_REFILL_DELAY]	= { .type = NLA_U32 },
+	[TCA_FQ_LOW_RATE_THRESHOLD]	= { .type = NLA_U32 },
 };
 
 static int fq_change(struct Qdisc *sch, struct nlattr *opt)
@@ -716,6 +725,10 @@ static int fq_change(struct Qdisc *sch, struct nlattr *opt)
 	if (tb[TCA_FQ_FLOW_MAX_RATE])
 		q->flow_max_rate = nla_get_u32(tb[TCA_FQ_FLOW_MAX_RATE]);
 
+	if (tb[TCA_FQ_LOW_RATE_THRESHOLD])
+		q->low_rate_threshold =
+			nla_get_u32(tb[TCA_FQ_LOW_RATE_THRESHOLD]);
+
 	if (tb[TCA_FQ_RATE_ENABLE]) {
 		u32 enable = nla_get_u32(tb[TCA_FQ_RATE_ENABLE]);
 
@@ -781,6 +794,7 @@ static int fq_init(struct Qdisc *sch, struct nlattr *opt)
 	q->fq_root		= NULL;
 	q->fq_trees_log		= ilog2(1024);
 	q->orphan_mask		= 1024 - 1;
+	q->low_rate_threshold	= 550000 / 8;
 	qdisc_watchdog_init(&q->watchdog, sch);
 
 	if (opt)
@@ -811,6 +825,8 @@ static int fq_dump(struct Qdisc *sch, struct sk_buff *skb)
 	    nla_put_u32(skb, TCA_FQ_FLOW_REFILL_DELAY,
 			jiffies_to_usecs(q->flow_refill_delay)) ||
 	    nla_put_u32(skb, TCA_FQ_ORPHAN_MASK, q->orphan_mask) ||
+	    nla_put_u32(skb, TCA_FQ_LOW_RATE_THRESHOLD,
+			q->low_rate_threshold) ||
 	    nla_put_u32(skb, TCA_FQ_BUCKETS_LOG, q->fq_trees_log))
 		goto nla_put_failure;
 
-- 
2.8.0.rc3.226.g39d4020
