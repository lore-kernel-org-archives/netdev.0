From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/3] rhashtable: Provide notifier for deferred resizes
Date: Tue, 20 Jan 2015 14:20:25 +0100
Message-ID: <1a7fba3c718fb70f0f5d67c9c49e4c154ebcd915.1421759056.git.tgraf@suug.ch>
References: <cover.1421759056.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: davem@davemloft.net, kaber@trash.net, herbert@gondor.apana.org.au,
	paulmck@linux.vnet.ibm.com, ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:49252 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755090AbbATNUh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 08:20:37 -0500
In-Reply-To: <cover.1421759056.git.tgraf@suug.ch>
In-Reply-To: <cover.1421759056.git.tgraf@suug.ch>
References: <cover.1421759056.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allowing users of rhashtable to bump a sequence counter and invalidate
Netlink dumps which have been interrupted by a deferred resize.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/linux/rhashtable.h | 10 +++++++++-
 lib/rhashtable.c           | 13 ++++++++++---
 2 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index a2562ed..b711d16 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -1,7 +1,7 @@
 /*
  * Resizable, Scalable, Concurrent Hash Table
  *
- * Copyright (c) 2014 Thomas Graf <tgraf@suug.ch>
+ * Copyright (c) 2014-2015 Thomas Graf <tgraf@suug.ch>
  * Copyright (c) 2008-2014 Patrick McHardy <kaber@trash.net>
  *
  * Based on the following paper by Josh Triplett, Paul E. McKenney
@@ -64,6 +64,11 @@ typedef u32 (*rht_obj_hashfn_t)(const void *data, u32 seed);
 
 struct rhashtable;
 
+enum rht_resize_op {
+	RHT_GROWING,
+	RHT_SHRINKING,
+};
+
 /**
  * struct rhashtable_params - Hash table construction parameters
  * @nelem_hint: Hint on number of elements, should be 75% of desired size
@@ -79,6 +84,7 @@ struct rhashtable;
  * @obj_hashfn: Function to hash object
  * @grow_decision: If defined, may return true if table should expand
  * @shrink_decision: If defined, may return true if table should shrink
+ * @resize_notify: Called when a table resize is scheduled.
  *
  * Note: when implementing the grow and shrink decision function, min/max
  * shift must be enforced, otherwise, resizing watermarks they set may be
@@ -100,6 +106,8 @@ struct rhashtable_params {
 						 size_t new_size);
 	bool			(*shrink_decision)(const struct rhashtable *ht,
 						   size_t new_size);
+	void			(*resize_notify)(const struct rhashtable *ht,
+						 enum rht_resize_op op);
 };
 
 /**
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 84a78e3..a4449c4 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -1,7 +1,7 @@
 /*
  * Resizable, Scalable, Concurrent Hash Table
  *
- * Copyright (c) 2014 Thomas Graf <tgraf@suug.ch>
+ * Copyright (c) 2014-2015 Thomas Graf <tgraf@suug.ch>
  * Copyright (c) 2008-2014 Patrick McHardy <kaber@trash.net>
  *
  * Based on the following paper:
@@ -489,10 +489,17 @@ static void rht_deferred_worker(struct work_struct *work)
 	mutex_lock(&ht->mutex);
 	tbl = rht_dereference(ht->tbl, ht);
 
-	if (ht->p.grow_decision && ht->p.grow_decision(ht, tbl->size))
+	if (ht->p.grow_decision && ht->p.grow_decision(ht, tbl->size)) {
+		if (ht->p.resize_notify)
+			ht->p.resize_notify(ht, RHT_GROWING);
+
 		rhashtable_expand(ht);
-	else if (ht->p.shrink_decision && ht->p.shrink_decision(ht, tbl->size))
+	} else if (ht->p.shrink_decision && ht->p.shrink_decision(ht, tbl->size)) {
+		if (ht->p.resize_notify)
+			ht->p.resize_notify(ht, RHT_SHRINKING);
+
 		rhashtable_shrink(ht);
+	}
 
 	mutex_unlock(&ht->mutex);
 }
-- 
1.9.3
