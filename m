From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2.6 3/5]: Use double-linked list for dev->qdisc_list
Date: Tue, 03 Aug 2004 17:24:50 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <410FAE42.2050909@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030000030800010808020702"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030000030800010808020702
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

This patch changes dev->qdisc_list to a double-linked list. This solves
the performance problems when destroying qdiscs with large number of inner
qdiscs.


--------------030000030800010808020702
Content-Type: text/x-patch;
 name="03-qdisc_list-list_h.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="03-qdisc_list-list_h.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/08/03 00:48:50+02:00 kaber@coreworks.de 
#   [PKT_SCHED]: Use double-linked list for dev->qdisc_list
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/sch_generic.c
#   2004/08/03 00:48:19+02:00 kaber@coreworks.de +5 -19
#   [PKT_SCHED]: Use double-linked list for dev->qdisc_list
# 
# net/sched/sch_api.c
#   2004/08/03 00:48:19+02:00 kaber@coreworks.de +16 -11
#   [PKT_SCHED]: Use double-linked list for dev->qdisc_list
# 
# include/net/pkt_sched.h
#   2004/08/03 00:48:19+02:00 kaber@coreworks.de +1 -1
#   [PKT_SCHED]: Use double-linked list for dev->qdisc_list
# 
# include/linux/netdevice.h
#   2004/08/03 00:48:19+02:00 kaber@coreworks.de +1 -1
#   [PKT_SCHED]: Use double-linked list for dev->qdisc_list
# 
diff -Nru a/include/linux/netdevice.h b/include/linux/netdevice.h
--- a/include/linux/netdevice.h	2004-08-03 01:11:00 +02:00
+++ b/include/linux/netdevice.h	2004-08-03 01:11:00 +02:00
@@ -362,8 +362,8 @@
 
 	struct Qdisc		*qdisc;
 	struct Qdisc		*qdisc_sleeping;
-	struct Qdisc		*qdisc_list;
 	struct Qdisc		*qdisc_ingress;
+	struct list_head	qdisc_list;
 	unsigned long		tx_queue_len;	/* Max frames per queue allowed */
 
 	/* ingress path synchronizer */
diff -Nru a/include/net/pkt_sched.h b/include/net/pkt_sched.h
--- a/include/net/pkt_sched.h	2004-08-03 01:11:00 +02:00
+++ b/include/net/pkt_sched.h	2004-08-03 01:11:00 +02:00
@@ -78,11 +78,11 @@
 #define TCQ_F_THROTTLED	2
 #define TCQ_F_INGRES	4
 	struct Qdisc_ops	*ops;
-	struct Qdisc		*next;
 	u32			handle;
 	atomic_t		refcnt;
 	struct sk_buff_head	q;
 	struct net_device	*dev;
+	struct list_head	list;
 
 	struct tc_stats		stats;
 	spinlock_t		*stats_lock;
diff -Nru a/net/sched/sch_api.c b/net/sched/sch_api.c
--- a/net/sched/sch_api.c	2004-08-03 01:11:00 +02:00
+++ b/net/sched/sch_api.c	2004-08-03 01:11:00 +02:00
@@ -34,6 +34,7 @@
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/kmod.h>
+#include <linux/list.h>
 
 #include <net/sock.h>
 #include <net/pkt_sched.h>
@@ -195,7 +196,7 @@
 {
 	struct Qdisc *q;
 
-	for (q = dev->qdisc_list; q; q = q->next) {
+	list_for_each_entry(q, &dev->qdisc_list, list) {
 		if (q->handle == handle)
 			return q;
 	}
@@ -421,6 +422,7 @@
 
 	memset(sch, 0, size);
 
+	INIT_LIST_HEAD(&sch->list);
 	skb_queue_head_init(&sch->q);
 
 	if (handle == TC_H_INGRESS)
@@ -454,8 +456,7 @@
 	smp_wmb();
 	if (!ops->init || (err = ops->init(sch, tca[TCA_OPTIONS-1])) == 0) {
 		qdisc_lock_tree(dev);
-		sch->next = dev->qdisc_list;
-		dev->qdisc_list = sch;
+		list_add_tail(&sch->list, &dev->qdisc_list);
 		qdisc_unlock_tree(dev);
 
 #ifdef CONFIG_NET_ESTIMATOR
@@ -814,9 +815,9 @@
 		if (idx > s_idx)
 			s_q_idx = 0;
 		read_lock_bh(&qdisc_tree_lock);
-		for (q = dev->qdisc_list, q_idx = 0; q;
-		     q = q->next, q_idx++) {
-			if (q_idx < s_q_idx)
+		q_idx = 0;
+		list_for_each_entry(q, &dev->qdisc_list, list) {
+			if (q_idx++ < s_q_idx)
 				continue;
 			if (tc_fill_qdisc(skb, q, 0, NETLINK_CB(cb->skb).pid,
 					  cb->nlh->nlmsg_seq, NLM_F_MULTI, RTM_NEWQDISC) <= 0) {
@@ -831,7 +832,7 @@
 	read_unlock(&dev_base_lock);
 
 	cb->args[0] = idx;
-	cb->args[1] = q_idx;
+	cb->args[1] = q_idx - 1;
 
 	return skb->len;
 }
@@ -1033,13 +1034,16 @@
 		return 0;
 
 	s_t = cb->args[0];
+	t = 0;
 
 	read_lock_bh(&qdisc_tree_lock);
-	for (q=dev->qdisc_list, t=0; q; q = q->next, t++) {
-		if (t < s_t) continue;
-		if (!q->ops->cl_ops) continue;
-		if (tcm->tcm_parent && TC_H_MAJ(tcm->tcm_parent) != q->handle)
+	list_for_each_entry(q, &dev->qdisc_list, list) {
+		if (t < s_t || !q->ops->cl_ops ||
+		    (tcm->tcm_parent &&
+		     TC_H_MAJ(tcm->tcm_parent) != q->handle)) {
+			t++;
 			continue;
+		}
 		if (t > s_t)
 			memset(&cb->args[1], 0, sizeof(cb->args)-sizeof(cb->args[0]));
 		arg.w.fn = qdisc_class_dump;
@@ -1052,6 +1056,7 @@
 		cb->args[1] = arg.w.count;
 		if (arg.w.stop)
 			break;
+		t++;
 	}
 	read_unlock_bh(&qdisc_tree_lock);
 
diff -Nru a/net/sched/sch_generic.c b/net/sched/sch_generic.c
--- a/net/sched/sch_generic.c	2004-08-03 01:11:00 +02:00
+++ b/net/sched/sch_generic.c	2004-08-03 01:11:00 +02:00
@@ -31,6 +31,7 @@
 #include <linux/rtnetlink.h>
 #include <linux/init.h>
 #include <linux/rcupdate.h>
+#include <linux/list.h>
 #include <net/sock.h>
 #include <net/pkt_sched.h>
 
@@ -394,6 +395,7 @@
 		return NULL;
 	memset(sch, 0, size);
 
+	INIT_LIST_HEAD(&sch->list);
 	skb_queue_head_init(&sch->q);
 	sch->ops = ops;
 	sch->enqueue = ops->enqueue;
@@ -451,20 +453,9 @@
 
 void qdisc_destroy(struct Qdisc *qdisc)
 {
-	struct net_device *dev = qdisc->dev;
-
 	if (!atomic_dec_and_test(&qdisc->refcnt))
 		return;
-
-	if (dev) {
-		struct Qdisc *q, **qp;
-		for (qp = &qdisc->dev->qdisc_list; (q=*qp) != NULL; qp = &q->next) {
-			if (q == qdisc) {
-				*qp = q->next;
-				break;
-			}
-		}
-	}
+	list_del(&qdisc->list);
 	call_rcu(&qdisc->q_rcu, __qdisc_destroy);
 }
 
@@ -484,12 +475,9 @@
 				printk(KERN_INFO "%s: activation failed\n", dev->name);
 				return;
 			}
-
 			write_lock_bh(&qdisc_tree_lock);
-			qdisc->next = dev->qdisc_list;
-			dev->qdisc_list = qdisc;
+			list_add_tail(&qdisc->list, &dev->qdisc_list);
 			write_unlock_bh(&qdisc_tree_lock);
-
 		} else {
 			qdisc =  &noqueue_qdisc;
 		}
@@ -531,7 +519,7 @@
 	qdisc_lock_tree(dev);
 	dev->qdisc = &noop_qdisc;
 	dev->qdisc_sleeping = &noop_qdisc;
-	dev->qdisc_list = NULL;
+	INIT_LIST_HEAD(&dev->qdisc_list);
 	qdisc_unlock_tree(dev);
 
 	dev_watchdog_init(dev);
@@ -552,9 +540,7 @@
 		qdisc_destroy(qdisc);
         }
 #endif
-	BUG_TRAP(dev->qdisc_list == NULL);
 	BUG_TRAP(!timer_pending(&dev->watchdog_timer));
-	dev->qdisc_list = NULL;
 	qdisc_unlock_tree(dev);
 }
 

--------------030000030800010808020702--
