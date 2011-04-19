From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: ibmveth: convert to hw_features
Date: Tue, 19 Apr 2011 14:14:25 +0200 (CEST)
Message-ID: <20110419121426.18A2D13909@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Santiago Leon <santil@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:36242 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754944Ab1DSMO2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2011 08:14:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A minimal conversion.

ibmveth_set_csum_offload() can be folded into ibmveth_set_features()
and adapter->rx_csum removed - left for later cleanup.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/ibmveth.c |   96 ++++++++++++++---------------------------=
--------
 1 files changed, 27 insertions(+), 69 deletions(-)

diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index 5522d45..4855f1f 100644
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -729,45 +729,24 @@ static void netdev_get_drvinfo(struct net_device =
*dev,
 		sizeof(info->version) - 1);
 }
=20
-static void ibmveth_set_rx_csum_flags(struct net_device *dev, u32 data=
)
+static u32 ibmveth_fix_features(struct net_device *dev, u32 features)
 {
-	struct ibmveth_adapter *adapter =3D netdev_priv(dev);
+	/*
+	 * Since the ibmveth firmware interface does not have the
+	 * concept of separate tx/rx checksum offload enable, if rx
+	 * checksum is disabled we also have to disable tx checksum
+	 * offload. Once we disable rx checksum offload, we are no
+	 * longer allowed to send tx buffers that are not properly
+	 * checksummed.
+	 */
=20
-	if (data) {
-		adapter->rx_csum =3D 1;
-	} else {
-		/*
-		 * Since the ibmveth firmware interface does not have the
-		 * concept of separate tx/rx checksum offload enable, if rx
-		 * checksum is disabled we also have to disable tx checksum
-		 * offload. Once we disable rx checksum offload, we are no
-		 * longer allowed to send tx buffers that are not properly
-		 * checksummed.
-		 */
-		adapter->rx_csum =3D 0;
-		dev->features &=3D ~NETIF_F_IP_CSUM;
-		dev->features &=3D ~NETIF_F_IPV6_CSUM;
-	}
-}
-
-static void ibmveth_set_tx_csum_flags(struct net_device *dev, u32 data=
)
-{
-	struct ibmveth_adapter *adapter =3D netdev_priv(dev);
+	if (!(features & NETIF_F_RXCSUM))
+		features &=3D ~NETIF_F_ALL_CSUM;
=20
-	if (data) {
-		if (adapter->fw_ipv4_csum_support)
-			dev->features |=3D NETIF_F_IP_CSUM;
-		if (adapter->fw_ipv6_csum_support)
-			dev->features |=3D NETIF_F_IPV6_CSUM;
-		adapter->rx_csum =3D 1;
-	} else {
-		dev->features &=3D ~NETIF_F_IP_CSUM;
-		dev->features &=3D ~NETIF_F_IPV6_CSUM;
-	}
+	return features;
 }
=20
-static int ibmveth_set_csum_offload(struct net_device *dev, u32 data,
-				    void (*done) (struct net_device *, u32))
+static int ibmveth_set_csum_offload(struct net_device *dev, u32 data)
 {
 	struct ibmveth_adapter *adapter =3D netdev_priv(dev);
 	unsigned long set_attr, clr_attr, ret_attr;
@@ -827,8 +806,8 @@ static int ibmveth_set_csum_offload(struct net_devi=
ce *dev, u32 data,
 		} else
 			adapter->fw_ipv6_csum_support =3D data;
=20
-		if (ret =3D=3D H_SUCCESS || ret6 =3D=3D H_SUCCESS)
-			done(dev, data);
+		if (ret !=3D H_SUCCESS || ret6 !=3D H_SUCCESS)
+			adapter->rx_csum =3D data;
 		else
 			rc1 =3D -EIO;
 	} else {
@@ -844,41 +823,22 @@ static int ibmveth_set_csum_offload(struct net_de=
vice *dev, u32 data,
 	return rc1 ? rc1 : rc2;
 }
=20
-static int ibmveth_set_rx_csum(struct net_device *dev, u32 data)
+static int ibmveth_set_features(struct net_device *dev, u32 features)
 {
 	struct ibmveth_adapter *adapter =3D netdev_priv(dev);
+	int rx_csum =3D !!(features & NETIF_F_RXCSUM);
+	int rc;
=20
-	if ((data && adapter->rx_csum) || (!data && !adapter->rx_csum))
+	if (rx_csum =3D=3D adapter->rx_csum)
 		return 0;
=20
-	return ibmveth_set_csum_offload(dev, data, ibmveth_set_rx_csum_flags)=
;
-}
-
-static int ibmveth_set_tx_csum(struct net_device *dev, u32 data)
-{
-	struct ibmveth_adapter *adapter =3D netdev_priv(dev);
-	int rc =3D 0;
-
-	if (data && (dev->features & (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM)))
-		return 0;
-	if (!data && !(dev->features & (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM))=
)
-		return 0;
-
-	if (data && !adapter->rx_csum)
-		rc =3D ibmveth_set_csum_offload(dev, data,
-					      ibmveth_set_tx_csum_flags);
-	else
-		ibmveth_set_tx_csum_flags(dev, data);
+	rc =3D ibmveth_set_csum_offload(dev, rx_csum);
+	if (rc && !adapter->rx_csum)
+		dev->features =3D features & ~(NETIF_F_ALL_CSUM | NETIF_F_RXCSUM);
=20
 	return rc;
 }
=20
-static u32 ibmveth_get_rx_csum(struct net_device *dev)
-{
-	struct ibmveth_adapter *adapter =3D netdev_priv(dev);
-	return adapter->rx_csum;
-}
-
 static void ibmveth_get_strings(struct net_device *dev, u32 stringset,=
 u8 *data)
 {
 	int i;
@@ -914,13 +874,9 @@ static const struct ethtool_ops netdev_ethtool_ops=
 =3D {
 	.get_drvinfo		=3D netdev_get_drvinfo,
 	.get_settings		=3D netdev_get_settings,
 	.get_link		=3D ethtool_op_get_link,
-	.set_tx_csum		=3D ibmveth_set_tx_csum,
-	.get_rx_csum		=3D ibmveth_get_rx_csum,
-	.set_rx_csum		=3D ibmveth_set_rx_csum,
 	.get_strings		=3D ibmveth_get_strings,
 	.get_sset_count		=3D ibmveth_get_sset_count,
 	.get_ethtool_stats	=3D ibmveth_get_ethtool_stats,
-	.set_sg			=3D ethtool_op_set_sg,
 };
=20
 static int ibmveth_ioctl(struct net_device *dev, struct ifreq *ifr, in=
t cmd)
@@ -1345,6 +1301,8 @@ static const struct net_device_ops ibmveth_netdev=
_ops =3D {
 	.ndo_set_multicast_list	=3D ibmveth_set_multicast_list,
 	.ndo_do_ioctl		=3D ibmveth_ioctl,
 	.ndo_change_mtu		=3D ibmveth_change_mtu,
+	.ndo_fix_features	=3D ibmveth_fix_features,
+	.ndo_set_features	=3D ibmveth_set_features,
 	.ndo_validate_addr	=3D eth_validate_addr,
 	.ndo_set_mac_address	=3D eth_mac_addr,
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -1412,7 +1370,9 @@ static int __devinit ibmveth_probe(struct vio_dev=
 *dev,
 	netdev->netdev_ops =3D &ibmveth_netdev_ops;
 	netdev->ethtool_ops =3D &netdev_ethtool_ops;
 	SET_NETDEV_DEV(netdev, &dev->dev);
-	netdev->features |=3D NETIF_F_SG;
+	netdev->hw_features =3D NETIF_F_SG | NETIF_F_RXCSUM |
+		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
+	netdev->features |=3D netdev->hw_features;
=20
 	memcpy(netdev->dev_addr, &adapter->mac_addr, netdev->addr_len);
=20
@@ -1437,8 +1397,6 @@ static int __devinit ibmveth_probe(struct vio_dev=
 *dev,
=20
 	netdev_dbg(netdev, "registering netdev...\n");
=20
-	ibmveth_set_csum_offload(netdev, 1, ibmveth_set_tx_csum_flags);
-
 	rc =3D register_netdev(netdev);
=20
 	if (rc) {
--=20
1.7.2.5

