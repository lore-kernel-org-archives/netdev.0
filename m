From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 03/45] clip: convert to internal network_device_stats
Date: Fri, 09 Jan 2009 15:01:00 -0800
Message-ID: <20090109230136.928409407@linux-foundation.org>
References: <20090109230057.575650817@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Chas Williams <chas@cmf.nrl.navy.mil>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42288 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754677AbZAIXSJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 18:18:09 -0500
Content-Disposition: inline; filename=clip_stats.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 include/net/atmclip.h |    1 -
 net/atm/clip.c        |   30 ++++++++++++------------------
 2 files changed, 12 insertions(+), 19 deletions(-)

--- a/include/net/atmclip.h	2009-01-08 23:29:07.000000000 -0800
+++ b/include/net/atmclip.h	2009-01-08 23:29:47.000000000 -0800
@@ -50,7 +50,6 @@ struct atmarp_entry {
 struct clip_priv {
 	int number;			/* for convenience ... */
 	spinlock_t xoff_lock;		/* ensures that pop is atomic (SMP) */
-	struct net_device_stats stats;
 	struct net_device *next;	/* next CLIP interface */
 };
 
--- a/net/atm/clip.c	2009-01-08 23:29:07.000000000 -0800
+++ b/net/atm/clip.c	2009-01-08 23:29:47.000000000 -0800
@@ -214,15 +214,15 @@ static void clip_push(struct atm_vcc *vc
 		skb->protocol = ((__be16 *) skb->data)[3];
 		skb_pull(skb, RFC1483LLC_LEN);
 		if (skb->protocol == htons(ETH_P_ARP)) {
-			PRIV(skb->dev)->stats.rx_packets++;
-			PRIV(skb->dev)->stats.rx_bytes += skb->len;
+			skb->dev->stats.rx_packets++;
+			skb->dev->stats.rx_bytes += skb->len;
 			clip_arp_rcv(skb);
 			return;
 		}
 	}
 	clip_vcc->last_use = jiffies;
-	PRIV(skb->dev)->stats.rx_packets++;
-	PRIV(skb->dev)->stats.rx_bytes += skb->len;
+	skb->dev->stats.rx_packets++;
+	skb->dev->stats.rx_bytes += skb->len;
 	memset(ATM_SKB(skb), 0, sizeof(struct atm_skb_data));
 	netif_rx(skb);
 }
@@ -372,7 +372,7 @@ static int clip_start_xmit(struct sk_buf
 	if (!skb->dst) {
 		printk(KERN_ERR "clip_start_xmit: skb->dst == NULL\n");
 		dev_kfree_skb(skb);
-		clip_priv->stats.tx_dropped++;
+		dev->stats.tx_dropped++;
 		return 0;
 	}
 	if (!skb->dst->neighbour) {
@@ -380,13 +380,13 @@ static int clip_start_xmit(struct sk_buf
 		skb->dst->neighbour = clip_find_neighbour(skb->dst, 1);
 		if (!skb->dst->neighbour) {
 			dev_kfree_skb(skb);	/* lost that one */
-			clip_priv->stats.tx_dropped++;
+			dev->stats.tx_dropped++;
 			return 0;
 		}
 #endif
 		printk(KERN_ERR "clip_start_xmit: NO NEIGHBOUR !\n");
 		dev_kfree_skb(skb);
-		clip_priv->stats.tx_dropped++;
+		dev->stats.tx_dropped++;
 		return 0;
 	}
 	entry = NEIGH2ENTRY(skb->dst->neighbour);
@@ -400,7 +400,7 @@ static int clip_start_xmit(struct sk_buf
 			skb_queue_tail(&entry->neigh->arp_queue, skb);
 		else {
 			dev_kfree_skb(skb);
-			clip_priv->stats.tx_dropped++;
+			dev->stats.tx_dropped++;
 		}
 		return 0;
 	}
@@ -423,8 +423,8 @@ static int clip_start_xmit(struct sk_buf
 		printk(KERN_WARNING "clip_start_xmit: XOFF->XOFF transition\n");
 		return 0;
 	}
-	clip_priv->stats.tx_packets++;
-	clip_priv->stats.tx_bytes += skb->len;
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += skb->len;
 	vcc->send(vcc, skb);
 	if (atm_may_send(vcc, 0)) {
 		entry->vccs->xoff = 0;
@@ -443,11 +443,6 @@ static int clip_start_xmit(struct sk_buf
 	return 0;
 }
 
-static struct net_device_stats *clip_get_stats(struct net_device *dev)
-{
-	return &PRIV(dev)->stats;
-}
-
 static int clip_mkip(struct atm_vcc *vcc, int timeout)
 {
 	struct clip_vcc *clip_vcc;
@@ -501,8 +496,8 @@ static int clip_mkip(struct atm_vcc *vcc
 
 			skb_get(skb);
 			clip_push(vcc, skb);
-			PRIV(skb->dev)->stats.rx_packets--;
-			PRIV(skb->dev)->stats.rx_bytes -= len;
+			skb->dev->stats.rx_packets--;
+			skb->dev->stats.rx_bytes -= len;
 			kfree_skb(skb);
 		}
 
@@ -561,7 +556,6 @@ static void clip_setup(struct net_device
 {
 	dev->hard_start_xmit = clip_start_xmit;
 	/* sg_xmit ... */
-	dev->get_stats = clip_get_stats;
 	dev->type = ARPHRD_ATM;
 	dev->hard_header_len = RFC1483LLC_LEN;
 	dev->mtu = RFC1626_MTU;


