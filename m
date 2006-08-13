From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/16] [CRYPTO] api: Added crypto_type support
Date: Sun, 13 Aug 2006 22:19:37 +1000
Message-ID: <E1GCEwL-0004f4-00@gondolin.me.apana.org.au>
References: <20060813121722.GA16115@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3337 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751033AbWHMMTj
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Aug 2006 08:19:39 -0400
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[CRYPTO] api: Added crypto_type support

This patch adds the crypto_type structure which will be used for all new
crypto algorithm types, beginning with block ciphers.

The primary purpose of this abstraction is to allow different crypto_type
objects for crypto algorithms of the same type, in particular, there will
be a different crypto_type objects for asynchronous algorithms.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 crypto/api.c            |   32 +++++++++++++++++++++++---------
 include/crypto/algapi.h |    6 ++++++
 include/linux/crypto.h  |    3 +++
 3 files changed, 32 insertions(+), 9 deletions(-)

diff --git a/crypto/api.c b/crypto/api.c
--- a/crypto/api.c
+++ b/crypto/api.c
@@ -226,17 +226,18 @@ static int crypto_init_flags(struct cryp
 		
 	case CRYPTO_ALG_TYPE_COMPRESS:
 		return crypto_init_compress_flags(tfm, flags);
-	
-	default:
-		break;
 	}
 	
-	BUG();
-	return -EINVAL;
+	return 0;
 }
 
 static int crypto_init_ops(struct crypto_tfm *tfm)
 {
+	const struct crypto_type *type = tfm->__crt_alg->cra_type;
+
+	if (type)
+		return type->init(tfm);
+
 	switch (crypto_tfm_alg_type(tfm)) {
 	case CRYPTO_ALG_TYPE_CIPHER:
 		return crypto_init_cipher_ops(tfm);
@@ -257,6 +258,14 @@ static int crypto_init_ops(struct crypto
 
 static void crypto_exit_ops(struct crypto_tfm *tfm)
 {
+	const struct crypto_type *type = tfm->__crt_alg->cra_type;
+
+	if (type) {
+		if (type->exit)
+			type->exit(tfm);
+		return;
+	}
+
 	switch (crypto_tfm_alg_type(tfm)) {
 	case CRYPTO_ALG_TYPE_CIPHER:
 		crypto_exit_cipher_ops(tfm);
@@ -278,26 +287,31 @@ static void crypto_exit_ops(struct crypt
 
 static unsigned int crypto_ctxsize(struct crypto_alg *alg, int flags)
 {
+	const struct crypto_type *type = alg->cra_type;
 	unsigned int len;
 
+	len = alg->cra_alignmask & ~(crypto_tfm_ctx_alignment() - 1);
+	if (type)
+		return len + type->ctxsize(alg);
+
 	switch (alg->cra_flags & CRYPTO_ALG_TYPE_MASK) {
 	default:
 		BUG();
 
 	case CRYPTO_ALG_TYPE_CIPHER:
-		len = crypto_cipher_ctxsize(alg, flags);
+		len += crypto_cipher_ctxsize(alg, flags);
 		break;
 		
 	case CRYPTO_ALG_TYPE_DIGEST:
-		len = crypto_digest_ctxsize(alg, flags);
+		len += crypto_digest_ctxsize(alg, flags);
 		break;
 		
 	case CRYPTO_ALG_TYPE_COMPRESS:
-		len = crypto_compress_ctxsize(alg, flags);
+		len += crypto_compress_ctxsize(alg, flags);
 		break;
 	}
 
-	return len + (alg->cra_alignmask & ~(crypto_tfm_ctx_alignment() - 1));
+	return len;
 }
 
 void crypto_shoot_alg(struct crypto_alg *alg)
diff --git a/include/crypto/algapi.h b/include/crypto/algapi.h
--- a/include/crypto/algapi.h
+++ b/include/crypto/algapi.h
@@ -16,6 +16,12 @@
 
 struct module;
 
+struct crypto_type {
+	unsigned int (*ctxsize)(struct crypto_alg *alg);
+	int (*init)(struct crypto_tfm *tfm);
+	void (*exit)(struct crypto_tfm *tfm);
+};
+
 struct crypto_instance {
 	struct crypto_alg alg;
 
diff --git a/include/linux/crypto.h b/include/linux/crypto.h
--- a/include/linux/crypto.h
+++ b/include/linux/crypto.h
@@ -78,6 +78,7 @@
 
 struct scatterlist;
 struct crypto_tfm;
+struct crypto_type;
 
 struct cipher_desc {
 	struct crypto_tfm *tfm;
@@ -149,6 +150,8 @@ struct crypto_alg {
 	char cra_name[CRYPTO_MAX_ALG_NAME];
 	char cra_driver_name[CRYPTO_MAX_ALG_NAME];
 
+	const struct crypto_type *cra_type;
+
 	union {
 		struct cipher_alg cipher;
 		struct digest_alg digest;
