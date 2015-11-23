From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 01/18] net/mlx5_core: Modify enable/disable hca functions
Date: Mon, 23 Nov 2015 13:11:34 +0200
Message-ID: <1448277111-16474-2-git-send-email-ogerlitz@mellanox.com>
References: <1448277111-16474-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Don Dutile <ddutile@redhat.com>,
	Doug Ledford <dledford@redhat.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>, Eli Cohen <eli@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:37120 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751173AbbKWLMZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2015 06:12:25 -0500
In-Reply-To: <1448277111-16474-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cohen <eli@mellanox.com>

Modify these functions to have func_id argument to state which device we
are referring to. This is done as a preparation for SRIOV support where
a PF driver needs to control its virtual functions.

Signed-off-by: Eli Cohen <eli@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c     | 45 ++++++++++------------
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |  2 +
 2 files changed, 23 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 4ac8d4cc..f2e64dc 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -462,42 +462,39 @@ static int set_hca_ctrl(struct mlx5_core_dev *dev)
 	return err;
 }
 
-static int mlx5_core_enable_hca(struct mlx5_core_dev *dev)
+int mlx5_core_enable_hca(struct mlx5_core_dev *dev, u16 func_id)
 {
+	u32 out[MLX5_ST_SZ_DW(enable_hca_out)];
+	u32 in[MLX5_ST_SZ_DW(enable_hca_in)];
 	int err;
-	struct mlx5_enable_hca_mbox_in in;
-	struct mlx5_enable_hca_mbox_out out;
 
-	memset(&in, 0, sizeof(in));
-	memset(&out, 0, sizeof(out));
-	in.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_ENABLE_HCA);
+	memset(in, 0, sizeof(in));
+	MLX5_SET(enable_hca_in, in, opcode, MLX5_CMD_OP_ENABLE_HCA);
+	MLX5_SET(enable_hca_in, in, function_id, func_id);
+	memset(out, 0, sizeof(out));
+
 	err = mlx5_cmd_exec(dev, &in, sizeof(in), &out, sizeof(out));
 	if (err)
 		return err;
 
-	if (out.hdr.status)
-		return mlx5_cmd_status_to_err(&out.hdr);
-
-	return 0;
+	return mlx5_cmd_status_to_err_v2(out);
 }
 
-static int mlx5_core_disable_hca(struct mlx5_core_dev *dev)
+int mlx5_core_disable_hca(struct mlx5_core_dev *dev, u16 func_id)
 {
+	u32 out[MLX5_ST_SZ_DW(disable_hca_out)];
+	u32 in[MLX5_ST_SZ_DW(disable_hca_in)];
 	int err;
-	struct mlx5_disable_hca_mbox_in in;
-	struct mlx5_disable_hca_mbox_out out;
 
-	memset(&in, 0, sizeof(in));
-	memset(&out, 0, sizeof(out));
-	in.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_DISABLE_HCA);
-	err = mlx5_cmd_exec(dev, &in, sizeof(in), &out, sizeof(out));
+	memset(in, 0, sizeof(in));
+	MLX5_SET(disable_hca_in, in, opcode, MLX5_CMD_OP_DISABLE_HCA);
+	MLX5_SET(disable_hca_in, in, function_id, func_id);
+	memset(out, 0, sizeof(out));
+	err = mlx5_cmd_exec(dev, in, sizeof(in), out, sizeof(out));
 	if (err)
 		return err;
 
-	if (out.hdr.status)
-		return mlx5_cmd_status_to_err(&out.hdr);
-
-	return 0;
+	return mlx5_cmd_status_to_err_v2(out);
 }
 
 static int mlx5_irq_set_affinity_hint(struct mlx5_core_dev *mdev, int i)
@@ -942,7 +939,7 @@ static int mlx5_load_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
 
 	mlx5_pagealloc_init(dev);
 
-	err = mlx5_core_enable_hca(dev);
+	err = mlx5_core_enable_hca(dev, 0);
 	if (err) {
 		dev_err(&pdev->dev, "enable hca failed\n");
 		goto err_pagealloc_cleanup;
@@ -1106,7 +1103,7 @@ reclaim_boot_pages:
 	mlx5_reclaim_startup_pages(dev);
 
 err_disable_hca:
-	mlx5_core_disable_hca(dev);
+	mlx5_core_disable_hca(dev, 0);
 
 err_pagealloc_cleanup:
 	mlx5_pagealloc_cleanup(dev);
@@ -1149,7 +1146,7 @@ static int mlx5_unload_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
 	}
 	mlx5_pagealloc_stop(dev);
 	mlx5_reclaim_startup_pages(dev);
-	mlx5_core_disable_hca(dev);
+	mlx5_core_disable_hca(dev, 0);
 	mlx5_pagealloc_cleanup(dev);
 	mlx5_cmd_cleanup(dev);
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
index cee5b7a..1ed2239 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
@@ -90,6 +90,8 @@ void mlx5_core_event(struct mlx5_core_dev *dev, enum mlx5_dev_event event,
 		     unsigned long param);
 void mlx5_enter_error_state(struct mlx5_core_dev *dev);
 void mlx5_disable_device(struct mlx5_core_dev *dev);
+int mlx5_core_enable_hca(struct mlx5_core_dev *dev, u16 func_id);
+int mlx5_core_disable_hca(struct mlx5_core_dev *dev, u16 func_id);
 
 void mlx5e_init(void);
 void mlx5e_cleanup(void);
-- 
2.3.7
