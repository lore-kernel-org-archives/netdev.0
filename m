From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH 7/7] slub: initial bulk free implementation
Date: Mon, 15 Jun 2015 17:52:56 +0200
Message-ID: <20150615155256.18824.42651.stgit@devil>
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
Received: from mx1.redhat.com ([209.132.183.28]:54479 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755796AbbFOPxB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jun 2015 11:53:01 -0400
In-Reply-To: <20150615155053.18824.617.stgit@devil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This implements SLUB specific kmem_cache_free_bulk().  SLUB allocator
now both have bulk alloc and free implemented.

Play nice and reenable local IRQs while calling slowpath.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 mm/slub.c |   32 +++++++++++++++++++++++++++++++-
 1 file changed, 31 insertions(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index 98d0e6f73ec1..cc4f870677bb 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2752,7 +2752,37 @@ EXPORT_SYMBOL(kmem_cache_free);
 
 void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
 {
-	__kmem_cache_free_bulk(s, size, p);
+	struct kmem_cache_cpu *c;
+	struct page *page;
+	int i;
+
+	local_irq_disable();
+	c = this_cpu_ptr(s->cpu_slab);
+
+	for (i = 0; i < size; i++) {
+		void *object = p[i];
+
+		if (unlikely(!object))
+			continue; // HOW ABOUT BUG_ON()???
+
+		page = virt_to_head_page(object);
+		BUG_ON(s != page->slab_cache); /* Check if valid slab page */
+
+		if (c->page == page) {
+			/* Fastpath: local CPU free */
+			set_freepointer(s, object, c->freelist);
+			c->freelist = object;
+		} else {
+			c->tid = next_tid(c->tid);
+			local_irq_enable();
+			/* Slowpath: overhead locked cmpxchg_double_slab */
+			__slab_free(s, page, object, _RET_IP_);
+			local_irq_disable();
+			c = this_cpu_ptr(s->cpu_slab);
+		}
+	}
+	c->tid = next_tid(c->tid);
+	local_irq_enable();
 }
 EXPORT_SYMBOL(kmem_cache_free_bulk);
 
