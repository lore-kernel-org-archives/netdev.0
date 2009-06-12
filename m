From: Patrick McHardy <kaber@trash.net>
Subject: net: fix network driver ndo_start_xmit() return values (part 1)
Date: Fri, 12 Jun 2009 15:00:35 +0200
Message-ID: <4A325173.3070608@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050509070802030900080301"
Cc: Linux Netdev List <netdev@vger.kernel.org>, holt@sgi.com,
	thierry.reding@avionic-design.de, jes@trained-monkey.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44561 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763297AbZFLNAh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2009 09:00:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050509070802030900080301
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

These patches begin fixing up the ndo_start_xmit() return values
of drivers returning errno codes. I'll send them one at a time as
I finish them since its quite a lot.

All four drivers touched in this patch compile tested.


--------------050509070802030900080301
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

commit 1a2b8190d63e4e3d69c074f0e913a814edd481fe
Author: Patrick McHardy <kaber@trash.net>
Date:   Fri Jun 12 14:52:19 2009 +0200

    net: fix network driver ndo_start_xmit() return values (part 1)
    
    Fix up drivers that return an errno value to qdisc_restart(), causing
    qdisc_restart() to print a warning and requeue/retransmit the skb.
    
    - xpnet: memory allocation error, intention is to drop
    - ethoc: oversized packet, packet must be dropped
    - ibmlana: skb freed: use after free
    - rrunner: skb freed: use after free
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/drivers/misc/sgi-xp/xpnet.c b/drivers/misc/sgi-xp/xpnet.c
index 6faefcf..8d1c60a 100644
--- a/drivers/misc/sgi-xp/xpnet.c
+++ b/drivers/misc/sgi-xp/xpnet.c
@@ -450,7 +450,8 @@ xpnet_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			 "packet\n", sizeof(struct xpnet_pending_msg));
 
 		dev->stats.tx_errors++;
-		return -ENOMEM;
+		dev_kfree_skb(skb);
+		return NETDEV_TX_OK;
 	}
 
 	/* get the beginning of the first cacheline and end of last */
diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index 91a9b1a..ceb6a9c 100644
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -811,7 +811,7 @@ static int ethoc_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (unlikely(skb->len > ETHOC_BUFSIZ)) {
 		priv->stats.tx_errors++;
-		return -EMSGSIZE;
+		goto out;
 	}
 
 	entry = priv->cur_tx % priv->num_tx;
@@ -840,9 +840,9 @@ static int ethoc_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	dev->trans_start = jiffies;
-	dev_kfree_skb(skb);
-
 	spin_unlock_irq(&priv->lock);
+out:
+	dev_kfree_skb(skb);
 	return NETDEV_TX_OK;
 }
 
diff --git a/drivers/net/ibmlana.c b/drivers/net/ibmlana.c
index c25bc0b..448098d 100644
--- a/drivers/net/ibmlana.c
+++ b/drivers/net/ibmlana.c
@@ -815,7 +815,7 @@ static int ibmlana_close(struct net_device *dev)
 static int ibmlana_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	ibmlana_priv *priv = netdev_priv(dev);
-	int retval = 0, tmplen, addr;
+	int tmplen, addr;
 	unsigned long flags;
 	tda_t tda;
 	int baddr;
@@ -824,7 +824,6 @@ static int ibmlana_tx(struct sk_buff *skb, struct net_device *dev)
 	   the upper layer is in deep desperation and we simply ignore the frame. */
 
 	if (priv->txusedcnt >= TXBUFCNT) {
-		retval = -EIO;
 		dev->stats.tx_dropped++;
 		goto tx_done;
 	}
@@ -874,7 +873,7 @@ static int ibmlana_tx(struct sk_buff *skb, struct net_device *dev)
 	spin_unlock_irqrestore(&priv->lock, flags);
 tx_done:
 	dev_kfree_skb(skb);
-	return retval;
+	return NETDEV_TX_OK;
 }
 
 /* switch receiver mode. */
diff --git a/drivers/net/rrunner.c b/drivers/net/rrunner.c
index d890829..81dbcbb 100644
--- a/drivers/net/rrunner.c
+++ b/drivers/net/rrunner.c
@@ -1425,7 +1425,7 @@ static int rr_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		if (!(new_skb = dev_alloc_skb(len + 8))) {
 			dev_kfree_skb(skb);
 			netif_wake_queue(dev);
-			return -EBUSY;
+			return NETDEV_TX_OK;
 		}
 		skb_reserve(new_skb, 8);
 		skb_put(new_skb, len);

--------------050509070802030900080301--
