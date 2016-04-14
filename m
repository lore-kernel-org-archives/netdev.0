From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 05/18] mlxsw: spectrum_buffers: Push out indexes and direction out of SB structs
Date: Thu, 14 Apr 2016 18:19:17 +0200
Message-ID: <1460650770-19382-6-git-send-email-jiri@resnulli.us>
References: <1460650770-19382-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	jhs@mojatatu.com, john.fastabend@gmail.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com, stephen@networkplumber.org,
	sfeldma@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:36488 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932235AbcDNQTl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 12:19:41 -0400
Received: by mail-wm0-f49.google.com with SMTP id v188so227618715wme.1
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2016 09:19:40 -0700 (PDT)
In-Reply-To: <1460650770-19382-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Structs are in arrays so use array index as pool/tc/prio index. With
that, there is need to maintain separate arrays for ingress and egress.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_buffers.c | 425 +++++++++++----------
 1 file changed, 221 insertions(+), 204 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
index ae60838..c326e58 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
@@ -73,27 +73,17 @@ static int mlxsw_sp_sb_pm_write(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sbpm), sbpm_pl);
 }
 
-struct mlxsw_sp_pb {
-	u8 index;
-	u16 size;
-};
-
-#define MLXSW_SP_PB(_index, _size)	\
-	{				\
-		.index = _index,	\
-		.size = _size,		\
-	}
-
-static const struct mlxsw_sp_pb mlxsw_sp_pbs[] = {
-	MLXSW_SP_PB(0, 2 * MLXSW_SP_BYTES_TO_CELLS(ETH_FRAME_LEN)),
-	MLXSW_SP_PB(1, 0),
-	MLXSW_SP_PB(2, 0),
-	MLXSW_SP_PB(3, 0),
-	MLXSW_SP_PB(4, 0),
-	MLXSW_SP_PB(5, 0),
-	MLXSW_SP_PB(6, 0),
-	MLXSW_SP_PB(7, 0),
-	MLXSW_SP_PB(9, 2 * MLXSW_SP_BYTES_TO_CELLS(MLXSW_PORT_MAX_MTU)),
+static const u16 mlxsw_sp_pbs[] = {
+	2 * MLXSW_SP_BYTES_TO_CELLS(ETH_FRAME_LEN),
+	0,
+	0,
+	0,
+	0,
+	0,
+	0,
+	0,
+	0, /* Unused */
+	2 * MLXSW_SP_BYTES_TO_CELLS(MLXSW_PORT_MAX_MTU),
 };
 
 #define MLXSW_SP_PBS_LEN ARRAY_SIZE(mlxsw_sp_pbs)
@@ -106,10 +96,9 @@ static int mlxsw_sp_port_pb_init(struct mlxsw_sp_port *mlxsw_sp_port)
 	mlxsw_reg_pbmc_pack(pbmc_pl, mlxsw_sp_port->local_port,
 			    0xffff, 0xffff / 2);
 	for (i = 0; i < MLXSW_SP_PBS_LEN; i++) {
-		const struct mlxsw_sp_pb *pb;
-
-		pb = &mlxsw_sp_pbs[i];
-		mlxsw_reg_pbmc_lossy_buffer_pack(pbmc_pl, pb->index, pb->size);
+		if (i == 8)
+			continue;
+		mlxsw_reg_pbmc_lossy_buffer_pack(pbmc_pl, i, mlxsw_sp_pbs[i]);
 	}
 	mlxsw_reg_pbmc_lossy_buffer_pack(pbmc_pl,
 					 MLXSW_REG_PBMC_PORT_SHARED_BUF_IDX, 0);
@@ -140,8 +129,6 @@ static int mlxsw_sp_port_headroom_init(struct mlxsw_sp_port *mlxsw_sp_port)
 }
 
 struct mlxsw_sp_sb_pool {
-	u8 pool;
-	enum mlxsw_reg_sbxx_dir dir;
 	enum mlxsw_reg_sbpr_mode mode;
 	u32 size;
 };
@@ -151,45 +138,46 @@ struct mlxsw_sp_sb_pool {
 #define MLXSW_SP_SB_POOL_EGRESS_SIZE				\
 	(14000000 - (8 * 1500 * MLXSW_PORT_MAX_PORTS))
 
-#define MLXSW_SP_SB_POOL(_pool, _dir, _mode, _size)		\
-	{							\
-		.pool = _pool,					\
-		.dir = _dir,					\
-		.mode = _mode,					\
-		.size = _size,					\
+#define MLXSW_SP_SB_POOL(_mode, _size)	\
+	{				\
+		.mode = _mode,		\
+		.size = _size,		\
 	}
 
-#define MLXSW_SP_SB_POOL_INGRESS(_pool, _size)			\
-	MLXSW_SP_SB_POOL(_pool, MLXSW_REG_SBXX_DIR_INGRESS,	\
-			 MLXSW_REG_SBPR_MODE_DYNAMIC, _size)
-
-#define MLXSW_SP_SB_POOL_EGRESS(_pool, _size)			\
-	MLXSW_SP_SB_POOL(_pool, MLXSW_REG_SBXX_DIR_EGRESS,	\
-			 MLXSW_REG_SBPR_MODE_DYNAMIC, _size)
-
-static const struct mlxsw_sp_sb_pool mlxsw_sp_sb_pools[] = {
-	MLXSW_SP_SB_POOL_INGRESS(0, MLXSW_SP_BYTES_TO_CELLS(MLXSW_SP_SB_POOL_INGRESS_SIZE)),
-	MLXSW_SP_SB_POOL_INGRESS(1, 0),
-	MLXSW_SP_SB_POOL_INGRESS(2, 0),
-	MLXSW_SP_SB_POOL_INGRESS(3, 0),
-	MLXSW_SP_SB_POOL_EGRESS(0, MLXSW_SP_BYTES_TO_CELLS(MLXSW_SP_SB_POOL_EGRESS_SIZE)),
-	MLXSW_SP_SB_POOL_EGRESS(1, 0),
-	MLXSW_SP_SB_POOL_EGRESS(2, 0),
-	MLXSW_SP_SB_POOL_EGRESS(2, MLXSW_SP_BYTES_TO_CELLS(MLXSW_SP_SB_POOL_EGRESS_SIZE)),
+static const struct mlxsw_sp_sb_pool mlxsw_sp_sb_pools_ingress[] = {
+	MLXSW_SP_SB_POOL(MLXSW_REG_SBPR_MODE_DYNAMIC,
+			 MLXSW_SP_BYTES_TO_CELLS(MLXSW_SP_SB_POOL_INGRESS_SIZE)),
+	MLXSW_SP_SB_POOL(MLXSW_REG_SBPR_MODE_DYNAMIC, 0),
+	MLXSW_SP_SB_POOL(MLXSW_REG_SBPR_MODE_DYNAMIC, 0),
+	MLXSW_SP_SB_POOL(MLXSW_REG_SBPR_MODE_DYNAMIC, 0),
 };
 
-#define MLXSW_SP_SB_POOLS_LEN ARRAY_SIZE(mlxsw_sp_sb_pools)
+#define MLXSW_SP_SB_POOLS_INGRESS_LEN ARRAY_SIZE(mlxsw_sp_sb_pools_ingress)
 
-static int mlxsw_sp_sb_pools_init(struct mlxsw_sp *mlxsw_sp)
+static const struct mlxsw_sp_sb_pool mlxsw_sp_sb_pools_egress[] = {
+	MLXSW_SP_SB_POOL(MLXSW_REG_SBPR_MODE_DYNAMIC,
+			 MLXSW_SP_BYTES_TO_CELLS(MLXSW_SP_SB_POOL_EGRESS_SIZE)),
+	MLXSW_SP_SB_POOL(MLXSW_REG_SBPR_MODE_DYNAMIC, 0),
+	MLXSW_SP_SB_POOL(MLXSW_REG_SBPR_MODE_DYNAMIC, 0),
+	MLXSW_SP_SB_POOL(MLXSW_REG_SBPR_MODE_DYNAMIC,
+			 MLXSW_SP_BYTES_TO_CELLS(MLXSW_SP_SB_POOL_EGRESS_SIZE)),
+};
+
+#define MLXSW_SP_SB_POOLS_EGRESS_LEN ARRAY_SIZE(mlxsw_sp_sb_pools_egress)
+
+static int __mlxsw_sp_sb_pools_init(struct mlxsw_sp *mlxsw_sp,
+				    enum mlxsw_reg_sbxx_dir dir,
+				    const struct mlxsw_sp_sb_pool *pools,
+				    size_t pools_len)
 {
 	int i;
 	int err;
 
-	for (i = 0; i < MLXSW_SP_SB_POOLS_LEN; i++) {
+	for (i = 0; i < pools_len; i++) {
 		const struct mlxsw_sp_sb_pool *pool;
 
-		pool = &mlxsw_sp_sb_pools[i];
-		err = mlxsw_sp_sb_pr_write(mlxsw_sp, pool->pool, pool->dir,
+		pool = &pools[i];
+		err = mlxsw_sp_sb_pr_write(mlxsw_sp, i, dir,
 					   pool->mode, pool->size);
 		if (err)
 			return err;
@@ -197,109 +185,114 @@ static int mlxsw_sp_sb_pools_init(struct mlxsw_sp *mlxsw_sp)
 	return 0;
 }
 
+static int mlxsw_sp_sb_pools_init(struct mlxsw_sp *mlxsw_sp)
+{
+	int err;
+
+	err = __mlxsw_sp_sb_pools_init(mlxsw_sp, MLXSW_REG_SBXX_DIR_INGRESS,
+				       mlxsw_sp_sb_pools_ingress,
+				       MLXSW_SP_SB_POOLS_INGRESS_LEN);
+	if (err)
+		return err;
+	return __mlxsw_sp_sb_pools_init(mlxsw_sp, MLXSW_REG_SBXX_DIR_EGRESS,
+					mlxsw_sp_sb_pools_egress,
+					MLXSW_SP_SB_POOLS_EGRESS_LEN);
+}
+
 struct mlxsw_sp_sb_cm {
-	union {
-		u8 pg;
-		u8 tc;
-	} u;
-	enum mlxsw_reg_sbxx_dir dir;
 	u32 min_buff;
 	u32 max_buff;
 	u8 pool;
 };
 
-#define MLXSW_SP_SB_CM(_pg_tc, _dir, _min_buff, _max_buff, _pool)	\
-	{								\
-		.u.pg = _pg_tc,						\
-		.dir = _dir,						\
-		.min_buff = _min_buff,					\
-		.max_buff = _max_buff,					\
-		.pool = _pool,						\
+#define MLXSW_SP_SB_CM(_min_buff, _max_buff, _pool)	\
+	{						\
+		.min_buff = _min_buff,			\
+		.max_buff = _max_buff,			\
+		.pool = _pool,				\
 	}
 
-#define MLXSW_SP_SB_CM_INGRESS(_pg, _min_buff, _max_buff)		\
-	MLXSW_SP_SB_CM(_pg, MLXSW_REG_SBXX_DIR_INGRESS,			\
-		       _min_buff, _max_buff, 0)
-
-#define MLXSW_SP_SB_CM_EGRESS(_tc, _min_buff, _max_buff)		\
-	MLXSW_SP_SB_CM(_tc, MLXSW_REG_SBXX_DIR_EGRESS,			\
-		       _min_buff, _max_buff, 0)
-
-#define MLXSW_SP_CPU_PORT_SB_CM_EGRESS(_tc)				\
-	MLXSW_SP_SB_CM(_tc, MLXSW_REG_SBXX_DIR_EGRESS, 104, 2, 3)
-
-static const struct mlxsw_sp_sb_cm mlxsw_sp_sb_cms[] = {
-	MLXSW_SP_SB_CM_INGRESS(0, MLXSW_SP_BYTES_TO_CELLS(10000), 8),
-	MLXSW_SP_SB_CM_INGRESS(1, 0, 0),
-	MLXSW_SP_SB_CM_INGRESS(2, 0, 0),
-	MLXSW_SP_SB_CM_INGRESS(3, 0, 0),
-	MLXSW_SP_SB_CM_INGRESS(4, 0, 0),
-	MLXSW_SP_SB_CM_INGRESS(5, 0, 0),
-	MLXSW_SP_SB_CM_INGRESS(6, 0, 0),
-	MLXSW_SP_SB_CM_INGRESS(7, 0, 0),
-	MLXSW_SP_SB_CM_INGRESS(9, MLXSW_SP_BYTES_TO_CELLS(20000), 0xff),
-	MLXSW_SP_SB_CM_EGRESS(0, MLXSW_SP_BYTES_TO_CELLS(1500), 9),
-	MLXSW_SP_SB_CM_EGRESS(1, MLXSW_SP_BYTES_TO_CELLS(1500), 9),
-	MLXSW_SP_SB_CM_EGRESS(2, MLXSW_SP_BYTES_TO_CELLS(1500), 9),
-	MLXSW_SP_SB_CM_EGRESS(3, MLXSW_SP_BYTES_TO_CELLS(1500), 9),
-	MLXSW_SP_SB_CM_EGRESS(4, MLXSW_SP_BYTES_TO_CELLS(1500), 9),
-	MLXSW_SP_SB_CM_EGRESS(5, MLXSW_SP_BYTES_TO_CELLS(1500), 9),
-	MLXSW_SP_SB_CM_EGRESS(6, MLXSW_SP_BYTES_TO_CELLS(1500), 9),
-	MLXSW_SP_SB_CM_EGRESS(7, MLXSW_SP_BYTES_TO_CELLS(1500), 9),
-	MLXSW_SP_SB_CM_EGRESS(8, 0, 0),
-	MLXSW_SP_SB_CM_EGRESS(9, 0, 0),
-	MLXSW_SP_SB_CM_EGRESS(10, 0, 0),
-	MLXSW_SP_SB_CM_EGRESS(11, 0, 0),
-	MLXSW_SP_SB_CM_EGRESS(12, 0, 0),
-	MLXSW_SP_SB_CM_EGRESS(13, 0, 0),
-	MLXSW_SP_SB_CM_EGRESS(14, 0, 0),
-	MLXSW_SP_SB_CM_EGRESS(15, 0, 0),
-	MLXSW_SP_SB_CM_EGRESS(16, 1, 0xff),
+static const struct mlxsw_sp_sb_cm mlxsw_sp_sb_cms_ingress[] = {
+	MLXSW_SP_SB_CM(MLXSW_SP_BYTES_TO_CELLS(10000), 8, 0),
+	MLXSW_SP_SB_CM(0, 0, 0),
+	MLXSW_SP_SB_CM(0, 0, 0),
+	MLXSW_SP_SB_CM(0, 0, 0),
+	MLXSW_SP_SB_CM(0, 0, 0),
+	MLXSW_SP_SB_CM(0, 0, 0),
+	MLXSW_SP_SB_CM(0, 0, 0),
+	MLXSW_SP_SB_CM(0, 0, 0),
+	MLXSW_SP_SB_CM(0, 0, 0), /* dummy, this PG does not exist */
+	MLXSW_SP_SB_CM(MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
 };
 
-#define MLXSW_SP_SB_CMS_LEN ARRAY_SIZE(mlxsw_sp_sb_cms)
+#define MLXSW_SP_SB_CMS_INGRESS_LEN ARRAY_SIZE(mlxsw_sp_sb_cms_ingress)
+
+static const struct mlxsw_sp_sb_cm mlxsw_sp_sb_cms_egress[] = {
+	MLXSW_SP_SB_CM(MLXSW_SP_BYTES_TO_CELLS(1500), 9, 0),
+	MLXSW_SP_SB_CM(MLXSW_SP_BYTES_TO_CELLS(1500), 9, 0),
+	MLXSW_SP_SB_CM(MLXSW_SP_BYTES_TO_CELLS(1500), 9, 0),
+	MLXSW_SP_SB_CM(MLXSW_SP_BYTES_TO_CELLS(1500), 9, 0),
+	MLXSW_SP_SB_CM(MLXSW_SP_BYTES_TO_CELLS(1500), 9, 0),
+	MLXSW_SP_SB_CM(MLXSW_SP_BYTES_TO_CELLS(1500), 9, 0),
+	MLXSW_SP_SB_CM(MLXSW_SP_BYTES_TO_CELLS(1500), 9, 0),
+	MLXSW_SP_SB_CM(MLXSW_SP_BYTES_TO_CELLS(1500), 9, 0),
+	MLXSW_SP_SB_CM(0, 0, 0),
+	MLXSW_SP_SB_CM(0, 0, 0),
+	MLXSW_SP_SB_CM(0, 0, 0),
+	MLXSW_SP_SB_CM(0, 0, 0),
+	MLXSW_SP_SB_CM(0, 0, 0),
+	MLXSW_SP_SB_CM(0, 0, 0),
+	MLXSW_SP_SB_CM(0, 0, 0),
+	MLXSW_SP_SB_CM(0, 0, 0),
+	MLXSW_SP_SB_CM(1, 0xff, 0),
+};
+
+#define MLXSW_SP_SB_CMS_EGRESS_LEN ARRAY_SIZE(mlxsw_sp_sb_cms_egress)
+
+#define MLXSW_SP_CPU_PORT_SB_CM MLXSW_SP_SB_CM(104, 2, 3)
 
 static const struct mlxsw_sp_sb_cm mlxsw_sp_cpu_port_sb_cms[] = {
-	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(0),
-	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(1),
-	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(2),
-	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(3),
-	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(4),
-	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(5),
-	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(6),
-	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(7),
-	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(8),
-	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(9),
-	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(10),
-	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(11),
-	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(12),
-	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(13),
-	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(14),
-	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(15),
-	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(16),
-	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(17),
-	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(18),
-	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(19),
-	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(20),
-	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(21),
-	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(22),
-	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(23),
-	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(24),
-	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(25),
-	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(26),
-	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(27),
-	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(28),
-	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(29),
-	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(30),
-	MLXSW_SP_CPU_PORT_SB_CM_EGRESS(31),
+	MLXSW_SP_CPU_PORT_SB_CM,
+	MLXSW_SP_CPU_PORT_SB_CM,
+	MLXSW_SP_CPU_PORT_SB_CM,
+	MLXSW_SP_CPU_PORT_SB_CM,
+	MLXSW_SP_CPU_PORT_SB_CM,
+	MLXSW_SP_CPU_PORT_SB_CM,
+	MLXSW_SP_CPU_PORT_SB_CM,
+	MLXSW_SP_CPU_PORT_SB_CM,
+	MLXSW_SP_CPU_PORT_SB_CM,
+	MLXSW_SP_CPU_PORT_SB_CM,
+	MLXSW_SP_CPU_PORT_SB_CM,
+	MLXSW_SP_CPU_PORT_SB_CM,
+	MLXSW_SP_CPU_PORT_SB_CM,
+	MLXSW_SP_CPU_PORT_SB_CM,
+	MLXSW_SP_CPU_PORT_SB_CM,
+	MLXSW_SP_CPU_PORT_SB_CM,
+	MLXSW_SP_CPU_PORT_SB_CM,
+	MLXSW_SP_CPU_PORT_SB_CM,
+	MLXSW_SP_CPU_PORT_SB_CM,
+	MLXSW_SP_CPU_PORT_SB_CM,
+	MLXSW_SP_CPU_PORT_SB_CM,
+	MLXSW_SP_CPU_PORT_SB_CM,
+	MLXSW_SP_CPU_PORT_SB_CM,
+	MLXSW_SP_CPU_PORT_SB_CM,
+	MLXSW_SP_CPU_PORT_SB_CM,
+	MLXSW_SP_CPU_PORT_SB_CM,
+	MLXSW_SP_CPU_PORT_SB_CM,
+	MLXSW_SP_CPU_PORT_SB_CM,
+	MLXSW_SP_CPU_PORT_SB_CM,
+	MLXSW_SP_CPU_PORT_SB_CM,
+	MLXSW_SP_CPU_PORT_SB_CM,
+	MLXSW_SP_CPU_PORT_SB_CM,
 };
 
 #define MLXSW_SP_CPU_PORT_SB_MCS_LEN \
 	ARRAY_SIZE(mlxsw_sp_cpu_port_sb_cms)
 
-static int mlxsw_sp_sb_cms_init(struct mlxsw_sp *mlxsw_sp, u8 local_port,
-				const struct mlxsw_sp_sb_cm *cms,
-				size_t cms_len)
+static int __mlxsw_sp_sb_cms_init(struct mlxsw_sp *mlxsw_sp, u8 local_port,
+				  enum mlxsw_reg_sbxx_dir dir,
+				  const struct mlxsw_sp_sb_cm *cms,
+				  size_t cms_len)
 {
 	int i;
 	int err;
@@ -307,10 +300,12 @@ static int mlxsw_sp_sb_cms_init(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 	for (i = 0; i < cms_len; i++) {
 		const struct mlxsw_sp_sb_cm *cm;
 
+		if (i == 8 && dir == MLXSW_REG_SBXX_DIR_INGRESS)
+			continue; /* PG number 8 does not exist, skip it */
 		cm = &cms[i];
-		err = mlxsw_sp_sb_cm_write(mlxsw_sp, local_port, cm->u.pg,
-					   cm->dir, cm->min_buff,
-					   cm->max_buff, cm->pool);
+		err = mlxsw_sp_sb_cm_write(mlxsw_sp, local_port, i, dir,
+					   cm->min_buff, cm->max_buff,
+					   cm->pool);
 		if (err)
 			return err;
 	}
@@ -319,65 +314,71 @@ static int mlxsw_sp_sb_cms_init(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 
 static int mlxsw_sp_port_sb_cms_init(struct mlxsw_sp_port *mlxsw_sp_port)
 {
-	return mlxsw_sp_sb_cms_init(mlxsw_sp_port->mlxsw_sp,
-				    mlxsw_sp_port->local_port, mlxsw_sp_sb_cms,
-				    MLXSW_SP_SB_CMS_LEN);
+	int err;
+
+	err = __mlxsw_sp_sb_cms_init(mlxsw_sp_port->mlxsw_sp,
+				     mlxsw_sp_port->local_port,
+				     MLXSW_REG_SBXX_DIR_INGRESS,
+				     mlxsw_sp_sb_cms_ingress,
+				     MLXSW_SP_SB_CMS_INGRESS_LEN);
+	if (err)
+		return err;
+	return __mlxsw_sp_sb_cms_init(mlxsw_sp_port->mlxsw_sp,
+				      mlxsw_sp_port->local_port,
+				      MLXSW_REG_SBXX_DIR_EGRESS,
+				      mlxsw_sp_sb_cms_egress,
+				      MLXSW_SP_SB_CMS_EGRESS_LEN);
 }
 
 static int mlxsw_sp_cpu_port_sb_cms_init(struct mlxsw_sp *mlxsw_sp)
 {
-	return mlxsw_sp_sb_cms_init(mlxsw_sp, 0, mlxsw_sp_cpu_port_sb_cms,
-				    MLXSW_SP_CPU_PORT_SB_MCS_LEN);
+	return __mlxsw_sp_sb_cms_init(mlxsw_sp, 0, MLXSW_REG_SBXX_DIR_EGRESS,
+				      mlxsw_sp_cpu_port_sb_cms,
+				      MLXSW_SP_CPU_PORT_SB_MCS_LEN);
 }
 
 struct mlxsw_sp_sb_pm {
-	u8 pool;
-	enum mlxsw_reg_sbxx_dir dir;
 	u32 min_buff;
 	u32 max_buff;
 };
 
-#define MLXSW_SP_SB_PM(_pool, _dir, _min_buff, _max_buff)	\
-	{							\
-		.pool = _pool,					\
-		.dir = _dir,					\
-		.min_buff = _min_buff,				\
-		.max_buff = _max_buff,				\
+#define MLXSW_SP_SB_PM(_min_buff, _max_buff)	\
+	{					\
+		.min_buff = _min_buff,		\
+		.max_buff = _max_buff,		\
 	}
 
-#define MLXSW_SP_SB_PM_INGRESS(_pool, _min_buff, _max_buff)	\
-	MLXSW_SP_SB_PM(_pool, MLXSW_REG_SBXX_DIR_INGRESS,	\
-		       _min_buff, _max_buff)
-
-#define MLXSW_SP_SB_PM_EGRESS(_pool, _min_buff, _max_buff)	\
-	MLXSW_SP_SB_PM(_pool, MLXSW_REG_SBXX_DIR_EGRESS,	\
-		       _min_buff, _max_buff)
-
-static const struct mlxsw_sp_sb_pm mlxsw_sp_sb_pms[] = {
-	MLXSW_SP_SB_PM_INGRESS(0, 0, 0xff),
-	MLXSW_SP_SB_PM_INGRESS(1, 0, 0),
-	MLXSW_SP_SB_PM_INGRESS(2, 0, 0),
-	MLXSW_SP_SB_PM_INGRESS(3, 0, 0),
-	MLXSW_SP_SB_PM_EGRESS(0, 0, 7),
-	MLXSW_SP_SB_PM_EGRESS(1, 0, 0),
-	MLXSW_SP_SB_PM_EGRESS(2, 0, 0),
-	MLXSW_SP_SB_PM_EGRESS(3, 0, 0),
+static const struct mlxsw_sp_sb_pm mlxsw_sp_sb_pms_ingress[] = {
+	MLXSW_SP_SB_PM(0, 0xff),
+	MLXSW_SP_SB_PM(0, 0),
+	MLXSW_SP_SB_PM(0, 0),
+	MLXSW_SP_SB_PM(0, 0),
 };
 
-#define MLXSW_SP_SB_PMS_LEN ARRAY_SIZE(mlxsw_sp_sb_pms)
+#define MLXSW_SP_SB_PMS_INGRESS_LEN ARRAY_SIZE(mlxsw_sp_sb_pms_ingress)
 
-static int mlxsw_sp_port_sb_pms_init(struct mlxsw_sp_port *mlxsw_sp_port)
+static const struct mlxsw_sp_sb_pm mlxsw_sp_sb_pms_egress[] = {
+	MLXSW_SP_SB_PM(0, 7),
+	MLXSW_SP_SB_PM(0, 0),
+	MLXSW_SP_SB_PM(0, 0),
+	MLXSW_SP_SB_PM(0, 0),
+};
+
+#define MLXSW_SP_SB_PMS_EGRESS_LEN ARRAY_SIZE(mlxsw_sp_sb_pms_egress)
+
+static int __mlxsw_sp_port_sb_pms_init(struct mlxsw_sp *mlxsw_sp, u8 local_port,
+				       enum mlxsw_reg_sbxx_dir dir,
+				       const struct mlxsw_sp_sb_pm *pms,
+				       size_t pms_len)
 {
 	int i;
 	int err;
 
-	for (i = 0; i < MLXSW_SP_SB_PMS_LEN; i++) {
+	for (i = 0; i < pms_len; i++) {
 		const struct mlxsw_sp_sb_pm *pm;
 
-		pm = &mlxsw_sp_sb_pms[i];
-		err = mlxsw_sp_sb_pm_write(mlxsw_sp_port->mlxsw_sp,
-					   mlxsw_sp_port->local_port,
-					   pm->pool, pm->dir,
+		pm = &pms[i];
+		err = mlxsw_sp_sb_pm_write(mlxsw_sp, local_port, i, dir,
 					   pm->min_buff, pm->max_buff);
 		if (err)
 			return err;
@@ -385,37 +386,53 @@ static int mlxsw_sp_port_sb_pms_init(struct mlxsw_sp_port *mlxsw_sp_port)
 	return 0;
 }
 
+static int mlxsw_sp_port_sb_pms_init(struct mlxsw_sp_port *mlxsw_sp_port)
+{
+	int err;
+
+	err = __mlxsw_sp_port_sb_pms_init(mlxsw_sp_port->mlxsw_sp,
+					  mlxsw_sp_port->local_port,
+					  MLXSW_REG_SBXX_DIR_INGRESS,
+					  mlxsw_sp_sb_pms_ingress,
+					  MLXSW_SP_SB_PMS_INGRESS_LEN);
+	if (err)
+		return err;
+	return __mlxsw_sp_port_sb_pms_init(mlxsw_sp_port->mlxsw_sp,
+					   mlxsw_sp_port->local_port,
+					   MLXSW_REG_SBXX_DIR_EGRESS,
+					   mlxsw_sp_sb_pms_egress,
+					   MLXSW_SP_SB_PMS_EGRESS_LEN);
+}
+
 struct mlxsw_sp_sb_mm {
-	u8 prio;
 	u32 min_buff;
 	u32 max_buff;
 	u8 pool;
 };
 
-#define MLXSW_SP_SB_MM(_prio, _min_buff, _max_buff, _pool)	\
-	{							\
-		.prio = _prio,					\
-		.min_buff = _min_buff,				\
-		.max_buff = _max_buff,				\
-		.pool = _pool,					\
+#define MLXSW_SP_SB_MM(_min_buff, _max_buff, _pool)	\
+	{						\
+		.min_buff = _min_buff,			\
+		.max_buff = _max_buff,			\
+		.pool = _pool,				\
 	}
 
 static const struct mlxsw_sp_sb_mm mlxsw_sp_sb_mms[] = {
-	MLXSW_SP_SB_MM(0, MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
-	MLXSW_SP_SB_MM(1, MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
-	MLXSW_SP_SB_MM(2, MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
-	MLXSW_SP_SB_MM(3, MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
-	MLXSW_SP_SB_MM(4, MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
-	MLXSW_SP_SB_MM(5, MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
-	MLXSW_SP_SB_MM(6, MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
-	MLXSW_SP_SB_MM(7, MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
-	MLXSW_SP_SB_MM(8, MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
-	MLXSW_SP_SB_MM(9, MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
-	MLXSW_SP_SB_MM(10, MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
-	MLXSW_SP_SB_MM(11, MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
-	MLXSW_SP_SB_MM(12, MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
-	MLXSW_SP_SB_MM(13, MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
-	MLXSW_SP_SB_MM(14, MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
+	MLXSW_SP_SB_MM(MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
+	MLXSW_SP_SB_MM(MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
+	MLXSW_SP_SB_MM(MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
+	MLXSW_SP_SB_MM(MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
+	MLXSW_SP_SB_MM(MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
+	MLXSW_SP_SB_MM(MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
+	MLXSW_SP_SB_MM(MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
+	MLXSW_SP_SB_MM(MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
+	MLXSW_SP_SB_MM(MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
+	MLXSW_SP_SB_MM(MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
+	MLXSW_SP_SB_MM(MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
+	MLXSW_SP_SB_MM(MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
+	MLXSW_SP_SB_MM(MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
+	MLXSW_SP_SB_MM(MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
+	MLXSW_SP_SB_MM(MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
 };
 
 #define MLXSW_SP_SB_MMS_LEN ARRAY_SIZE(mlxsw_sp_sb_mms)
@@ -430,7 +447,7 @@ static int mlxsw_sp_sb_mms_init(struct mlxsw_sp *mlxsw_sp)
 		const struct mlxsw_sp_sb_mm *mc;
 
 		mc = &mlxsw_sp_sb_mms[i];
-		mlxsw_reg_sbmm_pack(sbmm_pl, mc->prio, mc->min_buff,
+		mlxsw_reg_sbmm_pack(sbmm_pl, i, mc->min_buff,
 				    mc->max_buff, mc->pool);
 		err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sbmm), sbmm_pl);
 		if (err)
-- 
2.5.5
