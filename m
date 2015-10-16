From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 03/16] mlxsw: cmd: Introduce per-FID flooding tables
Date: Fri, 16 Oct 2015 14:01:24 +0200
Message-ID: <1444996897-2708-4-git-send-email-jiri@resnulli.us>
References: <1444996897-2708-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	linux@roeck-us.net, vivien.didelot@savoirfairelinux.com,
	andrew@lunn.ch, john.fastabend@gmail.com, David.Laight@ACULAB.COM,
	stephen@networkplumber.org, tgraf@suug.ch, jhs@mojatatu.com,
	sagir@mellanox.com, mattyk@mellanox.com, aviadr@mellanox.com
To: netdev@vger.kernel.org, ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:36518 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752962AbbJPMBo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 08:01:44 -0400
Received: by wicgb1 with SMTP id gb1so6386371wic.1
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 05:01:43 -0700 (PDT)
In-Reply-To: <1444996897-2708-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

In the newly introduced Spectrum switch ASIC, packets destined to not
offloaded netdevs will be classified to special FIDs (vFIDs) in the
device and flooded to the CPU port.

The flooding table used is of type per-FID, which allows one to create
different flooding domains for different vFIDs.

While using a simple single-entry flood table is certainly sufficient at
this point, we do plan to offload 802.1D bridges involving VLAN
interfaces, thus making this change necessary.

Add support for this flooding table type, by exposing the configuration
of the number of tables from this type and their size.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/cmd.h  | 13 +++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/core.h |  2 ++
 drivers/net/ethernet/mellanox/mlxsw/pci.c  |  4 ++++
 3 files changed, 19 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/cmd.h b/drivers/net/ethernet/mellanox/mlxsw/cmd.h
index c7889f4..010eb5d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/cmd.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/cmd.h
@@ -674,6 +674,19 @@ MLXSW_ITEM32(cmd_mbox, config_profile, max_vid_flood_tables, 0x30, 8, 4);
  */
 MLXSW_ITEM32(cmd_mbox, config_profile, flood_mode, 0x30, 0, 2);
 
+/* cmd_mbox_config_profile_max_fid_flood_tables
+ * Maximum number of per-FID flooding tables.
+ *
+ * Note: This flooding tables cover special FIDs only (vFIDs), starting at
+ * FID value 4K and higher.
+ */
+MLXSW_ITEM32(cmd_mbox, config_profile, max_fid_flood_tables, 0x38, 24, 4);
+
+/* cmd_mbox_config_profile_fid_flood_table_size
+ * The size (number of entries) of each per-FID table.
+ */
+MLXSW_ITEM32(cmd_mbox, config_profile, fid_flood_table_size, 0x38, 0, 16);
+
 /* cmd_mbox_config_profile_max_ib_mc
  * Maximum number of multicast FDB records for InfiniBand
  * FDB (in 512 chunks) per InfiniBand switch partition.
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index 1658084..8bb85ea 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -153,6 +153,8 @@ struct mlxsw_config_profile {
 	u8	max_flood_tables;
 	u8	max_vid_flood_tables;
 	u8	flood_mode;
+	u8	max_fid_flood_tables;
+	u16	fid_flood_table_size;
 	u16	max_ib_mc;
 	u16	max_pkey;
 	u8	ar_sec;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.c b/drivers/net/ethernet/mellanox/mlxsw/pci.c
index 974ce47..faa4f3f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.c
@@ -1214,6 +1214,10 @@ static int mlxsw_pci_config_profile(struct mlxsw_pci *mlxsw_pci, char *mbox,
 			mbox, profile->max_flood_tables);
 		mlxsw_cmd_mbox_config_profile_max_vid_flood_tables_set(
 			mbox, profile->max_vid_flood_tables);
+		mlxsw_cmd_mbox_config_profile_max_fid_flood_tables_set(
+			mbox, profile->max_fid_flood_tables);
+		mlxsw_cmd_mbox_config_profile_fid_flood_table_size_set(
+			mbox, profile->fid_flood_table_size);
 	}
 	if (profile->used_flood_mode) {
 		mlxsw_cmd_mbox_config_profile_set_flood_mode_set(
-- 
1.9.3
