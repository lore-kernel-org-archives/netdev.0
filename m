From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 5/5] mlxsw: spectrum: Query cell size from firmware
Date: Fri, 24 Mar 2017 08:02:51 +0100
Message-ID: <1490338971-2687-6-git-send-email-jiri@resnulli.us>
References: <1490338971-2687-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35010 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751991AbdCXHJ1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 03:09:27 -0400
Received: by mail-wm0-f67.google.com with SMTP id z133so1407311wmb.2
        for <netdev@vger.kernel.org>; Fri, 24 Mar 2017 00:09:26 -0700 (PDT)
In-Reply-To: <1490338971-2687-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

As explained in the previous patch, the cell size may change in future
devices, so query it from the firmware instead of hard coding it.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/resources.h    |   2 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  68 +++++++-----
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  18 +++-
 .../net/ethernet/mellanox/mlxsw/spectrum_buffers.c | 114 ++++++++++++---------
 4 files changed, 119 insertions(+), 83 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/resources.h b/drivers/net/ethernet/mellanox/mlxsw/resources.h
index 41553a7..ee09769 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/resources.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/resources.h
@@ -50,6 +50,7 @@ enum mlxsw_res_id {
 	MLXSW_RES_ID_MAX_LAG,
 	MLXSW_RES_ID_MAX_LAG_MEMBERS,
 	MLXSW_RES_ID_MAX_BUFFER_SIZE,
+	MLXSW_RES_ID_CELL_SIZE,
 	MLXSW_RES_ID_ACL_MAX_TCAM_REGIONS,
 	MLXSW_RES_ID_ACL_MAX_TCAM_RULES,
 	MLXSW_RES_ID_ACL_MAX_REGIONS,
@@ -85,6 +86,7 @@ static u16 mlxsw_res_ids[] = {
 	[MLXSW_RES_ID_MAX_LAG] = 0x2520,
 	[MLXSW_RES_ID_MAX_LAG_MEMBERS] = 0x2521,
 	[MLXSW_RES_ID_MAX_BUFFER_SIZE] = 0x2802,	/* Bytes */
+	[MLXSW_RES_ID_CELL_SIZE] = 0x2803,	/* Bytes */
 	[MLXSW_RES_ID_ACL_MAX_TCAM_REGIONS] = 0x2901,
 	[MLXSW_RES_ID_ACL_MAX_TCAM_RULES] = 0x2902,
 	[MLXSW_RES_ID_ACL_MAX_REGIONS] = 0x2903,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index c440b35..eabfe5c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -359,9 +359,10 @@ static bool mlxsw_sp_span_is_egress_mirror(struct mlxsw_sp_port *port)
 	return false;
 }
 
-static int mlxsw_sp_span_mtu_to_buffsize(int mtu)
+static int mlxsw_sp_span_mtu_to_buffsize(const struct mlxsw_sp *mlxsw_sp,
+					 int mtu)
 {
-	return MLXSW_SP_BYTES_TO_CELLS(mtu * 5 / 2) + 1;
+	return mlxsw_sp_bytes_cells(mlxsw_sp, mtu * 5 / 2) + 1;
 }
 
 static int mlxsw_sp_span_port_mtu_update(struct mlxsw_sp_port *port, u16 mtu)
@@ -374,8 +375,9 @@ static int mlxsw_sp_span_port_mtu_update(struct mlxsw_sp_port *port, u16 mtu)
 	 * updated according to the mtu value
 	 */
 	if (mlxsw_sp_span_is_egress_mirror(port)) {
-		mlxsw_reg_sbib_pack(sbib_pl, port->local_port,
-				    mlxsw_sp_span_mtu_to_buffsize(mtu));
+		u32 buffsize = mlxsw_sp_span_mtu_to_buffsize(mlxsw_sp, mtu);
+
+		mlxsw_reg_sbib_pack(sbib_pl, port->local_port, buffsize);
 		err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sbib), sbib_pl);
 		if (err) {
 			netdev_err(port->dev, "Could not update shared buffer for mirroring\n");
@@ -412,8 +414,10 @@ mlxsw_sp_span_inspected_port_bind(struct mlxsw_sp_port *port,
 
 	/* if it is an egress SPAN, bind a shared buffer to it */
 	if (type == MLXSW_SP_SPAN_EGRESS) {
-		mlxsw_reg_sbib_pack(sbib_pl, port->local_port,
-				    mlxsw_sp_span_mtu_to_buffsize(port->dev->mtu));
+		u32 buffsize = mlxsw_sp_span_mtu_to_buffsize(mlxsw_sp,
+							     port->dev->mtu);
+
+		mlxsw_reg_sbib_pack(sbib_pl, port->local_port, buffsize);
 		err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sbib), sbib_pl);
 		if (err) {
 			netdev_err(port->dev, "Could not create shared buffer for mirroring\n");
@@ -800,28 +804,35 @@ static int mlxsw_sp_port_set_mac_address(struct net_device *dev, void *p)
 	return 0;
 }
 
-static u16 mlxsw_sp_pg_buf_threshold_get(int mtu)
+static u16 mlxsw_sp_pg_buf_threshold_get(const struct mlxsw_sp *mlxsw_sp,
+					 int mtu)
 {
-	return 2 * MLXSW_SP_BYTES_TO_CELLS(mtu);
+	return 2 * mlxsw_sp_bytes_cells(mlxsw_sp, mtu);
 }
 
 #define MLXSW_SP_CELL_FACTOR 2	/* 2 * cell_size / (IPG + cell_size + 1) */
-static u16 mlxsw_sp_pfc_delay_get(int mtu, u16 delay)
+
+static u16 mlxsw_sp_pfc_delay_get(const struct mlxsw_sp *mlxsw_sp, int mtu,
+				  u16 delay)
 {
-	delay = MLXSW_SP_BYTES_TO_CELLS(DIV_ROUND_UP(delay, BITS_PER_BYTE));
-	return MLXSW_SP_CELL_FACTOR * delay + MLXSW_SP_BYTES_TO_CELLS(mtu);
+	delay = mlxsw_sp_bytes_cells(mlxsw_sp, DIV_ROUND_UP(delay,
+							    BITS_PER_BYTE));
+	return MLXSW_SP_CELL_FACTOR * delay + mlxsw_sp_bytes_cells(mlxsw_sp,
+								   mtu);
 }
 
-/* Maximum delay buffer needed in case of PAUSE frames, in cells.
+/* Maximum delay buffer needed in case of PAUSE frames, in bytes.
  * Assumes 100m cable and maximum MTU.
  */
-#define MLXSW_SP_PAUSE_DELAY 612
-static u16 mlxsw_sp_pg_buf_delay_get(int mtu, u16 delay, bool pfc, bool pause)
+#define MLXSW_SP_PAUSE_DELAY 58752
+
+static u16 mlxsw_sp_pg_buf_delay_get(const struct mlxsw_sp *mlxsw_sp, int mtu,
+				     u16 delay, bool pfc, bool pause)
 {
 	if (pfc)
-		return mlxsw_sp_pfc_delay_get(mtu, delay);
+		return mlxsw_sp_pfc_delay_get(mlxsw_sp, mtu, delay);
 	else if (pause)
-		return MLXSW_SP_PAUSE_DELAY;
+		return mlxsw_sp_bytes_cells(mlxsw_sp, MLXSW_SP_PAUSE_DELAY);
 	else
 		return 0;
 }
@@ -869,8 +880,9 @@ int __mlxsw_sp_port_headroom_set(struct mlxsw_sp_port *mlxsw_sp_port, int mtu,
 			continue;
 
 		lossy = !(pfc || pause_en);
-		thres = mlxsw_sp_pg_buf_threshold_get(mtu);
-		delay = mlxsw_sp_pg_buf_delay_get(mtu, delay, pfc, pause_en);
+		thres = mlxsw_sp_pg_buf_threshold_get(mlxsw_sp, mtu);
+		delay = mlxsw_sp_pg_buf_delay_get(mlxsw_sp, mtu, delay, pfc,
+						  pause_en);
 		mlxsw_sp_pg_buf_pack(pbmc_pl, i, thres + delay, thres, lossy);
 	}
 
@@ -1577,6 +1589,7 @@ static int mlxsw_sp_port_set_pauseparam(struct net_device *dev,
 struct mlxsw_sp_port_hw_stats {
 	char str[ETH_GSTRING_LEN];
 	u64 (*getter)(const char *payload);
+	bool cells_bytes;
 };
 
 static struct mlxsw_sp_port_hw_stats mlxsw_sp_port_hw_stats[] = {
@@ -1697,17 +1710,11 @@ static struct mlxsw_sp_port_hw_stats mlxsw_sp_port_hw_prio_stats[] = {
 
 #define MLXSW_SP_PORT_HW_PRIO_STATS_LEN ARRAY_SIZE(mlxsw_sp_port_hw_prio_stats)
 
-static u64 mlxsw_reg_ppcnt_tc_transmit_queue_bytes_get(const char *ppcnt_pl)
-{
-	u64 transmit_queue = mlxsw_reg_ppcnt_tc_transmit_queue_get(ppcnt_pl);
-
-	return MLXSW_SP_CELLS_TO_BYTES(transmit_queue);
-}
-
 static struct mlxsw_sp_port_hw_stats mlxsw_sp_port_hw_tc_stats[] = {
 	{
 		.str = "tc_transmit_queue_tc",
-		.getter = mlxsw_reg_ppcnt_tc_transmit_queue_bytes_get,
+		.getter = mlxsw_reg_ppcnt_tc_transmit_queue_get,
+		.cells_bytes = true,
 	},
 	{
 		.str = "tc_no_buffer_discard_uc_tc",
@@ -1819,6 +1826,8 @@ static void __mlxsw_sp_port_get_stats(struct net_device *dev,
 				      enum mlxsw_reg_ppcnt_grp grp, int prio,
 				      u64 *data, int data_index)
 {
+	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	struct mlxsw_sp_port_hw_stats *hw_stats;
 	char ppcnt_pl[MLXSW_REG_PPCNT_LEN];
 	int i, len;
@@ -1828,8 +1837,13 @@ static void __mlxsw_sp_port_get_stats(struct net_device *dev,
 	if (err)
 		return;
 	mlxsw_sp_port_get_stats_raw(dev, grp, prio, ppcnt_pl);
-	for (i = 0; i < len; i++)
+	for (i = 0; i < len; i++) {
 		data[data_index + i] = hw_stats[i].getter(ppcnt_pl);
+		if (!hw_stats[i].cells_bytes)
+			continue;
+		data[data_index + i] = mlxsw_sp_cells_bytes(mlxsw_sp,
+							    data[data_index + i]);
+	}
 }
 
 static void mlxsw_sp_port_get_stats(struct net_device *dev,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 958acac..3025b76 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -65,11 +65,6 @@
 
 #define MLXSW_SP_PORT_BASE_SPEED 25000	/* Mb/s */
 
-#define MLXSW_SP_BYTES_PER_CELL 96
-
-#define MLXSW_SP_BYTES_TO_CELLS(b) DIV_ROUND_UP(b, MLXSW_SP_BYTES_PER_CELL)
-#define MLXSW_SP_CELLS_TO_BYTES(c) (c * MLXSW_SP_BYTES_PER_CELL)
-
 #define MLXSW_SP_KVD_LINEAR_SIZE 65536 /* entries */
 #define MLXSW_SP_KVD_GRANULARITY 128
 
@@ -147,6 +142,7 @@ struct mlxsw_sp_sb_port {
 struct mlxsw_sp_sb {
 	struct mlxsw_sp_sb_pr prs[2][MLXSW_SP_SB_POOL_COUNT];
 	struct mlxsw_sp_sb_port *ports;
+	u32 cell_size;
 };
 
 #define MLXSW_SP_PREFIX_COUNT (sizeof(struct in6_addr) * BITS_PER_BYTE)
@@ -284,6 +280,18 @@ mlxsw_sp_lag_get(struct mlxsw_sp *mlxsw_sp, u16 lag_id)
 	return &mlxsw_sp->lags[lag_id];
 }
 
+static inline u32 mlxsw_sp_cells_bytes(const struct mlxsw_sp *mlxsw_sp,
+				       u32 cells)
+{
+	return mlxsw_sp->sb.cell_size * cells;
+}
+
+static inline u32 mlxsw_sp_bytes_cells(const struct mlxsw_sp *mlxsw_sp,
+				       u32 bytes)
+{
+	return DIV_ROUND_UP(bytes, mlxsw_sp->sb.cell_size);
+}
+
 struct mlxsw_sp_port_pcpu_stats {
 	u64			rx_packets;
 	u64			rx_bytes;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
index 7e67d0e..997189c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
@@ -162,8 +162,8 @@ static int mlxsw_sp_sb_pm_occ_query(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 }
 
 static const u16 mlxsw_sp_pbs[] = {
-	[0] = 2 * MLXSW_SP_BYTES_TO_CELLS(ETH_FRAME_LEN),
-	[9] = 2 * MLXSW_SP_BYTES_TO_CELLS(MLXSW_PORT_MAX_MTU),
+	[0] = 2 * ETH_FRAME_LEN,
+	[9] = 2 * MLXSW_PORT_MAX_MTU,
 };
 
 #define MLXSW_SP_PBS_LEN ARRAY_SIZE(mlxsw_sp_pbs)
@@ -171,20 +171,22 @@ static const u16 mlxsw_sp_pbs[] = {
 
 static int mlxsw_sp_port_pb_init(struct mlxsw_sp_port *mlxsw_sp_port)
 {
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	char pbmc_pl[MLXSW_REG_PBMC_LEN];
 	int i;
 
 	mlxsw_reg_pbmc_pack(pbmc_pl, mlxsw_sp_port->local_port,
 			    0xffff, 0xffff / 2);
 	for (i = 0; i < MLXSW_SP_PBS_LEN; i++) {
+		u16 size = mlxsw_sp_bytes_cells(mlxsw_sp, mlxsw_sp_pbs[i]);
+
 		if (i == MLXSW_SP_PB_UNUSED)
 			continue;
-		mlxsw_reg_pbmc_lossy_buffer_pack(pbmc_pl, i, mlxsw_sp_pbs[i]);
+		mlxsw_reg_pbmc_lossy_buffer_pack(pbmc_pl, i, size);
 	}
 	mlxsw_reg_pbmc_lossy_buffer_pack(pbmc_pl,
 					 MLXSW_REG_PBMC_PORT_SHARED_BUF_IDX, 0);
-	return mlxsw_reg_write(mlxsw_sp_port->mlxsw_sp->core,
-			       MLXSW_REG(pbmc), pbmc_pl);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(pbmc), pbmc_pl);
 }
 
 static int mlxsw_sp_port_pb_prio_init(struct mlxsw_sp_port *mlxsw_sp_port)
@@ -237,18 +239,17 @@ static void mlxsw_sp_sb_ports_fini(struct mlxsw_sp *mlxsw_sp)
 
 static const struct mlxsw_sp_sb_pr mlxsw_sp_sb_prs_ingress[] = {
 	MLXSW_SP_SB_PR(MLXSW_REG_SBPR_MODE_DYNAMIC,
-		       MLXSW_SP_BYTES_TO_CELLS(MLXSW_SP_SB_PR_INGRESS_SIZE)),
+		       MLXSW_SP_SB_PR_INGRESS_SIZE),
 	MLXSW_SP_SB_PR(MLXSW_REG_SBPR_MODE_DYNAMIC, 0),
 	MLXSW_SP_SB_PR(MLXSW_REG_SBPR_MODE_DYNAMIC, 0),
 	MLXSW_SP_SB_PR(MLXSW_REG_SBPR_MODE_DYNAMIC,
-		       MLXSW_SP_BYTES_TO_CELLS(MLXSW_SP_SB_PR_INGRESS_MNG_SIZE)),
+		       MLXSW_SP_SB_PR_INGRESS_MNG_SIZE),
 };
 
 #define MLXSW_SP_SB_PRS_INGRESS_LEN ARRAY_SIZE(mlxsw_sp_sb_prs_ingress)
 
 static const struct mlxsw_sp_sb_pr mlxsw_sp_sb_prs_egress[] = {
-	MLXSW_SP_SB_PR(MLXSW_REG_SBPR_MODE_DYNAMIC,
-		       MLXSW_SP_BYTES_TO_CELLS(MLXSW_SP_SB_PR_EGRESS_SIZE)),
+	MLXSW_SP_SB_PR(MLXSW_REG_SBPR_MODE_DYNAMIC, MLXSW_SP_SB_PR_EGRESS_SIZE),
 	MLXSW_SP_SB_PR(MLXSW_REG_SBPR_MODE_DYNAMIC, 0),
 	MLXSW_SP_SB_PR(MLXSW_REG_SBPR_MODE_DYNAMIC, 0),
 	MLXSW_SP_SB_PR(MLXSW_REG_SBPR_MODE_DYNAMIC, 0),
@@ -265,11 +266,9 @@ static int __mlxsw_sp_sb_prs_init(struct mlxsw_sp *mlxsw_sp,
 	int err;
 
 	for (i = 0; i < prs_len; i++) {
-		const struct mlxsw_sp_sb_pr *pr;
+		u32 size = mlxsw_sp_bytes_cells(mlxsw_sp, prs[i].size);
 
-		pr = &prs[i];
-		err = mlxsw_sp_sb_pr_write(mlxsw_sp, i, dir,
-					   pr->mode, pr->size);
+		err = mlxsw_sp_sb_pr_write(mlxsw_sp, i, dir, prs[i].mode, size);
 		if (err)
 			return err;
 	}
@@ -298,7 +297,7 @@ static int mlxsw_sp_sb_prs_init(struct mlxsw_sp *mlxsw_sp)
 	}
 
 static const struct mlxsw_sp_sb_cm mlxsw_sp_sb_cms_ingress[] = {
-	MLXSW_SP_SB_CM(MLXSW_SP_BYTES_TO_CELLS(10000), 8, 0),
+	MLXSW_SP_SB_CM(10000, 8, 0),
 	MLXSW_SP_SB_CM(0, MLXSW_REG_SBXX_DYN_MAX_BUFF_MIN, 0),
 	MLXSW_SP_SB_CM(0, MLXSW_REG_SBXX_DYN_MAX_BUFF_MIN, 0),
 	MLXSW_SP_SB_CM(0, MLXSW_REG_SBXX_DYN_MAX_BUFF_MIN, 0),
@@ -307,20 +306,20 @@ static const struct mlxsw_sp_sb_cm mlxsw_sp_sb_cms_ingress[] = {
 	MLXSW_SP_SB_CM(0, MLXSW_REG_SBXX_DYN_MAX_BUFF_MIN, 0),
 	MLXSW_SP_SB_CM(0, MLXSW_REG_SBXX_DYN_MAX_BUFF_MIN, 0),
 	MLXSW_SP_SB_CM(0, 0, 0), /* dummy, this PG does not exist */
-	MLXSW_SP_SB_CM(MLXSW_SP_BYTES_TO_CELLS(20000), 1, 3),
+	MLXSW_SP_SB_CM(20000, 1, 3),
 };
 
 #define MLXSW_SP_SB_CMS_INGRESS_LEN ARRAY_SIZE(mlxsw_sp_sb_cms_ingress)
 
 static const struct mlxsw_sp_sb_cm mlxsw_sp_sb_cms_egress[] = {
-	MLXSW_SP_SB_CM(MLXSW_SP_BYTES_TO_CELLS(1500), 9, 0),
-	MLXSW_SP_SB_CM(MLXSW_SP_BYTES_TO_CELLS(1500), 9, 0),
-	MLXSW_SP_SB_CM(MLXSW_SP_BYTES_TO_CELLS(1500), 9, 0),
-	MLXSW_SP_SB_CM(MLXSW_SP_BYTES_TO_CELLS(1500), 9, 0),
-	MLXSW_SP_SB_CM(MLXSW_SP_BYTES_TO_CELLS(1500), 9, 0),
-	MLXSW_SP_SB_CM(MLXSW_SP_BYTES_TO_CELLS(1500), 9, 0),
-	MLXSW_SP_SB_CM(MLXSW_SP_BYTES_TO_CELLS(1500), 9, 0),
-	MLXSW_SP_SB_CM(MLXSW_SP_BYTES_TO_CELLS(1500), 9, 0),
+	MLXSW_SP_SB_CM(1500, 9, 0),
+	MLXSW_SP_SB_CM(1500, 9, 0),
+	MLXSW_SP_SB_CM(1500, 9, 0),
+	MLXSW_SP_SB_CM(1500, 9, 0),
+	MLXSW_SP_SB_CM(1500, 9, 0),
+	MLXSW_SP_SB_CM(1500, 9, 0),
+	MLXSW_SP_SB_CM(1500, 9, 0),
+	MLXSW_SP_SB_CM(1500, 9, 0),
 	MLXSW_SP_SB_CM(0, 0, 0),
 	MLXSW_SP_SB_CM(0, 0, 0),
 	MLXSW_SP_SB_CM(0, 0, 0),
@@ -344,7 +343,7 @@ static const struct mlxsw_sp_sb_cm mlxsw_sp_cpu_port_sb_cms[] = {
 	MLXSW_SP_CPU_PORT_SB_CM,
 	MLXSW_SP_CPU_PORT_SB_CM,
 	MLXSW_SP_CPU_PORT_SB_CM,
-	MLXSW_SP_SB_CM(MLXSW_SP_BYTES_TO_CELLS(10000), 0, 0),
+	MLXSW_SP_SB_CM(10000, 0, 0),
 	MLXSW_SP_CPU_PORT_SB_CM,
 	MLXSW_SP_CPU_PORT_SB_CM,
 	MLXSW_SP_CPU_PORT_SB_CM,
@@ -384,13 +383,17 @@ static int __mlxsw_sp_sb_cms_init(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 
 	for (i = 0; i < cms_len; i++) {
 		const struct mlxsw_sp_sb_cm *cm;
+		u32 min_buff;
 
 		if (i == 8 && dir == MLXSW_REG_SBXX_DIR_INGRESS)
 			continue; /* PG number 8 does not exist, skip it */
 		cm = &cms[i];
+		/* All pools are initialized using dynamic thresholds,
+		 * therefore 'max_buff' isn't specified in cells.
+		 */
+		min_buff = mlxsw_sp_bytes_cells(mlxsw_sp, cm->min_buff);
 		err = mlxsw_sp_sb_cm_write(mlxsw_sp, local_port, i, dir,
-					   cm->min_buff, cm->max_buff,
-					   cm->pool);
+					   min_buff, cm->max_buff, cm->pool);
 		if (err)
 			return err;
 	}
@@ -498,21 +501,21 @@ struct mlxsw_sp_sb_mm {
 	}
 
 static const struct mlxsw_sp_sb_mm mlxsw_sp_sb_mms[] = {
-	MLXSW_SP_SB_MM(MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
-	MLXSW_SP_SB_MM(MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
-	MLXSW_SP_SB_MM(MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
-	MLXSW_SP_SB_MM(MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
-	MLXSW_SP_SB_MM(MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
-	MLXSW_SP_SB_MM(MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
-	MLXSW_SP_SB_MM(MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
-	MLXSW_SP_SB_MM(MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
-	MLXSW_SP_SB_MM(MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
-	MLXSW_SP_SB_MM(MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
-	MLXSW_SP_SB_MM(MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
-	MLXSW_SP_SB_MM(MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
-	MLXSW_SP_SB_MM(MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
-	MLXSW_SP_SB_MM(MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
-	MLXSW_SP_SB_MM(MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
+	MLXSW_SP_SB_MM(20000, 0xff, 0),
+	MLXSW_SP_SB_MM(20000, 0xff, 0),
+	MLXSW_SP_SB_MM(20000, 0xff, 0),
+	MLXSW_SP_SB_MM(20000, 0xff, 0),
+	MLXSW_SP_SB_MM(20000, 0xff, 0),
+	MLXSW_SP_SB_MM(20000, 0xff, 0),
+	MLXSW_SP_SB_MM(20000, 0xff, 0),
+	MLXSW_SP_SB_MM(20000, 0xff, 0),
+	MLXSW_SP_SB_MM(20000, 0xff, 0),
+	MLXSW_SP_SB_MM(20000, 0xff, 0),
+	MLXSW_SP_SB_MM(20000, 0xff, 0),
+	MLXSW_SP_SB_MM(20000, 0xff, 0),
+	MLXSW_SP_SB_MM(20000, 0xff, 0),
+	MLXSW_SP_SB_MM(20000, 0xff, 0),
+	MLXSW_SP_SB_MM(20000, 0xff, 0),
 };
 
 #define MLXSW_SP_SB_MMS_LEN ARRAY_SIZE(mlxsw_sp_sb_mms)
@@ -525,10 +528,15 @@ static int mlxsw_sp_sb_mms_init(struct mlxsw_sp *mlxsw_sp)
 
 	for (i = 0; i < MLXSW_SP_SB_MMS_LEN; i++) {
 		const struct mlxsw_sp_sb_mm *mc;
+		u32 min_buff;
 
 		mc = &mlxsw_sp_sb_mms[i];
-		mlxsw_reg_sbmm_pack(sbmm_pl, i, mc->min_buff,
-				    mc->max_buff, mc->pool);
+		/* All pools are initialized using dynamic thresholds,
+		 * therefore 'max_buff' isn't specified in cells.
+		 */
+		min_buff = mlxsw_sp_bytes_cells(mlxsw_sp, mc->min_buff);
+		mlxsw_reg_sbmm_pack(sbmm_pl, i, min_buff, mc->max_buff,
+				    mc->pool);
 		err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sbmm), sbmm_pl);
 		if (err)
 			return err;
@@ -541,6 +549,10 @@ int mlxsw_sp_buffers_init(struct mlxsw_sp *mlxsw_sp)
 	u64 sb_size;
 	int err;
 
+	if (!MLXSW_CORE_RES_VALID(mlxsw_sp->core, CELL_SIZE))
+		return -EIO;
+	mlxsw_sp->sb.cell_size = MLXSW_CORE_RES_GET(mlxsw_sp->core, CELL_SIZE);
+
 	if (!MLXSW_CORE_RES_VALID(mlxsw_sp->core, MAX_BUFFER_SIZE))
 		return -EIO;
 	sb_size = MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_BUFFER_SIZE);
@@ -627,7 +639,7 @@ int mlxsw_sp_sb_pool_get(struct mlxsw_core *mlxsw_core,
 	struct mlxsw_sp_sb_pr *pr = mlxsw_sp_sb_pr_get(mlxsw_sp, pool, dir);
 
 	pool_info->pool_type = (enum devlink_sb_pool_type) dir;
-	pool_info->size = MLXSW_SP_CELLS_TO_BYTES(pr->size);
+	pool_info->size = mlxsw_sp_cells_bytes(mlxsw_sp, pr->size);
 	pool_info->threshold_type = (enum devlink_sb_threshold_type) pr->mode;
 	return 0;
 }
@@ -637,9 +649,9 @@ int mlxsw_sp_sb_pool_set(struct mlxsw_core *mlxsw_core,
 			 enum devlink_sb_threshold_type threshold_type)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_core_driver_priv(mlxsw_core);
+	u32 pool_size = mlxsw_sp_bytes_cells(mlxsw_sp, size);
 	u8 pool = pool_get(pool_index);
 	enum mlxsw_reg_sbxx_dir dir = dir_get(pool_index);
-	u32 pool_size = MLXSW_SP_BYTES_TO_CELLS(size);
 	enum mlxsw_reg_sbpr_mode mode;
 
 	if (size > MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_BUFFER_SIZE))
@@ -658,7 +670,7 @@ static u32 mlxsw_sp_sb_threshold_out(struct mlxsw_sp *mlxsw_sp, u8 pool,
 
 	if (pr->mode == MLXSW_REG_SBPR_MODE_DYNAMIC)
 		return max_buff - MLXSW_SP_SB_THRESHOLD_TO_ALPHA_OFFSET;
-	return MLXSW_SP_CELLS_TO_BYTES(max_buff);
+	return mlxsw_sp_cells_bytes(mlxsw_sp, max_buff);
 }
 
 static int mlxsw_sp_sb_threshold_in(struct mlxsw_sp *mlxsw_sp, u8 pool,
@@ -676,7 +688,7 @@ static int mlxsw_sp_sb_threshold_in(struct mlxsw_sp *mlxsw_sp, u8 pool,
 			return -EINVAL;
 		*p_max_buff = val;
 	} else {
-		*p_max_buff = MLXSW_SP_BYTES_TO_CELLS(threshold);
+		*p_max_buff = mlxsw_sp_bytes_cells(mlxsw_sp, threshold);
 	}
 	return 0;
 }
@@ -963,8 +975,8 @@ int mlxsw_sp_sb_occ_port_pool_get(struct mlxsw_core_port *mlxsw_core_port,
 	struct mlxsw_sp_sb_pm *pm = mlxsw_sp_sb_pm_get(mlxsw_sp, local_port,
 						       pool, dir);
 
-	*p_cur = MLXSW_SP_CELLS_TO_BYTES(pm->occ.cur);
-	*p_max = MLXSW_SP_CELLS_TO_BYTES(pm->occ.max);
+	*p_cur = mlxsw_sp_cells_bytes(mlxsw_sp, pm->occ.cur);
+	*p_max = mlxsw_sp_cells_bytes(mlxsw_sp, pm->occ.max);
 	return 0;
 }
 
@@ -982,7 +994,7 @@ int mlxsw_sp_sb_occ_tc_port_bind_get(struct mlxsw_core_port *mlxsw_core_port,
 	struct mlxsw_sp_sb_cm *cm = mlxsw_sp_sb_cm_get(mlxsw_sp, local_port,
 						       pg_buff, dir);
 
-	*p_cur = MLXSW_SP_CELLS_TO_BYTES(cm->occ.cur);
-	*p_max = MLXSW_SP_CELLS_TO_BYTES(cm->occ.max);
+	*p_cur = mlxsw_sp_cells_bytes(mlxsw_sp, cm->occ.cur);
+	*p_max = mlxsw_sp_cells_bytes(mlxsw_sp, cm->occ.max);
 	return 0;
 }
-- 
2.7.4
