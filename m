From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2.6 1/5]: Fix locking in __qdisc_destroy rcu-callback
Date: Tue, 03 Aug 2004 17:20:36 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <410FAD44.7020503@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010405060805000700060907"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010405060805000700060907
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

The __qdisc_destroy rcu-callback doesn't do any locking when calling
ops->reset and ops->destroy. qdisc_destroy is often called from both
of these functions and it changes dev->qdisc_list. This patch adds proper
locking to __qdisc_destroy. Unfortunately when using qdisc_tree_lock in
process context we now also need to disable local bh's to avoid beeing
interrupted by the rcu-callback. I'm not sure if RCU callback can be
scheduled while the kernel is running in process context, so this may
be unneccessary.


--------------010405060805000700060907
Content-Type: text/x-patch;
 name="01-qdisc_destroy-rcu-locking.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01-qdisc_destroy-rcu-locking.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/08/02 14:02:29+02:00 kaber@coreworks.de 
#   [PKT_SCHED]: Fix locking in __qdisc_destroy rcu-callback
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/sch_generic.c
#   2004/08/02 14:02:07+02:00 kaber@coreworks.de +12 -12
#   [PKT_SCHED]: Fix locking in __qdisc_destroy rcu-callback
# 
# net/sched/sch_api.c
#   2004/08/02 14:02:07+02:00 kaber@coreworks.de +5 -5
#   [PKT_SCHED]: Fix locking in __qdisc_destroy rcu-callback
# 
diff -Nru a/net/sched/sch_api.c b/net/sched/sch_api.c
--- a/net/sched/sch_api.c	2004-08-03 01:09:43 +02:00
+++ b/net/sched/sch_api.c	2004-08-03 01:09:43 +02:00
@@ -812,18 +812,18 @@
 			continue;
 		if (idx > s_idx)
 			s_q_idx = 0;
-		read_lock(&qdisc_tree_lock);
+		read_lock_bh(&qdisc_tree_lock);
 		for (q = dev->qdisc_list, q_idx = 0; q;
 		     q = q->next, q_idx++) {
 			if (q_idx < s_q_idx)
 				continue;
 			if (tc_fill_qdisc(skb, q, 0, NETLINK_CB(cb->skb).pid,
 					  cb->nlh->nlmsg_seq, NLM_F_MULTI, RTM_NEWQDISC) <= 0) {
-				read_unlock(&qdisc_tree_lock);
+				read_unlock_bh(&qdisc_tree_lock);
 				goto done;
 			}
 		}
-		read_unlock(&qdisc_tree_lock);
+		read_unlock_bh(&qdisc_tree_lock);
 	}
 
 done:
@@ -1033,7 +1033,7 @@
 
 	s_t = cb->args[0];
 
-	read_lock(&qdisc_tree_lock);
+	read_lock_bh(&qdisc_tree_lock);
 	for (q=dev->qdisc_list, t=0; q; q = q->next, t++) {
 		if (t < s_t) continue;
 		if (!q->ops->cl_ops) continue;
@@ -1052,7 +1052,7 @@
 		if (arg.w.stop)
 			break;
 	}
-	read_unlock(&qdisc_tree_lock);
+	read_unlock_bh(&qdisc_tree_lock);
 
 	cb->args[0] = t;
 
diff -Nru a/net/sched/sch_generic.c b/net/sched/sch_generic.c
--- a/net/sched/sch_generic.c	2004-08-03 01:09:43 +02:00
+++ b/net/sched/sch_generic.c	2004-08-03 01:09:43 +02:00
@@ -45,10 +45,11 @@
    The idea is the following:
    - enqueue, dequeue are serialized via top level device
      spinlock dev->queue_lock.
-   - tree walking is protected by read_lock(qdisc_tree_lock)
+   - tree walking is protected by read_lock_bh(qdisc_tree_lock)
      and this lock is used only in process context.
-   - updates to tree are made only under rtnl semaphore,
-     hence this lock may be made without local bh disabling.
+   - updates to tree are made under rtnl semaphore or
+     from softirq context (__qdisc_destroy rcu-callback)
+     hence this lock needs local bh disabling.
 
    qdisc_tree_lock must be grabbed BEFORE dev->queue_lock!
  */
@@ -56,14 +57,14 @@
 
 void qdisc_lock_tree(struct net_device *dev)
 {
-	write_lock(&qdisc_tree_lock);
+	write_lock_bh(&qdisc_tree_lock);
 	spin_lock_bh(&dev->queue_lock);
 }
 
 void qdisc_unlock_tree(struct net_device *dev)
 {
 	spin_unlock_bh(&dev->queue_lock);
-	write_unlock(&qdisc_tree_lock);
+	write_unlock_bh(&qdisc_tree_lock);
 }
 
 /* 
@@ -431,10 +432,12 @@
 #ifdef CONFIG_NET_ESTIMATOR
 	qdisc_kill_estimator(&qdisc->stats);
 #endif
+	write_lock(&qdisc_tree_lock);
 	if (ops->reset)
 		ops->reset(qdisc);
 	if (ops->destroy)
 		ops->destroy(qdisc);
+	write_unlock(&qdisc_tree_lock);
 	module_put(ops->owner);
 
 	if (!(qdisc->flags&TCQ_F_BUILTIN))
@@ -459,12 +462,9 @@
 			}
 		}
 	}
-
 	call_rcu(&qdisc->q_rcu, __qdisc_destroy);
-
 }
 
-
 void dev_activate(struct net_device *dev)
 {
 	/* No queueing discipline is attached to device;
@@ -482,17 +482,17 @@
 				return;
 			}
 
-			write_lock(&qdisc_tree_lock);
+			write_lock_bh(&qdisc_tree_lock);
 			qdisc->next = dev->qdisc_list;
 			dev->qdisc_list = qdisc;
-			write_unlock(&qdisc_tree_lock);
+			write_unlock_bh(&qdisc_tree_lock);
 
 		} else {
 			qdisc =  &noqueue_qdisc;
 		}
-		write_lock(&qdisc_tree_lock);
+		write_lock_bh(&qdisc_tree_lock);
 		dev->qdisc_sleeping = qdisc;
-		write_unlock(&qdisc_tree_lock);
+		write_unlock_bh(&qdisc_tree_lock);
 	}
 
 	spin_lock_bh(&dev->queue_lock);

--------------010405060805000700060907--
