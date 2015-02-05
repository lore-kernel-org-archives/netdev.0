From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v3 net-next] pkt_sched: fq: better control of DDOS traffic
Date: Wed, 04 Feb 2015 21:30:40 -0800
Message-ID: <1423114240.31870.33.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1422626772.21689.90.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1422984739.907.25.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:45102 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734AbbBEFan (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 00:30:43 -0500
Received: by mail-pa0-f42.google.com with SMTP id bj1so7744747pad.1
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 21:30:42 -0800 (PST)
In-Reply-To: <1422984739.907.25.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

FQ has a fast path for skb attached to a socket, as it does not
have to compute a flow hash. But for other packets, FQ being non
stochastic means that hosts exposed to random Internet traffic
can allocate million of flows structure (104 bytes each) pretty
easily. Not only host can OOM, but lookup in RB trees can take
too much cpu and memory resources.

This patch adds a new attribute, orphan_mask, that is adding
possibility of having a stochastic hash for orphaned skb.

Its default value is 1024 slots, to mimic SFQ behavior.

Note: This does not apply to locally generated TCP traffic,
and no locally generated traffic will share a flow structure
with another perfect or stochastic flow.

This patch also handles the specific case of SYNACK messages:

They are attached to the listener socket, and therefore all map
to a single hash bucket. If listener have set SO_MAX_PACING_RATE,
hoping to have new accepted socket inherit this rate, SYNACK
might be paced and even dropped.

This is very similar to an internal patch Google have used more
than one year.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
v3: adding the missing include file change
v2: make the left shift in fq_classify.

 include/uapi/linux/pkt_sched.h |    2 ++
 net/sched/sch_fq.c             |   19 +++++++++++++++++--
 2 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_sched.h
index d62316baae942c43b2558ed2768c88950516126c..534b847107453019d362e9f9f9c0969fc3100c8b 100644
--- a/include/uapi/linux/pkt_sched.h
+++ b/include/uapi/linux/pkt_sched.h
@@ -774,6 +774,8 @@ enum {
 
 	TCA_FQ_FLOW_REFILL_DELAY,	/* flow credit refill delay in usec */
 
+	TCA_FQ_ORPHAN_MASK,	/* mask applied to orphaned skb hashes */
+
 	__TCA_FQ_MAX
 };
 
diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index 69a3dbf55c60271723e580b209282c8b3ae91ae8..a00c4304300101a093e834c73fdd3bdb2c2c38a3 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -93,6 +93,7 @@ struct fq_sched_data {
 	u32		flow_refill_delay;
 	u32		flow_max_rate;	/* optional max rate per flow */
 	u32		flow_plimit;	/* max packets per flow */
+	u32		orphan_mask;	/* mask for orphaned skb */
 	struct rb_root	*fq_root;
 	u8		rate_enable;
 	u8		fq_trees_log;
@@ -223,11 +224,20 @@ static struct fq_flow *fq_classify(struct sk_buff *skb, struct fq_sched_data *q)
 	if (unlikely((skb->priority & TC_PRIO_MAX) == TC_PRIO_CONTROL))
 		return &q->internal;
 
-	if (unlikely(!sk)) {
+	/* SYNACK messages are attached to a listener socket.
+	 * 1) They are not part of a 'flow' yet
+	 * 2) We do not want to rate limit them (eg SYNFLOOD attack),
+	 *    especially if the listener set SO_MAX_PACING_RATE
+	 * 3) We pretend they are orphaned
+	 */
+	if (!sk || sk->sk_state == TCP_LISTEN) {
+		unsigned long hash = skb_get_hash(skb) & q->orphan_mask;
+
 		/* By forcing low order bit to 1, we make sure to not
 		 * collide with a local flow (socket pointers are word aligned)
 		 */
-		sk = (struct sock *)(skb_get_hash(skb) | 1L);
+		sk = (struct sock *)((hash << 1) | 1UL);
+		skb_orphan(skb);
 	}
 
 	root = &q->fq_root[hash_32((u32)(long)sk, q->fq_trees_log)];
@@ -704,6 +714,9 @@ static int fq_change(struct Qdisc *sch, struct nlattr *opt)
 		q->flow_refill_delay = usecs_to_jiffies(usecs_delay);
 	}
 
+	if (tb[TCA_FQ_ORPHAN_MASK])
+		q->orphan_mask = nla_get_u32(tb[TCA_FQ_ORPHAN_MASK]);
+
 	if (!err) {
 		sch_tree_unlock(sch);
 		err = fq_resize(sch, fq_log);
@@ -749,6 +762,7 @@ static int fq_init(struct Qdisc *sch, struct nlattr *opt)
 	q->delayed		= RB_ROOT;
 	q->fq_root		= NULL;
 	q->fq_trees_log		= ilog2(1024);
+	q->orphan_mask		= 1024 - 1;
 	qdisc_watchdog_init(&q->watchdog, sch);
 
 	if (opt)
@@ -778,6 +792,7 @@ static int fq_dump(struct Qdisc *sch, struct sk_buff *skb)
 	    nla_put_u32(skb, TCA_FQ_FLOW_MAX_RATE, q->flow_max_rate) ||
 	    nla_put_u32(skb, TCA_FQ_FLOW_REFILL_DELAY,
 			jiffies_to_usecs(q->flow_refill_delay)) ||
+	    nla_put_u32(skb, TCA_FQ_ORPHAN_MASK, q->orphan_mask) ||
 	    nla_put_u32(skb, TCA_FQ_BUCKETS_LOG, q->fq_trees_log))
 		goto nla_put_failure;
 
