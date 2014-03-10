From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] flowcache: restore a single flow_cache kmem_cache
Date: Mon, 10 Mar 2014 07:09:07 -0700
Message-ID: <1394460547.3607.14.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140310014452.144b0491@north>
	 <1394424146.3607.2.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1394424557.3607.4.camel@edumazet-glaptop2.roam.corp.google.com>
	 <531D60EF.9000501@windriver.com>
	 <1394459069.3607.8.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jakub Kicinski <moorray3@wp.pl>, netdev@vger.kernel.org,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:53529 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753300AbaCJORE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 10:17:04 -0400
Received: by mail-pb0-f49.google.com with SMTP id jt11so7290580pbb.22
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 07:17:04 -0700 (PDT)
In-Reply-To: <1394459069.3607.8.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

It is not legal to create multiple kmem_cache having the same name.

flowcache can use a single kmem_cache, no need for a per netns
one.

Fixes: ca925cf1534e ("flowcache: Make flow cache name space aware")
Reported-by: Jakub Kicinski <moorray3@wp.pl>
Tested-by: Jakub Kicinski <moorray3@wp.pl>
Tested-by: Fan Du <fan.du@windriver.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/netns/xfrm.h |    1 -
 net/core/flow.c          |   14 ++++++++------
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
index 51f0dce7b643..3492434baf88 100644
--- a/include/net/netns/xfrm.h
+++ b/include/net/netns/xfrm.h
@@ -64,7 +64,6 @@ struct netns_xfrm {
 
 	/* flow cache part */
 	struct flow_cache	flow_cache_global;
-	struct kmem_cache	*flow_cachep;
 	atomic_t		flow_cache_genid;
 	struct list_head	flow_cache_gc_list;
 	spinlock_t		flow_cache_gc_lock;
diff --git a/net/core/flow.c b/net/core/flow.c
index 344a184011fd..102f8ea2eb6e 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -45,6 +45,8 @@ struct flow_flush_info {
 	struct completion		completion;
 };
 
+static struct kmem_cache *flow_cachep __read_mostly;
+
 #define flow_cache_hash_size(cache)	(1 << (cache)->hash_shift)
 #define FLOW_HASH_RND_PERIOD		(10 * 60 * HZ)
 
@@ -75,7 +77,7 @@ static void flow_entry_kill(struct flow_cache_entry *fle,
 {
 	if (fle->object)
 		fle->object->ops->delete(fle->object);
-	kmem_cache_free(xfrm->flow_cachep, fle);
+	kmem_cache_free(flow_cachep, fle);
 }
 
 static void flow_cache_gc_task(struct work_struct *work)
@@ -230,7 +232,7 @@ flow_cache_lookup(struct net *net, const struct flowi *key, u16 family, u8 dir,
 		if (fcp->hash_count > fc->high_watermark)
 			flow_cache_shrink(fc, fcp);
 
-		fle = kmem_cache_alloc(net->xfrm.flow_cachep, GFP_ATOMIC);
+		fle = kmem_cache_alloc(flow_cachep, GFP_ATOMIC);
 		if (fle) {
 			fle->net = net;
 			fle->family = family;
@@ -435,10 +437,10 @@ int flow_cache_init(struct net *net)
 	int i;
 	struct flow_cache *fc = &net->xfrm.flow_cache_global;
 
-	/* Initialize per-net flow cache global variables here */
-	net->xfrm.flow_cachep = kmem_cache_create("flow_cache",
-					sizeof(struct flow_cache_entry),
-					0, SLAB_PANIC, NULL);
+	if (!flow_cachep)
+		flow_cachep = kmem_cache_create("flow_cache",
+						sizeof(struct flow_cache_entry),
+						0, SLAB_PANIC, NULL);
 	spin_lock_init(&net->xfrm.flow_cache_gc_lock);
 	INIT_LIST_HEAD(&net->xfrm.flow_cache_gc_list);
 	INIT_WORK(&net->xfrm.flow_cache_gc_work, flow_cache_gc_task);
