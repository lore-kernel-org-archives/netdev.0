From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 4/4]: fix CONFIG_NET_CLS_ACT skb leaks in HFSC/CBQ
Date: Wed, 19 Jan 2005 05:38:58 +0100
Message-ID: <41EDE462.9040602@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090400050402010302070004"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090400050402010302070004
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit



--------------090400050402010302070004
Content-Type: text/x-patch;
 name="04.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="04.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/19 05:15:16+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: fix CONFIG_NET_CLS_ACT skb leaks in HFSC/CBQ
#   
#   Both HFSC and CBQ leak unclassified skbs with CONFIG_NET_CLS_ACT.
#   Move freeing to enqueue where it belongs. Same change for in HTB/prio,
#   they just don't leak because they don't have unclassified packets.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/sch_prio.c
#   2005/01/19 05:15:07+01:00 kaber@coreworks.de +30 -44
#   [PKT_SCHED]: fix CONFIG_NET_CLS_ACT skb leaks in HFSC/CBQ
#   
#   Both HFSC and CBQ leak unclassified skbs with CONFIG_NET_CLS_ACT.
#   Move freeing to enqueue where it belongs. Same change for in HTB/prio,
#   they just don't leak because they don't have unclassified packets.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/sch_htb.c
#   2005/01/19 05:15:07+01:00 kaber@coreworks.de +16 -44
#   [PKT_SCHED]: fix CONFIG_NET_CLS_ACT skb leaks in HFSC/CBQ
#   
#   Both HFSC and CBQ leak unclassified skbs with CONFIG_NET_CLS_ACT.
#   Move freeing to enqueue where it belongs. Same change for in HTB/prio,
#   they just don't leak because they don't have unclassified packets.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/sch_hfsc.c
#   2005/01/19 05:15:07+01:00 kaber@coreworks.de +11 -34
#   [PKT_SCHED]: fix CONFIG_NET_CLS_ACT skb leaks in HFSC/CBQ
#   
#   Both HFSC and CBQ leak unclassified skbs with CONFIG_NET_CLS_ACT.
#   Move freeing to enqueue where it belongs. Same change for in HTB/prio,
#   they just don't leak because they don't have unclassified packets.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/sch_cbq.c
#   2005/01/19 05:15:07+01:00 kaber@coreworks.de +26 -53
#   [PKT_SCHED]: fix CONFIG_NET_CLS_ACT skb leaks in HFSC/CBQ
#   
#   Both HFSC and CBQ leak unclassified skbs with CONFIG_NET_CLS_ACT.
#   Move freeing to enqueue where it belongs. Same change for in HTB/prio,
#   they just don't leak because they classify all packets.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
--- a/net/sched/sch_cbq.c	2005-01-19 05:30:01 +01:00
+++ b/net/sched/sch_cbq.c	2005-01-19 05:30:01 +01:00
@@ -241,7 +241,7 @@
  */
 
 static struct cbq_class *
-cbq_classify(struct sk_buff *skb, struct Qdisc *sch, int *qres)
+cbq_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 {
 	struct cbq_sched_data *q = qdisc_priv(sch);
 	struct cbq_class *head = &q->link;
@@ -255,13 +255,11 @@
 	 */
 	if (TC_H_MAJ(prio^sch->handle) == 0 &&
 	    (cl = cbq_class_lookup(q, prio)) != NULL)
-			return cl;
+		return cl;
 
+	*qerr = NET_XMIT_DROP;
 	for (;;) {
 		int result = 0;
-#ifdef CONFIG_NET_CLS_ACT
-		int terminal = 0;
-#endif
 		defmap = head->defaults;
 
 		/*
@@ -282,27 +280,13 @@
 
 #ifdef CONFIG_NET_CLS_ACT
 		switch (result) {
-		case TC_ACT_SHOT: /* Stop and kfree */
-			*qres = NET_XMIT_DROP;
-			terminal = 1;
-			break;
 		case TC_ACT_QUEUED:
 		case TC_ACT_STOLEN: 
-			terminal = 1;
-			break;
-		case TC_ACT_RECLASSIFY:  /* Things look good */
-		case TC_ACT_OK: 
-		case TC_ACT_UNSPEC:
-		default:
-			break;
-		}
-
-		if (terminal) {
-			kfree_skb(skb);
+			*qerr = NET_XMIT_SUCCESS;
+		case TC_ACT_SHOT:
 			return NULL;
 		}
-#else
-#ifdef CONFIG_NET_CLS_POLICE
+#elif defined(CONFIG_NET_CLS_POLICE)
 		switch (result) {
 		case TC_POLICE_RECLASSIFY:
 			return cbq_reclassify(skb, cl);
@@ -312,7 +296,6 @@
 			break;
 		}
 #endif
-#endif
 		if (cl->level == 0)
 			return cl;
 
@@ -423,45 +406,35 @@
 {
 	struct cbq_sched_data *q = qdisc_priv(sch);
 	int len = skb->len;
-	int ret = NET_XMIT_SUCCESS;
-	struct cbq_class *cl = cbq_classify(skb, sch,&ret);
+	int ret;
+	struct cbq_class *cl = cbq_classify(skb, sch, &ret);
 
 #ifdef CONFIG_NET_CLS_POLICE
 	q->rx_class = cl;
 #endif
-	if (cl) {
-#ifdef CONFIG_NET_CLS_POLICE
-		cl->q->__parent = sch;
-#endif
-		if ((ret = cl->q->enqueue(skb, cl->q)) == NET_XMIT_SUCCESS) {
-			sch->q.qlen++;
-			sch->bstats.packets++;
-			sch->bstats.bytes+=len;
-			cbq_mark_toplevel(q, cl);
-			if (!cl->next_alive)
-				cbq_activate_class(cl);
-			return ret;
-		}
-	}
-
-#ifndef CONFIG_NET_CLS_ACT
-	sch->qstats.drops++;
-	if (cl == NULL)
+	if (cl == NULL) {
+		if (ret == NET_XMIT_DROP)
+			sch->qstats.drops++;
 		kfree_skb(skb);
-	else {
-		cbq_mark_toplevel(q, cl);
-		cl->qstats.drops++;
-	}
-#else
-	if ( NET_XMIT_DROP == ret) {
-		sch->qstats.drops++;
+		return ret;
 	}
 
-	if (cl != NULL) {
+#ifdef CONFIG_NET_CLS_POLICE
+	cl->q->__parent = sch;
+#endif
+	if ((ret = cl->q->enqueue(skb, cl->q)) == NET_XMIT_SUCCESS) {
+		sch->q.qlen++;
+		sch->bstats.packets++;
+		sch->bstats.bytes+=len;
 		cbq_mark_toplevel(q, cl);
-		cl->qstats.drops++;
+		if (!cl->next_alive)
+			cbq_activate_class(cl);
+		return ret;
 	}
-#endif
+
+	sch->qstats.drops++;
+	cbq_mark_toplevel(q, cl);
+	cl->qstats.drops++;
 	return ret;
 }
 
diff -Nru a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
--- a/net/sched/sch_hfsc.c	2005-01-19 05:30:01 +01:00
+++ b/net/sched/sch_hfsc.c	2005-01-19 05:30:01 +01:00
@@ -1214,7 +1214,7 @@
 }
 
 static struct hfsc_class *
-hfsc_classify(struct sk_buff *skb, struct Qdisc *sch, int *qres)
+hfsc_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 {
 	struct hfsc_sched *q = qdisc_priv(sch);
 	struct hfsc_class *cl;
@@ -1227,36 +1227,21 @@
 		if (cl->level == 0)
 			return cl;
 
+	*qerr = NET_XMIT_DROP;
 	tcf = q->root.filter_list;
 	while (tcf && (result = tc_classify(skb, tcf, &res)) >= 0) {
 #ifdef CONFIG_NET_CLS_ACT
-		int terminal = 0;
 		switch (result) {
-		case TC_ACT_SHOT: 
-			*qres = NET_XMIT_DROP;
-			terminal = 1;
-			break;
 		case TC_ACT_QUEUED:
 		case TC_ACT_STOLEN: 
-			terminal = 1;
-			break;
-		case TC_ACT_RECLASSIFY: 
-		case TC_ACT_OK:
-		case TC_ACT_UNSPEC:
-		default:
-		break;
-		}
-
-		if (terminal) {
-			kfree_skb(skb);
+			*qerr = NET_XMIT_SUCCESS;
+		case TC_ACT_SHOT: 
 			return NULL;
 		}
-#else
-#ifdef CONFIG_NET_CLS_POLICE
+#elif defined(CONFIG_NET_CLS_POLICE)
 		if (result == TC_POLICE_SHOT)
 			return NULL;
 #endif
-#endif
 		if ((cl = (struct hfsc_class *)res.class) == NULL) {
 			if ((cl = hfsc_find_class(res.classid, sch)) == NULL)
 				break; /* filter selected invalid classid */
@@ -1652,27 +1637,19 @@
 static int
 hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
-	int ret = NET_XMIT_SUCCESS;
-	struct hfsc_class *cl = hfsc_classify(skb, sch, &ret);
-	unsigned int len = skb->len;
+	struct hfsc_class *cl;
+	unsigned int len;
 	int err;
 
-
-#ifdef CONFIG_NET_CLS_ACT
+	cl = hfsc_classify(skb, sch, &err);
 	if (cl == NULL) {
-		if (NET_XMIT_DROP == ret) {
+		if (err == NET_XMIT_DROP)
 			sch->qstats.drops++;
-		}
-		return ret;
-	}
-#else
-	if (cl == NULL) {
 		kfree_skb(skb);
-		sch->qstats.drops++;
-		return NET_XMIT_DROP;
+		return err;
 	}
-#endif
 
+	len = skb->len;
 	err = cl->qdisc->enqueue(skb, cl->qdisc);
 	if (unlikely(err != NET_XMIT_SUCCESS)) {
 		cl->qstats.drops++;
diff -Nru a/net/sched/sch_htb.c b/net/sched/sch_htb.c
--- a/net/sched/sch_htb.c	2005-01-19 05:30:01 +01:00
+++ b/net/sched/sch_htb.c	2005-01-19 05:30:01 +01:00
@@ -305,7 +305,7 @@
 	return (cl && cl != HTB_DIRECT) ? cl->classid : TC_H_UNSPEC;
 }
 
-static struct htb_class *htb_classify(struct sk_buff *skb, struct Qdisc *sch, int *qres)
+static struct htb_class *htb_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 {
 	struct htb_sched *q = qdisc_priv(sch);
 	struct htb_class *cl;
@@ -321,35 +321,20 @@
 	if ((cl = htb_find(skb->priority,sch)) != NULL && cl->level == 0) 
 		return cl;
 
+	*qerr = NET_XMIT_DROP;
 	tcf = q->filter_list;
 	while (tcf && (result = tc_classify(skb, tcf, &res)) >= 0) {
 #ifdef CONFIG_NET_CLS_ACT
-		int terminal = 0;
 		switch (result) {
-		case TC_ACT_SHOT: /* Stop and kfree */
-			*qres = NET_XMIT_DROP;
-			terminal = 1;
-			break;
 		case TC_ACT_QUEUED:
 		case TC_ACT_STOLEN: 
-			terminal = 1;
-			break;
-		case TC_ACT_RECLASSIFY:  /* Things look good */
-		case TC_ACT_OK:
-		case TC_ACT_UNSPEC:
-		default:
-		break;
-		}
-
-		if (terminal) {
-			kfree_skb(skb);
+			*qerr = NET_XMIT_SUCCESS;
+		case TC_ACT_SHOT:
 			return NULL;
 		}
-#else
-#ifdef CONFIG_NET_CLS_POLICE
+#elif defined(CONFIG_NET_CLS_POLICE)
 		if (result == TC_POLICE_SHOT)
-			return NULL;
-#endif
+			return HTB_DIRECT;
 #endif
 		if ((cl = (void*)res.class) == NULL) {
 			if (res.classid == sch->handle)
@@ -723,37 +708,24 @@
 
 static int htb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
-    int ret = NET_XMIT_SUCCESS;
+    int ret;
     struct htb_sched *q = qdisc_priv(sch);
     struct htb_class *cl = htb_classify(skb,sch,&ret);
 
-
-#ifdef CONFIG_NET_CLS_ACT
-    if (cl == HTB_DIRECT ) {
-	if (q->direct_queue.qlen < q->direct_qlen ) {
-	    __skb_queue_tail(&q->direct_queue, skb);
-	    q->direct_pkts++;
-	}
-    } else if (!cl) {
-	    if (NET_XMIT_DROP == ret) {
-		    sch->qstats.drops++;
-	    }
-	    return ret;
-    }
-#else
-    if (cl == HTB_DIRECT || !cl) {
+    if (cl == HTB_DIRECT) {
 	/* enqueue to helper queue */
-	if (q->direct_queue.qlen < q->direct_qlen && cl) {
+	if (q->direct_queue.qlen < q->direct_qlen) {
 	    __skb_queue_tail(&q->direct_queue, skb);
 	    q->direct_pkts++;
-	} else {
-	    kfree_skb (skb);
-	    sch->qstats.drops++;
-	    return NET_XMIT_DROP;
 	}
-    }
+#ifdef CONFIG_NET_CLS_ACT
+    } else if (!cl) {
+	if (ret == NET_XMIT_DROP)
+		sch->qstats.drops++;
+	kfree_skb (skb);
+	return ret;
 #endif
-    else if (cl->un.leaf.q->enqueue(skb, cl->un.leaf.q) != NET_XMIT_SUCCESS) {
+    } else if (cl->un.leaf.q->enqueue(skb, cl->un.leaf.q) != NET_XMIT_SUCCESS) {
 	sch->qstats.drops++;
 	cl->qstats.drops++;
 	return NET_XMIT_DROP;
diff -Nru a/net/sched/sch_prio.c b/net/sched/sch_prio.c
--- a/net/sched/sch_prio.c	2005-01-19 05:30:01 +01:00
+++ b/net/sched/sch_prio.c	2005-01-19 05:30:01 +01:00
@@ -47,37 +47,23 @@
 };
 
 
-static struct Qdisc *prio_classify(struct sk_buff *skb,
-				   struct Qdisc *sch, int *r)
+static struct Qdisc *
+prio_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 {
 	struct prio_sched_data *q = qdisc_priv(sch);
 	u32 band = skb->priority;
 	struct tcf_result res;
 
+	*qerr = NET_XMIT_DROP;
 	if (TC_H_MAJ(skb->priority) != sch->handle) {
 #ifdef CONFIG_NET_CLS_ACT
-		int result = 0, terminal = 0;
-		result = tc_classify(skb, q->filter_list, &res);
-
-		switch (result) {
-			case TC_ACT_SHOT:
-				*r = NET_XMIT_DROP;
-				terminal = 1;
-				break;
-			case TC_ACT_STOLEN:
-			case TC_ACT_QUEUED:
-				terminal = 1;
-				break;
-			case TC_ACT_RECLASSIFY:
-			case TC_ACT_OK:
-			case TC_ACT_UNSPEC:
-			default:
-			break;
-		};
-		if (terminal) {
-			kfree_skb(skb);
+		switch (tc_classify(skb, q->filter_list, &res)) {
+		case TC_ACT_STOLEN:
+		case TC_ACT_QUEUED:
+			*qerr = NET_XMIT_SUCCESS;
+		case TC_ACT_SHOT:
 			return NULL;
-		} 
+		};
 
 		if (!q->filter_list ) {
 #else
@@ -97,15 +83,20 @@
 }
 
 static int
-prio_enqueue(struct sk_buff *skb, struct Qdisc* sch)
+prio_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct Qdisc *qdisc;
-	int ret = NET_XMIT_SUCCESS;
+	int ret;
 
 	qdisc = prio_classify(skb, sch, &ret);
-
-	if (NULL == qdisc)
-		goto dropped;
+#ifdef CONFIG_NET_CLS_ACT
+	if (qdisc == NULL) {
+		if (ret == NET_XMIT_DROP)
+			sch->qstats.drops++;
+		kfree_skb(skb);
+		return ret;
+	}
+#endif
 
 	if ((ret = qdisc->enqueue(skb, qdisc)) == NET_XMIT_SUCCESS) {
 		sch->bstats.bytes += skb->len;
@@ -113,17 +104,7 @@
 		sch->q.qlen++;
 		return NET_XMIT_SUCCESS;
 	}
-
-dropped:
-#ifdef CONFIG_NET_CLS_ACT
-	if (NET_XMIT_DROP == ret) {
-#endif
-		sch->qstats.drops++;
-#ifdef CONFIG_NET_CLS_ACT
-	} else {
-		sch->qstats.overlimits++; /* abuse, but noone uses it */
-	}
-#endif
+	sch->qstats.drops++;
 	return ret; 
 }
 
@@ -132,18 +113,23 @@
 prio_requeue(struct sk_buff *skb, struct Qdisc* sch)
 {
 	struct Qdisc *qdisc;
-	int ret = NET_XMIT_DROP;
+	int ret;
 
 	qdisc = prio_classify(skb, sch, &ret);
-	if (qdisc == NULL)
-		goto dropped;
+#ifdef CONFIG_NET_CLS_ACT
+	if (qdisc == NULL) {
+		if (ret == NET_XMIT_DROP)
+			sch->qstats.drops++;
+		kfree_skb(skb);
+		return ret;
+	}
+#endif
 
-	if ((ret = qdisc->ops->requeue(skb, qdisc)) == 0) {
+	if ((ret = qdisc->ops->requeue(skb, qdisc)) == NET_XMIT_SUCCESS) {
 		sch->q.qlen++;
 		sch->qstats.requeues++;
 		return 0;
 	}
-dropped:
 	sch->qstats.drops++;
 	return NET_XMIT_DROP;
 }

--------------090400050402010302070004--
