From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TUN problems (regression?)
Date: Thu, 20 Dec 2012 15:38:17 -0800
Message-ID: <1356046697.21834.3606.camel@edumazet-glaptop>
References: <4151394.nMo40zlg68@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jason Wang <jasowang@redhat.com>, netdev@vger.kernel.org
To: Paul Moore <pmoore@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:54309 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751805Ab2LTXnx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2012 18:43:53 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so2306187pbc.5
        for <netdev@vger.kernel.org>; Thu, 20 Dec 2012 15:43:53 -0800 (PST)
In-Reply-To: <4151394.nMo40zlg68@sifl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-12-20 at 18:16 -0500, Paul Moore wrote:
> [CC'ing netdev in case this is a known problem I just missed ...]
> 
> Hi Jason,
> 
> I started doing some more testing with the multiqueue TUN changes and I ran 
> into a problem when running tunctl: running it once w/o arguments works as 
> expected, but running it a second time results in failure and a 
> kmem_cache_sanity_check() failure.  The problem appears to be very repeatable 
> on my test VM and happens independent of the LSM/SELinux fixup patches.
> 
> Have you seen this before?
> 

Obviously code in tun_flow_init() is wrong...

static int tun_flow_init(struct tun_struct *tun)
{
        int i;

        tun->flow_cache = kmem_cache_create("tun_flow_cache",
                                            sizeof(struct tun_flow_entry), 0, 0,
                                            NULL);
        if (!tun->flow_cache)
                return -ENOMEM;
...
}


I have no idea why we would need a kmem_cache per tun_struct,
and why we even need a kmem_cache.


I would try following patch :

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
