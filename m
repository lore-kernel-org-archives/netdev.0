From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 6/7] mlxsw: pci: Add support for getting resource through devlink
Date: Tue, 24 Oct 2017 11:22:44 +0200
Message-ID: <20171024092245.1386-7-jiri@resnulli.us>
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
Received: from mail-wr0-f193.google.com ([209.85.128.193]:50383 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751932AbdJXJWx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 05:22:53 -0400
Received: by mail-wr0-f193.google.com with SMTP id p96so6074162wrb.7
        for <netdev@vger.kernel.org>; Tue, 24 Oct 2017 02:22:53 -0700 (PDT)
In-Reply-To: <20171024092245.1386-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Up until now the KVD partition was static. This patch introduces the
ability to get the resource sizes via devlink. In case the resource is not
available the default configuration is used.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.c     | 16 ++++++++
 drivers/net/ethernet/mellanox/mlxsw/core.h     |  9 ++++
 drivers/net/ethernet/mellanox/mlxsw/pci.c      | 40 +++++-------------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 57 ++++++++++++++++++++++++++
 4 files changed, 92 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index ee41036..ab93437 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -1800,6 +1800,22 @@ void mlxsw_core_flush_owq(void)
 }
 EXPORT_SYMBOL(mlxsw_core_flush_owq);
 
+int mlxsw_core_kvd_sizes_get(struct mlxsw_core *mlxsw_core,
+			     const struct mlxsw_config_profile *profile,
+			     u64 *p_single_size, u64 *p_double_size,
+			     u64 *p_linear_size)
+{
+	struct mlxsw_driver *driver =  mlxsw_core->driver;
+
+	if (!driver->kvd_sizes_get)
+		return -EINVAL;
+
+	return driver->kvd_sizes_get(mlxsw_core, profile,
+				     p_single_size, p_double_size,
+				     p_linear_size);
+}
+EXPORT_SYMBOL(mlxsw_core_kvd_sizes_get);
+
 static int __init mlxsw_core_module_init(void)
 {
 	int err;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index e23f83b..e44061d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -309,10 +309,19 @@ struct mlxsw_driver {
 	void (*txhdr_construct)(struct sk_buff *skb,
 				const struct mlxsw_tx_info *tx_info);
 	int (*resources_register)(struct mlxsw_core *mlxsw_core);
+	int (*kvd_sizes_get)(struct mlxsw_core *mlxsw_core,
+			     const struct mlxsw_config_profile *profile,
+			     u64 *p_single_size, u64 *p_double_size,
+			     u64 *p_linear_size);
 	u8 txhdr_len;
 	const struct mlxsw_config_profile *profile;
 };
 
+int mlxsw_core_kvd_sizes_get(struct mlxsw_core *mlxsw_core,
+			     const struct mlxsw_config_profile *profile,
+			     u64 *p_single_size, u64 *p_double_size,
+			     u64 *p_linear_size);
+
 bool mlxsw_core_res_valid(struct mlxsw_core *mlxsw_core,
 			  enum mlxsw_res_id res_id);
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.c b/drivers/net/ethernet/mellanox/mlxsw/pci.c
index 00c9155..da08f08 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.c
@@ -1053,38 +1053,18 @@ static int mlxsw_pci_resources_query(struct mlxsw_pci *mlxsw_pci, char *mbox,
 }
 
 static int
-mlxsw_pci_profile_get_kvd_sizes(const struct mlxsw_config_profile *profile,
+mlxsw_pci_profile_get_kvd_sizes(const struct mlxsw_pci *mlxsw_pci,
+				const struct mlxsw_config_profile *profile,
 				struct mlxsw_res *res)
 {
-	u32 single_size, double_size, linear_size;
-
-	if (!MLXSW_RES_VALID(res, KVD_SINGLE_MIN_SIZE) ||
-	    !MLXSW_RES_VALID(res, KVD_DOUBLE_MIN_SIZE) ||
-	    !profile->used_kvd_split_data)
-		return -EIO;
-
-	linear_size = profile->kvd_linear_size;
+	u64 single_size, double_size, linear_size;
+	int err;
 
-	/* The hash part is what left of the kvd without the
-	 * linear part. It is split to the single size and
-	 * double size by the parts ratio from the profile.
-	 * Both sizes must be a multiplications of the
-	 * granularity from the profile.
-	 */
-	double_size = MLXSW_RES_GET(res, KVD_SIZE) - linear_size;
-	double_size *= profile->kvd_hash_double_parts;
-	double_size /= profile->kvd_hash_double_parts +
-		       profile->kvd_hash_single_parts;
-	double_size /= profile->kvd_hash_granularity;
-	double_size *= profile->kvd_hash_granularity;
-	single_size = MLXSW_RES_GET(res, KVD_SIZE) - double_size -
-		      linear_size;
-
-	/* Check results are legal. */
-	if (single_size < MLXSW_RES_GET(res, KVD_SINGLE_MIN_SIZE) ||
-	    double_size < MLXSW_RES_GET(res, KVD_DOUBLE_MIN_SIZE) ||
-	    MLXSW_RES_GET(res, KVD_SIZE) < linear_size)
-		return -EIO;
+	err = mlxsw_core_kvd_sizes_get(mlxsw_pci->core, profile,
+				       &single_size, &double_size,
+				       &linear_size);
+	if (err)
+		return err;
 
 	MLXSW_RES_SET(res, KVD_SINGLE_SIZE, single_size);
 	MLXSW_RES_SET(res, KVD_DOUBLE_SIZE, double_size);
@@ -1185,7 +1165,7 @@ static int mlxsw_pci_config_profile(struct mlxsw_pci *mlxsw_pci, char *mbox,
 			mbox, profile->adaptive_routing_group_cap);
 	}
 	if (MLXSW_RES_VALID(res, KVD_SIZE)) {
-		err = mlxsw_pci_profile_get_kvd_sizes(profile, res);
+		err = mlxsw_pci_profile_get_kvd_sizes(mlxsw_pci, profile, res);
 		if (err)
 			return err;
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 565f94e..8f8db6c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -3985,6 +3985,62 @@ static int mlxsw_sp_resources_register(struct mlxsw_core *mlxsw_core)
 	return 0;
 }
 
+static int mlxsw_sp_kvd_sizes_get(struct mlxsw_core *mlxsw_core,
+				  const struct mlxsw_config_profile *profile,
+				  u64 *p_single_size, u64 *p_double_size,
+				  u64 *p_linear_size)
+{
+	struct devlink *devlink = priv_to_devlink(mlxsw_core);
+	u64 double_size;
+	int err;
+
+	if (!MLXSW_CORE_RES_VALID(mlxsw_core, KVD_SINGLE_MIN_SIZE) ||
+	    !MLXSW_CORE_RES_VALID(mlxsw_core, KVD_DOUBLE_MIN_SIZE) ||
+	    !profile->used_kvd_split_data)
+		return -EIO;
+
+	/* The hash part is what left of the kvd without the
+	 * linear part. It is split to the single size and
+	 * double size by the parts ratio from the profile.
+	 * Both sizes must be a multiplications of the
+	 * granularity from the profile. In case the user
+	 * provided the sizes they are obtained via devlink.
+	 */
+	err = devlink_resource_size_get(devlink,
+					MLXSW_SP_RESOURCE_KVD_LINEAR,
+					p_linear_size);
+	if (err)
+		*p_linear_size = profile->kvd_linear_size;
+
+	err = devlink_resource_size_get(devlink,
+					MLXSW_SP_RESOURCE_KVD_HASH_DOUBLE,
+					p_double_size);
+	if (err) {
+		double_size = MLXSW_CORE_RES_GET(mlxsw_core, KVD_SIZE) -
+			      *p_linear_size;
+		double_size *= profile->kvd_hash_double_parts;
+		double_size /= profile->kvd_hash_double_parts +
+			       profile->kvd_hash_single_parts;
+		*p_double_size = rounddown(double_size,
+					   profile->kvd_hash_granularity);
+	}
+
+	err = devlink_resource_size_get(devlink,
+					MLXSW_SP_RESOURCE_KVD_HASH_SINGLE,
+					p_single_size);
+	if (err)
+		*p_single_size = MLXSW_CORE_RES_GET(mlxsw_core, KVD_SIZE) -
+				 *p_double_size - *p_linear_size;
+
+	/* Check results are legal. */
+	if (*p_single_size < MLXSW_CORE_RES_GET(mlxsw_core, KVD_SINGLE_MIN_SIZE) ||
+	    *p_double_size < MLXSW_CORE_RES_GET(mlxsw_core, KVD_DOUBLE_MIN_SIZE) ||
+	    MLXSW_CORE_RES_GET(mlxsw_core, KVD_SIZE) < *p_linear_size)
+		return -EIO;
+
+	return 0;
+}
+
 static struct mlxsw_driver mlxsw_sp_driver = {
 	.kind				= mlxsw_sp_driver_name,
 	.priv_size			= sizeof(struct mlxsw_sp),
@@ -4005,6 +4061,7 @@ static struct mlxsw_driver mlxsw_sp_driver = {
 	.sb_occ_tc_port_bind_get	= mlxsw_sp_sb_occ_tc_port_bind_get,
 	.txhdr_construct		= mlxsw_sp_txhdr_construct,
 	.resources_register		= mlxsw_sp_resources_register,
+	.kvd_sizes_get			= mlxsw_sp_kvd_sizes_get,
 	.txhdr_len			= MLXSW_TXHDR_LEN,
 	.profile			= &mlxsw_sp_config_profile,
 };
-- 
2.9.5
