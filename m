From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH 5/5 v2] net: add old_queue_mapping into skb->cb
Date: Wed, 15 Dec 2010 13:23:56 +0800
Message-ID: <1292390636-3156-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	netem@lists.linux-foundation.org, Changli Gao <xiaosuo@gmail.com>
To: Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f180.google.com ([209.85.161.180]:50092 "EHLO
	mail-gx0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751089Ab0LOFYt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 00:24:49 -0500
Received: by gxk19 with SMTP id 19so1018342gxk.11
        for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 21:24:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For the skbs returned from ifb, we should use the queue_mapping
saved before ifb.

We save old queue_mapping in old_queue_mapping just before calling 
dev_queue_xmit, and restore the old_queue_mapping to queue_mapping
just before reinjecting the skb.

dev_pick_tx() use the current queue_mapping for the skbs reinjected
by ifb.

A new struct dev_skb_cb is added, and valid in qdisc and gso layer.
The original qdisc_skb_cb and DEV_GSO_CB are placed after dev_skb_cb.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
v2: save old_queue_mapping in skb->cb
 drivers/net/ifb.c         |    1 +
 include/linux/netdevice.h |   11 +++++++++++
 include/net/sch_generic.h |    6 ++++--
 net/core/dev.c            |   18 ++++++++++++++----
 net/sched/act_mirred.c    |    1 +
 net/sched/sch_netem.c     |    5 +++--
 6 files changed, 34 insertions(+), 8 deletions(-)
diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 918a38e..ff01795 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -92,6 +92,7 @@ static void ri_tasklet(unsigned long arg)
 		u64_stats_update_end(&qp->syncp);
 		skb->skb_iif = dev->ifindex;
 
+		skb->queue_mapping = dev_skb_cb(skb)->old_queue_mapping;
 		if (from & AT_EGRESS) {
 			dev_queue_xmit(skb);
 		} else if (from & AT_INGRESS) {
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d31bc3c..9820a48 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1295,6 +1295,17 @@ struct napi_gro_cb {
 
 #define NAPI_GRO_CB(skb) ((struct napi_gro_cb *)(skb)->cb)
 
+struct dev_skb_cb {
+	u16		old_queue_mapping;
+	unsigned long	data[];
+};
+
+static inline struct dev_skb_cb *dev_skb_cb(struct sk_buff *skb)
+{
+	BUILD_BUG_ON(sizeof(skb->cb) < sizeof(struct dev_skb_cb));
+	return (struct dev_skb_cb *)skb->cb;
+}
+
 struct packet_type {
 	__be16			type;	/* This is really htons(ether_type). */
 	struct net_device	*dev;	/* NULL is wildcarded here	     */
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index ea1f8a8..1089938 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -199,7 +199,7 @@ struct tcf_proto {
 
 struct qdisc_skb_cb {
 	unsigned int		pkt_len;
-	char			data[];
+	unsigned long		data[];
 };
 
 static inline int qdisc_qlen(struct Qdisc *q)
@@ -209,7 +209,9 @@ static inline int qdisc_qlen(struct Qdisc *q)
 
 static inline struct qdisc_skb_cb *qdisc_skb_cb(struct sk_buff *skb)
 {
-	return (struct qdisc_skb_cb *)skb->cb;
+	BUILD_BUG_ON(sizeof(skb->cb) < sizeof(struct dev_skb_cb) +
+				       sizeof(struct qdisc_skb_cb));
+	return (struct qdisc_skb_cb *)dev_skb_cb(skb)->data;
 }
 
 static inline spinlock_t *qdisc_lock(struct Qdisc *qdisc)
diff --git a/net/core/dev.c b/net/core/dev.c
index d28b3a0..11a5a13 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1904,7 +1904,12 @@ struct dev_gso_cb {
 	void (*destructor)(struct sk_buff *skb);
 };
 
-#define DEV_GSO_CB(skb) ((struct dev_gso_cb *)(skb)->cb)
+static inline struct dev_gso_cb *dev_gso_cb(struct sk_buff *skb)
+{
+	BUILD_BUG_ON(sizeof(skb->cb) < sizeof(struct dev_skb_cb) +
+				       sizeof(struct dev_gso_cb));
+	return (struct dev_gso_cb *)dev_skb_cb(skb)->data;
+}
 
 static void dev_gso_skb_destructor(struct sk_buff *skb)
 {
@@ -1918,7 +1923,7 @@ static void dev_gso_skb_destructor(struct sk_buff *skb)
 		kfree_skb(nskb);
 	} while (skb->next);
 
-	cb = DEV_GSO_CB(skb);
+	cb = dev_gso_cb(skb);
 	if (cb->destructor)
 		cb->destructor(skb);
 }
@@ -1947,7 +1952,7 @@ static int dev_gso_segment(struct sk_buff *skb)
 		return PTR_ERR(segs);
 
 	skb->next = segs;
-	DEV_GSO_CB(skb)->destructor = skb->destructor;
+	dev_gso_cb(skb)->destructor = skb->destructor;
 	skb->destructor = dev_gso_skb_destructor;
 
 	return 0;
@@ -2103,7 +2108,7 @@ gso:
 
 out_kfree_gso_skb:
 	if (likely(skb->next == NULL))
-		skb->destructor = DEV_GSO_CB(skb)->destructor;
+		skb->destructor = dev_gso_cb(skb)->destructor;
 out_kfree_skb:
 	kfree_skb(skb);
 out:
@@ -2190,6 +2195,11 @@ static struct netdev_queue *dev_pick_tx(struct net_device *dev,
 	int queue_index;
 	const struct net_device_ops *ops = dev->netdev_ops;
 
+#ifdef CONFIG_NET_CLS_ACT
+	if (skb->tc_verd & TC_NCLS)
+		queue_index = skb_get_queue_mapping(skb);
+	else
+#endif
 	if (dev->real_num_tx_queues == 1)
 		queue_index = 0;
 	else if (ops->ndo_select_queue) {
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 0c311be..419e82f 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -197,6 +197,7 @@ static int tcf_mirred(struct sk_buff *skb, struct tc_action *a,
 
 	skb2->skb_iif = skb->dev->ifindex;
 	skb2->dev = dev;
+	dev_skb_cb(skb2)->old_queue_mapping = skb->queue_mapping;
 	dev_queue_xmit(skb2);
 	err = 0;
 
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index e5593c0..df4ff89 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -82,8 +82,9 @@ struct netem_skb_cb {
 
 static inline struct netem_skb_cb *netem_skb_cb(struct sk_buff *skb)
 {
-	BUILD_BUG_ON(sizeof(skb->cb) <
-		sizeof(struct qdisc_skb_cb) + sizeof(struct netem_skb_cb));
+	BUILD_BUG_ON(sizeof(skb->cb) < sizeof(struct dev_skb_cb) +
+				       sizeof(struct qdisc_skb_cb) +
+				       sizeof(struct netem_skb_cb));
 	return (struct netem_skb_cb *)qdisc_skb_cb(skb)->data;
 }
 
