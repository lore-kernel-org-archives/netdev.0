From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 09/13] mlxsw: spectrum_buffers: Push out shared buffer register writes
Date: Thu, 17 Mar 2016 18:13:49 +0100
Message-ID: <1458234833-25836-10-git-send-email-jiri@resnulli.us>
References: <1458234833-25836-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	jhs@mojatatu.com, john.fastabend@gmail.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com, stephen@networkplumber.org,
	sfeldma@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34393 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031768AbcCQRON (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 13:14:13 -0400
Received: by mail-wm0-f68.google.com with SMTP id p65so489954wmp.1
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2016 10:14:07 -0700 (PDT)
In-Reply-To: <1458234833-25836-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Pushed them into helper functions.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_buffers.c | 54 ++++++++++++++++------
 1 file changed, 40 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
index fb5f787..cc40f4c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
@@ -40,6 +40,37 @@
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
@@ -129,7 +160,6 @@ static const struct mlxsw_sp_sb_pool mlxsw_sp_sb_pools[] = {
 
 static int mlxsw_sp_sb_pools_init(struct mlxsw_sp *mlxsw_sp)
 {
-	char sbpr_pl[MLXSW_REG_SBPR_LEN];
 	int i;
 	int err;
 
@@ -137,9 +167,8 @@ static int mlxsw_sp_sb_pools_init(struct mlxsw_sp *mlxsw_sp)
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
@@ -250,7 +279,6 @@ static int mlxsw_sp_sb_cms_init(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 				const struct mlxsw_sp_sb_cm *cms,
 				size_t cms_len)
 {
-	char sbcm_pl[MLXSW_REG_SBCM_LEN];
 	int i;
 	int err;
 
@@ -258,9 +286,9 @@ static int mlxsw_sp_sb_cms_init(struct mlxsw_sp *mlxsw_sp, u8 local_port,
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
@@ -318,7 +346,6 @@ static const struct mlxsw_sp_sb_pm mlxsw_sp_sb_pms[] = {
 
 static int mlxsw_sp_port_sb_pms_init(struct mlxsw_sp_port *mlxsw_sp_port)
 {
-	char sbpm_pl[MLXSW_REG_SBPM_LEN];
 	int i;
 	int err;
 
@@ -326,11 +353,10 @@ static int mlxsw_sp_port_sb_pms_init(struct mlxsw_sp_port *mlxsw_sp_port)
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
2.5.0
