From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2] net_sched: sch_sfq: better struct layouts
Date: Mon, 20 Dec 2010 18:02:05 +0100
Message-ID: <1292864525.2800.189.camel@edumazet-laptop>
References: <1292421783.3427.232.camel@edumazet-laptop>
	 <4D08E6C2.804@trash.net> <1292430424.3427.350.camel@edumazet-laptop>
	 <1292431256.3427.358.camel@edumazet-laptop> <4D08F025.5030603@trash.net>
	 <1292432120.3427.366.camel@edumazet-laptop> <4D08F4F4.3050501@trash.net>
	 <1292504932.2883.110.camel@edumazet-laptop>
	 <1292604766.2906.51.camel@edumazet-laptop>
	 <20101219212234.GA2323@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:53954 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932895Ab0LTRCN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 12:02:13 -0500
Received: by wyb28 with SMTP id 28so3057958wyb.19
        for <netdev@vger.kernel.org>; Mon, 20 Dec 2010 09:02:11 -0800 (PST)
In-Reply-To: <20101219212234.GA2323@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 19 d=C3=A9cembre 2010 =C3=A0 22:22 +0100, Jarek Poplawski a=
 =C3=A9crit :

> I think open coding sk_buff_head is a wrong idea. Otherwise, this
> patch looks OK to me, only a few cosmetic suggestions below.
>=20

I completely agree with you but this should be temporary, because David
really wants to use list_head for skbs, I believe this will be done ;)

I chose to name the list skblist to make clear where we want to plug a
real list_head once done.

Also, not using sk_buff_head saves at least 8 bytes per slot.

>  =20
> > -#define SFQ_DEPTH		128
> > +#define SFQ_DEPTH		128 /* max number of packets per slot (per flow=
) */
> > +#define SFQ_SLOTS		128 /* max number of flows */
> > +#define EMPTY_SLOT		255
>=20
> SFQ_EMPTY_SLOT?

OK done


> > =20
> > +struct sfq_slot {
> > +	struct sk_buff	*skblist_next;
> > +	struct sk_buff	*skblist_prev;
> > +	sfq_index	qlen; /* number of skbs in skblist */
> > +	sfq_index	next; /* next slot in sfq chain */
> > +	unsigned short	hash; /* hash value (index in ht[]) */
> > +	short		allot; /* credit for this slot */
> > +	struct sfq_head anchor; /* anchor in dep[] chains */
>=20
> struct sfq_head dep?

OK

>=20
> > +};
> > +
> >  struct sfq_sched_data
> >  {
> >  /* Parameters */
> > @@ -99,17 +114,24 @@ struct sfq_sched_data
> >  	struct tcf_proto *filter_list;
> >  	struct timer_list perturb_timer;
> >  	u32		perturbation;
> > -	sfq_index	tail;		/* Index of current slot in round */
> > -	sfq_index	max_depth;	/* Maximal depth */
> > +	sfq_index	max_depth;	/* depth of longest slot */
>=20
> depth and/or length? (One dimension should be enough.)

maybe cur_depth ? Its not the maximal possible depth, but depth of
longest slot, or current max depth...

>=20
> > =20
> > +	struct sfq_slot *tail;		/* current slot in round */
> >  	sfq_index	ht[SFQ_HASH_DIVISOR];	/* Hash table */
> > -	sfq_index	next[SFQ_DEPTH];	/* Active slots link */
> > -	short		allot[SFQ_DEPTH];	/* Current allotment per slot */
> > -	unsigned short	hash[SFQ_DEPTH];	/* Hash value indexed by slots */
> > -	struct sk_buff_head	qs[SFQ_DEPTH];		/* Slot queue */
> > -	struct sfq_head	dep[SFQ_DEPTH*2];	/* Linked list of slots, indexe=
d by depth */
> > +	struct sfq_slot	slots[SFQ_SLOTS];
> > +	struct sfq_head	dep[SFQ_DEPTH];	/* Linked list of slots, indexed =
by depth */
> >  };
> > =20
> > +/*
> > + * sfq_head are either in a sfq_slot or in dep[] array
> > + */
> > +static inline struct sfq_head *get_head(struct sfq_sched_data *q, =
sfq_index val)
>=20
> static inline struct sfq_head *sfq_dep_head()?
>=20

OK


> > -	/* If selected queue has length q->limit, this means that
> > -	 * all another queues are empty and that we do simple tail drop,
>=20
> No reason to remove this line.

Well, the reason we drop this packet is not because other queues are
empty, but because we reach max depth for this queue. (I have the idea
to extend SFQ to allow more packets to be queued, still with a 127 limi=
t
per queue, and 127 flows). With 10Gbs links, a global limit of 127
packets is short.


> If you really have to do this, all these: __skb_queue_tail(),
> __skb_dequeue(), skb_queue_head_init(), skb_peek() etc. used here
> should stay as (local) inline functions to remain readability.
>=20

OK done, thanks a lot for reviewing and very useful comments !

We should address the problem of allot being 16bit, GRO makes allot
overflow so fast, that SFQ is not fair at all...

allot could use 17 bits and hash only 15 (10 really needed for current
divisor)

[PATCH v2] net_sched: sch_sfq: better struct layouts

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
        unsigned short  hash; /* hash value (index in ht[]) */
        short           allot; /* credit for this slot */
        struct sfq_head dep; /* anchor in dep[] chains */
};

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Jarek Poplawski <jarkao2@gmail.com>
---
v2: address Jarek comments

 net/sched/sch_sfq.c |  263 +++++++++++++++++++++++++-----------------
 1 files changed, 160 insertions(+), 103 deletions(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 3cf478d..ef94f3d 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -67,27 +67,42 @@
=20
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
=20
 	It is easy to increase these values, but not in flight.  */
=20
-#define SFQ_DEPTH		128
+#define SFQ_DEPTH		128 /* max number of packets per flow */
+#define SFQ_SLOTS		128 /* max number of flows */
+#define SFQ_EMPTY_SLOT		255
 #define SFQ_HASH_DIVISOR	1024
=20
-/* This type should contain at least SFQ_DEPTH*2 values */
+/* This type should contain at least SFQ_DEPTH + SFQ_SLOTS values */
 typedef unsigned char sfq_index;
=20
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
=20
+struct sfq_slot {
+	struct sk_buff	*skblist_next;
+	struct sk_buff	*skblist_prev;
+	sfq_index	qlen; /* number of skbs in skblist */
+	sfq_index	next; /* next slot in sfq chain */
+	unsigned short	hash; /* hash value (index in ht[]) */
+	short		allot; /* credit for this slot */
+	struct sfq_head dep; /* anchor in dep[] chains */
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
=20
+	struct sfq_slot *tail;		/* current slot in round */
 	sfq_index	ht[SFQ_HASH_DIVISOR];	/* Hash table */
-	sfq_index	next[SFQ_DEPTH];	/* Active slots link */
-	short		allot[SFQ_DEPTH];	/* Current allotment per slot */
-	unsigned short	hash[SFQ_DEPTH];	/* Hash value indexed by slots */
-	struct sk_buff_head	qs[SFQ_DEPTH];		/* Slot queue */
-	struct sfq_head	dep[SFQ_DEPTH*2];	/* Linked list of slots, indexed by=
 depth */
+	struct sfq_slot	slots[SFQ_SLOTS];
+	struct sfq_head	dep[SFQ_DEPTH];	/* Linked list of slots, indexed by d=
epth */
 };
=20
+/*
+ * sfq_head are either in a sfq_slot or in dep[] array
+ */
+static inline struct sfq_head *sfq_dep_head(struct sfq_sched_data *q, =
sfq_index val)
+{
+	if (val < SFQ_SLOTS)
+		return &q->slots[val].dep;
+	return &q->dep[val - SFQ_SLOTS];
+}
+
 static __inline__ unsigned sfq_fold_hash(struct sfq_sched_data *q, u32=
 h, u32 h1)
 {
 	return jhash_2words(h, h1, q->perturbation) & (SFQ_HASH_DIVISOR - 1);
@@ -200,30 +222,41 @@ static unsigned int sfq_classify(struct sk_buff *=
skb, struct Qdisc *sch,
 	return 0;
 }
=20
+/*
+ * x : slot number [0 .. SFQ_SLOTS - 1]
+ */
 static inline void sfq_link(struct sfq_sched_data *q, sfq_index x)
 {
 	sfq_index p, n;
-	int d =3D q->qs[x].qlen + SFQ_DEPTH;
+	int qlen =3D q->slots[x].qlen;
=20
-	p =3D d;
-	n =3D q->dep[d].next;
-	q->dep[x].next =3D n;
-	q->dep[x].prev =3D p;
-	q->dep[p].next =3D q->dep[n].prev =3D x;
+	p =3D qlen + SFQ_SLOTS;
+	n =3D q->dep[qlen].next;
+
+	q->slots[x].dep.next =3D n;
+	q->slots[x].dep.prev =3D p;
+
+	q->dep[qlen].next =3D x;		/* sfq_dep_head(q, p)->next =3D x */
+	sfq_dep_head(q, n)->prev =3D x;
 }
=20
+#define sfq_unlink(q, x, n, p)			\
+	n =3D q->slots[x].dep.next;		\
+	p =3D q->slots[x].dep.prev;		\
+	sfq_dep_head(q, p)->next =3D n;		\
+	sfq_dep_head(q, n)->prev =3D p
+=09
+
 static inline void sfq_dec(struct sfq_sched_data *q, sfq_index x)
 {
 	sfq_index p, n;
+	int d;
=20
-	n =3D q->dep[x].next;
-	p =3D q->dep[x].prev;
-	q->dep[p].next =3D n;
-	q->dep[n].prev =3D p;
-
-	if (n =3D=3D p && q->max_depth =3D=3D q->qs[x].qlen + 1)
-		q->max_depth--;
+	sfq_unlink(q, x, n, p);
=20
+	d =3D q->slots[x].qlen--;
+	if (n =3D=3D p && q->cur_depth =3D=3D d)
+		q->cur_depth--;
 	sfq_link(q, x);
 }
=20
@@ -232,34 +265,68 @@ static inline void sfq_inc(struct sfq_sched_data =
*q, sfq_index x)
 	sfq_index p, n;
 	int d;
=20
-	n =3D q->dep[x].next;
-	p =3D q->dep[x].prev;
-	q->dep[p].next =3D n;
-	q->dep[n].prev =3D p;
-	d =3D q->qs[x].qlen;
-	if (q->max_depth < d)
-		q->max_depth =3D d;
+	sfq_unlink(q, x, n, p);
=20
+	d =3D ++q->slots[x].qlen;
+	if (q->cur_depth < d)
+		q->cur_depth =3D d;
 	sfq_link(q, x);
 }
=20
+/* helper functions : might be changed when/if skb use a standard list=
_head */
+
+/* remove one skb from tail of slot queue */
+static inline struct sk_buff *slot_dequeue_tail(struct sfq_slot *slot)
+{
+	struct sk_buff *skb =3D slot->skblist_prev;
+
+	slot->skblist_prev =3D skb->prev;
+	skb->next =3D skb->prev =3D NULL;
+	return skb;
+}
+
+/* remove one skb from head of slot queue */
+static inline struct sk_buff *slot_dequeue_head(struct sfq_slot *slot)
+{
+	struct sk_buff *skb =3D slot->skblist_next;
+
+	slot->skblist_next =3D skb->next;
+	skb->next =3D skb->prev =3D NULL;
+	return skb;
+}
+
+static inline void slot_queue_init(struct sfq_slot *slot)
+{
+	slot->skblist_prev =3D slot->skblist_next =3D (struct sk_buff *)slot;
+}
+
+/* add skb to slot queue (tail add) */
+static inline void slot_queue_add(struct sfq_slot *slot, struct sk_buf=
f *skb)
+{
+	skb->prev =3D slot->skblist_prev;
+	skb->next =3D (struct sk_buff *)slot;
+	slot->skblist_prev->next =3D skb;
+	slot->skblist_prev =3D skb;
+}
+
+
 static unsigned int sfq_drop(struct Qdisc *sch)
 {
 	struct sfq_sched_data *q =3D qdisc_priv(sch);
-	sfq_index d =3D q->max_depth;
+	sfq_index x, d =3D q->cur_depth;
 	struct sk_buff *skb;
 	unsigned int len;
+	struct sfq_slot *slot;
=20
-	/* Queue is full! Find the longest slot and
-	   drop a packet from it */
-
+	/* Queue is full! Find the longest slot and drop tail packet from it =
*/
 	if (d > 1) {
-		sfq_index x =3D q->dep[d + SFQ_DEPTH].next;
-		skb =3D q->qs[x].prev;
+		x =3D q->dep[d].next;
+		slot =3D &q->slots[x];
+drop:
+		skb =3D slot_dequeue_tail(slot);
 		len =3D qdisc_pkt_len(skb);
-		__skb_unlink(skb, &q->qs[x]);
-		kfree_skb(skb);
 		sfq_dec(q, x);
+		kfree_skb(skb);
 		sch->q.qlen--;
 		sch->qstats.drops++;
 		sch->qstats.backlog -=3D len;
@@ -268,19 +335,11 @@ static unsigned int sfq_drop(struct Qdisc *sch)
=20
 	if (d =3D=3D 1) {
 		/* It is difficult to believe, but ALL THE SLOTS HAVE LENGTH 1. */
-		d =3D q->next[q->tail];
-		q->next[q->tail] =3D q->next[d];
-		q->allot[q->next[d]] +=3D q->quantum;
-		skb =3D q->qs[d].prev;
-		len =3D qdisc_pkt_len(skb);
-		__skb_unlink(skb, &q->qs[d]);
-		kfree_skb(skb);
-		sfq_dec(q, d);
-		sch->q.qlen--;
-		q->ht[q->hash[d]] =3D SFQ_DEPTH;
-		sch->qstats.drops++;
-		sch->qstats.backlog -=3D len;
-		return len;
+		x =3D q->tail->next;
+		slot =3D &q->slots[x];
+		q->tail->next =3D slot->next;
+		q->ht[slot->hash] =3D SFQ_EMPTY_SLOT;
+		goto drop;
 	}
=20
 	return 0;
@@ -292,6 +351,7 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	struct sfq_sched_data *q =3D qdisc_priv(sch);
 	unsigned int hash;
 	sfq_index x;
+	struct sfq_slot *slot;
 	int uninitialized_var(ret);
=20
 	hash =3D sfq_classify(skb, sch, &ret);
@@ -304,31 +364,33 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sc=
h)
 	hash--;
=20
 	x =3D q->ht[hash];
-	if (x =3D=3D SFQ_DEPTH) {
-		q->ht[hash] =3D x =3D q->dep[SFQ_DEPTH].next;
-		q->hash[x] =3D hash;
+	slot =3D &q->slots[x];
+	if (x =3D=3D SFQ_EMPTY_SLOT) {
+		x =3D q->dep[0].next; /* get a free slot */
+		q->ht[hash] =3D x;
+		slot =3D &q->slots[x];
+		slot->hash =3D hash;
+		slot_queue_init(slot);
 	}
=20
-	/* If selected queue has length q->limit, this means that
-	 * all another queues are empty and that we do simple tail drop,
+	/* If selected queue has length q->limit, do simple tail drop,
 	 * i.e. drop _this_ packet.
 	 */
-	if (q->qs[x].qlen >=3D q->limit)
+	if (slot->qlen >=3D q->limit)
 		return qdisc_drop(skb, sch);
=20
 	sch->qstats.backlog +=3D qdisc_pkt_len(skb);
-	__skb_queue_tail(&q->qs[x], skb);
+	slot_queue_add(slot, skb);
 	sfq_inc(q, x);
-	if (q->qs[x].qlen =3D=3D 1) {		/* The flow is new */
-		if (q->tail =3D=3D SFQ_DEPTH) {	/* It is the first flow */
-			q->tail =3D x;
-			q->next[x] =3D x;
-			q->allot[x] =3D q->quantum;
+	if (slot->qlen =3D=3D 1) {		/* The flow is new */
+		if (q->tail =3D=3D NULL) {	/* It is the first flow */
+			slot->next =3D x;
 		} else {
-			q->next[x] =3D q->next[q->tail];
-			q->next[q->tail] =3D x;
-			q->tail =3D x;
+			slot->next =3D q->tail->next;
+			q->tail->next =3D x;
 		}
+		q->tail =3D slot;
+		slot->allot =3D q->quantum;
 	}
 	if (++sch->q.qlen <=3D q->limit) {
 		sch->bstats.bytes +=3D qdisc_pkt_len(skb);
@@ -344,14 +406,12 @@ static struct sk_buff *
 sfq_peek(struct Qdisc *sch)
 {
 	struct sfq_sched_data *q =3D qdisc_priv(sch);
-	sfq_index a;
=20
 	/* No active slots */
-	if (q->tail =3D=3D SFQ_DEPTH)
+	if (q->tail =3D=3D NULL)
 		return NULL;
=20
-	a =3D q->next[q->tail];
-	return skb_peek(&q->qs[a]);
+	return q->slots[q->tail->next].skblist_next;
 }
=20
 static struct sk_buff *
@@ -359,34 +419,32 @@ sfq_dequeue(struct Qdisc *sch)
 {
 	struct sfq_sched_data *q =3D qdisc_priv(sch);
 	struct sk_buff *skb;
-	sfq_index a, old_a;
+	sfq_index a, next_a;
+	struct sfq_slot *slot;
=20
 	/* No active slots */
-	if (q->tail =3D=3D SFQ_DEPTH)
+	if (q->tail =3D=3D NULL)
 		return NULL;
=20
-	a =3D old_a =3D q->next[q->tail];
-
-	/* Grab packet */
-	skb =3D __skb_dequeue(&q->qs[a]);
+	a =3D q->tail->next;
+	slot =3D &q->slots[a];
+	skb =3D slot_dequeue_head(slot);
 	sfq_dec(q, a);
 	sch->q.qlen--;
 	sch->qstats.backlog -=3D qdisc_pkt_len(skb);
=20
-	/* Is the slot empty? */
-	if (q->qs[a].qlen =3D=3D 0) {
-		q->ht[q->hash[a]] =3D SFQ_DEPTH;
-		a =3D q->next[a];
-		if (a =3D=3D old_a) {
-			q->tail =3D SFQ_DEPTH;
+	/* Is the slot now empty? */
+	if (slot->qlen =3D=3D 0) {
+		q->ht[slot->hash] =3D SFQ_EMPTY_SLOT;
+		next_a =3D slot->next;
+		if (a =3D=3D next_a) {
+			q->tail =3D NULL; /* no more active slots */
 			return skb;
 		}
-		q->next[q->tail] =3D a;
-		q->allot[a] +=3D q->quantum;
-	} else if ((q->allot[a] -=3D qdisc_pkt_len(skb)) <=3D 0) {
-		q->tail =3D a;
-		a =3D q->next[a];
-		q->allot[a] +=3D q->quantum;
+		q->tail->next =3D next_a;
+	} else if ((slot->allot -=3D qdisc_pkt_len(skb)) <=3D 0) {
+		q->tail =3D slot;
+		slot->allot +=3D q->quantum;
 	}
 	return skb;
 }
@@ -450,17 +508,16 @@ static int sfq_init(struct Qdisc *sch, struct nla=
ttr *opt)
 	init_timer_deferrable(&q->perturb_timer);
=20
 	for (i =3D 0; i < SFQ_HASH_DIVISOR; i++)
-		q->ht[i] =3D SFQ_DEPTH;
+		q->ht[i] =3D SFQ_EMPTY_SLOT;
=20
 	for (i =3D 0; i < SFQ_DEPTH; i++) {
-		skb_queue_head_init(&q->qs[i]);
-		q->dep[i + SFQ_DEPTH].next =3D i + SFQ_DEPTH;
-		q->dep[i + SFQ_DEPTH].prev =3D i + SFQ_DEPTH;
+		q->dep[i].next =3D i + SFQ_SLOTS;
+		q->dep[i].prev =3D i + SFQ_SLOTS;
 	}
=20
 	q->limit =3D SFQ_DEPTH - 1;
-	q->max_depth =3D 0;
-	q->tail =3D SFQ_DEPTH;
+	q->cur_depth =3D 0;
+	q->tail =3D NULL;
 	if (opt =3D=3D NULL) {
 		q->quantum =3D psched_mtu(qdisc_dev(sch));
 		q->perturb_period =3D 0;
@@ -471,7 +528,7 @@ static int sfq_init(struct Qdisc *sch, struct nlatt=
r *opt)
 			return err;
 	}
=20
-	for (i =3D 0; i < SFQ_DEPTH; i++)
+	for (i =3D 0; i < SFQ_SLOTS; i++)
 		sfq_link(q, i);
 	return 0;
 }
@@ -547,9 +604,9 @@ static int sfq_dump_class_stats(struct Qdisc *sch, =
unsigned long cl,
 				struct gnet_dump *d)
 {
 	struct sfq_sched_data *q =3D qdisc_priv(sch);
-	sfq_index idx =3D q->ht[cl-1];
-	struct gnet_stats_queue qs =3D { .qlen =3D q->qs[idx].qlen };
-	struct tc_sfq_xstats xstats =3D { .allot =3D q->allot[idx] };
+	const struct sfq_slot *slot =3D &q->slots[q->ht[cl - 1]];
+	struct gnet_stats_queue qs =3D { .qlen =3D slot->qlen };
+	struct tc_sfq_xstats xstats =3D { .allot =3D slot->allot };
=20
 	if (gnet_stats_copy_queue(d, &qs) < 0)
 		return -1;
@@ -565,7 +622,7 @@ static void sfq_walk(struct Qdisc *sch, struct qdis=
c_walker *arg)
 		return;
=20
 	for (i =3D 0; i < SFQ_HASH_DIVISOR; i++) {
-		if (q->ht[i] =3D=3D SFQ_DEPTH ||
+		if (q->ht[i] =3D=3D SFQ_EMPTY_SLOT ||
 		    arg->count < arg->skip) {
 			arg->count++;
 			continue;


