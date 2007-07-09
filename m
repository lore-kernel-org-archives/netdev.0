From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 04/05]: act_api: qdisc internal reclassify support
Date: Mon,  9 Jul 2007 22:46:18 +0200 (MEST)
Message-ID: <20070709204617.1461.70129.sendpatchset@localhost.localdomain>
References: <20070709204611.1461.16465.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41516 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755161AbXGIUqT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 16:46:19 -0400
In-Reply-To: <20070709204611.1461.16465.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET_SCHED]: act_api: qdisc internal reclassify support

The behaviour of NET_CLS_POLICE for TC_POLICE_RECLASSIFY was to return
it to the qdisc, which could handle it internally or ignore it. With
NET_CLS_ACT however, tc_classify starts over at the first classifier
and never returns it to the qdisc. This makes it impossible to support
qdisc-internal reclassification, which in turn makes it impossible to
remove the old NET_CLS_POLICE code without breaking compatibility since
we have two qdiscs (CBQ and ATM) that support this.

This patch adds a tc_classify_compat function that handles
reclassification the old way and changes CBQ and ATM to use it.

This again is of course not fully backwards compatible with the previous
NET_CLS_ACT behaviour. Unfortunately there is no way to fully maintain
compatibility *and* support qdisc internal reclassification with
NET_CLS_ACT, but this seems like the better choice over keeping the two
incompatible options around forever.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit e43a238efc6a97ee9fbff39dd414455561d9a941
tree 01aac86377be19007d65caf8141eb5c47e381322
parent 57dbe6717456e774fc1163d801eab312d7c092e5
author Patrick McHardy <kaber@trash.net> Mon, 09 Jul 2007 22:18:06 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 09 Jul 2007 22:18:06 +0200

 include/net/pkt_sched.h   |    4 ++-
 include/net/sch_generic.h |    2 +
 net/sched/sch_api.c       |   67 ++++++++++++++++++++++++++-------------------
 net/sched/sch_atm.c       |   11 ++++++-
 net/sched/sch_cbq.c       |   39 ++++++++++++++------------
 net/sched/sch_tbf.c       |    2 +
 6 files changed, 73 insertions(+), 52 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index 5754d53..9e22526 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -89,8 +89,10 @@ static inline void qdisc_run(struct net_device *dev)
 		__qdisc_run(dev);
 }
 
+extern int tc_classify_compat(struct sk_buff *skb, struct tcf_proto *tp,
+			      struct tcf_result *res);
 extern int tc_classify(struct sk_buff *skb, struct tcf_proto *tp,
-	struct tcf_result *res);
+		       struct tcf_result *res);
 
 /* Calculate maximal size of packet seen by hard_start_xmit
    routine of this device.
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 1b8e351..0153cd9 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -290,7 +290,7 @@ static inline int qdisc_reshape_fail(struct sk_buff *skb, struct Qdisc *sch)
 {
 	sch->qstats.drops++;
 
-#ifdef CONFIG_NET_CLS_POLICE
+#if defined(CONFIG_NET_CLS_ACT) || defined(CONFIG_NET_CLS_POLICE)
 	if (sch->reshape_fail == NULL || sch->reshape_fail(skb, sch))
 		goto drop;
 
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index d92ea26..1b35b41 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1149,47 +1149,57 @@ static int tc_dump_tclass(struct sk_buff *skb, struct netlink_callback *cb)
    to this qdisc, (optionally) tests for protocol and asks
    specific classifiers.
  */
+int tc_classify_compat(struct sk_buff *skb, struct tcf_proto *tp,
+		       struct tcf_result *res)
+{
+	__be16 protocol = skb->protocol;
+	int err = 0;
+
+	for (; tp; tp = tp->next) {
+		if ((tp->protocol == protocol ||
+		     tp->protocol == htons(ETH_P_ALL)) &&
+		    (err = tp->classify(skb, tp, res)) >= 0) {
+#ifdef CONFIG_NET_CLS_ACT
+			if (err != TC_ACT_RECLASSIFY && skb->tc_verd)
+				skb->tc_verd = SET_TC_VERD(skb->tc_verd, 0);
+#endif
+			return err;
+		}
+	}
+	return -1;
+}
+EXPORT_SYMBOL(tc_classify_compat);
+
 int tc_classify(struct sk_buff *skb, struct tcf_proto *tp,
-	struct tcf_result *res)
+		struct tcf_result *res)
 {
 	int err = 0;
-	__be16 protocol = skb->protocol;
+	__be16 protocol;
 #ifdef CONFIG_NET_CLS_ACT
 	struct tcf_proto *otp = tp;
 reclassify:
 #endif
 	protocol = skb->protocol;
 
-	for ( ; tp; tp = tp->next) {
-		if ((tp->protocol == protocol ||
-			tp->protocol == htons(ETH_P_ALL)) &&
-			(err = tp->classify(skb, tp, res)) >= 0) {
+	err = tc_classify_compat(skb, tp, res);
 #ifdef CONFIG_NET_CLS_ACT
-			if ( TC_ACT_RECLASSIFY == err) {
-				__u32 verd = (__u32) G_TC_VERD(skb->tc_verd);
-				tp = otp;
-
-				if (MAX_REC_LOOP < verd++) {
-					printk("rule prio %d protocol %02x reclassify is buggy packet dropped\n",
-						tp->prio&0xffff, ntohs(tp->protocol));
-					return TC_ACT_SHOT;
-				}
-				skb->tc_verd = SET_TC_VERD(skb->tc_verd,verd);
-				goto reclassify;
-			} else {
-				if (skb->tc_verd)
-					skb->tc_verd = SET_TC_VERD(skb->tc_verd,0);
-				return err;
-			}
-#else
-
-			return err;
-#endif
+	if (err == TC_ACT_RECLASSIFY) {
+		u32 verd = G_TC_VERD(skb->tc_verd);
+		tp = otp;
+
+		if (verd++ >= MAX_REC_LOOP) {
+			printk("rule prio %u protocol %02x reclassify loop, "
+			       "packet dropped\n",
+			       tp->prio&0xffff, ntohs(tp->protocol));
+			return TC_ACT_SHOT;
 		}
-
+		skb->tc_verd = SET_TC_VERD(skb->tc_verd, verd);
+		goto reclassify;
 	}
-	return -1;
+#endif
+	return err;
 }
+EXPORT_SYMBOL(tc_classify);
 
 void tcf_destroy(struct tcf_proto *tp)
 {
@@ -1256,4 +1266,3 @@ EXPORT_SYMBOL(qdisc_get_rtab);
 EXPORT_SYMBOL(qdisc_put_rtab);
 EXPORT_SYMBOL(register_qdisc);
 EXPORT_SYMBOL(unregister_qdisc);
-EXPORT_SYMBOL(tc_classify);
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index ccee10d..37ae6d1 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -396,8 +396,9 @@ static int atm_tc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	    !(flow = (struct atm_flow_data *)atm_tc_get(sch, skb->priority)))
 		for (flow = p->flows; flow; flow = flow->next)
 			if (flow->filter_list) {
-				result = tc_classify(skb, flow->filter_list,
-						     &res);
+				result = tc_classify_compat(skb,
+							    flow->filter_list,
+							    &res);
 				if (result < 0)
 					continue;
 				flow = (struct atm_flow_data *)res.class;
@@ -420,6 +421,12 @@ static int atm_tc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		case TC_ACT_SHOT:
 			kfree_skb(skb);
 			goto drop;
+		case TC_POLICE_RECLASSIFY:
+			if (flow->excess)
+				flow = flow->excess;
+			else
+				ATM_SKB(skb)->atm_options |= ATM_ATMOPT_CLP;
+			break;
 		}
 #elif defined(CONFIG_NET_CLS_POLICE)
 		switch (result) {
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index b184c35..77381f1 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -82,7 +82,7 @@ struct cbq_class
 	unsigned char		priority2;	/* priority to be used after overlimit */
 	unsigned char		ewma_log;	/* time constant for idle time calculation */
 	unsigned char		ovl_strategy;
-#ifdef CONFIG_NET_CLS_POLICE
+#if defined(CONFIG_NET_CLS_ACT) || defined(CONFIG_NET_CLS_POLICE)
 	unsigned char		police;
 #endif
 
@@ -154,7 +154,7 @@ struct cbq_sched_data
 	struct cbq_class	*active[TC_CBQ_MAXPRIO+1];	/* List of all classes
 								   with backlog */
 
-#ifdef CONFIG_NET_CLS_POLICE
+#if defined(CONFIG_NET_CLS_ACT) || defined(CONFIG_NET_CLS_POLICE)
 	struct cbq_class	*rx_class;
 #endif
 	struct cbq_class	*tx_class;
@@ -196,7 +196,7 @@ cbq_class_lookup(struct cbq_sched_data *q, u32 classid)
 	return NULL;
 }
 
-#ifdef CONFIG_NET_CLS_POLICE
+#if defined(CONFIG_NET_CLS_ACT) || defined(CONFIG_NET_CLS_POLICE)
 
 static struct cbq_class *
 cbq_reclassify(struct sk_buff *skb, struct cbq_class *this)
@@ -247,7 +247,8 @@ cbq_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 		/*
 		 * Step 2+n. Apply classifier.
 		 */
-		if (!head->filter_list || (result = tc_classify(skb, head->filter_list, &res)) < 0)
+		if (!head->filter_list ||
+		    (result = tc_classify_compat(skb, head->filter_list, &res)) < 0)
 			goto fallback;
 
 		if ((cl = (void*)res.class) == NULL) {
@@ -267,6 +268,8 @@ cbq_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 			*qerr = NET_XMIT_SUCCESS;
 		case TC_ACT_SHOT:
 			return NULL;
+		case TC_ACT_RECLASSIFY:
+			return cbq_reclassify(skb, cl);
 		}
 #elif defined(CONFIG_NET_CLS_POLICE)
 		switch (result) {
@@ -389,7 +392,7 @@ cbq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	int ret;
 	struct cbq_class *cl = cbq_classify(skb, sch, &ret);
 
-#ifdef CONFIG_NET_CLS_POLICE
+#if defined(CONFIG_NET_CLS_ACT) || defined(CONFIG_NET_CLS_POLICE)
 	q->rx_class = cl;
 #endif
 	if (cl == NULL) {
@@ -399,7 +402,7 @@ cbq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		return ret;
 	}
 
-#ifdef CONFIG_NET_CLS_POLICE
+#if defined(CONFIG_NET_CLS_ACT) || defined(CONFIG_NET_CLS_POLICE)
 	cl->q->__parent = sch;
 #endif
 	if ((ret = cl->q->enqueue(skb, cl->q)) == NET_XMIT_SUCCESS) {
@@ -434,7 +437,7 @@ cbq_requeue(struct sk_buff *skb, struct Qdisc *sch)
 
 	cbq_mark_toplevel(q, cl);
 
-#ifdef CONFIG_NET_CLS_POLICE
+#if defined(CONFIG_NET_CLS_ACT) || defined(CONFIG_NET_CLS_POLICE)
 	q->rx_class = cl;
 	cl->q->__parent = sch;
 #endif
@@ -670,7 +673,7 @@ static enum hrtimer_restart cbq_undelay(struct hrtimer *timer)
 }
 
 
-#ifdef CONFIG_NET_CLS_POLICE
+#if defined(CONFIG_NET_CLS_ACT) || defined(CONFIG_NET_CLS_POLICE)
 
 static int cbq_reshape_fail(struct sk_buff *skb, struct Qdisc *child)
 {
@@ -1364,7 +1367,7 @@ static int cbq_set_overlimit(struct cbq_class *cl, struct tc_cbq_ovl *ovl)
 	return 0;
 }
 
-#ifdef CONFIG_NET_CLS_POLICE
+#if defined(CONFIG_NET_CLS_ACT) || defined(CONFIG_NET_CLS_POLICE)
 static int cbq_set_police(struct cbq_class *cl, struct tc_cbq_police *p)
 {
 	cl->police = p->police;
@@ -1532,7 +1535,7 @@ rtattr_failure:
 	return -1;
 }
 
-#ifdef CONFIG_NET_CLS_POLICE
+#if defined(CONFIG_NET_CLS_ACT) || defined(CONFIG_NET_CLS_POLICE)
 static __inline__ int cbq_dump_police(struct sk_buff *skb, struct cbq_class *cl)
 {
 	unsigned char *b = skb_tail_pointer(skb);
@@ -1558,7 +1561,7 @@ static int cbq_dump_attr(struct sk_buff *skb, struct cbq_class *cl)
 	    cbq_dump_rate(skb, cl) < 0 ||
 	    cbq_dump_wrr(skb, cl) < 0 ||
 	    cbq_dump_ovl(skb, cl) < 0 ||
-#ifdef CONFIG_NET_CLS_POLICE
+#if defined(CONFIG_NET_CLS_ACT) || defined(CONFIG_NET_CLS_POLICE)
 	    cbq_dump_police(skb, cl) < 0 ||
 #endif
 	    cbq_dump_fopt(skb, cl) < 0)
@@ -1653,7 +1656,7 @@ static int cbq_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
 						     cl->classid)) == NULL)
 				return -ENOBUFS;
 		} else {
-#ifdef CONFIG_NET_CLS_POLICE
+#if defined(CONFIG_NET_CLS_ACT) || defined(CONFIG_NET_CLS_POLICE)
 			if (cl->police == TC_POLICE_RECLASSIFY)
 				new->reshape_fail = cbq_reshape_fail;
 #endif
@@ -1718,7 +1721,7 @@ cbq_destroy(struct Qdisc* sch)
 	struct cbq_class *cl;
 	unsigned h;
 
-#ifdef CONFIG_NET_CLS_POLICE
+#if defined(CONFIG_NET_CLS_ACT) || defined(CONFIG_NET_CLS_POLICE)
 	q->rx_class = NULL;
 #endif
 	/*
@@ -1747,7 +1750,7 @@ static void cbq_put(struct Qdisc *sch, unsigned long arg)
 	struct cbq_class *cl = (struct cbq_class*)arg;
 
 	if (--cl->refcnt == 0) {
-#ifdef CONFIG_NET_CLS_POLICE
+#if defined(CONFIG_NET_CLS_ACT) || defined(CONFIG_NET_CLS_POLICE)
 		struct cbq_sched_data *q = qdisc_priv(sch);
 
 		spin_lock_bh(&sch->dev->queue_lock);
@@ -1795,7 +1798,7 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct rtattr **t
 	    RTA_PAYLOAD(tb[TCA_CBQ_WRROPT-1]) < sizeof(struct tc_cbq_wrropt))
 			return -EINVAL;
 
-#ifdef CONFIG_NET_CLS_POLICE
+#if defined(CONFIG_NET_CLS_ACT) || defined(CONFIG_NET_CLS_POLICE)
 	if (tb[TCA_CBQ_POLICE-1] &&
 	    RTA_PAYLOAD(tb[TCA_CBQ_POLICE-1]) < sizeof(struct tc_cbq_police))
 			return -EINVAL;
@@ -1838,7 +1841,7 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct rtattr **t
 		if (tb[TCA_CBQ_OVL_STRATEGY-1])
 			cbq_set_overlimit(cl, RTA_DATA(tb[TCA_CBQ_OVL_STRATEGY-1]));
 
-#ifdef CONFIG_NET_CLS_POLICE
+#if defined(CONFIG_NET_CLS_ACT) || defined(CONFIG_NET_CLS_POLICE)
 		if (tb[TCA_CBQ_POLICE-1])
 			cbq_set_police(cl, RTA_DATA(tb[TCA_CBQ_POLICE-1]));
 #endif
@@ -1931,7 +1934,7 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct rtattr **t
 	cl->overlimit = cbq_ovl_classic;
 	if (tb[TCA_CBQ_OVL_STRATEGY-1])
 		cbq_set_overlimit(cl, RTA_DATA(tb[TCA_CBQ_OVL_STRATEGY-1]));
-#ifdef CONFIG_NET_CLS_POLICE
+#if defined(CONFIG_NET_CLS_ACT) || defined(CONFIG_NET_CLS_POLICE)
 	if (tb[TCA_CBQ_POLICE-1])
 		cbq_set_police(cl, RTA_DATA(tb[TCA_CBQ_POLICE-1]));
 #endif
@@ -1975,7 +1978,7 @@ static int cbq_delete(struct Qdisc *sch, unsigned long arg)
 		q->tx_class = NULL;
 		q->tx_borrowed = NULL;
 	}
-#ifdef CONFIG_NET_CLS_POLICE
+#if defined(CONFIG_NET_CLS_ACT) || defined(CONFIG_NET_CLS_POLICE)
 	if (q->rx_class == cl)
 		q->rx_class = NULL;
 #endif
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 22e431d..b8b3345 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -125,7 +125,7 @@ static int tbf_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 
 	if (skb->len > q->max_size) {
 		sch->qstats.drops++;
-#ifdef CONFIG_NET_CLS_POLICE
+#if defined(CONFIG_NET_CLS_ACT) || defined(CONFIG_NET_CLS_POLICE)
 		if (sch->reshape_fail == NULL || sch->reshape_fail(skb, sch))
 #endif
 			kfree_skb(skb);
