From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 2/2] mlxsw: spectrum_router: Use FIB notifications instead of switchdev calls
Date: Tue,  6 Sep 2016 14:01:40 +0200
Message-ID: <1473163300-2045-3-git-send-email-jiri@resnulli.us>
References: <1473163300-2045-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        linville@tuxdriver.com, tgraf@suug.ch, gospo@cumulusnetworks.com,
        sfeldma@gmail.com, ast@plumgrid.com, edumazet@google.com,
        hannes@stressinduktion.org, f.fainelli@gmail.com,
        dsa@cumulusnetworks.com, jhs@mojatatu.com,
        vivien.didelot@savoirfairelinux.com, john.fastabend@intel.com,
        andrew@lunn.ch, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33437 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754722AbcIFMBx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 08:01:53 -0400
Received: by mail-wm0-f67.google.com with SMTP id w207so18117126wmw.0
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2016 05:01:52 -0700 (PDT)
In-Reply-To: <1473163300-2045-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Until now, in order to offload a FIB entry to HW we use switchdev op.
However that has limits. Mainly in case we need to make the HW aware of
all route prefixes configured in kernel. HW needs to know those in order
to properly trap appropriate packets and pass the to kernel to do
the forwarding.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   8 +-
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 257 ++++++++++-----------
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   |   9 -
 3 files changed, 119 insertions(+), 155 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 49f4caf..03b97da 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -45,7 +45,7 @@
 #include <linux/list.h>
 #include <linux/dcbnl.h>
 #include <linux/in6.h>
-#include <net/switchdev.h>
+#include <linux/notifier.h>
 
 #include "port.h"
 #include "core.h"
@@ -302,6 +302,7 @@ struct mlxsw_sp {
 		struct mlxsw_sp_span_entry *entries;
 		int entries_count;
 	} span;
+	struct notifier_block fib_nb;
 };
 
 static inline struct mlxsw_sp_upper *
@@ -587,11 +588,6 @@ static inline void mlxsw_sp_port_dcb_fini(struct mlxsw_sp_port *mlxsw_sp_port)
 
 int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp);
 void mlxsw_sp_router_fini(struct mlxsw_sp *mlxsw_sp);
-int mlxsw_sp_router_fib4_add(struct mlxsw_sp_port *mlxsw_sp_port,
-			     const struct switchdev_obj_ipv4_fib *fib4,
-			     struct switchdev_trans *trans);
-int mlxsw_sp_router_fib4_del(struct mlxsw_sp_port *mlxsw_sp_port,
-			     const struct switchdev_obj_ipv4_fib *fib4);
 int mlxsw_sp_router_neigh_construct(struct net_device *dev,
 				    struct neighbour *n);
 void mlxsw_sp_router_neigh_destroy(struct net_device *dev,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 3f5c51d..7330439 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -43,6 +43,7 @@
 #include <net/netevent.h>
 #include <net/neighbour.h>
 #include <net/arp.h>
+#include <net/ip_fib.h>
 
 #include "spectrum.h"
 #include "core.h"
@@ -1489,50 +1490,6 @@ static void mlxsw_sp_nexthop_group_put(struct mlxsw_sp *mlxsw_sp,
 	mlxsw_sp_nexthop_group_destroy(mlxsw_sp, nh_grp);
 }
 
-static int __mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
-{
-	char rgcr_pl[MLXSW_REG_RGCR_LEN];
-
-	mlxsw_reg_rgcr_pack(rgcr_pl, true);
-	mlxsw_reg_rgcr_max_router_interfaces_set(rgcr_pl, MLXSW_SP_RIF_MAX);
-	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(rgcr), rgcr_pl);
-}
-
-static void __mlxsw_sp_router_fini(struct mlxsw_sp *mlxsw_sp)
-{
-	char rgcr_pl[MLXSW_REG_RGCR_LEN];
-
-	mlxsw_reg_rgcr_pack(rgcr_pl, false);
-	mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(rgcr), rgcr_pl);
-}
-
-int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
-{
-	int err;
-
-	INIT_LIST_HEAD(&mlxsw_sp->router.nexthop_neighs_list);
-	INIT_LIST_HEAD(&mlxsw_sp->router.nexthop_group_list);
-	err = __mlxsw_sp_router_init(mlxsw_sp);
-	if (err)
-		return err;
-	mlxsw_sp_lpm_init(mlxsw_sp);
-	mlxsw_sp_vrs_init(mlxsw_sp);
-	err = mlxsw_sp_neigh_init(mlxsw_sp);
-	if (err)
-		goto err_neigh_init;
-	return 0;
-
-err_neigh_init:
-	__mlxsw_sp_router_fini(mlxsw_sp);
-	return err;
-}
-
-void mlxsw_sp_router_fini(struct mlxsw_sp *mlxsw_sp)
-{
-	mlxsw_sp_neigh_fini(mlxsw_sp);
-	__mlxsw_sp_router_fini(mlxsw_sp);
-}
-
 static int mlxsw_sp_fib_entry_op4_remote(struct mlxsw_sp *mlxsw_sp,
 					 struct mlxsw_sp_fib_entry *fib_entry,
 					 enum mlxsw_reg_ralue_op op)
@@ -1637,45 +1594,34 @@ static int mlxsw_sp_fib_entry_del(struct mlxsw_sp *mlxsw_sp,
 				     MLXSW_REG_RALUE_OP_WRITE_DELETE);
 }
 
-struct mlxsw_sp_router_fib4_add_info {
-	struct switchdev_trans_item tritem;
-	struct mlxsw_sp *mlxsw_sp;
-	struct mlxsw_sp_fib_entry *fib_entry;
-};
-
-static void mlxsw_sp_router_fib4_add_info_destroy(void const *data)
-{
-	const struct mlxsw_sp_router_fib4_add_info *info = data;
-	struct mlxsw_sp_fib_entry *fib_entry = info->fib_entry;
-	struct mlxsw_sp *mlxsw_sp = info->mlxsw_sp;
-	struct mlxsw_sp_vr *vr = fib_entry->vr;
-
-	mlxsw_sp_fib_entry_destroy(fib_entry);
-	mlxsw_sp_vr_put(mlxsw_sp, vr);
-	kfree(info);
-}
-
 static int
 mlxsw_sp_router_fib4_entry_init(struct mlxsw_sp *mlxsw_sp,
-				const struct switchdev_obj_ipv4_fib *fib4,
+				const struct fib_notifier_info *fn_info,
 				struct mlxsw_sp_fib_entry *fib_entry)
 {
-	struct fib_info *fi = fib4->fi;
+	struct fib_info *fi = fn_info->fi;
 
-	if (fib4->type == RTN_LOCAL || fib4->type == RTN_BROADCAST) {
+	if (fn_info->type == RTN_LOCAL || fn_info->type == RTN_BROADCAST) {
 		fib_entry->type = MLXSW_SP_FIB_ENTRY_TYPE_TRAP;
 		return 0;
 	}
-	if (fib4->type != RTN_UNICAST)
+	if (fn_info->type != RTN_UNICAST)
 		return -EINVAL;
 
 	if (fi->fib_scope != RT_SCOPE_UNIVERSE) {
 		struct mlxsw_sp_rif *r;
 
-		fib_entry->type = MLXSW_SP_FIB_ENTRY_TYPE_LOCAL;
 		r = mlxsw_sp_rif_find_by_dev(mlxsw_sp, fi->fib_dev);
-		if (!r)
-			return -EINVAL;
+		if (!r) {
+			/* In case router interface is not found, that means
+			 * the fib entry was added to some device unrelated
+			 * to us. Set trap and pass the packets for
+			 * this prefix to kernel.
+			 */
+			fib_entry->type = MLXSW_SP_FIB_ENTRY_TYPE_TRAP;
+			return 0;
+		}
+		fib_entry->type = MLXSW_SP_FIB_ENTRY_TYPE_LOCAL;
 		fib_entry->rif = r->rif;
 		return 0;
 	}
@@ -1694,29 +1640,29 @@ mlxsw_sp_router_fib4_entry_fini(struct mlxsw_sp *mlxsw_sp,
 
 static struct mlxsw_sp_fib_entry *
 mlxsw_sp_fib_entry_get(struct mlxsw_sp *mlxsw_sp,
-		       const struct switchdev_obj_ipv4_fib *fib4)
+		       const struct fib_notifier_info *fn_info)
 {
 	struct mlxsw_sp_fib_entry *fib_entry;
-	struct fib_info *fi = fib4->fi;
+	struct fib_info *fi = fn_info->fi;
 	struct mlxsw_sp_vr *vr;
 	int err;
 
-	vr = mlxsw_sp_vr_get(mlxsw_sp, fib4->dst_len, fib4->tb_id,
+	vr = mlxsw_sp_vr_get(mlxsw_sp, fn_info->dst_len, fn_info->tb_id,
 			     MLXSW_SP_L3_PROTO_IPV4);
 	if (IS_ERR(vr))
 		return ERR_CAST(vr);
 
-	fib_entry = mlxsw_sp_fib_entry_lookup(vr->fib, &fib4->dst,
-					      sizeof(fib4->dst),
-					      fib4->dst_len, fi->fib_dev);
+	fib_entry = mlxsw_sp_fib_entry_lookup(vr->fib, &fn_info->dst,
+					      sizeof(fn_info->dst),
+					      fn_info->dst_len, fi->fib_dev);
 	if (fib_entry) {
 		/* Already exists, just take a reference */
 		fib_entry->ref_count++;
 		return fib_entry;
 	}
-	fib_entry = mlxsw_sp_fib_entry_create(vr->fib, &fib4->dst,
-					      sizeof(fib4->dst),
-					      fib4->dst_len, fi->fib_dev);
+	fib_entry = mlxsw_sp_fib_entry_create(vr->fib, &fn_info->dst,
+					      sizeof(fn_info->dst),
+					      fn_info->dst_len, fi->fib_dev);
 	if (!fib_entry) {
 		err = -ENOMEM;
 		goto err_fib_entry_create;
@@ -1724,7 +1670,7 @@ mlxsw_sp_fib_entry_get(struct mlxsw_sp *mlxsw_sp,
 	fib_entry->vr = vr;
 	fib_entry->ref_count = 1;
 
-	err = mlxsw_sp_router_fib4_entry_init(mlxsw_sp, fib4, fib_entry);
+	err = mlxsw_sp_router_fib4_entry_init(mlxsw_sp, fn_info, fib_entry);
 	if (err)
 		goto err_fib4_entry_init;
 
@@ -1740,17 +1686,17 @@ err_fib_entry_create:
 
 static struct mlxsw_sp_fib_entry *
 mlxsw_sp_fib_entry_find(struct mlxsw_sp *mlxsw_sp,
-			const struct switchdev_obj_ipv4_fib *fib4)
+			const struct fib_notifier_info *fn_info)
 {
 	struct mlxsw_sp_vr *vr;
 
-	vr = mlxsw_sp_vr_find(mlxsw_sp, fib4->tb_id, MLXSW_SP_L3_PROTO_IPV4);
+	vr = mlxsw_sp_vr_find(mlxsw_sp, fn_info->tb_id, MLXSW_SP_L3_PROTO_IPV4);
 	if (!vr)
 		return NULL;
 
-	return mlxsw_sp_fib_entry_lookup(vr->fib, &fib4->dst,
-					 sizeof(fib4->dst), fib4->dst_len,
-					 fib4->fi->fib_dev);
+	return mlxsw_sp_fib_entry_lookup(vr->fib, &fn_info->dst,
+					 sizeof(fn_info->dst), fn_info->dst_len,
+					 fn_info->fi->fib_dev);
 }
 
 void mlxsw_sp_fib_entry_put(struct mlxsw_sp *mlxsw_sp,
@@ -1765,60 +1711,29 @@ void mlxsw_sp_fib_entry_put(struct mlxsw_sp *mlxsw_sp,
 	mlxsw_sp_vr_put(mlxsw_sp, vr);
 }
 
-static int
-mlxsw_sp_router_fib4_add_prepare(struct mlxsw_sp_port *mlxsw_sp_port,
-				 const struct switchdev_obj_ipv4_fib *fib4,
-				 struct switchdev_trans *trans)
+static int mlxsw_sp_router_fib4_add(struct mlxsw_sp *mlxsw_sp,
+				    struct fib_notifier_info *fn_info)
 {
-	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
-	struct mlxsw_sp_router_fib4_add_info *info;
 	struct mlxsw_sp_fib_entry *fib_entry;
+	struct mlxsw_sp_vr *vr;
 	int err;
 
-	fib_entry = mlxsw_sp_fib_entry_get(mlxsw_sp, fib4);
-	if (IS_ERR(fib_entry))
+	fib_entry = mlxsw_sp_fib_entry_get(mlxsw_sp, fn_info);
+	if (IS_ERR(fib_entry)) {
+		dev_warn(mlxsw_sp->bus_info->dev, "Failed to get FIB4 entry being added.\n");
 		return PTR_ERR(fib_entry);
-
-	info = kmalloc(sizeof(*info), GFP_KERNEL);
-	if (!info) {
-		err = -ENOMEM;
-		goto err_alloc_info;
 	}
-	info->mlxsw_sp = mlxsw_sp;
-	info->fib_entry = fib_entry;
-	switchdev_trans_item_enqueue(trans, info,
-				     mlxsw_sp_router_fib4_add_info_destroy,
-				     &info->tritem);
-	return 0;
-
-err_alloc_info:
-	mlxsw_sp_fib_entry_put(mlxsw_sp, fib_entry);
-	return err;
-}
-
-static int
-mlxsw_sp_router_fib4_add_commit(struct mlxsw_sp_port *mlxsw_sp_port,
-				const struct switchdev_obj_ipv4_fib *fib4,
-				struct switchdev_trans *trans)
-{
-	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
-	struct mlxsw_sp_router_fib4_add_info *info;
-	struct mlxsw_sp_fib_entry *fib_entry;
-	struct mlxsw_sp_vr *vr;
-	int err;
-
-	info = switchdev_trans_item_dequeue(trans);
-	fib_entry = info->fib_entry;
-	kfree(info);
 
 	if (fib_entry->ref_count != 1)
 		return 0;
 
 	vr = fib_entry->vr;
 	err = mlxsw_sp_fib_entry_insert(vr->fib, fib_entry);
-	if (err)
+	if (err) {
+		dev_warn(mlxsw_sp->bus_info->dev, "Failed to insert FIB4 entry being added.\n");
 		goto err_fib_entry_insert;
-	err = mlxsw_sp_fib_entry_update(mlxsw_sp_port->mlxsw_sp, fib_entry);
+	}
+	err = mlxsw_sp_fib_entry_update(mlxsw_sp, fib_entry);
 	if (err)
 		goto err_fib_entry_add;
 	return 0;
@@ -1830,24 +1745,12 @@ err_fib_entry_insert:
 	return err;
 }
 
-int mlxsw_sp_router_fib4_add(struct mlxsw_sp_port *mlxsw_sp_port,
-			     const struct switchdev_obj_ipv4_fib *fib4,
-			     struct switchdev_trans *trans)
+static int mlxsw_sp_router_fib4_del(struct mlxsw_sp *mlxsw_sp,
+				    struct fib_notifier_info *fn_info)
 {
-	if (switchdev_trans_ph_prepare(trans))
-		return mlxsw_sp_router_fib4_add_prepare(mlxsw_sp_port,
-							fib4, trans);
-	return mlxsw_sp_router_fib4_add_commit(mlxsw_sp_port,
-					       fib4, trans);
-}
-
-int mlxsw_sp_router_fib4_del(struct mlxsw_sp_port *mlxsw_sp_port,
-			     const struct switchdev_obj_ipv4_fib *fib4)
-{
-	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	struct mlxsw_sp_fib_entry *fib_entry;
 
-	fib_entry = mlxsw_sp_fib_entry_find(mlxsw_sp, fib4);
+	fib_entry = mlxsw_sp_fib_entry_find(mlxsw_sp, fn_info);
 	if (!fib_entry) {
 		dev_warn(mlxsw_sp->bus_info->dev, "Failed to find FIB4 entry being removed.\n");
 		return -ENOENT;
@@ -1861,3 +1764,77 @@ int mlxsw_sp_router_fib4_del(struct mlxsw_sp_port *mlxsw_sp_port,
 	mlxsw_sp_fib_entry_put(mlxsw_sp, fib_entry);
 	return 0;
 }
+
+static void mlxsw_sp_router_fib4_abort(struct mlxsw_sp *mlxsw_sp)
+{
+	/* TODO: remove all ralue entries from the asic and set trap
+	 * to pass everything to kernel
+	 */
+}
+
+static int __mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
+{
+	char rgcr_pl[MLXSW_REG_RGCR_LEN];
+
+	mlxsw_reg_rgcr_pack(rgcr_pl, true);
+	mlxsw_reg_rgcr_max_router_interfaces_set(rgcr_pl, MLXSW_SP_RIF_MAX);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(rgcr), rgcr_pl);
+}
+
+static void __mlxsw_sp_router_fini(struct mlxsw_sp *mlxsw_sp)
+{
+	char rgcr_pl[MLXSW_REG_RGCR_LEN];
+
+	mlxsw_reg_rgcr_pack(rgcr_pl, false);
+	mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(rgcr), rgcr_pl);
+}
+
+static int mlxsw_sp_router_fib_event(struct notifier_block *nb,
+				     unsigned long event, void *ptr)
+{
+	struct mlxsw_sp *mlxsw_sp = container_of(nb, struct mlxsw_sp, fib_nb);
+	struct fib_notifier_info *fn_info = ptr;
+	int err;
+
+	switch (event) {
+	case FIB_EVENT_TYPE_ADD:
+		err = mlxsw_sp_router_fib4_add(mlxsw_sp, fn_info);
+		if (err)
+			mlxsw_sp_router_fib4_abort(mlxsw_sp);
+		break;
+	case FIB_EVENT_TYPE_DEL:
+		mlxsw_sp_router_fib4_del(mlxsw_sp, fn_info);
+		break;
+	}
+	return NOTIFY_DONE;
+}
+
+int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
+{
+	int err;
+
+	INIT_LIST_HEAD(&mlxsw_sp->router.nexthop_neighs_list);
+	INIT_LIST_HEAD(&mlxsw_sp->router.nexthop_group_list);
+	err = __mlxsw_sp_router_init(mlxsw_sp);
+	if (err)
+		return err;
+	mlxsw_sp_lpm_init(mlxsw_sp);
+	mlxsw_sp_vrs_init(mlxsw_sp);
+	err = mlxsw_sp_neigh_init(mlxsw_sp);
+	if (err)
+		goto err_neigh_init;
+	mlxsw_sp->fib_nb.notifier_call = mlxsw_sp_router_fib_event;
+	register_fib_notifier(&mlxsw_sp->fib_nb);
+	return 0;
+
+err_neigh_init:
+	__mlxsw_sp_router_fini(mlxsw_sp);
+	return err;
+}
+
+void mlxsw_sp_router_fini(struct mlxsw_sp *mlxsw_sp)
+{
+	unregister_fib_notifier(&mlxsw_sp->fib_nb);
+	mlxsw_sp_neigh_fini(mlxsw_sp);
+	__mlxsw_sp_router_fini(mlxsw_sp);
+}
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 7186c48..7042608 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -1044,11 +1044,6 @@ static int mlxsw_sp_port_obj_add(struct net_device *dev,
 					      SWITCHDEV_OBJ_PORT_VLAN(obj),
 					      trans);
 		break;
-	case SWITCHDEV_OBJ_ID_IPV4_FIB:
-		err = mlxsw_sp_router_fib4_add(mlxsw_sp_port,
-					       SWITCHDEV_OBJ_IPV4_FIB(obj),
-					       trans);
-		break;
 	case SWITCHDEV_OBJ_ID_PORT_FDB:
 		err = mlxsw_sp_port_fdb_static_add(mlxsw_sp_port,
 						   SWITCHDEV_OBJ_PORT_FDB(obj),
@@ -1181,10 +1176,6 @@ static int mlxsw_sp_port_obj_del(struct net_device *dev,
 		err = mlxsw_sp_port_vlans_del(mlxsw_sp_port,
 					      SWITCHDEV_OBJ_PORT_VLAN(obj));
 		break;
-	case SWITCHDEV_OBJ_ID_IPV4_FIB:
-		err = mlxsw_sp_router_fib4_del(mlxsw_sp_port,
-					       SWITCHDEV_OBJ_IPV4_FIB(obj));
-		break;
 	case SWITCHDEV_OBJ_ID_PORT_FDB:
 		err = mlxsw_sp_port_fdb_static_del(mlxsw_sp_port,
 						   SWITCHDEV_OBJ_PORT_FDB(obj));
-- 
2.5.5
