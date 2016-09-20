From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 4/9] mlxsw: profile: Add KVD resources to profile config
Date: Tue, 20 Sep 2016 11:16:52 +0200
Message-ID: <1474363017-2901-5-git-send-email-jiri@resnulli.us>
References: <1474363017-2901-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36417 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752869AbcITJRF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 05:17:05 -0400
Received: by mail-wm0-f66.google.com with SMTP id b184so2304175wma.3
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 02:17:04 -0700 (PDT)
In-Reply-To: <1474363017-2901-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Use resources from resource query to determine values for
the profile configuration.
Add KVD determined section sizes to the resources struct.
Change the profile struct and value to match this changes.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.h     | 15 ++++--
 drivers/net/ethernet/mellanox/mlxsw/pci.c      | 73 +++++++++++++++++++++-----
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c |  7 +--
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h |  3 +-
 4 files changed, 76 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index 76ad566..1193bdc 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -190,7 +190,8 @@ struct mlxsw_config_profile {
 		used_max_pkey:1,
 		used_ar_sec:1,
 		used_adaptive_routing_group_cap:1,
-		used_kvd_sizes:1;
+		used_kvd_split_data:1; /* indicate for the kvd's values */
+
 	u8	max_vepa_channels;
 	u16	max_mid;
 	u16	max_pgt;
@@ -210,8 +211,9 @@ struct mlxsw_config_profile {
 	u16	adaptive_routing_group_cap;
 	u8	arn;
 	u32	kvd_linear_size;
-	u32	kvd_hash_single_size;
-	u32	kvd_hash_double_size;
+	u16	kvd_hash_granularity;
+	u8	kvd_hash_single_parts;
+	u8	kvd_hash_double_parts;
 	u8	resource_query_enable;
 	struct mlxsw_swid_config swid_config[MLXSW_CONFIG_PROFILE_SWID_COUNT];
 };
@@ -277,6 +279,13 @@ struct mlxsw_resources {
 	u32	kvd_size;
 	u32	kvd_single_min_size;
 	u32	kvd_double_min_size;
+
+	/* Internal resources.
+	 * Determined by the SW, not queried from the HW.
+	 */
+	u32	kvd_single_size;
+	u32	kvd_double_size;
+	u32	kvd_linear_size;
 };
 
 struct mlxsw_resources *mlxsw_core_resources_get(struct mlxsw_core *mlxsw_core);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.c b/drivers/net/ethernet/mellanox/mlxsw/pci.c
index 7b2ab1e..c2d2fa1 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.c
@@ -1234,10 +1234,52 @@ static int mlxsw_pci_resources_query(struct mlxsw_pci *mlxsw_pci, char *mbox,
 	return -EIO;
 }
 
+static int mlxsw_pci_profile_get_kvd_sizes(const struct mlxsw_config_profile *profile,
+					   struct mlxsw_resources *resources)
+{
+	u32 singles_size, doubles_size, linear_size;
+
+	if (!resources->kvd_single_min_size_valid ||
+	    !resources->kvd_double_min_size_valid ||
+	    !profile->used_kvd_split_data)
+		return -EIO;
+
+	linear_size = profile->kvd_linear_size;
+
+	/* The hash part is what left of the kvd without the
+	 * linear part. It is split to the single size and
+	 * double size by the parts ratio from the profile.
+	 * Both sizes must be a multiplications of the
+	 * granularity from the profile.
+	 */
+	doubles_size = (resources->kvd_size - linear_size);
+	doubles_size *= profile->kvd_hash_double_parts;
+	doubles_size /= (profile->kvd_hash_double_parts +
+			 profile->kvd_hash_single_parts);
+	doubles_size /= profile->kvd_hash_granularity;
+	doubles_size *= profile->kvd_hash_granularity;
+	singles_size = resources->kvd_size - doubles_size -
+		       linear_size;
+
+	/* Check results are legal. */
+	if (singles_size < resources->kvd_single_min_size ||
+	    doubles_size < resources->kvd_double_min_size ||
+	    resources->kvd_size < linear_size)
+		return -EIO;
+
+	resources->kvd_single_size = singles_size;
+	resources->kvd_double_size = doubles_size;
+	resources->kvd_linear_size = linear_size;
+
+	return 0;
+}
+
 static int mlxsw_pci_config_profile(struct mlxsw_pci *mlxsw_pci, char *mbox,
-				    const struct mlxsw_config_profile *profile)
+				    const struct mlxsw_config_profile *profile,
+				    struct mlxsw_resources *resources)
 {
 	int i;
+	int err;
 
 	mlxsw_cmd_mbox_zero(mbox);
 
@@ -1323,19 +1365,22 @@ static int mlxsw_pci_config_profile(struct mlxsw_pci *mlxsw_pci, char *mbox,
 		mlxsw_cmd_mbox_config_profile_adaptive_routing_group_cap_set(
 			mbox, profile->adaptive_routing_group_cap);
 	}
-	if (profile->used_kvd_sizes) {
-		mlxsw_cmd_mbox_config_profile_set_kvd_linear_size_set(
-			mbox, 1);
-		mlxsw_cmd_mbox_config_profile_kvd_linear_size_set(
-			mbox, profile->kvd_linear_size);
-		mlxsw_cmd_mbox_config_profile_set_kvd_hash_single_size_set(
-			mbox, 1);
-		mlxsw_cmd_mbox_config_profile_kvd_hash_single_size_set(
-			mbox, profile->kvd_hash_single_size);
+	if (resources->kvd_size_valid) {
+		err = mlxsw_pci_profile_get_kvd_sizes(profile, resources);
+		if (err)
+			return err;
+
+		mlxsw_cmd_mbox_config_profile_set_kvd_linear_size_set(mbox, 1);
+		mlxsw_cmd_mbox_config_profile_kvd_linear_size_set(mbox,
+						resources->kvd_linear_size);
+		mlxsw_cmd_mbox_config_profile_set_kvd_hash_single_size_set(mbox,
+									   1);
+		mlxsw_cmd_mbox_config_profile_kvd_hash_single_size_set(mbox,
+						resources->kvd_single_size);
 		mlxsw_cmd_mbox_config_profile_set_kvd_hash_double_size_set(
-			mbox, 1);
-		mlxsw_cmd_mbox_config_profile_kvd_hash_double_size_set(
-			mbox, profile->kvd_hash_double_size);
+								mbox, 1);
+		mlxsw_cmd_mbox_config_profile_kvd_hash_double_size_set(mbox,
+						resources->kvd_double_size);
 	}
 
 	for (i = 0; i < MLXSW_CONFIG_PROFILE_SWID_COUNT; i++)
@@ -1537,7 +1582,7 @@ static int mlxsw_pci_init(void *bus_priv, struct mlxsw_core *mlxsw_core,
 	if (err)
 		goto err_query_resources;
 
-	err = mlxsw_pci_config_profile(mlxsw_pci, mbox, profile);
+	err = mlxsw_pci_config_profile(mlxsw_pci, mbox, profile, resources);
 	if (err)
 		goto err_config_profile;
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 1a6d21e..29ad6a0 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -3057,10 +3057,11 @@ static struct mlxsw_config_profile mlxsw_sp_config_profile = {
 	.max_ib_mc			= 0,
 	.used_max_pkey			= 1,
 	.max_pkey			= 0,
-	.used_kvd_sizes			= 1,
+	.used_kvd_split_data		= 1,
+	.kvd_hash_granularity		= MLXSW_SP_KVD_GRANULARITY,
+	.kvd_hash_single_parts		= 2,
+	.kvd_hash_double_parts		= 1,
 	.kvd_linear_size		= MLXSW_SP_KVD_LINEAR_SIZE,
-	.kvd_hash_single_size		= MLXSW_SP_KVD_HASH_SINGLE_SIZE,
-	.kvd_hash_double_size		= MLXSW_SP_KVD_HASH_DOUBLE_SIZE,
 	.swid_config			= {
 		{
 			.used_type	= 1,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index a056aaa..208dfee 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -74,8 +74,7 @@
 #define MLXSW_SP_CELLS_TO_BYTES(c) (c * MLXSW_SP_BYTES_PER_CELL)
 
 #define MLXSW_SP_KVD_LINEAR_SIZE 65536 /* entries */
-#define MLXSW_SP_KVD_HASH_SINGLE_SIZE 163840 /* entries */
-#define MLXSW_SP_KVD_HASH_DOUBLE_SIZE 32768 /* entries */
+#define MLXSW_SP_KVD_GRANULARITY 128
 
 /* Maximum delay buffer needed in case of PAUSE frames, in cells.
  * Assumes 100m cable and maximum MTU.
-- 
2.5.5
