From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 03/13] net/mlx5e: Allocate set of queue counters per netdev
Date: Fri, 11 Mar 2016 15:39:44 +0200
Message-ID: <1457703594-9482-4-git-send-email-saeedm@mellanox.com>
References: <1457703594-9482-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Rana Shahout <ranas@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:33258 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932149AbcCKNlb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2016 08:41:31 -0500
In-Reply-To: <1457703594-9482-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rana Shahout <ranas@mellanox.com>

Connect all netdev RQs to this set of queue counters.
Also, add an "rx_out_of_buffer" counter to ethtool,
which indicates RX packet drops due to lack of receive
buffers.

Signed-off-by: Rana Shahout <ranas@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |   11 +++++
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |   11 +++++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |   42 +++++++++++++++++++-
 3 files changed, 62 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 1f5cc1b..5ef91a9 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -236,6 +236,15 @@ struct mlx5e_pport_stats {
 	__be64 RFC_2819_counters[NUM_RFC_2819_COUNTERS];
 };
 
+static const char qcounter_stats_strings[][ETH_GSTRING_LEN] = {
+	"rx_out_of_buffer",
+};
+
+struct mlx5e_qcounter_stats {
+	u32 rx_out_of_buffer;
+#define NUM_Q_COUNTERS 1
+};
+
 static const char rq_stats_strings[][ETH_GSTRING_LEN] = {
 	"packets",
 	"bytes",
@@ -293,6 +302,7 @@ struct mlx5e_sq_stats {
 struct mlx5e_stats {
 	struct mlx5e_vport_stats   vport;
 	struct mlx5e_pport_stats   pport;
+	struct mlx5e_qcounter_stats qcnt;
 };
 
 struct mlx5e_params {
@@ -575,6 +585,7 @@ struct mlx5e_priv {
 	struct net_device         *netdev;
 	struct mlx5e_stats         stats;
 	struct mlx5e_tstamp        tstamp;
+	u16 q_counter;
 };
 
 #define MLX5E_NET_IP_ALIGN 2
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 68834b7..39c1902 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -165,6 +165,8 @@ static const struct {
 	},
 };
 
+#define MLX5E_NUM_Q_CNTRS(priv) (NUM_Q_COUNTERS * (!!priv->q_counter))
+
 static int mlx5e_get_sset_count(struct net_device *dev, int sset)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
@@ -172,6 +174,7 @@ static int mlx5e_get_sset_count(struct net_device *dev, int sset)
 	switch (sset) {
 	case ETH_SS_STATS:
 		return NUM_VPORT_COUNTERS + NUM_PPORT_COUNTERS +
+		       MLX5E_NUM_Q_CNTRS(priv) +
 		       priv->params.num_channels * NUM_RQ_STATS +
 		       priv->params.num_channels * priv->params.num_tc *
 						   NUM_SQ_STATS;
@@ -200,6 +203,11 @@ static void mlx5e_get_strings(struct net_device *dev,
 			strcpy(data + (idx++) * ETH_GSTRING_LEN,
 			       vport_strings[i]);
 
+		/* Q counters */
+		for (i = 0; i < MLX5E_NUM_Q_CNTRS(priv); i++)
+			strcpy(data + (idx++) * ETH_GSTRING_LEN,
+			       qcounter_stats_strings[i]);
+
 		/* PPORT counters */
 		for (i = 0; i < NUM_PPORT_COUNTERS; i++)
 			strcpy(data + (idx++) * ETH_GSTRING_LEN,
@@ -240,6 +248,9 @@ static void mlx5e_get_ethtool_stats(struct net_device *dev,
 	for (i = 0; i < NUM_VPORT_COUNTERS; i++)
 		data[idx++] = ((u64 *)&priv->stats.vport)[i];
 
+	for (i = 0; i < MLX5E_NUM_Q_CNTRS(priv); i++)
+		data[idx++] = ((u32 *)&priv->stats.qcnt)[i];
+
 	for (i = 0; i < NUM_PPORT_COUNTERS; i++)
 		data[idx++] = be64_to_cpu(((__be64 *)&priv->stats.pport)[i]);
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index e0adb60..7fbe1ba 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -129,6 +129,17 @@ free_out:
 	kvfree(out);
 }
 
+static void mlx5e_update_q_counter(struct mlx5e_priv *priv)
+{
+	struct mlx5e_qcounter_stats *qcnt = &priv->stats.qcnt;
+
+	if (!priv->q_counter)
+		return;
+
+	mlx5_core_query_out_of_buffer(priv->mdev, priv->q_counter,
+				      &qcnt->rx_out_of_buffer);
+}
+
 void mlx5e_update_stats(struct mlx5e_priv *priv)
 {
 	struct mlx5_core_dev *mdev = priv->mdev;
@@ -250,6 +261,8 @@ void mlx5e_update_stats(struct mlx5e_priv *priv)
 			       s->rx_csum_sw;
 
 	mlx5e_update_pport_counters(priv);
+	mlx5e_update_q_counter(priv);
+
 free_out:
 	kvfree(out);
 }
@@ -1055,6 +1068,7 @@ static void mlx5e_build_rq_param(struct mlx5e_priv *priv,
 	MLX5_SET(wq, wq, log_wq_stride,    ilog2(sizeof(struct mlx5e_rx_wqe)));
 	MLX5_SET(wq, wq, log_wq_sz,        priv->params.log_rq_size);
 	MLX5_SET(wq, wq, pd,               priv->pdn);
+	MLX5_SET(rqc, rqc, counter_set_id, priv->q_counter);
 
 	param->wq.buf_numa_node = dev_to_node(&priv->mdev->pdev->dev);
 	param->wq.linear = 1;
@@ -2442,6 +2456,26 @@ static int mlx5e_create_mkey(struct mlx5e_priv *priv, u32 pdn,
 	return err;
 }
 
+static void mlx5e_create_q_counter(struct mlx5e_priv *priv)
+{
+	struct mlx5_core_dev *mdev = priv->mdev;
+	int err;
+
+	err = mlx5_core_alloc_q_counter(mdev, &priv->q_counter);
+	if (err) {
+		mlx5_core_warn(mdev, "alloc queue counter failed, %d\n", err);
+		priv->q_counter = 0;
+	}
+}
+
+static void mlx5e_destroy_q_counter(struct mlx5e_priv *priv)
+{
+	if (!priv->q_counter)
+		return;
+
+	mlx5_core_dealloc_q_counter(priv->mdev, priv->q_counter);
+}
+
 static void *mlx5e_create_netdev(struct mlx5_core_dev *mdev)
 {
 	struct net_device *netdev;
@@ -2527,13 +2561,15 @@ static void *mlx5e_create_netdev(struct mlx5_core_dev *mdev)
 		goto err_destroy_tirs;
 	}
 
+	mlx5e_create_q_counter(priv);
+
 	mlx5e_init_eth_addr(priv);
 
 	mlx5e_vxlan_init(priv);
 
 	err = mlx5e_tc_init(priv);
 	if (err)
-		goto err_destroy_flow_tables;
+		goto err_dealloc_q_counters;
 
 #ifdef CONFIG_MLX5_CORE_EN_DCB
 	mlx5e_dcbnl_ieee_setets_core(priv, &priv->params.ets);
@@ -2556,7 +2592,8 @@ static void *mlx5e_create_netdev(struct mlx5_core_dev *mdev)
 err_tc_cleanup:
 	mlx5e_tc_cleanup(priv);
 
-err_destroy_flow_tables:
+err_dealloc_q_counters:
+	mlx5e_destroy_q_counter(priv);
 	mlx5e_destroy_flow_tables(priv);
 
 err_destroy_tirs:
@@ -2605,6 +2642,7 @@ static void mlx5e_destroy_netdev(struct mlx5_core_dev *mdev, void *vpriv)
 	unregister_netdev(netdev);
 	mlx5e_tc_cleanup(priv);
 	mlx5e_vxlan_cleanup(priv);
+	mlx5e_destroy_q_counter(priv);
 	mlx5e_destroy_flow_tables(priv);
 	mlx5e_destroy_tirs(priv);
 	mlx5e_destroy_rqt(priv, MLX5E_SINGLE_RQ_RQT);
-- 
1.7.1
