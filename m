From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 13/13] mlxsw: spectrum: Implement shared buffer configuration
Date: Thu, 17 Mar 2016 18:13:53 +0100
Message-ID: <1458234833-25836-14-git-send-email-jiri@resnulli.us>
References: <1458234833-25836-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	jhs@mojatatu.com, john.fastabend@gmail.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com, stephen@networkplumber.org,
	sfeldma@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:32865 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031757AbcCQROP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 13:14:15 -0400
Received: by mail-wm0-f68.google.com with SMTP id x188so460615wmg.0
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2016 10:14:14 -0700 (PDT)
In-Reply-To: <1458234833-25836-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Implement previously introduced devlink shared buffer API. In mlxsw that
is done utilizing registers SBPR, SBCM and SBPM.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |   8 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  21 +++
 .../net/ethernet/mellanox/mlxsw/spectrum_buffers.c | 161 ++++++++++++++++++++-
 3 files changed, 189 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 324848d..60fc109 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2136,6 +2136,7 @@ static int mlxsw_sp_init(struct mlxsw_core *mlxsw_core,
 
 err_switchdev_init:
 err_lag_init:
+	mlxsw_sp_buffers_fini(mlxsw_sp);
 err_buffers_init:
 err_flood_init:
 	mlxsw_sp_traps_fini(mlxsw_sp);
@@ -2150,6 +2151,7 @@ static void mlxsw_sp_fini(struct mlxsw_core *mlxsw_core)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_core_driver_priv(mlxsw_core);
 
+	mlxsw_sp_buffers_fini(mlxsw_sp);
 	mlxsw_sp_switchdev_fini(mlxsw_sp);
 	mlxsw_sp_traps_fini(mlxsw_sp);
 	mlxsw_sp_event_unregister(mlxsw_sp, MLXSW_TRAP_ID_PUDE);
@@ -2200,6 +2202,12 @@ static struct mlxsw_driver mlxsw_sp_driver = {
 	.fini			= mlxsw_sp_fini,
 	.port_split		= mlxsw_sp_port_split,
 	.port_unsplit		= mlxsw_sp_port_unsplit,
+	.sb_pool_get		= mlxsw_sp_sb_pool_get,
+	.sb_pool_set		= mlxsw_sp_sb_pool_set,
+	.sb_port_pool_get	= mlxsw_sp_sb_port_pool_get,
+	.sb_port_pool_set	= mlxsw_sp_sb_port_pool_set,
+	.sb_tc_pool_bind_get	= mlxsw_sp_sb_tc_pool_bind_get,
+	.sb_tc_pool_bind_set	= mlxsw_sp_sb_tc_pool_bind_set,
 	.txhdr_construct	= mlxsw_sp_txhdr_construct,
 	.txhdr_len		= MLXSW_TXHDR_LEN,
 	.profile		= &mlxsw_sp_config_profile,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index ed3c871..4c3d8a7 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -272,7 +272,28 @@ enum mlxsw_sp_flood_table {
 };
 
 int mlxsw_sp_buffers_init(struct mlxsw_sp *mlxsw_sp);
+void mlxsw_sp_buffers_fini(struct mlxsw_sp *mlxsw_sp);
 int mlxsw_sp_port_buffers_init(struct mlxsw_sp_port *mlxsw_sp_port);
+int mlxsw_sp_sb_pool_get(struct mlxsw_core *mlxsw_core,
+			 unsigned int sb_index, u16 pool_index,
+			 struct devlink_sb_pool_info *pool_info);
+int mlxsw_sp_sb_pool_set(struct mlxsw_core *mlxsw_core,
+			 unsigned int sb_index, u16 pool_index, u32 size,
+			 enum devlink_sb_threshold_type threshold_type);
+int mlxsw_sp_sb_port_pool_get(struct mlxsw_core_port *mlxsw_core_port,
+			      unsigned int sb_index, u16 pool_index,
+			      u32 *p_threshold);
+int mlxsw_sp_sb_port_pool_set(struct mlxsw_core_port *mlxsw_core_port,
+			      unsigned int sb_index, u16 pool_index,
+			      u32 threshold);
+int mlxsw_sp_sb_tc_pool_bind_get(struct mlxsw_core_port *mlxsw_core_port,
+				 unsigned int sb_index, u16 tc_index,
+				 enum devlink_sb_pool_type pool_type,
+				 u16 *p_pool_index, u32 *p_threshold);
+int mlxsw_sp_sb_tc_pool_bind_set(struct mlxsw_core_port *mlxsw_core_port,
+				 unsigned int sb_index, u16 tc_index,
+				 enum devlink_sb_pool_type pool_type,
+				 u16 pool_index, u32 threshold);
 
 int mlxsw_sp_switchdev_init(struct mlxsw_sp *mlxsw_sp);
 void mlxsw_sp_switchdev_fini(struct mlxsw_sp *mlxsw_sp);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
index beca792..17f8564 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
@@ -470,6 +470,8 @@ static int mlxsw_sp_sb_mms_init(struct mlxsw_sp *mlxsw_sp)
 	return 0;
 }
 
+#define MLXSW_SP_SB_SIZE (16 * 1024 * 1024)
+
 int mlxsw_sp_buffers_init(struct mlxsw_sp *mlxsw_sp)
 {
 	int err;
@@ -484,7 +486,16 @@ int mlxsw_sp_buffers_init(struct mlxsw_sp *mlxsw_sp)
 	if (err)
 		return err;
 
-	return 0;
+	return devlink_sb_register(priv_to_devlink(mlxsw_sp->core), 0,
+				   MLXSW_SP_SB_SIZE,
+				   MLXSW_SP_SB_POOL_COUNT,
+				   MLXSW_SP_SB_POOL_COUNT,
+				   MLXSW_SP_SB_TC_COUNT);
+}
+
+void mlxsw_sp_buffers_fini(struct mlxsw_sp *mlxsw_sp)
+{
+	devlink_sb_unregister(priv_to_devlink(mlxsw_sp->core), 0);
 }
 
 int mlxsw_sp_port_buffers_init(struct mlxsw_sp_port *mlxsw_sp_port)
@@ -501,3 +512,151 @@ int mlxsw_sp_port_buffers_init(struct mlxsw_sp_port *mlxsw_sp_port)
 
 	return err;
 }
+
+static u8 pool_get(u16 pool_index)
+{
+	return pool_index % MLXSW_SP_SB_POOL_COUNT;
+}
+
+static u16 pool_index_get(u8 pool, enum mlxsw_reg_sbxx_dir dir)
+{
+	u16 pool_index;
+
+	pool_index = pool;
+	if (dir == MLXSW_REG_SBXX_DIR_EGRESS)
+		pool_index += MLXSW_SP_SB_POOL_COUNT;
+	return pool_index;
+}
+
+static enum mlxsw_reg_sbxx_dir dir_get(u16 pool_index)
+{
+	return pool_index < MLXSW_SP_SB_POOL_COUNT ?
+	       MLXSW_REG_SBXX_DIR_INGRESS : MLXSW_REG_SBXX_DIR_EGRESS;
+}
+
+int mlxsw_sp_sb_pool_get(struct mlxsw_core *mlxsw_core,
+			 unsigned int sb_index, u16 pool_index,
+			 struct devlink_sb_pool_info *pool_info)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_core_driver_priv(mlxsw_core);
+	u8 pool = pool_get(pool_index);
+	enum mlxsw_reg_sbxx_dir dir = dir_get(pool_index);
+	struct mlxsw_sp_sb_pr *pr = mlxsw_sp_sb_pr_get(mlxsw_sp, pool, dir);
+
+	pool_info->pool_type = dir;
+	pool_info->size = pr->size * MLXSW_SP_SB_BYTES_PER_CELL;
+	pool_info->threshold_type = pr->mode;
+	return 0;
+}
+
+int mlxsw_sp_sb_pool_set(struct mlxsw_core *mlxsw_core,
+			 unsigned int sb_index, u16 pool_index, u32 size,
+			 enum devlink_sb_threshold_type threshold_type)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_core_driver_priv(mlxsw_core);
+	u8 pool = pool_get(pool_index);
+	enum mlxsw_reg_sbxx_dir dir = dir_get(pool_index);
+	enum mlxsw_reg_sbpr_mode mode = threshold_type;
+	u32 pool_size = DIV_ROUND_UP(size, MLXSW_SP_SB_BYTES_PER_CELL);
+
+	return mlxsw_sp_sb_pr_write(mlxsw_sp, pool, dir, mode, pool_size);
+}
+
+static u32 mlxsw_sp_sb_threshold_out(struct mlxsw_sp *mlxsw_sp, u8 pool,
+				     enum mlxsw_reg_sbxx_dir dir, u32 max_buff)
+{
+	struct mlxsw_sp_sb_pr *pr = mlxsw_sp_sb_pr_get(mlxsw_sp, pool, dir);
+
+	if (pr->mode == MLXSW_REG_SBPR_MODE_DYNAMIC)
+		return max_buff;
+	return max_buff * MLXSW_SP_SB_BYTES_PER_CELL;
+}
+
+static u32 mlxsw_sp_sb_threshold_in(struct mlxsw_sp *mlxsw_sp, u8 pool,
+				    enum mlxsw_reg_sbxx_dir dir, u32 threshold)
+{
+	struct mlxsw_sp_sb_pr *pr = mlxsw_sp_sb_pr_get(mlxsw_sp, pool, dir);
+
+	if (pr->mode == MLXSW_REG_SBPR_MODE_DYNAMIC)
+		return threshold;
+	return DIV_ROUND_UP(threshold, MLXSW_SP_SB_BYTES_PER_CELL);
+}
+
+int mlxsw_sp_sb_port_pool_get(struct mlxsw_core_port *mlxsw_core_port,
+			      unsigned int sb_index, u16 pool_index,
+			      u32 *p_threshold)
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
+	*p_threshold = mlxsw_sp_sb_threshold_out(mlxsw_sp, pool, dir,
+						 pm->max_buff);
+	return 0;
+}
+
+int mlxsw_sp_sb_port_pool_set(struct mlxsw_core_port *mlxsw_core_port,
+			      unsigned int sb_index, u16 pool_index,
+			      u32 threshold)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port =
+			mlxsw_core_port_driver_priv(mlxsw_core_port);
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	u8 local_port = mlxsw_sp_port->local_port;
+	u8 pool = pool_get(pool_index);
+	enum mlxsw_reg_sbxx_dir dir = dir_get(pool_index);
+	u32 max_buff = mlxsw_sp_sb_threshold_in(mlxsw_sp, pool, dir, threshold);
+
+	return mlxsw_sp_sb_pm_write(mlxsw_sp, local_port, pool, dir,
+				    0, max_buff);
+}
+
+int mlxsw_sp_sb_tc_pool_bind_get(struct mlxsw_core_port *mlxsw_core_port,
+				 unsigned int sb_index, u16 tc_index,
+				 enum devlink_sb_pool_type pool_type,
+				 u16 *p_pool_index, u32 *p_threshold)
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
+	*p_threshold = mlxsw_sp_sb_threshold_out(mlxsw_sp, cm->pool, dir,
+						 cm->max_buff);
+	*p_pool_index = pool_index_get(cm->pool, pool_type);;
+	return 0;
+}
+
+int mlxsw_sp_sb_tc_pool_bind_set(struct mlxsw_core_port *mlxsw_core_port,
+				 unsigned int sb_index, u16 tc_index,
+				 enum devlink_sb_pool_type pool_type,
+				 u16 pool_index, u32 threshold)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port =
+			mlxsw_core_port_driver_priv(mlxsw_core_port);
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	u8 local_port = mlxsw_sp_port->local_port;
+	u8 pg_buff = tc_index;
+	enum mlxsw_reg_sbxx_dir dir = pool_type;
+	u8 pool = pool_index;
+	u32 max_buff = mlxsw_sp_sb_threshold_in(mlxsw_sp, pool, dir, threshold);
+
+	if (pool_type == DEVLINK_SB_POOL_TYPE_EGRESS) {
+		if (pool < MLXSW_SP_SB_POOL_COUNT)
+			return -EINVAL;
+		pool -= MLXSW_SP_SB_POOL_COUNT;
+	} else if (pool >= MLXSW_SP_SB_POOL_COUNT) {
+		return -EINVAL;
+	}
+	return mlxsw_sp_sb_cm_write(mlxsw_sp, local_port, pg_buff, dir,
+				    0, max_buff, pool);
+}
-- 
2.5.0
