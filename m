From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V4 03/12] net/mlx5_core: Add EQ renaming mechanism
Date: Sun, 17 May 2015 16:02:14 +0300
Message-ID: <1431867743-13149-4-git-send-email-amirv@mellanox.com>
References: <1431867743-13149-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:40595 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752841AbbEQNDP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 May 2015 09:03:15 -0400
In-Reply-To: <1431867743-13149-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

Introduce mlx5_rename_eq() to rename an EQ. This will be used by a
following commit for the Ethernet functionality of the driver.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c     | 25 ++++++++++++++++++++--
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |  2 ++
 2 files changed, 25 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 55085b0..7fdbdb4 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -591,11 +591,11 @@ static void mlx5_irq_clear_affinity_hints(struct mlx5_core_dev *mdev)
 int mlx5_vector2eqn(struct mlx5_core_dev *dev, int vector, int *eqn, int *irqn)
 {
 	struct mlx5_eq_table *table = &dev->priv.eq_table;
-	struct mlx5_eq *eq, *n;
+	struct mlx5_eq *eq;
 	int err = -ENOENT;
 
 	spin_lock(&table->lock);
-	list_for_each_entry_safe(eq, n, &table->comp_eqs_list, list) {
+	list_for_each_entry(eq, &table->comp_eqs_list, list) {
 		if (eq->index == vector) {
 			*eqn = eq->eqn;
 			*irqn = eq->irqn;
@@ -609,6 +609,27 @@ int mlx5_vector2eqn(struct mlx5_core_dev *dev, int vector, int *eqn, int *irqn)
 }
 EXPORT_SYMBOL(mlx5_vector2eqn);
 
+int mlx5_rename_eq(struct mlx5_core_dev *dev, int eq_ix, char *name)
+{
+	struct mlx5_priv *priv = &dev->priv;
+	struct mlx5_eq_table *table = &priv->eq_table;
+	struct mlx5_eq *eq;
+	int err = -ENOENT;
+
+	spin_lock(&table->lock);
+	list_for_each_entry(eq, &table->comp_eqs_list, list) {
+		if (eq->index == eq_ix) {
+			snprintf(priv->irq_info[eq_ix].name, MLX5_MAX_IRQ_NAME,
+				 "%s-%d", name, eq_ix);
+			err = 0;
+			break;
+		}
+	}
+	spin_unlock(&table->lock);
+
+	return err;
+}
+
 static void free_comp_eqs(struct mlx5_core_dev *dev)
 {
 	struct mlx5_eq_table *table = &dev->priv.eq_table;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
index a051b90..230855a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
@@ -72,4 +72,6 @@ int mlx5_cmd_query_adapter(struct mlx5_core_dev *dev);
 int mlx5_cmd_init_hca(struct mlx5_core_dev *dev);
 int mlx5_cmd_teardown_hca(struct mlx5_core_dev *dev);
 
+int mlx5_rename_eq(struct mlx5_core_dev *dev, int eq_ix, char *name);
+
 #endif /* __MLX5_CORE_H__ */
-- 
1.9.3
