From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 12/13] net/mlx4_en: Move spinlocks and work initalizations to beginning of init_netdev
Date: Mon, 27 Oct 2014 11:37:46 +0200
Message-ID: <1414402667-8841-13-git-send-email-amirv@mellanox.com>
References: <1414402667-8841-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:32864 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752271AbaJ0Jia (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2014 05:38:30 -0400
In-Reply-To: <1414402667-8841-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

Upon failures, destroy_netdev is called, and spinlocks/works must be
initialized before calling it. Otherwise kernel panic may occur.


Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 30 +++++++++++++-------------
 1 file changed, 15 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 3c07a75..ca6ffcf 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2440,6 +2440,21 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 
 	priv = netdev_priv(dev);
 	memset(priv, 0, sizeof(struct mlx4_en_priv));
+	spin_lock_init(&priv->stats_lock);
+	INIT_WORK(&priv->rx_mode_task, mlx4_en_do_set_rx_mode);
+	INIT_WORK(&priv->watchdog_task, mlx4_en_restart);
+	INIT_WORK(&priv->linkstate_task, mlx4_en_linkstate);
+	INIT_DELAYED_WORK(&priv->stats_task, mlx4_en_do_get_stats);
+	INIT_DELAYED_WORK(&priv->service_task, mlx4_en_service_task);
+#ifdef CONFIG_MLX4_EN_VXLAN
+	INIT_WORK(&priv->vxlan_add_task, mlx4_en_add_vxlan_offloads);
+	INIT_WORK(&priv->vxlan_del_task, mlx4_en_del_vxlan_offloads);
+#endif
+#ifdef CONFIG_RFS_ACCEL
+	INIT_LIST_HEAD(&priv->filters);
+	spin_lock_init(&priv->filters_lock);
+#endif
+
 	priv->dev = dev;
 	priv->mdev = mdev;
 	priv->ddev = &mdev->pdev->dev;
@@ -2471,16 +2486,6 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	priv->cqe_size = mdev->dev->caps.cqe_size;
 	priv->mac_index = -1;
 	priv->msg_enable = MLX4_EN_MSG_LEVEL;
-	spin_lock_init(&priv->stats_lock);
-	INIT_WORK(&priv->rx_mode_task, mlx4_en_do_set_rx_mode);
-	INIT_WORK(&priv->watchdog_task, mlx4_en_restart);
-	INIT_WORK(&priv->linkstate_task, mlx4_en_linkstate);
-	INIT_DELAYED_WORK(&priv->stats_task, mlx4_en_do_get_stats);
-	INIT_DELAYED_WORK(&priv->service_task, mlx4_en_service_task);
-#ifdef CONFIG_MLX4_EN_VXLAN
-	INIT_WORK(&priv->vxlan_add_task, mlx4_en_add_vxlan_offloads);
-	INIT_WORK(&priv->vxlan_del_task, mlx4_en_del_vxlan_offloads);
-#endif
 #ifdef CONFIG_MLX4_EN_DCB
 	if (!mlx4_is_slave(priv->mdev->dev)) {
 		if (mdev->dev->caps.flags & MLX4_DEV_CAP_FLAG_SET_ETH_SCHED) {
@@ -2523,11 +2528,6 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	if (err)
 		goto out;
 
-#ifdef CONFIG_RFS_ACCEL
-	INIT_LIST_HEAD(&priv->filters);
-	spin_lock_init(&priv->filters_lock);
-#endif
-
 	/* Initialize time stamping config */
 	priv->hwtstamp_config.flags = 0;
 	priv->hwtstamp_config.tx_type = HWTSTAMP_TX_OFF;
-- 
1.8.3.4
