From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/8] mlxsw: spectrum: Better represent KVDL partitions
Date: Sun, 22 Oct 2017 23:11:44 +0200
Message-ID: <20171022211150.2567-3-jiri@resnulli.us>
References: <20171022211150.2567-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:47872 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932108AbdJVVLy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Oct 2017 17:11:54 -0400
Received: by mail-wm0-f65.google.com with SMTP id t69so6097290wmt.2
        for <netdev@vger.kernel.org>; Sun, 22 Oct 2017 14:11:54 -0700 (PDT)
In-Reply-To: <20171022211150.2567-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The KVD linear (KVDL) allocator currently consists of a very large
bitmap that reflects the KVDL's usage. The boundaries of each partition
as well as their allocation size are represented using defines.

This representation requires us to patch all the functions that act on a
partition whenever the partitioning scheme is changed. In addition, it
does not enable the dynamic configuration of the KVDL using the
up-coming resource manager.

Add objects to represent these partitions as well as the accompanying
code that acts on them to perform allocations and de-allocations.

In the following patches, this will allow us to easily add another
partition as well as new operations to act on these partitions.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  11 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   7 +-
 .../net/ethernet/mellanox/mlxsw/spectrum_kvdl.c    | 257 ++++++++++++++++++---
 3 files changed, 238 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 4d73a6f..1bc3fc3 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -3726,10 +3726,16 @@ static int mlxsw_sp_init(struct mlxsw_core *mlxsw_core,
 		return err;
 	}
 
+	err = mlxsw_sp_kvdl_init(mlxsw_sp);
+	if (err) {
+		dev_err(mlxsw_sp->bus_info->dev, "Failed to initialize KVDL\n");
+		return err;
+	}
+
 	err = mlxsw_sp_fids_init(mlxsw_sp);
 	if (err) {
 		dev_err(mlxsw_sp->bus_info->dev, "Failed to initialize FIDs\n");
-		return err;
+		goto err_fids_init;
 	}
 
 	err = mlxsw_sp_traps_init(mlxsw_sp);
@@ -3834,6 +3840,8 @@ static int mlxsw_sp_init(struct mlxsw_core *mlxsw_core,
 	mlxsw_sp_traps_fini(mlxsw_sp);
 err_traps_init:
 	mlxsw_sp_fids_fini(mlxsw_sp);
+err_fids_init:
+	mlxsw_sp_kvdl_fini(mlxsw_sp);
 	return err;
 }
 
@@ -3854,6 +3862,7 @@ static void mlxsw_sp_fini(struct mlxsw_core *mlxsw_core)
 	mlxsw_sp_buffers_fini(mlxsw_sp);
 	mlxsw_sp_traps_fini(mlxsw_sp);
 	mlxsw_sp_fids_fini(mlxsw_sp);
+	mlxsw_sp_kvdl_fini(mlxsw_sp);
 }
 
 static const struct mlxsw_config_profile mlxsw_sp_config_profile = {
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 2a2472a..035c753 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -143,6 +143,7 @@ struct mlxsw_sp_mr;
 struct mlxsw_sp_acl;
 struct mlxsw_sp_counter_pool;
 struct mlxsw_sp_fid_core;
+struct mlxsw_sp_kvdl;
 
 struct mlxsw_sp {
 	struct mlxsw_sp_port **ports;
@@ -158,9 +159,7 @@ struct mlxsw_sp {
 	struct mlxsw_afa *afa;
 	struct mlxsw_sp_acl *acl;
 	struct mlxsw_sp_fid_core *fid_core;
-	struct {
-		DECLARE_BITMAP(usage, MLXSW_SP_KVD_LINEAR_SIZE);
-	} kvdl;
+	struct mlxsw_sp_kvdl *kvdl;
 	struct notifier_block netdevice_nb;
 
 	struct mlxsw_sp_counter_pool *counter_pool;
@@ -411,6 +410,8 @@ mlxsw_sp_port_vlan_router_leave(struct mlxsw_sp_port_vlan *mlxsw_sp_port_vlan);
 void mlxsw_sp_rif_destroy(struct mlxsw_sp_rif *rif);
 
 /* spectrum_kvdl.c */
+int mlxsw_sp_kvdl_init(struct mlxsw_sp *mlxsw_sp);
+void mlxsw_sp_kvdl_fini(struct mlxsw_sp *mlxsw_sp);
 int mlxsw_sp_kvdl_alloc(struct mlxsw_sp *mlxsw_sp, unsigned int entry_count,
 			u32 *p_entry_index);
 void mlxsw_sp_kvdl_free(struct mlxsw_sp *mlxsw_sp, int entry_index);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_kvdl.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_kvdl.c
index 26c26cd..5125375 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_kvdl.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_kvdl.c
@@ -39,55 +39,246 @@
 
 #define MLXSW_SP_KVDL_SINGLE_BASE 0
 #define MLXSW_SP_KVDL_SINGLE_SIZE 16384
+#define MLXSW_SP_KVDL_SINGLE_END \
+	(MLXSW_SP_KVDL_SINGLE_SIZE + MLXSW_SP_KVDL_SINGLE_BASE - 1)
 #define MLXSW_SP_KVDL_CHUNKS_BASE \
 	(MLXSW_SP_KVDL_SINGLE_BASE + MLXSW_SP_KVDL_SINGLE_SIZE)
 #define MLXSW_SP_KVDL_CHUNKS_SIZE \
 	(MLXSW_SP_KVD_LINEAR_SIZE - MLXSW_SP_KVDL_CHUNKS_BASE)
+#define MLXSW_SP_KVDL_CHUNKS_END \
+	(MLXSW_SP_KVDL_CHUNKS_SIZE + MLXSW_SP_KVDL_CHUNKS_BASE - 1)
 #define MLXSW_SP_CHUNK_MAX 32
 
+struct mlxsw_sp_kvdl_part_info {
+	unsigned int part_index;
+	unsigned int start_index;
+	unsigned int end_index;
+	unsigned int alloc_size;
+};
+
+struct mlxsw_sp_kvdl_part {
+	struct list_head list;
+	const struct mlxsw_sp_kvdl_part_info *info;
+	unsigned long usage[0];	/* Entries */
+};
+
+struct mlxsw_sp_kvdl {
+	struct list_head parts_list;
+};
+
+static struct mlxsw_sp_kvdl_part *
+mlxsw_sp_kvdl_alloc_size_part(struct mlxsw_sp_kvdl *kvdl,
+			      unsigned int alloc_size)
+{
+	struct mlxsw_sp_kvdl_part *part, *min_part = NULL;
+
+	list_for_each_entry(part, &kvdl->parts_list, list) {
+		if (alloc_size <= part->info->alloc_size &&
+		    (!min_part ||
+		     part->info->alloc_size <= min_part->info->alloc_size))
+			min_part = part;
+	}
+
+	return min_part ?: ERR_PTR(-ENOBUFS);
+}
+
+static struct mlxsw_sp_kvdl_part *
+mlxsw_sp_kvdl_index_part(struct mlxsw_sp_kvdl *kvdl, u32 kvdl_index)
+{
+	struct mlxsw_sp_kvdl_part *part;
+
+	list_for_each_entry(part, &kvdl->parts_list, list) {
+		if (kvdl_index >= part->info->start_index &&
+		    kvdl_index <= part->info->end_index)
+			return part;
+	}
+
+	return ERR_PTR(-EINVAL);
+}
+
+static u32
+mlxsw_sp_entry_index_kvdl_index(const struct mlxsw_sp_kvdl_part_info *info,
+				unsigned int entry_index)
+{
+	return info->start_index + entry_index * info->alloc_size;
+}
+
+static unsigned int
+mlxsw_sp_kvdl_index_entry_index(const struct mlxsw_sp_kvdl_part_info *info,
+				u32 kvdl_index)
+{
+	return (kvdl_index - info->start_index) / info->alloc_size;
+}
+
+static int mlxsw_sp_kvdl_part_alloc(struct mlxsw_sp_kvdl_part *part,
+				    u32 *p_kvdl_index)
+{
+	const struct mlxsw_sp_kvdl_part_info *info = part->info;
+	unsigned int entry_index, nr_entries;
+
+	nr_entries = (info->end_index - info->start_index + 1) /
+		     info->alloc_size;
+	entry_index = find_first_zero_bit(part->usage, nr_entries);
+	if (entry_index == nr_entries)
+		return -ENOBUFS;
+	__set_bit(entry_index, part->usage);
+
+	*p_kvdl_index = mlxsw_sp_entry_index_kvdl_index(part->info,
+							entry_index);
+
+	return 0;
+}
+
+static void mlxsw_sp_kvdl_part_free(struct mlxsw_sp_kvdl_part *part,
+				    u32 kvdl_index)
+{
+	unsigned int entry_index;
+
+	entry_index = mlxsw_sp_kvdl_index_entry_index(part->info,
+						      kvdl_index);
+	__clear_bit(entry_index, part->usage);
+}
+
 int mlxsw_sp_kvdl_alloc(struct mlxsw_sp *mlxsw_sp, unsigned int entry_count,
 			u32 *p_entry_index)
 {
-	int entry_index;
-	int size;
-	int type_base;
-	int type_size;
-	int type_entries;
-
-	if (entry_count == 0 || entry_count > MLXSW_SP_CHUNK_MAX) {
-		return -EINVAL;
-	} else if (entry_count == 1) {
-		type_base = MLXSW_SP_KVDL_SINGLE_BASE;
-		type_size = MLXSW_SP_KVDL_SINGLE_SIZE;
-		type_entries = 1;
-	} else {
-		type_base = MLXSW_SP_KVDL_CHUNKS_BASE;
-		type_size = MLXSW_SP_KVDL_CHUNKS_SIZE;
-		type_entries = MLXSW_SP_CHUNK_MAX;
+	struct mlxsw_sp_kvdl_part *part;
+
+	/* Find partition with smallest allocation size satisfying the
+	 * requested size.
+	 */
+	part = mlxsw_sp_kvdl_alloc_size_part(mlxsw_sp->kvdl, entry_count);
+	if (IS_ERR(part))
+		return PTR_ERR(part);
+
+	return mlxsw_sp_kvdl_part_alloc(part, p_entry_index);
+}
+
+void mlxsw_sp_kvdl_free(struct mlxsw_sp *mlxsw_sp, int entry_index)
+{
+	struct mlxsw_sp_kvdl_part *part;
+
+	part = mlxsw_sp_kvdl_index_part(mlxsw_sp->kvdl, entry_index);
+	if (IS_ERR(part))
+		return;
+	mlxsw_sp_kvdl_part_free(part, entry_index);
+}
+
+static const struct mlxsw_sp_kvdl_part_info kvdl_parts_info[] = {
+	{
+		.part_index	= 0,
+		.start_index	= MLXSW_SP_KVDL_SINGLE_BASE,
+		.end_index	= MLXSW_SP_KVDL_SINGLE_END,
+		.alloc_size	= 1,
+	},
+	{
+		.part_index	= 1,
+		.start_index	= MLXSW_SP_KVDL_CHUNKS_BASE,
+		.end_index	= MLXSW_SP_KVDL_CHUNKS_END,
+		.alloc_size	= MLXSW_SP_CHUNK_MAX,
+	},
+};
+
+static struct mlxsw_sp_kvdl_part *
+mlxsw_sp_kvdl_part_find(struct mlxsw_sp *mlxsw_sp, unsigned int part_index)
+{
+	struct mlxsw_sp_kvdl_part *part;
+
+	list_for_each_entry(part, &mlxsw_sp->kvdl->parts_list, list) {
+		if (part->info->part_index == part_index)
+			return part;
 	}
 
-	entry_index = type_base;
-	size = type_base + type_size;
-	for_each_clear_bit_from(entry_index, mlxsw_sp->kvdl.usage, size) {
-		int i;
+	return NULL;
+}
+
+static int mlxsw_sp_kvdl_part_init(struct mlxsw_sp *mlxsw_sp,
+				   unsigned int part_index)
+{
+	const struct mlxsw_sp_kvdl_part_info *info;
+	struct mlxsw_sp_kvdl_part *part;
+	unsigned int nr_entries;
+	size_t usage_size;
+
+	info = &kvdl_parts_info[part_index];
+
+	nr_entries = (info->end_index - info->start_index + 1) /
+		     info->alloc_size;
+	usage_size = BITS_TO_LONGS(nr_entries) * sizeof(unsigned long);
+	part = kzalloc(sizeof(*part) + usage_size, GFP_KERNEL);
+	if (!part)
+		return -ENOMEM;
+
+	part->info = info;
+	list_add(&part->list, &mlxsw_sp->kvdl->parts_list);
+
+	return 0;
+}
+
+static void mlxsw_sp_kvdl_part_fini(struct mlxsw_sp *mlxsw_sp,
+				    unsigned int part_index)
+{
+	struct mlxsw_sp_kvdl_part *part;
+
+	part = mlxsw_sp_kvdl_part_find(mlxsw_sp, part_index);
+	if (!part)
+		return;
 
-		for (i = 0; i < type_entries; i++)
-			set_bit(entry_index + i, mlxsw_sp->kvdl.usage);
-		*p_entry_index = entry_index;
-		return 0;
+	list_del(&part->list);
+	kfree(part);
+}
+
+static int mlxsw_sp_kvdl_parts_init(struct mlxsw_sp *mlxsw_sp)
+{
+	int err, i;
+
+	INIT_LIST_HEAD(&mlxsw_sp->kvdl->parts_list);
+
+	for (i = 0; i < ARRAY_SIZE(kvdl_parts_info); i++) {
+		err = mlxsw_sp_kvdl_part_init(mlxsw_sp, i);
+		if (err)
+			goto err_kvdl_part_init;
 	}
-	return -ENOBUFS;
+
+	return 0;
+
+err_kvdl_part_init:
+	for (i--; i >= 0; i--)
+		mlxsw_sp_kvdl_part_fini(mlxsw_sp, i);
+	return err;
 }
 
-void mlxsw_sp_kvdl_free(struct mlxsw_sp *mlxsw_sp, int entry_index)
+static void mlxsw_sp_kvdl_parts_fini(struct mlxsw_sp *mlxsw_sp)
 {
-	int type_entries;
 	int i;
 
-	if (entry_index < MLXSW_SP_KVDL_CHUNKS_BASE)
-		type_entries = 1;
-	else
-		type_entries = MLXSW_SP_CHUNK_MAX;
-	for (i = 0; i < type_entries; i++)
-		clear_bit(entry_index + i, mlxsw_sp->kvdl.usage);
+	for (i = ARRAY_SIZE(kvdl_parts_info) - 1; i >= 0; i--)
+		mlxsw_sp_kvdl_part_fini(mlxsw_sp, i);
+}
+
+int mlxsw_sp_kvdl_init(struct mlxsw_sp *mlxsw_sp)
+{
+	struct mlxsw_sp_kvdl *kvdl;
+	int err;
+
+	kvdl = kzalloc(sizeof(*mlxsw_sp->kvdl), GFP_KERNEL);
+	if (!kvdl)
+		return -ENOMEM;
+	mlxsw_sp->kvdl = kvdl;
+
+	err = mlxsw_sp_kvdl_parts_init(mlxsw_sp);
+	if (err)
+		goto err_kvdl_parts_init;
+
+	return 0;
+
+err_kvdl_parts_init:
+	kfree(mlxsw_sp->kvdl);
+	return err;
+}
+
+void mlxsw_sp_kvdl_fini(struct mlxsw_sp *mlxsw_sp)
+{
+	mlxsw_sp_kvdl_parts_fini(mlxsw_sp);
+	kfree(mlxsw_sp->kvdl);
 }
-- 
2.9.5
