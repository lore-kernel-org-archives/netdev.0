From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 03/15] net: sched: remove remaining uses for
 qdisc_qlen in xmit path
Date: Tue, 23 Aug 2016 13:23:47 -0700
Message-ID: <20160823202347.14368.78284.stgit@john-Precision-Tower-5810>
References: <20160823202135.14368.62466.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        john.fastabend@gmail.com
To: eric.dumazet@gmail.com, jhs@mojatatu.com, davem@davemloft.net,
        brouer@redhat.com, xiyou.wangcong@gmail.com,
        alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:32963 "EHLO
        mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751861AbcHWUYH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 16:24:07 -0400
Received: by mail-pa0-f66.google.com with SMTP id vy10so10419608pac.0
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 13:24:07 -0700 (PDT)
In-Reply-To: <20160823202135.14368.62466.stgit@john-Precision-Tower-5810>
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

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/net/pkt_sched.h |    6 +++---
 net/sched/sch_generic.c |   23 ++++++++++++-----------
 2 files changed, 15 insertions(+), 14 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index 69540c6..6520e42 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -99,9 +99,9 @@ struct qdisc_rate_table *qdisc_get_rtab(struct tc_ratespec *r,
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
index af32418..80544c2 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -160,12 +160,12 @@ bulk:
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
 		if (!(q->flags & TCQ_F_NOLOCK))
 			spin_lock(root_lock);
-		return qdisc_qlen(q);
+		return true;
 	}
 
 	if (!(q->flags & TCQ_F_NOLOCK))
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
 	struct netdev_queue *txq;
 	struct net_device *dev;
@@ -240,7 +241,7 @@ static inline int qdisc_restart(struct Qdisc *q, int *packets)
 	/* Dequeue packet */
 	skb = dequeue_skb(q, &validate, packets);
 	if (unlikely(!skb))
-		return 0;
+		return false;
 
 	root_lock = qdisc_lock(q);
 	dev = qdisc_dev(q);
