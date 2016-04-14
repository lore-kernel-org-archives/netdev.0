From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 07/18] mlxsw: spectrum_buffers: Cache shared buffer configuration
Date: Thu, 14 Apr 2016 18:19:19 +0200
Message-ID: <1460650770-19382-8-git-send-email-jiri@resnulli.us>
References: <1460650770-19382-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	jhs@mojatatu.com, john.fastabend@gmail.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com, stephen@networkplumber.org,
	sfeldma@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:35688 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932927AbcDNQTn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 12:19:43 -0400
Received: by mail-wm0-f46.google.com with SMTP id a140so154838256wma.0
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2016 09:19:43 -0700 (PDT)
In-Reply-To: <1460650770-19382-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

In order to achieve faster dumping of current setting and also in order
to provide possibility to get pool mode without a need to query hardware,
do cache the configuration in driver.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     | 28 +++++++++
 .../net/ethernet/mellanox/mlxsw/spectrum_buffers.c | 73 ++++++++++++++++------
 2 files changed, 82 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 361b0c2..790c292 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -117,6 +117,33 @@ static inline bool mlxsw_sp_fid_is_vfid(u16 fid)
 	return fid >= MLXSW_SP_VFID_BASE;
 }
 
+struct mlxsw_sp_sb_pr {
+	enum mlxsw_reg_sbpr_mode mode;
+	u32 size;
+};
+
+struct mlxsw_sp_sb_cm {
+	u32 min_buff;
+	u32 max_buff;
+	u8 pool;
+};
+
+struct mlxsw_sp_sb_pm {
+	u32 min_buff;
+	u32 max_buff;
+};
+
+#define MLXSW_SP_SB_POOL_COUNT	4
+#define MLXSW_SP_SB_TC_COUNT	8
+
+struct mlxsw_sp_sb {
+	struct mlxsw_sp_sb_pr prs[2][MLXSW_SP_SB_POOL_COUNT];
+	struct {
+		struct mlxsw_sp_sb_cm cms[2][MLXSW_SP_SB_TC_COUNT];
+		struct mlxsw_sp_sb_pm pms[2][MLXSW_SP_SB_POOL_COUNT];
+	} ports[MLXSW_PORT_MAX_PORTS];
+};
+
 struct mlxsw_sp {
 	struct {
 		struct list_head list;
@@ -147,6 +174,7 @@ struct mlxsw_sp {
 	struct mlxsw_sp_upper master_bridge;
 	struct mlxsw_sp_upper lags[MLXSW_SP_LAG_MAX];
 	u8 port_to_module[MLXSW_PORT_MAX_PORTS];
+	struct mlxsw_sp_sb sb;
 };
 
 static inline struct mlxsw_sp_upper *
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
index 15bd5aa..b43f7d36e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
@@ -42,14 +42,44 @@
 #include "port.h"
 #include "reg.h"
 
+static struct mlxsw_sp_sb_pr *mlxsw_sp_sb_pr_get(struct mlxsw_sp *mlxsw_sp,
+						 u8 pool,
+						 enum mlxsw_reg_sbxx_dir dir)
+{
+	return &mlxsw_sp->sb.prs[dir][pool];
+}
+
+static struct mlxsw_sp_sb_cm *mlxsw_sp_sb_cm_get(struct mlxsw_sp *mlxsw_sp,
+						 u8 local_port, u8 pg_buff,
+						 enum mlxsw_reg_sbxx_dir dir)
+{
+	return &mlxsw_sp->sb.ports[local_port].cms[dir][pg_buff];
+}
+
+static struct mlxsw_sp_sb_pm *mlxsw_sp_sb_pm_get(struct mlxsw_sp *mlxsw_sp,
+						 u8 local_port, u8 pool,
+						 enum mlxsw_reg_sbxx_dir dir)
+{
+	return &mlxsw_sp->sb.ports[local_port].pms[dir][pool];
+}
+
 static int mlxsw_sp_sb_pr_write(struct mlxsw_sp *mlxsw_sp, u8 pool,
 				enum mlxsw_reg_sbxx_dir dir,
 				enum mlxsw_reg_sbpr_mode mode, u32 size)
 {
 	char sbpr_pl[MLXSW_REG_SBPR_LEN];
+	struct mlxsw_sp_sb_pr *pr;
+	int err;
 
 	mlxsw_reg_sbpr_pack(sbpr_pl, pool, dir, mode, size);
-	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sbpr), sbpr_pl);
+	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sbpr), sbpr_pl);
+	if (err)
+		return err;
+
+	pr = mlxsw_sp_sb_pr_get(mlxsw_sp, pool, dir);
+	pr->mode = mode;
+	pr->size = size;
+	return 0;
 }
 
 static int mlxsw_sp_sb_cm_write(struct mlxsw_sp *mlxsw_sp, u8 local_port,
@@ -57,10 +87,22 @@ static int mlxsw_sp_sb_cm_write(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 				u32 min_buff, u32 max_buff, u8 pool)
 {
 	char sbcm_pl[MLXSW_REG_SBCM_LEN];
+	int err;
 
 	mlxsw_reg_sbcm_pack(sbcm_pl, local_port, pg_buff, dir,
 			    min_buff, max_buff, pool);
-	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sbcm), sbcm_pl);
+	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sbcm), sbcm_pl);
+	if (err)
+		return err;
+	if (pg_buff < MLXSW_SP_SB_TC_COUNT) {
+		struct mlxsw_sp_sb_cm *cm;
+
+		cm = mlxsw_sp_sb_cm_get(mlxsw_sp, local_port, pg_buff, dir);
+		cm->min_buff = min_buff;
+		cm->max_buff = max_buff;
+		cm->pool = pool;
+	}
+	return 0;
 }
 
 static int mlxsw_sp_sb_pm_write(struct mlxsw_sp *mlxsw_sp, u8 local_port,
@@ -68,9 +110,18 @@ static int mlxsw_sp_sb_pm_write(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 				u32 min_buff, u32 max_buff)
 {
 	char sbpm_pl[MLXSW_REG_SBPM_LEN];
+	struct mlxsw_sp_sb_pm *pm;
+	int err;
 
 	mlxsw_reg_sbpm_pack(sbpm_pl, local_port, pool, dir, min_buff, max_buff);
-	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sbpm), sbpm_pl);
+	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sbpm), sbpm_pl);
+	if (err)
+		return err;
+
+	pm = mlxsw_sp_sb_pm_get(mlxsw_sp, local_port, pool, dir);
+	pm->min_buff = min_buff;
+	pm->max_buff = max_buff;
+	return 0;
 }
 
 static const u16 mlxsw_sp_pbs[] = {
@@ -128,11 +179,6 @@ static int mlxsw_sp_port_headroom_init(struct mlxsw_sp_port *mlxsw_sp_port)
 	return mlxsw_sp_port_pb_prio_init(mlxsw_sp_port);
 }
 
-struct mlxsw_sp_sb_pr {
-	enum mlxsw_reg_sbpr_mode mode;
-	u32 size;
-};
-
 #define MLXSW_SP_SB_PR_INGRESS_SIZE				\
 	(15000000 - (2 * 20000 * MLXSW_PORT_MAX_PORTS))
 #define MLXSW_SP_SB_PR_EGRESS_SIZE				\
@@ -199,12 +245,6 @@ static int mlxsw_sp_sb_prs_init(struct mlxsw_sp *mlxsw_sp)
 				      MLXSW_SP_SB_PRS_EGRESS_LEN);
 }
 
-struct mlxsw_sp_sb_cm {
-	u32 min_buff;
-	u32 max_buff;
-	u8 pool;
-};
-
 #define MLXSW_SP_SB_CM(_min_buff, _max_buff, _pool)	\
 	{						\
 		.min_buff = _min_buff,			\
@@ -337,11 +377,6 @@ static int mlxsw_sp_cpu_port_sb_cms_init(struct mlxsw_sp *mlxsw_sp)
 				      MLXSW_SP_CPU_PORT_SB_MCS_LEN);
 }
 
-struct mlxsw_sp_sb_pm {
-	u32 min_buff;
-	u32 max_buff;
-};
-
 #define MLXSW_SP_SB_PM(_min_buff, _max_buff)	\
 	{					\
 		.min_buff = _min_buff,		\
-- 
2.5.5
