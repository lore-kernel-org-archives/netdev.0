From: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH] IPoIB: Stop lying about hard_header_len and use skb->cb to stash LL addresses
Date: Tue,  7 Feb 2012 16:51:21 -0800
Message-ID: <1328662281-16256-1-git-send-email-roland@kernel.org>
References: <CAG4TOxP2iEgT64L8vAR6P139U-HyHSxU8gdWw+cLsDwWSGkrwA@mail.gmail.com>
Cc: eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, herbert-F6s6mLieUQo7FNHlEwC/lvQIK84fMopw@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAG4TOxP2iEgT64L8vAR6P139U-HyHSxU8gdWw+cLsDwWSGkrwA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>

Commit a0417fa3a18a ("net: Make qdisc_skb_cb upper size bound
explicit.") made it possible for a netdev driver to use skb->cb
between its header_ops.create method and its .ndo_start_xmit
method.  Use this in ipoib_hard_header() to stash away the LL address
(GID + QPN), instead of the "ipoib_pseudoheader" hack.  This allows
IPoIB to stop lying about its hard_header_len, which will let us fix
the L2 check for GRO.

Signed-off-by: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
---
OK, this works for me.  Definitely looks cleaner and also looks
obvious enough that it's probably even correct.

 drivers/infiniband/ulp/ipoib/ipoib.h           |    6 ++-
 drivers/infiniband/ulp/ipoib/ipoib_main.c      |   55 ++++++++---------------
 drivers/infiniband/ulp/ipoib/ipoib_multicast.c |   10 +----
 3 files changed, 24 insertions(+), 47 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib.h b/drivers/infiniband/ulp/ipoib/ipoib.h
index b3cc1e0..86df632 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib.h
+++ b/drivers/infiniband/ulp/ipoib/ipoib.h
@@ -44,6 +44,7 @@
 #include <linux/mutex.h>
 
 #include <net/neighbour.h>
+#include <net/sch_generic.h>
 
 #include <linux/atomic.h>
 
@@ -117,8 +118,9 @@ struct ipoib_header {
 	u16	reserved;
 };
 
-struct ipoib_pseudoheader {
-	u8  hwaddr[INFINIBAND_ALEN];
+struct ipoib_cb {
+	struct qdisc_skb_cb	qdisc_cb;
+	u8			hwaddr[INFINIBAND_ALEN];
 };
 
 /* Used for all multicast joins (broadcast, IPv4 mcast and IPv6 mcast) */
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index 3514ca0..3974c29 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -653,7 +653,7 @@ static void ipoib_path_lookup(struct sk_buff *skb, struct neighbour *n, struct n
 }
 
 static void unicast_arp_send(struct sk_buff *skb, struct net_device *dev,
-			     struct ipoib_pseudoheader *phdr)
+			     struct ipoib_cb *cb)
 {
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
 	struct ipoib_path *path;
@@ -661,17 +661,15 @@ static void unicast_arp_send(struct sk_buff *skb, struct net_device *dev,
 
 	spin_lock_irqsave(&priv->lock, flags);
 
-	path = __path_find(dev, phdr->hwaddr + 4);
+	path = __path_find(dev, cb->hwaddr + 4);
 	if (!path || !path->valid) {
 		int new_path = 0;
 
 		if (!path) {
-			path = path_rec_create(dev, phdr->hwaddr + 4);
+			path = path_rec_create(dev, cb->hwaddr + 4);
 			new_path = 1;
 		}
 		if (path) {
-			/* put pseudoheader back on for next time */
-			skb_push(skb, sizeof *phdr);
 			__skb_queue_tail(&path->queue, skb);
 
 			if (!path->query && path_rec_start(dev, path)) {
@@ -695,12 +693,10 @@ static void unicast_arp_send(struct sk_buff *skb, struct net_device *dev,
 			  be16_to_cpu(path->pathrec.dlid));
 
 		spin_unlock_irqrestore(&priv->lock, flags);
-		ipoib_send(dev, skb, path->ah, IPOIB_QPN(phdr->hwaddr));
+		ipoib_send(dev, skb, path->ah, IPOIB_QPN(cb->hwaddr));
 		return;
 	} else if ((path->query || !path_rec_start(dev, path)) &&
 		   skb_queue_len(&path->queue) < IPOIB_MAX_PATH_REC_QUEUE) {
-		/* put pseudoheader back on for next time */
-		skb_push(skb, sizeof *phdr);
 		__skb_queue_tail(&path->queue, skb);
 	} else {
 		++dev->stats.tx_dropped;
@@ -774,16 +770,14 @@ static int ipoib_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			dev_kfree_skb_any(skb);
 		}
 	} else {
-		struct ipoib_pseudoheader *phdr =
-			(struct ipoib_pseudoheader *) skb->data;
-		skb_pull(skb, sizeof *phdr);
+		struct ipoib_cb *cb = (struct ipoib_cb *) skb->cb;
 
-		if (phdr->hwaddr[4] == 0xff) {
+		if (cb->hwaddr[4] == 0xff) {
 			/* Add in the P_Key for multicast*/
-			phdr->hwaddr[8] = (priv->pkey >> 8) & 0xff;
-			phdr->hwaddr[9] = priv->pkey & 0xff;
+			cb->hwaddr[8] = (priv->pkey >> 8) & 0xff;
+			cb->hwaddr[9] = priv->pkey & 0xff;
 
-			ipoib_mcast_send(dev, phdr->hwaddr + 4, skb);
+			ipoib_mcast_send(dev, cb->hwaddr + 4, skb);
 		} else {
 			/* unicast GID -- should be ARP or RARP reply */
 
@@ -792,14 +786,14 @@ static int ipoib_start_xmit(struct sk_buff *skb, struct net_device *dev)
 				ipoib_warn(priv, "Unicast, no %s: type %04x, QPN %06x %pI6\n",
 					   skb_dst(skb) ? "neigh" : "dst",
 					   be16_to_cpup((__be16 *) skb->data),
-					   IPOIB_QPN(phdr->hwaddr),
-					   phdr->hwaddr + 4);
+					   IPOIB_QPN(cb->hwaddr),
+					   cb->hwaddr + 4);
 				dev_kfree_skb_any(skb);
 				++dev->stats.tx_dropped;
 				goto unlock;
 			}
 
-			unicast_arp_send(skb, dev, phdr);
+			unicast_arp_send(skb, dev, cb);
 		}
 	}
 unlock:
@@ -825,8 +819,6 @@ static int ipoib_hard_header(struct sk_buff *skb,
 			     const void *daddr, const void *saddr, unsigned len)
 {
 	struct ipoib_header *header;
-	struct dst_entry *dst;
-	struct neighbour *n;
 
 	header = (struct ipoib_header *) skb_push(skb, sizeof *header);
 
@@ -834,18 +826,13 @@ static int ipoib_hard_header(struct sk_buff *skb,
 	header->reserved = 0;
 
 	/*
-	 * If we don't have a neighbour structure, stuff the
-	 * destination address onto the front of the skb so we can
-	 * figure out where to send the packet later.
+	 * If we don't have a dst_entry structure, stuff the
+	 * destination address into skb->cb so we can figure out where
+	 * to send the packet later.
 	 */
-	dst = skb_dst(skb);
-	n = NULL;
-	if (dst)
-		n = dst_get_neighbour_noref_raw(dst);
-	if ((!dst || !n) && daddr) {
-		struct ipoib_pseudoheader *phdr =
-			(struct ipoib_pseudoheader *) skb_push(skb, sizeof *phdr);
-		memcpy(phdr->hwaddr, daddr, INFINIBAND_ALEN);
+	if (!skb_dst(skb)) {
+		struct ipoib_cb *cb = (struct ipoib_cb *) skb->cb;
+		memcpy(cb->hwaddr, daddr, INFINIBAND_ALEN);
 	}
 
 	return 0;
@@ -1021,11 +1008,7 @@ static void ipoib_setup(struct net_device *dev)
 
 	dev->flags		|= IFF_BROADCAST | IFF_MULTICAST;
 
-	/*
-	 * We add in INFINIBAND_ALEN to allow for the destination
-	 * address "pseudoheader" for skbs without neighbour struct.
-	 */
-	dev->hard_header_len	 = IPOIB_ENCAP_LEN + INFINIBAND_ALEN;
+	dev->hard_header_len	 = IPOIB_ENCAP_LEN;
 	dev->addr_len		 = INFINIBAND_ALEN;
 	dev->type		 = ARPHRD_INFINIBAND;
 	dev->tx_queue_len	 = ipoib_sendq_size * 2;
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
index f7ff9dd..20ebc6f 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
@@ -262,21 +262,13 @@ static int ipoib_mcast_join_finish(struct ipoib_mcast *mcast,
 	netif_tx_lock_bh(dev);
 	while (!skb_queue_empty(&mcast->pkt_queue)) {
 		struct sk_buff *skb = skb_dequeue(&mcast->pkt_queue);
-		struct dst_entry *dst = skb_dst(skb);
-		struct neighbour *n = NULL;
 
 		netif_tx_unlock_bh(dev);
 
 		skb->dev = dev;
-		if (dst)
-			n = dst_get_neighbour_noref_raw(dst);
-		if (!dst || !n) {
-			/* put pseudoheader back on for next time */
-			skb_push(skb, sizeof (struct ipoib_pseudoheader));
-		}
-
 		if (dev_queue_xmit(skb))
 			ipoib_warn(priv, "dev_queue_xmit failed to requeue packet\n");
+
 		netif_tx_lock_bh(dev);
 	}
 	netif_tx_unlock_bh(dev);
-- 
1.7.9

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
