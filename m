From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 04/16] mlxsw: cmd: Introduce FID-offset flooding tables
Date: Fri, 16 Oct 2015 14:01:25 +0200
Message-ID: <1444996897-2708-5-git-send-email-jiri@resnulli.us>
References: <1444996897-2708-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	linux@roeck-us.net, vivien.didelot@savoirfairelinux.com,
	andrew@lunn.ch, john.fastabend@gmail.com, David.Laight@ACULAB.COM,
	stephen@networkplumber.org, tgraf@suug.ch, jhs@mojatatu.com,
	sagir@mellanox.com, mattyk@mellanox.com, aviadr@mellanox.com
To: netdev@vger.kernel.org, ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:36926 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752631AbbJPMBr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 08:01:47 -0400
Received: by wijq8 with SMTP id q8so7279847wij.0
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 05:01:46 -0700 (PDT)
In-Reply-To: <1444996897-2708-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Packets destined to offloaded netdevs will be classified to FIDs in the
device and flooded in case of BUM.

The flooding table used is of type FID-offset, which allows one to
create different flooding domains for different FIDs and specify the
offset in the flooding table for each FID (not necessarily equal to FID
or VID).

Add support for this flooding table type, by exposing the configuration
of the number of tables from this type and their size.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/cmd.h  | 12 ++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/core.h |  2 ++
 drivers/net/ethernet/mellanox/mlxsw/pci.c  |  4 ++++
 3 files changed, 18 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/cmd.h b/drivers/net/ethernet/mellanox/mlxsw/cmd.h
index 010eb5d..cd63b82 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/cmd.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/cmd.h
@@ -674,6 +674,18 @@ MLXSW_ITEM32(cmd_mbox, config_profile, max_vid_flood_tables, 0x30, 8, 4);
  */
 MLXSW_ITEM32(cmd_mbox, config_profile, flood_mode, 0x30, 0, 2);
 
+/* cmd_mbox_config_profile_max_fid_offset_flood_tables
+ * Maximum number of FID-offset flooding tables.
+ */
+MLXSW_ITEM32(cmd_mbox, config_profile,
+	     max_fid_offset_flood_tables, 0x34, 24, 4);
+
+/* cmd_mbox_config_profile_fid_offset_flood_table_size
+ * The size (number of entries) of each FID-offset flood table.
+ */
+MLXSW_ITEM32(cmd_mbox, config_profile,
+	     fid_offset_flood_table_size, 0x34, 0, 16);
+
 /* cmd_mbox_config_profile_max_fid_flood_tables
  * Maximum number of per-FID flooding tables.
  *
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index 8bb85ea..e92ab27 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -153,6 +153,8 @@ struct mlxsw_config_profile {
 	u8	max_flood_tables;
 	u8	max_vid_flood_tables;
 	u8	flood_mode;
+	u8	max_fid_offset_flood_tables;
+	u16	fid_offset_flood_table_size;
 	u8	max_fid_flood_tables;
 	u16	fid_flood_table_size;
 	u16	max_ib_mc;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.c b/drivers/net/ethernet/mellanox/mlxsw/pci.c
index faa4f3f..0fa44c8 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.c
@@ -1214,6 +1214,10 @@ static int mlxsw_pci_config_profile(struct mlxsw_pci *mlxsw_pci, char *mbox,
 			mbox, profile->max_flood_tables);
 		mlxsw_cmd_mbox_config_profile_max_vid_flood_tables_set(
 			mbox, profile->max_vid_flood_tables);
+		mlxsw_cmd_mbox_config_profile_max_fid_offset_flood_tables_set(
+			mbox, profile->max_fid_offset_flood_tables);
+		mlxsw_cmd_mbox_config_profile_fid_offset_flood_table_size_set(
+			mbox, profile->fid_offset_flood_table_size);
 		mlxsw_cmd_mbox_config_profile_max_fid_flood_tables_set(
 			mbox, profile->max_fid_flood_tables);
 		mlxsw_cmd_mbox_config_profile_fid_flood_table_size_set(
-- 
1.9.3
