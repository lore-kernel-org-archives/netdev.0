From: Patrick McHardy <kaber@trash.net>
Subject: Re: tc related lockdep warning.
Date: Wed, 27 Sep 2006 14:07:04 +0200
Message-ID: <451A6968.2090607@trash.net>
References: <20060925124352.GA1592@ff.dom.local> <1159188473.5301.68.camel@jzny2> <4517D9A6.70307@trash.net> <45195219.7050105@trash.net> <20060926212034.GA3134@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030205060600030901000206"
Cc: hadi@cyberus.ca, Jarek Poplawski <jarkao2@o2.pl>,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx01.qsc.de ([213.148.129.14]:59351 "EHLO mx01.qsc.de")
	by vger.kernel.org with ESMTP id S1030205AbWI0MHL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 08:07:11 -0400
To: Dave Jones <davej@redhat.com>
In-Reply-To: <20060926212034.GA3134@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030205060600030901000206
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Dave Jones wrote:
> With this patch, I get no lockdep warnings, but the machine locks up completely.
> I hooked up a serial console, and found this..
> 
> 
> u32 classifier
>     Performance counters on
>     input device check on 
>     Actions configured 
> BUG: warning at net/sched/sch_htb.c:395/htb_safe_rb_erase()
> 
> Call Trace:
>  [<ffffffff8026f79b>] show_trace+0xae/0x336
>  [<ffffffff8026fa38>] dump_stack+0x15/0x17
>  [<ffffffff8860a171>] :sch_htb:htb_safe_rb_erase+0x3b/0x55

I found the reason for this, it was an unrelated bug. I've attached
the latest version of the locking fixes and the fix for the HTB bug.
Can you please try again?



--------------030205060600030901000206
Content-Type: text/plain;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

[NET_SCHED]: HTB: fix incorrect use of RB_EMPTY_NODE

Fix incorrect use of RB_EMPTY_NODE in htb_safe_rb_erase, which makes it
skip nodes within the rbtree instead of nodes not in the tree, resulting
in crashes later on.

The root cause for this seems to be the very counter-intuitive behaviour
of the RB_EMPTY_NODE macro, which returns _false_ when the node is empty.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 9a0cd6d60280d88c38791844c87548d45cf6f2c2
tree fdf4f4a46fb088d957322006828af557b8ce594a
parent 7e4720201ad44ace85a443f41d668a62a737e7d0
author Patrick McHardy <kaber@trash.net> Wed, 27 Sep 2006 13:27:24 +0200
committer Patrick McHardy <kaber@trash.net> Wed, 27 Sep 2006 13:27:24 +0200

 net/sched/sch_htb.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index bb3ddd4..6c058e3 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -391,7 +391,7 @@ static inline void htb_add_class_to_row(
 /* If this triggers, it is a bug in this code, but it need not be fatal */
 static void htb_safe_rb_erase(struct rb_node *rb, struct rb_root *root)
 {
-	if (RB_EMPTY_NODE(rb)) {
+	if (!RB_EMPTY_NODE(rb)) {
 		WARN_ON(1);
 	} else {
 		rb_erase(rb, root);


--------------030205060600030901000206
Content-Type: text/plain;
 name="02.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02.diff"

[NET_SCHED]: Fix fallout from dev->qdisc RCU change

The move of qdisc destruction to a rcu callback broke locking in the
entire qdisc layer by invalidating previously valid assumptions about
the context in which changes to the qdisc tree occur.

The two assumptions were:

- since changes only happen in process context, read_lock doesn't need
  bottem half protection. Now invalid since destruction of inner qdiscs,
  classifiers, actions and estimators happens in the RCU callback unless
  they're manually deleted, resulting in dead-locks when read_lock in
  process context is interrupted by write_lock_bh in bottem half context.

- since changes only happen under the RTNL, no additional locking is
  necessary for data not used during packet processing (f.e. u32_list).
  Again, since destruction now happens in the RCU callback, this assumption
  is not valid anymore, causing races while using this data, which can
  result in corruption or use-after-free.

Instead of "fixing" this by disabling bottem halfs everywhere and adding
new locks/refcounting, this patch makes these assumptions valid again by
moving destruction back to process context. Since only the dev->qdisc
pointer is protected by RCU, but ->enqueue and the qdisc tree are still
protected by dev->qdisc_lock, destruction of the tree can be performed
immediately and only the final free needs to happen in the rcu callback
to make sure dev_queue_xmit doesn't access already freed memory.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit fe5b95bfcde98ca2e32b4274c93889cdd1fbc040
tree 951a0d83d91b15dbe55a41366e0fe01966fec7ed
parent 9a0cd6d60280d88c38791844c87548d45cf6f2c2
author Patrick McHardy <kaber@trash.net> Wed, 27 Sep 2006 13:57:18 +0200
committer Patrick McHardy <kaber@trash.net> Wed, 27 Sep 2006 13:57:18 +0200

 net/core/dev.c          |   14 ++++++----
 net/sched/cls_api.c     |    4 +--
 net/sched/sch_api.c     |   16 ++++++-----
 net/sched/sch_generic.c |   66 +++++++++++++++--------------------------------
 4 files changed, 39 insertions(+), 61 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 14de297..4d891be 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1480,14 +1480,16 @@ #endif
 	if (q->enqueue) {
 		/* Grab device queue */
 		spin_lock(&dev->queue_lock);
+		q = dev->qdisc;
+		if (q->enqueue) {
+			rc = q->enqueue(skb, q);
+			qdisc_run(dev);
+			spin_unlock(&dev->queue_lock);
 
-		rc = q->enqueue(skb, q);
-
-		qdisc_run(dev);
-
+			rc = rc == NET_XMIT_BYPASS ? NET_XMIT_SUCCESS : rc;
+			goto out;
+		}
 		spin_unlock(&dev->queue_lock);
-		rc = rc == NET_XMIT_BYPASS ? NET_XMIT_SUCCESS : rc;
-		goto out;
 	}
 
 	/* The device has no queue. Common case for software devices:
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 7e14f14..37a1840 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -401,7 +401,7 @@ static int tc_dump_tfilter(struct sk_buf
 	if ((dev = dev_get_by_index(tcm->tcm_ifindex)) == NULL)
 		return skb->len;
 
-	read_lock_bh(&qdisc_tree_lock);
+	read_lock(&qdisc_tree_lock);
 	if (!tcm->tcm_parent)
 		q = dev->qdisc_sleeping;
 	else
@@ -458,7 +458,7 @@ errout:
 	if (cl)
 		cops->put(q, cl);
 out:
-	read_unlock_bh(&qdisc_tree_lock);
+	read_unlock(&qdisc_tree_lock);
 	dev_put(dev);
 	return skb->len;
 }
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index a19eff1..0b64892 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -195,14 +195,14 @@ struct Qdisc *qdisc_lookup(struct net_de
 {
 	struct Qdisc *q;
 
-	read_lock_bh(&qdisc_tree_lock);
+	read_lock(&qdisc_tree_lock);
 	list_for_each_entry(q, &dev->qdisc_list, list) {
 		if (q->handle == handle) {
-			read_unlock_bh(&qdisc_tree_lock);
+			read_unlock(&qdisc_tree_lock);
 			return q;
 		}
 	}
-	read_unlock_bh(&qdisc_tree_lock);
+	read_unlock(&qdisc_tree_lock);
 	return NULL;
 }
 
@@ -837,7 +837,7 @@ static int tc_dump_qdisc(struct sk_buff 
 			continue;
 		if (idx > s_idx)
 			s_q_idx = 0;
-		read_lock_bh(&qdisc_tree_lock);
+		read_lock(&qdisc_tree_lock);
 		q_idx = 0;
 		list_for_each_entry(q, &dev->qdisc_list, list) {
 			if (q_idx < s_q_idx) {
@@ -846,12 +846,12 @@ static int tc_dump_qdisc(struct sk_buff 
 			}
 			if (tc_fill_qdisc(skb, q, q->parent, NETLINK_CB(cb->skb).pid,
 					  cb->nlh->nlmsg_seq, NLM_F_MULTI, RTM_NEWQDISC) <= 0) {
-				read_unlock_bh(&qdisc_tree_lock);
+				read_unlock(&qdisc_tree_lock);
 				goto done;
 			}
 			q_idx++;
 		}
-		read_unlock_bh(&qdisc_tree_lock);
+		read_unlock(&qdisc_tree_lock);
 	}
 
 done:
@@ -1074,7 +1074,7 @@ static int tc_dump_tclass(struct sk_buff
 	s_t = cb->args[0];
 	t = 0;
 
-	read_lock_bh(&qdisc_tree_lock);
+	read_lock(&qdisc_tree_lock);
 	list_for_each_entry(q, &dev->qdisc_list, list) {
 		if (t < s_t || !q->ops->cl_ops ||
 		    (tcm->tcm_parent &&
@@ -1096,7 +1096,7 @@ static int tc_dump_tclass(struct sk_buff
 			break;
 		t++;
 	}
-	read_unlock_bh(&qdisc_tree_lock);
+	read_unlock(&qdisc_tree_lock);
 
 	cb->args[0] = t;
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 6f91518..88c6a99 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -45,11 +45,10 @@ #include <net/pkt_sched.h>
    The idea is the following:
    - enqueue, dequeue are serialized via top level device
      spinlock dev->queue_lock.
-   - tree walking is protected by read_lock_bh(qdisc_tree_lock)
+   - tree walking is protected by read_lock(qdisc_tree_lock)
      and this lock is used only in process context.
-   - updates to tree are made under rtnl semaphore or
-     from softirq context (__qdisc_destroy rcu-callback)
-     hence this lock needs local bh disabling.
+   - updates to tree are made only under rtnl semaphore,
+     hence this lock may be made without local bh disabling.
 
    qdisc_tree_lock must be grabbed BEFORE dev->queue_lock!
  */
@@ -57,14 +56,14 @@ DEFINE_RWLOCK(qdisc_tree_lock);
 
 void qdisc_lock_tree(struct net_device *dev)
 {
-	write_lock_bh(&qdisc_tree_lock);
+	write_lock(&qdisc_tree_lock);
 	spin_lock_bh(&dev->queue_lock);
 }
 
 void qdisc_unlock_tree(struct net_device *dev)
 {
 	spin_unlock_bh(&dev->queue_lock);
-	write_unlock_bh(&qdisc_tree_lock);
+	write_unlock(&qdisc_tree_lock);
 }
 
 /* 
@@ -483,20 +482,6 @@ void qdisc_reset(struct Qdisc *qdisc)
 static void __qdisc_destroy(struct rcu_head *head)
 {
 	struct Qdisc *qdisc = container_of(head, struct Qdisc, q_rcu);
-	struct Qdisc_ops  *ops = qdisc->ops;
-
-#ifdef CONFIG_NET_ESTIMATOR
-	gen_kill_estimator(&qdisc->bstats, &qdisc->rate_est);
-#endif
-	write_lock(&qdisc_tree_lock);
-	if (ops->reset)
-		ops->reset(qdisc);
-	if (ops->destroy)
-		ops->destroy(qdisc);
-	write_unlock(&qdisc_tree_lock);
-	module_put(ops->owner);
-
-	dev_put(qdisc->dev);
 	kfree((char *) qdisc - qdisc->padded);
 }
 
@@ -504,32 +489,23 @@ #endif
 
 void qdisc_destroy(struct Qdisc *qdisc)
 {
-	struct list_head cql = LIST_HEAD_INIT(cql);
-	struct Qdisc *cq, *q, *n;
+	struct Qdisc_ops  *ops = qdisc->ops;
 
 	if (qdisc->flags & TCQ_F_BUILTIN ||
-		!atomic_dec_and_test(&qdisc->refcnt))
+	    !atomic_dec_and_test(&qdisc->refcnt))
 		return;
 
-	if (!list_empty(&qdisc->list)) {
-		if (qdisc->ops->cl_ops == NULL)
-			list_del(&qdisc->list);
-		else
-			list_move(&qdisc->list, &cql);
-	}
-
-	/* unlink inner qdiscs from dev->qdisc_list immediately */
-	list_for_each_entry(cq, &cql, list)
-		list_for_each_entry_safe(q, n, &qdisc->dev->qdisc_list, list)
-			if (TC_H_MAJ(q->parent) == TC_H_MAJ(cq->handle)) {
-				if (q->ops->cl_ops == NULL)
-					list_del_init(&q->list);
-				else
-					list_move_tail(&q->list, &cql);
-			}
-	list_for_each_entry_safe(cq, n, &cql, list)
-		list_del_init(&cq->list);
+	list_del(&qdisc->list);
+#ifdef CONFIG_NET_ESTIMATOR
+	gen_kill_estimator(&qdisc->bstats, &qdisc->rate_est);
+#endif
+	if (ops->reset)
+		ops->reset(qdisc);
+	if (ops->destroy)
+		ops->destroy(qdisc);
 
+	module_put(ops->owner);
+	dev_put(qdisc->dev);
 	call_rcu(&qdisc->q_rcu, __qdisc_destroy);
 }
 
@@ -549,15 +525,15 @@ void dev_activate(struct net_device *dev
 				printk(KERN_INFO "%s: activation failed\n", dev->name);
 				return;
 			}
-			write_lock_bh(&qdisc_tree_lock);
+			write_lock(&qdisc_tree_lock);
 			list_add_tail(&qdisc->list, &dev->qdisc_list);
-			write_unlock_bh(&qdisc_tree_lock);
+			write_unlock(&qdisc_tree_lock);
 		} else {
 			qdisc =  &noqueue_qdisc;
 		}
-		write_lock_bh(&qdisc_tree_lock);
+		write_lock(&qdisc_tree_lock);
 		dev->qdisc_sleeping = qdisc;
-		write_unlock_bh(&qdisc_tree_lock);
+		write_unlock(&qdisc_tree_lock);
 	}
 
 	if (!netif_carrier_ok(dev))


--------------030205060600030901000206--
