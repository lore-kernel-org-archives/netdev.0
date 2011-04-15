From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: dm9000: convert to hw_features
Date: Fri, 15 Apr 2011 16:50:49 +0200 (CEST)
Message-ID: <20110415145050.0222B13A68@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Dooks <ben-linux@fluff.org>,
	Henry Nestler <henry.nestler@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:46538 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756259Ab1DOOuw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Apr 2011 10:50:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/dm9000.c |   57 +++++++++++-------------------------------=
-------
 1 files changed, 13 insertions(+), 44 deletions(-)

diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index b7af5ba..f7bdebb 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -131,8 +131,6 @@ typedef struct board_info {
 	u32		msg_enable;
 	u32		wake_state;
=20
-	int		rx_csum;
-	int		can_csum;
 	int		ip_summed;
 } board_info_t;
=20
@@ -470,47 +468,20 @@ static int dm9000_nway_reset(struct net_device *d=
ev)
 	return mii_nway_restart(&dm->mii);
 }
=20
-static uint32_t dm9000_get_rx_csum(struct net_device *dev)
+static int dm9000_set_features(struct net_device *dev, u32 features)
 {
 	board_info_t *dm =3D to_dm9000_board(dev);
-	return dm->rx_csum;
-}
-
-static int dm9000_set_rx_csum_unlocked(struct net_device *dev, uint32_=
t data)
-{
-	board_info_t *dm =3D to_dm9000_board(dev);
-
-	if (dm->can_csum) {
-		dm->rx_csum =3D data;
-		iow(dm, DM9000_RCSR, dm->rx_csum ? RCSR_CSUM : 0);
+	u32 changed =3D dev->features ^ features;
+	unsigned long flags;
=20
+	if (!(changed & NETIF_F_RXCSUM))
 		return 0;
-	}
-
-	return -EOPNOTSUPP;
-}
-
-static int dm9000_set_rx_csum(struct net_device *dev, uint32_t data)
-{
-	board_info_t *dm =3D to_dm9000_board(dev);
-	unsigned long flags;
-	int ret;
=20
 	spin_lock_irqsave(&dm->lock, flags);
-	ret =3D dm9000_set_rx_csum_unlocked(dev, data);
+	iow(dm, DM9000_RCSR, (features & NETIF_F_RXCSUM) ? RCSR_CSUM : 0);
 	spin_unlock_irqrestore(&dm->lock, flags);
=20
-	return ret;
-}
-
-static int dm9000_set_tx_csum(struct net_device *dev, uint32_t data)
-{
-	board_info_t *dm =3D to_dm9000_board(dev);
-	int ret =3D -EOPNOTSUPP;
-
-	if (dm->can_csum)
-		ret =3D ethtool_op_set_tx_csum(dev, data);
-	return ret;
+	return 0;
 }
=20
 static u32 dm9000_get_link(struct net_device *dev)
@@ -643,10 +614,6 @@ static const struct ethtool_ops dm9000_ethtool_ops=
 =3D {
  	.get_eeprom_len		=3D dm9000_get_eeprom_len,
  	.get_eeprom		=3D dm9000_get_eeprom,
  	.set_eeprom		=3D dm9000_set_eeprom,
-	.get_rx_csum		=3D dm9000_get_rx_csum,
-	.set_rx_csum		=3D dm9000_set_rx_csum,
-	.get_tx_csum		=3D ethtool_op_get_tx_csum,
-	.set_tx_csum		=3D dm9000_set_tx_csum,
 };
=20
 static void dm9000_show_carrier(board_info_t *db,
@@ -800,7 +767,9 @@ dm9000_init_dm9000(struct net_device *dev)
 	db->io_mode =3D ior(db, DM9000_ISR) >> 6;	/* ISR bit7:6 keeps I/O mod=
e */
=20
 	/* Checksum mode */
-	dm9000_set_rx_csum_unlocked(dev, db->rx_csum);
+	if (dev->hw_features & NETIF_F_RXCSUM)
+		iow(dm, DM9000_RCSR,
+			(dev->features & NETIF_F_RXCSUM) ? RCSR_CSUM : 0);
=20
 	iow(db, DM9000_GPCR, GPCR_GEP_CNTL);	/* Let GPIO0 output */
=20
@@ -1049,7 +1018,7 @@ dm9000_rx(struct net_device *dev)
=20
 			/* Pass to upper layer */
 			skb->protocol =3D eth_type_trans(skb, dev);
-			if (db->rx_csum) {
+			if (dev->features & NETIF_F_RXCSUM) {
 				if ((((rxbyte & 0x1c) << 3) & rxbyte) =3D=3D 0)
 					skb->ip_summed =3D CHECKSUM_UNNECESSARY;
 				else
@@ -1358,6 +1327,7 @@ static const struct net_device_ops dm9000_netdev_=
ops =3D {
 	.ndo_set_multicast_list	=3D dm9000_hash_table,
 	.ndo_do_ioctl		=3D dm9000_ioctl,
 	.ndo_change_mtu		=3D eth_change_mtu,
+	.ndo_set_features	=3D dm9000_set_features,
 	.ndo_validate_addr	=3D eth_validate_addr,
 	.ndo_set_mac_address	=3D eth_mac_addr,
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -1551,9 +1521,8 @@ dm9000_probe(struct platform_device *pdev)
=20
 	/* dm9000a/b are capable of hardware checksum offload */
 	if (db->type =3D=3D TYPE_DM9000A || db->type =3D=3D TYPE_DM9000B) {
-		db->can_csum =3D 1;
-		db->rx_csum =3D 1;
-		ndev->features |=3D NETIF_F_IP_CSUM;
+		ndev->hw_features =3D NETIF_F_RXCSUM | NETIF_F_IP_CSUM;
+		ndev->features |=3D ndev->hw_features;
 	}
=20
 	/* from this point we assume that we have found a DM9000 */
--=20
1.7.2.5

