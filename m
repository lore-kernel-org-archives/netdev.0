From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: enic: convert to hw_features
Date: Thu,  7 Apr 2011 14:43:48 +0200 (CEST)
Message-ID: <20110407124348.BB13A138ED@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christian Benvenuti <benve@cisco.com>,
	Vasanthy Kolluri <vkolluri@cisco.com>,
	Roopa Prabhu <roprabhu@cisco.com>,
	David Wang <dwang2@cisco.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:52331 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753437Ab1DGMnu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2011 08:43:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As the driver uses GRO and not LRO, LRO settings are ignored anyway
and are removed here to avoid confusion.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/enic/enic.h      |    1 -
 drivers/net/enic/enic_main.c |   74 ++++------------------------------=
-------
 drivers/net/enic/enic_res.c  |    4 +-
 3 files changed, 10 insertions(+), 69 deletions(-)

diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index 178b94d..38b351c 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -84,7 +84,6 @@ struct enic {
 	unsigned int flags;
 	unsigned int mc_count;
 	unsigned int uc_count;
-	int csum_rx_enabled;
 	u32 port_mtu;
 	u32 rx_coalesce_usecs;
 	u32 tx_coalesce_usecs;
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.=
c
index 9a3a027..b224551 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -251,56 +251,6 @@ static void enic_get_ethtool_stats(struct net_devi=
ce *netdev,
 		*(data++) =3D ((u64 *)&vstats->rx)[enic_rx_stats[i].offset];
 }
=20
-static u32 enic_get_rx_csum(struct net_device *netdev)
-{
-	struct enic *enic =3D netdev_priv(netdev);
-	return enic->csum_rx_enabled;
-}
-
-static int enic_set_rx_csum(struct net_device *netdev, u32 data)
-{
-	struct enic *enic =3D netdev_priv(netdev);
-
-	if (data && !ENIC_SETTING(enic, RXCSUM))
-		return -EINVAL;
-
-	enic->csum_rx_enabled =3D !!data;
-
-	return 0;
-}
-
-static int enic_set_tx_csum(struct net_device *netdev, u32 data)
-{
-	struct enic *enic =3D netdev_priv(netdev);
-
-	if (data && !ENIC_SETTING(enic, TXCSUM))
-		return -EINVAL;
-
-	if (data)
-		netdev->features |=3D NETIF_F_HW_CSUM;
-	else
-		netdev->features &=3D ~NETIF_F_HW_CSUM;
-
-	return 0;
-}
-
-static int enic_set_tso(struct net_device *netdev, u32 data)
-{
-	struct enic *enic =3D netdev_priv(netdev);
-
-	if (data && !ENIC_SETTING(enic, TSO))
-		return -EINVAL;
-
-	if (data)
-		netdev->features |=3D
-			NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_TSO_ECN;
-	else
-		netdev->features &=3D
-			~(NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_TSO_ECN);
-
-	return 0;
-}
-
 static u32 enic_get_msglevel(struct net_device *netdev)
 {
 	struct enic *enic =3D netdev_priv(netdev);
@@ -388,17 +338,8 @@ static const struct ethtool_ops enic_ethtool_ops =3D=
 {
 	.get_strings =3D enic_get_strings,
 	.get_sset_count =3D enic_get_sset_count,
 	.get_ethtool_stats =3D enic_get_ethtool_stats,
-	.get_rx_csum =3D enic_get_rx_csum,
-	.set_rx_csum =3D enic_set_rx_csum,
-	.get_tx_csum =3D ethtool_op_get_tx_csum,
-	.set_tx_csum =3D enic_set_tx_csum,
-	.get_sg =3D ethtool_op_get_sg,
-	.set_sg =3D ethtool_op_set_sg,
-	.get_tso =3D ethtool_op_get_tso,
-	.set_tso =3D enic_set_tso,
 	.get_coalesce =3D enic_get_coalesce,
 	.set_coalesce =3D enic_set_coalesce,
-	.get_flags =3D ethtool_op_get_flags,
 };
=20
 static void enic_free_wq_buf(struct vnic_wq *wq, struct vnic_wq_buf *b=
uf)
@@ -1309,7 +1250,7 @@ static void enic_rq_indicate_buf(struct vnic_rq *=
rq,
 		skb_put(skb, bytes_written);
 		skb->protocol =3D eth_type_trans(skb, netdev);
=20
-		if (enic->csum_rx_enabled && !csum_not_calc) {
+		if ((netdev->features & NETIF_F_RXCSUM) && !csum_not_calc) {
 			skb->csum =3D htons(checksum);
 			skb->ip_summed =3D CHECKSUM_COMPLETE;
 		}
@@ -2438,17 +2379,18 @@ static int __devinit enic_probe(struct pci_dev =
*pdev,
 		dev_info(dev, "loopback tag=3D0x%04x\n", enic->loop_tag);
 	}
 	if (ENIC_SETTING(enic, TXCSUM))
-		netdev->features |=3D NETIF_F_SG | NETIF_F_HW_CSUM;
+		netdev->hw_features |=3D NETIF_F_SG | NETIF_F_HW_CSUM;
 	if (ENIC_SETTING(enic, TSO))
-		netdev->features |=3D NETIF_F_TSO |
+		netdev->hw_features |=3D NETIF_F_TSO |
 			NETIF_F_TSO6 | NETIF_F_TSO_ECN;
-	if (ENIC_SETTING(enic, LRO))
-		netdev->features |=3D NETIF_F_GRO;
+	if (ENIC_SETTING(enic, RXCSUM))
+		netdev->hw_features |=3D NETIF_F_RXCSUM;
+
+	netdev->features |=3D netdev->hw_features;
+
 	if (using_dac)
 		netdev->features |=3D NETIF_F_HIGHDMA;
=20
-	enic->csum_rx_enabled =3D ENIC_SETTING(enic, RXCSUM);
-
 	err =3D register_netdev(netdev);
 	if (err) {
 		dev_err(dev, "Cannot register net device, aborting\n");
diff --git a/drivers/net/enic/enic_res.c b/drivers/net/enic/enic_res.c
index f111a37..6e5c635 100644
--- a/drivers/net/enic/enic_res.c
+++ b/drivers/net/enic/enic_res.c
@@ -98,9 +98,9 @@ int enic_get_vnic_config(struct enic *enic)
 		"vNIC MAC addr %pM wq/rq %d/%d mtu %d\n",
 		enic->mac_addr, c->wq_desc_count, c->rq_desc_count, c->mtu);
 	dev_info(enic_get_dev(enic), "vNIC csum tx/rx %d/%d "
-		"tso/lro %d/%d intr timer %d usec rss %d\n",
+		"tso %d intr timer %d usec rss %d\n",
 		ENIC_SETTING(enic, TXCSUM), ENIC_SETTING(enic, RXCSUM),
-		ENIC_SETTING(enic, TSO), ENIC_SETTING(enic, LRO),
+		ENIC_SETTING(enic, TSO),
 		c->intr_timer_usec, ENIC_SETTING(enic, RSS));
=20
 	return 0;
--=20
1.7.2.5

