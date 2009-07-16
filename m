From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 03/03: nf_conntrack: nf_conntrack_alloc() fixes
Date: Thu, 16 Jul 2009 14:26:47 +0200 (MEST)
Message-ID: <20090716122642.23343.83669.sendpatchset@x2.localnet>
References: <20090716122638.23343.77832.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55088 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755894AbZGPM0s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 08:26:48 -0400
In-Reply-To: <20090716122638.23343.77832.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 941297f443f871b8c3372feccf27a8733f6ce9e9
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Thu Jul 16 14:03:40 2009 +0200

    netfilter: nf_conntrack: nf_conntrack_alloc() fixes
    
    When a slab cache uses SLAB_DESTROY_BY_RCU, we must be careful when allocating
    objects, since slab allocator could give a freed object still used by lockless
    readers.
    
    In particular, nf_conntrack RCU lookups rely on ct->tuplehash[xxx].hnnode.next
    being always valid (ie containing a valid 'nulls' value, or a valid pointer to next
    object in hash chain.)
    
    kmem_cache_zalloc() setups object with NULL values, but a NULL value is not valid
    for ct->tuplehash[xxx].hnnode.next.
    
    Fix is to call kmem_cache_alloc() and do the zeroing ourself.
    
    As spotted by Patrick, we also need to make sure lookup keys are committed to
    memory before setting refcount to 1, or a lockless reader could get a reference
    on the old version of the object. Its key re-check could then pass the barrier.
    
    Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/Documentation/RCU/rculist_nulls.txt b/Documentation/RCU/rculist_nulls.txt
index 93cb28d..18f9651 100644
--- a/Documentation/RCU/rculist_nulls.txt
+++ b/Documentation/RCU/rculist_nulls.txt
@@ -83,11 +83,12 @@ not detect it missed following items in original chain.
 obj = kmem_cache_alloc(...);
 lock_chain(); // typically a spin_lock()
 obj->key = key;
-atomic_inc(&obj->refcnt);
 /*
  * we need to make sure obj->key is updated before obj->next
+ * or obj->refcnt
  */
 smp_wmb();
+atomic_set(&obj->refcnt, 1);
 hlist_add_head_rcu(&obj->obj_node, list);
 unlock_chain(); // typically a spin_unlock()
 
@@ -159,6 +160,10 @@ out:
 obj = kmem_cache_alloc(cachep);
 lock_chain(); // typically a spin_lock()
 obj->key = key;
+/*
+ * changes to obj->key must be visible before refcnt one
+ */
+smp_wmb();
 atomic_set(&obj->refcnt, 1);
 /*
  * insert obj in RCU way (readers might be traversing chain)
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 7508f11..b5869b9 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -561,23 +561,38 @@ struct nf_conn *nf_conntrack_alloc(struct net *net,
 		}
 	}
 
-	ct = kmem_cache_zalloc(nf_conntrack_cachep, gfp);
+	/*
+	 * Do not use kmem_cache_zalloc(), as this cache uses
+	 * SLAB_DESTROY_BY_RCU.
+	 */
+	ct = kmem_cache_alloc(nf_conntrack_cachep, gfp);
 	if (ct == NULL) {
 		pr_debug("nf_conntrack_alloc: Can't alloc conntrack.\n");
 		atomic_dec(&net->ct.count);
 		return ERR_PTR(-ENOMEM);
 	}
-
+	/*
+	 * Let ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode.next
+	 * and ct->tuplehash[IP_CT_DIR_REPLY].hnnode.next unchanged.
+	 */
+	memset(&ct->tuplehash[IP_CT_DIR_MAX], 0,
+	       sizeof(*ct) - offsetof(struct nf_conn, tuplehash[IP_CT_DIR_MAX]));
 	spin_lock_init(&ct->lock);
-	atomic_set(&ct->ct_general.use, 1);
 	ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple = *orig;
+	ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode.pprev = NULL;
 	ct->tuplehash[IP_CT_DIR_REPLY].tuple = *repl;
+	ct->tuplehash[IP_CT_DIR_REPLY].hnnode.pprev = NULL;
 	/* Don't set timer yet: wait for confirmation */
 	setup_timer(&ct->timeout, death_by_timeout, (unsigned long)ct);
 #ifdef CONFIG_NET_NS
 	ct->ct_net = net;
 #endif
 
+	/*
+	 * changes to lookup keys must be done before setting refcnt to 1
+	 */
+	smp_wmb();
+	atomic_set(&ct->ct_general.use, 1);
 	return ct;
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_alloc);
