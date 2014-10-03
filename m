From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] qdisc: validate skb without holding lock
Date: Fri, 03 Oct 2014 15:31:07 -0700
Message-ID: <1412375467.17245.16.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141001203345.3321.99675.stgit@dragon>
	 <20141003.123806.183331913071081861.davem@davemloft.net>
	 <1412369869.17245.4.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141003.145647.1980640682969765484.davem@davemloft.net>
	 <1412373477.17245.5.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org, therbert@google.com,
	hannes@stressinduktion.org, fw@strlen.de, dborkman@redhat.com,
	jhs@mojatatu.com, alexander.duyck@gmail.com,
	john.r.fastabend@intel.com, dave.taht@gmail.com, toke@toke.dk
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:55549 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758330AbaJCWah (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 18:30:37 -0400
Received: by mail-pd0-f175.google.com with SMTP id v10so287667pde.6
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 15:30:37 -0700 (PDT)
In-Reply-To: <1412373477.17245.5.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Validation of skb can be pretty expensive :

GSO segmentation and/or checksum computations.

We can do this without holding qdisc lock, so that other cpus
can queue additional packets.

Trick is that requeued packets were already validated, so we carry
a boolean so that sch_direct_xmit() can validate a fresh skb list,
or directly use an old one.

Tested on 40Gb NIC (8 TX queues) and 200 concurrent flows, 48 threads
host.

Turning TSO on or off had no effect on throughput, only few more cpu
cycles. Lock contention on qdisc lock disappeared.

Same if disabling TX checksum offload.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/netdevice.h |    2 -
 include/net/pkt_sched.h   |    2 -
 net/core/dev.c            |   29 +++++++++++++++--
 net/sched/sch_generic.c   |   61 ++++++++++++++++--------------------
 4 files changed, 56 insertions(+), 38 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9b7fbacb6296..910fb17ad148 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2821,7 +2821,7 @@ int dev_set_mac_address(struct net_device *, struct sockaddr *);
 int dev_change_carrier(struct net_device *, bool new_carrier);
 int dev_get_phys_port_id(struct net_device *dev,
 			 struct netdev_phys_port_id *ppid);
-struct sk_buff *validate_xmit_skb(struct sk_buff *skb, struct net_device *dev);
+struct sk_buff *validate_xmit_skb_list(struct sk_buff *skb, struct net_device *dev);
 struct sk_buff *dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 				    struct netdev_queue *txq, int *ret);
 int __dev_forward_skb(struct net_device *dev, struct sk_buff *skb);
diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index 8bbe626e9ece..e4b3c828c1c2 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -99,7 +99,7 @@ void qdisc_put_stab(struct qdisc_size_table *tab);
 void qdisc_warn_nonwc(const char *txt, struct Qdisc *qdisc);
 int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
 		    struct net_device *dev, struct netdev_queue *txq,
-		    spinlock_t *root_lock);
+		    spinlock_t *root_lock, bool validate);
 
 void __qdisc_run(struct Qdisc *q);
 
diff --git a/net/core/dev.c b/net/core/dev.c
index e55c546717d4..1a90530f83ff 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2655,7 +2655,7 @@ struct sk_buff *validate_xmit_vlan(struct sk_buff *skb, netdev_features_t featur
 	return skb;
 }
 
-struct sk_buff *validate_xmit_skb(struct sk_buff *skb, struct net_device *dev)
+static struct sk_buff *validate_xmit_skb(struct sk_buff *skb, struct net_device *dev)
 {
 	netdev_features_t features;
 
@@ -2720,6 +2720,30 @@ out_null:
 	return NULL;
 }
 
+struct sk_buff *validate_xmit_skb_list(struct sk_buff *skb, struct net_device *dev)
+{
+	struct sk_buff *next, *head = NULL, *tail;
+
+	while (skb) {
+		next = skb->next;
+		skb->next = NULL;
+		skb = validate_xmit_skb(skb, dev);
+		if (skb) {
+			struct sk_buff *end = skb;
+
+			while (end->next)
+				end = end->next;
+			if (!head)
+				head = skb;
+			else
+				tail->next = skb;
+			tail = end;
+		}
+		skb = next;
+	}
+	return head;
+}
+
 static void qdisc_pkt_len_init(struct sk_buff *skb)
 {
 	const struct skb_shared_info *shinfo = skb_shinfo(skb);
@@ -2786,8 +2810,7 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 
 		qdisc_bstats_update(q, skb);
 
-		skb = validate_xmit_skb(skb, dev);
-		if (skb && sch_direct_xmit(skb, q, dev, txq, root_lock)) {
+		if (sch_direct_xmit(skb, q, dev, txq, root_lock, true)) {
 			if (unlikely(contended)) {
 				spin_unlock(&q->busylock);
 				contended = false;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 797ebef73642..2b349a4de3c8 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -56,40 +56,34 @@ static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
 	return 0;
 }
 
-static struct sk_buff *try_bulk_dequeue_skb(struct Qdisc *q,
-					    struct sk_buff *head_skb,
-					    int bytelimit)
+static void try_bulk_dequeue_skb(struct Qdisc *q,
+				 struct sk_buff *skb,
+				 const struct netdev_queue *txq)
 {
-	struct sk_buff *skb, *tail_skb = head_skb;
+	int bytelimit = qdisc_avail_bulklimit(txq) - skb->len;
 
 	while (bytelimit > 0) {
-		skb = q->dequeue(q);
-		if (!skb)
-			break;
+		struct sk_buff *nskb = q->dequeue(q);
 
-		bytelimit -= skb->len; /* covers GSO len */
-		skb = validate_xmit_skb(skb, qdisc_dev(q));
-		if (!skb)
+		if (!nskb)
 			break;
 
-		while (tail_skb->next) /* GSO list goto tail */
-			tail_skb = tail_skb->next;
-
-		tail_skb->next = skb;
-		tail_skb = skb;
+		bytelimit -= nskb->len; /* covers GSO len */
+		skb->next = nskb;
+		skb = nskb;
 	}
-
-	return head_skb;
+	skb->next = NULL;
 }
 
 /* Note that dequeue_skb can possibly return a SKB list (via skb->next).
  * A requeued skb (via q->gso_skb) can also be a SKB list.
  */
-static inline struct sk_buff *dequeue_skb(struct Qdisc *q)
+static struct sk_buff *dequeue_skb(struct Qdisc *q, bool *validate)
 {
 	struct sk_buff *skb = q->gso_skb;
 	const struct netdev_queue *txq = q->dev_queue;
 
+	*validate = true;
 	if (unlikely(skb)) {
 		/* check the reason of requeuing without tx lock first */
 		txq = skb_get_tx_queue(txq->dev, skb);
@@ -98,21 +92,16 @@ static inline struct sk_buff *dequeue_skb(struct Qdisc *q)
 			q->q.qlen--;
 		} else
 			skb = NULL;
+		/* skb in gso_skb were already validated */
+		*validate = false;
 	} else {
 		if (!(q->flags & TCQ_F_ONETXQUEUE) ||
 		    !netif_xmit_frozen_or_stopped(txq)) {
-			int bytelimit = qdisc_avail_bulklimit(txq);
-
 			skb = q->dequeue(q);
-			if (skb) {
-				bytelimit -= skb->len;
-				skb = validate_xmit_skb(skb, qdisc_dev(q));
-			}
 			if (skb && qdisc_may_bulk(q))
-				skb = try_bulk_dequeue_skb(q, skb, bytelimit);
+				try_bulk_dequeue_skb(q, skb, txq);
 		}
 	}
-
 	return skb;
 }
 
@@ -156,19 +145,24 @@ static inline int handle_dev_cpu_collision(struct sk_buff *skb,
  */
 int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
 		    struct net_device *dev, struct netdev_queue *txq,
-		    spinlock_t *root_lock)
+		    spinlock_t *root_lock, bool validate)
 {
 	int ret = NETDEV_TX_BUSY;
 
 	/* And release qdisc */
 	spin_unlock(root_lock);
 
-	HARD_TX_LOCK(dev, txq, smp_processor_id());
-	if (!netif_xmit_frozen_or_stopped(txq))
-		skb = dev_hard_start_xmit(skb, dev, txq, &ret);
+	/* Note that we validate skb (GSO, checksum, ...) outside of locks */
+	if (validate)
+		skb = validate_xmit_skb_list(skb, dev);
 
-	HARD_TX_UNLOCK(dev, txq);
+	if (skb) {
+		HARD_TX_LOCK(dev, txq, smp_processor_id());
+		if (!netif_xmit_frozen_or_stopped(txq))
+			skb = dev_hard_start_xmit(skb, dev, txq, &ret);
 
+		HARD_TX_UNLOCK(dev, txq);
+	}
 	spin_lock(root_lock);
 
 	if (dev_xmit_complete(ret)) {
@@ -217,9 +211,10 @@ static inline int qdisc_restart(struct Qdisc *q)
 	struct net_device *dev;
 	spinlock_t *root_lock;
 	struct sk_buff *skb;
+	bool validate;
 
 	/* Dequeue packet */
-	skb = dequeue_skb(q);
+	skb = dequeue_skb(q, &validate);
 	if (unlikely(!skb))
 		return 0;
 
@@ -229,7 +224,7 @@ static inline int qdisc_restart(struct Qdisc *q)
 	dev = qdisc_dev(q);
 	txq = skb_get_tx_queue(dev, skb);
 
-	return sch_direct_xmit(skb, q, dev, txq, root_lock);
+	return sch_direct_xmit(skb, q, dev, txq, root_lock, validate);
 }
 
 void __qdisc_run(struct Qdisc *q)
