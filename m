From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 3/6] mlxsw: spectrum_router: Use FIB notifications instead of switchdev calls
Date: Fri, 23 Sep 2016 11:22:12 +0200
Message-ID: <1474622535-4002-4-git-send-email-jiri@resnulli.us>
References: <1474622535-4002-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        linville@tuxdriver.com, andy@greyhouse.net, f.fainelli@gmail.com,
        dsa@cumulusnetworks.com, jhs@mojatatu.com,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
        ivecera@redhat.com, kaber@trash.net, john@phrozen.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34717 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752772AbcIWJWX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 05:22:23 -0400
Received: by mail-wm0-f66.google.com with SMTP id l132so1772263wmf.1
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 02:22:22 -0700 (PDT)
In-Reply-To: <1474622535-4002-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Until now, in order to offload a FIB entry to HW we use switchdev op.
However that has limits. Mainly in case we need to make the HW aware of
all route prefixes configured in kernel. HW needs to know those in order
to properly trap appropriate packets and pass the to kernel to do
the forwarding. Abort mechanism is now handled within the mlxsw driver.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   9 +-
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 428 ++++++++++++---------
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   |   9 -
 3 files changed, 256 insertions(+), 190 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 73cae21..9b22863 100644
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
@@ -257,6 +257,7 @@ struct mlxsw_sp_router {
 #define MLXSW_SP_UNRESOLVED_NH_PROBE_INTERVAL 5000 /* ms */
 	struct list_head nexthop_group_list;
 	struct list_head nexthop_neighs_list;
+	bool aborted;
 };
 
 struct mlxsw_sp {
@@ -296,6 +297,7 @@ struct mlxsw_sp {
 		struct mlxsw_sp_span_entry *entries;
 		int entries_count;
 	} span;
+	struct notifier_block fib_nb;
 };
 
 static inline struct mlxsw_sp_upper *
@@ -584,11 +586,6 @@ static inline void mlxsw_sp_port_dcb_fini(struct mlxsw_sp_port *mlxsw_sp_port)
 
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
index cc653ac..1e5fb14 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -43,6 +43,7 @@
 #include <net/netevent.h>
 #include <net/neighbour.h>
 #include <net/arp.h>
+#include <net/ip_fib.h>
 
 #include "spectrum.h"
 #include "core.h"
@@ -122,17 +123,20 @@ struct mlxsw_sp_nexthop_group;
 
 struct mlxsw_sp_fib_entry {
 	struct rhash_head ht_node;
+	struct list_head list;
 	struct mlxsw_sp_fib_key key;
 	enum mlxsw_sp_fib_entry_type type;
 	unsigned int ref_count;
 	u16 rif; /* used for action local */
 	struct mlxsw_sp_vr *vr;
+	struct fib_info *fi;
 	struct list_head nexthop_group_node;
 	struct mlxsw_sp_nexthop_group *nh_group;
 };
 
 struct mlxsw_sp_fib {
 	struct rhashtable ht;
+	struct list_head entry_list;
 	unsigned long prefix_ref_count[MLXSW_SP_PREFIX_COUNT];
 	struct mlxsw_sp_prefix_usage prefix_usage;
 };
@@ -154,6 +158,7 @@ static int mlxsw_sp_fib_entry_insert(struct mlxsw_sp_fib *fib,
 				     mlxsw_sp_fib_ht_params);
 	if (err)
 		return err;
+	list_add_tail(&fib_entry->list, &fib->entry_list);
 	if (fib->prefix_ref_count[prefix_len]++ == 0)
 		mlxsw_sp_prefix_usage_set(&fib->prefix_usage, prefix_len);
 	return 0;
@@ -166,6 +171,7 @@ static void mlxsw_sp_fib_entry_remove(struct mlxsw_sp_fib *fib,
 
 	if (--fib->prefix_ref_count[prefix_len] == 0)
 		mlxsw_sp_prefix_usage_clear(&fib->prefix_usage, prefix_len);
+	list_del(&fib_entry->list);
 	rhashtable_remove_fast(&fib->ht, &fib_entry->ht_node,
 			       mlxsw_sp_fib_ht_params);
 }
@@ -216,6 +222,7 @@ static struct mlxsw_sp_fib *mlxsw_sp_fib_create(void)
 	err = rhashtable_init(&fib->ht, &mlxsw_sp_fib_ht_params);
 	if (err)
 		goto err_rhashtable_init;
+	INIT_LIST_HEAD(&fib->entry_list);
 	return fib;
 
 err_rhashtable_init:
@@ -1520,85 +1527,6 @@ static void mlxsw_sp_nexthop_group_put(struct mlxsw_sp *mlxsw_sp,
 	mlxsw_sp_nexthop_group_destroy(mlxsw_sp, nh_grp);
 }
 
-static int __mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
-{
-	struct mlxsw_resources *resources;
-	char rgcr_pl[MLXSW_REG_RGCR_LEN];
-	int err;
-
-	resources = mlxsw_core_resources_get(mlxsw_sp->core);
-	if (!resources->max_rif_valid)
-		return -EIO;
-
-	mlxsw_sp->rifs = kcalloc(resources->max_rif,
-				 sizeof(struct mlxsw_sp_rif *), GFP_KERNEL);
-	if (!mlxsw_sp->rifs)
-		return -ENOMEM;
-
-	mlxsw_reg_rgcr_pack(rgcr_pl, true);
-	mlxsw_reg_rgcr_max_router_interfaces_set(rgcr_pl, resources->max_rif);
-	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(rgcr), rgcr_pl);
-	if (err)
-		goto err_rgcr_fail;
-
-	return 0;
-
-err_rgcr_fail:
-	kfree(mlxsw_sp->rifs);
-	return err;
-}
-
-static void __mlxsw_sp_router_fini(struct mlxsw_sp *mlxsw_sp)
-{
-	struct mlxsw_resources *resources;
-	char rgcr_pl[MLXSW_REG_RGCR_LEN];
-	int i;
-
-	mlxsw_reg_rgcr_pack(rgcr_pl, false);
-	mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(rgcr), rgcr_pl);
-
-	resources = mlxsw_core_resources_get(mlxsw_sp->core);
-	for (i = 0; i < resources->max_rif; i++)
-		WARN_ON_ONCE(mlxsw_sp->rifs[i]);
-
-	kfree(mlxsw_sp->rifs);
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
-
-	mlxsw_sp_lpm_init(mlxsw_sp);
-	err = mlxsw_sp_vrs_init(mlxsw_sp);
-	if (err)
-		goto err_vrs_init;
-
-	err =  mlxsw_sp_neigh_init(mlxsw_sp);
-	if (err)
-		goto err_neigh_init;
-
-	return 0;
-
-err_neigh_init:
-	mlxsw_sp_vrs_fini(mlxsw_sp);
-err_vrs_init:
-	__mlxsw_sp_router_fini(mlxsw_sp);
-	return err;
-}
-
-void mlxsw_sp_router_fini(struct mlxsw_sp *mlxsw_sp)
-{
-	mlxsw_sp_neigh_fini(mlxsw_sp);
-	mlxsw_sp_vrs_fini(mlxsw_sp);
-	__mlxsw_sp_router_fini(mlxsw_sp);
-}
-
 static int mlxsw_sp_fib_entry_op4_remote(struct mlxsw_sp *mlxsw_sp,
 					 struct mlxsw_sp_fib_entry *fib_entry,
 					 enum mlxsw_reg_ralue_op op)
@@ -1706,48 +1634,46 @@ static int mlxsw_sp_fib_entry_del(struct mlxsw_sp *mlxsw_sp,
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
+				const struct fib_entry_notifier_info *fen_info,
 				struct mlxsw_sp_fib_entry *fib_entry)
 {
-	struct fib_info *fi = fib4->fi;
+	struct fib_info *fi = fen_info->fi;
+	struct mlxsw_sp_rif *r;
+	int nhsel;
 
-	if (fib4->type == RTN_LOCAL || fib4->type == RTN_BROADCAST) {
+	if (fen_info->type == RTN_LOCAL || fen_info->type == RTN_BROADCAST) {
 		fib_entry->type = MLXSW_SP_FIB_ENTRY_TYPE_TRAP;
 		return 0;
 	}
-	if (fib4->type != RTN_UNICAST)
+	if (fen_info->type != RTN_UNICAST)
 		return -EINVAL;
 
-	if (fi->fib_scope != RT_SCOPE_UNIVERSE) {
-		struct mlxsw_sp_rif *r;
+	for (nhsel = 0; nhsel < fi->fib_nhs; nhsel++) {
+		const struct fib_nh *nh = &fi->fib_nh[nhsel];
+
+		if (!nh->nh_dev)
+			continue;
+		r = mlxsw_sp_rif_find_by_dev(mlxsw_sp, nh->nh_dev);
+		if (!r) {
+			/* In case router interface is not found for
+			 * at least one of the nexthops, that means
+			 * the nexthop points to some device unrelated
+			 * to us. Set trap and pass the packets for
+			 * this prefix to kernel.
+			 */
+			fib_entry->type = MLXSW_SP_FIB_ENTRY_TYPE_TRAP;
+			return 0;
+		}
+	}
 
+	if (fi->fib_scope != RT_SCOPE_UNIVERSE) {
 		fib_entry->type = MLXSW_SP_FIB_ENTRY_TYPE_LOCAL;
-		r = mlxsw_sp_rif_find_by_dev(mlxsw_sp, fi->fib_dev);
-		if (!r)
-			return -EINVAL;
 		fib_entry->rif = r->rif;
 		return 0;
 	}
+
 	fib_entry->type = MLXSW_SP_FIB_ENTRY_TYPE_REMOTE;
 	return mlxsw_sp_nexthop_group_get(mlxsw_sp, fib_entry, fi);
 }
@@ -1763,37 +1689,38 @@ mlxsw_sp_router_fib4_entry_fini(struct mlxsw_sp *mlxsw_sp,
 
 static struct mlxsw_sp_fib_entry *
 mlxsw_sp_fib_entry_get(struct mlxsw_sp *mlxsw_sp,
-		       const struct switchdev_obj_ipv4_fib *fib4)
+		       const struct fib_entry_notifier_info *fen_info)
 {
 	struct mlxsw_sp_fib_entry *fib_entry;
-	struct fib_info *fi = fib4->fi;
+	struct fib_info *fi = fen_info->fi;
 	struct mlxsw_sp_vr *vr;
 	int err;
 
-	vr = mlxsw_sp_vr_get(mlxsw_sp, fib4->dst_len, fib4->tb_id,
+	vr = mlxsw_sp_vr_get(mlxsw_sp, fen_info->dst_len, fen_info->tb_id,
 			     MLXSW_SP_L3_PROTO_IPV4);
 	if (IS_ERR(vr))
 		return ERR_CAST(vr);
 
-	fib_entry = mlxsw_sp_fib_entry_lookup(vr->fib, &fib4->dst,
-					      sizeof(fib4->dst),
-					      fib4->dst_len, fi->fib_dev);
+	fib_entry = mlxsw_sp_fib_entry_lookup(vr->fib, &fen_info->dst,
+					      sizeof(fen_info->dst),
+					      fen_info->dst_len, fi->fib_dev);
 	if (fib_entry) {
 		/* Already exists, just take a reference */
 		fib_entry->ref_count++;
 		return fib_entry;
 	}
-	fib_entry = mlxsw_sp_fib_entry_create(vr->fib, &fib4->dst,
-					      sizeof(fib4->dst),
-					      fib4->dst_len, fi->fib_dev);
+	fib_entry = mlxsw_sp_fib_entry_create(vr->fib, &fen_info->dst,
+					      sizeof(fen_info->dst),
+					      fen_info->dst_len, fi->fib_dev);
 	if (!fib_entry) {
 		err = -ENOMEM;
 		goto err_fib_entry_create;
 	}
 	fib_entry->vr = vr;
+	fib_entry->fi = fi;
 	fib_entry->ref_count = 1;
 
-	err = mlxsw_sp_router_fib4_entry_init(mlxsw_sp, fib4, fib_entry);
+	err = mlxsw_sp_router_fib4_entry_init(mlxsw_sp, fen_info, fib_entry);
 	if (err)
 		goto err_fib4_entry_init;
 
@@ -1809,17 +1736,19 @@ err_fib_entry_create:
 
 static struct mlxsw_sp_fib_entry *
 mlxsw_sp_fib_entry_find(struct mlxsw_sp *mlxsw_sp,
-			const struct switchdev_obj_ipv4_fib *fib4)
+			const struct fib_entry_notifier_info *fen_info)
 {
 	struct mlxsw_sp_vr *vr;
 
-	vr = mlxsw_sp_vr_find(mlxsw_sp, fib4->tb_id, MLXSW_SP_L3_PROTO_IPV4);
+	vr = mlxsw_sp_vr_find(mlxsw_sp, fen_info->tb_id,
+			      MLXSW_SP_L3_PROTO_IPV4);
 	if (!vr)
 		return NULL;
 
-	return mlxsw_sp_fib_entry_lookup(vr->fib, &fib4->dst,
-					 sizeof(fib4->dst), fib4->dst_len,
-					 fib4->fi->fib_dev);
+	return mlxsw_sp_fib_entry_lookup(vr->fib, &fen_info->dst,
+					 sizeof(fen_info->dst),
+					 fen_info->dst_len,
+					 fen_info->fi->fib_dev);
 }
 
 static void mlxsw_sp_fib_entry_put(struct mlxsw_sp *mlxsw_sp,
@@ -1834,62 +1763,48 @@ static void mlxsw_sp_fib_entry_put(struct mlxsw_sp *mlxsw_sp,
 	mlxsw_sp_vr_put(mlxsw_sp, vr);
 }
 
-static int
-mlxsw_sp_router_fib4_add_prepare(struct mlxsw_sp_port *mlxsw_sp_port,
-				 const struct switchdev_obj_ipv4_fib *fib4,
-				 struct switchdev_trans *trans)
+static void mlxsw_sp_fib_entry_put_all(struct mlxsw_sp *mlxsw_sp,
+				       struct mlxsw_sp_fib_entry *fib_entry)
 {
-	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
-	struct mlxsw_sp_router_fib4_add_info *info;
-	struct mlxsw_sp_fib_entry *fib_entry;
-	int err;
-
-	fib_entry = mlxsw_sp_fib_entry_get(mlxsw_sp, fib4);
-	if (IS_ERR(fib_entry))
-		return PTR_ERR(fib_entry);
-
-	info = kmalloc(sizeof(*info), GFP_KERNEL);
-	if (!info) {
-		err = -ENOMEM;
-		goto err_alloc_info;
-	}
-	info->mlxsw_sp = mlxsw_sp;
-	info->fib_entry = fib_entry;
-	switchdev_trans_item_enqueue(trans, info,
-				     mlxsw_sp_router_fib4_add_info_destroy,
-				     &info->tritem);
-	return 0;
+	unsigned int last_ref_count;
 
-err_alloc_info:
-	mlxsw_sp_fib_entry_put(mlxsw_sp, fib_entry);
-	return err;
+	do {
+		last_ref_count = fib_entry->ref_count;
+		mlxsw_sp_fib_entry_put(mlxsw_sp, fib_entry);
+	} while (last_ref_count != 1);
 }
 
-static int
-mlxsw_sp_router_fib4_add_commit(struct mlxsw_sp_port *mlxsw_sp_port,
-				const struct switchdev_obj_ipv4_fib *fib4,
-				struct switchdev_trans *trans)
+static int mlxsw_sp_router_fib4_add(struct mlxsw_sp *mlxsw_sp,
+				    struct fib_entry_notifier_info *fen_info)
 {
-	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
-	struct mlxsw_sp_router_fib4_add_info *info;
 	struct mlxsw_sp_fib_entry *fib_entry;
 	struct mlxsw_sp_vr *vr;
 	int err;
 
-	info = switchdev_trans_item_dequeue(trans);
-	fib_entry = info->fib_entry;
-	kfree(info);
+	if (mlxsw_sp->router.aborted)
+		return 0;
+
+	fib_entry = mlxsw_sp_fib_entry_get(mlxsw_sp, fen_info);
+	if (IS_ERR(fib_entry)) {
+		dev_warn(mlxsw_sp->bus_info->dev, "Failed to get FIB4 entry being added.\n");
+		return PTR_ERR(fib_entry);
+	}
 
 	if (fib_entry->ref_count != 1)
-		return 0;
+		goto skip_add;
 
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
+
+skip_add:
+	fib_info_offload_inc(fen_info->fi);
 	return 0;
 
 err_fib_entry_add:
@@ -1899,29 +1814,22 @@ err_fib_entry_insert:
 	return err;
 }
 
-int mlxsw_sp_router_fib4_add(struct mlxsw_sp_port *mlxsw_sp_port,
-			     const struct switchdev_obj_ipv4_fib *fib4,
-			     struct switchdev_trans *trans)
-{
-	if (switchdev_trans_ph_prepare(trans))
-		return mlxsw_sp_router_fib4_add_prepare(mlxsw_sp_port,
-							fib4, trans);
-	return mlxsw_sp_router_fib4_add_commit(mlxsw_sp_port,
-					       fib4, trans);
-}
-
-int mlxsw_sp_router_fib4_del(struct mlxsw_sp_port *mlxsw_sp_port,
-			     const struct switchdev_obj_ipv4_fib *fib4)
+static int mlxsw_sp_router_fib4_del(struct mlxsw_sp *mlxsw_sp,
+				    struct fib_entry_notifier_info *fen_info)
 {
-	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	struct mlxsw_sp_fib_entry *fib_entry;
 
-	fib_entry = mlxsw_sp_fib_entry_find(mlxsw_sp, fib4);
+	if (mlxsw_sp->router.aborted)
+		return 0;
+
+	fib_entry = mlxsw_sp_fib_entry_find(mlxsw_sp, fen_info);
 	if (!fib_entry) {
 		dev_warn(mlxsw_sp->bus_info->dev, "Failed to find FIB4 entry being removed.\n");
 		return -ENOENT;
 	}
 
+	fib_info_offload_dec(fen_info->fi);
+
 	if (fib_entry->ref_count == 1) {
 		mlxsw_sp_fib_entry_del(mlxsw_sp, fib_entry);
 		mlxsw_sp_fib_entry_remove(fib_entry->vr->fib, fib_entry);
@@ -1930,3 +1838,173 @@ int mlxsw_sp_router_fib4_del(struct mlxsw_sp_port *mlxsw_sp_port,
 	mlxsw_sp_fib_entry_put(mlxsw_sp, fib_entry);
 	return 0;
 }
+
+static int mlxsw_sp_router_set_abort_trap(struct mlxsw_sp *mlxsw_sp)
+{
+	char ralta_pl[MLXSW_REG_RALTA_LEN];
+	char ralst_pl[MLXSW_REG_RALST_LEN];
+	char raltb_pl[MLXSW_REG_RALTB_LEN];
+	char ralue_pl[MLXSW_REG_RALUE_LEN];
+	int err;
+
+	mlxsw_reg_ralta_pack(ralta_pl, true, MLXSW_REG_RALXX_PROTOCOL_IPV4,
+			     MLXSW_SP_LPM_TREE_MIN);
+	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ralta), ralta_pl);
+	if (err)
+		return err;
+
+	mlxsw_reg_ralst_pack(ralst_pl, 0xff, MLXSW_SP_LPM_TREE_MIN);
+	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ralst), ralst_pl);
+	if (err)
+		return err;
+
+	mlxsw_reg_raltb_pack(raltb_pl, 0, MLXSW_REG_RALXX_PROTOCOL_IPV4, 0);
+	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(raltb), raltb_pl);
+	if (err)
+		return err;
+
+	mlxsw_reg_ralue_pack4(ralue_pl, MLXSW_SP_L3_PROTO_IPV4,
+			      MLXSW_REG_RALUE_OP_WRITE_WRITE, 0, 0, 0);
+	mlxsw_reg_ralue_act_ip2me_pack(ralue_pl);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ralue), ralue_pl);
+}
+
+static void mlxsw_sp_router_fib4_abort(struct mlxsw_sp *mlxsw_sp)
+{
+	struct mlxsw_resources *resources;
+	struct mlxsw_sp_fib_entry *fib_entry;
+	struct mlxsw_sp_fib_entry *tmp;
+	struct mlxsw_sp_vr *vr;
+	int i;
+	int err;
+
+	resources = mlxsw_core_resources_get(mlxsw_sp->core);
+	for (i = 0; i < resources->max_virtual_routers; i++) {
+		vr = &mlxsw_sp->router.vrs[i];
+		if (!vr->used)
+			continue;
+
+		list_for_each_entry_safe(fib_entry, tmp,
+					 &vr->fib->entry_list, list) {
+			bool do_break = &tmp->list == &vr->fib->entry_list;
+
+			fib_info_offload_dec(fib_entry->fi);
+			mlxsw_sp_fib_entry_del(mlxsw_sp, fib_entry);
+			mlxsw_sp_fib_entry_remove(fib_entry->vr->fib,
+						  fib_entry);
+			mlxsw_sp_fib_entry_put_all(mlxsw_sp, fib_entry);
+			if (do_break)
+				break;
+		}
+	}
+	mlxsw_sp->router.aborted = true;
+	err = mlxsw_sp_router_set_abort_trap(mlxsw_sp);
+	if (err)
+		dev_warn(mlxsw_sp->bus_info->dev, "Failed to set abort trap.\n");
+}
+
+static int __mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
+{
+	struct mlxsw_resources *resources;
+	char rgcr_pl[MLXSW_REG_RGCR_LEN];
+	int err;
+
+	resources = mlxsw_core_resources_get(mlxsw_sp->core);
+	if (!resources->max_rif_valid)
+		return -EIO;
+
+	mlxsw_sp->rifs = kcalloc(resources->max_rif,
+				 sizeof(struct mlxsw_sp_rif *), GFP_KERNEL);
+	if (!mlxsw_sp->rifs)
+		return -ENOMEM;
+
+	mlxsw_reg_rgcr_pack(rgcr_pl, true);
+	mlxsw_reg_rgcr_max_router_interfaces_set(rgcr_pl, resources->max_rif);
+	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(rgcr), rgcr_pl);
+	if (err)
+		goto err_rgcr_fail;
+
+	return 0;
+
+err_rgcr_fail:
+	kfree(mlxsw_sp->rifs);
+	return err;
+}
+
+static void __mlxsw_sp_router_fini(struct mlxsw_sp *mlxsw_sp)
+{
+	struct mlxsw_resources *resources;
+	char rgcr_pl[MLXSW_REG_RGCR_LEN];
+	int i;
+
+	mlxsw_reg_rgcr_pack(rgcr_pl, false);
+	mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(rgcr), rgcr_pl);
+
+	resources = mlxsw_core_resources_get(mlxsw_sp->core);
+	for (i = 0; i < resources->max_rif; i++)
+		WARN_ON_ONCE(mlxsw_sp->rifs[i]);
+
+	kfree(mlxsw_sp->rifs);
+}
+
+static int mlxsw_sp_router_fib_event(struct notifier_block *nb,
+				     unsigned long event, void *ptr)
+{
+	struct mlxsw_sp *mlxsw_sp = container_of(nb, struct mlxsw_sp, fib_nb);
+	struct fib_entry_notifier_info *fen_info = ptr;
+	int err;
+
+	switch (event) {
+	case FIB_EVENT_ENTRY_ADD:
+		err = mlxsw_sp_router_fib4_add(mlxsw_sp, fen_info);
+		if (err)
+			mlxsw_sp_router_fib4_abort(mlxsw_sp);
+		break;
+	case FIB_EVENT_ENTRY_DEL:
+		mlxsw_sp_router_fib4_del(mlxsw_sp, fen_info);
+		break;
+	case FIB_EVENT_RULE_ADD: /* fall through */
+	case FIB_EVENT_RULE_DEL:
+		mlxsw_sp_router_fib4_abort(mlxsw_sp);
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
+
+	mlxsw_sp_lpm_init(mlxsw_sp);
+	err = mlxsw_sp_vrs_init(mlxsw_sp);
+	if (err)
+		goto err_vrs_init;
+
+	err =  mlxsw_sp_neigh_init(mlxsw_sp);
+	if (err)
+		goto err_neigh_init;
+
+	mlxsw_sp->fib_nb.notifier_call = mlxsw_sp_router_fib_event;
+	register_fib_notifier(&mlxsw_sp->fib_nb);
+	return 0;
+
+err_neigh_init:
+	mlxsw_sp_vrs_fini(mlxsw_sp);
+err_vrs_init:
+	__mlxsw_sp_router_fini(mlxsw_sp);
+	return err;
+}
+
+void mlxsw_sp_router_fini(struct mlxsw_sp *mlxsw_sp)
+{
+	unregister_fib_notifier(&mlxsw_sp->fib_nb);
+	mlxsw_sp_neigh_fini(mlxsw_sp);
+	mlxsw_sp_vrs_fini(mlxsw_sp);
+	__mlxsw_sp_router_fini(mlxsw_sp);
+}
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 2b04b76..5e00c79 100644
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
