From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 2/2] afs: Make afs_readpages() fetch data in bulk
Date: Fri, 06 Jan 2017 17:09:04 +0000
Message-ID: <148372254415.8578.7711330270476665864.stgit@warthog.procyon.org.uk>
References: <148372251997.8578.5117118854142528477.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45936 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1030533AbdAFRJN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Jan 2017 12:09:13 -0500
In-Reply-To: <148372251997.8578.5117118854142528477.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make afs_readpages() use afs_vnode_fetch_data()'s new ability to take a
list of pages and do a bulk fetch.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/afs/file.c   |  131 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 fs/afs/volume.c |    1 
 2 files changed, 130 insertions(+), 2 deletions(-)

diff --git a/fs/afs/file.c b/fs/afs/file.c
index 6c262ceef32d..82897a78abc7 100644
--- a/fs/afs/file.c
+++ b/fs/afs/file.c
@@ -16,6 +16,7 @@
 #include <linux/pagemap.h>
 #include <linux/writeback.h>
 #include <linux/gfp.h>
+#include <linux/task_io_accounting_ops.h>
 #include "internal.h"
 
 static int afs_readpage(struct file *file, struct page *page);
@@ -262,6 +263,129 @@ static int afs_readpage(struct file *file, struct page *page)
 }
 
 /*
+ * Make pages available as they're filled.
+ */
+static void afs_readpages_page_done(struct afs_call *call, struct afs_read *req)
+{
+	struct afs_vnode *vnode = call->reply;
+	struct page *page = req->pages[req->index];
+
+	req->pages[req->index] = NULL;
+	SetPageUptodate(page);
+
+	/* send the page to the cache */
+#ifdef CONFIG_AFS_FSCACHE
+	if (PageFsCache(page) &&
+	    fscache_write_page(vnode->cache, page, GFP_KERNEL) != 0) {
+		fscache_uncache_page(vnode->cache, page);
+		BUG_ON(PageFsCache(page));
+	}
+#endif
+	unlock_page(page);
+	put_page(page);
+}
+
+/*
+ * Read a contiguous set of pages.
+ */
+static int afs_readpages_one(struct file *file, struct address_space *mapping,
+			     struct list_head *pages)
+{
+	struct afs_vnode *vnode = AFS_FS_I(mapping->host);
+	struct afs_read *req;
+	struct list_head *p;
+	struct page *first, *page;
+	struct key *key = file->private_data;
+	pgoff_t index;
+	int ret, n, i;
+
+	/* Count the number of contiguous pages at the front of the list.  Note
+	 * that the list goes prev-wards rather than next-wards.
+	 */
+	first = list_entry(pages->prev, struct page, lru);
+	index = first->index + 1;
+	n = 1;
+	for (p = first->lru.prev; p != pages; p = p->prev) {
+		page = list_entry(p, struct page, lru);
+		if (page->index != index)
+			break;
+		index++;
+		n++;
+	}
+
+	req = kzalloc(sizeof(struct afs_read) + sizeof(struct page *) * n,
+		      GFP_NOFS);
+	if (!req)
+		return -ENOMEM;
+
+	atomic_set(&req->usage, 1);
+	req->page_done = afs_readpages_page_done;
+	req->pos = first->index;
+	req->pos <<= PAGE_SHIFT;
+
+	/* Transfer the pages to the request.  We add them in until one fails
+	 * to add to the LRU and then we stop (as that'll make a hole in the
+	 * contiguous run.
+	 *
+	 * Note that it's possible for the file size to change whilst we're
+	 * doing this, but we rely on the server returning less than we asked
+	 * for if the file shrank.  We also rely on this to deal with a partial
+	 * page at the end of the file.
+	 */
+	do {
+		page = list_entry(pages->prev, struct page, lru);
+		list_del(&page->lru);
+		index = page->index;
+		if (add_to_page_cache_lru(page, mapping, index,
+					  readahead_gfp_mask(mapping))) {
+#ifdef CONFIG_AFS_FSCACHE
+			fscache_uncache_page(vnode->cache, page);
+#endif
+			put_page(page);
+			break;
+		}
+
+		req->pages[req->nr_pages++] = page;
+		req->len += PAGE_SIZE;
+	} while (req->nr_pages < n);
+
+	if (req->nr_pages == 0) {
+		kfree(req);
+		return 0;
+	}
+
+	ret = afs_vnode_fetch_data(vnode, key, req);
+	if (ret < 0)
+		goto error;
+
+	task_io_account_read(PAGE_SIZE * req->nr_pages);
+	afs_put_read(req);
+	return 0;
+
+error:
+	if (ret == -ENOENT) {
+		_debug("got NOENT from server"
+		       " - marking file deleted and stale");
+		set_bit(AFS_VNODE_DELETED, &vnode->flags);
+		ret = -ESTALE;
+	}
+
+	for (i = 0; i < req->nr_pages; i++) {
+		page = req->pages[i];
+		if (page) {
+#ifdef CONFIG_AFS_FSCACHE
+			fscache_uncache_page(vnode->cache, page);
+#endif
+			SetPageError(page);
+			unlock_page(page);
+		}
+	}
+
+	afs_put_read(req);
+	return ret;
+}
+
+/*
  * read a set of pages
  */
 static int afs_readpages(struct file *file, struct address_space *mapping,
@@ -314,8 +438,11 @@ static int afs_readpages(struct file *file, struct address_space *mapping,
 		return ret;
 	}
 
-	/* load the missing pages from the network */
-	ret = read_cache_pages(mapping, pages, afs_page_filler, key);
+	while (!list_empty(pages)) {
+		ret = afs_readpages_one(file, mapping, pages);
+		if (ret < 0)
+			break;
+	}
 
 	_leave(" = %d [netting]", ret);
 	return ret;
diff --git a/fs/afs/volume.c b/fs/afs/volume.c
index d142a2449e65..546f9d01710b 100644
--- a/fs/afs/volume.c
+++ b/fs/afs/volume.c
@@ -106,6 +106,7 @@ struct afs_volume *afs_volume_lookup(struct afs_mount_params *params)
 	volume->cell		= params->cell;
 	volume->vid		= vlocation->vldb.vid[params->type];
 
+	volume->bdi.ra_pages	= VM_MAX_READAHEAD*1024/PAGE_SIZE; 
 	ret = bdi_setup_and_register(&volume->bdi, "afs");
 	if (ret)
 		goto error_bdi;
