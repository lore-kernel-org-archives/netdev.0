From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next 2/4] cbq: remove TCA_CBQ_POLICE support
Date: Wed,  8 Jun 2016 17:35:39 +0200
Message-ID: <1465400141-29088-3-git-send-email-fw@strlen.de>
References: <1465400141-29088-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:59858 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161902AbcFHPfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 11:35:31 -0400
In-Reply-To: <1465400141-29088-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

iproute2 doesn't implement any cbq option that results in this attribute
being sent to kernel.

To make use of it, user would have to

- patch iproute2
- add a class
- attach a qdisc to the class (default pfifo doesn't work as
  q->handle is 0 and cbq_set_police() is a no-op in this case)
- re-'add' the same class (tc class change ...) again
- user must also specifiy a defmap (e.g. 'split 1:0 defmap 3f'), since
  this 'police' feature relies on its presence
- the added qdisc must be one of bfifo, pfifo or netem

If all of these conditions are met and _some_ leaf qdiscs, namely
p/bfifo, netem, plug or tbf would drop a packet, kernel calls back into
cbq, which will attempt to re-queue the skb into a different class
as indicated by the parents' defmap entry for TC_PRIO_BESTEFFORT.

[ i.e. we behave as if tc_classify returned TC_ACT_RECLASSIFY ].

This feature, which isn't documented or implemented in iproute2,
and isn't implemented consistently (most qdiscs like sfq, codel, etc
drop right away instead of attempting this reclassification) is the
sole reason for the reshape_fail and __parent member in Qdisc struct.

So remove TCA_CBQ_POLICE support from the kernel, reject it via EOPNOTSUPP
so userspace knows we don't support it, and then remove no-longer needed
infrastructure in followup commit.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/sch_generic.h |  4 --
 net/sched/sch_cbq.c       | 95 +----------------------------------------------
 2 files changed, 1 insertion(+), 98 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index c4f5749..c069ac1 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -68,10 +68,6 @@ struct Qdisc {
 
 	void			*u32_node;
 
-	/* This field is deprecated, but it is still used by CBQ
-	 * and it will live until better solution will be invented.
-	 */
-	struct Qdisc		*__parent;
 	struct netdev_queue	*dev_queue;
 
 	struct gnet_stats_rate_est64	rate_est;
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index fdca45e..7f4d6c5 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -80,9 +80,6 @@ struct cbq_class {
 	unsigned char		priority;	/* class priority */
 	unsigned char		priority2;	/* priority to be used after overlimit */
 	unsigned char		ewma_log;	/* time constant for idle time calculation */
-#ifdef CONFIG_NET_CLS_ACT
-	unsigned char		police;
-#endif
 
 	u32			defmap;
 
@@ -377,9 +374,6 @@ cbq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		return ret;
 	}
 
-#ifdef CONFIG_NET_CLS_ACT
-	cl->q->__parent = sch;
-#endif
 	ret = qdisc_enqueue(skb, cl->q);
 	if (ret == NET_XMIT_SUCCESS) {
 		sch->q.qlen++;
@@ -524,40 +518,6 @@ static enum hrtimer_restart cbq_undelay(struct hrtimer *timer)
 	return HRTIMER_NORESTART;
 }
 
-#ifdef CONFIG_NET_CLS_ACT
-static int cbq_reshape_fail(struct sk_buff *skb, struct Qdisc *child)
-{
-	struct Qdisc *sch = child->__parent;
-	struct cbq_sched_data *q = qdisc_priv(sch);
-	struct cbq_class *cl = q->rx_class;
-
-	q->rx_class = NULL;
-
-	if (cl && (cl = cbq_reclassify(skb, cl)) != NULL) {
-		int ret;
-
-		cbq_mark_toplevel(q, cl);
-
-		q->rx_class = cl;
-		cl->q->__parent = sch;
-
-		ret = qdisc_enqueue(skb, cl->q);
-		if (ret == NET_XMIT_SUCCESS) {
-			sch->q.qlen++;
-			if (!cl->next_alive)
-				cbq_activate_class(cl);
-			return 0;
-		}
-		if (net_xmit_drop_count(ret))
-			qdisc_qstats_drop(sch);
-		return 0;
-	}
-
-	qdisc_qstats_drop(sch);
-	return -1;
-}
-#endif
-
 /*
  * It is mission critical procedure.
  *
@@ -1179,21 +1139,6 @@ static int cbq_set_wrr(struct cbq_class *cl, struct tc_cbq_wrropt *wrr)
 	return 0;
 }
 
-#ifdef CONFIG_NET_CLS_ACT
-static int cbq_set_police(struct cbq_class *cl, struct tc_cbq_police *p)
-{
-	cl->police = p->police;
-
-	if (cl->q->handle) {
-		if (p->police == TC_POLICE_RECLASSIFY)
-			cl->q->reshape_fail = cbq_reshape_fail;
-		else
-			cl->q->reshape_fail = NULL;
-	}
-	return 0;
-}
-#endif
-
 static int cbq_set_fopt(struct cbq_class *cl, struct tc_cbq_fopt *fopt)
 {
 	cbq_change_defmap(cl, fopt->split, fopt->defmap, fopt->defchange);
@@ -1350,35 +1295,11 @@ nla_put_failure:
 	return -1;
 }
 
-#ifdef CONFIG_NET_CLS_ACT
-static int cbq_dump_police(struct sk_buff *skb, struct cbq_class *cl)
-{
-	unsigned char *b = skb_tail_pointer(skb);
-	struct tc_cbq_police opt;
-
-	if (cl->police) {
-		opt.police = cl->police;
-		opt.__res1 = 0;
-		opt.__res2 = 0;
-		if (nla_put(skb, TCA_CBQ_POLICE, sizeof(opt), &opt))
-			goto nla_put_failure;
-	}
-	return skb->len;
-
-nla_put_failure:
-	nlmsg_trim(skb, b);
-	return -1;
-}
-#endif
-
 static int cbq_dump_attr(struct sk_buff *skb, struct cbq_class *cl)
 {
 	if (cbq_dump_lss(skb, cl) < 0 ||
 	    cbq_dump_rate(skb, cl) < 0 ||
 	    cbq_dump_wrr(skb, cl) < 0 ||
-#ifdef CONFIG_NET_CLS_ACT
-	    cbq_dump_police(skb, cl) < 0 ||
-#endif
 	    cbq_dump_fopt(skb, cl) < 0)
 		return -1;
 	return 0;
@@ -1468,11 +1389,6 @@ static int cbq_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
 					&pfifo_qdisc_ops, cl->common.classid);
 		if (new == NULL)
 			return -ENOBUFS;
-	} else {
-#ifdef CONFIG_NET_CLS_ACT
-		if (cl->police == TC_POLICE_RECLASSIFY)
-			new->reshape_fail = cbq_reshape_fail;
-#endif
 	}
 
 	*old = qdisc_replace(sch, new, &cl->q);
@@ -1585,7 +1501,7 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct nlattr **t
 	if (err < 0)
 		return err;
 
-	if (tb[TCA_CBQ_OVL_STRATEGY])
+	if (tb[TCA_CBQ_OVL_STRATEGY] || tb[TCA_CBQ_POLICE])
 		return -EOPNOTSUPP;
 
 	if (cl) {
@@ -1636,11 +1552,6 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct nlattr **t
 			cbq_set_wrr(cl, nla_data(tb[TCA_CBQ_WRROPT]));
 		}
 
-#ifdef CONFIG_NET_CLS_ACT
-		if (tb[TCA_CBQ_POLICE])
-			cbq_set_police(cl, nla_data(tb[TCA_CBQ_POLICE]));
-#endif
-
 		if (tb[TCA_CBQ_FOPT])
 			cbq_set_fopt(cl, nla_data(tb[TCA_CBQ_FOPT]));
 
@@ -1736,10 +1647,6 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct nlattr **t
 		cl->maxidle = q->link.maxidle;
 	if (cl->avpkt == 0)
 		cl->avpkt = q->link.avpkt;
-#ifdef CONFIG_NET_CLS_ACT
-	if (tb[TCA_CBQ_POLICE])
-		cbq_set_police(cl, nla_data(tb[TCA_CBQ_POLICE]));
-#endif
 	if (tb[TCA_CBQ_FOPT])
 		cbq_set_fopt(cl, nla_data(tb[TCA_CBQ_FOPT]));
 	sch_tree_unlock(sch);
-- 
2.7.3
