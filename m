From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 17/33] 8139: convert to net_device_ops
Date: Mon, 17 Nov 2008 15:42:24 -0800
Message-ID: <20081117234356.245209612@vyatta.com>
References: <20081117234207.854110282@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:55082 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752206AbYKRAAL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 19:00:11 -0500
Content-Disposition: inline; filename=8139-netdev_ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert to new network device ops interface.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 drivers/net/8139cp.c  |   31 ++++++++++++++++++-------------
 drivers/net/8139too.c |   27 ++++++++++++++++-----------
 2 files changed, 34 insertions(+), 24 deletions(-)

--- a/drivers/net/8139cp.c	2008-11-04 13:58:05.000000000 -0800
+++ b/drivers/net/8139cp.c	2008-11-17 11:53:01.000000000 -0800
@@ -1817,6 +1817,23 @@ static void cp_set_d3_state (struct cp_p
 	pci_set_power_state (cp->pdev, PCI_D3hot);
 }
 
+static const struct net_device_ops cp_netdev_ops = {
+	.open			= cp_open,
+	.stop			= cp_close,
+	.validate_addr		= eth_validate_addr,
+	.set_multicast_list	= cp_set_rx_mode,
+	.get_stats		= cp_get_stats,
+	.do_ioctl		= cp_ioctl,
+	.tx_timeout		= cp_tx_timeout,
+	.vlan_rx_register	= cp_vlan_rx_register,
+#ifdef BROKEN
+	.change_mtu		= cp_change_mtu,
+#endif
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.poll_controller	= cp_poll_controller,
+#endif
+};
+
 static int cp_init_one (struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *dev;
@@ -1929,26 +1946,14 @@ static int cp_init_one (struct pci_dev *
 		    cpu_to_le16(read_eeprom (regs, i + 7, addr_len));
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
-	dev->open = cp_open;
-	dev->stop = cp_close;
-	dev->set_multicast_list = cp_set_rx_mode;
+	dev->netdev_ops = &cp_netdev_ops;
 	dev->hard_start_xmit = cp_start_xmit;
-	dev->get_stats = cp_get_stats;
-	dev->do_ioctl = cp_ioctl;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = cp_poll_controller;
-#endif
 	netif_napi_add(dev, &cp->napi, cp_rx_poll, 16);
-#ifdef BROKEN
-	dev->change_mtu = cp_change_mtu;
-#endif
 	dev->ethtool_ops = &cp_ethtool_ops;
-	dev->tx_timeout = cp_tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
 
 #if CP_VLAN_TAG_USED
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-	dev->vlan_rx_register = cp_vlan_rx_register;
 #endif
 
 	if (pci_using_dac)
--- a/drivers/net/8139too.c	2008-11-04 13:58:05.000000000 -0800
+++ b/drivers/net/8139too.c	2008-11-17 11:53:01.000000000 -0800
@@ -916,6 +916,19 @@ err_out:
 	return rc;
 }
 
+static const struct net_device_ops rtl8139_netdev_ops = {
+	.open			= rtl8139_open,
+	.stop			= rtl8139_close,
+	.get_stats		= rtl8139_get_stats,
+	.validate_addr		= eth_validate_addr,
+	.set_multicast_list	= rtl8139_set_rx_mode,
+	.do_ioctl		= netdev_ioctl,
+	.tx_timeout		= rtl8139_tx_timeout,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.poll_controller	= rtl8139_poll_controller,
+#endif
+
+};
 
 static int __devinit rtl8139_init_one (struct pci_dev *pdev,
 				       const struct pci_device_id *ent)
@@ -976,19 +989,11 @@ static int __devinit rtl8139_init_one (s
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
 	/* The Rtl8139-specific entries in the device structure. */
-	dev->open = rtl8139_open;
-	dev->hard_start_xmit = rtl8139_start_xmit;
-	netif_napi_add(dev, &tp->napi, rtl8139_poll, 64);
-	dev->stop = rtl8139_close;
-	dev->get_stats = rtl8139_get_stats;
-	dev->set_multicast_list = rtl8139_set_rx_mode;
-	dev->do_ioctl = netdev_ioctl;
+	dev->netdev_ops = &rtl8139_netdev_ops;
 	dev->ethtool_ops = &rtl8139_ethtool_ops;
-	dev->tx_timeout = rtl8139_tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = rtl8139_poll_controller;
-#endif
+	dev->hard_start_xmit = rtl8139_start_xmit;
+	netif_napi_add(dev, &tp->napi, rtl8139_poll, 64);
 
 	/* note: the hardware is not capable of sg/csum/highdma, however
 	 * through the use of skb_copy_and_csum_dev we enable these

-- 

