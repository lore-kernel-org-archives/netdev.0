From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 4/7] net: add req_prot_cleanup() & req_prot_init() helpers
Date: Thu, 12 Mar 2015 14:50:13 -0700
Message-ID: <1426197016-14482-5-git-send-email-edumazet@google.com>
References: <1426197016-14482-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f74.google.com ([209.85.220.74]:33841 "EHLO
	mail-pa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755071AbbCLVu7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 17:50:59 -0400
Received: by padet14 with SMTP id et14so5565842pad.1
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 14:50:59 -0700 (PDT)
In-Reply-To: <1426197016-14482-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make proto_register() & proto_unregister() a bit nicer.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/sock.c | 69 ++++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 41 insertions(+), 28 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index c8842f279f7a..63d871a91b5c 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2726,6 +2726,42 @@ static inline void release_proto_idx(struct proto *prot)
 }
 #endif
 
+static void req_prot_cleanup(struct request_sock_ops *rsk_prot)
+{
+	if (!rsk_prot)
+		return;
+	kfree(rsk_prot->slab_name);
+	rsk_prot->slab_name = NULL;
+	if (rsk_prot->slab) {
+		kmem_cache_destroy(rsk_prot->slab);
+		rsk_prot->slab = NULL;
+	}
+}
+
+static int req_prot_init(const struct proto *prot)
+{
+	struct request_sock_ops *rsk_prot = prot->rsk_prot;
+
+	if (!rsk_prot)
+		return 0;
+
+	rsk_prot->slab_name = kasprintf(GFP_KERNEL, "request_sock_%s",
+					prot->name);
+	if (!rsk_prot->slab_name)
+		return -ENOMEM;
+
+	rsk_prot->slab = kmem_cache_create(rsk_prot->slab_name,
+					   rsk_prot->obj_size, 0,
+					   SLAB_HWCACHE_ALIGN, NULL);
+
+	if (!rsk_prot->slab) {
+		pr_crit("%s: Can't create request sock SLAB cache!\n",
+			prot->name);
+		return -ENOMEM;
+	}
+	return 0;
+}
+
 int proto_register(struct proto *prot, int alloc_slab)
 {
 	if (alloc_slab) {
@@ -2739,21 +2775,8 @@ int proto_register(struct proto *prot, int alloc_slab)
 			goto out;
 		}
 
-		if (prot->rsk_prot != NULL) {
-			prot->rsk_prot->slab_name = kasprintf(GFP_KERNEL, "request_sock_%s", prot->name);
-			if (prot->rsk_prot->slab_name == NULL)
-				goto out_free_sock_slab;
-
-			prot->rsk_prot->slab = kmem_cache_create(prot->rsk_prot->slab_name,
-								 prot->rsk_prot->obj_size, 0,
-								 SLAB_HWCACHE_ALIGN, NULL);
-
-			if (prot->rsk_prot->slab == NULL) {
-				pr_crit("%s: Can't create request sock SLAB cache!\n",
-					prot->name);
-				goto out_free_request_sock_slab_name;
-			}
-		}
+		if (req_prot_init(prot))
+			goto out_free_request_sock_slab;
 
 		if (prot->twsk_prot != NULL) {
 			prot->twsk_prot->twsk_slab_name = kasprintf(GFP_KERNEL, "tw_sock_%s", prot->name);
@@ -2782,14 +2805,8 @@ int proto_register(struct proto *prot, int alloc_slab)
 out_free_timewait_sock_slab_name:
 	kfree(prot->twsk_prot->twsk_slab_name);
 out_free_request_sock_slab:
-	if (prot->rsk_prot && prot->rsk_prot->slab) {
-		kmem_cache_destroy(prot->rsk_prot->slab);
-		prot->rsk_prot->slab = NULL;
-	}
-out_free_request_sock_slab_name:
-	if (prot->rsk_prot)
-		kfree(prot->rsk_prot->slab_name);
-out_free_sock_slab:
+	req_prot_cleanup(prot->rsk_prot);
+
 	kmem_cache_destroy(prot->slab);
 	prot->slab = NULL;
 out:
@@ -2809,11 +2826,7 @@ void proto_unregister(struct proto *prot)
 		prot->slab = NULL;
 	}
 
-	if (prot->rsk_prot != NULL && prot->rsk_prot->slab != NULL) {
-		kmem_cache_destroy(prot->rsk_prot->slab);
-		kfree(prot->rsk_prot->slab_name);
-		prot->rsk_prot->slab = NULL;
-	}
+	req_prot_cleanup(prot->rsk_prot);
 
 	if (prot->twsk_prot != NULL && prot->twsk_prot->twsk_slab != NULL) {
 		kmem_cache_destroy(prot->twsk_prot->twsk_slab);
-- 
2.2.0.rc0.207.ga3a616c
