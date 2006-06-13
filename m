From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: [PATCH 1/2] AES-XCBC-MAC
Date: Wed, 14 Jun 2006 00:44:00 +0900
Message-ID: <1150213440.4200.36.camel@hookipa>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 221x116x13x66.ap221.ftth.ucom.ne.jp ([221.116.13.66]:53389 "EHLO
	miyazawa.org") by vger.kernel.org with ESMTP id S932149AbWFMPoW
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jun 2006 11:44:22 -0400
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is preparation to introduce AES-XCBC-MAC.
- introducing common interface "keyed hash"
- making HMAC use the interface

---
commit 9c6b9affbacf12fc1e32868eaa14fef279b2696c
tree 67b19707fae179e20bfb8060444f287d0bda7bb1
parent 650fb8382287f7990d5127a82a54295139224606
author Kazunori MIYAZAWA <kazunori@miyazawa.org> Tue, 13 Jun 2006 10:02:54 +0900
committer Kazunori MIYAZAWA <kazunori@miyazawa.org> Tue, 13 Jun 2006 10:02:54 +0900

 crypto/digest.c        |   23 +++++++++++++++++++----
 crypto/hmac.c          |   36 +++++++++++++++++++++++++-----------
 crypto/tcrypt.c        |    2 +-
 include/linux/crypto.h |   31 +++++++++++++++++++++++++------
 4 files changed, 70 insertions(+), 22 deletions(-)

diff --git a/crypto/digest.c b/crypto/digest.c
index d9b6ac9..66bc263 100644
--- a/crypto/digest.c
+++ b/crypto/digest.c
@@ -85,11 +85,13 @@ static void digest(struct crypto_tfm *tf
 
 int crypto_init_digest_flags(struct crypto_tfm *tfm, u32 flags)
 {
-	return flags ? -EINVAL : 0;
+	tfm->crt_digest.cit_mode = flags & CRYPTO_TFM_MODE_MASK;
+	return 0;
 }
 
 int crypto_init_digest_ops(struct crypto_tfm *tfm)
 {
+	int ret = 0;
 	struct digest_tfm *ops = &tfm->crt_digest;
 	
 	ops->dit_init	= init;
@@ -97,11 +99,24 @@ int crypto_init_digest_ops(struct crypto
 	ops->dit_final	= final;
 	ops->dit_digest	= digest;
 	ops->dit_setkey	= setkey;
-	
-	return crypto_alloc_hmac_block(tfm);
+
+#ifdef CONFIG_CRYPTO_HMAC
+	if (tfm->crt_digest.cit_mode & CRYPTO_TFM_MODE_HMAC) {
+		ret = crypto_alloc_hmac_block(tfm);
+		tfm->crt_keyedhash.kht_init = crypto_hmac_init;
+		tfm->crt_keyedhash.kht_update = crypto_hmac_update;
+		tfm->crt_keyedhash.kht_final = crypto_hmac_final;
+		tfm->crt_keyedhash.keyed_hash = crypto_hmac;
+		tfm->crt_keyedhash.kht_digestsize = crypto_tfm_alg_digestsize;
+	}
+#endif
+	return ret;
 }
 
 void crypto_exit_digest_ops(struct crypto_tfm *tfm)
 {
-	crypto_free_hmac_block(tfm);
+#ifdef CONFIG_CRYPTO_HMAC
+	if (tfm->crt_digest.cit_mode & CRYPTO_TFM_MODE_HMAC)
+		crypto_free_hmac_block(tfm);
+#endif
 }
diff --git a/crypto/hmac.c b/crypto/hmac.c
index 46120de..d9610ca 100644
--- a/crypto/hmac.c
+++ b/crypto/hmac.c
@@ -34,10 +34,10 @@ int crypto_alloc_hmac_block(struct crypt
 	int ret = 0;
 
 	BUG_ON(!crypto_tfm_alg_blocksize(tfm));
-	
-	tfm->crt_digest.dit_hmac_block = kmalloc(crypto_tfm_alg_blocksize(tfm),
+
+	tfm->crt_keyedhash.kht_hmac_block = kmalloc(crypto_tfm_alg_blocksize(tfm),
 	                                         GFP_KERNEL);
-	if (tfm->crt_digest.dit_hmac_block == NULL)
+	if (tfm->crt_keyedhash.kht_hmac_block == NULL)
 		ret = -ENOMEM;
 
 	return ret;
@@ -46,14 +46,16 @@ int crypto_alloc_hmac_block(struct crypt
 
 void crypto_free_hmac_block(struct crypto_tfm *tfm)
 {
-	kfree(tfm->crt_digest.dit_hmac_block);
+	kfree(tfm->crt_keyedhash.kht_hmac_block);
 }
 
-void crypto_hmac_init(struct crypto_tfm *tfm, u8 *key, unsigned int *keylen)
+int crypto_hmac_init(struct crypto_tfm *tfm, u8 *key, unsigned int *keylen)
 {
 	unsigned int i;
 	struct scatterlist tmp;
-	char *ipad = tfm->crt_digest.dit_hmac_block;
+	char *ipad = tfm->crt_keyedhash.kht_hmac_block;
+
+	BUG_ON(ipad == NULL);
 	
 	if (*keylen > crypto_tfm_alg_blocksize(tfm)) {
 		hash_key(tfm, key, *keylen);
@@ -70,6 +72,8 @@ void crypto_hmac_init(struct crypto_tfm 
 	
 	crypto_digest_init(tfm);
 	crypto_digest_update(tfm, &tmp, 1);
+
+	return 0;
 }
 
 void crypto_hmac_update(struct crypto_tfm *tfm,
@@ -78,13 +82,15 @@ void crypto_hmac_update(struct crypto_tf
 	crypto_digest_update(tfm, sg, nsg);
 }
 
-void crypto_hmac_final(struct crypto_tfm *tfm, u8 *key,
+int crypto_hmac_final(struct crypto_tfm *tfm, u8 *key,
                        unsigned int *keylen, u8 *out)
 {
 	unsigned int i;
 	struct scatterlist tmp;
-	char *opad = tfm->crt_digest.dit_hmac_block;
+	char *opad = tfm->crt_keyedhash.kht_hmac_block;
 	
+	BUG_ON(opad == NULL);
+
 	if (*keylen > crypto_tfm_alg_blocksize(tfm)) {
 		hash_key(tfm, key, *keylen);
 		*keylen = crypto_tfm_alg_digestsize(tfm);
@@ -107,14 +113,22 @@ void crypto_hmac_final(struct crypto_tfm
 	
 	crypto_digest_update(tfm, &tmp, 1);
 	crypto_digest_final(tfm, out);
+
+	return 0;
 }
 
-void crypto_hmac(struct crypto_tfm *tfm, u8 *key, unsigned int *keylen,
+int crypto_hmac(struct crypto_tfm *tfm, u8 *key, unsigned int *keylen,
                  struct scatterlist *sg, unsigned int nsg, u8 *out)
 {
-	crypto_hmac_init(tfm, key, keylen);
+	int ret = 0;
+
+	ret = crypto_hmac_init(tfm, key, keylen);
+	if (ret != 0)
+		return ret;
 	crypto_hmac_update(tfm, sg, nsg);
-	crypto_hmac_final(tfm, key, keylen, out);
+	ret = crypto_hmac_final(tfm, key, keylen, out);
+
+	return ret;
 }
 
 EXPORT_SYMBOL_GPL(crypto_hmac_init);
diff --git a/crypto/tcrypt.c b/crypto/tcrypt.c
index 49e344f..37aeced 100644
--- a/crypto/tcrypt.c
+++ b/crypto/tcrypt.c
@@ -180,7 +180,7 @@ static void test_hmac(char *algo, struct
 	struct hmac_testvec *hmac_tv;
 	unsigned int tsize, klen;
 
-	tfm = crypto_alloc_tfm(algo, 0);
+	tfm = crypto_alloc_tfm(algo, CRYPTO_TFM_MODE_HMAC);
 	if (tfm == NULL) {
 		printk("failed to load transform for %s\n", algo);
 		return;
diff --git a/include/linux/crypto.h b/include/linux/crypto.h
index 0ab1bc1..1ade651 100644
--- a/include/linux/crypto.h
+++ b/include/linux/crypto.h
@@ -44,6 +44,7 @@
 #define CRYPTO_TFM_MODE_CBC		0x00000002
 #define CRYPTO_TFM_MODE_CFB		0x00000004
 #define CRYPTO_TFM_MODE_CTR		0x00000008
+#define CRYPTO_TFM_MODE_HMAC		0x00000080
 
 #define CRYPTO_TFM_REQ_WEAK_KEY		0x00000100
 #define CRYPTO_TFM_REQ_MAY_SLEEP	0x00000200
@@ -192,6 +193,7 @@ struct cipher_tfm {
 };
 
 struct digest_tfm {
+	u32 cit_mode;
 	void (*dit_init)(struct crypto_tfm *tfm);
 	void (*dit_update)(struct crypto_tfm *tfm,
 	                   struct scatterlist *sg, unsigned int nsg);
@@ -200,9 +202,6 @@ struct digest_tfm {
 	                   unsigned int nsg, u8 *out);
 	int (*dit_setkey)(struct crypto_tfm *tfm,
 	                  const u8 *key, unsigned int keylen);
-#ifdef CONFIG_CRYPTO_HMAC
-	void *dit_hmac_block;
-#endif
 };
 
 struct compress_tfm {
@@ -218,6 +217,23 @@ struct compress_tfm {
 #define crt_digest	crt_u.digest
 #define crt_compress	crt_u.compress
 
+#if defined(CONFIG_CRYPTO_HMAC)
+
+#define kht_hmac_block	kht_u.hmac_block
+
+struct keyed_hash_tfm {
+	int (*kht_init)(struct crypto_tfm *tfm, u8 *key, unsigned int *keylen);
+	void (*kht_update)(struct crypto_tfm *tfm, struct scatterlist *sg, unsigned int nsg);
+	int (*kht_final)(struct crypto_tfm *tfm, u8 *key, unsigned int *keylen, u8 *out);
+	int (*keyed_hash)(struct crypto_tfm *tfm, u8 *key, unsigned int *keylen,
+			 struct scatterlist *sg, unsigned int nsg, u8 *out);
+	unsigned int (*kht_digestsize)(struct crypto_tfm *tfm);
+	union {
+		void *hmac_block;
+	} kht_u;
+};
+#endif
+
 struct crypto_tfm {
 
 	u32 crt_flags;
@@ -228,6 +244,9 @@ struct crypto_tfm {
 		struct compress_tfm compress;
 	} crt_u;
 	
+#if defined(CONFIG_CRYPTO_HMAC)
+	struct keyed_hash_tfm crt_keyedhash;
+#endif	
 	struct crypto_alg *__crt_alg;
 
 	char __crt_ctx[] __attribute__ ((__aligned__));
@@ -431,12 +450,12 @@ static inline int crypto_comp_decompress
  * HMAC support.
  */
 #ifdef CONFIG_CRYPTO_HMAC
-void crypto_hmac_init(struct crypto_tfm *tfm, u8 *key, unsigned int *keylen);
+int crypto_hmac_init(struct crypto_tfm *tfm, u8 *key, unsigned int *keylen);
 void crypto_hmac_update(struct crypto_tfm *tfm,
                         struct scatterlist *sg, unsigned int nsg);
-void crypto_hmac_final(struct crypto_tfm *tfm, u8 *key,
+int crypto_hmac_final(struct crypto_tfm *tfm, u8 *key,
                        unsigned int *keylen, u8 *out);
-void crypto_hmac(struct crypto_tfm *tfm, u8 *key, unsigned int *keylen,
+int crypto_hmac(struct crypto_tfm *tfm, u8 *key, unsigned int *keylen,
                  struct scatterlist *sg, unsigned int nsg, u8 *out);
 #endif	/* CONFIG_CRYPTO_HMAC */
 


