From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v3 net-next-2.6] net_sched: sch_sfq: better struct layouts
Date: Mon, 20 Dec 2010 23:54:58 +0100
Message-ID: <1292885698.2627.119.camel@edumazet-laptop>
References: <1292604766.2906.51.camel@edumazet-laptop>
	 <20101219212234.GA2323@del.dom.local>
	 <1292864525.2800.189.camel@edumazet-laptop>
	 <20101220.133342.246531313.davem@davemloft.net>
	 <1292881372.2627.38.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Jarek Poplawski <jarkao2@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56939 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757660Ab0LTWzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 17:55:08 -0500
Received: by wyb28 with SMTP id 28so3382854wyb.19
        for <netdev@vger.kernel.org>; Mon, 20 Dec 2010 14:55:06 -0800 (PST)
In-Reply-To: <1292881372.2627.38.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is a respin of patch.

I'll send a short patch to make SFQ more fair in presence of large
packets as well.

Thanks

[PATCH v3 net-next-2.6] net_sched: sch_sfq: better struct layouts

This patch shrinks sizeof(struct sfq_sched_data)
from 0x14f8 (or more if spinlocks are bigger) to 0x1180 bytes, and
reduce text size as well.

   text    data     bss     dec     hex filename
   4821     152       0    4973    136d old/net/sched/sch_sfq.o
   4627     136       0    4763    129b new/net/sched/sch_sfq.o


All data for a slot/flow is now grouped in a compact and cache friendly
structure, instead of being spreaded in many different points.

struct sfq_slot {
        struct sk_buff  *skblist_next;
        struct sk_buff  *skblist_prev;
        sfq_index       qlen; /* number of skbs in skblist */
        sfq_index       next; /* next slot in sfq chain */
        struct sfq_head dep; /* anchor in dep[] chains */
        unsigned short  hash; /* hash value (index in ht[]) */
        short           allot; /* credit for this slot */
};

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Jarek Poplawski <jarkao2@gmail.com>
Cc: Patrick McHardy <kaber@trash.net>
---
v3: respin after two prior patches applied

 net/sched/sch_sfq.c |  260 ++++++++++++++++++++++++++----------------
 1 file changed, 162 insertions(+), 98 deletions(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 42396c9..c474b4b 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -67,27 +67,42 @@
 
 	IMPLEMENTATION:
 	This implementation limits maximal queue length to 128;
-	maximal mtu to 2^15-1; number of hash buckets to 1024.
+	maximal mtu to 2^15-1; max 128 flows, number of hash buckets to 1024.
 	The only goal of this restrictions was that all data
-	fit into one 4K page :-). Struct sfq_sched_data is
-	organized in anti-cache manner: all the data for a bucket
-	are scattered over different locations. This is not good,
-	but it allowed me to put it into 4K.
+	fit into one 4K page on 32bit arches.
 
 	It is easy to increase these values, but not in flight.  */
 
-#define SFQ_DEPTH		128
+#define SFQ_DEPTH		128 /* max number of packets per flow */
+#define SFQ_SLOTS		128 /* max number of flows */
+#define SFQ_EMPTY_SLOT		255
 #define SFQ_HASH_DIVISOR	1024
 
-/* This type should contain at least SFQ_DEPTH*2 values */
+/* This type should contain at least SFQ_DEPTH + SFQ_SLOTS values */
 typedef unsigned char sfq_index;
 
+/*
+ * We dont use pointers to save space.
+ * Small indexes [0 ... SFQ_SLOTS - 1] are 'pointers' to slots[] array
+ * while following values [SFQ_SLOTS ... SFQ_SLOTS + SFQ_DEPTH - 1]
+ * are 'pointers' to dep[] array
+ */
 struct sfq_head
 {
 	sfq_index	next;
 	sfq_index	prev;
 };
 
+struct sfq_slot {
+	struct sk_buff	*skblist_next;
+	struct sk_buff	*skblist_prev;
+	sfq_index	qlen; /* number of skbs in skblist */
+	sfq_index	next; /* next slot in sfq chain */
+	struct sfq_head dep; /* anchor in dep[] chains */
+	unsigned short	hash; /* hash value (index in ht[]) */
+	short		allot; /* credit for this slot */
+};
+
 struct sfq_sched_data
 {
 /* Parameters */
@@ -99,17 +114,24 @@ struct sfq_sched_data
 	struct tcf_proto *filter_list;
 	struct timer_list perturb_timer;
 	u32		perturbation;
-	sfq_index	tail;		/* Index of current slot in round */
-	sfq_index	max_depth;	/* Maximal depth */
+	sfq_index	cur_depth;	/* depth of longest slot */
 
+	struct sfq_slot *tail;		/* current slot in round */
 	sfq_index	ht[SFQ_HASH_DIVISOR];	/* Hash table */
-	sfq_index	next[SFQ_DEPTH];	/* Active slots link */
-	short		allot[SFQ_DEPTH];	/* Current allotment per slot */
-	unsigned short	hash[SFQ_DEPTH];	/* Hash value indexed by slots */
-	struct sk_buff_head	qs[SFQ_DEPTH];		/* Slot queue */
-	struct sfq_head	dep[SFQ_DEPTH*2];	/* Linked list of slots, indexed by depth */
+	struct sfq_slot	slots[SFQ_SLOTS];
+	struct sfq_head	dep[SFQ_DEPTH];	/* Linked list of slots, indexed by depth */
 };
 
+/*
+ * sfq_head are either in a sfq_slot or in dep[] array
+ */
+static inline struct sfq_head *sfq_dep_head(struct sfq_sched_data *q, sfq_index val)
+{
+	if (val < SFQ_SLOTS)
+		return &q->slots[val].dep;
+	return &q->dep[val - SFQ_SLOTS];
+}
+
 static __inline__ unsigned sfq_fold_hash(struct sfq_sched_data *q, u32 h, u32 h1)
 {
 	return jhash_2words(h, h1, q->perturbation) & (SFQ_HASH_DIVISOR - 1);
@@ -200,30 +222,41 @@ static unsigned int sfq_classify(struct sk_buff *skb, struct Qdisc *sch,
 	return 0;
 }
 
+/*
+ * x : slot number [0 .. SFQ_SLOTS - 1]
+ */
 static inline void sfq_link(struct sfq_sched_data *q, sfq_index x)
 {
 	sfq_index p, n;
-	int d = q->qs[x].qlen + SFQ_DEPTH;
+	int qlen = q->slots[x].qlen;
 
-	p = d;
-	n = q->dep[d].next;
-	q->dep[x].next = n;
-	q->dep[x].prev = p;
-	q->dep[p].next = q->dep[n].prev = x;
+	p = qlen + SFQ_SLOTS;
+	n = q->dep[qlen].next;
+
+	q->slots[x].dep.next = n;
+	q->slots[x].dep.prev = p;
+
+	q->dep[qlen].next = x;		/* sfq_dep_head(q, p)->next = x */
+	sfq_dep_head(q, n)->prev = x;
 }
 
+#define sfq_unlink(q, x, n, p)			\
+	n = q->slots[x].dep.next;		\
+	p = q->slots[x].dep.prev;		\
+	sfq_dep_head(q, p)->next = n;		\
+	sfq_dep_head(q, n)->prev = p
+	
+
 static inline void sfq_dec(struct sfq_sched_data *q, sfq_index x)
 {
 	sfq_index p, n;
+	int d;
 
-	n = q->dep[x].next;
-	p = q->dep[x].prev;
-	q->dep[p].next = n;
-	q->dep[n].prev = p;
-
-	if (n == p && q->max_depth == q->qs[x].qlen + 1)
-		q->max_depth--;
+	sfq_unlink(q, x, n, p);
 
+	d = q->slots[x].qlen--;
+	if (n == p && q->cur_depth == d)
+		q->cur_depth--;
 	sfq_link(q, x);
 }
 
@@ -232,34 +265,72 @@ static inline void sfq_inc(struct sfq_sched_data *q, sfq_index x)
 	sfq_index p, n;
 	int d;
 
-	n = q->dep[x].next;
-	p = q->dep[x].prev;
-	q->dep[p].next = n;
-	q->dep[n].prev = p;
-	d = q->qs[x].qlen;
-	if (q->max_depth < d)
-		q->max_depth = d;
+	sfq_unlink(q, x, n, p);
 
+	d = ++q->slots[x].qlen;
+	if (q->cur_depth < d)
+		q->cur_depth = d;
 	sfq_link(q, x);
 }
 
+/* helper functions : might be changed when/if skb use a standard list_head */
+
+/* remove one skb from tail of slot queue */
+static inline struct sk_buff *slot_dequeue_tail(struct sfq_slot *slot)
+{
+	struct sk_buff *skb = slot->skblist_prev;
+
+	slot->skblist_prev = skb->prev;
+	skb->next = skb->prev = NULL;
+	return skb;
+}
+
+/* remove one skb from head of slot queue */
+static inline struct sk_buff *slot_dequeue_head(struct sfq_slot *slot)
+{
+	struct sk_buff *skb = slot->skblist_next;
+
+	slot->skblist_next = skb->next;
+	skb->next = skb->prev = NULL;
+	return skb;
+}
+
+static inline void slot_queue_init(struct sfq_slot *slot)
+{
+	slot->skblist_prev = slot->skblist_next = (struct sk_buff *)slot;
+}
+
+/* add skb to slot queue (tail add) */
+static inline void slot_queue_add(struct sfq_slot *slot, struct sk_buff *skb)
+{
+	skb->prev = slot->skblist_prev;
+	skb->next = (struct sk_buff *)slot;
+	slot->skblist_prev->next = skb;
+	slot->skblist_prev = skb;
+}
+
+#define	slot_queue_walk(slot, skb)		\
+	for (skb = slot->skblist_next;		\
+	     skb != (struct sk_buff *)slot;	\
+	     skb = skb->next)
+
 static unsigned int sfq_drop(struct Qdisc *sch)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
-	sfq_index d = q->max_depth;
+	sfq_index x, d = q->cur_depth;
 	struct sk_buff *skb;
 	unsigned int len;
+	struct sfq_slot *slot;
 
-	/* Queue is full! Find the longest slot and
-	   drop a packet from it */
-
+	/* Queue is full! Find the longest slot and drop tail packet from it */
 	if (d > 1) {
-		sfq_index x = q->dep[d + SFQ_DEPTH].next;
-		skb = q->qs[x].prev;
+		x = q->dep[d].next;
+		slot = &q->slots[x];
+drop:
+		skb = slot_dequeue_tail(slot);
 		len = qdisc_pkt_len(skb);
-		__skb_unlink(skb, &q->qs[x]);
-		kfree_skb(skb);
 		sfq_dec(q, x);
+		kfree_skb(skb);
 		sch->q.qlen--;
 		sch->qstats.drops++;
 		sch->qstats.backlog -= len;
@@ -268,18 +339,11 @@ static unsigned int sfq_drop(struct Qdisc *sch)
 
 	if (d == 1) {
 		/* It is difficult to believe, but ALL THE SLOTS HAVE LENGTH 1. */
-		d = q->next[q->tail];
-		q->next[q->tail] = q->next[d];
-		skb = q->qs[d].prev;
-		len = qdisc_pkt_len(skb);
-		__skb_unlink(skb, &q->qs[d]);
-		kfree_skb(skb);
-		sfq_dec(q, d);
-		sch->q.qlen--;
-		q->ht[q->hash[d]] = SFQ_DEPTH;
-		sch->qstats.drops++;
-		sch->qstats.backlog -= len;
-		return len;
+		x = q->tail->next;
+		slot = &q->slots[x];
+		q->tail->next = slot->next;
+		q->ht[slot->hash] = SFQ_EMPTY_SLOT;
+		goto drop;
 	}
 
 	return 0;
@@ -291,6 +355,7 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	struct sfq_sched_data *q = qdisc_priv(sch);
 	unsigned int hash;
 	sfq_index x;
+	struct sfq_slot *slot;
 	int uninitialized_var(ret);
 
 	hash = sfq_classify(skb, sch, &ret);
@@ -303,30 +368,33 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	hash--;
 
 	x = q->ht[hash];
-	if (x == SFQ_DEPTH) {
-		q->ht[hash] = x = q->dep[SFQ_DEPTH].next;
-		q->hash[x] = hash;
+	slot = &q->slots[x];
+	if (x == SFQ_EMPTY_SLOT) {
+		x = q->dep[0].next; /* get a free slot */
+		q->ht[hash] = x;
+		slot = &q->slots[x];
+		slot->hash = hash;
+		slot_queue_init(slot);
 	}
 
-	/* If selected queue has length q->limit, this means that
-	 * all another queues are empty and that we do simple tail drop,
+	/* If selected queue has length q->limit, do simple tail drop,
 	 * i.e. drop _this_ packet.
 	 */
-	if (q->qs[x].qlen >= q->limit)
+	if (slot->qlen >= q->limit)
 		return qdisc_drop(skb, sch);
 
 	sch->qstats.backlog += qdisc_pkt_len(skb);
-	__skb_queue_tail(&q->qs[x], skb);
+	slot_queue_add(slot, skb);
 	sfq_inc(q, x);
-	if (q->qs[x].qlen == 1) {		/* The flow is new */
-		if (q->tail == SFQ_DEPTH) {	/* It is the first flow */
-			q->next[x] = x;
+	if (slot->qlen == 1) {		/* The flow is new */
+		if (q->tail == NULL) {	/* It is the first flow */
+			slot->next = x;
 		} else {
-			q->next[x] = q->next[q->tail];
-			q->next[q->tail] = x;
+			slot->next = q->tail->next;
+			q->tail->next = x;
 		}
-		q->tail = x;
-		q->allot[x] = q->quantum;
+		q->tail = slot;
+		slot->allot = q->quantum;
 	}
 	if (++sch->q.qlen <= q->limit) {
 		sch->bstats.bytes += qdisc_pkt_len(skb);
@@ -342,14 +410,12 @@ static struct sk_buff *
 sfq_peek(struct Qdisc *sch)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
-	sfq_index a;
 
 	/* No active slots */
-	if (q->tail == SFQ_DEPTH)
+	if (q->tail == NULL)
 		return NULL;
 
-	a = q->next[q->tail];
-	return skb_peek(&q->qs[a]);
+	return q->slots[q->tail->next].skblist_next;
 }
 
 static struct sk_buff *
@@ -358,31 +424,31 @@ sfq_dequeue(struct Qdisc *sch)
 	struct sfq_sched_data *q = qdisc_priv(sch);
 	struct sk_buff *skb;
 	sfq_index a, next_a;
+	struct sfq_slot *slot;
 
 	/* No active slots */
-	if (q->tail == SFQ_DEPTH)
+	if (q->tail == NULL)
 		return NULL;
 
-	a = q->next[q->tail];
-
-	/* Grab packet */
-	skb = __skb_dequeue(&q->qs[a]);
+	a = q->tail->next;
+	slot = &q->slots[a];
+	skb = slot_dequeue_head(slot);
 	sfq_dec(q, a);
 	sch->q.qlen--;
 	sch->qstats.backlog -= qdisc_pkt_len(skb);
 
 	/* Is the slot empty? */
-	if (q->qs[a].qlen == 0) {
-		q->ht[q->hash[a]] = SFQ_DEPTH;
-		next_a = q->next[a];
+	if (slot->qlen == 0) {
+		q->ht[slot->hash] = SFQ_EMPTY_SLOT;
+		next_a = slot->next;
 		if (a == next_a) {
-			q->tail = SFQ_DEPTH;
+			q->tail = NULL; /* no more active slots */
 			return skb;
 		}
-		q->next[q->tail] = next_a;
-	} else if ((q->allot[a] -= qdisc_pkt_len(skb)) <= 0) {
-		q->allot[a] += q->quantum;
-		q->tail = a;
+		q->tail->next = next_a;
+	} else if ((slot->allot -= qdisc_pkt_len(skb)) <= 0) {
+		q->tail = slot;
+		slot->allot += q->quantum;
 	}
 	return skb;
 }
@@ -446,17 +512,16 @@ static int sfq_init(struct Qdisc *sch, struct nlattr *opt)
 	init_timer_deferrable(&q->perturb_timer);
 
 	for (i = 0; i < SFQ_HASH_DIVISOR; i++)
-		q->ht[i] = SFQ_DEPTH;
+		q->ht[i] = SFQ_EMPTY_SLOT;
 
 	for (i = 0; i < SFQ_DEPTH; i++) {
-		skb_queue_head_init(&q->qs[i]);
-		q->dep[i + SFQ_DEPTH].next = i + SFQ_DEPTH;
-		q->dep[i + SFQ_DEPTH].prev = i + SFQ_DEPTH;
+		q->dep[i].next = i + SFQ_SLOTS;
+		q->dep[i].prev = i + SFQ_SLOTS;
 	}
 
 	q->limit = SFQ_DEPTH - 1;
-	q->max_depth = 0;
-	q->tail = SFQ_DEPTH;
+	q->cur_depth = 0;
+	q->tail = NULL;
 	if (opt == NULL) {
 		q->quantum = psched_mtu(qdisc_dev(sch));
 		q->perturb_period = 0;
@@ -467,7 +532,7 @@ static int sfq_init(struct Qdisc *sch, struct nlattr *opt)
 			return err;
 	}
 
-	for (i = 0; i < SFQ_DEPTH; i++)
+	for (i = 0; i < SFQ_SLOTS; i++)
 		sfq_link(q, i);
 	return 0;
 }
@@ -543,13 +608,12 @@ static int sfq_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 				struct gnet_dump *d)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
-	sfq_index idx = q->ht[cl-1];
-	struct sk_buff_head *list = &q->qs[idx];
-	struct gnet_stats_queue qs = { .qlen = list->qlen };
-	struct tc_sfq_xstats xstats = { .allot = q->allot[idx] };
+	const struct sfq_slot *slot = &q->slots[q->ht[cl - 1]];
+	struct gnet_stats_queue qs = { .qlen = slot->qlen };
+	struct tc_sfq_xstats xstats = { .allot = slot->allot };
 	struct sk_buff *skb;
 
-	skb_queue_walk(list, skb)
+	slot_queue_walk(slot, skb)
 		qs.backlog += qdisc_pkt_len(skb);
 
 	if (gnet_stats_copy_queue(d, &qs) < 0)
@@ -566,7 +630,7 @@ static void sfq_walk(struct Qdisc *sch, struct qdisc_walker *arg)
 		return;
 
 	for (i = 0; i < SFQ_HASH_DIVISOR; i++) {
-		if (q->ht[i] == SFQ_DEPTH ||
+		if (q->ht[i] == SFQ_EMPTY_SLOT ||
 		    arg->count < arg->skip) {
 			arg->count++;
 			continue;


