From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 04/45] lec: convert to internal network_device_stats
Date: Fri, 09 Jan 2009 15:01:01 -0800
Message-ID: <20090109230137.002883258@linux-foundation.org>
References: <20090109230057.575650817@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Chas Williams <chas@cmf.nrl.navy.mil>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42302 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755121AbZAIXSO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 18:18:14 -0500
Content-Disposition: inline; filename=lec-stats.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 net/atm/lec.c |   44 +++++++++++++++++---------------------------
 net/atm/lec.h |    1 -
 2 files changed, 17 insertions(+), 28 deletions(-)

--- a/net/atm/lec.h	2009-01-09 10:14:04.000000000 -0800
+++ b/net/atm/lec.h	2009-01-09 10:15:14.000000000 -0800
@@ -69,7 +69,6 @@ struct lane2_ops {
 #define LEC_ARP_TABLE_SIZE 16
 
 struct lec_priv {
-	struct net_device_stats stats;
 	unsigned short lecid;			/* Lecid of this client */
 	struct hlist_head lec_arp_empty_ones;
 						/* Used for storing VCC's that don't have a MAC address attached yet */
--- a/net/atm/lec.c	2009-01-09 10:14:04.000000000 -0800
+++ b/net/atm/lec.c	2009-01-09 10:15:14.000000000 -0800
@@ -62,7 +62,6 @@ static unsigned char bridge_ula_lec[] = 
 static int lec_open(struct net_device *dev);
 static int lec_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static int lec_close(struct net_device *dev);
-static struct net_device_stats *lec_get_stats(struct net_device *dev);
 static void lec_init(struct net_device *dev);
 static struct lec_arp_table *lec_arp_find(struct lec_priv *priv,
 					  const unsigned char *mac_addr);
@@ -218,28 +217,28 @@ static unsigned char *get_tr_dst(unsigne
 
 static int lec_open(struct net_device *dev)
 {
-	struct lec_priv *priv = netdev_priv(dev);
-
 	netif_start_queue(dev);
-	memset(&priv->stats, 0, sizeof(struct net_device_stats));
+	memset(&dev->stats, 0, sizeof(struct net_device_stats));
 
 	return 0;
 }
 
-static __inline__ void
-lec_send(struct atm_vcc *vcc, struct sk_buff *skb, struct lec_priv *priv)
+static void
+lec_send(struct atm_vcc *vcc, struct sk_buff *skb)
 {
+	struct net_device *dev = skb->dev;
+
 	ATM_SKB(skb)->vcc = vcc;
 	ATM_SKB(skb)->atm_options = vcc->atm_options;
 
 	atomic_add(skb->truesize, &sk_atm(vcc)->sk_wmem_alloc);
 	if (vcc->send(vcc, skb) < 0) {
-		priv->stats.tx_dropped++;
+		dev->stats.tx_dropped++;
 		return;
 	}
 
-	priv->stats.tx_packets++;
-	priv->stats.tx_bytes += skb->len;
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += skb->len;
 }
 
 static void lec_tx_timeout(struct net_device *dev)
@@ -270,7 +269,7 @@ static int lec_start_xmit(struct sk_buff
 	pr_debug("lec_start_xmit called\n");
 	if (!priv->lecd) {
 		printk("%s:No lecd attached\n", dev->name);
-		priv->stats.tx_errors++;
+		dev->stats.tx_errors++;
 		netif_stop_queue(dev);
 		return -EUNATCH;
 	}
@@ -345,7 +344,7 @@ static int lec_start_xmit(struct sk_buff
 					       GFP_ATOMIC);
 			dev_kfree_skb(skb);
 			if (skb2 == NULL) {
-				priv->stats.tx_dropped++;
+				dev->stats.tx_dropped++;
 				return 0;
 			}
 			skb = skb2;
@@ -380,7 +379,7 @@ static int lec_start_xmit(struct sk_buff
 			    ("%s:lec_start_xmit: tx queue full or no arp entry, dropping, ",
 			     dev->name);
 			pr_debug("MAC address %pM\n", lec_h->h_dest);
-			priv->stats.tx_dropped++;
+			dev->stats.tx_dropped++;
 			dev_kfree_skb(skb);
 		}
 		goto out;
@@ -392,10 +391,10 @@ static int lec_start_xmit(struct sk_buff
 	while (entry && (skb2 = skb_dequeue(&entry->tx_wait))) {
 		pr_debug("lec.c: emptying tx queue, ");
 		pr_debug("MAC address %pM\n", lec_h->h_dest);
-		lec_send(vcc, skb2, priv);
+		lec_send(vcc, skb2);
 	}
 
-	lec_send(vcc, skb, priv);
+	lec_send(vcc, skb);
 
 	if (!atm_may_send(vcc, 0)) {
 		struct lec_vcc_priv *vpriv = LEC_VCC_PRIV(vcc);
@@ -427,15 +426,6 @@ static int lec_close(struct net_device *
 	return 0;
 }
 
-/*
- * Get the current statistics.
- * This may be called with the card open or closed.
- */
-static struct net_device_stats *lec_get_stats(struct net_device *dev)
-{
-	return &((struct lec_priv *)netdev_priv(dev))->stats;
-}
-
 static int lec_atm_send(struct atm_vcc *vcc, struct sk_buff *skb)
 {
 	unsigned long flags;
@@ -810,8 +800,8 @@ static void lec_push(struct atm_vcc *vcc
 		else
 #endif
 			skb->protocol = eth_type_trans(skb, dev);
-		priv->stats.rx_packets++;
-		priv->stats.rx_bytes += skb->len;
+		dev->stats.rx_packets++;
+		dev->stats.rx_bytes += skb->len;
 		memset(ATM_SKB(skb), 0, sizeof(struct atm_skb_data));
 		netif_rx(skb);
 	}
@@ -1887,7 +1877,7 @@ restart:
 					lec_arp_hold(entry);
 					spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
 					while ((skb = skb_dequeue(&entry->tx_wait)) != NULL)
-						lec_send(vcc, skb, entry->priv);
+						lec_send(vcc, skb);
 					entry->last_used = jiffies;
 					entry->status = ESI_FORWARD_DIRECT;
 					lec_arp_put(entry);
@@ -2305,7 +2295,7 @@ restart:
 				lec_arp_hold(entry);
 				spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
 				while ((skb = skb_dequeue(&entry->tx_wait)) != NULL)
-					lec_send(vcc, skb, entry->priv);
+					lec_send(vcc, skb);
 				entry->last_used = jiffies;
 				entry->status = ESI_FORWARD_DIRECT;
 				lec_arp_put(entry);


