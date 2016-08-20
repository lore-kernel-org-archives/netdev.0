From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next 03/30] net/mlx5: PD and UAR commands via mlx5 ifc
Date: Sat, 20 Aug 2016 23:11:46 +0300
Message-ID: <1471723933-5894-4-git-send-email-saeedm@mellanox.com>
References: <1471723933-5894-1-git-send-email-saeedm@mellanox.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Tal Alon <talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1471723933-5894-1-git-send-email-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Remove old representation of manually created PD/UAR commands layouts
and use mlx5_ifc canonical structures and defines.

Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/pd.c  | 58 +++++------------------
 drivers/net/ethernet/mellanox/mlx5/core/uar.c | 66 ++++++---------------------
 2 files changed, 25 insertions(+), 99 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/pd.c b/drivers/net/ethernet/mellanox/mlx5/core/pd.c
index f2d3aee..efe452c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/pd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/pd.c
@@ -36,66 +36,32 @@
 #include <linux/mlx5/cmd.h>
 #include "mlx5_core.h"
 
-struct mlx5_alloc_pd_mbox_in {
-	struct mlx5_inbox_hdr	hdr;
-	u8			rsvd[8];
-};
-
-struct mlx5_alloc_pd_mbox_out {
-	struct mlx5_outbox_hdr	hdr;
-	__be32			pdn;
-	u8			rsvd[4];
-};
-
-struct mlx5_dealloc_pd_mbox_in {
-	struct mlx5_inbox_hdr	hdr;
-	__be32			pdn;
-	u8			rsvd[4];
-};
-
-struct mlx5_dealloc_pd_mbox_out {
-	struct mlx5_outbox_hdr	hdr;
-	u8			rsvd[8];
-};
-
 int mlx5_core_alloc_pd(struct mlx5_core_dev *dev, u32 *pdn)
 {
-	struct mlx5_alloc_pd_mbox_in	in;
-	struct mlx5_alloc_pd_mbox_out	out;
+	u32 out[MLX5_ST_SZ_DW(alloc_pd_out)] = {0};
+	u32 in[MLX5_ST_SZ_DW(alloc_pd_in)]   = {0};
 	int err;
 
-	memset(&in, 0, sizeof(in));
-	memset(&out, 0, sizeof(out));
-	in.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_ALLOC_PD);
-	err = mlx5_cmd_exec(dev, &in, sizeof(in), &out, sizeof(out));
+	MLX5_SET(alloc_pd_in, in, opcode, MLX5_CMD_OP_ALLOC_PD);
+	err = mlx5_cmd_exec(dev, in, sizeof(in), out, sizeof(out));
+	err = err ? : mlx5_cmd_status_to_err_v2(out);
 	if (err)
 		return err;
 
-	if (out.hdr.status)
-		return mlx5_cmd_status_to_err(&out.hdr);
-
-	*pdn = be32_to_cpu(out.pdn) & 0xffffff;
+	*pdn = MLX5_GET(alloc_pd_out, out, pd);
 	return err;
 }
 EXPORT_SYMBOL(mlx5_core_alloc_pd);
 
 int mlx5_core_dealloc_pd(struct mlx5_core_dev *dev, u32 pdn)
 {
-	struct mlx5_dealloc_pd_mbox_in	in;
-	struct mlx5_dealloc_pd_mbox_out	out;
+	u32 out[MLX5_ST_SZ_DW(dealloc_pd_out)] = {0};
+	u32 in[MLX5_ST_SZ_DW(dealloc_pd_in)]   = {0};
 	int err;
 
-	memset(&in, 0, sizeof(in));
-	memset(&out, 0, sizeof(out));
-	in.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_DEALLOC_PD);
-	in.pdn = cpu_to_be32(pdn);
-	err = mlx5_cmd_exec(dev, &in, sizeof(in), &out, sizeof(out));
-	if (err)
-		return err;
-
-	if (out.hdr.status)
-		return mlx5_cmd_status_to_err(&out.hdr);
-
-	return err;
+	MLX5_SET(dealloc_pd_in, in, opcode, MLX5_CMD_OP_DEALLOC_PD);
+	MLX5_SET(dealloc_pd_in, in, pd, pdn);
+	err = mlx5_cmd_exec(dev, in, sizeof(in), out, sizeof(out));
+	return err ? : mlx5_cmd_status_to_err_v2(out);
 }
 EXPORT_SYMBOL(mlx5_core_dealloc_pd);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/uar.c b/drivers/net/ethernet/mellanox/mlx5/core/uar.c
index 5ff8af4..d0a0e0b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/uar.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/uar.c
@@ -42,73 +42,33 @@ enum {
 	NUM_LOW_LAT_UUARS	= 4,
 };
 
-
-struct mlx5_alloc_uar_mbox_in {
-	struct mlx5_inbox_hdr	hdr;
-	u8			rsvd[8];
-};
-
-struct mlx5_alloc_uar_mbox_out {
-	struct mlx5_outbox_hdr	hdr;
-	__be32			uarn;
-	u8			rsvd[4];
-};
-
-struct mlx5_free_uar_mbox_in {
-	struct mlx5_inbox_hdr	hdr;
-	__be32			uarn;
-	u8			rsvd[4];
-};
-
-struct mlx5_free_uar_mbox_out {
-	struct mlx5_outbox_hdr	hdr;
-	u8			rsvd[8];
-};
-
 int mlx5_cmd_alloc_uar(struct mlx5_core_dev *dev, u32 *uarn)
 {
-	struct mlx5_alloc_uar_mbox_in	in;
-	struct mlx5_alloc_uar_mbox_out	out;
+	u32 out[MLX5_ST_SZ_DW(alloc_uar_out)] = {0};
+	u32 in[MLX5_ST_SZ_DW(alloc_uar_in)]   = {0};
 	int err;
 
-	memset(&in, 0, sizeof(in));
-	memset(&out, 0, sizeof(out));
-	in.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_ALLOC_UAR);
-	err = mlx5_cmd_exec(dev, &in, sizeof(in), &out, sizeof(out));
+	MLX5_SET(alloc_uar_in, in, opcode, MLX5_CMD_OP_ALLOC_UAR);
+	err = mlx5_cmd_exec(dev, in, sizeof(in), out, sizeof(out));
+	err = err ? : mlx5_cmd_status_to_err_v2(out);
 	if (err)
-		goto ex;
-
-	if (out.hdr.status) {
-		err = mlx5_cmd_status_to_err(&out.hdr);
-		goto ex;
-	}
-
-	*uarn = be32_to_cpu(out.uarn) & 0xffffff;
+		return err;
 
-ex:
+	*uarn = MLX5_GET(alloc_uar_out, out, uar);
 	return err;
 }
 EXPORT_SYMBOL(mlx5_cmd_alloc_uar);
 
 int mlx5_cmd_free_uar(struct mlx5_core_dev *dev, u32 uarn)
 {
-	struct mlx5_free_uar_mbox_in	in;
-	struct mlx5_free_uar_mbox_out	out;
+	u32 out[MLX5_ST_SZ_DW(dealloc_uar_out)] = {0};
+	u32 in[MLX5_ST_SZ_DW(dealloc_uar_in)]   = {0};
 	int err;
 
-	memset(&in, 0, sizeof(in));
-	memset(&out, 0, sizeof(out));
-	in.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_DEALLOC_UAR);
-	in.uarn = cpu_to_be32(uarn);
-	err = mlx5_cmd_exec(dev, &in, sizeof(in), &out, sizeof(out));
-	if (err)
-		goto ex;
-
-	if (out.hdr.status)
-		err = mlx5_cmd_status_to_err(&out.hdr);
-
-ex:
-	return err;
+	MLX5_SET(dealloc_uar_in, in, opcode, MLX5_CMD_OP_DEALLOC_UAR);
+	MLX5_SET(dealloc_uar_in, in, uar, uarn);
+	err = mlx5_cmd_exec(dev, in, sizeof(in), out, sizeof(out));
+	return err ? : mlx5_cmd_status_to_err_v2(out);
 }
 EXPORT_SYMBOL(mlx5_cmd_free_uar);
 
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
