From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 3/5][SOCK]: Drop per-proto inuse init and fre functions
 (v2).
Date: Fri, 28 Mar 2008 15:35:17 +0300
Message-ID: <47ECE605.1050403@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:50963 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753535AbYC1Mf0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 08:35:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Constructive part of the set is finished here. We have to
remove the pcounter, so start with its init and free
functions.

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
index 174c64b..c1ae56e 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1999,11 +1999,6 @@ int proto_register(struct proto *prot, int alloc_slab)
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
@@ -2011,7 +2006,7 @@ int proto_register(struct proto *prot, int alloc_slab)
 		if (prot->slab == NULL) {
 			printk(KERN_CRIT "%s: Can't create sock SLAB cache!\n",
 			       prot->name);
-			goto out_free_inuse;
+			goto out;
 		}
 
 		if (prot->rsk_prot != NULL) {
@@ -2070,8 +2065,6 @@ out_free_request_sock_slab_name:
 out_free_sock_slab:
 	kmem_cache_destroy(prot->slab);
 	prot->slab = NULL;
-out_free_inuse:
-	sock_prot_inuse_free(prot);
 out:
 	return -ENOBUFS;
 }
@@ -2085,8 +2078,6 @@ void proto_unregister(struct proto *prot)
 	list_del(&prot->node);
 	write_unlock(&proto_list_lock);
 
-	sock_prot_inuse_free(prot);
-
 	if (prot->slab != NULL) {
 		kmem_cache_destroy(prot->slab);
 		prot->slab = NULL;
-- 
1.5.3.4


