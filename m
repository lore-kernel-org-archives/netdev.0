From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [ofa-general] [PATCH 04/77] infiniband: convert nes driver to
	net_device_ops
Date: Fri, 20 Mar 2009 22:35:31 -0700
Message-ID: <20090321053712.868239443@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org
To: David Miller <davem@davemloft.net>, faisal.latif@intel.com,
	chien.tin.tung@intel.com
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline; filename=inifiband-nes.patch
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Also, removed unnecessary memset() sinc alloc_netdev returns
zeroed memory.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/infiniband/hw/nes/nes_nic.c |   27 +++++++++++++++------------
 1 file changed, 15 insertions(+), 12 deletions(-)

--- a/drivers/infiniband/hw/nes/nes_nic.c	2009-03-19 22:40:30.556964185 -0700
+++ b/drivers/infiniband/hw/nes/nes_nic.c	2009-03-19 22:42:43.317902045 -0700
@@ -1568,6 +1568,19 @@ static void nes_netdev_vlan_rx_register(
 	spin_unlock_irqrestore(&nesadapter->phy_lock, flags);
 }
 
+static const struct net_device_ops nes_netdev_ops = {
+	.ndo_open 		= nes_netdev_open,
+	.ndo_stop		= nes_netdev_stop,
+	.ndo_start_xmit 	= nes_netdev_start_xmit,
+	.ndo_get_stats		= nes_netdev_get_stats,
+	.ndo_tx_timeout 	= nes_netdev_tx_timeout,
+	.ndo_set_mac_address	= nes_netdev_set_mac_address,
+	.ndo_set_multicast_list = nes_netdev_set_multicast_list,
+	.ndo_change_mtu		= nes_netdev_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_vlan_rx_register 	= nes_netdev_vlan_rx_register,
+};
 
 /**
  * nes_netdev_init - initialize network device
@@ -1593,17 +1606,6 @@ struct net_device *nes_netdev_init(struc
 
 	SET_NETDEV_DEV(netdev, &nesdev->pcidev->dev);
 
-	nesvnic = netdev_priv(netdev);
-	memset(nesvnic, 0, sizeof(*nesvnic));
-
-	netdev->open = nes_netdev_open;
-	netdev->stop = nes_netdev_stop;
-	netdev->hard_start_xmit = nes_netdev_start_xmit;
-	netdev->get_stats = nes_netdev_get_stats;
-	netdev->tx_timeout = nes_netdev_tx_timeout;
-	netdev->set_mac_address = nes_netdev_set_mac_address;
-	netdev->set_multicast_list = nes_netdev_set_multicast_list;
-	netdev->change_mtu = nes_netdev_change_mtu;
 	netdev->watchdog_timeo = NES_TX_TIMEOUT;
 	netdev->irq = nesdev->pcidev->irq;
 	netdev->mtu = ETH_DATA_LEN;
@@ -1611,14 +1613,15 @@ struct net_device *nes_netdev_init(struc
 	netdev->addr_len = ETH_ALEN;
 	netdev->type = ARPHRD_ETHER;
 	netdev->features = NETIF_F_HIGHDMA;
+	netdev->netdev_ops = &nes_netdev_ops;
 	netdev->ethtool_ops = &nes_ethtool_ops;
 	netif_napi_add(netdev, &nesvnic->napi, nes_netdev_poll, 128);
 	nes_debug(NES_DBG_INIT, "Enabling VLAN Insert/Delete.\n");
 	netdev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-	netdev->vlan_rx_register = nes_netdev_vlan_rx_register;
 	netdev->features |= NETIF_F_LLTX;
 
 	/* Fill in the port structure */
+	nesvnic = netdev_priv(netdev);
 	nesvnic->netdev = netdev;
 	nesvnic->nesdev = nesdev;
 	nesvnic->msg_enable = netif_msg_init(debug, default_msg);

-- 
