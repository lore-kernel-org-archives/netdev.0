From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: benet: convert to hw_features
Date: Thu,  7 Apr 2011 14:43:48 +0200 (CEST)
Message-ID: <20110407124348.A8F1E13909@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:52330 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756100Ab1DGMnu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2011 08:43:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simple conversion.

This also fixes a bug in TX checksum toggling --- driver was changing
NETIF_F_HW_CSUM instead of NETIF_F_IP_CSUM+NETIF_F_IPV6_CSUM.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/benet/be.h         |    1 -
 drivers/net/benet/be_ethtool.c |   27 ---------------------------
 drivers/net/benet/be_main.c    |   19 ++++++++++---------
 3 files changed, 10 insertions(+), 37 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 0899d91..30d52b0 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -309,7 +309,6 @@ struct be_adapter {
 	u16 work_counter;
=20
 	/* Ethtool knobs and info */
-	bool rx_csum; 		/* BE card must perform rx-checksumming */
 	char fw_ver[FW_VER_LEN];
 	u32 if_handle;		/* Used to configure filtering */
 	u32 pmac_id;		/* MAC addr handle used by BE card */
diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_etht=
ool.c
index a665697..bc8ba8d 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -261,25 +261,6 @@ be_set_coalesce(struct net_device *netdev, struct =
ethtool_coalesce *coalesce)
 	return 0;
 }
=20
-static u32 be_get_rx_csum(struct net_device *netdev)
-{
-	struct be_adapter *adapter =3D netdev_priv(netdev);
-
-	return adapter->rx_csum;
-}
-
-static int be_set_rx_csum(struct net_device *netdev, uint32_t data)
-{
-	struct be_adapter *adapter =3D netdev_priv(netdev);
-
-	if (data)
-		adapter->rx_csum =3D true;
-	else
-		adapter->rx_csum =3D false;
-
-	return 0;
-}
-
 static void
 be_get_ethtool_stats(struct net_device *netdev,
 		struct ethtool_stats *stats, uint64_t *data)
@@ -748,14 +729,6 @@ const struct ethtool_ops be_ethtool_ops =3D {
 	.get_ringparam =3D be_get_ringparam,
 	.get_pauseparam =3D be_get_pauseparam,
 	.set_pauseparam =3D be_set_pauseparam,
-	.get_rx_csum =3D be_get_rx_csum,
-	.set_rx_csum =3D be_set_rx_csum,
-	.get_tx_csum =3D ethtool_op_get_tx_csum,
-	.set_tx_csum =3D ethtool_op_set_tx_hw_csum,
-	.get_sg =3D ethtool_op_get_sg,
-	.set_sg =3D ethtool_op_set_sg,
-	.get_tso =3D ethtool_op_get_tso,
-	.set_tso =3D ethtool_op_set_tso,
 	.get_strings =3D be_get_stat_strings,
 	.set_phys_id =3D be_set_phys_id,
 	.get_sset_count =3D be_get_sset_count,
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index a24fb45..41816a7 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -993,9 +993,10 @@ static void be_rx_compl_process(struct be_adapter =
*adapter,
 			struct be_rx_obj *rxo,
 			struct be_rx_compl_info *rxcp)
 {
+	struct net_device *netdev =3D adapter->netdev;
 	struct sk_buff *skb;
=20
-	skb =3D netdev_alloc_skb_ip_align(adapter->netdev, BE_HDR_LEN);
+	skb =3D netdev_alloc_skb_ip_align(netdev, BE_HDR_LEN);
 	if (unlikely(!skb)) {
 		if (net_ratelimit())
 			dev_warn(&adapter->pdev->dev, "skb alloc failed\n");
@@ -1005,13 +1006,13 @@ static void be_rx_compl_process(struct be_adapt=
er *adapter,
=20
 	skb_fill_rx_data(adapter, rxo, skb, rxcp);
=20
-	if (likely(adapter->rx_csum && csum_passed(rxcp)))
+	if (likely((netdev->features & NETIF_F_RXCSUM) && csum_passed(rxcp)))
 		skb->ip_summed =3D CHECKSUM_UNNECESSARY;
 	else
 		skb_checksum_none_assert(skb);
=20
 	skb->truesize =3D skb->len + sizeof(struct sk_buff);
-	skb->protocol =3D eth_type_trans(skb, adapter->netdev);
+	skb->protocol =3D eth_type_trans(skb, netdev);
=20
 	if (unlikely(rxcp->vlanf)) {
 		if (!adapter->vlan_grp || adapter->vlans_added =3D=3D 0) {
@@ -2609,10 +2610,12 @@ static void be_netdev_init(struct net_device *n=
etdev)
 	struct be_rx_obj *rxo;
 	int i;
=20
-	netdev->features |=3D NETIF_F_SG | NETIF_F_HW_VLAN_RX | NETIF_F_TSO |
-		NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_FILTER |
-		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
-		NETIF_F_GRO | NETIF_F_TSO6;
+	netdev->hw_features |=3D NETIF_F_SG | NETIF_F_TSO | NETIF_F_TSO6 |
+		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM | NETIF_F_RXCSUM;
+
+	netdev->features |=3D netdev->hw_features |
+		NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_TX |
+		NETIF_F_HW_VLAN_FILTER;
=20
 	netdev->vlan_features |=3D NETIF_F_SG | NETIF_F_TSO |
 		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
@@ -2622,8 +2625,6 @@ static void be_netdev_init(struct net_device *net=
dev)
=20
 	netdev->flags |=3D IFF_MULTICAST;
=20
-	adapter->rx_csum =3D true;
-
 	/* Default settings for Rx and Tx flow control */
 	adapter->rx_fc =3D true;
 	adapter->tx_fc =3D true;
--=20
1.7.2.5

