From: Chris Mi <chrism@mellanox.com>
Subject: [patch net-next 1/3] idr: Add new APIs to support unsigned long
Date: Mon, 28 Aug 2017 02:41:15 -0400
Message-ID: <1503902477-39829-2-git-send-email-chrism@mellanox.com>
References: <1503902477-39829-1-git-send-email-chrism@mellanox.com>
Cc: jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        davem@davemloft.net, mawilcox@microsoft.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:48360 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750767AbdH1Glk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 02:41:40 -0400
In-Reply-To: <1503902477-39829-1-git-send-email-chrism@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following new APIs are added:

int idr_alloc_ext(struct idr *idr, void *ptr, unsigned long *index,
                  unsigned long start, unsigned long end, gfp_t gfp);
static inline void *idr_remove_ext(struct idr *idr, unsigned long id);
static inline void *idr_find_ext(const struct idr *idr, unsigned long id);
void *idr_replace_ext(struct idr *idr, void *ptr, unsigned long id);
void *idr_get_next_ext(struct idr *idr, unsigned long *nextid);

Signed-off-by: Chris Mi <chrism@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/linux/idr.h        | 16 ++++++++++
 include/linux/radix-tree.h |  3 ++
 lib/idr.c                  | 56 +++++++++++++++++++++++++++++++++++
 lib/radix-tree.c           | 73 ++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 148 insertions(+)

diff --git a/include/linux/idr.h b/include/linux/idr.h
index bf70b3e..e0a030b 100644
--- a/include/linux/idr.h
+++ b/include/linux/idr.h
@@ -81,11 +81,15 @@ static inline void idr_set_cursor(struct idr *idr, unsigned int val)
 
 void idr_preload(gfp_t gfp_mask);
 int idr_alloc(struct idr *, void *entry, int start, int end, gfp_t);
+int idr_alloc_ext(struct idr *idr, void *ptr, unsigned long *index,
+		  unsigned long start, unsigned long end, gfp_t gfp);
 int idr_alloc_cyclic(struct idr *, void *entry, int start, int end, gfp_t);
 int idr_for_each(const struct idr *,
 		 int (*fn)(int id, void *p, void *data), void *data);
 void *idr_get_next(struct idr *, int *nextid);
+void *idr_get_next_ext(struct idr *idr, unsigned long *nextid);
 void *idr_replace(struct idr *, void *, int id);
+void *idr_replace_ext(struct idr *idr, void *ptr, unsigned long id);
 void idr_destroy(struct idr *);
 
 static inline void *idr_remove(struct idr *idr, int id)
@@ -93,6 +97,11 @@ static inline void *idr_remove(struct idr *idr, int id)
 	return radix_tree_delete_item(&idr->idr_rt, id, NULL);
 }
 
+static inline void *idr_remove_ext(struct idr *idr, unsigned long id)
+{
+	return radix_tree_delete_item(&idr->idr_rt, id, NULL);
+}
+
 static inline void idr_init(struct idr *idr)
 {
 	INIT_RADIX_TREE(&idr->idr_rt, IDR_RT_MARKER);
@@ -133,6 +142,11 @@ static inline void *idr_find(const struct idr *idr, int id)
 	return radix_tree_lookup(&idr->idr_rt, id);
 }
 
+static inline void *idr_find_ext(const struct idr *idr, unsigned long id)
+{
+	return radix_tree_lookup(&idr->idr_rt, id);
+}
+
 /**
  * idr_for_each_entry - iterate over an idr's elements of a given type
  * @idr:     idr handle
@@ -145,6 +159,8 @@ static inline void *idr_find(const struct idr *idr, int id)
  */
 #define idr_for_each_entry(idr, entry, id)			\
 	for (id = 0; ((entry) = idr_get_next(idr, &(id))) != NULL; ++id)
+#define idr_for_each_entry_ext(idr, entry, id)			\
+	for (id = 0; ((entry) = idr_get_next_ext(idr, &(id))) != NULL; ++id)
 
 /**
  * idr_for_each_entry_continue - continue iteration over an idr's elements of a given type
diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 3e57350..947299e 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -359,6 +359,9 @@ int radix_tree_join(struct radix_tree_root *, unsigned long index,
 			unsigned new_order, void *);
 void __rcu **idr_get_free(struct radix_tree_root *, struct radix_tree_iter *,
 			gfp_t, int end);
+void __rcu **idr_get_free_ext(struct radix_tree_root *root,
+			      struct radix_tree_iter *iter,
+			      gfp_t gfp, unsigned long end);
 
 enum {
 	RADIX_TREE_ITER_TAG_MASK = 0x0f,	/* tag index in lower nybble */
diff --git a/lib/idr.c b/lib/idr.c
index b13682b..2a091b9 100644
--- a/lib/idr.c
+++ b/lib/idr.c
@@ -47,6 +47,29 @@ int idr_alloc(struct idr *idr, void *ptr, int start, int end, gfp_t gfp)
 }
 EXPORT_SYMBOL_GPL(idr_alloc);
 
+int idr_alloc_ext(struct idr *idr, void *ptr, unsigned long *index,
+		  unsigned long start, unsigned long end, gfp_t gfp)
+{
+	void __rcu **slot;
+	struct radix_tree_iter iter;
+
+	if (WARN_ON_ONCE(radix_tree_is_internal_node(ptr)))
+		return -EINVAL;
+
+	radix_tree_iter_init(&iter, start);
+	slot = idr_get_free_ext(&idr->idr_rt, &iter, gfp, end);
+	if (IS_ERR(slot))
+		return PTR_ERR(slot);
+
+	radix_tree_iter_replace(&idr->idr_rt, &iter, slot, ptr);
+	radix_tree_iter_tag_clear(&idr->idr_rt, &iter, IDR_FREE);
+
+	if (index)
+		*index = iter.index;
+	return 0;
+}
+EXPORT_SYMBOL_GPL(idr_alloc_ext);
+
 /**
  * idr_alloc_cyclic - allocate new idr entry in a cyclical fashion
  * @idr: idr handle
@@ -134,6 +157,20 @@ void *idr_get_next(struct idr *idr, int *nextid)
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
@@ -169,6 +206,25 @@ void *idr_replace(struct idr *idr, void *ptr, int id)
 }
 EXPORT_SYMBOL(idr_replace);
 
+void *idr_replace_ext(struct idr *idr, void *ptr, unsigned long id)
+{
+	struct radix_tree_node *node;
+	void __rcu **slot = NULL;
+	void *entry;
+
+	if (WARN_ON_ONCE(radix_tree_is_internal_node(ptr)))
+		return ERR_PTR(-EINVAL);
+
+	entry = __radix_tree_lookup(&idr->idr_rt, id, &node, &slot);
+	if (!slot || radix_tree_tag_get(&idr->idr_rt, id, IDR_FREE))
+		return ERR_PTR(-ENOENT);
+
+	__radix_tree_replace(&idr->idr_rt, node, slot, ptr, NULL, NULL);
+
+	return entry;
+}
+EXPORT_SYMBOL(idr_replace_ext);
+
 /**
  * DOC: IDA description
  *
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 898e879..06bfdbd 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -2208,6 +2208,79 @@ void __rcu **idr_get_free(struct radix_tree_root *root,
 	return slot;
 }
 
+void __rcu **idr_get_free_ext(struct radix_tree_root *root,
+			      struct radix_tree_iter *iter,
+			      gfp_t gfp, unsigned long end)
+{
+	struct radix_tree_node *node = NULL, *child;
+	void __rcu **slot = (void __rcu **)&root->rnode;
+	unsigned long maxindex, start = iter->next_index;
+	unsigned long max = end - 1;
+	unsigned int shift, offset = 0;
+
+ grow:
+	shift = radix_tree_load_root(root, &child, &maxindex);
+	if (!radix_tree_tagged(root, IDR_FREE))
+		start = max(start, maxindex + 1);
+	if (start > max)
+		return ERR_PTR(-ENOSPC);
+
+	if (start > maxindex) {
+		int error = radix_tree_extend(root, gfp, start, shift);
+
+		if (error < 0)
+			return ERR_PTR(error);
+		shift = error;
+		child = rcu_dereference_raw(root->rnode);
+	}
+
+	while (shift) {
+		shift -= RADIX_TREE_MAP_SHIFT;
+		if (child == NULL) {
+			/* Have to add a child node.  */
+			child = radix_tree_node_alloc(gfp, node, root, shift,
+						      offset, 0, 0);
+			if (!child)
+				return ERR_PTR(-ENOMEM);
+			all_tag_set(child, IDR_FREE);
+			rcu_assign_pointer(*slot, node_to_entry(child));
+			if (node)
+				node->count++;
+		} else if (!radix_tree_is_internal_node(child))
+			break;
+
+		node = entry_to_node(child);
+		offset = radix_tree_descend(node, &child, start);
+		if (!tag_get(node, IDR_FREE, offset)) {
+			offset = radix_tree_find_next_bit(node, IDR_FREE,
+							  offset + 1);
+			start = next_index(start, node, offset);
+			if (start > max)
+				return ERR_PTR(-ENOSPC);
+			while (offset == RADIX_TREE_MAP_SIZE) {
+				offset = node->offset + 1;
+				node = node->parent;
+				if (!node)
+					goto grow;
+				shift = node->shift;
+			}
+			child = rcu_dereference_raw(node->slots[offset]);
+		}
+		slot = &node->slots[offset];
+	}
+
+	iter->index = start;
+	if (node)
+		iter->next_index = 1 + min(max, (start | node_maxindex(node)));
+	else
+		iter->next_index = 1;
+	iter->node = node;
+	__set_iter_shift(iter, shift);
+	set_iter_tags(iter, node, offset, IDR_FREE);
+
+	return slot;
+}
+
 /**
  * idr_destroy - release all internal memory from an IDR
  * @idr: idr handle
-- 
1.8.3.1
