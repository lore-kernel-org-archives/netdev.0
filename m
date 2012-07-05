From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 10/10] net/mlx4_en: Add support for drop action through ethtool
Date: Thu,  5 Jul 2012 17:03:50 +0300
Message-ID: <1341497030-1818-11-git-send-email-ogerlitz@mellanox.com>
References: <1341497030-1818-1-git-send-email-ogerlitz@mellanox.com>
Cc: roland@kernel.org, yevgenyp@mellanox.com, oren@mellanox.com,
	netdev@vger.kernel.org, amirv@mellanox.com,
	Hadar Hen Zion <hadarh@mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:41048 "HELO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756506Ab2GEOEF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2012 10:04:05 -0400
In-Reply-To: <1341497030-1818-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.co.il>

The drop action is implemented by allocating a QP and keeping it in a reset state
such that the HW drops any packets which are steered to that QP. When a drop action
is requested, we attach the relevant flow to that QP.

Sign-off-by: Hadar Hen Zion <hadarh@mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |    2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |    9 ++++++-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c      |   30 +++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |    3 ++
 4 files changed, 42 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index 3e72a20..dd6a77b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -821,7 +821,7 @@ static int mlx4_en_flow_replace(struct net_device *dev,
 
 	/* Allow direct QP attaches if the EN_ETHTOOL_QP_ATTACH flag is set */
 	if (cmd->fs.ring_cookie == RX_CLS_FLOW_DISC)
-		return -EINVAL;
+		qpn = priv->drop_qp.qpn;
 	else if (cmd->fs.ring_cookie & EN_ETHTOOL_QP_ATTACH) {
 		qpn = cmd->fs.ring_cookie & (EN_ETHTOOL_QP_ATTACH - 1);
 	} else {
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index b7945a8..94375a8 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -796,6 +796,10 @@ int mlx4_en_start_port(struct net_device *dev)
 		goto mac_err;
 	}
 
+	err = mlx4_en_create_drop_qp(priv);
+	if (err)
+		goto rss_err;
+
 	/* Configure tx cq's and rings */
 	for (i = 0; i < priv->tx_ring_num; i++) {
 		/* Configure cq */
@@ -895,7 +899,8 @@ tx_err:
 		mlx4_en_deactivate_tx_ring(priv, &priv->tx_ring[tx_index]);
 		mlx4_en_deactivate_cq(priv, &priv->tx_cq[tx_index]);
 	}
-
+	mlx4_en_destroy_drop_qp(priv);
+rss_err:
 	mlx4_en_release_rss_steer(priv);
 mac_err:
 	mlx4_put_eth_qp(mdev->dev, priv->port, priv->mac, priv->base_qpn);
@@ -950,6 +955,8 @@ void mlx4_en_stop_port(struct net_device *dev)
 	/* Flush multicast filter */
 	mlx4_SET_MCAST_FLTR(mdev->dev, priv->port, 0, 1, MLX4_MCAST_CONFIG);
 
+	mlx4_en_destroy_drop_qp(priv);
+
 	/* Free TX Rings */
 	for (i = 0; i < priv->tx_ring_num; i++) {
 		mlx4_en_deactivate_tx_ring(priv, &priv->tx_ring[i]);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index d49a7ac..a04cbf7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -844,6 +844,36 @@ out:
 	return err;
 }
 
+int mlx4_en_create_drop_qp(struct mlx4_en_priv *priv)
+{
+	int err;
+	u32 qpn;
+
+	err = mlx4_qp_reserve_range(priv->mdev->dev, 1, 1, &qpn);
+	if (err) {
+		en_err(priv, "Failed reserving drop qpn\n");
+		return err;
+	}
+	err = mlx4_qp_alloc(priv->mdev->dev, qpn, &priv->drop_qp);
+	if (err) {
+		en_err(priv, "Failed allocating drop qp\n");
+		mlx4_qp_release_range(priv->mdev->dev, qpn, 1);
+		return err;
+	}
+
+	return 0;
+}
+
+void mlx4_en_destroy_drop_qp(struct mlx4_en_priv *priv)
+{
+	u32 qpn;
+
+	qpn = priv->drop_qp.qpn;
+	mlx4_qp_remove(priv->mdev->dev, &priv->drop_qp);
+	mlx4_qp_free(priv->mdev->dev, &priv->drop_qp);
+	mlx4_qp_release_range(priv->mdev->dev, qpn, 1);
+}
+
 /* Allocate rx qp's and configure them according to rss map */
 int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
 {
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 8882e70..a126321 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -500,6 +500,7 @@ struct mlx4_en_priv {
 	struct mlx4_en_rx_ring rx_ring[MAX_RX_RINGS];
 	struct mlx4_en_cq *tx_cq;
 	struct mlx4_en_cq rx_cq[MAX_RX_RINGS];
+	struct mlx4_qp drop_qp;
 	struct work_struct mcast_task;
 	struct work_struct mac_task;
 	struct work_struct watchdog_task;
@@ -586,6 +587,8 @@ void mlx4_en_unmap_buffer(struct mlx4_buf *buf);
 void mlx4_en_calc_rx_buf(struct net_device *dev);
 int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv);
 void mlx4_en_release_rss_steer(struct mlx4_en_priv *priv);
+int mlx4_en_create_drop_qp(struct mlx4_en_priv *priv);
+void mlx4_en_destroy_drop_qp(struct mlx4_en_priv *priv);
 int mlx4_en_free_tx_buf(struct net_device *dev, struct mlx4_en_tx_ring *ring);
 void mlx4_en_rx_irq(struct mlx4_cq *mcq);
 
-- 
1.7.1
