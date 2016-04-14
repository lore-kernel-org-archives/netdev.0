From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 04/18] mlxsw: spectrum_buffers: Push out shared buffer register writes
Date: Thu, 14 Apr 2016 18:19:16 +0200
Message-ID: <1460650770-19382-5-git-send-email-jiri@resnulli.us>
References: <1460650770-19382-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	jhs@mojatatu.com, john.fastabend@gmail.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com, stephen@networkplumber.org,
	sfeldma@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:36471 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964788AbcDNQTj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 12:19:39 -0400
Received: by mail-wm0-f49.google.com with SMTP id v188so227617821wme.1
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2016 09:19:39 -0700 (PDT)
In-Reply-To: <1460650770-19382-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Pushed them into helper functions.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_buffers.c | 54 ++++++++++++++++------
 1 file changed, 40 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
index f58b1d3..ae60838 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
@@ -42,6 +42,37 @@
 #include "port.h"
 #include "reg.h"
 
+static int mlxsw_sp_sb_pr_write(struct mlxsw_sp *mlxsw_sp, u8 pool,
+				enum mlxsw_reg_sbxx_dir dir,
+				enum mlxsw_reg_sbpr_mode mode, u32 size)
+{
+	char sbpr_pl[MLXSW_REG_SBPR_LEN];
+
+	mlxsw_reg_sbpr_pack(sbpr_pl, pool, dir, mode, size);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sbpr), sbpr_pl);
+}
+
+static int mlxsw_sp_sb_cm_write(struct mlxsw_sp *mlxsw_sp, u8 local_port,
+				u8 pg_buff, enum mlxsw_reg_sbxx_dir dir,
+				u32 min_buff, u32 max_buff, u8 pool)
+{
+	char sbcm_pl[MLXSW_REG_SBCM_LEN];
+
+	mlxsw_reg_sbcm_pack(sbcm_pl, local_port, pg_buff, dir,
+			    min_buff, max_buff, pool);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sbcm), sbcm_pl);
+}
+
+static int mlxsw_sp_sb_pm_write(struct mlxsw_sp *mlxsw_sp, u8 local_port,
+				u8 pool, enum mlxsw_reg_sbxx_dir dir,
+				u32 min_buff, u32 max_buff)
+{
+	char sbpm_pl[MLXSW_REG_SBPM_LEN];
+
+	mlxsw_reg_sbpm_pack(sbpm_pl, local_port, pool, dir, min_buff, max_buff);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sbpm), sbpm_pl);
+}
+
 struct mlxsw_sp_pb {
 	u8 index;
 	u16 size;
@@ -151,7 +182,6 @@ static const struct mlxsw_sp_sb_pool mlxsw_sp_sb_pools[] = {
 
 static int mlxsw_sp_sb_pools_init(struct mlxsw_sp *mlxsw_sp)
 {
-	char sbpr_pl[MLXSW_REG_SBPR_LEN];
 	int i;
 	int err;
 
@@ -159,9 +189,8 @@ static int mlxsw_sp_sb_pools_init(struct mlxsw_sp *mlxsw_sp)
 		const struct mlxsw_sp_sb_pool *pool;
 
 		pool = &mlxsw_sp_sb_pools[i];
-		mlxsw_reg_sbpr_pack(sbpr_pl, pool->pool, pool->dir,
-				    pool->mode, pool->size);
-		err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sbpr), sbpr_pl);
+		err = mlxsw_sp_sb_pr_write(mlxsw_sp, pool->pool, pool->dir,
+					   pool->mode, pool->size);
 		if (err)
 			return err;
 	}
@@ -272,7 +301,6 @@ static int mlxsw_sp_sb_cms_init(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 				const struct mlxsw_sp_sb_cm *cms,
 				size_t cms_len)
 {
-	char sbcm_pl[MLXSW_REG_SBCM_LEN];
 	int i;
 	int err;
 
@@ -280,9 +308,9 @@ static int mlxsw_sp_sb_cms_init(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 		const struct mlxsw_sp_sb_cm *cm;
 
 		cm = &cms[i];
-		mlxsw_reg_sbcm_pack(sbcm_pl, local_port, cm->u.pg, cm->dir,
-				    cm->min_buff, cm->max_buff, cm->pool);
-		err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sbcm), sbcm_pl);
+		err = mlxsw_sp_sb_cm_write(mlxsw_sp, local_port, cm->u.pg,
+					   cm->dir, cm->min_buff,
+					   cm->max_buff, cm->pool);
 		if (err)
 			return err;
 	}
@@ -340,7 +368,6 @@ static const struct mlxsw_sp_sb_pm mlxsw_sp_sb_pms[] = {
 
 static int mlxsw_sp_port_sb_pms_init(struct mlxsw_sp_port *mlxsw_sp_port)
 {
-	char sbpm_pl[MLXSW_REG_SBPM_LEN];
 	int i;
 	int err;
 
@@ -348,11 +375,10 @@ static int mlxsw_sp_port_sb_pms_init(struct mlxsw_sp_port *mlxsw_sp_port)
 		const struct mlxsw_sp_sb_pm *pm;
 
 		pm = &mlxsw_sp_sb_pms[i];
-		mlxsw_reg_sbpm_pack(sbpm_pl, mlxsw_sp_port->local_port,
-				    pm->pool, pm->dir,
-				    pm->min_buff, pm->max_buff);
-		err = mlxsw_reg_write(mlxsw_sp_port->mlxsw_sp->core,
-				      MLXSW_REG(sbpm), sbpm_pl);
+		err = mlxsw_sp_sb_pm_write(mlxsw_sp_port->mlxsw_sp,
+					   mlxsw_sp_port->local_port,
+					   pm->pool, pm->dir,
+					   pm->min_buff, pm->max_buff);
 		if (err)
 			return err;
 	}
-- 
2.5.5
