From: David Miller <davem@davemloft.net>
Subject: [PATCH] sch_atm: Convert to use standard list_head facilities.
Date: Sun, 18 Jul 2010 19:53:25 -0700 (PDT)
Message-ID: <20100718.195325.148533291.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39120
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758190Ab0GSCxJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jul 2010 22:53:09 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 9E90024C090
	for <netdev@vger.kernel.org>; Sun, 18 Jul 2010 19:53:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sched/sch_atm.c |   98 +++++++++++++++++++++-----------------------------
 1 files changed, 41 insertions(+), 57 deletions(-)

diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index fcbb86a..e114f23 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -52,7 +52,7 @@ struct atm_flow_data {
 	int			ref;		/* reference count */
 	struct gnet_stats_basic_packed	bstats;
 	struct gnet_stats_queue	qstats;
-	struct atm_flow_data	*next;
+	struct list_head	list;
 	struct atm_flow_data	*excess;	/* flow for excess traffic;
 						   NULL to set CLP instead */
 	int			hdr_len;
@@ -61,34 +61,23 @@ struct atm_flow_data {
 
 struct atm_qdisc_data {
 	struct atm_flow_data	link;		/* unclassified skbs go here */
-	struct atm_flow_data	*flows;		/* NB: "link" is also on this
+	struct list_head	flows;		/* NB: "link" is also on this
 						   list */
 	struct tasklet_struct	task;		/* dequeue tasklet */
 };
 
 /* ------------------------- Class/flow operations ------------------------- */
 
-static int find_flow(struct atm_qdisc_data *qdisc, struct atm_flow_data *flow)
-{
-	struct atm_flow_data *walk;
-
-	pr_debug("find_flow(qdisc %p,flow %p)\n", qdisc, flow);
-	for (walk = qdisc->flows; walk; walk = walk->next)
-		if (walk == flow)
-			return 1;
-	pr_debug("find_flow: not found\n");
-	return 0;
-}
-
 static inline struct atm_flow_data *lookup_flow(struct Qdisc *sch, u32 classid)
 {
 	struct atm_qdisc_data *p = qdisc_priv(sch);
 	struct atm_flow_data *flow;
 
-	for (flow = p->flows; flow; flow = flow->next)
+	list_for_each_entry(flow, &p->flows, list) {
 		if (flow->classid == classid)
-			break;
-	return flow;
+			return flow;
+	}
+	return NULL;
 }
 
 static int atm_tc_graft(struct Qdisc *sch, unsigned long arg,
@@ -99,7 +88,7 @@ static int atm_tc_graft(struct Qdisc *sch, unsigned long arg,
 
 	pr_debug("atm_tc_graft(sch %p,[qdisc %p],flow %p,new %p,old %p)\n",
 		sch, p, flow, new, old);
-	if (!find_flow(p, flow))
+	if (list_empty(&flow->list))
 		return -EINVAL;
 	if (!new)
 		new = &noop_qdisc;
@@ -146,20 +135,12 @@ static void atm_tc_put(struct Qdisc *sch, unsigned long cl)
 {
 	struct atm_qdisc_data *p = qdisc_priv(sch);
 	struct atm_flow_data *flow = (struct atm_flow_data *)cl;
-	struct atm_flow_data **prev;
 
 	pr_debug("atm_tc_put(sch %p,[qdisc %p],flow %p)\n", sch, p, flow);
 	if (--flow->ref)
 		return;
 	pr_debug("atm_tc_put: destroying\n");
-	for (prev = &p->flows; *prev; prev = &(*prev)->next)
-		if (*prev == flow)
-			break;
-	if (!*prev) {
-		printk(KERN_CRIT "atm_tc_put: class %p not found\n", flow);
-		return;
-	}
-	*prev = flow->next;
+	list_del_init(&flow->list);
 	pr_debug("atm_tc_put: qdisc %p\n", flow->q);
 	qdisc_destroy(flow->q);
 	tcf_destroy_chain(&flow->filter_list);
@@ -274,7 +255,7 @@ static int atm_tc_change(struct Qdisc *sch, u32 classid, u32 parent,
 			error = -EINVAL;
 			goto err_out;
 		}
-		if (find_flow(p, flow)) {
+		if (!list_empty(&flow->list)) {
 			error = -EEXIST;
 			goto err_out;
 		}
@@ -313,8 +294,7 @@ static int atm_tc_change(struct Qdisc *sch, u32 classid, u32 parent,
 	flow->classid = classid;
 	flow->ref = 1;
 	flow->excess = excess;
-	flow->next = p->link.next;
-	p->link.next = flow;
+	list_add(&flow->list, &p->link.list);
 	flow->hdr_len = hdr_len;
 	if (hdr)
 		memcpy(flow->hdr, hdr, hdr_len);
@@ -335,7 +315,7 @@ static int atm_tc_delete(struct Qdisc *sch, unsigned long arg)
 	struct atm_flow_data *flow = (struct atm_flow_data *)arg;
 
 	pr_debug("atm_tc_delete(sch %p,[qdisc %p],flow %p)\n", sch, p, flow);
-	if (!find_flow(qdisc_priv(sch), flow))
+	if (list_empty(&flow->list))
 		return -EINVAL;
 	if (flow->filter_list || flow == &p->link)
 		return -EBUSY;
@@ -361,12 +341,12 @@ static void atm_tc_walk(struct Qdisc *sch, struct qdisc_walker *walker)
 	pr_debug("atm_tc_walk(sch %p,[qdisc %p],walker %p)\n", sch, p, walker);
 	if (walker->stop)
 		return;
-	for (flow = p->flows; flow; flow = flow->next) {
-		if (walker->count >= walker->skip)
-			if (walker->fn(sch, (unsigned long)flow, walker) < 0) {
-				walker->stop = 1;
-				break;
-			}
+	list_for_each_entry(flow, &p->flows, list) {
+		if (walker->count >= walker->skip &&
+		    walker->fn(sch, (unsigned long)flow, walker) < 0) {
+			walker->stop = 1;
+			break;
+		}
 		walker->count++;
 	}
 }
@@ -385,16 +365,17 @@ static struct tcf_proto **atm_tc_find_tcf(struct Qdisc *sch, unsigned long cl)
 static int atm_tc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct atm_qdisc_data *p = qdisc_priv(sch);
-	struct atm_flow_data *flow = NULL;	/* @@@ */
+	struct atm_flow_data *flow;
 	struct tcf_result res;
 	int result;
 	int ret = NET_XMIT_POLICED;
 
 	pr_debug("atm_tc_enqueue(skb %p,sch %p,[qdisc %p])\n", skb, sch, p);
 	result = TC_POLICE_OK;	/* be nice to gcc */
+	flow = NULL;
 	if (TC_H_MAJ(skb->priority) != sch->handle ||
-	    !(flow = (struct atm_flow_data *)atm_tc_get(sch, skb->priority)))
-		for (flow = p->flows; flow; flow = flow->next)
+	    !(flow = (struct atm_flow_data *)atm_tc_get(sch, skb->priority))) {
+		list_for_each_entry(flow, &p->flows, list) {
 			if (flow->filter_list) {
 				result = tc_classify_compat(skb,
 							    flow->filter_list,
@@ -404,8 +385,13 @@ static int atm_tc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 				flow = (struct atm_flow_data *)res.class;
 				if (!flow)
 					flow = lookup_flow(sch, res.classid);
-				break;
+				goto done;
 			}
+		}
+		flow = NULL;
+	done:
+		;		
+	}
 	if (!flow)
 		flow = &p->link;
 	else {
@@ -477,7 +463,9 @@ static void sch_atm_dequeue(unsigned long data)
 	struct sk_buff *skb;
 
 	pr_debug("sch_atm_dequeue(sch %p,[qdisc %p])\n", sch, p);
-	for (flow = p->link.next; flow; flow = flow->next)
+	list_for_each_entry(flow, &p->flows, list) {
+		if (flow == &p->link)
+			continue;
 		/*
 		 * If traffic is properly shaped, this won't generate nasty
 		 * little bursts. Otherwise, it may ... (but that's okay)
@@ -512,6 +500,7 @@ static void sch_atm_dequeue(unsigned long data)
 			/* atm.atm_options are already set by atm_tc_enqueue */
 			flow->vcc->send(flow->vcc, skb);
 		}
+	}
 }
 
 static struct sk_buff *atm_tc_dequeue(struct Qdisc *sch)
@@ -543,9 +532,10 @@ static unsigned int atm_tc_drop(struct Qdisc *sch)
 	unsigned int len;
 
 	pr_debug("atm_tc_drop(sch %p,[qdisc %p])\n", sch, p);
-	for (flow = p->flows; flow; flow = flow->next)
+	list_for_each_entry(flow, &p->flows, list) {
 		if (flow->q->ops->drop && (len = flow->q->ops->drop(flow->q)))
 			return len;
+	}
 	return 0;
 }
 
@@ -554,7 +544,9 @@ static int atm_tc_init(struct Qdisc *sch, struct nlattr *opt)
 	struct atm_qdisc_data *p = qdisc_priv(sch);
 
 	pr_debug("atm_tc_init(sch %p,[qdisc %p],opt %p)\n", sch, p, opt);
-	p->flows = &p->link;
+	INIT_LIST_HEAD(&p->flows);
+	INIT_LIST_HEAD(&p->link.list);
+	list_add(&p->link.list, &p->flows);
 	p->link.q = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
 				      &pfifo_qdisc_ops, sch->handle);
 	if (!p->link.q)
@@ -565,7 +557,6 @@ static int atm_tc_init(struct Qdisc *sch, struct nlattr *opt)
 	p->link.sock = NULL;
 	p->link.classid = sch->handle;
 	p->link.ref = 1;
-	p->link.next = NULL;
 	tasklet_init(&p->task, sch_atm_dequeue, (unsigned long)sch);
 	return 0;
 }
@@ -576,7 +567,7 @@ static void atm_tc_reset(struct Qdisc *sch)
 	struct atm_flow_data *flow;
 
 	pr_debug("atm_tc_reset(sch %p,[qdisc %p])\n", sch, p);
-	for (flow = p->flows; flow; flow = flow->next)
+	list_for_each_entry(flow, &p->flows, list)
 		qdisc_reset(flow->q);
 	sch->q.qlen = 0;
 }
@@ -584,24 +575,17 @@ static void atm_tc_reset(struct Qdisc *sch)
 static void atm_tc_destroy(struct Qdisc *sch)
 {
 	struct atm_qdisc_data *p = qdisc_priv(sch);
-	struct atm_flow_data *flow;
+	struct atm_flow_data *flow, *tmp;
 
 	pr_debug("atm_tc_destroy(sch %p,[qdisc %p])\n", sch, p);
-	for (flow = p->flows; flow; flow = flow->next)
+	list_for_each_entry(flow, &p->flows, list)
 		tcf_destroy_chain(&flow->filter_list);
 
-	/* races ? */
-	while ((flow = p->flows)) {
+	list_for_each_entry_safe(flow, tmp, &p->flows, list) {
 		if (flow->ref > 1)
 			printk(KERN_ERR "atm_destroy: %p->ref = %d\n", flow,
 			       flow->ref);
 		atm_tc_put(sch, (unsigned long)flow);
-		if (p->flows == flow) {
-			printk(KERN_ERR "atm_destroy: putting flow %p didn't "
-			       "kill it\n", flow);
-			p->flows = flow->next;	/* brute force */
-			break;
-		}
 	}
 	tasklet_kill(&p->task);
 }
@@ -615,7 +599,7 @@ static int atm_tc_dump_class(struct Qdisc *sch, unsigned long cl,
 
 	pr_debug("atm_tc_dump_class(sch %p,[qdisc %p],flow %p,skb %p,tcm %p)\n",
 		sch, p, flow, skb, tcm);
-	if (!find_flow(p, flow))
+	if (list_empty(&flow->list))
 		return -EINVAL;
 	tcm->tcm_handle = flow->classid;
 	tcm->tcm_info = flow->q->handle;
-- 
1.7.1.1

