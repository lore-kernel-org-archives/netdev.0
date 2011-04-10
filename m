From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: bnx2: convert to hw_features
Date: Sun, 10 Apr 2011 16:47:46 +0200 (CEST)
Message-ID: <20110410144746.AAFBF13A64@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Chan <mchan@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:52576 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753136Ab1DJOrs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Apr 2011 10:47:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/bnx2.c |  109 +++++++++++++-------------------------------=
-------
 drivers/net/bnx2.h |    2 -
 2 files changed, 28 insertions(+), 83 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 05ddfb1..0a52079 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -3174,7 +3174,7 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bn=
api, int budget)
 		}
=20
 		skb_checksum_none_assert(skb);
-		if (bp->rx_csum &&
+		if ((bp->dev->features & NETIF_F_RXCSUM) &&
 			(status & (L2_FHDR_STATUS_TCP_SEGMENT |
 			L2_FHDR_STATUS_UDP_DATAGRAM))) {
=20
@@ -7189,38 +7189,6 @@ bnx2_set_pauseparam(struct net_device *dev, stru=
ct ethtool_pauseparam *epause)
 	return 0;
 }
=20
-static u32
-bnx2_get_rx_csum(struct net_device *dev)
-{
-	struct bnx2 *bp =3D netdev_priv(dev);
-
-	return bp->rx_csum;
-}
-
-static int
-bnx2_set_rx_csum(struct net_device *dev, u32 data)
-{
-	struct bnx2 *bp =3D netdev_priv(dev);
-
-	bp->rx_csum =3D data;
-	return 0;
-}
-
-static int
-bnx2_set_tso(struct net_device *dev, u32 data)
-{
-	struct bnx2 *bp =3D netdev_priv(dev);
-
-	if (data) {
-		dev->features |=3D NETIF_F_TSO | NETIF_F_TSO_ECN;
-		if (CHIP_NUM(bp) =3D=3D CHIP_NUM_5709)
-			dev->features |=3D NETIF_F_TSO6;
-	} else
-		dev->features &=3D ~(NETIF_F_TSO | NETIF_F_TSO6 |
-				   NETIF_F_TSO_ECN);
-	return 0;
-}
-
 static struct {
 	char string[ETH_GSTRING_LEN];
 } bnx2_stats_str_arr[] =3D {
@@ -7532,43 +7500,37 @@ bnx2_set_phys_id(struct net_device *dev, enum e=
thtool_phys_id_state state)
 	return 0;
 }
=20
-static int
-bnx2_set_tx_csum(struct net_device *dev, u32 data)
+static u32
+bnx2_fix_features(struct net_device *dev, u32 features)
 {
 	struct bnx2 *bp =3D netdev_priv(dev);
=20
-	if (CHIP_NUM(bp) =3D=3D CHIP_NUM_5709)
-		return ethtool_op_set_tx_ipv6_csum(dev, data);
-	else
-		return ethtool_op_set_tx_csum(dev, data);
+	if (!(bp->flags & BNX2_FLAG_CAN_KEEP_VLAN))
+		features |=3D NETIF_F_HW_VLAN_RX;
+
+	return features;
 }
=20
 static int
-bnx2_set_flags(struct net_device *dev, u32 data)
+bnx2_set_features(struct net_device *dev, u32 features)
 {
 	struct bnx2 *bp =3D netdev_priv(dev);
-	int rc;
-
-	if (!(bp->flags & BNX2_FLAG_CAN_KEEP_VLAN) &&
-	    !(data & ETH_FLAG_RXVLAN))
-		return -EINVAL;
=20
 	/* TSO with VLAN tag won't work with current firmware */
-	if (!(data & ETH_FLAG_TXVLAN))
-		return -EINVAL;
+	if (features & NETIF_F_HW_VLAN_TX)
+		dev->vlan_features |=3D (dev->hw_features & NETIF_F_ALL_TSO);
+	else
+		dev->vlan_features &=3D ~NETIF_F_ALL_TSO;
=20
-	rc =3D ethtool_op_set_flags(dev, data, ETH_FLAG_RXHASH | ETH_FLAG_RXV=
LAN |
-				  ETH_FLAG_TXVLAN);
-	if (rc)
-		return rc;
-
-	if ((!!(data & ETH_FLAG_RXVLAN) !=3D
+	if ((!!(features & NETIF_F_HW_VLAN_RX) !=3D
 	    !!(bp->rx_mode & BNX2_EMAC_RX_MODE_KEEP_VLAN_TAG)) &&
 	    netif_running(dev)) {
 		bnx2_netif_stop(bp, false);
+		dev->features =3D features;
 		bnx2_set_rx_mode(dev);
 		bnx2_fw_sync(bp, BNX2_DRV_MSG_CODE_KEEP_VLAN_UPDATE, 0, 1);
 		bnx2_netif_start(bp, false);
+		return 1;
 	}
=20
 	return 0;
@@ -7593,18 +7555,11 @@ static const struct ethtool_ops bnx2_ethtool_op=
s =3D {
 	.set_ringparam		=3D bnx2_set_ringparam,
 	.get_pauseparam		=3D bnx2_get_pauseparam,
 	.set_pauseparam		=3D bnx2_set_pauseparam,
-	.get_rx_csum		=3D bnx2_get_rx_csum,
-	.set_rx_csum		=3D bnx2_set_rx_csum,
-	.set_tx_csum		=3D bnx2_set_tx_csum,
-	.set_sg			=3D ethtool_op_set_sg,
-	.set_tso		=3D bnx2_set_tso,
 	.self_test		=3D bnx2_self_test,
 	.get_strings		=3D bnx2_get_strings,
 	.set_phys_id		=3D bnx2_set_phys_id,
 	.get_ethtool_stats	=3D bnx2_get_ethtool_stats,
 	.get_sset_count		=3D bnx2_get_sset_count,
-	.set_flags		=3D bnx2_set_flags,
-	.get_flags		=3D ethtool_op_get_flags,
 };
=20
 /* Called with rtnl_lock */
@@ -8116,8 +8071,6 @@ bnx2_init_board(struct pci_dev *pdev, struct net_=
device *dev)
 	bp->tx_ring_size =3D MAX_TX_DESC_CNT;
 	bnx2_set_rx_ring_size(bp, 255);
=20
-	bp->rx_csum =3D 1;
-
 	bp->tx_quick_cons_trip_int =3D 2;
 	bp->tx_quick_cons_trip =3D 20;
 	bp->tx_ticks_int =3D 18;
@@ -8309,17 +8262,14 @@ static const struct net_device_ops bnx2_netdev_=
ops =3D {
 	.ndo_validate_addr	=3D eth_validate_addr,
 	.ndo_set_mac_address	=3D bnx2_change_mac_addr,
 	.ndo_change_mtu		=3D bnx2_change_mtu,
+	.ndo_fix_features	=3D bnx2_fix_features,
+	.ndo_set_features	=3D bnx2_set_features,
 	.ndo_tx_timeout		=3D bnx2_tx_timeout,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	=3D poll_bnx2,
 #endif
 };
=20
-static inline void vlan_features_add(struct net_device *dev, u32 flags=
)
-{
-	dev->vlan_features |=3D flags;
-}
-
 static int __devinit
 bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
@@ -8359,20 +8309,17 @@ bnx2_init_one(struct pci_dev *pdev, const struc=
t pci_device_id *ent)
 	memcpy(dev->dev_addr, bp->mac_addr, 6);
 	memcpy(dev->perm_addr, bp->mac_addr, 6);
=20
-	dev->features |=3D NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_GRO |
-			 NETIF_F_RXHASH;
-	vlan_features_add(dev, NETIF_F_IP_CSUM | NETIF_F_SG);
-	if (CHIP_NUM(bp) =3D=3D CHIP_NUM_5709) {
-		dev->features |=3D NETIF_F_IPV6_CSUM;
-		vlan_features_add(dev, NETIF_F_IPV6_CSUM);
-	}
-	dev->features |=3D NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-	dev->features |=3D NETIF_F_TSO | NETIF_F_TSO_ECN;
-	vlan_features_add(dev, NETIF_F_TSO | NETIF_F_TSO_ECN);
-	if (CHIP_NUM(bp) =3D=3D CHIP_NUM_5709) {
-		dev->features |=3D NETIF_F_TSO6;
-		vlan_features_add(dev, NETIF_F_TSO6);
-	}
+	dev->hw_features =3D NETIF_F_IP_CSUM | NETIF_F_SG |
+		NETIF_F_TSO | NETIF_F_TSO_ECN |
+		NETIF_F_RXHASH | NETIF_F_RXCSUM;
+
+	if (CHIP_NUM(bp) =3D=3D CHIP_NUM_5709)
+		dev->hw_features |=3D NETIF_F_IPV6_CSUM | NETIF_F_TSO6;
+
+	dev->vlan_features =3D dev->hw_features;
+	dev->hw_features |=3D NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
+	dev->features |=3D dev->hw_features;
+
 	if ((rc =3D register_netdev(dev))) {
 		dev_err(&pdev->dev, "Cannot register net device\n");
 		goto error;
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 91e8356..bf371f6 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6754,8 +6754,6 @@ struct bnx2 {
 	u32			rx_max_ring_idx;
 	u32			rx_max_pg_ring_idx;
=20
-	u32			rx_csum;
-
 	/* TX constants */
 	int		tx_ring_size;
 	u32		tx_wake_thresh;
--=20
1.7.2.5

