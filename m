From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 16/33] r8169: convert to net_device_ops
Date: Mon, 17 Nov 2008 15:42:23 -0800
Message-ID: <20081117234356.157757873@vyatta.com>
References: <20081117234207.854110282@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:55078 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752193AbYKRAAJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 19:00:09 -0500
Content-Disposition: inline; filename=r8169-netdev_ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert to new network device ops interface. In this case needed
to match behaviour of old code which only allowed ioctl on some
device types.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/r8169.c	2008-11-17 11:34:07.000000000 -0800
+++ b/drivers/net/r8169.c	2008-11-17 11:46:31.000000000 -0800
@@ -1832,6 +1832,9 @@ static int rtl8169_ioctl(struct net_devi
 	if (!netif_running(dev))
 		return -ENODEV;
 
+	if (tp->get_settings != rtl8169_gset_xmii)
+		return -EOPNOTSUPP;
+
 	switch (cmd) {
 	case SIOCGMIIPHY:
 		data->phy_id = 32; /* Internal PHY */
@@ -1915,6 +1918,23 @@ static void rtl_disable_msi(struct pci_d
 	}
 }
 
+static const struct net_device_ops rtl8169_netdev_ops = {
+	.open			= rtl8169_open,
+	.stop			= rtl8169_close,
+	.get_stats		= rtl8169_get_stats,
+	.tx_timeout		= rtl8169_tx_timeout,
+	.validate_addr		= eth_validate_addr,
+	.change_mtu		= rtl8169_change_mtu,
+	.set_mac_address	= rtl_set_mac_address,
+	.do_ioctl		= rtl8169_ioctl,
+	.set_multicast_list	= rtl_set_rx_mode,
+	.vlan_rx_register	= rtl8169_vlan_rx_register,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.poll_controller	= rtl8169_netpoll,
+#endif
+
+};
+
 static int __devinit
 rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
@@ -1941,6 +1961,7 @@ rtl8169_init_one(struct pci_dev *pdev, c
 	}
 
 	SET_NETDEV_DEV(dev, &pdev->dev);
+	dev->netdev_ops = &rtl8169_netdev_ops;
 	tp = netdev_priv(dev);
 	tp->dev = dev;
 	tp->pci_dev = pdev;
@@ -2084,8 +2105,6 @@ rtl8169_init_one(struct pci_dev *pdev, c
 		tp->phy_reset_enable = rtl8169_xmii_reset_enable;
 		tp->phy_reset_pending = rtl8169_xmii_reset_pending;
 		tp->link_ok = rtl8169_xmii_link_ok;
-
-		dev->do_ioctl = rtl8169_ioctl;
 	}
 
 	spin_lock_init(&tp->lock);
@@ -2097,28 +2116,16 @@ rtl8169_init_one(struct pci_dev *pdev, c
 		dev->dev_addr[i] = RTL_R8(MAC0 + i);
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
-	dev->open = rtl8169_open;
 	dev->hard_start_xmit = rtl8169_start_xmit;
-	dev->get_stats = rtl8169_get_stats;
 	SET_ETHTOOL_OPS(dev, &rtl8169_ethtool_ops);
-	dev->stop = rtl8169_close;
-	dev->tx_timeout = rtl8169_tx_timeout;
-	dev->set_multicast_list = rtl_set_rx_mode;
 	dev->watchdog_timeo = RTL8169_TX_TIMEOUT;
 	dev->irq = pdev->irq;
 	dev->base_addr = (unsigned long) ioaddr;
-	dev->change_mtu = rtl8169_change_mtu;
-	dev->set_mac_address = rtl_set_mac_address;
 
 	netif_napi_add(dev, &tp->napi, rtl8169_poll, R8169_NAPI_WEIGHT);
 
 #ifdef CONFIG_R8169_VLAN
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-	dev->vlan_rx_register = rtl8169_vlan_rx_register;
-#endif
-
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = rtl8169_netpoll;
 #endif
 
 	tp->intr_mask = 0xffff;

-- 

