From: Magnus Damm <magnus.damm@gmail.com>
Subject: [PATCH] via-rhine: add support for changing MTU
Date: Wed, 14 Jun 2017 02:18:27 +0900
Message-ID: <149737430797.28477.9215445312169809396.sendpatchset@little-apple>
Cc: Magnus Damm <magnus.damm@gmail.com>, linux-kernel@vger.kernel.org,
        davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Magnus Damm <damm+renesas@opensource.se>

Allow adjusting the MTU for via-rhine devices in case of no TX alignment
buffer is used.

Lightly tested on ALIX2D13 hardware by making use of VXLAN with MTU set
to 1500 on top of via-rhine devices with 1550 MTU. Without this patch
the VXLAN MTU is limited to less than 1500.

Signed-off-by: Magnus Damm <damm+renesas@opensource.se>
---

 Developed on top of next-20170613

 drivers/net/ethernet/via/via-rhine.c |   19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

--- 0001/drivers/net/ethernet/via/via-rhine.c
+++ work/drivers/net/ethernet/via/via-rhine.c	2017-06-14 02:05:25.410607110 +0900
@@ -518,6 +518,7 @@ static void rhine_get_stats64(struct net
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 static const struct ethtool_ops netdev_ethtool_ops;
 static int  rhine_close(struct net_device *dev);
+static int rhine_change_mtu(struct net_device *dev, int new_mtu);
 static int rhine_vlan_rx_add_vid(struct net_device *dev,
 				 __be16 proto, u16 vid);
 static int rhine_vlan_rx_kill_vid(struct net_device *dev,
@@ -894,6 +895,7 @@ static const struct net_device_ops rhine
 	.ndo_set_mac_address 	 = eth_mac_addr,
 	.ndo_do_ioctl		 = netdev_ioctl,
 	.ndo_tx_timeout 	 = rhine_tx_timeout,
+	.ndo_change_mtu 	 = rhine_change_mtu,
 	.ndo_vlan_rx_add_vid	 = rhine_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	 = rhine_vlan_rx_kill_vid,
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -981,6 +983,14 @@ static int rhine_init_one_common(struct
 				 NETIF_F_HW_VLAN_CTAG_RX |
 				 NETIF_F_HW_VLAN_CTAG_FILTER;
 
+	/* Allow MTU configuration as long as TX alignment buffer is unused */
+	if (!(rp->quirks & rqRhineI)) {
+		/* Packets less than 64 octets will raise RDES0.RUNT. */
+		dev->min_mtu = ETH_ZLEN - ETH_HLEN;
+		/* Hardware has 11 bits of RDES0.Rx_Length including FCS. */
+		dev->max_mtu = 0x1fff - ETH_HLEN - ETH_FCS_LEN;
+	}
+
 	/* dev->name not defined before register_netdev()! */
 	rc = register_netdev(dev);
 	if (rc)
@@ -1399,6 +1409,15 @@ static void rhine_set_carrier(struct mii
 		   mii->force_media, netif_carrier_ok(dev));
 }
 
+static int rhine_change_mtu(struct net_device *dev, int new_mtu)
+{
+	if (dev->flags & IFF_UP)
+		return -EBUSY;
+
+	dev->mtu = new_mtu;
+	return 0;
+}
+
 /**
  * rhine_set_cam - set CAM multicast filters
  * @ioaddr: register block of this Rhine
