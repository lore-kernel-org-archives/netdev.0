From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 08/12] mlxsw: spectrum: Add router interface struct
Date: Sat,  2 Jul 2016 11:00:16 +0200
Message-ID: <1467450020-23415-9-git-send-email-jiri@resnulli.us>
References: <1467450020-23415-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36363 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752228AbcGBJAf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jul 2016 05:00:35 -0400
Received: by mail-wm0-f68.google.com with SMTP id c82so10282806wme.3
        for <netdev@vger.kernel.org>; Sat, 02 Jul 2016 02:00:35 -0700 (PDT)
In-Reply-To: <1467450020-23415-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When enabling the router in the device we will represent L3 netdevs
using router interfaces (RIFs). These will be specified whenever
programming routes or neighbours on the netdev.

Introduce the basic RIF infrastructure which allows one to lookup a RIF
by its netdev. Later patches in the series will extend this, but the
basic routines are needed now in order to direct traffic to CPU.

Pointers to the RIF structs are stored in an array indexed by the RIF's
number. This will allow us to efficiently update the kernel's neighbour
table when regularly dumping the device's table.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c |  3 +++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h | 19 +++++++++++++++++++
 2 files changed, 22 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index d011902..d15ebf3 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2470,6 +2470,7 @@ err_rx_listener_register:
 static void mlxsw_sp_fini(struct mlxsw_core *mlxsw_core)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_core_driver_priv(mlxsw_core);
+	int i;
 
 	mlxsw_sp_ports_remove(mlxsw_sp);
 	mlxsw_sp_router_fini(mlxsw_sp);
@@ -2478,6 +2479,8 @@ static void mlxsw_sp_fini(struct mlxsw_core *mlxsw_core)
 	mlxsw_sp_traps_fini(mlxsw_sp);
 	mlxsw_sp_event_unregister(mlxsw_sp, MLXSW_TRAP_ID_PUDE);
 	WARN_ON(!list_empty(&mlxsw_sp->fids));
+	for (i = 0; i < MLXSW_SP_RIF_MAX; i++)
+		WARN_ON_ONCE(mlxsw_sp->rifs[i]);
 }
 
 static struct mlxsw_config_profile mlxsw_sp_config_profile = {
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index c2ac037..83d5807 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -98,6 +98,11 @@ struct mlxsw_sp_fid {
 	u16 vid;
 };
 
+struct mlxsw_sp_rif {
+	struct net_device *dev;
+	u16 rif;
+};
+
 struct mlxsw_sp_mid {
 	struct list_head list;
 	unsigned char addr[ETH_ALEN];
@@ -169,6 +174,7 @@ struct mlxsw_sp {
 		DECLARE_BITMAP(mapped, MLXSW_SP_MID_MAX);
 	} br_mids;
 	struct list_head fids;	/* VLAN-aware bridge FIDs */
+	struct mlxsw_sp_rif *rifs[MLXSW_SP_RIF_MAX];
 	struct mlxsw_sp_port **ports;
 	struct mlxsw_core *core;
 	const struct mlxsw_bus_info *bus_info;
@@ -327,6 +333,19 @@ mlxsw_sp_port_vport_find_by_fid(const struct mlxsw_sp_port *mlxsw_sp_port,
 	return NULL;
 }
 
+static inline struct mlxsw_sp_rif *
+mlxsw_sp_rif_find_by_dev(const struct mlxsw_sp *mlxsw_sp,
+			 const struct net_device *dev)
+{
+	int i;
+
+	for (i = 0; i < MLXSW_SP_RIF_MAX; i++)
+		if (mlxsw_sp->rifs[i] && mlxsw_sp->rifs[i]->dev == dev)
+			return mlxsw_sp->rifs[i];
+
+	return NULL;
+}
+
 enum mlxsw_sp_flood_table {
 	MLXSW_SP_FLOOD_TABLE_UC,
 	MLXSW_SP_FLOOD_TABLE_BM,
-- 
2.5.5
