From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: [PATCH 03/39]: netdev: Create netdev_queue abstraction.
Date: Thu, 03 Jul 2008 00:02:32 -0700 (PDT)
Message-ID: <20080703.000232.39861363.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vinay-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, krkumar2-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	Matheos.Worku-UdXhSnd/wVw@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


A netdev_queue is an entity managed by a qdisc.

Currently there is one RX and one TX queue, and
a netdev_queue merely contains a backpointer to
the net_device.

The Qdisc struct is augmented with a netdev_queue
pointer as well.  Eventually the 'dev' Qdisc member
will go away and we will have the resulting hierarchy:

	net_device --> netdev_queue --> Qdisc

Also, qdisc_alloc() and qdisc_create_dflt() now take
a netdev_queue pointer argument.

Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 include/linux/netdevice.h |    7 +++++++
 include/net/sch_generic.h |    6 +++++-
 net/core/dev.c            |    8 ++++++++
 net/mac80211/wme.c        |    6 ++++--
 net/sched/sch_api.c       |   12 +++++++-----
 net/sched/sch_atm.c       |    6 ++++--
 net/sched/sch_cbq.c       |    9 ++++++---
 net/sched/sch_dsmark.c    |    6 ++++--
 net/sched/sch_generic.c   |   14 ++++++++++----
 net/sched/sch_hfsc.c      |    9 ++++++---
 net/sched/sch_htb.c       |   11 +++++++----
 net/sched/sch_netem.c     |    3 ++-
 net/sched/sch_prio.c      |    3 ++-
 net/sched/sch_red.c       |    3 ++-
 net/sched/sch_tbf.c       |    3 ++-
 15 files changed, 76 insertions(+), 30 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 56dadb5..2c792e6 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -448,6 +448,10 @@ static inline void napi_synchronize(const struct napi_struct *n)
 # define napi_synchronize(n)	barrier()
 #endif
 
+struct netdev_queue {
+	struct net_device	*dev;
+};
+
 /*
  *	The DEVICE structure.
  *	Actually, this whole structure is a big mistake.  It mixes I/O
@@ -624,6 +628,9 @@ struct net_device
 
 	unsigned char		broadcast[MAX_ADDR_LEN];	/* hw bcast add	*/
 
+	struct netdev_queue	rx_queue;
+	struct netdev_queue	tx_queue;
+
 	/* ingress path synchronizer */
 	spinlock_t		ingress_lock;
 	struct Qdisc		*qdisc_ingress;
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index ab502ec..4fa07c6 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -37,6 +37,7 @@ struct Qdisc
 	u32			parent;
 	atomic_t		refcnt;
 	struct sk_buff_head	q;
+	struct netdev_queue	*dev_queue;
 	struct net_device	*dev;
 	struct list_head	list;
 
@@ -174,8 +175,11 @@ extern void dev_deactivate(struct net_device *dev);
 extern void qdisc_reset(struct Qdisc *qdisc);
 extern void qdisc_destroy(struct Qdisc *qdisc);
 extern void qdisc_tree_decrease_qlen(struct Qdisc *qdisc, unsigned int n);
-extern struct Qdisc *qdisc_alloc(struct net_device *dev, struct Qdisc_ops *ops);
+extern struct Qdisc *qdisc_alloc(struct net_device *dev,
+				 struct netdev_queue *dev_queue,
+				 struct Qdisc_ops *ops);
 extern struct Qdisc *qdisc_create_dflt(struct net_device *dev,
+				       struct netdev_queue *dev_queue,
 				       struct Qdisc_ops *ops, u32 parentid);
 extern void tcf_destroy(struct tcf_proto *tp);
 extern void tcf_destroy_chain(struct tcf_proto *fl);
diff --git a/net/core/dev.c b/net/core/dev.c
index 472676d..26ba606 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4072,6 +4072,12 @@ static struct net_device_stats *internal_stats(struct net_device *dev)
 	return &dev->stats;
 }
 
+static void netdev_init_queues(struct net_device *dev)
+{
+	dev->rx_queue.dev = dev;
+	dev->tx_queue.dev = dev;
+}
+
 /**
  *	alloc_netdev_mq - allocate network device
  *	@sizeof_priv:	size of private data to allocate space for
@@ -4124,6 +4130,8 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 	dev->egress_subqueue_count = queue_count;
 	dev->gso_max_size = GSO_MAX_SIZE;
 
+	netdev_init_queues(dev);
+
 	dev->get_stats = internal_stats;
 	netpoll_netdev_init(dev);
 	setup(dev);
diff --git a/net/mac80211/wme.c b/net/mac80211/wme.c
index cfa8fbb..0ba081a 100644
--- a/net/mac80211/wme.c
+++ b/net/mac80211/wme.c
@@ -361,7 +361,8 @@ static int wme_qdiscop_init(struct Qdisc *qd, struct nlattr *opt)
 	/* create child queues */
 	for (i = 0; i < QD_NUM(hw); i++) {
 		skb_queue_head_init(&q->requeued[i]);
-		q->queues[i] = qdisc_create_dflt(qd->dev, &pfifo_qdisc_ops,
+		q->queues[i] = qdisc_create_dflt(qd->dev, qd->dev_queue,
+						 &pfifo_qdisc_ops,
 						 qd->handle);
 		if (!q->queues[i]) {
 			q->queues[i] = &noop_qdisc;
@@ -577,7 +578,8 @@ void ieee80211_install_qdisc(struct net_device *dev)
 {
 	struct Qdisc *qdisc;
 
-	qdisc = qdisc_create_dflt(dev, &wme_qdisc_ops, TC_H_ROOT);
+	qdisc = qdisc_create_dflt(dev, &dev->tx_queue,
+				  &wme_qdisc_ops, TC_H_ROOT);
 	if (!qdisc) {
 		printk(KERN_ERR "%s: qdisc installation failed\n", dev->name);
 		return;
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 365a84c..4de7410 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -448,8 +448,8 @@ static int qdisc_graft(struct net_device *dev, struct Qdisc *parent,
  */
 
 static struct Qdisc *
-qdisc_create(struct net_device *dev, u32 parent, u32 handle,
-	   struct nlattr **tca, int *errp)
+qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
+	     u32 parent, u32 handle, struct nlattr **tca, int *errp)
 {
 	int err;
 	struct nlattr *kind = tca[TCA_KIND];
@@ -489,7 +489,7 @@ qdisc_create(struct net_device *dev, u32 parent, u32 handle,
 	if (ops == NULL)
 		goto err_out;
 
-	sch = qdisc_alloc(dev, ops);
+	sch = qdisc_alloc(dev, dev_queue, ops);
 	if (IS_ERR(sch)) {
 		err = PTR_ERR(sch);
 		goto err_out2;
@@ -788,10 +788,12 @@ create_n_graft:
 	if (!(n->nlmsg_flags&NLM_F_CREATE))
 		return -ENOENT;
 	if (clid == TC_H_INGRESS)
-		q = qdisc_create(dev, tcm->tcm_parent, tcm->tcm_parent,
+		q = qdisc_create(dev, &dev->rx_queue,
+				 tcm->tcm_parent, tcm->tcm_parent,
 				 tca, &err);
 	else
-		q = qdisc_create(dev, tcm->tcm_parent, tcm->tcm_handle,
+		q = qdisc_create(dev, &dev->tx_queue,
+				 tcm->tcm_parent, tcm->tcm_handle,
 				 tca, &err);
 	if (q == NULL) {
 		if (err == -EAGAIN)
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 3352734..97bab52 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -296,7 +296,8 @@ static int atm_tc_change(struct Qdisc *sch, u32 classid, u32 parent,
 		goto err_out;
 	}
 	flow->filter_list = NULL;
-	flow->q = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops, classid);
+	flow->q = qdisc_create_dflt(sch->dev, sch->dev_queue,
+				    &pfifo_qdisc_ops, classid);
 	if (!flow->q)
 		flow->q = &noop_qdisc;
 	pr_debug("atm_tc_change: qdisc %p\n", flow->q);
@@ -555,7 +556,8 @@ static int atm_tc_init(struct Qdisc *sch, struct nlattr *opt)
 
 	pr_debug("atm_tc_init(sch %p,[qdisc %p],opt %p)\n", sch, p, opt);
 	p->flows = &p->link;
-	p->link.q = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops, sch->handle);
+	p->link.q = qdisc_create_dflt(sch->dev, sch->dev_queue,
+				      &pfifo_qdisc_ops, sch->handle);
 	if (!p->link.q)
 		p->link.q = &noop_qdisc;
 	pr_debug("atm_tc_init: link (%p) qdisc %p\n", &p->link, p->link.q);
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 09969c1..78923a6 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -1410,7 +1410,8 @@ static int cbq_init(struct Qdisc *sch, struct nlattr *opt)
 	q->link.sibling = &q->link;
 	q->link.classid = sch->handle;
 	q->link.qdisc = sch;
-	if (!(q->link.q = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops,
+	if (!(q->link.q = qdisc_create_dflt(sch->dev, sch->dev_queue,
+					    &pfifo_qdisc_ops,
 					    sch->handle)))
 		q->link.q = &noop_qdisc;
 
@@ -1650,7 +1651,8 @@ static int cbq_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
 
 	if (cl) {
 		if (new == NULL) {
-			if ((new = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops,
+			if ((new = qdisc_create_dflt(sch->dev, sch->dev_queue,
+						     &pfifo_qdisc_ops,
 						     cl->classid)) == NULL)
 				return -ENOBUFS;
 		} else {
@@ -1883,7 +1885,8 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct nlattr **t
 	cl->R_tab = rtab;
 	rtab = NULL;
 	cl->refcnt = 1;
-	if (!(cl->q = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops, classid)))
+	if (!(cl->q = qdisc_create_dflt(sch->dev, sch->dev_queue,
+					&pfifo_qdisc_ops, classid)))
 		cl->q = &noop_qdisc;
 	cl->classid = classid;
 	cl->tparent = parent;
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 64465ba..adee048 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -60,7 +60,8 @@ static int dsmark_graft(struct Qdisc *sch, unsigned long arg,
 		sch, p, new, old);
 
 	if (new == NULL) {
-		new = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops,
+		new = qdisc_create_dflt(sch->dev, sch->dev_queue,
+					&pfifo_qdisc_ops,
 					sch->handle);
 		if (new == NULL)
 			new = &noop_qdisc;
@@ -390,7 +391,8 @@ static int dsmark_init(struct Qdisc *sch, struct nlattr *opt)
 	p->default_index = default_index;
 	p->set_tc_index = nla_get_flag(tb[TCA_DSMARK_SET_TC_INDEX]);
 
-	p->q = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops, sch->handle);
+	p->q = qdisc_create_dflt(sch->dev, sch->dev_queue,
+				 &pfifo_qdisc_ops, sch->handle);
 	if (p->q == NULL)
 		p->q = &noop_qdisc;
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 13afa72..d970864 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -440,7 +440,9 @@ static struct Qdisc_ops pfifo_fast_ops __read_mostly = {
 	.owner		=	THIS_MODULE,
 };
 
-struct Qdisc *qdisc_alloc(struct net_device *dev, struct Qdisc_ops *ops)
+struct Qdisc *qdisc_alloc(struct net_device *dev,
+			  struct netdev_queue *dev_queue,
+			  struct Qdisc_ops *ops)
 {
 	void *p;
 	struct Qdisc *sch;
@@ -462,6 +464,7 @@ struct Qdisc *qdisc_alloc(struct net_device *dev, struct Qdisc_ops *ops)
 	sch->ops = ops;
 	sch->enqueue = ops->enqueue;
 	sch->dequeue = ops->dequeue;
+	sch->dev_queue = dev_queue;
 	sch->dev = dev;
 	dev_hold(dev);
 	atomic_set(&sch->refcnt, 1);
@@ -471,12 +474,14 @@ errout:
 	return ERR_PTR(err);
 }
 
-struct Qdisc * qdisc_create_dflt(struct net_device *dev, struct Qdisc_ops *ops,
+struct Qdisc * qdisc_create_dflt(struct net_device *dev,
+				 struct netdev_queue *dev_queue,
+				 struct Qdisc_ops *ops,
 				 unsigned int parentid)
 {
 	struct Qdisc *sch;
 
-	sch = qdisc_alloc(dev, ops);
+	sch = qdisc_alloc(dev, dev_queue, ops);
 	if (IS_ERR(sch))
 		goto errout;
 	sch->stats_lock = &dev->queue_lock;
@@ -545,7 +550,8 @@ void dev_activate(struct net_device *dev)
 	if (dev->qdisc_sleeping == &noop_qdisc) {
 		struct Qdisc *qdisc;
 		if (dev->tx_queue_len) {
-			qdisc = qdisc_create_dflt(dev, &pfifo_fast_ops,
+			qdisc = qdisc_create_dflt(dev, &dev->tx_queue,
+						  &pfifo_fast_ops,
 						  TC_H_ROOT);
 			if (qdisc == NULL) {
 				printk(KERN_INFO "%s: activation failed\n", dev->name);
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index fdfaa3f..b5f80ba 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1095,7 +1095,8 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 	cl->classid   = classid;
 	cl->sched     = q;
 	cl->cl_parent = parent;
-	cl->qdisc = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops, classid);
+	cl->qdisc = qdisc_create_dflt(sch->dev, sch->dev_queue,
+				      &pfifo_qdisc_ops, classid);
 	if (cl->qdisc == NULL)
 		cl->qdisc = &noop_qdisc;
 	INIT_LIST_HEAD(&cl->children);
@@ -1211,7 +1212,8 @@ hfsc_graft_class(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
 	if (cl->level > 0)
 		return -EINVAL;
 	if (new == NULL) {
-		new = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops,
+		new = qdisc_create_dflt(sch->dev, sch->dev_queue,
+					&pfifo_qdisc_ops,
 					cl->classid);
 		if (new == NULL)
 			new = &noop_qdisc;
@@ -1449,7 +1451,8 @@ hfsc_init_qdisc(struct Qdisc *sch, struct nlattr *opt)
 	q->root.refcnt  = 1;
 	q->root.classid = sch->handle;
 	q->root.sched   = q;
-	q->root.qdisc = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops,
+	q->root.qdisc = qdisc_create_dflt(sch->dev, sch->dev_queue,
+					  &pfifo_qdisc_ops,
 					  sch->handle);
 	if (q->root.qdisc == NULL)
 		q->root.qdisc = &noop_qdisc;
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 2cef8f3..42f7fce 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1151,7 +1151,8 @@ static int htb_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
 
 	if (cl && !cl->level) {
 		if (new == NULL &&
-		    (new = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops,
+		    (new = qdisc_create_dflt(sch->dev, sch->dev_queue,
+					     &pfifo_qdisc_ops,
 					     cl->classid))
 		    == NULL)
 			return -ENOBUFS;
@@ -1289,8 +1290,9 @@ static int htb_delete(struct Qdisc *sch, unsigned long arg)
 		return -EBUSY;
 
 	if (!cl->level && htb_parent_last_child(cl)) {
-		new_q = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops,
-						cl->parent->classid);
+		new_q = qdisc_create_dflt(sch->dev, sch->dev_queue,
+					  &pfifo_qdisc_ops,
+					  cl->parent->classid);
 		last_child = 1;
 	}
 
@@ -1407,7 +1409,8 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 		/* create leaf qdisc early because it uses kmalloc(GFP_KERNEL)
 		   so that can't be used inside of sch_tree_lock
 		   -- thanks to Karlis Peisenieks */
-		new_q = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops, classid);
+		new_q = qdisc_create_dflt(sch->dev, sch->dev_queue,
+					  &pfifo_qdisc_ops, classid);
 		sch_tree_lock(sch);
 		if (parent && !parent->level) {
 			unsigned int qlen = parent->un.leaf.q->q.qlen;
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index c9c649b..5f1adc0 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -558,7 +558,8 @@ static int netem_init(struct Qdisc *sch, struct nlattr *opt)
 
 	qdisc_watchdog_init(&q->watchdog, sch);
 
-	q->qdisc = qdisc_create_dflt(sch->dev, &tfifo_qdisc_ops,
+	q->qdisc = qdisc_create_dflt(sch->dev, sch->dev_queue,
+				     &tfifo_qdisc_ops,
 				     TC_H_MAKE(sch->handle, 1));
 	if (!q->qdisc) {
 		pr_debug("netem: qdisc create failed\n");
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index b050c26..0ffefb6 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -212,7 +212,8 @@ static int prio_tune(struct Qdisc *sch, struct nlattr *opt)
 	for (i=0; i<q->bands; i++) {
 		if (q->queues[i] == &noop_qdisc) {
 			struct Qdisc *child;
-			child = qdisc_create_dflt(sch->dev, &pfifo_qdisc_ops,
+			child = qdisc_create_dflt(sch->dev, sch->dev_queue,
+						  &pfifo_qdisc_ops,
 						  TC_H_MAKE(sch->handle, i + 1));
 			if (child) {
 				sch_tree_lock(sch);
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index 5c56985..d10c47a 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -180,7 +180,8 @@ static struct Qdisc *red_create_dflt(struct Qdisc *sch, u32 limit)
 	struct nlattr *nla;
 	int ret;
 
-	q = qdisc_create_dflt(sch->dev, &bfifo_qdisc_ops,
+	q = qdisc_create_dflt(sch->dev, sch->dev_queue,
+			      &bfifo_qdisc_ops,
 			      TC_H_MAKE(sch->handle, 1));
 	if (q) {
 		nla = kmalloc(nla_attr_size(sizeof(struct tc_fifo_qopt)),
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 0b7d78f..61559e1 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -248,7 +248,8 @@ static struct Qdisc *tbf_create_dflt_qdisc(struct Qdisc *sch, u32 limit)
 	struct nlattr *nla;
 	int ret;
 
-	q = qdisc_create_dflt(sch->dev, &bfifo_qdisc_ops,
+	q = qdisc_create_dflt(sch->dev, sch->dev_queue,
+			      &bfifo_qdisc_ops,
 			      TC_H_MAKE(sch->handle, 1));
 	if (q) {
 		nla = kmalloc(nla_attr_size(sizeof(struct tc_fifo_qopt)),
-- 
1.5.6

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
