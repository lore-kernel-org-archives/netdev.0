From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH v2 02/17] net: sched: allow qdiscs to handle locking
Date: Tue, 02 May 2017 08:36:42 -0700
Message-ID: <20170502153642.9304.23483.stgit@john-Precision-Tower-5810>
References: <20170502153518.9304.17904.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34968 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751161AbdEBPhB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 11:37:01 -0400
Received: by mail-pg0-f66.google.com with SMTP id i63so3547104pgd.2
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 08:37:00 -0700 (PDT)
In-Reply-To: <20170502153518.9304.17904.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a flag for queueing disciplines to indicate the stack
does not need to use the qdisc lock to protect operations. This can
be used to build lockless scheduling algorithms and improving
performance.

The flag is checked in the tx path and the qdisc lock is only taken
if it is not set. For now use a conditional if statement. Later we
could be more aggressive if it proves worthwhile and use a static key
or wrap this in a likely().

Also the lockless case drops the TCQ_F_CAN_BYPASS logic. The reason
for this is synchronizing a qlen counter across threads proves to
cost more than doing the enqueue/dequeue operations when tested with
pktgen.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/net/sch_generic.h |    1 +
 net/core/dev.c            |   26 ++++++++++++++++++++++----
 net/sched/sch_generic.c   |   30 ++++++++++++++++++++----------
 3 files changed, 43 insertions(+), 14 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 22e5209..f5c8613 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -67,6 +67,7 @@ struct Qdisc {
 				      * qdisc_tree_decrease_qlen() should stop.
 				      */
 #define TCQ_F_INVISIBLE		0x80 /* invisible by default in dump */
+#define TCQ_F_NOLOCK		0x100 /* qdisc does not require locking */
 	u32			limit;
 	const struct Qdisc_ops	*ops;
 	struct qdisc_size_table	__rcu *stab;
diff --git a/net/core/dev.c b/net/core/dev.c
index 3169074..6d2db37 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3069,6 +3069,21 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 	int rc;
 
 	qdisc_calculate_pkt_len(skb, q);
+
+	if (q->flags & TCQ_F_NOLOCK) {
+		if (unlikely(test_bit(__QDISC_STATE_DEACTIVATED, &q->state))) {
+			__qdisc_drop(skb, &to_free);
+			rc = NET_XMIT_DROP;
+		} else {
+			rc = q->enqueue(skb, q, &to_free) & NET_XMIT_MASK;
+			__qdisc_run(q);
+		}
+
+		if (unlikely(to_free))
+			kfree_skb_list(to_free);
+		return rc;
+	}
+
 	/*
 	 * Heuristic to force contended enqueues to serialize on a
 	 * separate lock before trying to get qdisc main lock.
@@ -3896,19 +3911,22 @@ static __latent_entropy void net_tx_action(struct softirq_action *h)
 
 		while (head) {
 			struct Qdisc *q = head;
-			spinlock_t *root_lock;
+			spinlock_t *root_lock = NULL;
 
 			head = head->next_sched;
 
-			root_lock = qdisc_lock(q);
-			spin_lock(root_lock);
+			if (!(q->flags & TCQ_F_NOLOCK)) {
+				root_lock = qdisc_lock(q);
+				spin_lock(root_lock);
+			}
 			/* We need to make sure head->next_sched is read
 			 * before clearing __QDISC_STATE_SCHED
 			 */
 			smp_mb__before_atomic();
 			clear_bit(__QDISC_STATE_SCHED, &q->state);
 			qdisc_run(q);
-			spin_unlock(root_lock);
+			if (root_lock)
+				spin_unlock(root_lock);
 		}
 	}
 }
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index ef33bf8..39653e8 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -170,7 +170,8 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
 	int ret = NETDEV_TX_BUSY;
 
 	/* And release qdisc */
-	spin_unlock(root_lock);
+	if (root_lock)
+		spin_unlock(root_lock);
 
 	/* Note that we validate skb (GSO, checksum, ...) outside of locks */
 	if (validate)
@@ -183,10 +184,13 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
 
 		HARD_TX_UNLOCK(dev, txq);
 	} else {
-		spin_lock(root_lock);
+		if (root_lock)
+			spin_lock(root_lock);
 		return qdisc_qlen(q);
 	}
-	spin_lock(root_lock);
+
+	if (root_lock)
+		spin_lock(root_lock);
 
 	if (dev_xmit_complete(ret)) {
 		/* Driver sent out skb successfully or skb was consumed */
@@ -227,9 +231,9 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
  */
 static inline int qdisc_restart(struct Qdisc *q, int *packets)
 {
+	spinlock_t *root_lock = NULL;
 	struct netdev_queue *txq;
 	struct net_device *dev;
-	spinlock_t *root_lock;
 	struct sk_buff *skb;
 	bool validate;
 
@@ -238,7 +242,9 @@ static inline int qdisc_restart(struct Qdisc *q, int *packets)
 	if (unlikely(!skb))
 		return 0;
 
-	root_lock = qdisc_lock(q);
+	if (!(q->flags & TCQ_F_NOLOCK))
+		root_lock = qdisc_lock(q);
+
 	dev = qdisc_dev(q);
 	txq = skb_get_tx_queue(dev, skb);
 
@@ -875,14 +881,18 @@ static bool some_qdisc_is_busy(struct net_device *dev)
 
 		dev_queue = netdev_get_tx_queue(dev, i);
 		q = dev_queue->qdisc_sleeping;
-		root_lock = qdisc_lock(q);
 
-		spin_lock_bh(root_lock);
+		if (q->flags & TCQ_F_NOLOCK) {
+			val = test_bit(__QDISC_STATE_SCHED, &q->state);
+		} else {
+			root_lock = qdisc_lock(q);
+			spin_lock_bh(root_lock);
 
-		val = (qdisc_is_running(q) ||
-		       test_bit(__QDISC_STATE_SCHED, &q->state));
+			val = (qdisc_is_running(q) ||
+			       test_bit(__QDISC_STATE_SCHED, &q->state));
 
-		spin_unlock_bh(root_lock);
+			spin_unlock_bh(root_lock);
+		}
 
 		if (val)
 			return true;
