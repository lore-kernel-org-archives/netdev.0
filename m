From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH] net_sched: sfq: add optional RED on top of SFQ
Date: Fri, 6 Jan 2012 17:56:51 +0100
Message-ID: <CAA93jw7024Ejncj_Gjg9jcQF=HTERkc0dSCrVKrv7XJfELryow@mail.gmail.com>
References: <1325766316.2415.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<CAA93jw4ndMg-4BnhmspxgcXYdozu5+YX9VJgtHJ3N5HVX1b4yg@mail.gmail.com>
	<1325770777.2415.35.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1325867504.2911.23.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Kathleen Nichols <nichols@pollere.com>,
	Jim Gettys <jg@freedesktop.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:48022 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758790Ab2AFQ4w convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2012 11:56:52 -0500
Received: by iaeh11 with SMTP id h11so2867384iae.19
        for <netdev@vger.kernel.org>; Fri, 06 Jan 2012 08:56:51 -0800 (PST)
In-Reply-To: <1325867504.2911.23.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 6, 2012 at 5:31 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Adds an optional Random Early Detection on each SFQ flow queue.

netperf -t TCP_RR is useful
-t TCP_MAERTS will be interesting.
simultaneous ping?

> Traditional SFQ limits count of packets, while RED permits to also
> control number of bytes per flow, and adds ECN capability as well.
>
> 1) We dont handle the idle time management in this RED implementation=
,
> since each 'new flow' begins with a null qavg. We really want to addr=
ess
> backlogged flows.
>
> 2) if headdrop is selected, we try to ecn mark first packet instead o=
f
> currently enqueued packet. This gives faster feedback for tcp flows
> compared to traditional RED [ marking the last packet in queue ]
>
> Example of use :
>
> tc qdisc add dev $DEV parent 1:1 handle 10: est 1sec 4sec sfq \
> =A0 =A0 =A0 =A0limit 3000 headdrop flows 512 divisor 16384 \
> =A0 =A0 =A0 =A0redflowlimit 100000 min 8000 max 60000 probability 0.2=
0 ecn
>
> qdisc sfq 10: parent 1:1 limit 3000p quantum 1514b depth 127 headdrop
> flows 512/16384 divisor 16384
> =A0ewma 6 min 8000b max 60000b probability 0.2 ecn
> =A0prob_mark 0 prob_mark_head 4876 prob_drop 6131
> =A0forced_mark 0 forced_mark_head 0 forced_drop 0
> =A0Sent 1175211782 bytes 777537 pkt (dropped 6131, overlimits 11007
> requeues 0)
> =A0rate 99483Kbit 8219pps backlog 689392b 456p requeues 0
>
> In this test, with 64 netperf TCP_STREAM sessions, 50% using ECN enab=
led
> flows, we can see number of packets CE marked is smaller than number =
of
> drops (for non ECN flows)
>
> If same test is run, without RED, we can check backlog is much bigger=
=2E
>
> qdisc sfq 10: parent 1:1 limit 3000p quantum 1514b depth 127 headdrop
> flows 512/16384 divisor 16384
> =A0Sent 1148683617 bytes 795006 pkt (dropped 0, overlimits 0 requeues=
 0)
> =A0rate 98429Kbit 8521pps backlog 1221290b 841p requeues 0
>
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Stephen Hemminger <shemminger@vyatta.com>
> CC: Dave Taht <dave.taht@gmail.com>
> ---
> =A0include/linux/pkt_sched.h | =A0 20 ++++
> =A0include/net/red.h =A0 =A0 =A0 =A0 | =A0 =A03
> =A0net/sched/sch_sfq.c =A0 =A0 =A0 | =A0146 +++++++++++++++++++++++++=
+++++++----
> =A03 files changed, 152 insertions(+), 17 deletions(-)
>
> diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
> index 8f1b928..0d5b793 100644
> --- a/include/linux/pkt_sched.h
> +++ b/include/linux/pkt_sched.h
> @@ -162,10 +162,30 @@ struct tc_sfq_qopt {
> =A0 =A0 =A0 =A0unsigned =A0 =A0 =A0 =A0flows; =A0 =A0 =A0 =A0 =A0/* M=
aximal number of flows =A0*/
> =A0};
>
> +struct tc_sfqred_stats {
> + =A0 =A0 =A0 __u32 =A0 =A0 =A0 =A0 =A0 prob_drop; =A0 =A0 =A0/* Earl=
y drops, below max threshold */
> + =A0 =A0 =A0 __u32 =A0 =A0 =A0 =A0 =A0 forced_drop; =A0 =A0/* Early =
drops, after max threshold */
> + =A0 =A0 =A0 __u32 =A0 =A0 =A0 =A0 =A0 prob_mark; =A0 =A0 =A0/* Mark=
ed packets, below max threshold */
> + =A0 =A0 =A0 __u32 =A0 =A0 =A0 =A0 =A0 forced_mark; =A0 =A0/* Marked=
 packets, after max threshold */
> + =A0 =A0 =A0 __u32 =A0 =A0 =A0 =A0 =A0 prob_mark_head; /* Marked pac=
kets, below max threshold */
> + =A0 =A0 =A0 __u32 =A0 =A0 =A0 =A0 =A0 forced_mark_head;/* Marked pa=
ckets, after max threshold */
> +};
> +
> =A0struct tc_sfq_qopt_v1 {
> =A0 =A0 =A0 =A0struct tc_sfq_qopt v0;
> =A0 =A0 =A0 =A0unsigned int =A0 =A0depth; =A0 =A0 =A0 =A0 =A0/* max n=
umber of packets per flow */
> =A0 =A0 =A0 =A0unsigned int =A0 =A0headdrop;
> +/* SFQRED parameters */
> + =A0 =A0 =A0 __u32 =A0 =A0 =A0 =A0 =A0 limit; =A0 =A0 =A0 =A0 =A0/* =
HARD maximal flow queue length (bytes) */
> + =A0 =A0 =A0 __u32 =A0 =A0 =A0 =A0 =A0 qth_min; =A0 =A0 =A0 =A0/* Mi=
n average length threshold (bytes) */
> + =A0 =A0 =A0 __u32 =A0 =A0 =A0 =A0 =A0 qth_max; =A0 =A0 =A0 =A0/* Ma=
x average length threshold (bytes) */
> + =A0 =A0 =A0 unsigned char =A0 Wlog; =A0 =A0 =A0 =A0 =A0 /* log(W) =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 */
> + =A0 =A0 =A0 unsigned char =A0 Plog; =A0 =A0 =A0 =A0 =A0 /* log(P_ma=
x/(qth_max-qth_min)) */
> + =A0 =A0 =A0 unsigned char =A0 Scell_log; =A0 =A0 =A0/* cell size fo=
r idle damping */
> + =A0 =A0 =A0 unsigned char =A0 flags;
> + =A0 =A0 =A0 __u32 =A0 =A0 =A0 =A0 =A0 max_P; =A0 =A0 =A0 =A0 =A0/* =
probability, high resolution */
> +/* SFQRED stats */
> + =A0 =A0 =A0 struct tc_sfqred_stats stats;
> =A0};
>
>
> diff --git a/include/net/red.h b/include/net/red.h
> index baab385..28068ec 100644
> --- a/include/net/red.h
> +++ b/include/net/red.h
> @@ -199,7 +199,8 @@ static inline void red_set_parms(struct red_parms=
 *p,
> =A0 =A0 =A0 =A0p->Scell_log =A0 =A0=3D Scell_log;
> =A0 =A0 =A0 =A0p->Scell_max =A0 =A0=3D (255 << Scell_log);
>
> - =A0 =A0 =A0 memcpy(p->Stab, stab, sizeof(p->Stab));
> + =A0 =A0 =A0 if (stab)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcpy(p->Stab, stab, sizeof(p->Stab));
> =A0}
>
> =A0static inline int red_is_idling(const struct red_vars *v)
> diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
> index 0a79640..67494ae 100644
> --- a/net/sched/sch_sfq.c
> +++ b/net/sched/sch_sfq.c
> @@ -24,6 +24,7 @@
> =A0#include <net/netlink.h>
> =A0#include <net/pkt_sched.h>
> =A0#include <net/flow_keys.h>
> +#include <net/red.h>
>
>
> =A0/* =A0 =A0 Stochastic Fairness Queuing algorithm.
> @@ -108,24 +109,30 @@ struct sfq_slot {
> =A0 =A0 =A0 =A0struct sfq_head dep; /* anchor in dep[] chains */
> =A0 =A0 =A0 =A0unsigned short =A0hash; /* hash value (index in ht[]) =
*/
> =A0 =A0 =A0 =A0short =A0 =A0 =A0 =A0 =A0 allot; /* credit for this sl=
ot */
> +
> + =A0 =A0 =A0 unsigned int =A0 =A0backlog;
> + =A0 =A0 =A0 struct red_vars vars;
> =A0};
>
> =A0struct sfq_sched_data {
> =A0/* frequently used fields */
> =A0 =A0 =A0 =A0int =A0 =A0 =A0 =A0 =A0 =A0 limit; =A0 =A0 =A0 =A0 =A0=
/* limit of total number of packets in this qdisc */
> =A0 =A0 =A0 =A0unsigned int =A0 =A0divisor; =A0 =A0 =A0 =A0/* number =
of slots in hash table */
> - =A0 =A0 =A0 unsigned int =A0 =A0maxflows; =A0 =A0 =A0 /* number of =
flows in flows array */
> - =A0 =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 headdrop;
> - =A0 =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 maxdepth; =A0 =A0 =A0 /* li=
mit of packets per flow */
> + =A0 =A0 =A0 u8 =A0 =A0 =A0 =A0 =A0 =A0 =A0headdrop;
> + =A0 =A0 =A0 u8 =A0 =A0 =A0 =A0 =A0 =A0 =A0maxdepth; =A0 =A0 =A0 /* =
limit of packets per flow */
>
> =A0 =A0 =A0 =A0u32 =A0 =A0 =A0 =A0 =A0 =A0 perturbation;
> - =A0 =A0 =A0 struct tcf_proto *filter_list;
> - =A0 =A0 =A0 sfq_index =A0 =A0 =A0 cur_depth; =A0 =A0 =A0/* depth of=
 longest slot */
> + =A0 =A0 =A0 u8 =A0 =A0 =A0 =A0 =A0 =A0 =A0cur_depth; =A0 =A0 =A0/* =
depth of longest slot */
> + =A0 =A0 =A0 u8 =A0 =A0 =A0 =A0 =A0 =A0 =A0flags;
> =A0 =A0 =A0 =A0unsigned short =A0scaled_quantum; /* SFQ_ALLOT_SIZE(qu=
antum) */
> - =A0 =A0 =A0 struct sfq_slot *tail; =A0 =A0 =A0 =A0 =A0/* current sl=
ot in round */
> + =A0 =A0 =A0 struct tcf_proto *filter_list;
> =A0 =A0 =A0 =A0sfq_index =A0 =A0 =A0 *ht; =A0 =A0 =A0 =A0 =A0 =A0/* H=
ash table ('divisor' slots) */
> =A0 =A0 =A0 =A0struct sfq_slot *slots; =A0 =A0 =A0 =A0 /* Flows table=
 ('maxflows' entries) */
>
> + =A0 =A0 =A0 struct red_parms *red_parms;
> + =A0 =A0 =A0 struct tc_sfqred_stats stats;
> + =A0 =A0 =A0 struct sfq_slot *tail; =A0 =A0 =A0 =A0 =A0/* current sl=
ot in round */
> +
> =A0 =A0 =A0 =A0struct sfq_head dep[SFQ_MAX_DEPTH + 1];
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0/* Linked lists of slots, indexed by depth
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 * dep[0] : list of unused flows
> @@ -133,6 +140,7 @@ struct sfq_sched_data {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 * dep[X] : list of flows with X packets
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 */
>
> + =A0 =A0 =A0 unsigned int =A0 =A0maxflows; =A0 =A0 =A0 /* number of =
flows in flows array */
> =A0 =A0 =A0 =A0int =A0 =A0 =A0 =A0 =A0 =A0 perturb_period;
> =A0 =A0 =A0 =A0unsigned int =A0 =A0quantum; =A0 =A0 =A0 =A0/* Allotme=
nt per round: MUST BE >=3D MTU */
> =A0 =A0 =A0 =A0struct timer_list perturb_timer;
> @@ -321,6 +329,7 @@ static unsigned int sfq_drop(struct Qdisc *sch)
> =A0drop:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb =3D q->headdrop ? slot_dequeue_hea=
d(slot) : slot_dequeue_tail(slot);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0len =3D qdisc_pkt_len(skb);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 slot->backlog -=3D len;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sfq_dec(q, x);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kfree_skb(skb);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sch->q.qlen--;
> @@ -341,6 +350,23 @@ drop:
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> +/* Is ECN parameter configured */
> +static int sfq_prob_mark(const struct sfq_sched_data *q)
> +{
> + =A0 =A0 =A0 return q->flags & TC_RED_ECN;
> +}
> +
> +/* Should packets over max threshold just be marked */
> +static int sfq_hard_mark(const struct sfq_sched_data *q)
> +{
> + =A0 =A0 =A0 return (q->flags & (TC_RED_ECN | TC_RED_HARDDROP)) =3D=3D=
 TC_RED_ECN;
> +}
> +
> +static int sfq_headdrop(const struct sfq_sched_data *q)
> +{
> + =A0 =A0 =A0 return q->headdrop;
> +}
> +
> =A0static int
> =A0sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
> =A0{
> @@ -349,6 +375,8 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sc=
h)
> =A0 =A0 =A0 =A0sfq_index x, qlen;
> =A0 =A0 =A0 =A0struct sfq_slot *slot;
> =A0 =A0 =A0 =A0int uninitialized_var(ret);
> + =A0 =A0 =A0 struct sk_buff *head;
> + =A0 =A0 =A0 int delta;
>
> =A0 =A0 =A0 =A0hash =3D sfq_classify(skb, sch, &ret);
> =A0 =A0 =A0 =A0if (hash =3D=3D 0) {
> @@ -368,24 +396,75 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *=
sch)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0q->ht[hash] =3D x;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0slot =3D &q->slots[x];
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0slot->hash =3D hash;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 slot->backlog =3D 0; /* should already =
be 0 anyway... */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 red_set_vars(&slot->vars);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto enqueue;
> =A0 =A0 =A0 =A0}
> + =A0 =A0 =A0 if (q->red_parms) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 slot->vars.qavg =3D red_calc_qavg_no_id=
le_time(q->red_parms,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &slot->vars,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 slot->backlog);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 switch (red_action(q->red_parms,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
&slot->vars,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
slot->vars.qavg)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case RED_DONT_MARK:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>
> - =A0 =A0 =A0 if (slot->qlen >=3D q->maxdepth) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct sk_buff *head;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case RED_PROB_MARK:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sch->qstats.overlimits+=
+;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (sfq_prob_mark(q)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* We k=
now we have at least one packet in queue */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (sfq=
_headdrop(q) &&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 INET_ECN_set_ce(slot->skblist_next)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 q->stats.prob_mark_head++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (INE=
T_ECN_set_ce(skb)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 q->stats.prob_mark++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 q->stats.prob_drop++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto congestion_drop;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case RED_HARD_MARK:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sch->qstats.overlimits+=
+;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (sfq_hard_mark(q)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* We k=
now we have at least one packet in queue */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (sfq=
_headdrop(q) &&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 INET_ECN_set_ce(slot->skblist_next)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 q->stats.forced_mark_head++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (INE=
T_ECN_set_ce(skb)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 q->stats.forced_mark++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 q->stats.forced_drop++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto congestion_drop;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!q->headdrop)
> + =A0 =A0 =A0 if (slot->qlen >=3D q->maxdepth) {
> +congestion_drop:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!sfq_headdrop(q))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return qdisc_drop(skb,=
 sch);
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* We know we have at least one packet =
in queue */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0head =3D slot_dequeue_head(slot);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 sch->qstats.backlog -=3D qdisc_pkt_len(=
head);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 delta =3D qdisc_pkt_len(head) - qdisc_p=
kt_len(skb);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sch->qstats.backlog -=3D delta;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 slot->backlog -=3D delta;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0qdisc_drop(head, sch);
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 sch->qstats.backlog +=3D qdisc_pkt_len(=
skb);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0slot_queue_add(slot, skb);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return NET_XMIT_CN;
> =A0 =A0 =A0 =A0}
>
> +enqueue:
> =A0 =A0 =A0 =A0sch->qstats.backlog +=3D qdisc_pkt_len(skb);
> + =A0 =A0 =A0 slot->backlog +=3D qdisc_pkt_len(skb);
> =A0 =A0 =A0 =A0slot_queue_add(slot, skb);
> =A0 =A0 =A0 =A0sfq_inc(q, x);
> =A0 =A0 =A0 =A0if (slot->qlen =3D=3D 1) { =A0 =A0 =A0 =A0 =A0/* The f=
low is new */
> @@ -396,6 +475,7 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sc=
h)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0slot->next =3D q->tail=
->next;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0q->tail->next =3D x;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* We could use a bigger initial quantu=
m for new flows */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0slot->allot =3D q->scaled_quantum;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0if (++sch->q.qlen <=3D q->limit)
> @@ -439,7 +519,7 @@ next_slot:
> =A0 =A0 =A0 =A0qdisc_bstats_update(sch, skb);
> =A0 =A0 =A0 =A0sch->q.qlen--;
> =A0 =A0 =A0 =A0sch->qstats.backlog -=3D qdisc_pkt_len(skb);
> -
> + =A0 =A0 =A0 slot->backlog -=3D qdisc_pkt_len(skb);
> =A0 =A0 =A0 =A0/* Is the slot empty? */
> =A0 =A0 =A0 =A0if (slot->qlen =3D=3D 0) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0q->ht[slot->hash] =3D SFQ_EMPTY_SLOT;
> @@ -490,6 +570,8 @@ static void sfq_rehash(struct Qdisc *sch)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sfq_dec(q, i);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__skb_queue_tail(&list=
, skb);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 slot->backlog =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 red_set_vars(&slot->vars);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0q->ht[slot->hash] =3D SFQ_EMPTY_SLOT;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0q->tail =3D NULL;
> @@ -514,6 +596,11 @@ drop: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0sch->qstats.backlog -=3D qdisc_pkt_len(skb);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (slot->qlen >=3D q->maxdepth)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto drop;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0slot_queue_add(slot, skb);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (q->red_parms)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 slot->vars.qavg =3D red=
_calc_qavg(q->red_parms,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &slot->vars,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 slot->backlog);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 slot->backlog +=3D qdisc_pkt_len(skb);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sfq_inc(q, x);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (slot->qlen =3D=3D 1) { =A0 =A0 =A0=
 =A0 =A0/* The flow is new */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (q->tail =3D=3D NUL=
L) { =A0/* It is the first flow */
> @@ -552,6 +639,7 @@ static int sfq_change(struct Qdisc *sch, struct n=
lattr *opt)
> =A0 =A0 =A0 =A0struct tc_sfq_qopt *ctl =3D nla_data(opt);
> =A0 =A0 =A0 =A0struct tc_sfq_qopt_v1 *ctl_v1 =3D NULL;
> =A0 =A0 =A0 =A0unsigned int qlen;
> + =A0 =A0 =A0 struct red_parms *p =3D NULL;
>
> =A0 =A0 =A0 =A0if (opt->nla_len < nla_attr_size(sizeof(*ctl)))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;
> @@ -560,7 +648,11 @@ static int sfq_change(struct Qdisc *sch, struct =
nlattr *opt)
> =A0 =A0 =A0 =A0if (ctl->divisor &&
> =A0 =A0 =A0 =A0 =A0 =A0(!is_power_of_2(ctl->divisor) || ctl->divisor =
> 65536))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;
> -
> + =A0 =A0 =A0 if (ctl_v1 && ctl_v1->qth_min) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 p =3D kmalloc(sizeof(*p), GFP_KERNEL);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!p)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> + =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0sch_tree_lock(sch);
> =A0 =A0 =A0 =A0if (ctl->quantum) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0q->quantum =3D ctl->quantum;
> @@ -576,6 +668,16 @@ static int sfq_change(struct Qdisc *sch, struct =
nlattr *opt)
> =A0 =A0 =A0 =A0if (ctl_v1) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (ctl_v1->depth)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0q->maxdepth =3D min_t(=
u32, ctl_v1->depth, SFQ_MAX_DEPTH);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (p) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 swap(q->red_parms, p);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 red_set_parms(q->red_pa=
rms,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 ctl_v1->qth_min, ctl_v1->qth_max,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 ctl_v1->Wlog,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 ctl_v1->Plog, ctl_v1->Scell_log,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 NULL,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 ctl_v1->max_P);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 q->flags =3D ctl_v1->flags;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0q->headdrop =3D ctl_v1->headdrop;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0if (ctl->limit) {
> @@ -594,6 +696,7 @@ static int sfq_change(struct Qdisc *sch, struct n=
lattr *opt)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0q->perturbation =3D net_random();
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0sch_tree_unlock(sch);
> + =A0 =A0 =A0 kfree(p);
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> @@ -625,6 +728,7 @@ static void sfq_destroy(struct Qdisc *sch)
> =A0 =A0 =A0 =A0del_timer_sync(&q->perturb_timer);
> =A0 =A0 =A0 =A0sfq_free(q->ht);
> =A0 =A0 =A0 =A0sfq_free(q->slots);
> + =A0 =A0 =A0 kfree(q->red_parms);
> =A0}
>
> =A0static int sfq_init(struct Qdisc *sch, struct nlattr *opt)
> @@ -683,6 +787,7 @@ static int sfq_dump(struct Qdisc *sch, struct sk_=
buff *skb)
> =A0 =A0 =A0 =A0struct sfq_sched_data *q =3D qdisc_priv(sch);
> =A0 =A0 =A0 =A0unsigned char *b =3D skb_tail_pointer(skb);
> =A0 =A0 =A0 =A0struct tc_sfq_qopt_v1 opt;
> + =A0 =A0 =A0 struct red_parms *p =3D q->red_parms;
>
> =A0 =A0 =A0 =A0memset(&opt, 0, sizeof(opt));
> =A0 =A0 =A0 =A0opt.v0.quantum =A0=3D q->quantum;
> @@ -693,6 +798,17 @@ static int sfq_dump(struct Qdisc *sch, struct sk=
_buff *skb)
> =A0 =A0 =A0 =A0opt.depth =A0 =A0 =A0 =3D q->maxdepth;
> =A0 =A0 =A0 =A0opt.headdrop =A0 =A0=3D q->headdrop;
>
> + =A0 =A0 =A0 if (p) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 opt.qth_min =A0 =A0 =3D p->qth_min >> p=
->Wlog;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 opt.qth_max =A0 =A0 =3D p->qth_max >> p=
->Wlog;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 opt.Wlog =A0 =A0 =A0 =A0=3D p->Wlog;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 opt.Plog =A0 =A0 =A0 =A0=3D p->Plog;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 opt.Scell_log =A0 =3D p->Scell_log;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 opt.max_P =A0 =A0 =A0 =3D p->max_P;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 memcpy(&opt.stats, &q->stats, sizeof(opt.stats));
> + =A0 =A0 =A0 opt.flags =A0 =A0 =A0 =3D q->flags;
> +
> =A0 =A0 =A0 =A0NLA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
>
> =A0 =A0 =A0 =A0return skb->len;
> @@ -747,15 +863,13 @@ static int sfq_dump_class_stats(struct Qdisc *s=
ch, unsigned long cl,
> =A0 =A0 =A0 =A0sfq_index idx =3D q->ht[cl - 1];
> =A0 =A0 =A0 =A0struct gnet_stats_queue qs =3D { 0 };
> =A0 =A0 =A0 =A0struct tc_sfq_xstats xstats =3D { 0 };
> - =A0 =A0 =A0 struct sk_buff *skb;
>
> =A0 =A0 =A0 =A0if (idx !=3D SFQ_EMPTY_SLOT) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0const struct sfq_slot *slot =3D &q->sl=
ots[idx];
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0xstats.allot =3D slot->allot << SFQ_AL=
LOT_SHIFT;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0qs.qlen =3D slot->qlen;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 slot_queue_walk(slot, skb)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 qs.backlog +=3D qdisc_p=
kt_len(skb);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 qs.backlog =3D slot->backlog;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0if (gnet_stats_copy_queue(d, &qs) < 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -1;
>
>



--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
=46R Tel: 0638645374
http://www.bufferbloat.net
