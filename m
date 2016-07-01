From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 35/42] mlxsw: Add KVD sizes configuration into profile
Date: Fri,  1 Jul 2016 16:05:03 +0200
Message-ID: <1467381910-3445-36-git-send-email-jiri@resnulli.us>
References: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34623 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752690AbcGAOY5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 10:24:57 -0400
Received: by mail-wm0-f65.google.com with SMTP id 187so5696023wmz.1
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 07:23:52 -0700 (PDT)
In-Reply-To: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Up until now we only used hash-based tables in the device, but we are
going to use the linear table for remote routes adjacency lists.

Add the configuration fields that control the size of the linear table.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/cmd.h  | 43 ++++++++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/core.h |  6 ++++-
 drivers/net/ethernet/mellanox/mlxsw/pci.c  | 14 ++++++++++
 3 files changed, 62 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/cmd.h b/drivers/net/ethernet/mellanox/mlxsw/cmd.h
index cd63b82..f9cd6e3 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/cmd.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/cmd.h
@@ -607,6 +607,24 @@ MLXSW_ITEM32(cmd_mbox, config_profile,
  */
 MLXSW_ITEM32(cmd_mbox, config_profile, set_ar_sec, 0x0C, 15, 1);
 
+/* cmd_mbox_config_set_kvd_linear_size
+ * Capability bit. Setting a bit to 1 configures the profile
+ * according to the mailbox contents.
+ */
+MLXSW_ITEM32(cmd_mbox, config_profile, set_kvd_linear_size, 0x0C, 24, 1);
+
+/* cmd_mbox_config_set_kvd_hash_single_size
+ * Capability bit. Setting a bit to 1 configures the profile
+ * according to the mailbox contents.
+ */
+MLXSW_ITEM32(cmd_mbox, config_profile, set_kvd_hash_single_size, 0x0C, 25, 1);
+
+/* cmd_mbox_config_set_kvd_hash_double_size
+ * Capability bit. Setting a bit to 1 configures the profile
+ * according to the mailbox contents.
+ */
+MLXSW_ITEM32(cmd_mbox, config_profile, set_kvd_hash_double_size, 0x0C, 26, 1);
+
 /* cmd_mbox_config_profile_max_vepa_channels
  * Maximum number of VEPA channels per port (0 through 16)
  * 0 - multi-channel VEPA is disabled
@@ -733,6 +751,31 @@ MLXSW_ITEM32(cmd_mbox, config_profile, adaptive_routing_group_cap, 0x4C, 0, 16);
  */
 MLXSW_ITEM32(cmd_mbox, config_profile, arn, 0x50, 31, 1);
 
+/* cmd_mbox_config_kvd_linear_size
+ * KVD Linear Size
+ * Valid for Spectrum only
+ * Allowed values are 128*N where N=0 or higher
+ */
+MLXSW_ITEM32(cmd_mbox, config_profile, kvd_linear_size, 0x54, 0, 24);
+
+/* cmd_mbox_config_kvd_hash_single_size
+ * KVD Hash single-entries size
+ * Valid for Spectrum only
+ * Allowed values are 128*N where N=0 or higher
+ * Must be greater or equal to cap_min_kvd_hash_single_size
+ * Must be smaller or equal to cap_kvd_size - kvd_linear_size
+ */
+MLXSW_ITEM32(cmd_mbox, config_profile, kvd_hash_single_size, 0x58, 0, 24);
+
+/* cmd_mbox_config_kvd_hash_double_size
+ * KVD Hash double-entries size (units of single-size entries)
+ * Valid for Spectrum only
+ * Allowed values are 128*N where N=0 or higher
+ * Must be either 0 or greater or equal to cap_min_kvd_hash_double_size
+ * Must be smaller or equal to cap_kvd_size - kvd_linear_size
+ */
+MLXSW_ITEM32(cmd_mbox, config_profile, kvd_hash_double_size, 0x5C, 0, 24);
+
 /* cmd_mbox_config_profile_swid_config_mask
  * Modify Switch Partition Configuration mask. When set, the configu-
  * ration value for the Switch Partition are taken from the mailbox.
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index 436bc49..2fe385c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -190,7 +190,8 @@ struct mlxsw_config_profile {
 		used_max_ib_mc:1,
 		used_max_pkey:1,
 		used_ar_sec:1,
-		used_adaptive_routing_group_cap:1;
+		used_adaptive_routing_group_cap:1,
+		used_kvd_sizes:1;
 	u8	max_vepa_channels;
 	u16	max_lag;
 	u16	max_port_per_lag;
@@ -211,6 +212,9 @@ struct mlxsw_config_profile {
 	u8	ar_sec;
 	u16	adaptive_routing_group_cap;
 	u8	arn;
+	u32	kvd_linear_size;
+	u32	kvd_hash_single_size;
+	u32	kvd_hash_double_size;
 	struct mlxsw_swid_config swid_config[MLXSW_CONFIG_PROFILE_SWID_COUNT];
 };
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.c b/drivers/net/ethernet/mellanox/mlxsw/pci.c
index 7f4173c..ddbc9f2 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.c
@@ -1255,6 +1255,20 @@ static int mlxsw_pci_config_profile(struct mlxsw_pci *mlxsw_pci, char *mbox,
 		mlxsw_cmd_mbox_config_profile_adaptive_routing_group_cap_set(
 			mbox, profile->adaptive_routing_group_cap);
 	}
+	if (profile->used_kvd_sizes) {
+		mlxsw_cmd_mbox_config_profile_set_kvd_linear_size_set(
+			mbox, 1);
+		mlxsw_cmd_mbox_config_profile_kvd_linear_size_set(
+			mbox, profile->kvd_linear_size);
+		mlxsw_cmd_mbox_config_profile_set_kvd_hash_single_size_set(
+			mbox, 1);
+		mlxsw_cmd_mbox_config_profile_kvd_hash_single_size_set(
+			mbox, profile->kvd_hash_single_size);
+		mlxsw_cmd_mbox_config_profile_set_kvd_hash_double_size_set(
+			mbox, 1);
+		mlxsw_cmd_mbox_config_profile_kvd_hash_double_size_set(
+			mbox, profile->kvd_hash_double_size);
+	}
 
 	for (i = 0; i < MLXSW_CONFIG_PROFILE_SWID_COUNT; i++)
 		mlxsw_pci_config_profile_swid_config(mlxsw_pci, mbox, i,
-- 
2.5.5
