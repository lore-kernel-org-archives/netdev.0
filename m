From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 01/30] net/mlx5: Init/Teardown hca commands via mlx5 ifc
Date: Sat, 20 Aug 2016 23:11:44 +0300
Message-ID: <1471723933-5894-2-git-send-email-saeedm@mellanox.com>
References: <1471723933-5894-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Leon Romanovsky <leonro@mellanox.com>,
        Tal Alon <talal@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Leon Romanovsky <leon@kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:34049 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751532AbcHTUMn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 20 Aug 2016 16:12:43 -0400
In-Reply-To: <1471723933-5894-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove old representation of manually created Init/Teardown hca
commands layout and use mlx5_ifc canonical structures and defines.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Leon Romanovsky <leon@kernel.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/fw.c | 36 ++++++++--------------------
 include/linux/mlx5/device.h                  | 24 -------------------
 2 files changed, 10 insertions(+), 50 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fw.c b/drivers/net/ethernet/mellanox/mlx5/core/fw.c
index 77fc1aa..56bf520 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fw.c
@@ -162,38 +162,22 @@ int mlx5_query_hca_caps(struct mlx5_core_dev *dev)
 
 int mlx5_cmd_init_hca(struct mlx5_core_dev *dev)
 {
-	struct mlx5_cmd_init_hca_mbox_in in;
-	struct mlx5_cmd_init_hca_mbox_out out;
+	u32 out[MLX5_ST_SZ_DW(init_hca_out)] = {0};
+	u32 in[MLX5_ST_SZ_DW(init_hca_in)]   = {0};
 	int err;
 
-	memset(&in, 0, sizeof(in));
-	memset(&out, 0, sizeof(out));
-	in.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_INIT_HCA);
-	err = mlx5_cmd_exec(dev, &in, sizeof(in), &out, sizeof(out));
-	if (err)
-		return err;
-
-	if (out.hdr.status)
-		err = mlx5_cmd_status_to_err(&out.hdr);
-
-	return err;
+	MLX5_SET(init_hca_in, in, opcode, MLX5_CMD_OP_INIT_HCA);
+	err = mlx5_cmd_exec(dev, in, sizeof(in), out, sizeof(out));
+	return err ? : mlx5_cmd_status_to_err_v2(out);
 }
 
 int mlx5_cmd_teardown_hca(struct mlx5_core_dev *dev)
 {
-	struct mlx5_cmd_teardown_hca_mbox_in in;
-	struct mlx5_cmd_teardown_hca_mbox_out out;
+	u32 out[MLX5_ST_SZ_DW(teardown_hca_out)] = {0};
+	u32 in[MLX5_ST_SZ_DW(teardown_hca_in)]   = {0};
 	int err;
 
-	memset(&in, 0, sizeof(in));
-	memset(&out, 0, sizeof(out));
-	in.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_TEARDOWN_HCA);
-	err = mlx5_cmd_exec(dev, &in, sizeof(in), &out, sizeof(out));
-	if (err)
-		return err;
-
-	if (out.hdr.status)
-		err = mlx5_cmd_status_to_err(&out.hdr);
-
-	return err;
+	MLX5_SET(teardown_hca_in, in, opcode, MLX5_CMD_OP_TEARDOWN_HCA);
+	err = mlx5_cmd_exec(dev, in, sizeof(in), out, sizeof(out));
+	return err ? : mlx5_cmd_status_to_err_v2(out);
 }
diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index 0b6d15c..6c343c0 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -455,30 +455,6 @@ struct mlx5_odp_caps {
 	char reserved2[0xe4];
 };
 
-struct mlx5_cmd_init_hca_mbox_in {
-	struct mlx5_inbox_hdr	hdr;
-	u8			rsvd0[2];
-	__be16			profile;
-	u8			rsvd1[4];
-};
-
-struct mlx5_cmd_init_hca_mbox_out {
-	struct mlx5_outbox_hdr	hdr;
-	u8			rsvd[8];
-};
-
-struct mlx5_cmd_teardown_hca_mbox_in {
-	struct mlx5_inbox_hdr	hdr;
-	u8			rsvd0[2];
-	__be16			profile;
-	u8			rsvd1[4];
-};
-
-struct mlx5_cmd_teardown_hca_mbox_out {
-	struct mlx5_outbox_hdr	hdr;
-	u8			rsvd[8];
-};
-
 struct mlx5_cmd_layout {
 	u8		type;
 	u8		rsvd0[3];
-- 
2.7.4
