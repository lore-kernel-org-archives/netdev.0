From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: infiniband/hw/nes: convert to hw_features
Date: Tue, 19 Apr 2011 12:43:20 +0200 (CEST)
Message-ID: <20110419104320.51E5F13A64@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Faisal Latif <faisal.latif@intel.com>,
	Roland Dreier <roland@kernel.org>,
	Sean Hefty <sean.hefty@intel.com>,
	Hal Rosenstock <hal.rosenstock@gmail.com>,
	linux-rdma@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:46860 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754568Ab1DSKnV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2011 06:43:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/infiniband/hw/nes/nes_hw.c  |    5 +--
 drivers/infiniband/hw/nes/nes_hw.h  |    1 -
 drivers/infiniband/hw/nes/nes_nic.c |   55 +++------------------------=
-------
 3 files changed, 7 insertions(+), 54 deletions(-)

diff --git a/drivers/infiniband/hw/nes/nes_hw.c b/drivers/infiniband/hw=
/nes/nes_hw.c
index 10d0a5e..96fa9a4 100644
--- a/drivers/infiniband/hw/nes/nes_hw.c
+++ b/drivers/infiniband/hw/nes/nes_hw.c
@@ -2885,9 +2885,8 @@ void nes_nic_ce_handler(struct nes_device *nesdev=
, struct nes_hw_nic_cq *cq)
 					if ((cqe_errv &
 							(NES_NIC_ERRV_BITS_IPV4_CSUM_ERR | NES_NIC_ERRV_BITS_TCPUDP_CSU=
M_ERR |
 							NES_NIC_ERRV_BITS_IPH_ERR | NES_NIC_ERRV_BITS_WQE_OVERRUN)) =3D=
=3D 0) {
-						if (nesvnic->rx_checksum_disabled =3D=3D 0) {
+						if (nesvnic->netdev->features & NETIF_F_RXCSUM)
 							rx_skb->ip_summed =3D CHECKSUM_UNNECESSARY;
-						}
 					} else
 						nes_debug(NES_DBG_CQ, "%s: unsuccessfully checksummed TCP or UDP=
 packet."
 								" errv =3D 0x%X, pkt_type =3D 0x%X.\n",
@@ -2897,7 +2896,7 @@ void nes_nic_ce_handler(struct nes_device *nesdev=
, struct nes_hw_nic_cq *cq)
 					if ((cqe_errv &
 							(NES_NIC_ERRV_BITS_IPV4_CSUM_ERR | NES_NIC_ERRV_BITS_IPH_ERR |
 							NES_NIC_ERRV_BITS_WQE_OVERRUN)) =3D=3D 0) {
-						if (nesvnic->rx_checksum_disabled =3D=3D 0) {
+						if (nesvnic->netdev->features & NETIF_F_RXCSUM) {
 							rx_skb->ip_summed =3D CHECKSUM_UNNECESSARY;
 							/* nes_debug(NES_DBG_CQ, "%s: Reporting successfully checksumme=
d IPv4 packet.\n",
 								  nesvnic->netdev->name); */
diff --git a/drivers/infiniband/hw/nes/nes_hw.h b/drivers/infiniband/hw=
/nes/nes_hw.h
index d2abe07..9159411 100644
--- a/drivers/infiniband/hw/nes/nes_hw.h
+++ b/drivers/infiniband/hw/nes/nes_hw.h
@@ -1245,7 +1245,6 @@ struct nes_vnic {
 	u8  next_qp_nic_index;
 	u8  of_device_registered;
 	u8  rdma_enabled;
-	u8  rx_checksum_disabled;
 	u32 lro_max_aggr;
 	struct net_lro_mgr lro_mgr;
 	struct net_lro_desc lro_desc[NES_MAX_LRO_DESCRIPTORS];
diff --git a/drivers/infiniband/hw/nes/nes_nic.c b/drivers/infiniband/h=
w/nes/nes_nic.c
index e96b8fb..d2e67c4 100644
--- a/drivers/infiniband/hw/nes/nes_nic.c
+++ b/drivers/infiniband/hw/nes/nes_nic.c
@@ -1093,34 +1093,6 @@ static const char nes_ethtool_stringset[][ETH_GS=
TRING_LEN] =3D {
 };
 #define NES_ETHTOOL_STAT_COUNT  ARRAY_SIZE(nes_ethtool_stringset)
=20
-/**
- * nes_netdev_get_rx_csum
- */
-static u32 nes_netdev_get_rx_csum (struct net_device *netdev)
-{
-	struct nes_vnic *nesvnic =3D netdev_priv(netdev);
-
-	if (nesvnic->rx_checksum_disabled)
-		return 0;
-	else
-		return 1;
-}
-
-
-/**
- * nes_netdev_set_rc_csum
- */
-static int nes_netdev_set_rx_csum(struct net_device *netdev, u32 enabl=
e)
-{
-	struct nes_vnic *nesvnic =3D netdev_priv(netdev);
-
-	if (enable)
-		nesvnic->rx_checksum_disabled =3D 0;
-	else
-		nesvnic->rx_checksum_disabled =3D 1;
-	return 0;
-}
-
=20
 /**
  * nes_netdev_get_sset_count
@@ -1598,19 +1570,10 @@ static int nes_netdev_set_settings(struct net_d=
evice *netdev, struct ethtool_cmd
 }
=20
=20
-static int nes_netdev_set_flags(struct net_device *netdev, u32 flags)
-{
-	return ethtool_op_set_flags(netdev, flags, ETH_FLAG_LRO);
-}
-
-
 static const struct ethtool_ops nes_ethtool_ops =3D {
 	.get_link =3D ethtool_op_get_link,
 	.get_settings =3D nes_netdev_get_settings,
 	.set_settings =3D nes_netdev_set_settings,
-	.get_tx_csum =3D ethtool_op_get_tx_csum,
-	.get_rx_csum =3D nes_netdev_get_rx_csum,
-	.get_sg =3D ethtool_op_get_sg,
 	.get_strings =3D nes_netdev_get_strings,
 	.get_sset_count =3D nes_netdev_get_sset_count,
 	.get_ethtool_stats =3D nes_netdev_get_ethtool_stats,
@@ -1619,13 +1582,6 @@ static const struct ethtool_ops nes_ethtool_ops =
=3D {
 	.set_coalesce =3D nes_netdev_set_coalesce,
 	.get_pauseparam =3D nes_netdev_get_pauseparam,
 	.set_pauseparam =3D nes_netdev_set_pauseparam,
-	.set_tx_csum =3D ethtool_op_set_tx_csum,
-	.set_rx_csum =3D nes_netdev_set_rx_csum,
-	.set_sg =3D ethtool_op_set_sg,
-	.get_tso =3D ethtool_op_get_tso,
-	.set_tso =3D ethtool_op_set_tso,
-	.get_flags =3D ethtool_op_get_flags,
-	.set_flags =3D nes_netdev_set_flags,
 };
=20
=20
@@ -1727,12 +1683,11 @@ struct net_device *nes_netdev_init(struct nes_d=
evice *nesdev,
 	netdev->dev_addr[5] =3D (u8)u64temp;
 	memcpy(netdev->perm_addr, netdev->dev_addr, 6);
=20
-	if ((nesvnic->logical_port < 2) || (nesdev->nesadapter->hw_rev !=3D N=
E020_REV)) {
-		netdev->features |=3D NETIF_F_TSO | NETIF_F_SG | NETIF_F_IP_CSUM;
-		netdev->features |=3D NETIF_F_GSO | NETIF_F_TSO | NETIF_F_SG | NETIF=
_F_IP_CSUM;
-	} else {
-		netdev->features |=3D NETIF_F_SG | NETIF_F_IP_CSUM;
-	}
+	netdev->hw_features =3D NETIF_F_RXCSUM | NETIF_F_SG | NETIF_F_IP_CSUM=
;
+	if ((nesvnic->logical_port < 2) || (nesdev->nesadapter->hw_rev !=3D N=
E020_REV))
+		netdev->hw_features |=3D NETIF_F_TSO;
+	netdev->features |=3D netdev->hw_features;
+	netdev->hw_features |=3D NETIF_F_LRO;
=20
 	nes_debug(NES_DBG_INIT, "nesvnic =3D %p, reported features =3D 0x%lX,=
 QPid =3D %d,"
 			" nic_index =3D %d, logical_port =3D %d, mac_index =3D %d.\n",
--=20
1.7.2.5

