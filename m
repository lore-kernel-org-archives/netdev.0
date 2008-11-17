From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 14/33] sky2: convert to net_device_ops
Date: Mon, 17 Nov 2008 15:42:21 -0800
Message-ID: <20081117234355.977815463@vyatta.com>
References: <20081117234207.854110282@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:55072 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752170AbYKRAAI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 19:00:08 -0500
Content-Disposition: inline; filename=sky2-netdev_ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert to new network device ops interface. Slight additional complexity
here because the second port does not allow netpoll and therefore has
different virtual function table.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sky2.c	2008-11-02 09:48:53.000000000 -0800
+++ b/drivers/net/sky2.c	2008-11-02 10:06:05.000000000 -0800
@@ -3979,7 +3979,7 @@ static int sky2_device_event(struct noti
 	struct net_device *dev = ptr;
 	struct sky2_port *sky2 = netdev_priv(dev);
 
-	if (dev->open != sky2_up || !sky2_debug)
+	if (dev->netdev_ops->open != sky2_up || !sky2_debug)
 		return NOTIFY_DONE;
 
 	switch(event) {
@@ -4041,6 +4041,35 @@ static __exit void sky2_debug_cleanup(vo
 #define sky2_debug_cleanup()
 #endif
 
+/* Two copies of network device operations to handle special case of
+   not allowing netpoll on second port */
+static const struct net_device_ops sky2_netdev_ops[2] = {
+  {
+	.open		= sky2_up,
+	.stop		= sky2_down,
+	.do_ioctl	= sky2_ioctl,
+	.validate_addr	= eth_validate_addr,
+	.set_mac_address = sky2_set_mac_address,
+	.set_multicast_list = sky2_set_multicast,
+	.change_mtu	= sky2_change_mtu,
+	.tx_timeout	= sky2_tx_timeout,
+	.vlan_rx_register = sky2_vlan_rx_register,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.poll_controller = sky2_netpoll,
+#endif
+  },
+  {
+	.open		= sky2_up,
+	.stop		= sky2_down,
+	.do_ioctl	= sky2_ioctl,
+	.validate_addr	= eth_validate_addr,
+	.set_mac_address = sky2_set_mac_address,
+	.set_multicast_list = sky2_set_multicast,
+	.change_mtu	= sky2_change_mtu,
+	.tx_timeout	= sky2_tx_timeout,
+	.vlan_rx_register = sky2_vlan_rx_register,
+  },
+};
 
 /* Initialize network device */
 static __devinit struct net_device *sky2_init_netdev(struct sky2_hw *hw,
@@ -4057,20 +4086,10 @@ static __devinit struct net_device *sky2
 
 	SET_NETDEV_DEV(dev, &hw->pdev->dev);
 	dev->irq = hw->pdev->irq;
-	dev->open = sky2_up;
-	dev->stop = sky2_down;
-	dev->do_ioctl = sky2_ioctl;
 	dev->hard_start_xmit = sky2_xmit_frame;
-	dev->set_multicast_list = sky2_set_multicast;
-	dev->set_mac_address = sky2_set_mac_address;
-	dev->change_mtu = sky2_change_mtu;
 	SET_ETHTOOL_OPS(dev, &sky2_ethtool_ops);
-	dev->tx_timeout = sky2_tx_timeout;
 	dev->watchdog_timeo = TX_WATCHDOG;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	if (port == 0)
-		dev->poll_controller = sky2_netpoll;
-#endif
+	dev->netdev_ops = &sky2_netdev_ops[port];
 
 	sky2 = netdev_priv(dev);
 	sky2->netdev = dev;
@@ -4104,7 +4123,6 @@ static __devinit struct net_device *sky2
 	if (!(sky2->hw->chip_id == CHIP_ID_YUKON_FE_P &&
 	      sky2->hw->chip_rev == CHIP_REV_YU_FE2_A0)) {
 		dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-		dev->vlan_rx_register = sky2_vlan_rx_register;
 	}
 #endif
 

-- 

