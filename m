From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net_sched: sfq: allow divisor to be a variable
Date: Thu, 20 Jan 2011 10:50:52 +0100
Message-ID: <1295517052.2733.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Patrick McHardy <kaber@trash.net>,
	Jesper Dangaard Brouer <hawk@diku.dk>,
	Jarek Poplawski <jarkao2@gmail.com>, jamal <hadi@cyberus.ca>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:55074 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752110Ab1ATKPD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 05:15:03 -0500
Received: by wwa36 with SMTP id 36so445004wwa.1
        for <netdev@vger.kernel.org>; Thu, 20 Jan 2011 02:15:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SFQ currently uses a 1024 slots hash table, and its internal structure
(sfq_sched_data) allocation needs order-1 page on x86_64

Allow tc command to specify a divisor value (hash table size), between 1
and 65536.
If no value is provided, assume the 1024 default size.

This allows admins to setup smaller (or bigger) SFQ for specific needs.

This also brings back sfq_sched_data allocations to order-0 ones, saving
3KB per SFQ qdisc.

Jesper uses ~55.000 sfq in one machine, this patch should free 165 MB of
memory.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Patrick McHardy <kaber@trash.net>
CC: Jesper Dangaard Brouer <hawk@diku.dk>
CC: Jarek Poplawski <jarkao2@gmail.com>
CC: Jamal Hadi Salim <hadi@cyberus.ca>
---
 net/sched/sch_sfq.c |   43 ++++++++++++++++++++++++++++++------------
 1 file changed, 31 insertions(+), 12 deletions(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 3fe5c45..ad7fa8b 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -21,6 +21,7 @@
 #include <linux/skbuff.h>
 #include <linux/jhash.h>
 #include <linux/slab.h>
+#include <linux/vmalloc.h>
 #include <net/ip.h>
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
@@ -76,7 +77,8 @@
 #define SFQ_DEPTH		128 /* max number of packets per flow */
 #define SFQ_SLOTS		128 /* max number of flows */
 #define SFQ_EMPTY_SLOT		255
-#define SFQ_HASH_DIVISOR	1024
+#define SFQ_DEFAULT_HASH_DIVISOR 1024
+
 /* We use 16 bits to store allot, and want to handle packets up to 64K
  * Scale allot by 8 (1<<3) so that no overflow occurs.
  */
@@ -112,7 +114,7 @@ struct sfq_sched_data {
 	int		perturb_period;
 	unsigned int	quantum;	/* Allotment per round: MUST BE >= MTU */
 	int		limit;
-
+	unsigned int	divisor;	/* number of slots in hash table */
 /* Variables */
 	struct tcf_proto *filter_list;
 	struct timer_list perturb_timer;
@@ -120,7 +122,7 @@ struct sfq_sched_data {
 	sfq_index	cur_depth;	/* depth of longest slot */
 	unsigned short  scaled_quantum; /* SFQ_ALLOT_SIZE(quantum) */
 	struct sfq_slot *tail;		/* current slot in round */
-	sfq_index	ht[SFQ_HASH_DIVISOR];	/* Hash table */
+	sfq_index	*ht;		/* Hash table (divisor slots) */
 	struct sfq_slot	slots[SFQ_SLOTS];
 	struct sfq_head	dep[SFQ_DEPTH];	/* Linked list of slots, indexed by depth */
 };
@@ -137,7 +139,7 @@ static inline struct sfq_head *sfq_dep_head(struct sfq_sched_data *q, sfq_index
 
 static unsigned int sfq_fold_hash(struct sfq_sched_data *q, u32 h, u32 h1)
 {
-	return jhash_2words(h, h1, q->perturbation) & (SFQ_HASH_DIVISOR - 1);
+	return jhash_2words(h, h1, q->perturbation) & (q->divisor - 1);
 }
 
 static unsigned int sfq_hash(struct sfq_sched_data *q, struct sk_buff *skb)
@@ -201,7 +203,7 @@ static unsigned int sfq_classify(struct sk_buff *skb, struct Qdisc *sch,
 
 	if (TC_H_MAJ(skb->priority) == sch->handle &&
 	    TC_H_MIN(skb->priority) > 0 &&
-	    TC_H_MIN(skb->priority) <= SFQ_HASH_DIVISOR)
+	    TC_H_MIN(skb->priority) <= q->divisor)
 		return TC_H_MIN(skb->priority);
 
 	if (!q->filter_list)
@@ -219,7 +221,7 @@ static unsigned int sfq_classify(struct sk_buff *skb, struct Qdisc *sch,
 			return 0;
 		}
 #endif
-		if (TC_H_MIN(res.classid) <= SFQ_HASH_DIVISOR)
+		if (TC_H_MIN(res.classid) <= q->divisor)
 			return TC_H_MIN(res.classid);
 	}
 	return 0;
@@ -496,7 +498,12 @@ static int sfq_change(struct Qdisc *sch, struct nlattr *opt)
 	q->perturb_period = ctl->perturb_period * HZ;
 	if (ctl->limit)
 		q->limit = min_t(u32, ctl->limit, SFQ_DEPTH - 1);
-
+	if (ctl->divisor) {
+		if (!is_power_of_2(ctl->divisor) || ctl->divisor > 65536)
+			return -EINVAL;
+		q->divisor = ctl->divisor;
+			
+	}
 	qlen = sch->q.qlen;
 	while (sch->q.qlen > q->limit)
 		sfq_drop(sch);
@@ -514,15 +521,13 @@ static int sfq_change(struct Qdisc *sch, struct nlattr *opt)
 static int sfq_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
+	size_t sz;
 	int i;
 
 	q->perturb_timer.function = sfq_perturbation;
 	q->perturb_timer.data = (unsigned long)sch;
 	init_timer_deferrable(&q->perturb_timer);
 
-	for (i = 0; i < SFQ_HASH_DIVISOR; i++)
-		q->ht[i] = SFQ_EMPTY_SLOT;
-
 	for (i = 0; i < SFQ_DEPTH; i++) {
 		q->dep[i].next = i + SFQ_SLOTS;
 		q->dep[i].prev = i + SFQ_SLOTS;
@@ -531,6 +536,7 @@ static int sfq_init(struct Qdisc *sch, struct nlattr *opt)
 	q->limit = SFQ_DEPTH - 1;
 	q->cur_depth = 0;
 	q->tail = NULL;
+	q->divisor = SFQ_DEFAULT_HASH_DIVISOR;
 	if (opt == NULL) {
 		q->quantum = psched_mtu(qdisc_dev(sch));
 		q->scaled_quantum = SFQ_ALLOT_SIZE(q->quantum);
@@ -542,6 +548,15 @@ static int sfq_init(struct Qdisc *sch, struct nlattr *opt)
 			return err;
 	}
 
+	sz = sizeof(q->ht[0]) * q->divisor;
+	q->ht = kmalloc(sz, GFP_KERNEL);
+	if (!q->ht && sz > PAGE_SIZE)
+		q->ht = vmalloc(sz);
+	if (!q->ht)
+		return -ENOMEM;
+	for (i = 0; i < q->divisor; i++)
+		q->ht[i] = SFQ_EMPTY_SLOT;
+
 	for (i = 0; i < SFQ_SLOTS; i++) {
 		slot_queue_init(&q->slots[i]);
 		sfq_link(q, i);
@@ -556,6 +571,10 @@ static void sfq_destroy(struct Qdisc *sch)
 	tcf_destroy_chain(&q->filter_list);
 	q->perturb_period = 0;
 	del_timer_sync(&q->perturb_timer);
+	if (is_vmalloc_addr(q->ht))
+		vfree(q->ht);
+	else
+		kfree(q->ht);
 }
 
 static int sfq_dump(struct Qdisc *sch, struct sk_buff *skb)
@@ -568,7 +587,7 @@ static int sfq_dump(struct Qdisc *sch, struct sk_buff *skb)
 	opt.perturb_period = q->perturb_period / HZ;
 
 	opt.limit = q->limit;
-	opt.divisor = SFQ_HASH_DIVISOR;
+	opt.divisor = q->divisor;
 	opt.flows = q->limit;
 
 	NLA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
@@ -646,7 +665,7 @@ static void sfq_walk(struct Qdisc *sch, struct qdisc_walker *arg)
 	if (arg->stop)
 		return;
 
-	for (i = 0; i < SFQ_HASH_DIVISOR; i++) {
+	for (i = 0; i < q->divisor; i++) {
 		if (q->ht[i] == SFQ_EMPTY_SLOT ||
 		    arg->count < arg->skip) {
 			arg->count++;


