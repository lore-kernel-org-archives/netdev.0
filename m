From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 32/32] nfs: fix various memory recursions possible with swap over NFS.
Date: Thu, 02 Oct 2008 15:05:36 +0200
Message-ID: <20081002131610.015455850@chello.nl>
References: <20081002130504.927878499@chello.nl>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fy
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:54837 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754689AbYJBNTb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2008 09:19:31 -0400
Content-Disposition: inline; filename=nfs-alloc-recursions.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

GFP_NOFS is _more_ permissive than GFP_NOIO in that it will initiate IO,
just not of any filesystem data.

The problem is that previuosly NOFS was correct because that avoids
recursion into the NFS code, it now is not, because also IO (swap) can
lead to this recursion.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 fs/nfs/pagelist.c |    2 +-
 fs/nfs/write.c    |    6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

Index: linux-2.6/fs/nfs/write.c
===================================================================
--- linux-2.6.orig/fs/nfs/write.c
+++ linux-2.6/fs/nfs/write.c
@@ -45,7 +45,7 @@ static struct kmem_cache *nfs_wdata_cach
 
 struct nfs_write_data *nfs_commitdata_alloc(void)
 {
-	struct nfs_write_data *p = kmem_cache_alloc(nfs_wdata_cachep, GFP_NOFS);
+	struct nfs_write_data *p = kmem_cache_alloc(nfs_wdata_cachep, GFP_NOIO);
 
 	if (p) {
 		memset(p, 0, sizeof(*p));
@@ -63,7 +63,7 @@ void nfs_commit_free(struct nfs_write_da
 
 struct nfs_write_data *nfs_writedata_alloc(unsigned int pagecount)
 {
-	struct nfs_write_data *p = kmem_cache_alloc(nfs_wdata_cachep, GFP_NOFS);
+	struct nfs_write_data *p = kmem_cache_alloc(nfs_wdata_cachep, GFP_NOIO);
 
 	if (p) {
 		memset(p, 0, sizeof(*p));
@@ -72,7 +72,7 @@ struct nfs_write_data *nfs_writedata_all
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

