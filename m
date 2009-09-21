From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: [PATCH  kernel 2.6.31-git9] 3c574_cs: spin_lock the
 set_multicast_list function
Date: Mon, 21 Sep 2009 13:10:23 +0900
Message-ID: <20090921131023.8cee3084.ken_kawasaki@spring.nifty.jp>
References: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
	<20090419084444.4ee7ddee.ken_kawasaki@spring.nifty.jp>
	<20090426162929.3d036f26.ken_kawasaki@spring.nifty.jp>
	<20090913072203.d92f1734.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userg502.nifty.com ([202.248.238.82]:46067 "EHLO
	userg502.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750783AbZIUEKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2009 00:10:33 -0400
Received: from localhost.localdomain (eaoska170164.adsl.ppp.infoweb.ne.jp [219.116.19.164])by userg502.nifty.com with SMTP id n8L4APpf018178
	for <netdev@vger.kernel.org>; Mon, 21 Sep 2009 13:10:25 +0900
In-Reply-To: <20090913072203.d92f1734.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


3c574_cs:
 spin_lock the set_multicast_list,
 and clean up the set_rx_mode function.

Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

---
  
--- linux-2.6.31-git9.orig/drivers/net/pcmcia/3c574_cs.c	2009-09-20 06:53:31.000000000 +0900
+++ linux-2.6.31-git9/drivers/net/pcmcia/3c574_cs.c	2009-09-20 07:03:39.000000000 +0900
@@ -251,6 +251,7 @@ static void el3_tx_timeout(struct net_de
 static int el3_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 static const struct ethtool_ops netdev_ethtool_ops;
 static void set_rx_mode(struct net_device *dev);
+static void set_multicast_list(struct net_device *dev);
 
 static void tc574_detach(struct pcmcia_device *p_dev);
 
@@ -266,7 +267,7 @@ static const struct net_device_ops el3_n
 	.ndo_tx_timeout 	= el3_tx_timeout,
 	.ndo_get_stats		= el3_get_stats,
 	.ndo_do_ioctl		= el3_ioctl,
-	.ndo_set_multicast_list = set_rx_mode,
+	.ndo_set_multicast_list = set_multicast_list,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
@@ -1153,12 +1154,23 @@ static void set_rx_mode(struct net_devic
 	unsigned int ioaddr = dev->base_addr;
 
 	if (dev->flags & IFF_PROMISC)
-		outw(SetRxFilter | RxStation | RxMulticast | RxBroadcast | RxProm,
-			 ioaddr + EL3_CMD);
+		outw(SetRxFilter|RxStation|RxMulticast|RxBroadcast|RxProm,
+			ioaddr + EL3_CMD);
 	else if (dev->mc_count || (dev->flags & IFF_ALLMULTI))
-		outw(SetRxFilter|RxStation|RxMulticast|RxBroadcast, ioaddr + EL3_CMD);
+		outw(SetRxFilter|RxStation|RxMulticast|RxBroadcast,
+			ioaddr + EL3_CMD);
 	else
-		outw(SetRxFilter | RxStation | RxBroadcast, ioaddr + EL3_CMD);
+		outw(SetRxFilter|RxStation|RxBroadcast, ioaddr + EL3_CMD);
+}
+
+static void set_multicast_list(struct net_device *dev)
+{
+	struct el3_private *lp = netdev_priv(dev);
+	unsigned long flags;
+
+	spin_lock_irqsave(&lp->window_lock, flags);
+	set_rx_mode(dev);
+	spin_unlock_irqrestore(&lp->window_lock, flags);
 }
 
 static int el3_close(struct net_device *dev)
