From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 02/22] s2io: convert to net_device_ops
Date: Fri, 21 Nov 2008 15:21:40 -0800
Message-ID: <20081121232239.063451634@vyatta.com>
References: <20081121232138.343333942@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:57002 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753256AbYKUXXO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 18:23:14 -0500
Content-Disposition: inline; filename=s2io-netdev_ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert this driver to network device ops. Compile teseted only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/s2io.c	2008-11-20 21:29:12.000000000 -0800
+++ b/drivers/net/s2io.c	2008-11-20 22:05:30.000000000 -0800
@@ -352,9 +352,10 @@ static void do_s2io_copy_mac_addr(struct
 	sp->def_mac_addr[offset].mac_addr[1] = (u8) (mac_addr >> 32);
 	sp->def_mac_addr[offset].mac_addr[0] = (u8) (mac_addr >> 40);
 }
+
 /* Add the vlan */
 static void s2io_vlan_rx_register(struct net_device *dev,
-					struct vlan_group *grp)
+				  struct vlan_group *grp)
 {
 	int i;
 	struct s2io_nic *nic = netdev_priv(dev);
@@ -372,7 +373,7 @@ static void s2io_vlan_rx_register(struct
 }
 
 /* Unregister the vlan */
-static void s2io_vlan_rx_kill_vid(struct net_device *dev, unsigned long vid)
+static void s2io_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
 {
 	int i;
 	struct s2io_nic *nic = netdev_priv(dev);
@@ -7717,6 +7718,24 @@ static int rts_ds_steer(struct s2io_nic 
 				S2IO_BIT_RESET);
 }
 
+static const struct net_device_ops s2io_netdev_ops = {
+	.ndo_open	        = s2io_open,
+	.ndo_stop	        = s2io_close,
+	.ndo_get_stats	        = s2io_get_stats,
+	.ndo_start_xmit    	= s2io_xmit,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_multicast_list = s2io_set_multicast,
+	.ndo_do_ioctl	   	= s2io_ioctl,
+	.ndo_set_mac_address    = s2io_set_mac_addr,
+	.ndo_change_mtu	   	= s2io_change_mtu,
+	.ndo_vlan_rx_register   = s2io_vlan_rx_register,
+	.ndo_vlan_rx_kill_vid   = s2io_vlan_rx_kill_vid,
+	.ndo_tx_timeout	   	= s2io_tx_watchdog,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller    = s2io_netpoll,
+#endif
+};
+
 /**
  *  s2io_init_nic - Initialization of the adapter .
  *  @pdev : structure containing the PCI related information of the device.
@@ -7942,26 +7961,9 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	}
 
 	/*  Driver entry points */
-	dev->open = &s2io_open;
-	dev->stop = &s2io_close;
-	dev->hard_start_xmit = &s2io_xmit;
-	dev->get_stats = &s2io_get_stats;
-	dev->set_multicast_list = &s2io_set_multicast;
-	dev->do_ioctl = &s2io_ioctl;
-	dev->set_mac_address = &s2io_set_mac_addr;
-	dev->change_mtu = &s2io_change_mtu;
+	dev->netdev_ops = &s2io_netdev_ops;
 	SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-	dev->vlan_rx_register = s2io_vlan_rx_register;
-	dev->vlan_rx_kill_vid = (void *)s2io_vlan_rx_kill_vid;
-
-	/*
-	 * will use eth_mac_addr() for  dev->set_mac_address
-	 * mac address will be set every time dev->open() is called
-	 */
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = s2io_netpoll;
-#endif
 
 	dev->features |= NETIF_F_SG | NETIF_F_IP_CSUM;
 	if (sp->high_dma_flag == TRUE)
@@ -7972,7 +7974,6 @@ s2io_init_nic(struct pci_dev *pdev, cons
 		dev->features |= NETIF_F_UFO;
 		dev->features |= NETIF_F_HW_CSUM;
 	}
-	dev->tx_timeout = &s2io_tx_watchdog;
 	dev->watchdog_timeo = WATCH_DOG_TIMEOUT;
 	INIT_WORK(&sp->rst_timer_task, s2io_restart_nic);
 	INIT_WORK(&sp->set_link_task, s2io_set_link);

-- 

