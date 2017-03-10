From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 09/10] mlxsw: spectrum_router: Explicitly Associate RIFs with VRs
Date: Fri, 10 Mar 2017 08:53:42 +0100
Message-ID: <1489132423-12575-10-git-send-email-jiri@resnulli.us>
References: <1489132423-12575-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34820 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753685AbdCJHyF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 02:54:05 -0500
Received: by mail-wm0-f65.google.com with SMTP id z63so931437wmg.2
        for <netdev@vger.kernel.org>; Thu, 09 Mar 2017 23:54:04 -0800 (PST)
In-Reply-To: <1489132423-12575-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Up until now we implicitly associated all the router interfaces (RIFs)
with the first virtual router (VR). This must be changed in order to
enable VRF offload. Otherwise, a packet received via a VRF slave would
do a FIB lookup in the same table used by other VRFs.

Instead, bind the RIF to a VR according to the table where FIB lookup
should be performed for packets received via the RIF.

Currently, we only care about the MAIN and LOCAL tables (which we squash
together).

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h          |  4 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  1 +
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 63 ++++++++++++++++------
 3 files changed, 50 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 0899e2d..eb94a5a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -4141,7 +4141,8 @@ static inline void mlxsw_reg_ritr_sp_if_pack(char *payload, bool lag,
 
 static inline void mlxsw_reg_ritr_pack(char *payload, bool enable,
 				       enum mlxsw_reg_ritr_if_type type,
-				       u16 rif, u16 mtu, const char *mac)
+				       u16 rif, u16 vr_id, u16 mtu,
+				       const char *mac)
 {
 	bool op = enable ? MLXSW_REG_RITR_RIF_CREATE : MLXSW_REG_RITR_RIF_DEL;
 
@@ -4153,6 +4154,7 @@ static inline void mlxsw_reg_ritr_pack(char *payload, bool enable,
 	mlxsw_reg_ritr_rif_set(payload, rif);
 	mlxsw_reg_ritr_ipv4_fe_set(payload, 1);
 	mlxsw_reg_ritr_lb_en_set(payload, 1);
+	mlxsw_reg_ritr_virtual_router_set(payload, vr_id);
 	mlxsw_reg_ritr_mtu_set(payload, mtu);
 	mlxsw_reg_ritr_if_mac_memcpy_to(payload, mac);
 }
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 5a7ffa1..3bc1b09 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -187,6 +187,7 @@ struct mlxsw_sp_fib;
 struct mlxsw_sp_vr {
 	u16 id; /* virtual router ID */
 	u32 tb_id; /* kernel fib table id */
+	unsigned int rif_count;
 	struct mlxsw_sp_fib *fib4;
 };
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 0a79fc7..22a4d68 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -58,6 +58,7 @@ struct mlxsw_sp_rif {
 	unsigned char addr[ETH_ALEN];
 	int mtu;
 	u16 rif;
+	u16 vr_id;
 };
 
 static struct mlxsw_sp_rif *
@@ -486,7 +487,7 @@ static struct mlxsw_sp_vr *mlxsw_sp_vr_get(struct mlxsw_sp *mlxsw_sp, u32 tb_id)
 
 static void mlxsw_sp_vr_put(struct mlxsw_sp_vr *vr)
 {
-	if (list_empty(&vr->fib4->node_list))
+	if (!vr->rif_count && list_empty(&vr->fib4->node_list))
 		mlxsw_sp_vr_destroy(vr);
 }
 
@@ -2666,15 +2667,15 @@ static void mlxsw_sp_vport_rif_sp_attr_get(struct mlxsw_sp_port *mlxsw_sp_vport,
 }
 
 static int mlxsw_sp_vport_rif_sp_op(struct mlxsw_sp_port *mlxsw_sp_vport,
-				    struct net_device *l3_dev, u16 rif,
-				    bool create)
+				    u16 vr_id, struct net_device *l3_dev,
+				    u16 rif, bool create)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_vport->mlxsw_sp;
 	bool lagged = mlxsw_sp_vport->lagged;
 	char ritr_pl[MLXSW_REG_RITR_LEN];
 	u16 system_port;
 
-	mlxsw_reg_ritr_pack(ritr_pl, create, MLXSW_REG_RITR_SP_IF, rif,
+	mlxsw_reg_ritr_pack(ritr_pl, create, MLXSW_REG_RITR_SP_IF, rif, vr_id,
 			    l3_dev->mtu, l3_dev->dev_addr);
 
 	mlxsw_sp_vport_rif_sp_attr_get(mlxsw_sp_vport, &lagged, &system_port);
@@ -2709,7 +2710,8 @@ mlxsw_sp_rfid_alloc(u16 fid, struct net_device *l3_dev)
 }
 
 static struct mlxsw_sp_rif *
-mlxsw_sp_rif_alloc(u16 rif, struct net_device *l3_dev, struct mlxsw_sp_fid *f)
+mlxsw_sp_rif_alloc(u16 rif, u16 vr_id, struct net_device *l3_dev,
+		   struct mlxsw_sp_fid *f)
 {
 	struct mlxsw_sp_rif *r;
 
@@ -2721,6 +2723,7 @@ mlxsw_sp_rif_alloc(u16 rif, struct net_device *l3_dev, struct mlxsw_sp_fid *f)
 	INIT_LIST_HEAD(&r->neigh_list);
 	ether_addr_copy(r->addr, l3_dev->dev_addr);
 	r->mtu = l3_dev->mtu;
+	r->vr_id = vr_id;
 	r->dev = l3_dev;
 	r->rif = rif;
 	r->f = f;
@@ -2733,6 +2736,7 @@ mlxsw_sp_vport_rif_sp_create(struct mlxsw_sp_port *mlxsw_sp_vport,
 			     struct net_device *l3_dev)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_vport->mlxsw_sp;
+	struct mlxsw_sp_vr *vr;
 	struct mlxsw_sp_fid *f;
 	struct mlxsw_sp_rif *r;
 	u16 fid, rif;
@@ -2742,9 +2746,14 @@ mlxsw_sp_vport_rif_sp_create(struct mlxsw_sp_port *mlxsw_sp_vport,
 	if (rif == MLXSW_SP_INVALID_RIF)
 		return ERR_PTR(-ERANGE);
 
-	err = mlxsw_sp_vport_rif_sp_op(mlxsw_sp_vport, l3_dev, rif, true);
+	vr = mlxsw_sp_vr_get(mlxsw_sp, RT_TABLE_MAIN);
+	if (IS_ERR(vr))
+		return ERR_CAST(vr);
+
+	err = mlxsw_sp_vport_rif_sp_op(mlxsw_sp_vport, vr->id, l3_dev, rif,
+				       true);
 	if (err)
-		return ERR_PTR(err);
+		goto err_vport_rif_sp_op;
 
 	fid = mlxsw_sp_rif_sp_to_fid(rif);
 	err = mlxsw_sp_rif_fdb_op(mlxsw_sp, l3_dev->dev_addr, fid, true);
@@ -2757,7 +2766,7 @@ mlxsw_sp_vport_rif_sp_create(struct mlxsw_sp_port *mlxsw_sp_vport,
 		goto err_rfid_alloc;
 	}
 
-	r = mlxsw_sp_rif_alloc(rif, l3_dev, f);
+	r = mlxsw_sp_rif_alloc(rif, vr->id, l3_dev, f);
 	if (!r) {
 		err = -ENOMEM;
 		goto err_rif_alloc;
@@ -2765,6 +2774,7 @@ mlxsw_sp_vport_rif_sp_create(struct mlxsw_sp_port *mlxsw_sp_vport,
 
 	f->r = r;
 	mlxsw_sp->rifs[rif] = r;
+	vr->rif_count++;
 
 	return r;
 
@@ -2773,7 +2783,9 @@ mlxsw_sp_vport_rif_sp_create(struct mlxsw_sp_port *mlxsw_sp_vport,
 err_rfid_alloc:
 	mlxsw_sp_rif_fdb_op(mlxsw_sp, l3_dev->dev_addr, fid, false);
 err_rif_fdb_op:
-	mlxsw_sp_vport_rif_sp_op(mlxsw_sp_vport, l3_dev, rif, false);
+	mlxsw_sp_vport_rif_sp_op(mlxsw_sp_vport, vr->id, l3_dev, rif, false);
+err_vport_rif_sp_op:
+	mlxsw_sp_vr_put(vr);
 	return ERR_PTR(err);
 }
 
@@ -2781,6 +2793,7 @@ static void mlxsw_sp_vport_rif_sp_destroy(struct mlxsw_sp_port *mlxsw_sp_vport,
 					  struct mlxsw_sp_rif *r)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_vport->mlxsw_sp;
+	struct mlxsw_sp_vr *vr = &mlxsw_sp->router.vrs[r->vr_id];
 	struct net_device *l3_dev = r->dev;
 	struct mlxsw_sp_fid *f = r->f;
 	u16 fid = f->fid;
@@ -2788,6 +2801,7 @@ static void mlxsw_sp_vport_rif_sp_destroy(struct mlxsw_sp_port *mlxsw_sp_vport,
 
 	mlxsw_sp_router_rif_gone_sync(mlxsw_sp, r);
 
+	vr->rif_count--;
 	mlxsw_sp->rifs[rif] = NULL;
 	f->r = NULL;
 
@@ -2797,7 +2811,9 @@ static void mlxsw_sp_vport_rif_sp_destroy(struct mlxsw_sp_port *mlxsw_sp_vport,
 
 	mlxsw_sp_rif_fdb_op(mlxsw_sp, l3_dev->dev_addr, fid, false);
 
-	mlxsw_sp_vport_rif_sp_op(mlxsw_sp_vport, l3_dev, rif, false);
+	mlxsw_sp_vport_rif_sp_op(mlxsw_sp_vport, vr->id, l3_dev, rif, false);
+
+	mlxsw_sp_vr_put(vr);
 }
 
 static int mlxsw_sp_vport_rif_sp_join(struct mlxsw_sp_port *mlxsw_sp_vport,
@@ -2948,7 +2964,7 @@ static enum mlxsw_reg_ritr_if_type mlxsw_sp_rif_type_get(u16 fid)
 		return MLXSW_REG_RITR_VLAN_IF;
 }
 
-static int mlxsw_sp_rif_bridge_op(struct mlxsw_sp *mlxsw_sp,
+static int mlxsw_sp_rif_bridge_op(struct mlxsw_sp *mlxsw_sp, u16 vr_id,
 				  struct net_device *l3_dev,
 				  u16 fid, u16 rif,
 				  bool create)
@@ -2957,7 +2973,7 @@ static int mlxsw_sp_rif_bridge_op(struct mlxsw_sp *mlxsw_sp,
 	char ritr_pl[MLXSW_REG_RITR_LEN];
 
 	rif_type = mlxsw_sp_rif_type_get(fid);
-	mlxsw_reg_ritr_pack(ritr_pl, create, rif_type, rif, l3_dev->mtu,
+	mlxsw_reg_ritr_pack(ritr_pl, create, rif_type, rif, vr_id, l3_dev->mtu,
 			    l3_dev->dev_addr);
 	mlxsw_reg_ritr_fid_set(ritr_pl, rif_type, fid);
 
@@ -2968,6 +2984,7 @@ static int mlxsw_sp_rif_bridge_create(struct mlxsw_sp *mlxsw_sp,
 				      struct net_device *l3_dev,
 				      struct mlxsw_sp_fid *f)
 {
+	struct mlxsw_sp_vr *vr;
 	struct mlxsw_sp_rif *r;
 	u16 rif;
 	int err;
@@ -2976,11 +2993,16 @@ static int mlxsw_sp_rif_bridge_create(struct mlxsw_sp *mlxsw_sp,
 	if (rif == MLXSW_SP_INVALID_RIF)
 		return -ERANGE;
 
+	vr = mlxsw_sp_vr_get(mlxsw_sp, RT_TABLE_MAIN);
+	if (IS_ERR(vr))
+		return PTR_ERR(vr);
+
 	err = mlxsw_sp_router_port_flood_set(mlxsw_sp, f->fid, true);
 	if (err)
-		return err;
+		goto err_port_flood_set;
 
-	err = mlxsw_sp_rif_bridge_op(mlxsw_sp, l3_dev, f->fid, rif, true);
+	err = mlxsw_sp_rif_bridge_op(mlxsw_sp, vr->id, l3_dev, f->fid, rif,
+				     true);
 	if (err)
 		goto err_rif_bridge_op;
 
@@ -2988,7 +3010,7 @@ static int mlxsw_sp_rif_bridge_create(struct mlxsw_sp *mlxsw_sp,
 	if (err)
 		goto err_rif_fdb_op;
 
-	r = mlxsw_sp_rif_alloc(rif, l3_dev, f);
+	r = mlxsw_sp_rif_alloc(rif, vr->id, l3_dev, f);
 	if (!r) {
 		err = -ENOMEM;
 		goto err_rif_alloc;
@@ -2996,6 +3018,7 @@ static int mlxsw_sp_rif_bridge_create(struct mlxsw_sp *mlxsw_sp,
 
 	f->r = r;
 	mlxsw_sp->rifs[rif] = r;
+	vr->rif_count++;
 
 	netdev_dbg(l3_dev, "RIF=%d created\n", rif);
 
@@ -3004,21 +3027,25 @@ static int mlxsw_sp_rif_bridge_create(struct mlxsw_sp *mlxsw_sp,
 err_rif_alloc:
 	mlxsw_sp_rif_fdb_op(mlxsw_sp, l3_dev->dev_addr, f->fid, false);
 err_rif_fdb_op:
-	mlxsw_sp_rif_bridge_op(mlxsw_sp, l3_dev, f->fid, rif, false);
+	mlxsw_sp_rif_bridge_op(mlxsw_sp, vr->id, l3_dev, f->fid, rif, false);
 err_rif_bridge_op:
 	mlxsw_sp_router_port_flood_set(mlxsw_sp, f->fid, false);
+err_port_flood_set:
+	mlxsw_sp_vr_put(vr);
 	return err;
 }
 
 void mlxsw_sp_rif_bridge_destroy(struct mlxsw_sp *mlxsw_sp,
 				 struct mlxsw_sp_rif *r)
 {
+	struct mlxsw_sp_vr *vr = &mlxsw_sp->router.vrs[r->vr_id];
 	struct net_device *l3_dev = r->dev;
 	struct mlxsw_sp_fid *f = r->f;
 	u16 rif = r->rif;
 
 	mlxsw_sp_router_rif_gone_sync(mlxsw_sp, r);
 
+	vr->rif_count--;
 	mlxsw_sp->rifs[rif] = NULL;
 	f->r = NULL;
 
@@ -3026,10 +3053,12 @@ void mlxsw_sp_rif_bridge_destroy(struct mlxsw_sp *mlxsw_sp,
 
 	mlxsw_sp_rif_fdb_op(mlxsw_sp, l3_dev->dev_addr, f->fid, false);
 
-	mlxsw_sp_rif_bridge_op(mlxsw_sp, l3_dev, f->fid, rif, false);
+	mlxsw_sp_rif_bridge_op(mlxsw_sp, vr->id, l3_dev, f->fid, rif, false);
 
 	mlxsw_sp_router_port_flood_set(mlxsw_sp, f->fid, false);
 
+	mlxsw_sp_vr_put(vr);
+
 	netdev_dbg(l3_dev, "RIF=%d destroyed\n", rif);
 }
 
-- 
2.7.4
