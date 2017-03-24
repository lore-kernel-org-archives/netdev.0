From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 4/5] mlxsw: spectrum: Refactor port buffer configuration
Date: Fri, 24 Mar 2017 08:02:50 +0100
Message-ID: <1490338971-2687-5-git-send-email-jiri@resnulli.us>
References: <1490338971-2687-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:34186 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751503AbdCXHL4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 03:11:56 -0400
Received: by mail-wr0-f196.google.com with SMTP id y90so741075wrb.1
        for <netdev@vger.kernel.org>; Fri, 24 Mar 2017 00:11:55 -0700 (PDT)
In-Reply-To: <1490338971-2687-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The sizes and thresholds of the priority group (PG) buffers are
configured in cells, which represent a specific amount of bytes.

The cell size can vary in different devices, so it's better to query it
from the firmware than hard coding it.

Refactor the code dealing with this value into different functions, so
that it will be easier to make the conversion in the next patch.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 47 ++++++++++++++++++++------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h | 13 -------
 2 files changed, 37 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 7d0bd02..c440b35 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -800,19 +800,40 @@ static int mlxsw_sp_port_set_mac_address(struct net_device *dev, void *p)
 	return 0;
 }
 
-static void mlxsw_sp_pg_buf_pack(char *pbmc_pl, int pg_index, int mtu,
-				 bool pause_en, bool pfc_en, u16 delay)
+static u16 mlxsw_sp_pg_buf_threshold_get(int mtu)
 {
-	u16 pg_size = 2 * MLXSW_SP_BYTES_TO_CELLS(mtu);
+	return 2 * MLXSW_SP_BYTES_TO_CELLS(mtu);
+}
 
-	delay = pfc_en ? mlxsw_sp_pfc_delay_get(mtu, delay) :
-			 MLXSW_SP_PAUSE_DELAY;
+#define MLXSW_SP_CELL_FACTOR 2	/* 2 * cell_size / (IPG + cell_size + 1) */
+static u16 mlxsw_sp_pfc_delay_get(int mtu, u16 delay)
+{
+	delay = MLXSW_SP_BYTES_TO_CELLS(DIV_ROUND_UP(delay, BITS_PER_BYTE));
+	return MLXSW_SP_CELL_FACTOR * delay + MLXSW_SP_BYTES_TO_CELLS(mtu);
+}
 
-	if (pause_en || pfc_en)
-		mlxsw_reg_pbmc_lossless_buffer_pack(pbmc_pl, pg_index,
-						    pg_size + delay, pg_size);
+/* Maximum delay buffer needed in case of PAUSE frames, in cells.
+ * Assumes 100m cable and maximum MTU.
+ */
+#define MLXSW_SP_PAUSE_DELAY 612
+static u16 mlxsw_sp_pg_buf_delay_get(int mtu, u16 delay, bool pfc, bool pause)
+{
+	if (pfc)
+		return mlxsw_sp_pfc_delay_get(mtu, delay);
+	else if (pause)
+		return MLXSW_SP_PAUSE_DELAY;
 	else
-		mlxsw_reg_pbmc_lossy_buffer_pack(pbmc_pl, pg_index, pg_size);
+		return 0;
+}
+
+static void mlxsw_sp_pg_buf_pack(char *pbmc_pl, int index, u16 size, u16 thres,
+				 bool lossy)
+{
+	if (lossy)
+		mlxsw_reg_pbmc_lossy_buffer_pack(pbmc_pl, index, size);
+	else
+		mlxsw_reg_pbmc_lossless_buffer_pack(pbmc_pl, index, size,
+						    thres);
 }
 
 int __mlxsw_sp_port_headroom_set(struct mlxsw_sp_port *mlxsw_sp_port, int mtu,
@@ -833,6 +854,8 @@ int __mlxsw_sp_port_headroom_set(struct mlxsw_sp_port *mlxsw_sp_port, int mtu,
 	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++) {
 		bool configure = false;
 		bool pfc = false;
+		bool lossy;
+		u16 thres;
 
 		for (j = 0; j < IEEE_8021QAZ_MAX_TCS; j++) {
 			if (prio_tc[j] == i) {
@@ -844,7 +867,11 @@ int __mlxsw_sp_port_headroom_set(struct mlxsw_sp_port *mlxsw_sp_port, int mtu,
 
 		if (!configure)
 			continue;
-		mlxsw_sp_pg_buf_pack(pbmc_pl, i, mtu, pause_en, pfc, delay);
+
+		lossy = !(pfc || pause_en);
+		thres = mlxsw_sp_pg_buf_threshold_get(mtu);
+		delay = mlxsw_sp_pg_buf_delay_get(mtu, delay, pfc, pause_en);
+		mlxsw_sp_pg_buf_pack(pbmc_pl, i, thres + delay, thres, lossy);
 	}
 
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(pbmc), pbmc_pl);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 80a0d7d..958acac 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -73,19 +73,6 @@
 #define MLXSW_SP_KVD_LINEAR_SIZE 65536 /* entries */
 #define MLXSW_SP_KVD_GRANULARITY 128
 
-/* Maximum delay buffer needed in case of PAUSE frames, in cells.
- * Assumes 100m cable and maximum MTU.
- */
-#define MLXSW_SP_PAUSE_DELAY 612
-
-#define MLXSW_SP_CELL_FACTOR 2	/* 2 * cell_size / (IPG + cell_size + 1) */
-
-static inline u16 mlxsw_sp_pfc_delay_get(int mtu, u16 delay)
-{
-	delay = MLXSW_SP_BYTES_TO_CELLS(DIV_ROUND_UP(delay, BITS_PER_BYTE));
-	return MLXSW_SP_CELL_FACTOR * delay + MLXSW_SP_BYTES_TO_CELLS(mtu);
-}
-
 struct mlxsw_sp_port;
 struct mlxsw_sp_rif;
 
-- 
2.7.4
