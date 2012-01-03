From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] SFQ planned changes
Date: Tue, 03 Jan 2012 17:08:38 +0100
Message-ID: <1325606918.2320.84.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1325385056.4174.51.camel@denise.theartistscloset.com>
	 <21734335.uCtjXOcSpA@alaris>
	 <CAA93jw5NYChp+hKWjOWiw7SnGhNe+REofr2KM-85GnKNVpkw6w@mail.gmail.com>
	 <1325587235.2320.37.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAA93jw5T10PHD+YQQjy_r=LHKVbYeiWerwM0ou7HANGoenFRKw@mail.gmail.com>
	 <1325595036.2320.43.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michal =?UTF-8?Q?Kube=C4=8Dek?= <mkubecek@suse.cz>,
	netdev@vger.kernel.org,
	"John A. Sullivan III" <jsullivan@opensourcedevel.com>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:35050 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753977Ab2ACQIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 11:08:43 -0500
Received: by werm1 with SMTP id m1so7961615wer.19
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2012 08:08:42 -0800 (PST)
In-Reply-To: <1325595036.2320.43.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is the code I ran on my test server with 200 netperf TCP_STREAM
flows with pretty good results (each flow gets 0.5 % of bandwidth)

$TC qdisc add dev $DEV root handle 1: est 1sec 8sec htb default 1 
$TC class add dev $DEV parent 1: classid 1:1 est 1sec 8sec htb \
	rate 200Mbit mtu 40000 quantum 80000

$TC qdisc add dev $DEV parent 1:1 handle 10: est 1sec 8sec sfq \
	limit 2000 depth 10 headdrop flows 1000 divisor 16384 

# tcnew -s -d qdisc show dev eth3
qdisc htb 1: root refcnt 18 r2q 10 default 1 direct_packets_stat 0 ver 3.17
 Sent 4512949730 bytes 3030391 pkt (dropped 44409, overlimits 6105100 requeues 1) 
 rate 198288Kbit 16629pps backlog 0b 1732p requeues 1 
qdisc sfq 10: parent 1:1 limit 2000p quantum 1514b depth 10 headdrop flows 1000/16384 divisor 16384 
 Sent 4512949730 bytes 3030391 pkt (dropped 44409, overlimits 0 requeues 0) 
 rate 198288Kbit 16629pps backlog 2622248b 1732p requeues 0 

patch on top of current net-next

 include/linux/pkt_sched.h |    7 +
 net/sched/sch_sfq.c       |  144 ++++++++++++++++++++++++------------
 2 files changed, 104 insertions(+), 47 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index 8daced3..c2c6cfd 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -162,6 +162,13 @@ struct tc_sfq_qopt {
 	unsigned	flows;		/* Maximal number of flows  */
 };
 
+struct tc_sfq_ext_qopt {
+	struct tc_sfq_qopt qopt;
+	unsigned int depth;		/* max number of packets per flow */
+	unsigned int headdrop;
+};
+
+
 struct tc_sfq_xstats {
 	__s32		allot;
 };
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index d329a8a..66682fd 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -67,15 +67,16 @@
 
 	IMPLEMENTATION:
 	This implementation limits maximal queue length to 128;
-	max mtu to 2^18-1; max 128 flows, number of hash buckets to 1024.
-	The only goal of this restrictions was that all data
-	fit into one 4K page on 32bit arches.
+	max mtu to 2^18-1;
+	max 65280 flows,
+	number of hash buckets to 65536.
 
 	It is easy to increase these values, but not in flight.  */
 
 #define SFQ_DEPTH		128 /* max number of packets per flow */
-#define SFQ_SLOTS		128 /* max number of flows */
-#define SFQ_EMPTY_SLOT		255
+#define SFQ_DEFAULT_FLOWS	128
+#define SFQ_MAX_FLOWS		(0x10000 - 256) /* max number of flows */
+#define SFQ_EMPTY_SLOT		0xffff
 #define SFQ_DEFAULT_HASH_DIVISOR 1024
 
 /* We use 16 bits to store allot, and want to handle packets up to 64K
@@ -84,13 +85,13 @@
 #define SFQ_ALLOT_SHIFT		3
 #define SFQ_ALLOT_SIZE(X)	DIV_ROUND_UP(X, 1 << SFQ_ALLOT_SHIFT)
 
-/* This type should contain at least SFQ_DEPTH + SFQ_SLOTS values */
-typedef unsigned char sfq_index;
+/* This type should contain at least SFQ_DEPTH + SFQ_MAX_FLOWS values */
+typedef u16 sfq_index;
 
 /*
  * We dont use pointers to save space.
- * Small indexes [0 ... SFQ_SLOTS - 1] are 'pointers' to slots[] array
- * while following values [SFQ_SLOTS ... SFQ_SLOTS + SFQ_DEPTH - 1]
+ * Small indexes [0 ... SFQ_MAX_FLOWS - 1] are 'pointers' to slots[] array
+ * while following values [SFQ_MAX_FLOWS ... SFQ_MAX_FLOWS + SFQ_DEPTH - 1]
  * are 'pointers' to dep[] array
  */
 struct sfq_head {
@@ -112,8 +113,11 @@ struct sfq_sched_data {
 /* Parameters */
 	int		perturb_period;
 	unsigned int	quantum;	/* Allotment per round: MUST BE >= MTU */
-	int		limit;
+	int		limit;		/* limit of total number of packets in this qdisc */
 	unsigned int	divisor;	/* number of slots in hash table */
+	unsigned int	maxflows;	/* number of flows in flows array */
+	int		headdrop;
+	int		depth;		/* limit depth of each flow */
 /* Variables */
 	struct tcf_proto *filter_list;
 	struct timer_list perturb_timer;
@@ -122,7 +126,7 @@ struct sfq_sched_data {
 	unsigned short  scaled_quantum; /* SFQ_ALLOT_SIZE(quantum) */
 	struct sfq_slot *tail;		/* current slot in round */
 	sfq_index	*ht;		/* Hash table (divisor slots) */
-	struct sfq_slot	slots[SFQ_SLOTS];
+	struct sfq_slot	*slots;
 	struct sfq_head	dep[SFQ_DEPTH];	/* Linked list of slots, indexed by depth */
 };
 
@@ -131,9 +135,9 @@ struct sfq_sched_data {
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
@@ -199,18 +203,19 @@ static unsigned int sfq_classify(struct sk_buff *skb, struct Qdisc *sch,
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
@@ -305,7 +310,7 @@ static unsigned int sfq_drop(struct Qdisc *sch)
 		x = q->dep[d].next;
 		slot = &q->slots[x];
 drop:
-		skb = slot_dequeue_tail(slot);
+		skb = q->headdrop ? slot_dequeue_head(slot) : slot_dequeue_tail(slot);
 		len = qdisc_pkt_len(skb);
 		sfq_dec(q, x);
 		kfree_skb(skb);
@@ -349,16 +354,26 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
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
+	if (slot->qlen >= q->depth) {
+		struct sk_buff *head;
+
+		if (!q->headdrop)
+			return qdisc_drop(skb, sch);
+		head = slot_dequeue_head(slot);
+		sch->qstats.backlog -= qdisc_pkt_len(head);
+		kfree_skb(head);
+		sch->qstats.drops++;
+		sch->qstats.backlog += qdisc_pkt_len(skb);
+		slot_queue_add(slot, skb);
+		return NET_XMIT_CN;
+	}
 
 	sch->qstats.backlog += qdisc_pkt_len(skb);
 	slot_queue_add(slot, skb);
@@ -366,11 +381,11 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	if (slot->qlen == 1) {		/* The flow is new */
 		if (q->tail == NULL) {	/* It is the first flow */
 			slot->next = x;
+			q->tail = slot;
 		} else {
 			slot->next = q->tail->next;
 			q->tail->next = x;
 		}
-		q->tail = slot;
 		slot->allot = q->scaled_quantum;
 	}
 	if (++sch->q.qlen <= q->limit)
@@ -445,16 +460,17 @@ sfq_reset(struct Qdisc *sch)
  * We dont use sfq_dequeue()/sfq_enqueue() because we dont want to change
  * counters.
  */
-static void sfq_rehash(struct sfq_sched_data *q)
+static int sfq_rehash(struct sfq_sched_data *q)
 {
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
@@ -474,6 +490,11 @@ static void sfq_rehash(struct sfq_sched_data *q)
 		slot = &q->slots[x];
 		if (x == SFQ_EMPTY_SLOT) {
 			x = q->dep[0].next; /* get a free slot */
+			if (x >= SFQ_MAX_FLOWS) {
+				kfree_skb(skb);
+				dropped++;
+				continue;
+			}
 			q->ht[hash] = x;
 			slot = &q->slots[x];
 			slot->hash = hash;
@@ -491,6 +512,7 @@ static void sfq_rehash(struct sfq_sched_data *q)
 			slot->allot = q->scaled_quantum;
 		}
 	}
+	return dropped;
 }
 
 static void sfq_perturbation(unsigned long arg)
@@ -502,7 +524,7 @@ static void sfq_perturbation(unsigned long arg)
 	spin_lock(root_lock);
 	q->perturbation = net_random();
 	if (!q->filter_list && q->tail)
-		sfq_rehash(q);
+		qdisc_tree_decrease_qlen(sch, sfq_rehash(q));
 	spin_unlock(root_lock);
 
 	if (q->perturb_period)
@@ -513,11 +535,13 @@ static int sfq_change(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
 	struct tc_sfq_qopt *ctl = nla_data(opt);
+	struct tc_sfq_ext_qopt *ctl_ext = NULL;
 	unsigned int qlen;
 
 	if (opt->nla_len < nla_attr_size(sizeof(*ctl)))
 		return -EINVAL;
-
+	if (opt->nla_len >= nla_attr_size(sizeof(*ctl_ext)))
+		ctl_ext = nla_data(opt);
 	if (ctl->divisor &&
 	    (!is_power_of_2(ctl->divisor) || ctl->divisor > 65536))
 		return -EINVAL;
@@ -526,10 +550,18 @@ static int sfq_change(struct Qdisc *sch, struct nlattr *opt)
 	q->quantum = ctl->quantum ? : psched_mtu(qdisc_dev(sch));
 	q->scaled_quantum = SFQ_ALLOT_SIZE(q->quantum);
 	q->perturb_period = ctl->perturb_period * HZ;
-	if (ctl->limit)
-		q->limit = min_t(u32, ctl->limit, SFQ_DEPTH - 1);
+	if (ctl->flows)
+		q->maxflows = min_t(u32, ctl->flows, SFQ_MAX_FLOWS);
 	if (ctl->divisor)
 		q->divisor = ctl->divisor;
+	if (ctl_ext) {
+		if (ctl_ext->depth)
+			q->depth = min_t(u32, ctl_ext->depth, SFQ_DEPTH - 1);
+		q->headdrop = ctl_ext->headdrop;
+	}
+	if (ctl->limit)
+		q->limit = min_t(u32, ctl->limit, q->depth * q->maxflows);
+
 	qlen = sch->q.qlen;
 	while (sch->q.qlen > q->limit)
 		sfq_drop(sch);
@@ -544,6 +576,16 @@ static int sfq_change(struct Qdisc *sch, struct nlattr *opt)
 	return 0;
 }
 
+static void sfq_free(void *addr)
+{
+	if (addr) {
+		if (is_vmalloc_addr(addr))
+			vfree(addr);
+		else
+			kfree(addr);
+	}
+}
+
 static int sfq_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
@@ -555,14 +597,16 @@ static int sfq_init(struct Qdisc *sch, struct nlattr *opt)
 	init_timer_deferrable(&q->perturb_timer);
 
 	for (i = 0; i < SFQ_DEPTH; i++) {
-		q->dep[i].next = i + SFQ_SLOTS;
-		q->dep[i].prev = i + SFQ_SLOTS;
+		q->dep[i].next = i + SFQ_MAX_FLOWS;
+		q->dep[i].prev = i + SFQ_MAX_FLOWS;
 	}
 
 	q->limit = SFQ_DEPTH - 1;
+	q->depth = SFQ_DEPTH - 1;
 	q->cur_depth = 0;
 	q->tail = NULL;
 	q->divisor = SFQ_DEFAULT_HASH_DIVISOR;
+	q->maxflows = SFQ_DEFAULT_FLOWS;
 	if (opt == NULL) {
 		q->quantum = psched_mtu(qdisc_dev(sch));
 		q->scaled_quantum = SFQ_ALLOT_SIZE(q->quantum);
@@ -575,15 +619,22 @@ static int sfq_init(struct Qdisc *sch, struct nlattr *opt)
 	}
 
 	sz = sizeof(q->ht[0]) * q->divisor;
-	q->ht = kmalloc(sz, GFP_KERNEL);
+	q->ht = kmalloc(sz, GFP_KERNEL | __GFP_NOWARN);
 	if (!q->ht && sz > PAGE_SIZE)
 		q->ht = vmalloc(sz);
 	if (!q->ht)
 		return -ENOMEM;
+
+	q->slots = kzalloc(sizeof(q->slots[0]) * q->maxflows, GFP_KERNEL | __GFP_NOWARN);
+	if (!q->slots)
+		q->slots = vzalloc(sizeof(q->slots[0]) * q->maxflows);
+	if (!q->slots) {
+		sfq_free(q->ht);
+		return -ENOMEM;
+	}
 	for (i = 0; i < q->divisor; i++)
 		q->ht[i] = SFQ_EMPTY_SLOT;
-
-	for (i = 0; i < SFQ_SLOTS; i++) {
+	for (i = 0; i < q->maxflows; i++) {
 		slot_queue_init(&q->slots[i]);
 		sfq_link(q, i);
 	}
@@ -601,25 +652,24 @@ static void sfq_destroy(struct Qdisc *sch)
 	tcf_destroy_chain(&q->filter_list);
 	q->perturb_period = 0;
 	del_timer_sync(&q->perturb_timer);
-	if (is_vmalloc_addr(q->ht))
-		vfree(q->ht);
-	else
-		kfree(q->ht);
+	sfq_free(q->ht);
+	sfq_free(q->slots);
 }
 
 static int sfq_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
 	unsigned char *b = skb_tail_pointer(skb);
-	struct tc_sfq_qopt opt;
-
-	opt.quantum = q->quantum;
-	opt.perturb_period = q->perturb_period / HZ;
+	struct tc_sfq_ext_qopt opt;
 
-	opt.limit = q->limit;
-	opt.divisor = q->divisor;
-	opt.flows = q->limit;
+	opt.qopt.quantum = q->quantum;
+	opt.qopt.perturb_period = q->perturb_period / HZ;
 
+	opt.qopt.limit = q->limit;
+	opt.qopt.divisor = q->divisor;
+	opt.qopt.flows = q->maxflows;
+	opt.depth = q->depth;
+	opt.headdrop = q->headdrop;
 	NLA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
 
 	return skb->len;
