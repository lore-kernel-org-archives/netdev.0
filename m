From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 6/6] mlxsw: Convert resources into array
Date: Fri, 21 Oct 2016 16:07:23 +0200
Message-ID: <1477058843-9981-7-git-send-email-jiri@resnulli.us>
References: <1477058843-9981-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:35997 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932708AbcJUOHh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 10:07:37 -0400
Received: by mail-lf0-f68.google.com with SMTP id b75so6097373lfg.3
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 07:07:36 -0700 (PDT)
In-Reply-To: <1477058843-9981-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Since the number of resources is going to get much bigger, ease up the
addition by simly defining IDs. Convert the existing structure members
to a set array, one for validity, one for values. Introduce a set of
getters and setters for easy access.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.c         |  32 ++++--
 drivers/net/ethernet/mellanox/mlxsw/core.h         |  44 ++-----
 drivers/net/ethernet/mellanox/mlxsw/pci.c          | 127 ++++++---------------
 drivers/net/ethernet/mellanox/mlxsw/resources.h    | 121 ++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  38 +++---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   5 +-
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  |  39 +++----
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   |   7 +-
 8 files changed, 223 insertions(+), 190 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/resources.h

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index aa33d58..a37d471 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -67,6 +67,7 @@
 #include "trap.h"
 #include "emad.h"
 #include "reg.h"
+#include "resources.h"
 
 static LIST_HEAD(mlxsw_core_driver_list);
 static DEFINE_SPINLOCK(mlxsw_core_driver_list_lock);
@@ -111,7 +112,7 @@ struct mlxsw_core {
 	struct {
 		u8 *mapping; /* lag_id+port_index to local_port mapping */
 	} lag;
-	struct mlxsw_resources resources;
+	struct mlxsw_res res;
 	struct mlxsw_hwmon *hwmon;
 	unsigned long driver_priv[0];
 	/* driver_priv has to be always the last item */
@@ -1101,14 +1102,15 @@ int mlxsw_core_bus_device_register(const struct mlxsw_bus_info *mlxsw_bus_info,
 	}
 
 	err = mlxsw_bus->init(bus_priv, mlxsw_core, mlxsw_driver->profile,
-			      &mlxsw_core->resources);
+			      &mlxsw_core->res);
 	if (err)
 		goto err_bus_init;
 
-	if (mlxsw_core->resources.max_lag_valid &&
-	    mlxsw_core->resources.max_ports_in_lag_valid) {
-		alloc_size = sizeof(u8) * mlxsw_core->resources.max_lag *
-			mlxsw_core->resources.max_ports_in_lag;
+	if (MLXSW_CORE_RES_VALID(mlxsw_core, MAX_LAG) &&
+	    MLXSW_CORE_RES_VALID(mlxsw_core, MAX_LAG_MEMBERS)) {
+		alloc_size = sizeof(u8) *
+			MLXSW_CORE_RES_GET(mlxsw_core, MAX_LAG) *
+			MLXSW_CORE_RES_GET(mlxsw_core, MAX_LAG_MEMBERS);
 		mlxsw_core->lag.mapping = kzalloc(alloc_size, GFP_KERNEL);
 		if (!mlxsw_core->lag.mapping) {
 			err = -ENOMEM;
@@ -1615,7 +1617,7 @@ EXPORT_SYMBOL(mlxsw_core_skb_receive);
 static int mlxsw_core_lag_mapping_index(struct mlxsw_core *mlxsw_core,
 					u16 lag_id, u8 port_index)
 {
-	return mlxsw_core->resources.max_ports_in_lag * lag_id +
+	return MLXSW_CORE_RES_GET(mlxsw_core, MAX_LAG_MEMBERS) * lag_id +
 	       port_index;
 }
 
@@ -1644,7 +1646,7 @@ void mlxsw_core_lag_mapping_clear(struct mlxsw_core *mlxsw_core,
 {
 	int i;
 
-	for (i = 0; i < mlxsw_core->resources.max_ports_in_lag; i++) {
+	for (i = 0; i < MLXSW_CORE_RES_GET(mlxsw_core, MAX_LAG_MEMBERS); i++) {
 		int index = mlxsw_core_lag_mapping_index(mlxsw_core,
 							 lag_id, i);
 
@@ -1654,11 +1656,19 @@ void mlxsw_core_lag_mapping_clear(struct mlxsw_core *mlxsw_core,
 }
 EXPORT_SYMBOL(mlxsw_core_lag_mapping_clear);
 
-struct mlxsw_resources *mlxsw_core_resources_get(struct mlxsw_core *mlxsw_core)
+bool mlxsw_core_res_valid(struct mlxsw_core *mlxsw_core,
+			  enum mlxsw_res_id res_id)
 {
-	return &mlxsw_core->resources;
+	return mlxsw_res_valid(&mlxsw_core->res, res_id);
 }
-EXPORT_SYMBOL(mlxsw_core_resources_get);
+EXPORT_SYMBOL(mlxsw_core_res_valid);
+
+u64 mlxsw_core_res_get(struct mlxsw_core *mlxsw_core,
+		       enum mlxsw_res_id res_id)
+{
+	return mlxsw_res_get(&mlxsw_core->res, res_id);
+}
+EXPORT_SYMBOL(mlxsw_core_res_get);
 
 int mlxsw_core_port_init(struct mlxsw_core *mlxsw_core,
 			 struct mlxsw_core_port *mlxsw_core_port, u8 local_port,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index c4f550b..94a846d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -48,8 +48,8 @@
 
 #include "trap.h"
 #include "reg.h"
-
 #include "cmd.h"
+#include "resources.h"
 
 #define MLXSW_MODULE_ALIAS_PREFIX "mlxsw-driver-"
 #define MODULE_MLXSW_DRIVER_ALIAS(kind)	\
@@ -266,45 +266,23 @@ struct mlxsw_driver {
 	const struct mlxsw_config_profile *profile;
 };
 
-struct mlxsw_resources {
-	u32	max_span_valid:1,
-		max_lag_valid:1,
-		max_ports_in_lag_valid:1,
-		kvd_size_valid:1,
-		kvd_single_min_size_valid:1,
-		kvd_double_min_size_valid:1,
-		max_virtual_routers_valid:1,
-		max_system_ports_valid:1,
-		max_vlan_groups_valid:1,
-		max_regions_valid:1,
-		max_rif_valid:1;
-	u8      max_span;
-	u8	max_lag;
-	u8	max_ports_in_lag;
-	u32	kvd_size;
-	u32	kvd_single_min_size;
-	u32	kvd_double_min_size;
-	u16     max_virtual_routers;
-	u16	max_system_ports;
-	u16	max_vlan_groups;
-	u16	max_regions;
-	u16	max_rif;
+bool mlxsw_core_res_valid(struct mlxsw_core *mlxsw_core,
+			  enum mlxsw_res_id res_id);
 
-	/* Internal resources.
-	 * Determined by the SW, not queried from the HW.
-	 */
-	u32	kvd_single_size;
-	u32	kvd_double_size;
-	u32	kvd_linear_size;
-};
+#define MLXSW_CORE_RES_VALID(res, short_res_id)			\
+	mlxsw_core_res_valid(res, MLXSW_RES_ID_##short_res_id)
+
+u64 mlxsw_core_res_get(struct mlxsw_core *mlxsw_core,
+		       enum mlxsw_res_id res_id);
 
-struct mlxsw_resources *mlxsw_core_resources_get(struct mlxsw_core *mlxsw_core);
+#define MLXSW_CORE_RES_GET(res, short_res_id)			\
+	mlxsw_core_res_get(res, MLXSW_RES_ID_##short_res_id)
 
 struct mlxsw_bus {
 	const char *kind;
 	int (*init)(void *bus_priv, struct mlxsw_core *mlxsw_core,
 		    const struct mlxsw_config_profile *profile,
-		    struct mlxsw_resources *resources);
+		    struct mlxsw_res *res);
 	void (*fini)(void *bus_priv);
 	bool (*skb_transmit_busy)(void *bus_priv,
 				  const struct mlxsw_tx_info *tx_info);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.c b/drivers/net/ethernet/mellanox/mlxsw/pci.c
index c3b1663..c88f2ab 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.c
@@ -52,6 +52,7 @@
 #include "core.h"
 #include "cmd.h"
 #include "port.h"
+#include "resources.h"
 
 static const char mlxsw_pci_driver_name[] = "mlxsw_pci";
 
@@ -1155,73 +1156,8 @@ mlxsw_pci_config_profile_swid_config(struct mlxsw_pci *mlxsw_pci,
 	mlxsw_cmd_mbox_config_profile_swid_config_mask_set(mbox, index, mask);
 }
 
-#define MLXSW_MAX_SPAN_ID 0x2420
-#define MLXSW_MAX_LAG_ID 0x2520
-#define MLXSW_MAX_PORTS_IN_LAG_ID 0x2521
-#define MLXSW_KVD_SIZE_ID 0x1001
-#define MLXSW_KVD_SINGLE_MIN_SIZE_ID 0x1002
-#define MLXSW_KVD_DOUBLE_MIN_SIZE_ID 0x1003
-#define MLXSW_MAX_VIRTUAL_ROUTERS_ID 0x2C01
-#define MLXSW_MAX_SYSTEM_PORT_ID 0x2502
-#define MLXSW_MAX_VLAN_GROUPS_ID 0x2906
-#define MLXSW_MAX_REGIONS_ID 0x2901
-#define MLXSW_MAX_RIF_ID 0x2C02
-
-static void mlxsw_pci_resources_query_parse(int id, u64 val,
-					    struct mlxsw_resources *resources)
-{
-	switch (id) {
-	case MLXSW_MAX_SPAN_ID:
-		resources->max_span = val;
-		resources->max_span_valid = 1;
-		break;
-	case MLXSW_MAX_LAG_ID:
-		resources->max_lag = val;
-		resources->max_lag_valid = 1;
-		break;
-	case MLXSW_MAX_PORTS_IN_LAG_ID:
-		resources->max_ports_in_lag = val;
-		resources->max_ports_in_lag_valid = 1;
-		break;
-	case MLXSW_KVD_SIZE_ID:
-		resources->kvd_size = val;
-		resources->kvd_size_valid = 1;
-		break;
-	case MLXSW_KVD_SINGLE_MIN_SIZE_ID:
-		resources->kvd_single_min_size = val;
-		resources->kvd_single_min_size_valid = 1;
-		break;
-	case MLXSW_KVD_DOUBLE_MIN_SIZE_ID:
-		resources->kvd_double_min_size = val;
-		resources->kvd_double_min_size_valid = 1;
-		break;
-	case MLXSW_MAX_VIRTUAL_ROUTERS_ID:
-		resources->max_virtual_routers = val;
-		resources->max_virtual_routers_valid = 1;
-		break;
-	case MLXSW_MAX_SYSTEM_PORT_ID:
-		resources->max_system_ports = val;
-		resources->max_system_ports_valid = 1;
-		break;
-	case MLXSW_MAX_VLAN_GROUPS_ID:
-		resources->max_vlan_groups = val;
-		resources->max_vlan_groups_valid = 1;
-		break;
-	case MLXSW_MAX_REGIONS_ID:
-		resources->max_regions = val;
-		resources->max_regions_valid = 1;
-		break;
-	case MLXSW_MAX_RIF_ID:
-		resources->max_rif = val;
-		resources->max_rif_valid = 1;
-		break;
-	default:
-		break;
-	}
-}
-
 static int mlxsw_pci_resources_query(struct mlxsw_pci *mlxsw_pci, char *mbox,
-				     struct mlxsw_resources *resources,
+				     struct mlxsw_res *res,
 				     u8 query_enabled)
 {
 	int index, i;
@@ -1248,7 +1184,7 @@ static int mlxsw_pci_resources_query(struct mlxsw_pci *mlxsw_pci, char *mbox,
 			if (id == MLXSW_CMD_QUERY_RESOURCES_TABLE_END_ID)
 				return 0;
 
-			mlxsw_pci_resources_query_parse(id, data, resources);
+			mlxsw_res_parse(res, id, data);
 		}
 	}
 
@@ -1258,13 +1194,14 @@ static int mlxsw_pci_resources_query(struct mlxsw_pci *mlxsw_pci, char *mbox,
 	return -EIO;
 }
 
-static int mlxsw_pci_profile_get_kvd_sizes(const struct mlxsw_config_profile *profile,
-					   struct mlxsw_resources *resources)
+static int
+mlxsw_pci_profile_get_kvd_sizes(const struct mlxsw_config_profile *profile,
+				struct mlxsw_res *res)
 {
-	u32 singles_size, doubles_size, linear_size;
+	u32 single_size, double_size, linear_size;
 
-	if (!resources->kvd_single_min_size_valid ||
-	    !resources->kvd_double_min_size_valid ||
+	if (!MLXSW_RES_VALID(res, KVD_SINGLE_MIN_SIZE) ||
+	    !MLXSW_RES_VALID(res, KVD_DOUBLE_MIN_SIZE) ||
 	    !profile->used_kvd_split_data)
 		return -EIO;
 
@@ -1276,31 +1213,31 @@ static int mlxsw_pci_profile_get_kvd_sizes(const struct mlxsw_config_profile *pr
 	 * Both sizes must be a multiplications of the
 	 * granularity from the profile.
 	 */
-	doubles_size = (resources->kvd_size - linear_size);
-	doubles_size *= profile->kvd_hash_double_parts;
-	doubles_size /= (profile->kvd_hash_double_parts +
-			 profile->kvd_hash_single_parts);
-	doubles_size /= profile->kvd_hash_granularity;
-	doubles_size *= profile->kvd_hash_granularity;
-	singles_size = resources->kvd_size - doubles_size -
-		       linear_size;
+	double_size = MLXSW_RES_GET(res, KVD_SIZE) - linear_size;
+	double_size *= profile->kvd_hash_double_parts;
+	double_size /= profile->kvd_hash_double_parts +
+		       profile->kvd_hash_single_parts;
+	double_size /= profile->kvd_hash_granularity;
+	double_size *= profile->kvd_hash_granularity;
+	single_size = MLXSW_RES_GET(res, KVD_SIZE) - double_size -
+		      linear_size;
 
 	/* Check results are legal. */
-	if (singles_size < resources->kvd_single_min_size ||
-	    doubles_size < resources->kvd_double_min_size ||
-	    resources->kvd_size < linear_size)
+	if (single_size < MLXSW_RES_GET(res, KVD_SINGLE_MIN_SIZE) ||
+	    double_size < MLXSW_RES_GET(res, KVD_DOUBLE_MIN_SIZE) ||
+	    MLXSW_RES_GET(res, KVD_SIZE) < linear_size)
 		return -EIO;
 
-	resources->kvd_single_size = singles_size;
-	resources->kvd_double_size = doubles_size;
-	resources->kvd_linear_size = linear_size;
+	MLXSW_RES_SET(res, KVD_SINGLE_SIZE, single_size);
+	MLXSW_RES_SET(res, KVD_DOUBLE_SIZE, double_size);
+	MLXSW_RES_SET(res, KVD_LINEAR_SIZE, linear_size);
 
 	return 0;
 }
 
 static int mlxsw_pci_config_profile(struct mlxsw_pci *mlxsw_pci, char *mbox,
 				    const struct mlxsw_config_profile *profile,
-				    struct mlxsw_resources *resources)
+				    struct mlxsw_res *res)
 {
 	int i;
 	int err;
@@ -1389,22 +1326,22 @@ static int mlxsw_pci_config_profile(struct mlxsw_pci *mlxsw_pci, char *mbox,
 		mlxsw_cmd_mbox_config_profile_adaptive_routing_group_cap_set(
 			mbox, profile->adaptive_routing_group_cap);
 	}
-	if (resources->kvd_size_valid) {
-		err = mlxsw_pci_profile_get_kvd_sizes(profile, resources);
+	if (MLXSW_RES_VALID(res, KVD_SIZE)) {
+		err = mlxsw_pci_profile_get_kvd_sizes(profile, res);
 		if (err)
 			return err;
 
 		mlxsw_cmd_mbox_config_profile_set_kvd_linear_size_set(mbox, 1);
 		mlxsw_cmd_mbox_config_profile_kvd_linear_size_set(mbox,
-						resources->kvd_linear_size);
+					MLXSW_RES_GET(res, KVD_LINEAR_SIZE));
 		mlxsw_cmd_mbox_config_profile_set_kvd_hash_single_size_set(mbox,
 									   1);
 		mlxsw_cmd_mbox_config_profile_kvd_hash_single_size_set(mbox,
-						resources->kvd_single_size);
+					MLXSW_RES_GET(res, KVD_SINGLE_SIZE));
 		mlxsw_cmd_mbox_config_profile_set_kvd_hash_double_size_set(
 								mbox, 1);
 		mlxsw_cmd_mbox_config_profile_kvd_hash_double_size_set(mbox,
-						resources->kvd_double_size);
+					MLXSW_RES_GET(res, KVD_DOUBLE_SIZE));
 	}
 
 	for (i = 0; i < MLXSW_CONFIG_PROFILE_SWID_COUNT; i++)
@@ -1542,7 +1479,7 @@ static void mlxsw_pci_mbox_free(struct mlxsw_pci *mlxsw_pci,
 
 static int mlxsw_pci_init(void *bus_priv, struct mlxsw_core *mlxsw_core,
 			  const struct mlxsw_config_profile *profile,
-			  struct mlxsw_resources *resources)
+			  struct mlxsw_res *res)
 {
 	struct mlxsw_pci *mlxsw_pci = bus_priv;
 	struct pci_dev *pdev = mlxsw_pci->pdev;
@@ -1601,12 +1538,12 @@ static int mlxsw_pci_init(void *bus_priv, struct mlxsw_core *mlxsw_core,
 	if (err)
 		goto err_boardinfo;
 
-	err = mlxsw_pci_resources_query(mlxsw_pci, mbox, resources,
+	err = mlxsw_pci_resources_query(mlxsw_pci, mbox, res,
 					profile->resource_query_enable);
 	if (err)
 		goto err_query_resources;
 
-	err = mlxsw_pci_config_profile(mlxsw_pci, mbox, profile, resources);
+	err = mlxsw_pci_config_profile(mlxsw_pci, mbox, profile, res);
 	if (err)
 		goto err_config_profile;
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/resources.h b/drivers/net/ethernet/mellanox/mlxsw/resources.h
new file mode 100644
index 0000000..a031e45
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlxsw/resources.h
@@ -0,0 +1,121 @@
+/*
+ * drivers/net/ethernet/mellanox/mlxsw/resources.h
+ * Copyright (c) 2016 Mellanox Technologies. All rights reserved.
+ * Copyright (c) 2016 Jiri Pirko <jiri@mellanox.com>
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
+#ifndef _MLXSW_RESOURCES_H
+#define _MLXSW_RESOURCES_H
+
+#include <linux/kernel.h>
+#include <linux/types.h>
+
+enum mlxsw_res_id {
+	MLXSW_RES_ID_KVD_SIZE,
+	MLXSW_RES_ID_KVD_SINGLE_MIN_SIZE,
+	MLXSW_RES_ID_KVD_DOUBLE_MIN_SIZE,
+	MLXSW_RES_ID_MAX_SPAN,
+	MLXSW_RES_ID_MAX_SYSTEM_PORT,
+	MLXSW_RES_ID_MAX_LAG,
+	MLXSW_RES_ID_MAX_LAG_MEMBERS,
+	MLXSW_RES_ID_MAX_VRS,
+	MLXSW_RES_ID_MAX_RIFS,
+
+	/* Internal resources.
+	 * Determined by the SW, not queried from the HW.
+	 */
+	MLXSW_RES_ID_KVD_SINGLE_SIZE,
+	MLXSW_RES_ID_KVD_DOUBLE_SIZE,
+	MLXSW_RES_ID_KVD_LINEAR_SIZE,
+
+	__MLXSW_RES_ID_MAX,
+};
+
+static u16 mlxsw_res_ids[] = {
+	[MLXSW_RES_ID_KVD_SIZE] = 0x1001,
+	[MLXSW_RES_ID_KVD_SINGLE_MIN_SIZE] = 0x1002,
+	[MLXSW_RES_ID_KVD_DOUBLE_MIN_SIZE] = 0x1003,
+	[MLXSW_RES_ID_MAX_SPAN] = 0x2420,
+	[MLXSW_RES_ID_MAX_SYSTEM_PORT] = 0x2502,
+	[MLXSW_RES_ID_MAX_LAG] = 0x2520,
+	[MLXSW_RES_ID_MAX_LAG_MEMBERS] = 0x2521,
+	[MLXSW_RES_ID_MAX_VRS] = 0x2C01,
+	[MLXSW_RES_ID_MAX_RIFS] = 0x2C02,
+};
+
+struct mlxsw_res {
+	bool valid[__MLXSW_RES_ID_MAX];
+	u64 values[__MLXSW_RES_ID_MAX];
+};
+
+static inline bool mlxsw_res_valid(struct mlxsw_res *res,
+				   enum mlxsw_res_id res_id)
+{
+	return res->valid[res_id];
+}
+
+#define MLXSW_RES_VALID(res, short_res_id)			\
+	mlxsw_res_valid(res, MLXSW_RES_ID_##short_res_id)
+
+static inline u64 mlxsw_res_get(struct mlxsw_res *res,
+				enum mlxsw_res_id res_id)
+{
+	if (WARN_ON(!res->valid[res_id]))
+		return 0;
+	return res->values[res_id];
+}
+
+#define MLXSW_RES_GET(res, short_res_id)			\
+	mlxsw_res_get(res, MLXSW_RES_ID_##short_res_id)
+
+static inline void mlxsw_res_set(struct mlxsw_res *res,
+				 enum mlxsw_res_id res_id, u64 value)
+{
+	res->valid[res_id] = true;
+	res->values[res_id] = value;
+}
+
+#define MLXSW_RES_SET(res, short_res_id, value)			\
+	mlxsw_res_set(res, MLXSW_RES_ID_##short_res_id, value)
+
+static inline void mlxsw_res_parse(struct mlxsw_res *res, u16 id, u64 value)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(mlxsw_res_ids); i++) {
+		if (mlxsw_res_ids[i] == id) {
+			mlxsw_res_set(res, i, value);
+			return;
+		}
+	}
+}
+
+#endif
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 991a320..5d8f1d5 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -168,14 +168,13 @@ static int mlxsw_sp_base_mac_get(struct mlxsw_sp *mlxsw_sp)
 
 static int mlxsw_sp_span_init(struct mlxsw_sp *mlxsw_sp)
 {
-	struct mlxsw_resources *resources;
 	int i;
 
-	resources = mlxsw_core_resources_get(mlxsw_sp->core);
-	if (!resources->max_span_valid)
+	if (!MLXSW_CORE_RES_VALID(mlxsw_sp->core, MAX_SPAN))
 		return -EIO;
 
-	mlxsw_sp->span.entries_count = resources->max_span;
+	mlxsw_sp->span.entries_count = MLXSW_CORE_RES_GET(mlxsw_sp->core,
+							  MAX_SPAN);
 	mlxsw_sp->span.entries = kcalloc(mlxsw_sp->span.entries_count,
 					 sizeof(struct mlxsw_sp_span_entry),
 					 GFP_KERNEL);
@@ -2892,7 +2891,6 @@ static int mlxsw_sp_flood_init(struct mlxsw_sp *mlxsw_sp)
 
 static int mlxsw_sp_lag_init(struct mlxsw_sp *mlxsw_sp)
 {
-	struct mlxsw_resources *resources;
 	char slcr_pl[MLXSW_REG_SLCR_LEN];
 	int err;
 
@@ -2909,11 +2907,11 @@ static int mlxsw_sp_lag_init(struct mlxsw_sp *mlxsw_sp)
 	if (err)
 		return err;
 
-	resources = mlxsw_core_resources_get(mlxsw_sp->core);
-	if (!(resources->max_lag_valid && resources->max_ports_in_lag_valid))
+	if (!MLXSW_CORE_RES_VALID(mlxsw_sp->core, MAX_LAG) ||
+	    !MLXSW_CORE_RES_VALID(mlxsw_sp->core, MAX_LAG_MEMBERS))
 		return -EIO;
 
-	mlxsw_sp->lags = kcalloc(resources->max_lag,
+	mlxsw_sp->lags = kcalloc(MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_LAG),
 				 sizeof(struct mlxsw_sp_upper),
 				 GFP_KERNEL);
 	if (!mlxsw_sp->lags)
@@ -3183,11 +3181,9 @@ static bool mlxsw_sp_rif_should_config(struct mlxsw_sp_rif *r,
 
 static int mlxsw_sp_avail_rif_get(struct mlxsw_sp *mlxsw_sp)
 {
-	struct mlxsw_resources *resources;
 	int i;
 
-	resources = mlxsw_core_resources_get(mlxsw_sp->core);
-	for (i = 0; i < resources->max_rif; i++)
+	for (i = 0; i < MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_RIFS); i++)
 		if (!mlxsw_sp->rifs[i])
 			return i;
 
@@ -3710,14 +3706,15 @@ static bool mlxsw_sp_port_fdb_should_flush(struct mlxsw_sp_port *mlxsw_sp_port,
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	u8 local_port = mlxsw_sp_port->local_port;
 	u16 lag_id = mlxsw_sp_port->lag_id;
-	struct mlxsw_resources *resources;
+	u64 max_lag_members;
 	int i, count = 0;
 
 	if (!mlxsw_sp_port->lagged)
 		return true;
 
-	resources = mlxsw_core_resources_get(mlxsw_sp->core);
-	for (i = 0; i < resources->max_ports_in_lag; i++) {
+	max_lag_members = MLXSW_CORE_RES_GET(mlxsw_sp->core,
+					     MAX_LAG_MEMBERS);
+	for (i = 0; i < max_lag_members; i++) {
 		struct mlxsw_sp_port *lag_port;
 
 		lag_port = mlxsw_sp_port_lagged_get(mlxsw_sp, lag_id, i);
@@ -3923,13 +3920,13 @@ static int mlxsw_sp_lag_index_get(struct mlxsw_sp *mlxsw_sp,
 				  struct net_device *lag_dev,
 				  u16 *p_lag_id)
 {
-	struct mlxsw_resources *resources;
 	struct mlxsw_sp_upper *lag;
 	int free_lag_id = -1;
+	u64 max_lag;
 	int i;
 
-	resources = mlxsw_core_resources_get(mlxsw_sp->core);
-	for (i = 0; i < resources->max_lag; i++) {
+	max_lag = MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_LAG);
+	for (i = 0; i < max_lag; i++) {
 		lag = mlxsw_sp_lag_get(mlxsw_sp, i);
 		if (lag->ref_count) {
 			if (lag->dev == lag_dev) {
@@ -3963,11 +3960,12 @@ mlxsw_sp_master_lag_check(struct mlxsw_sp *mlxsw_sp,
 static int mlxsw_sp_port_lag_index_get(struct mlxsw_sp *mlxsw_sp,
 				       u16 lag_id, u8 *p_port_index)
 {
-	struct mlxsw_resources *resources;
+	u64 max_lag_members;
 	int i;
 
-	resources = mlxsw_core_resources_get(mlxsw_sp->core);
-	for (i = 0; i < resources->max_ports_in_lag; i++) {
+	max_lag_members = MLXSW_CORE_RES_GET(mlxsw_sp->core,
+					     MAX_LAG_MEMBERS);
+	for (i = 0; i < max_lag_members; i++) {
 		if (!mlxsw_sp_port_lagged_get(mlxsw_sp, lag_id, i)) {
 			*p_port_index = i;
 			return 0;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 9b22863..cc54625 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -479,12 +479,9 @@ static inline struct mlxsw_sp_rif *
 mlxsw_sp_rif_find_by_dev(const struct mlxsw_sp *mlxsw_sp,
 			 const struct net_device *dev)
 {
-	struct mlxsw_resources *resources;
 	int i;
 
-	resources = mlxsw_core_resources_get(mlxsw_sp->core);
-
-	for (i = 0; i < resources->max_rif; i++)
+	for (i = 0; i < MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_RIFS); i++)
 		if (mlxsw_sp->rifs[i] && mlxsw_sp->rifs[i]->dev == dev)
 			return mlxsw_sp->rifs[i];
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 78fc557d..113f667 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -379,12 +379,10 @@ static void mlxsw_sp_lpm_init(struct mlxsw_sp *mlxsw_sp)
 
 static struct mlxsw_sp_vr *mlxsw_sp_vr_find_unused(struct mlxsw_sp *mlxsw_sp)
 {
-	struct mlxsw_resources *resources;
 	struct mlxsw_sp_vr *vr;
 	int i;
 
-	resources = mlxsw_core_resources_get(mlxsw_sp->core);
-	for (i = 0; i < resources->max_virtual_routers; i++) {
+	for (i = 0; i < MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_VRS); i++) {
 		vr = &mlxsw_sp->router.vrs[i];
 		if (!vr->used)
 			return vr;
@@ -426,14 +424,12 @@ static struct mlxsw_sp_vr *mlxsw_sp_vr_find(struct mlxsw_sp *mlxsw_sp,
 					    u32 tb_id,
 					    enum mlxsw_sp_l3proto proto)
 {
-	struct mlxsw_resources *resources;
 	struct mlxsw_sp_vr *vr;
 	int i;
 
 	tb_id = mlxsw_sp_fix_tb_id(tb_id);
 
-	resources = mlxsw_core_resources_get(mlxsw_sp->core);
-	for (i = 0; i < resources->max_virtual_routers; i++) {
+	for (i = 0; i < MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_VRS); i++) {
 		vr = &mlxsw_sp->router.vrs[i];
 		if (vr->used && vr->proto == proto && vr->tb_id == tb_id)
 			return vr;
@@ -569,21 +565,20 @@ static void mlxsw_sp_vr_put(struct mlxsw_sp *mlxsw_sp, struct mlxsw_sp_vr *vr)
 
 static int mlxsw_sp_vrs_init(struct mlxsw_sp *mlxsw_sp)
 {
-	struct mlxsw_resources *resources;
 	struct mlxsw_sp_vr *vr;
+	u64 max_vrs;
 	int i;
 
-	resources = mlxsw_core_resources_get(mlxsw_sp->core);
-	if (!resources->max_virtual_routers_valid)
+	if (!MLXSW_CORE_RES_VALID(mlxsw_sp->core, MAX_VRS))
 		return -EIO;
 
-	mlxsw_sp->router.vrs = kcalloc(resources->max_virtual_routers,
-				       sizeof(struct mlxsw_sp_vr),
+	max_vrs = MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_VRS);
+	mlxsw_sp->router.vrs = kcalloc(max_vrs, sizeof(struct mlxsw_sp_vr),
 				       GFP_KERNEL);
 	if (!mlxsw_sp->router.vrs)
 		return -ENOMEM;
 
-	for (i = 0; i < resources->max_virtual_routers; i++) {
+	for (i = 0; i < max_vrs; i++) {
 		vr = &mlxsw_sp->router.vrs[i];
 		vr->id = i;
 	}
@@ -1875,15 +1870,13 @@ static int mlxsw_sp_router_set_abort_trap(struct mlxsw_sp *mlxsw_sp)
 
 static void mlxsw_sp_router_fib4_abort(struct mlxsw_sp *mlxsw_sp)
 {
-	struct mlxsw_resources *resources;
 	struct mlxsw_sp_fib_entry *fib_entry;
 	struct mlxsw_sp_fib_entry *tmp;
 	struct mlxsw_sp_vr *vr;
 	int i;
 	int err;
 
-	resources = mlxsw_core_resources_get(mlxsw_sp->core);
-	for (i = 0; i < resources->max_virtual_routers; i++) {
+	for (i = 0; i < MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_VRS); i++) {
 		vr = &mlxsw_sp->router.vrs[i];
 		if (!vr->used)
 			continue;
@@ -1908,21 +1901,21 @@ static void mlxsw_sp_router_fib4_abort(struct mlxsw_sp *mlxsw_sp)
 
 static int __mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
 {
-	struct mlxsw_resources *resources;
 	char rgcr_pl[MLXSW_REG_RGCR_LEN];
+	u64 max_rifs;
 	int err;
 
-	resources = mlxsw_core_resources_get(mlxsw_sp->core);
-	if (!resources->max_rif_valid)
+	if (!MLXSW_CORE_RES_VALID(mlxsw_sp->core, MAX_RIFS))
 		return -EIO;
 
-	mlxsw_sp->rifs = kcalloc(resources->max_rif,
-				 sizeof(struct mlxsw_sp_rif *), GFP_KERNEL);
+	max_rifs = MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_RIFS);
+	mlxsw_sp->rifs = kcalloc(max_rifs, sizeof(struct mlxsw_sp_rif *),
+				 GFP_KERNEL);
 	if (!mlxsw_sp->rifs)
 		return -ENOMEM;
 
 	mlxsw_reg_rgcr_pack(rgcr_pl, true);
-	mlxsw_reg_rgcr_max_router_interfaces_set(rgcr_pl, resources->max_rif);
+	mlxsw_reg_rgcr_max_router_interfaces_set(rgcr_pl, max_rifs);
 	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(rgcr), rgcr_pl);
 	if (err)
 		goto err_rgcr_fail;
@@ -1936,15 +1929,13 @@ static int __mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
 
 static void __mlxsw_sp_router_fini(struct mlxsw_sp *mlxsw_sp)
 {
-	struct mlxsw_resources *resources;
 	char rgcr_pl[MLXSW_REG_RGCR_LEN];
 	int i;
 
 	mlxsw_reg_rgcr_pack(rgcr_pl, false);
 	mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(rgcr), rgcr_pl);
 
-	resources = mlxsw_core_resources_get(mlxsw_sp->core);
-	for (i = 0; i < resources->max_rif; i++)
+	for (i = 0; i < MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_RIFS); i++)
 		WARN_ON_ONCE(mlxsw_sp->rifs[i]);
 
 	kfree(mlxsw_sp->rifs);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 5e00c79..b19552a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -1196,11 +1196,12 @@ static struct mlxsw_sp_port *mlxsw_sp_lag_rep_port(struct mlxsw_sp *mlxsw_sp,
 						   u16 lag_id)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port;
-	struct mlxsw_resources *resources;
+	u64 max_lag_members;
 	int i;
 
-	resources = mlxsw_core_resources_get(mlxsw_sp->core);
-	for (i = 0; i < resources->max_ports_in_lag; i++) {
+	max_lag_members = MLXSW_CORE_RES_GET(mlxsw_sp->core,
+					     MAX_LAG_MEMBERS);
+	for (i = 0; i < max_lag_members; i++) {
 		mlxsw_sp_port = mlxsw_sp_port_lagged_get(mlxsw_sp, lag_id, i);
 		if (mlxsw_sp_port)
 			return mlxsw_sp_port;
-- 
2.5.5
