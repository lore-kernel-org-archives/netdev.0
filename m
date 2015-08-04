From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 5/8] net/mlx5e: Rename/move functions following the ndo_stop flow change
Date: Tue,  4 Aug 2015 14:05:44 +0300
Message-ID: <1438686347-17370-6-git-send-email-amirv@mellanox.com>
References: <1438686347-17370-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Achiad Shochat <achiad@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:36434 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932776AbbHDLGU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Aug 2015 07:06:20 -0400
In-Reply-To: <1438686347-17370-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Achiad Shochat <achiad@mellanox.com>

Rename some functions that used to be invoked upon ndo_open/stop and
are now invoked upon create/destroy_netdev() in order to better hint
their place in the flow.

Change some functions location in the file so that functions involved
in ndo_open/stop flow will not be interleaved with other functions.

This is a cosmetic change, no logical change here.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |   4 +-
 .../ethernet/mellanox/mlx5/core/en_flow_table.c    |   4 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 606 ++++++++++-----------
 3 files changed, 306 insertions(+), 308 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 31e9610..a6c4bd3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -482,8 +482,8 @@ struct mlx5_cqe64 *mlx5e_get_cqe(struct mlx5e_cq *cq);
 
 void mlx5e_update_stats(struct mlx5e_priv *priv);
 
-int mlx5e_open_flow_table(struct mlx5e_priv *priv);
-void mlx5e_close_flow_table(struct mlx5e_priv *priv);
+int mlx5e_create_flow_tables(struct mlx5e_priv *priv);
+void mlx5e_destroy_flow_tables(struct mlx5e_priv *priv);
 void mlx5e_init_eth_addr(struct mlx5e_priv *priv);
 void mlx5e_set_rx_mode_core(struct mlx5e_priv *priv);
 void mlx5e_set_rx_mode_work(struct work_struct *work);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c b/drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c
index 70ec31b..d99be78 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c
@@ -929,7 +929,7 @@ static void mlx5e_destroy_vlan_flow_table(struct mlx5e_priv *priv)
 	mlx5_destroy_flow_table(priv->ft.vlan);
 }
 
-int mlx5e_open_flow_table(struct mlx5e_priv *priv)
+int mlx5e_create_flow_tables(struct mlx5e_priv *priv)
 {
 	int err;
 
@@ -949,7 +949,7 @@ err_destroy_main_flow_table:
 	return err;
 }
 
-void mlx5e_close_flow_table(struct mlx5e_priv *priv)
+void mlx5e_destroy_flow_tables(struct mlx5e_priv *priv)
 {
 	mlx5e_destroy_vlan_flow_table(priv);
 	mlx5e_destroy_main_flow_table(priv);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 33d08bb..33a0488 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1114,158 +1114,6 @@ static void mlx5e_close_channels(struct mlx5e_priv *priv)
 	kfree(priv->channel);
 }
 
-static int mlx5e_create_drop_rq(struct mlx5e_priv *priv,
-				struct mlx5e_rq *rq,
-				struct mlx5e_rq_param *param)
-{
-	struct mlx5_core_dev *mdev = priv->mdev;
-	void *rqc = param->rqc;
-	void *rqc_wq = MLX5_ADDR_OF(rqc, rqc, wq);
-	int err;
-
-	param->wq.db_numa_node = param->wq.buf_numa_node;
-
-	err = mlx5_wq_ll_create(mdev, &param->wq, rqc_wq, &rq->wq,
-				&rq->wq_ctrl);
-	if (err)
-		return err;
-
-	rq->priv = priv;
-
-	return 0;
-}
-
-static int mlx5e_create_drop_cq(struct mlx5e_priv *priv,
-				struct mlx5e_cq *cq,
-				struct mlx5e_cq_param *param)
-{
-	struct mlx5_core_dev *mdev = priv->mdev;
-	struct mlx5_core_cq *mcq = &cq->mcq;
-	int eqn_not_used;
-	int irqn;
-	int err;
-
-	err = mlx5_cqwq_create(mdev, &param->wq, param->cqc, &cq->wq,
-			       &cq->wq_ctrl);
-	if (err)
-		return err;
-
-	mlx5_vector2eqn(mdev, param->eq_ix, &eqn_not_used, &irqn);
-
-	mcq->cqe_sz     = 64;
-	mcq->set_ci_db  = cq->wq_ctrl.db.db;
-	mcq->arm_db     = cq->wq_ctrl.db.db + 1;
-	*mcq->set_ci_db = 0;
-	*mcq->arm_db    = 0;
-	mcq->vector     = param->eq_ix;
-	mcq->comp       = mlx5e_completion_event;
-	mcq->event      = mlx5e_cq_error_event;
-	mcq->irqn       = irqn;
-	mcq->uar        = &priv->cq_uar;
-
-	cq->priv = priv;
-
-	return 0;
-}
-
-static int mlx5e_open_drop_rq(struct mlx5e_priv *priv)
-{
-	struct mlx5e_cq_param cq_param;
-	struct mlx5e_rq_param rq_param;
-	struct mlx5e_rq *rq = &priv->drop_rq;
-	struct mlx5e_cq *cq = &priv->drop_rq.cq;
-	int err;
-
-	memset(&cq_param, 0, sizeof(cq_param));
-	memset(&rq_param, 0, sizeof(rq_param));
-	mlx5e_build_rx_cq_param(priv, &cq_param);
-	mlx5e_build_rq_param(priv, &rq_param);
-
-	err = mlx5e_create_drop_cq(priv, cq, &cq_param);
-	if (err)
-		return err;
-
-	err = mlx5e_enable_cq(cq, &cq_param);
-	if (err)
-		goto err_destroy_cq;
-
-	err = mlx5e_create_drop_rq(priv, rq, &rq_param);
-	if (err)
-		goto err_disable_cq;
-
-	err = mlx5e_enable_rq(rq, &rq_param);
-	if (err)
-		goto err_destroy_rq;
-
-	return 0;
-
-err_destroy_rq:
-	mlx5e_destroy_rq(&priv->drop_rq);
-
-err_disable_cq:
-	mlx5e_disable_cq(&priv->drop_rq.cq);
-
-err_destroy_cq:
-	mlx5e_destroy_cq(&priv->drop_rq.cq);
-
-	return err;
-}
-
-static void mlx5e_close_drop_rq(struct mlx5e_priv *priv)
-{
-	mlx5e_disable_rq(&priv->drop_rq);
-	mlx5e_destroy_rq(&priv->drop_rq);
-	mlx5e_disable_cq(&priv->drop_rq.cq);
-	mlx5e_destroy_cq(&priv->drop_rq.cq);
-}
-
-static int mlx5e_open_tis(struct mlx5e_priv *priv, int tc)
-{
-	struct mlx5_core_dev *mdev = priv->mdev;
-	u32 in[MLX5_ST_SZ_DW(create_tis_in)];
-	void *tisc = MLX5_ADDR_OF(create_tis_in, in, ctx);
-
-	memset(in, 0, sizeof(in));
-
-	MLX5_SET(tisc, tisc, prio,  tc);
-	MLX5_SET(tisc, tisc, transport_domain, priv->tdn);
-
-	return mlx5_core_create_tis(mdev, in, sizeof(in), &priv->tisn[tc]);
-}
-
-static void mlx5e_close_tis(struct mlx5e_priv *priv, int tc)
-{
-	mlx5_core_destroy_tis(priv->mdev, priv->tisn[tc]);
-}
-
-static int mlx5e_open_tises(struct mlx5e_priv *priv)
-{
-	int err;
-	int tc;
-
-	for (tc = 0; tc < priv->params.num_tc; tc++) {
-		err = mlx5e_open_tis(priv, tc);
-		if (err)
-			goto err_close_tises;
-	}
-
-	return 0;
-
-err_close_tises:
-	for (tc--; tc >= 0; tc--)
-		mlx5e_close_tis(priv, tc);
-
-	return err;
-}
-
-static void mlx5e_close_tises(struct mlx5e_priv *priv)
-{
-	int tc;
-
-	for (tc = 0; tc < priv->params.num_tc; tc++)
-		mlx5e_close_tis(priv, tc);
-}
-
 static int mlx5e_rx_hash_fn(int hfunc)
 {
 	return (hfunc == ETH_RSS_HASH_TOP) ?
@@ -1318,7 +1166,7 @@ static void mlx5e_fill_rqt_rqns(struct mlx5e_priv *priv, void *rqtc,
 	}
 }
 
-static int mlx5e_open_rqt(struct mlx5e_priv *priv, enum mlx5e_rqt_ix rqt_ix)
+static int mlx5e_create_rqt(struct mlx5e_priv *priv, enum mlx5e_rqt_ix rqt_ix)
 {
 	struct mlx5_core_dev *mdev = priv->mdev;
 	u32 *in;
@@ -1385,11 +1233,17 @@ static int mlx5e_redirect_rqt(struct mlx5e_priv *priv, enum mlx5e_rqt_ix rqt_ix)
 	return err;
 }
 
-static void mlx5e_close_rqt(struct mlx5e_priv *priv, enum mlx5e_rqt_ix rqt_ix)
+static void mlx5e_destroy_rqt(struct mlx5e_priv *priv, enum mlx5e_rqt_ix rqt_ix)
 {
 	mlx5_core_destroy_rqt(priv->mdev, priv->rqtn[rqt_ix]);
 }
 
+static void mlx5e_redirect_rqts(struct mlx5e_priv *priv)
+{
+	mlx5e_redirect_rqt(priv, MLX5E_INDIRECTION_RQT);
+	mlx5e_redirect_rqt(priv, MLX5E_SINGLE_RQ_RQT);
+}
+
 static void mlx5e_build_tir_ctx_lro(void *tirc, struct mlx5e_priv *priv)
 {
 	if (!priv->params.lro_en)
@@ -1434,6 +1288,261 @@ static int mlx5e_modify_tir_lro(struct mlx5e_priv *priv, int tt)
 	return err;
 }
 
+static int mlx5e_set_dev_port_mtu(struct net_device *netdev)
+{
+	struct mlx5e_priv *priv = netdev_priv(netdev);
+	struct mlx5_core_dev *mdev = priv->mdev;
+	int hw_mtu;
+	int err;
+
+	err = mlx5_set_port_mtu(mdev, MLX5E_SW2HW_MTU(netdev->mtu), 1);
+	if (err)
+		return err;
+
+	mlx5_query_port_oper_mtu(mdev, &hw_mtu, 1);
+
+	if (MLX5E_HW2SW_MTU(hw_mtu) != netdev->mtu)
+		netdev_warn(netdev, "%s: Port MTU %d is different than netdev mtu %d\n",
+			    __func__, MLX5E_HW2SW_MTU(hw_mtu), netdev->mtu);
+
+	netdev->mtu = MLX5E_HW2SW_MTU(hw_mtu);
+	return 0;
+}
+
+int mlx5e_open_locked(struct net_device *netdev)
+{
+	struct mlx5e_priv *priv = netdev_priv(netdev);
+	int num_txqs;
+	int err;
+
+	set_bit(MLX5E_STATE_OPENED, &priv->state);
+
+	num_txqs = priv->params.num_channels * priv->params.num_tc;
+	netif_set_real_num_tx_queues(netdev, num_txqs);
+	netif_set_real_num_rx_queues(netdev, priv->params.num_channels);
+
+	err = mlx5e_set_dev_port_mtu(netdev);
+	if (err)
+		return err;
+
+	err = mlx5e_open_channels(priv);
+	if (err) {
+		netdev_err(netdev, "%s: mlx5e_open_channels failed, %d\n",
+			   __func__, err);
+		return err;
+	}
+
+	err = mlx5e_add_all_vlan_rules(priv);
+	if (err) {
+		netdev_err(netdev, "%s: mlx5e_add_all_vlan_rules failed, %d\n",
+			   __func__, err);
+		goto err_close_channels;
+	}
+
+	mlx5e_update_carrier(priv);
+	mlx5e_redirect_rqts(priv);
+	mlx5e_set_rx_mode_core(priv);
+
+	schedule_delayed_work(&priv->update_stats_work, 0);
+	return 0;
+
+err_close_channels:
+	mlx5e_close_channels(priv);
+
+	return err;
+}
+
+static int mlx5e_open(struct net_device *netdev)
+{
+	struct mlx5e_priv *priv = netdev_priv(netdev);
+	int err;
+
+	mutex_lock(&priv->state_lock);
+	err = mlx5e_open_locked(netdev);
+	mutex_unlock(&priv->state_lock);
+
+	return err;
+}
+
+int mlx5e_close_locked(struct net_device *netdev)
+{
+	struct mlx5e_priv *priv = netdev_priv(netdev);
+
+	clear_bit(MLX5E_STATE_OPENED, &priv->state);
+
+	mlx5e_redirect_rqts(priv);
+	mlx5e_set_rx_mode_core(priv);
+	mlx5e_del_all_vlan_rules(priv);
+	netif_carrier_off(priv->netdev);
+	mlx5e_close_channels(priv);
+
+	return 0;
+}
+
+static int mlx5e_close(struct net_device *netdev)
+{
+	struct mlx5e_priv *priv = netdev_priv(netdev);
+	int err;
+
+	mutex_lock(&priv->state_lock);
+	err = mlx5e_close_locked(netdev);
+	mutex_unlock(&priv->state_lock);
+
+	return err;
+}
+
+static int mlx5e_create_drop_rq(struct mlx5e_priv *priv,
+				struct mlx5e_rq *rq,
+				struct mlx5e_rq_param *param)
+{
+	struct mlx5_core_dev *mdev = priv->mdev;
+	void *rqc = param->rqc;
+	void *rqc_wq = MLX5_ADDR_OF(rqc, rqc, wq);
+	int err;
+
+	param->wq.db_numa_node = param->wq.buf_numa_node;
+
+	err = mlx5_wq_ll_create(mdev, &param->wq, rqc_wq, &rq->wq,
+				&rq->wq_ctrl);
+	if (err)
+		return err;
+
+	rq->priv = priv;
+
+	return 0;
+}
+
+static int mlx5e_create_drop_cq(struct mlx5e_priv *priv,
+				struct mlx5e_cq *cq,
+				struct mlx5e_cq_param *param)
+{
+	struct mlx5_core_dev *mdev = priv->mdev;
+	struct mlx5_core_cq *mcq = &cq->mcq;
+	int eqn_not_used;
+	int irqn;
+	int err;
+
+	err = mlx5_cqwq_create(mdev, &param->wq, param->cqc, &cq->wq,
+			       &cq->wq_ctrl);
+	if (err)
+		return err;
+
+	mlx5_vector2eqn(mdev, param->eq_ix, &eqn_not_used, &irqn);
+
+	mcq->cqe_sz     = 64;
+	mcq->set_ci_db  = cq->wq_ctrl.db.db;
+	mcq->arm_db     = cq->wq_ctrl.db.db + 1;
+	*mcq->set_ci_db = 0;
+	*mcq->arm_db    = 0;
+	mcq->vector     = param->eq_ix;
+	mcq->comp       = mlx5e_completion_event;
+	mcq->event      = mlx5e_cq_error_event;
+	mcq->irqn       = irqn;
+	mcq->uar        = &priv->cq_uar;
+
+	cq->priv = priv;
+
+	return 0;
+}
+
+static int mlx5e_open_drop_rq(struct mlx5e_priv *priv)
+{
+	struct mlx5e_cq_param cq_param;
+	struct mlx5e_rq_param rq_param;
+	struct mlx5e_rq *rq = &priv->drop_rq;
+	struct mlx5e_cq *cq = &priv->drop_rq.cq;
+	int err;
+
+	memset(&cq_param, 0, sizeof(cq_param));
+	memset(&rq_param, 0, sizeof(rq_param));
+	mlx5e_build_rx_cq_param(priv, &cq_param);
+	mlx5e_build_rq_param(priv, &rq_param);
+
+	err = mlx5e_create_drop_cq(priv, cq, &cq_param);
+	if (err)
+		return err;
+
+	err = mlx5e_enable_cq(cq, &cq_param);
+	if (err)
+		goto err_destroy_cq;
+
+	err = mlx5e_create_drop_rq(priv, rq, &rq_param);
+	if (err)
+		goto err_disable_cq;
+
+	err = mlx5e_enable_rq(rq, &rq_param);
+	if (err)
+		goto err_destroy_rq;
+
+	return 0;
+
+err_destroy_rq:
+	mlx5e_destroy_rq(&priv->drop_rq);
+
+err_disable_cq:
+	mlx5e_disable_cq(&priv->drop_rq.cq);
+
+err_destroy_cq:
+	mlx5e_destroy_cq(&priv->drop_rq.cq);
+
+	return err;
+}
+
+static void mlx5e_close_drop_rq(struct mlx5e_priv *priv)
+{
+	mlx5e_disable_rq(&priv->drop_rq);
+	mlx5e_destroy_rq(&priv->drop_rq);
+	mlx5e_disable_cq(&priv->drop_rq.cq);
+	mlx5e_destroy_cq(&priv->drop_rq.cq);
+}
+
+static int mlx5e_create_tis(struct mlx5e_priv *priv, int tc)
+{
+	struct mlx5_core_dev *mdev = priv->mdev;
+	u32 in[MLX5_ST_SZ_DW(create_tis_in)];
+	void *tisc = MLX5_ADDR_OF(create_tis_in, in, ctx);
+
+	memset(in, 0, sizeof(in));
+
+	MLX5_SET(tisc, tisc, prio,  tc);
+	MLX5_SET(tisc, tisc, transport_domain, priv->tdn);
+
+	return mlx5_core_create_tis(mdev, in, sizeof(in), &priv->tisn[tc]);
+}
+
+static void mlx5e_destroy_tis(struct mlx5e_priv *priv, int tc)
+{
+	mlx5_core_destroy_tis(priv->mdev, priv->tisn[tc]);
+}
+
+static int mlx5e_create_tises(struct mlx5e_priv *priv)
+{
+	int err;
+	int tc;
+
+	for (tc = 0; tc < priv->params.num_tc; tc++) {
+		err = mlx5e_create_tis(priv, tc);
+		if (err)
+			goto err_close_tises;
+	}
+
+	return 0;
+
+err_close_tises:
+	for (tc--; tc >= 0; tc--)
+		mlx5e_destroy_tis(priv, tc);
+
+	return err;
+}
+
+static void mlx5e_destroy_tises(struct mlx5e_priv *priv)
+{
+	int tc;
+
+	for (tc = 0; tc < priv->params.num_tc; tc++)
+		mlx5e_destroy_tis(priv, tc);
+}
+
 static void mlx5e_build_tir_ctx(struct mlx5e_priv *priv, u32 *tirc, int tt)
 {
 	void *hfso = MLX5_ADDR_OF(tirc, tirc, rx_hash_field_selector_outer);
@@ -1560,7 +1669,7 @@ static void mlx5e_build_tir_ctx(struct mlx5e_priv *priv, u32 *tirc, int tt)
 	}
 }
 
-static int mlx5e_open_tir(struct mlx5e_priv *priv, int tt)
+static int mlx5e_create_tir(struct mlx5e_priv *priv, int tt)
 {
 	struct mlx5_core_dev *mdev = priv->mdev;
 	u32 *in;
@@ -1584,148 +1693,37 @@ static int mlx5e_open_tir(struct mlx5e_priv *priv, int tt)
 	return err;
 }
 
-static void mlx5e_close_tir(struct mlx5e_priv *priv, int tt)
+static void mlx5e_destroy_tir(struct mlx5e_priv *priv, int tt)
 {
 	mlx5_core_destroy_tir(priv->mdev, priv->tirn[tt]);
 }
 
-static int mlx5e_open_tirs(struct mlx5e_priv *priv)
+static int mlx5e_create_tirs(struct mlx5e_priv *priv)
 {
 	int err;
 	int i;
 
 	for (i = 0; i < MLX5E_NUM_TT; i++) {
-		err = mlx5e_open_tir(priv, i);
+		err = mlx5e_create_tir(priv, i);
 		if (err)
-			goto err_close_tirs;
+			goto err_destroy_tirs;
 	}
 
 	return 0;
 
-err_close_tirs:
+err_destroy_tirs:
 	for (i--; i >= 0; i--)
-		mlx5e_close_tir(priv, i);
+		mlx5e_destroy_tir(priv, i);
 
 	return err;
 }
 
-static void mlx5e_close_tirs(struct mlx5e_priv *priv)
+static void mlx5e_destroy_tirs(struct mlx5e_priv *priv)
 {
 	int i;
 
 	for (i = 0; i < MLX5E_NUM_TT; i++)
-		mlx5e_close_tir(priv, i);
-}
-
-static int mlx5e_set_dev_port_mtu(struct net_device *netdev)
-{
-	struct mlx5e_priv *priv = netdev_priv(netdev);
-	struct mlx5_core_dev *mdev = priv->mdev;
-	int hw_mtu;
-	int err;
-
-	err = mlx5_set_port_mtu(mdev, MLX5E_SW2HW_MTU(netdev->mtu), 1);
-	if (err)
-		return err;
-
-	mlx5_query_port_oper_mtu(mdev, &hw_mtu, 1);
-
-	if (MLX5E_HW2SW_MTU(hw_mtu) != netdev->mtu)
-		netdev_warn(netdev, "%s: Port MTU %d is different than netdev mtu %d\n",
-			    __func__, MLX5E_HW2SW_MTU(hw_mtu), netdev->mtu);
-
-	netdev->mtu = MLX5E_HW2SW_MTU(hw_mtu);
-	return 0;
-}
-
-static void mlx5e_redirect_rqts(struct mlx5e_priv *priv)
-{
-	mlx5e_redirect_rqt(priv, MLX5E_INDIRECTION_RQT);
-	mlx5e_redirect_rqt(priv, MLX5E_SINGLE_RQ_RQT);
-}
-
-int mlx5e_open_locked(struct net_device *netdev)
-{
-	struct mlx5e_priv *priv = netdev_priv(netdev);
-	int num_txqs;
-	int err;
-
-	set_bit(MLX5E_STATE_OPENED, &priv->state);
-
-	num_txqs = priv->params.num_channels * priv->params.num_tc;
-	netif_set_real_num_tx_queues(netdev, num_txqs);
-	netif_set_real_num_rx_queues(netdev, priv->params.num_channels);
-
-	err = mlx5e_set_dev_port_mtu(netdev);
-	if (err)
-		return err;
-
-	err = mlx5e_open_channels(priv);
-	if (err) {
-		netdev_err(netdev, "%s: mlx5e_open_channels failed, %d\n",
-			   __func__, err);
-		return err;
-	}
-
-	err = mlx5e_add_all_vlan_rules(priv);
-	if (err) {
-		netdev_err(netdev, "%s: mlx5e_add_all_vlan_rules failed, %d\n",
-			   __func__, err);
-		goto err_close_channels;
-	}
-
-	mlx5e_init_eth_addr(priv);
-
-	mlx5e_update_carrier(priv);
-	mlx5e_redirect_rqts(priv);
-	mlx5e_set_rx_mode_core(priv);
-
-	schedule_delayed_work(&priv->update_stats_work, 0);
-	return 0;
-
-err_close_channels:
-	mlx5e_close_channels(priv);
-
-	return err;
-}
-
-static int mlx5e_open(struct net_device *netdev)
-{
-	struct mlx5e_priv *priv = netdev_priv(netdev);
-	int err;
-
-	mutex_lock(&priv->state_lock);
-	err = mlx5e_open_locked(netdev);
-	mutex_unlock(&priv->state_lock);
-
-	return err;
-}
-
-int mlx5e_close_locked(struct net_device *netdev)
-{
-	struct mlx5e_priv *priv = netdev_priv(netdev);
-
-	clear_bit(MLX5E_STATE_OPENED, &priv->state);
-
-	mlx5e_set_rx_mode_core(priv);
-	mlx5e_del_all_vlan_rules(priv);
-	mlx5e_redirect_rqts(priv);
-	netif_carrier_off(priv->netdev);
-	mlx5e_close_channels(priv);
-
-	return 0;
-}
-
-static int mlx5e_close(struct net_device *netdev)
-{
-	struct mlx5e_priv *priv = netdev_priv(netdev);
-	int err;
-
-	mutex_lock(&priv->state_lock);
-	err = mlx5e_close_locked(netdev);
-	mutex_unlock(&priv->state_lock);
-
-	return err;
+		mlx5e_destroy_tir(priv, i);
 }
 
 static struct rtnl_link_stats64 *
@@ -2051,40 +2049,40 @@ static void *mlx5e_create_netdev(struct mlx5_core_dev *mdev)
 		goto err_dealloc_transport_domain;
 	}
 
-	err = mlx5e_open_tises(priv);
+	err = mlx5e_create_tises(priv);
 	if (err) {
-		mlx5_core_warn(mdev, "open tises failed, %d\n", err);
+		mlx5_core_warn(mdev, "create tises failed, %d\n", err);
 		goto err_destroy_mkey;
 	}
 
 	err = mlx5e_open_drop_rq(priv);
 	if (err) {
 		mlx5_core_err(mdev, "open drop rq failed, %d\n", err);
-		goto err_close_tises;
+		goto err_destroy_tises;
 	}
 
-	err = mlx5e_open_rqt(priv, MLX5E_INDIRECTION_RQT);
+	err = mlx5e_create_rqt(priv, MLX5E_INDIRECTION_RQT);
 	if (err) {
-		mlx5_core_warn(mdev, "open rqt(INDIR) failed, %d\n", err);
+		mlx5_core_warn(mdev, "create rqt(INDIR) failed, %d\n", err);
 		goto err_close_drop_rq;
 	}
 
-	err = mlx5e_open_rqt(priv, MLX5E_SINGLE_RQ_RQT);
+	err = mlx5e_create_rqt(priv, MLX5E_SINGLE_RQ_RQT);
 	if (err) {
-		mlx5_core_warn(mdev, "open rqt(SINGLE) failed, %d\n", err);
-		goto err_close_rqt_indir;
+		mlx5_core_warn(mdev, "create rqt(SINGLE) failed, %d\n", err);
+		goto err_destroy_rqt_indir;
 	}
 
-	err = mlx5e_open_tirs(priv);
+	err = mlx5e_create_tirs(priv);
 	if (err) {
-		mlx5_core_warn(mdev, "open tirs failed, %d\n", err);
-		goto err_close_rqt_single;
+		mlx5_core_warn(mdev, "create tirs failed, %d\n", err);
+		goto err_destroy_rqt_single;
 	}
 
-	err = mlx5e_open_flow_table(priv);
+	err = mlx5e_create_flow_tables(priv);
 	if (err) {
-		mlx5_core_warn(mdev, "open flow table failed, %d\n", err);
-		goto err_close_tirs;
+		mlx5_core_warn(mdev, "create flow tables failed, %d\n", err);
+		goto err_destroy_tirs;
 	}
 
 	mlx5e_init_eth_addr(priv);
@@ -2092,30 +2090,30 @@ static void *mlx5e_create_netdev(struct mlx5_core_dev *mdev)
 	err = register_netdev(netdev);
 	if (err) {
 		mlx5_core_err(mdev, "register_netdev failed, %d\n", err);
-		goto err_close_flow_table;
+		goto err_destroy_flow_tables;
 	}
 
 	mlx5e_enable_async_events(priv);
 
 	return priv;
 
-err_close_flow_table:
-	mlx5e_close_flow_table(priv);
+err_destroy_flow_tables:
+	mlx5e_destroy_flow_tables(priv);
 
-err_close_tirs:
-	mlx5e_close_tirs(priv);
+err_destroy_tirs:
+	mlx5e_destroy_tirs(priv);
 
-err_close_rqt_single:
-	mlx5e_close_rqt(priv, MLX5E_SINGLE_RQ_RQT);
+err_destroy_rqt_single:
+	mlx5e_destroy_rqt(priv, MLX5E_SINGLE_RQ_RQT);
 
-err_close_rqt_indir:
-	mlx5e_close_rqt(priv, MLX5E_INDIRECTION_RQT);
+err_destroy_rqt_indir:
+	mlx5e_destroy_rqt(priv, MLX5E_INDIRECTION_RQT);
 
 err_close_drop_rq:
 	mlx5e_close_drop_rq(priv);
 
-err_close_tises:
-	mlx5e_close_tises(priv);
+err_destroy_tises:
+	mlx5e_destroy_tises(priv);
 
 err_destroy_mkey:
 	mlx5_core_destroy_mkey(mdev, &priv->mr);
@@ -2141,12 +2139,12 @@ static void mlx5e_destroy_netdev(struct mlx5_core_dev *mdev, void *vpriv)
 	struct net_device *netdev = priv->netdev;
 
 	unregister_netdev(netdev);
-	mlx5e_close_flow_table(priv);
-	mlx5e_close_tirs(priv);
-	mlx5e_close_rqt(priv, MLX5E_SINGLE_RQ_RQT);
-	mlx5e_close_rqt(priv, MLX5E_INDIRECTION_RQT);
+	mlx5e_destroy_flow_tables(priv);
+	mlx5e_destroy_tirs(priv);
+	mlx5e_destroy_rqt(priv, MLX5E_SINGLE_RQ_RQT);
+	mlx5e_destroy_rqt(priv, MLX5E_INDIRECTION_RQT);
 	mlx5e_close_drop_rq(priv);
-	mlx5e_close_tises(priv);
+	mlx5e_destroy_tises(priv);
 	mlx5_core_destroy_mkey(priv->mdev, &priv->mr);
 	mlx5_dealloc_transport_domain(priv->mdev, priv->tdn);
 	mlx5_core_dealloc_pd(priv->mdev, priv->pdn);
-- 
2.4.3.413.ga5fe668
