From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 11/30] wan: convert sdla driver to net_device_ops
Date: Thu, 26 Mar 2009 18:11:25 -0700
Message-ID: <20090327011255.745791643@linux-foundation.org>
References: <20090327011114.169107105@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:43181 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756140AbZC0B1I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2009 21:27:08 -0400
Content-Disposition: inline; filename=sdla-netdev.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also use internal net_device_stats

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/wan/sdla.c	2009-03-21 12:37:00.000000000 -0700
+++ b/drivers/net/wan/sdla.c	2009-03-26 15:40:26.996589787 -0700
@@ -714,19 +714,19 @@ static int sdla_transmit(struct sk_buff 
 		switch (ret)
 		{
 			case SDLA_RET_OK:
-				flp->stats.tx_packets++;
+				dev->stats.tx_packets++;
 				ret = DLCI_RET_OK;
 				break;
 
 			case SDLA_RET_CIR_OVERFLOW:
 			case SDLA_RET_BUF_OVERSIZE:
 			case SDLA_RET_NO_BUFS:
-				flp->stats.tx_dropped++;
+				dev->stats.tx_dropped++;
 				ret = DLCI_RET_DROP;
 				break;
 
 			default:
-				flp->stats.tx_errors++;
+				dev->stats.tx_errors++;
 				ret = DLCI_RET_ERR;
 				break;
 		}
@@ -807,7 +807,7 @@ static void sdla_receive(struct net_devi
 		if (i == CONFIG_DLCI_MAX)
 		{
 			printk(KERN_NOTICE "%s: Received packet from invalid DLCI %i, ignoring.", dev->name, dlci);
-			flp->stats.rx_errors++;
+			dev->stats.rx_errors++;
 			success = 0;
 		}
 	}
@@ -819,7 +819,7 @@ static void sdla_receive(struct net_devi
 		if (skb == NULL) 
 		{
 			printk(KERN_NOTICE "%s: Memory squeeze, dropping packet.\n", dev->name);
-			flp->stats.rx_dropped++; 
+			dev->stats.rx_dropped++;
 			success = 0;
 		}
 		else
@@ -859,7 +859,7 @@ static void sdla_receive(struct net_devi
 
 	if (success)
 	{
-		flp->stats.rx_packets++;
+		dev->stats.rx_packets++;
 		dlp = netdev_priv(master);
 		(*dlp->receive)(skb, master);
 	}
@@ -1590,13 +1590,14 @@ fail:
 	return err;
 }
  
-static struct net_device_stats *sdla_stats(struct net_device *dev)
-{
-	struct frad_local *flp;
-	flp = netdev_priv(dev);
-
-	return(&flp->stats);
-}
+static const struct net_device_ops sdla_netdev_ops = {
+	.ndo_open	= sdla_open,
+	.ndo_stop	= sdla_close,
+	.ndo_do_ioctl	= sdla_ioctl,
+	.ndo_set_config	= sdla_set_config,
+	.ndo_start_xmit	= sdla_transmit,
+	.ndo_change_mtu	= sdla_change_mtu,
+};
 
 static void setup_sdla(struct net_device *dev)
 {
@@ -1604,20 +1605,13 @@ static void setup_sdla(struct net_device
 
 	netdev_boot_setup_check(dev);
 
+	dev->netdev_ops		= &sdla_netdev_ops;
 	dev->flags		= 0;
 	dev->type		= 0xFFFF;
 	dev->hard_header_len	= 0;
 	dev->addr_len		= 0;
 	dev->mtu		= SDLA_MAX_MTU;
 
-	dev->open		= sdla_open;
-	dev->stop		= sdla_close;
-	dev->do_ioctl		= sdla_ioctl;
-	dev->set_config		= sdla_set_config;
-	dev->get_stats		= sdla_stats;
-	dev->hard_start_xmit	= sdla_transmit;
-	dev->change_mtu		= sdla_change_mtu;
-
 	flp->activate		= sdla_activate;
 	flp->deactivate		= sdla_deactivate;
 	flp->assoc		= sdla_assoc;
--- a/include/linux/if_frad.h	2009-03-21 12:37:09.000000000 -0700
+++ b/include/linux/if_frad.h	2009-03-26 15:37:38.067344521 -0700
@@ -153,7 +153,6 @@ struct frhdr
 
 struct dlci_local
 {
-   struct net_device_stats stats;
    struct net_device      *master;
    struct net_device      *slave;
    struct dlci_conf       config;


