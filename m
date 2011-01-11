From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] sched: CHOKe packet scheduler (v0.4)
Date: Tue, 11 Jan 2011 07:34:10 +0100
Message-ID: <1294727650.4148.20.camel@edumazet-laptop>
References: <20110104162930.6fa672e3@nehalam>
	 <1294208375.3420.46.camel@edumazet-laptop>
	 <20110105091718.02f8a00f@nehalam>
	 <1294248332.10633.25.camel@edumazet-laptop>
	 <20110105112104.64ad3c86@nehalam>
	 <1294286850.2723.65.camel@edumazet-laptop>
	 <20110106205549.0de56de1@nehalam> <1294667210.3491.7.camel@edumazet-laptop>
	 <20110110154414.53f33916@nehalam> <1294704031.4148.2.camel@edumazet-laptop>
	 <20110110171047.0796b6fb@nehalam> <1294726715.4148.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:57236 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751320Ab1AKGeP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jan 2011 01:34:15 -0500
Received: by wyb28 with SMTP id 28so20148808wyb.19
        for <netdev@vger.kernel.org>; Mon, 10 Jan 2011 22:34:13 -0800 (PST)
In-Reply-To: <1294726715.4148.8.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 11 janvier 2011 =C3=A0 07:18 +0100, Eric Dumazet a =C3=A9crit =
:
> Le lundi 10 janvier 2011 =C3=A0 17:10 -0800, Stephen Hemminger a =C3=A9=
crit :
> > OK, put that in.
>=20
> Thanks !
>=20
> > >=20
> > > Here we missed :
> > >=20
> > > 		q->tab =3D ntab;
> > >=20
>=20
> We also need to change=20
>=20
> .peek       =3D   qdisc_peek_head,
>=20
> to
>=20
> .peek =3D choke_peek_head,
>=20
> static struct sk_buff *choke_peek_head(struct Qdisc *sch)
> {
> 	struct choke_sched_data *q =3D qdisc_priv(sch);
>=20
> 	return (q->head !=3D q->tail) ? q->tab[q->head] : NULL;
> }
>=20
>=20


And to correctly work with CBQ (at least...), we need to update=20
sch->q.qlen =3D choke_len(q) - q->holes;
in dequeue() and enqueue()

Here is the version I successfully tested, with 30000 packets in
queue :)

qdisc choke 11: parent 1:11 limit 70000b min 10000b max 30000b ewma 1 P=
log 16 Scell_log 11
 Sent 62099201 bytes 112920 pkt (dropped 367712, overlimits 282668 requ=
eues 0)=20
 rate 21344Kbit 4851pps backlog 39877589b 30001p requeues 0=20
  marked 0 early 282668 pdrop 0 other 0

diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index a36270a..e63ae56 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -205,6 +205,17 @@ config NET_SCH_DRR
=20
 	  If unsure, say N.
=20
+config NET_SCH_CHOKE
+	tristate "CHOose and Keep responsive flow scheduler (CHOKE)"
+	help
+	  Say Y here if you want to use the CHOKe packet scheduler (CHOose
+	  and Keep for responsive flows, CHOose and Kill for unresponsive
+	  flows). This is a variation of RED which trys to penalize flows
+	  that monopolize the queue.
+
+	  To compile this code as a module, choose M here: the
+	  module will be called sch_choke.
+
 config NET_SCH_INGRESS
 	tristate "Ingress Qdisc"
 	depends on NET_CLS_ACT
diff --git a/net/sched/Makefile b/net/sched/Makefile
index 960f5db..894fa3f 100644
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -32,6 +32,7 @@ obj-$(CONFIG_NET_SCH_MULTIQ)	+=3D sch_multiq.o
 obj-$(CONFIG_NET_SCH_ATM)	+=3D sch_atm.o
 obj-$(CONFIG_NET_SCH_NETEM)	+=3D sch_netem.o
 obj-$(CONFIG_NET_SCH_DRR)	+=3D sch_drr.o
+obj-$(CONFIG_NET_SCH_CHOKE)	+=3D sch_choke.o
 obj-$(CONFIG_NET_CLS_U32)	+=3D cls_u32.o
 obj-$(CONFIG_NET_CLS_ROUTE4)	+=3D cls_route.o
 obj-$(CONFIG_NET_CLS_FW)	+=3D cls_fw.o
diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
index e69de29..b565f2a 100644
--- a/net/sched/sch_choke.c
+++ b/net/sched/sch_choke.c
@@ -0,0 +1,536 @@
+/*
+ * net/sched/sch_choke.c	CHOKE scheduler
+ *
+ * Copyright (c) 2011 Stephen Hemminger <shemminger@vyatta.com>
+ * Copyright (c) 2011 Eric Dumazet <eric.dumazet@gmail.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * version 2 as published by the Free Software Foundation.
+ *
+ */
+
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/skbuff.h>
+#include <linux/reciprocal_div.h>
+#include <net/pkt_sched.h>
+#include <net/inet_ecn.h>
+#include <net/red.h>
+
+/*	CHOKe stateless AQM for fair bandwidth allocation
+        =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
+
+   CHOKe (CHOose and Keep for responsive flows, CHOose and Kill for
+   unresponsive flows) is a variant of RED that penalizes misbehaving =
flows but
+   maintains no flow state. The difference from RED is an additional s=
tep
+   during the enqueuing process. If average queue size is over the
+   low threshold (qmin), a packet is chosen at random from the queue.
+   If both the new and chosen packet are from the same flow, both
+   are dropped. Unlike RED, CHOKe is not really a "classful" qdisc bec=
ause it
+   needs to access packets in queue randomly. It has a minimal class
+   interface to allow overriding the builtin flow classifier with
+   filters.
+
+   Source:
+   R. Pan, B. Prabhakar, and K. Psounis, "CHOKe, A Stateless
+   Active Queue Management Scheme for Approximating Fair Bandwidth All=
ocation",
+   IEEE INFOCOM, 2000.
+
+   A. Tang, J. Wang, S. Low, "Understanding CHOKe: Throughput and Spat=
ial
+   Characteristics", IEEE/ACM Transactions on Networking, 2004
+
+ */
+
+struct choke_sched_data {
+/* Parameters */
+	u32		 limit;
+	unsigned char	 flags;
+
+	struct red_parms parms;
+	struct red_stats stats;
+
+/* Variables */
+	struct tcf_proto *filter_list;
+	unsigned int	 head;
+	unsigned int	 tail;
+	unsigned int	 holes;
+	unsigned int	 tab_mask; /* size - 1 */
+
+	struct sk_buff **tab;
+};
+
+static inline unsigned int choke_len(const struct choke_sched_data *q)
+{
+	return (q->tail - q->head) & q->tab_mask;
+}
+
+/* deliver a random number between 0 and N - 1 */
+static inline u32 random_N(unsigned int N)
+{
+	return reciprocal_divide(random32(), N);
+}
+
+
+/* Select a packet at random from the queue in O(1) and handle holes *=
/
+static struct sk_buff *choke_peek_random(struct choke_sched_data *q,
+					 unsigned int *pidx)
+{
+	struct sk_buff *skb;
+	int retrys =3D 3;
+
+	do {
+		*pidx =3D (q->head + random_N(choke_len(q))) & q->tab_mask;
+		skb =3D q->tab[*pidx];
+		if (skb)
+			return skb;
+	} while (--retrys > 0);
+
+	/* queue is has lots of holes use the head which is known to exist */
+	return q->tab[*pidx =3D q->head];
+}
+
+/* Is ECN parameter configured */
+static inline int use_ecn(const struct choke_sched_data *q)
+{
+	return q->flags & TC_RED_ECN;
+}
+
+/* Should packets over max just be dropped (versus marked) */
+static inline int use_harddrop(const struct choke_sched_data *q)
+{
+	return q->flags & TC_RED_HARDDROP;
+}
+
+/* Move head pointer forward to skip over holes */
+static void choke_zap_head_holes(struct choke_sched_data *q)
+{
+	while (q->holes && q->tab[q->head] =3D=3D NULL) {
+		q->head =3D (q->head + 1) & q->tab_mask;
+		q->holes--;
+	}
+}
+
+/* Move tail pointer backwards to reuse holes */
+static void choke_zap_tail_holes(struct choke_sched_data *q)
+{
+	while (q->holes && q->tab[q->tail - 1] =3D=3D NULL) {
+		q->tail =3D (q->tail - 1) & q->tab_mask;
+		q->holes--;
+	}
+}
+
+/* Drop packet from queue array by creating a "hole" */
+static void choke_drop_by_idx(struct choke_sched_data *q, unsigned int=
 idx)
+{
+	q->tab[idx] =3D NULL;
+	q->holes++;
+
+	if (idx =3D=3D q->head)
+		choke_zap_head_holes(q);
+	if (idx =3D=3D q->tail)
+		choke_zap_tail_holes(q);
+}
+
+/* Classify flow using either:
+   1. pre-existing classification result in skb
+   2. fast internal classification
+   3. use TC filter based classification
+*/
+static inline unsigned int choke_classify(struct sk_buff *skb,
+					  struct Qdisc *sch, int *qerr)
+
+{
+	struct choke_sched_data *q =3D qdisc_priv(sch);
+	struct tcf_result res;
+	int result;
+
+	*qerr =3D NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
+
+	if (TC_H_MAJ(skb->priority) =3D=3D sch->handle &&
+	    TC_H_MIN(skb->priority) > 0)
+		return TC_H_MIN(skb->priority);
+
+	if (!q->filter_list)
+		return skb_get_rxhash(skb);
+
+	result =3D tc_classify(skb, q->filter_list, &res);
+	if (result >=3D 0) {
+#ifdef CONFIG_NET_CLS_ACT
+		switch (result) {
+		case TC_ACT_STOLEN:
+		case TC_ACT_QUEUED:
+			*qerr =3D NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
+		case TC_ACT_SHOT:
+			return 0;
+		}
+#endif
+		return TC_H_MIN(res.classid);
+	}
+
+	return 0;
+}
+
+static int choke_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+{
+	struct choke_sched_data *q =3D qdisc_priv(sch);
+	struct red_parms *p =3D &q->parms;
+	unsigned int hash;
+	int uninitialized_var(ret);
+
+	hash =3D choke_classify(skb, sch, &ret);
+	if (unlikely(!hash)) {
+		if (ret & __NET_XMIT_BYPASS)
+			sch->qstats.drops++;
+		kfree_skb(skb);
+		return ret;
+	}
+
+	/* XXX add hash to qdisc_skb_cb? */
+	*(unsigned int *)(qdisc_skb_cb(skb)->data) =3D hash;
+
+	/* Compute average queue usage (see RED) */
+	p->qavg =3D red_calc_qavg(p, choke_len(q) - q->holes);
+	if (red_is_idling(p))
+		red_end_of_idle_period(p);
+
+	/* Is queue small? */
+	if (p->qavg <=3D p->qth_min)
+		p->qcount =3D -1;
+	else {
+		struct sk_buff *oskb;
+		unsigned int idx;
+
+		/* Draw a packet at random from queue */
+		oskb =3D choke_peek_random(q, &idx);
+
+		/* Both packets from same flow ? */
+		if (*(unsigned int *)(qdisc_skb_cb(oskb)->data) =3D=3D hash) {
+			/* Drop both packets */
+			choke_drop_by_idx(q, idx);
+			qdisc_drop(oskb, sch);
+			goto congestion_drop;
+		}
+
+		if (p->qavg > p->qth_max) {
+			p->qcount =3D -1;
+
+			sch->qstats.overlimits++;
+			if (use_harddrop(q) || !use_ecn(q) ||
+			    !INET_ECN_set_ce(skb)) {
+				q->stats.forced_drop++;
+				goto congestion_drop;
+			}
+
+			q->stats.forced_mark++;
+		}
+
+		if (++p->qcount) {
+			if (red_mark_probability(p, p->qavg)) {
+				p->qcount =3D 0;
+				p->qR =3D red_random(p);
+
+				sch->qstats.overlimits++;
+				if (!use_ecn(q) || !INET_ECN_set_ce(skb)) {
+					q->stats.prob_drop++;
+					goto congestion_drop;
+				}
+
+				q->stats.prob_mark++;
+			}
+		} else
+			p->qR =3D red_random(p);
+	}
+
+	/* Admit new packet */
+	if (likely(choke_len(q) < q->limit)) {
+		q->tab[q->tail] =3D skb;
+		q->tail =3D (q->tail + 1) & q->tab_mask;
+
+		sch->qstats.backlog +=3D qdisc_pkt_len(skb);
+		__qdisc_update_bstats(sch, qdisc_pkt_len(skb));
+		sch->q.qlen =3D choke_len(q) - q->holes;
+		return NET_XMIT_SUCCESS;
+	}
+
+	q->stats.pdrop++;
+	sch->qstats.drops++;
+	kfree_skb(skb);
+	return NET_XMIT_DROP;
+
+ congestion_drop:
+	qdisc_drop(skb, sch);
+	return NET_XMIT_CN;
+}
+
+static struct sk_buff *choke_dequeue(struct Qdisc *sch)
+{
+	struct choke_sched_data *q =3D qdisc_priv(sch);
+	struct sk_buff *skb;
+
+	if (q->head =3D=3D q->tail) {
+		if (!red_is_idling(&q->parms))
+			red_start_of_idle_period(&q->parms);
+		return NULL;
+	}
+	skb =3D q->tab[q->head];
+	q->tab[q->head] =3D NULL; /* not really needed */
+	q->head =3D (q->head + 1) & q->tab_mask;
+	choke_zap_head_holes(q);
+	sch->qstats.backlog -=3D qdisc_pkt_len(skb);
+	sch->q.qlen =3D choke_len(q) - q->holes;
+
+	return skb;
+}
+
+static unsigned int choke_drop(struct Qdisc *sch)
+{
+	struct choke_sched_data *q =3D qdisc_priv(sch);
+	unsigned int len;
+
+	len =3D qdisc_queue_drop(sch);
+
+	if (len > 0)
+		q->stats.other++;
+	else {
+		if (!red_is_idling(&q->parms))
+			red_start_of_idle_period(&q->parms);
+	}
+
+	return len;
+}
+
+static void choke_reset(struct Qdisc* sch)
+{
+	struct choke_sched_data *q =3D qdisc_priv(sch);
+
+	red_restart(&q->parms);
+}
+
+static const struct nla_policy choke_policy[TCA_RED_MAX + 1] =3D {
+	[TCA_RED_PARMS]	=3D { .len =3D sizeof(struct tc_red_qopt) },
+	[TCA_RED_STAB]	=3D { .len =3D RED_STAB_SIZE },
+};
+
+
+static void choke_free(void *addr)
+{
+	if (addr) {
+		if (is_vmalloc_addr(addr))
+			vfree(addr);
+		else
+			kfree(addr);
+	}
+}
+
+static int choke_change(struct Qdisc *sch, struct nlattr *opt)
+{
+	struct choke_sched_data *q =3D qdisc_priv(sch);
+	struct nlattr *tb[TCA_RED_MAX + 1];
+	struct tc_red_qopt *ctl;
+	int err;
+	struct sk_buff **old =3D NULL;
+	unsigned int mask;
+
+	if (opt =3D=3D NULL)
+		return -EINVAL;
+
+	err =3D nla_parse_nested(tb, TCA_RED_MAX, opt, choke_policy);
+	if (err < 0)
+		return err;
+
+	if (tb[TCA_RED_PARMS] =3D=3D NULL ||
+	    tb[TCA_RED_STAB] =3D=3D NULL)
+		return -EINVAL;
+
+	ctl =3D nla_data(tb[TCA_RED_PARMS]);
+
+	mask =3D roundup_pow_of_two(ctl->limit + 1) - 1;
+	if (mask !=3D q->tab_mask) {
+		struct sk_buff **ntab =3D kcalloc(mask + 1, sizeof(struct sk_buff *)=
,
+						GFP_KERNEL);
+		if (!ntab)
+			ntab =3D vzalloc((mask + 1) * sizeof(struct sk_buff *));
+		if (!ntab)
+			return -ENOMEM;
+		sch_tree_lock(sch);
+		old =3D q->tab;
+		if (old) {
+			unsigned int tail =3D 0;
+
+			while (q->head !=3D q->tail) {
+				ntab[tail++] =3D q->tab[q->head];
+				q->head =3D (q->head + 1) & q->tab_mask;
+			}
+			q->head =3D 0;
+			q->tail =3D tail;
+		}
+		q->tab_mask =3D mask;
+		q->tab =3D ntab;
+		q->holes =3D 0;
+	} else
+		sch_tree_lock(sch);
+	q->flags =3D ctl->flags;
+	q->limit =3D ctl->limit;
+
+	red_set_parms(&q->parms, ctl->qth_min, ctl->qth_max, ctl->Wlog,
+		      ctl->Plog, ctl->Scell_log,
+		      nla_data(tb[TCA_RED_STAB]));
+
+	if (q->head =3D=3D q->tail)
+		red_end_of_idle_period(&q->parms);
+
+	sch_tree_unlock(sch);
+	choke_free(old);
+	return 0;
+}
+
+static int choke_init(struct Qdisc* sch, struct nlattr *opt)
+{
+	return choke_change(sch, opt);
+}
+
+static int choke_dump(struct Qdisc *sch, struct sk_buff *skb)
+{
+	struct choke_sched_data *q =3D qdisc_priv(sch);
+	struct nlattr *opts =3D NULL;
+	struct tc_red_qopt opt =3D {
+		.limit		=3D q->limit,
+		.flags		=3D q->flags,
+		.qth_min	=3D q->parms.qth_min >> q->parms.Wlog,
+		.qth_max	=3D q->parms.qth_max >> q->parms.Wlog,
+		.Wlog		=3D q->parms.Wlog,
+		.Plog		=3D q->parms.Plog,
+		.Scell_log	=3D q->parms.Scell_log,
+	};
+
+	opts =3D nla_nest_start(skb, TCA_OPTIONS);
+	if (opts =3D=3D NULL)
+		goto nla_put_failure;
+
+	NLA_PUT(skb, TCA_RED_PARMS, sizeof(opt), &opt);
+	return nla_nest_end(skb, opts);
+
+nla_put_failure:
+	nla_nest_cancel(skb, opts);
+	return -EMSGSIZE;
+}
+
+static int choke_dump_stats(struct Qdisc *sch, struct gnet_dump *d)
+{
+	struct choke_sched_data *q =3D qdisc_priv(sch);
+	struct tc_red_xstats st =3D {
+		.early	=3D q->stats.prob_drop + q->stats.forced_drop,
+		.pdrop	=3D q->stats.pdrop,
+		.other	=3D q->stats.other,
+		.marked	=3D q->stats.prob_mark + q->stats.forced_mark,
+	};
+
+	return gnet_stats_copy_app(d, &st, sizeof(st));
+}
+
+static void choke_destroy(struct Qdisc *sch)
+{
+	struct choke_sched_data *q =3D qdisc_priv(sch);
+
+	tcf_destroy_chain(&q->filter_list);
+	choke_free(q->tab);
+}
+
+static struct Qdisc *choke_leaf(struct Qdisc *sch, unsigned long arg)
+{
+	return NULL;
+}
+
+static unsigned long choke_get(struct Qdisc *sch, u32 classid)
+{
+	return 0;
+}
+
+static void choke_put(struct Qdisc *q, unsigned long cl)
+{
+}
+
+static unsigned long choke_bind(struct Qdisc *sch, unsigned long paren=
t,
+				u32 classid)
+{
+	return 0;
+}
+
+static struct tcf_proto **choke_find_tcf(struct Qdisc *sch, unsigned l=
ong cl)
+{
+	struct choke_sched_data *q =3D qdisc_priv(sch);
+
+	if (cl)
+		return NULL;
+	return &q->filter_list;
+}
+
+static int choke_dump_class(struct Qdisc *sch, unsigned long cl,
+			  struct sk_buff *skb, struct tcmsg *tcm)
+{
+	tcm->tcm_handle |=3D TC_H_MIN(cl);
+	return 0;
+}
+
+static void choke_walk(struct Qdisc *sch, struct qdisc_walker *arg)
+{
+	if (!arg->stop) {
+		if (arg->fn(sch, 1, arg) < 0) {
+			arg->stop =3D 1;
+			return;
+		}
+		arg->count++;
+	}
+}
+
+static const struct Qdisc_class_ops choke_class_ops =3D {
+	.leaf		=3D	choke_leaf,
+	.get		=3D	choke_get,
+	.put		=3D	choke_put,
+	.tcf_chain	=3D	choke_find_tcf,
+	.bind_tcf	=3D	choke_bind,
+	.unbind_tcf	=3D	choke_put,
+	.dump		=3D	choke_dump_class,
+	.walk		=3D	choke_walk,
+};
+
+static struct sk_buff *choke_peek_head(struct Qdisc *sch)
+{
+	struct choke_sched_data *q =3D qdisc_priv(sch);
+
+	return (q->head !=3D q->tail) ? q->tab[q->head] : NULL;
+}
+
+static struct Qdisc_ops choke_qdisc_ops __read_mostly =3D {
+	.id		=3D	"choke",
+	.priv_size	=3D	sizeof(struct choke_sched_data),
+
+	.enqueue	=3D	choke_enqueue,
+	.dequeue	=3D	choke_dequeue,
+	.peek		=3D	choke_peek_head,
+	.drop		=3D	choke_drop,
+	.init		=3D	choke_init,
+	.destroy	=3D	choke_destroy,
+	.reset		=3D	choke_reset,
+	.change		=3D	choke_change,
+	.dump		=3D	choke_dump,
+	.dump_stats	=3D	choke_dump_stats,
+	.owner		=3D	THIS_MODULE,
+};
+
+static int __init choke_module_init(void)
+{
+	return register_qdisc(&choke_qdisc_ops);
+}
+
+static void __exit choke_module_exit(void)
+{
+	unregister_qdisc(&choke_qdisc_ops);
+}
+
+module_init(choke_module_init)
+module_exit(choke_module_exit)
+
+MODULE_LICENSE("GPL");


