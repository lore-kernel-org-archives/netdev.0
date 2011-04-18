From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: s2io: convert to hw_features
Date: Tue, 19 Apr 2011 01:31:20 +0200 (CEST)
Message-ID: <20110418233121.1726C13A64@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jon Mason <jdmason@kudzu.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:46015 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753487Ab1DRXbW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Apr 2011 19:31:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This removes advertising HW_CSUM as driver does not support it.

Note: driver advertises TSO6 but not IPV6_CSUM - bug maybe?

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/s2io.c |  100 ++++++++++----------------------------------=
-------
 1 files changed, 20 insertions(+), 80 deletions(-)

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 2302d97..58b78f4 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -6618,25 +6618,6 @@ static int s2io_ethtool_get_regs_len(struct net_=
device *dev)
 }
=20
=20
-static u32 s2io_ethtool_get_rx_csum(struct net_device *dev)
-{
-	struct s2io_nic *sp =3D netdev_priv(dev);
-
-	return sp->rx_csum;
-}
-
-static int s2io_ethtool_set_rx_csum(struct net_device *dev, u32 data)
-{
-	struct s2io_nic *sp =3D netdev_priv(dev);
-
-	if (data)
-		sp->rx_csum =3D 1;
-	else
-		sp->rx_csum =3D 0;
-
-	return 0;
-}
-
 static int s2io_get_eeprom_len(struct net_device *dev)
 {
 	return XENA_EEPROM_SPACE;
@@ -6688,61 +6669,27 @@ static void s2io_ethtool_get_strings(struct net=
_device *dev,
 	}
 }
=20
-static int s2io_ethtool_op_set_tx_csum(struct net_device *dev, u32 dat=
a)
-{
-	if (data)
-		dev->features |=3D NETIF_F_IP_CSUM;
-	else
-		dev->features &=3D ~NETIF_F_IP_CSUM;
-
-	return 0;
-}
-
-static u32 s2io_ethtool_op_get_tso(struct net_device *dev)
-{
-	return (dev->features & NETIF_F_TSO) !=3D 0;
-}
-
-static int s2io_ethtool_op_set_tso(struct net_device *dev, u32 data)
-{
-	if (data)
-		dev->features |=3D (NETIF_F_TSO | NETIF_F_TSO6);
-	else
-		dev->features &=3D ~(NETIF_F_TSO | NETIF_F_TSO6);
-
-	return 0;
-}
-
-static int s2io_ethtool_set_flags(struct net_device *dev, u32 data)
+static int s2io_set_features(struct net_device *dev, u32 features)
 {
 	struct s2io_nic *sp =3D netdev_priv(dev);
-	int rc =3D 0;
-	int changed =3D 0;
-
-	if (ethtool_invalid_flags(dev, data, ETH_FLAG_LRO))
-		return -EINVAL;
-
-	if (data & ETH_FLAG_LRO) {
-		if (!(dev->features & NETIF_F_LRO)) {
-			dev->features |=3D NETIF_F_LRO;
-			changed =3D 1;
-		}
-	} else if (dev->features & NETIF_F_LRO) {
-		dev->features &=3D ~NETIF_F_LRO;
-		changed =3D 1;
-	}
+	u32 changed =3D (features ^ dev->features) & NETIF_F_LRO;
=20
 	if (changed && netif_running(dev)) {
+		int rc;
+
 		s2io_stop_all_tx_queue(sp);
 		s2io_card_down(sp);
+		dev->features =3D features;
 		rc =3D s2io_card_up(sp);
 		if (rc)
 			s2io_reset(sp);
 		else
 			s2io_start_all_tx_queue(sp);
+
+		return rc ? rc : 1;
 	}
=20
-	return rc;
+	return 0;
 }
=20
 static const struct ethtool_ops netdev_ethtool_ops =3D {
@@ -6758,15 +6705,6 @@ static const struct ethtool_ops netdev_ethtool_o=
ps =3D {
 	.get_ringparam =3D s2io_ethtool_gringparam,
 	.get_pauseparam =3D s2io_ethtool_getpause_data,
 	.set_pauseparam =3D s2io_ethtool_setpause_data,
-	.get_rx_csum =3D s2io_ethtool_get_rx_csum,
-	.set_rx_csum =3D s2io_ethtool_set_rx_csum,
-	.set_tx_csum =3D s2io_ethtool_op_set_tx_csum,
-	.set_flags =3D s2io_ethtool_set_flags,
-	.get_flags =3D ethtool_op_get_flags,
-	.set_sg =3D ethtool_op_set_sg,
-	.get_tso =3D s2io_ethtool_op_get_tso,
-	.set_tso =3D s2io_ethtool_op_set_tso,
-	.set_ufo =3D ethtool_op_set_ufo,
 	.self_test =3D s2io_ethtool_test,
 	.get_strings =3D s2io_ethtool_get_strings,
 	.set_phys_id =3D s2io_ethtool_set_led,
@@ -7538,7 +7476,7 @@ static int rx_osm_handler(struct ring_info *ring_=
data, struct RxD_t * rxdp)
 	if ((rxdp->Control_1 & TCP_OR_UDP_FRAME) &&
 	    ((!ring_data->lro) ||
 	     (ring_data->lro && (!(rxdp->Control_1 & RXD_FRAME_IP_FRAG)))) &&
-	    (sp->rx_csum)) {
+	    (dev->features & NETIF_F_RXCSUM)) {
 		l3_csum =3D RXD_GET_L3_CKSUM(rxdp->Control_1);
 		l4_csum =3D RXD_GET_L4_CKSUM(rxdp->Control_1);
 		if ((l3_csum =3D=3D L3_CKSUM_OK) && (l4_csum =3D=3D L4_CKSUM_OK)) {
@@ -7799,6 +7737,7 @@ static const struct net_device_ops s2io_netdev_op=
s =3D {
 	.ndo_do_ioctl	   	=3D s2io_ioctl,
 	.ndo_set_mac_address    =3D s2io_set_mac_addr,
 	.ndo_change_mtu	   	=3D s2io_change_mtu,
+	.ndo_set_features	=3D s2io_set_features,
 	.ndo_vlan_rx_register   =3D s2io_vlan_rx_register,
 	.ndo_vlan_rx_kill_vid   =3D s2io_vlan_rx_kill_vid,
 	.ndo_tx_timeout	   	=3D s2io_tx_watchdog,
@@ -8040,17 +7979,18 @@ s2io_init_nic(struct pci_dev *pdev, const struc=
t pci_device_id *pre)
 	/*  Driver entry points */
 	dev->netdev_ops =3D &s2io_netdev_ops;
 	SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
-	dev->features |=3D NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-	dev->features |=3D NETIF_F_LRO;
-	dev->features |=3D NETIF_F_SG | NETIF_F_IP_CSUM;
+	dev->hw_features =3D NETIF_F_SG | NETIF_F_IP_CSUM |
+		NETIF_F_TSO | NETIF_F_TSO6 |
+		NETIF_F_RXCSUM | NETIF_F_LRO;
+	dev->features |=3D dev->hw_features |
+		NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
+	if (sp->device_type & XFRAME_II_DEVICE) {
+		dev->hw_features |=3D NETIF_F_UFO;
+		if (ufo)
+			dev->features |=3D NETIF_F_UFO;
+	}
 	if (sp->high_dma_flag =3D=3D true)
 		dev->features |=3D NETIF_F_HIGHDMA;
-	dev->features |=3D NETIF_F_TSO;
-	dev->features |=3D NETIF_F_TSO6;
-	if ((sp->device_type & XFRAME_II_DEVICE) && (ufo))  {
-		dev->features |=3D NETIF_F_UFO;
-		dev->features |=3D NETIF_F_HW_CSUM;
-	}
 	dev->watchdog_timeo =3D WATCH_DOG_TIMEOUT;
 	INIT_WORK(&sp->rst_timer_task, s2io_restart_nic);
 	INIT_WORK(&sp->set_link_task, s2io_set_link);
--=20
1.7.2.5

