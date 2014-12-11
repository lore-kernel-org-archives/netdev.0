From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V2 net-next 06/10] net/mlx4: Add mlx4_bitmap zone allocator
Date: Thu, 11 Dec 2014 10:57:56 +0200
Message-ID: <1418288280-334-7-git-send-email-ogerlitz@mellanox.com>
References: <1418288280-334-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40520 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S934176AbaLKI7M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Dec 2014 03:59:12 -0500
In-Reply-To: <1418288280-334-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matan Barak <matanb@mellanox.com>

The zone allocator is a mechanism which manages a few mlx4_bitmaps.

When allocating a resource, the user indicates the desired zone of
which this resource will be allocated from. If possible, the resource
will be allocated from this zone. Otherwise, the resource will be
allocated from a less-than, equal-to, higher-than priority zone,
according to the desired zone's properties with that respective
allocation order.

Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/alloc.c |  382 ++++++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/mlx4.h  |   69 +++++
 2 files changed, 451 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/alloc.c b/drivers/net/ethernet/mellanox/mlx4/alloc.c
index 91a8acc..963dd7e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/alloc.c
+++ b/drivers/net/ethernet/mellanox/mlx4/alloc.c
@@ -149,6 +149,11 @@ u32 mlx4_bitmap_avail(struct mlx4_bitmap *bitmap)
 	return bitmap->avail;
 }
 
+static u32 mlx4_bitmap_masked_value(struct mlx4_bitmap *bitmap, u32 obj)
+{
+	return obj & (bitmap->max + bitmap->reserved_top - 1);
+}
+
 void mlx4_bitmap_free_range(struct mlx4_bitmap *bitmap, u32 obj, int cnt,
 			    int use_rr)
 {
@@ -178,6 +183,7 @@ int mlx4_bitmap_init(struct mlx4_bitmap *bitmap, u32 num, u32 mask,
 	bitmap->mask = mask;
 	bitmap->reserved_top = reserved_top;
 	bitmap->avail = num - reserved_top - reserved_bot;
+	bitmap->effective_len = bitmap->avail;
 	spin_lock_init(&bitmap->lock);
 	bitmap->table = kzalloc(BITS_TO_LONGS(bitmap->max) *
 				sizeof (long), GFP_KERNEL);
@@ -194,6 +200,382 @@ void mlx4_bitmap_cleanup(struct mlx4_bitmap *bitmap)
 	kfree(bitmap->table);
 }
 
+struct mlx4_zone_allocator {
+	struct list_head		entries;
+	struct list_head		prios;
+	u32				last_uid;
+	u32				mask;
+	/* protect the zone_allocator from concurrent accesses */
+	spinlock_t			lock;
+	enum mlx4_zone_alloc_flags	flags;
+};
+
+struct mlx4_zone_entry {
+	struct list_head		list;
+	struct list_head		prio_list;
+	u32				uid;
+	struct mlx4_zone_allocator	*allocator;
+	struct mlx4_bitmap		*bitmap;
+	int				use_rr;
+	int				priority;
+	int				offset;
+	enum mlx4_zone_flags		flags;
+};
+
+struct mlx4_zone_allocator *mlx4_zone_allocator_create(enum mlx4_zone_alloc_flags flags)
+{
+	struct mlx4_zone_allocator *zones = kmalloc(sizeof(*zones), GFP_KERNEL);
+
+	if (NULL == zones)
+		return NULL;
+
+	INIT_LIST_HEAD(&zones->entries);
+	INIT_LIST_HEAD(&zones->prios);
+	spin_lock_init(&zones->lock);
+	zones->last_uid = 0;
+	zones->mask = 0;
+	zones->flags = flags;
+
+	return zones;
+}
+
+int mlx4_zone_add_one(struct mlx4_zone_allocator *zone_alloc,
+		      struct mlx4_bitmap *bitmap,
+		      u32 flags,
+		      int priority,
+		      int offset,
+		      u32 *puid)
+{
+	u32 mask = mlx4_bitmap_masked_value(bitmap, (u32)-1);
+	struct mlx4_zone_entry *it;
+	struct mlx4_zone_entry *zone = kmalloc(sizeof(*zone), GFP_KERNEL);
+
+	if (NULL == zone)
+		return -ENOMEM;
+
+	zone->flags = flags;
+	zone->bitmap = bitmap;
+	zone->use_rr = (flags & MLX4_ZONE_USE_RR) ? MLX4_USE_RR : 0;
+	zone->priority = priority;
+	zone->offset = offset;
+
+	spin_lock(&zone_alloc->lock);
+
+	zone->uid = zone_alloc->last_uid++;
+	zone->allocator = zone_alloc;
+
+	if (zone_alloc->mask < mask)
+		zone_alloc->mask = mask;
+
+	list_for_each_entry(it, &zone_alloc->prios, prio_list)
+		if (it->priority >= priority)
+			break;
+
+	if (&it->prio_list == &zone_alloc->prios || it->priority > priority)
+		list_add_tail(&zone->prio_list, &it->prio_list);
+	list_add_tail(&zone->list, &it->list);
+
+	spin_unlock(&zone_alloc->lock);
+
+	*puid = zone->uid;
+
+	return 0;
+}
+
+/* Should be called under a lock */
+static int __mlx4_zone_remove_one_entry(struct mlx4_zone_entry *entry)
+{
+	struct mlx4_zone_allocator *zone_alloc = entry->allocator;
+
+	if (!list_empty(&entry->prio_list)) {
+		/* Check if we need to add an alternative node to the prio list */
+		if (!list_is_last(&entry->list, &zone_alloc->entries)) {
+			struct mlx4_zone_entry *next = list_first_entry(&entry->list,
+									typeof(*next),
+									list);
+
+			if (next->priority == entry->priority)
+				list_add_tail(&next->prio_list, &entry->prio_list);
+		}
+
+		list_del(&entry->prio_list);
+	}
+
+	list_del(&entry->list);
+
+	if (zone_alloc->flags & MLX4_ZONE_ALLOC_FLAGS_NO_OVERLAP) {
+		u32 mask = 0;
+		struct mlx4_zone_entry *it;
+
+		list_for_each_entry(it, &zone_alloc->prios, prio_list) {
+			u32 cur_mask = mlx4_bitmap_masked_value(it->bitmap, (u32)-1);
+
+			if (mask < cur_mask)
+				mask = cur_mask;
+		}
+		zone_alloc->mask = mask;
+	}
+
+	return 0;
+}
+
+void mlx4_zone_allocator_destroy(struct mlx4_zone_allocator *zone_alloc)
+{
+	struct mlx4_zone_entry *zone, *tmp;
+
+	spin_lock(&zone_alloc->lock);
+
+	list_for_each_entry_safe(zone, tmp, &zone_alloc->entries, list) {
+		list_del(&zone->list);
+		list_del(&zone->prio_list);
+		kfree(zone);
+	}
+
+	spin_unlock(&zone_alloc->lock);
+	kfree(zone_alloc);
+}
+
+/* Should be called under a lock */
+static u32 __mlx4_alloc_from_zone(struct mlx4_zone_entry *zone, int count,
+				  int align, u32 skip_mask, u32 *puid)
+{
+	u32 uid;
+	u32 res;
+	struct mlx4_zone_allocator *zone_alloc = zone->allocator;
+	struct mlx4_zone_entry *curr_node;
+
+	res = mlx4_bitmap_alloc_range(zone->bitmap, count,
+				      align, skip_mask);
+
+	if (res != (u32)-1) {
+		res += zone->offset;
+		uid = zone->uid;
+		goto out;
+	}
+
+	list_for_each_entry(curr_node, &zone_alloc->prios, prio_list) {
+		if (unlikely(curr_node->priority == zone->priority))
+			break;
+	}
+
+	if (zone->flags & MLX4_ZONE_ALLOW_ALLOC_FROM_LOWER_PRIO) {
+		struct mlx4_zone_entry *it = curr_node;
+
+		list_for_each_entry_continue_reverse(it, &zone_alloc->entries, list) {
+			res = mlx4_bitmap_alloc_range(it->bitmap, count,
+						      align, skip_mask);
+			if (res != (u32)-1) {
+				res += it->offset;
+				uid = it->uid;
+				goto out;
+			}
+		}
+	}
+
+	if (zone->flags & MLX4_ZONE_ALLOW_ALLOC_FROM_EQ_PRIO) {
+		struct mlx4_zone_entry *it = curr_node;
+
+		list_for_each_entry_from(it, &zone_alloc->entries, list) {
+			if (unlikely(it == zone))
+				continue;
+
+			if (unlikely(it->priority != curr_node->priority))
+				break;
+
+			res = mlx4_bitmap_alloc_range(it->bitmap, count,
+						      align, skip_mask);
+			if (res != (u32)-1) {
+				res += it->offset;
+				uid = it->uid;
+				goto out;
+			}
+		}
+	}
+
+	if (zone->flags & MLX4_ZONE_FALLBACK_TO_HIGHER_PRIO) {
+		if (list_is_last(&curr_node->prio_list, &zone_alloc->prios))
+			goto out;
+
+		curr_node = list_first_entry(&curr_node->prio_list,
+					     typeof(*curr_node),
+					     prio_list);
+
+		list_for_each_entry_from(curr_node, &zone_alloc->entries, list) {
+			res = mlx4_bitmap_alloc_range(curr_node->bitmap, count,
+						      align, skip_mask);
+			if (res != (u32)-1) {
+				res += curr_node->offset;
+				uid = curr_node->uid;
+				goto out;
+			}
+		}
+	}
+
+out:
+	if (NULL != puid && res != (u32)-1)
+		*puid = uid;
+	return res;
+}
+
+/* Should be called under a lock */
+static void __mlx4_free_from_zone(struct mlx4_zone_entry *zone, u32 obj,
+				  u32 count)
+{
+	mlx4_bitmap_free_range(zone->bitmap, obj - zone->offset, count, zone->use_rr);
+}
+
+/* Should be called under a lock */
+static struct mlx4_zone_entry *__mlx4_find_zone_by_uid(
+		struct mlx4_zone_allocator *zones, u32 uid)
+{
+	struct mlx4_zone_entry *zone;
+
+	list_for_each_entry(zone, &zones->entries, list) {
+		if (zone->uid == uid)
+			return zone;
+	}
+
+	return NULL;
+}
+
+struct mlx4_bitmap *mlx4_zone_get_bitmap(struct mlx4_zone_allocator *zones, u32 uid)
+{
+	struct mlx4_zone_entry *zone;
+	struct mlx4_bitmap *bitmap;
+
+	spin_lock(&zones->lock);
+
+	zone = __mlx4_find_zone_by_uid(zones, uid);
+
+	bitmap = zone == NULL ? NULL : zone->bitmap;
+
+	spin_unlock(&zones->lock);
+
+	return bitmap;
+}
+
+int mlx4_zone_remove_one(struct mlx4_zone_allocator *zones, u32 uid)
+{
+	struct mlx4_zone_entry *zone;
+	int res;
+
+	spin_lock(&zones->lock);
+
+	zone = __mlx4_find_zone_by_uid(zones, uid);
+
+	if (NULL == zone) {
+		res = -1;
+		goto out;
+	}
+
+	res = __mlx4_zone_remove_one_entry(zone);
+
+out:
+	spin_unlock(&zones->lock);
+	kfree(zone);
+
+	return res;
+}
+
+/* Should be called under a lock */
+static struct mlx4_zone_entry *__mlx4_find_zone_by_uid_unique(
+		struct mlx4_zone_allocator *zones, u32 obj)
+{
+	struct mlx4_zone_entry *zone, *zone_candidate = NULL;
+	u32 dist = (u32)-1;
+
+	/* Search for the smallest zone that this obj could be
+	 * allocated from. This is done in order to handle
+	 * situations when small bitmaps are allocated from bigger
+	 * bitmaps (and the allocated space is marked as reserved in
+	 * the bigger bitmap.
+	 */
+	list_for_each_entry(zone, &zones->entries, list) {
+		if (obj >= zone->offset) {
+			u32 mobj = (obj - zone->offset) & zones->mask;
+
+			if (mobj < zone->bitmap->max) {
+				u32 curr_dist = zone->bitmap->effective_len;
+
+				if (curr_dist < dist) {
+					dist = curr_dist;
+					zone_candidate = zone;
+				}
+			}
+		}
+	}
+
+	return zone_candidate;
+}
+
+u32 mlx4_zone_alloc_entries(struct mlx4_zone_allocator *zones, u32 uid, int count,
+			    int align, u32 skip_mask, u32 *puid)
+{
+	struct mlx4_zone_entry *zone;
+	int res = -1;
+
+	spin_lock(&zones->lock);
+
+	zone = __mlx4_find_zone_by_uid(zones, uid);
+
+	if (NULL == zone)
+		goto out;
+
+	res = __mlx4_alloc_from_zone(zone, count, align, skip_mask, puid);
+
+out:
+	spin_unlock(&zones->lock);
+
+	return res;
+}
+
+u32 mlx4_zone_free_entries(struct mlx4_zone_allocator *zones, u32 uid, u32 obj, u32 count)
+{
+	struct mlx4_zone_entry *zone;
+	int res = 0;
+
+	spin_lock(&zones->lock);
+
+	zone = __mlx4_find_zone_by_uid(zones, uid);
+
+	if (NULL == zone) {
+		res = -1;
+		goto out;
+	}
+
+	__mlx4_free_from_zone(zone, obj, count);
+
+out:
+	spin_unlock(&zones->lock);
+
+	return res;
+}
+
+u32 mlx4_zone_free_entries_unique(struct mlx4_zone_allocator *zones, u32 obj, u32 count)
+{
+	struct mlx4_zone_entry *zone;
+	int res;
+
+	if (!(zones->flags & MLX4_ZONE_ALLOC_FLAGS_NO_OVERLAP))
+		return -EFAULT;
+
+	spin_lock(&zones->lock);
+
+	zone = __mlx4_find_zone_by_uid_unique(zones, obj);
+
+	if (NULL == zone) {
+		res = -1;
+		goto out;
+	}
+
+	__mlx4_free_from_zone(zone, obj, count);
+	res = 0;
+
+out:
+	spin_unlock(&zones->lock);
+
+	return res;
+}
 /*
  * Handling for queue buffers -- we allocate a bunch of memory and
  * register it in a memory region at HCA virtual address 0.  If the
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index 6834da6..bc1505e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -245,6 +245,7 @@ struct mlx4_bitmap {
 	u32                     reserved_top;
 	u32			mask;
 	u32			avail;
+	u32			effective_len;
 	spinlock_t		lock;
 	unsigned long	       *table;
 };
@@ -1345,4 +1346,72 @@ int mlx4_get_slave_num_gids(struct mlx4_dev *dev, int slave, int port);
 int mlx4_get_vf_indx(struct mlx4_dev *dev, int slave);
 int mlx4_config_mad_demux(struct mlx4_dev *dev);
 
+enum mlx4_zone_flags {
+	MLX4_ZONE_ALLOW_ALLOC_FROM_LOWER_PRIO	= 1UL << 0,
+	MLX4_ZONE_ALLOW_ALLOC_FROM_EQ_PRIO	= 1UL << 1,
+	MLX4_ZONE_FALLBACK_TO_HIGHER_PRIO	= 1UL << 2,
+	MLX4_ZONE_USE_RR			= 1UL << 3,
+};
+
+enum mlx4_zone_alloc_flags {
+	/* No two objects could overlap between zones. UID
+	 * could be left unused. If this flag is given and
+	 * two overlapped zones are used, an object will be free'd
+	 * from the smallest possible matching zone.
+	 */
+	MLX4_ZONE_ALLOC_FLAGS_NO_OVERLAP	= 1UL << 0,
+};
+
+struct mlx4_zone_allocator;
+
+/* Create a new zone allocator */
+struct mlx4_zone_allocator *mlx4_zone_allocator_create(enum mlx4_zone_alloc_flags flags);
+
+/* Attach a mlx4_bitmap <bitmap> of priority <priority> to the zone allocator
+ * <zone_alloc>. Allocating an object from this zone adds an offset <offset>.
+ * Similarly, when searching for an object to free, this offset it taken into
+ * account. The use_rr mlx4_ib parameter for allocating objects from this <bitmap>
+ * is given through the MLX4_ZONE_USE_RR flag in <flags>.
+ * When an allocation fails, <zone_alloc> tries to allocate from other zones
+ * according to the policy set by <flags>. <puid> is the unique identifier
+ * received to this zone.
+ */
+int mlx4_zone_add_one(struct mlx4_zone_allocator *zone_alloc,
+		      struct mlx4_bitmap *bitmap,
+		      u32 flags,
+		      int priority,
+		      int offset,
+		      u32 *puid);
+
+/* Remove bitmap indicated by <uid> from <zone_alloc> */
+int mlx4_zone_remove_one(struct mlx4_zone_allocator *zone_alloc, u32 uid);
+
+/* Delete the zone allocator <zone_alloc. This function doesn't destroy
+ * the attached bitmaps.
+ */
+void mlx4_zone_allocator_destroy(struct mlx4_zone_allocator *zone_alloc);
+
+/* Allocate <count> objects with align <align> and skip_mask <skip_mask>
+ * from the mlx4_bitmap whose uid is <uid>. The bitmap which we actually
+ * allocated from is returned in <puid>. If the allocation fails, a negative
+ * number is returned. Otherwise, the offset of the first object is returned.
+ */
+u32 mlx4_zone_alloc_entries(struct mlx4_zone_allocator *zones, u32 uid, int count,
+			    int align, u32 skip_mask, u32 *puid);
+
+/* Free <count> objects, start from <obj> of the uid <uid> from zone_allocator
+ * <zones>.
+ */
+u32 mlx4_zone_free_entries(struct mlx4_zone_allocator *zones,
+			   u32 uid, u32 obj, u32 count);
+
+/* If <zones> was allocated with MLX4_ZONE_ALLOC_FLAGS_NO_OVERLAP, instead of
+ * specifying the uid when freeing an object, zone allocator could figure it by
+ * itself. Other parameters are similar to mlx4_zone_free.
+ */
+u32 mlx4_zone_free_entries_unique(struct mlx4_zone_allocator *zones, u32 obj, u32 count);
+
+/* Returns a pointer to mlx4_bitmap that was attached to <zones> with <uid> */
+struct mlx4_bitmap *mlx4_zone_get_bitmap(struct mlx4_zone_allocator *zones, u32 uid);
+
 #endif /* MLX4_H */
-- 
1.7.1
