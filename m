From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 03/12] net: sched: allow qdiscs to handle locking
Date: Wed, 30 Dec 2015 09:51:59 -0800
Message-ID: <20151230175159.26257.51130.stgit@john-Precision-Tower-5810>
References: <20151230175000.26257.41532.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	john.fastabend@gmail.com
To: daniel@iogearbox.net, eric.dumazet@gmail.com, jhs@mojatatu.com,
	aduyck@mirantis.com, brouer@redhat.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33620 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754423AbbL3RwW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 12:52:22 -0500
Received: by mail-pa0-f54.google.com with SMTP id cy9so141170409pac.0
        for <netdev@vger.kernel.org>; Wed, 30 Dec 2015 09:52:21 -0800 (PST)
In-Reply-To: <20151230175000.26257.41532.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a flag for queueing disciplines to indicate
the stack does not need to use the qdisc lock to protect
operations. This can be used to build lockless scheduling
algorithms and improving performance.

The flag is checked in the tx path and the qdisc lock is
only taken if it is not set. For now use a conditional
if statement. Later we could be more aggressive if it
proves worthwhile and use a static key or wrap this in
a likely().

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/net/sch_generic.h |    1 +
 net/core/dev.c            |   20 ++++++++++++--------
 net/sched/sch_generic.c   |    7 +++++--
 3 files changed, 18 insertions(+), 10 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index b2a8e63..c8d42c3 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -64,6 +64,7 @@ struct Qdisc {
 #define TCQ_F_NOPARENT		0x40 /* root of its hierarchy :
 				      * qdisc_tree_decrease_qlen() should stop.
 				      */
+#define TCQ_F_NOLOCK		0x80 /* qdisc does not require locking */
 	u32			limit;
 	const struct Qdisc_ops	*ops;
 	struct qdisc_size_table	__rcu *stab;
diff --git a/net/core/dev.c b/net/core/dev.c
index 914b4a2..7a51609 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3004,7 +3004,7 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 				 struct netdev_queue *txq)
 {
 	spinlock_t *root_lock = qdisc_lock(q);
-	bool contended;
+	bool contended = false;
 	int rc;
 
 	qdisc_pkt_len_init(skb);
@@ -3015,11 +3015,13 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 	 * This permits __QDISC___STATE_RUNNING owner to get the lock more
 	 * often and dequeue packets faster.
 	 */
-	contended = qdisc_is_running(q);
-	if (unlikely(contended))
-		spin_lock(&q->busylock);
+	if (!(q->flags & TCQ_F_NOLOCK)) {
+		contended = qdisc_is_running(q);
+		if (unlikely(contended))
+			spin_lock(&q->busylock);
+		spin_lock(root_lock);
+	}
 
-	spin_lock(root_lock);
 	if (unlikely(test_bit(__QDISC_STATE_DEACTIVATED, &q->state))) {
 		kfree_skb(skb);
 		rc = NET_XMIT_DROP;
@@ -3053,9 +3055,11 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 			__qdisc_run(q);
 		}
 	}
-	spin_unlock(root_lock);
-	if (unlikely(contended))
-		spin_unlock(&q->busylock);
+	if (!(q->flags & TCQ_F_NOLOCK)) {
+		spin_unlock(root_lock);
+		if (unlikely(contended))
+			spin_unlock(&q->busylock);
+	}
 	return rc;
 }
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 16bc83b..37dfa4a 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -153,7 +153,8 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
 	int ret = NETDEV_TX_BUSY;
 
 	/* And release qdisc */
-	spin_unlock(root_lock);
+	if (!(q->flags & TCQ_F_NOLOCK))
+		spin_unlock(root_lock);
 
 	/* Note that we validate skb (GSO, checksum, ...) outside of locks */
 	if (validate)
@@ -166,7 +167,9 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
 
 		HARD_TX_UNLOCK(dev, txq);
 	}
-	spin_lock(root_lock);
+
+	if (!(q->flags & TCQ_F_NOLOCK))
+		spin_lock(root_lock);
 
 	if (dev_xmit_complete(ret)) {
 		/* Driver sent out skb successfully or skb was consumed */
