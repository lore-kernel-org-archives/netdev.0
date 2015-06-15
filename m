From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH 2/7] slub bulk alloc: extract objects from the per cpu slab
Date: Mon, 15 Jun 2015 17:52:07 +0200
Message-ID: <20150615155207.18824.8674.stgit@devil>
References: <20150615155053.18824.617.stgit@devil>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51082 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754477AbbFOPwL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jun 2015 11:52:11 -0400
In-Reply-To: <20150615155053.18824.617.stgit@devil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Lameter <cl@linux.com>

[NOTICE: Already in AKPM's quilt-queue]

First piece: acceleration of retrieval of per cpu objects

If we are allocating lots of objects then it is advantageous to disable
interrupts and avoid the this_cpu_cmpxchg() operation to get these objects
faster.

Note that we cannot do the fast operation if debugging is enabled, because
we would have to add extra code to do all the debugging checks.  And it
would not be fast anyway.

Note also that the requirement of having interrupts disabled
avoids having to do processor flag operations.

Allocate as many objects as possible in the fast way and then fall back to
the generic implementation for the rest of the objects.

Signed-off-by: Christoph Lameter <cl@linux.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 mm/slub.c |   27 ++++++++++++++++++++++++++-
 1 file changed, 26 insertions(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index 80f17403e503..d18f8e195ac4 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2759,7 +2759,32 @@ EXPORT_SYMBOL(kmem_cache_free_bulk);
 bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
 								void **p)
 {
-	return kmem_cache_alloc_bulk(s, flags, size, p);
+	if (!kmem_cache_debug(s)) {
+		struct kmem_cache_cpu *c;
+
+		/* Drain objects in the per cpu slab */
+		local_irq_disable();
+		c = this_cpu_ptr(s->cpu_slab);
+
+		while (size) {
+			void *object = c->freelist;
+
+			if (!object)
+				break;
+
+			c->freelist = get_freepointer(s, object);
+			*p++ = object;
+			size--;
+
+			if (unlikely(flags & __GFP_ZERO))
+				memset(object, 0, s->object_size);
+		}
+		c->tid = next_tid(c->tid);
+
+		local_irq_enable();
+	}
+
+	return __kmem_cache_alloc_bulk(s, flags, size, p);
 }
 EXPORT_SYMBOL(kmem_cache_alloc_bulk);
 
