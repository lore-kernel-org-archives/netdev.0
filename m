From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] CHOKe flow scheduler (0.9)
Date: Tue, 18 Jan 2011 11:06:34 -0800
Message-ID: <20110118110634.7386c757@nehalam>
References: <20110113092706.154748c2@s6510>
	<1294951069.3403.11.camel@edumazet-laptop>
	<20110113153436.70d3c0a3@s6510>
	<4D305598.1010207@trash.net>
	<4D3055C2.3060807@trash.net>
	<1295015043.3937.20.camel@edumazet-laptop>
	<20110114154521.54cc8ef5@nehalam>
	<1295077542.3977.20.camel@edumazet-laptop>
	<20110117092532.7d5f5a5b@nehalam>
	<1295286851.3335.36.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44309 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752345Ab1ARTGi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 14:06:38 -0500
In-Reply-To: <1295286851.3335.36.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 Jan 2011 18:54:11 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le lundi 17 janvier 2011 =E0 09:25 -0800, Stephen Hemminger a =E9crit=
 :
>=20
> > I rolled in your changes. But there is one more change I want to ma=
ke.
> > The existing flow match based on hash is vulnerable to side-channel=
 DoS attack.
> > It is possible for a hostile flow to send packets that match the sa=
me
> > hash value which would effectively kill a targeted flow.
> >=20
> > The solution is to match based on full source and destination, not =
hash value.
> > Still coding that up.
>=20
> I see, but you only want to make this full test if (!q->filter_list) =
 ?
>=20
> (or precisely only if skb_get_rxhash() was used to get the cookie )

This is what I am starting to retest. The code can probably be simplifi=
ed
to avoid the may_pull() on the packet already in queue.

Subject: sched: CHOKe flow scheduler

CHOKe ("CHOose and Kill" or "CHOose and Keep") is an alternative
packet scheduler based on the Random Exponential Drop (RED) algorithm.

The core idea is:
  For every packet arrival:
  	Calculate Qave
	if (Qave < minth)=20
	     Queue the new packet
	else=20
	     Select randomly a packet from the queue=20
	     if (both packets from same flow)
	     then Drop both the packets
	     else if (Qave > maxth)
	          Drop packet
	     else
	       	  Admit packet with proability p (same as RED)

See also:
  Rong Pan, Balaji Prabhakar, Konstantinos Psounis, "CHOKe: a stateless=
 active
   queue management scheme for approximating fair bandwidth allocation"=
,=20
  Proceeding of INFOCOM'2000, March 2000.

Help from:
     Eric Dumazet <eric.dumazet@gmail.com>
     Patrick McHardy <kaber@trash.net>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
This version is based on net-next, and assumes Eric's patch for
corrected bstats is already applied.

0.9 incorporate patches from Patrick/Eric
    rework the peek_random and drop code to simplify and fix bug where
    random_N needs to called with full length (including holes).

 include/linux/pkt_sched.h |   29 ++
 net/sched/Kconfig         |   11=20
 net/sched/Makefile        |    1=20
 net/sched/sch_choke.c     |  579 +++++++++++++++++++++++++++++++++++++=
+++++++++
 4 files changed, 620 insertions(+)

--- a/net/sched/Kconfig	2011-01-14 10:43:19.062537393 -0800
+++ b/net/sched/Kconfig	2011-01-16 13:42:45.938919517 -0800
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
--- a/net/sched/Makefile	2011-01-14 10:43:19.072538228 -0800
+++ b/net/sched/Makefile	2011-01-16 13:42:45.946919793 -0800
@@ -32,6 +32,7 @@ obj-$(CONFIG_NET_SCH_MULTIQ)	+=3D sch_mult
 obj-$(CONFIG_NET_SCH_ATM)	+=3D sch_atm.o
 obj-$(CONFIG_NET_SCH_NETEM)	+=3D sch_netem.o
 obj-$(CONFIG_NET_SCH_DRR)	+=3D sch_drr.o
+obj-$(CONFIG_NET_SCH_CHOKE)	+=3D sch_choke.o
 obj-$(CONFIG_NET_CLS_U32)	+=3D cls_u32.o
 obj-$(CONFIG_NET_CLS_ROUTE4)	+=3D cls_route.o
 obj-$(CONFIG_NET_CLS_FW)	+=3D cls_fw.o
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ b/net/sched/sch_choke.c	2011-01-17 09:18:42.271211633 -0800
@@ -0,0 +1,686 @@
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
+#include <linux/ip.h>
+#include <net/ip.h>
+#include <linux/ipv6.h>
+#include <net/ipv6.h>
+
+/*
+   CHOKe stateless AQM for fair bandwidth allocation
+   =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D
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
+/* Upper bound on size of sk_buff table (packets) */
+#define CHOKE_MAX_QUEUE	(128*1024 - 1)
+
+struct choke_sched_data {
+/* Parameters */
+	u32		 limit;
+	unsigned char	 flags;
+
+	struct red_parms parms;
+
+/* Variables */
+	struct tcf_proto *filter_list;
+	struct {
+		u32	prob_drop;	/* Early probability drops */
+		u32	prob_mark;	/* Early probability marks */
+		u32	forced_drop;	/* Forced drops, qavg > max_thresh */
+		u32	forced_mark;	/* Forced marks, qavg > max_thresh */
+		u32	pdrop;          /* Drops due to queue limits */
+		u32	other;          /* Drops due to drop() calls */
+		u32	matched;	/* Drops to flow match */
+	} stats;
+
+	unsigned int	 head;
+	unsigned int	 tail;
+
+	unsigned int	 tab_mask; /* size - 1 */
+
+	struct sk_buff **tab;
+};
+
+/* deliver a random number between 0 and N - 1 */
+static u32 random_N(unsigned int N)
+{
+	return reciprocal_divide(random32(), N);
+}
+
+/* number of elements in queue including holes */
+static unsigned int choke_len(const struct choke_sched_data *q)
+{
+	return (q->tail - q->head) & q->tab_mask;
+}
+
+/* Is ECN parameter configured */
+static int use_ecn(const struct choke_sched_data *q)
+{
+	return q->flags & TC_RED_ECN;
+}
+
+/* Should packets over max just be dropped (versus marked) */
+static int use_harddrop(const struct choke_sched_data *q)
+{
+	return q->flags & TC_RED_HARDDROP;
+}
+
+/* Move head pointer forward to skip over holes */
+static void choke_zap_head_holes(struct choke_sched_data *q)
+{
+	do {
+		q->head =3D (q->head + 1) & q->tab_mask;
+		if (q->head =3D=3D q->tail)
+			break;
+	} while (q->tab[q->head] =3D=3D NULL);
+}
+
+/* Move tail pointer backwards to reuse holes */
+static void choke_zap_tail_holes(struct choke_sched_data *q)
+{
+	do {
+		q->tail =3D (q->tail - 1) & q->tab_mask;
+		if (q->head =3D=3D q->tail)
+			break;
+	} while (q->tab[q->tail] =3D=3D NULL);
+}
+
+/* Drop packet from queue array by creating a "hole" */
+static void choke_drop_by_idx(struct Qdisc *sch, unsigned int idx)
+{
+	struct choke_sched_data *q =3D qdisc_priv(sch);
+	struct sk_buff *skb =3D q->tab[idx];
+
+	q->tab[idx] =3D NULL;
+
+	if (idx =3D=3D q->head)
+		choke_zap_head_holes(q);
+	if (idx =3D=3D q->tail)
+		choke_zap_tail_holes(q);
+
+	sch->qstats.backlog -=3D qdisc_pkt_len(skb);
+	qdisc_drop(skb, sch);
+	qdisc_tree_decrease_qlen(sch, 1);
+	--sch->q.qlen;
+}
+
+/*
+ * Compare flow of two packets
+ *  Returns true only if source and destination address and port match=
=2E
+ *          false for special cases
+ */
+static bool choke_match_flow(struct sk_buff *skb1, struct sk_buff *skb=
2)
+{
+	int off1, off2, poff;
+	u8 ip_proto;
+	u32 ihl;
+
+	if (skb1->protocol !=3D skb2->protocol)
+		return false;
+
+	off1 =3D skb_network_offset(skb1);
+	off2 =3D skb_network_offset(skb2);
+
+	switch (skb1->protocol) {
+	case __constant_htons(ETH_P_IP): {
+		struct iphdr *ip1, *ip2;
+
+		if (!pskb_may_pull(skb1, sizeof(struct iphdr) + off1))
+			return false;
+
+		ip1 =3D (struct iphdr *) (skb1->data + off1);
+		if (ip1->frag_off & htons(IP_MF | IP_OFFSET))
+			return false;	/* don't compare fragments */
+
+		if (!pskb_may_pull(skb2, sizeof(struct iphdr) + off2))
+			return false;
+
+		ip2 =3D (struct iphdr *) (skb2->data + off2);
+		if (ip2->frag_off & htons(IP_MF | IP_OFFSET))
+			return false;
+
+		if (ip1->protocol !=3D ip2->protocol ||
+		    ip1->saddr !=3D ip2->saddr || ip1->daddr !=3D ip2->daddr)
+			return false;
+
+		ip_proto =3D ip1->protocol;
+		ihl =3D ip1->ihl;
+		break;
+	}
+
+	case __constant_htons(ETH_P_IPV6): {
+		struct ipv6hdr *ip1, *ip2;
+
+		if (!pskb_may_pull(skb1, sizeof(struct ipv6hdr *) + off1))
+			return false;
+
+		if (!pskb_may_pull(skb2, sizeof(struct ipv6hdr *) + off2))
+			return false;
+
+		ip1 =3D (struct ipv6hdr *) (skb1->data + off1);
+		ip2 =3D (struct ipv6hdr *) (skb2->data + off2);
+
+		if (ip1->nexthdr !=3D ip2->nexthdr ||
+		    ipv6_addr_cmp(&ip1->saddr, &ip2->saddr) !=3D 0 ||
+		    ipv6_addr_cmp(&ip1->daddr, &ip2->daddr))
+			return false;
+
+		ihl =3D (40 >> 2);
+		ip_proto =3D ip1->nexthdr;
+		break;
+	}
+
+	default:
+		return false;
+	}
+
+	poff =3D proto_ports_offset(ip_proto);
+	if (poff >=3D 0) {
+		u32 *ports1, *ports2;
+
+		off1 +=3D ihl * 4 + poff;
+		if (!pskb_may_pull(skb1, off1 + 4))
+			return false;
+
+		off2 +=3D ihl * 4 + poff;
+		if (!pskb_may_pull(skb2, off2 + 4))
+			return false;
+
+		ports1 =3D (__force u32 *) (skb1->data + off1);
+		ports2 =3D (__force u32 *) (skb2->data + off2);
+
+		return *ports1 =3D=3D *ports2;
+	}
+
+	return true;
+}
+
+static inline void choke_set_classid(struct sk_buff *skb, u16 classid)
+{
+	*(unsigned int *)(qdisc_skb_cb(skb)->data) =3D classid;
+}
+
+static u16 choke_get_classid(const struct sk_buff *skb)
+{
+	return *(unsigned int *)(qdisc_skb_cb(skb)->data);
+}
+
+/*
+ * Classify flow using either:
+ *  1. pre-existing classification result in skb
+ *  2. fast internal classification
+ *  3. use TC filter based classification
+ */
+static bool choke_classify(struct sk_buff *skb,
+			   struct Qdisc *sch, int *qerr)
+
+{
+	struct choke_sched_data *q =3D qdisc_priv(sch);
+	struct tcf_result res;
+	int result;
+
+	*qerr =3D NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
+
+	result =3D tc_classify(skb, q->filter_list, &res);
+	if (result >=3D 0) {
+#ifdef CONFIG_NET_CLS_ACT
+		switch (result) {
+		case TC_ACT_STOLEN:
+		case TC_ACT_QUEUED:
+			*qerr =3D NET_XMIT_SUCCESS | __NET_XMIT_STOLEN;
+		case TC_ACT_SHOT:
+			return false;
+		}
+#endif
+		choke_set_classid(skb, TC_H_MIN(res.classid));
+		return true;
+	}
+
+	return false;
+}
+
+/* Select packet a random from queue */
+static struct sk_buff *choke_peek_random(const struct choke_sched_data=
 *q,
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
+	/* queue is has lots of holes use the head which is known to exist
+	 * Note : result can still be NULL if q->head =3D=3D q->tail
+	 */
+	return q->tab[*pidx =3D q->head];
+}
+
+/* Select a packet at random from the queue and compare flow */
+static bool choke_match_random(const struct choke_sched_data *q,
+			       struct sk_buff *nskb,
+			       unsigned int *pidx)
+{
+	struct sk_buff *oskb;
+
+	if (q->head =3D=3D q->tail)
+		return false;
+
+	oskb =3D choke_peek_random(q, pidx);
+	if (q->filter_list)
+		return choke_get_classid(nskb) =3D=3D choke_get_classid(oskb);
+
+
+	return choke_match_flow(oskb, nskb);
+}
+
+static int choke_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+{
+	struct choke_sched_data *q =3D qdisc_priv(sch);
+	struct red_parms *p =3D &q->parms;
+	int uninitialized_var(ret);
+
+	/* If using external classifiers, get result and record it. */
+	if (q->filter_list &&
+	    !choke_classify(skb, sch, &ret)) {
+		/* Packet was eaten by filter */
+		if (ret & __NET_XMIT_BYPASS)
+			sch->qstats.drops++;
+		kfree_skb(skb);
+		return ret;
+	}
+
+	/* Compute average queue usage (see RED) */
+	p->qavg =3D red_calc_qavg(p, sch->q.qlen);
+	if (red_is_idling(p))
+		red_end_of_idle_period(p);
+
+	/* Is queue small? */
+	if (p->qavg <=3D p->qth_min)
+		p->qcount =3D -1;
+	else {
+		unsigned int idx;
+
+		/* Draw a packet at random from queue and compare flow */
+		if (choke_match_random(q, skb, &idx)) {
+			q->stats.matched++;
+			choke_drop_by_idx(sch, idx);
+			goto congestion_drop;
+		}
+
+		/* Queue is large, always mark/drop */
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
+		} else if (++p->qcount) {
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
+	if (sch->q.qlen < q->limit) {
+		q->tab[q->tail] =3D skb;
+		q->tail =3D (q->tail + 1) & q->tab_mask;
+		++sch->q.qlen;
+		sch->qstats.backlog +=3D qdisc_pkt_len(skb);
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
+
+	skb =3D q->tab[q->head];
+	q->tab[q->head] =3D NULL;
+	choke_zap_head_holes(q);
+	--sch->q.qlen;
+	sch->qstats.backlog -=3D qdisc_pkt_len(skb);
+	qdisc_bstats_update(sch, skb);
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
+static void choke_reset(struct Qdisc *sch)
+{
+	struct choke_sched_data *q =3D qdisc_priv(sch);
+
+	red_restart(&q->parms);
+}
+
+static const struct nla_policy choke_policy[TCA_CHOKE_MAX + 1] =3D {
+	[TCA_CHOKE_PARMS]	=3D { .len =3D sizeof(struct tc_red_qopt) },
+	[TCA_CHOKE_STAB]	=3D { .len =3D RED_STAB_SIZE },
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
+	struct nlattr *tb[TCA_CHOKE_MAX + 1];
+	const struct tc_red_qopt *ctl;
+	int err;
+	struct sk_buff **old =3D NULL;
+	unsigned int mask;
+
+	if (opt =3D=3D NULL)
+		return -EINVAL;
+
+	err =3D nla_parse_nested(tb, TCA_CHOKE_MAX, opt, choke_policy);
+	if (err < 0)
+		return err;
+
+	if (tb[TCA_CHOKE_PARMS] =3D=3D NULL ||
+	    tb[TCA_CHOKE_STAB] =3D=3D NULL)
+		return -EINVAL;
+
+	ctl =3D nla_data(tb[TCA_CHOKE_PARMS]);
+
+	if (ctl->limit > CHOKE_MAX_QUEUE)
+		return -EINVAL;
+
+	mask =3D roundup_pow_of_two(ctl->limit + 1) - 1;
+	if (mask !=3D q->tab_mask) {
+		struct sk_buff **ntab;
+
+		ntab =3D kcalloc(mask + 1, sizeof(struct sk_buff *), GFP_KERNEL);
+		if (!ntab)
+			ntab =3D vzalloc((mask + 1) * sizeof(struct sk_buff *));
+		if (!ntab)
+			return -ENOMEM;
+
+		sch_tree_lock(sch);
+		old =3D q->tab;
+		if (old) {
+			unsigned int oqlen =3D sch->q.qlen, tail =3D 0;
+
+			while (q->head !=3D q->tail) {
+				struct sk_buff *skb =3D q->tab[q->head];
+
+				q->head =3D (q->head + 1) & q->tab_mask;
+				if (!skb)
+					continue;
+				if (tail < mask) {
+					ntab[tail++] =3D skb;
+					continue;
+				}
+				sch->qstats.backlog -=3D qdisc_pkt_len(skb);
+				--sch->q.qlen;
+				qdisc_drop(skb, sch);
+			}
+			qdisc_tree_decrease_qlen(sch, oqlen - sch->q.qlen);
+			q->head =3D 0;
+			q->tail =3D tail;
+		}
+
+		q->tab_mask =3D mask;
+		q->tab =3D ntab;
+	} else
+		sch_tree_lock(sch);
+
+	q->flags =3D ctl->flags;
+	q->limit =3D ctl->limit;
+
+	red_set_parms(&q->parms, ctl->qth_min, ctl->qth_max, ctl->Wlog,
+		      ctl->Plog, ctl->Scell_log,
+		      nla_data(tb[TCA_CHOKE_STAB]));
+
+	if (q->head =3D=3D q->tail)
+		red_end_of_idle_period(&q->parms);
+
+	sch_tree_unlock(sch);
+	choke_free(old);
+	return 0;
+}
+
+static int choke_init(struct Qdisc *sch, struct nlattr *opt)
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
+	NLA_PUT(skb, TCA_CHOKE_PARMS, sizeof(opt), &opt);
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
+	struct tc_choke_xstats st =3D {
+		.early	=3D q->stats.prob_drop + q->stats.forced_drop,
+		.marked	=3D q->stats.prob_mark + q->stats.forced_mark,
+		.pdrop	=3D q->stats.pdrop,
+		.other	=3D q->stats.other,
+		.matched =3D q->stats.matched,
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
--- a/include/linux/pkt_sched.h	2011-01-14 10:43:19.092539898 -0800
+++ b/include/linux/pkt_sched.h	2011-01-16 13:42:45.926919103 -0800
@@ -247,6 +247,35 @@ struct tc_gred_sopt {
 	__u16		pad1;
 };
=20
+/* CHOKe section */
+
+enum {
+	TCA_CHOKE_UNSPEC,
+	TCA_CHOKE_PARMS,
+	TCA_CHOKE_STAB,
+	__TCA_CHOKE_MAX,
+};
+
+#define TCA_CHOKE_MAX (__TCA_CHOKE_MAX - 1)
+
+struct tc_choke_qopt {
+	__u32		limit;		/* Hard queue length (packets)	*/
+	__u32		qth_min;	/* Min average threshold (packets) */
+	__u32		qth_max;	/* Max average threshold (packets) */
+	unsigned char   Wlog;		/* log(W)		*/
+	unsigned char   Plog;		/* log(P_max/(qth_max-qth_min))	*/
+	unsigned char   Scell_log;	/* cell size for idle damping */
+	unsigned char	flags;		/* see RED flags */
+};
+
+struct tc_choke_xstats {
+	__u32		early;          /* Early drops */
+	__u32		pdrop;          /* Drops due to queue limits */
+	__u32		other;          /* Drops due to drop() calls */
+	__u32		marked;         /* Marked packets */
+	__u32		matched;	/* Drops due to flow match */
+};
+
 /* HTB section */
 #define TC_HTB_NUMPRIO		8
 #define TC_HTB_MAXDEPTH		8
