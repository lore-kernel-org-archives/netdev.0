From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/9] mlxsw: spectrum: Add support for generic flow counter allocation
Date: Sat, 11 Mar 2017 09:42:53 +0100
Message-ID: <1489221779-3807-4-git-send-email-jiri@resnulli.us>
References: <1489221779-3807-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, mlxsw@mellanox.com,
        idosch@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33033 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752616AbdCKInH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 11 Mar 2017 03:43:07 -0500
Received: by mail-wm0-f67.google.com with SMTP id n11so2248876wma.0
        for <netdev@vger.kernel.org>; Sat, 11 Mar 2017 00:43:05 -0800 (PST)
In-Reply-To: <1489221779-3807-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Add support for allocating generic flow counter. Generic flow counter
can count packets or packets and bytes and can be assigned to different
hardware processes. First use will be for counting packets and bytes of
ACL rules, and will be introduced in the following patches.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Reviewed-by: Ido schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/resources.h    |  2 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 54 ++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  7 +++
 drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.c | 23 ++++++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.h |  3 +-
 5 files changed, 86 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/resources.h b/drivers/net/ethernet/mellanox/mlxsw/resources.h
index 15b8086..905a8e2 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/resources.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/resources.h
@@ -45,6 +45,7 @@ enum mlxsw_res_id {
 	MLXSW_RES_ID_MAX_TRAP_GROUPS,
 	MLXSW_RES_ID_COUNTER_POOL_SIZE,
 	MLXSW_RES_ID_MAX_SPAN,
+	MLXSW_RES_ID_COUNTER_SIZE_PACKETS_BYTES,
 	MLXSW_RES_ID_MAX_SYSTEM_PORT,
 	MLXSW_RES_ID_MAX_LAG,
 	MLXSW_RES_ID_MAX_LAG_MEMBERS,
@@ -78,6 +79,7 @@ static u16 mlxsw_res_ids[] = {
 	[MLXSW_RES_ID_MAX_TRAP_GROUPS] = 0x2201,
 	[MLXSW_RES_ID_COUNTER_POOL_SIZE] = 0x2410,
 	[MLXSW_RES_ID_MAX_SPAN] = 0x2420,
+	[MLXSW_RES_ID_COUNTER_SIZE_PACKETS_BYTES] = 0x2443,
 	[MLXSW_RES_ID_MAX_SYSTEM_PORT] = 0x2502,
 	[MLXSW_RES_ID_MAX_LAG] = 0x2520,
 	[MLXSW_RES_ID_MAX_LAG_MEMBERS] = 0x2521,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index b8237f9..af43048 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -139,6 +139,60 @@ MLXSW_ITEM32(tx, hdr, fid, 0x08, 0, 16);
  */
 MLXSW_ITEM32(tx, hdr, type, 0x0C, 0, 4);
 
+int mlxsw_sp_flow_counter_get(struct mlxsw_sp *mlxsw_sp,
+			      unsigned int counter_index, u64 *packets,
+			      u64 *bytes)
+{
+	char mgpc_pl[MLXSW_REG_MGPC_LEN];
+	int err;
+
+	mlxsw_reg_mgpc_pack(mgpc_pl, counter_index, MLXSW_REG_MGPC_OPCODE_NOP,
+			    MLXSW_REG_MGPC_COUNTER_SET_TYPE_PACKETS_BYTES);
+	err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(mgpc), mgpc_pl);
+	if (err)
+		return err;
+	*packets = mlxsw_reg_mgpc_packet_counter_get(mgpc_pl);
+	*bytes = mlxsw_reg_mgpc_byte_counter_get(mgpc_pl);
+	return 0;
+}
+
+static int mlxsw_sp_flow_counter_clear(struct mlxsw_sp *mlxsw_sp,
+				       unsigned int counter_index)
+{
+	char mgpc_pl[MLXSW_REG_MGPC_LEN];
+
+	mlxsw_reg_mgpc_pack(mgpc_pl, counter_index, MLXSW_REG_MGPC_OPCODE_CLEAR,
+			    MLXSW_REG_MGPC_COUNTER_SET_TYPE_PACKETS_BYTES);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(mgpc), mgpc_pl);
+}
+
+int mlxsw_sp_flow_counter_alloc(struct mlxsw_sp *mlxsw_sp,
+				unsigned int *p_counter_index)
+{
+	int err;
+
+	err = mlxsw_sp_counter_alloc(mlxsw_sp, MLXSW_SP_COUNTER_SUB_POOL_FLOW,
+				     p_counter_index);
+	if (err)
+		return err;
+	err = mlxsw_sp_flow_counter_clear(mlxsw_sp, *p_counter_index);
+	if (err)
+		goto err_counter_clear;
+	return 0;
+
+err_counter_clear:
+	mlxsw_sp_counter_free(mlxsw_sp, MLXSW_SP_COUNTER_SUB_POOL_FLOW,
+			      *p_counter_index);
+	return err;
+}
+
+void mlxsw_sp_flow_counter_free(struct mlxsw_sp *mlxsw_sp,
+				unsigned int counter_index)
+{
+	 mlxsw_sp_counter_free(mlxsw_sp, MLXSW_SP_COUNTER_SUB_POOL_FLOW,
+			       counter_index);
+}
+
 static void mlxsw_sp_txhdr_construct(struct sk_buff *skb,
 				     const struct mlxsw_tx_info *tx_info)
 {
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index dd59a9b..b0500b8 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -679,5 +679,12 @@ int mlxsw_sp_flower_replace(struct mlxsw_sp_port *mlxsw_sp_port, bool ingress,
 			    __be16 protocol, struct tc_cls_flower_offload *f);
 void mlxsw_sp_flower_destroy(struct mlxsw_sp_port *mlxsw_sp_port, bool ingress,
 			     struct tc_cls_flower_offload *f);
+int mlxsw_sp_flow_counter_get(struct mlxsw_sp *mlxsw_sp,
+			      unsigned int counter_index, u64 *packets,
+			      u64 *bytes);
+int mlxsw_sp_flow_counter_alloc(struct mlxsw_sp *mlxsw_sp,
+				unsigned int *p_counter_index);
+void mlxsw_sp_flow_counter_free(struct mlxsw_sp *mlxsw_sp,
+				unsigned int counter_index);
 
 #endif
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.c
index 0cae75c..1631e01 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.c
@@ -52,7 +52,11 @@ struct mlxsw_sp_counter_pool {
 	struct mlxsw_sp_counter_sub_pool *sub_pools;
 };
 
-static struct mlxsw_sp_counter_sub_pool mlxsw_sp_counter_sub_pools[] = {};
+static struct mlxsw_sp_counter_sub_pool mlxsw_sp_counter_sub_pools[] = {
+	[MLXSW_SP_COUNTER_SUB_POOL_FLOW] = {
+		.bank_count = 6,
+	},
+};
 
 static int mlxsw_sp_counter_pool_validate(struct mlxsw_sp *mlxsw_sp)
 {
@@ -69,6 +73,19 @@ static int mlxsw_sp_counter_pool_validate(struct mlxsw_sp *mlxsw_sp)
 	return 0;
 }
 
+static int mlxsw_sp_counter_sub_pools_prepare(struct mlxsw_sp *mlxsw_sp)
+{
+	struct mlxsw_sp_counter_sub_pool *sub_pool;
+
+	/* Prepare generic flow pool*/
+	sub_pool = &mlxsw_sp_counter_sub_pools[MLXSW_SP_COUNTER_SUB_POOL_FLOW];
+	if (!MLXSW_CORE_RES_VALID(mlxsw_sp->core, COUNTER_SIZE_PACKETS_BYTES))
+		return -EIO;
+	sub_pool->entry_size = MLXSW_CORE_RES_GET(mlxsw_sp->core,
+						  COUNTER_SIZE_PACKETS_BYTES);
+	return 0;
+}
+
 int mlxsw_sp_counter_pool_init(struct mlxsw_sp *mlxsw_sp)
 {
 	struct mlxsw_sp_counter_sub_pool *sub_pool;
@@ -85,6 +102,10 @@ int mlxsw_sp_counter_pool_init(struct mlxsw_sp *mlxsw_sp)
 	if (err)
 		return err;
 
+	err = mlxsw_sp_counter_sub_pools_prepare(mlxsw_sp);
+	if (err)
+		return err;
+
 	pool = kzalloc(sizeof(*pool), GFP_KERNEL);
 	if (!pool)
 		return -ENOMEM;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.h
index 5bf42d9..031bc4a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.h
@@ -38,8 +38,7 @@
 #include "spectrum.h"
 
 enum mlxsw_sp_counter_sub_pool_id {
-	/* Placeholder before first pool registered */
-	MLXSW_SP_COUNTER_SUB_POOL_PLACEHOLDER,
+	MLXSW_SP_COUNTER_SUB_POOL_FLOW,
 };
 
 int mlxsw_sp_counter_alloc(struct mlxsw_sp *mlxsw_sp,
-- 
2.7.4
