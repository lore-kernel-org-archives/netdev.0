From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [RFC] sched: QFQ - quick fair queue scheduler
Date: Sat, 8 Jan 2011 10:56:33 +0800
Message-ID: <AANLkTi=pqZ3CwLTAZnhd-cyQNj8OSeBHsP_bFiH3hJ-_@mail.gmail.com>
References: <20110106195614.20dbc402@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Fabio Checconi <fabio@gandalf.sssup.it>,
	netdev@vger.kernel.org, Luigi Rizzo <rizzo@iet.unipi.it>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:48232 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751671Ab1AHC44 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jan 2011 21:56:56 -0500
Received: by fxm20 with SMTP id 20so17484048fxm.19
        for <netdev@vger.kernel.org>; Fri, 07 Jan 2011 18:56:54 -0800 (PST)
In-Reply-To: <20110106195614.20dbc402@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 7, 2011 at 11:56 AM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> This is an implementation of the Quick Fair Queue scheduler developed
> by Fabio Checconi and Luigi Rizzo. The same algorithm is already impl=
emented in ipfw
> in FreeBSD. Fabio had an earlier version developed on Linux, I just
> did some cleanup, and backporting of FreeBSD version.
>
> For more information see web page: http://info.iet.unipi.it/~luigi/qf=
q/
> and Google tech talk: http://www.youtube.com/watch?v=3Dr8vBmybeKlE
>
> This is for inspection at this point, barely tested.
>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>
> ---
> Patch against net-next-2.6.
> Configuration may get patch fuzz because of testing CHOKe in
> same tree.
>
> =A0include/linux/pkt_sched.h | =A0 14
> =A0net/sched/Kconfig =A0 =A0 =A0 =A0 | =A0 11
> =A0net/sched/Makefile =A0 =A0 =A0 =A0| =A0 =A01
> =A0net/sched/sch_qfq.c =A0 =A0 =A0 | 1012 +++++++++++++++++++++++++++=
+++++++++++++++++++
> =A04 files changed, 1038 insertions(+)
>
> --- a/include/linux/pkt_sched.h 2011-01-05 09:01:33.268032043 -0800
> +++ b/include/linux/pkt_sched.h 2011-01-05 23:17:20.637390255 -0800
> @@ -481,4 +481,18 @@ struct tc_drr_stats {
> =A0 =A0 =A0 =A0__u32 =A0 deficit;
> =A0};
>
> +/* QFQ */
> +enum {
> + =A0 =A0 =A0 TCA_QFQ_WEIGHT,
> + =A0 =A0 =A0 TCA_QFQ_LMAX,
> + =A0 =A0 =A0 __TCA_QFQ_MAX
> +};
> +
> +#define TCA_QFQ_MAX =A0 =A0(__TCA_QFQ_MAX - 1)
> +
> +struct tc_qfq_stats {
> + =A0 =A0 =A0 __u32 weight;
> + =A0 =A0 =A0 __u32 lmax;
> +};
> +
> =A0#endif
> --- a/net/sched/Kconfig 2011-01-05 09:01:33.280032462 -0800
> +++ b/net/sched/Kconfig 2011-01-05 23:17:20.637390255 -0800
> @@ -216,6 +216,17 @@ config NET_SCH_CHOKE
> =A0 =A0 =A0 =A0 =A0To compile this code as a module, choose M here: t=
he
> =A0 =A0 =A0 =A0 =A0module will be called sch_choke.
>
> +config NET_SCH_QFQ
> + =A0 =A0 =A0 =A0tristate "Quick Fair Queueing Scheduler (QFQ)"
> + =A0 =A0 =A0 help
> + =A0 =A0 =A0 =A0 Say Y here if you want to use the Quick Fair Queuei=
ng Scheduler (QFQ)
> + =A0 =A0 =A0 =A0 packet scheduling algorithm.
> +
> + =A0 =A0 =A0 =A0 To compile this driver as a module, choose M here: =
the module
> + =A0 =A0 =A0 =A0 will be called sch_qfq.
> +
> + =A0 =A0 =A0 =A0 If unsure, say N.
> +
> =A0config NET_SCH_INGRESS
> =A0 =A0 =A0 =A0tristate "Ingress Qdisc"
> =A0 =A0 =A0 =A0depends on NET_CLS_ACT
> --- a/net/sched/Makefile =A0 =A0 =A0 =A02011-01-05 09:01:33.284032598=
 -0800
> +++ b/net/sched/Makefile =A0 =A0 =A0 =A02011-01-05 23:17:20.645389829=
 -0800
> @@ -32,6 +32,7 @@ obj-$(CONFIG_NET_SCH_MULTIQ) =A0+=3D sch_mult
> =A0obj-$(CONFIG_NET_SCH_ATM) =A0 =A0 =A0+=3D sch_atm.o
> =A0obj-$(CONFIG_NET_SCH_NETEM) =A0 =A0+=3D sch_netem.o
> =A0obj-$(CONFIG_NET_SCH_DRR) =A0 =A0 =A0+=3D sch_drr.o
> +obj-$(CONFIG_NET_SCH_QFQ) =A0 =A0 =A0+=3D sch_qfq.o
> =A0obj-$(CONFIG_NET_SCH_CHOKE) =A0 =A0+=3D sch_choke.o
> =A0obj-$(CONFIG_NET_CLS_U32) =A0 =A0 =A0+=3D cls_u32.o
> =A0obj-$(CONFIG_NET_CLS_ROUTE4) =A0 +=3D cls_route.o
> --- /dev/null =A0 1970-01-01 00:00:00.000000000 +0000
> +++ b/net/sched/sch_qfq.c =A0 =A0 =A0 2011-01-06 12:51:28.498280327 -=
0800
> @@ -0,0 +1,1125 @@
> +/*
> + * net/sched/sch_qfq.c =A0 =A0 =A0 =A0 Quick Fair Queueing Scheduler=
=2E
> + *
> + * Copyright (c) 2009 Fabio Checconi, Luigi Rizzo, and Paolo Valente=
=2E
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License
> + * version 2 as published by the Free Software Foundation.
> + */
> +
> +#include <linux/module.h>
> +#include <linux/init.h>
> +#include <linux/bitops.h>
> +#include <linux/errno.h>
> +#include <linux/netdevice.h>
> +#include <linux/pkt_sched.h>
> +#include <net/sch_generic.h>
> +#include <net/pkt_sched.h>
> +#include <net/pkt_cls.h>
> +
> +/* =A0Quick Fair Queueing
> + =A0 =A0=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +
> + =A0 =A0Sources:
> + =A0 =A0Fabio Checconi and Scuola Superiore and S. Anna
> + =A0 =A0and Paolo Valente and Luigi Riz "QFQ: Efficient Packet Sched=
uling
> + =A0 =A0with Tight Bandwidth Distribution Guarantees", SIGCOMM 2010
> +
> + =A0 =A0See also:
> + =A0 =A0http://retis.sssup.it/~fabio/linux/qfq/
> + */
> +
> +/*
> +
> + =A0Virtual time computations.
> +
> + =A0S, F and V are all computed in fixed point arithmetic with
> + =A0FRAC_BITS decimal bits.
> +
> + =A0QFQ_MAX_INDEX is the maximum index allowed for a group. We need
> + =A0 =A0 =A0 one bit per index.
> + =A0QFQ_MAX_WSHIFT is the maximum power of two supported as a weight=
=2E
> +
> + =A0The layout of the bits is as below:
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 [ MTU_SHIFT ][ =A0 =A0 =A0FRAC_=
BITS =A0 =A0]
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 [ MAX_INDEX =A0 =A0][ MIN_SLOT_=
SHIFT ]
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0^.__=
grp->index =3D 0
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*.__=
grp->slot_shift
> +
> + =A0where MIN_SLOT_SHIFT is derived by difference from the others.
> +
> + =A0The max group index corresponds to Lmax/w_min, where
> + =A0Lmax=3D1<<MTU_SHIFT, w_min =3D 1 .
> + =A0From this, and knowing how many groups (MAX_INDEX) we want,
> + =A0we can derive the shift corresponding to each group.
> +
> + =A0Because we often need to compute
> + =A0 =A0 =A0 F =3D S + len/w_i =A0and V =3D V + len/wsum
> + =A0instead of storing w_i store the value
> + =A0 =A0 =A0 inv_w =3D (1<<FRAC_BITS)/w_i
> + =A0so we can do F =3D S + len * inv_w * wsum.
> + =A0We use W_TOT in the formulas so we can easily move between
> + =A0static and adaptive weight sum.
> +
> + =A0The per-scheduler-instance data contain all the data structures
> + =A0for the scheduler: bitmaps and bucket lists.
> +
> + */
> +
> +/*
> + * Maximum number of consecutive slots occupied by backlogged classe=
s
> + * inside a group.
> + */
> +#define QFQ_MAX_SLOTS =A032
> +
> +/*
> + * Shifts used for class<->group mapping. =A0We allow class weights =
that are
> + * in the range [1, 2^MAX_WSHIFT], and we try to map each class i to=
 the
> + * group with the smallest index that can support the L_i / r_i conf=
igured
> + * for the class.
> + *
> + * grp->index is the index of the group; and grp->slot_shift
> + * is the shift for the corresponding (scaled) sigma_i.
> + */
> +#define QFQ_MAX_INDEX =A0 =A0 =A0 =A0 =A019
> +#define QFQ_MAX_WSHIFT =A0 =A0 =A0 =A0 16
> +
> +#define =A0 =A0 =A0 =A0QFQ_MAX_WEIGHT =A0 =A0 =A0 =A0 =A0(1<<QFQ_MAX=
_WSHIFT)
> +#define QFQ_MAX_WSUM =A0 =A0 =A0 =A0 =A0 (2*QFQ_MAX_WEIGHT)
> +
> +#define FRAC_BITS =A0 =A0 =A0 =A0 =A0 =A0 =A030 =A0 =A0 =A0/* fixed =
point arithmetic */
> +#define ONE_FP =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1UL << FRAC_BITS)
> +#define IWSUM =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(ONE_FP/QFQ_MAX_WSU=
M)
> +
> +#define QFQ_MTU_SHIFT =A0 =A0 =A0 =A0 =A011
> +#define QFQ_MIN_SLOT_SHIFT =A0 =A0 (FRAC_BITS + QFQ_MTU_SHIFT - QFQ_=
MAX_INDEX)
> +
> +/*
> + * Possible group states. =A0These values are used as indexes for th=
e bitmaps
> + * array of struct qfq_queue.
> + */
> +enum qfq_state { ER, IR, EB, IB, QFQ_MAX_STATE };
> +
> +struct qfq_group;
> +
> +struct qfq_class {
> + =A0 =A0 =A0 struct Qdisc_class_common common;
> +
> + =A0 =A0 =A0 unsigned int refcnt;
> + =A0 =A0 =A0 unsigned int filter_cnt;
> +
> + =A0 =A0 =A0 struct gnet_stats_basic_packed bstats;
> + =A0 =A0 =A0 struct gnet_stats_queue qstats;
> + =A0 =A0 =A0 struct gnet_stats_rate_est rate_est;
> + =A0 =A0 =A0 struct Qdisc *qdisc;
> +
> + =A0 =A0 =A0 struct qfq_class *next; /* Link for the slot list. */
> + =A0 =A0 =A0 u64 S, F; =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* flow timestamp=
s (exact) */
> +
> + =A0 =A0 =A0 /* group we belong to. In principle we would need the i=
ndex,
> + =A0 =A0 =A0 =A0* which is log_2(lmax/weight), but we never referenc=
e it
> + =A0 =A0 =A0 =A0* directly, only the group.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 struct qfq_group *grp;
> +
> + =A0 =A0 =A0 /* these are copied from the flowset. */
> + =A0 =A0 =A0 u32 =A0 =A0 inv_w; =A0 =A0 =A0 =A0 =A0/* ONE_FP/weight =
*/
> + =A0 =A0 =A0 u32 =A0 =A0 lmax; =A0 =A0 =A0 =A0 =A0 /* Max packet siz=
e for this flow. */
> +};
> +
> +struct qfq_group {
> + =A0 =A0 =A0 uint64_t S, F; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* gr=
oup timestamps (approx). */
> + =A0 =A0 =A0 unsigned int slot_shift; =A0 =A0 =A0 =A0/* Slot shift. =
*/
> + =A0 =A0 =A0 unsigned int index; =A0 =A0 =A0 =A0 =A0 =A0 /* Group in=
dex. */
> + =A0 =A0 =A0 unsigned int front; =A0 =A0 =A0 =A0 =A0 =A0 /* Index of=
 the front slot. */
> + =A0 =A0 =A0 unsigned long full_slots; =A0 =A0 =A0 /* non-empty slot=
s */
> +
> + =A0 =A0 =A0 /* Array of RR lists of active classes. */
> + =A0 =A0 =A0 struct qfq_class *slots[QFQ_MAX_SLOTS];
> +};
> +
> +struct qfq_sched {
> + =A0 =A0 =A0 struct tcf_proto *filter_list;
> + =A0 =A0 =A0 struct Qdisc_class_hash clhash;
> +
> + =A0 =A0 =A0 uint64_t =A0 =A0 =A0 =A0V; =A0 =A0 =A0 =A0 =A0 =A0 =A0/=
* Precise virtual time. */
> + =A0 =A0 =A0 u32 wsum; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /=
* weight sum */
> +
> + =A0 =A0 =A0 unsigned long bitmaps[QFQ_MAX_STATE]; =A0 =A0 =A0 /* Gr=
oup bitmaps. */
> + =A0 =A0 =A0 struct qfq_group groups[QFQ_MAX_INDEX + 1]; /* The grou=
ps. */
> +};
> +
> +static struct qfq_class *qfq_find_class(struct Qdisc *sch, u32 class=
id)
> +{
> + =A0 =A0 =A0 struct qfq_sched *q =3D qdisc_priv(sch);
> + =A0 =A0 =A0 struct Qdisc_class_common *clc;
> +
> + =A0 =A0 =A0 clc =3D qdisc_class_find(&q->clhash, classid);
> + =A0 =A0 =A0 if (clc =3D=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> + =A0 =A0 =A0 return container_of(clc, struct qfq_class, common);
> +}
> +
> +static void qfq_purge_queue(struct qfq_class *cl)
> +{
> + =A0 =A0 =A0 unsigned int len =3D cl->qdisc->q.qlen;
> +
> + =A0 =A0 =A0 qdisc_reset(cl->qdisc);
> + =A0 =A0 =A0 qdisc_tree_decrease_qlen(cl->qdisc, len);
> +}
> +
> +static const struct nla_policy qfq_policy[TCA_QFQ_MAX + 1] =3D {
> + =A0 =A0 =A0 [TCA_QFQ_WEIGHT] =3D { .type =3D NLA_U32 },
> + =A0 =A0 =A0 [TCA_QFQ_LMAX] =3D { .type =3D NLA_U32 },
> +};
> +
> +/*
> + * Calculate a flow index, given its weight and maximum packet lengt=
h.
> + * index =3D log_2(maxlen/weight) but we need to apply the scaling.
> + * This is used only once at flow creation.
> + */
> +static int qfq_calc_index(u32 inv_w, unsigned int maxlen)
> +{
> + =A0 =A0 =A0 u64 slot_size =3D (u64)maxlen *inv_w;
> + =A0 =A0 =A0 unsigned long size_map;
> + =A0 =A0 =A0 int index =3D 0;
> +
> + =A0 =A0 =A0 size_map =3D slot_size >> QFQ_MIN_SLOT_SHIFT;
> + =A0 =A0 =A0 if (!size_map)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> +
> + =A0 =A0 =A0 index =3D __fls(size_map) + 1; =A0 =A0/* basically a lo=
g_2 */
> + =A0 =A0 =A0 index -=3D !(slot_size - (1ULL << (index + QFQ_MIN_SLOT=
_SHIFT - 1)));
> +
> + =A0 =A0 =A0 if (index < 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 index =3D 0;
> +out:
> + =A0 =A0 =A0 pr_debug("qfq calc_index: W =3D %lu, L =3D %u, I =3D %d=
\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(unsigned long) ONE_FP/inv_w, maxlen=
, index);
> +
> + =A0 =A0 =A0 return index;
> +}
> +
> +static int qfq_change_class(struct Qdisc *sch, u32 classid, u32 pare=
ntid,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct nlattr *=
*tca, unsigned long *arg)
> +{
> + =A0 =A0 =A0 struct qfq_sched *q =3D qdisc_priv(sch);
> + =A0 =A0 =A0 struct qfq_class *cl =3D (struct qfq_class *)*arg;
> + =A0 =A0 =A0 struct nlattr *tb[TCA_QFQ_MAX + 1];
> + =A0 =A0 =A0 u32 weight, lmax, inv_w;
> + =A0 =A0 =A0 int i, err;
> +
> + =A0 =A0 =A0 if (tca[TCA_OPTIONS] =3D=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> +
> + =A0 =A0 =A0 err =3D nla_parse_nested(tb, TCA_QFQ_MAX, tca[TCA_OPTIO=
NS], qfq_policy);
> + =A0 =A0 =A0 if (err < 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return err;
> +
> + =A0 =A0 =A0 if (tb[TCA_QFQ_WEIGHT]) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 weight =3D nla_get_u32(tb[TCA_QFQ_WEIGH=
T]);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!weight || weight > (1UL << QFQ_MAX=
_WSHIFT)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_notice("qfq: invalid=
 weight %u\n", weight);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 } else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 weight =3D 1;
> +
> + =A0 =A0 =A0 inv_w =3D ONE_FP / weight;
> + =A0 =A0 =A0 weight =3D ONE_FP / inv_w;
> + =A0 =A0 =A0 if (q->wsum + weight > QFQ_MAX_WSUM) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_notice("qfq: total weight out of ran=
ge (%u + %u)\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 weight, q->wsum);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (tb[TCA_QFQ_LMAX]) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lmax =3D nla_get_u32(tb[TCA_QFQ_LMAX]);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!lmax || lmax > (1UL << QFQ_MTU_SHI=
=46T)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_notice("qfq: invalid=
 max length %u\n", lmax);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 } else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lmax =3D 1UL << QFQ_MTU_SHIFT;
> +
> + =A0 =A0 =A0 if (cl !=3D NULL) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (tca[TCA_RATE]) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D gen_replace_est=
imator(&cl->bstats, &cl->rate_est,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 qdisc_root_sleeping_lock(sch),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tca[TCA_RATE]);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (err)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return =
err;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sch_tree_lock(sch);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (tb[TCA_QFQ_WEIGHT]) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 q->wsum =3D weight - ON=
E_FP / cl->inv_w;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cl->inv_w =3D inv_w;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sch_tree_unlock(sch);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 cl =3D kzalloc(sizeof(struct qfq_class), GFP_KERNEL);
> + =A0 =A0 =A0 if (cl =3D=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOBUFS;
> +
> + =A0 =A0 =A0 cl->refcnt =3D 1;
> + =A0 =A0 =A0 cl->common.classid =3D classid;
> + =A0 =A0 =A0 cl->lmax =3D lmax;
> + =A0 =A0 =A0 cl->inv_w =3D inv_w;
> + =A0 =A0 =A0 i =3D qfq_calc_index(cl->inv_w, cl->lmax);
> +
> + =A0 =A0 =A0 cl->grp =3D &q->groups[i];
> + =A0 =A0 =A0 q->wsum +=3D weight;
> +
> + =A0 =A0 =A0 cl->qdisc =3D qdisc_create_dflt(sch->dev_queue,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 &pfifo_qdisc_ops, classid);
> + =A0 =A0 =A0 if (cl->qdisc =3D=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cl->qdisc =3D &noop_qdisc;
> +
> + =A0 =A0 =A0 if (tca[TCA_RATE]) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D gen_new_estimator(&cl->bstats, =
&cl->rate_est,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 qdisc_root_sleeping_lock(sch),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 tca[TCA_RATE]);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (err) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 qdisc_destroy(cl->qdisc=
);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(cl);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return err;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 sch_tree_lock(sch);
> + =A0 =A0 =A0 qdisc_class_hash_insert(&q->clhash, &cl->common);
> + =A0 =A0 =A0 sch_tree_unlock(sch);
> +
> + =A0 =A0 =A0 qdisc_class_hash_grow(sch, &q->clhash);
> +
> + =A0 =A0 =A0 *arg =3D (unsigned long)cl;
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static void qfq_destroy_class(struct Qdisc *sch, struct qfq_class *c=
l)
> +{
> + =A0 =A0 =A0 struct qfq_sched *q =3D (struct qfq_sched *)sch;
> +
> + =A0 =A0 =A0 if (cl->inv_w) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 q->wsum -=3D ONE_FP / cl->inv_w;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cl->inv_w =3D 0;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 gen_kill_estimator(&cl->bstats, &cl->rate_est);
> + =A0 =A0 =A0 qdisc_destroy(cl->qdisc);
> + =A0 =A0 =A0 kfree(cl);
> +}
> +
> +static int qfq_delete_class(struct Qdisc *sch, unsigned long arg)
> +{
> + =A0 =A0 =A0 struct qfq_sched *q =3D qdisc_priv(sch);
> + =A0 =A0 =A0 struct qfq_class *cl =3D (struct qfq_class *)arg;
> +
> + =A0 =A0 =A0 if (cl->filter_cnt > 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EBUSY;
> +
> + =A0 =A0 =A0 sch_tree_lock(sch);
> +
> + =A0 =A0 =A0 qfq_purge_queue(cl);
> + =A0 =A0 =A0 qdisc_class_hash_remove(&q->clhash, &cl->common);
> +
> + =A0 =A0 =A0 if (--cl->refcnt =3D=3D 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 qfq_destroy_class(sch, cl);
> +
> + =A0 =A0 =A0 sch_tree_unlock(sch);
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static unsigned long qfq_get_class(struct Qdisc *sch, u32 classid)
> +{
> + =A0 =A0 =A0 struct qfq_class *cl =3D qfq_find_class(sch, classid);
> +
> + =A0 =A0 =A0 if (cl !=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cl->refcnt++;
> +
> + =A0 =A0 =A0 return (unsigned long)cl;
> +}
> +
> +static void qfq_put_class(struct Qdisc *sch, unsigned long arg)
> +{
> + =A0 =A0 =A0 struct qfq_class *cl =3D (struct qfq_class *)arg;
> +
> + =A0 =A0 =A0 if (--cl->refcnt =3D=3D 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 qfq_destroy_class(sch, cl);
> +}
> +
> +static struct tcf_proto **qfq_tcf_chain(struct Qdisc *sch, unsigned =
long cl)
> +{
> + =A0 =A0 =A0 struct qfq_sched *q =3D qdisc_priv(sch);
> +
> + =A0 =A0 =A0 if (cl)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> +
> + =A0 =A0 =A0 return &q->filter_list;
> +}
> +
> +static unsigned long qfq_bind_tcf(struct Qdisc *sch, unsigned long p=
arent,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32=
 classid)
> +{
> + =A0 =A0 =A0 struct qfq_class *cl =3D qfq_find_class(sch, classid);
> +
> + =A0 =A0 =A0 if (cl !=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cl->filter_cnt++;
> +
> + =A0 =A0 =A0 return (unsigned long)cl;
> +}
> +
> +static void qfq_unbind_tcf(struct Qdisc *sch, unsigned long arg)
> +{
> + =A0 =A0 =A0 struct qfq_class *cl =3D (struct qfq_class *)arg;
> +
> + =A0 =A0 =A0 cl->filter_cnt--;
> +}
> +
> +static int qfq_graft_class(struct Qdisc *sch, unsigned long arg,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct Qdisc *ne=
w, struct Qdisc **old)
> +{
> + =A0 =A0 =A0 struct qfq_class *cl =3D (struct qfq_class *)arg;
> +
> + =A0 =A0 =A0 if (new =3D=3D NULL) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 new =3D qdisc_create_dflt(sch->dev_queu=
e,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 &pfifo_qdisc_ops, cl->common.classid);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (new =3D=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 new =3D &noop_qdisc;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 sch_tree_lock(sch);
> + =A0 =A0 =A0 qfq_purge_queue(cl);
> + =A0 =A0 =A0 *old =3D cl->qdisc;
> + =A0 =A0 =A0 cl->qdisc =3D new;
> + =A0 =A0 =A0 sch_tree_unlock(sch);
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static struct Qdisc *qfq_class_leaf(struct Qdisc *sch, unsigned long=
 arg)
> +{
> + =A0 =A0 =A0 struct qfq_class *cl =3D (struct qfq_class *)arg;
> +
> + =A0 =A0 =A0 return cl->qdisc;
> +}
> +
> +static int qfq_dump_class(struct Qdisc *sch, unsigned long arg,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct sk_buff *skb=
, struct tcmsg *tcm)
> +{
> + =A0 =A0 =A0 struct qfq_class *cl =3D (struct qfq_class *)arg;
> + =A0 =A0 =A0 struct nlattr *nest;
> +
> + =A0 =A0 =A0 tcm->tcm_parent =3D TC_H_ROOT;
> + =A0 =A0 =A0 tcm->tcm_handle =3D cl->common.classid;
> + =A0 =A0 =A0 tcm->tcm_info =A0 =3D cl->qdisc->handle;
> +
> + =A0 =A0 =A0 nest =3D nla_nest_start(skb, TCA_OPTIONS);
> + =A0 =A0 =A0 if (nest =3D=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto nla_put_failure;
> + =A0 =A0 =A0 NLA_PUT_U32(skb, TCA_QFQ_WEIGHT, ONE_FP/cl->inv_w);
> + =A0 =A0 =A0 NLA_PUT_U32(skb, TCA_QFQ_LMAX, cl->lmax);
> + =A0 =A0 =A0 return nla_nest_end(skb, nest);
> +
> +nla_put_failure:
> + =A0 =A0 =A0 nla_nest_cancel(skb, nest);
> + =A0 =A0 =A0 return -EMSGSIZE;
> +}
> +
> +static int qfq_dump_class_stats(struct Qdisc *sch, unsigned long arg=
,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct =
gnet_dump *d)
> +{
> + =A0 =A0 =A0 struct qfq_class *cl =3D (struct qfq_class *)arg;
> + =A0 =A0 =A0 struct tc_qfq_stats xstats;
> +
> + =A0 =A0 =A0 memset(&xstats, 0, sizeof(xstats));
> +
> + =A0 =A0 =A0 xstats.weight =3D ONE_FP/cl->inv_w;
> + =A0 =A0 =A0 xstats.lmax =3D cl->lmax;
> +
> + =A0 =A0 =A0 if (gnet_stats_copy_basic(d, &cl->bstats) < 0 ||
> + =A0 =A0 =A0 =A0 =A0 gnet_stats_copy_rate_est(d, NULL, &cl->rate_est=
) < 0 ||
> + =A0 =A0 =A0 =A0 =A0 gnet_stats_copy_queue(d, &cl->qdisc->qstats) < =
0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -1;
> +
> + =A0 =A0 =A0 return gnet_stats_copy_app(d, &xstats, sizeof(xstats));
> +}
> +
> +static void qfq_walk(struct Qdisc *sch, struct qdisc_walker *arg)
> +{
> + =A0 =A0 =A0 struct qfq_sched *q =3D qdisc_priv(sch);
> + =A0 =A0 =A0 struct qfq_class *cl;
> + =A0 =A0 =A0 struct hlist_node *n;
> + =A0 =A0 =A0 unsigned int i;
> +
> + =A0 =A0 =A0 if (arg->stop)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 for (i =3D 0; i < q->clhash.hashsize; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 hlist_for_each_entry(cl, n, &q->clhash.=
hash[i], common.hnode) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (arg->count < arg->s=
kip) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 arg->co=
unt++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continu=
e;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (arg->fn(sch, (unsig=
ned long)cl, arg) < 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 arg->st=
op =3D 1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 arg->count++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +}
> +
> +static struct qfq_class *qfq_classify(struct sk_buff *skb, struct Qd=
isc *sch,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 int *qerr)
> +{
> + =A0 =A0 =A0 struct qfq_sched *q =3D qdisc_priv(sch);
> + =A0 =A0 =A0 struct qfq_class *cl;
> + =A0 =A0 =A0 struct tcf_result res;
> + =A0 =A0 =A0 int result;
> +
> + =A0 =A0 =A0 if (TC_H_MAJ(skb->priority ^ sch->handle) =3D=3D 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cl =3D qfq_find_class(sch, skb->priorit=
y);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (cl !=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return cl;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 *qerr =3D NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
> + =A0 =A0 =A0 result =3D tc_classify(skb, q->filter_list, &res);
> + =A0 =A0 =A0 if (result >=3D 0) {
> +#ifdef CONFIG_NET_CLS_ACT
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 switch (result) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case TC_ACT_QUEUED:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case TC_ACT_STOLEN:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *qerr =3D NET_XMIT_SUCC=
ESS | __NET_XMIT_STOLEN;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case TC_ACT_SHOT:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +#endif
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cl =3D (struct qfq_class *)res.class;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (cl =3D=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cl =3D qfq_find_class(s=
ch, res.classid);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return cl;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return NULL;
> +}
> +
> +/* Generic comparison function, handling wraparound. */
> +static inline int qfq_gt(u64 a, u64 b)
> +{
> + =A0 =A0 =A0 return (s64)(a - b) > 0;
> +}
> +
> +/* Round a precise timestamp to its slotted value. */
> +static inline u64 qfq_round_down(u64 ts, unsigned int shift)
> +{
> + =A0 =A0 =A0 return ts & ~((1ULL << shift) - 1);
> +}
> +
> +/* return the pointer to the group with lowest index in the bitmap *=
/
> +static inline struct qfq_group *qfq_ffs(struct qfq_sched *q,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 unsigned long bitmap)
> +{
> + =A0 =A0 =A0 int index =3D __ffs(bitmap); // zero-based
> + =A0 =A0 =A0 return &q->groups[index];
> +}
> +/* Calculate a mask to mimic what would be ffs_from(). */
> +static inline unsigned long mask_from(unsigned long bitmap, int from=
)
> +{
> + =A0 =A0 =A0 return bitmap & ~((1UL << from) - 1);
> +}
> +
> +/*
> + * The state computation relies on ER=3D0, IR=3D1, EB=3D2, IB=3D3
> + * First compute eligibility comparing grp->S, q->V,
> + * then check if someone is blocking us and possibly add EB
> + */
> +static int qfq_calc_state(struct qfq_sched *q, const struct qfq_grou=
p *grp)
> +{
> + =A0 =A0 =A0 /* if S > V we are not eligible */
> + =A0 =A0 =A0 unsigned int state =3D qfq_gt(grp->S, q->V);
> + =A0 =A0 =A0 unsigned long mask =3D mask_from(q->bitmaps[ER], grp->i=
ndex);
> + =A0 =A0 =A0 struct qfq_group *next;
> +
> + =A0 =A0 =A0 if (mask) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 next =3D qfq_ffs(q, mask);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (qfq_gt(grp->F, next->F))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 state |=3D EB;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return state;
> +}
> +
> +
> +/*
> + * In principle
> + * =A0 =A0 q->bitmaps[dst] |=3D q->bitmaps[src] & mask;
> + * =A0 =A0 q->bitmaps[src] &=3D ~mask;
> + * but we should make sure that src !=3D dst
> + */
> +static inline void qfq_move_groups(struct qfq_sched *q, unsigned lon=
g mask,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
int src, int dst)
> +{
> + =A0 =A0 =A0 q->bitmaps[dst] |=3D q->bitmaps[src] & mask;
> + =A0 =A0 =A0 q->bitmaps[src] &=3D ~mask;
> +}
> +
> +static void qfq_unblock_groups(struct qfq_sched *q, int index, u64 o=
ld_F)
> +{
> + =A0 =A0 =A0 unsigned long mask =3D mask_from(q->bitmaps[ER], index =
+ 1);
> + =A0 =A0 =A0 struct qfq_group *next;
> +
> + =A0 =A0 =A0 if (mask) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 next =3D qfq_ffs(q, mask);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!qfq_gt(next->F, old_F))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 mask =3D (1UL << index) - 1;
> + =A0 =A0 =A0 qfq_move_groups(q, mask, EB, ER);
> + =A0 =A0 =A0 qfq_move_groups(q, mask, IB, IR);
> +}
> +
> +/*
> + * perhaps
> + *
> + =A0 =A0 =A0 old_V ^=3D q->V;
> + =A0 =A0 =A0 old_V >>=3D QFQ_MIN_SLOT_SHIFT;
> + =A0 =A0 =A0 if (old_V) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ...
> + =A0 =A0 =A0 }
> + *
> + */
> +static void qfq_make_eligible(struct qfq_sched *q, u64 old_V)
> +{
> + =A0 =A0 =A0 unsigned long vslot =3D q->V >> QFQ_MIN_SLOT_SHIFT;
> + =A0 =A0 =A0 unsigned long old_vslot =3D old_V >> QFQ_MIN_SLOT_SHIFT=
;
> +
> + =A0 =A0 =A0 if (vslot !=3D old_vslot) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long mask =3D (1UL << fls(vslo=
t ^ old_vslot)) - 1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 qfq_move_groups(q, mask, IR, ER);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 qfq_move_groups(q, mask, IB, EB);
> + =A0 =A0 =A0 }
> +}
> +
> +/*
> + * XXX we should make sure that slot becomes less than 32.
> + * This is guaranteed by the input values.
> + * roundedS is always cl->S rounded on grp->slot_shift bits.
> + */
> +static void qfq_slot_insert(struct qfq_group *grp, struct qfq_class =
*cl,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
u64 roundedS)
> +{
> + =A0 =A0 =A0 u64 slot =3D (roundedS - grp->S) >> grp->slot_shift;
> + =A0 =A0 =A0 unsigned int i =3D (grp->front + slot) % QFQ_MAX_SLOTS;
> +
> + =A0 =A0 =A0 cl->next =3D grp->slots[i];
> + =A0 =A0 =A0 grp->slots[i] =3D cl;
> + =A0 =A0 =A0 __set_bit(slot, &grp->full_slots);
> +}
> +
> +/*
> + * remove the entry from the slot
> + */
> +static void qfq_front_slot_remove(struct qfq_group *grp)
> +{
> + =A0 =A0 =A0 struct qfq_class **h =3D &grp->slots[grp->front];
> +
> + =A0 =A0 =A0 *h =3D (*h)->next;
> + =A0 =A0 =A0 if (!*h)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __clear_bit(0, &grp->full_slots);
> +}
> +
> +/*
> + * Returns the first full queue in a group. As a side effect,
> + * adjust the bucket list so the first non-empty bucket is at
> + * position 0 in full_slots.
> + */
> +static struct qfq_class *qfq_slot_scan(struct qfq_group *grp)
> +{
> + =A0 =A0 =A0 unsigned int i;
> +
> + =A0 =A0 =A0 pr_debug("qfq slot_scan: grp %u full %#lx\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0grp->index, grp->full_slots);
> +
> + =A0 =A0 =A0 if (!grp->full_slots)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> +
> + =A0 =A0 =A0 i =3D __ffs(grp->full_slots); =A0/* zero based */
> + =A0 =A0 =A0 if (i > 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 grp->front =3D (grp->front + i) % QFQ_M=
AX_SLOTS;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 grp->full_slots >>=3D i;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return grp->slots[grp->front];
> +}
> +
> +/*
> + * adjust the bucket list. When the start time of a group decreases,
> + * we move the index down (modulo QFQ_MAX_SLOTS) so we don't need to
> + * move the objects. The mask of occupied slots must be shifted
> + * because we use ffs() to find the first non-empty slot.
> + * This covers decreases in the group's start time, but what about
> + * increases of the start time ?
> + * Here too we should make sure that i is less than 32
> + */
> +static void qfq_slot_rotate(struct qfq_group *grp, u64 roundedS)
> +{
> + =A0 =A0 =A0 unsigned int i =3D (grp->S - roundedS) >> grp->slot_shi=
ft;
> +
> + =A0 =A0 =A0 grp->full_slots <<=3D i;
> + =A0 =A0 =A0 grp->front =3D (grp->front - i) % QFQ_MAX_SLOTS;
> +}
> +
> +static void qfq_update_eligible(struct qfq_sched *q, u64 old_V)
> +{
> + =A0 =A0 =A0 struct qfq_group *grp;
> + =A0 =A0 =A0 unsigned long ineligible;
> +
> + =A0 =A0 =A0 ineligible =3D q->bitmaps[IR] | q->bitmaps[IB];
> + =A0 =A0 =A0 if (ineligible) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!q->bitmaps[ER]) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 grp =3D qfq_ffs(q, inel=
igible);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (qfq_gt(grp->S, q->V=
))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 q->V =3D=
 grp->S;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 qfq_make_eligible(q, old_V);
> + =A0 =A0 =A0 }
> +}
> +
> +/* What is length of next packet in queue (0 if queue is empty) */
> +static unsigned int qdisc_peek_len(struct Qdisc *sch)
> +{
> + =A0 =A0 =A0 struct sk_buff *skb;
> +
> + =A0 =A0 =A0 skb =3D sch->ops->peek(sch);
> + =A0 =A0 =A0 return skb ? qdisc_pkt_len(skb) : 0;
> +}
> +
> +/*
> + * Updates the class, returns true if also the group needs to be upd=
ated.
> + */
> +static bool qfq_update_class(struct qfq_group *grp, struct qfq_class=
 *cl)
> +{
> + =A0 =A0 =A0 unsigned int len =3D qdisc_peek_len(cl->qdisc);
> +
> + =A0 =A0 =A0 cl->S =3D cl->F;
> + =A0 =A0 =A0 if (!len)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 qfq_front_slot_remove(grp); =A0 =A0 /* =
queue is empty */
> + =A0 =A0 =A0 else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 u64 roundedS;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cl->F =3D cl->S + (u64)len * cl->inv_w;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 roundedS =3D qfq_round_down(cl->S, grp-=
>slot_shift);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (roundedS =3D=3D grp->S)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return false;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 qfq_front_slot_remove(grp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 qfq_slot_insert(grp, cl, roundedS);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return true;
> +}
> +
> +static struct sk_buff *qfq_dequeue(struct Qdisc *sch)
> +{
> + =A0 =A0 =A0 struct qfq_sched *q =3D qdisc_priv(sch);
> + =A0 =A0 =A0 struct qfq_group *grp;
> + =A0 =A0 =A0 struct qfq_class *cl;
> + =A0 =A0 =A0 struct sk_buff *skb;
> + =A0 =A0 =A0 unsigned int len;
> + =A0 =A0 =A0 u64 old_V;
> +
> + =A0 =A0 =A0 if (!q->bitmaps[ER])
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> +
> + =A0 =A0 =A0 grp =3D qfq_ffs(q, q->bitmaps[ER]);
> +
> + =A0 =A0 =A0 cl =3D grp->slots[grp->front];
> + =A0 =A0 =A0 skb =3D qdisc_dequeue_peeked(cl->qdisc);
> + =A0 =A0 =A0 if (!skb) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 WARN_ONCE(1, "qfq_dequeue: non-workcons=
erving leaf\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 sch->q.qlen--;
> +
> + =A0 =A0 =A0 old_V =3D q->V;
> + =A0 =A0 =A0 len =3D qdisc_pkt_len(skb);
> + =A0 =A0 =A0 q->V +=3D (u64)len * IWSUM;
> + =A0 =A0 =A0 pr_debug("qfq enqueue: len %u F %lld now %lld\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0len, (unsigned long long) cl->F, (un=
signed long long) q->V);
> +
> + =A0 =A0 =A0 if (qfq_update_class(grp, cl)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 u64 old_F =3D grp->F;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cl =3D qfq_slot_scan(grp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!cl)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __clear_bit(grp->index,=
 &q->bitmaps[ER]);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u64 roundedS =3D qfq_ro=
und_down(cl->S, grp->slot_shift);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned int s;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (grp->S =3D=3D round=
edS)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto sk=
ip_unblock;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 grp->S =3D roundedS;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 grp->F =3D roundedS + (=
2ULL << grp->slot_shift);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __clear_bit(grp->index,=
 &q->bitmaps[ER]);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 s =3D qfq_calc_state(q,=
 grp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __set_bit(grp->index, &=
q->bitmaps[s]);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 qfq_unblock_groups(q, grp->index, old_F=
);
> + =A0 =A0 =A0 }
> +
> +skip_unblock:
> + =A0 =A0 =A0 qfq_update_eligible(q, old_V);
> +
> + =A0 =A0 =A0 return skb;
> +}
> +
> +/*
> + * Assign a reasonable start time for a new flow k in group i.
> + * Admissible values for \hat(F) are multiples of \sigma_i
> + * no greater than V+\sigma_i . Larger values mean that
> + * we had a wraparound so we consider the timestamp to be stale.
> + *
> + * If F is not stale and F >=3D V then we set S =3D F.
> + * Otherwise we should assign S =3D V, but this may violate
> + * the ordering in ER. So, if we have groups in ER, set S to
> + * the F_j of the first group j which would be blocking us.
> + * We are guaranteed not to move S backward because
> + * otherwise our group i would still be blocked.
> + */
> +static void qfq_update_start(struct qfq_sched *q, struct qfq_class *=
cl)
> +{
> + =A0 =A0 =A0 unsigned long mask;
> + =A0 =A0 =A0 uint32_t limit, roundedF;
> + =A0 =A0 =A0 int slot_shift =3D cl->grp->slot_shift;
> +
> + =A0 =A0 =A0 roundedF =3D qfq_round_down(cl->F, slot_shift);
> + =A0 =A0 =A0 limit =3D qfq_round_down(q->V, slot_shift) + (1UL << sl=
ot_shift);
> +
> + =A0 =A0 =A0 if (!qfq_gt(cl->F, q->V) || qfq_gt(roundedF, limit)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* timestamp was stale */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mask =3D mask_from(q->bitmaps[ER], cl->=
grp->index);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mask) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct qfq_group *next =
=3D qfq_ffs(q, mask);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (qfq_gt(roundedF, ne=
xt->F)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cl->S =3D=
 next->F;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cl->S =3D q->V;
> + =A0 =A0 =A0 } else { /* timestamp is not stale */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cl->S =3D cl->F;
> + =A0 =A0 =A0 }
> +}
> +
> +static int qfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
> +{
> + =A0 =A0 =A0 struct qfq_sched *q =3D qdisc_priv(sch);
> + =A0 =A0 =A0 struct qfq_group *grp;
> + =A0 =A0 =A0 struct qfq_class *cl;
> + =A0 =A0 =A0 unsigned int len;
> + =A0 =A0 =A0 int err;
> + =A0 =A0 =A0 u64 roundedS;
> + =A0 =A0 =A0 int s;
> +
> + =A0 =A0 =A0 cl =3D qfq_classify(skb, sch, &err);
> + =A0 =A0 =A0 if (cl =3D=3D NULL || cl->qdisc->q.qlen > 80) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (err & __NET_XMIT_BYPASS)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sch->qstats.drops++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree_skb(skb);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return err;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 len =3D qdisc_pkt_len(skb);
> + =A0 =A0 =A0 err =3D qdisc_enqueue(skb, cl->qdisc);
> + =A0 =A0 =A0 if (unlikely(err !=3D NET_XMIT_SUCCESS)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (net_xmit_drop_count(err)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cl->qstats.drops++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sch->qstats.drops++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return err;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 cl->bstats.packets +=3D skb_is_gso(skb)?skb_shinfo(skb)=
->gso_segs:1;

Hmm, there is no other packets schedulers which account packets in
this way. Which one is better? I am not sure. And in this patch,
qstats.drops isn't maintained in the same way. Would these two be
consistent.

> + =A0 =A0 =A0 cl->bstats.bytes +=3D qdisc_pkt_len(skb);
> +
> + =A0 =A0 =A0 sch->q.qlen++;
> + =A0 =A0 =A0 sch->bstats.packets +=3D skb_is_gso(skb)?skb_shinfo(skb=
)->gso_segs:1;
> + =A0 =A0 =A0 sch->bstats.bytes +=3D qdisc_pkt_len(skb);
> +
> + =A0 =A0 =A0 if (qdisc_peek_head(sch) !=3D skb)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return err;

I suspect that it is wrong.

Here is the fake code from the paper:


5 i f ( f low . queue . head !=3D pkt )
6 return ; // Flow already backlogged, we are don

So the correct code should be:
    if (qdisc_peek_head(cl->qdisc) !=3D skb)
           return err;

However, we can't assume the cl->qdisc is work conserving, so the code
should be:
   if (cl->qdisc->q.qlen > 1)
          return err;

> +
> + =A0 =A0 =A0 /* If reach this point, queue q was idle */
> + =A0 =A0 =A0 grp =3D cl->grp;
> + =A0 =A0 =A0 qfq_update_start(q, cl);
> +
> + =A0 =A0 =A0 /* compute new finish time and rounded start. */
> + =A0 =A0 =A0 cl->F =3D cl->S + (u64)qdisc_pkt_len(skb) * cl->inv_w;
> + =A0 =A0 =A0 roundedS =3D qfq_round_down(cl->S, grp->slot_shift);
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* insert cl in the correct bucket.
> + =A0 =A0 =A0 =A0* If cl->S >=3D grp->S we don't need to adjust the
> + =A0 =A0 =A0 =A0* bucket list and simply go to the insertion phase.
> + =A0 =A0 =A0 =A0* Otherwise grp->S is decreasing, we must make room
> + =A0 =A0 =A0 =A0* in the bucket list, and also recompute the group s=
tate.
> + =A0 =A0 =A0 =A0* Finally, if there were no flows in this group and =
nobody
> + =A0 =A0 =A0 =A0* was in ER make sure to adjust V.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (grp->full_slots) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!qfq_gt(grp->S, cl->S))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto skip_update;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* create a slot for this cl->S */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 qfq_slot_rotate(grp, roundedS);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* group was surely ineligible, remove =
*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __clear_bit(grp->index, &q->bitmaps[IR]=
);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __clear_bit(grp->index, &q->bitmaps[IB]=
);
> + =A0 =A0 =A0 } else if (!q->bitmaps[ER] && qfq_gt(roundedS, q->V))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 q->V =3D roundedS;
> +
> + =A0 =A0 =A0 grp->S =3D roundedS;
> + =A0 =A0 =A0 grp->F =3D roundedS + (2ULL << grp->slot_shift);
> + =A0 =A0 =A0 s =3D qfq_calc_state(q, grp);
> + =A0 =A0 =A0 __set_bit(grp->index, &q->bitmaps[s]);
> +
> + =A0 =A0 =A0 pr_debug("qfq enqueue: new state %d %#lx S %lld F %lld =
V %lld\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0s, q->bitmaps[s],
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(unsigned long long) cl->S,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(unsigned long long) cl->F,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(unsigned long long) q->V);
> +
> +skip_update:
> + =A0 =A0 =A0 qfq_slot_insert(grp, cl, roundedS);
> +
> + =A0 =A0 =A0 return err;
> +}
> +
> +
> +static void qfq_slot_remove(struct qfq_sched *q, struct qfq_group *g=
rp,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct qfq_clas=
s *cl, struct qfq_class **pprev)
> +{
> + =A0 =A0 =A0 unsigned int i, offset;
> + =A0 =A0 =A0 u64 roundedS;
> +
> + =A0 =A0 =A0 roundedS =3D qfq_round_down(cl->S, grp->slot_shift);
> + =A0 =A0 =A0 offset =3D (roundedS - grp->S) >> grp->slot_shift;
> + =A0 =A0 =A0 i =3D (grp->front + offset) % QFQ_MAX_SLOTS;
> +
> + =A0 =A0 =A0 if (!pprev) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pprev =3D &grp->slots[i];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 while (*pprev && *pprev !=3D cl)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pprev =3D &(*pprev)->ne=
xt;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 *pprev =3D cl->next;
> + =A0 =A0 =A0 if (!grp->slots[i])
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __clear_bit(offset, &grp->full_slots);
> +}
> +
> +/*
> + * called to forcibly destroy a queue.
> + * If the queue is not in the front bucket, or if it has
> + * other queues in the front bucket, we can simply remove
> + * the queue with no other side effects.
> + * Otherwise we must propagate the event up.
> + */
> +static void qfq_deactivate_class(struct qfq_sched *q, struct qfq_cla=
ss *cl,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0stru=
ct qfq_class **pprev)
> +{
> + =A0 =A0 =A0 struct qfq_group *grp =3D cl->grp;
> + =A0 =A0 =A0 unsigned long mask;
> + =A0 =A0 =A0 u64 roundedS;
> + =A0 =A0 =A0 int s;
> +
> + =A0 =A0 =A0 cl->F =3D cl->S;
> + =A0 =A0 =A0 qfq_slot_remove(q, grp, cl, pprev);
> +
> + =A0 =A0 =A0 if (!grp->full_slots) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __clear_bit(grp->index, &q->bitmaps[IR]=
);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __clear_bit(grp->index, &q->bitmaps[EB]=
);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __clear_bit(grp->index, &q->bitmaps[IB]=
);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (test_bit(grp->index, &q->bitmaps[ER=
]) &&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 !(q->bitmaps[ER] & ~((1UL << gr=
p->index) - 1))) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mask =3D q->bitmaps[ER]=
 & ((1UL << grp->index) - 1);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mask)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mask =3D=
 ~((1UL << __fls(mask)) - 1);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mask =3D=
 ~0UL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 qfq_move_groups(q, mask=
, EB, ER);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 qfq_move_groups(q, mask=
, IB, IR);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __clear_bit(grp->index, &q->bitmaps[ER]=
);
> + =A0 =A0 =A0 } else if (!grp->slots[grp->front]) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cl =3D qfq_slot_scan(grp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 roundedS =3D qfq_round_down(cl->S, grp-=
>slot_shift);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (grp->S !=3D roundedS) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __clear_bit(grp->index,=
 &q->bitmaps[ER]);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __clear_bit(grp->index,=
 &q->bitmaps[IR]);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __clear_bit(grp->index,=
 &q->bitmaps[EB]);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __clear_bit(grp->index,=
 &q->bitmaps[IB]);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 grp->S =3D roundedS;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 grp->F =3D roundedS + (=
2ULL << grp->slot_shift);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 s =3D qfq_calc_state(q,=
 grp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __set_bit(grp->index, &=
q->bitmaps[s]);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 qfq_update_eligible(q, q->V);
> +}
> +
> +static void qfq_qlen_notify(struct Qdisc *sch, unsigned long arg)
> +{
> + =A0 =A0 =A0 struct qfq_sched *q =3D (struct qfq_sched *)sch;
> + =A0 =A0 =A0 struct qfq_class *cl =3D (struct qfq_class *)arg;
> +
> + =A0 =A0 =A0 if (cl->qdisc->q.qlen =3D=3D 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 qfq_deactivate_class(q, cl, NULL);
> +}
> +
> +static unsigned int qfq_drop(struct Qdisc *sch)
> +{
> + =A0 =A0 =A0 struct qfq_sched *q =3D qdisc_priv(sch);
> + =A0 =A0 =A0 struct qfq_group *grp;
> + =A0 =A0 =A0 struct qfq_class *cl, **pp;
> + =A0 =A0 =A0 unsigned int i, j, len;
> +
> + =A0 =A0 =A0 for (i =3D 0; i <=3D QFQ_MAX_INDEX; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 grp =3D &q->groups[i];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (j =3D 0; j < QFQ_MAX_SLOTS; j++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (pp =3D &grp->slots=
[j]; *pp; pp =3D &(*pp)->next) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cl =3D =
*pp;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!cl=
->qdisc->ops->drop)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 continue;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 len =3D=
 cl->qdisc->ops->drop(cl->qdisc);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (len=
 > 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 sch->q.qlen--;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 if (!cl->qdisc->q.qlen)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 qfq_deactivate_class(q, cl, pp);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 return len;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static int qfq_init_qdisc(struct Qdisc *sch, struct nlattr *opt)
> +{
> + =A0 =A0 =A0 struct qfq_sched *q =3D qdisc_priv(sch);
> + =A0 =A0 =A0 struct qfq_group *grp;
> + =A0 =A0 =A0 int i, err;
> +
> + =A0 =A0 =A0 err =3D qdisc_class_hash_init(&q->clhash);
> + =A0 =A0 =A0 if (err < 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return err;
> +
> + =A0 =A0 =A0 for (i =3D 0; i <=3D QFQ_MAX_INDEX; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 grp =3D &q->groups[i];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 grp->index =3D i;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static void qfq_reset_qdisc(struct Qdisc *sch)
> +{
> + =A0 =A0 =A0 struct qfq_sched *q =3D qdisc_priv(sch);
> + =A0 =A0 =A0 struct qfq_group *grp;
> + =A0 =A0 =A0 struct qfq_class *cl, **pp;
> + =A0 =A0 =A0 struct hlist_node *n;
> + =A0 =A0 =A0 unsigned int i, j;
> +
> + =A0 =A0 =A0 for (i =3D 0; i <=3D QFQ_MAX_INDEX; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 grp =3D &q->groups[i];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (j =3D 0; j < QFQ_MAX_SLOTS; j++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (pp =3D &grp->slots=
[j]; *pp; pp =3D &(*pp)->next) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cl =3D =
*pp;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (cl-=
>qdisc->q.qlen)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 qfq_deactivate_class(q, cl, pp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 for (i =3D 0; i < q->clhash.hashsize; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 hlist_for_each_entry(cl, n, &q->clhash.=
hash[i], common.hnode)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 qdisc_reset(cl->qdisc);
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 sch->q.qlen =3D 0;
> +}
> +
> +static void qfq_destroy_qdisc(struct Qdisc *sch)
> +{
> + =A0 =A0 =A0 struct qfq_sched *q =3D qdisc_priv(sch);
> + =A0 =A0 =A0 struct qfq_class *cl;
> + =A0 =A0 =A0 struct hlist_node *n, *next;
> + =A0 =A0 =A0 unsigned int i;
> +
> + =A0 =A0 =A0 tcf_destroy_chain(&q->filter_list);
> +
> + =A0 =A0 =A0 for (i =3D 0; i < q->clhash.hashsize; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 hlist_for_each_entry_safe(cl, n, next, =
&q->clhash.hash[i],
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 common.hnode)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 qfq_destroy_class(sch, =
cl);
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 qdisc_class_hash_destroy(&q->clhash);
> +}
> +
> +static const struct Qdisc_class_ops qfq_class_ops =3D {
> + =A0 =A0 =A0 .change =A0 =A0 =A0 =A0 =3D qfq_change_class,
> + =A0 =A0 =A0 .delete =A0 =A0 =A0 =A0 =3D qfq_delete_class,
> + =A0 =A0 =A0 .get =A0 =A0 =A0 =A0 =A0 =A0=3D qfq_get_class,
> + =A0 =A0 =A0 .put =A0 =A0 =A0 =A0 =A0 =A0=3D qfq_put_class,
> + =A0 =A0 =A0 .tcf_chain =A0 =A0 =A0=3D qfq_tcf_chain,
> + =A0 =A0 =A0 .bind_tcf =A0 =A0 =A0 =3D qfq_bind_tcf,
> + =A0 =A0 =A0 .unbind_tcf =A0 =A0 =3D qfq_unbind_tcf,
> + =A0 =A0 =A0 .graft =A0 =A0 =A0 =A0 =A0=3D qfq_graft_class,
> + =A0 =A0 =A0 .leaf =A0 =A0 =A0 =A0 =A0 =3D qfq_class_leaf,
> + =A0 =A0 =A0 .qlen_notify =A0 =A0=3D qfq_qlen_notify,
> + =A0 =A0 =A0 .dump =A0 =A0 =A0 =A0 =A0 =3D qfq_dump_class,
> + =A0 =A0 =A0 .dump_stats =A0 =A0 =3D qfq_dump_class_stats,
> + =A0 =A0 =A0 .walk =A0 =A0 =A0 =A0 =A0 =3D qfq_walk,
> +};
> +
> +static struct Qdisc_ops qfq_qdisc_ops __read_mostly =3D {
> + =A0 =A0 =A0 .cl_ops =A0 =A0 =A0 =A0 =3D &qfq_class_ops,
> + =A0 =A0 =A0 .id =A0 =A0 =A0 =A0 =A0 =A0 =3D "qfq",
> + =A0 =A0 =A0 .priv_size =A0 =A0 =A0=3D sizeof(struct qfq_sched),
> + =A0 =A0 =A0 .enqueue =A0 =A0 =A0 =A0=3D qfq_enqueue,
> + =A0 =A0 =A0 .dequeue =A0 =A0 =A0 =A0=3D qfq_dequeue,
> + =A0 =A0 =A0 .peek =A0 =A0 =A0 =A0 =A0 =3D qdisc_peek_dequeued,
> + =A0 =A0 =A0 .drop =A0 =A0 =A0 =A0 =A0 =3D qfq_drop,
> + =A0 =A0 =A0 .init =A0 =A0 =A0 =A0 =A0 =3D qfq_init_qdisc,
> + =A0 =A0 =A0 .reset =A0 =A0 =A0 =A0 =A0=3D qfq_reset_qdisc,
> + =A0 =A0 =A0 .destroy =A0 =A0 =A0 =A0=3D qfq_destroy_qdisc,
> + =A0 =A0 =A0 .owner =A0 =A0 =A0 =A0 =A0=3D THIS_MODULE,
> +};
> +
> +static int __init qfq_init(void)
> +{
> + =A0 =A0 =A0 return register_qdisc(&qfq_qdisc_ops);
> +}
> +
> +static void __exit qfq_exit(void)
> +{
> + =A0 =A0 =A0 unregister_qdisc(&qfq_qdisc_ops);
> +}
> +
> +module_init(qfq_init);
> +module_exit(qfq_exit);
> +MODULE_LICENSE("GPL");
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>



--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
