From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 5/7] mlxsw: spectrum_router: Correctly handle identical routes
Date: Thu,  9 Feb 2017 10:28:42 +0100
Message-ID: <1486632524-5588-6-git-send-email-jiri@resnulli.us>
References: <1486632524-5588-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:33191 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752206AbdBIJhb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 04:37:31 -0500
Received: by mail-wr0-f195.google.com with SMTP id i10so11314213wrb.0
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 01:37:03 -0800 (PST)
In-Reply-To: <1486632524-5588-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

In the device, routes are indexed in a routing table based on the prefix
and its length. This is in contrast to the kernel's FIB where several
FIB aliases can exist with these parameters being identical. In such
cases, the routes will be sorted by table ID (LOCAL first, then MAIN),
TOS and finally priority (metric).

During lookup, these routes will be evaluated in order. In case the
packet's TOS field is non-zero and a FIB alias with a matching TOS is
found, then it's selected. Otherwise, the lookup defaults to the route
with TOS 0 (if it exists). However, if the requested scope is narrower
than the one found, then the lookup continues.

To best reflect the kernel's datapath we should take the above into
account. Given a prefix and its length, the reflected route will always
be the first one in the FIB alias list. However, if the route has a
non-zero TOS then its action will be converted to trap instead of
forward, since we currently don't support TOS-based routing. If this
turns out to be a real issue, we can add support for that using
policy-based switching.

The route's scope can be effectively ignored as any packet being routed
by the device would've been looked-up using the widest scope (UNIVERSE).

To achieve that we need to do two changes. Firstly, we need to create
another struct (FIB node) that will hold the list of FIB entries sharing
the same prefix and length. This struct will be hashed using these two
parameters.

Secondly, we need to change the route reflection to match the above
logic, so that the first FIB entry in the list will be programmed into
the device while the rest will remain in the driver's cache in case of
subsequent changes.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 581 ++++++++++++++-------
 1 file changed, 403 insertions(+), 178 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 71ff02f..7c55df9 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -109,7 +109,6 @@ mlxsw_sp_prefix_usage_clear(struct mlxsw_sp_prefix_usage *prefix_usage,
 }
 
 struct mlxsw_sp_fib_key {
-	struct net_device *dev;
 	unsigned char addr[sizeof(struct in6_addr)];
 	unsigned char prefix_len;
 };
@@ -122,94 +121,39 @@ enum mlxsw_sp_fib_entry_type {
 
 struct mlxsw_sp_nexthop_group;
 
-struct mlxsw_sp_fib_entry {
-	struct rhash_head ht_node;
+struct mlxsw_sp_fib_node {
+	struct list_head entry_list;
 	struct list_head list;
+	struct rhash_head ht_node;
+	struct mlxsw_sp_vr *vr;
 	struct mlxsw_sp_fib_key key;
+};
+
+struct mlxsw_sp_fib_entry_params {
+	u32 tb_id;
+	u32 prio;
+	u8 tos;
+	u8 type;
+};
+
+struct mlxsw_sp_fib_entry {
+	struct list_head list;
+	struct mlxsw_sp_fib_node *fib_node;
 	enum mlxsw_sp_fib_entry_type type;
-	unsigned int ref_count;
-	struct mlxsw_sp_vr *vr;
 	struct list_head nexthop_group_node;
 	struct mlxsw_sp_nexthop_group *nh_group;
+	struct mlxsw_sp_fib_entry_params params;
 	bool offloaded;
 };
 
 struct mlxsw_sp_fib {
 	struct rhashtable ht;
-	struct list_head entry_list;
+	struct list_head node_list;
 	unsigned long prefix_ref_count[MLXSW_SP_PREFIX_COUNT];
 	struct mlxsw_sp_prefix_usage prefix_usage;
 };
 
-static const struct rhashtable_params mlxsw_sp_fib_ht_params = {
-	.key_offset = offsetof(struct mlxsw_sp_fib_entry, key),
-	.head_offset = offsetof(struct mlxsw_sp_fib_entry, ht_node),
-	.key_len = sizeof(struct mlxsw_sp_fib_key),
-	.automatic_shrinking = true,
-};
-
-static int mlxsw_sp_fib_entry_insert(struct mlxsw_sp_fib *fib,
-				     struct mlxsw_sp_fib_entry *fib_entry)
-{
-	unsigned char prefix_len = fib_entry->key.prefix_len;
-	int err;
-
-	err = rhashtable_insert_fast(&fib->ht, &fib_entry->ht_node,
-				     mlxsw_sp_fib_ht_params);
-	if (err)
-		return err;
-	list_add_tail(&fib_entry->list, &fib->entry_list);
-	if (fib->prefix_ref_count[prefix_len]++ == 0)
-		mlxsw_sp_prefix_usage_set(&fib->prefix_usage, prefix_len);
-	return 0;
-}
-
-static void mlxsw_sp_fib_entry_remove(struct mlxsw_sp_fib *fib,
-				      struct mlxsw_sp_fib_entry *fib_entry)
-{
-	unsigned char prefix_len = fib_entry->key.prefix_len;
-
-	if (--fib->prefix_ref_count[prefix_len] == 0)
-		mlxsw_sp_prefix_usage_clear(&fib->prefix_usage, prefix_len);
-	list_del(&fib_entry->list);
-	rhashtable_remove_fast(&fib->ht, &fib_entry->ht_node,
-			       mlxsw_sp_fib_ht_params);
-}
-
-static struct mlxsw_sp_fib_entry *
-mlxsw_sp_fib_entry_create(struct mlxsw_sp_fib *fib, const void *addr,
-			  size_t addr_len, unsigned char prefix_len,
-			  struct net_device *dev)
-{
-	struct mlxsw_sp_fib_entry *fib_entry;
-
-	fib_entry = kzalloc(sizeof(*fib_entry), GFP_KERNEL);
-	if (!fib_entry)
-		return NULL;
-	fib_entry->key.dev = dev;
-	memcpy(fib_entry->key.addr, addr, addr_len);
-	fib_entry->key.prefix_len = prefix_len;
-	return fib_entry;
-}
-
-static void mlxsw_sp_fib_entry_destroy(struct mlxsw_sp_fib_entry *fib_entry)
-{
-	kfree(fib_entry);
-}
-
-static struct mlxsw_sp_fib_entry *
-mlxsw_sp_fib_entry_lookup(struct mlxsw_sp_fib *fib, const void *addr,
-			  size_t addr_len, unsigned char prefix_len,
-			  struct net_device *dev)
-{
-	struct mlxsw_sp_fib_key key;
-
-	memset(&key, 0, sizeof(key));
-	key.dev = dev;
-	memcpy(key.addr, addr, addr_len);
-	key.prefix_len = prefix_len;
-	return rhashtable_lookup_fast(&fib->ht, &key, mlxsw_sp_fib_ht_params);
-}
+static const struct rhashtable_params mlxsw_sp_fib_ht_params;
 
 static struct mlxsw_sp_fib *mlxsw_sp_fib_create(void)
 {
@@ -222,7 +166,7 @@ static struct mlxsw_sp_fib *mlxsw_sp_fib_create(void)
 	err = rhashtable_init(&fib->ht, &mlxsw_sp_fib_ht_params);
 	if (err)
 		goto err_rhashtable_init;
-	INIT_LIST_HEAD(&fib->entry_list);
+	INIT_LIST_HEAD(&fib->node_list);
 	return fib;
 
 err_rhashtable_init:
@@ -232,6 +176,7 @@ static struct mlxsw_sp_fib *mlxsw_sp_fib_create(void)
 
 static void mlxsw_sp_fib_destroy(struct mlxsw_sp_fib *fib)
 {
+	WARN_ON(!list_empty(&fib->node_list));
 	rhashtable_destroy(&fib->ht);
 	kfree(fib);
 }
@@ -1239,9 +1184,9 @@ static int mlxsw_sp_adj_index_mass_update(struct mlxsw_sp *mlxsw_sp,
 	int err;
 
 	list_for_each_entry(fib_entry, &nh_grp->fib_list, nexthop_group_node) {
-		if (vr == fib_entry->vr)
+		if (vr == fib_entry->fib_node->vr)
 			continue;
-		vr = fib_entry->vr;
+		vr = fib_entry->fib_node->vr;
 		err = mlxsw_sp_adj_index_mass_update_vr(mlxsw_sp, vr,
 							old_adj_index,
 							old_ecmp_size,
@@ -1727,6 +1672,9 @@ mlxsw_sp_fib_entry_should_offload(const struct mlxsw_sp_fib_entry *fib_entry)
 {
 	struct mlxsw_sp_nexthop_group *nh_group = fib_entry->nh_group;
 
+	if (fib_entry->params.tos)
+		return false;
+
 	switch (fib_entry->type) {
 	case MLXSW_SP_FIB_ENTRY_TYPE_REMOTE:
 		return !!nh_group->adj_index_valid;
@@ -1741,7 +1689,7 @@ static void mlxsw_sp_fib_entry_offload_set(struct mlxsw_sp_fib_entry *fib_entry)
 {
 	fib_entry->offloaded = true;
 
-	switch (fib_entry->vr->proto) {
+	switch (fib_entry->fib_node->vr->proto) {
 	case MLXSW_SP_L3_PROTO_IPV4:
 		fib_info_offload_inc(fib_entry->nh_group->key.fi);
 		break;
@@ -1753,7 +1701,7 @@ static void mlxsw_sp_fib_entry_offload_set(struct mlxsw_sp_fib_entry *fib_entry)
 static void
 mlxsw_sp_fib_entry_offload_unset(struct mlxsw_sp_fib_entry *fib_entry)
 {
-	switch (fib_entry->vr->proto) {
+	switch (fib_entry->fib_node->vr->proto) {
 	case MLXSW_SP_L3_PROTO_IPV4:
 		fib_info_offload_dec(fib_entry->nh_group->key.fi);
 		break;
@@ -1793,8 +1741,8 @@ static int mlxsw_sp_fib_entry_op4_remote(struct mlxsw_sp *mlxsw_sp,
 					 enum mlxsw_reg_ralue_op op)
 {
 	char ralue_pl[MLXSW_REG_RALUE_LEN];
-	u32 *p_dip = (u32 *) fib_entry->key.addr;
-	struct mlxsw_sp_vr *vr = fib_entry->vr;
+	u32 *p_dip = (u32 *) fib_entry->fib_node->key.addr;
+	struct mlxsw_sp_vr *vr = fib_entry->fib_node->vr;
 	enum mlxsw_reg_ralue_trap_action trap_action;
 	u16 trap_id = 0;
 	u32 adjacency_index = 0;
@@ -1815,7 +1763,8 @@ static int mlxsw_sp_fib_entry_op4_remote(struct mlxsw_sp *mlxsw_sp,
 
 	mlxsw_reg_ralue_pack4(ralue_pl,
 			      (enum mlxsw_reg_ralxx_protocol) vr->proto, op,
-			      vr->id, fib_entry->key.prefix_len, *p_dip);
+			      vr->id, fib_entry->fib_node->key.prefix_len,
+			      *p_dip);
 	mlxsw_reg_ralue_act_remote_pack(ralue_pl, trap_action, trap_id,
 					adjacency_index, ecmp_size);
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ralue), ralue_pl);
@@ -1828,8 +1777,8 @@ static int mlxsw_sp_fib_entry_op4_local(struct mlxsw_sp *mlxsw_sp,
 	struct mlxsw_sp_rif *r = fib_entry->nh_group->nh_rif;
 	enum mlxsw_reg_ralue_trap_action trap_action;
 	char ralue_pl[MLXSW_REG_RALUE_LEN];
-	u32 *p_dip = (u32 *) fib_entry->key.addr;
-	struct mlxsw_sp_vr *vr = fib_entry->vr;
+	u32 *p_dip = (u32 *) fib_entry->fib_node->key.addr;
+	struct mlxsw_sp_vr *vr = fib_entry->fib_node->vr;
 	u16 trap_id = 0;
 	u16 rif = 0;
 
@@ -1843,7 +1792,8 @@ static int mlxsw_sp_fib_entry_op4_local(struct mlxsw_sp *mlxsw_sp,
 
 	mlxsw_reg_ralue_pack4(ralue_pl,
 			      (enum mlxsw_reg_ralxx_protocol) vr->proto, op,
-			      vr->id, fib_entry->key.prefix_len, *p_dip);
+			      vr->id, fib_entry->fib_node->key.prefix_len,
+			      *p_dip);
 	mlxsw_reg_ralue_act_local_pack(ralue_pl, trap_action, trap_id, rif);
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ralue), ralue_pl);
 }
@@ -1853,12 +1803,13 @@ static int mlxsw_sp_fib_entry_op4_trap(struct mlxsw_sp *mlxsw_sp,
 				       enum mlxsw_reg_ralue_op op)
 {
 	char ralue_pl[MLXSW_REG_RALUE_LEN];
-	u32 *p_dip = (u32 *) fib_entry->key.addr;
-	struct mlxsw_sp_vr *vr = fib_entry->vr;
+	u32 *p_dip = (u32 *) fib_entry->fib_node->key.addr;
+	struct mlxsw_sp_vr *vr = fib_entry->fib_node->vr;
 
 	mlxsw_reg_ralue_pack4(ralue_pl,
 			      (enum mlxsw_reg_ralxx_protocol) vr->proto, op,
-			      vr->id, fib_entry->key.prefix_len, *p_dip);
+			      vr->id, fib_entry->fib_node->key.prefix_len,
+			      *p_dip);
 	mlxsw_reg_ralue_act_ip2me_pack(ralue_pl);
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ralue), ralue_pl);
 }
@@ -1884,7 +1835,7 @@ static int mlxsw_sp_fib_entry_op(struct mlxsw_sp *mlxsw_sp,
 {
 	int err = -EINVAL;
 
-	switch (fib_entry->vr->proto) {
+	switch (fib_entry->fib_node->vr->proto) {
 	case MLXSW_SP_L3_PROTO_IPV4:
 		err = mlxsw_sp_fib_entry_op4(mlxsw_sp, fib_entry, op);
 		break;
@@ -1930,130 +1881,376 @@ mlxsw_sp_fib4_entry_type_set(struct mlxsw_sp *mlxsw_sp,
 }
 
 static struct mlxsw_sp_fib_entry *
-mlxsw_sp_fib_entry_get(struct mlxsw_sp *mlxsw_sp,
-		       const struct fib_entry_notifier_info *fen_info)
+mlxsw_sp_fib4_entry_create(struct mlxsw_sp *mlxsw_sp,
+			   struct mlxsw_sp_fib_node *fib_node,
+			   const struct fib_entry_notifier_info *fen_info)
 {
 	struct mlxsw_sp_fib_entry *fib_entry;
-	struct fib_info *fi = fen_info->fi;
-	struct mlxsw_sp_vr *vr;
 	int err;
 
-	vr = mlxsw_sp_vr_get(mlxsw_sp, fen_info->dst_len, fen_info->tb_id,
-			     MLXSW_SP_L3_PROTO_IPV4);
-	if (IS_ERR(vr))
-		return ERR_CAST(vr);
-
-	fib_entry = mlxsw_sp_fib_entry_lookup(vr->fib, &fen_info->dst,
-					      sizeof(fen_info->dst),
-					      fen_info->dst_len, fi->fib_dev);
-	if (fib_entry) {
-		/* Already exists, just take a reference */
-		fib_entry->ref_count++;
-		return fib_entry;
-	}
-	fib_entry = mlxsw_sp_fib_entry_create(vr->fib, &fen_info->dst,
-					      sizeof(fen_info->dst),
-					      fen_info->dst_len, fi->fib_dev);
+	fib_entry = kzalloc(sizeof(*fib_entry), GFP_KERNEL);
 	if (!fib_entry) {
 		err = -ENOMEM;
-		goto err_fib_entry_create;
+		goto err_fib_entry_alloc;
 	}
-	fib_entry->vr = vr;
-	fib_entry->ref_count = 1;
 
 	err = mlxsw_sp_fib4_entry_type_set(mlxsw_sp, fen_info, fib_entry);
 	if (err)
 		goto err_fib4_entry_type_set;
 
-	err = mlxsw_sp_nexthop_group_get(mlxsw_sp, fib_entry, fi);
+	err = mlxsw_sp_nexthop_group_get(mlxsw_sp, fib_entry, fen_info->fi);
 	if (err)
 		goto err_nexthop_group_get;
 
+	fib_entry->params.prio = fen_info->fi->fib_priority;
+	fib_entry->params.tb_id = fen_info->tb_id;
+	fib_entry->params.type = fen_info->type;
+	fib_entry->params.tos = fen_info->tos;
+
+	fib_entry->fib_node = fib_node;
+
 	return fib_entry;
 
 err_nexthop_group_get:
 err_fib4_entry_type_set:
-	mlxsw_sp_fib_entry_destroy(fib_entry);
-err_fib_entry_create:
-	mlxsw_sp_vr_put(mlxsw_sp, vr);
-
+	kfree(fib_entry);
+err_fib_entry_alloc:
 	return ERR_PTR(err);
 }
 
+static void mlxsw_sp_fib4_entry_destroy(struct mlxsw_sp *mlxsw_sp,
+					struct mlxsw_sp_fib_entry *fib_entry)
+{
+	mlxsw_sp_nexthop_group_put(mlxsw_sp, fib_entry);
+	kfree(fib_entry);
+}
+
+static struct mlxsw_sp_fib_node *
+mlxsw_sp_fib4_node_get(struct mlxsw_sp *mlxsw_sp,
+		       const struct fib_entry_notifier_info *fen_info);
+
 static struct mlxsw_sp_fib_entry *
-mlxsw_sp_fib_entry_find(struct mlxsw_sp *mlxsw_sp,
-			const struct fib_entry_notifier_info *fen_info)
+mlxsw_sp_fib4_entry_lookup(struct mlxsw_sp *mlxsw_sp,
+			   const struct fib_entry_notifier_info *fen_info)
 {
-	struct mlxsw_sp_vr *vr;
+	struct mlxsw_sp_fib_entry *fib_entry;
+	struct mlxsw_sp_fib_node *fib_node;
 
-	vr = mlxsw_sp_vr_find(mlxsw_sp, fen_info->tb_id,
-			      MLXSW_SP_L3_PROTO_IPV4);
-	if (!vr)
+	fib_node = mlxsw_sp_fib4_node_get(mlxsw_sp, fen_info);
+	if (IS_ERR(fib_node))
+		return NULL;
+
+	list_for_each_entry(fib_entry, &fib_node->entry_list, list) {
+		if (fib_entry->params.tb_id == fen_info->tb_id &&
+		    fib_entry->params.tos == fen_info->tos &&
+		    fib_entry->params.type == fen_info->type &&
+		    fib_entry->nh_group->key.fi == fen_info->fi) {
+			return fib_entry;
+		}
+	}
+
+	return NULL;
+}
+
+static const struct rhashtable_params mlxsw_sp_fib_ht_params = {
+	.key_offset = offsetof(struct mlxsw_sp_fib_node, key),
+	.head_offset = offsetof(struct mlxsw_sp_fib_node, ht_node),
+	.key_len = sizeof(struct mlxsw_sp_fib_key),
+	.automatic_shrinking = true,
+};
+
+static int mlxsw_sp_fib_node_insert(struct mlxsw_sp_fib *fib,
+				    struct mlxsw_sp_fib_node *fib_node)
+{
+	return rhashtable_insert_fast(&fib->ht, &fib_node->ht_node,
+				      mlxsw_sp_fib_ht_params);
+}
+
+static void mlxsw_sp_fib_node_remove(struct mlxsw_sp_fib *fib,
+				     struct mlxsw_sp_fib_node *fib_node)
+{
+	rhashtable_remove_fast(&fib->ht, &fib_node->ht_node,
+			       mlxsw_sp_fib_ht_params);
+}
+
+static struct mlxsw_sp_fib_node *
+mlxsw_sp_fib_node_lookup(struct mlxsw_sp_fib *fib, const void *addr,
+			 size_t addr_len, unsigned char prefix_len)
+{
+	struct mlxsw_sp_fib_key key;
+
+	memset(&key, 0, sizeof(key));
+	memcpy(key.addr, addr, addr_len);
+	key.prefix_len = prefix_len;
+	return rhashtable_lookup_fast(&fib->ht, &key, mlxsw_sp_fib_ht_params);
+}
+
+static struct mlxsw_sp_fib_node *
+mlxsw_sp_fib_node_create(struct mlxsw_sp_vr *vr, const void *addr,
+			 size_t addr_len, unsigned char prefix_len)
+{
+	struct mlxsw_sp_fib_node *fib_node;
+
+	fib_node = kzalloc(sizeof(*fib_node), GFP_KERNEL);
+	if (!fib_node)
 		return NULL;
 
-	return mlxsw_sp_fib_entry_lookup(vr->fib, &fen_info->dst,
-					 sizeof(fen_info->dst),
-					 fen_info->dst_len,
-					 fen_info->fi->fib_dev);
+	INIT_LIST_HEAD(&fib_node->entry_list);
+	list_add(&fib_node->list, &vr->fib->node_list);
+	memcpy(fib_node->key.addr, addr, addr_len);
+	fib_node->key.prefix_len = prefix_len;
+	mlxsw_sp_fib_node_insert(vr->fib, fib_node);
+	fib_node->vr = vr;
+
+	return fib_node;
+}
+
+static void mlxsw_sp_fib_node_destroy(struct mlxsw_sp_fib_node *fib_node)
+{
+	mlxsw_sp_fib_node_remove(fib_node->vr->fib, fib_node);
+	list_del(&fib_node->list);
+	WARN_ON(!list_empty(&fib_node->entry_list));
+	kfree(fib_node);
+}
+
+static bool
+mlxsw_sp_fib_node_entry_is_first(const struct mlxsw_sp_fib_node *fib_node,
+				 const struct mlxsw_sp_fib_entry *fib_entry)
+{
+	return list_first_entry(&fib_node->entry_list,
+				struct mlxsw_sp_fib_entry, list) == fib_entry;
+}
+
+static void mlxsw_sp_fib_node_prefix_inc(struct mlxsw_sp_fib_node *fib_node)
+{
+	unsigned char prefix_len = fib_node->key.prefix_len;
+	struct mlxsw_sp_fib *fib = fib_node->vr->fib;
+
+	if (fib->prefix_ref_count[prefix_len]++ == 0)
+		mlxsw_sp_prefix_usage_set(&fib->prefix_usage, prefix_len);
+}
+
+static void mlxsw_sp_fib_node_prefix_dec(struct mlxsw_sp_fib_node *fib_node)
+{
+	unsigned char prefix_len = fib_node->key.prefix_len;
+	struct mlxsw_sp_fib *fib = fib_node->vr->fib;
+
+	if (--fib->prefix_ref_count[prefix_len] == 0)
+		mlxsw_sp_prefix_usage_clear(&fib->prefix_usage, prefix_len);
 }
 
-static void mlxsw_sp_fib_entry_put(struct mlxsw_sp *mlxsw_sp,
-				   struct mlxsw_sp_fib_entry *fib_entry)
+static struct mlxsw_sp_fib_node *
+mlxsw_sp_fib4_node_get(struct mlxsw_sp *mlxsw_sp,
+		       const struct fib_entry_notifier_info *fen_info)
 {
-	struct mlxsw_sp_vr *vr = fib_entry->vr;
+	struct mlxsw_sp_fib_node *fib_node;
+	struct mlxsw_sp_vr *vr;
+	int err;
+
+	vr = mlxsw_sp_vr_get(mlxsw_sp, fen_info->dst_len, fen_info->tb_id,
+			     MLXSW_SP_L3_PROTO_IPV4);
+	if (IS_ERR(vr))
+		return ERR_CAST(vr);
+
+	fib_node = mlxsw_sp_fib_node_lookup(vr->fib, &fen_info->dst,
+					    sizeof(fen_info->dst),
+					    fen_info->dst_len);
+	if (fib_node)
+		return fib_node;
 
-	if (--fib_entry->ref_count == 0) {
-		mlxsw_sp_nexthop_group_put(mlxsw_sp, fib_entry);
-		mlxsw_sp_fib_entry_destroy(fib_entry);
+	fib_node = mlxsw_sp_fib_node_create(vr, &fen_info->dst,
+					    sizeof(fen_info->dst),
+					    fen_info->dst_len);
+	if (!fib_node) {
+		err = -ENOMEM;
+		goto err_fib_node_create;
 	}
+
+	return fib_node;
+
+err_fib_node_create:
 	mlxsw_sp_vr_put(mlxsw_sp, vr);
+	return ERR_PTR(err);
 }
 
-static void mlxsw_sp_fib_entry_put_all(struct mlxsw_sp *mlxsw_sp,
-				       struct mlxsw_sp_fib_entry *fib_entry)
+static void mlxsw_sp_fib4_node_put(struct mlxsw_sp *mlxsw_sp,
+				   struct mlxsw_sp_fib_node *fib_node)
 {
-	unsigned int last_ref_count;
+	struct mlxsw_sp_vr *vr = fib_node->vr;
 
-	do {
-		last_ref_count = fib_entry->ref_count;
-		mlxsw_sp_fib_entry_put(mlxsw_sp, fib_entry);
-	} while (last_ref_count != 1);
+	if (!list_empty(&fib_node->entry_list))
+		return;
+	mlxsw_sp_fib_node_destroy(fib_node);
+	mlxsw_sp_vr_put(mlxsw_sp, vr);
 }
 
-static int mlxsw_sp_router_fib4_add(struct mlxsw_sp *mlxsw_sp,
-				    struct fib_entry_notifier_info *fen_info)
+static struct mlxsw_sp_fib_entry *
+mlxsw_sp_fib4_node_entry_find(const struct mlxsw_sp_fib_node *fib_node,
+			      const struct mlxsw_sp_fib_entry_params *params)
 {
 	struct mlxsw_sp_fib_entry *fib_entry;
-	struct mlxsw_sp_vr *vr;
+
+	list_for_each_entry(fib_entry, &fib_node->entry_list, list) {
+		if (fib_entry->params.tb_id > params->tb_id)
+			continue;
+		if (fib_entry->params.tb_id != params->tb_id)
+			break;
+		if (fib_entry->params.tos > params->tos)
+			continue;
+		if (fib_entry->params.prio >= params->prio ||
+		    fib_entry->params.tos < params->tos)
+			return fib_entry;
+	}
+
+	return NULL;
+}
+
+static int
+mlxsw_sp_fib4_node_list_insert(struct mlxsw_sp_fib_node *fib_node,
+			       struct mlxsw_sp_fib_entry *new_entry)
+{
+	struct mlxsw_sp_fib_entry *fib_entry;
+
+	fib_entry = mlxsw_sp_fib4_node_entry_find(fib_node, &new_entry->params);
+
+	if (fib_entry) {
+		list_add_tail(&new_entry->list, &fib_entry->list);
+	} else {
+		struct mlxsw_sp_fib_entry *last;
+
+		list_for_each_entry(last, &fib_node->entry_list, list) {
+			if (new_entry->params.tb_id > last->params.tb_id)
+				break;
+			fib_entry = last;
+		}
+
+		if (fib_entry)
+			list_add(&new_entry->list, &fib_entry->list);
+		else
+			list_add(&new_entry->list, &fib_node->entry_list);
+	}
+
+	return 0;
+}
+
+static void
+mlxsw_sp_fib4_node_list_remove(struct mlxsw_sp_fib_entry *fib_entry)
+{
+	list_del(&fib_entry->list);
+}
+
+static int
+mlxsw_sp_fib4_node_entry_add(struct mlxsw_sp *mlxsw_sp,
+			     const struct mlxsw_sp_fib_node *fib_node,
+			     struct mlxsw_sp_fib_entry *fib_entry)
+{
+	if (!mlxsw_sp_fib_node_entry_is_first(fib_node, fib_entry))
+		return 0;
+
+	/* To prevent packet loss, overwrite the previously offloaded
+	 * entry.
+	 */
+	if (!list_is_singular(&fib_node->entry_list)) {
+		enum mlxsw_reg_ralue_op op = MLXSW_REG_RALUE_OP_WRITE_DELETE;
+		struct mlxsw_sp_fib_entry *n = list_next_entry(fib_entry, list);
+
+		mlxsw_sp_fib_entry_offload_refresh(n, op, 0);
+	}
+
+	return mlxsw_sp_fib_entry_update(mlxsw_sp, fib_entry);
+}
+
+static void
+mlxsw_sp_fib4_node_entry_del(struct mlxsw_sp *mlxsw_sp,
+			     const struct mlxsw_sp_fib_node *fib_node,
+			     struct mlxsw_sp_fib_entry *fib_entry)
+{
+	if (!mlxsw_sp_fib_node_entry_is_first(fib_node, fib_entry))
+		return;
+
+	/* Promote the next entry by overwriting the deleted entry */
+	if (!list_is_singular(&fib_node->entry_list)) {
+		struct mlxsw_sp_fib_entry *n = list_next_entry(fib_entry, list);
+		enum mlxsw_reg_ralue_op op = MLXSW_REG_RALUE_OP_WRITE_DELETE;
+
+		mlxsw_sp_fib_entry_update(mlxsw_sp, n);
+		mlxsw_sp_fib_entry_offload_refresh(fib_entry, op, 0);
+		return;
+	}
+
+	mlxsw_sp_fib_entry_del(mlxsw_sp, fib_entry);
+}
+
+static int mlxsw_sp_fib4_node_entry_link(struct mlxsw_sp *mlxsw_sp,
+					 struct mlxsw_sp_fib_entry *fib_entry)
+{
+	struct mlxsw_sp_fib_node *fib_node = fib_entry->fib_node;
+	int err;
+
+	err = mlxsw_sp_fib4_node_list_insert(fib_node, fib_entry);
+	if (err)
+		return err;
+
+	err = mlxsw_sp_fib4_node_entry_add(mlxsw_sp, fib_node, fib_entry);
+	if (err)
+		goto err_fib4_node_entry_add;
+
+	mlxsw_sp_fib_node_prefix_inc(fib_node);
+
+	return 0;
+
+err_fib4_node_entry_add:
+	mlxsw_sp_fib4_node_list_remove(fib_entry);
+	return err;
+}
+
+static void
+mlxsw_sp_fib4_node_entry_unlink(struct mlxsw_sp *mlxsw_sp,
+				struct mlxsw_sp_fib_entry *fib_entry)
+{
+	struct mlxsw_sp_fib_node *fib_node = fib_entry->fib_node;
+
+	mlxsw_sp_fib_node_prefix_dec(fib_node);
+	mlxsw_sp_fib4_node_entry_del(mlxsw_sp, fib_node, fib_entry);
+	mlxsw_sp_fib4_node_list_remove(fib_entry);
+}
+
+static int
+mlxsw_sp_router_fib4_add(struct mlxsw_sp *mlxsw_sp,
+			 const struct fib_entry_notifier_info *fen_info)
+{
+	struct mlxsw_sp_fib_entry *fib_entry;
+	struct mlxsw_sp_fib_node *fib_node;
 	int err;
 
 	if (mlxsw_sp->router.aborted)
 		return 0;
 
-	fib_entry = mlxsw_sp_fib_entry_get(mlxsw_sp, fen_info);
-	if (IS_ERR(fib_entry)) {
-		dev_warn(mlxsw_sp->bus_info->dev, "Failed to get FIB4 entry being added.\n");
-		return PTR_ERR(fib_entry);
+	fib_node = mlxsw_sp_fib4_node_get(mlxsw_sp, fen_info);
+	if (IS_ERR(fib_node)) {
+		dev_warn(mlxsw_sp->bus_info->dev, "Failed to get FIB node\n");
+		return PTR_ERR(fib_node);
 	}
 
-	if (fib_entry->ref_count != 1)
-		return 0;
+	fib_entry = mlxsw_sp_fib4_entry_create(mlxsw_sp, fib_node, fen_info);
+	if (IS_ERR(fib_entry)) {
+		dev_warn(mlxsw_sp->bus_info->dev, "Failed to create FIB entry\n");
+		err = PTR_ERR(fib_entry);
+		goto err_fib4_entry_create;
+	}
 
-	vr = fib_entry->vr;
-	err = mlxsw_sp_fib_entry_insert(vr->fib, fib_entry);
+	err = mlxsw_sp_fib4_node_entry_link(mlxsw_sp, fib_entry);
 	if (err) {
-		dev_warn(mlxsw_sp->bus_info->dev, "Failed to insert FIB4 entry being added.\n");
-		goto err_fib_entry_insert;
+		dev_warn(mlxsw_sp->bus_info->dev, "Failed to link FIB entry to node\n");
+		goto err_fib4_node_entry_link;
 	}
-	err = mlxsw_sp_fib_entry_update(mlxsw_sp, fib_entry);
-	if (err)
-		goto err_fib_entry_add;
+
 	return 0;
 
-err_fib_entry_add:
-	mlxsw_sp_fib_entry_remove(vr->fib, fib_entry);
-err_fib_entry_insert:
-	mlxsw_sp_fib_entry_put(mlxsw_sp, fib_entry);
+err_fib4_node_entry_link:
+	mlxsw_sp_fib4_entry_destroy(mlxsw_sp, fib_entry);
+err_fib4_entry_create:
+	mlxsw_sp_fib4_node_put(mlxsw_sp, fib_node);
 	return err;
 }
 
@@ -2061,20 +2258,19 @@ static void mlxsw_sp_router_fib4_del(struct mlxsw_sp *mlxsw_sp,
 				     struct fib_entry_notifier_info *fen_info)
 {
 	struct mlxsw_sp_fib_entry *fib_entry;
+	struct mlxsw_sp_fib_node *fib_node;
 
 	if (mlxsw_sp->router.aborted)
 		return;
 
-	fib_entry = mlxsw_sp_fib_entry_find(mlxsw_sp, fen_info);
-	if (!fib_entry)
+	fib_entry = mlxsw_sp_fib4_entry_lookup(mlxsw_sp, fen_info);
+	if (WARN_ON(!fib_entry))
 		return;
+	fib_node = fib_entry->fib_node;
 
-	if (fib_entry->ref_count == 1) {
-		mlxsw_sp_fib_entry_del(mlxsw_sp, fib_entry);
-		mlxsw_sp_fib_entry_remove(fib_entry->vr->fib, fib_entry);
-	}
-
-	mlxsw_sp_fib_entry_put(mlxsw_sp, fib_entry);
+	mlxsw_sp_fib4_node_entry_unlink(mlxsw_sp, fib_entry);
+	mlxsw_sp_fib4_entry_destroy(mlxsw_sp, fib_entry);
+	mlxsw_sp_fib4_node_put(mlxsw_sp, fib_node);
 }
 
 static int mlxsw_sp_router_set_abort_trap(struct mlxsw_sp *mlxsw_sp)
@@ -2108,10 +2304,42 @@ static int mlxsw_sp_router_set_abort_trap(struct mlxsw_sp *mlxsw_sp)
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(ralue), ralue_pl);
 }
 
+static void mlxsw_sp_fib4_node_flush(struct mlxsw_sp *mlxsw_sp,
+				     struct mlxsw_sp_fib_node *fib_node)
+{
+	struct mlxsw_sp_fib_entry *fib_entry, *tmp;
+
+	list_for_each_entry_safe(fib_entry, tmp, &fib_node->entry_list, list) {
+		bool do_break = &tmp->list == &fib_node->entry_list;
+
+		mlxsw_sp_fib4_node_entry_unlink(mlxsw_sp, fib_entry);
+		mlxsw_sp_fib4_entry_destroy(mlxsw_sp, fib_entry);
+		mlxsw_sp_fib4_node_put(mlxsw_sp, fib_node);
+		/* Break when entry list is empty and node was freed.
+		 * Otherwise, we'll access freed memory in the next
+		 * iteration.
+		 */
+		if (do_break)
+			break;
+	}
+}
+
+static void mlxsw_sp_fib_node_flush(struct mlxsw_sp *mlxsw_sp,
+				    struct mlxsw_sp_fib_node *fib_node)
+{
+	switch (fib_node->vr->proto) {
+	case MLXSW_SP_L3_PROTO_IPV4:
+		mlxsw_sp_fib4_node_flush(mlxsw_sp, fib_node);
+		break;
+	case MLXSW_SP_L3_PROTO_IPV6:
+		WARN_ON_ONCE(1);
+		break;
+	}
+}
+
 static void mlxsw_sp_router_fib_flush(struct mlxsw_sp *mlxsw_sp)
 {
-	struct mlxsw_sp_fib_entry *fib_entry;
-	struct mlxsw_sp_fib_entry *tmp;
+	struct mlxsw_sp_fib_node *fib_node, *tmp;
 	struct mlxsw_sp_vr *vr;
 	int i;
 
@@ -2121,14 +2349,11 @@ static void mlxsw_sp_router_fib_flush(struct mlxsw_sp *mlxsw_sp)
 		if (!vr->used)
 			continue;
 
-		list_for_each_entry_safe(fib_entry, tmp,
-					 &vr->fib->entry_list, list) {
-			bool do_break = &tmp->list == &vr->fib->entry_list;
+		list_for_each_entry_safe(fib_node, tmp, &vr->fib->node_list,
+					 list) {
+			bool do_break = &tmp->list == &vr->fib->node_list;
 
-			mlxsw_sp_fib_entry_del(mlxsw_sp, fib_entry);
-			mlxsw_sp_fib_entry_remove(fib_entry->vr->fib,
-						  fib_entry);
-			mlxsw_sp_fib_entry_put_all(mlxsw_sp, fib_entry);
+			mlxsw_sp_fib_node_flush(mlxsw_sp, fib_node);
 			if (do_break)
 				break;
 		}
-- 
2.7.4
