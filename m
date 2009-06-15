From: Patrick McHardy <kaber@trash.net>
Subject: net: fix network drivers ndo_start_xmit() return values
Date: Mon, 15 Jun 2009 19:00:04 +0200
Message-ID: <4A367E14.4040104@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000203020802060302080208"
Cc: Linux Netdev List <netdev@vger.kernel.org>, perex@perex.cz
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46683 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752108AbZFORAG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2009 13:00:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000203020802060302080208
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

This patch contains the final driver ndo_start_xmit() return
value fixups. I'm pretty sure I got them all ...

Please let me know whether you still want me to submit the
remaining patches or whether I should wait until the -next
tree is opened up again.




--------------000203020802060302080208
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

commit fbc7a709feec3792247fb8596ac3d91a6d2c9ecc
Author: Patrick McHardy <kaber@trash.net>
Date:   Mon Jun 15 18:55:45 2009 +0200

    net: fix network drivers ndo_start_xmit() return values
    
    Fix up remaining drivers returning a magic or an errno value from their
    ndo_start_xmit() functions that were missed in the first pass:
    
    - isdn_net: missed conversion
    - bpqether: missed conversion: skb is freed, so return NETDEV_TX_OK
    - hp100: intention appears to be to resubmit skb once resources are
      available, but due to no queue handling it is dropped for now.
    - lapbether: skb is freed, so return NETDEV_TX_OK
    
    Compile tested only.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/drivers/isdn/i4l/isdn_net.c b/drivers/isdn/i4l/isdn_net.c
index 34d54e7..de4aad0 100644
--- a/drivers/isdn/i4l/isdn_net.c
+++ b/drivers/isdn/i4l/isdn_net.c
@@ -1300,7 +1300,7 @@ isdn_net_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 				netif_stop_queue(ndev);
 		}
 	}
-	return 1;
+	return NETDEV_TX_BUSY;
 }
 
 /*
diff --git a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
index 5105548..abcd19a 100644
--- a/drivers/net/hamradio/bpqether.c
+++ b/drivers/net/hamradio/bpqether.c
@@ -260,7 +260,7 @@ static int bpq_xmit(struct sk_buff *skb, struct net_device *dev)
 	 */
 	if (!netif_running(dev)) {
 		kfree_skb(skb);
-		return -ENODEV;
+		return NETDEV_TX_OK;
 	}
 
 	skb_pull(skb, 1);
diff --git a/drivers/net/hp100.c b/drivers/net/hp100.c
index 8feda9f..1d3429a 100644
--- a/drivers/net/hp100.c
+++ b/drivers/net/hp100.c
@@ -1495,13 +1495,8 @@ static int hp100_start_xmit_bm(struct sk_buff *skb, struct net_device *dev)
 	hp100_outw(0x4210, TRACE);
 	printk("hp100: %s: start_xmit_bm\n", dev->name);
 #endif
-
-	if (skb == NULL) {
-		return 0;
-	}
-
 	if (skb->len <= 0)
-		return 0;
+		goto drop;
 
 	if (lp->chip == HP100_CHIPID_SHASTA && skb_padto(skb, ETH_ZLEN))
 		return 0;
@@ -1514,10 +1509,10 @@ static int hp100_start_xmit_bm(struct sk_buff *skb, struct net_device *dev)
 #endif
 		/* not waited long enough since last tx? */
 		if (time_before(jiffies, dev->trans_start + HZ))
-			return -EAGAIN;
+			goto drop;
 
 		if (hp100_check_lan(dev))
-			return -EIO;
+			goto drop;
 
 		if (lp->lan_type == HP100_LAN_100 && lp->hub_status < 0) {
 			/* we have a 100Mb/s adapter but it isn't connected to hub */
@@ -1551,7 +1546,7 @@ static int hp100_start_xmit_bm(struct sk_buff *skb, struct net_device *dev)
 		}
 
 		dev->trans_start = jiffies;
-		return -EAGAIN;
+		goto drop;
 	}
 
 	/*
@@ -1591,6 +1586,10 @@ static int hp100_start_xmit_bm(struct sk_buff *skb, struct net_device *dev)
 	dev->trans_start = jiffies;
 
 	return 0;
+
+drop:
+	dev_kfree_skb(skb);
+	return NETDEV_TX_OK;
 }
 
 
@@ -1648,16 +1647,11 @@ static int hp100_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	hp100_outw(0x4212, TRACE);
 	printk("hp100: %s: start_xmit\n", dev->name);
 #endif
-
-	if (skb == NULL) {
-		return 0;
-	}
-
 	if (skb->len <= 0)
-		return 0;
+		goto drop;
 
 	if (hp100_check_lan(dev))
-		return -EIO;
+		goto drop;
 
 	/* If there is not enough free memory on the card... */
 	i = hp100_inl(TX_MEM_FREE) & 0x7fffffff;
@@ -1671,7 +1665,7 @@ static int hp100_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			printk("hp100: %s: trans_start timing problem\n",
 			       dev->name);
 #endif
-			return -EAGAIN;
+			goto drop;
 		}
 		if (lp->lan_type == HP100_LAN_100 && lp->hub_status < 0) {
 			/* we have a 100Mb/s adapter but it isn't connected to hub */
@@ -1705,7 +1699,7 @@ static int hp100_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			}
 		}
 		dev->trans_start = jiffies;
-		return -EAGAIN;
+		goto drop;
 	}
 
 	for (i = 0; i < 6000 && (hp100_inb(OPTION_MSW) & HP100_TX_CMD); i++) {
@@ -1759,6 +1753,11 @@ static int hp100_start_xmit(struct sk_buff *skb, struct net_device *dev)
 #endif
 
 	return 0;
+
+drop:
+	dev_kfree_skb(skb);
+	return NETDEV_TX_OK;
+
 }
 
 
diff --git a/drivers/net/wan/lapbether.c b/drivers/net/wan/lapbether.c
index 2dd78d2..1907939 100644
--- a/drivers/net/wan/lapbether.c
+++ b/drivers/net/wan/lapbether.c
@@ -149,46 +149,42 @@ static int lapbeth_data_indication(struct net_device *dev, struct sk_buff *skb)
  */
 static int lapbeth_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	int err = -ENODEV;
+	int err;
 
 	/*
 	 * Just to be *really* sure not to send anything if the interface
 	 * is down, the ethernet device may have gone.
 	 */
 	if (!netif_running(dev)) {
+		// XXX
 		goto drop;
 	}
 
 	switch (skb->data[0]) {
 	case 0x00:
-		err = 0;
 		break;
 	case 0x01:
 		if ((err = lapb_connect_request(dev)) != LAPB_OK)
 			printk(KERN_ERR "lapbeth: lapb_connect_request "
 			       "error: %d\n", err);
-		goto drop_ok;
+		goto drop;
 	case 0x02:
 		if ((err = lapb_disconnect_request(dev)) != LAPB_OK)
 			printk(KERN_ERR "lapbeth: lapb_disconnect_request "
 			       "err: %d\n", err);
 		/* Fall thru */
 	default:
-		goto drop_ok;
+		goto drop;
 	}
 
 	skb_pull(skb, 1);
 
 	if ((err = lapb_data_request(dev, skb)) != LAPB_OK) {
 		printk(KERN_ERR "lapbeth: lapb_data_request error - %d\n", err);
-		err = -ENOMEM;
 		goto drop;
 	}
-	err = 0;
 out:
-	return err;
-drop_ok:
-	err = 0;
+	return NETDEV_TX_OK;
 drop:
 	kfree_skb(skb);
 	goto out;

--------------000203020802060302080208--
