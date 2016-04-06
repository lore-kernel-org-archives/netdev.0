From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 03/17] mlxsw: spectrum: Add bytes to cells helper
Date: Wed,  6 Apr 2016 17:10:02 +0200
Message-ID: <1459955416-23786-4-git-send-email-jiri@resnulli.us>
References: <1459955416-23786-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33345 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751511AbcDFPKZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 11:10:25 -0400
Received: by mail-wm0-f67.google.com with SMTP id i204so14156409wmd.0
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 08:10:24 -0700 (PDT)
In-Reply-To: <1459955416-23786-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Buffers in the switch store packets in units called buffer cells. Add a
helper to convert from bytes to cells, so that the actual number of
cells required (result is round up) is returned.

Also, drop the SB (shared buffer) acronym from the BYTES_PER_CELL macro,
as this unit is also used in the ports' buffers and not only the
switch's shared buffer.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  4 ++
 .../net/ethernet/mellanox/mlxsw/spectrum_buffers.c | 64 ++++++++++------------
 2 files changed, 34 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index d58ab0c..84dddd4 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -62,6 +62,10 @@
 
 #define MLXSW_SP_PORT_BASE_SPEED 25000	/* Mb/s */
 
+#define MLXSW_SP_BYTES_PER_CELL 96
+
+#define MLXSW_SP_BYTES_TO_CELLS(b) DIV_ROUND_UP(b, MLXSW_SP_BYTES_PER_CELL)
+
 struct mlxsw_sp_port;
 
 struct mlxsw_sp_upper {
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
index c3a275b..dadb6e1 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
@@ -105,8 +105,6 @@ static int mlxsw_sp_port_headroom_init(struct mlxsw_sp_port *mlxsw_sp_port)
 	return mlxsw_sp_port_pb_prio_init(mlxsw_sp_port);
 }
 
-#define MLXSW_SP_SB_BYTES_PER_CELL 96
-
 struct mlxsw_sp_sb_pool {
 	u8 pool;
 	enum mlxsw_reg_sbpr_dir dir;
@@ -115,11 +113,9 @@ struct mlxsw_sp_sb_pool {
 };
 
 #define MLXSW_SP_SB_POOL_INGRESS_SIZE				\
-	((15000000 - (2 * 20000 * MLXSW_PORT_MAX_PORTS)) /	\
-	 MLXSW_SP_SB_BYTES_PER_CELL)
+	(15000000 - (2 * 20000 * MLXSW_PORT_MAX_PORTS))
 #define MLXSW_SP_SB_POOL_EGRESS_SIZE				\
-	((14000000 - (8 * 1500 * MLXSW_PORT_MAX_PORTS)) /	\
-	 MLXSW_SP_SB_BYTES_PER_CELL)
+	(14000000 - (8 * 1500 * MLXSW_PORT_MAX_PORTS))
 
 #define MLXSW_SP_SB_POOL(_pool, _dir, _mode, _size)		\
 	{							\
@@ -138,14 +134,14 @@ struct mlxsw_sp_sb_pool {
 			 MLXSW_REG_SBPR_MODE_DYNAMIC, _size)
 
 static const struct mlxsw_sp_sb_pool mlxsw_sp_sb_pools[] = {
-	MLXSW_SP_SB_POOL_INGRESS(0, MLXSW_SP_SB_POOL_INGRESS_SIZE),
+	MLXSW_SP_SB_POOL_INGRESS(0, MLXSW_SP_BYTES_TO_CELLS(MLXSW_SP_SB_POOL_INGRESS_SIZE)),
 	MLXSW_SP_SB_POOL_INGRESS(1, 0),
 	MLXSW_SP_SB_POOL_INGRESS(2, 0),
 	MLXSW_SP_SB_POOL_INGRESS(3, 0),
-	MLXSW_SP_SB_POOL_EGRESS(0, MLXSW_SP_SB_POOL_EGRESS_SIZE),
+	MLXSW_SP_SB_POOL_EGRESS(0, MLXSW_SP_BYTES_TO_CELLS(MLXSW_SP_SB_POOL_EGRESS_SIZE)),
 	MLXSW_SP_SB_POOL_EGRESS(1, 0),
 	MLXSW_SP_SB_POOL_EGRESS(2, 0),
-	MLXSW_SP_SB_POOL_EGRESS(2, MLXSW_SP_SB_POOL_EGRESS_SIZE),
+	MLXSW_SP_SB_POOL_EGRESS(2, MLXSW_SP_BYTES_TO_CELLS(MLXSW_SP_SB_POOL_EGRESS_SIZE)),
 };
 
 #define MLXSW_SP_SB_POOLS_LEN ARRAY_SIZE(mlxsw_sp_sb_pools)
@@ -201,7 +197,7 @@ struct mlxsw_sp_sb_cm {
 	MLXSW_SP_SB_CM(_tc, MLXSW_REG_SBCM_DIR_EGRESS, 104, 2, 3)
 
 static const struct mlxsw_sp_sb_cm mlxsw_sp_sb_cms[] = {
-	MLXSW_SP_SB_CM_INGRESS(0, 10000 / MLXSW_SP_SB_BYTES_PER_CELL, 8),
+	MLXSW_SP_SB_CM_INGRESS(0, MLXSW_SP_BYTES_TO_CELLS(10000), 8),
 	MLXSW_SP_SB_CM_INGRESS(1, 0, 0),
 	MLXSW_SP_SB_CM_INGRESS(2, 0, 0),
 	MLXSW_SP_SB_CM_INGRESS(3, 0, 0),
@@ -209,15 +205,15 @@ static const struct mlxsw_sp_sb_cm mlxsw_sp_sb_cms[] = {
 	MLXSW_SP_SB_CM_INGRESS(5, 0, 0),
 	MLXSW_SP_SB_CM_INGRESS(6, 0, 0),
 	MLXSW_SP_SB_CM_INGRESS(7, 0, 0),
-	MLXSW_SP_SB_CM_INGRESS(9, 20000 / MLXSW_SP_SB_BYTES_PER_CELL, 0xff),
-	MLXSW_SP_SB_CM_EGRESS(0, 1500 / MLXSW_SP_SB_BYTES_PER_CELL, 9),
-	MLXSW_SP_SB_CM_EGRESS(1, 1500 / MLXSW_SP_SB_BYTES_PER_CELL, 9),
-	MLXSW_SP_SB_CM_EGRESS(2, 1500 / MLXSW_SP_SB_BYTES_PER_CELL, 9),
-	MLXSW_SP_SB_CM_EGRESS(3, 1500 / MLXSW_SP_SB_BYTES_PER_CELL, 9),
-	MLXSW_SP_SB_CM_EGRESS(4, 1500 / MLXSW_SP_SB_BYTES_PER_CELL, 9),
-	MLXSW_SP_SB_CM_EGRESS(5, 1500 / MLXSW_SP_SB_BYTES_PER_CELL, 9),
-	MLXSW_SP_SB_CM_EGRESS(6, 1500 / MLXSW_SP_SB_BYTES_PER_CELL, 9),
-	MLXSW_SP_SB_CM_EGRESS(7, 1500 / MLXSW_SP_SB_BYTES_PER_CELL, 9),
+	MLXSW_SP_SB_CM_INGRESS(9, MLXSW_SP_BYTES_TO_CELLS(20000), 0xff),
+	MLXSW_SP_SB_CM_EGRESS(0, MLXSW_SP_BYTES_TO_CELLS(1500), 9),
+	MLXSW_SP_SB_CM_EGRESS(1, MLXSW_SP_BYTES_TO_CELLS(1500), 9),
+	MLXSW_SP_SB_CM_EGRESS(2, MLXSW_SP_BYTES_TO_CELLS(1500), 9),
+	MLXSW_SP_SB_CM_EGRESS(3, MLXSW_SP_BYTES_TO_CELLS(1500), 9),
+	MLXSW_SP_SB_CM_EGRESS(4, MLXSW_SP_BYTES_TO_CELLS(1500), 9),
+	MLXSW_SP_SB_CM_EGRESS(5, MLXSW_SP_BYTES_TO_CELLS(1500), 9),
+	MLXSW_SP_SB_CM_EGRESS(6, MLXSW_SP_BYTES_TO_CELLS(1500), 9),
+	MLXSW_SP_SB_CM_EGRESS(7, MLXSW_SP_BYTES_TO_CELLS(1500), 9),
 	MLXSW_SP_SB_CM_EGRESS(8, 0, 0),
 	MLXSW_SP_SB_CM_EGRESS(9, 0, 0),
 	MLXSW_SP_SB_CM_EGRESS(10, 0, 0),
@@ -376,21 +372,21 @@ struct mlxsw_sp_sb_mm {
 	}
 
 static const struct mlxsw_sp_sb_mm mlxsw_sp_sb_mms[] = {
-	MLXSW_SP_SB_MM(0, 20000 / MLXSW_SP_SB_BYTES_PER_CELL, 0xff, 0),
-	MLXSW_SP_SB_MM(1, 20000 / MLXSW_SP_SB_BYTES_PER_CELL, 0xff, 0),
-	MLXSW_SP_SB_MM(2, 20000 / MLXSW_SP_SB_BYTES_PER_CELL, 0xff, 0),
-	MLXSW_SP_SB_MM(3, 20000 / MLXSW_SP_SB_BYTES_PER_CELL, 0xff, 0),
-	MLXSW_SP_SB_MM(4, 20000 / MLXSW_SP_SB_BYTES_PER_CELL, 0xff, 0),
-	MLXSW_SP_SB_MM(5, 20000 / MLXSW_SP_SB_BYTES_PER_CELL, 0xff, 0),
-	MLXSW_SP_SB_MM(6, 20000 / MLXSW_SP_SB_BYTES_PER_CELL, 0xff, 0),
-	MLXSW_SP_SB_MM(7, 20000 / MLXSW_SP_SB_BYTES_PER_CELL, 0xff, 0),
-	MLXSW_SP_SB_MM(8, 20000 / MLXSW_SP_SB_BYTES_PER_CELL, 0xff, 0),
-	MLXSW_SP_SB_MM(9, 20000 / MLXSW_SP_SB_BYTES_PER_CELL, 0xff, 0),
-	MLXSW_SP_SB_MM(10, 20000 / MLXSW_SP_SB_BYTES_PER_CELL, 0xff, 0),
-	MLXSW_SP_SB_MM(11, 20000 / MLXSW_SP_SB_BYTES_PER_CELL, 0xff, 0),
-	MLXSW_SP_SB_MM(12, 20000 / MLXSW_SP_SB_BYTES_PER_CELL, 0xff, 0),
-	MLXSW_SP_SB_MM(13, 20000 / MLXSW_SP_SB_BYTES_PER_CELL, 0xff, 0),
-	MLXSW_SP_SB_MM(14, 20000 / MLXSW_SP_SB_BYTES_PER_CELL, 0xff, 0),
+	MLXSW_SP_SB_MM(0, MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
+	MLXSW_SP_SB_MM(1, MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
+	MLXSW_SP_SB_MM(2, MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
+	MLXSW_SP_SB_MM(3, MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
+	MLXSW_SP_SB_MM(4, MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
+	MLXSW_SP_SB_MM(5, MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
+	MLXSW_SP_SB_MM(6, MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
+	MLXSW_SP_SB_MM(7, MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
+	MLXSW_SP_SB_MM(8, MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
+	MLXSW_SP_SB_MM(9, MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
+	MLXSW_SP_SB_MM(10, MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
+	MLXSW_SP_SB_MM(11, MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
+	MLXSW_SP_SB_MM(12, MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
+	MLXSW_SP_SB_MM(13, MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
+	MLXSW_SP_SB_MM(14, MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
 };
 
 #define MLXSW_SP_SB_MMS_LEN ARRAY_SIZE(mlxsw_sp_sb_mms)
-- 
2.5.5
