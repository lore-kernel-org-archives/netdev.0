From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [RFC] SFQ planned changes
Date: Wed, 4 Jan 2012 00:57:11 +0100
Message-ID: <CAA93jw427XZj17CtAavJCiZDgPqYu4S5v_fZzoYuZ+p5KbyWAg@mail.gmail.com>
References: <1325385056.4174.51.camel@denise.theartistscloset.com>
	<21734335.uCtjXOcSpA@alaris>
	<CAA93jw5NYChp+hKWjOWiw7SnGhNe+REofr2KM-85GnKNVpkw6w@mail.gmail.com>
	<1325587235.2320.37.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<CAA93jw5T10PHD+YQQjy_r=LHKVbYeiWerwM0ou7HANGoenFRKw@mail.gmail.com>
	<1325595036.2320.43.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1325606918.2320.84.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Michal_Kube=C4=8Dek?= <mkubecek@suse.cz>,
	netdev@vger.kernel.org,
	"John A. Sullivan III" <jsullivan@opensourcedevel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:53814 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755136Ab2ACX5N convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jan 2012 18:57:13 -0500
Received: by obcwo16 with SMTP id wo16so13116567obc.19
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2012 15:57:12 -0800 (PST)
In-Reply-To: <1325606918.2320.84.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 3, 2012 at 5:08 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Here is the code I ran on my test server with 200 netperf TCP_STREAM
> flows with pretty good results (each flow gets 0.5 % of bandwidth)

Can I encourage you to always simultaneously run a fping and/or a
netperf -t TCP_RR

latency under load test when doing stuff like this?

The amount of backlogged bytes is rather impressive...


>
> $TC qdisc add dev $DEV root handle 1: est 1sec 8sec htb default 1
> $TC class add dev $DEV parent 1: classid 1:1 est 1sec 8sec htb \
> =A0 =A0 =A0 =A0rate 200Mbit mtu 40000 quantum 80000
>
> $TC qdisc add dev $DEV parent 1:1 handle 10: est 1sec 8sec sfq \
> =A0 =A0 =A0 =A0limit 2000 depth 10 headdrop flows 1000 divisor 16384
>
> # tcnew -s -d qdisc show dev eth3
> qdisc htb 1: root refcnt 18 r2q 10 default 1 direct_packets_stat 0 ve=
r 3.17
> =A0Sent 4512949730 bytes 3030391 pkt (dropped 44409, overlimits 61051=
00 requeues 1)
> =A0rate 198288Kbit 16629pps backlog 0b 1732p requeues 1
> qdisc sfq 10: parent 1:1 limit 2000p quantum 1514b depth 10 headdrop =
flows 1000/16384 divisor 16384
> =A0Sent 4512949730 bytes 3030391 pkt (dropped 44409, overlimits 0 req=
ueues 0)
> =A0rate 198288Kbit 16629pps backlog 2622248b 1732p requeues 0
>
> patch on top of current net-next

I'm not going to have time to get to this for a while...


> =A0include/linux/pkt_sched.h | =A0 =A07 +
> =A0net/sched/sch_sfq.c =A0 =A0 =A0 | =A0144 ++++++++++++++++++++++++-=
-----------
> =A02 files changed, 104 insertions(+), 47 deletions(-)
>
> diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
> index 8daced3..c2c6cfd 100644
> --- a/include/linux/pkt_sched.h
> +++ b/include/linux/pkt_sched.h
> @@ -162,6 +162,13 @@ struct tc_sfq_qopt {
> =A0 =A0 =A0 =A0unsigned =A0 =A0 =A0 =A0flows; =A0 =A0 =A0 =A0 =A0/* M=
aximal number of flows =A0*/
> =A0};
>
> +struct tc_sfq_ext_qopt {
> + =A0 =A0 =A0 struct tc_sfq_qopt qopt;
> + =A0 =A0 =A0 unsigned int depth; =A0 =A0 =A0 =A0 =A0 =A0 /* max numb=
er of packets per flow */
> + =A0 =A0 =A0 unsigned int headdrop;
> +};
> +
> +
> =A0struct tc_sfq_xstats {
> =A0 =A0 =A0 =A0__s32 =A0 =A0 =A0 =A0 =A0 allot;
> =A0};
> diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
> index d329a8a..66682fd 100644
> --- a/net/sched/sch_sfq.c
> +++ b/net/sched/sch_sfq.c
> @@ -67,15 +67,16 @@
>
> =A0 =A0 =A0 =A0IMPLEMENTATION:
> =A0 =A0 =A0 =A0This implementation limits maximal queue length to 128=
;
> - =A0 =A0 =A0 max mtu to 2^18-1; max 128 flows, number of hash bucket=
s to 1024.
> - =A0 =A0 =A0 The only goal of this restrictions was that all data
> - =A0 =A0 =A0 fit into one 4K page on 32bit arches.
> + =A0 =A0 =A0 max mtu to 2^18-1;
> + =A0 =A0 =A0 max 65280 flows,
> + =A0 =A0 =A0 number of hash buckets to 65536.
>
> =A0 =A0 =A0 =A0It is easy to increase these values, but not in flight=
=2E =A0*/
>
> =A0#define SFQ_DEPTH =A0 =A0 =A0 =A0 =A0 =A0 =A0128 /* max number of =
packets per flow */
> -#define SFQ_SLOTS =A0 =A0 =A0 =A0 =A0 =A0 =A0128 /* max number of fl=
ows */
> -#define SFQ_EMPTY_SLOT =A0 =A0 =A0 =A0 255
> +#define SFQ_DEFAULT_FLOWS =A0 =A0 =A0128
> +#define SFQ_MAX_FLOWS =A0 =A0 =A0 =A0 =A0(0x10000 - 256) /* max numb=
er of flows */
> +#define SFQ_EMPTY_SLOT =A0 =A0 =A0 =A0 0xffff
> =A0#define SFQ_DEFAULT_HASH_DIVISOR 1024
>
> =A0/* We use 16 bits to store allot, and want to handle packets up to=
 64K
> @@ -84,13 +85,13 @@
> =A0#define SFQ_ALLOT_SHIFT =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A03
> =A0#define SFQ_ALLOT_SIZE(X) =A0 =A0 =A0DIV_ROUND_UP(X, 1 << SFQ_ALLO=
T_SHIFT)
>
> -/* This type should contain at least SFQ_DEPTH + SFQ_SLOTS values */
> -typedef unsigned char sfq_index;
> +/* This type should contain at least SFQ_DEPTH + SFQ_MAX_FLOWS value=
s */
> +typedef u16 sfq_index;
>
> =A0/*
> =A0* We dont use pointers to save space.
> - * Small indexes [0 ... SFQ_SLOTS - 1] are 'pointers' to slots[] arr=
ay
> - * while following values [SFQ_SLOTS ... SFQ_SLOTS + SFQ_DEPTH - 1]
> + * Small indexes [0 ... SFQ_MAX_FLOWS - 1] are 'pointers' to slots[]=
 array
> + * while following values [SFQ_MAX_FLOWS ... SFQ_MAX_FLOWS + SFQ_DEP=
TH - 1]
> =A0* are 'pointers' to dep[] array
> =A0*/
> =A0struct sfq_head {
> @@ -112,8 +113,11 @@ struct sfq_sched_data {
> =A0/* Parameters */
> =A0 =A0 =A0 =A0int =A0 =A0 =A0 =A0 =A0 =A0 perturb_period;
> =A0 =A0 =A0 =A0unsigned int =A0 =A0quantum; =A0 =A0 =A0 =A0/* Allotme=
nt per round: MUST BE >=3D MTU */
> - =A0 =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 limit;
> + =A0 =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 limit; =A0 =A0 =A0 =A0 =A0/=
* limit of total number of packets in this qdisc */
> =A0 =A0 =A0 =A0unsigned int =A0 =A0divisor; =A0 =A0 =A0 =A0/* number =
of slots in hash table */
> + =A0 =A0 =A0 unsigned int =A0 =A0maxflows; =A0 =A0 =A0 /* number of =
flows in flows array */
> + =A0 =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 headdrop;
> + =A0 =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 depth; =A0 =A0 =A0 =A0 =A0/=
* limit depth of each flow */
> =A0/* Variables */
> =A0 =A0 =A0 =A0struct tcf_proto *filter_list;
> =A0 =A0 =A0 =A0struct timer_list perturb_timer;
> @@ -122,7 +126,7 @@ struct sfq_sched_data {
> =A0 =A0 =A0 =A0unsigned short =A0scaled_quantum; /* SFQ_ALLOT_SIZE(qu=
antum) */
> =A0 =A0 =A0 =A0struct sfq_slot *tail; =A0 =A0 =A0 =A0 =A0/* current s=
lot in round */
> =A0 =A0 =A0 =A0sfq_index =A0 =A0 =A0 *ht; =A0 =A0 =A0 =A0 =A0 =A0/* H=
ash table (divisor slots) */
> - =A0 =A0 =A0 struct sfq_slot slots[SFQ_SLOTS];
> + =A0 =A0 =A0 struct sfq_slot *slots;
> =A0 =A0 =A0 =A0struct sfq_head dep[SFQ_DEPTH]; /* Linked list of slot=
s, indexed by depth */
> =A0};
>
> @@ -131,9 +135,9 @@ struct sfq_sched_data {
> =A0*/
> =A0static inline struct sfq_head *sfq_dep_head(struct sfq_sched_data =
*q, sfq_index val)
> =A0{
> - =A0 =A0 =A0 if (val < SFQ_SLOTS)
> + =A0 =A0 =A0 if (val < SFQ_MAX_FLOWS)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return &q->slots[val].dep;
> - =A0 =A0 =A0 return &q->dep[val - SFQ_SLOTS];
> + =A0 =A0 =A0 return &q->dep[val - SFQ_MAX_FLOWS];
> =A0}
>
> =A0/*
> @@ -199,18 +203,19 @@ static unsigned int sfq_classify(struct sk_buff=
 *skb, struct Qdisc *sch,
> =A0}
>
> =A0/*
> - * x : slot number [0 .. SFQ_SLOTS - 1]
> + * x : slot number [0 .. SFQ_MAX_FLOWS - 1]
> =A0*/
> =A0static inline void sfq_link(struct sfq_sched_data *q, sfq_index x)
> =A0{
> =A0 =A0 =A0 =A0sfq_index p, n;
> - =A0 =A0 =A0 int qlen =3D q->slots[x].qlen;
> + =A0 =A0 =A0 struct sfq_slot *slot =3D &q->slots[x];
> + =A0 =A0 =A0 int qlen =3D slot->qlen;
>
> - =A0 =A0 =A0 p =3D qlen + SFQ_SLOTS;
> + =A0 =A0 =A0 p =3D qlen + SFQ_MAX_FLOWS;
> =A0 =A0 =A0 =A0n =3D q->dep[qlen].next;
>
> - =A0 =A0 =A0 q->slots[x].dep.next =3D n;
> - =A0 =A0 =A0 q->slots[x].dep.prev =3D p;
> + =A0 =A0 =A0 slot->dep.next =3D n;
> + =A0 =A0 =A0 slot->dep.prev =3D p;
>
> =A0 =A0 =A0 =A0q->dep[qlen].next =3D x; =A0 =A0 =A0 =A0 =A0/* sfq_dep=
_head(q, p)->next =3D x */
> =A0 =A0 =A0 =A0sfq_dep_head(q, n)->prev =3D x;
> @@ -305,7 +310,7 @@ static unsigned int sfq_drop(struct Qdisc *sch)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0x =3D q->dep[d].next;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0slot =3D &q->slots[x];
> =A0drop:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb =3D slot_dequeue_tail(slot);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb =3D q->headdrop ? slot_dequeue_head=
(slot) : slot_dequeue_tail(slot);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0len =3D qdisc_pkt_len(skb);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sfq_dec(q, x);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kfree_skb(skb);
> @@ -349,16 +354,26 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *=
sch)
> =A0 =A0 =A0 =A0slot =3D &q->slots[x];
> =A0 =A0 =A0 =A0if (x =3D=3D SFQ_EMPTY_SLOT) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0x =3D q->dep[0].next; /* get a free sl=
ot */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (x >=3D SFQ_MAX_FLOWS)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return qdisc_drop(skb, =
sch);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0q->ht[hash] =3D x;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0slot =3D &q->slots[x];
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0slot->hash =3D hash;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 /* If selected queue has length q->limit, do simple tai=
l drop,
> - =A0 =A0 =A0 =A0* i.e. drop _this_ packet.
> - =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 if (slot->qlen >=3D q->limit)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return qdisc_drop(skb, sch);
> + =A0 =A0 =A0 if (slot->qlen >=3D q->depth) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct sk_buff *head;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!q->headdrop)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return qdisc_drop(skb, =
sch);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 head =3D slot_dequeue_head(slot);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sch->qstats.backlog -=3D qdisc_pkt_len(=
head);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree_skb(head);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sch->qstats.drops++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sch->qstats.backlog +=3D qdisc_pkt_len(=
skb);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 slot_queue_add(slot, skb);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NET_XMIT_CN;
> + =A0 =A0 =A0 }
>
> =A0 =A0 =A0 =A0sch->qstats.backlog +=3D qdisc_pkt_len(skb);
> =A0 =A0 =A0 =A0slot_queue_add(slot, skb);
> @@ -366,11 +381,11 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *=
sch)
> =A0 =A0 =A0 =A0if (slot->qlen =3D=3D 1) { =A0 =A0 =A0 =A0 =A0/* The f=
low is new */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (q->tail =3D=3D NULL) { =A0/* It is=
 the first flow */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0slot->next =3D x;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 q->tail =3D slot;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0slot->next =3D q->tail=
->next;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0q->tail->next =3D x;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 q->tail =3D slot;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0slot->allot =3D q->scaled_quantum;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0if (++sch->q.qlen <=3D q->limit)
> @@ -445,16 +460,17 @@ sfq_reset(struct Qdisc *sch)
> =A0* We dont use sfq_dequeue()/sfq_enqueue() because we dont want to =
change
> =A0* counters.
> =A0*/
> -static void sfq_rehash(struct sfq_sched_data *q)
> +static int sfq_rehash(struct sfq_sched_data *q)
> =A0{
> =A0 =A0 =A0 =A0struct sk_buff *skb;
> =A0 =A0 =A0 =A0int i;
> =A0 =A0 =A0 =A0struct sfq_slot *slot;
> =A0 =A0 =A0 =A0struct sk_buff_head list;
> + =A0 =A0 =A0 int dropped =3D 0;
>
> =A0 =A0 =A0 =A0__skb_queue_head_init(&list);
>
> - =A0 =A0 =A0 for (i =3D 0; i < SFQ_SLOTS; i++) {
> + =A0 =A0 =A0 for (i =3D 0; i < q->maxflows; i++) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0slot =3D &q->slots[i];
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!slot->qlen)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> @@ -474,6 +490,11 @@ static void sfq_rehash(struct sfq_sched_data *q)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0slot =3D &q->slots[x];
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (x =3D=3D SFQ_EMPTY_SLOT) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0x =3D q->dep[0].next; =
/* get a free slot */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (x >=3D SFQ_MAX_FLOW=
S) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree_s=
kb(skb);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dropped=
++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continu=
e;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0q->ht[hash] =3D x;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0slot =3D &q->slots[x];
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0slot->hash =3D hash;
> @@ -491,6 +512,7 @@ static void sfq_rehash(struct sfq_sched_data *q)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0slot->allot =3D q->sca=
led_quantum;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
> + =A0 =A0 =A0 return dropped;
> =A0}
>
> =A0static void sfq_perturbation(unsigned long arg)
> @@ -502,7 +524,7 @@ static void sfq_perturbation(unsigned long arg)
> =A0 =A0 =A0 =A0spin_lock(root_lock);
> =A0 =A0 =A0 =A0q->perturbation =3D net_random();
> =A0 =A0 =A0 =A0if (!q->filter_list && q->tail)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 sfq_rehash(q);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 qdisc_tree_decrease_qlen(sch, sfq_rehas=
h(q));
> =A0 =A0 =A0 =A0spin_unlock(root_lock);
>
> =A0 =A0 =A0 =A0if (q->perturb_period)
> @@ -513,11 +535,13 @@ static int sfq_change(struct Qdisc *sch, struct=
 nlattr *opt)
> =A0{
> =A0 =A0 =A0 =A0struct sfq_sched_data *q =3D qdisc_priv(sch);
> =A0 =A0 =A0 =A0struct tc_sfq_qopt *ctl =3D nla_data(opt);
> + =A0 =A0 =A0 struct tc_sfq_ext_qopt *ctl_ext =3D NULL;
> =A0 =A0 =A0 =A0unsigned int qlen;
>
> =A0 =A0 =A0 =A0if (opt->nla_len < nla_attr_size(sizeof(*ctl)))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;
> -
> + =A0 =A0 =A0 if (opt->nla_len >=3D nla_attr_size(sizeof(*ctl_ext)))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ctl_ext =3D nla_data(opt);
> =A0 =A0 =A0 =A0if (ctl->divisor &&
> =A0 =A0 =A0 =A0 =A0 =A0(!is_power_of_2(ctl->divisor) || ctl->divisor =
> 65536))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;
> @@ -526,10 +550,18 @@ static int sfq_change(struct Qdisc *sch, struct=
 nlattr *opt)
> =A0 =A0 =A0 =A0q->quantum =3D ctl->quantum ? : psched_mtu(qdisc_dev(s=
ch));
> =A0 =A0 =A0 =A0q->scaled_quantum =3D SFQ_ALLOT_SIZE(q->quantum);
> =A0 =A0 =A0 =A0q->perturb_period =3D ctl->perturb_period * HZ;
> - =A0 =A0 =A0 if (ctl->limit)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 q->limit =3D min_t(u32, ctl->limit, SFQ=
_DEPTH - 1);
> + =A0 =A0 =A0 if (ctl->flows)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 q->maxflows =3D min_t(u32, ctl->flows, =
SFQ_MAX_FLOWS);
> =A0 =A0 =A0 =A0if (ctl->divisor)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0q->divisor =3D ctl->divisor;
> + =A0 =A0 =A0 if (ctl_ext) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ctl_ext->depth)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 q->depth =3D min_t(u32,=
 ctl_ext->depth, SFQ_DEPTH - 1);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 q->headdrop =3D ctl_ext->headdrop;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 if (ctl->limit)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 q->limit =3D min_t(u32, ctl->limit, q->=
depth * q->maxflows);
> +
> =A0 =A0 =A0 =A0qlen =3D sch->q.qlen;
> =A0 =A0 =A0 =A0while (sch->q.qlen > q->limit)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sfq_drop(sch);
> @@ -544,6 +576,16 @@ static int sfq_change(struct Qdisc *sch, struct =
nlattr *opt)
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> +static void sfq_free(void *addr)
> +{
> + =A0 =A0 =A0 if (addr) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (is_vmalloc_addr(addr))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vfree(addr);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(addr);
> + =A0 =A0 =A0 }
> +}
> +
> =A0static int sfq_init(struct Qdisc *sch, struct nlattr *opt)
> =A0{
> =A0 =A0 =A0 =A0struct sfq_sched_data *q =3D qdisc_priv(sch);
> @@ -555,14 +597,16 @@ static int sfq_init(struct Qdisc *sch, struct n=
lattr *opt)
> =A0 =A0 =A0 =A0init_timer_deferrable(&q->perturb_timer);
>
> =A0 =A0 =A0 =A0for (i =3D 0; i < SFQ_DEPTH; i++) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 q->dep[i].next =3D i + SFQ_SLOTS;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 q->dep[i].prev =3D i + SFQ_SLOTS;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 q->dep[i].next =3D i + SFQ_MAX_FLOWS;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 q->dep[i].prev =3D i + SFQ_MAX_FLOWS;
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0q->limit =3D SFQ_DEPTH - 1;
> + =A0 =A0 =A0 q->depth =3D SFQ_DEPTH - 1;
> =A0 =A0 =A0 =A0q->cur_depth =3D 0;
> =A0 =A0 =A0 =A0q->tail =3D NULL;
> =A0 =A0 =A0 =A0q->divisor =3D SFQ_DEFAULT_HASH_DIVISOR;
> + =A0 =A0 =A0 q->maxflows =3D SFQ_DEFAULT_FLOWS;
> =A0 =A0 =A0 =A0if (opt =3D=3D NULL) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0q->quantum =3D psched_mtu(qdisc_dev(sc=
h));
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0q->scaled_quantum =3D SFQ_ALLOT_SIZE(q=
->quantum);
> @@ -575,15 +619,22 @@ static int sfq_init(struct Qdisc *sch, struct n=
lattr *opt)
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0sz =3D sizeof(q->ht[0]) * q->divisor;
> - =A0 =A0 =A0 q->ht =3D kmalloc(sz, GFP_KERNEL);
> + =A0 =A0 =A0 q->ht =3D kmalloc(sz, GFP_KERNEL | __GFP_NOWARN);
> =A0 =A0 =A0 =A0if (!q->ht && sz > PAGE_SIZE)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0q->ht =3D vmalloc(sz);
> =A0 =A0 =A0 =A0if (!q->ht)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENOMEM;
> +
> + =A0 =A0 =A0 q->slots =3D kzalloc(sizeof(q->slots[0]) * q->maxflows,=
 GFP_KERNEL | __GFP_NOWARN);
> + =A0 =A0 =A0 if (!q->slots)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 q->slots =3D vzalloc(sizeof(q->slots[0]=
) * q->maxflows);
> + =A0 =A0 =A0 if (!q->slots) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sfq_free(q->ht);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> + =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0for (i =3D 0; i < q->divisor; i++)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0q->ht[i] =3D SFQ_EMPTY_SLOT;
> -
> - =A0 =A0 =A0 for (i =3D 0; i < SFQ_SLOTS; i++) {
> + =A0 =A0 =A0 for (i =3D 0; i < q->maxflows; i++) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0slot_queue_init(&q->slots[i]);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sfq_link(q, i);
> =A0 =A0 =A0 =A0}
> @@ -601,25 +652,24 @@ static void sfq_destroy(struct Qdisc *sch)
> =A0 =A0 =A0 =A0tcf_destroy_chain(&q->filter_list);
> =A0 =A0 =A0 =A0q->perturb_period =3D 0;
> =A0 =A0 =A0 =A0del_timer_sync(&q->perturb_timer);
> - =A0 =A0 =A0 if (is_vmalloc_addr(q->ht))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 vfree(q->ht);
> - =A0 =A0 =A0 else
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(q->ht);
> + =A0 =A0 =A0 sfq_free(q->ht);
> + =A0 =A0 =A0 sfq_free(q->slots);
> =A0}
>
> =A0static int sfq_dump(struct Qdisc *sch, struct sk_buff *skb)
> =A0{
> =A0 =A0 =A0 =A0struct sfq_sched_data *q =3D qdisc_priv(sch);
> =A0 =A0 =A0 =A0unsigned char *b =3D skb_tail_pointer(skb);
> - =A0 =A0 =A0 struct tc_sfq_qopt opt;
> -
> - =A0 =A0 =A0 opt.quantum =3D q->quantum;
> - =A0 =A0 =A0 opt.perturb_period =3D q->perturb_period / HZ;
> + =A0 =A0 =A0 struct tc_sfq_ext_qopt opt;
>
> - =A0 =A0 =A0 opt.limit =3D q->limit;
> - =A0 =A0 =A0 opt.divisor =3D q->divisor;
> - =A0 =A0 =A0 opt.flows =3D q->limit;
> + =A0 =A0 =A0 opt.qopt.quantum =3D q->quantum;
> + =A0 =A0 =A0 opt.qopt.perturb_period =3D q->perturb_period / HZ;
>
> + =A0 =A0 =A0 opt.qopt.limit =3D q->limit;
> + =A0 =A0 =A0 opt.qopt.divisor =3D q->divisor;
> + =A0 =A0 =A0 opt.qopt.flows =3D q->maxflows;
> + =A0 =A0 =A0 opt.depth =3D q->depth;
> + =A0 =A0 =A0 opt.headdrop =3D q->headdrop;
> =A0 =A0 =A0 =A0NLA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
>
> =A0 =A0 =A0 =A0return skb->len;
>
>



--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
=46R Tel: 0638645374
http://www.bufferbloat.net
