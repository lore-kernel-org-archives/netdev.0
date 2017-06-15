From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 13/15] net/mlx5e: Optimize update stats work
Date: Fri, 16 Jun 2017 00:42:50 +0300
Message-ID: <20170615214252.30140-14-saeedm@mellanox.com>
References: <20170615214252.30140-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Gal Pressman <galp@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>, kernel-team@fb.com
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:32940 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752269AbdFOVnF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 17:43:05 -0400
In-Reply-To: <20170615214252.30140-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

Unlike ethtool stats, get_stats ndo provides information cached by
update stats work that is running in the background without updating
them explicitly.
We cannot update all counters inside the ndo because some
updates require firmware commands that cannot be performed under a
spinlock.

update_stats work does not need to update ALL counters, since only
some of them are needed by ndo_get_stats.
This patch will allow for a minimal run of update_stats using an extra
parameter which will update necessary counters only and cut 13
firmware commands in each iteration of the work.

Work duration previous to this patch: ~4200us.
Work duration after this patch: ~700us (17% of the original time).

Signed-off-by: Gal Pressman <galp@mellanox.com>
Reviewed-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Cc: kernel-team@fb.com
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h         |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c    | 19 ++++++++++++++-----
 3 files changed, 16 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index a0516b0a5273..8094e78292de 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -822,7 +822,7 @@ void mlx5e_rx_am(struct mlx5e_rq *rq);
 void mlx5e_rx_am_work(struct work_struct *work);
 struct mlx5e_cq_moder mlx5e_am_get_def_profile(u8 rx_cq_period_mode);
 
-void mlx5e_update_stats(struct mlx5e_priv *priv);
+void mlx5e_update_stats(struct mlx5e_priv *priv, bool full);
 
 int mlx5e_create_flow_steering(struct mlx5e_priv *priv);
 void mlx5e_destroy_flow_steering(struct mlx5e_priv *priv);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index b4514f247402..216752070391 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -311,7 +311,7 @@ static void mlx5e_get_ethtool_stats(struct net_device *dev,
 
 	mutex_lock(&priv->state_lock);
 	if (test_bit(MLX5E_STATE_OPENED, &priv->state))
-		mlx5e_update_stats(priv);
+		mlx5e_update_stats(priv, true);
 	channels = &priv->channels;
 	mutex_unlock(&priv->state_lock);
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 8bb0241df069..2e9a4187a533 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -244,7 +244,7 @@ static void mlx5e_update_vport_counters(struct mlx5e_priv *priv)
 	mlx5_cmd_exec(mdev, in, sizeof(in), out, outlen);
 }
 
-static void mlx5e_update_pport_counters(struct mlx5e_priv *priv)
+static void mlx5e_update_pport_counters(struct mlx5e_priv *priv, bool full)
 {
 	struct mlx5e_pport_stats *pstats = &priv->stats.pport;
 	struct mlx5_core_dev *mdev = priv->mdev;
@@ -259,6 +259,9 @@ static void mlx5e_update_pport_counters(struct mlx5e_priv *priv)
 	MLX5_SET(ppcnt_reg, in, grp, MLX5_IEEE_802_3_COUNTERS_GROUP);
 	mlx5_core_access_reg(mdev, in, sz, out, sz, MLX5_REG_PPCNT, 0, 0);
 
+	if (!full)
+		return;
+
 	out = pstats->RFC_2863_counters;
 	MLX5_SET(ppcnt_reg, in, grp, MLX5_RFC_2863_COUNTERS_GROUP);
 	mlx5_core_access_reg(mdev, in, sz, out, sz, MLX5_REG_PPCNT, 0, 0);
@@ -318,15 +321,21 @@ static void mlx5e_update_pcie_counters(struct mlx5e_priv *priv)
 	mlx5_core_access_reg(mdev, in, sz, out, sz, MLX5_REG_MPCNT, 0, 0);
 }
 
-void mlx5e_update_stats(struct mlx5e_priv *priv)
+void mlx5e_update_stats(struct mlx5e_priv *priv, bool full)
 {
-	mlx5e_update_pcie_counters(priv);
-	mlx5e_update_pport_counters(priv);
+	if (full)
+		mlx5e_update_pcie_counters(priv);
+	mlx5e_update_pport_counters(priv, full);
 	mlx5e_update_vport_counters(priv);
 	mlx5e_update_q_counter(priv);
 	mlx5e_update_sw_counters(priv);
 }
 
+static void mlx5e_update_ndo_stats(struct mlx5e_priv *priv)
+{
+	mlx5e_update_stats(priv, false);
+}
+
 void mlx5e_update_stats_work(struct work_struct *work)
 {
 	struct delayed_work *dwork = to_delayed_work(work);
@@ -4195,7 +4204,7 @@ static const struct mlx5e_profile mlx5e_nic_profile = {
 	.cleanup_tx	   = mlx5e_cleanup_nic_tx,
 	.enable		   = mlx5e_nic_enable,
 	.disable	   = mlx5e_nic_disable,
-	.update_stats	   = mlx5e_update_stats,
+	.update_stats	   = mlx5e_update_ndo_stats,
 	.max_nch	   = mlx5e_get_max_num_channels,
 	.rx_handlers.handle_rx_cqe       = mlx5e_handle_rx_cqe,
 	.rx_handlers.handle_rx_cqe_mpwqe = mlx5e_handle_rx_cqe_mpwrq,
-- 
2.11.0
