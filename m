From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2.6 3/5]: Use double-linked list for dev->qdisc_list
Date: Tue, 3 Aug 2004 08:35:40 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040803083540.13675d64@dell_ss3.pdx.osdl.net>
References: <410FAE42.2050909@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <410FAE42.2050909@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 03 Aug 2004 17:24:50 +0200
Patrick McHardy <kaber@trash.net> wrote:

> This patch changes dev->qdisc_list to a double-linked list. This solves
> the performance problems when destroying qdiscs with large number of inner
> qdiscs.
> 
> 

Since qdisc lists are using rcu for deletion, you should use the
_rcu flavors of list stuff.


replace BUG_TRAP(dev->qdisc_list == NULL);
with BUG_TRAP(list_empty(&dev->qdisc_list));

I tried a similar patch but was finding the bug_trap() was showing up on
deletion so did not trust it.

This is what I was experimenting with.

------------
diff -Nru a/include/linux/netdevice.h b/include/linux/netdevice.h
--- a/include/linux/netdevice.h	2004-07-28 15:14:27 -07:00
+++ b/include/linux/netdevice.h	2004-07-28 15:14:27 -07:00
@@ -362,7 +362,7 @@
 
 	struct Qdisc		*qdisc;
 	struct Qdisc		*qdisc_sleeping;
-	struct Qdisc		*qdisc_list;
+	struct list_head	qdisc_list;
 	struct Qdisc		*qdisc_ingress;
 	unsigned long		tx_queue_len;	/* Max frames per queue allowed */
 
diff -Nru a/include/net/pkt_sched.h b/include/net/pkt_sched.h
--- a/include/net/pkt_sched.h	2004-07-28 15:14:27 -07:00
+++ b/include/net/pkt_sched.h	2004-07-28 15:14:27 -07:00
@@ -79,7 +79,7 @@
 #define TCQ_F_INGRES	4
 	int			padded;
 	struct Qdisc_ops	*ops;
-	struct Qdisc		*next;
+	struct list_head	list;
 	u32			handle;
 	atomic_t		refcnt;
 	struct sk_buff_head	q;
diff -Nru a/net/sched/sch_api.c b/net/sched/sch_api.c
--- a/net/sched/sch_api.c	2004-07-28 15:14:27 -07:00
+++ b/net/sched/sch_api.c	2004-07-28 15:14:27 -07:00
@@ -195,7 +195,7 @@
 {
 	struct Qdisc *q;
 
-	for (q = dev->qdisc_list; q; q = q->next) {
+	list_for_each_entry_rcu(q, &dev->qdisc_list, list) {
 		if (q->handle == handle)
 			return q;
 	}
@@ -453,8 +453,7 @@
 	smp_wmb();
 	if (!ops->init || (err = ops->init(sch, tca[TCA_OPTIONS-1])) == 0) {
 		qdisc_lock_tree(dev);
-		sch->next = dev->qdisc_list;
-		dev->qdisc_list = sch;
+		list_add_rcu(&sch->list, &dev->qdisc_list);
 		qdisc_unlock_tree(dev);
 
 #ifdef CONFIG_NET_ESTIMATOR
@@ -812,18 +811,20 @@
 			continue;
 		if (idx > s_idx)
 			s_q_idx = 0;
-		read_lock(&qdisc_tree_lock);
-		for (q = dev->qdisc_list, q_idx = 0; q;
-		     q = q->next, q_idx++) {
-			if (q_idx < s_q_idx)
+
+		rcu_read_lock();
+
+		q_idx = 0;
+		list_for_each_entry_rcu(q, &dev->qdisc_list, list) {
+			if (q_idx++ < s_q_idx)
 				continue;
 			if (tc_fill_qdisc(skb, q, 0, NETLINK_CB(cb->skb).pid,
 					  cb->nlh->nlmsg_seq, NLM_F_MULTI, RTM_NEWQDISC) <= 0) {
-				read_unlock(&qdisc_tree_lock);
+				rcu_read_unlock();
 				goto done;
 			}
 		}
-		read_unlock(&qdisc_tree_lock);
+		rcu_read_unlock();
 	}
 
 done:
@@ -1033,9 +1034,10 @@
 
 	s_t = cb->args[0];
 
-	read_lock(&qdisc_tree_lock);
-	for (q=dev->qdisc_list, t=0; q; q = q->next, t++) {
-		if (t < s_t) continue;
+	rcu_read_lock();
+	t = 0;
+	list_for_each_entry_rcu(q, &dev->qdisc_list, list) {
+		if (t++ < s_t) continue;
 		if (!q->ops->cl_ops) continue;
 		if (tcm->tcm_parent && TC_H_MAJ(tcm->tcm_parent) != q->handle)
 			continue;
@@ -1052,7 +1054,7 @@
 		if (arg.w.stop)
 			break;
 	}
-	read_unlock(&qdisc_tree_lock);
+	rcu_read_unlock();
 
 	cb->args[0] = t;
 
diff -Nru a/net/sched/sch_generic.c b/net/sched/sch_generic.c
--- a/net/sched/sch_generic.c	2004-07-28 15:14:27 -07:00
+++ b/net/sched/sch_generic.c	2004-07-28 15:14:27 -07:00
@@ -405,6 +405,8 @@
 	sch->dev = dev;
 	sch->stats_lock = &dev->queue_lock;
 	atomic_set(&sch->refcnt, 1);
+	INIT_LIST_HEAD(&sch->list);
+
 	/* enqueue is accessed locklessly - make sure it's visible
 	 * before we set a netdevice's qdisc pointer to sch */
 	smp_wmb();
@@ -450,23 +452,12 @@
 
 void qdisc_destroy(struct Qdisc *qdisc)
 {
-	struct net_device *dev = qdisc->dev;
-
 	if (!atomic_dec_and_test(&qdisc->refcnt))
 		return;
 
-	if (dev) {
-		struct Qdisc *q, **qp;
-		for (qp = &qdisc->dev->qdisc_list; (q=*qp) != NULL; qp = &q->next) {
-			if (q == qdisc) {
-				*qp = q->next;
-				break;
-			}
-		}
-	}
-
+	if (qdisc->dev)
+		list_del_rcu(&qdisc->list);
 	call_rcu(&qdisc->q_rcu, __qdisc_destroy);
-
 }
 
 
@@ -488,8 +479,7 @@
 			}
 
 			write_lock(&qdisc_tree_lock);
-			qdisc->next = dev->qdisc_list;
-			dev->qdisc_list = qdisc;
+			list_add_rcu(&qdisc->list, &dev->qdisc_list);
 			write_unlock(&qdisc_tree_lock);
 
 		} else {
@@ -533,7 +523,7 @@
 	qdisc_lock_tree(dev);
 	dev->qdisc = &noop_qdisc;
 	dev->qdisc_sleeping = &noop_qdisc;
-	dev->qdisc_list = NULL;
+	INIT_LIST_HEAD(&dev->qdisc_list);
 	qdisc_unlock_tree(dev);
 
 	dev_watchdog_init(dev);
@@ -554,9 +544,9 @@
 		qdisc_destroy(qdisc);
         }
 #endif
-	BUG_TRAP(dev->qdisc_list == NULL);
+	BUG_TRAP(!list_empty(&dev->qdisc_list));
 	BUG_TRAP(!timer_pending(&dev->watchdog_timer));
-	dev->qdisc_list = NULL;
+
 	qdisc_unlock_tree(dev);
 }
 
