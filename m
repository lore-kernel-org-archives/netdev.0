From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 24/29] mm: methods for teaching filesystems about PG_swapcache pages
Date: Fri, 14 Dec 2007 16:39:31 +0100
Message-ID: <20071214154442.394650000@chello.nl>
References: <20071214153907.770251000@chello.nl>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:38879 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753826AbXLNTXg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2007 14:23:36 -0500
Content-Disposition: inline; filename=mm-page_file_methods.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to teach filesystems to handle swap cache pages, two new page
functions are introduced:

  pgoff_t page_file_index(struct page *);
  struct address_space *page_file_mapping(struct page *);

page_file_index - gives the offset of this page in the file in PAGE_CACHE_SIZE
blocks. Like page->index is for mapped pages, this function also gives the
correct index for PG_swapcache pages.

page_file_mapping - gives the mapping backing the actual page; that is for
swap cache pages it will give swap_file->f_mapping.

page_offset() is modified to use page_file_index(), so that it will give the
expected result, even for PG_swapcache pages.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/mm.h      |   26 ++++++++++++++++++++++++++
 include/linux/pagemap.h |    2 +-
 2 files changed, 27 insertions(+), 1 deletion(-)

Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -14,6 +14,7 @@
 #include <linux/mm_types.h>
 #include <linux/security.h>
 #include <linux/swap.h>
+#include <linux/fs.h>
 
 struct mempolicy;
 struct anon_vma;
@@ -608,6 +609,16 @@ static inline struct swap_info_struct *p
 	return get_swap_info_struct(swp_type(swap));
 }
 
+static inline
+struct address_space *page_file_mapping(struct page *page)
+{
+#ifdef CONFIG_SWAP_FILE
+	if (unlikely(PageSwapCache(page)))
+		return page_swap_info(page)->swap_file->f_mapping;
+#endif
+	return page->mapping;
+}
+
 static inline int PageAnon(struct page *page)
 {
 	return ((unsigned long)page->mapping & PAGE_MAPPING_ANON) != 0;
@@ -625,6 +636,21 @@ static inline pgoff_t page_index(struct 
 }
 
 /*
+ * Return the file index of the page. Regular pagecache pages use ->index
+ * whereas swapcache pages use swp_offset(->private)
+ */
+static inline pgoff_t page_file_index(struct page *page)
+{
+#ifdef CONFIG_SWAP_FILE
+	if (unlikely(PageSwapCache(page))) {
+		swp_entry_t swap = { .val = page_private(page) };
+		return swp_offset(swap);
+	}
+#endif
+	return page->index;
+}
+
+/*
  * The atomic page->_mapcount, like _count, starts from -1:
  * so that transitions both from it and to it can be tracked,
  * using atomic_inc_and_test and atomic_add_negative(-1).
Index: linux-2.6/include/linux/pagemap.h
===================================================================
--- linux-2.6.orig/include/linux/pagemap.h
+++ linux-2.6/include/linux/pagemap.h
@@ -145,7 +145,7 @@ extern void __remove_from_page_cache(str
  */
 static inline loff_t page_offset(struct page *page)
 {
-	return ((loff_t)page->index) << PAGE_CACHE_SHIFT;
+	return ((loff_t)page_file_index(page)) << PAGE_CACHE_SHIFT;
 }
 
 static inline pgoff_t linear_page_index(struct vm_area_struct *vma,

--

