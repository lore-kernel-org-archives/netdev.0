From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 3/6] net/mlx5e: Support TX packet copy into WQE
Date: Thu, 23 Jul 2015 23:35:58 +0300
Message-ID: <1437683761-28052-4-git-send-email-amirv@mellanox.com>
References: <1437683761-28052-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:39705 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754101AbbGWUhA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jul 2015 16:37:00 -0400
In-Reply-To: <1437683761-28052-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Achiad Shochat <achiad@mellanox.com>

AKA inline WQE.
A TX latency optimization to save data gather DMA reads.
Controlled by ETHTOOL_TX_COPYBREAK.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  2 +
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 53 ++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 13 ++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    | 10 +++-
 4 files changed, 77 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 61d8433..d9dc506 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -196,6 +196,7 @@ struct mlx5e_params {
 	bool lro_en;
 	u32 lro_wqe_sz;
 	u8  rss_hfunc;
+	u16 tx_max_inline;
 };
 
 enum {
@@ -520,3 +521,4 @@ static inline void mlx5e_cq_arm(struct mlx5e_cq *cq)
 }
 
 extern const struct ethtool_ops mlx5e_ethtool_ops;
+u16 mlx5e_get_max_inline_cap(struct mlx5_core_dev *mdev);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index cb28535..14fd82c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -699,6 +699,57 @@ static int mlx5e_set_rxfh(struct net_device *netdev, const u32 *indir,
 	return err;
 }
 
+static int mlx5e_get_tunable(struct net_device *dev,
+			     const struct ethtool_tunable *tuna,
+			     void *data)
+{
+	const struct mlx5e_priv *priv = netdev_priv(dev);
+	int err = 0;
+
+	switch (tuna->id) {
+	case ETHTOOL_TX_COPYBREAK:
+		*(u32 *)data = priv->params.tx_max_inline;
+		break;
+	default:
+		err = -EINVAL;
+		break;
+	}
+
+	return err;
+}
+
+static int mlx5e_set_tunable(struct net_device *dev,
+			     const struct ethtool_tunable *tuna,
+			     const void *data)
+{
+	struct mlx5e_priv *priv = netdev_priv(dev);
+	struct mlx5_core_dev *mdev = priv->mdev;
+	struct mlx5e_params new_params;
+	u32 val;
+	int err = 0;
+
+	switch (tuna->id) {
+	case ETHTOOL_TX_COPYBREAK:
+		val = *(u32 *)data;
+		if (val > mlx5e_get_max_inline_cap(mdev)) {
+			err = -EINVAL;
+			break;
+		}
+
+		mutex_lock(&priv->state_lock);
+		new_params = priv->params;
+		new_params.tx_max_inline = val;
+		err = mlx5e_update_priv_params(priv, &new_params);
+		mutex_unlock(&priv->state_lock);
+		break;
+	default:
+		err = -EINVAL;
+		break;
+	}
+
+	return err;
+}
+
 const struct ethtool_ops mlx5e_ethtool_ops = {
 	.get_drvinfo       = mlx5e_get_drvinfo,
 	.get_link          = ethtool_op_get_link,
@@ -715,4 +766,6 @@ const struct ethtool_ops mlx5e_ethtool_ops = {
 	.set_settings      = mlx5e_set_settings,
 	.get_rxfh          = mlx5e_get_rxfh,
 	.set_rxfh          = mlx5e_set_rxfh,
+	.get_tunable       = mlx5e_get_tunable,
+	.set_tunable       = mlx5e_set_tunable,
 };
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 57cc896..c55fad4 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -41,6 +41,7 @@ struct mlx5e_rq_param {
 struct mlx5e_sq_param {
 	u32                        sqc[MLX5_ST_SZ_DW(sqc)];
 	struct mlx5_wq_param       wq;
+	u16                        max_inline;
 };
 
 struct mlx5e_cq_param {
@@ -514,6 +515,7 @@ static int mlx5e_create_sq(struct mlx5e_channel *c,
 	sq->wq.db       = &sq->wq.db[MLX5_SND_DBR];
 	sq->uar_map     = sq->uar.map;
 	sq->bf_buf_size = (1 << MLX5_CAP_GEN(mdev, log_bf_reg_size)) / 2;
+	sq->max_inline  = param->max_inline;
 
 	err = mlx5e_alloc_sq_db(sq, cpu_to_node(c->cpu));
 	if (err)
@@ -1020,6 +1022,7 @@ static void mlx5e_build_sq_param(struct mlx5e_priv *priv,
 	MLX5_SET(wq, wq, pd,            priv->pdn);
 
 	param->wq.buf_numa_node = dev_to_node(&priv->mdev->pdev->dev);
+	param->max_inline = priv->params.tx_max_inline;
 }
 
 static void mlx5e_build_common_cq_param(struct mlx5e_priv *priv,
@@ -1703,6 +1706,15 @@ static int mlx5e_check_required_hca_cap(struct mlx5_core_dev *mdev)
 	return 0;
 }
 
+u16 mlx5e_get_max_inline_cap(struct mlx5_core_dev *mdev)
+{
+	int bf_buf_size = (1 << MLX5_CAP_GEN(mdev, log_bf_reg_size)) / 2;
+
+	return bf_buf_size -
+	       sizeof(struct mlx5e_tx_wqe) +
+	       2 /*sizeof(mlx5e_tx_wqe.inline_hdr_start)*/;
+}
+
 static void mlx5e_build_netdev_priv(struct mlx5_core_dev *mdev,
 				    struct net_device *netdev,
 				    int num_comp_vectors)
@@ -1721,6 +1733,7 @@ static void mlx5e_build_netdev_priv(struct mlx5_core_dev *mdev,
 		MLX5E_PARAMS_DEFAULT_TX_CQ_MODERATION_USEC;
 	priv->params.tx_cq_moderation_pkts =
 		MLX5E_PARAMS_DEFAULT_TX_CQ_MODERATION_PKTS;
+	priv->params.tx_max_inline         = mlx5e_get_max_inline_cap(mdev);
 	priv->params.min_rx_wqes           =
 		MLX5E_PARAMS_DEFAULT_MIN_RX_WQES;
 	priv->params.rx_hash_log_tbl_sz    =
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index 03f28f4..351ac69 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -112,7 +112,15 @@ u16 mlx5e_select_queue(struct net_device *dev, struct sk_buff *skb,
 static inline u16 mlx5e_get_inline_hdr_size(struct mlx5e_sq *sq,
 					    struct sk_buff *skb)
 {
-#define MLX5E_MIN_INLINE 16 /* eth header with vlan (w/o next ethertype) */
+	/* Some NIC TX decisions, e.g loopback, are based on the packet
+	 * headers and occur before the data gather.
+	 * Therefore these headers must be copied into the WQE
+	 */
+#define MLX5E_MIN_INLINE (ETH_HLEN + 2/*vlan tag*/)
+
+	if (skb_headlen(skb) <= sq->max_inline)
+		return skb_headlen(skb);
+
 	return MLX5E_MIN_INLINE;
 }
 
-- 
2.4.3.413.ga5fe668
