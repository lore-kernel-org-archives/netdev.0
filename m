From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 02/06]: Set parent classid in default qdiscs
Date: Mon, 20 Nov 2006 14:08:38 +0100 (MET)
Message-ID: <20061120130838.22347.3990.sendpatchset@localhost.localdomain>
References: <20061120130834.22347.34853.sendpatchset@localhost.localdomain>
Cc: devik@cdi.cz, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:8190 "EHLO stinky.trash.net")
	by vger.kernel.org with ESMTP id S965862AbWKTNIk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Nov 2006 08:08:40 -0500
To: davem@davemloft.net
In-Reply-To: <20061120130834.22347.34853.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET_SCHED]: Set parent classid in default qdiscs

Set parent classids in default qdiscs to allow walking up the tree
from outside the qdiscs. This is needed by the next patch.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 825dfe1f03e69f3c2b56e6bd6ceea7ffe23c65bf
tree 28592aa602dcd936add9fb2851c97c5a603dda85
parent 28ceb9f1cece3e1fa989a96a99dc76dc44d5629b
author Patrick McHardy <kaber@trash.net> Mon, 20 Nov 2006 13:42:53 +0100
committer Patrick McHardy <kaber@trash.net> Mon, 20 Nov 2006 13:42:53 +0100

 include/net/sch_generic.h |    2 +-
 net/sched/sch_atm.c       |    5 +++--
 net/sched/sch_cbq.c       |    8 +++++---
 net/sched/sch_dsmark.c    |    5 +++--
 net/sched/sch_generic.c   |    7 +++++--
 net/sched/sch_hfsc.c      |    8 +++++---
 net/sched/sch_htb.c       |    7 ++++---
 net/sched/sch_netem.c     |    3 ++-
 net/sched/sch_prio.c      |    3 ++-
 net/sched/sch_red.c       |    8 +++++---
 net/sched/sch_tbf.c       |    8 +++++---
 11 files changed, 40 insertions(+), 24 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index b0e9108..660ff0a 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -174,7 +174,7 @@ extern void qdisc_reset(struct Qdisc *qd
 extern void qdisc_destroy(struct Qdisc *qdisc);
 extern struct Qdisc *qdisc_alloc(struct net_device *dev, struct Qdisc_ops *ops);
 extern struct Qdisc *qdisc_create_dflt(struct net_device *dev,
-				       struct Qdisc_ops *ops);
+				       struct Qdisc_ops *ops, u32 parentid);
 
 static inline void
 tcf_destroy(struct tcf_proto *tp)
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index dbf44da..edc7bb0 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -316,7 +316,7 @@ static int atm_tc_change(struct Qdisc *s
 	}
 	memset(flow,0,sizeof(*flow));
 	flow->filter_list = NULL;
-	if (!(flow->q = qdisc_create_dflt(sch->dev,&pfifo_qdisc_ops)))
+	if (!(flow->q = qdisc_create_dflt(sch->dev,&pfifo_qdisc_ops,classid)))
 		flow->q = &noop_qdisc;
 	DPRINTK("atm_tc_change: qdisc %p\n",flow->q);
 	flow->sock = sock;
@@ -576,7 +576,8 @@ static int atm_tc_init(struct Qdisc *sch
 
 	DPRINTK("atm_tc_init(sch %p,[qdisc %p],opt %p)\n",sch,p,opt);
 	p->flows = &p->link;
-	if(!(p->link.q = qdisc_create_dflt(sch->dev,&pfifo_qdisc_ops)))
+	if(!(p->link.q = qdisc_create_dflt(sch->dev,&pfifo_qdisc_ops,
+					   sch->handle)))
 		p->link.q = &noop_qdisc;
 	DPRINTK("atm_tc_init: link (%p) qdisc %p\n",&p->link,p->link.q);
 	p->link.filter_list = NULL;
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index bac881b..908b10d 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -1429,7 +1429,8 @@ static int cbq_init(struct Qdisc *sch, s
 	q->link.sibling = &q->link;
 	q->link.classid = sch->handle;
 	q->link.qdisc = sch;
-	if (!(q->link.q = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops)))
+	if (!(q->link.q = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops,
+					    sch->handle)))
 		q->link.q = &noop_qdisc;
 
 	q->link.priority = TC_CBQ_MAXPRIO-1;
@@ -1674,7 +1675,8 @@ static int cbq_graft(struct Qdisc *sch, 
 
 	if (cl) {
 		if (new == NULL) {
-			if ((new = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops)) == NULL)
+			if ((new = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops,
+						     cl->classid)) == NULL)
 				return -ENOBUFS;
 		} else {
 #ifdef CONFIG_NET_CLS_POLICE
@@ -1932,7 +1934,7 @@ #endif
 	cl->R_tab = rtab;
 	rtab = NULL;
 	cl->refcnt = 1;
-	if (!(cl->q = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops)))
+	if (!(cl->q = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops, classid)))
 		cl->q = &noop_qdisc;
 	cl->classid = classid;
 	cl->tparent = parent;
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 11c8a21..7809073 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -88,7 +88,8 @@ static int dsmark_graft(struct Qdisc *sc
 		sch, p, new, old);
 
 	if (new == NULL) {
-		new = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops);
+		new = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops,
+					sch->handle);
 		if (new == NULL)
 			new = &noop_qdisc;
 	}
@@ -387,7 +388,7 @@ static int dsmark_init(struct Qdisc *sch
 	p->default_index = default_index;
 	p->set_tc_index = RTA_GET_FLAG(tb[TCA_DSMARK_SET_TC_INDEX-1]);
 
-	p->q = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops);
+	p->q = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops, sch->handle);
 	if (p->q == NULL)
 		p->q = &noop_qdisc;
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 88c6a99..deafeb9 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -450,13 +450,15 @@ errout:
 	return ERR_PTR(-err);
 }
 
-struct Qdisc * qdisc_create_dflt(struct net_device *dev, struct Qdisc_ops *ops)
+struct Qdisc * qdisc_create_dflt(struct net_device *dev, struct Qdisc_ops *ops,
+				 unsigned int parentid)
 {
 	struct Qdisc *sch;
 	
 	sch = qdisc_alloc(dev, ops);
 	if (IS_ERR(sch))
 		goto errout;
+	sch->parent = parentid;
 
 	if (!ops->init || ops->init(sch, NULL) == 0)
 		return sch;
@@ -520,7 +522,8 @@ void dev_activate(struct net_device *dev
 	if (dev->qdisc_sleeping == &noop_qdisc) {
 		struct Qdisc *qdisc;
 		if (dev->tx_queue_len) {
-			qdisc = qdisc_create_dflt(dev, &pfifo_fast_ops);
+			qdisc = qdisc_create_dflt(dev, &pfifo_fast_ops,
+						  TC_H_ROOT);
 			if (qdisc == NULL) {
 				printk(KERN_INFO "%s: activation failed\n", dev->name);
 				return;
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 6a6735a..1142d29 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1138,7 +1138,7 @@ #endif
 	cl->classid   = classid;
 	cl->sched     = q;
 	cl->cl_parent = parent;
-	cl->qdisc = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops);
+	cl->qdisc = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops, classid);
 	if (cl->qdisc == NULL)
 		cl->qdisc = &noop_qdisc;
 	cl->stats_lock = &sch->dev->queue_lock;
@@ -1271,7 +1271,8 @@ hfsc_graft_class(struct Qdisc *sch, unsi
 	if (cl->level > 0)
 		return -EINVAL;
 	if (new == NULL) {
-		new = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops);
+		new = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops,
+					cl->classid);
 		if (new == NULL)
 			new = &noop_qdisc;
 	}
@@ -1514,7 +1515,8 @@ hfsc_init_qdisc(struct Qdisc *sch, struc
 	q->root.refcnt  = 1;
 	q->root.classid = sch->handle;
 	q->root.sched   = q;
-	q->root.qdisc = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops);
+	q->root.qdisc = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops,
+					  sch->handle);
 	if (q->root.qdisc == NULL)
 		q->root.qdisc = &noop_qdisc;
 	q->root.stats_lock = &sch->dev->queue_lock;
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 08fa4d0..3b36e9d 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1223,8 +1223,9 @@ static int htb_graft(struct Qdisc *sch, 
 	struct htb_class *cl = (struct htb_class *)arg;
 
 	if (cl && !cl->level) {
-		if (new == NULL && (new = qdisc_create_dflt(sch->dev,
-							    &pfifo_qdisc_ops))
+		if (new == NULL &&
+		    (new = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops,
+		    			     cl->classid))
 		    == NULL)
 			return -ENOBUFS;
 		sch_tree_lock(sch);
@@ -1415,7 +1416,7 @@ static int htb_change_class(struct Qdisc
 		/* create leaf qdisc early because it uses kmalloc(GFP_KERNEL)
 		   so that can't be used inside of sch_tree_lock
 		   -- thanks to Karlis Peisenieks */
-		new_q = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops);
+		new_q = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops, classid);
 		sch_tree_lock(sch);
 		if (parent && !parent->level) {
 			/* turn parent into inner node */
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 0441876..90aeeb7 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -574,7 +574,8 @@ static int netem_init(struct Qdisc *sch,
 	q->timer.function = netem_watchdog;
 	q->timer.data = (unsigned long) sch;
 
-	q->qdisc = qdisc_create_dflt(sch->dev, &tfifo_qdisc_ops);
+	q->qdisc = qdisc_create_dflt(sch->dev, &tfifo_qdisc_ops,
+				     TC_H_MAKE(sch->handle, 1));
 	if (!q->qdisc) {
 		pr_debug("netem: qdisc create failed\n");
 		return -ENOMEM;
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index a5fa03c..3fc0c0f 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -230,7 +230,8 @@ static int prio_tune(struct Qdisc *sch, 
 	for (i=0; i<q->bands; i++) {
 		if (q->queues[i] == &noop_qdisc) {
 			struct Qdisc *child;
-			child = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops);
+			child = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops,
+						  TC_H_MAKE(sch->handle, i + 1));
 			if (child) {
 				sch_tree_lock(sch);
 				child = xchg(&q->queues[i], child);
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index d65cadd..ee66c5c 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -175,12 +175,14 @@ static void red_destroy(struct Qdisc *sc
 	qdisc_destroy(q->qdisc);
 }
 
-static struct Qdisc *red_create_dflt(struct net_device *dev, u32 limit)
+static struct Qdisc *red_create_dflt(struct Qdisc *sch, u32 limit)
 {
-	struct Qdisc *q = qdisc_create_dflt(dev, &bfifo_qdisc_ops);
+	struct Qdisc *q;
 	struct rtattr *rta;
 	int ret;
 
+	q = qdisc_create_dflt(sch->dev, &bfifo_qdisc_ops,
+			      TC_H_MAKE(sch->handle, 1));
 	if (q) {
 		rta = kmalloc(RTA_LENGTH(sizeof(struct tc_fifo_qopt)),
 		              GFP_KERNEL);
@@ -219,7 +221,7 @@ static int red_change(struct Qdisc *sch,
 	ctl = RTA_DATA(tb[TCA_RED_PARMS-1]);
 
 	if (ctl->limit > 0) {
-		child = red_create_dflt(sch->dev, ctl->limit);
+		child = red_create_dflt(sch, ctl->limit);
 		if (child == NULL)
 			return -ENOMEM;
 	}
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index d9a5d29..2562a60 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -273,12 +273,14 @@ static void tbf_reset(struct Qdisc* sch)
 	del_timer(&q->wd_timer);
 }
 
-static struct Qdisc *tbf_create_dflt_qdisc(struct net_device *dev, u32 limit)
+static struct Qdisc *tbf_create_dflt_qdisc(struct Qdisc *sch, u32 limit)
 {
-	struct Qdisc *q = qdisc_create_dflt(dev, &bfifo_qdisc_ops);
+	struct Qdisc *q;
         struct rtattr *rta;
 	int ret;
 
+	q = qdisc_create_dflt(sch->dev, &bfifo_qdisc_ops,
+			      TC_H_MAKE(sch->handle, 1));
 	if (q) {
 		rta = kmalloc(RTA_LENGTH(sizeof(struct tc_fifo_qopt)), GFP_KERNEL);
 		if (rta) {
@@ -341,7 +343,7 @@ static int tbf_change(struct Qdisc* sch,
 		goto done;
 
 	if (qopt->limit > 0) {
-		if ((child = tbf_create_dflt_qdisc(sch->dev, qopt->limit)) == NULL)
+		if ((child = tbf_create_dflt_qdisc(sch, qopt->limit)) == NULL)
 			goto done;
 	}
 
