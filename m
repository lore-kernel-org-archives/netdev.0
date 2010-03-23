From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [RFC PATCH] net: add additional lock to qdisc to increase
	enqueue/dequeue fairness
Date: Tue, 23 Mar 2010 13:25:53 -0700
Message-ID: <20100323202553.21598.10754.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:62481 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751988Ab0CWUZ6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Mar 2010 16:25:58 -0400
Received: from gitlad.jf.intel.com (gitlad.jf.intel.com [127.0.0.1])
	by gitlad.jf.intel.com (8.14.2/8.14.2) with ESMTP id o2NKPrG9021627
	for <netdev@vger.kernel.org>; Tue, 23 Mar 2010 13:25:54 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The qdisc layer shows a significant issue when you start transmitting from
multiple CPUs.  The issue is that the transmit rate drops significantly, and I
believe it is due to the fact that the spinlock is shared between the 1
dequeue, and n-1 enqueue cpu threads.  In order to improve this situation I am
adding one additional lock which will need to be obtained during the enqueue
portion of the path.  This essentially allows sch_direct_xmit to jump to
near the head of the line when attempting to obtain the lock after
completing a transmit.

Running the script below I saw an increase from 200K packets per second to
1.07M packets per second as a result of this patch.

for j in `seq 0 15`; do
	for i in `seq 0 7`; do
		netperf -H <ip> -t UDP_STREAM -l 600 -N -T $i -- -m 6 &
	done
done

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 include/net/sch_generic.h |    3 ++-
 net/core/dev.c            |    7 ++++++-
 net/sched/sch_generic.c   |    1 +
 3 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 67dc08e..f5088a9 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -51,7 +51,6 @@ struct Qdisc {
 	struct list_head	list;
 	u32			handle;
 	u32			parent;
-	atomic_t		refcnt;
 	struct gnet_stats_rate_est	rate_est;
 	int			(*reshape_fail)(struct sk_buff *skb,
 					struct Qdisc *q);
@@ -65,6 +64,8 @@ struct Qdisc {
 	struct netdev_queue	*dev_queue;
 	struct Qdisc		*next_sched;
 
+	atomic_t		refcnt;
+	spinlock_t		enqueue_lock;
 	struct sk_buff		*gso_skb;
 	/*
 	 * For performance sake on SMP, we put highly modified fields at the end
diff --git a/net/core/dev.c b/net/core/dev.c
index a03aab4..8a2d508 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2006,8 +2006,10 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 	spinlock_t *root_lock = qdisc_lock(q);
 	int rc;
 
+	spin_lock(&q->enqueue_lock);
 	spin_lock(root_lock);
 	if (unlikely(test_bit(__QDISC_STATE_DEACTIVATED, &q->state))) {
+		spin_unlock(&q->enqueue_lock);
 		kfree_skb(skb);
 		rc = NET_XMIT_DROP;
 	} else if ((q->flags & TCQ_F_CAN_BYPASS) && !qdisc_qlen(q) &&
@@ -2018,7 +2020,9 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 		 * xmit the skb directly.
 		 */
 		__qdisc_update_bstats(q, skb->len);
-		if (sch_direct_xmit(skb, q, dev, txq, root_lock))
+		spin_unlock(&q->enqueue_lock);
+		rc = sch_direct_xmit(skb, q, dev, txq, root_lock);
+		if (rc)
 			__qdisc_run(q);
 		else
 			clear_bit(__QDISC_STATE_RUNNING, &q->state);
@@ -2026,6 +2030,7 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 		rc = NET_XMIT_SUCCESS;
 	} else {
 		rc = qdisc_enqueue_root(skb, q);
+		spin_unlock(&q->enqueue_lock);
 		qdisc_run(q);
 	}
 	spin_unlock(root_lock);
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 5173c1e..4b5e125 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -538,6 +538,7 @@ struct Qdisc *qdisc_alloc(struct netdev_queue *dev_queue,
 	sch = (struct Qdisc *) QDISC_ALIGN((unsigned long) p);
 	sch->padded = (char *) sch - (char *) p;
 
+	spin_lock_init(&sch->enqueue_lock);
 	INIT_LIST_HEAD(&sch->list);
 	skb_queue_head_init(&sch->q);
 	sch->ops = ops;

