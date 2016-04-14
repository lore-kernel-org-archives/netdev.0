From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 18/18] mlxsw: spectrum_buffers: Implement occupancy monitoring
Date: Thu, 14 Apr 2016 18:19:30 +0200
Message-ID: <1460650770-19382-19-git-send-email-jiri@resnulli.us>
References: <1460650770-19382-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	jhs@mojatatu.com, john.fastabend@gmail.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com, stephen@networkplumber.org,
	sfeldma@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:34853 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932924AbcDNQT6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 12:19:58 -0400
Received: by mail-wm0-f50.google.com with SMTP id a140so154847522wma.0
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2016 09:19:57 -0700 (PDT)
In-Reply-To: <1460650770-19382-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Implement occupancy API introduced in devlink and mlxsw core. This is
done by accessing SBPM register for Port-Pool and SBSR for Port-TC
current and max occupancy values. Max clear is implemented using the
same registers.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  36 +--
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  18 ++
 .../net/ethernet/mellanox/mlxsw/spectrum_buffers.c | 255 +++++++++++++++++++++
 3 files changed, 293 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index ecadb15..681afe1 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2493,22 +2493,26 @@ static struct mlxsw_config_profile mlxsw_sp_config_profile = {
 };
 
 static struct mlxsw_driver mlxsw_sp_driver = {
-	.kind			= MLXSW_DEVICE_KIND_SPECTRUM,
-	.owner			= THIS_MODULE,
-	.priv_size		= sizeof(struct mlxsw_sp),
-	.init			= mlxsw_sp_init,
-	.fini			= mlxsw_sp_fini,
-	.port_split		= mlxsw_sp_port_split,
-	.port_unsplit		= mlxsw_sp_port_unsplit,
-	.sb_pool_get		= mlxsw_sp_sb_pool_get,
-	.sb_pool_set		= mlxsw_sp_sb_pool_set,
-	.sb_port_pool_get	= mlxsw_sp_sb_port_pool_get,
-	.sb_port_pool_set	= mlxsw_sp_sb_port_pool_set,
-	.sb_tc_pool_bind_get	= mlxsw_sp_sb_tc_pool_bind_get,
-	.sb_tc_pool_bind_set	= mlxsw_sp_sb_tc_pool_bind_set,
-	.txhdr_construct	= mlxsw_sp_txhdr_construct,
-	.txhdr_len		= MLXSW_TXHDR_LEN,
-	.profile		= &mlxsw_sp_config_profile,
+	.kind				= MLXSW_DEVICE_KIND_SPECTRUM,
+	.owner				= THIS_MODULE,
+	.priv_size			= sizeof(struct mlxsw_sp),
+	.init				= mlxsw_sp_init,
+	.fini				= mlxsw_sp_fini,
+	.port_split			= mlxsw_sp_port_split,
+	.port_unsplit			= mlxsw_sp_port_unsplit,
+	.sb_pool_get			= mlxsw_sp_sb_pool_get,
+	.sb_pool_set			= mlxsw_sp_sb_pool_set,
+	.sb_port_pool_get		= mlxsw_sp_sb_port_pool_get,
+	.sb_port_pool_set		= mlxsw_sp_sb_port_pool_set,
+	.sb_tc_pool_bind_get		= mlxsw_sp_sb_tc_pool_bind_get,
+	.sb_tc_pool_bind_set		= mlxsw_sp_sb_tc_pool_bind_set,
+	.sb_occ_snapshot		= mlxsw_sp_sb_occ_snapshot,
+	.sb_occ_max_clear		= mlxsw_sp_sb_occ_max_clear,
+	.sb_occ_port_pool_get		= mlxsw_sp_sb_occ_port_pool_get,
+	.sb_occ_tc_port_bind_get	= mlxsw_sp_sb_occ_tc_port_bind_get,
+	.txhdr_construct		= mlxsw_sp_txhdr_construct,
+	.txhdr_len			= MLXSW_TXHDR_LEN,
+	.profile			= &mlxsw_sp_config_profile,
 };
 
 static int
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 6458efa..e2c022d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -123,15 +123,22 @@ struct mlxsw_sp_sb_pr {
 	u32 size;
 };
 
+struct mlxsw_cp_sb_occ {
+	u32 cur;
+	u32 max;
+};
+
 struct mlxsw_sp_sb_cm {
 	u32 min_buff;
 	u32 max_buff;
 	u8 pool;
+	struct mlxsw_cp_sb_occ occ;
 };
 
 struct mlxsw_sp_sb_pm {
 	u32 min_buff;
 	u32 max_buff;
+	struct mlxsw_cp_sb_occ occ;
 };
 
 #define MLXSW_SP_SB_POOL_COUNT	4
@@ -328,6 +335,17 @@ int mlxsw_sp_sb_tc_pool_bind_set(struct mlxsw_core_port *mlxsw_core_port,
 				 unsigned int sb_index, u16 tc_index,
 				 enum devlink_sb_pool_type pool_type,
 				 u16 pool_index, u32 threshold);
+int mlxsw_sp_sb_occ_snapshot(struct mlxsw_core *mlxsw_core,
+			     unsigned int sb_index);
+int mlxsw_sp_sb_occ_max_clear(struct mlxsw_core *mlxsw_core,
+			      unsigned int sb_index);
+int mlxsw_sp_sb_occ_port_pool_get(struct mlxsw_core_port *mlxsw_core_port,
+				  unsigned int sb_index, u16 pool_index,
+				  u32 *p_cur, u32 *p_max);
+int mlxsw_sp_sb_occ_tc_port_bind_get(struct mlxsw_core_port *mlxsw_core_port,
+				     unsigned int sb_index, u16 tc_index,
+				     enum devlink_sb_pool_type pool_type,
+				     u32 *p_cur, u32 *p_max);
 
 int mlxsw_sp_switchdev_init(struct mlxsw_sp *mlxsw_sp);
 void mlxsw_sp_switchdev_fini(struct mlxsw_sp *mlxsw_sp);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
index 639ba5a..f2e073a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
@@ -36,6 +36,7 @@
 #include <linux/types.h>
 #include <linux/dcbnl.h>
 #include <linux/if_ether.h>
+#include <linux/list.h>
 
 #include "spectrum.h"
 #include "core.h"
@@ -125,6 +126,41 @@ static int mlxsw_sp_sb_pm_write(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 	return 0;
 }
 
+static int mlxsw_sp_sb_pm_occ_clear(struct mlxsw_sp *mlxsw_sp, u8 local_port,
+				    u8 pool, enum mlxsw_reg_sbxx_dir dir,
+				    struct list_head *bulk_list)
+{
+	char sbpm_pl[MLXSW_REG_SBPM_LEN];
+
+	mlxsw_reg_sbpm_pack(sbpm_pl, local_port, pool, dir, true, 0, 0);
+	return mlxsw_reg_trans_query(mlxsw_sp->core, MLXSW_REG(sbpm), sbpm_pl,
+				     bulk_list, NULL, 0);
+}
+
+static void mlxsw_sp_sb_pm_occ_query_cb(struct mlxsw_core *mlxsw_core,
+					char *sbpm_pl, size_t sbpm_pl_len,
+					unsigned long cb_priv)
+{
+	struct mlxsw_sp_sb_pm *pm = (struct mlxsw_sp_sb_pm *) cb_priv;
+
+	mlxsw_reg_sbpm_unpack(sbpm_pl, &pm->occ.cur, &pm->occ.max);
+}
+
+static int mlxsw_sp_sb_pm_occ_query(struct mlxsw_sp *mlxsw_sp, u8 local_port,
+				    u8 pool, enum mlxsw_reg_sbxx_dir dir,
+				    struct list_head *bulk_list)
+{
+	char sbpm_pl[MLXSW_REG_SBPM_LEN];
+	struct mlxsw_sp_sb_pm *pm;
+
+	pm = mlxsw_sp_sb_pm_get(mlxsw_sp, local_port, pool, dir);
+	mlxsw_reg_sbpm_pack(sbpm_pl, local_port, pool, dir, false, 0, 0);
+	return mlxsw_reg_trans_query(mlxsw_sp->core, MLXSW_REG(sbpm), sbpm_pl,
+				     bulk_list,
+				     mlxsw_sp_sb_pm_occ_query_cb,
+				     (unsigned long) pm);
+}
+
 static const u16 mlxsw_sp_pbs[] = {
 	2 * MLXSW_SP_BYTES_TO_CELLS(ETH_FRAME_LEN),
 	0,
@@ -707,3 +743,222 @@ int mlxsw_sp_sb_tc_pool_bind_set(struct mlxsw_core_port *mlxsw_core_port,
 	return mlxsw_sp_sb_cm_write(mlxsw_sp, local_port, pg_buff, dir,
 				    0, max_buff, pool);
 }
+
+#define MASKED_COUNT_MAX \
+	(MLXSW_REG_SBSR_REC_MAX_COUNT / (MLXSW_SP_SB_TC_COUNT * 2))
+
+struct mlxsw_sp_sb_sr_occ_query_cb_ctx {
+	u8 masked_count;
+	u8 local_port_1;
+};
+
+static void mlxsw_sp_sb_sr_occ_query_cb(struct mlxsw_core *mlxsw_core,
+					char *sbsr_pl, size_t sbsr_pl_len,
+					unsigned long cb_priv)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_core_driver_priv(mlxsw_core);
+	struct mlxsw_sp_sb_sr_occ_query_cb_ctx cb_ctx;
+	u8 masked_count;
+	u8 local_port;
+	int rec_index = 0;
+	struct mlxsw_sp_sb_cm *cm;
+	int i;
+
+	memcpy(&cb_ctx, &cb_priv, sizeof(cb_ctx));
+
+	masked_count = 0;
+	for (local_port = cb_ctx.local_port_1;
+	     local_port < MLXSW_PORT_MAX_PORTS; local_port++) {
+		if (!mlxsw_sp->ports[local_port])
+			continue;
+		for (i = 0; i < MLXSW_SP_SB_TC_COUNT; i++) {
+			cm = mlxsw_sp_sb_cm_get(mlxsw_sp, local_port, i,
+						MLXSW_REG_SBXX_DIR_INGRESS);
+			mlxsw_reg_sbsr_rec_unpack(sbsr_pl, rec_index++,
+						  &cm->occ.cur, &cm->occ.max);
+		}
+		if (++masked_count == cb_ctx.masked_count)
+			break;
+	}
+	masked_count = 0;
+	for (local_port = cb_ctx.local_port_1;
+	     local_port < MLXSW_PORT_MAX_PORTS; local_port++) {
+		if (!mlxsw_sp->ports[local_port])
+			continue;
+		for (i = 0; i < MLXSW_SP_SB_TC_COUNT; i++) {
+			cm = mlxsw_sp_sb_cm_get(mlxsw_sp, local_port, i,
+						MLXSW_REG_SBXX_DIR_EGRESS);
+			mlxsw_reg_sbsr_rec_unpack(sbsr_pl, rec_index++,
+						  &cm->occ.cur, &cm->occ.max);
+		}
+		if (++masked_count == cb_ctx.masked_count)
+			break;
+	}
+}
+
+int mlxsw_sp_sb_occ_snapshot(struct mlxsw_core *mlxsw_core,
+			     unsigned int sb_index)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_core_driver_priv(mlxsw_core);
+	struct mlxsw_sp_sb_sr_occ_query_cb_ctx cb_ctx;
+	unsigned long cb_priv;
+	LIST_HEAD(bulk_list);
+	char *sbsr_pl;
+	u8 masked_count;
+	u8 local_port_1;
+	u8 local_port = 0;
+	int i;
+	int err;
+	int err2;
+
+	sbsr_pl = kmalloc(MLXSW_REG_SBSR_LEN, GFP_KERNEL);
+	if (!sbsr_pl)
+		return -ENOMEM;
+
+next_batch:
+	local_port++;
+	local_port_1 = local_port;
+	masked_count = 0;
+	mlxsw_reg_sbsr_pack(sbsr_pl, false);
+	for (i = 0; i < MLXSW_SP_SB_TC_COUNT; i++) {
+		mlxsw_reg_sbsr_pg_buff_mask_set(sbsr_pl, i, 1);
+		mlxsw_reg_sbsr_tclass_mask_set(sbsr_pl, i, 1);
+	}
+	for (; local_port < MLXSW_PORT_MAX_PORTS; local_port++) {
+		if (!mlxsw_sp->ports[local_port])
+			continue;
+		mlxsw_reg_sbsr_ingress_port_mask_set(sbsr_pl, local_port, 1);
+		mlxsw_reg_sbsr_egress_port_mask_set(sbsr_pl, local_port, 1);
+		for (i = 0; i < MLXSW_SP_SB_POOL_COUNT; i++) {
+			err = mlxsw_sp_sb_pm_occ_query(mlxsw_sp, local_port, i,
+						       MLXSW_REG_SBXX_DIR_INGRESS,
+						       &bulk_list);
+			if (err)
+				goto out;
+			err = mlxsw_sp_sb_pm_occ_query(mlxsw_sp, local_port, i,
+						       MLXSW_REG_SBXX_DIR_EGRESS,
+						       &bulk_list);
+			if (err)
+				goto out;
+		}
+		if (++masked_count == MASKED_COUNT_MAX)
+			goto do_query;
+	}
+
+do_query:
+	cb_ctx.masked_count = masked_count;
+	cb_ctx.local_port_1 = local_port_1;
+	memcpy(&cb_priv, &cb_ctx, sizeof(cb_ctx));
+	err = mlxsw_reg_trans_query(mlxsw_core, MLXSW_REG(sbsr), sbsr_pl,
+				    &bulk_list, mlxsw_sp_sb_sr_occ_query_cb,
+				    cb_priv);
+	if (err)
+		goto out;
+	if (local_port < MLXSW_PORT_MAX_PORTS)
+		goto next_batch;
+
+out:
+	err2 = mlxsw_reg_trans_bulk_wait(&bulk_list);
+	if (!err)
+		err = err2;
+	kfree(sbsr_pl);
+	return err;
+}
+
+int mlxsw_sp_sb_occ_max_clear(struct mlxsw_core *mlxsw_core,
+			      unsigned int sb_index)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_core_driver_priv(mlxsw_core);
+	LIST_HEAD(bulk_list);
+	char *sbsr_pl;
+	unsigned int masked_count;
+	u8 local_port = 0;
+	int i;
+	int err;
+	int err2;
+
+	sbsr_pl = kmalloc(MLXSW_REG_SBSR_LEN, GFP_KERNEL);
+	if (!sbsr_pl)
+		return -ENOMEM;
+
+next_batch:
+	local_port++;
+	masked_count = 0;
+	mlxsw_reg_sbsr_pack(sbsr_pl, true);
+	for (i = 0; i < MLXSW_SP_SB_TC_COUNT; i++) {
+		mlxsw_reg_sbsr_pg_buff_mask_set(sbsr_pl, i, 1);
+		mlxsw_reg_sbsr_tclass_mask_set(sbsr_pl, i, 1);
+	}
+	for (; local_port < MLXSW_PORT_MAX_PORTS; local_port++) {
+		if (!mlxsw_sp->ports[local_port])
+			continue;
+		mlxsw_reg_sbsr_ingress_port_mask_set(sbsr_pl, local_port, 1);
+		mlxsw_reg_sbsr_egress_port_mask_set(sbsr_pl, local_port, 1);
+		for (i = 0; i < MLXSW_SP_SB_POOL_COUNT; i++) {
+			err = mlxsw_sp_sb_pm_occ_clear(mlxsw_sp, local_port, i,
+						       MLXSW_REG_SBXX_DIR_INGRESS,
+						       &bulk_list);
+			if (err)
+				goto out;
+			err = mlxsw_sp_sb_pm_occ_clear(mlxsw_sp, local_port, i,
+						       MLXSW_REG_SBXX_DIR_EGRESS,
+						       &bulk_list);
+			if (err)
+				goto out;
+		}
+		if (++masked_count == MASKED_COUNT_MAX)
+			goto do_query;
+	}
+
+do_query:
+	err = mlxsw_reg_trans_query(mlxsw_core, MLXSW_REG(sbsr), sbsr_pl,
+				    &bulk_list, NULL, 0);
+	if (err)
+		goto out;
+	if (local_port < MLXSW_PORT_MAX_PORTS)
+		goto next_batch;
+
+out:
+	err2 = mlxsw_reg_trans_bulk_wait(&bulk_list);
+	if (!err)
+		err = err2;
+	kfree(sbsr_pl);
+	return err;
+}
+
+int mlxsw_sp_sb_occ_port_pool_get(struct mlxsw_core_port *mlxsw_core_port,
+				  unsigned int sb_index, u16 pool_index,
+				  u32 *p_cur, u32 *p_max)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port =
+			mlxsw_core_port_driver_priv(mlxsw_core_port);
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	u8 local_port = mlxsw_sp_port->local_port;
+	u8 pool = pool_get(pool_index);
+	enum mlxsw_reg_sbxx_dir dir = dir_get(pool_index);
+	struct mlxsw_sp_sb_pm *pm = mlxsw_sp_sb_pm_get(mlxsw_sp, local_port,
+						       pool, dir);
+
+	*p_cur = MLXSW_SP_CELLS_TO_BYTES(pm->occ.cur);
+	*p_max = MLXSW_SP_CELLS_TO_BYTES(pm->occ.max);
+	return 0;
+}
+
+int mlxsw_sp_sb_occ_tc_port_bind_get(struct mlxsw_core_port *mlxsw_core_port,
+				     unsigned int sb_index, u16 tc_index,
+				     enum devlink_sb_pool_type pool_type,
+				     u32 *p_cur, u32 *p_max)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port =
+			mlxsw_core_port_driver_priv(mlxsw_core_port);
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	u8 local_port = mlxsw_sp_port->local_port;
+	u8 pg_buff = tc_index;
+	enum mlxsw_reg_sbxx_dir dir = pool_type;
+	struct mlxsw_sp_sb_cm *cm = mlxsw_sp_sb_cm_get(mlxsw_sp, local_port,
+						       pg_buff, dir);
+
+	*p_cur = MLXSW_SP_CELLS_TO_BYTES(cm->occ.cur);
+	*p_max = MLXSW_SP_CELLS_TO_BYTES(cm->occ.max);
+	return 0;
+}
-- 
2.5.5
