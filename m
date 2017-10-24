From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 5/7] mlxsw: Register KVD resources with devlink
Date: Tue, 24 Oct 2017 11:22:43 +0200
Message-ID: <20171024092245.1386-6-jiri@resnulli.us>
References: <20171024092245.1386-1-jiri@resnulli.us>
Cc: davem@davemloft.net, mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        saeedm@mellanox.com, matanb@mellanox.com, leonro@mellanox.com,
        idosch@mellanox.com, jakub.kicinski@netronome.com, ast@kernel.org,
        daniel@iogearbox.net, simon.horman@netronome.com,
        pieter.jansenvanvuuren@netronome.com, john.hurley@netronome.com,
        alexander.h.duyck@intel.com, linville@tuxdriver.com,
        gospo@broadcom.com, steven.lin1@broadcom.com, yuvalm@mellanox.com,
        ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:57058 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751927AbdJXJWw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 05:22:52 -0400
Received: by mail-wm0-f67.google.com with SMTP id z3so7858515wme.5
        for <netdev@vger.kernel.org>; Tue, 24 Oct 2017 02:22:51 -0700 (PDT)
In-Reply-To: <20171024092245.1386-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Register the KVD resources with devlink. The KVD is a memory resource
which is subdivided into three partitions which are the linear, hash
single and hash double.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.c     |  9 +++
 drivers/net/ethernet/mellanox/mlxsw/core.h     |  1 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 91 +++++++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h | 12 ++++
 4 files changed, 112 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index f3315bc..ee41036 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -1012,6 +1012,12 @@ int mlxsw_core_bus_device_register(const struct mlxsw_bus_info *mlxsw_bus_info,
 	if (err)
 		goto err_bus_init;
 
+	if (mlxsw_driver->resources_register) {
+		err = mlxsw_driver->resources_register(mlxsw_core);
+		if (err)
+			goto err_register_resources;
+	}
+
 	err = mlxsw_ports_init(mlxsw_core);
 	if (err)
 		goto err_ports_init;
@@ -1067,6 +1073,8 @@ int mlxsw_core_bus_device_register(const struct mlxsw_bus_info *mlxsw_bus_info,
 err_ports_init:
 	mlxsw_bus->fini(bus_priv);
 err_bus_init:
+	devlink_resources_clear(devlink);
+err_register_resources:
 	devlink_free(devlink);
 err_devlink_alloc:
 	mlxsw_core_driver_put(device_kind);
@@ -1086,6 +1094,7 @@ void mlxsw_core_bus_device_unregister(struct mlxsw_core *mlxsw_core)
 	mlxsw_emad_fini(mlxsw_core);
 	kfree(mlxsw_core->lag.mapping);
 	mlxsw_ports_fini(mlxsw_core);
+	devlink_resources_clear(devlink);
 	mlxsw_core->bus->fini(mlxsw_core->bus_priv);
 	devlink_free(devlink);
 	mlxsw_core_driver_put(device_kind);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index 34dda96..e23f83b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -308,6 +308,7 @@ struct mlxsw_driver {
 				       u32 *p_cur, u32 *p_max);
 	void (*txhdr_construct)(struct sk_buff *skb,
 				const struct mlxsw_tx_info *tx_info);
+	int (*resources_register)(struct mlxsw_core *mlxsw_core);
 	u8 txhdr_len;
 	const struct mlxsw_config_profile *profile;
 };
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 12b6ac4..565f94e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -3864,7 +3864,6 @@ static void mlxsw_sp_fini(struct mlxsw_core *mlxsw_core)
 	mlxsw_sp_fids_fini(mlxsw_sp);
 	mlxsw_sp_kvdl_fini(mlxsw_sp);
 }
-
 static const struct mlxsw_config_profile mlxsw_sp_config_profile = {
 	.used_max_vepa_channels		= 1,
 	.max_vepa_channels		= 0,
@@ -3897,6 +3896,95 @@ static const struct mlxsw_config_profile mlxsw_sp_config_profile = {
 	.resource_query_enable		= 1,
 };
 
+int mlxsw_sp_resource_kvd_size_validate(void *priv, u64 size)
+{
+	/* KVD total size cannot be set*/
+	return -EINVAL;
+}
+
+int mlxsw_sp_resource_kvd_sub_size_validate(void *priv, u64 size)
+{
+	const struct mlxsw_config_profile *profile;
+
+	profile = &mlxsw_sp_config_profile;
+	if (size % profile->kvd_hash_granularity)
+		return -EINVAL;
+	return 0;
+}
+
+static struct devlink_resource_ops mlxsw_sp_resource_kvd_ops = {
+	.size_validate = mlxsw_sp_resource_kvd_size_validate,
+};
+
+static struct devlink_resource_ops mlxsw_sp_resource_kvd_linear_ops = {
+	.size_validate = mlxsw_sp_resource_kvd_sub_size_validate,
+};
+
+static struct devlink_resource_ops mlxsw_sp_resource_kvd_hash_single_ops = {
+	.size_validate = mlxsw_sp_resource_kvd_sub_size_validate,
+};
+
+static struct devlink_resource_ops mlxsw_sp_resource_kvd_hash_double_ops = {
+	.size_validate = mlxsw_sp_resource_kvd_sub_size_validate,
+};
+
+static int mlxsw_sp_resources_register(struct mlxsw_core *mlxsw_core)
+{
+	struct devlink *devlink = priv_to_devlink(mlxsw_core);
+	u64 kvd_size, single_size, double_size, linear_size;
+	const struct mlxsw_config_profile *profile;
+	int err;
+
+	profile = &mlxsw_sp_config_profile;
+	if (!MLXSW_CORE_RES_VALID(mlxsw_core, KVD_SIZE))
+		return -EIO;
+
+	kvd_size = MLXSW_CORE_RES_GET(mlxsw_core, KVD_SIZE);
+	err = devlink_resource_register(devlink, MLXSW_SP_RESOURCE_NAME_KVD,
+					true, kvd_size,
+					MLXSW_SP_RESOURCE_KVD,
+					DEVLINK_RESOURCE_ID_PARENT_TOP,
+					&mlxsw_sp_resource_kvd_ops, mlxsw_core);
+	if (err)
+		return err;
+
+	linear_size = profile->kvd_linear_size;
+	err = devlink_resource_register(devlink, MLXSW_SP_RESOURCE_NAME_KVD_LINEAR,
+					false, linear_size,
+					MLXSW_SP_RESOURCE_KVD_LINEAR,
+					MLXSW_SP_RESOURCE_KVD,
+					&mlxsw_sp_resource_kvd_linear_ops,
+					mlxsw_core);
+	if (err)
+		return err;
+
+	double_size = kvd_size - linear_size;
+	double_size *= profile->kvd_hash_double_parts;
+	double_size /= profile->kvd_hash_double_parts +
+		       profile->kvd_hash_single_parts;
+	double_size = rounddown(double_size, profile->kvd_hash_granularity);
+	err = devlink_resource_register(devlink, MLXSW_SP_RESOURCE_NAME_KVD_HASH_DOUBLE,
+					false, double_size,
+					MLXSW_SP_RESOURCE_KVD_HASH_DOUBLE,
+					MLXSW_SP_RESOURCE_KVD,
+					&mlxsw_sp_resource_kvd_hash_double_ops,
+					mlxsw_core);
+	if (err)
+		return err;
+
+	single_size = kvd_size - double_size - linear_size;
+	err = devlink_resource_register(devlink, MLXSW_SP_RESOURCE_NAME_KVD_HASH_SINGLE,
+					false, single_size,
+					MLXSW_SP_RESOURCE_KVD_HASH_SINGLE,
+					MLXSW_SP_RESOURCE_KVD,
+					&mlxsw_sp_resource_kvd_hash_single_ops,
+					mlxsw_core);
+	if (err)
+		return err;
+
+	return 0;
+}
+
 static struct mlxsw_driver mlxsw_sp_driver = {
 	.kind				= mlxsw_sp_driver_name,
 	.priv_size			= sizeof(struct mlxsw_sp),
@@ -3916,6 +4004,7 @@ static struct mlxsw_driver mlxsw_sp_driver = {
 	.sb_occ_port_pool_get		= mlxsw_sp_sb_occ_port_pool_get,
 	.sb_occ_tc_port_bind_get	= mlxsw_sp_sb_occ_tc_port_bind_get,
 	.txhdr_construct		= mlxsw_sp_txhdr_construct,
+	.resources_register		= mlxsw_sp_resources_register,
 	.txhdr_len			= MLXSW_TXHDR_LEN,
 	.profile			= &mlxsw_sp_config_profile,
 };
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index dc1b739..9413481 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -65,6 +65,18 @@
 #define MLXSW_SP_KVD_LINEAR_SIZE 98304 /* entries */
 #define MLXSW_SP_KVD_GRANULARITY 128
 
+#define MLXSW_SP_RESOURCE_NAME_KVD "kvd"
+#define MLXSW_SP_RESOURCE_NAME_KVD_LINEAR "linear"
+#define MLXSW_SP_RESOURCE_NAME_KVD_HASH_SINGLE "hash_single"
+#define MLXSW_SP_RESOURCE_NAME_KVD_HASH_DOUBLE "hash_double"
+
+enum mlxsw_sp_resource_id {
+	MLXSW_SP_RESOURCE_KVD,
+	MLXSW_SP_RESOURCE_KVD_LINEAR,
+	MLXSW_SP_RESOURCE_KVD_HASH_SINGLE,
+	MLXSW_SP_RESOURCE_KVD_HASH_DOUBLE,
+};
+
 struct mlxsw_sp_port;
 struct mlxsw_sp_rif;
 
-- 
2.9.5
