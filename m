From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 48/77] dlci: convert to net_device_ops
Date: Fri, 20 Mar 2009 22:36:15 -0700
Message-ID: <20090321053716.185935379@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36653 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761007AbZCUFsS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:18 -0400
Content-Disposition: inline; filename=dlci-netdev.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/wan/dlci.c	2009-03-20 16:39:20.344088959 -0700
+++ b/drivers/net/wan/dlci.c	2009-03-20 17:04:52.506777503 -0700
@@ -200,7 +200,7 @@ static int dlci_transmit(struct sk_buff 
 
 	netif_stop_queue(dev);
 	
-	ret = dlp->slave->hard_start_xmit(skb, dlp->slave);
+	ret = dlp->slave->netdev_ops->ndo_start_xmit(skb, dlp->slave);
 	switch (ret)
 	{
 		case DLCI_RET_OK:
@@ -295,11 +295,9 @@ static int dlci_dev_ioctl(struct net_dev
 
 static int dlci_change_mtu(struct net_device *dev, int new_mtu)
 {
-	struct dlci_local *dlp;
-
-	dlp = netdev_priv(dev);
+	struct dlci_local *dlp = netdev_priv(dev);
 
-	return((*dlp->slave->change_mtu)(dlp->slave, new_mtu));
+	return dev_set_mtu(dlp->slave, new_mtu);
 }
 
 static int dlci_open(struct net_device *dev)
@@ -479,17 +477,21 @@ static const struct header_ops dlci_head
 	.create	= dlci_header,
 };
 
+static const struct net_device_ops dlci_netdev_ops = {
+	.ndo_open	= dlci_open,
+	.ndo_stop	= dlci_close,
+	.ndo_do_ioctl	= dlci_dev_ioctl,
+	.ndo_start_xmit	= dlci_transmit,
+	.ndo_change_mtu	= dlci_change_mtu,
+};
+
 static void dlci_setup(struct net_device *dev)
 {
 	struct dlci_local *dlp = netdev_priv(dev);
 
 	dev->flags		= 0;
-	dev->open		= dlci_open;
-	dev->stop		= dlci_close;
-	dev->do_ioctl		= dlci_dev_ioctl;
-	dev->hard_start_xmit	= dlci_transmit;
 	dev->header_ops		= &dlci_header_ops;
-	dev->change_mtu		= dlci_change_mtu;
+	dev->netdev_ops		= &dlci_netdev_ops;
 	dev->destructor		= free_netdev;
 
 	dlp->receive		= dlci_receive;

-- 

