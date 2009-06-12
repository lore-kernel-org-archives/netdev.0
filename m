From: Patrick McHardy <kaber@trash.net>
Subject: net: fix network drivers ndo_start_xmit() return values (part 2)
Date: Fri, 12 Jun 2009 15:17:19 +0200
Message-ID: <4A32555F.1010907@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010109080506030304020600"
Cc: Linux Netdev List <netdev@vger.kernel.org>, samuel@sortiz.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44889 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758302AbZFLNRT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2009 09:17:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010109080506030304020600
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------010109080506030304020600
Content-Type: text/x-patch;
 name="02.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02.diff"

commit 3ce2adbe6573cb94e21d2bf3026ca0131badfb27
Author: Patrick McHardy <kaber@trash.net>
Date:   Fri Jun 12 15:14:36 2009 +0200

    net: fix network drivers ndo_start_xmit() return values (part 2)
    
    Fix up IRDA drivers that return an errno value to qdisc_restart(), causing
    qdisc_restart() to print a warning an requeue/retransmit the skb.
    
    - donauboe: intention appears to be to have the skb retransmitted without
                error message
    - irda-usb: intention is to drop silently according to comment
    - kingsub-sir: skb is freed: use after free
    - ks959-sir: skb is freed: use after free
    - ksdazzle-sir: skb is freed: use after free
    - mcs7880: skb is freed: use after free
    
    All but donauboe compile tested.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/drivers/net/irda/donauboe.c b/drivers/net/irda/donauboe.c
index 6b6548b..9a0346e 100644
--- a/drivers/net/irda/donauboe.c
+++ b/drivers/net/irda/donauboe.c
@@ -994,11 +994,11 @@ toshoboe_hard_xmit (struct sk_buff *skb, struct net_device *dev)
 
   /* change speed pending, wait for its execution */
   if (self->new_speed)
-      return -EBUSY;
+      return NETDEV_TX_BUSY;
 
   /* device stopped (apm) wait for restart */
   if (self->stopped)
-      return -EBUSY;
+      return NETDEV_TX_BUSY;
 
   toshoboe_checkstuck (self);
 
@@ -1049,7 +1049,7 @@ toshoboe_hard_xmit (struct sk_buff *skb, struct net_device *dev)
       if (self->txpending)
         {
 	  spin_unlock_irqrestore(&self->spinlock, flags);
-          return -EBUSY;
+          return NETDEV_TX_BUSY;
         }
 
       /* If in SIR mode we need to generate a string of XBOFs */
@@ -1105,7 +1105,7 @@ dumpbufs(skb->data,skb->len,'>');
           ,skb->len, self->ring->tx[self->txs].control, self->txpending);
       toshoboe_start_DMA(self, OBOE_CONFIG0H_ENTX);
       spin_unlock_irqrestore(&self->spinlock, flags);
-      return -EBUSY;
+      return NETDEV_TX_BUSY;
     }
 
   if (INB (OBOE_ENABLEH) & OBOE_ENABLEH_SIRON)
diff --git a/drivers/net/irda/irda-usb.c b/drivers/net/irda/irda-usb.c
index 394b2b1..0c0831c 100644
--- a/drivers/net/irda/irda-usb.c
+++ b/drivers/net/irda/irda-usb.c
@@ -389,7 +389,6 @@ static int irda_usb_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
 	s32 speed;
 	s16 xbofs;
 	int res, mtt;
-	int	err = 1;	/* Failed */
 
 	IRDA_DEBUG(4, "%s() on %s\n", __func__, netdev->name);
 
@@ -430,7 +429,6 @@ static int irda_usb_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
 			irda_usb_change_speed_xbofs(self);
 			netdev->trans_start = jiffies;
 			/* Will netif_wake_queue() in callback */
-			err = 0;	/* No error */
 			goto drop;
 		}
 	}
@@ -542,7 +540,7 @@ drop:
 	/* Drop silently the skb and exit */
 	dev_kfree_skb(skb);
 	spin_unlock_irqrestore(&self->lock, flags);
-	return err;		/* Usually 1 */
+	return NETDEV_TX_OK;
 }
 
 /*------------------------------------------------------------------*/
diff --git a/drivers/net/irda/kingsun-sir.c b/drivers/net/irda/kingsun-sir.c
index 9d813bc..c3e4e2c 100644
--- a/drivers/net/irda/kingsun-sir.c
+++ b/drivers/net/irda/kingsun-sir.c
@@ -156,9 +156,6 @@ static int kingsun_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
 	int wraplen;
 	int ret = 0;
 
-	if (skb == NULL || netdev == NULL)
-		return -EINVAL;
-
 	netif_stop_queue(netdev);
 
 	/* the IRDA wrapping routines don't deal with non linear skb */
@@ -197,7 +194,7 @@ static int kingsun_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
 	dev_kfree_skb(skb);
 	spin_unlock(&kingsun->lock);
 
-	return ret;
+	return NETDEV_TX_OK;
 }
 
 /* Receive callback function */
diff --git a/drivers/net/irda/ks959-sir.c b/drivers/net/irda/ks959-sir.c
index b6ffe97..d73b8b6 100644
--- a/drivers/net/irda/ks959-sir.c
+++ b/drivers/net/irda/ks959-sir.c
@@ -391,9 +391,6 @@ static int ks959_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
 	unsigned int wraplen;
 	int ret = 0;
 
-	if (skb == NULL || netdev == NULL)
-		return -EINVAL;
-
 	netif_stop_queue(netdev);
 
 	/* the IRDA wrapping routines don't deal with non linear skb */
@@ -428,7 +425,7 @@ static int ks959_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
 	dev_kfree_skb(skb);
 	spin_unlock(&kingsun->lock);
 
-	return ret;
+	return NETDEV_TX_OK;
 }
 
 /* Receive callback function */
diff --git a/drivers/net/irda/ksdazzle-sir.c b/drivers/net/irda/ksdazzle-sir.c
index 64df27f..1ef45ec 100644
--- a/drivers/net/irda/ksdazzle-sir.c
+++ b/drivers/net/irda/ksdazzle-sir.c
@@ -304,9 +304,6 @@ static int ksdazzle_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
 	unsigned int wraplen;
 	int ret = 0;
 
-	if (skb == NULL || netdev == NULL)
-		return -EINVAL;
-
 	netif_stop_queue(netdev);
 
 	/* the IRDA wrapping routines don't deal with non linear skb */
@@ -341,7 +338,7 @@ static int ksdazzle_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
 	dev_kfree_skb(skb);
 	spin_unlock(&kingsun->lock);
 
-	return ret;
+	return NETDEV_TX_OK;
 }
 
 /* Receive callback function */
diff --git a/drivers/net/irda/mcs7780.c b/drivers/net/irda/mcs7780.c
index fac504d..f4df100 100644
--- a/drivers/net/irda/mcs7780.c
+++ b/drivers/net/irda/mcs7780.c
@@ -824,10 +824,6 @@ static int mcs_hard_xmit(struct sk_buff *skb, struct net_device *ndev)
 	int wraplen;
 	int ret = 0;
 
-
-	if (skb == NULL || ndev == NULL)
-		return -EINVAL;
-
 	netif_stop_queue(ndev);
 	mcs = netdev_priv(ndev);
 
@@ -870,7 +866,7 @@ static int mcs_hard_xmit(struct sk_buff *skb, struct net_device *ndev)
 
 	dev_kfree_skb(skb);
 	spin_unlock_irqrestore(&mcs->lock, flags);
-	return ret;
+	return NETDEV_TX_OK;
 }
 
 static const struct net_device_ops mcs_netdev_ops = {

--------------010109080506030304020600--
