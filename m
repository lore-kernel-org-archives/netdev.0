From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: crypto: skcipher - Use eseqiv even on UP machines
Date: Thu, 24 Oct 2013 20:41:49 +0800
Message-ID: <20131024124149.GA10587@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:38197 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754106Ab3JXMl5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 08:41:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:
    
Previously we would use eseqiv on all async ciphers in all cases,
and sync ciphers if we have more than one CPU.  This meant that
chainiv is only used in the case of sync ciphers on a UP machine.

As chainiv may aid attackers by making the IV predictable, even
though this risk itself is small, the above usage pattern causes
it to further leak information about the host.

This patch addresses these issues by using eseqiv even if we're
on a UP machine.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

--git a/crypto/ablkcipher.c b/crypto/ablkcipher.c
index 7d4a8d2..40886c4 100644
--- a/crypto/ablkcipher.c
+++ b/crypto/ablkcipher.c
@@ -16,9 +16,7 @@
 #include <crypto/internal/skcipher.h>
 #include <linux/cpumask.h>
 #include <linux/err.h>
-#include <linux/init.h>
 #include <linux/kernel.h>
-#include <linux/module.h>
 #include <linux/rtnetlink.h>
 #include <linux/sched.h>
 #include <linux/slab.h>
@@ -30,8 +28,6 @@
 
 #include "internal.h"
 
-static const char *skcipher_default_geniv __read_mostly;
-
 struct ablkcipher_buffer {
 	struct list_head	entry;
 	struct scatter_walk	dst;
@@ -527,8 +523,7 @@ const char *crypto_default_geniv(const struct crypto_alg *alg)
 	    alg->cra_blocksize)
 		return "chainiv";
 
-	return alg->cra_flags & CRYPTO_ALG_ASYNC ?
-	       "eseqiv" : skcipher_default_geniv;
+	return "eseqiv";
 }
 
 static int crypto_givcipher_default(struct crypto_alg *alg, u32 type, u32 mask)
@@ -709,17 +704,3 @@ err:
 	return ERR_PTR(err);
 }
 EXPORT_SYMBOL_GPL(crypto_alloc_ablkcipher);
-
-static int __init skcipher_module_init(void)
-{
-	skcipher_default_geniv = num_possible_cpus() > 1 ?
-				 "eseqiv" : "chainiv";
-	return 0;
-}
-
-static void skcipher_module_exit(void)
-{
-}
-
-module_init(skcipher_module_init);
-module_exit(skcipher_module_exit);

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
