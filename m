From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] de-inline qdiscipline locking functions.
Date: Mon, 26 Jul 2004 11:34:02 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040726113402.25ba72ee@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This qdisc code has several inline functions for locking that is only
used when adding/deleting queuing disciplines; so make them functions
instead.  The new qdisc_lock_tree encapsulates the locking used throughout
this code.

Also qdisc_run() is only called from net/core/dev.c so it should be
defined there.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
 
diff -Nru a/include/net/pkt_sched.h b/include/net/pkt_sched.h
--- a/include/net/pkt_sched.h	2004-07-26 10:21:24 -07:00
+++ b/include/net/pkt_sched.h	2004-07-26 10:21:24 -07:00
@@ -105,43 +105,15 @@
 	int		refcnt;
 };
 
-static inline void sch_tree_lock(struct Qdisc *q)
-{
-	write_lock(&qdisc_tree_lock);
-	spin_lock_bh(&q->dev->queue_lock);
-}
-
-static inline void sch_tree_unlock(struct Qdisc *q)
-{
-	spin_unlock_bh(&q->dev->queue_lock);
-	write_unlock(&qdisc_tree_lock);
-}
-
-static inline void tcf_tree_lock(struct tcf_proto *tp)
-{
-	write_lock(&qdisc_tree_lock);
-	spin_lock_bh(&tp->q->dev->queue_lock);
-}
-
-static inline void tcf_tree_unlock(struct tcf_proto *tp)
-{
-	spin_unlock_bh(&tp->q->dev->queue_lock);
-	write_unlock(&qdisc_tree_lock);
-}
+extern void qdisc_lock_tree(struct net_device *dev);
+extern void qdisc_unlock_tree(struct net_device *dev);
 
+#define sch_tree_lock(q)	qdisc_lock_tree((q)->dev)
+#define sch_tree_unlock(q)	qdisc_unlock_tree((q)->dev)
+#define tcf_tree_lock(tp)	qdisc_lock_tree((tp)->q->dev)
+#define tcf_tree_unlock(tp)	qdisc_unlock_tree((tp)->q->dev)
 
-static inline unsigned long
-cls_set_class(struct tcf_proto *tp, unsigned long *clp, unsigned long cl)
-{
-	unsigned long old_cl;
-
-	tcf_tree_lock(tp);
-	old_cl = *clp;
-	*clp = cl;
-	tcf_tree_unlock(tp);
-	return old_cl;
-}
-
+#define cls_set_class(tp, clp, cl) tcf_set_class(tp, clp, cl)
 static inline unsigned long
 __cls_set_class(unsigned long *clp, unsigned long cl)
 {
@@ -407,6 +379,8 @@
 extern int tcf_act_police(struct sk_buff **skb, struct tc_action *a);
 #endif
 
+extern unsigned long tcf_set_class(struct tcf_proto *tp, unsigned long *clp, 
+				   unsigned long cl);
 extern int tcf_police(struct sk_buff *skb, struct tcf_police *p);
 extern int qdisc_copy_stats(struct sk_buff *skb, struct tc_stats *st, spinlock_t *lock);
 extern void tcf_police_destroy(struct tcf_police *p);
@@ -457,13 +431,6 @@
 void qdisc_put_rtab(struct qdisc_rate_table *tab);
 
 extern int qdisc_restart(struct net_device *dev);
-
-static inline void qdisc_run(struct net_device *dev)
-{
-	while (!netif_queue_stopped(dev) &&
-	       qdisc_restart(dev)<0)
-		/* NOTHING */;
-}
 
 /* Calculate maximal size of packet seen by hard_start_xmit
    routine of this device.
diff -Nru a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c	2004-07-26 10:21:24 -07:00
+++ b/net/core/dev.c	2004-07-26 10:21:24 -07:00
@@ -1320,6 +1320,13 @@
 	}						\
 }
 
+static inline void qdisc_run(struct net_device *dev)
+{
+	while (!netif_queue_stopped(dev) &&
+	       qdisc_restart(dev)<0)
+		/* NOTHING */;
+}
+
 /**
  *	dev_queue_xmit - transmit a buffer
  *	@skb: buffer to transmit
diff -Nru a/net/sched/cls_api.c b/net/sched/cls_api.c
--- a/net/sched/cls_api.c	2004-07-26 10:21:24 -07:00
+++ b/net/sched/cls_api.c	2004-07-26 10:21:24 -07:00
@@ -236,12 +236,12 @@
 			kfree(tp);
 			goto errout;
 		}
-		write_lock(&qdisc_tree_lock);
-		spin_lock_bh(&dev->queue_lock);
+
+		qdisc_lock_tree(dev);
 		tp->next = *back;
 		*back = tp;
-		spin_unlock_bh(&dev->queue_lock);
-		write_unlock(&qdisc_tree_lock);
+		qdisc_unlock_tree(dev);
+
 	} else if (tca[TCA_KIND-1] && rtattr_strcmp(tca[TCA_KIND-1], tp->ops->kind))
 		goto errout;
 
@@ -249,11 +249,10 @@
 
 	if (fh == 0) {
 		if (n->nlmsg_type == RTM_DELTFILTER && t->tcm_handle == 0) {
-			write_lock(&qdisc_tree_lock);
-			spin_lock_bh(&dev->queue_lock);
+			qdisc_lock_tree(dev);
 			*back = tp->next;
-			spin_unlock_bh(&dev->queue_lock);
-			write_unlock(&qdisc_tree_lock);
+			qdisc_unlock_tree(dev);
+
 			tfilter_notify(skb, n, tp, fh_s, RTM_DELTFILTER);
 			tcf_destroy(tp);
 			err = 0;
@@ -294,6 +293,19 @@
 	return err;
 }
 
+unsigned long tcf_set_class(struct tcf_proto *tp, unsigned long *clp, 
+			    unsigned long cl)
+{
+	unsigned long old_cl;
+
+	tcf_tree_lock(tp);
+	old_cl = __cls_set_class(clp, cl);
+	tcf_tree_unlock(tp);
+
+	return old_cl;
+}
+
+
 static int
 tcf_fill_node(struct sk_buff *skb, struct tcf_proto *tp, unsigned long fh,
 	      u32 pid, u32 seq, unsigned flags, int event)
@@ -459,3 +471,4 @@
 
 EXPORT_SYMBOL(register_tcf_proto_ops);
 EXPORT_SYMBOL(unregister_tcf_proto_ops);
+EXPORT_SYMBOL(tcf_set_class);
diff -Nru a/net/sched/sch_api.c b/net/sched/sch_api.c
--- a/net/sched/sch_api.c	2004-07-26 10:21:24 -07:00
+++ b/net/sched/sch_api.c	2004-07-26 10:21:24 -07:00
@@ -306,8 +306,7 @@
 	if (dev->flags & IFF_UP)
 		dev_deactivate(dev);
 
-	write_lock(&qdisc_tree_lock);
-	spin_lock_bh(&dev->queue_lock);
+	qdisc_lock_tree(dev);
 	if (qdisc && qdisc->flags&TCQ_F_INGRES) {
 		oqdisc = dev->qdisc_ingress;
 		/* Prune old scheduler */
@@ -334,8 +333,7 @@
 		dev->qdisc = &noop_qdisc;
 	}
 
-	spin_unlock_bh(&dev->queue_lock);
-	write_unlock(&qdisc_tree_lock);
+	qdisc_unlock_tree(dev);
 
 	if (dev->flags & IFF_UP)
 		dev_activate(dev);
@@ -454,10 +452,11 @@
 	 * before we set a netdevice's qdisc pointer to sch */
 	smp_wmb();
 	if (!ops->init || (err = ops->init(sch, tca[TCA_OPTIONS-1])) == 0) {
-		write_lock(&qdisc_tree_lock);
+		qdisc_lock_tree(dev);
 		sch->next = dev->qdisc_list;
 		dev->qdisc_list = sch;
-		write_unlock(&qdisc_tree_lock);
+		qdisc_unlock_tree(dev);
+
 #ifdef CONFIG_NET_ESTIMATOR
 		if (tca[TCA_RATE-1])
 			qdisc_new_estimator(&sch->stats, sch->stats_lock,
diff -Nru a/net/sched/sch_generic.c b/net/sched/sch_generic.c
--- a/net/sched/sch_generic.c	2004-07-26 10:21:24 -07:00
+++ b/net/sched/sch_generic.c	2004-07-26 10:21:24 -07:00
@@ -54,6 +54,18 @@
  */
 rwlock_t qdisc_tree_lock = RW_LOCK_UNLOCKED;
 
+void qdisc_lock_tree(struct net_device *dev)
+{
+	write_lock(&qdisc_tree_lock);
+	spin_lock_bh(&dev->queue_lock);
+}
+
+void qdisc_unlock_tree(struct net_device *dev)
+{
+	spin_unlock_bh(&dev->queue_lock);
+	write_unlock(&qdisc_tree_lock);
+}
+
 /* 
    dev->queue_lock serializes queue accesses for this device
    AND dev->qdisc pointer itself.
@@ -513,13 +525,11 @@
 
 void dev_init_scheduler(struct net_device *dev)
 {
-	write_lock(&qdisc_tree_lock);
-	spin_lock_bh(&dev->queue_lock);
+	qdisc_lock_tree(dev);
 	dev->qdisc = &noop_qdisc;
-	spin_unlock_bh(&dev->queue_lock);
 	dev->qdisc_sleeping = &noop_qdisc;
 	dev->qdisc_list = NULL;
-	write_unlock(&qdisc_tree_lock);
+	qdisc_unlock_tree(dev);
 
 	dev_watchdog_init(dev);
 }
@@ -528,8 +538,7 @@
 {
 	struct Qdisc *qdisc;
 
-	write_lock(&qdisc_tree_lock);
-	spin_lock_bh(&dev->queue_lock);
+	qdisc_lock_tree(dev);
 	qdisc = dev->qdisc_sleeping;
 	dev->qdisc = &noop_qdisc;
 	dev->qdisc_sleeping = &noop_qdisc;
@@ -543,8 +552,7 @@
 	BUG_TRAP(dev->qdisc_list == NULL);
 	BUG_TRAP(!timer_pending(&dev->watchdog_timer));
 	dev->qdisc_list = NULL;
-	spin_unlock_bh(&dev->queue_lock);
-	write_unlock(&qdisc_tree_lock);
+	qdisc_unlock_tree(dev);
 }
 
 EXPORT_SYMBOL(__netdev_watchdog_up);
@@ -554,4 +562,5 @@
 EXPORT_SYMBOL(qdisc_destroy);
 EXPORT_SYMBOL(qdisc_reset);
 EXPORT_SYMBOL(qdisc_restart);
-EXPORT_SYMBOL(qdisc_tree_lock);
+EXPORT_SYMBOL(qdisc_lock_tree);
+EXPORT_SYMBOL(qdisc_unlock_tree);
