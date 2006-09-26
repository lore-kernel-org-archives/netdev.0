From: Patrick McHardy <kaber@trash.net>
Subject: Re: tc related lockdep warning.
Date: Tue, 26 Sep 2006 18:15:21 +0200
Message-ID: <45195219.7050105@trash.net>
References: <20060925124352.GA1592@ff.dom.local> <1159188473.5301.68.camel@jzny2> <4517D9A6.70307@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030404030104030008040208"
Cc: hadi@cyberus.ca, Jarek Poplawski <jarkao2@o2.pl>,
	netdev@vger.kernel.org, Dave Jones <davej@redhat.com>,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:3573 "EHLO stinky.trash.net")
	by vger.kernel.org with ESMTP id S932328AbWIZQSq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2006 12:18:46 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4517D9A6.70307@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030404030104030008040208
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> jamal wrote:
> 
>>Yes, that looks plausible. Can you try making those changes and see if
>>the warning is gone?
> 
>
> I think this points to a bigger brokeness caused by the move of
> dev->qdisc to RCU. It means destruction of filters and actions doesn't
> necessarily happens in user-context and thus not protected by the rtnl
> anymore.

I looked into this and we indeed still have lots of problems from that
broken RCU patch. Basically all locking (qdiscs, classifiers, actions,
estimators) assumes that updates are only done in process context and
thus read_lock doesn't need bottem half protection. Quite a few things
also assume that updates only happen under the RTNL and don't need
any further protection if not used during packet processing.

Instead of "fixing" all this I suggest something like this (untested)
patch instead. Since only the dev->qdisc pointer is protected by RCU,
but enqueue and the qdisc tree are still protected by dev->qdisc_lock,
we can perform destruction of the tree immediately and only do the
final free in the rcu callback, as long as we make sure not to enqueue
anything to a half-way destroyed qdisc.


--------------030404030104030008040208
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index b0e9108..278d5e6 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -31,6 +31,7 @@ struct Qdisc
 #define TCQ_F_BUILTIN	1
 #define TCQ_F_THROTTLED	2
 #define TCQ_F_INGRESS	4
+#define TCQ_F_DYING	8
 	int			padded;
 	struct Qdisc_ops	*ops;
 	u32			handle;
diff --git a/net/core/dev.c b/net/core/dev.c
index 14de297..c9c65c2 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1480,14 +1480,15 @@ #endif
 	if (q->enqueue) {
 		/* Grab device queue */
 		spin_lock(&dev->queue_lock);
+		if (likely(!(q->flags & TCQ_F_DYING))) {
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
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 6f91518..93d52e0 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -47,9 +47,8 @@ #include <net/pkt_sched.h>
      spinlock dev->queue_lock.
    - tree walking is protected by read_lock_bh(qdisc_tree_lock)
      and this lock is used only in process context.
-   - updates to tree are made under rtnl semaphore or
-     from softirq context (__qdisc_destroy rcu-callback)
-     hence this lock needs local bh disabling.
+   - updates to tree are made only under rtnl semaphore,
+     hence this lock may be made without local bh disabling.
 
    qdisc_tree_lock must be grabbed BEFORE dev->queue_lock!
  */
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
 
@@ -504,32 +489,24 @@ #endif
 
 void qdisc_destroy(struct Qdisc *qdisc)
 {
-	struct list_head cql = LIST_HEAD_INIT(cql);
-	struct Qdisc *cq, *q, *n;
+	struct Qdisc_ops  *ops = qdisc->ops;
 
 	if (qdisc->flags & TCQ_F_BUILTIN ||
-		!atomic_dec_and_test(&qdisc->refcnt))
+	    !atomic_dec_and_test(&qdisc->refcnt))
 		return;
+	qdisc->flags |= TCQ_F_DYING;
 
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
 

--------------030404030104030008040208--
