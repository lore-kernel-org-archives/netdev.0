From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 1/7 net-2.6.26] [TIPC]: Remove inlining of reference table locking routines
Date: Tue, 15 Apr 2008 15:43:51 -0400
Message-ID: <1208288637-15304-2-git-send-email-allan.stephens@windriver.com>
References: <1208288637-15304-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:46923 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754958AbYDOTpw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 15:45:52 -0400
In-Reply-To: <1208288637-15304-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch converts the TIPC reference table locking routines
into non-inlined routines, since they are mainly called from
non-performance critical areas of TIPC and the added code
footprint incurred through inlining can no longer be justified.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/ref.c |  101 +++++++++++++++++++++++++++++++++++++++++++++++++++-----
 net/tipc/ref.h |   89 ++-----------------------------------------------
 2 files changed, 96 insertions(+), 94 deletions(-)

diff --git a/net/tipc/ref.c b/net/tipc/ref.c
index c38744c..9c2eb9b 100644
--- a/net/tipc/ref.c
+++ b/net/tipc/ref.c
@@ -2,7 +2,7 @@
  * net/tipc/ref.c: TIPC object registry code
  *
  * Copyright (c) 1991-2006, Ericsson AB
- * Copyright (c) 2004-2005, Wind River Systems
+ * Copyright (c) 2004-2007, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -46,6 +46,37 @@
 #include "node.h"
 #include "bcast.h"
 
+/**
+ * struct reference - TIPC object reference entry
+ * @object: pointer to object associated with reference entry
+ * @lock: spinlock controlling access to object
+ * @data: reference value associated with object (or link to next unused entry)
+ */
+
+struct reference {
+	void *object;
+	spinlock_t lock;
+	union {
+		u32 next_plus_upper;
+		u32 reference;
+	} data;
+};
+
+/**
+ * struct tipc_ref_table - table of TIPC object reference entries
+ * @entries: pointer to array of reference entries
+ * @index_mask: bitmask for array index portion of reference values
+ * @first_free: array index of first unused object reference entry
+ * @last_free: array index of last unused object reference entry
+ */
+
+struct ref_table {
+	struct reference *entries;
+	u32 index_mask;
+	u32 first_free;
+	u32 last_free;
+};
+
 /*
  * Object reference table consists of 2**N entries.
  *
@@ -61,7 +92,7 @@
  * because entry 0's reference field has the form XXXX|1--1.
  */
 
-struct ref_table tipc_ref_table = { NULL };
+static struct ref_table tipc_ref_table = { NULL };
 
 static DEFINE_RWLOCK(ref_table_lock);
 
@@ -104,7 +135,7 @@ int tipc_ref_table_init(u32 requested_size, u32 start)
 
 void tipc_ref_table_stop(void)
 {
-	if (!tipc_ref_table.entries)
+	if (unlikely(tipc_ref_table.entries == NULL))
 		return;
 
 	vfree(tipc_ref_table.entries);
@@ -127,11 +158,11 @@ u32 tipc_ref_acquire(void *object, spinlock_t **lock)
 	u32 next_plus_upper;
 	u32 reference = 0;
 
-	if (!object) {
+	if (unlikely(object == NULL)) {
 		err("Attempt to acquire reference to non-existent object\n");
 		return 0;
 	}
-	if (!tipc_ref_table.entries) {
+	if (unlikely(tipc_ref_table.entries == NULL)) {
 		err("Reference table not found during acquisition attempt\n");
 		return 0;
 	}
@@ -173,7 +204,7 @@ void tipc_ref_discard(u32 ref)
 		err("Attempt to discard reference 0\n");
 		return;
 	}
-	if (!tipc_ref_table.entries) {
+	if (unlikely(tipc_ref_table.entries == NULL)) {
 		err("Reference table not found during discard attempt\n");
 		return;
 	}
@@ -183,7 +214,7 @@ void tipc_ref_discard(u32 ref)
 	index = ref & index_mask;
 	entry = &(tipc_ref_table.entries[index]);
 
-	if (!entry->object) {
+	if (unlikely(entry->object == NULL)) {
 		err("Attempt to discard reference to non-existent object\n");
 		goto exit;
 	}
@@ -198,8 +229,8 @@ void tipc_ref_discard(u32 ref)
 		tipc_ref_table.first_free = index;
 	else
 		/* next_plus_upper is always XXXX|0--0 for last free entry */
-		tipc_ref_table.entries[tipc_ref_table.last_free].data.next_plus_upper
-			|= index;
+		tipc_ref_table.entries[tipc_ref_table.last_free].
+			data.next_plus_upper |= index;
 	tipc_ref_table.last_free = index;
 
 	/* increment upper bits of entry to invalidate subsequent references */
@@ -208,3 +239,55 @@ exit:
 	write_unlock_bh(&ref_table_lock);
 }
 
+/**
+ * tipc_ref_lock - lock referenced object and return pointer to it
+ */
+
+void *tipc_ref_lock(u32 ref)
+{
+	if (likely(tipc_ref_table.entries != NULL)) {
+		struct reference *r;
+
+		r = &tipc_ref_table.entries[ref & tipc_ref_table.index_mask];
+		spin_lock_bh(&r->lock);
+		if (likely(r->data.reference == ref))
+			return r->object;
+		spin_unlock_bh(&r->lock);
+	}
+	return NULL;
+}
+
+/**
+ * tipc_ref_unlock - unlock referenced object
+ */
+
+void tipc_ref_unlock(u32 ref)
+{
+	if (likely(tipc_ref_table.entries != NULL)) {
+		struct reference *r;
+
+		r = &tipc_ref_table.entries[ref & tipc_ref_table.index_mask];
+		if (likely(r->data.reference == ref))
+			spin_unlock_bh(&r->lock);
+		else
+			err("tipc_ref_unlock() invoked using "
+			    "obsolete reference\n");
+	}
+}
+
+/**
+ * tipc_ref_deref - return pointer referenced object (without locking it)
+ */
+
+void *tipc_ref_deref(u32 ref)
+{
+	if (likely(tipc_ref_table.entries != NULL)) {
+		struct reference *r;
+
+		r = &tipc_ref_table.entries[ref & tipc_ref_table.index_mask];
+		if (likely(r->data.reference == ref))
+			return r->object;
+	}
+	return NULL;
+}
+
diff --git a/net/tipc/ref.h b/net/tipc/ref.h
index 38f3a7f..7e3798e 100644
--- a/net/tipc/ref.h
+++ b/net/tipc/ref.h
@@ -2,7 +2,7 @@
  * net/tipc/ref.h: Include file for TIPC object registry code
  *
  * Copyright (c) 1991-2006, Ericsson AB
- * Copyright (c) 2005, Wind River Systems
+ * Copyright (c) 2005-2006, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -37,95 +37,14 @@
 #ifndef _TIPC_REF_H
 #define _TIPC_REF_H
 
-/**
- * struct reference - TIPC object reference entry
- * @object: pointer to object associated with reference entry
- * @lock: spinlock controlling access to object
- * @data: reference value associated with object (or link to next unused entry)
- */
-
-struct reference {
-	void *object;
-	spinlock_t lock;
-	union {
-		u32 next_plus_upper;
-		u32 reference;
-	} data;
-};
-
-/**
- * struct tipc_ref_table - table of TIPC object reference entries
- * @entries: pointer to array of reference entries
- * @index_mask: bitmask for array index portion of reference values
- * @first_free: array index of first unused object reference entry
- * @last_free: array index of last unused object reference entry
- */
-
-struct ref_table {
-	struct reference *entries;
-	u32 index_mask;
-	u32 first_free;
-	u32 last_free;
-};
-
-extern struct ref_table tipc_ref_table;
-
 int tipc_ref_table_init(u32 requested_size, u32 start);
 void tipc_ref_table_stop(void);
 
 u32 tipc_ref_acquire(void *object, spinlock_t **lock);
 void tipc_ref_discard(u32 ref);
 
-
-/**
- * tipc_ref_lock - lock referenced object and return pointer to it
- */
-
-static inline void *tipc_ref_lock(u32 ref)
-{
-	if (likely(tipc_ref_table.entries)) {
-		struct reference *r =
-			&tipc_ref_table.entries[ref & tipc_ref_table.index_mask];
-
-		spin_lock_bh(&r->lock);
-		if (likely(r->data.reference == ref))
-			return r->object;
-		spin_unlock_bh(&r->lock);
-	}
-	return NULL;
-}
-
-/**
- * tipc_ref_unlock - unlock referenced object
- */
-
-static inline void tipc_ref_unlock(u32 ref)
-{
-	if (likely(tipc_ref_table.entries)) {
-		struct reference *r =
-			&tipc_ref_table.entries[ref & tipc_ref_table.index_mask];
-
-		if (likely(r->data.reference == ref))
-			spin_unlock_bh(&r->lock);
-		else
-			err("tipc_ref_unlock() invoked using obsolete reference\n");
-	}
-}
-
-/**
- * tipc_ref_deref - return pointer referenced object (without locking it)
- */
-
-static inline void *tipc_ref_deref(u32 ref)
-{
-	if (likely(tipc_ref_table.entries)) {
-		struct reference *r =
-			&tipc_ref_table.entries[ref & tipc_ref_table.index_mask];
-
-		if (likely(r->data.reference == ref))
-			return r->object;
-	}
-	return NULL;
-}
+void *tipc_ref_lock(u32 ref);
+void tipc_ref_unlock(u32 ref);
+void *tipc_ref_deref(u32 ref);
 
 #endif
-- 
1.5.3.2

