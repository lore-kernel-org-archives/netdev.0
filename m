From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 12/18] mlxsw: spectrum_buffers: Implement shared buffer configuration
Date: Thu, 14 Apr 2016 18:19:24 +0200
Message-ID: <1460650770-19382-13-git-send-email-jiri@resnulli.us>
References: <1460650770-19382-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	jhs@mojatatu.com, john.fastabend@gmail.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com, stephen@networkplumber.org,
	sfeldma@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:36605 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964820AbcDNQTu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 12:19:50 -0400
Received: by mail-wm0-f53.google.com with SMTP id v188so227624420wme.1
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2016 09:19:49 -0700 (PDT)
In-Reply-To: <1460650770-19382-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Implement previously introduced mlxsw core shared buffer API.
For Spectrum, that is done utilizing registers SBPR, SBCM and SBPM.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |   8 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  22 +++
 .../net/ethernet/mellanox/mlxsw/spectrum_buffers.c | 187 ++++++++++++++++++++-
 3 files changed, 216 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 19b3c14..ecadb15 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2434,6 +2434,7 @@ static int mlxsw_sp_init(struct mlxsw_core *mlxsw_core,
 
 err_switchdev_init:
 err_lag_init:
+	mlxsw_sp_buffers_fini(mlxsw_sp);
 err_buffers_init:
 err_flood_init:
 	mlxsw_sp_traps_fini(mlxsw_sp);
@@ -2448,6 +2449,7 @@ static void mlxsw_sp_fini(struct mlxsw_core *mlxsw_core)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_core_driver_priv(mlxsw_core);
 
+	mlxsw_sp_buffers_fini(mlxsw_sp);
 	mlxsw_sp_switchdev_fini(mlxsw_sp);
 	mlxsw_sp_traps_fini(mlxsw_sp);
 	mlxsw_sp_event_unregister(mlxsw_sp, MLXSW_TRAP_ID_PUDE);
@@ -2498,6 +2500,12 @@ static struct mlxsw_driver mlxsw_sp_driver = {
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
index 790c292..6458efa 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -65,6 +65,7 @@
 #define MLXSW_SP_BYTES_PER_CELL 96
 
 #define MLXSW_SP_BYTES_TO_CELLS(b) DIV_ROUND_UP(b, MLXSW_SP_BYTES_PER_CELL)
+#define MLXSW_SP_CELLS_TO_BYTES(c) (c * MLXSW_SP_BYTES_PER_CELL)
 
 /* Maximum delay buffer needed in case of PAUSE frames, in cells.
  * Assumes 100m cable and maximum MTU.
@@ -305,7 +306,28 @@ enum mlxsw_sp_flood_table {
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
index fd6b080..6042c17 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
@@ -492,6 +492,8 @@ static int mlxsw_sp_sb_mms_init(struct mlxsw_sp *mlxsw_sp)
 	return 0;
 }
 
+#define MLXSW_SP_SB_SIZE (16 * 1024 * 1024)
+
 int mlxsw_sp_buffers_init(struct mlxsw_sp *mlxsw_sp)
 {
 	int err;
@@ -503,8 +505,19 @@ int mlxsw_sp_buffers_init(struct mlxsw_sp *mlxsw_sp)
 	if (err)
 		return err;
 	err = mlxsw_sp_sb_mms_init(mlxsw_sp);
+	if (err)
+		return err;
+	return devlink_sb_register(priv_to_devlink(mlxsw_sp->core), 0,
+				   MLXSW_SP_SB_SIZE,
+				   MLXSW_SP_SB_POOL_COUNT,
+				   MLXSW_SP_SB_POOL_COUNT,
+				   MLXSW_SP_SB_TC_COUNT,
+				   MLXSW_SP_SB_TC_COUNT);
+}
 
-	return err;
+void mlxsw_sp_buffers_fini(struct mlxsw_sp *mlxsw_sp)
+{
+	devlink_sb_unregister(priv_to_devlink(mlxsw_sp->core), 0);
 }
 
 int mlxsw_sp_port_buffers_init(struct mlxsw_sp_port *mlxsw_sp_port)
@@ -521,3 +534,175 @@ int mlxsw_sp_port_buffers_init(struct mlxsw_sp_port *mlxsw_sp_port)
 
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
+	pool_info->size = MLXSW_SP_CELLS_TO_BYTES(pr->size);
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
+	u32 pool_size = MLXSW_SP_BYTES_TO_CELLS(size);
+
+	return mlxsw_sp_sb_pr_write(mlxsw_sp, pool, dir, mode, pool_size);
+}
+
+#define MLXSW_SP_SB_THRESHOLD_TO_ALPHA_OFFSET (-2) /* 3->1, 16->14 */
+
+static u32 mlxsw_sp_sb_threshold_out(struct mlxsw_sp *mlxsw_sp, u8 pool,
+				     enum mlxsw_reg_sbxx_dir dir, u32 max_buff)
+{
+	struct mlxsw_sp_sb_pr *pr = mlxsw_sp_sb_pr_get(mlxsw_sp, pool, dir);
+
+	if (pr->mode == MLXSW_REG_SBPR_MODE_DYNAMIC)
+		return max_buff - MLXSW_SP_SB_THRESHOLD_TO_ALPHA_OFFSET;
+	return MLXSW_SP_CELLS_TO_BYTES(max_buff);
+}
+
+static int mlxsw_sp_sb_threshold_in(struct mlxsw_sp *mlxsw_sp, u8 pool,
+				    enum mlxsw_reg_sbxx_dir dir, u32 threshold,
+				    u32 *p_max_buff)
+{
+	struct mlxsw_sp_sb_pr *pr = mlxsw_sp_sb_pr_get(mlxsw_sp, pool, dir);
+
+	if (pr->mode == MLXSW_REG_SBPR_MODE_DYNAMIC) {
+		int val;
+
+		val = threshold + MLXSW_SP_SB_THRESHOLD_TO_ALPHA_OFFSET;
+		if (val < MLXSW_REG_SBXX_DYN_MAX_BUFF_MIN ||
+		    val > MLXSW_REG_SBXX_DYN_MAX_BUFF_MAX)
+			return -EINVAL;
+		*p_max_buff = val;
+	} else {
+		*p_max_buff = MLXSW_SP_BYTES_TO_CELLS(threshold);
+	}
+	return 0;
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
+	u32 max_buff;
+	int err;
+
+	err = mlxsw_sp_sb_threshold_in(mlxsw_sp, pool, dir,
+				       threshold, &max_buff);
+	if (err)
+		return err;
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
+	*p_pool_index = pool_index_get(cm->pool, pool_type);
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
+	u32 max_buff;
+	int err;
+
+	err = mlxsw_sp_sb_threshold_in(mlxsw_sp, pool, dir,
+				       threshold, &max_buff);
+	if (err)
+		return err;
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
2.5.5
