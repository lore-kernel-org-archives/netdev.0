From: Patrick McHardy <kaber@trash.net>
Subject: net-sched 01/02: change tcf_destroy_chain() to clear start of filter
 list
Date: Tue, 01 Jul 2008 12:06:22 +0200
Message-ID: <486A019E.7000200@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090607010308000309050105"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63862 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752253AbYGAKGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2008 06:06:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090607010308000309050105
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

These two patches fix a potential use-after-free in hfsc
and atm filter destruction. All filters must be destroyed
before beginning class destruction since the destination
class must still be alive to unbind the filter.



--------------090607010308000309050105
Content-Type: text/x-diff;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

commit 887cfcf1e17d3c387dd43bb85f184253134648e4
Author: Patrick McHardy <kaber@trash.net>
Date:   Thu Jun 26 18:31:02 2008 +0200

    net-sched: change tcf_destroy_chain() to clear start of filter list
    
    Pass double tcf_proto pointers to tcf_destroy_chain() to make it
    clear the start of the filter list for more consistency.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index ab502ec..a87fc03 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -178,7 +178,7 @@ extern struct Qdisc *qdisc_alloc(struct net_device *dev, struct Qdisc_ops *ops);
 extern struct Qdisc *qdisc_create_dflt(struct net_device *dev,
 				       struct Qdisc_ops *ops, u32 parentid);
 extern void tcf_destroy(struct tcf_proto *tp);
-extern void tcf_destroy_chain(struct tcf_proto *fl);
+extern void tcf_destroy_chain(struct tcf_proto **fl);
 
 static inline int __qdisc_enqueue_tail(struct sk_buff *skb, struct Qdisc *sch,
 				       struct sk_buff_head *list)
diff --git a/net/mac80211/wme.c b/net/mac80211/wme.c
index cfa8fbb..58d8b1b 100644
--- a/net/mac80211/wme.c
+++ b/net/mac80211/wme.c
@@ -308,8 +308,7 @@ static void wme_qdiscop_destroy(struct Qdisc* qd)
 	struct ieee80211_hw *hw = &local->hw;
 	int queue;
 
-	tcf_destroy_chain(q->filter_list);
-	q->filter_list = NULL;
+	tcf_destroy_chain(&q->filter_list);
 
 	for (queue = 0; queue < QD_NUM(hw); queue++) {
 		skb_queue_purge(&q->requeued[queue]);
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index c40773c..10f01ad 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1252,12 +1252,12 @@ void tcf_destroy(struct tcf_proto *tp)
 	kfree(tp);
 }
 
-void tcf_destroy_chain(struct tcf_proto *fl)
+void tcf_destroy_chain(struct tcf_proto **fl)
 {
 	struct tcf_proto *tp;
 
-	while ((tp = fl) != NULL) {
-		fl = tp->next;
+	while ((tp = *fl) != NULL) {
+		*fl = tp->next;
 		tcf_destroy(tp);
 	}
 }
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 3352734..8e5f70b 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -160,7 +160,7 @@ static void atm_tc_put(struct Qdisc *sch, unsigned long cl)
 	*prev = flow->next;
 	pr_debug("atm_tc_put: qdisc %p\n", flow->q);
 	qdisc_destroy(flow->q);
-	tcf_destroy_chain(flow->filter_list);
+	tcf_destroy_chain(&flow->filter_list);
 	if (flow->sock) {
 		pr_debug("atm_tc_put: f_count %d\n",
 			file_count(flow->sock->file));
@@ -588,8 +588,7 @@ static void atm_tc_destroy(struct Qdisc *sch)
 	pr_debug("atm_tc_destroy(sch %p,[qdisc %p])\n", sch, p);
 	/* races ? */
 	while ((flow = p->flows)) {
-		tcf_destroy_chain(flow->filter_list);
-		flow->filter_list = NULL;
+		tcf_destroy_chain(&flow->filter_list);
 		if (flow->ref > 1)
 			printk(KERN_ERR "atm_destroy: %p->ref = %d\n", flow,
 			       flow->ref);
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 09969c1..2a3c97f 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -1704,7 +1704,7 @@ static void cbq_destroy_class(struct Qdisc *sch, struct cbq_class *cl)
 
 	BUG_TRAP(!cl->filters);
 
-	tcf_destroy_chain(cl->filter_list);
+	tcf_destroy_chain(&cl->filter_list);
 	qdisc_destroy(cl->q);
 	qdisc_put_rtab(cl->R_tab);
 	gen_kill_estimator(&cl->bstats, &cl->rate_est);
@@ -1728,10 +1728,8 @@ cbq_destroy(struct Qdisc* sch)
 	 * be bound to classes which have been destroyed already. --TGR '04
 	 */
 	for (h = 0; h < 16; h++) {
-		for (cl = q->classes[h]; cl; cl = cl->next) {
-			tcf_destroy_chain(cl->filter_list);
-			cl->filter_list = NULL;
-		}
+		for (cl = q->classes[h]; cl; cl = cl->next)
+			tcf_destroy_chain(&cl->filter_list);
 	}
 	for (h = 0; h < 16; h++) {
 		struct cbq_class *next;
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 64465ba..c4c1317 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -416,7 +416,7 @@ static void dsmark_destroy(struct Qdisc *sch)
 
 	pr_debug("dsmark_destroy(sch %p,[qdisc %p])\n", sch, p);
 
-	tcf_destroy_chain(p->filter_list);
+	tcf_destroy_chain(&p->filter_list);
 	qdisc_destroy(p->q);
 	kfree(p->mask);
 }
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index fdfaa3f..eca83a3 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1123,7 +1123,7 @@ hfsc_destroy_class(struct Qdisc *sch, struct hfsc_class *cl)
 {
 	struct hfsc_sched *q = qdisc_priv(sch);
 
-	tcf_destroy_chain(cl->filter_list);
+	tcf_destroy_chain(&cl->filter_list);
 	qdisc_destroy(cl->qdisc);
 	gen_kill_estimator(&cl->bstats, &cl->rate_est);
 	if (cl != &q->root)
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 2cef8f3..0284791 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1236,7 +1236,7 @@ static void htb_destroy_class(struct Qdisc *sch, struct htb_class *cl)
 	qdisc_put_rtab(cl->rate);
 	qdisc_put_rtab(cl->ceil);
 
-	tcf_destroy_chain(cl->filter_list);
+	tcf_destroy_chain(&cl->filter_list);
 
 	while (!list_empty(&cl->children))
 		htb_destroy_class(sch, list_entry(cl->children.next,
@@ -1265,7 +1265,7 @@ static void htb_destroy(struct Qdisc *sch)
 	   and surprisingly it worked in 2.4. But it must precede it
 	   because filter need its target class alive to be able to call
 	   unbind_filter on it (without Oops). */
-	tcf_destroy_chain(q->filter_list);
+	tcf_destroy_chain(&q->filter_list);
 
 	while (!list_empty(&q->root))
 		htb_destroy_class(sch, list_entry(q->root.next,
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index 274b1dd..956c80a 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -104,7 +104,7 @@ static void ingress_destroy(struct Qdisc *sch)
 {
 	struct ingress_qdisc_data *p = qdisc_priv(sch);
 
-	tcf_destroy_chain(p->filter_list);
+	tcf_destroy_chain(&p->filter_list);
 }
 
 static int ingress_dump(struct Qdisc *sch, struct sk_buff *skb)
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 4aa2b45..5532f10 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -219,7 +219,7 @@ prio_destroy(struct Qdisc* sch)
 	int prio;
 	struct prio_sched_data *q = qdisc_priv(sch);
 
-	tcf_destroy_chain(q->filter_list);
+	tcf_destroy_chain(&q->filter_list);
 	for (prio=0; prio<q->bands; prio++)
 		qdisc_destroy(q->queues[prio]);
 }
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index f0463d7..6a97afb 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -520,7 +520,7 @@ static void sfq_destroy(struct Qdisc *sch)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
 
-	tcf_destroy_chain(q->filter_list);
+	tcf_destroy_chain(&q->filter_list);
 	q->perturb_period = 0;
 	del_timer_sync(&q->perturb_timer);
 }

--------------090607010308000309050105--
