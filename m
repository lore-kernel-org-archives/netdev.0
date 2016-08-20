From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next 15/30] net/mlx5: Introduce alloc_encap and dealloc_encap commands
Date: Sat, 20 Aug 2016 23:11:58 +0300
Message-ID: <1471723933-5894-16-git-send-email-saeedm@mellanox.com>
References: <1471723933-5894-1-git-send-email-saeedm@mellanox.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Tal Alon <talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Ilya Lesokhin <ilyal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Hadar Hen Zion <hadarh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1471723933-5894-1-git-send-email-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ilya Lesokhin <ilyal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Implement low-level commands to support vxlan encapsulation.

Signed-off-by: Ilya Lesokhin <ilyal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Hadar Hen Zion <hadarh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c    |  4 ++
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c | 48 ++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h |  7 ++++
 3 files changed, 59 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
index 23b95da..00bec60 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
@@ -301,6 +301,7 @@ static int mlx5_internal_err_ret_value(struct mlx5_core_dev *dev, u16 op,
 	case MLX5_CMD_OP_MODIFY_FLOW_TABLE:
 	case MLX5_CMD_OP_SET_FLOW_TABLE_ENTRY:
 	case MLX5_CMD_OP_SET_FLOW_TABLE_ROOT:
+	case MLX5_CMD_OP_DEALLOC_ENCAP_HEADER:
 		return MLX5_CMD_STAT_OK;
 
 	case MLX5_CMD_OP_QUERY_HCA_CAP:
@@ -402,6 +403,7 @@ static int mlx5_internal_err_ret_value(struct mlx5_core_dev *dev, u16 op,
 	case MLX5_CMD_OP_QUERY_FLOW_TABLE_ENTRY:
 	case MLX5_CMD_OP_ALLOC_FLOW_COUNTER:
 	case MLX5_CMD_OP_QUERY_FLOW_COUNTER:
+	case MLX5_CMD_OP_ALLOC_ENCAP_HEADER:
 		*status = MLX5_DRIVER_STATUS_ABORTED;
 		*synd = MLX5_DRIVER_SYND;
 		return -EIO;
@@ -550,6 +552,8 @@ const char *mlx5_command_str(int command)
 	MLX5_COMMAND_STR_CASE(DEALLOC_FLOW_COUNTER);
 	MLX5_COMMAND_STR_CASE(QUERY_FLOW_COUNTER);
 	MLX5_COMMAND_STR_CASE(MODIFY_FLOW_TABLE);
+	MLX5_COMMAND_STR_CASE(ALLOC_ENCAP_HEADER);
+	MLX5_COMMAND_STR_CASE(DEALLOC_ENCAP_HEADER);
 	default: return "unknown command opcode";
 	}
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
index e64499e..7aaefa9 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
@@ -424,3 +424,51 @@ void mlx5_cmd_fc_bulk_get(struct mlx5_core_dev *dev,
 	*packets = MLX5_GET64(traffic_counter, stats, packets);
 	*bytes = MLX5_GET64(traffic_counter, stats, octets);
 }
+
+#define MAX_ENCAP_SIZE (128)
+
+int mlx5_cmd_alloc_encap(struct mlx5_core_dev *dev,
+			 int header_type,
+			 size_t size,
+			 void *encap_header,
+			 u32 *encap_id)
+{
+	u32 out[MLX5_ST_SZ_DW(alloc_encap_header_out)];
+	u32 in[MLX5_ST_SZ_DW(alloc_encap_header_in) +
+	      (MAX_ENCAP_SIZE / sizeof(u32))];
+	void *encap_header_in = MLX5_ADDR_OF(alloc_encap_header_in, in,
+					     encap_header);
+	void *header = MLX5_ADDR_OF(encap_header_in, encap_header_in,
+				    encap_header);
+	int inlen = header - (void *)in  + size;
+	int err;
+
+	if (size > MAX_ENCAP_SIZE)
+		return -EINVAL;
+
+	memset(in, 0, inlen);
+	MLX5_SET(alloc_encap_header_in, in, opcode,
+		 MLX5_CMD_OP_ALLOC_ENCAP_HEADER);
+	MLX5_SET(encap_header_in, encap_header_in, encap_header_size, size);
+	MLX5_SET(encap_header_in, encap_header_in, header_type, header_type);
+	memcpy(header, encap_header, size);
+
+	memset(out, 0, sizeof(out));
+	err = mlx5_cmd_exec(dev, in, inlen, out, sizeof(out));
+
+	*encap_id = MLX5_GET(alloc_encap_header_out, out, encap_id);
+	return err;
+}
+
+void mlx5_cmd_dealloc_encap(struct mlx5_core_dev *dev, u32 encap_id)
+{
+	u32 in[MLX5_ST_SZ_DW(dealloc_encap_header_in)];
+	u32 out[MLX5_ST_SZ_DW(dealloc_encap_header_out)];
+
+	memset(in, 0, sizeof(in));
+	MLX5_SET(dealloc_encap_header_in, in, opcode,
+		 MLX5_CMD_OP_DEALLOC_ENCAP_HEADER);
+	MLX5_SET(dealloc_encap_header_in, in, encap_id, encap_id);
+
+	mlx5_cmd_exec(dev, in, sizeof(in), out, sizeof(out));
+}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h
index 158844c..ac52fdf 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h
@@ -88,4 +88,11 @@ void mlx5_cmd_fc_bulk_get(struct mlx5_core_dev *dev,
 			  struct mlx5_cmd_fc_bulk *b, u16 id,
 			  u64 *packets, u64 *bytes);
 
+int mlx5_cmd_alloc_encap(struct mlx5_core_dev *dev,
+			 int header_type,
+			 size_t size,
+			 void *encap_header,
+			 u32 *encap_id);
+void mlx5_cmd_dealloc_encap(struct mlx5_core_dev *dev, u32 encap_id);
+
 #endif
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
