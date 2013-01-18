From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH v2] [iproute] ipxfrm: use alloca to allocate stack space
Date: Thu, 17 Jan 2013 23:00:50 -0500
Message-ID: <1358481650-20816-1-git-send-email-vapier@gentoo.org>
References: <1358476746-10810-1-git-send-email-vapier@gentoo.org>
To: stephen.hemminger@vyatta.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:43350 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753294Ab3ARD5Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2013 22:57:16 -0500
In-Reply-To: <1358476746-10810-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clang doesn't support the gcc extension for embeddeding flexible arrays
inside of structures.  Use the slightly more portable alloca().

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
v2
	- use alloca rather than flexible arrays in structures

 ip/ipxfrm.c | 27 +++++++++++----------------
 1 file changed, 11 insertions(+), 16 deletions(-)

diff --git a/ip/ipxfrm.c b/ip/ipxfrm.c
index c7b3420..dda4a7a 100644
--- a/ip/ipxfrm.c
+++ b/ip/ipxfrm.c
@@ -25,6 +25,7 @@
  *	Masahide NAKAMURA @USAGI
  */
 
+#include <alloca.h>
 #include <stdio.h>
 #include <stdlib.h>
 #include <string.h>
@@ -555,16 +556,13 @@ static inline void xfrm_algo_print(struct xfrm_algo *algo, int type, int len,
 static void xfrm_aead_print(struct xfrm_algo_aead *algo, int len,
 			    FILE *fp, const char *prefix)
 {
-	struct {
-		struct xfrm_algo algo;
-		char key[algo->alg_key_len / 8];
-	} base;
+	struct xfrm_algo *base_algo = alloca(sizeof(*base_algo) + algo->alg_key_len / 8);
 
-	memcpy(base.algo.alg_name, algo->alg_name, sizeof(base.algo.alg_name));
-	base.algo.alg_key_len = algo->alg_key_len;
-	memcpy(base.algo.alg_key, algo->alg_key, algo->alg_key_len / 8);
+	memcpy(base_algo->alg_name, algo->alg_name, sizeof(base_algo->alg_name));
+	base_algo->alg_key_len = algo->alg_key_len;
+	memcpy(base_algo->alg_key, algo->alg_key, algo->alg_key_len / 8);
 
-	__xfrm_algo_print(&base.algo, XFRMA_ALG_AEAD, len, fp, prefix, 0);
+	__xfrm_algo_print(base_algo, XFRMA_ALG_AEAD, len, fp, prefix, 0);
 
 	fprintf(fp, " %d", algo->alg_icv_len);
 
@@ -574,16 +572,13 @@ static void xfrm_aead_print(struct xfrm_algo_aead *algo, int len,
 static void xfrm_auth_trunc_print(struct xfrm_algo_auth *algo, int len,
 				  FILE *fp, const char *prefix)
 {
-	struct {
-		struct xfrm_algo algo;
-		char key[algo->alg_key_len / 8];
-	} base;
+	struct xfrm_algo *base_algo = alloca(sizeof(*base_algo) + algo->alg_key_len / 8);
 
-	memcpy(base.algo.alg_name, algo->alg_name, sizeof(base.algo.alg_name));
-	base.algo.alg_key_len = algo->alg_key_len;
-	memcpy(base.algo.alg_key, algo->alg_key, algo->alg_key_len / 8);
+	memcpy(base_algo->alg_name, algo->alg_name, sizeof(base_algo->alg_name));
+	base_algo->alg_key_len = algo->alg_key_len;
+	memcpy(base_algo->alg_key, algo->alg_key, algo->alg_key_len / 8);
 
-	__xfrm_algo_print(&base.algo, XFRMA_ALG_AUTH_TRUNC, len, fp, prefix, 0);
+	__xfrm_algo_print(base_algo, XFRMA_ALG_AUTH_TRUNC, len, fp, prefix, 0);
 
 	fprintf(fp, " %d", algo->alg_trunc_len);
 
-- 
1.8.0.2
