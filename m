From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V2 01/11] net/mlx5: Introduce device queue counters
Date: Mon, 18 Apr 2016 00:31:55 +0300
Message-ID: <1460928725-18741-2-git-send-email-saeedm@mellanox.com>
References: <1460928725-18741-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Rana Shahout <ranas@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:36995 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751981AbcDQVcl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Apr 2016 17:32:41 -0400
In-Reply-To: <1460928725-18741-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

A queue counter can collect several statistics for one or more
hardware queues (QPs, RQs, etc ..) that the counter is attached to.

For Ethernet it will provide an "out of buffer" counter which collects
the number of all packets that are dropped due to lack of software
buffers.

Here we add device commands to alloc/query/dealloc queue counters.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Rana Shahout <ranas@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/qp.c |   68 ++++++++++++++++++++++++++
 include/linux/mlx5/qp.h                      |    6 ++
 2 files changed, 74 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/qp.c b/drivers/net/ethernet/mellanox/mlx5/core/qp.c
index def2893..b720a27 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/qp.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/qp.c
@@ -538,3 +538,71 @@ void mlx5_core_destroy_sq_tracked(struct mlx5_core_dev *dev,
 	mlx5_core_destroy_sq(dev, sq->qpn);
 }
 EXPORT_SYMBOL(mlx5_core_destroy_sq_tracked);
+
+int mlx5_core_alloc_q_counter(struct mlx5_core_dev *dev, u16 *counter_id)
+{
+	u32 in[MLX5_ST_SZ_DW(alloc_q_counter_in)];
+	u32 out[MLX5_ST_SZ_DW(alloc_q_counter_out)];
+	int err;
+
+	memset(in, 0, sizeof(in));
+	memset(out, 0, sizeof(out));
+
+	MLX5_SET(alloc_q_counter_in, in, opcode, MLX5_CMD_OP_ALLOC_Q_COUNTER);
+	err = mlx5_cmd_exec_check_status(dev, in, sizeof(in), out, sizeof(out));
+	if (!err)
+		*counter_id = MLX5_GET(alloc_q_counter_out, out,
+				       counter_set_id);
+	return err;
+}
+EXPORT_SYMBOL_GPL(mlx5_core_alloc_q_counter);
+
+int mlx5_core_dealloc_q_counter(struct mlx5_core_dev *dev, u16 counter_id)
+{
+	u32 in[MLX5_ST_SZ_DW(dealloc_q_counter_in)];
+	u32 out[MLX5_ST_SZ_DW(dealloc_q_counter_out)];
+
+	memset(in, 0, sizeof(in));
+	memset(out, 0, sizeof(out));
+
+	MLX5_SET(dealloc_q_counter_in, in, opcode,
+		 MLX5_CMD_OP_DEALLOC_Q_COUNTER);
+	MLX5_SET(dealloc_q_counter_in, in, counter_set_id, counter_id);
+	return mlx5_cmd_exec_check_status(dev, in, sizeof(in), out,
+					  sizeof(out));
+}
+EXPORT_SYMBOL_GPL(mlx5_core_dealloc_q_counter);
+
+int mlx5_core_query_q_counter(struct mlx5_core_dev *dev, u16 counter_id,
+			      int reset, void *out, int out_size)
+{
+	u32 in[MLX5_ST_SZ_DW(query_q_counter_in)];
+
+	memset(in, 0, sizeof(in));
+
+	MLX5_SET(query_q_counter_in, in, opcode, MLX5_CMD_OP_QUERY_Q_COUNTER);
+	MLX5_SET(query_q_counter_in, in, clear, reset);
+	MLX5_SET(query_q_counter_in, in, counter_set_id, counter_id);
+	return mlx5_cmd_exec_check_status(dev, in, sizeof(in), out, out_size);
+}
+EXPORT_SYMBOL_GPL(mlx5_core_query_q_counter);
+
+int mlx5_core_query_out_of_buffer(struct mlx5_core_dev *dev, u16 counter_id,
+				  u32 *out_of_buffer)
+{
+	int outlen = MLX5_ST_SZ_BYTES(query_q_counter_out);
+	void *out;
+	int err;
+
+	out = mlx5_vzalloc(outlen);
+	if (!out)
+		return -ENOMEM;
+
+	err = mlx5_core_query_q_counter(dev, counter_id, 0, out, outlen);
+	if (!err)
+		*out_of_buffer = MLX5_GET(query_q_counter_out, out,
+					  out_of_buffer);
+
+	kfree(out);
+	return err;
+}
diff --git a/include/linux/mlx5/qp.h b/include/linux/mlx5/qp.h
index cf031a3..6422102 100644
--- a/include/linux/mlx5/qp.h
+++ b/include/linux/mlx5/qp.h
@@ -668,6 +668,12 @@ int mlx5_core_create_sq_tracked(struct mlx5_core_dev *dev, u32 *in, int inlen,
 				struct mlx5_core_qp *sq);
 void mlx5_core_destroy_sq_tracked(struct mlx5_core_dev *dev,
 				  struct mlx5_core_qp *sq);
+int mlx5_core_alloc_q_counter(struct mlx5_core_dev *dev, u16 *counter_id);
+int mlx5_core_dealloc_q_counter(struct mlx5_core_dev *dev, u16 counter_id);
+int mlx5_core_query_q_counter(struct mlx5_core_dev *dev, u16 counter_id,
+			      int reset, void *out, int out_size);
+int mlx5_core_query_out_of_buffer(struct mlx5_core_dev *dev, u16 counter_id,
+				  u32 *out_of_buffer);
 
 static inline const char *mlx5_qp_type_str(int type)
 {
-- 
1.7.1
