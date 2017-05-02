From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH v2 03/17] net: sched: remove remaining uses for
 qdisc_qlen in xmit path
Date: Tue, 02 May 2017 08:37:01 -0700
Message-ID: <20170502153701.9304.30831.stgit@john-Precision-Tower-5810>
References: <20170502153518.9304.17904.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34790 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750896AbdEBPhV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 11:37:21 -0400
Received: by mail-pf0-f195.google.com with SMTP id g23so33814497pfj.1
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 08:37:21 -0700 (PDT)
In-Reply-To: <20170502153518.9304.17904.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sch_direct_xmit() uses qdisc_qlen as a return value but all call sites
of the routine only check if it is zero or not. Simplify the logic so
that we don't need to return an actual queue length value.

This introduces a case now where sch_direct_xmit would have returned
a qlen of zero but now it returns true. However in this case all
call sites of sch_direct_xmit will implement a dequeue() and get
a null skb and abort. This trades tracking qlen in the hotpath for
an extra dequeue operation. Overall this seems to be good for
performance.

Acked-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/net/pkt_sched.h |    6 +++---
 net/sched/sch_generic.c |   23 ++++++++++++-----------
 2 files changed, 15 insertions(+), 14 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index b7f5776..69b90a3 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -101,9 +101,9 @@ struct qdisc_rate_table *qdisc_get_rtab(struct tc_ratespec *r,
 void qdisc_put_rtab(struct qdisc_rate_table *tab);
 void qdisc_put_stab(struct qdisc_size_table *tab);
 void qdisc_warn_nonwc(const char *txt, struct Qdisc *qdisc);
-int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
-		    struct net_device *dev, struct netdev_queue *txq,
-		    spinlock_t *root_lock, bool validate);
+bool sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
+		     struct net_device *dev, struct netdev_queue *txq,
+		     spinlock_t *root_lock, bool validate);
 
 void __qdisc_run(struct Qdisc *q);
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 39653e8..2f66b1f 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -160,12 +160,12 @@ static struct sk_buff *dequeue_skb(struct Qdisc *q, bool *validate,
  * only one CPU can execute this function.
  *
  * Returns to the caller:
- *				0  - queue is empty or throttled.
- *				>0 - queue is not empty.
+ *				false  - hardware queue frozen backoff
+ *				true   - feel free to send more pkts
  */
-int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
-		    struct net_device *dev, struct netdev_queue *txq,
-		    spinlock_t *root_lock, bool validate)
+bool sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
+		     struct net_device *dev, struct netdev_queue *txq,
+		     spinlock_t *root_lock, bool validate)
 {
 	int ret = NETDEV_TX_BUSY;
 
@@ -186,7 +186,7 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
 	} else {
 		if (root_lock)
 			spin_lock(root_lock);
-		return qdisc_qlen(q);
+		return true;
 	}
 
 	if (root_lock)
@@ -194,18 +194,19 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
 
 	if (dev_xmit_complete(ret)) {
 		/* Driver sent out skb successfully or skb was consumed */
-		ret = qdisc_qlen(q);
+		ret = true;
 	} else {
 		/* Driver returned NETDEV_TX_BUSY - requeue skb */
 		if (unlikely(ret != NETDEV_TX_BUSY))
 			net_warn_ratelimited("BUG %s code %d qlen %d\n",
 					     dev->name, ret, q->q.qlen);
 
-		ret = dev_requeue_skb(skb, q);
+		dev_requeue_skb(skb, q);
+		ret = false;
 	}
 
 	if (ret && netif_xmit_frozen_or_stopped(txq))
-		ret = 0;
+		ret = false;
 
 	return ret;
 }
@@ -229,7 +230,7 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
  *				>0 - queue is not empty.
  *
  */
-static inline int qdisc_restart(struct Qdisc *q, int *packets)
+static inline bool qdisc_restart(struct Qdisc *q, int *packets)
 {
 	spinlock_t *root_lock = NULL;
 	struct netdev_queue *txq;
@@ -240,7 +241,7 @@ static inline int qdisc_restart(struct Qdisc *q, int *packets)
 	/* Dequeue packet */
 	skb = dequeue_skb(q, &validate, packets);
 	if (unlikely(!skb))
-		return 0;
+		return false;
 
 	if (!(q->flags & TCQ_F_NOLOCK))
 		root_lock = qdisc_lock(q);
