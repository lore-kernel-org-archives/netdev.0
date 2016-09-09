From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 06/11] net/mlx5: Implement eswitch attach/detach flows
Date: Fri,  9 Sep 2016 17:35:22 +0300
Message-ID: <1473431727-20150-7-git-send-email-saeedm@mellanox.com>
References: <1473431727-20150-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>,
        Moahamd Haj Yahia <mohamad@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:35501 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752820AbcIIOhA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 10:37:00 -0400
In-Reply-To: <1473431727-20150-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mohamad Haj Yahia <mohamad@mellanox.com>

Needed for lightweight and modular internal/pci error handling.
Implement eswitch attach function which allocates/starts hw related
resources.
Implement eswitch detach function which releases/stops hw related
resources.
Init/cleanup function only handle eswitch software context allocation
and destruction.

Signed-off-by: Mohamad Haj Yahia <mohamad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c | 24 ++++++++++++++++++++---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h |  2 ++
 2 files changed, 23 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index 1014305..24058894 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -1559,6 +1559,25 @@ void mlx5_eswitch_disable_sriov(struct mlx5_eswitch *esw)
 	esw_enable_vport(esw, 0, UC_ADDR_CHANGE);
 }
 
+void mlx5_eswitch_attach(struct mlx5_eswitch *esw)
+{
+	if (!esw || !MLX5_CAP_GEN(esw->dev, vport_group_manager) ||
+	    MLX5_CAP_GEN(esw->dev, port_type) != MLX5_CAP_PORT_TYPE_ETH)
+		return;
+
+	esw_enable_vport(esw, 0, UC_ADDR_CHANGE);
+	/* VF Vports will be enabled when SRIOV is enabled */
+}
+
+void mlx5_eswitch_detach(struct mlx5_eswitch *esw)
+{
+	if (!esw || !MLX5_CAP_GEN(esw->dev, vport_group_manager) ||
+	    MLX5_CAP_GEN(esw->dev, port_type) != MLX5_CAP_PORT_TYPE_ETH)
+		return;
+
+	esw_disable_vport(esw, 0);
+}
+
 int mlx5_eswitch_init(struct mlx5_core_dev *dev)
 {
 	int l2_table_size = 1 << MLX5_CAP_GEN(dev, log_max_l2_table);
@@ -1635,9 +1654,8 @@ int mlx5_eswitch_init(struct mlx5_core_dev *dev)
 	esw->enabled_vports = 0;
 	esw->mode = SRIOV_NONE;
 
+	mlx5_eswitch_attach(esw);
 	dev->priv.eswitch = esw;
-	esw_enable_vport(esw, 0, UC_ADDR_CHANGE);
-	/* VF Vports will be enabled when SRIOV is enabled */
 	return 0;
 abort:
 	if (esw->work_queue)
@@ -1656,8 +1674,8 @@ void mlx5_eswitch_cleanup(struct mlx5_eswitch *esw)
 		return;
 
 	esw_info(esw->dev, "cleanup\n");
-	esw_disable_vport(esw, 0);
 
+	mlx5_eswitch_detach(esw);
 	esw->dev->priv.eswitch = NULL;
 	destroy_workqueue(esw->work_queue);
 	kfree(esw->l2_table.bitmap);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index a961409..48c273d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -204,6 +204,8 @@ struct mlx5_eswitch {
 /* E-Switch API */
 int mlx5_eswitch_init(struct mlx5_core_dev *dev);
 void mlx5_eswitch_cleanup(struct mlx5_eswitch *esw);
+void mlx5_eswitch_attach(struct mlx5_eswitch *esw);
+void mlx5_eswitch_detach(struct mlx5_eswitch *esw);
 void mlx5_eswitch_vport_event(struct mlx5_eswitch *esw, struct mlx5_eqe *eqe);
 int mlx5_eswitch_enable_sriov(struct mlx5_eswitch *esw, int nvfs, int mode);
 void mlx5_eswitch_disable_sriov(struct mlx5_eswitch *esw);
-- 
2.7.4
