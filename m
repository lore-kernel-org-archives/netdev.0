From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH take 2] pkt_sched: Fix qdisc list locking
Date: Fri, 22 Aug 2008 09:27:30 +0000
Message-ID: <20080822092729.GA14729@ff.dom.local>
References: <20080821124834.GA8794@gondor.apana.org.au> <20080821204052.GB2665@ami.dom.local> <20080821222446.GF14521@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	denys@visp.net.lb
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:56371 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752577AbYHVJ1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 05:27:38 -0400
Received: by nf-out-0910.google.com with SMTP id d3so172955nfc.21
        for <netdev@vger.kernel.org>; Fri, 22 Aug 2008 02:27:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080821222446.GF14521@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I made an error in the name of this new lock in the changlog,
so I decided to fix this in ...the patch.

Sorry,
Jarek P.

---------------> (take 2)

pkt_sched: Fix qdisc list locking

Since some qdiscs call qdisc_tree_decrease_qlen() (so qdisc_lookup())
without rtnl_lock(), adding and deleting from a qdisc list needs
additional locking. This patch adds global spinlock qdisc_list_lock
and wrapper functions for modifying the list. It is considered as a
temporary solution until hfsc_dequeue(), netem_dequeue() and
tbf_dequeue() (or qdisc_tree_decrease_qlen()) are redone.

With feedback from Herbert Xu and David S. Miller.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

 include/net/pkt_sched.h |    1 +
 net/sched/sch_api.c     |   44 +++++++++++++++++++++++++++++++++++++++-----
 net/sched/sch_generic.c |    5 ++---
 3 files changed, 42 insertions(+), 8 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index 853fe83..b786a5b 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -78,6 +78,7 @@ extern struct Qdisc *fifo_create_dflt(struct Qdisc *sch, struct Qdisc_ops *ops,
 
 extern int register_qdisc(struct Qdisc_ops *qops);
 extern int unregister_qdisc(struct Qdisc_ops *qops);
+extern void qdisc_list_del(struct Qdisc *q);
 extern struct Qdisc *qdisc_lookup(struct net_device *dev, u32 handle);
 extern struct Qdisc *qdisc_lookup_class(struct net_device *dev, u32 handle);
 extern struct qdisc_rate_table *qdisc_get_rtab(struct tc_ratespec *r,
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 45f442d..e7fb9e0 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -199,19 +199,53 @@ struct Qdisc *qdisc_match_from_root(struct Qdisc *root, u32 handle)
 	return NULL;
 }
 
+/*
+ * This lock is needed until some qdiscs stop calling qdisc_tree_decrease_qlen()
+ * without rtnl_lock(); currently hfsc_dequeue(), netem_dequeue(), tbf_dequeue()
+ */
+static DEFINE_SPINLOCK(qdisc_list_lock);
+
+static void qdisc_list_add(struct Qdisc *q)
+{
+	if ((q->parent != TC_H_ROOT) && !(q->flags & TCQ_F_INGRESS)) {
+		spin_lock_bh(&qdisc_list_lock);
+		list_add_tail(&q->list, &qdisc_root_sleeping(q)->list);
+		spin_unlock_bh(&qdisc_list_lock);
+	}
+}
+
+void qdisc_list_del(struct Qdisc *q)
+{
+	if ((q->parent != TC_H_ROOT) && !(q->flags & TCQ_F_INGRESS)) {
+		spin_lock_bh(&qdisc_list_lock);
+		list_del(&q->list);
+		spin_unlock_bh(&qdisc_list_lock);
+	}
+}
+EXPORT_SYMBOL(qdisc_list_del);
+
 struct Qdisc *qdisc_lookup(struct net_device *dev, u32 handle)
 {
 	unsigned int i;
+	struct Qdisc *q;
+
+	spin_lock_bh(&qdisc_list_lock);
 
 	for (i = 0; i < dev->num_tx_queues; i++) {
 		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
-		struct Qdisc *q, *txq_root = txq->qdisc_sleeping;
+		struct Qdisc *txq_root = txq->qdisc_sleeping;
 
 		q = qdisc_match_from_root(txq_root, handle);
 		if (q)
-			return q;
+			goto unlock;
 	}
-	return qdisc_match_from_root(dev->rx_queue.qdisc_sleeping, handle);
+
+	q = qdisc_match_from_root(dev->rx_queue.qdisc_sleeping, handle);
+
+unlock:
+	spin_unlock_bh(&qdisc_list_lock);
+
+	return q;
 }
 
 static struct Qdisc *qdisc_leaf(struct Qdisc *p, u32 classid)
@@ -810,8 +844,8 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 				goto err_out3;
 			}
 		}
-		if ((parent != TC_H_ROOT) && !(sch->flags & TCQ_F_INGRESS))
-			list_add_tail(&sch->list, &dev_queue->qdisc_sleeping->list);
+
+		qdisc_list_add(sch);
 
 		return sch;
 	}
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index c3ed4d4..5f0ade7 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -526,10 +526,9 @@ void qdisc_destroy(struct Qdisc *qdisc)
 	    !atomic_dec_and_test(&qdisc->refcnt))
 		return;
 
-	if (qdisc->parent)
-		list_del(&qdisc->list);
-
 #ifdef CONFIG_NET_SCHED
+	qdisc_list_del(qdisc);
+
 	qdisc_put_stab(qdisc->stab);
 #endif
 	gen_kill_estimator(&qdisc->bstats, &qdisc->rate_est);
