From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 22/23 v3] mlx4_en: Use reasonable resources for slaves
Date: Thu, 04 Feb 2010 17:57:13 +0200
Message-ID: <4B6AEE59.1050106@mellanox.co.il>
References: <49BFC313.1030901@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: general@lists.openfabrics.org, netdev@vger.kernel.org,
	liranl@mellanox.co.il, tziporet@mellanox.co.il
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:49926 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933249Ab0BDP5P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2010 10:57:15 -0500
In-Reply-To: <49BFC313.1030901@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From d42a1ac0bbfeb2522e11d2aca2f41396b070d6eb Mon Sep 17 00:00:00 2001
From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Fri, 6 Nov 2009 01:10:28 +0200
Subject: [PATCH 22/23] mlx4_en: Use reasonable resources for slaves.

Each slave gets a single MSI-X vector when in multi function mode.
In this case each slave would allocate less resources (which
normally depend on number of completion vectors).
We set a minimum number of RX and TX queues to achieve an
acceptable performance in multi function mode.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_main.c   |   12 +++++++-----
 drivers/net/mlx4/en_netdev.c |    3 ++-
 drivers/net/mlx4/en_tx.c     |    2 +-
 drivers/net/mlx4/mlx4_en.h   |    8 +++++---
 4 files changed, 15 insertions(+), 10 deletions(-)

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
index 751c79d..947fb2f 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -1053,7 +1053,8 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	 */
 	dev->netdev_ops = &mlx4_netdev_ops;
 	dev->watchdog_timeo = MLX4_EN_WATCHDOG_TIMEOUT;
-	dev->real_num_tx_queues = MLX4_EN_NUM_TX_RINGS;
+	dev->real_num_tx_queues = priv->tx_ring_num -
+				!!(priv->prof->rx_ppp) * MLX4_EN_NUM_PPP_RINGS;
 
 	SET_ETHTOOL_OPS(dev, &mlx4_en_ethtool_ops);
 
diff --git a/drivers/net/mlx4/en_tx.c b/drivers/net/mlx4/en_tx.c
index d4af0fe..b8e994d 100644
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
index 809c45d..834fd24 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -93,8 +93,11 @@
 
 #define MLX4_EN_PAGE_SHIFT	12
 #define MLX4_EN_PAGE_SIZE	(1 << MLX4_EN_PAGE_SHIFT)
-#define MAX_TX_RINGS		16
-#define MAX_RX_RINGS		16
+#define MAX_TX_RINGS		12
+#define MAX_RX_RINGS		8
+#define MIN_RX_RINGS		4
+#define NUM_TX_RINGS		4
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


