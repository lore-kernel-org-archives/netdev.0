From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH for-next V3 15/15] net/mlx5: Introduce alloc_encap and dealloc_encap commands
Date: Tue, 23 Aug 2016 11:49:17 +0300
Message-ID: <1471942157-9131-16-git-send-email-saeedm@mellanox.com>
References: <1471942157-9131-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Leon Romanovsky <leonro@mellanox.com>,
        Tal Alon <talal@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Ilya Lesokhin <ilyal@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Leon Romanovsky <leon@kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:36796 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1757218AbcHWIvM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 04:51:12 -0400
In-Reply-To: <1471942157-9131-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ilya Lesokhin <ilyal@mellanox.com>

Implement low-level commands to support vxlan encapsulation.

Signed-off-by: Ilya Lesokhin <ilyal@mellanox.com>
Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Leon Romanovsky <leon@kernel.org>
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
