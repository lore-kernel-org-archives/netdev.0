From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/3] flowcache: Avoid OOM condition under preasure
Date: Wed, 4 May 2016 07:40:52 +0200
Message-ID: <1462340454-27922-2-git-send-email-steffen.klassert@secunet.com>
References: <1462340454-27922-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:56686 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751155AbcEDFlK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2016 01:41:10 -0400
In-Reply-To: <1462340454-27922-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can hit an OOM condition if we are under presure because
we can not free the entries in gc_list fast enough. So add
a counter for the not yet freed entries in the gc_list and
refuse new allocations if the value is too high.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/netns/xfrm.h |  1 +
 net/core/flow.c          | 14 +++++++++++++-
 2 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
index 730d82a..24cd394 100644
--- a/include/net/netns/xfrm.h
+++ b/include/net/netns/xfrm.h
@@ -80,6 +80,7 @@ struct netns_xfrm {
 	struct flow_cache	flow_cache_global;
 	atomic_t		flow_cache_genid;
 	struct list_head	flow_cache_gc_list;
+	atomic_t		flow_cache_gc_count;
 	spinlock_t		flow_cache_gc_lock;
 	struct work_struct	flow_cache_gc_work;
 	struct work_struct	flow_cache_flush_work;
diff --git a/net/core/flow.c b/net/core/flow.c
index 1033725..3937b1b 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -92,8 +92,11 @@ static void flow_cache_gc_task(struct work_struct *work)
 	list_splice_tail_init(&xfrm->flow_cache_gc_list, &gc_list);
 	spin_unlock_bh(&xfrm->flow_cache_gc_lock);
 
-	list_for_each_entry_safe(fce, n, &gc_list, u.gc_list)
+	list_for_each_entry_safe(fce, n, &gc_list, u.gc_list) {
 		flow_entry_kill(fce, xfrm);
+		atomic_dec(&xfrm->flow_cache_gc_count);
+		WARN_ON(atomic_read(&xfrm->flow_cache_gc_count) < 0);
+	}
 }
 
 static void flow_cache_queue_garbage(struct flow_cache_percpu *fcp,
@@ -101,6 +104,7 @@ static void flow_cache_queue_garbage(struct flow_cache_percpu *fcp,
 				     struct netns_xfrm *xfrm)
 {
 	if (deleted) {
+		atomic_add(deleted, &xfrm->flow_cache_gc_count);
 		fcp->hash_count -= deleted;
 		spin_lock_bh(&xfrm->flow_cache_gc_lock);
 		list_splice_tail(gc_list, &xfrm->flow_cache_gc_list);
@@ -232,6 +236,13 @@ flow_cache_lookup(struct net *net, const struct flowi *key, u16 family, u8 dir,
 		if (fcp->hash_count > fc->high_watermark)
 			flow_cache_shrink(fc, fcp);
 
+		if (fcp->hash_count > 2 * fc->high_watermark ||
+		    atomic_read(&net->xfrm.flow_cache_gc_count) > fc->high_watermark) {
+			atomic_inc(&net->xfrm.flow_cache_genid);
+			flo = ERR_PTR(-ENOBUFS);
+			goto ret_object;
+		}
+
 		fle = kmem_cache_alloc(flow_cachep, GFP_ATOMIC);
 		if (fle) {
 			fle->net = net;
@@ -446,6 +457,7 @@ int flow_cache_init(struct net *net)
 	INIT_WORK(&net->xfrm.flow_cache_gc_work, flow_cache_gc_task);
 	INIT_WORK(&net->xfrm.flow_cache_flush_work, flow_cache_flush_task);
 	mutex_init(&net->xfrm.flow_flush_sem);
+	atomic_set(&net->xfrm.flow_cache_gc_count, 0);
 
 	fc->hash_shift = 10;
 	fc->low_watermark = 2 * flow_cache_hash_size(fc);
-- 
1.9.1
