From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 5/6 V2] mlx4_en: Adding rxhash support
Date: Tue, 18 Oct 2011 13:51:24 +0200
Message-ID: <4E9D683C.8010902@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:36410 "HELO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757965Ab1JRN7P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 09:59:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Moving to Toeplitz function in RSS calculation.
Reporting rxhash in skb.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    2 +-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c     |   12 ++++++++++++
 2 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index c4c4be4..78d776b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1084,7 +1084,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 
 	dev->vlan_features = dev->hw_features;
 
-	dev->hw_features |= NETIF_F_RXCSUM;
+	dev->hw_features |= NETIF_F_RXCSUM | NETIF_F_RXHASH;
 	dev->features = dev->hw_features | NETIF_F_HIGHDMA |
 			NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX |
 			NETIF_F_HW_VLAN_FILTER;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index eed2a0a..0e368af 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -618,6 +618,9 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 						__vlan_hwaccel_put_tag(gro_skb, vid);
 					}
 
+					if (dev->features & NETIF_F_RXHASH)
+						gro_skb->rxhash = be32_to_cpu(cqe->immed_rss_invalid);
+
 					skb_record_rx_queue(gro_skb, cq->ring);
 					napi_gro_frags(&cq->napi);
 
@@ -651,6 +654,9 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 		skb->protocol = eth_type_trans(skb, dev);
 		skb_record_rx_queue(skb, cq->ring);
 
+		if (dev->features & NETIF_F_RXHASH)
+			skb->rxhash = be32_to_cpu(cqe->immed_rss_invalid);
+
 		if (be32_to_cpu(cqe->vlan_my_qpn) &
 		    MLX4_CQE_VLAN_PRESENT_MASK)
 			__vlan_hwaccel_put_tag(skb, be16_to_cpu(cqe->sl_vid));
@@ -834,6 +840,9 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
 	int i, qpn;
 	int err = 0;
 	int good_qps = 0;
+	static const u32 rsskey[10] = { 0xD181C62C, 0xF7F4DB5B, 0x1983A2FC,
+				0x943E1ADB, 0xD9389E6B, 0xD1039C2C, 0xA74499AD,
+				0x593D56D9, 0xF3253C06, 0x2ADC1FFC};
 
 	en_dbg(DRV, priv, "Configuring rss steering\n");
 	err = mlx4_qp_reserve_range(mdev->dev, priv->rx_ring_num,
@@ -871,6 +880,9 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
 					    (rss_map->base_qpn));
 	rss_context->default_qpn = cpu_to_be32(rss_map->base_qpn);
 	rss_context->flags = rss_mask;
+	rss_context->hash_fn = 1;
+	for (i = 0; i < 10; i++)
+		rss_context->rss_key[i] = rsskey[i];
 
 	if (priv->mdev->profile.udp_rss)
 		rss_context->base_qpn_udp = rss_context->default_qpn;
-- 
1.7.7
