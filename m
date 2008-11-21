From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH] Fix memory leak in the proto_register function
Date: Fri, 21 Nov 2008 12:08:08 -0200
Message-ID: <20081121140808.GA20958@ghostprotocols.net>
References: <20081121125628.11468.72009.stgit@pc1117.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Catalin Marinas <catalin.marinas@arm.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:60299 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752743AbYKUOIn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 09:08:43 -0500
Content-Disposition: inline
In-Reply-To: <20081121125628.11468.72009.stgit@pc1117.cambridge.arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please send networking patches to netdev@vger.kernel.org as well.

David,
	Please apply.

- arnaldo

> Em Fri, Nov 21, 2008 at 12:56:28PM +0000, Catalin Marinas escreveu:
If the slub allocator is used, kmem_cache_create() may merge two or more
kmem_cache's into one but the cache name pointer is not updated and
kmem_cache_name() is no longer guaranteed to return the pointer passed
to the former function. This patch stores the kmalloc'ed pointers in the
corresponding request_sock_ops and timewait_sock_ops structures.

Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
Reviewed-by: Christoph Lameter <cl@linux-foundation.org>
---
 include/net/request_sock.h  |    1 +
 include/net/timewait_sock.h |    1 +
 net/core/sock.c             |   31 ++++++++++++-------------------
 3 files changed, 14 insertions(+), 19 deletions(-)

diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index cac811e..c719084 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -31,6 +31,7 @@ struct request_sock_ops {
 	int		family;
 	int		obj_size;
 	struct kmem_cache	*slab;
+	char		*slab_name;
 	int		(*rtx_syn_ack)(struct sock *sk,
 				       struct request_sock *req);
 	void		(*send_ack)(struct sock *sk, struct sk_buff *skb,
diff --git a/include/net/timewait_sock.h b/include/net/timewait_sock.h
index 1e1ee32..97c3b14 100644
--- a/include/net/timewait_sock.h
+++ b/include/net/timewait_sock.h
@@ -16,6 +16,7 @@
 
 struct timewait_sock_ops {
 	struct kmem_cache	*twsk_slab;
+	char		*twsk_slab_name;
 	unsigned int	twsk_obj_size;
 	int		(*twsk_unique)(struct sock *sk,
 				       struct sock *sktw, void *twp);
diff --git a/net/core/sock.c b/net/core/sock.c
index 341e394..edf7220 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2035,9 +2035,6 @@ static inline void release_proto_idx(struct proto *prot)
 
 int proto_register(struct proto *prot, int alloc_slab)
 {
-	char *request_sock_slab_name = NULL;
-	char *timewait_sock_slab_name;
-
 	if (alloc_slab) {
 		prot->slab = kmem_cache_create(prot->name, prot->obj_size, 0,
 					       SLAB_HWCACHE_ALIGN, NULL);
@@ -2051,12 +2048,12 @@ int proto_register(struct proto *prot, int alloc_slab)
 		if (prot->rsk_prot != NULL) {
 			static const char mask[] = "request_sock_%s";
 
-			request_sock_slab_name = kmalloc(strlen(prot->name) + sizeof(mask) - 1, GFP_KERNEL);
-			if (request_sock_slab_name == NULL)
+			prot->rsk_prot->slab_name = kmalloc(strlen(prot->name) + sizeof(mask) - 1, GFP_KERNEL);
+			if (prot->rsk_prot->slab_name == NULL)
 				goto out_free_sock_slab;
 
-			sprintf(request_sock_slab_name, mask, prot->name);
-			prot->rsk_prot->slab = kmem_cache_create(request_sock_slab_name,
+			sprintf(prot->rsk_prot->slab_name, mask, prot->name);
+			prot->rsk_prot->slab = kmem_cache_create(prot->rsk_prot->slab_name,
 								 prot->rsk_prot->obj_size, 0,
 								 SLAB_HWCACHE_ALIGN, NULL);
 
@@ -2070,14 +2067,14 @@ int proto_register(struct proto *prot, int alloc_slab)
 		if (prot->twsk_prot != NULL) {
 			static const char mask[] = "tw_sock_%s";
 
-			timewait_sock_slab_name = kmalloc(strlen(prot->name) + sizeof(mask) - 1, GFP_KERNEL);
+			prot->twsk_prot->twsk_slab_name = kmalloc(strlen(prot->name) + sizeof(mask) - 1, GFP_KERNEL);
 
-			if (timewait_sock_slab_name == NULL)
+			if (prot->twsk_prot->twsk_slab_name == NULL)
 				goto out_free_request_sock_slab;
 
-			sprintf(timewait_sock_slab_name, mask, prot->name);
+			sprintf(prot->twsk_prot->twsk_slab_name, mask, prot->name);
 			prot->twsk_prot->twsk_slab =
-				kmem_cache_create(timewait_sock_slab_name,
+				kmem_cache_create(prot->twsk_prot->twsk_slab_name,
 						  prot->twsk_prot->twsk_obj_size,
 						  0, SLAB_HWCACHE_ALIGN,
 						  NULL);
@@ -2093,14 +2090,14 @@ int proto_register(struct proto *prot, int alloc_slab)
 	return 0;
 
 out_free_timewait_sock_slab_name:
-	kfree(timewait_sock_slab_name);
+	kfree(prot->twsk_prot->twsk_slab_name);
 out_free_request_sock_slab:
 	if (prot->rsk_prot && prot->rsk_prot->slab) {
 		kmem_cache_destroy(prot->rsk_prot->slab);
 		prot->rsk_prot->slab = NULL;
 	}
 out_free_request_sock_slab_name:
-	kfree(request_sock_slab_name);
+	kfree(prot->rsk_prot->slab_name);
 out_free_sock_slab:
 	kmem_cache_destroy(prot->slab);
 	prot->slab = NULL;
@@ -2123,18 +2120,14 @@ void proto_unregister(struct proto *prot)
 	}
 
 	if (prot->rsk_prot != NULL && prot->rsk_prot->slab != NULL) {
-		const char *name = kmem_cache_name(prot->rsk_prot->slab);
-
 		kmem_cache_destroy(prot->rsk_prot->slab);
-		kfree(name);
+		kfree(prot->rsk_prot->slab_name);
 		prot->rsk_prot->slab = NULL;
 	}
 
 	if (prot->twsk_prot != NULL && prot->twsk_prot->twsk_slab != NULL) {
-		const char *name = kmem_cache_name(prot->twsk_prot->twsk_slab);
-
 		kmem_cache_destroy(prot->twsk_prot->twsk_slab);
-		kfree(name);
+		kfree(prot->twsk_prot->twsk_slab_name);
 		prot->twsk_prot->twsk_slab = NULL;
 	}
 }

