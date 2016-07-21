From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/9] mlxsw: pci: Add resources query implementation.
Date: Thu, 21 Jul 2016 10:19:12 +0200
Message-ID: <1469089160-4239-2-git-send-email-jiri@resnulli.us>
References: <1469089160-4239-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, eladr@mellanox.com,
	idosch@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	jhs@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35726 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751126AbcGUITY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 04:19:24 -0400
Received: by mail-wm0-f68.google.com with SMTP id i5so1638034wmg.2
        for <netdev@vger.kernel.org>; Thu, 21 Jul 2016 01:19:24 -0700 (PDT)
In-Reply-To: <1469089160-4239-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Add resources query implementation. If exists, query the HW for its
builtin resources instead of having them as consts in the code.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/cmd.h      | 32 ++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/core.c     | 10 ++++-
 drivers/net/ethernet/mellanox/mlxsw/core.h     |  9 +++-
 drivers/net/ethernet/mellanox/mlxsw/pci.c      | 60 +++++++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c |  1 +
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c |  1 +
 6 files changed, 110 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/cmd.h b/drivers/net/ethernet/mellanox/mlxsw/cmd.h
index f9cd6e3..28271be 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/cmd.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/cmd.h
@@ -105,6 +105,7 @@ enum mlxsw_cmd_opcode {
 	MLXSW_CMD_OPCODE_SW2HW_EQ		= 0x013,
 	MLXSW_CMD_OPCODE_HW2SW_EQ		= 0x014,
 	MLXSW_CMD_OPCODE_QUERY_EQ		= 0x015,
+	MLXSW_CMD_OPCODE_QUERY_RESOURCES	= 0x101,
 };
 
 static inline const char *mlxsw_cmd_opcode_str(u16 opcode)
@@ -144,6 +145,8 @@ static inline const char *mlxsw_cmd_opcode_str(u16 opcode)
 		return "HW2SW_EQ";
 	case MLXSW_CMD_OPCODE_QUERY_EQ:
 		return "QUERY_EQ";
+	case MLXSW_CMD_OPCODE_QUERY_RESOURCES:
+		return "QUERY_RESOURCES";
 	default:
 		return "*UNKNOWN*";
 	}
@@ -500,6 +503,35 @@ static inline int mlxsw_cmd_unmap_fa(struct mlxsw_core *mlxsw_core)
 	return mlxsw_cmd_exec_none(mlxsw_core, MLXSW_CMD_OPCODE_UNMAP_FA, 0, 0);
 }
 
+/* QUERY_RESOURCES - Query chip resources
+ * --------------------------------------
+ * OpMod == 0 (N/A) , INMmod is index
+ * ----------------------------------
+ * The QUERY_RESOURCES command retrieves information related to chip resources
+ * by resource ID. Every command returns 32 entries. INmod is being use as base.
+ * for example, index 1 will return entries 32-63. When the tables end and there
+ * are no more sources in the table, will return resource id 0xFFF to indicate
+ * it.
+ */
+static inline int mlxsw_cmd_query_resources(struct mlxsw_core *mlxsw_core,
+					    char *out_mbox, int index)
+{
+	return mlxsw_cmd_exec_out(mlxsw_core, MLXSW_CMD_OPCODE_QUERY_RESOURCES,
+				  0, index, false, out_mbox,
+				  MLXSW_CMD_MBOX_SIZE);
+}
+
+/* cmd_mbox_query_resource_id
+ * The resource id. 0xFFFF indicates table's end.
+ */
+MLXSW_ITEM32_INDEXED(cmd_mbox, query_resource, id, 0x00, 16, 16, 0x8, 0, false);
+
+/* cmd_mbox_query_resource_data
+ * The resource
+ */
+MLXSW_ITEM64_INDEXED(cmd_mbox, query_resource, data,
+		     0x00, 0, 40, 0x8, 0, false);
+
 /* CONFIG_PROFILE (Set) - Configure Switch Profile
  * ------------------------------
  * OpMod == 1 (Set), INMmod == 0 (N/A)
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index 480a3ba..068ee65a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -111,6 +111,7 @@ struct mlxsw_core {
 	struct {
 		u8 *mapping; /* lag_id+port_index to local_port mapping */
 	} lag;
+	struct mlxsw_resources resources;
 	struct mlxsw_hwmon *hwmon;
 	unsigned long driver_priv[0];
 	/* driver_priv has to be always the last item */
@@ -1110,7 +1111,8 @@ int mlxsw_core_bus_device_register(const struct mlxsw_bus_info *mlxsw_bus_info,
 		}
 	}
 
-	err = mlxsw_bus->init(bus_priv, mlxsw_core, mlxsw_driver->profile);
+	err = mlxsw_bus->init(bus_priv, mlxsw_core, mlxsw_driver->profile,
+			      &mlxsw_core->resources);
 	if (err)
 		goto err_bus_init;
 
@@ -1652,6 +1654,12 @@ void mlxsw_core_lag_mapping_clear(struct mlxsw_core *mlxsw_core,
 }
 EXPORT_SYMBOL(mlxsw_core_lag_mapping_clear);
 
+struct mlxsw_resources *mlxsw_core_resources_get(struct mlxsw_core *mlxsw_core)
+{
+	return &mlxsw_core->resources;
+}
+EXPORT_SYMBOL(mlxsw_core_resources_get);
+
 int mlxsw_core_port_init(struct mlxsw_core *mlxsw_core,
 			 struct mlxsw_core_port *mlxsw_core_port, u8 local_port,
 			 struct net_device *dev, bool split, u32 split_group)
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index 2fe385c..d57ad0d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -215,6 +215,7 @@ struct mlxsw_config_profile {
 	u32	kvd_linear_size;
 	u32	kvd_hash_single_size;
 	u32	kvd_hash_double_size;
+	u8	resource_query_enable;
 	struct mlxsw_swid_config swid_config[MLXSW_CONFIG_PROFILE_SWID_COUNT];
 };
 
@@ -266,10 +267,16 @@ struct mlxsw_driver {
 	const struct mlxsw_config_profile *profile;
 };
 
+struct mlxsw_resources {
+};
+
+struct mlxsw_resources *mlxsw_core_resources_get(struct mlxsw_core *mlxsw_core);
+
 struct mlxsw_bus {
 	const char *kind;
 	int (*init)(void *bus_priv, struct mlxsw_core *mlxsw_core,
-		    const struct mlxsw_config_profile *profile);
+		    const struct mlxsw_config_profile *profile,
+		    struct mlxsw_resources *resources);
 	void (*fini)(void *bus_priv);
 	bool (*skb_transmit_busy)(void *bus_priv,
 				  const struct mlxsw_tx_info *tx_info);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.c b/drivers/net/ethernet/mellanox/mlxsw/pci.c
index ddbc9f2..6408cc9 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.c
@@ -1154,6 +1154,57 @@ mlxsw_pci_config_profile_swid_config(struct mlxsw_pci *mlxsw_pci,
 	mlxsw_cmd_mbox_config_profile_swid_config_mask_set(mbox, index, mask);
 }
 
+#define MLXSW_RESOURCES_TABLE_END_ID 0xffff
+#define MLXSW_RESOURCES_QUERY_MAX_QUERIES 100
+#define MLXSW_RESOURCES_PER_QUERY 32
+
+static void
+mlxsw_pci_resources_query_parse(int id, u64 val,
+				struct mlxsw_resources *resources)
+{
+	switch (id) {
+	default:
+		break;
+	}
+}
+
+static int
+mlxsw_pci_resources_query(struct mlxsw_pci *mlxsw_pci, char *mbox,
+			  struct mlxsw_resources *resources, u8 query_enabled)
+{
+	int index, i;
+	u64 data;
+	u16 id;
+	int err;
+
+	/* Not all the versions support resources query */
+	if (!query_enabled)
+		return 0;
+
+	mlxsw_cmd_mbox_zero(mbox);
+
+	for (index = 0; index < MLXSW_RESOURCES_QUERY_MAX_QUERIES; index++) {
+		err = mlxsw_cmd_query_resources(mlxsw_pci->core, mbox, index);
+		if (err)
+			return err;
+
+		for (i = 0; i < MLXSW_RESOURCES_PER_QUERY; i++) {
+			id = mlxsw_cmd_mbox_query_resource_id_get(mbox, i);
+			data = mlxsw_cmd_mbox_query_resource_data_get(mbox, i);
+
+			if (id == MLXSW_RESOURCES_TABLE_END_ID)
+				return 0;
+
+			mlxsw_pci_resources_query_parse(id, data, resources);
+		}
+	}
+
+	/* If after MLXSW_RESOURCES_QUERY_MAX_QUERIES we still didn't get
+	 * MLXSW_RESOURCES_TABLE_END_ID, something went bad in the FW.
+	 */
+	return -EIO;
+}
+
 static int mlxsw_pci_config_profile(struct mlxsw_pci *mlxsw_pci, char *mbox,
 				    const struct mlxsw_config_profile *profile)
 {
@@ -1404,7 +1455,8 @@ static void mlxsw_pci_mbox_free(struct mlxsw_pci *mlxsw_pci,
 }
 
 static int mlxsw_pci_init(void *bus_priv, struct mlxsw_core *mlxsw_core,
-			  const struct mlxsw_config_profile *profile)
+			  const struct mlxsw_config_profile *profile,
+			  struct mlxsw_resources *resources)
 {
 	struct mlxsw_pci *mlxsw_pci = bus_priv;
 	struct pci_dev *pdev = mlxsw_pci->pdev;
@@ -1463,6 +1515,11 @@ static int mlxsw_pci_init(void *bus_priv, struct mlxsw_core *mlxsw_core,
 	if (err)
 		goto err_boardinfo;
 
+	err = mlxsw_pci_resources_query(mlxsw_pci, mbox, resources,
+					profile->resource_query_enable);
+	if (err)
+		goto err_query_resources;
+
 	err = mlxsw_pci_config_profile(mlxsw_pci, mbox, profile);
 	if (err)
 		goto err_config_profile;
@@ -1485,6 +1542,7 @@ err_request_eq_irq:
 	mlxsw_pci_aqs_fini(mlxsw_pci);
 err_aqs_init:
 err_config_profile:
+err_query_resources:
 err_boardinfo:
 	mlxsw_pci_fw_area_fini(mlxsw_pci);
 err_fw_area_init:
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 3e7920b..417dbd7 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2510,6 +2510,7 @@ static struct mlxsw_config_profile mlxsw_sp_config_profile = {
 			.type		= MLXSW_PORT_SWID_TYPE_ETH,
 		}
 	},
+	.resource_query_enable		= 1,
 };
 
 static struct mlxsw_driver mlxsw_sp_driver = {
diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index 25f658b..377daa4 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -1541,6 +1541,7 @@ static struct mlxsw_config_profile mlxsw_sx_config_profile = {
 			.type		= MLXSW_PORT_SWID_TYPE_ETH,
 		}
 	},
+	.resource_query_enable		= 0,
 };
 
 static struct mlxsw_driver mlxsw_sx_driver = {
-- 
2.5.5
