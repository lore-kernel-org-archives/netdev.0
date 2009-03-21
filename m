From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 59/77] airo: convert to net_device_ops
Date: Fri, 20 Mar 2009 22:36:26 -0700
Message-ID: <20090321053717.048069302@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36680 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761067AbZCUFsV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:21 -0400
Content-Disposition: inline; filename=airo.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/wireless/airo.c	2009-03-20 22:14:19.396839469 -0700
+++ b/drivers/net/wireless/airo.c	2009-03-20 22:25:53.106714188 -0700
@@ -2646,17 +2646,21 @@ static const struct header_ops airo_head
 	.parse = wll_header_parse,
 };
 
+static const struct net_device_ops airo11_netdev_ops = {
+	.ndo_open 		= airo_open,
+	.ndo_stop 		= airo_close,
+	.ndo_start_xmit 	= airo_start_xmit11,
+	.ndo_get_stats 		= airo_get_stats,
+	.ndo_set_mac_address	= airo_set_mac_address,
+	.ndo_do_ioctl		= airo_ioctl,
+	.ndo_change_mtu		= airo_change_mtu,
+};
+
 static void wifi_setup(struct net_device *dev)
 {
+	dev->netdev_ops = &airo11_netdev_ops;
 	dev->header_ops = &airo_header_ops;
-	dev->hard_start_xmit = &airo_start_xmit11;
-	dev->get_stats = &airo_get_stats;
-	dev->set_mac_address = &airo_set_mac_address;
-	dev->do_ioctl = &airo_ioctl;
 	dev->wireless_handlers = &airo_handler_def;
-	dev->change_mtu = &airo_change_mtu;
-	dev->open = &airo_open;
-	dev->stop = &airo_close;
 
 	dev->type               = ARPHRD_IEEE80211;
 	dev->hard_header_len    = ETH_HLEN;
@@ -2739,6 +2743,33 @@ static void airo_networks_initialize(str
 			      &ai->network_free_list);
 }
 
+static const struct net_device_ops airo_netdev_ops = {
+	.ndo_open		= airo_open,
+	.ndo_stop		= airo_close,
+	.ndo_start_xmit		= airo_start_xmit,
+	.ndo_get_stats		= airo_get_stats,
+	.ndo_set_multicast_list	= airo_set_multicast_list,
+	.ndo_set_mac_address	= airo_set_mac_address,
+	.ndo_do_ioctl		= airo_ioctl,
+	.ndo_change_mtu		= airo_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
+static const struct net_device_ops mpi_netdev_ops = {
+	.ndo_open		= airo_open,
+	.ndo_stop		= airo_close,
+	.ndo_start_xmit		= mpi_start_xmit,
+	.ndo_get_stats		= airo_get_stats,
+	.ndo_set_multicast_list	= airo_set_multicast_list,
+	.ndo_set_mac_address	= airo_set_mac_address,
+	.ndo_do_ioctl		= airo_ioctl,
+	.ndo_change_mtu		= airo_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
+
 static struct net_device *_init_airo_card( unsigned short irq, int port,
 					   int is_pcmcia, struct pci_dev *pci,
 					   struct device *dmdev )
@@ -2776,22 +2807,16 @@ static struct net_device *_init_airo_car
 		goto err_out_free;
 	airo_networks_initialize (ai);
 
+	skb_queue_head_init (&ai->txq);
+
 	/* The Airo-specific entries in the device structure. */
-	if (test_bit(FLAG_MPI,&ai->flags)) {
-		skb_queue_head_init (&ai->txq);
-		dev->hard_start_xmit = &mpi_start_xmit;
-	} else
-		dev->hard_start_xmit = &airo_start_xmit;
-	dev->get_stats = &airo_get_stats;
-	dev->set_multicast_list = &airo_set_multicast_list;
-	dev->set_mac_address = &airo_set_mac_address;
-	dev->do_ioctl = &airo_ioctl;
+	if (test_bit(FLAG_MPI,&ai->flags))
+		dev->netdev_ops = &mpi_netdev_ops;
+	else
+		dev->netdev_ops = &airo_netdev_ops;
 	dev->wireless_handlers = &airo_handler_def;
 	ai->wireless_data.spy_data = &ai->spy_data;
 	dev->wireless_data = &ai->wireless_data;
-	dev->change_mtu = &airo_change_mtu;
-	dev->open = &airo_open;
-	dev->stop = &airo_close;
 	dev->irq = irq;
 	dev->base_addr = port;
 

-- 

