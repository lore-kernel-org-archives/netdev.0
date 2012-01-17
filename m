From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net] mlx4_en: set number of rx rings used by RSS using ethtool
Date: Tue, 17 Jan 2012 18:50:24 +0200
Message-ID: <4F15A6D0.8040501@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<amirv@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:55707 "HELO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754587Ab2AQQvI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 11:51:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.co.il>

Value must be a power of 2 due to HW limitation.
Driver supports only 'equal' mode in ethtool and can't be set by using weights.

Signed-off-by: Amir Vadai <amirv@mellanox.co.il>
Reviewed-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |   93 +++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_main.c    |    6 +-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c      |    8 ++-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |    2 +-
 4 files changed, 102 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index 7dbc6a2..85cf580 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -479,6 +479,95 @@ static void mlx4_en_get_ringparam(struct net_device *dev,
 	param->tx_pending = priv->tx_ring[0].size;
 }
 
+static u32 mlx4_en_get_rxfh_indir_size(struct net_device *dev)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+
+	return priv->rx_ring_num;
+}
+
+static int mlx4_en_get_rxfh_indir(struct net_device *dev, u32 *ring_index)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	struct mlx4_en_rss_map *rss_map = &priv->rss_map;
+	int rss_rings;
+	size_t n = priv->rx_ring_num;
+	int err = 0;
+
+	rss_rings = priv->prof->rss_rings ?: priv->rx_ring_num;
+
+	while (n--) {
+		ring_index[n] = rss_map->qps[n % rss_rings].qpn -
+			rss_map->base_qpn;
+	}
+
+	return err;
+}
+
+static int mlx4_en_set_rxfh_indir(struct net_device *dev,
+		const u32 *ring_index)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	struct mlx4_en_dev *mdev = priv->mdev;
+	int port_up = 0;
+	int err = 0;
+	int i;
+	int rss_rings = 0;
+
+	/* Calculate RSS table size and make sure flows are spread evenly
+	 * between rings
+	 */
+	for (i = 0; i < priv->rx_ring_num; i++) {
+		if (i > 0 && !ring_index[i] && !rss_rings)
+			rss_rings = i;
+
+		if (ring_index[i] != (i % (rss_rings ?: priv->rx_ring_num)))
+			return -EINVAL;
+	}
+
+	if (!rss_rings)
+		rss_rings = priv->rx_ring_num;
+
+	/* RSS table size must be an order of 2 */
+	if (rss_rings != (1 << order_base_2(rss_rings)))
+		return -EINVAL;
+
+	mutex_lock(&mdev->state_lock);
+	if (priv->port_up) {
+		port_up = 1;
+		mlx4_en_stop_port(dev);
+	}
+
+	priv->prof->rss_rings = rss_rings;
+
+	if (port_up) {
+		err = mlx4_en_start_port(dev);
+		if (err)
+			en_err(priv, "Failed starting port\n");
+	}
+
+	mutex_unlock(&mdev->state_lock);
+	return err;
+}
+
+static int mlx4_en_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd,
+			     u32 *rule_locs)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	int err = 0;
+
+	switch (cmd->cmd) {
+	case ETHTOOL_GRXRINGS:
+		cmd->data = priv->rx_ring_num;
+		break;
+	default:
+		err = -EOPNOTSUPP;
+		break;
+	}
+
+	return err;
+}
+
 const struct ethtool_ops mlx4_en_ethtool_ops = {
 	.get_drvinfo = mlx4_en_get_drvinfo,
 	.get_settings = mlx4_en_get_settings,
@@ -498,6 +587,10 @@ const struct ethtool_ops mlx4_en_ethtool_ops = {
 	.set_pauseparam = mlx4_en_set_pauseparam,
 	.get_ringparam = mlx4_en_get_ringparam,
 	.set_ringparam = mlx4_en_set_ringparam,
+	.get_rxnfc = mlx4_en_get_rxnfc,
+	.get_rxfh_indir_size = mlx4_en_get_rxfh_indir_size,
+	.get_rxfh_indir = mlx4_en_get_rxfh_indir,
+	.set_rxfh_indir = mlx4_en_set_rxfh_indir,
 };
 
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_main.c b/drivers/net/ethernet/mellanox/mlx4/en_main.c
index a06096f..2097a7d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_main.c
@@ -62,10 +62,6 @@ static const char mlx4_en_version[] =
  * Device scope module parameters
  */
 
-
-/* Enable RSS TCP traffic */
-MLX4_EN_PARM_INT(tcp_rss, 1,
-		 "Enable RSS for incomming TCP traffic or disabled (0)");
 /* Enable RSS UDP traffic */
 MLX4_EN_PARM_INT(udp_rss, 1,
 		 "Enable RSS for incomming UDP traffic or disabled (0)");
@@ -104,7 +100,6 @@ static int mlx4_en_get_profile(struct mlx4_en_dev *mdev)
 	struct mlx4_en_profile *params = &mdev->profile;
 	int i;
 
-	params->tcp_rss = tcp_rss;
 	params->udp_rss = udp_rss;
 	if (params->udp_rss && !(mdev->dev->caps.flags
 					& MLX4_DEV_CAP_FLAG_UDP_RSS)) {
@@ -120,6 +115,7 @@ static int mlx4_en_get_profile(struct mlx4_en_dev *mdev)
 		params->prof[i].rx_ring_size = MLX4_EN_DEF_RX_RING_SIZE;
 		params->prof[i].tx_ring_num = MLX4_EN_NUM_TX_RINGS +
 			(!!pfcrx) * MLX4_EN_NUM_PPP_RINGS;
+		params->prof[i].rss_rings = 0;
 	}
 
 	return 0;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index e8d6ad2..971d4b6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -853,6 +853,7 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
 	struct mlx4_en_rss_map *rss_map = &priv->rss_map;
 	struct mlx4_qp_context context;
 	struct mlx4_rss_context *rss_context;
+	int rss_rings;
 	void *ptr;
 	u8 rss_mask = (MLX4_RSS_IPV4 | MLX4_RSS_TCP_IPV4 | MLX4_RSS_IPV6 |
 			MLX4_RSS_TCP_IPV6);
@@ -893,10 +894,15 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
 	mlx4_en_fill_qp_context(priv, 0, 0, 0, 1, priv->base_qpn,
 				priv->rx_ring[0].cqn, &context);
 
+	if (!priv->prof->rss_rings || priv->prof->rss_rings > priv->rx_ring_num)
+		rss_rings = priv->rx_ring_num;
+	else
+		rss_rings = priv->prof->rss_rings;
+
 	ptr = ((void *) &context) + offsetof(struct mlx4_qp_context, pri_path)
 					+ MLX4_RSS_OFFSET_IN_QPC_PRI_PATH;
 	rss_context = ptr;
-	rss_context->base_qpn = cpu_to_be32(ilog2(priv->rx_ring_num) << 24 |
+	rss_context->base_qpn = cpu_to_be32(ilog2(rss_rings) << 24 |
 					    (rss_map->base_qpn));
 	rss_context->default_qpn = cpu_to_be32(rss_map->base_qpn);
 	if (priv->mdev->profile.udp_rss) {
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index f2a8e65..f4d189a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -325,11 +325,11 @@ struct mlx4_en_port_profile {
 	u8 rx_ppp;
 	u8 tx_pause;
 	u8 tx_ppp;
+	int rss_rings;
 };
 
 struct mlx4_en_profile {
 	int rss_xor;
-	int tcp_rss;
 	int udp_rss;
 	u8 rss_mask;
 	u32 active_ports;
-- 
1.5.4.3
