From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH 5/7] slub: kmem_cache_alloc_bulk() move clearing outside IRQ
 disabled section
Date: Mon, 15 Jun 2015 17:52:36 +0200
Message-ID: <20150615155236.18824.56477.stgit@devil>
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
Received: from mx1.redhat.com ([209.132.183.28]:51275 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755699AbbFOPwl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jun 2015 11:52:41 -0400
In-Reply-To: <20150615155053.18824.617.stgit@devil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move clearing of objects outside IRQ disabled section,
to minimize time spend with local IRQs off.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 mm/slub.c |   11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index d10de5a33c03..26f64005a347 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2781,13 +2781,18 @@ bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
 
 		c->freelist = get_freepointer(s, object);
 		p[i] = object;
-
-		if (unlikely(flags & __GFP_ZERO))
-			memset(object, 0, s->object_size);
 	}
 	c->tid = next_tid(c->tid);
 	local_irq_enable();
 
+	/* Clear memory outside IRQ disabled fastpath loop */
+	if (unlikely(flags & __GFP_ZERO)) {
+		int j;
+
+		for (j = 0; j < i; j++)
+			memset(p[j], 0, s->object_size);
+	}
+
 	/* Fallback to single elem alloc */
 	for (; i < size; i++) {
 		void *x = p[i] = kmem_cache_alloc(s, flags);
