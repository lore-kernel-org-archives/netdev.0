From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH v2 3/3] flowcache: more "unsigned int"
Date: Mon, 3 Apr 2017 00:53:15 +0300
Message-ID: <20170402215315.GC8938@avx2>
References: <20170402215150.GA8938@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
        netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:34120 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750953AbdDBVxT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 2 Apr 2017 17:53:19 -0400
Received: by mail-lf0-f66.google.com with SMTP id x137so11433290lff.1
        for <netdev@vger.kernel.org>; Sun, 02 Apr 2017 14:53:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170402215150.GA8938@avx2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make ->hash_count, ->low_watermark and ->high_watermark unsigned int
and propagate unsignedness to other variables.

This change doesn't change code generation because these fields aren't
used in 64-bit contexts but make it anyway: these fields can't be
negative numbers.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/flowcache.h |    6 +++---
 net/core/flow.c         |   13 +++++++------
 2 files changed, 10 insertions(+), 9 deletions(-)

--- a/include/net/flowcache.h
+++ b/include/net/flowcache.h
@@ -8,7 +8,7 @@
 
 struct flow_cache_percpu {
 	struct hlist_head		*hash_table;
-	int				hash_count;
+	unsigned int			hash_count;
 	u32				hash_rnd;
 	int				hash_rnd_recalc;
 	struct tasklet_struct		flush_tasklet;
@@ -18,8 +18,8 @@ struct flow_cache {
 	u32				hash_shift;
 	struct flow_cache_percpu __percpu *percpu;
 	struct hlist_node		node;
-	int				low_watermark;
-	int				high_watermark;
+	unsigned int			low_watermark;
+	unsigned int			high_watermark;
 	struct timer_list		rnd_timer;
 };
 #endif	/* _NET_FLOWCACHE_H */
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -99,7 +99,8 @@ static void flow_cache_gc_task(struct work_struct *work)
 }
 
 static void flow_cache_queue_garbage(struct flow_cache_percpu *fcp,
-				     int deleted, struct list_head *gc_list,
+				     unsigned int deleted,
+				     struct list_head *gc_list,
 				     struct netns_xfrm *xfrm)
 {
 	if (deleted) {
@@ -114,18 +115,18 @@ static void flow_cache_queue_garbage(struct flow_cache_percpu *fcp,
 
 static void __flow_cache_shrink(struct flow_cache *fc,
 				struct flow_cache_percpu *fcp,
-				int shrink_to)
+				unsigned int shrink_to)
 {
 	struct flow_cache_entry *fle;
 	struct hlist_node *tmp;
 	LIST_HEAD(gc_list);
-	int deleted = 0;
+	unsigned int deleted = 0;
 	struct netns_xfrm *xfrm = container_of(fc, struct netns_xfrm,
 						flow_cache_global);
 	unsigned int i;
 
 	for (i = 0; i < flow_cache_hash_size(fc); i++) {
-		int saved = 0;
+		unsigned int saved = 0;
 
 		hlist_for_each_entry_safe(fle, tmp,
 					  &fcp->hash_table[i], u.hlist) {
@@ -146,7 +147,7 @@ static void __flow_cache_shrink(struct flow_cache *fc,
 static void flow_cache_shrink(struct flow_cache *fc,
 			      struct flow_cache_percpu *fcp)
 {
-	int shrink_to = fc->low_watermark / flow_cache_hash_size(fc);
+	unsigned int shrink_to = fc->low_watermark / flow_cache_hash_size(fc);
 
 	__flow_cache_shrink(fc, fcp, shrink_to);
 }
@@ -296,7 +297,7 @@ static void flow_cache_flush_tasklet(unsigned long data)
 	struct flow_cache_entry *fle;
 	struct hlist_node *tmp;
 	LIST_HEAD(gc_list);
-	int deleted = 0;
+	unsigned int deleted = 0;
 	struct netns_xfrm *xfrm = container_of(fc, struct netns_xfrm,
 						flow_cache_global);
 	unsigned int i;
