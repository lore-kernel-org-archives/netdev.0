From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 7/9] mlxsw: pci: Add some miscellaneous resources
Date: Tue, 20 Sep 2016 11:16:55 +0200
Message-ID: <1474363017-2901-8-git-send-email-jiri@resnulli.us>
References: <1474363017-2901-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34652 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932185AbcITJRJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 05:17:09 -0400
Received: by mail-wm0-f65.google.com with SMTP id l132so2309162wmf.1
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 02:17:08 -0700 (PDT)
In-Reply-To: <1474363017-2901-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Add max system ports, max regions and max vlan groups to resource query.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.h     | 10 ++++++++--
 drivers/net/ethernet/mellanox/mlxsw/pci.c      | 15 +++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c |  6 ------
 3 files changed, 23 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index e936dc9..097e560 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -267,13 +267,16 @@ struct mlxsw_driver {
 };
 
 struct mlxsw_resources {
-	u8	max_span_valid:1,
+	u32	max_span_valid:1,
 		max_lag_valid:1,
 		max_ports_in_lag_valid:1,
 		kvd_size_valid:1,
 		kvd_single_min_size_valid:1,
 		kvd_double_min_size_valid:1,
-		max_virtual_routers_valid:1;
+		max_virtual_routers_valid:1,
+		max_system_ports_valid:1,
+		max_vlan_groups_valid:1,
+		max_regions_valid:1;
 	u8      max_span;
 	u8	max_lag;
 	u8	max_ports_in_lag;
@@ -281,6 +284,9 @@ struct mlxsw_resources {
 	u32	kvd_single_min_size;
 	u32	kvd_double_min_size;
 	u16     max_virtual_routers;
+	u16	max_system_ports;
+	u16	max_vlan_groups;
+	u16	max_regions;
 
 	/* Internal resources.
 	 * Determined by the SW, not queried from the HW.
diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.c b/drivers/net/ethernet/mellanox/mlxsw/pci.c
index cb95f9a..826b502 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.c
@@ -1162,6 +1162,9 @@ mlxsw_pci_config_profile_swid_config(struct mlxsw_pci *mlxsw_pci,
 #define MLXSW_KVD_SINGLE_MIN_SIZE_ID 0x1002
 #define MLXSW_KVD_DOUBLE_MIN_SIZE_ID 0x1003
 #define MLXSW_MAX_VIRTUAL_ROUTERS_ID 0x2C01
+#define MLXSW_MAX_SYSTEM_PORT_ID 0x2502
+#define MLXSW_MAX_VLAN_GROUPS_ID 0x2906
+#define MLXSW_MAX_REGIONS_ID 0x2901
 #define MLXSW_RESOURCES_QUERY_MAX_QUERIES 100
 #define MLXSW_RESOURCES_PER_QUERY 32
 
@@ -1197,6 +1200,18 @@ static void mlxsw_pci_resources_query_parse(int id, u64 val,
 		resources->max_virtual_routers = val;
 		resources->max_virtual_routers_valid = 1;
 		break;
+	case MLXSW_MAX_SYSTEM_PORT_ID:
+		resources->max_system_ports = val;
+		resources->max_system_ports_valid = 1;
+		break;
+	case MLXSW_MAX_VLAN_GROUPS_ID:
+		resources->max_vlan_groups = val;
+		resources->max_vlan_groups_valid = 1;
+		break;
+	case MLXSW_MAX_REGIONS_ID:
+		resources->max_regions = val;
+		resources->max_regions_valid = 1;
+		break;
 	default:
 		break;
 	}
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 29ad6a0..359a9dc 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -3040,12 +3040,6 @@ static struct mlxsw_config_profile mlxsw_sp_config_profile = {
 	.max_mid			= MLXSW_SP_MID_MAX,
 	.used_max_pgt			= 1,
 	.max_pgt			= 0,
-	.used_max_system_port		= 1,
-	.max_system_port		= 64,
-	.used_max_vlan_groups		= 1,
-	.max_vlan_groups		= 127,
-	.used_max_regions		= 1,
-	.max_regions			= 400,
 	.used_flood_tables		= 1,
 	.used_flood_mode		= 1,
 	.flood_mode			= 3,
-- 
2.5.5
