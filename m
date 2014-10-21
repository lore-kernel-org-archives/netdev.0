From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 linux-next] ceph: remove unused ceph_get_direct_page_vector
Date: Tue, 21 Oct 2014 18:35:27 +0200
Message-ID: <1413909327-6542-1-git-send-email-fabf@skynet.be>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
	Fabian Frederick <fabf@skynet.be>,
	Sage Weil <sage@inktank.com>,
	"David S. Miller" <davem@davemloft.net>,
	ceph-devel@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This function is not used since commit 64c3131161c1
("ceph_sync_direct_write: stop poking into iov_iter guts")

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 include/linux/ceph/libceph.h |  3 ---
 net/ceph/pagevec.c           | 35 -----------------------------------
 2 files changed, 38 deletions(-)

diff --git a/include/linux/ceph/libceph.h b/include/linux/ceph/libceph.h
index 07bc359..3ba8b15 100644
--- a/include/linux/ceph/libceph.h
+++ b/include/linux/ceph/libceph.h
@@ -206,9 +206,6 @@ extern int ceph_open_session(struct ceph_client *client);
 /* pagevec.c */
 extern void ceph_release_page_vector(struct page **pages, int num_pages);
 
-extern struct page **ceph_get_direct_page_vector(const void __user *data,
-						 int num_pages,
-						 bool write_page);
 extern void ceph_put_page_vector(struct page **pages, int num_pages,
 				 bool dirty);
 extern struct page **ceph_alloc_page_vector(int num_pages, gfp_t flags);
diff --git a/net/ceph/pagevec.c b/net/ceph/pagevec.c
index 5550130..4d159fe 100644
--- a/net/ceph/pagevec.c
+++ b/net/ceph/pagevec.c
@@ -9,41 +9,6 @@
 
 #include <linux/ceph/libceph.h>
 
-/*
- * build a vector of user pages
- */
-struct page **ceph_get_direct_page_vector(const void __user *data,
-					  int num_pages, bool write_page)
-{
-	struct page **pages;
-	int got = 0;
-	int rc = 0;
-
-	pages = kmalloc(sizeof(*pages) * num_pages, GFP_NOFS);
-	if (!pages)
-		return ERR_PTR(-ENOMEM);
-
-	down_read(&current->mm->mmap_sem);
-	while (got < num_pages) {
-		rc = get_user_pages(current, current->mm,
-		    (unsigned long)data + ((unsigned long)got * PAGE_SIZE),
-		    num_pages - got, write_page, 0, pages + got, NULL);
-		if (rc < 0)
-			break;
-		BUG_ON(rc == 0);
-		got += rc;
-	}
-	up_read(&current->mm->mmap_sem);
-	if (rc < 0)
-		goto fail;
-	return pages;
-
-fail:
-	ceph_put_page_vector(pages, got, false);
-	return ERR_PTR(rc);
-}
-EXPORT_SYMBOL(ceph_get_direct_page_vector);
-
 void ceph_put_page_vector(struct page **pages, int num_pages, bool dirty)
 {
 	int i;
-- 
1.9.3
