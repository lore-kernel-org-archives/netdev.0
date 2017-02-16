From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 7/8] mlxsw: spectrum: Support for counters on router interfaces
Date: Thu, 16 Feb 2017 16:22:43 +0100
Message-ID: <1487258564-3775-8-git-send-email-jiri@resnulli.us>
References: <1487258564-3775-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, jhs@mojatatu.com, ivecera@redhat.com,
        roopa@cumulusnetworks.com, f.fainelli@gmail.com,
        vivien.didelot@savoirfairelinux.com, john.fastabend@gmail.com,
        andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33151 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932423AbdBPPWz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 10:22:55 -0500
Received: by mail-wm0-f68.google.com with SMTP id v77so3651049wmv.0
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2017 07:22:54 -0800 (PST)
In-Reply-To: <1487258564-3775-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Add support for counter allocation on router interfaces. The allocation
depends on the counter state of relevant table. In case the counting is
disabled or no counters left the counter index will be set as invalid.

Also a counter pool for router allocation is added.

Signed-off-by: Arakdi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 143 +++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  19 +++
 drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.c |   7 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.h |   9 +-
 4 files changed, 176 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index cb66416..9a8c563 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -3318,6 +3318,138 @@ static struct mlxsw_config_profile mlxsw_sp_config_profile = {
 	.resource_query_enable		= 1,
 };
 
+static void mlxsw_sp_rif_counter_set(struct mlxsw_sp_rif *r,
+				     int counter_index, bool valid,
+				     enum mlxsw_sp_rif_counter_dir dir)
+{
+	switch (dir) {
+	case MLXSW_SP_RIF_COUNTER_EGRESS:
+		r->counter_egress = counter_index;
+		r->counter_egress_valid = valid;
+		break;
+	case MLXSW_SP_RIF_COUNTER_INGRESS:
+		r->counter_ingress = counter_index;
+		r->counter_ingress_valid = valid;
+		break;
+	}
+}
+
+static int mlxsw_sp_rif_counter_get(struct mlxsw_sp_rif *r,
+				    enum mlxsw_sp_rif_counter_dir dir)
+{
+	switch (dir) {
+	case MLXSW_SP_RIF_COUNTER_EGRESS:
+		if (r->counter_egress_valid)
+			return r->counter_egress;
+		break;
+	case MLXSW_SP_RIF_COUNTER_INGRESS:
+		if (r->counter_ingress_valid)
+			return r->counter_ingress;
+		break;
+	}
+	return -EINVAL;
+}
+
+static int mlxsw_sp_rif_counter_edit(struct mlxsw_sp *mlxsw_sp, u16 rif,
+				     int counter_index, bool enable,
+				     enum mlxsw_sp_rif_counter_dir dir)
+{
+	char ritr_pl[MLXSW_REG_RITR_LEN];
+	bool is_egress = false;
+	int err;
+
+	if (dir == MLXSW_SP_RIF_COUNTER_EGRESS)
+		is_egress = true;
+	mlxsw_reg_ritr_rif_pack(ritr_pl, rif);
+	err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(ritr), ritr_pl);
+	if (err)
+		return err;
+
+	mlxsw_reg_ritr_counter_pack(ritr_pl, counter_index, enable,
+				    is_egress);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ritr), ritr_pl);
+}
+
+int mlxsw_sp_rif_counter_value_get(struct mlxsw_sp *mlxsw_sp,
+				   struct mlxsw_sp_rif *r,
+				   enum mlxsw_sp_rif_counter_dir dir, u64 *cnt)
+{
+	char ricnt_pl[MLXSW_REG_RICNT_LEN];
+	int counter_index;
+	int err;
+
+	counter_index = mlxsw_sp_rif_counter_get(r, dir);
+	if (counter_index < 0)
+		return -EINVAL;
+	mlxsw_reg_ricnt_pack(ricnt_pl, counter_index,
+			     MLXSW_REG_RICNT_OPCODE_NOP);
+	err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(ricnt), ricnt_pl);
+	if (err)
+		return err;
+	*cnt = mlxsw_reg_ricnt_good_unicast_packets_get(ricnt_pl);
+	return 0;
+}
+
+static int mlxsw_sp_rif_counter_clear(struct mlxsw_sp *mlxsw_sp,
+				      int counter_index)
+{
+	char ricnt_pl[MLXSW_REG_RICNT_LEN];
+
+	mlxsw_reg_ricnt_pack(ricnt_pl, counter_index,
+			     MLXSW_REG_RICNT_OPCODE_CLEAR);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ricnt), ricnt_pl);
+}
+
+int mlxsw_sp_rif_counter_alloc(struct mlxsw_sp *mlxsw_sp,
+			       struct mlxsw_sp_rif *r,
+			       enum mlxsw_sp_rif_counter_dir dir)
+{
+	int counter_index;
+	int err;
+
+	counter_index = mlxsw_sp_counter_alloc(mlxsw_sp,
+					       MLXSW_SP_COUNTER_SUB_POOL_RIF,
+					       MLXSW_SP_COUNTER_SIZE_RIF_BASIC);
+	if (counter_index < 0) {
+		err = counter_index;
+		return err;
+	}
+
+	err = mlxsw_sp_rif_counter_clear(mlxsw_sp, counter_index);
+	if (err)
+		goto err_counter_clear;
+
+	err = mlxsw_sp_rif_counter_edit(mlxsw_sp, r->rif, counter_index,
+					true, dir);
+	if (err)
+		goto err_counter_edit;
+
+	mlxsw_sp_rif_counter_set(r, counter_index, true, dir);
+	return 0;
+
+err_counter_edit:
+err_counter_clear:
+	mlxsw_sp_counter_free(mlxsw_sp, MLXSW_SP_COUNTER_SUB_POOL_RIF,
+			      counter_index);
+	return err;
+}
+
+void mlxsw_sp_rif_counter_free(struct mlxsw_sp *mlxsw_sp,
+			       struct mlxsw_sp_rif *r,
+			       enum mlxsw_sp_rif_counter_dir dir)
+{
+	int counter_index;
+
+	counter_index = mlxsw_sp_rif_counter_get(r, dir);
+	if (counter_index < 0)
+		return;
+	mlxsw_sp_rif_counter_edit(mlxsw_sp, r->rif,
+				  counter_index, false, dir);
+	mlxsw_sp_counter_free(mlxsw_sp, MLXSW_SP_COUNTER_SUB_POOL_RIF,
+			      counter_index);
+	mlxsw_sp_rif_counter_set(r, 0, false, dir);
+}
+
 static struct mlxsw_driver mlxsw_sp_driver = {
 	.kind				= mlxsw_sp_driver_name,
 	.priv_size			= sizeof(struct mlxsw_sp),
@@ -3549,6 +3681,15 @@ mlxsw_sp_vport_rif_sp_create(struct mlxsw_sp_port *mlxsw_sp_vport,
 	f->r = r;
 	mlxsw_sp->rifs[rif] = r;
 
+	if (devlink_dpipe_table_counter_enabled(priv_to_devlink(mlxsw_sp->core),
+						MLXSW_SP_DPIPE_TABLE_NAME_ERIF)){
+		err = mlxsw_sp_rif_counter_alloc(mlxsw_sp, r,
+						 MLXSW_SP_RIF_COUNTER_EGRESS);
+		if (err)
+			netdev_dbg(mlxsw_sp_vport->dev,
+				   "Counter alloc Failed err=%d\n", err);
+	}
+
 	return r;
 
 err_rif_alloc:
@@ -3570,6 +3711,8 @@ static void mlxsw_sp_vport_rif_sp_destroy(struct mlxsw_sp_port *mlxsw_sp_vport,
 	u16 rif = r->rif;
 
 	mlxsw_sp_router_rif_gone_sync(mlxsw_sp, r);
+	mlxsw_sp_rif_counter_free(mlxsw_sp, r, MLXSW_SP_RIF_COUNTER_EGRESS);
+	mlxsw_sp_rif_counter_free(mlxsw_sp, r, MLXSW_SP_RIF_COUNTER_INGRESS);
 
 	mlxsw_sp->rifs[rif] = NULL;
 	f->r = NULL;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 1aec58a..1fb2a43 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -85,6 +85,11 @@
 
 #define MLXSW_SP_CELL_FACTOR 2	/* 2 * cell_size / (IPG + cell_size + 1) */
 
+enum mlxsw_sp_rif_counter_dir {
+	MLXSW_SP_RIF_COUNTER_INGRESS,
+	MLXSW_SP_RIF_COUNTER_EGRESS,
+};
+
 static inline u16 mlxsw_sp_pfc_delay_get(int mtu, u16 delay)
 {
 	delay = MLXSW_SP_BYTES_TO_CELLS(DIV_ROUND_UP(delay, BITS_PER_BYTE));
@@ -116,6 +121,10 @@ struct mlxsw_sp_rif {
 	unsigned char addr[ETH_ALEN];
 	int mtu;
 	u16 rif;
+	unsigned int counter_ingress;
+	bool counter_ingress_valid;
+	unsigned int counter_egress;
+	bool counter_egress_valid;
 };
 
 struct mlxsw_sp_mid {
@@ -711,4 +720,14 @@ int mlxsw_sp_flower_replace(struct mlxsw_sp_port *mlxsw_sp_port, bool ingress,
 void mlxsw_sp_flower_destroy(struct mlxsw_sp_port *mlxsw_sp_port, bool ingress,
 			     struct tc_cls_flower_offload *f);
 
+int mlxsw_sp_rif_counter_value_get(struct mlxsw_sp *mlxsw_sp,
+				   struct mlxsw_sp_rif *r,
+				   enum mlxsw_sp_rif_counter_dir dir,
+				   u64 *cnt);
+void mlxsw_sp_rif_counter_free(struct mlxsw_sp *mlxsw_sp,
+			       struct mlxsw_sp_rif *r,
+			       enum mlxsw_sp_rif_counter_dir dir);
+int mlxsw_sp_rif_counter_alloc(struct mlxsw_sp *mlxsw_sp,
+			       struct mlxsw_sp_rif *r,
+			       enum mlxsw_sp_rif_counter_dir dir);
 #endif
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.c
index a0344c6..3e3ca6b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.c
@@ -53,7 +53,12 @@ struct mlxsw_sp_counter_pool {
 	unsigned int sub_pools_count;
 };
 
-static struct mlxsw_sp_counter_sub_pool mlxsw_sp_counter_sub_pools[] = {};
+static struct mlxsw_sp_counter_sub_pool mlxsw_sp_counter_sub_pools[] = {
+	[MLXSW_SP_COUNTER_SUB_POOL_RIF] = {
+		.bank_count = 2,
+		.entry_size = MLXSW_SP_COUNTER_SIZE_RIF_BASIC,
+	},
+};
 
 int mlxsw_sp_counter_pool_init(struct mlxsw_sp *mlxsw_sp)
 {
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.h
index d300b89..aaf4c90 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.h
@@ -37,7 +37,14 @@
 
 #include "spectrum.h"
 
-enum mlxsw_sp_counter_sub_pool_id;
+enum mlxsw_sp_counter_sub_pool_id {
+	MLXSW_SP_COUNTER_SUB_POOL_RIF,
+};
+
+/* Counter indexes number needed for different resources */
+enum mlxsw_sp_counter_sizes {
+	MLXSW_SP_COUNTER_SIZE_RIF_BASIC = 10,
+};
 
 int mlxsw_sp_counter_alloc(struct mlxsw_sp *mlxsw_sp, unsigned int sub_pool_id,
 			   unsigned int entry_size);
-- 
2.7.4
