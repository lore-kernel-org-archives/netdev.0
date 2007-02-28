From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Run-time kfree check for correct cache [was Re: [NET]: Fix kfree(skb)]
Date: Wed, 28 Feb 2007 12:02:58 +0300
Message-ID: <20070228090258.GA28336@2ka.mipt.ru>
References: <20070227.100052.59655152.davem@davemloft.net> <20070227181425.GA26886@2ka.mipt.ru> <20070227182001.GA4278@2ka.mipt.ru> <20070227.102452.102574618.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: paul.moore@hp.com, kaber@trash.net, netdev@vger.kernel.org,
	acme@ghostprotocols.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:50035 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752065AbXB1JHG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Feb 2007 04:07:06 -0500
Content-Disposition: inline
In-Reply-To: <20070227.102452.102574618.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Attached patch detects in run-time things like:
skb = alloc_skb();
kfree(skb);

where provided to kfree pointer does not belong to kmalloc caches.
It is turned on when slab debug config option is enabled.

When problem is detected, following warning is printed with hint to
what cache/function should be used instead:

[  168.085641] bhtest_init: skb: ffff81003e791478.
[  168.085698] kfree debug: i: 4, size: 15, caches: malloc:
ffff81000119d8c0, dma: ffff81000119e100, free: ffff81003f19c940.
[  168.085776] kfree debug: likely you want to use something with
'skbuff_head_cache' in name instead of kfree().
[  168.085853] BUG: at mm/slab.c:2847 kfree_debug_cahce_pointer()
[  168.085907]
[  168.085907] Call Trace:
[  168.086008]  [<ffffffff8020b28b>] kfree+0xfd/0x274
[  168.086064]  [<ffffffff88025039>] :bhtest:bhtest_init+0x38/0x3f
[  168.086122]  [<ffffffff8029385a>] sys_init_module+0x163d/0x179d
[  168.086183]  [<ffffffff80222183>] filp_close+0x5d/0x65
[  168.086240]  [<ffffffff80254c9e>] system_call+0x7e/0x83
[  168.086295]

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

diff --git a/mm/slab.c b/mm/slab.c
index c610062..acd3871 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2829,6 +2829,27 @@ static void kfree_debugcheck(const void *objp)
 	}
 }
 
+static void kfree_debug_cahce_pointer(struct kmem_cache *cachep, void *objp)
+{
+	int size = obj_size(cachep), i;
+	struct cache_sizes *cs;
+
+	for (i=0; i<ARRAY_SIZE(malloc_sizes); ++i) {
+		cs = &malloc_sizes[i];
+		if (size <= cs->cs_size)
+			break;
+	}
+	if ((i == ARRAY_SIZE(malloc_sizes)) || 
+			(cs->cs_cachep != cachep && cs->cs_dmacachep != cachep)) {
+		printk("kfree debug: i: %d, size: %u, caches: malloc: %p, dma: %p, free: %p.\n",
+				i, ARRAY_SIZE(malloc_sizes), cs->cs_cachep, cs->cs_dmacachep,
+				cachep);
+		printk("kfree debug: likely you want to use something with '%s' in name instead of kfree().\n",
+				cachep->name);
+		WARN_ON(1);
+	}
+}
+
 static inline void verify_redzone_free(struct kmem_cache *cache, void *obj)
 {
 	unsigned long redzone1, redzone2;
@@ -2940,6 +2961,7 @@ bad:
 }
 #else
 #define kfree_debugcheck(x) do { } while(0)
+#define kfree_debug_cahce_pointer(x, y) do { } while(0)
 #define cache_free_debugcheck(x,objp,z) (objp)
 #define check_slabp(x,y) do { } while(0)
 #endif
@@ -3757,6 +3779,7 @@ void kfree(const void *objp)
 	local_irq_save(flags);
 	kfree_debugcheck(objp);
 	c = virt_to_cache(objp);
+	kfree_debug_cahce_pointer(c, objp);
 	debug_check_no_locks_freed(objp, obj_size(c));
 	__cache_free(c, (void *)objp);
 	local_irq_restore(flags);

-- 
	Evgeniy Polyakov
