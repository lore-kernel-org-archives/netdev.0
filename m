From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 06/14] mlxsw: spectrum: Add another flood table for vFIDs
Date: Tue, 15 Dec 2015 16:03:39 +0100
Message-ID: <1450191827-6679-7-git-send-email-jiri@resnulli.us>
References: <1450191827-6679-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	gospo@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	f.fainelli@gmail.com, sfeldma@gmail.com, john.fastabend@gmail.com,
	roopa@cumulusnetworks.com, andrew@lunn.ch, kaber@trash.net,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:38499 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933550AbbLOPEA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 10:04:00 -0500
Received: by mail-wm0-f48.google.com with SMTP id p66so29759806wmp.1
        for <netdev@vger.kernel.org>; Tue, 15 Dec 2015 07:03:59 -0800 (PST)
In-Reply-To: <1450191827-6679-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

We previously used only one flood table for packets classified to vFIDs.
However, since we are going to add support for bridges between VLAN
interfaces (mapped to vFIDs) we need to add one more flood table.

That way we can separate the flooding domain of unknown unicast traffic
from all the rest and support flood control (as we do with the 802.1Q
bridge).

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 36 ++++++++--------------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  2 +-
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   |  5 +--
 3 files changed, 16 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 00ffff9..7b1ce97 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -679,7 +679,7 @@ int mlxsw_sp_port_add_vid(struct net_device *dev, __be16 __always_unused proto,
 
 	if (!vfid->nr_vports) {
 		err = mlxsw_sp_vport_flood_set(mlxsw_sp_vport, vfid->vfid,
-					       true);
+					       true, false);
 		if (err) {
 			netdev_err(dev, "Failed to setup flooding for vFID=%d\n",
 				   vfid->vfid);
@@ -747,7 +747,8 @@ err_port_vid_to_fid_set:
 		mlxsw_sp_port_vlan_mode_trans(mlxsw_sp_port);
 err_port_vp_mode_trans:
 	if (!vfid->nr_vports)
-		mlxsw_sp_vport_flood_set(mlxsw_sp_vport, vfid->vfid, false);
+		mlxsw_sp_vport_flood_set(mlxsw_sp_vport, vfid->vfid, false,
+					 false);
 err_vport_flood_set:
 	mlxsw_sp_port_vport_destroy(mlxsw_sp_vport);
 err_port_vport_create:
@@ -1788,16 +1789,15 @@ static int __mlxsw_sp_flood_init(struct mlxsw_core *mlxsw_core,
 	enum mlxsw_sp_flood_table flood_table;
 	char sfgc_pl[MLXSW_REG_SFGC_LEN];
 
-	if (bridge_type == MLXSW_REG_SFGC_BRIDGE_TYPE_VFID) {
+	if (bridge_type == MLXSW_REG_SFGC_BRIDGE_TYPE_VFID)
 		table_type = MLXSW_REG_SFGC_TABLE_TYPE_FID;
-		flood_table = 0;
-	} else {
+	else
 		table_type = MLXSW_REG_SFGC_TABLE_TYPE_FID_OFFEST;
-		if (type == MLXSW_REG_SFGC_TYPE_UNKNOWN_UNICAST)
-			flood_table = MLXSW_SP_FLOOD_TABLE_UC;
-		else
-			flood_table = MLXSW_SP_FLOOD_TABLE_BM;
-	}
+
+	if (type == MLXSW_REG_SFGC_TYPE_UNKNOWN_UNICAST)
+		flood_table = MLXSW_SP_FLOOD_TABLE_UC;
+	else
+		flood_table = MLXSW_SP_FLOOD_TABLE_BM;
 
 	mlxsw_reg_sfgc_pack(sfgc_pl, type, bridge_type, table_type,
 			    flood_table);
@@ -1808,9 +1808,6 @@ static int mlxsw_sp_flood_init(struct mlxsw_sp *mlxsw_sp)
 {
 	int type, err;
 
-	/* For non-offloaded netdevs, flood all traffic types to CPU
-	 * port.
-	 */
 	for (type = 0; type < MLXSW_REG_SFGC_TYPE_MAX; type++) {
 		if (type == MLXSW_REG_SFGC_TYPE_RESERVED)
 			continue;
@@ -1819,15 +1816,6 @@ static int mlxsw_sp_flood_init(struct mlxsw_sp *mlxsw_sp)
 					    MLXSW_REG_SFGC_BRIDGE_TYPE_VFID);
 		if (err)
 			return err;
-	}
-
-	/* For bridged ports, use one flooding table for unknown unicast
-	 * traffic and a second table for unregistered multicast and
-	 * broadcast.
-	 */
-	for (type = 0; type < MLXSW_REG_SFGC_TYPE_MAX; type++) {
-		if (type == MLXSW_REG_SFGC_TYPE_RESERVED)
-			continue;
 
 		err = __mlxsw_sp_flood_init(mlxsw_sp->core, type,
 					    MLXSW_REG_SFGC_BRIDGE_TYPE_1Q_FID);
@@ -1958,8 +1946,8 @@ static struct mlxsw_config_profile mlxsw_sp_config_profile = {
 	.flood_mode			= 3,
 	.max_fid_offset_flood_tables	= 2,
 	.fid_offset_flood_table_size	= VLAN_N_VID - 1,
-	.max_fid_flood_tables		= 1,
-	.fid_flood_table_size		= VLAN_N_VID,
+	.max_fid_flood_tables		= 2,
+	.fid_flood_table_size		= MLXSW_SP_VFID_MAX,
 	.used_max_ib_mc			= 1,
 	.max_ib_mc			= 0,
 	.used_max_pkey			= 1,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index c2aa9ac..809c322 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -200,6 +200,6 @@ int mlxsw_sp_port_add_vid(struct net_device *dev, __be16 __always_unused proto,
 int mlxsw_sp_port_kill_vid(struct net_device *dev,
 			   __be16 __always_unused proto, u16 vid);
 int mlxsw_sp_vport_flood_set(struct mlxsw_sp_port *mlxsw_sp_vport, u16 vfid,
-			     bool set);
+			     bool set, bool only_uc);
 
 #endif
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index a8c35ed..af9c73b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -193,12 +193,13 @@ err_port_flood_set:
 }
 
 int mlxsw_sp_vport_flood_set(struct mlxsw_sp_port *mlxsw_sp_vport, u16 vfid,
-			     bool set)
+			     bool set, bool only_uc)
 {
 	/* In case of vFIDs, index into the flooding table is relative to
 	 * the start of the vFIDs range.
 	 */
-	return __mlxsw_sp_port_flood_set(mlxsw_sp_vport, vfid, vfid, set, true);
+	return __mlxsw_sp_port_flood_set(mlxsw_sp_vport, vfid, vfid, set,
+					 only_uc);
 }
 
 static int mlxsw_sp_port_attr_br_flags_set(struct mlxsw_sp_port *mlxsw_sp_port,
-- 
1.9.3
