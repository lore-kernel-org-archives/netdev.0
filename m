From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH 5/5 v4] net: add old_queue_mapping into skb->cb
Date: Thu, 16 Dec 2010 12:56:50 +0800
Message-ID: <1292475410-24665-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	netem@lists.linux-foundation.org, Changli Gao <xiaosuo@gmail.com>
To: Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:65057 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750911Ab0LPFEv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 00:04:51 -0500
Received: by pva4 with SMTP id 4so438256pva.19
        for <netdev@vger.kernel.org>; Wed, 15 Dec 2010 21:04:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For the skbs returned from ifb, we should use the queue_mapping
saved before ifb.

We save old queue_mapping in old_queue_mapping just before calling 
dev_queue_xmit, and restore the old_queue_mapping to queue_mapping
just before reinjecting the ingress packets.

A new struct dev_skb_cb is added, and valid in qdisc and gso layer.
The original qdisc_skb_cb and DEV_GSO_CB use dev_skb_cb as the first
member.

netem_skb_cb is changed to contain qdisc_skb_cb.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
v4: don't restore the old_queue_mapping for egress packets.
v3: use the method from Eric to allocate memory from skb->cb. Thank him.
v2: save old_queue_mapping in skb->cb
 drivers/net/ifb.c         |    1 +
 include/linux/netdevice.h |   10 ++++++++++
 include/net/sch_generic.h |    3 ++-
 net/core/dev.c            |   15 ++++++++++-----
 net/sched/act_mirred.c    |    1 +
 net/sched/sch_netem.c     |    8 ++++----
 6 files changed, 28 insertions(+), 10 deletions(-)
diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 918a38e..1632345 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -96,6 +96,7 @@ static void ri_tasklet(unsigned long arg)
 			dev_queue_xmit(skb);
 		} else if (from & AT_INGRESS) {
 			skb_pull(skb, skb->dev->hard_header_len);
+			skb->queue_mapping = dev_skb_cb(skb)->old_queue_mapping;
 			netif_rx(skb);
 		} else
 			BUG();
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d31bc3c..6f128e3 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1295,6 +1295,16 @@ struct napi_gro_cb {
 
 #define NAPI_GRO_CB(skb) ((struct napi_gro_cb *)(skb)->cb)
 
+struct dev_skb_cb {
+	u16		old_queue_mapping;
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
index ea1f8a8..52c32e3 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -198,8 +198,8 @@ struct tcf_proto {
 };
 
 struct qdisc_skb_cb {
+	struct dev_skb_cb	dev_cb; /* must be the first */
 	unsigned int		pkt_len;
-	char			data[];
 };
 
 static inline int qdisc_qlen(struct Qdisc *q)
@@ -209,6 +209,7 @@ static inline int qdisc_qlen(struct Qdisc *q)
 
 static inline struct qdisc_skb_cb *qdisc_skb_cb(struct sk_buff *skb)
 {
+	BUILD_BUG_ON(sizeof(skb->cb) < sizeof(struct qdisc_skb_cb));
 	return (struct qdisc_skb_cb *)skb->cb;
 }
 
diff --git a/net/core/dev.c b/net/core/dev.c
index d28b3a0..bf5ced5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1901,10 +1901,15 @@ static int illegal_highdma(struct net_device *dev, struct sk_buff *skb)
 }
 
 struct dev_gso_cb {
-	void (*destructor)(struct sk_buff *skb);
+	struct dev_skb_cb	dev_cb; /* must be the first */
+	void			(*destructor)(struct sk_buff *skb);
 };
 
-#define DEV_GSO_CB(skb) ((struct dev_gso_cb *)(skb)->cb)
+static inline struct dev_gso_cb *dev_gso_cb(struct sk_buff *skb)
+{
+	BUILD_BUG_ON(sizeof(skb->cb) < sizeof(struct dev_gso_cb));
+	return (struct dev_gso_cb *)skb->cb;
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
index e5593c0..c2cf72f 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -77,14 +77,14 @@ struct netem_sched_data {
 
 /* Time stamp put into socket buffer control block */
 struct netem_skb_cb {
-	psched_time_t	time_to_send;
+	struct qdisc_skb_cb	qdisc_cb; /* must be the first */
+	psched_time_t		time_to_send;
 };
 
 static inline struct netem_skb_cb *netem_skb_cb(struct sk_buff *skb)
 {
-	BUILD_BUG_ON(sizeof(skb->cb) <
-		sizeof(struct qdisc_skb_cb) + sizeof(struct netem_skb_cb));
-	return (struct netem_skb_cb *)qdisc_skb_cb(skb)->data;
+	BUILD_BUG_ON(sizeof(skb->cb) < sizeof(struct netem_skb_cb));
+	return (struct netem_skb_cb *)skb->cb;
 }
 
 /* init_crandom - initialize correlated random number generator
