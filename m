From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 09/11]: Unline tcf_destroy
Date: Fri, 23 Mar 2007 14:35:50 +0100 (MET)
Message-ID: <20070323133525.10264.58638.sendpatchset@localhost.localdomain>
References: <20070323133513.10264.16515.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61437 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934283AbXCWNfw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2007 09:35:52 -0400
In-Reply-To: <20070323133513.10264.16515.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET_SCHED]: Unline tcf_destroy

Uninline tcf_destroy and add a helper function to destroy an entire filter
chain.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 8da4bcec7e54c8344c8fd77c72a61f24ce12cfc3
tree 7f36f4af8e9413637fb9b65501f281fd8a915da3
parent 231788aa3b9eef85b72ecac2e33441bd842ce3f4
author Patrick McHardy <kaber@trash.net> Fri, 23 Mar 2007 10:31:31 +0100
committer Patrick McHardy <kaber@trash.net> Fri, 23 Mar 2007 10:31:31 +0100

 include/net/sch_generic.h |   10 ++--------
 net/sched/sch_api.c       |   18 ++++++++++++++++++
 net/sched/sch_atm.c       |   17 ++---------------
 net/sched/sch_cbq.c       |   14 ++------------
 net/sched/sch_dsmark.c    |    8 +-------
 net/sched/sch_hfsc.c      |   13 +------------
 net/sched/sch_htb.c       |   14 ++------------
 net/sched/sch_ingress.c   |    7 +------
 net/sched/sch_prio.c      |    7 +------
 9 files changed, 30 insertions(+), 78 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index a3f4ddd..1b8e351 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -177,14 +177,8 @@ extern void qdisc_tree_decrease_qlen(struct Qdisc *qdisc, unsigned int n);
 extern struct Qdisc *qdisc_alloc(struct net_device *dev, struct Qdisc_ops *ops);
 extern struct Qdisc *qdisc_create_dflt(struct net_device *dev,
 				       struct Qdisc_ops *ops, u32 parentid);
-
-static inline void
-tcf_destroy(struct tcf_proto *tp)
-{
-	tp->ops->destroy(tp);
-	module_put(tp->ops->owner);
-	kfree(tp);
-}
+extern void tcf_destroy(struct tcf_proto *tp);
+extern void tcf_destroy_chain(struct tcf_proto *fl);
 
 static inline int __qdisc_enqueue_tail(struct sk_buff *skb, struct Qdisc *sch,
 				       struct sk_buff_head *list)
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 5873250..5b5bce0 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1220,6 +1220,24 @@ reclassify:
 	return -1;
 }
 
+void tcf_destroy(struct tcf_proto *tp)
+{
+	tp->ops->destroy(tp);
+	module_put(tp->ops->owner);
+	kfree(tp);
+}
+
+void tcf_destroy_chain(struct tcf_proto *fl)
+{
+	struct tcf_proto *tp;
+
+	while ((tp = fl) != NULL) {
+		fl = tp->next;
+		tcf_destroy(tp);
+	}
+}
+EXPORT_SYMBOL(tcf_destroy_chain);
+
 #ifdef CONFIG_PROC_FS
 static int psched_show(struct seq_file *seq, void *v)
 {
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 0cc3c9b..be7d299 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -158,19 +158,6 @@ static unsigned long atm_tc_bind_filter(struct Qdisc *sch,
 	return atm_tc_get(sch,classid);
 }
 
-
-static void destroy_filters(struct atm_flow_data *flow)
-{
-	struct tcf_proto *filter;
-
-	while ((filter = flow->filter_list)) {
-		DPRINTK("destroy_filters: destroying filter %p\n",filter);
-		flow->filter_list = filter->next;
-		tcf_destroy(filter);
-	}
-}
-
-
 /*
  * atm_tc_put handles all destructions, including the ones that are explicitly
  * requested (atm_tc_destroy, etc.). The assumption here is that we never drop
@@ -195,7 +182,7 @@ static void atm_tc_put(struct Qdisc *sch, unsigned long cl)
 	*prev = flow->next;
 	DPRINTK("atm_tc_put: qdisc %p\n",flow->q);
 	qdisc_destroy(flow->q);
-	destroy_filters(flow);
+	tcf_destroy_chain(flow->filter_list);
 	if (flow->sock) {
 		DPRINTK("atm_tc_put: f_count %d\n",
 		    file_count(flow->sock->file));
@@ -611,7 +598,7 @@ static void atm_tc_destroy(struct Qdisc *sch)
 	DPRINTK("atm_tc_destroy(sch %p,[qdisc %p])\n",sch,p);
 	/* races ? */
 	while ((flow = p->flows)) {
-		destroy_filters(flow);
+		tcf_destroy_chain(flow->filter_list);
 		if (flow->ref > 1)
 			printk(KERN_ERR "atm_destroy: %p->ref = %d\n",flow,
 			    flow->ref);
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 414a97c..a294542 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -1717,23 +1717,13 @@ static unsigned long cbq_get(struct Qdisc *sch, u32 classid)
 	return 0;
 }
 
-static void cbq_destroy_filters(struct cbq_class *cl)
-{
-	struct tcf_proto *tp;
-
-	while ((tp = cl->filter_list) != NULL) {
-		cl->filter_list = tp->next;
-		tcf_destroy(tp);
-	}
-}
-
 static void cbq_destroy_class(struct Qdisc *sch, struct cbq_class *cl)
 {
 	struct cbq_sched_data *q = qdisc_priv(sch);
 
 	BUG_TRAP(!cl->filters);
 
-	cbq_destroy_filters(cl);
+	tcf_destroy_chain(cl->filter_list);
 	qdisc_destroy(cl->q);
 	qdisc_put_rtab(cl->R_tab);
 #ifdef CONFIG_NET_ESTIMATOR
@@ -1760,7 +1750,7 @@ cbq_destroy(struct Qdisc* sch)
 	 */
 	for (h = 0; h < 16; h++)
 		for (cl = q->classes[h]; cl; cl = cl->next)
-			cbq_destroy_filters(cl);
+			tcf_destroy_chain(cl->filter_list);
 
 	for (h = 0; h < 16; h++) {
 		struct cbq_class *next;
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 2c857af..e38e0d0 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -412,16 +412,10 @@ static void dsmark_reset(struct Qdisc *sch)
 static void dsmark_destroy(struct Qdisc *sch)
 {
 	struct dsmark_qdisc_data *p = PRIV(sch);
-	struct tcf_proto *tp;
 
 	DPRINTK("dsmark_destroy(sch %p,[qdisc %p])\n", sch, p);
 
-	while (p->filter_list) {
-		tp = p->filter_list;
-		p->filter_list = tp->next;
-		tcf_destroy(tp);
-	}
-
+	tcf_destroy_chain(p->filter_list);
 	qdisc_destroy(p->q);
 	kfree(p->mask);
 }
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 0913f71..22cec11 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1122,22 +1122,11 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 }
 
 static void
-hfsc_destroy_filters(struct tcf_proto **fl)
-{
-	struct tcf_proto *tp;
-
-	while ((tp = *fl) != NULL) {
-		*fl = tp->next;
-		tcf_destroy(tp);
-	}
-}
-
-static void
 hfsc_destroy_class(struct Qdisc *sch, struct hfsc_class *cl)
 {
 	struct hfsc_sched *q = qdisc_priv(sch);
 
-	hfsc_destroy_filters(&cl->filter_list);
+	tcf_destroy_chain(cl->filter_list);
 	qdisc_destroy(cl->qdisc);
 #ifdef CONFIG_NET_ESTIMATOR
 	gen_kill_estimator(&cl->bstats, &cl->rate_est);
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 00f4c4f..71db121 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1236,16 +1236,6 @@ static unsigned long htb_get(struct Qdisc *sch, u32 classid)
 	return (unsigned long)cl;
 }
 
-static void htb_destroy_filters(struct tcf_proto **fl)
-{
-	struct tcf_proto *tp;
-
-	while ((tp = *fl) != NULL) {
-		*fl = tp->next;
-		tcf_destroy(tp);
-	}
-}
-
 static inline int htb_parent_last_child(struct htb_class *cl)
 {
 	if (!cl->parent)
@@ -1289,7 +1279,7 @@ static void htb_destroy_class(struct Qdisc *sch, struct htb_class *cl)
 	qdisc_put_rtab(cl->rate);
 	qdisc_put_rtab(cl->ceil);
 
-	htb_destroy_filters(&cl->filter_list);
+	tcf_destroy_chain(cl->filter_list);
 
 	while (!list_empty(&cl->children))
 		htb_destroy_class(sch, list_entry(cl->children.next,
@@ -1321,7 +1311,7 @@ static void htb_destroy(struct Qdisc *sch)
 	   and surprisingly it worked in 2.4. But it must precede it
 	   because filter need its target class alive to be able to call
 	   unbind_filter on it (without Oops). */
-	htb_destroy_filters(&q->filter_list);
+	tcf_destroy_chain(q->filter_list);
 
 	while (!list_empty(&q->root))
 		htb_destroy_class(sch, list_entry(q->root.next,
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index f63d5c6..1fb60ab 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -346,14 +346,9 @@ static void ingress_reset(struct Qdisc *sch)
 static void ingress_destroy(struct Qdisc *sch)
 {
 	struct ingress_qdisc_data *p = PRIV(sch);
-	struct tcf_proto *tp;
 
 	DPRINTK("ingress_destroy(sch %p,[qdisc %p])\n", sch, p);
-	while (p->filter_list) {
-		tp = p->filter_list;
-		p->filter_list = tp->next;
-		tcf_destroy(tp);
-	}
+	tcf_destroy_chain(p->filter_list);
 #if 0
 /* for future use */
 	qdisc_destroy(p->q);
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index f139963..5cfe60b 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -189,13 +189,8 @@ prio_destroy(struct Qdisc* sch)
 {
 	int prio;
 	struct prio_sched_data *q = qdisc_priv(sch);
-	struct tcf_proto *tp;
-
-	while ((tp = q->filter_list) != NULL) {
-		q->filter_list = tp->next;
-		tcf_destroy(tp);
-	}
 
+	tcf_destroy_chain(q->filter_list);
 	for (prio=0; prio<q->bands; prio++)
 		qdisc_destroy(q->queues[prio]);
 }
