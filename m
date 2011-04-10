From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: ksz884x: convert to hw_features
Date: Sun, 10 Apr 2011 15:13:21 +0200 (CEST)
Message-ID: <20110410131321.BE47D13909@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tristram Ha <Tristram.Ha@micrel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:58034 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752267Ab1DJNNX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Apr 2011 09:13:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This also fixes possible race when changing receive checksum state
and removes IPV6_CSUM_GEN_HACK as it's always set.

BTW, The claim about fake IPV6 checksum looks dubious. If that were tru=
e,
then there's a problem in networking core and should be fixed there and=
 not
in random drivers.

BTW#2, there's no MAINTAINERS entry for this driver. I assume this driv=
er
is supported by Micrel?

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/ksz884x.c |   73 ++++++++++++++---------------------------=
--------
 1 files changed, 21 insertions(+), 52 deletions(-)

diff --git a/drivers/net/ksz884x.c b/drivers/net/ksz884x.c
index 7f7d570..2c37a38 100644
--- a/drivers/net/ksz884x.c
+++ b/drivers/net/ksz884x.c
@@ -1221,7 +1221,6 @@ struct ksz_port_info {
 #define LINK_INT_WORKING		(1 << 0)
 #define SMALL_PACKET_TX_BUG		(1 << 1)
 #define HALF_DUPLEX_SIGNAL_BUG		(1 << 2)
-#define IPV6_CSUM_GEN_HACK		(1 << 3)
 #define RX_HUGE_FRAME			(1 << 4)
 #define STP_SUPPORT			(1 << 8)
=20
@@ -3748,7 +3747,6 @@ static int hw_init(struct ksz_hw *hw)
 		if (1 =3D=3D rc)
 			hw->features |=3D HALF_DUPLEX_SIGNAL_BUG;
 	}
-	hw->features |=3D IPV6_CSUM_GEN_HACK;
 	return rc;
 }
=20
@@ -4887,8 +4885,7 @@ static netdev_tx_t netdev_tx(struct sk_buff *skb,=
 struct net_device *dev)
 	left =3D hw_alloc_pkt(hw, skb->len, num);
 	if (left) {
 		if (left < num ||
-				((hw->features & IPV6_CSUM_GEN_HACK) &&
-				(CHECKSUM_PARTIAL =3D=3D skb->ip_summed) &&
+				((CHECKSUM_PARTIAL =3D=3D skb->ip_summed) &&
 				(ETH_P_IPV6 =3D=3D htons(skb->protocol)))) {
 			struct sk_buff *org_skb =3D skb;
=20
@@ -6583,57 +6580,33 @@ static void netdev_get_ethtool_stats(struct net=
_device *dev,
 }
=20
 /**
- * netdev_get_rx_csum - get receive checksum support
+ * netdev_set_features - set receive checksum support
  * @dev:	Network device.
- *
- * This function gets receive checksum support setting.
- *
- * Return true if receive checksum is enabled; false otherwise.
- */
-static u32 netdev_get_rx_csum(struct net_device *dev)
-{
-	struct dev_priv *priv =3D netdev_priv(dev);
-	struct dev_info *hw_priv =3D priv->adapter;
-	struct ksz_hw *hw =3D &hw_priv->hw;
-
-	return hw->rx_cfg &
-		(DMA_RX_CSUM_UDP |
-		DMA_RX_CSUM_TCP |
-		DMA_RX_CSUM_IP);
-}
-
-/**
- * netdev_set_rx_csum - set receive checksum support
- * @dev:	Network device.
- * @data:	Zero to disable receive checksum support.
+ * @features:	New device features (offloads).
  *
  * This function sets receive checksum support setting.
  *
  * Return 0 if successful; otherwise an error code.
  */
-static int netdev_set_rx_csum(struct net_device *dev, u32 data)
+static int netdev_set_features(struct net_device *dev, u32 features)
 {
 	struct dev_priv *priv =3D netdev_priv(dev);
 	struct dev_info *hw_priv =3D priv->adapter;
 	struct ksz_hw *hw =3D &hw_priv->hw;
-	u32 new_setting =3D hw->rx_cfg;
=20
-	if (data)
-		new_setting |=3D
-			(DMA_RX_CSUM_UDP | DMA_RX_CSUM_TCP |
-			DMA_RX_CSUM_IP);
-	else
-		new_setting &=3D
-			~(DMA_RX_CSUM_UDP | DMA_RX_CSUM_TCP |
-			DMA_RX_CSUM_IP);
-	new_setting &=3D ~DMA_RX_CSUM_UDP;
 	mutex_lock(&hw_priv->lock);
-	if (new_setting !=3D hw->rx_cfg) {
-		hw->rx_cfg =3D new_setting;
-		if (hw->enabled)
-			writel(hw->rx_cfg, hw->io + KS_DMA_RX_CTRL);
-	}
+
+	/* see note in hw_setup() */
+	if (features & NETIF_F_RXCSUM)
+		hw->rx_cfg |=3D DMA_RX_CSUM_TCP | DMA_RX_CSUM_IP;
+	else
+		hw->rx_cfg &=3D ~(DMA_RX_CSUM_TCP | DMA_RX_CSUM_IP);
+
+	if (hw->enabled)
+		writel(hw->rx_cfg, hw->io + KS_DMA_RX_CTRL);
+
 	mutex_unlock(&hw_priv->lock);
+
 	return 0;
 }
=20
@@ -6658,12 +6631,6 @@ static struct ethtool_ops netdev_ethtool_ops =3D=
 {
 	.get_strings		=3D netdev_get_strings,
 	.get_sset_count		=3D netdev_get_sset_count,
 	.get_ethtool_stats	=3D netdev_get_ethtool_stats,
-	.get_rx_csum		=3D netdev_get_rx_csum,
-	.set_rx_csum		=3D netdev_set_rx_csum,
-	.get_tx_csum		=3D ethtool_op_get_tx_csum,
-	.set_tx_csum		=3D ethtool_op_set_tx_csum,
-	.get_sg			=3D ethtool_op_get_sg,
-	.set_sg			=3D ethtool_op_set_sg,
 };
=20
 /*
@@ -6828,14 +6795,15 @@ static int __init netdev_init(struct net_device=
 *dev)
 	/* 500 ms timeout */
 	dev->watchdog_timeo =3D HZ / 2;
=20
-	dev->features |=3D NETIF_F_IP_CSUM;
+	dev->hw_features =3D NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_RXCSUM;
=20
 	/*
 	 * Hardware does not really support IPv6 checksum generation, but
-	 * driver actually runs faster with this on.  Refer IPV6_CSUM_GEN_HAC=
K.
+	 * driver actually runs faster with this on.
 	 */
-	dev->features |=3D NETIF_F_IPV6_CSUM;
-	dev->features |=3D NETIF_F_SG;
+	dev->hw_features |=3D NETIF_F_IPV6_CSUM;
+
+	dev->features |=3D dev->hw_features;
=20
 	sema_init(&priv->proc_sem, 1);
=20
@@ -6860,6 +6828,7 @@ static const struct net_device_ops netdev_ops =3D=
 {
 	.ndo_start_xmit		=3D netdev_tx,
 	.ndo_tx_timeout		=3D netdev_tx_timeout,
 	.ndo_change_mtu		=3D netdev_change_mtu,
+	.ndo_set_features	=3D netdev_set_features,
 	.ndo_set_mac_address	=3D netdev_set_mac_address,
 	.ndo_validate_addr	=3D eth_validate_addr,
 	.ndo_do_ioctl		=3D netdev_ioctl,
--=20
1.7.2.5

