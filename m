From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: greth: convert to hw_features
Date: Sun, 17 Apr 2011 12:15:47 +0200 (CEST)
Message-ID: <20110417101547.D59E313A6F@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kristoffer Glembo <kristoffer@gaisler.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:48113 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755381Ab1DQKPw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Apr 2011 06:15:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Note: Driver modifies its struct net_device_ops. This will break if use=
d for
multiple devices that are not all the same (if that HW config is possib=
le).

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/greth.c |   46 ++++---------------------------------------=
---
 drivers/net/greth.h |    4 ----
 2 files changed, 4 insertions(+), 46 deletions(-)

diff --git a/drivers/net/greth.c b/drivers/net/greth.c
index 396ff7d..f181304 100644
--- a/drivers/net/greth.c
+++ b/drivers/net/greth.c
@@ -901,7 +901,7 @@ static int greth_rx_gbit(struct net_device *dev, in=
t limit)
=20
 				skb_put(skb, pkt_len);
=20
-				if (greth->flags & GRETH_FLAG_RX_CSUM && hw_checksummed(status))
+				if (dev->features & NETIF_F_RXCSUM && hw_checksummed(status))
 					skb->ip_summed =3D CHECKSUM_UNNECESSARY;
 				else
 					skb_checksum_none_assert(skb);
@@ -1142,41 +1142,6 @@ static void greth_get_regs(struct net_device *de=
v, struct ethtool_regs *regs, vo
 		buff[i] =3D greth_read_bd(&greth_regs[i]);
 }
=20
-static u32 greth_get_rx_csum(struct net_device *dev)
-{
-	struct greth_private *greth =3D netdev_priv(dev);
-	return (greth->flags & GRETH_FLAG_RX_CSUM) !=3D 0;
-}
-
-static int greth_set_rx_csum(struct net_device *dev, u32 data)
-{
-	struct greth_private *greth =3D netdev_priv(dev);
-
-	spin_lock_bh(&greth->devlock);
-
-	if (data)
-		greth->flags |=3D GRETH_FLAG_RX_CSUM;
-	else
-		greth->flags &=3D ~GRETH_FLAG_RX_CSUM;
-
-	spin_unlock_bh(&greth->devlock);
-
-	return 0;
-}
-
-static u32 greth_get_tx_csum(struct net_device *dev)
-{
-	return (dev->features & NETIF_F_IP_CSUM) !=3D 0;
-}
-
-static int greth_set_tx_csum(struct net_device *dev, u32 data)
-{
-	netif_tx_lock_bh(dev);
-	ethtool_op_set_tx_csum(dev, data);
-	netif_tx_unlock_bh(dev);
-	return 0;
-}
-
 static const struct ethtool_ops greth_ethtool_ops =3D {
 	.get_msglevel		=3D greth_get_msglevel,
 	.set_msglevel		=3D greth_set_msglevel,
@@ -1185,10 +1150,6 @@ static const struct ethtool_ops greth_ethtool_op=
s =3D {
 	.get_drvinfo		=3D greth_get_drvinfo,
 	.get_regs_len           =3D greth_get_regs_len,
 	.get_regs               =3D greth_get_regs,
-	.get_rx_csum		=3D greth_get_rx_csum,
-	.set_rx_csum		=3D greth_set_rx_csum,
-	.get_tx_csum		=3D greth_get_tx_csum,
-	.set_tx_csum		=3D greth_set_tx_csum,
 	.get_link		=3D ethtool_op_get_link,
 };
=20
@@ -1570,9 +1531,10 @@ static int __devinit greth_of_probe(struct platf=
orm_device *ofdev)
 	GRETH_REGSAVE(regs->status, 0xFF);
=20
 	if (greth->gbit_mac) {
-		dev->features =3D NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_HIGHDMA;
+		dev->hw_features =3D NETIF_F_SG | NETIF_F_IP_CSUM |
+			NETIF_F_RXCSUM;
+		dev->features =3D dev->hw_features | NETIF_F_HIGHDMA;
 		greth_netdev_ops.ndo_start_xmit =3D greth_start_xmit_gbit;
-		greth->flags =3D GRETH_FLAG_RX_CSUM;
 	}
=20
 	if (greth->multicast) {
diff --git a/drivers/net/greth.h b/drivers/net/greth.h
index be0f206..9a0040d 100644
--- a/drivers/net/greth.h
+++ b/drivers/net/greth.h
@@ -77,9 +77,6 @@
  */
 #define MAX_FRAME_SIZE		1520
=20
-/* Flags */
-#define GRETH_FLAG_RX_CSUM 0x1
-
 /* GRETH APB registers */
 struct greth_regs {
 	u32 control;
@@ -133,7 +130,6 @@ struct greth_private {
 	unsigned int duplex;
=20
 	u32 msg_enable;
-	u32 flags;
=20
 	u8 phyaddr;
 	u8 multicast;
--=20
1.7.2.5

