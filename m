From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: bna: convert to hw_features
Date: Tue, 12 Apr 2011 21:38:23 +0200 (CEST)
Message-ID: <20110412193823.177C613A64@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rasesh Mody <rmody@brocade.com>, Debashis Dutt <ddutt@brocade.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:44443 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756297Ab1DLTiY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Apr 2011 15:38:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Note: looks like bnad->conf_mutex is duplicating rtnl_lock.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/bna/bnad.c         |   22 ++++++--------
 drivers/net/bna/bnad.h         |    2 -
 drivers/net/bna/bnad_ethtool.c |   63 --------------------------------=
--------
 3 files changed, 9 insertions(+), 78 deletions(-)

diff --git a/drivers/net/bna/bnad.c b/drivers/net/bna/bnad.c
index 9f356d5..b9f2534 100644
--- a/drivers/net/bna/bnad.c
+++ b/drivers/net/bna/bnad.c
@@ -501,7 +501,7 @@ bnad_poll_cq(struct bnad *bnad, struct bna_ccb *ccb=
, int budget)
=20
 		skb_put(skb, ntohs(cmpl->length));
 		if (likely
-		    (bnad->rx_csum &&
+		    ((bnad->netdev->features & NETIF_F_RXCSUM) &&
 		     (((flags & BNA_CQ_EF_IPV4) &&
 		      (flags & BNA_CQ_EF_L3_CKSUM_OK)) ||
 		      (flags & BNA_CQ_EF_IPV6)) &&
@@ -2903,23 +2903,20 @@ bnad_netdev_init(struct bnad *bnad, bool using_=
dac)
 {
 	struct net_device *netdev =3D bnad->netdev;
=20
-	netdev->features |=3D NETIF_F_IPV6_CSUM;
-	netdev->features |=3D NETIF_F_TSO;
-	netdev->features |=3D NETIF_F_TSO6;
+	netdev->hw_features =3D NETIF_F_SG | NETIF_F_RXCSUM |
+		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
+		NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_HW_VLAN_TX;
=20
-	netdev->features |=3D NETIF_F_GRO;
-	pr_warn("bna: GRO enabled, using kernel stack GRO\n");
+	netdev->vlan_features =3D NETIF_F_SG | NETIF_F_HIGHDMA |
+		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
+		NETIF_F_TSO | NETIF_F_TSO6;
=20
-	netdev->features |=3D NETIF_F_SG | NETIF_F_IP_CSUM;
+	netdev->features |=3D netdev->hw_features |
+		NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER;
=20
 	if (using_dac)
 		netdev->features |=3D NETIF_F_HIGHDMA;
=20
-	netdev->features |=3D
-		NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX |
-		NETIF_F_HW_VLAN_FILTER;
-
-	netdev->vlan_features =3D netdev->features;
 	netdev->mem_start =3D bnad->mmio_start;
 	netdev->mem_end =3D bnad->mmio_start + bnad->mmio_len - 1;
=20
@@ -2970,7 +2967,6 @@ bnad_init(struct bnad *bnad,
=20
 	bnad->txq_depth =3D BNAD_TXQ_DEPTH;
 	bnad->rxq_depth =3D BNAD_RXQ_DEPTH;
-	bnad->rx_csum =3D true;
=20
 	bnad->tx_coalescing_timeo =3D BFI_TX_COALESCING_TIMEO;
 	bnad->rx_coalescing_timeo =3D BFI_RX_COALESCING_TIMEO;
diff --git a/drivers/net/bna/bnad.h b/drivers/net/bna/bnad.h
index a89117f..ccdabad 100644
--- a/drivers/net/bna/bnad.h
+++ b/drivers/net/bna/bnad.h
@@ -237,8 +237,6 @@ struct bnad {
 	struct bna_rx_config rx_config[BNAD_MAX_RXS];
 	struct bna_tx_config tx_config[BNAD_MAX_TXS];
=20
-	u32		rx_csum;
-
 	void __iomem		*bar0;	/* BAR0 address */
=20
 	struct bna bna;
diff --git a/drivers/net/bna/bnad_ethtool.c b/drivers/net/bna/bnad_etht=
ool.c
index 142d604..c51e078e 100644
--- a/drivers/net/bna/bnad_ethtool.c
+++ b/drivers/net/bna/bnad_ethtool.c
@@ -806,61 +806,6 @@ bnad_set_pauseparam(struct net_device *netdev,
 	return 0;
 }
=20
-static u32
-bnad_get_rx_csum(struct net_device *netdev)
-{
-	u32 rx_csum;
-	struct bnad *bnad =3D netdev_priv(netdev);
-
-	rx_csum =3D bnad->rx_csum;
-	return rx_csum;
-}
-
-static int
-bnad_set_rx_csum(struct net_device *netdev, u32 rx_csum)
-{
-	struct bnad *bnad =3D netdev_priv(netdev);
-
-	mutex_lock(&bnad->conf_mutex);
-	bnad->rx_csum =3D rx_csum;
-	mutex_unlock(&bnad->conf_mutex);
-	return 0;
-}
-
-static int
-bnad_set_tx_csum(struct net_device *netdev, u32 tx_csum)
-{
-	struct bnad *bnad =3D netdev_priv(netdev);
-
-	mutex_lock(&bnad->conf_mutex);
-	if (tx_csum) {
-		netdev->features |=3D NETIF_F_IP_CSUM;
-		netdev->features |=3D NETIF_F_IPV6_CSUM;
-	} else {
-		netdev->features &=3D ~NETIF_F_IP_CSUM;
-		netdev->features &=3D ~NETIF_F_IPV6_CSUM;
-	}
-	mutex_unlock(&bnad->conf_mutex);
-	return 0;
-}
-
-static int
-bnad_set_tso(struct net_device *netdev, u32 tso)
-{
-	struct bnad *bnad =3D netdev_priv(netdev);
-
-	mutex_lock(&bnad->conf_mutex);
-	if (tso) {
-		netdev->features |=3D NETIF_F_TSO;
-		netdev->features |=3D NETIF_F_TSO6;
-	} else {
-		netdev->features &=3D ~NETIF_F_TSO;
-		netdev->features &=3D ~NETIF_F_TSO6;
-	}
-	mutex_unlock(&bnad->conf_mutex);
-	return 0;
-}
-
 static void
 bnad_get_strings(struct net_device *netdev, u32 stringset, u8 * string=
)
 {
@@ -1256,14 +1201,6 @@ static struct ethtool_ops bnad_ethtool_ops =3D {
 	.set_ringparam =3D bnad_set_ringparam,
 	.get_pauseparam =3D bnad_get_pauseparam,
 	.set_pauseparam =3D bnad_set_pauseparam,
-	.get_rx_csum =3D bnad_get_rx_csum,
-	.set_rx_csum =3D bnad_set_rx_csum,
-	.get_tx_csum =3D ethtool_op_get_tx_csum,
-	.set_tx_csum =3D bnad_set_tx_csum,
-	.get_sg =3D ethtool_op_get_sg,
-	.set_sg =3D ethtool_op_set_sg,
-	.get_tso =3D ethtool_op_get_tso,
-	.set_tso =3D bnad_set_tso,
 	.get_strings =3D bnad_get_strings,
 	.get_ethtool_stats =3D bnad_get_ethtool_stats,
 	.get_sset_count =3D bnad_get_sset_count
--=20
1.7.2.5

