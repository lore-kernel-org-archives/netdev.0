From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2.4] Use double-linked list for dev->qdisc_list
Date: Sat, 14 Aug 2004 10:17:12 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <411DCA88.3080508@trash.net>
References: <20040804125926.GA15324@krezus.e-wro.net>	<4110E505.1010205@trash.net>	<20040804145610.GA21339@krezus.e-wro.net> <20040804134432.40500c15.davem@redhat.com> <41115A37.30806@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050501020404090900080208"
Cc: Tomasz Paszkowski <tomasz.paszkowski@e-wro.pl>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <41115A37.30806@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050501020404090900080208
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi Dave,

Patrick McHardy wrote:
> David S. Miller wrote:
> 
>> Can someone regenerate this patch with the q_idx fix Patrick
>> just posted added to it?
>>  
>>
> Updated patch for 2.4 attached.

seems like you missed this patch.

Regards
Patrick

--------------050501020404090900080208
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/08/04 23:46:47+02:00 kaber@coreworks.de 
#   [PKT_SCHED]: Use double-linked list for dev->qdisc_list
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/sch_generic.c
#   2004/08/04 23:46:40+02:00 kaber@coreworks.de +6 -19
#   [PKT_SCHED]: Use double-linked list for dev->qdisc_list
# 
# net/sched/sch_api.c
#   2004/08/04 23:46:40+02:00 kaber@coreworks.de +18 -10
#   [PKT_SCHED]: Use double-linked list for dev->qdisc_list
# 
# include/net/pkt_sched.h
#   2004/08/04 23:46:40+02:00 kaber@coreworks.de +1 -1
#   [PKT_SCHED]: Use double-linked list for dev->qdisc_list
# 
# include/linux/netdevice.h
#   2004/08/04 23:46:40+02:00 kaber@coreworks.de +1 -1
#   [PKT_SCHED]: Use double-linked list for dev->qdisc_list
# 
diff -Nru a/include/linux/netdevice.h b/include/linux/netdevice.h
--- a/include/linux/netdevice.h	2004-08-04 23:49:06 +02:00
+++ b/include/linux/netdevice.h	2004-08-04 23:49:06 +02:00
@@ -352,8 +352,8 @@
 
 	struct Qdisc		*qdisc;
 	struct Qdisc		*qdisc_sleeping;
-	struct Qdisc		*qdisc_list;
 	struct Qdisc		*qdisc_ingress;
+	struct list_head	qdisc_list;
 	unsigned long		tx_queue_len;	/* Max frames per queue allowed */
 
 	/* hard_start_xmit synchronizer */
diff -Nru a/include/net/pkt_sched.h b/include/net/pkt_sched.h
--- a/include/net/pkt_sched.h	2004-08-04 23:49:06 +02:00
+++ b/include/net/pkt_sched.h	2004-08-04 23:49:06 +02:00
@@ -80,11 +80,11 @@
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
 	int			(*reshape_fail)(struct sk_buff *skb, struct Qdisc *q);
diff -Nru a/net/sched/sch_api.c b/net/sched/sch_api.c
--- a/net/sched/sch_api.c	2004-08-04 23:49:06 +02:00
+++ b/net/sched/sch_api.c	2004-08-04 23:49:06 +02:00
@@ -32,6 +32,7 @@
 #include <linux/init.h>
 #include <linux/proc_fs.h>
 #include <linux/kmod.h>
+#include <linux/list.h>
 
 #include <net/sock.h>
 #include <net/pkt_sched.h>
@@ -193,7 +194,7 @@
 {
 	struct Qdisc *q;
 
-	for (q = dev->qdisc_list; q; q = q->next) {
+	list_for_each_entry(q, &dev->qdisc_list, list) {
 		if (q->handle == handle)
 			return q;
 	}
@@ -424,6 +425,7 @@
 
 	memset(sch, 0, size);
 
+	INIT_LIST_HEAD(&sch->list);
 	skb_queue_head_init(&sch->q);
 
 	if (handle == TC_H_INGRESS)
@@ -449,8 +451,7 @@
 
 	if (!ops->init || (err = ops->init(sch, tca[TCA_OPTIONS-1])) == 0) {
 		write_lock(&qdisc_tree_lock);
-		sch->next = dev->qdisc_list;
-		dev->qdisc_list = sch;
+		list_add_tail(&sch->list, &dev->qdisc_list);
 		write_unlock(&qdisc_tree_lock);
 #ifdef CONFIG_NET_ESTIMATOR
 		if (tca[TCA_RATE-1])
@@ -805,15 +806,18 @@
 		if (idx > s_idx)
 			s_q_idx = 0;
 		read_lock(&qdisc_tree_lock);
-		for (q = dev->qdisc_list, q_idx = 0; q;
-		     q = q->next, q_idx++) {
-			if (q_idx < s_q_idx)
+		q_idx = 0;
+		list_for_each_entry(q, &dev->qdisc_list, list) {
+			if (q_idx < s_q_idx) {
+				q_idx++;
 				continue;
+			}
 			if (tc_fill_qdisc(skb, q, 0, NETLINK_CB(cb->skb).pid,
 					  cb->nlh->nlmsg_seq, NLM_F_MULTI, RTM_NEWQDISC) <= 0) {
 				read_unlock(&qdisc_tree_lock);
 				goto done;
 			}
+			q_idx++;
 		}
 		read_unlock(&qdisc_tree_lock);
 	}
@@ -1024,13 +1028,16 @@
 		return 0;
 
 	s_t = cb->args[0];
+	t = 0;
 
 	read_lock(&qdisc_tree_lock);
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
@@ -1043,6 +1050,7 @@
 		cb->args[1] = arg.w.count;
 		if (arg.w.stop)
 			break;
+		t++;
 	}
 	read_unlock(&qdisc_tree_lock);
 
diff -Nru a/net/sched/sch_generic.c b/net/sched/sch_generic.c
--- a/net/sched/sch_generic.c	2004-08-04 23:49:06 +02:00
+++ b/net/sched/sch_generic.c	2004-08-04 23:49:06 +02:00
@@ -29,6 +29,7 @@
 #include <linux/skbuff.h>
 #include <linux/rtnetlink.h>
 #include <linux/init.h>
+#include <linux/list.h>
 #include <net/sock.h>
 #include <net/pkt_sched.h>
 
@@ -391,6 +392,7 @@
 		return NULL;
 	memset(sch, 0, size);
 
+	INIT_LIST_HEAD(&sch->list);
 	skb_queue_head_init(&sch->q);
 	sch->ops = ops;
 	sch->enqueue = ops->enqueue;
@@ -420,22 +422,10 @@
 void qdisc_destroy(struct Qdisc *qdisc)
 {
 	struct Qdisc_ops *ops = qdisc->ops;
-	struct net_device *dev;
 
 	if (!atomic_dec_and_test(&qdisc->refcnt))
 		return;
-
-	dev = qdisc->dev;
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
 #ifdef CONFIG_NET_ESTIMATOR
 	qdisc_kill_estimator(&qdisc->stats);
 #endif
@@ -464,10 +454,8 @@
 				printk(KERN_INFO "%s: activation failed\n", dev->name);
 				return;
 			}
-
 			write_lock(&qdisc_tree_lock);
-			qdisc->next = dev->qdisc_list;
-			dev->qdisc_list = qdisc;
+			list_add_tail(&qdisc->list, &dev->qdisc_list);
 			write_unlock(&qdisc_tree_lock);
 
 		} else {
@@ -513,7 +501,7 @@
 	dev->qdisc = &noop_qdisc;
 	spin_unlock_bh(&dev->queue_lock);
 	dev->qdisc_sleeping = &noop_qdisc;
-	dev->qdisc_list = NULL;
+	INIT_LIST_HEAD(&dev->qdisc_list);
 	write_unlock(&qdisc_tree_lock);
 
 	dev_watchdog_init(dev);
@@ -535,9 +523,8 @@
 		qdisc_destroy(qdisc);
         }
 #endif
-	BUG_TRAP(dev->qdisc_list == NULL);
+	BUG_TRAP(list_empty(&dev->qdisc_list));
 	BUG_TRAP(!timer_pending(&dev->watchdog_timer));
-	dev->qdisc_list = NULL;
 	spin_unlock_bh(&dev->queue_lock);
 	write_unlock(&qdisc_tree_lock);
 }

--------------050501020404090900080208--
