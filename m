From: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Subject: [PATCH 18/25] mlx4_en: Use reasonable resources for slaves.
Date: Wed, 04 Nov 2009 17:31:49 +0200
Message-ID: <4AF19E65.5030400@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org, tziporet-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org,
	yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org
To: rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Each slave gets a single MSI-X vector when in multi function mode.
In this case each slave would allocate less resources (which
normally depend on number of completion vectors).
We set a minimum number of RX and TX queues to achieve an
acceptable performance in multi function mode.

Signed-off-by: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
---
 drivers/net/mlx4/en_main.c   |   12 +++++++-----
 drivers/net/mlx4/en_netdev.c |    3 ++-
 drivers/net/mlx4/en_tx.c     |    2 +-
 drivers/net/mlx4/mlx4_en.h   |    4 +++-
 4 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/drivers/net/mlx4/en_main.c b/drivers/net/mlx4/en_main.c
index 507e11f..3883071 100644
--- a/drivers/net/mlx4/en_main.c
+++ b/drivers/net/mlx4/en_main.c
@@ -93,8 +93,6 @@ static int mlx4_en_get_profile(struct mlx4_en_dev *mdev)
 		params->prof[i].tx_ppp = pfctx;
 		params->prof[i].tx_ring_size = MLX4_EN_DEF_TX_RING_SIZE;
 		params->prof[i].rx_ring_size = MLX4_EN_DEF_RX_RING_SIZE;
-		params->prof[i].tx_ring_num = MLX4_EN_NUM_TX_RINGS +
-			(!!pfcrx) * MLX4_EN_NUM_PPP_RINGS;
 	}
 
 	return 0;
@@ -216,11 +214,15 @@ static void *mlx4_en_add(struct mlx4_dev *dev)
 	/* If we did not receive an explicit number of Rx rings, default to
 	 * the number of completion vectors populated by the mlx4_core */
 	mlx4_foreach_port(i, dev, MLX4_PORT_TYPE_ETH) {
+		mdev->profile.prof[i].tx_ring_num = max_t(int,
+			min_t(int, roundup_pow_of_two(dev->caps.num_comp_vectors),
+			NUM_TX_RINGS), MIN_TX_RINGS) +
+			(!!pfcrx) * MLX4_EN_NUM_PPP_RINGS;
 		mlx4_info(mdev, "Using %d tx rings for port:%d\n",
 			  mdev->profile.prof[i].tx_ring_num, i);
-		mdev->profile.prof[i].rx_ring_num = min_t(int,
-			roundup_pow_of_two(dev->caps.num_comp_vectors),
-			MAX_RX_RINGS);
+		mdev->profile.prof[i].rx_ring_num = max_t(int,
+			min_t(int, roundup_pow_of_two(dev->caps.num_comp_vectors),
+			MAX_RX_RINGS), MIN_RX_RINGS);
 		mlx4_info(mdev, "Defaulting to %d rx rings for port:%d\n",
 			  mdev->profile.prof[i].rx_ring_num, i);
 	}
diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index fd96078..488f967 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -1024,7 +1024,8 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	 */
 	dev->netdev_ops = &mlx4_netdev_ops;
 	dev->watchdog_timeo = MLX4_EN_WATCHDOG_TIMEOUT;
-	dev->real_num_tx_queues = MLX4_EN_NUM_TX_RINGS;
+	dev->real_num_tx_queues = priv->tx_ring_num -
+				!!(priv->prof->rx_ppp) * MLX4_EN_NUM_PPP_RINGS;
 
 	SET_ETHTOOL_OPS(dev, &mlx4_en_ethtool_ops);
 
diff --git a/drivers/net/mlx4/en_tx.c b/drivers/net/mlx4/en_tx.c
index 8c72799..a893733 100644
--- a/drivers/net/mlx4/en_tx.c
+++ b/drivers/net/mlx4/en_tx.c
@@ -583,7 +583,7 @@ u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb)
 	 */
 	if (priv->prof->rx_ppp && priv->vlgrp && vlan_tx_tag_present(skb)) {
 		vlan_tag = vlan_tx_tag_get(skb);
-		return MLX4_EN_NUM_TX_RINGS + (vlan_tag >> 13);
+		return priv->tx_ring_num - MLX4_EN_NUM_PPP_RINGS + (vlan_tag >> 13);
 	}
 
 	return skb_tx_hash(dev, skb);
diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index 4376147..6e0c9ed 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -95,6 +95,9 @@
 #define MLX4_EN_PAGE_SIZE	(1 << MLX4_EN_PAGE_SHIFT)
 #define MAX_TX_RINGS		16
 #define MAX_RX_RINGS		16
+#define MIN_RX_RINGS		4
+#define NUM_TX_RINGS		8
+#define MIN_TX_RINGS		4
 #define TXBB_SIZE		64
 #define HEADROOM		(2048 / TXBB_SIZE + 1)
 #define STAMP_STRIDE		64
@@ -137,7 +140,6 @@ enum {
 #define MLX4_EN_MIN_TX_SIZE	(4096 / TXBB_SIZE)
 
 #define MLX4_EN_SMALL_PKT_SIZE		64
-#define MLX4_EN_NUM_TX_RINGS		8
 #define MLX4_EN_NUM_PPP_RINGS		8
 #define MLX4_EN_DEF_TX_RING_SIZE	512
 #define MLX4_EN_DEF_RX_RING_SIZE  	1024
-- 
1.6.1.3




--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
