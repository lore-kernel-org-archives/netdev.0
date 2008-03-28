From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 3/5][SOCK]: Drop per-proto inuse initialization
 and removal.
Date: Fri, 28 Mar 2008 12:04:16 +0300
Message-ID: <47ECB490.90400@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:40490 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752508AbYC1JES (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 05:04:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the proto->inuse pcounter is no longer used its initialization
can be dropped.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 include/net/sock.h |   18 ------------------
 net/core/sock.c    |   11 +----------
 2 files changed, 1 insertions(+), 28 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index ebf9552..1f42942 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -640,31 +640,13 @@ static inline void sk_refcnt_debug_release(const struct sock *sk)
 # define REF_PROTO_INUSE(NAME) PCOUNTER_MEMBER_INITIALIZER(NAME, .inuse)
 /* Called with local bh disabled */
 extern void sock_prot_inuse_add(struct proto *prot, int inc);
-
-static inline int sock_prot_inuse_init(struct proto *proto)
-{
-	return pcounter_alloc(&proto->inuse);
-}
-
 extern int sock_prot_inuse_get(struct proto *proto);
-
-static inline void sock_prot_inuse_free(struct proto *proto)
-{
-	pcounter_free(&proto->inuse);
-}
 #else
 # define DEFINE_PROTO_INUSE(NAME)
 # define REF_PROTO_INUSE(NAME)
 static void inline sock_prot_inuse_add(struct proto *prot, int inc)
 {
 }
-static int inline sock_prot_inuse_init(struct proto *proto)
-{
-	return 0;
-}
-static void inline sock_prot_inuse_free(struct proto *proto)
-{
-}
 #endif
 
 
diff --git a/net/core/sock.c b/net/core/sock.c
index 2b6f8f1..3316888 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1988,11 +1988,6 @@ int proto_register(struct proto *prot, int alloc_slab)
 	char *request_sock_slab_name = NULL;
 	char *timewait_sock_slab_name;
 
-	if (sock_prot_inuse_init(prot) != 0) {
-		printk(KERN_CRIT "%s: Can't alloc inuse counters!\n", prot->name);
-		goto out;
-	}
-
 	if (alloc_slab) {
 		prot->slab = kmem_cache_create(prot->name, prot->obj_size, 0,
 					       SLAB_HWCACHE_ALIGN, NULL);
@@ -2000,7 +1995,7 @@ int proto_register(struct proto *prot, int alloc_slab)
 		if (prot->slab == NULL) {
 			printk(KERN_CRIT "%s: Can't create sock SLAB cache!\n",
 			       prot->name);
-			goto out_free_inuse;
+			goto out;
 		}
 
 		if (prot->rsk_prot != NULL) {
@@ -2059,8 +2054,6 @@ out_free_request_sock_slab_name:
 out_free_sock_slab:
 	kmem_cache_destroy(prot->slab);
 	prot->slab = NULL;
-out_free_inuse:
-	sock_prot_inuse_free(prot);
 out:
 	return -ENOBUFS;
 }
@@ -2073,8 +2066,6 @@ void proto_unregister(struct proto *prot)
 	list_del(&prot->node);
 	write_unlock(&proto_list_lock);
 
-	sock_prot_inuse_free(prot);
-
 	if (prot->slab != NULL) {
 		kmem_cache_destroy(prot->slab);
 		prot->slab = NULL;
-- 
1.5.3.4

