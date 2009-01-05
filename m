From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 7/8] infiniband: driver API update
Date: Mon, 05 Jan 2009 12:14:49 -0800
Message-ID: <20090105201514.828840735@vyatta.com>
References: <20090105201442.749889072@vyatta.com>
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org
To: David Miller <davem@davemloft.net>,
	Roland Dreier <rolandd@cisco.com>,
	Sean Hefty <sean.hefty@intel.com>,
	Hal Rosenstock <hal.rosenstock@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:35283 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752978AbZAEUYt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jan 2009 15:24:49 -0500
Content-Disposition: inline; filename=ib.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do some driver API updates on the IB drivers:
  * remove last_rx
  * use internal net_device_stats
  * convert to use net_device_ops

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/infiniband/hw/amso1100/c2.c	2009-01-05 12:11:28.942819613 -0800
+++ b/drivers/infiniband/hw/amso1100/c2.c	2009-01-05 12:11:32.537821389 -0800
@@ -76,7 +76,6 @@ static irqreturn_t c2_interrupt(int irq,
 static void c2_tx_timeout(struct net_device *netdev);
 static int c2_change_mtu(struct net_device *netdev, int new_mtu);
 static void c2_reset(struct c2_port *c2_port);
-static struct net_device_stats *c2_get_stats(struct net_device *netdev);
 
 static struct pci_device_id c2_pci_table[] = {
 	{ PCI_DEVICE(0x18b8, 0xb001) },
@@ -531,7 +530,6 @@ static void c2_rx_interrupt(struct net_d
 
 		netif_rx(skb);
 
-		netdev->last_rx = jiffies;
 		c2_port->netstats.rx_packets++;
 		c2_port->netstats.rx_bytes += buflen;
 	}
@@ -880,6 +878,17 @@ static int c2_change_mtu(struct net_devi
 	return ret;
 }
 
+static const struct net_device_ops c2_netdev_ops = {
+	.ndo_open 	     = c2_up,
+	.ndo_stop	     = c2_down,
+	.ndo_start_xmit      = c2_xmit_frame,
+	.ndo_get_stats	     = c2_get_stats,
+	.ndo_tx_timeout	     = c2_tx_timeout,
+	.ndo_change_mtu	     = c2_change_mtu,
+	.ndo_set_mac_address = eth_mac_addr,
+	.ndo_validate_addr   = eth_validate_addr,
+};
+
 /* Initialize network device */
 static struct net_device *c2_devinit(struct c2_dev *c2dev,
 				     void __iomem * mmio_addr)
@@ -894,12 +903,7 @@ static struct net_device *c2_devinit(str
 
 	SET_NETDEV_DEV(netdev, &c2dev->pcidev->dev);
 
-	netdev->open = c2_up;
-	netdev->stop = c2_down;
-	netdev->hard_start_xmit = c2_xmit_frame;
-	netdev->get_stats = c2_get_stats;
-	netdev->tx_timeout = c2_tx_timeout;
-	netdev->change_mtu = c2_change_mtu;
+	netdev->netdev_ops = &c2_netdev_ops;
 	netdev->watchdog_timeo = C2_TX_TIMEOUT;
 	netdev->irq = c2dev->pcidev->irq;
 
--- a/drivers/infiniband/hw/amso1100/c2_provider.c	2009-01-05 12:11:28.930819448 -0800
+++ b/drivers/infiniband/hw/amso1100/c2_provider.c	2009-01-05 12:11:32.537821389 -0800
@@ -719,15 +719,17 @@ static int c2_pseudo_change_mtu(struct n
 	return ret;
 }
 
+static const struct net_device_ops c2_netdev_ops = {
+	.ndo_open       = c2_pseudo_up,
+	.ndo_stop       = c2_pseudo_down,
+	.ndo_start_xmit = c2_pseudo_xmit_frame,
+	.ndo_change_mtu = c2_pseudo_change_mtu,
+};
+
+
 static void setup(struct net_device *netdev)
 {
-	netdev->open = c2_pseudo_up;
-	netdev->stop = c2_pseudo_down;
-	netdev->hard_start_xmit = c2_pseudo_xmit_frame;
-	netdev->get_stats = NULL;
-	netdev->tx_timeout = NULL;
-	netdev->set_mac_address = NULL;
-	netdev->change_mtu = c2_pseudo_change_mtu;
+	netdev->netdev_ops = &c2_netdev_ops;
 	netdev->watchdog_timeo = 0;
 	netdev->type = ARPHRD_ETHER;
 	netdev->mtu = 1500;
@@ -735,7 +737,6 @@ static void setup(struct net_device *net
 	netdev->addr_len = ETH_ALEN;
 	netdev->tx_queue_len = 0;
 	netdev->flags |= IFF_NOARP;
-	return;
 }
 
 static struct net_device *c2_pseudo_netdev_init(struct c2_dev *c2dev)
--- a/drivers/infiniband/hw/nes/nes_nic.c	2009-01-05 12:11:28.958819510 -0800
+++ b/drivers/infiniband/hw/nes/nes_nic.c	2009-01-05 12:11:32.541819495 -0800
@@ -1568,6 +1568,19 @@ static void nes_netdev_vlan_rx_register(
 	spin_unlock_irqrestore(&nesadapter->phy_lock, flags);
 }
 
+static const struct net_device_ops nes_netdev_ops = {
+	.ndo_open		= nes_netdev_open,
+	.ndo_stop		= nes_netdev_stop,
+	.ndo_start_xmit		= nes_netdev_start_xmit,
+	.ndo_get_stats		= nes_netdev_get_stats,
+	.ndo_tx_timeout		= nes_netdev_tx_timeout,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= nes_netdev_set_mac_address,
+	.ndo_set_multicast_list = nes_netdev_set_multicast_list,
+	.ndo_change_mtu 	= nes_netdev_change_mtu,
+	.ndo_vlan_rx_register   = nes_netdev_vlan_rx_register,
+};
+
 
 /**
  * nes_netdev_init - initialize network device
@@ -1596,14 +1609,7 @@ struct net_device *nes_netdev_init(struc
 	nesvnic = netdev_priv(netdev);
 	memset(nesvnic, 0, sizeof(*nesvnic));
 
-	netdev->open = nes_netdev_open;
-	netdev->stop = nes_netdev_stop;
-	netdev->hard_start_xmit = nes_netdev_start_xmit;
-	netdev->get_stats = nes_netdev_get_stats;
-	netdev->tx_timeout = nes_netdev_tx_timeout;
-	netdev->set_mac_address = nes_netdev_set_mac_address;
-	netdev->set_multicast_list = nes_netdev_set_multicast_list;
-	netdev->change_mtu = nes_netdev_change_mtu;
+	netdev->netdev_ops = &nes_netdev_ops;
 	netdev->watchdog_timeo = NES_TX_TIMEOUT;
 	netdev->irq = nesdev->pcidev->irq;
 	netdev->mtu = ETH_DATA_LEN;
@@ -1615,7 +1621,6 @@ struct net_device *nes_netdev_init(struc
 	netif_napi_add(netdev, &nesvnic->napi, nes_netdev_poll, 128);
 	nes_debug(NES_DBG_INIT, "Enabling VLAN Insert/Delete.\n");
 	netdev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-	netdev->vlan_rx_register = nes_netdev_vlan_rx_register;
 	netdev->features |= NETIF_F_LLTX;
 
 	/* Fill in the port structure */
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c	2009-01-05 12:11:28.922818928 -0800
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c	2009-01-05 12:11:32.541819495 -0800
@@ -1013,18 +1013,22 @@ static void ipoib_lro_setup(struct ipoib
 	priv->lro.lro_mgr.ip_summed_aggr = CHECKSUM_UNNECESSARY;
 }
 
+static const struct net_device_ops ipoib_netdev_ops = {
+	.ndo_open		 = ipoib_open,
+	.ndo_stop		 = ipoib_stop,
+	.ndo_change_mtu		 = ipoib_change_mtu,
+	.ndo_start_xmit		 = ipoib_start_xmit,
+	.ndo_tx_timeout	 	 = ipoib_timeout,
+	.ndo_set_multicast_list	 = ipoib_set_mcast_list,
+	.ndo_neigh_setup	 = ipoib_neigh_setup_dev,
+};
+
 static void ipoib_setup(struct net_device *dev)
 {
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
 
-	dev->open		 = ipoib_open;
-	dev->stop		 = ipoib_stop;
-	dev->change_mtu		 = ipoib_change_mtu;
-	dev->hard_start_xmit	 = ipoib_start_xmit;
-	dev->tx_timeout		 = ipoib_timeout;
-	dev->header_ops		 = &ipoib_header_ops;
-	dev->set_multicast_list	 = ipoib_set_mcast_list;
-	dev->neigh_setup	 = ipoib_neigh_setup_dev;
+	dev->netdev_ops		= &ipoib_netdev_ops;
+	dev->header_ops		= &ipoib_header_ops;
 
 	ipoib_set_ethtool_ops(dev);
 

-- 

