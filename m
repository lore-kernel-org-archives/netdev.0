From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V1 02/12] net/mlx5: Introduce physical port PFC access functions
Date: Thu, 18 Feb 2016 12:32:43 +0200
Message-ID: <1455791573-5270-3-git-send-email-saeedm@mellanox.com>
References: <1455791573-5270-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Rana Shahout <ranas@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Matthew Finlay <matt@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:34110 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1425322AbcBRKll (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 05:41:41 -0500
In-Reply-To: <1455791573-5270-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Achiad Shochat <achiad@mellanox.com>

Add access functions to set and query a physical port PFC
(Priority Flow Control) parameters.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/port.c |   41 ++++++++++++++++++++++++
 include/linux/mlx5/port.h                      |    4 ++
 2 files changed, 45 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/port.c b/drivers/net/ethernet/mellanox/mlx5/core/port.c
index 1e86321..dae7050 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/port.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/port.c
@@ -364,3 +364,44 @@ int mlx5_query_port_pause(struct mlx5_core_dev *dev,
 	return 0;
 }
 EXPORT_SYMBOL_GPL(mlx5_query_port_pause);
+
+int mlx5_set_port_pfc(struct mlx5_core_dev *dev, u8 pfc_en_tx, u8 pfc_en_rx)
+{
+	u32 in[MLX5_ST_SZ_DW(pfcc_reg)];
+	u32 out[MLX5_ST_SZ_DW(pfcc_reg)];
+
+	memset(in, 0, sizeof(in));
+	MLX5_SET(pfcc_reg, in, local_port, 1);
+	MLX5_SET(pfcc_reg, in, pfctx, pfc_en_tx);
+	MLX5_SET(pfcc_reg, in, pfcrx, pfc_en_rx);
+	MLX5_SET_TO_ONES(pfcc_reg, in, prio_mask_tx);
+	MLX5_SET_TO_ONES(pfcc_reg, in, prio_mask_rx);
+
+	return mlx5_core_access_reg(dev, in, sizeof(in), out,
+				    sizeof(out), MLX5_REG_PFCC, 0, 1);
+}
+EXPORT_SYMBOL_GPL(mlx5_set_port_pfc);
+
+int mlx5_query_port_pfc(struct mlx5_core_dev *dev, u8 *pfc_en_tx, u8 *pfc_en_rx)
+{
+	u32 in[MLX5_ST_SZ_DW(pfcc_reg)];
+	u32 out[MLX5_ST_SZ_DW(pfcc_reg)];
+	int err;
+
+	memset(in, 0, sizeof(in));
+	MLX5_SET(pfcc_reg, in, local_port, 1);
+
+	err = mlx5_core_access_reg(dev, in, sizeof(in), out,
+				   sizeof(out), MLX5_REG_PFCC, 0, 0);
+	if (err)
+		return err;
+
+	if (pfc_en_tx)
+		*pfc_en_tx = MLX5_GET(pfcc_reg, out, pfctx);
+
+	if (pfc_en_rx)
+		*pfc_en_rx = MLX5_GET(pfcc_reg, out, pfcrx);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(mlx5_query_port_pfc);
diff --git a/include/linux/mlx5/port.h b/include/linux/mlx5/port.h
index 7accd4a..4b3644c 100644
--- a/include/linux/mlx5/port.h
+++ b/include/linux/mlx5/port.h
@@ -66,4 +66,8 @@ int mlx5_set_port_pause(struct mlx5_core_dev *dev, u32 rx_pause, u32 tx_pause);
 int mlx5_query_port_pause(struct mlx5_core_dev *dev,
 			  u32 *rx_pause, u32 *tx_pause);
 
+int mlx5_set_port_pfc(struct mlx5_core_dev *dev, u8 pfc_en_tx, u8 pfc_en_rx);
+int mlx5_query_port_pfc(struct mlx5_core_dev *dev, u8 *pfc_en_tx,
+			u8 *pfc_en_rx);
+
 #endif /* __MLX5_PORT_H__ */
-- 
1.7.1
