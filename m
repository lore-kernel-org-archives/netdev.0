From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V2 1/9] net/mlx5e: Replace async events spinlock with synchronize_irq()
Date: Tue,  1 Mar 2016 17:42:14 +0200
Message-ID: <1456846942-15082-2-git-send-email-saeedm@mellanox.com>
References: <1456846942-15082-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:50531 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754503AbcCAPqM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Mar 2016 10:46:12 -0500
In-Reply-To: <1456846942-15082-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

We only need to flush the irq handler to make sure it does not
queue a work into the global work queue after we start to flush it.
So using synchronize_irq() is more appropriate than a spin lock.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |    1 -
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |   24 ++++++-------------
 drivers/net/ethernet/mellanox/mlx5/core/eq.c       |    5 ++++
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |    1 +
 4 files changed, 14 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 1dca3dc..4511984 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -555,7 +555,6 @@ struct mlx5e_priv {
 	struct mlx5e_vxlan_db      vxlan;
 
 	struct mlx5e_params        params;
-	spinlock_t                 async_events_spinlock; /* sync hw events */
 	struct work_struct         update_carrier_work;
 	struct work_struct         set_rx_mode_work;
 	struct delayed_work        update_stats_work;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 0d45f35..38944b8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -275,9 +275,14 @@ static void mlx5e_update_stats_work(struct work_struct *work)
 	mutex_unlock(&priv->state_lock);
 }
 
-static void __mlx5e_async_event(struct mlx5e_priv *priv,
-				enum mlx5_dev_event event)
+static void mlx5e_async_event(struct mlx5_core_dev *mdev, void *vpriv,
+			      enum mlx5_dev_event event, unsigned long param)
 {
+	struct mlx5e_priv *priv = vpriv;
+
+	if (!test_bit(MLX5E_STATE_ASYNC_EVENTS_ENABLE, &priv->state))
+		return;
+
 	switch (event) {
 	case MLX5_DEV_EVENT_PORT_UP:
 	case MLX5_DEV_EVENT_PORT_DOWN:
@@ -289,17 +294,6 @@ static void __mlx5e_async_event(struct mlx5e_priv *priv,
 	}
 }
 
-static void mlx5e_async_event(struct mlx5_core_dev *mdev, void *vpriv,
-			      enum mlx5_dev_event event, unsigned long param)
-{
-	struct mlx5e_priv *priv = vpriv;
-
-	spin_lock(&priv->async_events_spinlock);
-	if (test_bit(MLX5E_STATE_ASYNC_EVENTS_ENABLE, &priv->state))
-		__mlx5e_async_event(priv, event);
-	spin_unlock(&priv->async_events_spinlock);
-}
-
 static void mlx5e_enable_async_events(struct mlx5e_priv *priv)
 {
 	set_bit(MLX5E_STATE_ASYNC_EVENTS_ENABLE, &priv->state);
@@ -307,9 +301,8 @@ static void mlx5e_enable_async_events(struct mlx5e_priv *priv)
 
 static void mlx5e_disable_async_events(struct mlx5e_priv *priv)
 {
-	spin_lock_irq(&priv->async_events_spinlock);
 	clear_bit(MLX5E_STATE_ASYNC_EVENTS_ENABLE, &priv->state);
-	spin_unlock_irq(&priv->async_events_spinlock);
+	synchronize_irq(mlx5_get_msix_vec(priv->mdev, MLX5_EQ_VEC_ASYNC));
 }
 
 #define MLX5E_HW2SW_MTU(hwmtu) (hwmtu - (ETH_HLEN + VLAN_HLEN + ETH_FCS_LEN))
@@ -2290,7 +2283,6 @@ static void mlx5e_build_netdev_priv(struct mlx5_core_dev *mdev,
 	mlx5e_ets_init(priv);
 #endif
 
-	spin_lock_init(&priv->async_events_spinlock);
 	mutex_init(&priv->state_lock);
 
 	INIT_WORK(&priv->update_carrier_work, mlx5e_update_carrier_work);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eq.c b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
index 647a3ca..18fccec 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
@@ -442,6 +442,11 @@ int mlx5_destroy_unmap_eq(struct mlx5_core_dev *dev, struct mlx5_eq *eq)
 }
 EXPORT_SYMBOL_GPL(mlx5_destroy_unmap_eq);
 
+u32 mlx5_get_msix_vec(struct mlx5_core_dev *dev, int vecidx)
+{
+	return dev->priv.msix_arr[MLX5_EQ_VEC_ASYNC].vector;
+}
+
 int mlx5_eq_init(struct mlx5_core_dev *dev)
 {
 	int err;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
index 0336847..0b0b226 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
@@ -99,6 +99,7 @@ int mlx5_core_enable_hca(struct mlx5_core_dev *dev, u16 func_id);
 int mlx5_core_disable_hca(struct mlx5_core_dev *dev, u16 func_id);
 int mlx5_wait_for_vf_pages(struct mlx5_core_dev *dev);
 cycle_t mlx5_read_internal_timer(struct mlx5_core_dev *dev);
+u32 mlx5_get_msix_vec(struct mlx5_core_dev *dev, int vecidx);
 
 void mlx5e_init(void);
 void mlx5e_cleanup(void);
-- 
1.7.1
