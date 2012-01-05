From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net_sched: sfq: extend limits
Date: Thu, 05 Jan 2012 01:18:38 +0100
Message-ID: <1325722718.2634.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Dave Taht <dave.taht@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:39002 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932073Ab2AEASn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2012 19:18:43 -0500
Received: by wgbdr13 with SMTP id dr13so29593298wgb.1
        for <netdev@vger.kernel.org>; Wed, 04 Jan 2012 16:18:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SFQ as implemented in Linux is very limited, with at most 127 flows
and limit of 127 packets. [ So if 127 flows are active, we have one
packet per flow ]

This patch brings to SFQ following features to cope with modern needs.

- Ability to specify a smaller per flow limit of inflight packets.
    (default value being at 127 packets)

- Ability to have up to 65408 active flows (instead of 127)

- Ability to have head drops instead of tail drops
  (to drop old packets from a flow)

Example of use : No more than 20 packets per flow, max 8000 flows, max
20000 packets in SFQ qdisc, hash table of 65536 slots.

tc qdisc add ... sfq \
        flows 8000 \
        depth 20 \
        headdrop \
        limit 20000 \
	divisor 65536

Ram usage : 

2 bytes per hash table entry (instead of previous 1 byte/entry)
32 bytes per flow on 64bit arches, instead of 384 for QFQ, so much
better cache hit ratio.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Dave Taht <dave.taht@gmail.com>
---
 include/linux/pkt_sched.h |   16 +--
 net/sched/sch_sfq.c       |  175 ++++++++++++++++++++++++------------
 2 files changed, 124 insertions(+), 67 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index 8daced3..8f1b928 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -162,19 +162,17 @@ struct tc_sfq_qopt {
 	unsigned	flows;		/* Maximal number of flows  */
 };
 
+struct tc_sfq_qopt_v1 {
+	struct tc_sfq_qopt v0;
+	unsigned int	depth;		/* max number of packets per flow */
+	unsigned int	headdrop;
+};
+
+
 struct tc_sfq_xstats {
 	__s32		allot;
 };
 
-/*
- *  NOTE: limit, divisor and flows are hardwired to code at the moment.
- *
- *	limit=flows=128, divisor=1024;
- *
- *	The only reason for this is efficiency, it is possible
- *	to change these parameters in compile time.
- */
-
 /* RED section */
 
 enum {
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 8430181..0a79640 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -66,16 +66,18 @@
 	SFQ is superior for this purpose.
 
 	IMPLEMENTATION:
-	This implementation limits maximal queue length to 128;
-	max mtu to 2^18-1; max 128 flows, number of hash buckets to 1024.
-	The only goal of this restrictions was that all data
-	fit into one 4K page on 32bit arches.
+	This implementation limits :
+	- maximal queue length per flow to 127 packets.
+	- max mtu to 2^18-1;
+	- max 65408 flows,
+	- number of hash buckets to 65536.
 
 	It is easy to increase these values, but not in flight.  */
 
-#define SFQ_DEPTH		128 /* max number of packets per flow */
-#define SFQ_SLOTS		128 /* max number of flows */
-#define SFQ_EMPTY_SLOT		255
+#define SFQ_MAX_DEPTH		127 /* max number of packets per flow */
+#define SFQ_DEFAULT_FLOWS	128
+#define SFQ_MAX_FLOWS		(0x10000 - SFQ_MAX_DEPTH - 1) /* max number of flows */
+#define SFQ_EMPTY_SLOT		0xffff
 #define SFQ_DEFAULT_HASH_DIVISOR 1024
 
 /* We use 16 bits to store allot, and want to handle packets up to 64K
@@ -84,13 +86,13 @@
 #define SFQ_ALLOT_SHIFT		3
 #define SFQ_ALLOT_SIZE(X)	DIV_ROUND_UP(X, 1 << SFQ_ALLOT_SHIFT)
 
-/* This type should contain at least SFQ_DEPTH + SFQ_SLOTS values */
-typedef unsigned char sfq_index;
+/* This type should contain at least SFQ_MAX_DEPTH + 1 + SFQ_MAX_FLOWS values */
+typedef u16 sfq_index;
 
 /*
  * We dont use pointers to save space.
- * Small indexes [0 ... SFQ_SLOTS - 1] are 'pointers' to slots[] array
- * while following values [SFQ_SLOTS ... SFQ_SLOTS + SFQ_DEPTH - 1]
+ * Small indexes [0 ... SFQ_MAX_FLOWS - 1] are 'pointers' to slots[] array
+ * while following values [SFQ_MAX_FLOWS ... SFQ_MAX_FLOWS + SFQ_MAX_DEPTH]
  * are 'pointers' to dep[] array
  */
 struct sfq_head {
@@ -102,28 +104,38 @@ struct sfq_slot {
 	struct sk_buff	*skblist_next;
 	struct sk_buff	*skblist_prev;
 	sfq_index	qlen; /* number of skbs in skblist */
-	sfq_index	next; /* next slot in sfq chain */
+	sfq_index	next; /* next slot in sfq RR chain */
 	struct sfq_head dep; /* anchor in dep[] chains */
 	unsigned short	hash; /* hash value (index in ht[]) */
 	short		allot; /* credit for this slot */
 };
 
 struct sfq_sched_data {
-/* Parameters */
-	int		perturb_period;
-	unsigned int	quantum;	/* Allotment per round: MUST BE >= MTU */
-	int		limit;
+/* frequently used fields */
+	int		limit;		/* limit of total number of packets in this qdisc */
 	unsigned int	divisor;	/* number of slots in hash table */
-/* Variables */
-	struct tcf_proto *filter_list;
-	struct timer_list perturb_timer;
+	unsigned int	maxflows;	/* number of flows in flows array */
+	int		headdrop;
+	int		maxdepth;	/* limit of packets per flow */
+
 	u32		perturbation;
+	struct tcf_proto *filter_list;
 	sfq_index	cur_depth;	/* depth of longest slot */
 	unsigned short  scaled_quantum; /* SFQ_ALLOT_SIZE(quantum) */
 	struct sfq_slot *tail;		/* current slot in round */
-	sfq_index	*ht;		/* Hash table (divisor slots) */
-	struct sfq_slot	slots[SFQ_SLOTS];
-	struct sfq_head	dep[SFQ_DEPTH];	/* Linked list of slots, indexed by depth */
+	sfq_index	*ht;		/* Hash table ('divisor' slots) */
+	struct sfq_slot	*slots;		/* Flows table ('maxflows' entries) */
+
+	struct sfq_head	dep[SFQ_MAX_DEPTH + 1];
+					/* Linked lists of slots, indexed by depth
+					 * dep[0] : list of unused flows
+					 * dep[1] : list of flows with 1 packet
+					 * dep[X] : list of flows with X packets
+					 */
+
+	int		perturb_period;
+	unsigned int	quantum;	/* Allotment per round: MUST BE >= MTU */
+	struct timer_list perturb_timer;
 };
 
 /*
@@ -131,9 +143,9 @@ struct sfq_sched_data {
  */
 static inline struct sfq_head *sfq_dep_head(struct sfq_sched_data *q, sfq_index val)
 {
-	if (val < SFQ_SLOTS)
+	if (val < SFQ_MAX_FLOWS)
 		return &q->slots[val].dep;
-	return &q->dep[val - SFQ_SLOTS];
+	return &q->dep[val - SFQ_MAX_FLOWS];
 }
 
 /*
@@ -199,18 +211,19 @@ static unsigned int sfq_classify(struct sk_buff *skb, struct Qdisc *sch,
 }
 
 /*
- * x : slot number [0 .. SFQ_SLOTS - 1]
+ * x : slot number [0 .. SFQ_MAX_FLOWS - 1]
  */
 static inline void sfq_link(struct sfq_sched_data *q, sfq_index x)
 {
 	sfq_index p, n;
-	int qlen = q->slots[x].qlen;
+	struct sfq_slot *slot = &q->slots[x];
+	int qlen = slot->qlen;
 
-	p = qlen + SFQ_SLOTS;
+	p = qlen + SFQ_MAX_FLOWS;
 	n = q->dep[qlen].next;
 
-	q->slots[x].dep.next = n;
-	q->slots[x].dep.prev = p;
+	slot->dep.next = n;
+	slot->dep.prev = p;
 
 	q->dep[qlen].next = x;		/* sfq_dep_head(q, p)->next = x */
 	sfq_dep_head(q, n)->prev = x;
@@ -275,6 +288,7 @@ static inline struct sk_buff *slot_dequeue_head(struct sfq_slot *slot)
 
 static inline void slot_queue_init(struct sfq_slot *slot)
 {
+	memset(slot, 0, sizeof(*slot));
 	slot->skblist_prev = slot->skblist_next = (struct sk_buff *)slot;
 }
 
@@ -305,7 +319,7 @@ static unsigned int sfq_drop(struct Qdisc *sch)
 		x = q->dep[d].next;
 		slot = &q->slots[x];
 drop:
-		skb = slot_dequeue_tail(slot);
+		skb = q->headdrop ? slot_dequeue_head(slot) : slot_dequeue_tail(slot);
 		len = qdisc_pkt_len(skb);
 		sfq_dec(q, x);
 		kfree_skb(skb);
@@ -349,16 +363,27 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	slot = &q->slots[x];
 	if (x == SFQ_EMPTY_SLOT) {
 		x = q->dep[0].next; /* get a free slot */
+		if (x >= SFQ_MAX_FLOWS)
+			return qdisc_drop(skb, sch);
 		q->ht[hash] = x;
 		slot = &q->slots[x];
 		slot->hash = hash;
 	}
 
-	/* If selected queue has length q->limit, do simple tail drop,
-	 * i.e. drop _this_ packet.
-	 */
-	if (slot->qlen >= q->limit)
-		return qdisc_drop(skb, sch);
+	if (slot->qlen >= q->maxdepth) {
+		struct sk_buff *head;
+
+		if (!q->headdrop)
+			return qdisc_drop(skb, sch);
+
+		head = slot_dequeue_head(slot);
+		sch->qstats.backlog -= qdisc_pkt_len(head);
+		qdisc_drop(head, sch);
+
+		sch->qstats.backlog += qdisc_pkt_len(skb);
+		slot_queue_add(slot, skb);
+		return NET_XMIT_CN;
+	}
 
 	sch->qstats.backlog += qdisc_pkt_len(skb);
 	slot_queue_add(slot, skb);
@@ -445,16 +470,18 @@ sfq_reset(struct Qdisc *sch)
  * We dont use sfq_dequeue()/sfq_enqueue() because we dont want to change
  * counters.
  */
-static void sfq_rehash(struct sfq_sched_data *q)
+static void sfq_rehash(struct Qdisc *sch)
 {
+	struct sfq_sched_data *q = qdisc_priv(sch);
 	struct sk_buff *skb;
 	int i;
 	struct sfq_slot *slot;
 	struct sk_buff_head list;
+	int dropped = 0;
 
 	__skb_queue_head_init(&list);
 
-	for (i = 0; i < SFQ_SLOTS; i++) {
+	for (i = 0; i < q->maxflows; i++) {
 		slot = &q->slots[i];
 		if (!slot->qlen)
 			continue;
@@ -474,10 +501,18 @@ static void sfq_rehash(struct sfq_sched_data *q)
 		slot = &q->slots[x];
 		if (x == SFQ_EMPTY_SLOT) {
 			x = q->dep[0].next; /* get a free slot */
+			if (x >= SFQ_MAX_FLOWS) {
+drop:				sch->qstats.backlog -= qdisc_pkt_len(skb);
+				kfree_skb(skb);
+				dropped++;
+				continue;
+			}
 			q->ht[hash] = x;
 			slot = &q->slots[x];
 			slot->hash = hash;
 		}
+		if (slot->qlen >= q->maxdepth)
+			goto drop;
 		slot_queue_add(slot, skb);
 		sfq_inc(q, x);
 		if (slot->qlen == 1) {		/* The flow is new */
@@ -491,6 +526,8 @@ static void sfq_rehash(struct sfq_sched_data *q)
 			slot->allot = q->scaled_quantum;
 		}
 	}
+	sch->q.qlen -= dropped;
+	qdisc_tree_decrease_qlen(sch, dropped);
 }
 
 static void sfq_perturbation(unsigned long arg)
@@ -502,7 +539,7 @@ static void sfq_perturbation(unsigned long arg)
 	spin_lock(root_lock);
 	q->perturbation = net_random();
 	if (!q->filter_list && q->tail)
-		sfq_rehash(q);
+		sfq_rehash(sch);
 	spin_unlock(root_lock);
 
 	if (q->perturb_period)
@@ -513,23 +550,39 @@ static int sfq_change(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
 	struct tc_sfq_qopt *ctl = nla_data(opt);
+	struct tc_sfq_qopt_v1 *ctl_v1 = NULL;
 	unsigned int qlen;
 
 	if (opt->nla_len < nla_attr_size(sizeof(*ctl)))
 		return -EINVAL;
-
+	if (opt->nla_len >= nla_attr_size(sizeof(*ctl_v1)))
+		ctl_v1 = nla_data(opt);
 	if (ctl->divisor &&
 	    (!is_power_of_2(ctl->divisor) || ctl->divisor > 65536))
 		return -EINVAL;
 
 	sch_tree_lock(sch);
-	q->quantum = ctl->quantum ? : psched_mtu(qdisc_dev(sch));
-	q->scaled_quantum = SFQ_ALLOT_SIZE(q->quantum);
+	if (ctl->quantum) {
+		q->quantum = ctl->quantum;
+		q->scaled_quantum = SFQ_ALLOT_SIZE(q->quantum);
+	}
 	q->perturb_period = ctl->perturb_period * HZ;
-	if (ctl->limit)
-		q->limit = min_t(u32, ctl->limit, SFQ_DEPTH - 1);
-	if (ctl->divisor)
+	if (ctl->flows)
+		q->maxflows = min_t(u32, ctl->flows, SFQ_MAX_FLOWS);
+	if (ctl->divisor) {
 		q->divisor = ctl->divisor;
+		q->maxflows = min_t(u32, q->maxflows, q->divisor);
+	}
+	if (ctl_v1) {
+		if (ctl_v1->depth)
+			q->maxdepth = min_t(u32, ctl_v1->depth, SFQ_MAX_DEPTH);
+		q->headdrop = ctl_v1->headdrop;
+	}
+	if (ctl->limit) {
+		q->limit = min_t(u32, ctl->limit, q->maxdepth * q->maxflows);
+		q->maxflows = min_t(u32, q->maxflows, q->limit);
+	}
+
 	qlen = sch->q.qlen;
 	while (sch->q.qlen > q->limit)
 		sfq_drop(sch);
@@ -571,6 +624,7 @@ static void sfq_destroy(struct Qdisc *sch)
 	q->perturb_period = 0;
 	del_timer_sync(&q->perturb_timer);
 	sfq_free(q->ht);
+	sfq_free(q->slots);
 }
 
 static int sfq_init(struct Qdisc *sch, struct nlattr *opt)
@@ -582,15 +636,17 @@ static int sfq_init(struct Qdisc *sch, struct nlattr *opt)
 	q->perturb_timer.data = (unsigned long)sch;
 	init_timer_deferrable(&q->perturb_timer);
 
-	for (i = 0; i < SFQ_DEPTH; i++) {
-		q->dep[i].next = i + SFQ_SLOTS;
-		q->dep[i].prev = i + SFQ_SLOTS;
+	for (i = 0; i < SFQ_MAX_DEPTH + 1; i++) {
+		q->dep[i].next = i + SFQ_MAX_FLOWS;
+		q->dep[i].prev = i + SFQ_MAX_FLOWS;
 	}
 
-	q->limit = SFQ_DEPTH - 1;
+	q->limit = SFQ_MAX_DEPTH;
+	q->maxdepth = SFQ_MAX_DEPTH;
 	q->cur_depth = 0;
 	q->tail = NULL;
 	q->divisor = SFQ_DEFAULT_HASH_DIVISOR;
+	q->maxflows = SFQ_DEFAULT_FLOWS;
 	q->quantum = psched_mtu(qdisc_dev(sch));
 	q->scaled_quantum = SFQ_ALLOT_SIZE(q->quantum);
 	q->perturb_period = 0;
@@ -603,14 +659,15 @@ static int sfq_init(struct Qdisc *sch, struct nlattr *opt)
 	}
 
 	q->ht = sfq_alloc(sizeof(q->ht[0]) * q->divisor);
-	if (!q->ht) {
+	q->slots = sfq_alloc(sizeof(q->slots[0]) * q->maxflows);
+	if (!q->ht || !q->slots) {
 		sfq_destroy(sch);
 		return -ENOMEM;
 	}
 	for (i = 0; i < q->divisor; i++)
 		q->ht[i] = SFQ_EMPTY_SLOT;
 
-	for (i = 0; i < SFQ_SLOTS; i++) {
+	for (i = 0; i < q->maxflows; i++) {
 		slot_queue_init(&q->slots[i]);
 		sfq_link(q, i);
 	}
@@ -625,14 +682,16 @@ static int sfq_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
 	unsigned char *b = skb_tail_pointer(skb);
-	struct tc_sfq_qopt opt;
-
-	opt.quantum = q->quantum;
-	opt.perturb_period = q->perturb_period / HZ;
-
-	opt.limit = q->limit;
-	opt.divisor = q->divisor;
-	opt.flows = q->limit;
+	struct tc_sfq_qopt_v1 opt;
+
+	memset(&opt, 0, sizeof(opt));
+	opt.v0.quantum	= q->quantum;
+	opt.v0.perturb_period = q->perturb_period / HZ;
+	opt.v0.limit	= q->limit;
+	opt.v0.divisor	= q->divisor;
+	opt.v0.flows	= q->maxflows;
+	opt.depth	= q->maxdepth;
+	opt.headdrop	= q->headdrop;
 
 	NLA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
 
