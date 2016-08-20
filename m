From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next 04/30] net/mlx5: MCG commands via mlx5 ifc
Date: Sat, 20 Aug 2016 23:11:47 +0300
Message-ID: <1471723933-5894-5-git-send-email-saeedm@mellanox.com>
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

Remove old representation of manually created MCG commands layout
and use mlx5_ifc canonical structures and defines.

Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c |  4 +-
 drivers/net/ethernet/mellanox/mlx5/core/mcg.c | 70 +++++++--------------------
 include/linux/mlx5/mlx5_ifc.h                 |  2 +-
 3 files changed, 21 insertions(+), 55 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
index d6e2a1c..0d55e0f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
@@ -280,7 +280,7 @@ static int mlx5_internal_err_ret_value(struct mlx5_core_dev *dev, u16 op,
 	case MLX5_CMD_OP_DEALLOC_Q_COUNTER:
 	case MLX5_CMD_OP_DEALLOC_PD:
 	case MLX5_CMD_OP_DEALLOC_UAR:
-	case MLX5_CMD_OP_DETTACH_FROM_MCG:
+	case MLX5_CMD_OP_DETACH_FROM_MCG:
 	case MLX5_CMD_OP_DEALLOC_XRCD:
 	case MLX5_CMD_OP_DEALLOC_TRANSPORT_DOMAIN:
 	case MLX5_CMD_OP_DELETE_VXLAN_UDP_DPORT:
@@ -490,7 +490,7 @@ const char *mlx5_command_str(int command)
 	MLX5_COMMAND_STR_CASE(CONFIG_INT_MODERATION);
 	MLX5_COMMAND_STR_CASE(ACCESS_REG);
 	MLX5_COMMAND_STR_CASE(ATTACH_TO_MCG);
-	MLX5_COMMAND_STR_CASE(DETTACH_FROM_MCG);
+	MLX5_COMMAND_STR_CASE(DETACH_FROM_MCG);
 	MLX5_COMMAND_STR_CASE(GET_DROPPED_PACKET_LOG);
 	MLX5_COMMAND_STR_CASE(MAD_IFC);
 	MLX5_COMMAND_STR_CASE(QUERY_MAD_DEMUX);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mcg.c b/drivers/net/ethernet/mellanox/mlx5/core/mcg.c
index d5a0c2d..01a1abd 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mcg.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mcg.c
@@ -37,70 +37,36 @@
 #include <rdma/ib_verbs.h>
 #include "mlx5_core.h"
 
-struct mlx5_attach_mcg_mbox_in {
-	struct mlx5_inbox_hdr	hdr;
-	__be32			qpn;
-	__be32			rsvd;
-	u8			gid[16];
-};
-
-struct mlx5_attach_mcg_mbox_out {
-	struct mlx5_outbox_hdr	hdr;
-	u8			rsvf[8];
-};
-
-struct mlx5_detach_mcg_mbox_in {
-	struct mlx5_inbox_hdr	hdr;
-	__be32			qpn;
-	__be32			rsvd;
-	u8			gid[16];
-};
-
-struct mlx5_detach_mcg_mbox_out {
-	struct mlx5_outbox_hdr	hdr;
-	u8			rsvf[8];
-};
-
 int mlx5_core_attach_mcg(struct mlx5_core_dev *dev, union ib_gid *mgid, u32 qpn)
 {
-	struct mlx5_attach_mcg_mbox_in in;
-	struct mlx5_attach_mcg_mbox_out out;
+	u32 out[MLX5_ST_SZ_DW(attach_to_mcg_out)] = {0};
+	u32 in[MLX5_ST_SZ_DW(attach_to_mcg_in)]   = {0};
+	void *gid;
 	int err;
 
-	memset(&in, 0, sizeof(in));
-	memset(&out, 0, sizeof(out));
-	in.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_ATTACH_TO_MCG);
-	memcpy(in.gid, mgid, sizeof(*mgid));
-	in.qpn = cpu_to_be32(qpn);
-	err = mlx5_cmd_exec(dev, &in, sizeof(in), &out, sizeof(out));
-	if (err)
-		return err;
-
-	if (out.hdr.status)
-		err = mlx5_cmd_status_to_err(&out.hdr);
+	MLX5_SET(attach_to_mcg_in, in, opcode, MLX5_CMD_OP_ATTACH_TO_MCG);
+	MLX5_SET(attach_to_mcg_in, in, qpn, qpn);
+	gid = MLX5_ADDR_OF(attach_to_mcg_in, in, multicast_gid);
+	memcpy(gid, mgid, sizeof(*mgid));
 
-	return err;
+	err = mlx5_cmd_exec(dev, in, sizeof(in), out, sizeof(out));
+	return err ? : mlx5_cmd_status_to_err_v2(out);
 }
 EXPORT_SYMBOL(mlx5_core_attach_mcg);
 
 int mlx5_core_detach_mcg(struct mlx5_core_dev *dev, union ib_gid *mgid, u32 qpn)
 {
-	struct mlx5_detach_mcg_mbox_in in;
-	struct mlx5_detach_mcg_mbox_out out;
+	u32 out[MLX5_ST_SZ_DW(detach_from_mcg_out)] = {0};
+	u32 in[MLX5_ST_SZ_DW(detach_from_mcg_in)]   = {0};
+	void *gid;
 	int err;
 
-	memset(&in, 0, sizeof(in));
-	memset(&out, 0, sizeof(out));
-	in.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_DETTACH_FROM_MCG);
-	memcpy(in.gid, mgid, sizeof(*mgid));
-	in.qpn = cpu_to_be32(qpn);
-	err = mlx5_cmd_exec(dev, &in, sizeof(in), &out, sizeof(out));
-	if (err)
-		return err;
-
-	if (out.hdr.status)
-		err = mlx5_cmd_status_to_err(&out.hdr);
+	MLX5_SET(detach_from_mcg_in, in, opcode, MLX5_CMD_OP_DETACH_FROM_MCG);
+	MLX5_SET(detach_from_mcg_in, in, qpn, qpn);
+	gid = MLX5_ADDR_OF(detach_from_mcg_in, in, multicast_gid);
+	memcpy(gid, mgid, sizeof(*mgid));
 
-	return err;
+	err = mlx5_cmd_exec(dev, in, sizeof(in), out, sizeof(out));
+	return err ? : mlx5_cmd_status_to_err_v2(out);
 }
 EXPORT_SYMBOL(mlx5_core_detach_mcg);
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index 21bc455..3f70fc9 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -152,7 +152,7 @@ enum {
 	MLX5_CMD_OP_CONFIG_INT_MODERATION         = 0x804,
 	MLX5_CMD_OP_ACCESS_REG                    = 0x805,
 	MLX5_CMD_OP_ATTACH_TO_MCG                 = 0x806,
-	MLX5_CMD_OP_DETTACH_FROM_MCG              = 0x807,
+	MLX5_CMD_OP_DETACH_FROM_MCG               = 0x807,
 	MLX5_CMD_OP_GET_DROPPED_PACKET_LOG        = 0x80a,
 	MLX5_CMD_OP_MAD_IFC                       = 0x50d,
 	MLX5_CMD_OP_QUERY_MAD_DEMUX               = 0x80b,
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
