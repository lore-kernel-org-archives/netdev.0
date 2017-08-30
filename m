From: Chris Mi <chrism@mellanox.com>
Subject: [patch net-next v2 1/3] idr: Add new APIs to support unsigned long
Date: Wed, 30 Aug 2017 02:31:57 -0400
Message-ID: <1504074719-15147-2-git-send-email-chrism@mellanox.com>
References: <1504074719-15147-1-git-send-email-chrism@mellanox.com>
Cc: jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        davem@davemloft.net, mawilcox@microsoft.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:37966 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750746AbdH3GcZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 02:32:25 -0400
In-Reply-To: <1504074719-15147-1-git-send-email-chrism@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following new APIs are added:

int idr_alloc_ext(struct idr *idr, void *ptr, unsigned long *index,
                  unsigned long start, unsigned long end, gfp_t gfp);
void *idr_remove_ext(struct idr *idr, unsigned long id);
void *idr_find_ext(const struct idr *idr, unsigned long id);
void *idr_replace_ext(struct idr *idr, void *ptr, unsigned long id);
void *idr_get_next_ext(struct idr *idr, unsigned long *nextid);

Signed-off-by: Chris Mi <chrism@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/linux/idr.h        | 69 ++++++++++++++++++++++++++++++++++++++++++++--
 include/linux/radix-tree.h | 21 ++++++++++++--
 lib/idr.c                  | 66 +++++++++++++++++++++++++-------------------
 lib/radix-tree.c           |  6 ++--
 4 files changed, 125 insertions(+), 37 deletions(-)

diff --git a/include/linux/idr.h b/include/linux/idr.h
index bf70b3e..7c3a365 100644
--- a/include/linux/idr.h
+++ b/include/linux/idr.h
@@ -80,19 +80,75 @@ static inline void idr_set_cursor(struct idr *idr, unsigned int val)
  */
 
 void idr_preload(gfp_t gfp_mask);
-int idr_alloc(struct idr *, void *entry, int start, int end, gfp_t);
+
+int idr_alloc_cmn(struct idr *idr, void *ptr, unsigned long *index,
+		  unsigned long start, unsigned long end, gfp_t gfp,
+		  bool ext);
+
+/**
+ * idr_alloc - allocate an id
+ * @idr: idr handle
+ * @ptr: pointer to be associated with the new id
+ * @start: the minimum id (inclusive)
+ * @end: the maximum id (exclusive)
+ * @gfp: memory allocation flags
+ *
+ * Allocates an unused ID in the range [start, end).  Returns -ENOSPC
+ * if there are no unused IDs in that range.
+ *
+ * Note that @end is treated as max when <= 0.  This is to always allow
+ * using @start + N as @end as long as N is inside integer range.
+ *
+ * Simultaneous modifications to the @idr are not allowed and should be
+ * prevented by the user, usually with a lock.  idr_alloc() may be called
+ * concurrently with read-only accesses to the @idr, such as idr_find() and
+ * idr_for_each_entry().
+ */
+static inline int idr_alloc(struct idr *idr, void *ptr,
+			    int start, int end, gfp_t gfp)
+{
+	unsigned long id;
+	int ret;
+
+	if (WARN_ON_ONCE(start < 0))
+		return -EINVAL;
+
+	ret = idr_alloc_cmn(idr, ptr, &id, start, end, gfp, false);
+
+	if (ret)
+		return ret;
+
+	return id;
+}
+
+static inline int idr_alloc_ext(struct idr *idr, void *ptr,
+				unsigned long *index,
+				unsigned long start,
+				unsigned long end,
+				gfp_t gfp)
+{
+	return idr_alloc_cmn(idr, ptr, index, start, end, gfp, true);
+}
+
 int idr_alloc_cyclic(struct idr *, void *entry, int start, int end, gfp_t);
 int idr_for_each(const struct idr *,
 		 int (*fn)(int id, void *p, void *data), void *data);
 void *idr_get_next(struct idr *, int *nextid);
+void *idr_get_next_ext(struct idr *idr, unsigned long *nextid);
 void *idr_replace(struct idr *, void *, int id);
+void *idr_replace_ext(struct idr *idr, void *ptr, unsigned long id);
 void idr_destroy(struct idr *);
 
-static inline void *idr_remove(struct idr *idr, int id)
+static inline void *idr_remove_ext(struct idr *idr, unsigned long id)
 {
 	return radix_tree_delete_item(&idr->idr_rt, id, NULL);
 }
 
+static inline void *idr_remove(struct idr *idr, int id)
+{
+	return idr_remove_ext(idr, id);
+}
+
 static inline void idr_init(struct idr *idr)
 {
 	INIT_RADIX_TREE(&idr->idr_rt, IDR_RT_MARKER);
@@ -128,11 +184,16 @@ static inline void idr_preload_end(void)
  * This function can be called under rcu_read_lock(), given that the leaf
  * pointers lifetimes are correctly managed.
  */
-static inline void *idr_find(const struct idr *idr, int id)
+static inline void *idr_find_ext(const struct idr *idr, unsigned long id)
 {
 	return radix_tree_lookup(&idr->idr_rt, id);
 }
 
+static inline void *idr_find(const struct idr *idr, int id)
+{
+	return idr_find_ext(idr, id);
+}
+
 /**
  * idr_for_each_entry - iterate over an idr's elements of a given type
  * @idr:     idr handle
@@ -145,6 +206,8 @@ static inline void *idr_find(const struct idr *idr, int id)
  */
 #define idr_for_each_entry(idr, entry, id)			\
 	for (id = 0; ((entry) = idr_get_next(idr, &(id))) != NULL; ++id)
+#define idr_for_each_entry_ext(idr, entry, id)			\
+	for (id = 0; ((entry) = idr_get_next_ext(idr, &(id))) != NULL; ++id)
 
 /**
  * idr_for_each_entry_continue - continue iteration over an idr's elements of a given type
diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 3e57350..567ebb5 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -357,8 +357,25 @@ int radix_tree_split(struct radix_tree_root *, unsigned long index,
 			unsigned new_order);
 int radix_tree_join(struct radix_tree_root *, unsigned long index,
 			unsigned new_order, void *);
-void __rcu **idr_get_free(struct radix_tree_root *, struct radix_tree_iter *,
-			gfp_t, int end);
+
+void __rcu **idr_get_free_cmn(struct radix_tree_root *root,
+			      struct radix_tree_iter *iter, gfp_t gfp,
+			      unsigned long max);
+static inline void __rcu **idr_get_free(struct radix_tree_root *root,
+					struct radix_tree_iter *iter,
+					gfp_t gfp,
+					int end)
+{
+	return idr_get_free_cmn(root, iter, gfp, end > 0 ? end - 1 : INT_MAX);
+}
+
+static inline void __rcu **idr_get_free_ext(struct radix_tree_root *root,
+					    struct radix_tree_iter *iter,
+					    gfp_t gfp,
+					    unsigned long end)
+{
+	return idr_get_free_cmn(root, iter, gfp, end - 1);
+}
 
 enum {
 	RADIX_TREE_ITER_TAG_MASK = 0x0f,	/* tag index in lower nybble */
diff --git a/lib/idr.c b/lib/idr.c
index b13682b..082778c 100644
--- a/lib/idr.c
+++ b/lib/idr.c
@@ -7,45 +7,32 @@
 DEFINE_PER_CPU(struct ida_bitmap *, ida_bitmap);
 static DEFINE_SPINLOCK(simple_ida_lock);
 
-/**
- * idr_alloc - allocate an id
- * @idr: idr handle
- * @ptr: pointer to be associated with the new id
- * @start: the minimum id (inclusive)
- * @end: the maximum id (exclusive)
- * @gfp: memory allocation flags
- *
- * Allocates an unused ID in the range [start, end).  Returns -ENOSPC
- * if there are no unused IDs in that range.
- *
- * Note that @end is treated as max when <= 0.  This is to always allow
- * using @start + N as @end as long as N is inside integer range.
- *
- * Simultaneous modifications to the @idr are not allowed and should be
- * prevented by the user, usually with a lock.  idr_alloc() may be called
- * concurrently with read-only accesses to the @idr, such as idr_find() and
- * idr_for_each_entry().
- */
-int idr_alloc(struct idr *idr, void *ptr, int start, int end, gfp_t gfp)
+int idr_alloc_cmn(struct idr *idr, void *ptr, unsigned long *index,
+		  unsigned long start, unsigned long end, gfp_t gfp,
+		  bool ext)
 {
-	void __rcu **slot;
 	struct radix_tree_iter iter;
+	void __rcu **slot;
 
-	if (WARN_ON_ONCE(start < 0))
-		return -EINVAL;
 	if (WARN_ON_ONCE(radix_tree_is_internal_node(ptr)))
 		return -EINVAL;
 
 	radix_tree_iter_init(&iter, start);
-	slot = idr_get_free(&idr->idr_rt, &iter, gfp, end);
+	if (ext)
+		slot = idr_get_free_ext(&idr->idr_rt, &iter, gfp, end);
+	else
+		slot = idr_get_free(&idr->idr_rt, &iter, gfp, end);
 	if (IS_ERR(slot))
 		return PTR_ERR(slot);
 
 	radix_tree_iter_replace(&idr->idr_rt, &iter, slot, ptr);
 	radix_tree_iter_tag_clear(&idr->idr_rt, &iter, IDR_FREE);
-	return iter.index;
+
+	if (index)
+		*index = iter.index;
+	return 0;
 }
-EXPORT_SYMBOL_GPL(idr_alloc);
+EXPORT_SYMBOL_GPL(idr_alloc_cmn);
 
 /**
  * idr_alloc_cyclic - allocate new idr entry in a cyclical fashion
@@ -134,6 +121,20 @@ void *idr_get_next(struct idr *idr, int *nextid)
 }
 EXPORT_SYMBOL(idr_get_next);
 
+void *idr_get_next_ext(struct idr *idr, unsigned long *nextid)
+{
+	struct radix_tree_iter iter;
+	void __rcu **slot;
+
+	slot = radix_tree_iter_find(&idr->idr_rt, &iter, *nextid);
+	if (!slot)
+		return NULL;
+
+	*nextid = iter.index;
+	return rcu_dereference_raw(*slot);
+}
+EXPORT_SYMBOL(idr_get_next_ext);
+
 /**
  * idr_replace - replace pointer for given id
  * @idr: idr handle
@@ -150,12 +151,19 @@ void *idr_get_next(struct idr *idr, int *nextid)
  */
 void *idr_replace(struct idr *idr, void *ptr, int id)
 {
+	if (WARN_ON_ONCE(id < 0))
+		return ERR_PTR(-EINVAL);
+
+	return idr_replace_ext(idr, ptr, id);
+}
+EXPORT_SYMBOL(idr_replace);
+
+void *idr_replace_ext(struct idr *idr, void *ptr, unsigned long id)
+{
 	struct radix_tree_node *node;
 	void __rcu **slot = NULL;
 	void *entry;
 
-	if (WARN_ON_ONCE(id < 0))
-		return ERR_PTR(-EINVAL);
 	if (WARN_ON_ONCE(radix_tree_is_internal_node(ptr)))
 		return ERR_PTR(-EINVAL);
 
@@ -167,7 +175,7 @@ void *idr_replace(struct idr *idr, void *ptr, int id)
 
 	return entry;
 }
-EXPORT_SYMBOL(idr_replace);
+EXPORT_SYMBOL(idr_replace_ext);
 
 /**
  * DOC: IDA description
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 898e879..c191b42 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -2137,13 +2137,13 @@ int ida_pre_get(struct ida *ida, gfp_t gfp)
 }
 EXPORT_SYMBOL(ida_pre_get);
 
-void __rcu **idr_get_free(struct radix_tree_root *root,
-			struct radix_tree_iter *iter, gfp_t gfp, int end)
+void __rcu **idr_get_free_cmn(struct radix_tree_root *root,
+			      struct radix_tree_iter *iter, gfp_t gfp,
+			      unsigned long max)
 {
 	struct radix_tree_node *node = NULL, *child;
 	void __rcu **slot = (void __rcu **)&root->rnode;
 	unsigned long maxindex, start = iter->next_index;
-	unsigned long max = end > 0 ? end - 1 : INT_MAX;
 	unsigned int shift, offset = 0;
 
  grow:
-- 
1.8.3.1
