From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 1/6] mlxsw: spectrum_router: Fix failure caused by double fib removal from HW
Date: Thu,  1 Sep 2016 10:37:40 +0200
Message-ID: <1472719065-3247-2-git-send-email-jiri@resnulli.us>
References: <1472719065-3247-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33441 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752134AbcIAIhv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 04:37:51 -0400
Received: by mail-wm0-f68.google.com with SMTP id w207so7295234wmw.0
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 01:37:50 -0700 (PDT)
In-Reply-To: <1472719065-3247-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

In mlxsw we squash tables 254 and 255 together into HW. Kernel adds/dels
/32 ip to/from both 254 and 255. On del path, that causes the same
prefix being removed twice. Fix this by introducing reference counting
for private mlxsw fib entries. That required a bit of code reshuffle.
Also put dev into fib entry key so the same prefix could be represented
once per every router interface.

Fixes: 61c503f976b5 ("mlxsw: spectrum_router: Implement fib4 add/del switchdev obj ops")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 126 +++++++++++++++------
 1 file changed, 92 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 917ddd1..ed61814 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -107,6 +107,7 @@ mlxsw_sp_prefix_usage_clear(struct mlxsw_sp_prefix_usage *prefix_usage,
 }
 
 struct mlxsw_sp_fib_key {
+	struct net_device *dev;
 	unsigned char addr[sizeof(struct in6_addr)];
 	unsigned char prefix_len;
 };
@@ -123,6 +124,7 @@ struct mlxsw_sp_fib_entry {
 	struct rhash_head ht_node;
 	struct mlxsw_sp_fib_key key;
 	enum mlxsw_sp_fib_entry_type type;
+	unsigned int ref_count;
 	u8 added:1;
 	u16 rif; /* used for action local */
 	struct mlxsw_sp_vr *vr;
@@ -171,13 +173,15 @@ static void mlxsw_sp_fib_entry_remove(struct mlxsw_sp_fib *fib,
 
 static struct mlxsw_sp_fib_entry *
 mlxsw_sp_fib_entry_create(struct mlxsw_sp_fib *fib, const void *addr,
-			  size_t addr_len, unsigned char prefix_len)
+			  size_t addr_len, unsigned char prefix_len,
+			  struct net_device *dev)
 {
 	struct mlxsw_sp_fib_entry *fib_entry;
 
 	fib_entry = kzalloc(sizeof(*fib_entry), GFP_KERNEL);
 	if (!fib_entry)
 		return NULL;
+	fib_entry->key.dev = dev;
 	memcpy(fib_entry->key.addr, addr, addr_len);
 	fib_entry->key.prefix_len = prefix_len;
 	return fib_entry;
@@ -190,10 +194,13 @@ static void mlxsw_sp_fib_entry_destroy(struct mlxsw_sp_fib_entry *fib_entry)
 
 static struct mlxsw_sp_fib_entry *
 mlxsw_sp_fib_entry_lookup(struct mlxsw_sp_fib *fib, const void *addr,
-			  size_t addr_len, unsigned char prefix_len)
+			  size_t addr_len, unsigned char prefix_len,
+			  struct net_device *dev)
 {
-	struct mlxsw_sp_fib_key key = {{ 0 } };
+	struct mlxsw_sp_fib_key key;
 
+	memset(&key, 0, sizeof(key));
+	key.dev = dev;
 	memcpy(key.addr, addr, addr_len);
 	key.prefix_len = prefix_len;
 	return rhashtable_lookup_fast(&fib->ht, &key, mlxsw_sp_fib_ht_params);
@@ -1695,34 +1702,93 @@ mlxsw_sp_router_fib4_entry_fini(struct mlxsw_sp *mlxsw_sp,
 	mlxsw_sp_nexthop_group_put(mlxsw_sp, fib_entry);
 }
 
-static int
-mlxsw_sp_router_fib4_add_prepare(struct mlxsw_sp_port *mlxsw_sp_port,
-				 const struct switchdev_obj_ipv4_fib *fib4,
-				 struct switchdev_trans *trans)
+static struct mlxsw_sp_fib_entry *
+mlxsw_sp_fib_entry_get(struct mlxsw_sp *mlxsw_sp,
+		       const struct switchdev_obj_ipv4_fib *fib4)
 {
-	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
-	struct mlxsw_sp_router_fib4_add_info *info;
 	struct mlxsw_sp_fib_entry *fib_entry;
+	struct fib_info *fi = fib4->fi;
 	struct mlxsw_sp_vr *vr;
 	int err;
 
 	vr = mlxsw_sp_vr_get(mlxsw_sp, fib4->dst_len, fib4->tb_id,
 			     MLXSW_SP_L3_PROTO_IPV4);
 	if (IS_ERR(vr))
-		return PTR_ERR(vr);
+		return ERR_CAST(vr);
 
+	fib_entry = mlxsw_sp_fib_entry_lookup(vr->fib, &fib4->dst,
+					      sizeof(fib4->dst),
+					      fib4->dst_len, fi->fib_dev);
+	if (fib_entry) {
+		/* Already exists, just take a reference */
+		fib_entry->ref_count++;
+		return fib_entry;
+	}
 	fib_entry = mlxsw_sp_fib_entry_create(vr->fib, &fib4->dst,
-					      sizeof(fib4->dst), fib4->dst_len);
+					      sizeof(fib4->dst),
+					      fib4->dst_len, fi->fib_dev);
 	if (!fib_entry) {
 		err = -ENOMEM;
 		goto err_fib_entry_create;
 	}
 	fib_entry->vr = vr;
+	fib_entry->ref_count = 1;
 
 	err = mlxsw_sp_router_fib4_entry_init(mlxsw_sp, fib4, fib_entry);
 	if (err)
 		goto err_fib4_entry_init;
 
+	return fib_entry;
+
+err_fib4_entry_init:
+	mlxsw_sp_fib_entry_destroy(fib_entry);
+err_fib_entry_create:
+	mlxsw_sp_vr_put(mlxsw_sp, vr);
+
+	return ERR_PTR(err);
+}
+
+static struct mlxsw_sp_fib_entry *
+mlxsw_sp_fib_entry_find(struct mlxsw_sp *mlxsw_sp,
+			const struct switchdev_obj_ipv4_fib *fib4)
+{
+	struct mlxsw_sp_vr *vr;
+
+	vr = mlxsw_sp_vr_find(mlxsw_sp, fib4->tb_id, MLXSW_SP_L3_PROTO_IPV4);
+	if (!vr)
+		return NULL;
+
+	return mlxsw_sp_fib_entry_lookup(vr->fib, &fib4->dst,
+					 sizeof(fib4->dst), fib4->dst_len,
+					 fib4->fi->fib_dev);
+}
+
+void mlxsw_sp_fib_entry_put(struct mlxsw_sp *mlxsw_sp,
+			    struct mlxsw_sp_fib_entry *fib_entry)
+{
+	struct mlxsw_sp_vr *vr = fib_entry->vr;
+
+	if (--fib_entry->ref_count == 0) {
+		mlxsw_sp_router_fib4_entry_fini(mlxsw_sp, fib_entry);
+		mlxsw_sp_fib_entry_destroy(fib_entry);
+	}
+	mlxsw_sp_vr_put(mlxsw_sp, vr);
+}
+
+static int
+mlxsw_sp_router_fib4_add_prepare(struct mlxsw_sp_port *mlxsw_sp_port,
+				 const struct switchdev_obj_ipv4_fib *fib4,
+				 struct switchdev_trans *trans)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	struct mlxsw_sp_router_fib4_add_info *info;
+	struct mlxsw_sp_fib_entry *fib_entry;
+	int err;
+
+	fib_entry = mlxsw_sp_fib_entry_get(mlxsw_sp, fib4);
+	if (IS_ERR(fib_entry))
+		return PTR_ERR(fib_entry);
+
 	info = kmalloc(sizeof(*info), GFP_KERNEL);
 	if (!info) {
 		err = -ENOMEM;
@@ -1736,11 +1802,7 @@ mlxsw_sp_router_fib4_add_prepare(struct mlxsw_sp_port *mlxsw_sp_port,
 	return 0;
 
 err_alloc_info:
-	mlxsw_sp_router_fib4_entry_fini(mlxsw_sp, fib_entry);
-err_fib4_entry_init:
-	mlxsw_sp_fib_entry_destroy(fib_entry);
-err_fib_entry_create:
-	mlxsw_sp_vr_put(mlxsw_sp, vr);
+	mlxsw_sp_fib_entry_put(mlxsw_sp, fib_entry);
 	return err;
 }
 
@@ -1759,11 +1821,14 @@ mlxsw_sp_router_fib4_add_commit(struct mlxsw_sp_port *mlxsw_sp_port,
 	fib_entry = info->fib_entry;
 	kfree(info);
 
+	if (fib_entry->ref_count != 1)
+		return 0;
+
 	vr = fib_entry->vr;
-	err = mlxsw_sp_fib_entry_insert(fib_entry->vr->fib, fib_entry);
+	err = mlxsw_sp_fib_entry_insert(vr->fib, fib_entry);
 	if (err)
 		goto err_fib_entry_insert;
-	err = mlxsw_sp_fib_entry_update(mlxsw_sp, fib_entry);
+	err = mlxsw_sp_fib_entry_update(mlxsw_sp_port->mlxsw_sp, fib_entry);
 	if (err)
 		goto err_fib_entry_add;
 	return 0;
@@ -1771,9 +1836,7 @@ mlxsw_sp_router_fib4_add_commit(struct mlxsw_sp_port *mlxsw_sp_port,
 err_fib_entry_add:
 	mlxsw_sp_fib_entry_remove(vr->fib, fib_entry);
 err_fib_entry_insert:
-	mlxsw_sp_router_fib4_entry_fini(mlxsw_sp, fib_entry);
-	mlxsw_sp_fib_entry_destroy(fib_entry);
-	mlxsw_sp_vr_put(mlxsw_sp, vr);
+	mlxsw_sp_fib_entry_put(mlxsw_sp, fib_entry);
 	return err;
 }
 
@@ -1793,23 +1856,18 @@ int mlxsw_sp_router_fib4_del(struct mlxsw_sp_port *mlxsw_sp_port,
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
 	struct mlxsw_sp_fib_entry *fib_entry;
-	struct mlxsw_sp_vr *vr;
 
-	vr = mlxsw_sp_vr_find(mlxsw_sp, fib4->tb_id, MLXSW_SP_L3_PROTO_IPV4);
-	if (!vr) {
-		dev_warn(mlxsw_sp->bus_info->dev, "Failed to find virtual router for FIB4 entry being removed.\n");
-		return -ENOENT;
-	}
-	fib_entry = mlxsw_sp_fib_entry_lookup(vr->fib, &fib4->dst,
-					      sizeof(fib4->dst), fib4->dst_len);
+	fib_entry = mlxsw_sp_fib_entry_find(mlxsw_sp, fib4);
 	if (!fib_entry) {
 		dev_warn(mlxsw_sp->bus_info->dev, "Failed to find FIB4 entry being removed.\n");
 		return -ENOENT;
 	}
-	mlxsw_sp_fib_entry_del(mlxsw_sp_port->mlxsw_sp, fib_entry);
-	mlxsw_sp_fib_entry_remove(vr->fib, fib_entry);
-	mlxsw_sp_router_fib4_entry_fini(mlxsw_sp, fib_entry);
-	mlxsw_sp_fib_entry_destroy(fib_entry);
-	mlxsw_sp_vr_put(mlxsw_sp, vr);
+
+	if (fib_entry->ref_count == 1) {
+		mlxsw_sp_fib_entry_del(mlxsw_sp, fib_entry);
+		mlxsw_sp_fib_entry_remove(fib_entry->vr->fib, fib_entry);
+	}
+
+	mlxsw_sp_fib_entry_put(mlxsw_sp, fib_entry);
 	return 0;
 }
-- 
2.5.5
