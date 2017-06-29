From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 1/2] net/mlx4_en: Add dynamic variable to hold the number of user priorities (UP)
Date: Thu, 29 Jun 2017 14:07:56 +0300
Message-ID: <1498734477-26111-2-git-send-email-tariqt@mellanox.com>
References: <1498734477-26111-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Inbar Karmy <inbark@mellanox.com>,
        Tarick Bedeir <tarick@google.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:55778 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751758AbdF2LIo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 07:08:44 -0400
In-Reply-To: <1498734477-26111-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Inbar Karmy <inbark@mellanox.com>

Until this patch, the number of UPs was hard coded for eight.
Replace this with a variable in struct "mlx4_en_port_profile".
Currently, the variable will hold the maximum number of UP,
as before.
The patch creates an infrastructure to add an option for dynamic
change of the actual number of TCs.

Signed-off-by: Inbar Karmy <inbark@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Cc: Tarick Bedeir <tarick@google.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c  |  2 +-
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 12 +++++++-----
 drivers/net/ethernet/mellanox/mlx4/en_main.c    |  3 ++-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |  6 +++---
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |  7 ++++---
 5 files changed, 17 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
index 1dae8e40fb25..91481f117daa 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c
@@ -303,7 +303,7 @@ static int mlx4_en_ets_validate(struct mlx4_en_priv *priv, struct ieee_ets *ets)
 	int has_ets_tc = 0;
 
 	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++) {
-		if (ets->prio_tc[i] >= MLX4_EN_NUM_UP) {
+		if (ets->prio_tc[i] >= priv->prof->num_up) {
 			en_err(priv, "Bad priority in UP <=> TC mapping. TC: %d, UP: %d\n",
 					i, ets->prio_tc[i]);
 			return -EINVAL;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index e97fbf327594..2b80a4a9945c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -1750,7 +1750,8 @@ static void mlx4_en_get_channels(struct net_device *dev,
 	channel->max_tx = MLX4_EN_MAX_TX_RING_P_UP;
 
 	channel->rx_count = priv->rx_ring_num;
-	channel->tx_count = priv->tx_ring_num[TX] / MLX4_EN_NUM_UP;
+	channel->tx_count = priv->tx_ring_num[TX] /
+			    priv->prof->num_up;
 }
 
 static int mlx4_en_set_channels(struct net_device *dev,
@@ -1773,18 +1774,19 @@ static int mlx4_en_set_channels(struct net_device *dev,
 
 	mutex_lock(&mdev->state_lock);
 	xdp_count = priv->tx_ring_num[TX_XDP] ? channel->rx_count : 0;
-	if (channel->tx_count * MLX4_EN_NUM_UP + xdp_count > MAX_TX_RINGS) {
+	if (channel->tx_count * priv->prof->num_up + xdp_count >
+	    MAX_TX_RINGS) {
 		err = -EINVAL;
 		en_err(priv,
 		       "Total number of TX and XDP rings (%d) exceeds the maximum supported (%d)\n",
-		       channel->tx_count * MLX4_EN_NUM_UP + xdp_count,
+		       channel->tx_count * priv->prof->num_up  + xdp_count,
 		       MAX_TX_RINGS);
 		goto out;
 	}
 
 	memcpy(&new_prof, priv->prof, sizeof(struct mlx4_en_port_profile));
 	new_prof.num_tx_rings_p_up = channel->tx_count;
-	new_prof.tx_ring_num[TX] = channel->tx_count * MLX4_EN_NUM_UP;
+	new_prof.tx_ring_num[TX] = channel->tx_count * priv->prof->num_up;
 	new_prof.tx_ring_num[TX_XDP] = xdp_count;
 	new_prof.rx_ring_num = channel->rx_count;
 
@@ -1803,7 +1805,7 @@ static int mlx4_en_set_channels(struct net_device *dev,
 	netif_set_real_num_rx_queues(dev, priv->rx_ring_num);
 
 	if (netdev_get_num_tc(dev))
-		mlx4_en_setup_tc(dev, MLX4_EN_NUM_UP);
+		mlx4_en_setup_tc(dev, priv->prof->num_up);
 
 	en_warn(priv, "Using %d TX rings\n", priv->tx_ring_num[TX]);
 	en_warn(priv, "Using %d RX rings\n", priv->rx_ring_num);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_main.c b/drivers/net/ethernet/mellanox/mlx4/en_main.c
index 56cdf38d150e..a8eb856b0158 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_main.c
@@ -169,8 +169,9 @@ static int mlx4_en_get_profile(struct mlx4_en_dev *mdev)
 		params->prof[i].tx_ppp = pfctx;
 		params->prof[i].tx_ring_size = MLX4_EN_DEF_TX_RING_SIZE;
 		params->prof[i].rx_ring_size = MLX4_EN_DEF_RX_RING_SIZE;
+		params->prof[i].num_up = MLX4_EN_NUM_UP_HIGH;
 		params->prof[i].tx_ring_num[TX] = params->num_tx_rings_p_up *
-			MLX4_EN_NUM_UP;
+			params->prof[i].num_up;
 		params->prof[i].rss_rings = 0;
 		params->prof[i].inline_thold = inline_thold;
 	}
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 9da76e3be2fc..e7f654623eab 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -60,7 +60,7 @@ int mlx4_en_setup_tc(struct net_device *dev, u8 up)
 	int i;
 	unsigned int offset = 0;
 
-	if (up && up != MLX4_EN_NUM_UP)
+	if (up && up != MLX4_EN_NUM_UP_HIGH)
 		return -EINVAL;
 
 	netdev_set_num_tc(dev, up);
@@ -2780,7 +2780,7 @@ static int mlx4_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 	if (priv->tx_ring_num[TX] + xdp_ring_num > MAX_TX_RINGS) {
 		tx_changed = 1;
 		new_prof.tx_ring_num[TX] =
-			MAX_TX_RINGS - ALIGN(xdp_ring_num, MLX4_EN_NUM_UP);
+			MAX_TX_RINGS - ALIGN(xdp_ring_num, priv->prof->num_up);
 		en_warn(priv, "Reducing the number of TX rings, to not exceed the max total rings number.\n");
 	}
 
@@ -3271,7 +3271,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 		priv->flags |= MLX4_EN_DCB_ENABLED;
 		priv->cee_config.pfc_state = false;
 
-		for (i = 0; i < MLX4_EN_NUM_UP; i++)
+		for (i = 0; i < MLX4_EN_NUM_UP_HIGH; i++)
 			priv->cee_config.dcb_pfc[i] = pfc_disabled;
 
 		if (mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_ETS_CFG) {
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 963b77d51b48..89885281d489 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -115,11 +115,11 @@
 #define MLX4_EN_SMALL_PKT_SIZE		64
 #define MLX4_EN_MIN_TX_RING_P_UP	1
 #define MLX4_EN_MAX_TX_RING_P_UP	32
-#define MLX4_EN_NUM_UP			8
+#define MLX4_EN_NUM_UP_HIGH		8
 #define MLX4_EN_DEF_RX_RING_SIZE  	1024
 #define MLX4_EN_DEF_TX_RING_SIZE	MLX4_EN_DEF_RX_RING_SIZE
 #define MAX_TX_RINGS			(MLX4_EN_MAX_TX_RING_P_UP * \
-					 MLX4_EN_NUM_UP)
+					 MLX4_EN_NUM_UP_HIGH)
 
 #define MLX4_EN_DEFAULT_TX_WORK		256
 
@@ -386,6 +386,7 @@ struct mlx4_en_port_profile {
 	u8 rx_ppp;
 	u8 tx_pause;
 	u8 tx_ppp;
+	u8 num_up;
 	int rss_rings;
 	int inline_thold;
 	struct hwtstamp_config hwtstamp_config;
@@ -485,7 +486,7 @@ enum dcb_pfc_type {
 
 struct mlx4_en_cee_config {
 	bool	pfc_state;
-	enum	dcb_pfc_type dcb_pfc[MLX4_EN_NUM_UP];
+	enum	dcb_pfc_type dcb_pfc[MLX4_EN_NUM_UP_HIGH];
 };
 #endif
 
-- 
1.8.3.1
