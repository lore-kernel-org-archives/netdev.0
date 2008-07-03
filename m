From: David Miller <davem@davemloft.net>
Subject: [PATCH 04/39]: pkt_sched: Remove 'dev' member of struct Qdisc.
Date: Thu, 03 Jul 2008 00:02:48 -0700 (PDT)
Message-ID: <20080703.000248.255571030.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vinay@linux.vnet.ibm.com, krkumar2@in.ibm.com, mchan@broadcom.com,
	Matheos.Worku@Sun.COM, linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47451
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756627AbYGCHCt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 03:02:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It can be obtained via the netdev_queue.  So create a helper
routine "qdisc_dev" to make the transformations nicer looking.

qdisc_alloc() now no longer needs a net_device pointer argument.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/sch_generic.h |   16 +++++++++-------
 net/mac80211/wme.c        |   28 ++++++++++++++--------------
 net/sched/cls_api.c       |    2 +-
 net/sched/cls_route.c     |    4 ++--
 net/sched/sch_api.c       |   10 +++++-----
 net/sched/sch_atm.c       |    4 ++--
 net/sched/sch_cbq.c       |   22 +++++++++++-----------
 net/sched/sch_dsmark.c    |    4 ++--
 net/sched/sch_fifo.c      |    4 ++--
 net/sched/sch_generic.c   |   12 +++++-------
 net/sched/sch_gred.c      |    2 +-
 net/sched/sch_hfsc.c      |   10 +++++-----
 net/sched/sch_htb.c       |   24 ++++++++++++------------
 net/sched/sch_netem.c     |   10 +++++-----
 net/sched/sch_prio.c      |    2 +-
 net/sched/sch_red.c       |    2 +-
 net/sched/sch_sfq.c       |    4 ++--
 net/sched/sch_tbf.c       |    2 +-
 net/sched/sch_teql.c      |   12 ++++++------
 19 files changed, 87 insertions(+), 87 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 4fa07c6..1dce549 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -38,7 +38,6 @@ struct Qdisc
 	atomic_t		refcnt;
 	struct sk_buff_head	q;
 	struct netdev_queue	*dev_queue;
-	struct net_device	*dev;
 	struct list_head	list;
 
 	struct gnet_stats_basic	bstats;
@@ -156,14 +155,18 @@ struct tcf_proto
 	struct tcf_proto_ops	*ops;
 };
 
+static inline struct net_device *qdisc_dev(struct Qdisc *qdisc)
+{
+	return qdisc->dev_queue->dev;
+}
 
 extern void qdisc_lock_tree(struct net_device *dev);
 extern void qdisc_unlock_tree(struct net_device *dev);
 
-#define sch_tree_lock(q)	qdisc_lock_tree((q)->dev)
-#define sch_tree_unlock(q)	qdisc_unlock_tree((q)->dev)
-#define tcf_tree_lock(tp)	qdisc_lock_tree((tp)->q->dev)
-#define tcf_tree_unlock(tp)	qdisc_unlock_tree((tp)->q->dev)
+#define sch_tree_lock(q)	qdisc_lock_tree(qdisc_dev(q))
+#define sch_tree_unlock(q)	qdisc_unlock_tree(qdisc_dev(q))
+#define tcf_tree_lock(tp)	qdisc_lock_tree(qdisc_dev((tp)->q))
+#define tcf_tree_unlock(tp)	qdisc_unlock_tree(qdisc_dev((tp)->q))
 
 extern struct Qdisc noop_qdisc;
 extern struct Qdisc_ops noop_qdisc_ops;
@@ -175,8 +178,7 @@ extern void dev_deactivate(struct net_device *dev);
 extern void qdisc_reset(struct Qdisc *qdisc);
 extern void qdisc_destroy(struct Qdisc *qdisc);
 extern void qdisc_tree_decrease_qlen(struct Qdisc *qdisc, unsigned int n);
-extern struct Qdisc *qdisc_alloc(struct net_device *dev,
-				 struct netdev_queue *dev_queue,
+extern struct Qdisc *qdisc_alloc(struct netdev_queue *dev_queue,
 				 struct Qdisc_ops *ops);
 extern struct Qdisc *qdisc_create_dflt(struct net_device *dev,
 				       struct netdev_queue *dev_queue,
diff --git a/net/mac80211/wme.c b/net/mac80211/wme.c
index 0ba081a..cc8b5a9 100644
--- a/net/mac80211/wme.c
+++ b/net/mac80211/wme.c
@@ -103,7 +103,7 @@ static inline int wme_downgrade_ac(struct sk_buff *skb)
  * negative return value indicates to drop the frame */
 static int classify80211(struct sk_buff *skb, struct Qdisc *qd)
 {
-	struct ieee80211_local *local = wdev_priv(qd->dev->ieee80211_ptr);
+	struct ieee80211_local *local = wdev_priv(qdisc_dev(qd)->ieee80211_ptr);
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
 
 	if (!ieee80211_is_data(hdr->frame_control)) {
@@ -140,7 +140,7 @@ static int classify80211(struct sk_buff *skb, struct Qdisc *qd)
 
 static int wme_qdiscop_enqueue(struct sk_buff *skb, struct Qdisc* qd)
 {
-	struct ieee80211_local *local = wdev_priv(qd->dev->ieee80211_ptr);
+	struct ieee80211_local *local = wdev_priv(qdisc_dev(qd)->ieee80211_ptr);
 	struct ieee80211_hw *hw = &local->hw;
 	struct ieee80211_sched_data *q = qdisc_priv(qd);
 	struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
@@ -250,7 +250,7 @@ static int wme_qdiscop_requeue(struct sk_buff *skb, struct Qdisc* qd)
 static struct sk_buff *wme_qdiscop_dequeue(struct Qdisc* qd)
 {
 	struct ieee80211_sched_data *q = qdisc_priv(qd);
-	struct net_device *dev = qd->dev;
+	struct net_device *dev = qdisc_dev(qd);
 	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
 	struct ieee80211_hw *hw = &local->hw;
 	struct sk_buff *skb;
@@ -287,7 +287,7 @@ static struct sk_buff *wme_qdiscop_dequeue(struct Qdisc* qd)
 static void wme_qdiscop_reset(struct Qdisc* qd)
 {
 	struct ieee80211_sched_data *q = qdisc_priv(qd);
-	struct ieee80211_local *local = wdev_priv(qd->dev->ieee80211_ptr);
+	struct ieee80211_local *local = wdev_priv(qdisc_dev(qd)->ieee80211_ptr);
 	struct ieee80211_hw *hw = &local->hw;
 	int queue;
 
@@ -304,7 +304,7 @@ static void wme_qdiscop_reset(struct Qdisc* qd)
 static void wme_qdiscop_destroy(struct Qdisc* qd)
 {
 	struct ieee80211_sched_data *q = qdisc_priv(qd);
-	struct ieee80211_local *local = wdev_priv(qd->dev->ieee80211_ptr);
+	struct ieee80211_local *local = wdev_priv(qdisc_dev(qd)->ieee80211_ptr);
 	struct ieee80211_hw *hw = &local->hw;
 	int queue;
 
@@ -330,7 +330,7 @@ static int wme_qdiscop_tune(struct Qdisc *qd, struct nlattr *opt)
 static int wme_qdiscop_init(struct Qdisc *qd, struct nlattr *opt)
 {
 	struct ieee80211_sched_data *q = qdisc_priv(qd);
-	struct net_device *dev = qd->dev;
+	struct net_device *dev = qdisc_dev(qd);
 	struct ieee80211_local *local;
 	struct ieee80211_hw *hw;
 	int err = 0, i;
@@ -361,7 +361,7 @@ static int wme_qdiscop_init(struct Qdisc *qd, struct nlattr *opt)
 	/* create child queues */
 	for (i = 0; i < QD_NUM(hw); i++) {
 		skb_queue_head_init(&q->requeued[i]);
-		q->queues[i] = qdisc_create_dflt(qd->dev, qd->dev_queue,
+		q->queues[i] = qdisc_create_dflt(qdisc_dev(qd), qd->dev_queue,
 						 &pfifo_qdisc_ops,
 						 qd->handle);
 		if (!q->queues[i]) {
@@ -388,7 +388,7 @@ static int wme_classop_graft(struct Qdisc *qd, unsigned long arg,
 			     struct Qdisc *new, struct Qdisc **old)
 {
 	struct ieee80211_sched_data *q = qdisc_priv(qd);
-	struct ieee80211_local *local = wdev_priv(qd->dev->ieee80211_ptr);
+	struct ieee80211_local *local = wdev_priv(qdisc_dev(qd)->ieee80211_ptr);
 	struct ieee80211_hw *hw = &local->hw;
 	unsigned long queue = arg - 1;
 
@@ -412,7 +412,7 @@ static struct Qdisc *
 wme_classop_leaf(struct Qdisc *qd, unsigned long arg)
 {
 	struct ieee80211_sched_data *q = qdisc_priv(qd);
-	struct ieee80211_local *local = wdev_priv(qd->dev->ieee80211_ptr);
+	struct ieee80211_local *local = wdev_priv(qdisc_dev(qd)->ieee80211_ptr);
 	struct ieee80211_hw *hw = &local->hw;
 	unsigned long queue = arg - 1;
 
@@ -425,7 +425,7 @@ wme_classop_leaf(struct Qdisc *qd, unsigned long arg)
 
 static unsigned long wme_classop_get(struct Qdisc *qd, u32 classid)
 {
-	struct ieee80211_local *local = wdev_priv(qd->dev->ieee80211_ptr);
+	struct ieee80211_local *local = wdev_priv(qdisc_dev(qd)->ieee80211_ptr);
 	struct ieee80211_hw *hw = &local->hw;
 	unsigned long queue = TC_H_MIN(classid);
 
@@ -452,7 +452,7 @@ static int wme_classop_change(struct Qdisc *qd, u32 handle, u32 parent,
 			      struct nlattr **tca, unsigned long *arg)
 {
 	unsigned long cl = *arg;
-	struct ieee80211_local *local = wdev_priv(qd->dev->ieee80211_ptr);
+	struct ieee80211_local *local = wdev_priv(qdisc_dev(qd)->ieee80211_ptr);
 	struct ieee80211_hw *hw = &local->hw;
 
 	if (cl - 1 > QD_NUM(hw))
@@ -469,7 +469,7 @@ static int wme_classop_change(struct Qdisc *qd, u32 handle, u32 parent,
  * when we add WMM-SA support - TSPECs may be deleted here */
 static int wme_classop_delete(struct Qdisc *qd, unsigned long cl)
 {
-	struct ieee80211_local *local = wdev_priv(qd->dev->ieee80211_ptr);
+	struct ieee80211_local *local = wdev_priv(qdisc_dev(qd)->ieee80211_ptr);
 	struct ieee80211_hw *hw = &local->hw;
 
 	if (cl - 1 > QD_NUM(hw))
@@ -482,7 +482,7 @@ static int wme_classop_dump_class(struct Qdisc *qd, unsigned long cl,
 				  struct sk_buff *skb, struct tcmsg *tcm)
 {
 	struct ieee80211_sched_data *q = qdisc_priv(qd);
-	struct ieee80211_local *local = wdev_priv(qd->dev->ieee80211_ptr);
+	struct ieee80211_local *local = wdev_priv(qdisc_dev(qd)->ieee80211_ptr);
 	struct ieee80211_hw *hw = &local->hw;
 
 	if (cl - 1 > QD_NUM(hw))
@@ -496,7 +496,7 @@ static int wme_classop_dump_class(struct Qdisc *qd, unsigned long cl,
 
 static void wme_classop_walk(struct Qdisc *qd, struct qdisc_walker *arg)
 {
-	struct ieee80211_local *local = wdev_priv(qd->dev->ieee80211_ptr);
+	struct ieee80211_local *local = wdev_priv(qdisc_dev(qd)->ieee80211_ptr);
 	struct ieee80211_hw *hw = &local->hw;
 	int queue;
 
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 9360fc8..e2389f1 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -334,7 +334,7 @@ static int tcf_fill_node(struct sk_buff *skb, struct tcf_proto *tp,
 	tcm->tcm_family = AF_UNSPEC;
 	tcm->tcm__pad1 = 0;
 	tcm->tcm__pad1 = 0;
-	tcm->tcm_ifindex = tp->q->dev->ifindex;
+	tcm->tcm_ifindex = qdisc_dev(tp->q)->ifindex;
 	tcm->tcm_parent = tp->classid;
 	tcm->tcm_info = TC_H_MAKE(tp->prio, tp->protocol);
 	NLA_PUT_STRING(skb, TCA_KIND, tp->ops->kind);
diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index 784dcb8..5a16ca2 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -302,7 +302,7 @@ static int route4_delete(struct tcf_proto *tp, unsigned long arg)
 			*fp = f->next;
 			tcf_tree_unlock(tp);
 
-			route4_reset_fastmap(tp->q->dev, head, f->id);
+			route4_reset_fastmap(qdisc_dev(tp->q), head, f->id);
 			route4_delete_filter(tp, f);
 
 			/* Strip tree */
@@ -500,7 +500,7 @@ reinsert:
 	}
 	tcf_tree_unlock(tp);
 
-	route4_reset_fastmap(tp->q->dev, head, f->id);
+	route4_reset_fastmap(qdisc_dev(tp->q), head, f->id);
 	*arg = (unsigned long)f;
 	return 0;
 
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 4de7410..8bb8929 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -281,7 +281,7 @@ static enum hrtimer_restart qdisc_watchdog(struct hrtimer *timer)
 {
 	struct qdisc_watchdog *wd = container_of(timer, struct qdisc_watchdog,
 						 timer);
-	struct net_device *dev = wd->qdisc->dev;
+	struct net_device *dev = qdisc_dev(wd->qdisc);
 
 	wd->qdisc->flags &= ~TCQ_F_THROTTLED;
 	smp_wmb();
@@ -389,7 +389,7 @@ void qdisc_tree_decrease_qlen(struct Qdisc *sch, unsigned int n)
 		if (TC_H_MAJ(parentid) == TC_H_MAJ(TC_H_INGRESS))
 			return;
 
-		sch = qdisc_lookup(sch->dev, TC_H_MAJ(parentid));
+		sch = qdisc_lookup(qdisc_dev(sch), TC_H_MAJ(parentid));
 		if (sch == NULL) {
 			WARN_ON(parentid != TC_H_ROOT);
 			return;
@@ -489,7 +489,7 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 	if (ops == NULL)
 		goto err_out;
 
-	sch = qdisc_alloc(dev, dev_queue, ops);
+	sch = qdisc_alloc(dev_queue, ops);
 	if (IS_ERR(sch)) {
 		err = PTR_ERR(sch);
 		goto err_out2;
@@ -836,7 +836,7 @@ static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 clid,
 	tcm->tcm_family = AF_UNSPEC;
 	tcm->tcm__pad1 = 0;
 	tcm->tcm__pad2 = 0;
-	tcm->tcm_ifindex = q->dev->ifindex;
+	tcm->tcm_ifindex = qdisc_dev(q)->ifindex;
 	tcm->tcm_parent = clid;
 	tcm->tcm_handle = q->handle;
 	tcm->tcm_info = atomic_read(&q->refcnt);
@@ -1082,7 +1082,7 @@ static int tc_fill_tclass(struct sk_buff *skb, struct Qdisc *q,
 	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*tcm), flags);
 	tcm = NLMSG_DATA(nlh);
 	tcm->tcm_family = AF_UNSPEC;
-	tcm->tcm_ifindex = q->dev->ifindex;
+	tcm->tcm_ifindex = qdisc_dev(q)->ifindex;
 	tcm->tcm_parent = q->handle;
 	tcm->tcm_handle = q->handle;
 	tcm->tcm_info = 0;
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 97bab52..8a5012e 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -296,7 +296,7 @@ static int atm_tc_change(struct Qdisc *sch, u32 classid, u32 parent,
 		goto err_out;
 	}
 	flow->filter_list = NULL;
-	flow->q = qdisc_create_dflt(sch->dev, sch->dev_queue,
+	flow->q = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
 				    &pfifo_qdisc_ops, classid);
 	if (!flow->q)
 		flow->q = &noop_qdisc;
@@ -556,7 +556,7 @@ static int atm_tc_init(struct Qdisc *sch, struct nlattr *opt)
 
 	pr_debug("atm_tc_init(sch %p,[qdisc %p],opt %p)\n", sch, p, opt);
 	p->flows = &p->link;
-	p->link.q = qdisc_create_dflt(sch->dev, sch->dev_queue,
+	p->link.q = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
 				      &pfifo_qdisc_ops, sch->handle);
 	if (!p->link.q)
 		p->link.q = &noop_qdisc;
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 78923a6..c7adc38 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -659,7 +659,7 @@ static enum hrtimer_restart cbq_undelay(struct hrtimer *timer)
 	}
 
 	sch->flags &= ~TCQ_F_THROTTLED;
-	netif_schedule(sch->dev);
+	netif_schedule(qdisc_dev(sch));
 	return HRTIMER_NORESTART;
 }
 
@@ -1085,9 +1085,9 @@ static void cbq_normalize_quanta(struct cbq_sched_data *q, int prio)
 				cl->quantum = (cl->weight*cl->allot*q->nclasses[prio])/
 					q->quanta[prio];
 			}
-			if (cl->quantum <= 0 || cl->quantum>32*cl->qdisc->dev->mtu) {
+			if (cl->quantum <= 0 || cl->quantum>32*qdisc_dev(cl->qdisc)->mtu) {
 				printk(KERN_WARNING "CBQ: class %08x has bad quantum==%ld, repaired.\n", cl->classid, cl->quantum);
-				cl->quantum = cl->qdisc->dev->mtu/2 + 1;
+				cl->quantum = qdisc_dev(cl->qdisc)->mtu/2 + 1;
 			}
 		}
 	}
@@ -1410,7 +1410,7 @@ static int cbq_init(struct Qdisc *sch, struct nlattr *opt)
 	q->link.sibling = &q->link;
 	q->link.classid = sch->handle;
 	q->link.qdisc = sch;
-	if (!(q->link.q = qdisc_create_dflt(sch->dev, sch->dev_queue,
+	if (!(q->link.q = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
 					    &pfifo_qdisc_ops,
 					    sch->handle)))
 		q->link.q = &noop_qdisc;
@@ -1420,7 +1420,7 @@ static int cbq_init(struct Qdisc *sch, struct nlattr *opt)
 	q->link.cpriority = TC_CBQ_MAXPRIO-1;
 	q->link.ovl_strategy = TC_CBQ_OVL_CLASSIC;
 	q->link.overlimit = cbq_ovl_classic;
-	q->link.allot = psched_mtu(sch->dev);
+	q->link.allot = psched_mtu(qdisc_dev(sch));
 	q->link.quantum = q->link.allot;
 	q->link.weight = q->link.R_tab->rate.rate;
 
@@ -1651,7 +1651,7 @@ static int cbq_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
 
 	if (cl) {
 		if (new == NULL) {
-			if ((new = qdisc_create_dflt(sch->dev, sch->dev_queue,
+			if ((new = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
 						     &pfifo_qdisc_ops,
 						     cl->classid)) == NULL)
 				return -ENOBUFS;
@@ -1753,10 +1753,10 @@ static void cbq_put(struct Qdisc *sch, unsigned long arg)
 #ifdef CONFIG_NET_CLS_ACT
 		struct cbq_sched_data *q = qdisc_priv(sch);
 
-		spin_lock_bh(&sch->dev->queue_lock);
+		spin_lock_bh(&qdisc_dev(sch)->queue_lock);
 		if (q->rx_class == cl)
 			q->rx_class = NULL;
-		spin_unlock_bh(&sch->dev->queue_lock);
+		spin_unlock_bh(&qdisc_dev(sch)->queue_lock);
 #endif
 
 		cbq_destroy_class(sch, cl);
@@ -1834,7 +1834,7 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct nlattr **t
 
 		if (tca[TCA_RATE])
 			gen_replace_estimator(&cl->bstats, &cl->rate_est,
-					      &sch->dev->queue_lock,
+					      &qdisc_dev(sch)->queue_lock,
 					      tca[TCA_RATE]);
 		return 0;
 	}
@@ -1885,7 +1885,7 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct nlattr **t
 	cl->R_tab = rtab;
 	rtab = NULL;
 	cl->refcnt = 1;
-	if (!(cl->q = qdisc_create_dflt(sch->dev, sch->dev_queue,
+	if (!(cl->q = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
 					&pfifo_qdisc_ops, classid)))
 		cl->q = &noop_qdisc;
 	cl->classid = classid;
@@ -1923,7 +1923,7 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct nlattr **t
 
 	if (tca[TCA_RATE])
 		gen_new_estimator(&cl->bstats, &cl->rate_est,
-				  &sch->dev->queue_lock, tca[TCA_RATE]);
+				  &qdisc_dev(sch)->queue_lock, tca[TCA_RATE]);
 
 	*arg = (unsigned long)cl;
 	return 0;
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index adee048..b7d8502 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -60,7 +60,7 @@ static int dsmark_graft(struct Qdisc *sch, unsigned long arg,
 		sch, p, new, old);
 
 	if (new == NULL) {
-		new = qdisc_create_dflt(sch->dev, sch->dev_queue,
+		new = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
 					&pfifo_qdisc_ops,
 					sch->handle);
 		if (new == NULL)
@@ -391,7 +391,7 @@ static int dsmark_init(struct Qdisc *sch, struct nlattr *opt)
 	p->default_index = default_index;
 	p->set_tc_index = nla_get_flag(tb[TCA_DSMARK_SET_TC_INDEX]);
 
-	p->q = qdisc_create_dflt(sch->dev, sch->dev_queue,
+	p->q = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
 				 &pfifo_qdisc_ops, sch->handle);
 	if (p->q == NULL)
 		p->q = &noop_qdisc;
diff --git a/net/sched/sch_fifo.c b/net/sched/sch_fifo.c
index 95ed482..eb6ba17 100644
--- a/net/sched/sch_fifo.c
+++ b/net/sched/sch_fifo.c
@@ -48,10 +48,10 @@ static int fifo_init(struct Qdisc *sch, struct nlattr *opt)
 	struct fifo_sched_data *q = qdisc_priv(sch);
 
 	if (opt == NULL) {
-		u32 limit = sch->dev->tx_queue_len ? : 1;
+		u32 limit = qdisc_dev(sch)->tx_queue_len ? : 1;
 
 		if (sch->ops == &bfifo_qdisc_ops)
-			limit *= sch->dev->mtu;
+			limit *= qdisc_dev(sch)->mtu;
 
 		q->limit = limit;
 	} else {
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index d970864..b626a4f 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -364,7 +364,7 @@ static int pfifo_fast_enqueue(struct sk_buff *skb, struct Qdisc* qdisc)
 {
 	struct sk_buff_head *list = prio2list(skb, qdisc);
 
-	if (skb_queue_len(list) < qdisc->dev->tx_queue_len) {
+	if (skb_queue_len(list) < qdisc_dev(qdisc)->tx_queue_len) {
 		qdisc->q.qlen++;
 		return __qdisc_enqueue_tail(skb, qdisc, list);
 	}
@@ -440,8 +440,7 @@ static struct Qdisc_ops pfifo_fast_ops __read_mostly = {
 	.owner		=	THIS_MODULE,
 };
 
-struct Qdisc *qdisc_alloc(struct net_device *dev,
-			  struct netdev_queue *dev_queue,
+struct Qdisc *qdisc_alloc(struct netdev_queue *dev_queue,
 			  struct Qdisc_ops *ops)
 {
 	void *p;
@@ -465,8 +464,7 @@ struct Qdisc *qdisc_alloc(struct net_device *dev,
 	sch->enqueue = ops->enqueue;
 	sch->dequeue = ops->dequeue;
 	sch->dev_queue = dev_queue;
-	sch->dev = dev;
-	dev_hold(dev);
+	dev_hold(qdisc_dev(sch));
 	atomic_set(&sch->refcnt, 1);
 
 	return sch;
@@ -481,7 +479,7 @@ struct Qdisc * qdisc_create_dflt(struct net_device *dev,
 {
 	struct Qdisc *sch;
 
-	sch = qdisc_alloc(dev, dev_queue, ops);
+	sch = qdisc_alloc(dev_queue, ops);
 	if (IS_ERR(sch))
 		goto errout;
 	sch->stats_lock = &dev->queue_lock;
@@ -534,7 +532,7 @@ void qdisc_destroy(struct Qdisc *qdisc)
 		ops->destroy(qdisc);
 
 	module_put(ops->owner);
-	dev_put(qdisc->dev);
+	dev_put(qdisc_dev(qdisc));
 	call_rcu(&qdisc->q_rcu, __qdisc_destroy);
 }
 EXPORT_SYMBOL(qdisc_destroy);
diff --git a/net/sched/sch_gred.c b/net/sched/sch_gred.c
index c89fba5..39fa285 100644
--- a/net/sched/sch_gred.c
+++ b/net/sched/sch_gred.c
@@ -164,7 +164,7 @@ static int gred_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 			 * if no default DP has been configured. This
 			 * allows for DP flows to be left untouched.
 			 */
-			if (skb_queue_len(&sch->q) < sch->dev->tx_queue_len)
+			if (skb_queue_len(&sch->q) < qdisc_dev(sch)->tx_queue_len)
 				return qdisc_enqueue_tail(skb, sch);
 			else
 				goto drop;
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index b5f80ba..78fa9ad 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1057,7 +1057,7 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 
 		if (tca[TCA_RATE])
 			gen_replace_estimator(&cl->bstats, &cl->rate_est,
-					      &sch->dev->queue_lock,
+					      &qdisc_dev(sch)->queue_lock,
 					      tca[TCA_RATE]);
 		return 0;
 	}
@@ -1095,7 +1095,7 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 	cl->classid   = classid;
 	cl->sched     = q;
 	cl->cl_parent = parent;
-	cl->qdisc = qdisc_create_dflt(sch->dev, sch->dev_queue,
+	cl->qdisc = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
 				      &pfifo_qdisc_ops, classid);
 	if (cl->qdisc == NULL)
 		cl->qdisc = &noop_qdisc;
@@ -1114,7 +1114,7 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 
 	if (tca[TCA_RATE])
 		gen_new_estimator(&cl->bstats, &cl->rate_est,
-				  &sch->dev->queue_lock, tca[TCA_RATE]);
+				  &qdisc_dev(sch)->queue_lock, tca[TCA_RATE]);
 	*arg = (unsigned long)cl;
 	return 0;
 }
@@ -1212,7 +1212,7 @@ hfsc_graft_class(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
 	if (cl->level > 0)
 		return -EINVAL;
 	if (new == NULL) {
-		new = qdisc_create_dflt(sch->dev, sch->dev_queue,
+		new = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
 					&pfifo_qdisc_ops,
 					cl->classid);
 		if (new == NULL)
@@ -1451,7 +1451,7 @@ hfsc_init_qdisc(struct Qdisc *sch, struct nlattr *opt)
 	q->root.refcnt  = 1;
 	q->root.classid = sch->handle;
 	q->root.sched   = q;
-	q->root.qdisc = qdisc_create_dflt(sch->dev, sch->dev_queue,
+	q->root.qdisc = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
 					  &pfifo_qdisc_ops,
 					  sch->handle);
 	if (q->root.qdisc == NULL)
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 42f7fce..ec770ea 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1048,7 +1048,7 @@ static int htb_init(struct Qdisc *sch, struct nlattr *opt)
 	qdisc_watchdog_init(&q->watchdog, sch);
 	skb_queue_head_init(&q->direct_queue);
 
-	q->direct_qlen = sch->dev->tx_queue_len;
+	q->direct_qlen = qdisc_dev(sch)->tx_queue_len;
 	if (q->direct_qlen < 2)	/* some devices have zero tx_queue_len */
 		q->direct_qlen = 2;
 
@@ -1065,7 +1065,7 @@ static int htb_dump(struct Qdisc *sch, struct sk_buff *skb)
 	struct nlattr *nest;
 	struct tc_htb_glob gopt;
 
-	spin_lock_bh(&sch->dev->queue_lock);
+	spin_lock_bh(&qdisc_dev(sch)->queue_lock);
 
 	gopt.direct_pkts = q->direct_pkts;
 	gopt.version = HTB_VER;
@@ -1079,11 +1079,11 @@ static int htb_dump(struct Qdisc *sch, struct sk_buff *skb)
 	NLA_PUT(skb, TCA_HTB_INIT, sizeof(gopt), &gopt);
 	nla_nest_end(skb, nest);
 
-	spin_unlock_bh(&sch->dev->queue_lock);
+	spin_unlock_bh(&qdisc_dev(sch)->queue_lock);
 	return skb->len;
 
 nla_put_failure:
-	spin_unlock_bh(&sch->dev->queue_lock);
+	spin_unlock_bh(&qdisc_dev(sch)->queue_lock);
 	nla_nest_cancel(skb, nest);
 	return -1;
 }
@@ -1095,7 +1095,7 @@ static int htb_dump_class(struct Qdisc *sch, unsigned long arg,
 	struct nlattr *nest;
 	struct tc_htb_opt opt;
 
-	spin_lock_bh(&sch->dev->queue_lock);
+	spin_lock_bh(&qdisc_dev(sch)->queue_lock);
 	tcm->tcm_parent = cl->parent ? cl->parent->classid : TC_H_ROOT;
 	tcm->tcm_handle = cl->classid;
 	if (!cl->level && cl->un.leaf.q)
@@ -1117,11 +1117,11 @@ static int htb_dump_class(struct Qdisc *sch, unsigned long arg,
 	NLA_PUT(skb, TCA_HTB_PARMS, sizeof(opt), &opt);
 
 	nla_nest_end(skb, nest);
-	spin_unlock_bh(&sch->dev->queue_lock);
+	spin_unlock_bh(&qdisc_dev(sch)->queue_lock);
 	return skb->len;
 
 nla_put_failure:
-	spin_unlock_bh(&sch->dev->queue_lock);
+	spin_unlock_bh(&qdisc_dev(sch)->queue_lock);
 	nla_nest_cancel(skb, nest);
 	return -1;
 }
@@ -1151,7 +1151,7 @@ static int htb_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
 
 	if (cl && !cl->level) {
 		if (new == NULL &&
-		    (new = qdisc_create_dflt(sch->dev, sch->dev_queue,
+		    (new = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
 					     &pfifo_qdisc_ops,
 					     cl->classid))
 		    == NULL)
@@ -1290,7 +1290,7 @@ static int htb_delete(struct Qdisc *sch, unsigned long arg)
 		return -EBUSY;
 
 	if (!cl->level && htb_parent_last_child(cl)) {
-		new_q = qdisc_create_dflt(sch->dev, sch->dev_queue,
+		new_q = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
 					  &pfifo_qdisc_ops,
 					  cl->parent->classid);
 		last_child = 1;
@@ -1394,7 +1394,7 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 			goto failure;
 
 		gen_new_estimator(&cl->bstats, &cl->rate_est,
-				  &sch->dev->queue_lock,
+				  &qdisc_dev(sch)->queue_lock,
 				  tca[TCA_RATE] ? : &est.nla);
 		cl->refcnt = 1;
 		INIT_LIST_HEAD(&cl->sibling);
@@ -1409,7 +1409,7 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 		/* create leaf qdisc early because it uses kmalloc(GFP_KERNEL)
 		   so that can't be used inside of sch_tree_lock
 		   -- thanks to Karlis Peisenieks */
-		new_q = qdisc_create_dflt(sch->dev, sch->dev_queue,
+		new_q = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
 					  &pfifo_qdisc_ops, classid);
 		sch_tree_lock(sch);
 		if (parent && !parent->level) {
@@ -1451,7 +1451,7 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 	} else {
 		if (tca[TCA_RATE])
 			gen_replace_estimator(&cl->bstats, &cl->rate_est,
-					      &sch->dev->queue_lock,
+					      &qdisc_dev(sch)->queue_lock,
 					      tca[TCA_RATE]);
 		sch_tree_lock(sch);
 	}
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 5f1adc0..130dd13 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -180,7 +180,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	 * skb will be queued.
 	 */
 	if (count > 1 && (skb2 = skb_clone(skb, GFP_ATOMIC)) != NULL) {
-		struct Qdisc *rootq = sch->dev->qdisc;
+		struct Qdisc *rootq = qdisc_dev(sch)->qdisc;
 		u32 dupsave = q->duplicate; /* prevent duplicating a dup... */
 		q->duplicate = 0;
 
@@ -355,9 +355,9 @@ static int get_dist_table(struct Qdisc *sch, const struct nlattr *attr)
 	for (i = 0; i < n; i++)
 		d->table[i] = data[i];
 
-	spin_lock_bh(&sch->dev->queue_lock);
+	spin_lock_bh(&qdisc_dev(sch)->queue_lock);
 	d = xchg(&q->delay_dist, d);
-	spin_unlock_bh(&sch->dev->queue_lock);
+	spin_unlock_bh(&qdisc_dev(sch)->queue_lock);
 
 	kfree(d);
 	return 0;
@@ -517,7 +517,7 @@ static int tfifo_init(struct Qdisc *sch, struct nlattr *opt)
 
 		q->limit = ctl->limit;
 	} else
-		q->limit = max_t(u32, sch->dev->tx_queue_len, 1);
+		q->limit = max_t(u32, qdisc_dev(sch)->tx_queue_len, 1);
 
 	q->oldest = PSCHED_PASTPERFECT;
 	return 0;
@@ -558,7 +558,7 @@ static int netem_init(struct Qdisc *sch, struct nlattr *opt)
 
 	qdisc_watchdog_init(&q->watchdog, sch);
 
-	q->qdisc = qdisc_create_dflt(sch->dev, sch->dev_queue,
+	q->qdisc = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
 				     &tfifo_qdisc_ops,
 				     TC_H_MAKE(sch->handle, 1));
 	if (!q->qdisc) {
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 0ffefb6..d24f801 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -212,7 +212,7 @@ static int prio_tune(struct Qdisc *sch, struct nlattr *opt)
 	for (i=0; i<q->bands; i++) {
 		if (q->queues[i] == &noop_qdisc) {
 			struct Qdisc *child;
-			child = qdisc_create_dflt(sch->dev, sch->dev_queue,
+			child = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
 						  &pfifo_qdisc_ops,
 						  TC_H_MAKE(sch->handle, i + 1));
 			if (child) {
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index d10c47a..3aafd9e 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -180,7 +180,7 @@ static struct Qdisc *red_create_dflt(struct Qdisc *sch, u32 limit)
 	struct nlattr *nla;
 	int ret;
 
-	q = qdisc_create_dflt(sch->dev, sch->dev_queue,
+	q = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
 			      &bfifo_qdisc_ops,
 			      TC_H_MAKE(sch->handle, 1));
 	if (q) {
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index f0463d7..9027e06 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -461,7 +461,7 @@ static int sfq_change(struct Qdisc *sch, struct nlattr *opt)
 		return -EINVAL;
 
 	sch_tree_lock(sch);
-	q->quantum = ctl->quantum ? : psched_mtu(sch->dev);
+	q->quantum = ctl->quantum ? : psched_mtu(qdisc_dev(sch));
 	q->perturb_period = ctl->perturb_period * HZ;
 	if (ctl->limit)
 		q->limit = min_t(u32, ctl->limit, SFQ_DEPTH - 1);
@@ -502,7 +502,7 @@ static int sfq_init(struct Qdisc *sch, struct nlattr *opt)
 	q->max_depth = 0;
 	q->tail = SFQ_DEPTH;
 	if (opt == NULL) {
-		q->quantum = psched_mtu(sch->dev);
+		q->quantum = psched_mtu(qdisc_dev(sch));
 		q->perturb_period = 0;
 		q->perturbation = net_random();
 	} else {
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 61559e1..27fed26 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -248,7 +248,7 @@ static struct Qdisc *tbf_create_dflt_qdisc(struct Qdisc *sch, u32 limit)
 	struct nlattr *nla;
 	int ret;
 
-	q = qdisc_create_dflt(sch->dev, sch->dev_queue,
+	q = qdisc_create_dflt(qdisc_dev(sch), sch->dev_queue,
 			      &bfifo_qdisc_ops,
 			      TC_H_MAKE(sch->handle, 1));
 	if (q) {
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index 0444fd0..b3fc826 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -78,7 +78,7 @@ struct teql_sched_data
 static int
 teql_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 {
-	struct net_device *dev = sch->dev;
+	struct net_device *dev = qdisc_dev(sch);
 	struct teql_sched_data *q = qdisc_priv(sch);
 
 	if (q->q.qlen < dev->tx_queue_len) {
@@ -111,7 +111,7 @@ teql_dequeue(struct Qdisc* sch)
 
 	skb = __skb_dequeue(&dat->q);
 	if (skb == NULL) {
-		struct net_device *m = dat->m->dev->qdisc->dev;
+		struct net_device *m = qdisc_dev(dat->m->dev->qdisc);
 		if (m) {
 			dat->m->slaves = sch;
 			netif_wake_queue(m);
@@ -170,7 +170,7 @@ teql_destroy(struct Qdisc* sch)
 
 static int teql_qdisc_init(struct Qdisc *sch, struct nlattr *opt)
 {
-	struct net_device *dev = sch->dev;
+	struct net_device *dev = qdisc_dev(sch);
 	struct teql_master *m = (struct teql_master*)sch->ops;
 	struct teql_sched_data *q = qdisc_priv(sch);
 
@@ -282,7 +282,7 @@ restart:
 		goto drop;
 
 	do {
-		struct net_device *slave = q->dev;
+		struct net_device *slave = qdisc_dev(q);
 
 		if (slave->qdisc_sleeping != q)
 			continue;
@@ -352,7 +352,7 @@ static int teql_master_open(struct net_device *dev)
 
 	q = m->slaves;
 	do {
-		struct net_device *slave = q->dev;
+		struct net_device *slave = qdisc_dev(q);
 
 		if (slave == NULL)
 			return -EUNATCH;
@@ -403,7 +403,7 @@ static int teql_master_mtu(struct net_device *dev, int new_mtu)
 	q = m->slaves;
 	if (q) {
 		do {
-			if (new_mtu > q->dev->mtu)
+			if (new_mtu > qdisc_dev(q)->mtu)
 				return -EINVAL;
 		} while ((q=NEXT_SLAVE(q)) != m->slaves);
 	}
-- 
1.5.6

