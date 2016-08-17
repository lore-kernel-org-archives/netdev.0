From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 01/13] net: sched: allow qdiscs to handle locking
Date: Wed, 17 Aug 2016 12:33:38 -0700
Message-ID: <20160817193338.27032.71493.stgit@john-Precision-Tower-5810>
References: <20160817193120.27032.20918.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	john.fastabend@gmail.com, davem@davemloft.net
To: xiyou.wangcong@gmail.com, jhs@mojatatu.com,
	alexei.starovoitov@gmail.com, eric.dumazet@gmail.com,
	brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:36220 "EHLO
	mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752907AbcHQTep (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 15:34:45 -0400
Received: by mail-oi0-f66.google.com with SMTP id b22so12980141oii.3
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 12:34:11 -0700 (PDT)
In-Reply-To: <20160817193120.27032.20918.stgit@john-Precision-Tower-5810>
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

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/net/pkt_sched.h   |    4 +++-
 include/net/sch_generic.h |    1 +
 net/core/dev.c            |   32 ++++++++++++++++++++++++++++----
 net/sched/sch_generic.c   |   26 ++++++++++++++++----------
 4 files changed, 48 insertions(+), 15 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index 7caa99b..69540c6 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -107,8 +107,10 @@ void __qdisc_run(struct Qdisc *q);
 
 static inline void qdisc_run(struct Qdisc *q)
 {
-	if (qdisc_run_begin(q))
+	if (qdisc_run_begin(q)) {
 		__qdisc_run(q);
+		qdisc_run_end(q);
+	}
 }
 
 int tc_classify(struct sk_buff *skb, const struct tcf_proto *tp,
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 909aff2..3de6a8c 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -58,6 +58,7 @@ struct Qdisc {
 #define TCQ_F_NOPARENT		0x40 /* root of its hierarchy :
 				      * qdisc_tree_decrease_qlen() should stop.
 				      */
+#define TCQ_F_NOLOCK		0x80 /* qdisc does not require locking */
 	u32			limit;
 	const struct Qdisc_ops	*ops;
 	struct qdisc_size_table	__rcu *stab;
diff --git a/net/core/dev.c b/net/core/dev.c
index 4ce07dc..5db395d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3076,6 +3076,26 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 	int rc;
 
 	qdisc_calculate_pkt_len(skb, q);
+
+	if (q->flags & TCQ_F_NOLOCK) {
+		if (unlikely(test_bit(__QDISC_STATE_DEACTIVATED, &q->state))) {
+			__qdisc_drop(skb, &to_free);
+			rc = NET_XMIT_DROP;
+		} else if ((q->flags & TCQ_F_CAN_BYPASS) && !qdisc_qlen(q)) {
+			qdisc_bstats_cpu_update(q, skb);
+			if (sch_direct_xmit(skb, q, dev, txq, root_lock, true))
+				__qdisc_run(q);
+			rc = NET_XMIT_SUCCESS;
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
@@ -3118,6 +3138,7 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 				contended = false;
 			}
 			__qdisc_run(q);
+			qdisc_run_end(q);
 		}
 	}
 	spin_unlock(root_lock);
@@ -3897,19 +3918,22 @@ static void net_tx_action(struct softirq_action *h)
 
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
+			if (!(q->flags & TCQ_F_NOLOCK))
+				spin_unlock(root_lock);
 		}
 	}
 }
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index e95b67c..af32418 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -170,7 +170,8 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
 	int ret = NETDEV_TX_BUSY;
 
 	/* And release qdisc */
-	spin_unlock(root_lock);
+	if (!(q->flags & TCQ_F_NOLOCK))
+		spin_unlock(root_lock);
 
 	/* Note that we validate skb (GSO, checksum, ...) outside of locks */
 	if (validate)
@@ -183,10 +184,13 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
 
 		HARD_TX_UNLOCK(dev, txq);
 	} else {
-		spin_lock(root_lock);
+		if (!(q->flags & TCQ_F_NOLOCK))
+			spin_lock(root_lock);
 		return qdisc_qlen(q);
 	}
-	spin_lock(root_lock);
+
+	if (!(q->flags & TCQ_F_NOLOCK))
+		spin_lock(root_lock);
 
 	if (dev_xmit_complete(ret)) {
 		/* Driver sent out skb successfully or skb was consumed */
@@ -262,8 +266,6 @@ void __qdisc_run(struct Qdisc *q)
 			break;
 		}
 	}
-
-	qdisc_run_end(q);
 }
 
 unsigned long dev_trans_start(struct net_device *dev)
@@ -868,14 +870,18 @@ static bool some_qdisc_is_busy(struct net_device *dev)
 
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
