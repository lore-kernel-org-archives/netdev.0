From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 29/29] nfs: fix various memory recursions possible with swap over NFS.
Date: Fri, 14 Dec 2007 16:39:36 +0100
Message-ID: <20071214154443.047840000@chello.nl>
References: <20071214153907.770251000@chello.nl>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:38881 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755031AbXLNTXh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2007 14:23:37 -0500
Content-Disposition: inline; filename=nfs-alloc-recursions.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

GFP_NOFS is not enough, since swap traffic is IO, hence fall back to GFP_NOIO.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 fs/nfs/pagelist.c |    2 +-
 fs/nfs/write.c    |    6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

Index: linux-2.6/fs/nfs/write.c
===================================================================
--- linux-2.6.orig/fs/nfs/write.c
+++ linux-2.6/fs/nfs/write.c
@@ -44,7 +44,7 @@ static struct kmem_cache *nfs_wdata_cach
 
 struct nfs_write_data *nfs_commit_alloc(void)
 {
-	struct nfs_write_data *p = kmem_cache_alloc(nfs_wdata_cachep, GFP_NOFS);
+	struct nfs_write_data *p = kmem_cache_alloc(nfs_wdata_cachep, GFP_NOIO);
 
 	if (p) {
 		memset(p, 0, sizeof(*p));
@@ -68,7 +68,7 @@ void nfs_commit_free(struct nfs_write_da
 
 struct nfs_write_data *nfs_writedata_alloc(unsigned int pagecount)
 {
-	struct nfs_write_data *p = kmem_cache_alloc(nfs_wdata_cachep, GFP_NOFS);
+	struct nfs_write_data *p = kmem_cache_alloc(nfs_wdata_cachep, GFP_NOIO);
 
 	if (p) {
 		memset(p, 0, sizeof(*p));
@@ -77,7 +77,7 @@ struct nfs_write_data *nfs_writedata_all
 		if (pagecount <= ARRAY_SIZE(p->page_array))
 			p->pagevec = p->page_array;
 		else {
-			p->pagevec = kcalloc(pagecount, sizeof(struct page *), GFP_NOFS);
+			p->pagevec = kcalloc(pagecount, sizeof(struct page *), GFP_NOIO);
 			if (!p->pagevec) {
 				kmem_cache_free(nfs_wdata_cachep, p);
 				p = NULL;
Index: linux-2.6/fs/nfs/pagelist.c
===================================================================
--- linux-2.6.orig/fs/nfs/pagelist.c
+++ linux-2.6/fs/nfs/pagelist.c
@@ -27,7 +27,7 @@ static inline struct nfs_page *
 nfs_page_alloc(void)
 {
 	struct nfs_page	*p;
-	p = kmem_cache_alloc(nfs_page_cachep, GFP_KERNEL);
+	p = kmem_cache_alloc(nfs_page_cachep, GFP_NOIO);
 	if (p) {
 		memset(p, 0, sizeof(*p));
 		INIT_LIST_HEAD(&p->wb_list);

--

