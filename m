From: Martin KaFai Lau <kafai@fb.com>
Subject: [RFC PATCH net-next 1/5] bpf: LRU List
Date: Sat, 1 Oct 2016 20:58:29 -0700
Message-ID: <1475380713-4106095-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: FB Kernel Team <kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:43460 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751388AbcJBD6g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Oct 2016 23:58:36 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u923soNn011576
        for <netdev@vger.kernel.org>; Sat, 1 Oct 2016 20:58:36 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 25tau5axe1-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Sat, 01 Oct 2016 20:58:35 -0700
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)     by
 mx-out.facebook.com (10.212.232.63) with ESMTP id
 7d5e0b72885411e683a70002c992ebde-399fba50 for <netdev@vger.kernel.org>;        Sat,
 01 Oct 2016 20:58:34 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce bpf_lru_list which will provide LRU capability to
the bpf_htab in the later patch.

General Thoughts:
1. Target use case.  Read is more often than update.
   (i.e. bpf_lookup_elem() is more often than bpf_update_elem()).
   If bpf_prog does a bpf_lookup_elem() first and then an in-place
   update, it still counts as a read operation to the LRU list concern.
2. It may be useful to think of it as a LRU cache
3. Optimize the read case
   3.1 No lock in read case
   3.2 The LRU maintenance is only done during bpf_update_elem()
4. If there is a percpu LRU list, it will lose the system-wise LRU
   property.  A completely isolated percpu LRU list has the best
   performance but the memory utilization is not ideal considering
   the work load may be imbalance.
5. Hence, this patch starts the LRU implementation with a global LRU
   list with batched operations before accessing the global LRU list.
6. There is a percpu list which is named 'struct bpf_lru_locallist' in
   the code.  The local list is to batch enough operations before
   acquiring the lock of the global LRU list.  More details on this later.

Global LRU List:
1. It has three sub-lists: active-list, inactive-list and free-list.
2. The two list idea, active and inactive, is borrowed from the
   page cache.
3. All nodes are pre-allocated and all sit at the free-list (of the
   global LRU list) at the beginning.  The pre-allocated reasoning
   is similar to the existing BPF_MAP_TYPE_HASH.  However,
   opting-out prealloc (BPF_F_NO_PREALLOC) is not supported in
   the LRU map.

Active/Inactive List (of the global LRU list):
1. The active list, as its name says it, maintains the active set of
   the nodes.  We can think of it as the working set or more frequently
   accessed nodes.  The access frequency is approximated by a ref-bit.
   The ref-bit is set during the bpf_lookup_elem().
2. The inactive list, as its name also says it, maintains a less
   active set of nodes.  They are the candidates to be removed
   from the bpf_htab when we are running out of free nodes.
3. The ordering of these two lists is acting as a rough clock.
   The tail of the inactive list is the older nodes and
   should be released first if the bpf_htab needs free element.

Rotating the Active/Inactive List (of the global LRU list):
1. It is the basic operation to maintain the LRU property of
   the global list.
2. The active list is only rotated when the inactive list is running
   low.  This idea is similar to the current page cache.
   Inactive running low is currently defined as
   "# of inactive < # of active".
3. The active list rotation always starts from the tail.  It moves
   node without ref-bit set to the head of the inactive list.
   It moves node with ref-bit set back to the head of the active
   list and then clears its ref-bit.
4. The inactive rotation is pretty simply.
   It walks the inactive list and moves the nodes back to the head of
   active list if its ref-bit is set. The ref-bit is cleared after moving
   to the active list.
   If the node does not have ref-bit set, it just leave it as it is
   because it is already in the inactive list.

Shrinking the Inactive List (of the global LRU list):
1. Shrinking is the operation to get free nodes when the bpf_htab is
   full.
2. It usually only shrinks the inactive list to get free nodes.
3. During shrinking, it will walk the inactive list from the tail,
   delete the nodes without ref-bit set from bpf_htab.
4. If no free node found after step (3), it will forcefully get
   one node from the tail of inactive or active list.  Forcefully is
   in the sense that it ignores the ref-bit.

Local List:
1. Each CPU has a 'struct bpf_lru_locallist'.  The purpose is to
   batch enough operations before acquiring the lock of the
   global LRU.
2. A local list has two sub-lists, free-list and pending-list.
3. During bpf_update_elem(), it will try to get from the free-list
   of (the current CPU local list).
4. If the local free-list is empty, it will acquire from the
   global LRU list.  The global LRU list can either satisfy it
   by its global free-list or by shrinking the global inactive
   list.  Since we have acquired the global LRU list lock,
   it will try to get at most LOCAL_FREE_TARGET elements
   to the local free list.
5. When a new element is added to the bpf_htab, it will
   first sit at the pending-list (of the local list) first.
   The pending-list will be flushed to the global LRU list
   when it needs to acquire free nodes from the global list
   next time.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 kernel/bpf/Makefile       |   2 +-
 kernel/bpf/bpf_lru_list.c | 585 ++++++++++++++++++++++++++++++++++++++++++++++
 kernel/bpf/bpf_lru_list.h |  74 ++++++
 3 files changed, 660 insertions(+), 1 deletion(-)
 create mode 100644 kernel/bpf/bpf_lru_list.c
 create mode 100644 kernel/bpf/bpf_lru_list.h

diff --git a/kernel/bpf/Makefile b/kernel/bpf/Makefile
index eed911d..c4d89d6 100644
--- a/kernel/bpf/Makefile
+++ b/kernel/bpf/Makefile
@@ -1,7 +1,7 @@
 obj-y := core.o
 
 obj-$(CONFIG_BPF_SYSCALL) += syscall.o verifier.o inode.o helpers.o
-obj-$(CONFIG_BPF_SYSCALL) += hashtab.o arraymap.o percpu_freelist.o
+obj-$(CONFIG_BPF_SYSCALL) += hashtab.o arraymap.o percpu_freelist.o bpf_lru_list.o
 ifeq ($(CONFIG_PERF_EVENTS),y)
 obj-$(CONFIG_BPF_SYSCALL) += stackmap.o
 endif
diff --git a/kernel/bpf/bpf_lru_list.c b/kernel/bpf/bpf_lru_list.c
new file mode 100644
index 0000000..4581872
--- /dev/null
+++ b/kernel/bpf/bpf_lru_list.c
@@ -0,0 +1,585 @@
+/* Copyright (c) 2016 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <linux/cpumask.h>
+#include <linux/spinlock.h>
+#include <linux/percpu.h>
+
+#include "bpf_lru_list.h"
+
+/* The max number of elements to process when walking a list */
+#define MAX_WALKS			(128)
+
+/* Whenever we acquire the global LRU's lock to get free nodes,
+ * we try to get LOCAL_FREE_TARGET number of free elements to
+ * the local list.
+ */
+#define LOCAL_FREE_TARGET		(128)
+
+/* Helpers to get the local list index */
+#define LOCAL_LIST_IDX(t)	((t) - BPF_LOCAL_LIST_T_OFFSET)
+#define LOCAL_FREE_LIST_IDX	LOCAL_LIST_IDX(BPF_LRU_LOCAL_LIST_T_FREE)
+#define LOCAL_PENDING_LIST_IDX	LOCAL_LIST_IDX(BPF_LRU_LOCAL_LIST_T_PENDING)
+#define IS_LOCAL_LIST_TYPE(t)	((t) >= BPF_LOCAL_LIST_T_OFFSET)
+
+static int get_next_cpu(int cpu)
+{
+	cpu = cpumask_next(cpu, cpu_possible_mask);
+	if (cpu >= nr_cpu_ids)
+		cpu = cpumask_first(cpu_possible_mask);
+	return cpu;
+}
+
+/* Local list helpers */
+static struct list_head *local_free_list(struct bpf_lru_locallist *loc_l)
+{
+	return &loc_l->lists[LOCAL_FREE_LIST_IDX];
+}
+
+static struct list_head *local_pending_list(struct bpf_lru_locallist *loc_l)
+{
+	return &loc_l->lists[LOCAL_PENDING_LIST_IDX];
+}
+
+/* bpf_lru_node helpers */
+static bool bpf_lru_node_is_ref(const struct bpf_lru_node *node)
+{
+	return node->ref;
+}
+
+static void bpf_lru_list_count_inc(struct bpf_lru_list *l,
+				   enum bpf_lru_list_type type)
+{
+	if (type < NR_BPF_LRU_LIST_COUNT)
+		l->counts[type]++;
+}
+
+static void bpf_lru_list_count_dec(struct bpf_lru_list *l,
+				   enum bpf_lru_list_type type)
+{
+	if (type < NR_BPF_LRU_LIST_COUNT)
+		l->counts[type]--;
+}
+
+/* Move nodes out of the global LRU list to the local free list.
+ *
+ * @l: The global LRU list
+ * @loc_l: The local list
+ * @node: The node which is already in the global LRU list
+ */
+static void __bpf_lru_node_move_out(struct bpf_lru_list *l,
+				    struct bpf_lru_locallist *loc_l,
+				    struct bpf_lru_node *node)
+{
+	if (WARN_ON_ONCE(IS_LOCAL_LIST_TYPE(node->type)))
+		return;
+
+	/* If the removing node is the next_inactive_rotation candidate,
+	 * move the next_inactive_rotation pointer also.
+	 */
+	if (&node->list == l->next_inactive_rotation)
+		l->next_inactive_rotation = l->next_inactive_rotation->prev;
+
+	bpf_lru_list_count_dec(l, node->type);
+
+	node->type = BPF_LRU_LOCAL_LIST_T_FREE;
+	node->cpu = loc_l->cpu;
+	list_move(&node->list, local_free_list(loc_l));
+}
+
+/* Move nodes from local list to the global LRU list
+ *
+ * @l: The global LRU list
+ * @node: The node which is already in the local list
+ * @tgt_type: The target list type
+ */
+static void __bpf_lru_node_move_in(struct bpf_lru_list *l,
+				   struct bpf_lru_node *node,
+				   enum bpf_lru_list_type tgt_type)
+{
+	if (WARN_ON_ONCE(!IS_LOCAL_LIST_TYPE(node->type)) ||
+	    WARN_ON_ONCE(IS_LOCAL_LIST_TYPE(tgt_type)))
+		return;
+
+	bpf_lru_list_count_inc(l, tgt_type);
+	node->type = tgt_type;
+	node->ref = 0;
+	list_move(&node->list, &l->lists[tgt_type]);
+}
+
+/* Move nodes between or within active and inactive list (like
+ * active to inactive, inactive to active or tail of active back to
+ * the head of active).
+ *
+ * @l: The global LRU list
+ * @node: A node which is already in the global LRU list
+ * @tgt_type: The target list type
+ */
+static void __bpf_lru_node_move(struct bpf_lru_list *l,
+				struct bpf_lru_node *node,
+				enum bpf_lru_list_type tgt_type)
+{
+	if (WARN_ON_ONCE(IS_LOCAL_LIST_TYPE(node->type)) ||
+	    WARN_ON_ONCE(IS_LOCAL_LIST_TYPE(tgt_type)))
+		return;
+
+	if (node->type != tgt_type) {
+		bpf_lru_list_count_dec(l, node->type);
+		bpf_lru_list_count_inc(l, tgt_type);
+		node->type = tgt_type;
+	}
+	node->ref = 0;
+
+	/* If the moving node is the next_inactive_rotation candidate,
+	 * move the next_inactive_rotation pointer also.
+	 */
+	if (&node->list == l->next_inactive_rotation)
+		l->next_inactive_rotation = l->next_inactive_rotation->prev;
+
+	list_move(&node->list, &l->lists[tgt_type]);
+}
+
+static bool bpf_lru_list_inactive_low(const struct bpf_lru_list *l)
+{
+	return l->counts[BPF_LRU_LIST_T_INACTIVE] <
+		l->counts[BPF_LRU_LIST_T_ACTIVE];
+}
+
+/* Rotate the active list (of the global LRU list):
+ * 1. Start from tail
+ * 2. If the node has the ref bit set, it will be rotated
+ *    back to the head of active list with the ref bit cleared.
+ *    Give this node one more chance to survive in the active list.
+ * 3. If the ref bit is not set, move it to the head of the
+ *    inactive list.
+ * 4. It will at most scan MAX_WALKS nodes
+ */
+static void __bpf_lru_list_rotate_active(struct bpf_lru_list *l)
+{
+	struct list_head *active = &l->lists[BPF_LRU_LIST_T_ACTIVE];
+	struct bpf_lru_node *node, *tmp_node, *first_node;
+	int i = 0;
+
+	first_node = list_first_entry(active, struct bpf_lru_node, list);
+	list_for_each_entry_safe_reverse(node, tmp_node, active, list) {
+		if (bpf_lru_node_is_ref(node))
+			__bpf_lru_node_move(l, node, BPF_LRU_LIST_T_ACTIVE);
+		else
+			__bpf_lru_node_move(l, node, BPF_LRU_LIST_T_INACTIVE);
+
+		if (++i == MAX_WALKS || node == first_node)
+			break;
+	}
+}
+
+/* Rotate the inactive list (of the global LRU list).  It starts from the
+ * next_inactive_rotation.
+ * 1. If the node has ref bit set, it will be moved to the head
+ *    of active list with the ref bit cleared.
+ * 2. If the node does not have ref bit set, it will leave it
+ *    at its current location (i.e. do nothing) so that it can
+ *    be considered during the next inactive_shrink.
+ * 3. It will at most scan MAX_WALKS nodes.
+ */
+static void __bpf_lru_list_rotate_inactive(struct bpf_lru_list *l)
+{
+	struct list_head *inactive = &l->lists[BPF_LRU_LIST_T_INACTIVE];
+	struct list_head *cur, *next, *last;
+	struct bpf_lru_node *node;
+	unsigned int i = 0;
+
+	if (list_empty(inactive))
+		return;
+
+	last = l->next_inactive_rotation->next;
+	if (last == inactive)
+		last = last->next;
+
+	cur = l->next_inactive_rotation;
+	while (i < MAX_WALKS) {
+		if (cur == inactive) {
+			cur = cur->prev;
+			continue;
+		}
+
+		node = list_entry(cur, struct bpf_lru_node, list);
+		next = cur->prev;
+		if (bpf_lru_node_is_ref(node))
+			__bpf_lru_node_move(l, node, BPF_LRU_LIST_T_ACTIVE);
+		if (cur == last)
+			break;
+		cur = next;
+		i++;
+	}
+
+	l->next_inactive_rotation = next;
+}
+
+/* Shrink the inactive list (of the global LRU list)
+ * It starts from the tail of the inactive list and only
+ * move the nodes without the ref bit set to the
+ * free list (of the percpu _local_ list).
+ */
+static unsigned int __bpf_lru_list_shrink_inactive(struct bpf_lru *lru,
+					   struct bpf_lru_locallist *loc_l,
+					   unsigned int tgt_nshrink)
+{
+	struct bpf_lru_list *l = &lru->lru_list;
+	struct list_head *inactive = &l->lists[BPF_LRU_LIST_T_INACTIVE];
+	struct bpf_lru_node *node, *tmp_node, *first_node;
+	unsigned int nshrinked = 0;
+	int i = 0;
+
+	first_node = list_first_entry(inactive, struct bpf_lru_node, list);
+	list_for_each_entry_safe_reverse(node, tmp_node, inactive, list) {
+		if (bpf_lru_node_is_ref(node))
+			__bpf_lru_node_move(l, node, BPF_LRU_LIST_T_ACTIVE);
+		else if (lru->del_from_htab(lru->del_arg, node)) {
+			__bpf_lru_node_move_out(l, loc_l, node);
+			if (++nshrinked == tgt_nshrink)
+				break;
+		}
+
+		if (++i == MAX_WALKS)
+			break;
+	}
+
+	return nshrinked;
+}
+
+/* 1. Rotate the active list (if needed)
+ * 2. Always rotate the inactive list
+ */
+static void __bpf_lru_list_rotate(struct bpf_lru_list *l)
+{
+	if (bpf_lru_list_inactive_low(l))
+		__bpf_lru_list_rotate_active(l);
+
+	__bpf_lru_list_rotate_inactive(l);
+}
+
+/* Calls __bpf_lru_list_shrink_inactive() to shrink some
+ * ref-bit-cleared nodes and move them to the
+ * free list (of a _local_ list).
+ *
+ * If the _local_ list has no free nodes after calling
+ * __bpf_lru_list_shrink_inactive().  It will just remove
+ * one node from either inactive or active list without
+ * honoring the ref-bit.  It prefers inactive list to active
+ * list in this situation.
+ */
+static unsigned int __bpf_lru_list_shrink(struct bpf_lru *lru,
+				  struct bpf_lru_locallist *loc_l,
+				  unsigned int tgt_nshrink)
+{
+	struct bpf_lru_list *l = &lru->lru_list;
+	struct bpf_lru_node *node, *tmp_node;
+	struct list_head *force_shrink_list;
+	unsigned int nshrinked;
+
+	nshrinked = __bpf_lru_list_shrink_inactive(lru, loc_l, tgt_nshrink);
+	if (nshrinked)
+		return nshrinked;
+
+	/* Do a force shrink by ignoring the reference bit */
+	if (!list_empty(&l->lists[BPF_LRU_LIST_T_INACTIVE]))
+		force_shrink_list = &l->lists[BPF_LRU_LIST_T_INACTIVE];
+	else
+		force_shrink_list = &l->lists[BPF_LRU_LIST_T_ACTIVE];
+
+	list_for_each_entry_safe_reverse(node, tmp_node, force_shrink_list,
+					 list) {
+		if (lru->del_from_htab(lru->del_arg, node)) {
+			__bpf_lru_node_move_out(l, loc_l, node);
+			return 1;
+		}
+	}
+
+	return 0;
+}
+
+static unsigned int __bpf_lru_list_get_free(struct bpf_lru_list *l,
+				    struct bpf_lru_locallist *loc_l,
+				    unsigned int tgt_nfree)
+{
+	struct bpf_lru_node *node, *tmp_node;
+	unsigned int nfree = 0;
+
+	list_for_each_entry_safe(node, tmp_node, &l->lists[BPF_LRU_LIST_T_FREE],
+				 list) {
+		__bpf_lru_node_move_out(l, loc_l, node);
+
+		if (++nfree == tgt_nfree)
+			break;
+	}
+
+	return nfree;
+}
+
+static void __local_list_flush(struct bpf_lru_list *l,
+			       struct bpf_lru_locallist *loc_l)
+{
+	struct bpf_lru_node *node, *tmp_node;
+
+	list_for_each_entry_safe_reverse(node, tmp_node,
+					 local_pending_list(loc_l), list) {
+		if (bpf_lru_node_is_ref(node))
+			__bpf_lru_node_move_in(l, node, BPF_LRU_LIST_T_ACTIVE);
+		else
+			__bpf_lru_node_move_in(l, node,
+					       BPF_LRU_LIST_T_INACTIVE);
+	}
+}
+
+static void bpf_lru_list_push_free(struct bpf_lru_list *l,
+				   struct bpf_lru_node *node)
+{
+	unsigned long flags;
+
+	if (WARN_ON_ONCE(IS_LOCAL_LIST_TYPE(node->type)))
+		return;
+
+	raw_spin_lock_irqsave(&l->lock, flags);
+	__bpf_lru_node_move(l, node, BPF_LRU_LIST_T_FREE);
+	raw_spin_unlock_irqrestore(&l->lock, flags);
+}
+
+static void bpf_lru_list_pop_free(struct bpf_lru *lru,
+				  struct bpf_lru_locallist *loc_l)
+{
+	struct bpf_lru_list *l = &lru->lru_list;
+	unsigned int nfree;
+
+	raw_spin_lock(&l->lock);
+
+	__local_list_flush(l, loc_l);
+
+	__bpf_lru_list_rotate(l);
+
+	nfree = __bpf_lru_list_get_free(l, loc_l, LOCAL_FREE_TARGET);
+	if (nfree < LOCAL_FREE_TARGET)
+		__bpf_lru_list_shrink(lru, loc_l, LOCAL_FREE_TARGET - nfree);
+
+	raw_spin_unlock(&l->lock);
+}
+
+static void __local_list_add_pending(struct bpf_lru *lru,
+				     struct bpf_lru_locallist *loc_l,
+				     struct bpf_lru_node *node,
+				     u32 hash)
+{
+	*(u32 *)((void *)node + lru->hash_offset) = hash;
+	node->type = BPF_LRU_LOCAL_LIST_T_PENDING;
+	node->ref = 0;
+	list_add(&node->list, local_pending_list(loc_l));
+}
+
+struct bpf_lru_node *__local_list_pop_free(struct bpf_lru_locallist *loc_l)
+{
+	struct bpf_lru_node *node;
+
+	node = list_first_entry_or_null(local_free_list(loc_l),
+					struct bpf_lru_node,
+					list);
+	if (node)
+		list_del(&node->list);
+
+	return node;
+}
+
+struct bpf_lru_node *__local_list_pop_pending(struct bpf_lru *lru,
+					      struct bpf_lru_locallist *loc_l)
+{
+	struct bpf_lru_node *node;
+	bool force = false;
+
+ignore_ref:
+	/* Get from the tail (i.e. older element) of the pending list. */
+	list_for_each_entry_reverse(node, local_pending_list(loc_l),
+				    list) {
+		if ((!bpf_lru_node_is_ref(node) || force) &&
+		    lru->del_from_htab(lru->del_arg, node)) {
+			list_del(&node->list);
+			return node;
+		}
+	}
+
+	if (!force) {
+		force = true;
+		goto ignore_ref;
+	}
+
+	return NULL;
+}
+
+struct bpf_lru_node *bpf_lru_pop_free(struct bpf_lru *lru, u32 hash)
+{
+	struct bpf_lru_locallist *loc_l, *steal_loc_l;
+	struct bpf_lru_node *node;
+	int steal, first_steal;
+	unsigned long flags;
+
+	loc_l = this_cpu_ptr(lru->local_list);
+
+	raw_spin_lock_irqsave(&loc_l->lock, flags);
+
+	node = __local_list_pop_free(loc_l);
+	if (!node) {
+		bpf_lru_list_pop_free(lru, loc_l);
+		node = __local_list_pop_free(loc_l);
+	}
+
+	if (node)
+		__local_list_add_pending(lru, loc_l, node, hash);
+
+	raw_spin_unlock_irqrestore(&loc_l->lock, flags);
+
+	if (node)
+		return node;
+
+	/* No free nodes found from the local free list and
+	 * the global LRU list.
+	 *
+	 * Steal from the local free/pending list of the
+	 * current CPU and remote CPU in RR.  It starts
+	 * with the loc_l->next_steal CPU.
+	 */
+
+	first_steal = loc_l->next_steal;
+	steal = first_steal;
+	do {
+		steal_loc_l = per_cpu_ptr(lru->local_list, steal);
+
+		raw_spin_lock_irqsave(&steal_loc_l->lock, flags);
+
+		node = __local_list_pop_free(steal_loc_l);
+		if (!node)
+			node = __local_list_pop_pending(lru, steal_loc_l);
+
+		raw_spin_unlock_irqrestore(&steal_loc_l->lock, flags);
+
+		steal = get_next_cpu(steal);
+	} while (!node && steal != first_steal);
+
+	loc_l->next_steal = steal;
+
+	if (node) {
+		raw_spin_lock_irqsave(&loc_l->lock, flags);
+		__local_list_add_pending(lru, loc_l, node, hash);
+		raw_spin_unlock_irqrestore(&loc_l->lock, flags);
+	}
+
+	return node;
+}
+
+void bpf_lru_push_free(struct bpf_lru *lru, struct bpf_lru_node *node)
+{
+	unsigned long flags;
+
+	if (WARN_ON_ONCE(node->type == BPF_LRU_LIST_T_FREE) ||
+	    WARN_ON_ONCE(node->type == BPF_LRU_LOCAL_LIST_T_FREE))
+		return;
+
+	if (node->type == BPF_LRU_LOCAL_LIST_T_PENDING) {
+		struct bpf_lru_locallist *loc_l;
+
+		loc_l = per_cpu_ptr(lru->local_list, node->cpu);
+
+		raw_spin_lock_irqsave(&loc_l->lock, flags);
+
+		if (unlikely(node->type != BPF_LRU_LOCAL_LIST_T_PENDING)) {
+			raw_spin_unlock_irqrestore(&loc_l->lock, flags);
+			goto check_lru_list;
+		}
+
+		node->type = BPF_LRU_LOCAL_LIST_T_FREE;
+		node->ref = 0;
+		list_move(&node->list, local_free_list(loc_l));
+
+		raw_spin_unlock_irqrestore(&loc_l->lock, flags);
+		return;
+	}
+
+check_lru_list:
+	bpf_lru_list_push_free(&lru->lru_list, node);
+}
+
+void bpf_lru_populate(struct bpf_lru *lru, void *buf, u32 node_offset,
+		      u32 elem_size, u32 nr_elems)
+{
+	struct bpf_lru_list *l = &lru->lru_list;
+	u32 i;
+
+	for (i = 0; i < nr_elems; i++) {
+		struct bpf_lru_node *node;
+
+		node = (struct bpf_lru_node *)(buf + node_offset);
+		node->type = BPF_LRU_LIST_T_FREE;
+		node->ref = 0;
+		list_add(&node->list, &l->lists[BPF_LRU_LIST_T_FREE]);
+		buf += elem_size;
+	}
+}
+
+static void bpf_lru_locallist_init(struct bpf_lru_locallist *loc_l, int cpu)
+{
+	int i;
+
+	for (i = 0; i < NR_BPF_LRU_LOCAL_LIST_T; i++)
+		INIT_LIST_HEAD(&loc_l->lists[i]);
+
+	loc_l->cpu = cpu;
+	loc_l->next_steal = cpu;
+
+	raw_spin_lock_init(&loc_l->lock);
+}
+
+static void bpf_lru_list_init(struct bpf_lru_list *l)
+{
+	int i;
+
+	for (i = 0; i < NR_BPF_LRU_LIST_T; i++)
+		INIT_LIST_HEAD(&l->lists[i]);
+
+	for (i = 0; i < NR_BPF_LRU_LIST_COUNT; i++)
+		l->counts[i] = 0;
+
+	l->next_inactive_rotation = &l->lists[BPF_LRU_LIST_T_INACTIVE];
+
+	raw_spin_lock_init(&l->lock);
+}
+
+int bpf_lru_init(struct bpf_lru *lru,
+		 u32 hash_offset,
+		 del_from_htab_func del_from_htab,
+		 void *del_arg)
+{
+	int cpu;
+
+	lru->local_list = alloc_percpu(struct bpf_lru_locallist);
+	if (!lru->local_list)
+		return -ENOMEM;
+
+	for_each_possible_cpu(cpu) {
+		struct bpf_lru_locallist *loc_l;
+
+		loc_l = per_cpu_ptr(lru->local_list, cpu);
+		bpf_lru_locallist_init(loc_l, cpu);
+	}
+
+	bpf_lru_list_init(&lru->lru_list);
+
+	lru->del_from_htab = del_from_htab;
+	lru->del_arg = del_arg;
+	lru->hash_offset = hash_offset;
+
+	return 0;
+}
+
+void bpf_lru_destroy(struct bpf_lru *lru)
+{
+	free_percpu(lru->local_list);
+}
diff --git a/kernel/bpf/bpf_lru_list.h b/kernel/bpf/bpf_lru_list.h
new file mode 100644
index 0000000..dfe46cd
--- /dev/null
+++ b/kernel/bpf/bpf_lru_list.h
@@ -0,0 +1,74 @@
+/* Copyright (c) 2016 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#ifndef __BPF_LRU_LIST_H_
+#define __BPF_LRU_LIST_H_
+
+#include <linux/list.h>
+#include <linux/spinlock_types.h>
+
+#define NR_BPF_LRU_LIST_T	(3)
+#define NR_BPF_LRU_LIST_COUNT	(2)
+#define NR_BPF_LRU_LOCAL_LIST_T (2)
+#define BPF_LOCAL_LIST_T_OFFSET NR_BPF_LRU_LIST_T
+
+enum bpf_lru_list_type {
+	BPF_LRU_LIST_T_ACTIVE,
+	BPF_LRU_LIST_T_INACTIVE,
+	BPF_LRU_LIST_T_FREE,
+	BPF_LRU_LOCAL_LIST_T_FREE,
+	BPF_LRU_LOCAL_LIST_T_PENDING,
+};
+
+struct bpf_lru_node {
+	struct list_head list;
+	u16 cpu;
+	u8 type;
+	u8 ref;
+};
+
+struct bpf_lru_list {
+	struct list_head lists[NR_BPF_LRU_LIST_T];
+	unsigned int counts[BPF_LRU_LIST_T_FREE];
+	/* The next inacitve list rotation starts from here */
+	struct list_head *next_inactive_rotation;
+	raw_spinlock_t lock ____cacheline_aligned_in_smp;
+};
+
+struct bpf_lru_locallist {
+	struct list_head lists[NR_BPF_LRU_LOCAL_LIST_T];
+	u16 cpu;
+	u16 next_steal;
+	raw_spinlock_t lock;
+};
+
+typedef bool (*del_from_htab_func)(void *arg, struct bpf_lru_node *node);
+
+struct bpf_lru {
+	struct bpf_lru_list lru_list;
+	struct bpf_lru_locallist __percpu *local_list;
+	del_from_htab_func del_from_htab;
+	void *del_arg;
+	unsigned int hash_offset;
+};
+
+static inline void bpf_lru_node_set_ref(struct bpf_lru_node *node)
+{
+	node->ref = 1;
+}
+
+int bpf_lru_init(struct bpf_lru *lru,
+		 u32 hash,
+		 del_from_htab_func del_from_htab,
+		 void *delete_arg);
+void bpf_lru_populate(struct bpf_lru *lru, void *buf, u32 node_offset,
+		      u32 elem_size, u32 nr_elems);
+void bpf_lru_destroy(struct bpf_lru *lru);
+struct bpf_lru_node *bpf_lru_pop_free(struct bpf_lru *lru, u32 hash);
+void bpf_lru_push_free(struct bpf_lru *lru, struct bpf_lru_node *node);
+void bpf_lru_promote(struct bpf_lru *lru, struct bpf_lru_node *node);
+
+#endif
-- 
2.5.1
