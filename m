From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: spider_net: convert to hw_features
Date: Fri, 15 Apr 2011 16:50:49 +0200 (CEST)
Message-ID: <20110415145049.D0047138DD@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>,
	Jens Osterkamp <jens@de.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:46536 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756040Ab1DOOuw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Apr 2011 10:50:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/spider_net.c         |   15 +++++++--------
 drivers/net/spider_net.h         |    7 -------
 drivers/net/spider_net_ethtool.c |   21 ---------------------
 3 files changed, 7 insertions(+), 36 deletions(-)

diff --git a/drivers/net/spider_net.c b/drivers/net/spider_net.c
index cb6bcca..949f124 100644
--- a/drivers/net/spider_net.c
+++ b/drivers/net/spider_net.c
@@ -994,15 +994,13 @@ spider_net_pass_skb_up(struct spider_net_descr *d=
escr,
 	skb->protocol =3D eth_type_trans(skb, netdev);
=20
 	/* checksum offload */
-	if (card->options.rx_csum) {
+	skb_checksum_none_assert(skb);
+	if (netdev->features & NETIF_F_RXCSUM) {
 		if ( ( (data_status & SPIDER_NET_DATA_STATUS_CKSUM_MASK) =3D=3D
 		       SPIDER_NET_DATA_STATUS_CKSUM_MASK) &&
 		     !(data_error & SPIDER_NET_DATA_ERR_CKSUM_MASK))
 			skb->ip_summed =3D CHECKSUM_UNNECESSARY;
-		else
-			skb_checksum_none_assert(skb);
-	} else
-		skb_checksum_none_assert(skb);
+	}
=20
 	if (data_status & SPIDER_NET_VLAN_PACKET) {
 		/* further enhancements: HW-accel VLAN
@@ -2322,14 +2320,15 @@ spider_net_setup_netdev(struct spider_net_card =
*card)
 	card->aneg_timer.function =3D spider_net_link_phy;
 	card->aneg_timer.data =3D (unsigned long) card;
=20
-	card->options.rx_csum =3D SPIDER_NET_RX_CSUM_DEFAULT;
-
 	netif_napi_add(netdev, &card->napi,
 		       spider_net_poll, SPIDER_NET_NAPI_WEIGHT);
=20
 	spider_net_setup_netdev_ops(netdev);
=20
-	netdev->features =3D NETIF_F_IP_CSUM | NETIF_F_LLTX;
+	netdev->hw_features =3D NETIF_F_RXCSUM | NETIF_F_IP_CSUM;
+	if (SPIDER_NET_RX_CSUM_DEFAULT)
+		netdev->features |=3D NETIF_F_RXCSUM;
+	netdev->features |=3D NETIF_F_IP_CSUM | NETIF_F_LLTX;
 	/* some time: NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX |
 	 *		NETIF_F_HW_VLAN_FILTER */
=20
diff --git a/drivers/net/spider_net.h b/drivers/net/spider_net.h
index 05f74cb..020f64a 100644
--- a/drivers/net/spider_net.h
+++ b/drivers/net/spider_net.h
@@ -429,12 +429,6 @@ struct spider_net_descr_chain {
  * 701b8000 would be correct, but every packets gets that flag */
 #define SPIDER_NET_DESTROY_RX_FLAGS	0x700b8000
=20
-/* this will be bigger some time */
-struct spider_net_options {
-	int rx_csum; /* for rx: if 0 ip_summed=3DNONE,
-			if 1 and hw has verified, ip_summed=3DUNNECESSARY */
-};
-
 #define SPIDER_NET_DEFAULT_MSG		( NETIF_MSG_DRV | \
 					  NETIF_MSG_PROBE | \
 					  NETIF_MSG_LINK | \
@@ -487,7 +481,6 @@ struct spider_net_card {
 	/* for ethtool */
 	int msg_enable;
 	struct spider_net_extra_stats spider_stats;
-	struct spider_net_options options;
=20
 	/* Must be last item in struct */
 	struct spider_net_descr darray[0];
diff --git a/drivers/net/spider_net_ethtool.c b/drivers/net/spider_net_=
ethtool.c
index 5bae728..d723fca 100644
--- a/drivers/net/spider_net_ethtool.c
+++ b/drivers/net/spider_net_ethtool.c
@@ -115,24 +115,6 @@ spider_net_ethtool_nway_reset(struct net_device *n=
etdev)
 	return 0;
 }
=20
-static u32
-spider_net_ethtool_get_rx_csum(struct net_device *netdev)
-{
-	struct spider_net_card *card =3D netdev_priv(netdev);
-
-	return card->options.rx_csum;
-}
-
-static int
-spider_net_ethtool_set_rx_csum(struct net_device *netdev, u32 n)
-{
-	struct spider_net_card *card =3D netdev_priv(netdev);
-
-	card->options.rx_csum =3D n;
-	return 0;
-}
-
-
 static void
 spider_net_ethtool_get_ringparam(struct net_device *netdev,
 				 struct ethtool_ringparam *ering)
@@ -189,9 +171,6 @@ const struct ethtool_ops spider_net_ethtool_ops =3D=
 {
 	.set_msglevel		=3D spider_net_ethtool_set_msglevel,
 	.get_link		=3D ethtool_op_get_link,
 	.nway_reset		=3D spider_net_ethtool_nway_reset,
-	.get_rx_csum		=3D spider_net_ethtool_get_rx_csum,
-	.set_rx_csum		=3D spider_net_ethtool_set_rx_csum,
-	.set_tx_csum		=3D ethtool_op_set_tx_csum,
 	.get_ringparam          =3D spider_net_ethtool_get_ringparam,
 	.get_strings		=3D spider_net_get_strings,
 	.get_sset_count		=3D spider_net_get_sset_count,
--=20
1.7.2.5

