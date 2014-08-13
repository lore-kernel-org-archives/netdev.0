From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/4] rhashtable: RCU annotations for next pointers
Date: Wed, 13 Aug 2014 16:38:29 +0200
Message-ID: <312783ea71fab009fd2e837a4361250ba8e57872.1407939963.git.tgraf@suug.ch>
References: <cover.1407939963.git.tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:54739 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751749AbaHMOih (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2014 10:38:37 -0400
Received: from 77-56-195-25.dclient.hispeed.ch ([77.56.195.25] helo=lsx.localdomain)
	by bombadil.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XHZhF-00056M-A2
	for netdev@vger.kernel.org; Wed, 13 Aug 2014 14:38:37 +0000
In-Reply-To: <cover.1407939963.git.tgraf@suug.ch>
In-Reply-To: <cover.1407939963.git.tgraf@suug.ch>
References: <cover.1407939963.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Properly annotate next pointers as access is RCU protected in
the lookup path.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/linux/rhashtable.h | 4 ++--
 lib/rhashtable.c           | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index 9cda293..8c6048e 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -21,7 +21,7 @@
 #include <linux/rculist.h>
 
 struct rhash_head {
-	struct rhash_head		*next;
+	struct rhash_head __rcu		*next;
 };
 
 #define INIT_HASH_HEAD(ptr) ((ptr)->next = NULL)
@@ -97,7 +97,7 @@ u32 rhashtable_obj_hashfn(const struct rhashtable *ht, void *ptr);
 void rhashtable_insert(struct rhashtable *ht, struct rhash_head *node, gfp_t);
 bool rhashtable_remove(struct rhashtable *ht, struct rhash_head *node, gfp_t);
 void rhashtable_remove_pprev(struct rhashtable *ht, struct rhash_head *obj,
-			     struct rhash_head **pprev, gfp_t flags);
+			     struct rhash_head __rcu **pprev, gfp_t flags);
 
 bool rht_grow_above_75(const struct rhashtable *ht, size_t new_size);
 bool rht_shrink_below_30(const struct rhashtable *ht, size_t new_size);
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index e6940cf..338dd7a 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -386,7 +386,7 @@ EXPORT_SYMBOL_GPL(rhashtable_insert);
  * deletion when combined with walking or lookup.
  */
 void rhashtable_remove_pprev(struct rhashtable *ht, struct rhash_head *obj,
-			     struct rhash_head **pprev, gfp_t flags)
+			     struct rhash_head __rcu **pprev, gfp_t flags)
 {
 	struct bucket_table *tbl = rht_dereference(ht->tbl, ht);
 
-- 
1.9.3
