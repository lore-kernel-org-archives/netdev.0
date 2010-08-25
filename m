From: Ben Greear <greearb@candelatech.com>
Subject: [net-next 1/2] qdisc:  Allow qdiscs to provide backpressure up the stack.
Date: Wed, 25 Aug 2010 12:00:50 -0700
Message-ID: <1282762851-3612-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:43803 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752580Ab0HYTAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 15:00:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some qdiscs, in some instances, can reliably detect when they
are about to drop a packet in the dev_queue_xmit path.  In
this case, it would be nice to provide backpressure up the
stack, and NOT free the skb in the qdisc logic.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 59962db... 20be932... M	include/linux/netdevice.h
:100644 100644 3c8728a... 146a97a... M	include/net/sch_generic.h
:100644 100644 859e30f... f360a9b... M	net/core/dev.c
:100644 100644 2aeb3a4... 0692717... M	net/sched/sch_generic.c
 include/linux/netdevice.h |    7 +++++++
 include/net/sch_generic.h |   19 +++++++++++++++++++
 net/core/dev.c            |   19 ++++++++++++++-----
 net/sched/sch_generic.c   |   20 ++++++++++++++++++++
 4 files changed, 60 insertions(+), 5 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 59962db..20be932 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -97,6 +97,7 @@ struct wireless_dev;
 #define NET_XMIT_DROP		0x01	/* skb dropped			*/
 #define NET_XMIT_CN		0x02	/* congestion notification	*/
 #define NET_XMIT_POLICED	0x03	/* skb is shot by police	*/
+#define NET_XMIT_BUSY	  	0x04	/* congestion, but skb was NOT freed */
 #define NET_XMIT_MASK		0x0f	/* qdisc flags in net/sch_generic.h */
 
 /* NET_XMIT_CN is special. It does not guarantee that this packet is lost. It
@@ -1296,6 +1297,12 @@ extern int		dev_open(struct net_device *dev);
 extern int		dev_close(struct net_device *dev);
 extern void		dev_disable_lro(struct net_device *dev);
 extern int		dev_queue_xmit(struct sk_buff *skb);
+
+/* Similar to dev_queue_xmit, but if try_no_consume != 0,
+ * it may return NET_XMIT_BUSY and NOT free the skb if it detects congestion
+ */
+extern int		try_dev_queue_xmit(struct sk_buff *skb, int try_no_consume);
+
 extern int		register_netdevice(struct net_device *dev);
 extern void		unregister_netdevice_queue(struct net_device *dev,
 						   struct list_head *head);
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 3c8728a..146a97a 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -43,6 +43,7 @@ struct qdisc_size_table {
 
 struct Qdisc {
 	int 			(*enqueue)(struct sk_buff *skb, struct Qdisc *dev);
+	int 			(*try_enqueue)(struct sk_buff *, struct Qdisc *dev); /* May return NET_XMIT_BUSY and NOT free skb. */
 	struct sk_buff *	(*dequeue)(struct Qdisc *dev);
 	unsigned		flags;
 #define TCQ_F_BUILTIN		1
@@ -135,6 +136,7 @@ struct Qdisc_ops {
 	int			priv_size;
 
 	int 			(*enqueue)(struct sk_buff *, struct Qdisc *);
+	int 			(*try_enqueue)(struct sk_buff *, struct Qdisc *); /* May return NET_XMIT_BUSY and NOT free skb. */
 	struct sk_buff *	(*dequeue)(struct Qdisc *);
 	struct sk_buff *	(*peek)(struct Qdisc *);
 	unsigned int		(*drop)(struct Qdisc *);
@@ -426,6 +428,23 @@ static inline int qdisc_enqueue_root(struct sk_buff *skb, struct Qdisc *sch)
 	return qdisc_enqueue(skb, sch) & NET_XMIT_MASK;
 }
 
+static inline int try_qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+{
+#ifdef CONFIG_NET_SCHED
+	if (sch->stab)
+		qdisc_calculate_pkt_len(skb, sch->stab);
+#endif
+	if (sch->try_enqueue)
+		return sch->try_enqueue(skb, sch);
+	return sch->enqueue(skb, sch);
+}
+
+static inline int try_qdisc_enqueue_root(struct sk_buff *skb, struct Qdisc *sch)
+{
+	qdisc_skb_cb(skb)->pkt_len = skb->len;
+	return try_qdisc_enqueue(skb, sch) & NET_XMIT_MASK;
+}
+
 static inline void __qdisc_update_bstats(struct Qdisc *sch, unsigned int len)
 {
 	sch->bstats.bytes += len;
diff --git a/net/core/dev.c b/net/core/dev.c
index 859e30f..f360a9b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2087,7 +2087,8 @@ static struct netdev_queue *dev_pick_tx(struct net_device *dev,
 
 static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 				 struct net_device *dev,
-				 struct netdev_queue *txq)
+				 struct netdev_queue *txq,
+				 bool try_no_consume)
 {
 	spinlock_t *root_lock = qdisc_lock(q);
 	bool contended = qdisc_is_running(q);
@@ -2128,7 +2129,10 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 		rc = NET_XMIT_SUCCESS;
 	} else {
 		skb_dst_force(skb);
-		rc = qdisc_enqueue_root(skb, q);
+		if (try_no_consume) 
+			rc = try_qdisc_enqueue_root(skb, q);
+		else
+			rc = qdisc_enqueue_root(skb, q);
 		if (qdisc_run_begin(q)) {
 			if (unlikely(contended)) {
 				spin_unlock(&q->busylock);
@@ -2168,7 +2172,12 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
  *      the BH enable code must have IRQs enabled so that it will not deadlock.
  *          --BLG
  */
-int dev_queue_xmit(struct sk_buff *skb)
+int dev_queue_xmit(struct sk_buff *skb) {
+	return try_dev_queue_xmit(skb, 0);
+}
+EXPORT_SYMBOL(dev_queue_xmit);
+
+int try_dev_queue_xmit(struct sk_buff *skb, int try_no_consume)
 {
 	struct net_device *dev = skb->dev;
 	struct netdev_queue *txq;
@@ -2187,7 +2196,7 @@ int dev_queue_xmit(struct sk_buff *skb)
 	skb->tc_verd = SET_TC_AT(skb->tc_verd, AT_EGRESS);
 #endif
 	if (q->enqueue) {
-		rc = __dev_xmit_skb(skb, q, dev, txq);
+		rc = __dev_xmit_skb(skb, q, dev, txq, try_no_consume);
 		goto out;
 	}
 
@@ -2239,7 +2248,7 @@ out:
 	rcu_read_unlock_bh();
 	return rc;
 }
-EXPORT_SYMBOL(dev_queue_xmit);
+EXPORT_SYMBOL(try_dev_queue_xmit);
 
 
 /*=======================================================================
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 2aeb3a4..0692717 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -460,6 +460,24 @@ static int pfifo_fast_enqueue(struct sk_buff *skb, struct Qdisc* qdisc)
 	return qdisc_drop(skb, qdisc);
 }
 
+static int pfifo_fast_try_enqueue(struct sk_buff *skb, struct Qdisc* qdisc)
+{
+	if (skb_queue_len(&qdisc->q) < qdisc_dev(qdisc)->tx_queue_len) {
+		int band = prio2band[skb->priority & TC_PRIO_MAX];
+		struct pfifo_fast_priv *priv = qdisc_priv(qdisc);
+		struct sk_buff_head *list = band2list(priv, band);
+
+		priv->bitmap |= (1 << band);
+		qdisc->q.qlen++;
+		return __qdisc_enqueue_tail(skb, qdisc, list);
+	}
+
+	/* no room to enqueue, tell calling code to back off.  Do NOT free skb, that is
+	 * calling code's to deal with.
+	 */
+	return NET_XMIT_BUSY;
+}
+
 static struct sk_buff *pfifo_fast_dequeue(struct Qdisc* qdisc)
 {
 	struct pfifo_fast_priv *priv = qdisc_priv(qdisc);
@@ -533,6 +551,7 @@ struct Qdisc_ops pfifo_fast_ops __read_mostly = {
 	.id		=	"pfifo_fast",
 	.priv_size	=	sizeof(struct pfifo_fast_priv),
 	.enqueue	=	pfifo_fast_enqueue,
+	.try_enqueue	=	pfifo_fast_try_enqueue,
 	.dequeue	=	pfifo_fast_dequeue,
 	.peek		=	pfifo_fast_peek,
 	.init		=	pfifo_fast_init,
@@ -564,6 +583,7 @@ struct Qdisc *qdisc_alloc(struct netdev_queue *dev_queue,
 	spin_lock_init(&sch->busylock);
 	sch->ops = ops;
 	sch->enqueue = ops->enqueue;
+	sch->try_enqueue = ops->try_enqueue;
 	sch->dequeue = ops->dequeue;
 	sch->dev_queue = dev_queue;
 	dev_hold(qdisc_dev(sch));
-- 
1.6.2.5

