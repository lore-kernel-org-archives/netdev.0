From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 3/7 net-2.6.26] [TIPC]: Cleanup of TIPC reference table code
Date: Tue, 15 Apr 2008 15:43:53 -0400
Message-ID: <1208288637-15304-4-git-send-email-allan.stephens@windriver.com>
References: <1208288637-15304-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:46948 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756125AbYDOTpx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 15:45:53 -0400
In-Reply-To: <1208288637-15304-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is a largely cosmetic cleanup of the TIPC reference
table code.  Variable naming has been made more consistent,
useless #includes have been eliminated, and the object reference
field in each table entry is no longer implemented using an
unnecessary structure union.  In addition, error checking has
been enhanced to detect accidental access to reference table
entries that are on the free list.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/ref.c |   80 +++++++++++++++++++++++--------------------------------
 1 files changed, 34 insertions(+), 46 deletions(-)

diff --git a/net/tipc/ref.c b/net/tipc/ref.c
index 75cfb8d..b7ef559 100644
--- a/net/tipc/ref.c
+++ b/net/tipc/ref.c
@@ -36,30 +36,18 @@
 
 #include "core.h"
 #include "ref.h"
-#include "port.h"
-#include "subscr.h"
-#include "name_distr.h"
-#include "name_table.h"
-#include "config.h"
-#include "discover.h"
-#include "bearer.h"
-#include "node.h"
-#include "bcast.h"
 
 /**
  * struct reference - TIPC object reference entry
  * @object: pointer to object associated with reference entry
  * @lock: spinlock controlling access to object
- * @data: reference value for object (combines instance & array index info)
+ * @ref: reference value for object (combines instance & array index info)
  */
 
 struct reference {
 	void *object;
 	spinlock_t lock;
-	union {
-		u32 next_plus_upper;
-		u32 reference;
-	} data;
+	u32 ref;
 };
 
 /**
@@ -163,7 +151,7 @@ u32 tipc_ref_acquire(void *object, spinlock_t **lock)
 	u32 index;
 	u32 index_mask;
 	u32 next_plus_upper;
-	u32 reference;
+	u32 ref;
 
 	if (unlikely(object == NULL)) {
 		err("Attempt to acquire reference to non-existent object\n");
@@ -183,10 +171,10 @@ u32 tipc_ref_acquire(void *object, spinlock_t **lock)
 		index_mask = tipc_ref_table.index_mask;
 		/* take lock in case a previous user of entry still holds it */
 		spin_lock_bh(&entry->lock);
-		next_plus_upper = entry->data.next_plus_upper;
+		next_plus_upper = entry->ref;
 		tipc_ref_table.first_free = next_plus_upper & index_mask;
-		reference = (next_plus_upper & ~index_mask) + index;
-		entry->data.reference = reference;
+		ref = (next_plus_upper & ~index_mask) + index;
+		entry->ref = ref;
 		entry->object = object;
 		spin_unlock_bh(&entry->lock);
 		*lock = &entry->lock;
@@ -195,17 +183,17 @@ u32 tipc_ref_acquire(void *object, spinlock_t **lock)
 		index = tipc_ref_table.init_point++;
 		entry = &(tipc_ref_table.entries[index]);
 		spin_lock_init(&entry->lock);
-		reference = tipc_ref_table.start_mask + index;
-		entry->data.reference = reference;
+		ref = tipc_ref_table.start_mask + index;
+		entry->ref = ref;
 		entry->object = object;
 		*lock = &entry->lock;
 	}
 	else {
-		reference = 0;
+		ref = 0;
 	}
 	write_unlock_bh(&ref_table_lock);
 
-	return reference;
+	return ref;
 }
 
 /**
@@ -236,26 +224,25 @@ void tipc_ref_discard(u32 ref)
 		err("Attempt to discard reference to non-existent object\n");
 		goto exit;
 	}
-	if (unlikely(entry->data.reference != ref)) {
+	if (unlikely(entry->ref != ref)) {
 		err("Attempt to discard non-existent reference\n");
 		goto exit;
 	}
 
 	/*
-	 * mark entry as unused; increment upper bits of entry's data field
+	 * mark entry as unused; increment instance part of entry's reference
 	 * to invalidate any subsequent references
 	 */
 
 	entry->object = NULL;
-	entry->data.next_plus_upper = (ref & ~index_mask) + (index_mask + 1);
+	entry->ref = (ref & ~index_mask) + (index_mask + 1);
 
 	/* append entry to free entry list */
 
 	if (tipc_ref_table.first_free == 0)
 		tipc_ref_table.first_free = index;
 	else
-		tipc_ref_table.entries[tipc_ref_table.last_free].
-			data.next_plus_upper |= index;
+		tipc_ref_table.entries[tipc_ref_table.last_free].ref |= index;
 	tipc_ref_table.last_free = index;
 
 exit:
@@ -269,15 +256,16 @@ exit:
 void *tipc_ref_lock(u32 ref)
 {
 	if (likely(tipc_ref_table.entries != NULL)) {
-		struct reference *r;
-
-		r = &tipc_ref_table.entries[ref & tipc_ref_table.index_mask];
-
-		if (likely(r->data.reference != 0)) {
-			spin_lock_bh(&r->lock);
-			if (likely(r->data.reference == ref))
-				return r->object;
-			spin_unlock_bh(&r->lock);
+		struct reference *entry;
+
+		entry = &tipc_ref_table.entries[ref &
+						tipc_ref_table.index_mask];
+		if (likely(entry->ref != 0)) {
+			spin_lock_bh(&entry->lock);
+			if (likely((entry->ref == ref) &&
+				   (entry->object != NULL)))
+				return entry->object;
+			spin_unlock_bh(&entry->lock);
 		}
 	}
 	return NULL;
@@ -290,13 +278,12 @@ void *tipc_ref_lock(u32 ref)
 void tipc_ref_unlock(u32 ref)
 {
 	if (likely(tipc_ref_table.entries != NULL)) {
-		struct reference *r;
-
-		r = &tipc_ref_table.entries[ref & tipc_ref_table.index_mask];
+		struct reference *entry;
 
-		if (likely((r->data.reference == ref) &&
-			   (r->data.reference != 0)))
-			spin_unlock_bh(&r->lock);
+		entry = &tipc_ref_table.entries[ref &
+						tipc_ref_table.index_mask];
+		if (likely((entry->ref == ref) && (entry->object != NULL)))
+			spin_unlock_bh(&entry->lock);
 		else
 			err("tipc_ref_unlock() invoked using "
 			    "invalid reference\n");
@@ -310,11 +297,12 @@ void tipc_ref_unlock(u32 ref)
 void *tipc_ref_deref(u32 ref)
 {
 	if (likely(tipc_ref_table.entries != NULL)) {
-		struct reference *r;
+		struct reference *entry;
 
-		r = &tipc_ref_table.entries[ref & tipc_ref_table.index_mask];
-		if (likely(r->data.reference == ref))
-			return r->object;
+		entry = &tipc_ref_table.entries[ref &
+						tipc_ref_table.index_mask];
+		if (likely(entry->ref == ref))
+			return entry->object;
 	}
 	return NULL;
 }
-- 
1.5.3.2

