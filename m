From: Laurent Chavey <chavey@google.com>
Subject: Re: [PATCH net-next] net_sched: sfq: extend limits
Date: Thu, 5 Jan 2012 10:08:05 -0800
Message-ID: <CAEas1LKV3USGX5wi6ucW2j_REzxKAeu3Rzj4Je5s92y33=kWDQ@mail.gmail.com>
References: <1325722718.2634.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Dave Taht <dave.taht@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:45316 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751811Ab2AESIr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 13:08:47 -0500
Received: by vbbfc26 with SMTP id fc26so582318vbb.19
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2012 10:08:46 -0800 (PST)
In-Reply-To: <1325722718.2634.17.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 4, 2012 at 4:18 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> SFQ as implemented in Linux is very limited, with at most 127 flows
> and limit of 127 packets. [ So if 127 flows are active, we have one
> packet per flow ]
>
> This patch brings to SFQ following features to cope with modern needs=
=2E
>
> - Ability to specify a smaller per flow limit of inflight packets.
> =A0 =A0(default value being at 127 packets)
>
> - Ability to have up to 65408 active flows (instead of 127)
>
> - Ability to have head drops instead of tail drops
> =A0(to drop old packets from a flow)
>
> Example of use : No more than 20 packets per flow, max 8000 flows, ma=
x
> 20000 packets in SFQ qdisc, hash table of 65536 slots.
>
> tc qdisc add ... sfq \
> =A0 =A0 =A0 =A0flows 8000 \
> =A0 =A0 =A0 =A0depth 20 \
> =A0 =A0 =A0 =A0headdrop \
> =A0 =A0 =A0 =A0limit 20000 \
> =A0 =A0 =A0 =A0divisor 65536
>
> Ram usage :
>
> 2 bytes per hash table entry (instead of previous 1 byte/entry)
> 32 bytes per flow on 64bit arches, instead of 384 for QFQ, so much
> better cache hit ratio.
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Dave Taht <dave.taht@gmail.com>
> ---
> =A0include/linux/pkt_sched.h | =A0 16 +--
> =A0net/sched/sch_sfq.c =A0 =A0 =A0 | =A0175 ++++++++++++++++++++++++-=
-----------
> =A02 files changed, 124 insertions(+), 67 deletions(-)
>
> diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
> index 8daced3..8f1b928 100644
> --- a/include/linux/pkt_sched.h
> +++ b/include/linux/pkt_sched.h
> @@ -162,19 +162,17 @@ struct tc_sfq_qopt {
> =A0 =A0 =A0 =A0unsigned =A0 =A0 =A0 =A0flows; =A0 =A0 =A0 =A0 =A0/* M=
aximal number of flows =A0*/
> =A0};
>
> +struct tc_sfq_qopt_v1 {
> + =A0 =A0 =A0 struct tc_sfq_qopt v0;
> + =A0 =A0 =A0 unsigned int =A0 =A0depth; =A0 =A0 =A0 =A0 =A0/* max nu=
mber of packets per flow */
> + =A0 =A0 =A0 unsigned int =A0 =A0headdrop;
> +};
> +
> +
> =A0struct tc_sfq_xstats {
> =A0 =A0 =A0 =A0__s32 =A0 =A0 =A0 =A0 =A0 allot;
> =A0};
>
> -/*
> - * =A0NOTE: limit, divisor and flows are hardwired to code at the mo=
ment.
> - *
> - * =A0 =A0 limit=3Dflows=3D128, divisor=3D1024;
> - *
> - * =A0 =A0 The only reason for this is efficiency, it is possible
> - * =A0 =A0 to change these parameters in compile time.
> - */
> -
> =A0/* RED section */
>
> =A0enum {
> diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
> index 8430181..0a79640 100644
> --- a/net/sched/sch_sfq.c
> +++ b/net/sched/sch_sfq.c
> @@ -66,16 +66,18 @@
> =A0 =A0 =A0 =A0SFQ is superior for this purpose.
>
> =A0 =A0 =A0 =A0IMPLEMENTATION:
> - =A0 =A0 =A0 This implementation limits maximal queue length to 128;
> - =A0 =A0 =A0 max mtu to 2^18-1; max 128 flows, number of hash bucket=
s to 1024.
> - =A0 =A0 =A0 The only goal of this restrictions was that all data
> - =A0 =A0 =A0 fit into one 4K page on 32bit arches.
> + =A0 =A0 =A0 This implementation limits :
> + =A0 =A0 =A0 - maximal queue length per flow to 127 packets.
> + =A0 =A0 =A0 - max mtu to 2^18-1;
> + =A0 =A0 =A0 - max 65408 flows,
> + =A0 =A0 =A0 - number of hash buckets to 65536.
>
> =A0 =A0 =A0 =A0It is easy to increase these values, but not in flight=
=2E =A0*/
>
> -#define SFQ_DEPTH =A0 =A0 =A0 =A0 =A0 =A0 =A0128 /* max number of pa=
ckets per flow */
> -#define SFQ_SLOTS =A0 =A0 =A0 =A0 =A0 =A0 =A0128 /* max number of fl=
ows */
> -#define SFQ_EMPTY_SLOT =A0 =A0 =A0 =A0 255
> +#define SFQ_MAX_DEPTH =A0 =A0 =A0 =A0 =A0127 /* max number of packet=
s per flow */
> +#define SFQ_DEFAULT_FLOWS =A0 =A0 =A0128
> +#define SFQ_MAX_FLOWS =A0 =A0 =A0 =A0 =A0(0x10000 - SFQ_MAX_DEPTH - =
1) /* max number of flows */
> +#define SFQ_EMPTY_SLOT =A0 =A0 =A0 =A0 0xffff
> =A0#define SFQ_DEFAULT_HASH_DIVISOR 1024
>
> =A0/* We use 16 bits to store allot, and want to handle packets up to=
 64K
> @@ -84,13 +86,13 @@
> =A0#define SFQ_ALLOT_SHIFT =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A03
> =A0#define SFQ_ALLOT_SIZE(X) =A0 =A0 =A0DIV_ROUND_UP(X, 1 << SFQ_ALLO=
T_SHIFT)
>
> -/* This type should contain at least SFQ_DEPTH + SFQ_SLOTS values */
> -typedef unsigned char sfq_index;
> +/* This type should contain at least SFQ_MAX_DEPTH + 1 + SFQ_MAX_FLO=
WS values */
> +typedef u16 sfq_index;
>
> =A0/*
> =A0* We dont use pointers to save space.
> - * Small indexes [0 ... SFQ_SLOTS - 1] are 'pointers' to slots[] arr=
ay
> - * while following values [SFQ_SLOTS ... SFQ_SLOTS + SFQ_DEPTH - 1]
> + * Small indexes [0 ... SFQ_MAX_FLOWS - 1] are 'pointers' to slots[]=
 array
> + * while following values [SFQ_MAX_FLOWS ... SFQ_MAX_FLOWS + SFQ_MAX=
_DEPTH]
> =A0* are 'pointers' to dep[] array
> =A0*/
> =A0struct sfq_head {
> @@ -102,28 +104,38 @@ struct sfq_slot {
> =A0 =A0 =A0 =A0struct sk_buff =A0*skblist_next;
> =A0 =A0 =A0 =A0struct sk_buff =A0*skblist_prev;
> =A0 =A0 =A0 =A0sfq_index =A0 =A0 =A0 qlen; /* number of skbs in skbli=
st */
> - =A0 =A0 =A0 sfq_index =A0 =A0 =A0 next; /* next slot in sfq chain *=
/
> + =A0 =A0 =A0 sfq_index =A0 =A0 =A0 next; /* next slot in sfq RR chai=
n */
> =A0 =A0 =A0 =A0struct sfq_head dep; /* anchor in dep[] chains */
> =A0 =A0 =A0 =A0unsigned short =A0hash; /* hash value (index in ht[]) =
*/
> =A0 =A0 =A0 =A0short =A0 =A0 =A0 =A0 =A0 allot; /* credit for this sl=
ot */
> =A0};
>
> =A0struct sfq_sched_data {
> -/* Parameters */
> - =A0 =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 perturb_period;
> - =A0 =A0 =A0 unsigned int =A0 =A0quantum; =A0 =A0 =A0 =A0/* Allotmen=
t per round: MUST BE >=3D MTU */
> - =A0 =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 limit;
> +/* frequently used fields */
> + =A0 =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 limit; =A0 =A0 =A0 =A0 =A0/=
* limit of total number of packets in this qdisc */
> =A0 =A0 =A0 =A0unsigned int =A0 =A0divisor; =A0 =A0 =A0 =A0/* number =
of slots in hash table */
> -/* Variables */
> - =A0 =A0 =A0 struct tcf_proto *filter_list;
> - =A0 =A0 =A0 struct timer_list perturb_timer;
> + =A0 =A0 =A0 unsigned int =A0 =A0maxflows; =A0 =A0 =A0 /* number of =
flows in flows array */
> + =A0 =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 headdrop;
> + =A0 =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 maxdepth; =A0 =A0 =A0 /* li=
mit of packets per flow */
> +
> =A0 =A0 =A0 =A0u32 =A0 =A0 =A0 =A0 =A0 =A0 perturbation;
> + =A0 =A0 =A0 struct tcf_proto *filter_list;
> =A0 =A0 =A0 =A0sfq_index =A0 =A0 =A0 cur_depth; =A0 =A0 =A0/* depth o=
f longest slot */
> =A0 =A0 =A0 =A0unsigned short =A0scaled_quantum; /* SFQ_ALLOT_SIZE(qu=
antum) */
> =A0 =A0 =A0 =A0struct sfq_slot *tail; =A0 =A0 =A0 =A0 =A0/* current s=
lot in round */
> - =A0 =A0 =A0 sfq_index =A0 =A0 =A0 *ht; =A0 =A0 =A0 =A0 =A0 =A0/* Ha=
sh table (divisor slots) */
> - =A0 =A0 =A0 struct sfq_slot slots[SFQ_SLOTS];
> - =A0 =A0 =A0 struct sfq_head dep[SFQ_DEPTH]; /* Linked list of slots=
, indexed by depth */
> + =A0 =A0 =A0 sfq_index =A0 =A0 =A0 *ht; =A0 =A0 =A0 =A0 =A0 =A0/* Ha=
sh table ('divisor' slots) */
> + =A0 =A0 =A0 struct sfq_slot *slots; =A0 =A0 =A0 =A0 /* Flows table =
('maxflows' entries) */
> +
> + =A0 =A0 =A0 struct sfq_head dep[SFQ_MAX_DEPTH + 1];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 /* Linked lists of slots, indexed by depth
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0* dep[0] : list of unused flows
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0* dep[1] : list of flows with 1 packet
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0* dep[X] : list of flows with X packets
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0*/
> +
> + =A0 =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 perturb_period;
> + =A0 =A0 =A0 unsigned int =A0 =A0quantum; =A0 =A0 =A0 =A0/* Allotmen=
t per round: MUST BE >=3D MTU */
> + =A0 =A0 =A0 struct timer_list perturb_timer;
> =A0};
>
> =A0/*
> @@ -131,9 +143,9 @@ struct sfq_sched_data {
> =A0*/
> =A0static inline struct sfq_head *sfq_dep_head(struct sfq_sched_data =
*q, sfq_index val)
> =A0{
> - =A0 =A0 =A0 if (val < SFQ_SLOTS)


why not use q->maxflows here rather than SFQ_MAX_FLOWS ?

looking at sfq_change(), q->maxflows may be <=3D to SFQ_MAX_FLOWS

the initial creation of the slots array in sfq_init() uses q->maxflows.
q->maxflows is initialized to SFQ_DEFAULT_FLOWS which is / maybe less
than SFQ_MAX_FLOWS



> + =A0 =A0 =A0 if (val < SFQ_MAX_FLOWS)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return &q->slots[val].dep;
> - =A0 =A0 =A0 return &q->dep[val - SFQ_SLOTS];
> + =A0 =A0 =A0 return &q->dep[val - SFQ_MAX_FLOWS];
> =A0}
>
> =A0/*
> @@ -199,18 +211,19 @@ static unsigned int sfq_classify(struct sk_buff=
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
> @@ -275,6 +288,7 @@ static inline struct sk_buff *slot_dequeue_head(s=
truct sfq_slot *slot)
>
> =A0static inline void slot_queue_init(struct sfq_slot *slot)
> =A0{
> + =A0 =A0 =A0 memset(slot, 0, sizeof(*slot));
> =A0 =A0 =A0 =A0slot->skblist_prev =3D slot->skblist_next =3D (struct =
sk_buff *)slot;
> =A0}
>
> @@ -305,7 +319,7 @@ static unsigned int sfq_drop(struct Qdisc *sch)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0x =3D q->dep[d].next;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0slot =3D &q->slots[x];
> =A0drop:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb =3D slot_dequeue_tail(slot);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb =3D q->headdrop ? slot_dequeue_head=
(slot) : slot_dequeue_tail(slot);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0len =3D qdisc_pkt_len(skb);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sfq_dec(q, x);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kfree_skb(skb);
> @@ -349,16 +363,27 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *=
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
> + =A0 =A0 =A0 if (slot->qlen >=3D q->maxdepth) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct sk_buff *head;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!q->headdrop)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return qdisc_drop(skb, =
sch);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 head =3D slot_dequeue_head(slot);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sch->qstats.backlog -=3D qdisc_pkt_len(=
head);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 qdisc_drop(head, sch);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sch->qstats.backlog +=3D qdisc_pkt_len(=
skb);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 slot_queue_add(slot, skb);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NET_XMIT_CN;
> + =A0 =A0 =A0 }
>
> =A0 =A0 =A0 =A0sch->qstats.backlog +=3D qdisc_pkt_len(skb);
> =A0 =A0 =A0 =A0slot_queue_add(slot, skb);
> @@ -445,16 +470,18 @@ sfq_reset(struct Qdisc *sch)
> =A0* We dont use sfq_dequeue()/sfq_enqueue() because we dont want to =
change
> =A0* counters.
> =A0*/
> -static void sfq_rehash(struct sfq_sched_data *q)
> +static void sfq_rehash(struct Qdisc *sch)
> =A0{
> + =A0 =A0 =A0 struct sfq_sched_data *q =3D qdisc_priv(sch);
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
> @@ -474,10 +501,18 @@ static void sfq_rehash(struct sfq_sched_data *q=
)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0slot =3D &q->slots[x];
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (x =3D=3D SFQ_EMPTY_SLOT) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0x =3D q->dep[0].next; =
/* get a free slot */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (x >=3D SFQ_MAX_FLOW=
S) {
> +drop: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sch->qstats=
=2Ebacklog -=3D qdisc_pkt_len(skb);
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
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (slot->qlen >=3D q->maxdepth)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto drop;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0slot_queue_add(slot, skb);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sfq_inc(q, x);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (slot->qlen =3D=3D 1) { =A0 =A0 =A0=
 =A0 =A0/* The flow is new */
> @@ -491,6 +526,8 @@ static void sfq_rehash(struct sfq_sched_data *q)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0slot->allot =3D q->sca=
led_quantum;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
> + =A0 =A0 =A0 sch->q.qlen -=3D dropped;
> + =A0 =A0 =A0 qdisc_tree_decrease_qlen(sch, dropped);
> =A0}
>
> =A0static void sfq_perturbation(unsigned long arg)
> @@ -502,7 +539,7 @@ static void sfq_perturbation(unsigned long arg)
> =A0 =A0 =A0 =A0spin_lock(root_lock);
> =A0 =A0 =A0 =A0q->perturbation =3D net_random();
> =A0 =A0 =A0 =A0if (!q->filter_list && q->tail)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 sfq_rehash(q);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sfq_rehash(sch);
> =A0 =A0 =A0 =A0spin_unlock(root_lock);
>
> =A0 =A0 =A0 =A0if (q->perturb_period)
> @@ -513,23 +550,39 @@ static int sfq_change(struct Qdisc *sch, struct=
 nlattr *opt)
> =A0{
> =A0 =A0 =A0 =A0struct sfq_sched_data *q =3D qdisc_priv(sch);
> =A0 =A0 =A0 =A0struct tc_sfq_qopt *ctl =3D nla_data(opt);
> + =A0 =A0 =A0 struct tc_sfq_qopt_v1 *ctl_v1 =3D NULL;
> =A0 =A0 =A0 =A0unsigned int qlen;
>
> =A0 =A0 =A0 =A0if (opt->nla_len < nla_attr_size(sizeof(*ctl)))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;
> -
> + =A0 =A0 =A0 if (opt->nla_len >=3D nla_attr_size(sizeof(*ctl_v1)))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ctl_v1 =3D nla_data(opt);
> =A0 =A0 =A0 =A0if (ctl->divisor &&
> =A0 =A0 =A0 =A0 =A0 =A0(!is_power_of_2(ctl->divisor) || ctl->divisor =
> 65536))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;
>
> =A0 =A0 =A0 =A0sch_tree_lock(sch);
> - =A0 =A0 =A0 q->quantum =3D ctl->quantum ? : psched_mtu(qdisc_dev(sc=
h));
> - =A0 =A0 =A0 q->scaled_quantum =3D SFQ_ALLOT_SIZE(q->quantum);
> + =A0 =A0 =A0 if (ctl->quantum) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 q->quantum =3D ctl->quantum;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 q->scaled_quantum =3D SFQ_ALLOT_SIZE(q-=
>quantum);
> + =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0q->perturb_period =3D ctl->perturb_period * HZ;
> - =A0 =A0 =A0 if (ctl->limit)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 q->limit =3D min_t(u32, ctl->limit, SFQ=
_DEPTH - 1);
> - =A0 =A0 =A0 if (ctl->divisor)
> + =A0 =A0 =A0 if (ctl->flows)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 q->maxflows =3D min_t(u32, ctl->flows, =
SFQ_MAX_FLOWS);
> + =A0 =A0 =A0 if (ctl->divisor) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0q->divisor =3D ctl->divisor;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 q->maxflows =3D min_t(u32, q->maxflows,=
 q->divisor);
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 if (ctl_v1) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ctl_v1->depth)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 q->maxdepth =3D min_t(u=
32, ctl_v1->depth, SFQ_MAX_DEPTH);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 q->headdrop =3D ctl_v1->headdrop;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 if (ctl->limit) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 q->limit =3D min_t(u32, ctl->limit, q->=
maxdepth * q->maxflows);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 q->maxflows =3D min_t(u32, q->maxflows,=
 q->limit);
> + =A0 =A0 =A0 }
> +
> =A0 =A0 =A0 =A0qlen =3D sch->q.qlen;
> =A0 =A0 =A0 =A0while (sch->q.qlen > q->limit)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sfq_drop(sch);
> @@ -571,6 +624,7 @@ static void sfq_destroy(struct Qdisc *sch)
> =A0 =A0 =A0 =A0q->perturb_period =3D 0;
> =A0 =A0 =A0 =A0del_timer_sync(&q->perturb_timer);
> =A0 =A0 =A0 =A0sfq_free(q->ht);
> + =A0 =A0 =A0 sfq_free(q->slots);
> =A0}
>
> =A0static int sfq_init(struct Qdisc *sch, struct nlattr *opt)
> @@ -582,15 +636,17 @@ static int sfq_init(struct Qdisc *sch, struct n=
lattr *opt)
> =A0 =A0 =A0 =A0q->perturb_timer.data =3D (unsigned long)sch;
> =A0 =A0 =A0 =A0init_timer_deferrable(&q->perturb_timer);
>
> - =A0 =A0 =A0 for (i =3D 0; i < SFQ_DEPTH; i++) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 q->dep[i].next =3D i + SFQ_SLOTS;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 q->dep[i].prev =3D i + SFQ_SLOTS;
> + =A0 =A0 =A0 for (i =3D 0; i < SFQ_MAX_DEPTH + 1; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 q->dep[i].next =3D i + SFQ_MAX_FLOWS;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 q->dep[i].prev =3D i + SFQ_MAX_FLOWS;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 q->limit =3D SFQ_DEPTH - 1;
> + =A0 =A0 =A0 q->limit =3D SFQ_MAX_DEPTH;
> + =A0 =A0 =A0 q->maxdepth =3D SFQ_MAX_DEPTH;
> =A0 =A0 =A0 =A0q->cur_depth =3D 0;
> =A0 =A0 =A0 =A0q->tail =3D NULL;
> =A0 =A0 =A0 =A0q->divisor =3D SFQ_DEFAULT_HASH_DIVISOR;
> + =A0 =A0 =A0 q->maxflows =3D SFQ_DEFAULT_FLOWS;
> =A0 =A0 =A0 =A0q->quantum =3D psched_mtu(qdisc_dev(sch));
> =A0 =A0 =A0 =A0q->scaled_quantum =3D SFQ_ALLOT_SIZE(q->quantum);
> =A0 =A0 =A0 =A0q->perturb_period =3D 0;
> @@ -603,14 +659,15 @@ static int sfq_init(struct Qdisc *sch, struct n=
lattr *opt)
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0q->ht =3D sfq_alloc(sizeof(q->ht[0]) * q->divisor);
> - =A0 =A0 =A0 if (!q->ht) {
> + =A0 =A0 =A0 q->slots =3D sfq_alloc(sizeof(q->slots[0]) * q->maxflow=
s);
> + =A0 =A0 =A0 if (!q->ht || !q->slots) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sfq_destroy(sch);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENOMEM;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0for (i =3D 0; i < q->divisor; i++)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0q->ht[i] =3D SFQ_EMPTY_SLOT;
>
> - =A0 =A0 =A0 for (i =3D 0; i < SFQ_SLOTS; i++) {
> + =A0 =A0 =A0 for (i =3D 0; i < q->maxflows; i++) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0slot_queue_init(&q->slots[i]);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sfq_link(q, i);
> =A0 =A0 =A0 =A0}
> @@ -625,14 +682,16 @@ static int sfq_dump(struct Qdisc *sch, struct s=
k_buff *skb)
> =A0{
> =A0 =A0 =A0 =A0struct sfq_sched_data *q =3D qdisc_priv(sch);
> =A0 =A0 =A0 =A0unsigned char *b =3D skb_tail_pointer(skb);
> - =A0 =A0 =A0 struct tc_sfq_qopt opt;
> -
> - =A0 =A0 =A0 opt.quantum =3D q->quantum;
> - =A0 =A0 =A0 opt.perturb_period =3D q->perturb_period / HZ;
> -
> - =A0 =A0 =A0 opt.limit =3D q->limit;
> - =A0 =A0 =A0 opt.divisor =3D q->divisor;
> - =A0 =A0 =A0 opt.flows =3D q->limit;
> + =A0 =A0 =A0 struct tc_sfq_qopt_v1 opt;
> +
> + =A0 =A0 =A0 memset(&opt, 0, sizeof(opt));
> + =A0 =A0 =A0 opt.v0.quantum =A0=3D q->quantum;
> + =A0 =A0 =A0 opt.v0.perturb_period =3D q->perturb_period / HZ;
> + =A0 =A0 =A0 opt.v0.limit =A0 =A0=3D q->limit;
> + =A0 =A0 =A0 opt.v0.divisor =A0=3D q->divisor;
> + =A0 =A0 =A0 opt.v0.flows =A0 =A0=3D q->maxflows;
> + =A0 =A0 =A0 opt.depth =A0 =A0 =A0 =3D q->maxdepth;
> + =A0 =A0 =A0 opt.headdrop =A0 =A0=3D q->headdrop;
>
> =A0 =A0 =A0 =A0NLA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html



--=20
-----------------------------------------------------------------------=
---------
