From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 09/12] net/mlx5: Initializing CPU reverse mapping
Date: Fri, 29 Apr 2016 01:36:39 +0300
Message-ID: <1461883002-8912-10-git-send-email-saeedm@mellanox.com>
References: <1461883002-8912-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:33184 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752517AbcD1Wi0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Apr 2016 18:38:26 -0400
In-Reply-To: <1461883002-8912-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maor Gottlieb <maorg@mellanox.com>

Allocating CPU rmap and add entry for each IRQ.
CPU rmap is used in aRFS to get the RX queue number
of the RX completion interrupts.

Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |    3 +++
 drivers/net/ethernet/mellanox/mlx5/core/main.c    |   18 ++++++++++++++++++
 include/linux/mlx5/driver.h                       |    3 +++
 3 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 07c596d..a2b3297 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1689,6 +1689,9 @@ int mlx5e_open_locked(struct net_device *netdev)
 	mlx5e_redirect_rqts(priv);
 	mlx5e_update_carrier(priv);
 	mlx5e_timestamp_init(priv);
+#ifdef CONFIG_RFS_ACCEL
+	priv->netdev->rx_cpu_rmap = priv->mdev->rmap;
+#endif
 
 	schedule_delayed_work(&priv->update_stats_work, 0);
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 6892746..6feef7f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -48,6 +48,9 @@
 #include <linux/kmod.h>
 #include <linux/delay.h>
 #include <linux/mlx5/mlx5_ifc.h>
+#ifdef CONFIG_RFS_ACCEL
+#include <linux/cpu_rmap.h>
+#endif
 #include "mlx5_core.h"
 #include "fs_core.h"
 #ifdef CONFIG_MLX5_CORE_EN
@@ -665,6 +668,12 @@ static void free_comp_eqs(struct mlx5_core_dev *dev)
 	struct mlx5_eq_table *table = &dev->priv.eq_table;
 	struct mlx5_eq *eq, *n;
 
+#ifdef CONFIG_RFS_ACCEL
+	if (dev->rmap) {
+		free_irq_cpu_rmap(dev->rmap);
+		dev->rmap = NULL;
+	}
+#endif
 	spin_lock(&table->lock);
 	list_for_each_entry_safe(eq, n, &table->comp_eqs_list, list) {
 		list_del(&eq->list);
@@ -691,6 +700,11 @@ static int alloc_comp_eqs(struct mlx5_core_dev *dev)
 	INIT_LIST_HEAD(&table->comp_eqs_list);
 	ncomp_vec = table->num_comp_vectors;
 	nent = MLX5_COMP_EQ_SIZE;
+#ifdef CONFIG_RFS_ACCEL
+	dev->rmap = alloc_irq_cpu_rmap(ncomp_vec);
+	if (!dev->rmap)
+		return -ENOMEM;
+#endif
 	for (i = 0; i < ncomp_vec; i++) {
 		eq = kzalloc(sizeof(*eq), GFP_KERNEL);
 		if (!eq) {
@@ -698,6 +712,10 @@ static int alloc_comp_eqs(struct mlx5_core_dev *dev)
 			goto clean;
 		}
 
+#ifdef CONFIG_RFS_ACCEL
+		irq_cpu_rmap_add(dev->rmap,
+				 dev->priv.msix_arr[i + MLX5_EQ_VEC_COMP_BASE].vector);
+#endif
 		snprintf(name, MLX5_MAX_IRQ_NAME, "mlx5_comp%d", i);
 		err = mlx5_create_map_eq(dev, eq,
 					 i + MLX5_EQ_VEC_COMP_BASE, nent, 0,
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 96a428d..d552944 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -560,6 +560,9 @@ struct mlx5_core_dev {
 	struct mlx5_profile	*profile;
 	atomic_t		num_qps;
 	u32			issi;
+#ifdef CONFIG_RFS_ACCEL
+	struct cpu_rmap         *rmap;
+#endif
 };
 
 struct mlx5_db {
-- 
1.7.1
