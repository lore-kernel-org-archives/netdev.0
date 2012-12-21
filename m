From: Eric Dumazet <erdnetdev@gmail.com>
Subject: [PATCH] tuntap: dont use a private kmem_cache
Date: Fri, 21 Dec 2012 09:17:21 -0800
Message-ID: <1356110241.21834.7530.camel@edumazet-glaptop>
References: <4151394.nMo40zlg68@sifl>
	 <1356046697.21834.3606.camel@edumazet-glaptop>  <2090364.S7KStA6R4d@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jason Wang <jasowang@redhat.com>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Paul Moore <pmoore@redhat.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:51345 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750983Ab2LURRY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2012 12:17:24 -0500
Received: by mail-pb0-f48.google.com with SMTP id rq13so2875855pbb.7
        for <netdev@vger.kernel.org>; Fri, 21 Dec 2012 09:17:24 -0800 (PST)
In-Reply-To: <2090364.S7KStA6R4d@sifl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Commit 96442e42429 (tuntap: choose the txq based on rxq)
added a per tun_struct kmem_cache.

As soon as several tun_struct are used, we get an error
because two caches cannot have same name.

Use the default kmalloc()/kfree_rcu(), as it reduce code
size and doesn't have performance impact here.

Reported-by: Paul Moore <pmoore@redhat.com>
Tested-by: Paul Moore <pmoore@redhat.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Acked-by: Stephen Hemminger <shemminger@vyatta.com>
Acked-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tun.c |   24 +++---------------------
 1 file changed, 3 insertions(+), 21 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 504f7f1..fbd106e 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -180,7 +180,6 @@ struct tun_struct {
 	int debug;
 #endif
 	spinlock_t lock;
-	struct kmem_cache *flow_cache;
 	struct hlist_head flows[TUN_NUM_FLOW_ENTRIES];
 	struct timer_list flow_gc_timer;
 	unsigned long ageing_time;
@@ -209,8 +208,8 @@ static struct tun_flow_entry *tun_flow_create(struct tun_struct *tun,
 					      struct hlist_head *head,
 					      u32 rxhash, u16 queue_index)
 {
-	struct tun_flow_entry *e = kmem_cache_alloc(tun->flow_cache,
-						    GFP_ATOMIC);
+	struct tun_flow_entry *e = kmalloc(sizeof(*e), GFP_ATOMIC);
+
 	if (e) {
 		tun_debug(KERN_INFO, tun, "create flow: hash %u index %u\n",
 			  rxhash, queue_index);
@@ -223,19 +222,12 @@ static struct tun_flow_entry *tun_flow_create(struct tun_struct *tun,
 	return e;
 }
 
-static void tun_flow_free(struct rcu_head *head)
-{
-	struct tun_flow_entry *e
-		= container_of(head, struct tun_flow_entry, rcu);
-	kmem_cache_free(e->tun->flow_cache, e);
-}
-
 static void tun_flow_delete(struct tun_struct *tun, struct tun_flow_entry *e)
 {
 	tun_debug(KERN_INFO, tun, "delete flow: hash %u index %u\n",
 		  e->rxhash, e->queue_index);
 	hlist_del_rcu(&e->hash_link);
-	call_rcu(&e->rcu, tun_flow_free);
+	kfree_rcu(e, rcu);
 }
 
 static void tun_flow_flush(struct tun_struct *tun)
@@ -833,12 +825,6 @@ static int tun_flow_init(struct tun_struct *tun)
 {
 	int i;
 
-	tun->flow_cache = kmem_cache_create("tun_flow_cache",
-					    sizeof(struct tun_flow_entry), 0, 0,
-					    NULL);
-	if (!tun->flow_cache)
-		return -ENOMEM;
-
 	for (i = 0; i < TUN_NUM_FLOW_ENTRIES; i++)
 		INIT_HLIST_HEAD(&tun->flows[i]);
 
@@ -854,10 +840,6 @@ static void tun_flow_uninit(struct tun_struct *tun)
 {
 	del_timer_sync(&tun->flow_gc_timer);
 	tun_flow_flush(tun);
-
-	/* Wait for completion of call_rcu()'s */
-	rcu_barrier();
-	kmem_cache_destroy(tun->flow_cache);
 }
 
 /* Initialize net device. */
