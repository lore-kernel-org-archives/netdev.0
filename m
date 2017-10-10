From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 1/3] net/mlx4_en: Limit the number of TX rings
Date: Tue, 10 Oct 2017 12:28:33 +0300
Message-ID: <1507627715-25487-2-git-send-email-tariqt@mellanox.com>
References: <1507627715-25487-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Inbar Karmy <inbark@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:48088 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754877AbdJJJ2v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 05:28:51 -0400
In-Reply-To: <1507627715-25487-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Inbar Karmy <inbark@mellanox.com>

Limit the number of TX rings per UP by the number of cores
in the system.

Signed-off-by: Inbar Karmy <inbark@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 4 ++--
 drivers/net/ethernet/mellanox/mlx4/en_main.c    | 6 +++---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  | 2 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    | 2 +-
 4 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index 3d4e4a5d00d1..e9432bc1c1bc 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -1748,7 +1748,7 @@ static void mlx4_en_get_channels(struct net_device *dev,
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 
 	channel->max_rx = MAX_RX_RINGS;
-	channel->max_tx = MLX4_EN_MAX_TX_RING_P_UP;
+	channel->max_tx = priv->mdev->profile.max_num_tx_rings_p_up;
 
 	channel->rx_count = priv->rx_ring_num;
 	channel->tx_count = priv->tx_ring_num[TX] /
@@ -1777,7 +1777,7 @@ static int mlx4_en_set_channels(struct net_device *dev,
 	mutex_lock(&mdev->state_lock);
 	xdp_count = priv->tx_ring_num[TX_XDP] ? channel->rx_count : 0;
 	if (channel->tx_count * priv->prof->num_up + xdp_count >
-	    MAX_TX_RINGS) {
+	    priv->mdev->profile.max_num_tx_rings_p_up * priv->prof->num_up) {
 		err = -EINVAL;
 		en_err(priv,
 		       "Total number of TX and XDP rings (%d) exceeds the maximum supported (%d)\n",
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_main.c b/drivers/net/ethernet/mellanox/mlx4/en_main.c
index 686e18de9a97..2c2965497ed3 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_main.c
@@ -153,7 +153,7 @@ static void mlx4_en_get_profile(struct mlx4_en_dev *mdev)
 	int i;
 
 	params->udp_rss = udp_rss;
-	params->num_tx_rings_p_up = mlx4_low_memory_profile() ?
+	params->max_num_tx_rings_p_up = mlx4_low_memory_profile() ?
 		MLX4_EN_MIN_TX_RING_P_UP :
 		min_t(int, num_online_cpus(), MLX4_EN_MAX_TX_RING_P_UP);
 
@@ -170,8 +170,8 @@ static void mlx4_en_get_profile(struct mlx4_en_dev *mdev)
 		params->prof[i].tx_ring_size = MLX4_EN_DEF_TX_RING_SIZE;
 		params->prof[i].rx_ring_size = MLX4_EN_DEF_RX_RING_SIZE;
 		params->prof[i].num_up = MLX4_EN_NUM_UP_LOW;
-		params->prof[i].num_tx_rings_p_up = params->num_tx_rings_p_up;
-		params->prof[i].tx_ring_num[TX] = params->num_tx_rings_p_up *
+		params->prof[i].num_tx_rings_p_up = params->max_num_tx_rings_p_up;
+		params->prof[i].tx_ring_num[TX] = params->max_num_tx_rings_p_up *
 			params->prof[i].num_up;
 		params->prof[i].rss_rings = 0;
 		params->prof[i].inline_thold = inline_thold;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 9c218f1cfc6c..e4c7a80ef5a8 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -3305,7 +3305,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	priv->pflags = MLX4_EN_PRIV_FLAGS_BLUEFLAME;
 	priv->ctrl_flags = cpu_to_be32(MLX4_WQE_CTRL_CQ_UPDATE |
 			MLX4_WQE_CTRL_SOLICITED);
-	priv->num_tx_rings_p_up = mdev->profile.num_tx_rings_p_up;
+	priv->num_tx_rings_p_up = mdev->profile.max_num_tx_rings_p_up;
 	priv->tx_work_limit = MLX4_EN_DEFAULT_TX_WORK;
 	netdev_rss_key_fill(priv->rss_key, sizeof(priv->rss_key));
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index fdb3ad0cbe54..245e9ea09ab2 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -399,7 +399,7 @@ struct mlx4_en_profile {
 	u32 active_ports;
 	u32 small_pkt_int;
 	u8 no_reset;
-	u8 num_tx_rings_p_up;
+	u8 max_num_tx_rings_p_up;
 	struct mlx4_en_port_profile prof[MLX4_MAX_PORTS + 1];
 };
 
-- 
1.8.3.1
