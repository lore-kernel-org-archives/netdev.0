From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 6/8] mlxsw: spectrum: Support for counters on router interfaces
Date: Tue, 28 Mar 2017 17:24:15 +0200
Message-ID: <1490714657-6116-7-git-send-email-jiri@resnulli.us>
References: <1490714657-6116-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, jhs@mojatatu.com, ivecera@redhat.com,
        roopa@cumulusnetworks.com, f.fainelli@gmail.com,
        vivien.didelot@savoirfairelinux.com, john.fastabend@gmail.com,
        andrew@lunn.ch, simon.horman@netronome.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:35462 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752402AbdC1PZA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 11:25:00 -0400
Received: by mail-wr0-f194.google.com with SMTP id p52so20542153wrc.2
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 08:24:44 -0700 (PDT)
In-Reply-To: <1490714657-6116-1-git-send-email-jiri@resnulli.us>
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
v1->v2:
- fix warning pointed out by DaveM
---
 drivers/net/ethernet/mellanox/mlxsw/resources.h    |   2 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.c |   9 ++
 drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.h |   1 +
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 164 +++++++++++++++++++++
 .../net/ethernet/mellanox/mlxsw/spectrum_router.h  |  56 +++++++
 5 files changed, 232 insertions(+)
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h

diff --git a/drivers/net/ethernet/mellanox/mlxsw/resources.h b/drivers/net/ethernet/mellanox/mlxsw/resources.h
index ee09769..9556d93 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/resources.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/resources.h
@@ -46,6 +46,7 @@ enum mlxsw_res_id {
 	MLXSW_RES_ID_COUNTER_POOL_SIZE,
 	MLXSW_RES_ID_MAX_SPAN,
 	MLXSW_RES_ID_COUNTER_SIZE_PACKETS_BYTES,
+	MLXSW_RES_ID_COUNTER_SIZE_ROUTER_BASIC,
 	MLXSW_RES_ID_MAX_SYSTEM_PORT,
 	MLXSW_RES_ID_MAX_LAG,
 	MLXSW_RES_ID_MAX_LAG_MEMBERS,
@@ -82,6 +83,7 @@ static u16 mlxsw_res_ids[] = {
 	[MLXSW_RES_ID_COUNTER_POOL_SIZE] = 0x2410,
 	[MLXSW_RES_ID_MAX_SPAN] = 0x2420,
 	[MLXSW_RES_ID_COUNTER_SIZE_PACKETS_BYTES] = 0x2443,
+	[MLXSW_RES_ID_COUNTER_SIZE_ROUTER_BASIC] = 0x2449,
 	[MLXSW_RES_ID_MAX_SYSTEM_PORT] = 0x2502,
 	[MLXSW_RES_ID_MAX_LAG] = 0x2520,
 	[MLXSW_RES_ID_MAX_LAG_MEMBERS] = 0x2521,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.c
index 1631e01..0f46775 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.c
@@ -56,6 +56,9 @@ static struct mlxsw_sp_counter_sub_pool mlxsw_sp_counter_sub_pools[] = {
 	[MLXSW_SP_COUNTER_SUB_POOL_FLOW] = {
 		.bank_count = 6,
 	},
+	[MLXSW_SP_COUNTER_SUB_POOL_RIF] = {
+		.bank_count = 2,
+	}
 };
 
 static int mlxsw_sp_counter_pool_validate(struct mlxsw_sp *mlxsw_sp)
@@ -83,6 +86,12 @@ static int mlxsw_sp_counter_sub_pools_prepare(struct mlxsw_sp *mlxsw_sp)
 		return -EIO;
 	sub_pool->entry_size = MLXSW_CORE_RES_GET(mlxsw_sp->core,
 						  COUNTER_SIZE_PACKETS_BYTES);
+	/* Prepare erif pool*/
+	sub_pool = &mlxsw_sp_counter_sub_pools[MLXSW_SP_COUNTER_SUB_POOL_RIF];
+	if (!MLXSW_CORE_RES_VALID(mlxsw_sp->core, COUNTER_SIZE_ROUTER_BASIC))
+		return -EIO;
+	sub_pool->entry_size = MLXSW_CORE_RES_GET(mlxsw_sp->core,
+						  COUNTER_SIZE_ROUTER_BASIC);
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.h
index 031bc4a..fd34d0a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_cnt.h
@@ -39,6 +39,7 @@
 
 enum mlxsw_sp_counter_sub_pool_id {
 	MLXSW_SP_COUNTER_SUB_POOL_FLOW,
+	MLXSW_SP_COUNTER_SUB_POOL_RIF,
 };
 
 int mlxsw_sp_counter_alloc(struct mlxsw_sp *mlxsw_sp,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 905d459..b0e0439 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -52,6 +52,9 @@
 #include "spectrum.h"
 #include "core.h"
 #include "reg.h"
+#include "spectrum_cnt.h"
+#include "spectrum_dpipe.h"
+#include "spectrum_router.h"
 
 struct mlxsw_sp_rif {
 	struct list_head nexthop_list;
@@ -62,8 +65,157 @@ struct mlxsw_sp_rif {
 	int mtu;
 	u16 rif_index;
 	u16 vr_id;
+	unsigned int counter_ingress;
+	bool counter_ingress_valid;
+	unsigned int counter_egress;
+	bool counter_egress_valid;
 };
 
+static unsigned int *
+mlxsw_sp_rif_p_counter_get(struct mlxsw_sp_rif *rif,
+			   enum mlxsw_sp_rif_counter_dir dir)
+{
+	switch (dir) {
+	case MLXSW_SP_RIF_COUNTER_EGRESS:
+		return &rif->counter_egress;
+	case MLXSW_SP_RIF_COUNTER_INGRESS:
+		return &rif->counter_ingress;
+	}
+	return NULL;
+}
+
+static bool
+mlxsw_sp_rif_counter_valid_get(struct mlxsw_sp_rif *rif,
+			       enum mlxsw_sp_rif_counter_dir dir)
+{
+	switch (dir) {
+	case MLXSW_SP_RIF_COUNTER_EGRESS:
+		return rif->counter_egress_valid;
+	case MLXSW_SP_RIF_COUNTER_INGRESS:
+		return rif->counter_ingress_valid;
+	}
+	return false;
+}
+
+static void
+mlxsw_sp_rif_counter_valid_set(struct mlxsw_sp_rif *rif,
+			       enum mlxsw_sp_rif_counter_dir dir,
+			       bool valid)
+{
+	switch (dir) {
+	case MLXSW_SP_RIF_COUNTER_EGRESS:
+		rif->counter_egress_valid = valid;
+		break;
+	case MLXSW_SP_RIF_COUNTER_INGRESS:
+		rif->counter_ingress_valid = valid;
+		break;
+	}
+}
+
+static int mlxsw_sp_rif_counter_edit(struct mlxsw_sp *mlxsw_sp, u16 rif_index,
+				     unsigned int counter_index, bool enable,
+				     enum mlxsw_sp_rif_counter_dir dir)
+{
+	char ritr_pl[MLXSW_REG_RITR_LEN];
+	bool is_egress = false;
+	int err;
+
+	if (dir == MLXSW_SP_RIF_COUNTER_EGRESS)
+		is_egress = true;
+	mlxsw_reg_ritr_rif_pack(ritr_pl, rif_index);
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
+				   struct mlxsw_sp_rif *rif,
+				   enum mlxsw_sp_rif_counter_dir dir, u64 *cnt)
+{
+	char ricnt_pl[MLXSW_REG_RICNT_LEN];
+	unsigned int *p_counter_index;
+	bool valid;
+	int err;
+
+	valid = mlxsw_sp_rif_counter_valid_get(rif, dir);
+	if (!valid)
+		return -EINVAL;
+
+	p_counter_index = mlxsw_sp_rif_p_counter_get(rif, dir);
+	if (!p_counter_index)
+		return -EINVAL;
+	mlxsw_reg_ricnt_pack(ricnt_pl, *p_counter_index,
+			     MLXSW_REG_RICNT_OPCODE_NOP);
+	err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(ricnt), ricnt_pl);
+	if (err)
+		return err;
+	*cnt = mlxsw_reg_ricnt_good_unicast_packets_get(ricnt_pl);
+	return 0;
+}
+
+static int mlxsw_sp_rif_counter_clear(struct mlxsw_sp *mlxsw_sp,
+				      unsigned int counter_index)
+{
+	char ricnt_pl[MLXSW_REG_RICNT_LEN];
+
+	mlxsw_reg_ricnt_pack(ricnt_pl, counter_index,
+			     MLXSW_REG_RICNT_OPCODE_CLEAR);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ricnt), ricnt_pl);
+}
+
+int mlxsw_sp_rif_counter_alloc(struct mlxsw_sp *mlxsw_sp,
+			       struct mlxsw_sp_rif *rif,
+			       enum mlxsw_sp_rif_counter_dir dir)
+{
+	unsigned int *p_counter_index;
+	int err;
+
+	p_counter_index = mlxsw_sp_rif_p_counter_get(rif, dir);
+	if (!p_counter_index)
+		return -EINVAL;
+	err = mlxsw_sp_counter_alloc(mlxsw_sp, MLXSW_SP_COUNTER_SUB_POOL_RIF,
+				     p_counter_index);
+	if (err)
+		return err;
+
+	err = mlxsw_sp_rif_counter_clear(mlxsw_sp, *p_counter_index);
+	if (err)
+		goto err_counter_clear;
+
+	err = mlxsw_sp_rif_counter_edit(mlxsw_sp, rif->rif_index,
+					*p_counter_index, true, dir);
+	if (err)
+		goto err_counter_edit;
+	mlxsw_sp_rif_counter_valid_set(rif, dir, true);
+	return 0;
+
+err_counter_edit:
+err_counter_clear:
+	mlxsw_sp_counter_free(mlxsw_sp, MLXSW_SP_COUNTER_SUB_POOL_RIF,
+			      *p_counter_index);
+	return err;
+}
+
+void mlxsw_sp_rif_counter_free(struct mlxsw_sp *mlxsw_sp,
+			       struct mlxsw_sp_rif *rif,
+			       enum mlxsw_sp_rif_counter_dir dir)
+{
+	unsigned int *p_counter_index;
+
+	p_counter_index = mlxsw_sp_rif_p_counter_get(rif, dir);
+	if (WARN_ON(!p_counter_index))
+		return;
+	mlxsw_sp_rif_counter_edit(mlxsw_sp, rif->rif_index,
+				  *p_counter_index, false, dir);
+	mlxsw_sp_counter_free(mlxsw_sp, MLXSW_SP_COUNTER_SUB_POOL_RIF,
+			      *p_counter_index);
+	mlxsw_sp_rif_counter_valid_set(rif, dir, false);
+}
+
 static struct mlxsw_sp_rif *
 mlxsw_sp_rif_find_by_dev(const struct mlxsw_sp *mlxsw_sp,
 			 const struct net_device *dev);
@@ -2822,6 +2974,15 @@ mlxsw_sp_vport_rif_sp_create(struct mlxsw_sp_port *mlxsw_sp_vport,
 		goto err_rif_alloc;
 	}
 
+	if (devlink_dpipe_table_counter_enabled(priv_to_devlink(mlxsw_sp->core),
+						MLXSW_SP_DPIPE_TABLE_NAME_ERIF)) {
+		err = mlxsw_sp_rif_counter_alloc(mlxsw_sp, rif,
+						 MLXSW_SP_RIF_COUNTER_EGRESS);
+		if (err)
+			netdev_dbg(mlxsw_sp_vport->dev,
+				   "Counter alloc Failed err=%d\n", err);
+	}
+
 	f->rif = rif;
 	mlxsw_sp->rifs[rif_index] = rif;
 	vr->rif_count++;
@@ -2852,6 +3013,9 @@ static void mlxsw_sp_vport_rif_sp_destroy(struct mlxsw_sp_port *mlxsw_sp_vport,
 
 	mlxsw_sp_router_rif_gone_sync(mlxsw_sp, rif);
 
+	mlxsw_sp_rif_counter_free(mlxsw_sp, rif, MLXSW_SP_RIF_COUNTER_EGRESS);
+	mlxsw_sp_rif_counter_free(mlxsw_sp, rif, MLXSW_SP_RIF_COUNTER_INGRESS);
+
 	vr->rif_count--;
 	mlxsw_sp->rifs[rif_index] = NULL;
 	f->rif = NULL;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
new file mode 100644
index 0000000..f469dc9
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
@@ -0,0 +1,56 @@
+/*
+ * drivers/net/ethernet/mellanox/mlxsw/spectrum_router.h
+ * Copyright (c) 2017 Mellanox Technologies. All rights reserved.
+ * Copyright (c) 2017 Arkadi Sharshevsky <arkadis@mellanox.com>
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in the
+ *    documentation and/or other materials provided with the distribution.
+ * 3. Neither the names of the copyright holders nor the names of its
+ *    contributors may be used to endorse or promote products derived from
+ *    this software without specific prior written permission.
+ *
+ * Alternatively, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") version 2 as published by the Free
+ * Software Foundation.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
+ * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
+ * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
+ * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
+ * POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#ifndef _MLXSW_ROUTER_H_
+#define _MLXSW_ROUTER_H_
+
+#include "spectrum.h"
+
+enum mlxsw_sp_rif_counter_dir {
+	MLXSW_SP_RIF_COUNTER_INGRESS,
+	MLXSW_SP_RIF_COUNTER_EGRESS,
+};
+
+int mlxsw_sp_rif_counter_value_get(struct mlxsw_sp *mlxsw_sp,
+				   struct mlxsw_sp_rif *rif,
+				   enum mlxsw_sp_rif_counter_dir dir,
+				   u64 *cnt);
+void mlxsw_sp_rif_counter_free(struct mlxsw_sp *mlxsw_sp,
+			       struct mlxsw_sp_rif *rif,
+			       enum mlxsw_sp_rif_counter_dir dir);
+int mlxsw_sp_rif_counter_alloc(struct mlxsw_sp *mlxsw_sp,
+			       struct mlxsw_sp_rif *rif,
+			       enum mlxsw_sp_rif_counter_dir dir);
+
+#endif /* _MLXSW_ROUTER_H_*/
-- 
2.7.4
