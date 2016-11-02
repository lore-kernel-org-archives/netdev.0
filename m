From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [mm PATCH v2 24/26] mm: Add support for releasing multiple
 instances of a page
Date: Wed, 02 Nov 2016 07:16:08 -0400
Message-ID: <20161102111605.79519.37675.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161102111031.79519.14741.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux-mm@kvack.org, akpm@linux-foundation.org
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20161102111031.79519.14741.stgit@ahduyck-blue-test.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

This patch adds a function that allows us to batch free a page that has
multiple references outstanding.  Specifically this function can be used to
drop a page being used in the page frag alloc cache.  With this drivers can
make use of functionality similar to the page frag alloc cache without
having to do any workarounds for the fact that there is no function that
frees multiple references.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 include/linux/gfp.h |    2 ++
 mm/page_alloc.c     |   14 ++++++++++++++
 2 files changed, 16 insertions(+)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index f8041f9de..4175dca 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -506,6 +506,8 @@ extern struct page *alloc_pages_vma(gfp_t gfp_mask, int order,
 extern void free_hot_cold_page_list(struct list_head *list, bool cold);
 
 struct page_frag_cache;
+extern void __page_frag_drain(struct page *page, unsigned int order,
+			      unsigned int count);
 extern void *__alloc_page_frag(struct page_frag_cache *nc,
 			       unsigned int fragsz, gfp_t gfp_mask);
 extern void __free_page_frag(void *addr);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 65e0b51..bb6d7bd 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3938,6 +3938,20 @@ static struct page *__page_frag_refill(struct page_frag_cache *nc,
 	return page;
 }
 
+void __page_frag_drain(struct page *page, unsigned int order,
+		       unsigned int count)
+{
+	VM_BUG_ON_PAGE(page_ref_count(page) == 0, page);
+
+	if (page_ref_sub_and_test(page, count)) {
+		if (order == 0)
+			free_hot_cold_page(page, false);
+		else
+			__free_pages_ok(page, order);
+	}
+}
+EXPORT_SYMBOL(__page_frag_drain);
+
 void *__alloc_page_frag(struct page_frag_cache *nc,
 			unsigned int fragsz, gfp_t gfp_mask)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
