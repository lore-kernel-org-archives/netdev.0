From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [2/5] [NET]: Add generic segmentation offload
Date: Thu, 22 Jun 2006 18:13:23 +1000
Message-ID: <20060622081323.GB22671@gondor.apana.org.au>
References: <20060622081211.GA22505@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="NDin8bjvE/0mNLFQ"
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:14084 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932840AbWFVIN0
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 04:13:26 -0400
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060622081211.GA22505@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--NDin8bjvE/0mNLFQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

[NET]: Add generic segmentation offload

This patch adds the infrastructure for generic segmentation offload.
The idea is to tap into the potential savings of TSO without hardware
support by postponing the allocation of segmented skb's until just
before the entry point into the NIC driver.

The same structure can be used to support software IPv6 TSO, as well as
UFO and segmentation offload for other relevant protocols, e.g., DCCP.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--NDin8bjvE/0mNLFQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="p2.patch"

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -406,6 +406,9 @@ struct net_device
 	struct list_head	qdisc_list;
 	unsigned long		tx_queue_len;	/* Max frames per queue allowed */
 
+	/* Partially transmitted GSO packet. */
+	struct sk_buff		*gso_skb;
+
 	/* ingress path synchronizer */
 	spinlock_t		ingress_lock;
 	struct Qdisc		*qdisc_ingress;
@@ -540,6 +543,7 @@ struct packet_type {
 					 struct net_device *,
 					 struct packet_type *,
 					 struct net_device *);
+	struct sk_buff		*(*gso_segment)(struct sk_buff *skb, int sg);
 	void			*af_packet_priv;
 	struct list_head	list;
 };
@@ -690,7 +694,8 @@ extern int		dev_change_name(struct net_d
 extern int		dev_set_mtu(struct net_device *, int);
 extern int		dev_set_mac_address(struct net_device *,
 					    struct sockaddr *);
-extern void		dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev);
+extern int		dev_hard_start_xmit(struct sk_buff *skb,
+					    struct net_device *dev);
 
 extern void		dev_init(void);
 
@@ -964,6 +969,7 @@ extern int		netdev_max_backlog;
 extern int		weight_p;
 extern int		netdev_set_master(struct net_device *dev, struct net_device *master);
 extern int skb_checksum_help(struct sk_buff *skb, int inward);
+extern struct sk_buff *skb_gso_segment(struct sk_buff *skb, int sg);
 #ifdef CONFIG_BUG
 extern void netdev_rx_csum_fault(struct net_device *dev);
 #else
diff --git a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -116,6 +116,7 @@
 #include <asm/current.h>
 #include <linux/audit.h>
 #include <linux/dmaengine.h>
+#include <linux/err.h>
 
 /*
  *	The list of packet types we will receive (as opposed to discard)
@@ -1048,7 +1049,7 @@ static inline void net_timestamp(struct 
  *	taps currently in use.
  */
 
-void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
+static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct packet_type *ptype;
 
@@ -1186,6 +1187,40 @@ out:	
 	return ret;
 }
 
+/**
+ *	skb_gso_segment - Perform segmentation on skb.
+ *	@skb: buffer to segment
+ *	@sg: whether scatter-gather is supported on the target.
+ *
+ *	This function segments the given skb and returns a list of segments.
+ */
+struct sk_buff *skb_gso_segment(struct sk_buff *skb, int sg)
+{
+	struct sk_buff *segs = ERR_PTR(-EPROTONOSUPPORT);
+	struct packet_type *ptype;
+	int type = skb->protocol;
+
+	BUG_ON(skb_shinfo(skb)->frag_list);
+	BUG_ON(skb->ip_summed != CHECKSUM_HW);
+
+	skb->mac.raw = skb->data;
+	skb->mac_len = skb->nh.raw - skb->data;
+	__skb_pull(skb, skb->mac_len);
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(ptype, &ptype_base[ntohs(type) & 15], list) {
+		if (ptype->type == type && !ptype->dev && ptype->gso_segment) {
+			segs = ptype->gso_segment(skb, sg);
+			break;
+		}
+	}
+	rcu_read_unlock();
+
+	return segs;
+}
+
+EXPORT_SYMBOL(skb_gso_segment);
+
 /* Take action when hardware reception checksum errors are detected. */
 #ifdef CONFIG_BUG
 void netdev_rx_csum_fault(struct net_device *dev)
@@ -1222,6 +1257,86 @@ static inline int illegal_highdma(struct
 #define illegal_highdma(dev, skb)	(0)
 #endif
 
+struct dev_gso_cb {
+	void (*destructor)(struct sk_buff *skb);
+};
+
+#define DEV_GSO_CB(skb) ((struct dev_gso_cb *)(skb)->cb)
+
+static void dev_gso_skb_destructor(struct sk_buff *skb)
+{
+	struct dev_gso_cb *cb;
+
+	do {
+		struct sk_buff *nskb = skb->next;
+
+		skb->next = nskb->next;
+		nskb->next = NULL;
+		kfree_skb(nskb);
+	} while (skb->next);
+
+	cb = DEV_GSO_CB(skb);
+	if (cb->destructor)
+		cb->destructor(skb);
+}
+
+/**
+ *	dev_gso_segment - Perform emulated hardware segmentation on skb.
+ *	@skb: buffer to segment
+ *
+ *	This function segments the given skb and stores the list of segments
+ *	in skb->next.
+ */
+static int dev_gso_segment(struct sk_buff *skb)
+{
+	struct net_device *dev = skb->dev;
+	struct sk_buff *segs;
+
+	segs = skb_gso_segment(skb, dev->features & NETIF_F_SG &&
+				    !illegal_highdma(dev, skb));
+	if (unlikely(IS_ERR(segs)))
+		return PTR_ERR(segs);
+
+	skb->next = segs;
+	DEV_GSO_CB(skb)->destructor = skb->destructor;
+	skb->destructor = dev_gso_skb_destructor;
+
+	return 0;
+}
+
+int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	if (likely(!skb->next)) {
+		if (netdev_nit)
+			dev_queue_xmit_nit(skb, dev);
+
+		if (!netif_needs_gso(dev, skb))
+			return dev->hard_start_xmit(skb, dev);
+
+		if (unlikely(dev_gso_segment(skb)))
+			goto out_kfree_skb;
+	}
+
+	do {
+		struct sk_buff *nskb = skb->next;
+		int rc;
+
+		skb->next = nskb->next;
+		nskb->next = NULL;
+		rc = dev->hard_start_xmit(nskb, dev);
+		if (unlikely(rc)) {
+			skb->next = nskb;
+			return rc;
+		}
+	} while (skb->next);
+	
+	skb->destructor = DEV_GSO_CB(skb)->destructor;
+
+out_kfree_skb:
+	kfree_skb(skb);
+	return 0;
+}
+
 #define HARD_TX_LOCK(dev, cpu) {			\
 	if ((dev->features & NETIF_F_LLTX) == 0) {	\
 		netif_tx_lock(dev);			\
@@ -1266,6 +1381,10 @@ int dev_queue_xmit(struct sk_buff *skb)
 	struct Qdisc *q;
 	int rc = -ENOMEM;
 
+	/* GSO will handle the following emulations directly. */
+	if (netif_needs_gso(dev, skb))
+		goto gso;
+
 	if (skb_shinfo(skb)->frag_list &&
 	    !(dev->features & NETIF_F_FRAGLIST) &&
 	    __skb_linearize(skb))
@@ -1290,6 +1409,7 @@ int dev_queue_xmit(struct sk_buff *skb)
 	      	if (skb_checksum_help(skb, 0))
 	      		goto out_kfree_skb;
 
+gso:
 	spin_lock_prefetch(&dev->queue_lock);
 
 	/* Disable soft irqs for various locks below. Also 
@@ -1346,11 +1466,8 @@ int dev_queue_xmit(struct sk_buff *skb)
 			HARD_TX_LOCK(dev, cpu);
 
 			if (!netif_queue_stopped(dev)) {
-				if (netdev_nit)
-					dev_queue_xmit_nit(skb, dev);
-
 				rc = 0;
-				if (!dev->hard_start_xmit(skb, dev)) {
+				if (!dev_hard_start_xmit(skb, dev)) {
 					HARD_TX_UNLOCK(dev);
 					goto out;
 				}
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -96,8 +96,11 @@ static inline int qdisc_restart(struct n
 	struct sk_buff *skb;
 
 	/* Dequeue packet */
-	if ((skb = q->dequeue(q)) != NULL) {
+	if (((skb = dev->gso_skb)) || ((skb = q->dequeue(q)))) {
 		unsigned nolock = (dev->features & NETIF_F_LLTX);
+
+		dev->gso_skb = NULL;
+
 		/*
 		 * When the driver has LLTX set it does its own locking
 		 * in start_xmit. No need to add additional overhead by
@@ -134,10 +137,8 @@ static inline int qdisc_restart(struct n
 
 			if (!netif_queue_stopped(dev)) {
 				int ret;
-				if (netdev_nit)
-					dev_queue_xmit_nit(skb, dev);
 
-				ret = dev->hard_start_xmit(skb, dev);
+				ret = dev_hard_start_xmit(skb, dev);
 				if (ret == NETDEV_TX_OK) { 
 					if (!nolock) {
 						netif_tx_unlock(dev);
@@ -171,7 +172,10 @@ static inline int qdisc_restart(struct n
 		 */
 
 requeue:
-		q->ops->requeue(skb, q);
+		if (skb->next)
+			dev->gso_skb = skb;
+		else
+			q->ops->requeue(skb, q);
 		netif_schedule(dev);
 		return 1;
 	}
@@ -576,6 +580,7 @@ void dev_activate(struct net_device *dev
 void dev_deactivate(struct net_device *dev)
 {
 	struct Qdisc *qdisc;
+	struct sk_buff *skb;
 
 	spin_lock_bh(&dev->queue_lock);
 	qdisc = dev->qdisc;
@@ -593,6 +598,11 @@ void dev_deactivate(struct net_device *d
 	/* Wait for outstanding qdisc_run calls. */
 	while (test_bit(__LINK_STATE_QDISC_RUNNING, &dev->state))
 		yield();
+
+	if (dev->gso_skb) {
+		kfree_skb(dev->gso_skb);
+		dev->gso_skb = NULL;
+	}
 }
 
 void dev_init_scheduler(struct net_device *dev)

--NDin8bjvE/0mNLFQ--
