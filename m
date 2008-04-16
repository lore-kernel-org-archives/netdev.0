From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 2/3 net-2.6.26] [TIPC]: Optimized initialization of TIPC reference table
Date: Wed, 16 Apr 2008 14:27:25 -0400
Message-ID: <1208370446-12065-3-git-send-email-allan.stephens@windriver.com>
References: <1208370446-12065-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:51878 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750945AbYDPS31 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2008 14:29:27 -0400
In-Reply-To: <1208370446-12065-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch modifies TIPC's reference table code to delay initializing
table entries until they are actually needed by applications.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/ref.c |  123 ++++++++++++++++++++++++++++++++++---------------------
 1 files changed, 76 insertions(+), 47 deletions(-)

diff --git a/net/tipc/ref.c b/net/tipc/ref.c
index d0b240e..1853cca 100644
--- a/net/tipc/ref.c
+++ b/net/tipc/ref.c
@@ -50,7 +50,7 @@
  * struct reference - TIPC object reference entry
  * @object: pointer to object associated with reference entry
  * @lock: spinlock controlling access to object
- * @data: reference value associated with object (or link to next unused entry)
+ * @data: reference value for object (combines instance & array index info)
  */
 
 struct reference {
@@ -65,31 +65,40 @@ struct reference {
 /**
  * struct tipc_ref_table - table of TIPC object reference entries
  * @entries: pointer to array of reference entries
- * @index_mask: bitmask for array index portion of reference values
+ * @capacity: array index of first unusable entry
+ * @init_point: array index of first uninitialized entry
  * @first_free: array index of first unused object reference entry
  * @last_free: array index of last unused object reference entry
+ * @index_mask: bitmask for array index portion of reference values
+ * @start_mask: initial value for instance value portion of reference values
  */
 
 struct ref_table {
 	struct reference *entries;
-	u32 index_mask;
+	u32 capacity;
+	u32 init_point;
 	u32 first_free;
 	u32 last_free;
+	u32 index_mask;
+	u32 start_mask;
 };
 
 /*
  * Object reference table consists of 2**N entries.
  *
- * A used entry has object ptr != 0, reference == XXXX|own index
- *				     (XXXX changes each time entry is acquired)
- * A free entry has object ptr == 0, reference == YYYY|next free index
- *				     (YYYY is one more than last used XXXX)
+ * State	Object ptr	Reference
+ * -----        ----------      ---------
+ * In use        non-NULL       XXXX|own index
+ *				(XXXX changes each time entry is acquired)
+ * Free            NULL         YYYY|next free index
+ *				(YYYY is one more than last used XXXX)
+ * Uninitialized   NULL         0
  *
- * Free list is initially chained from entry (2**N)-1 to entry 1.
- * Entry 0 is not used to allow index 0 to indicate the end of the free list.
+ * Entry 0 is not used; this allows index 0 to denote the end of the free list.
  *
- * Note: Any accidental reference of the form XXXX|0--0 won't match entry 0
- * because entry 0's reference field has the form XXXX|1--1.
+ * Note that a reference value of 0 does not necessarily indicate that an
+ * entry is uninitialized, since the last entry in the free list could also
+ * have a reference value of 0 (although this is unlikely).
  */
 
 static struct ref_table tipc_ref_table = { NULL };
@@ -103,29 +112,29 @@ static DEFINE_RWLOCK(ref_table_lock);
 int tipc_ref_table_init(u32 requested_size, u32 start)
 {
 	struct reference *table;
-	u32 sz = 1 << 4;
-	u32 index_mask;
-	int i;
+	u32 actual_size;
 
-	while (sz < requested_size) {
-		sz <<= 1;
-	}
-	table = vmalloc(sz * sizeof(*table));
+	/* account for unused entry, then round up size to a power of 2 */
+
+	requested_size++;
+	for (actual_size = 16; actual_size < requested_size; actual_size <<= 1)
+		/* do nothing */ ;
+
+	/* allocate table & mark all entries as uninitialized */
+
+	table = __vmalloc(actual_size * sizeof(struct reference),
+			  GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO, PAGE_KERNEL);
 	if (table == NULL)
 		return -ENOMEM;
 
-	write_lock_bh(&ref_table_lock);
-	index_mask = sz - 1;
-	for (i = sz - 1; i >= 0; i--) {
-		table[i].object = NULL;
-		spin_lock_init(&table[i].lock);
-		table[i].data.next_plus_upper = (start & ~index_mask) + i - 1;
-	}
 	tipc_ref_table.entries = table;
-	tipc_ref_table.index_mask = index_mask;
-	tipc_ref_table.first_free = sz - 1;
-	tipc_ref_table.last_free = 1;
-	write_unlock_bh(&ref_table_lock);
+	tipc_ref_table.capacity = requested_size;
+	tipc_ref_table.init_point = 1;
+	tipc_ref_table.first_free = 0;
+	tipc_ref_table.last_free = 0;
+	tipc_ref_table.index_mask = actual_size - 1;
+	tipc_ref_table.start_mask = start & ~tipc_ref_table.index_mask;
+
 	return TIPC_OK;
 }
 
@@ -156,7 +165,7 @@ u32 tipc_ref_acquire(void *object, spinlock_t **lock)
 	u32 index;
 	u32 index_mask;
 	u32 next_plus_upper;
-	u32 reference = 0;
+	u32 reference;
 
 	if (!object) {
 		err("Attempt to acquire reference to non-existent object\n");
@@ -167,6 +176,8 @@ u32 tipc_ref_acquire(void *object, spinlock_t **lock)
 		return 0;
 	}
 
+	/* take a free entry, if available; otherwise initialize a new entry */
+
 	write_lock_bh(&ref_table_lock);
 	if (tipc_ref_table.first_free) {
 		index = tipc_ref_table.first_free;
@@ -179,11 +190,23 @@ u32 tipc_ref_acquire(void *object, spinlock_t **lock)
 		reference = (next_plus_upper & ~index_mask) + index;
 		entry->data.reference = reference;
 		entry->object = object;
-		if (lock != NULL)
-			*lock = &entry->lock;
 		spin_unlock_bh(&entry->lock);
+		*lock = &entry->lock;
+	}
+	else if (tipc_ref_table.init_point < tipc_ref_table.capacity) {
+		index = tipc_ref_table.init_point++;
+		entry = &(tipc_ref_table.entries[index]);
+		spin_lock_init(&entry->lock);
+		reference = tipc_ref_table.start_mask + index;
+		entry->data.reference = reference;
+		entry->object = object;
+		*lock = &entry->lock;
+	}
+	else {
+		reference = 0;
 	}
 	write_unlock_bh(&ref_table_lock);
+
 	return reference;
 }
 
@@ -200,20 +223,17 @@ void tipc_ref_discard(u32 ref)
 	u32 index;
 	u32 index_mask;
 
-	if (!ref) {
-		err("Attempt to discard reference 0\n");
-		return;
-	}
 	if (!tipc_ref_table.entries) {
 		err("Reference table not found during discard attempt\n");
 		return;
 	}
 
-	write_lock_bh(&ref_table_lock);
 	index_mask = tipc_ref_table.index_mask;
 	index = ref & index_mask;
 	entry = &(tipc_ref_table.entries[index]);
 
+	write_lock_bh(&ref_table_lock);
+
 	if (!entry->object) {
 		err("Attempt to discard reference to non-existent object\n");
 		goto exit;
@@ -223,18 +243,23 @@ void tipc_ref_discard(u32 ref)
 		goto exit;
 	}
 
-	/* mark entry as unused */
+	/*
+	 * mark entry as unused; increment upper bits of entry's data field
+	 * to invalidate any subsequent references
+	 */
+
 	entry->object = NULL;
+	entry->data.next_plus_upper = (ref & ~index_mask) + (index_mask + 1);
+
+	/* append entry to free entry list */
+
 	if (tipc_ref_table.first_free == 0)
 		tipc_ref_table.first_free = index;
 	else
-		/* next_plus_upper is always XXXX|0--0 for last free entry */
 		tipc_ref_table.entries[tipc_ref_table.last_free].
 			data.next_plus_upper |= index;
 	tipc_ref_table.last_free = index;
 
-	/* increment upper bits of entry to invalidate subsequent references */
-	entry->data.next_plus_upper = (ref & ~index_mask) + (index_mask + 1);
 exit:
 	write_unlock_bh(&ref_table_lock);
 }
@@ -249,10 +274,13 @@ void *tipc_ref_lock(u32 ref)
 		struct reference *r;
 
 		r = &tipc_ref_table.entries[ref & tipc_ref_table.index_mask];
-		spin_lock_bh(&r->lock);
-		if (likely(r->data.reference == ref))
-			return r->object;
-		spin_unlock_bh(&r->lock);
+
+		if (likely(r->data.reference != 0)) {
+			spin_lock_bh(&r->lock);
+			if (likely((r->data.reference == ref) && (r->object)))
+				return r->object;
+			spin_unlock_bh(&r->lock);
+		}
 	}
 	return NULL;
 }
@@ -267,11 +295,12 @@ void tipc_ref_unlock(u32 ref)
 		struct reference *r;
 
 		r = &tipc_ref_table.entries[ref & tipc_ref_table.index_mask];
-		if (likely(r->data.reference == ref))
+
+		if (likely((r->data.reference == ref) && (r->object)))
 			spin_unlock_bh(&r->lock);
 		else
 			err("tipc_ref_unlock() invoked using "
-			    "obsolete reference\n");
+			    "invalid reference\n");
 	}
 }
 
-- 
1.5.3.2

