From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 12/18] mlxsw: spectrum_router: Extend the RIF struct
Date: Fri, 26 May 2017 08:37:34 +0200
Message-ID: <20170526063740.8909-13-jiri@resnulli.us>
References: <20170526063740.8909-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        stephen@networkplumber.org, nikolay@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35586 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S970581AbdEZGiA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 02:38:00 -0400
Received: by mail-wm0-f65.google.com with SMTP id g15so1684481wmc.2
        for <netdev@vger.kernel.org>; Thu, 25 May 2017 23:38:00 -0700 (PDT)
In-Reply-To: <20170526063740.8909-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Currently, when a Subport RIF is configured, the LAG status and VLAN of
the underlying port are read from the port itself. This is problematic,
as we would like to have common code to configure all types of RIFs,
which aren't necessarily bound to a port.

Instead, embed the RIF in a struct specific to the Subport type, which
contains all the necessary information.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 31 +++++++++++++++++++---
 1 file changed, 27 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index e81d45c..28ba5d3 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -97,6 +97,16 @@ struct mlxsw_sp_rif {
 	bool counter_egress_valid;
 };
 
+struct mlxsw_sp_rif_subport {
+	struct mlxsw_sp_rif common;
+	union {
+		u16 system_port;
+		u16 lag_id;
+	};
+	u16 vid;
+	bool lag;
+};
+
 static unsigned int *
 mlxsw_sp_rif_p_counter_get(struct mlxsw_sp_rif *rif,
 			   enum mlxsw_sp_rif_counter_dir dir)
@@ -2965,11 +2975,13 @@ mlxsw_sp_rfid_alloc(u16 fid, struct net_device *l3_dev)
 
 static struct mlxsw_sp_rif *
 mlxsw_sp_rif_alloc(u16 rif_index, u16 vr_id, struct net_device *l3_dev,
-		   struct mlxsw_sp_fid *f)
+		   struct mlxsw_sp_fid *f, bool is_subport)
 {
+	size_t size = is_subport ? sizeof(struct mlxsw_sp_rif_subport) :
+				   sizeof(struct mlxsw_sp_rif);
 	struct mlxsw_sp_rif *rif;
 
-	rif = kzalloc(sizeof(*rif), GFP_KERNEL);
+	rif = kzalloc(size, GFP_KERNEL);
 	if (!rif)
 		return NULL;
 
@@ -3007,6 +3019,7 @@ mlxsw_sp_port_vlan_rif_sp_create(struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan,
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = mlxsw_sp_port_vlan->mlxsw_sp_port;
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	struct mlxsw_sp_rif_subport *rif_subport;
 	u32 tb_id = l3mdev_fib_table(l3_dev);
 	struct mlxsw_sp_vr *vr;
 	struct mlxsw_sp_fid *f;
@@ -3029,12 +3042,22 @@ mlxsw_sp_port_vlan_rif_sp_create(struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan,
 		goto err_vr_get;
 	}
 
-	rif = mlxsw_sp_rif_alloc(rif_index, vr->id, l3_dev, f);
+	rif = mlxsw_sp_rif_alloc(rif_index, vr->id, l3_dev, f, true);
 	if (!rif) {
 		err = -ENOMEM;
 		goto err_rif_alloc;
 	}
 
+	rif_subport = container_of(rif, struct mlxsw_sp_rif_subport, common);
+	rif_subport->vid = mlxsw_sp_port_vlan->vid;
+	if (mlxsw_sp_port->lagged) {
+		rif_subport->lag = true;
+		rif_subport->lag_id = mlxsw_sp_port->lag_id;
+	} else {
+		rif_subport->lag = false;
+		rif_subport->system_port = mlxsw_sp_port->local_port;
+	}
+
 	err = mlxsw_sp_port_vlan_rif_sp_op(mlxsw_sp_port_vlan, vr->id, l3_dev,
 					   rif_index, true);
 	if (err)
@@ -3341,7 +3364,7 @@ static int mlxsw_sp_rif_bridge_create(struct mlxsw_sp *mlxsw_sp,
 	if (err)
 		goto err_port_flood_set;
 
-	rif = mlxsw_sp_rif_alloc(rif_index, vr->id, l3_dev, f);
+	rif = mlxsw_sp_rif_alloc(rif_index, vr->id, l3_dev, f, false);
 	if (!rif) {
 		err = -ENOMEM;
 		goto err_rif_alloc;
-- 
2.9.3
