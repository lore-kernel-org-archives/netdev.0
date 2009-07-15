From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: nf_conntrack_alloc() should not use kmem_cache_zalloc()
Date: Wed, 15 Jul 2009 14:28:44 +0200
Message-ID: <4A5DCB7C.9000502@gmail.com>
References: <20090707.191424.167842005.davem@davemloft.net>	<4A5441A0.3050504@gmail.com>	<4A5581C5.5070409@gmail.com> <20090711.202727.18146102.davem@davemloft.net> <4A598BAB.6030400@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com
To: David Miller <davem@davemloft.net>, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:33494 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754324AbZGOM26 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2009 08:28:58 -0400
In-Reply-To: <4A598BAB.6030400@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David, Patrick

Here is a fix for nf_conntrack, candidate for linux-2.6.31 and stable (linux-2.6.30)

Thank you

[PATCH] net: nf_conntrack_alloc() should not use kmem_cache_zalloc()

When a slab cache uses SLAB_DESTROY_BY_RCU, we must be careful when allocating
objects, since slab allocator could give a freed object still used by lockless
readers.

In particular, nf_conntrack RCU lookups rely on ct->tuplehash[xxx].hnnode.next
being always valid (ie containing a valid 'nulls' value, or a valid pointer to next
object in hash chain.)

kmem_cache_zalloc() setups object with NULL values, but a NULL value is not valid
for ct->tuplehash[xxx].hnnode.next.

Fix is to call kmem_cache_alloc() and do the zeroing ourself.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 7508f11..23feafa 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -561,17 +561,28 @@ struct nf_conn *nf_conntrack_alloc(struct net *net,
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
 	atomic_set(&ct->ct_general.use, 1);
 	ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple = *orig;
+	ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode.pprev = NULL;
 	ct->tuplehash[IP_CT_DIR_REPLY].tuple = *repl;
+	ct->tuplehash[IP_CT_DIR_REPLY].hnnode.pprev = NULL;
 	/* Don't set timer yet: wait for confirmation */
 	setup_timer(&ct->timeout, death_by_timeout, (unsigned long)ct);
 #ifdef CONFIG_NET_NS

