From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: ps3_gelic: convert to hw_features
Date: Sun, 10 Apr 2011 16:47:46 +0200 (CEST)
Message-ID: <20110410144746.A28B11389B@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Geoff Levand <geoff@infradead.org>,
	"linuxppc-dev@lists.ozlabs.org.cbe-oss-dev"@lists.ozlabs.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:52574 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753153Ab1DJOrs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Apr 2011 10:47:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
[untested]

 drivers/net/ps3_gelic_net.c      |   26 +++++---------------------
 drivers/net/ps3_gelic_net.h      |    3 ---
 drivers/net/ps3_gelic_wireless.c |    4 ----
 3 files changed, 5 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ps3_gelic_net.c b/drivers/net/ps3_gelic_net.c
index 5ecfa4b..6c83ac6 100644
--- a/drivers/net/ps3_gelic_net.c
+++ b/drivers/net/ps3_gelic_net.c
@@ -951,7 +951,7 @@ static void gelic_net_pass_skb_up(struct gelic_desc=
r *descr,
 	skb->protocol =3D eth_type_trans(skb, netdev);
=20
 	/* checksum offload */
-	if (card->rx_csum) {
+	if (netdev->features & NETIF_F_RXCSUM) {
 		if ((data_status & GELIC_DESCR_DATA_STATUS_CHK_MASK) &&
 		    (!(data_error & GELIC_DESCR_DATA_ERROR_CHK_MASK)))
 			skb->ip_summed =3D CHECKSUM_UNNECESSARY;
@@ -1312,21 +1312,6 @@ static int gelic_ether_set_settings(struct net_d=
evice *netdev,
 	return 0;
 }
=20
-u32 gelic_net_get_rx_csum(struct net_device *netdev)
-{
-	struct gelic_card *card =3D netdev_card(netdev);
-
-	return card->rx_csum;
-}
-
-int gelic_net_set_rx_csum(struct net_device *netdev, u32 data)
-{
-	struct gelic_card *card =3D netdev_card(netdev);
-
-	card->rx_csum =3D data;
-	return 0;
-}
-
 static void gelic_net_get_wol(struct net_device *netdev,
 			      struct ethtool_wolinfo *wol)
 {
@@ -1411,10 +1396,6 @@ static const struct ethtool_ops gelic_ether_etht=
ool_ops =3D {
 	.get_settings	=3D gelic_ether_get_settings,
 	.set_settings	=3D gelic_ether_set_settings,
 	.get_link	=3D ethtool_op_get_link,
-	.get_tx_csum	=3D ethtool_op_get_tx_csum,
-	.set_tx_csum	=3D ethtool_op_set_tx_csum,
-	.get_rx_csum	=3D gelic_net_get_rx_csum,
-	.set_rx_csum	=3D gelic_net_set_rx_csum,
 	.get_wol	=3D gelic_net_get_wol,
 	.set_wol	=3D gelic_net_set_wol,
 };
@@ -1512,7 +1493,11 @@ int __devinit gelic_net_setup_netdev(struct net_=
device *netdev,
 	int status;
 	u64 v1, v2;
=20
+	netdev->hw_features =3D NETIF_F_IP_CSUM | NETIF_F_RXCSUM;
+
 	netdev->features =3D NETIF_F_IP_CSUM;
+	if (GELIC_CARD_RX_CSUM_DEFAULT)
+		netdev->features |=3D NETIF_F_RXCSUM;
=20
 	status =3D lv1_net_control(bus_id(card), dev_id(card),
 				 GELIC_LV1_GET_MAC_ADDRESS,
@@ -1756,7 +1741,6 @@ static int __devinit ps3_gelic_driver_probe(struc=
t ps3_system_bus_device *dev)
 	/* setup card structure */
 	card->irq_mask =3D GELIC_CARD_RXINT | GELIC_CARD_TXINT |
 		GELIC_CARD_PORT_STATUS_CHANGED;
-	card->rx_csum =3D GELIC_CARD_RX_CSUM_DEFAULT;
=20
=20
 	if (gelic_card_init_chain(card, &card->tx_chain,
diff --git a/drivers/net/ps3_gelic_net.h b/drivers/net/ps3_gelic_net.h
index 32521ae..50d8958 100644
--- a/drivers/net/ps3_gelic_net.h
+++ b/drivers/net/ps3_gelic_net.h
@@ -290,7 +290,6 @@ struct gelic_card {
 	struct gelic_descr_chain tx_chain;
 	struct gelic_descr_chain rx_chain;
 	int rx_dma_restart_required;
-	int rx_csum;
 	/*
 	 * tx_lock guards tx descriptor list and
 	 * tx_dma_progress.
@@ -377,8 +376,6 @@ extern int gelic_net_setup_netdev(struct net_device=
 *netdev,
 /* shared ethtool ops */
 extern void gelic_net_get_drvinfo(struct net_device *netdev,
 				  struct ethtool_drvinfo *info);
-extern u32 gelic_net_get_rx_csum(struct net_device *netdev);
-extern int gelic_net_set_rx_csum(struct net_device *netdev, u32 data);
 extern void gelic_net_poll_controller(struct net_device *netdev);
=20
 #endif /* _GELIC_NET_H */
diff --git a/drivers/net/ps3_gelic_wireless.c b/drivers/net/ps3_gelic_w=
ireless.c
index 4a624a2..39a93e8 100644
--- a/drivers/net/ps3_gelic_wireless.c
+++ b/drivers/net/ps3_gelic_wireless.c
@@ -2581,10 +2581,6 @@ static const struct net_device_ops gelic_wl_netd=
evice_ops =3D {
 static const struct ethtool_ops gelic_wl_ethtool_ops =3D {
 	.get_drvinfo	=3D gelic_net_get_drvinfo,
 	.get_link	=3D gelic_wl_get_link,
-	.get_tx_csum	=3D ethtool_op_get_tx_csum,
-	.set_tx_csum	=3D ethtool_op_set_tx_csum,
-	.get_rx_csum	=3D gelic_net_get_rx_csum,
-	.set_rx_csum	=3D gelic_net_set_rx_csum,
 };
=20
 static void __devinit gelic_wl_setup_netdev_ops(struct net_device *net=
dev)
--=20
1.7.2.5

