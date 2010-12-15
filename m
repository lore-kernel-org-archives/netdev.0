From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [RFC PATCH 12/12] skge: convert to hw_features
Date: Wed, 15 Dec 2010 23:24:30 +0100 (CET)
Message-ID: <e637d799425195dec656efeb0f4cfbaf9c8b82eb.1292451560.git.mirq-linux@rere.qmqm.pl>
References: <cover.1292451559.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:53559 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752467Ab0LOWYc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Dec 2010 17:24:32 -0500
In-Reply-To: <cover.1292451559.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The hardware might do full HW_CSUM, not just IP_CSUM, but it's not test=
ed
and so not changed here.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/skge.c |   53 ++++----------------------------------------=
-------
 drivers/net/skge.h |    1 -
 2 files changed, 5 insertions(+), 49 deletions(-)

diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index 50815fb..41e02e9 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -537,46 +537,6 @@ static int skge_nway_reset(struct net_device *dev)
 	return 0;
 }
=20
-static int skge_set_sg(struct net_device *dev, u32 data)
-{
-	struct skge_port *skge =3D netdev_priv(dev);
-	struct skge_hw *hw =3D skge->hw;
-
-	if (hw->chip_id =3D=3D CHIP_ID_GENESIS && data)
-		return -EOPNOTSUPP;
-	return ethtool_op_set_sg(dev, data);
-}
-
-static int skge_set_tx_csum(struct net_device *dev, u32 data)
-{
-	struct skge_port *skge =3D netdev_priv(dev);
-	struct skge_hw *hw =3D skge->hw;
-
-	if (hw->chip_id =3D=3D CHIP_ID_GENESIS && data)
-		return -EOPNOTSUPP;
-
-	return ethtool_op_set_tx_csum(dev, data);
-}
-
-static u32 skge_get_rx_csum(struct net_device *dev)
-{
-	struct skge_port *skge =3D netdev_priv(dev);
-
-	return skge->rx_csum;
-}
-
-/* Only Yukon supports checksum offload. */
-static int skge_set_rx_csum(struct net_device *dev, u32 data)
-{
-	struct skge_port *skge =3D netdev_priv(dev);
-
-	if (skge->hw->chip_id =3D=3D CHIP_ID_GENESIS && data)
-		return -EOPNOTSUPP;
-
-	skge->rx_csum =3D data;
-	return 0;
-}
-
 static void skge_get_pauseparam(struct net_device *dev,
 				struct ethtool_pauseparam *ecmd)
 {
@@ -925,10 +885,6 @@ static const struct ethtool_ops skge_ethtool_ops =3D=
 {
 	.set_pauseparam =3D skge_set_pauseparam,
 	.get_coalesce	=3D skge_get_coalesce,
 	.set_coalesce	=3D skge_set_coalesce,
-	.set_sg		=3D skge_set_sg,
-	.set_tx_csum	=3D skge_set_tx_csum,
-	.get_rx_csum	=3D skge_get_rx_csum,
-	.set_rx_csum	=3D skge_set_rx_csum,
 	.get_strings	=3D skge_get_strings,
 	.phys_id	=3D skge_phys_id,
 	.get_sset_count =3D skge_get_sset_count,
@@ -3085,7 +3041,8 @@ static struct sk_buff *skge_rx_get(struct net_dev=
ice *dev,
 	}
=20
 	skb_put(skb, len);
-	if (skge->rx_csum) {
+
+	if (dev->features & NETIF_F_RXCSUM) {
 		skb->csum =3D csum;
 		skb->ip_summed =3D CHECKSUM_COMPLETE;
 	}
@@ -3847,10 +3804,10 @@ static struct net_device *skge_devinit(struct s=
kge_hw *hw, int port,
 	setup_timer(&skge->link_timer, xm_link_timer, (unsigned long) skge);
=20
 	if (hw->chip_id !=3D CHIP_ID_GENESIS) {
-		dev->features |=3D NETIF_F_IP_CSUM | NETIF_F_SG;
-		skge->rx_csum =3D 1;
+		dev->hw_features =3D NETIF_F_IP_CSUM | NETIF_F_SG |
+		                   NETIF_F_RXCSUM;
+		dev->features |=3D dev->hw_features;
 	}
-	dev->features |=3D NETIF_F_GRO;
=20
 	/* read the mac address */
 	memcpy_fromio(dev->dev_addr, hw->regs + B2_MAC_1 + port*8, ETH_ALEN);
diff --git a/drivers/net/skge.h b/drivers/net/skge.h
index 507addc..f055c47 100644
--- a/drivers/net/skge.h
+++ b/drivers/net/skge.h
@@ -2460,7 +2460,6 @@ struct skge_port {
 	struct timer_list    link_timer;
 	enum pause_control   flow_control;
 	enum pause_status    flow_status;
-	u8		     rx_csum;
 	u8		     blink_on;
 	u8		     wol;
 	u8		     autoneg;	/* AUTONEG_ENABLE, AUTONEG_DISABLE */
--=20
1.7.2.3

