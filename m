From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: [PATCH] am79c961a: use netstats in net_device structure
Date: Tue, 06 May 2008 00:28:52 +0300
Message-ID: <481F7C14.7040909@teltonika.lt>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030504040402070405000005"
Cc: linux-arm-kernel@lists.arm.linux.org.uk
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:37925 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757045AbYEEVaF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 May 2008 17:30:05 -0400
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1Jt8G2-0004OC-F1
	for netdev@vger.kernel.org; Mon, 05 May 2008 21:30:02 +0000
Received: from 78-62-85-225.static.zebra.lt ([78.62.85.225])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 05 May 2008 21:30:02 +0000
Received: from paulius.zaleckas by 78-62-85-225.static.zebra.lt with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 05 May 2008 21:30:02 +0000
Cc: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030504040402070405000005
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Use net_device_stats from net_device structure instead of local.
Kill am79c961_getstats function, because by default it is used
identical internal_stats function from net/core/dev.c
Don't clear statistics when opening device.

Haven't tried to compile it. Need ack from ARM people!

Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>

--------------030504040402070405000005
Content-Type: text/x-patch;
 name="am79c961a_netstats.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="am79c961a_netstats.patch"

diff --git a/drivers/net/arm/am79c961a.c b/drivers/net/arm/am79c961a.c
index a637910..d5ec2fc 100644
--- a/drivers/net/arm/am79c961a.c
+++ b/drivers/net/arm/am79c961a.c
@@ -300,8 +300,6 @@ am79c961_open(struct net_device *dev)
 	struct dev_priv *priv = netdev_priv(dev);
 	int ret;
 
-	memset (&priv->stats, 0, sizeof (priv->stats));
-
 	ret = request_irq(dev->irq, am79c961_interrupt, 0, dev->name, dev);
 	if (ret)
 		return ret;
@@ -342,15 +340,6 @@ am79c961_close(struct net_device *dev)
 	return 0;
 }
 
-/*
- * Get the current statistics.
- */
-static struct net_device_stats *am79c961_getstats (struct net_device *dev)
-{
-	struct dev_priv *priv = netdev_priv(dev);
-	return &priv->stats;
-}
-
 static void am79c961_mc_hash(struct dev_mc_list *dmi, unsigned short *hash)
 {
 	if (dmi->dmi_addrlen == ETH_ALEN && dmi->dmi_addr[0] & 0x01) {
@@ -511,14 +500,14 @@ am79c961_rx(struct net_device *dev, struct dev_priv *priv)
 
 		if ((status & (RMD_ERR|RMD_STP|RMD_ENP)) != (RMD_STP|RMD_ENP)) {
 			am_writeword (dev, hdraddr + 2, RMD_OWN);
-			priv->stats.rx_errors ++;
+			dev->stats.rx_errors ++;
 			if (status & RMD_ERR) {
 				if (status & RMD_FRAM)
-					priv->stats.rx_frame_errors ++;
+					dev->stats.rx_frame_errors ++;
 				if (status & RMD_CRC)
-					priv->stats.rx_crc_errors ++;
+					dev->stats.rx_crc_errors ++;
 			} else if (status & RMD_STP)
-				priv->stats.rx_length_errors ++;
+				dev->stats.rx_length_errors ++;
 			continue;
 		}
 
@@ -533,12 +522,12 @@ am79c961_rx(struct net_device *dev, struct dev_priv *priv)
 			skb->protocol = eth_type_trans(skb, dev);
 			netif_rx(skb);
 			dev->last_rx = jiffies;
-			priv->stats.rx_bytes += len;
-			priv->stats.rx_packets ++;
+			dev->stats.rx_bytes += len;
+			dev->stats.rx_packets ++;
 		} else {
 			am_writeword (dev, hdraddr + 2, RMD_OWN);
 			printk (KERN_WARNING "%s: memory squeeze, dropping packet.\n", dev->name);
-			priv->stats.rx_dropped ++;
+			dev->stats.rx_dropped ++;
 			break;
 		}
 	} while (1);
@@ -567,7 +556,7 @@ am79c961_tx(struct net_device *dev, struct dev_priv *priv)
 		if (status & TMD_ERR) {
 			u_int status2;
 
-			priv->stats.tx_errors ++;
+			dev->stats.tx_errors ++;
 
 			status2 = am_readword (dev, hdraddr + 6);
 
@@ -577,18 +566,18 @@ am79c961_tx(struct net_device *dev, struct dev_priv *priv)
 			am_writeword (dev, hdraddr + 6, 0);
 
 			if (status2 & TST_RTRY)
-				priv->stats.collisions += 16;
+				dev->stats.collisions += 16;
 			if (status2 & TST_LCOL)
-				priv->stats.tx_window_errors ++;
+				dev->stats.tx_window_errors ++;
 			if (status2 & TST_LCAR)
-				priv->stats.tx_carrier_errors ++;
+				dev->stats.tx_carrier_errors ++;
 			if (status2 & TST_UFLO)
-				priv->stats.tx_fifo_errors ++;
+				dev->stats.tx_fifo_errors ++;
 			continue;
 		}
-		priv->stats.tx_packets ++;
+		dev->stats.tx_packets ++;
 		len = am_readword (dev, hdraddr + 4);
-		priv->stats.tx_bytes += -len;
+		dev->stats.tx_bytes += -len;
 	} while (priv->txtail != priv->txhead);
 
 	netif_wake_queue(dev);
@@ -618,7 +607,7 @@ am79c961_interrupt(int irq, void *dev_id)
 		}
 		if (status & CSR0_MISS) {
 			handled = 1;
-			priv->stats.rx_dropped ++;
+			dev->stats.rx_dropped ++;
 		}
 		if (status & CSR0_CERR) {
 			handled = 1;
@@ -736,7 +725,6 @@ static int __init am79c961_probe(struct platform_device *pdev)
 	dev->open		= am79c961_open;
 	dev->stop		= am79c961_close;
 	dev->hard_start_xmit	= am79c961_sendpacket;
-	dev->get_stats		= am79c961_getstats;
 	dev->set_multicast_list	= am79c961_setmulticastlist;
 	dev->tx_timeout		= am79c961_timeout;
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/arm/am79c961a.h b/drivers/net/arm/am79c961a.h
index 483009f..fd634d3 100644
--- a/drivers/net/arm/am79c961a.h
+++ b/drivers/net/arm/am79c961a.h
@@ -130,7 +130,6 @@
 #define ISALED0_LNKST	0x8000
 
 struct dev_priv {
-    struct net_device_stats stats;
     unsigned long	rxbuffer[RX_BUFFERS];
     unsigned long	txbuffer[TX_BUFFERS];
     unsigned char	txhead;

--------------030504040402070405000005--

