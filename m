From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6 v3] net_sched: SFB flow scheduler
Date: Wed, 23 Feb 2011 16:14:51 +0100
Message-ID: <1298474091.3301.364.camel@edumazet-laptop>
References: <20110221160306.GA9650@tuxdriver.com>
	 <1298308283.2849.5.camel@edumazet-laptop>
	 <1298390536.2861.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>
To: David Miller <davem@davemloft.net>,
	Juliusz Chroboczek <Juliusz.Chroboczek@pps.jussieu.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f51.google.com ([209.85.214.51]:54297 "EHLO
	mail-bw0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753098Ab1BWPO6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 10:14:58 -0500
Received: by bwz10 with SMTP id 10so192657bwz.10
        for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 07:14:56 -0800 (PST)
In-Reply-To: <1298390536.2861.9.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David & Juliusz

Here is v3 of SFB. (previous ones were from Juliusz)

Thanks

[PATCH net-next-2.6 v3] net_sched: SFB flow scheduler

This is the Stochastic Fair Blue scheduler, based on work from :

W. Feng, D. Kandlur, D. Saha, K. Shin. Blue: A New Class of Active Queue
Management Algorithms. U. Michigan CSE-TR-387-99, April 1999.

http://www.thefengs.com/wuchang/blue/CSE-TR-387-99.pdf

This implementation is based on work done by Juliusz Chroboczek

General SFB algorithm can be found in figure 14, page 15:

B[l][n] : L x N array of bins (L levels, N bins per level)
enqueue()
Calculate hash function values h{0}, h{1}, .. h{L-1}
Update bins at each level
for i = 0 to L - 1
   if (B[i][h{i}].qlen > bin_size)
      B[i][h{i}].pm += delta;
   else if (B[i][h{i}].qlen == 0)
      B[i][h{i}].pm -= delta;
pmin = min(B[0][h{0}].pm ... B[L-1][h{L-1}].pm);
if (pmin == 1.0)
    ratelimit();
else
    mark/drop with probabilty pmin;

I did the adaptation of Juliusz code to meet current kernel standards,
and various changes to address previous comments :

http://thread.gmane.org/gmane.linux.network/90225
http://thread.gmane.org/gmane.linux.network/90375

Default flow classifier is the rxhash introduced by RPS in 2.6.35, but
we can use an external flow classifier if wanted.

tc qdisc add dev $IFB parent 1:11 handle 11:  \
	est 0.5sec 2sec sfb limit 128

tc filter add dev $DEV protocol ip parent 11: handle 3 \
	flow hash keys dst divisor 1024

Notes:

1) SFB default child qdisc is pfifo_fast. It can be changed by another
qdisc but a child qdisc MUST not drop a packet previously queued. This
is because SFB needs to handle a dequeued packet in order to maintain
its virtual queue states. pfifo_head_drop or CHOKe should not be used.

2) I added one field in qdisc_skb_cb because SFB needs to remember the
hash/classid of an skb to decrement virtual queue lengthes at dequeue()
time.

3) ECN is enabled by default, unlike RED/CHOKe/GRED

With help from Patrick McHardy & Andi Kleen

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Juliusz Chroboczek <Juliusz.Chroboczek@pps.jussieu.fr>
CC: Stephen Hemminger <shemminger@vyatta.com>
CC: Patrick McHardy <kaber@trash.net>
CC: Andi Kleen <andi@firstfloor.org>
CC: John W. Linville <linville@tuxdriver.com>
---
 include/linux/pkt_sched.h |   38 +
 include/net/sch_generic.h |    1 
 net/sched/Kconfig         |   11 
 net/sched/Makefile        |    1 
 net/sched/sch_sfb.c       |  696 ++++++++++++++++++++++++++++++++++++
 5 files changed, 747 insertions(+)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index d4bb6f5..629a8b0 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -522,4 +522,42 @@ struct tc_mqprio_qopt {
 	__u16	offset[TC_QOPT_MAX_QUEUE];
 };
 
+/* SFB */
+
+enum {
+	TCA_SFB_UNSPEC,
+	TCA_SFB_PARMS,
+	__TCA_SFB_MAX,
+};
+
+#define TCA_SFB_MAX (__TCA_SFB_MAX - 1)
+
+/*
+ * Note: increment, decrement are Q0.16 fixed-point values.
+ */
+struct tc_sfb_qopt {
+	__u32 rehash_interval;	/* delay between hash flip, in seconds */
+	__u32 db_interval;	/* double buffering interval in seconds (db_interval < rehash_interval) */
+	__u32 max;		/* max len of qlen_min */
+	__u32 target;		/* bin_size */
+	__u32 increment;	/* delta, (d1 in Blue) */
+	__u32 decrement;	/* delta, (d2 in Blue) */
+	__u32 limit;		/* max SFB queue length */
+	__u32 penalty_rate;
+	__u32 penalty_burst;
+};
+
+struct tc_sfb_xstats {
+	__u32 earlydrop;
+	__u32 penaltydrop;
+	__u32 bucketdrop;
+	__u32 queuedrop;
+	__u32 childdrop; /* drops in child qdisc */
+	__u32 marked;
+	__u32 maxqlen;
+	__u32 maxprob;
+};
+
+#define SFB_MAX_PROB 0xFFFF
+
 #endif
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 16626a0..f40d32e 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -218,6 +218,7 @@ struct tcf_proto {
 
 struct qdisc_skb_cb {
 	unsigned int		pkt_len;
+	unsigned int		sfb_classid;
 	char			data[];
 };
 
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 8c19b6e..a7a5583 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -126,6 +126,17 @@ config NET_SCH_RED
 	  To compile this code as a module, choose M here: the
 	  module will be called sch_red.
 
+config NET_SCH_SFB
+	tristate "Stochastic Fair Blue (SFB)"
+	---help---
+	  Say Y here if you want to use the Stochastic Fair Blue (SFB)
+	  packet scheduling algorithm.
+
+	  See the top of <file:net/sched/sch_sfb.c> for more details.
+
+	  To compile this code as a module, choose M here: the
+	  module will be called sch_sfb.
+
 config NET_SCH_SFQ
 	tristate "Stochastic Fairness Queueing (SFQ)"
 	---help---
diff --git a/net/sched/Makefile b/net/sched/Makefile
index 06c6cdf..2e77b8d 100644
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -24,6 +24,7 @@ obj-$(CONFIG_NET_SCH_RED)	+= sch_red.o
 obj-$(CONFIG_NET_SCH_GRED)	+= sch_gred.o
 obj-$(CONFIG_NET_SCH_INGRESS)	+= sch_ingress.o 
 obj-$(CONFIG_NET_SCH_DSMARK)	+= sch_dsmark.o
+obj-$(CONFIG_NET_SCH_SFB)	+= sch_sfb.o
 obj-$(CONFIG_NET_SCH_SFQ)	+= sch_sfq.o
 obj-$(CONFIG_NET_SCH_TBF)	+= sch_tbf.o
 obj-$(CONFIG_NET_SCH_TEQL)	+= sch_teql.o
diff --git a/net/sched/sch_sfb.c b/net/sched/sch_sfb.c
new file mode 100644
index 0000000..b7f1c6e
--- /dev/null
+++ b/net/sched/sch_sfb.c
@@ -0,0 +1,696 @@
+/*
+ * net/sched/sch_sfb.c	  Stochastic Fair Blue
+ *
+ * Copyright (c) 2008-2011 Juliusz Chroboczek <jch@pps.jussieu.fr>
+ * Copyright (c) 2011 Eric Dumazet <eric.dumazet@gmail.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * version 2 as published by the Free Software Foundation.
+ *
+ * W. Feng, D. Kandlur, D. Saha, K. Shin. Blue: 
+ * A New Class of Active Queue Management Algorithms. 
+ * U. Michigan CSE-TR-387-99, April 1999.
+ *
+ * http://www.thefengs.com/wuchang/blue/CSE-TR-387-99.pdf
+ *
+ */
+
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/errno.h>
+#include <linux/skbuff.h>
+#include <linux/random.h>
+#include <linux/jhash.h>
+#include <net/ip.h>
+#include <net/pkt_sched.h>
+#include <net/inet_ecn.h>
+
+/*
+ * SFB uses two B[l][n] : L x N arrays of bins (L levels, N bins per level)
+ * This implementation uses L = 8 and N = 16
+ * This permits us to split one 32bit hash (provided per packet by rxhash or
+ * external classifier) into 8 subhashes of 4 bits.
+ */
+#define SFB_BUCKET_SHIFT 4
+#define SFB_NUMBUCKETS	(1 << SFB_BUCKET_SHIFT) /* N bins per Level */
+#define SFB_BUCKET_MASK (SFB_NUMBUCKETS - 1)
+#define SFB_LEVELS	(32 / SFB_BUCKET_SHIFT) /* L */
+
+/* SFB algo uses a virtual queue, named "bin" */
+struct sfb_bucket {
+	u16		qlen; /* length of virtual queue */
+	u16		pm; /* marking probability */
+};
+
+/* We use a double buffering right before hash change
+ * (Section 4.4 of SFB reference : moving hash functions)
+ */
+struct sfb_bins {
+	u32		  perturbation; /* jhash perturbation */
+	struct sfb_bucket bins[SFB_LEVELS][SFB_NUMBUCKETS];
+};
+
+struct sfb_sched_data {
+	struct Qdisc	*qdisc;
+	struct tcf_proto *filter_list;
+	unsigned long	rehash_interval;
+	unsigned long	db_interval;	/* interval of double buffering */
+	u32		max;
+	u32		target;		/* bin_size */
+	u32		increment;	/* d1 */
+	u32		decrement;	/* d2 */
+	u32		limit;		/* HARD maximal queue length */
+	u32		penalty_rate;
+	u32		penalty_burst;
+	u32		tokens_avail;
+	unsigned long	rehash_time;
+	unsigned long	token_time;
+
+	u8		slot;		/* current active bins (0 or 1) */
+	bool		double_buffering;
+	struct sfb_bins bins[2];
+
+	struct {
+		u32	earlydrop;
+		u32	penaltydrop;
+		u32	bucketdrop;
+		u32	queuedrop;
+		u32	childdrop;	/* drops in child qdisc */
+		u32	marked;		/* ECN mark */
+	} stats;
+};
+
+/*
+ * If using 'internal' SFB flow classifier, sfb_classid is skb rxhash
+ * If using external classifier, sfb_classid contains the classid.
+ */
+static u32 sfb_hash(const struct sk_buff *skb, u32 slot,
+		    struct sfb_sched_data *q)
+{
+	return jhash_1word(qdisc_skb_cb(skb)->sfb_classid,
+			   q->bins[slot].perturbation);
+}
+
+/* Probabilities are coded as Q0.16 fixed-point values,
+ * with 0xFFFF representing 65535/65536 (almost 1.0)
+ * Addition and subtraction are saturating in [0, 65535]
+ */
+static u32 prob_plus(u32 p1, u32 p2)
+{
+	u32 res = p1 + p2;
+
+	return min_t(u32, res, SFB_MAX_PROB);
+}
+
+static u32 prob_minus(u32 p1, u32 p2)
+{
+	return p1 > p2 ? p1 - p2 : 0;
+}
+
+static void increment_one_qlen(u32 sfbhash, u32 slot, struct sfb_sched_data *q)
+{
+	int i;
+	struct sfb_bucket *b = &q->bins[slot].bins[0][0];
+
+	for (i = 0; i < SFB_LEVELS; i++) {
+		u32 hash = sfbhash & SFB_BUCKET_MASK;
+
+		sfbhash >>= SFB_BUCKET_SHIFT;
+		if (b[hash].qlen < 0xFFFF)
+			b[hash].qlen++;
+		b += SFB_NUMBUCKETS; /* next level */
+	}
+}
+
+static void increment_qlen(u32 hashes[2], struct sfb_sched_data *q)
+{
+	u32 slot = q->slot;
+
+	increment_one_qlen(hashes[slot], slot, q);
+	if (q->double_buffering) {
+		slot ^= 1;
+		increment_one_qlen(hashes[slot], slot, q);
+	}
+}
+
+static void decrement_one_qlen(u32 sfbhash, u32 slot,
+			       struct sfb_sched_data *q)
+{
+	int i;
+	struct sfb_bucket *b = &q->bins[slot].bins[0][0];
+
+	for (i = 0; i < SFB_LEVELS; i++) {
+		u32 hash = sfbhash & SFB_BUCKET_MASK;
+
+		sfbhash >>= SFB_BUCKET_SHIFT;
+		if (b[hash].qlen > 0)
+			b[hash].qlen--;
+		b += SFB_NUMBUCKETS; /* next level */
+	}
+}
+
+static void decrement_qlen(struct sk_buff *skb, struct sfb_sched_data *q)
+{
+	u32 slot = q->slot;
+	u32 sfbhash = sfb_hash(skb, slot, q);
+
+	decrement_one_qlen(sfbhash, slot, q);
+	if (q->double_buffering) {
+		slot ^= 1;
+		sfbhash = sfb_hash(skb, slot, q);
+		decrement_one_qlen(sfbhash, slot, q);
+	}
+}
+
+static void decrement_prob(struct sfb_bucket *b, struct sfb_sched_data *q)
+{
+	b->pm =	prob_minus(b->pm, q->decrement);
+}
+
+static void increment_prob(struct sfb_bucket *b, struct sfb_sched_data *q)
+{
+	b->pm = prob_plus(b->pm, q->increment);
+}
+
+static void sfb_zero_all_buckets(int slot, struct sfb_sched_data *q)
+{
+	memset(&q->bins[slot], 0, sizeof(q->bins[slot]));
+}
+
+/*
+ * compute max qlen and max pm
+ */
+static u32 sfb_compute_qlen(u32 *prob_r, const struct sfb_sched_data *q)
+{
+	int i;
+	u32 qlen = 0, prob = 0;
+	const struct sfb_bucket *b = &q->bins[q->slot].bins[0][0];
+
+	for (i = 0; i < SFB_LEVELS * SFB_NUMBUCKETS; i++) {
+		if (qlen < b->qlen)
+			qlen = b->qlen;
+		if (prob < b->pm)
+			prob = b->pm;
+		b++;
+	}
+	*prob_r = prob;
+	return qlen;
+}
+
+
+static void sfb_init_perturbation(u32 slot, struct sfb_sched_data *q)
+{
+	q->bins[slot].perturbation = net_random();
+}
+
+static void sfb_swap_buffers(struct sfb_sched_data *q)
+{
+	sfb_zero_all_buckets(q->slot, q);
+	sfb_init_perturbation(q->slot, q);
+	q->slot ^= 1;
+	q->double_buffering = false;
+}
+
+/* Non elastic flows are allowed to use part of the bandwidth, expressed
+ * in "penalty_rate" packets per second, with "penalty_burst" burst
+ */
+static bool sfb_rate_limit(struct sk_buff *skb, struct sfb_sched_data *q)
+{
+	if (q->penalty_rate == 0 || q->penalty_burst == 0)
+		return true;
+
+	if (q->tokens_avail < 1) {
+		unsigned long age = min(10UL * HZ, jiffies - q->token_time);
+
+		q->tokens_avail = (age * q->penalty_rate) / HZ;
+		if (q->tokens_avail > q->penalty_burst)
+			q->tokens_avail = q->penalty_burst;
+		q->token_time = jiffies;
+		if (q->tokens_avail < 1)
+			return true;
+	}
+
+	q->tokens_avail--;
+	return false;
+}
+
+static bool sfb_classify(struct sk_buff *skb, struct sfb_sched_data *q,
+			 int *qerr)
+{
+	struct tcf_result res;
+	int result;
+
+	result = tc_classify(skb, q->filter_list, &res);
+	if (result >= 0) {
+#ifdef CONFIG_NET_CLS_ACT
+		switch (result) {
+		case TC_ACT_STOLEN:
+		case TC_ACT_QUEUED:
+			*qerr = NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
+		case TC_ACT_SHOT:
+			return false;
+		}
+#endif
+		qdisc_skb_cb(skb)->sfb_classid = TC_H_MIN(res.classid);
+		return true;
+	}
+	return false;
+}
+
+static int sfb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+{
+
+	struct sfb_sched_data *q = qdisc_priv(sch);
+	struct Qdisc *child = q->qdisc;
+	int i;
+	u32 minprob = SFB_MAX_PROB;
+	u32 minqlen = ~0;
+	u32 r, slot, hashes[2], sfbhash;
+	int ret = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
+
+	if (q->filter_list) {
+		/* If using external classifiers, get result and record it. */
+		if (!sfb_classify(skb, q, &ret))
+			goto other_drop;
+	} else {
+		qdisc_skb_cb(skb)->sfb_classid = skb_get_rxhash(skb);
+	}
+
+	if (q->rehash_interval > 0) {
+		unsigned long limit = q->rehash_time + q->rehash_interval;
+
+		if (unlikely(time_after(jiffies, limit))) {
+			sfb_swap_buffers(q);
+			q->rehash_time = jiffies;
+		} else if (unlikely(!q->double_buffering && q->db_interval > 0 &&
+				    time_after(jiffies, limit - q->db_interval))) {
+			q->double_buffering = true;
+		}
+	}
+
+	slot = q->slot;
+
+	hashes[slot] = sfbhash = sfb_hash(skb, slot, q);
+	for (i = 0; i < SFB_LEVELS; i++) {
+		u32 hash = sfbhash & SFB_BUCKET_MASK;
+		struct sfb_bucket *b = &q->bins[slot].bins[i][hash];
+
+		sfbhash >>= SFB_BUCKET_SHIFT;
+		if (b->qlen == 0)
+			decrement_prob(b, q);
+		else if (unlikely(b->qlen >= q->target))
+			increment_prob(b, q);
+		if (minqlen > b->qlen)
+			minqlen = b->qlen;
+		if (minprob > b->pm)
+			minprob = b->pm;
+	}
+
+	if (q->double_buffering) {
+		slot ^= 1;
+		hashes[slot] = sfbhash = sfb_hash(skb, slot, q);
+		for (i = 0; i < SFB_LEVELS; i++) {
+			u32 hash = sfbhash & SFB_BUCKET_MASK;
+			struct sfb_bucket *b = &q->bins[slot].bins[i][hash];
+
+			sfbhash >>= SFB_BUCKET_SHIFT;
+			if (b->qlen == 0)
+				decrement_prob(b, q);
+			else if (unlikely(b->qlen >= q->target))
+				increment_prob(b, q);
+		}
+	}
+
+	if (unlikely(minqlen >= q->max || sch->q.qlen >= q->limit)) {
+		sch->qstats.overlimits++;
+		if (minqlen >= q->max)
+			q->stats.bucketdrop++;
+		else
+			q->stats.queuedrop++;
+		goto drop;
+	}
+
+	if (unlikely(minprob >= SFB_MAX_PROB)) {
+		/* Inelastic flow */
+		if (sfb_rate_limit(skb, q)) {
+			sch->qstats.overlimits++;
+			q->stats.penaltydrop++;
+			goto drop;
+		}
+		goto enqueue;
+	}
+
+	r = net_random() & SFB_MAX_PROB;
+
+	if (unlikely(r < minprob)) {
+		if (unlikely(minprob > SFB_MAX_PROB / 2)) {
+			/* If we're marking that many packets, then either
+			 * this flow is unresponsive, or we're badly congested.
+			 * In either case, we want to start dropping packets.
+			 */
+			if (r < (minprob - SFB_MAX_PROB / 2) * 2) {
+				q->stats.earlydrop++;
+				goto drop;
+			}
+		}
+		if (INET_ECN_set_ce(skb)) {
+			q->stats.marked++;
+		} else {
+			q->stats.earlydrop++;
+			goto drop;
+		}
+	}
+
+enqueue:
+	ret = qdisc_enqueue(skb, child);
+	if (likely(ret == NET_XMIT_SUCCESS)) {
+		sch->q.qlen++;
+		increment_qlen(hashes, q);
+	} else if (net_xmit_drop_count(ret)) {
+		q->stats.childdrop++;
+		sch->qstats.drops++;
+	}
+	return ret;
+
+drop:
+	qdisc_drop(skb, sch);
+	return NET_XMIT_CN;
+other_drop:
+	if (ret & __NET_XMIT_BYPASS)
+		sch->qstats.drops++;
+	kfree_skb(skb);
+	return ret;
+}
+
+static struct sk_buff *sfb_dequeue(struct Qdisc *sch)
+{
+	struct sfb_sched_data *q = qdisc_priv(sch);
+	struct Qdisc *child = q->qdisc;
+	struct sk_buff *skb;
+
+	skb = child->dequeue(q->qdisc);
+
+	if (skb) {
+		qdisc_bstats_update(sch, skb);
+		sch->q.qlen--;
+		decrement_qlen(skb, q);
+	}
+
+	return skb;
+}
+
+static struct sk_buff *sfb_peek(struct Qdisc *sch)
+{
+	struct sfb_sched_data *q = qdisc_priv(sch);
+	struct Qdisc *child = q->qdisc;
+
+	return child->ops->peek(child);
+}
+
+/* No sfb_drop -- impossible since the child doesn't return the dropped skb. */
+
+static void sfb_reset(struct Qdisc *sch)
+{
+	struct sfb_sched_data *q = qdisc_priv(sch);
+
+	qdisc_reset(q->qdisc);
+	sch->q.qlen = 0;
+	q->slot = 0;
+	q->double_buffering = false;
+	sfb_zero_all_buckets(0, q);
+	sfb_zero_all_buckets(1, q);
+	sfb_init_perturbation(0, q);
+}
+
+static void sfb_destroy(struct Qdisc *sch)
+{
+	struct sfb_sched_data *q = qdisc_priv(sch);
+
+	tcf_destroy_chain(&q->filter_list);
+	qdisc_destroy(q->qdisc);
+}
+
+static const struct nla_policy sfb_policy[TCA_SFB_MAX + 1] = {
+	[TCA_SFB_PARMS]	= { .len = sizeof(struct tc_sfb_qopt) },
+};
+
+static int sfb_change(struct Qdisc *sch, struct nlattr *opt)
+{
+	struct sfb_sched_data *q = qdisc_priv(sch);
+	struct Qdisc *child = NULL;
+	struct nlattr *tb[TCA_SFB_MAX + 1];
+	struct tc_sfb_qopt *ctl;
+	u32 rehash_interval, db_interval;
+	u32 limit;
+	u32 max, target;
+	u32 increment, decrement;
+	u32 penalty_rate, penalty_burst;
+	int err;
+
+	if (opt == NULL) {
+		rehash_interval = 600;
+		db_interval = 60;
+		limit = 0;
+		max = 25;
+		target = 20;
+		increment = (SFB_MAX_PROB + 500) / 1000; /* 0.1 % */
+		decrement = (SFB_MAX_PROB + 3000) / 6000;
+		penalty_rate = 10;
+		penalty_burst = 20;
+	} else {
+		err = nla_parse_nested(tb, TCA_SFB_MAX, opt, sfb_policy);
+		if (err < 0)
+			return -EINVAL;
+
+		if (tb[TCA_SFB_PARMS] == NULL)
+			return -EINVAL;
+
+		ctl = nla_data(tb[TCA_SFB_PARMS]);
+
+		rehash_interval = ctl->rehash_interval;
+		db_interval = ctl->db_interval;
+		limit = ctl->limit;
+		max = ctl->max;
+		target = ctl->target;
+		increment = ctl->increment;
+		decrement = ctl->decrement;
+		penalty_rate = ctl->penalty_rate;
+		penalty_burst = ctl->penalty_burst;
+	}
+
+	if (limit == 0)
+		limit = qdisc_dev(sch)->tx_queue_len;
+	if (limit == 0)
+		limit = 1;
+
+	child = fifo_create_dflt(sch, &pfifo_qdisc_ops, limit);
+	if (IS_ERR(child))
+		return PTR_ERR(child);
+
+	sch_tree_lock(sch);
+
+	qdisc_tree_decrease_qlen(q->qdisc, q->qdisc->q.qlen);
+	qdisc_destroy(q->qdisc);
+	q->qdisc = child;
+
+	q->rehash_interval = (unsigned long)rehash_interval * HZ;
+	q->db_interval = (unsigned long)db_interval * HZ;
+	q->rehash_time = jiffies;
+	q->limit = limit;
+	q->increment = increment;
+	q->decrement = decrement;
+	q->max = max;
+	q->target = target;
+	q->penalty_rate = penalty_rate;
+	q->penalty_burst = penalty_burst;
+	q->tokens_avail = penalty_burst;
+	q->token_time = jiffies;
+
+	q->slot = 0;
+	q->double_buffering = false;
+	sfb_zero_all_buckets(0, q);
+	sfb_zero_all_buckets(1, q);
+	sfb_init_perturbation(0, q);
+
+	sch_tree_unlock(sch);
+
+	return 0;
+}
+
+static int sfb_init(struct Qdisc *sch, struct nlattr *opt)
+{
+	struct sfb_sched_data *q = qdisc_priv(sch);
+
+	q->qdisc = &noop_qdisc;
+	return sfb_change(sch, opt);
+}
+
+static int sfb_dump(struct Qdisc *sch, struct sk_buff *skb)
+{
+	struct sfb_sched_data *q = qdisc_priv(sch);
+	struct nlattr *opts;
+	struct tc_sfb_qopt opt = {
+		.rehash_interval = q->rehash_interval / HZ,
+		.db_interval = q->db_interval / HZ,
+		.limit = q->limit,
+		.max = q->max,
+		.target = q->target,
+		.increment = q->increment,
+		.decrement = q->decrement,
+		.penalty_rate = q->penalty_rate,
+		.penalty_burst = q->penalty_burst,
+	};
+
+	sch->qstats.backlog = q->qdisc->qstats.backlog;
+	opts = nla_nest_start(skb, TCA_OPTIONS);
+	NLA_PUT(skb, TCA_SFB_PARMS, sizeof(opt), &opt);
+	return nla_nest_end(skb, opts);
+
+nla_put_failure:
+	nla_nest_cancel(skb, opts);
+	return -EMSGSIZE;
+}
+
+static int sfb_dump_stats(struct Qdisc *sch, struct gnet_dump *d)
+{
+	struct sfb_sched_data *q = qdisc_priv(sch);
+	struct tc_sfb_xstats st = {
+		.earlydrop = q->stats.earlydrop,
+		.penaltydrop = q->stats.penaltydrop,
+		.bucketdrop = q->stats.bucketdrop,
+		.queuedrop = q->stats.queuedrop,
+		.childdrop = q->stats.childdrop,
+		.marked = q->stats.marked,
+	};
+
+	st.maxqlen = sfb_compute_qlen(&st.maxprob, q);
+
+	return gnet_stats_copy_app(d, &st, sizeof(st));
+}
+
+static int sfb_dump_class(struct Qdisc *sch, unsigned long cl,
+			  struct sk_buff *skb, struct tcmsg *tcm)
+{
+	return -ENOSYS;
+}
+
+static int sfb_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
+		     struct Qdisc **old)
+{
+	struct sfb_sched_data *q = qdisc_priv(sch);
+
+	if (new == NULL)
+		new = &noop_qdisc;
+
+	sch_tree_lock(sch);
+	*old = q->qdisc;
+	q->qdisc = new;
+	qdisc_tree_decrease_qlen(*old, (*old)->q.qlen);
+	qdisc_reset(*old);
+	sch_tree_unlock(sch);
+	return 0;
+}
+
+static struct Qdisc *sfb_leaf(struct Qdisc *sch, unsigned long arg)
+{
+	struct sfb_sched_data *q = qdisc_priv(sch);
+
+	return q->qdisc;
+}
+
+static unsigned long sfb_get(struct Qdisc *sch, u32 classid)
+{
+	return 1;
+}
+
+static void sfb_put(struct Qdisc *sch, unsigned long arg)
+{
+}
+
+static int sfb_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
+			    struct nlattr **tca, unsigned long *arg)
+{
+	return -ENOSYS;
+}
+
+static int sfb_delete(struct Qdisc *sch, unsigned long cl)
+{
+	return -ENOSYS;
+}
+
+static void sfb_walk(struct Qdisc *sch, struct qdisc_walker *walker)
+{
+	if (!walker->stop) {
+		if (walker->count >= walker->skip)
+			if (walker->fn(sch, 1, walker) < 0) {
+				walker->stop = 1;
+				return;
+			}
+		walker->count++;
+	}
+}
+
+static struct tcf_proto **sfb_find_tcf(struct Qdisc *sch, unsigned long cl)
+{
+	struct sfb_sched_data *q = qdisc_priv(sch);
+
+	if (cl)
+		return NULL;
+	return &q->filter_list;
+}
+
+static unsigned long sfb_bind(struct Qdisc *sch, unsigned long parent,
+			      u32 classid)
+{
+	return 0;
+}
+
+
+static const struct Qdisc_class_ops sfb_class_ops = {
+	.graft		=	sfb_graft,
+	.leaf		=	sfb_leaf,
+	.get		=	sfb_get,
+	.put		=	sfb_put,
+	.change		=	sfb_change_class,
+	.delete		=	sfb_delete,
+	.walk		=	sfb_walk,
+	.tcf_chain	=	sfb_find_tcf,
+	.bind_tcf	=	sfb_bind,
+	.unbind_tcf	=	sfb_put,
+	.dump		=	sfb_dump_class,
+};
+
+struct Qdisc_ops sfb_qdisc_ops __read_mostly = {
+	.id		=	"sfb",
+	.priv_size	=	sizeof(struct sfb_sched_data),
+	.cl_ops		=	&sfb_class_ops,
+	.enqueue	=	sfb_enqueue,
+	.dequeue	=	sfb_dequeue,
+	.peek		=	sfb_peek,
+	.init		=	sfb_init,
+	.reset		=	sfb_reset,
+	.destroy	=	sfb_destroy,
+	.change		=	sfb_change,
+	.dump		=	sfb_dump,
+	.dump_stats	=	sfb_dump_stats,
+	.owner		=	THIS_MODULE,
+};
+
+static int __init sfb_module_init(void)
+{
+	return register_qdisc(&sfb_qdisc_ops);
+}
+
+static void __exit sfb_module_exit(void)
+{
+	unregister_qdisc(&sfb_qdisc_ops);
+}
+
+module_init(sfb_module_init)
+module_exit(sfb_module_exit)
+
+MODULE_DESCRIPTION("Stochastic Fair Blue queue discipline");
+MODULE_AUTHOR("Juliusz Chroboczek");
+MODULE_LICENSE("GPL");


