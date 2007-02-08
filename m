From: David Howells <dhowells@redhat.com>
Subject: [PATCH 3/5] Crypto: Add blkcipher accessors for using kernel data directly
Date: Thu, 08 Feb 2007 16:32:29 +0000
Message-ID: <20070208163229.23973.71555.stgit@warthog.cambridge.redhat.com>
References: <20070208163211.23973.5877.stgit@warthog.cambridge.redhat.com>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: hch@infradead.org, arjan@infradead.org, dhowells@redhat.com
To: davem@davemloft.net, netdev@vger.kernel.org, herbert.xu@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:38828 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423182AbXBHQcj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Feb 2007 11:32:39 -0500
In-Reply-To: <20070208163211.23973.5877.stgit@warthog.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add blkcipher accessors for using kernel data directly without the use of
scatter lists.

Also add a CRYPTO_ALG_DMA algorithm capability flag to permit or deny the use
of DMA and hardware accelerators.  A hardware accelerator may not be used to
access any arbitrary piece of kernel memory lest it not be in a DMA'able
region.  Only software algorithms may do that.

If kernel data is going to be accessed directly, then CRYPTO_ALG_DMA must, for
instance, be passed in the mask of crypto_alloc_blkcipher(), but not the type.

Signed-Off-By: David Howells <dhowells@redhat.com>
---

 crypto/blkcipher.c     |    2 ++
 crypto/pcbc.c          |   60 ++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/crypto.h |   52 +++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 113 insertions(+), 1 deletions(-)

diff --git a/crypto/blkcipher.c b/crypto/blkcipher.c
index 6e93004..d43c22e 100644
--- a/crypto/blkcipher.c
+++ b/crypto/blkcipher.c
@@ -371,6 +371,8 @@ static int crypto_init_blkcipher_ops(str
 	crt->setkey = setkey;
 	crt->encrypt = alg->encrypt;
 	crt->decrypt = alg->decrypt;
+	crt->encrypt_kernel = alg->encrypt_kernel;
+	crt->decrypt_kernel = alg->decrypt_kernel;
 
 	addr = (unsigned long)crypto_tfm_ctx(tfm);
 	addr = ALIGN(addr, align);
diff --git a/crypto/pcbc.c b/crypto/pcbc.c
index 0ffb46e..5ac751e 100644
--- a/crypto/pcbc.c
+++ b/crypto/pcbc.c
@@ -126,6 +126,35 @@ static int crypto_pcbc_encrypt(struct bl
 	return err;
 }
 
+static int crypto_pcbc_encrypt_kernel(struct blkcipher_desc *desc,
+				      u8 *dst, const u8 *src,
+				      unsigned int nbytes)
+{
+	struct blkcipher_walk walk;
+	struct crypto_blkcipher *tfm = desc->tfm;
+	struct crypto_pcbc_ctx *ctx = crypto_blkcipher_ctx(tfm);
+	struct crypto_cipher *child = ctx->child;
+	void (*xor)(u8 *, const u8 *, unsigned int bs) = ctx->xor;
+
+	BUG_ON(crypto_tfm_alg_capabilities(child) & CRYPTO_ALG_DMA);
+
+	if (nbytes == 0)
+		return 0;
+
+	memset(&walk, 0, sizeof(walk));
+	walk.src.virt.addr = (u8 *) src;
+	walk.dst.virt.addr = (u8 *) dst;
+	walk.nbytes = nbytes;
+	walk.total = nbytes;
+	walk.iv = desc->info;
+
+	if (walk.src.virt.addr == walk.dst.virt.addr)
+		nbytes = crypto_pcbc_encrypt_inplace(desc, &walk, child, xor);
+	else
+		nbytes = crypto_pcbc_encrypt_segment(desc, &walk, child, xor);
+	return 0;
+}
+
 static int crypto_pcbc_decrypt_segment(struct blkcipher_desc *desc,
 				       struct blkcipher_walk *walk,
 				       struct crypto_cipher *tfm,
@@ -211,6 +240,35 @@ static int crypto_pcbc_decrypt(struct bl
 	return err;
 }
 
+static int crypto_pcbc_decrypt_kernel(struct blkcipher_desc *desc,
+				      u8 *dst, const u8 *src,
+				      unsigned int nbytes)
+{
+	struct blkcipher_walk walk;
+	struct crypto_blkcipher *tfm = desc->tfm;
+	struct crypto_pcbc_ctx *ctx = crypto_blkcipher_ctx(tfm);
+	struct crypto_cipher *child = ctx->child;
+	void (*xor)(u8 *, const u8 *, unsigned int bs) = ctx->xor;
+
+	BUG_ON(crypto_tfm_alg_capabilities(child) & CRYPTO_ALG_DMA);
+
+	if (nbytes == 0)
+		return 0;
+
+	memset(&walk, 0, sizeof(walk));
+	walk.src.virt.addr = (u8 *) src;
+	walk.dst.virt.addr = (u8 *) dst;
+	walk.nbytes = nbytes;
+	walk.total = nbytes;
+	walk.iv = desc->info;
+
+	if (walk.src.virt.addr == walk.dst.virt.addr)
+		nbytes = crypto_pcbc_decrypt_inplace(desc, &walk, child, xor);
+	else
+		nbytes = crypto_pcbc_decrypt_segment(desc, &walk, child, xor);
+	return 0;
+}
+
 static void xor_byte(u8 *a, const u8 *b, unsigned int bs)
 {
 	do {
@@ -312,6 +370,8 @@ static struct crypto_instance *crypto_pc
 	inst->alg.cra_blkcipher.setkey = crypto_pcbc_setkey;
 	inst->alg.cra_blkcipher.encrypt = crypto_pcbc_encrypt;
 	inst->alg.cra_blkcipher.decrypt = crypto_pcbc_decrypt;
+	inst->alg.cra_blkcipher.encrypt_kernel = crypto_pcbc_encrypt_kernel;
+	inst->alg.cra_blkcipher.decrypt_kernel = crypto_pcbc_decrypt_kernel;
 
 out_put_alg:
 	crypto_mod_put(alg);
diff --git a/include/linux/crypto.h b/include/linux/crypto.h
index 4aa9046..00ec299 100644
--- a/include/linux/crypto.h
+++ b/include/linux/crypto.h
@@ -40,7 +40,10 @@ #define CRYPTO_ALG_TYPE_HASH_MASK	0x0000
 #define CRYPTO_ALG_LARVAL		0x00000010
 #define CRYPTO_ALG_DEAD			0x00000020
 #define CRYPTO_ALG_DYING		0x00000040
-#define CRYPTO_ALG_ASYNC		0x00000080
+
+#define CRYPTO_ALG_CAP_MASK		0x00000180	/* capabilities mask */
+#define CRYPTO_ALG_ASYNC		0x00000080	/* capable of async operation */
+#define CRYPTO_ALG_DMA			0x00000100	/* capable of using of DMA */
 
 /*
  * Set this bit if and only if the algorithm requires another algorithm of
@@ -135,6 +138,10 @@ struct blkcipher_alg {
 	int (*decrypt)(struct blkcipher_desc *desc,
 		       struct scatterlist *dst, struct scatterlist *src,
 		       unsigned int nbytes);
+	int (*encrypt_kernel)(struct blkcipher_desc *desc, u8 *dst,
+			      const u8 *src, unsigned int nbytes);
+	int (*decrypt_kernel)(struct blkcipher_desc *desc, u8 *dst,
+			      const u8 *src, unsigned int nbytes);
 
 	unsigned int min_keysize;
 	unsigned int max_keysize;
@@ -268,6 +275,10 @@ struct blkcipher_tfm {
 		       struct scatterlist *src, unsigned int nbytes);
 	int (*decrypt)(struct blkcipher_desc *desc, struct scatterlist *dst,
 		       struct scatterlist *src, unsigned int nbytes);
+	int (*encrypt_kernel)(struct blkcipher_desc *desc, u8 *dst,
+			      const u8 *src, unsigned int nbytes);
+	int (*decrypt_kernel)(struct blkcipher_desc *desc, u8 *dst,
+			      const u8 *src, unsigned int nbytes);
 };
 
 struct cipher_tfm {
@@ -395,6 +406,11 @@ static inline u32 crypto_tfm_alg_type(st
 	return tfm->__crt_alg->cra_flags & CRYPTO_ALG_TYPE_MASK;
 }
 
+static inline u32 crypto_tfm_alg_capabilities(struct crypto_tfm *tfm)
+{
+	return tfm->__crt_alg->cra_flags & CRYPTO_ALG_CAP_MASK;
+}
+
 static unsigned int crypto_tfm_alg_min_keysize(struct crypto_tfm *tfm)
 	__deprecated;
 static inline unsigned int crypto_tfm_alg_min_keysize(struct crypto_tfm *tfm)
@@ -581,6 +597,23 @@ static inline int crypto_blkcipher_encry
 	return crypto_blkcipher_crt(desc->tfm)->encrypt(desc, dst, src, nbytes);
 }
 
+static inline void crypto_blkcipher_encrypt_kernel(struct blkcipher_desc *desc,
+						   u8 *dst, const u8 *src,
+						   unsigned int nbytes)
+{
+	desc->info = crypto_blkcipher_crt(desc->tfm)->iv;
+	crypto_blkcipher_crt(desc->tfm)->encrypt_kernel(desc, dst, src,
+							nbytes);
+}
+
+static inline void crypto_blkcipher_encrypt_kernel_iv(struct blkcipher_desc *desc,
+						      u8 *dst, const u8 *src,
+						      unsigned int nbytes)
+{
+	crypto_blkcipher_crt(desc->tfm)->encrypt_kernel(desc, dst, src,
+							nbytes);
+}
+
 static inline int crypto_blkcipher_decrypt(struct blkcipher_desc *desc,
 					   struct scatterlist *dst,
 					   struct scatterlist *src,
@@ -598,6 +631,23 @@ static inline int crypto_blkcipher_decry
 	return crypto_blkcipher_crt(desc->tfm)->decrypt(desc, dst, src, nbytes);
 }
 
+static inline void crypto_cipher_decrypt_kernel(struct blkcipher_desc *desc,
+						u8 *dst, const u8 *src,
+						unsigned int nbytes)
+{
+	desc->info = crypto_blkcipher_crt(desc->tfm)->iv;
+	crypto_blkcipher_crt(desc->tfm)->decrypt_kernel(desc, dst, src,
+							nbytes);
+}
+
+static inline void crypto_cipher_decrypt_kernel_iv(struct blkcipher_desc *desc,
+						   u8 *dst, const u8 *src,
+						   unsigned int nbytes)
+{
+	crypto_blkcipher_crt(desc->tfm)->decrypt_kernel(desc, dst, src,
+							nbytes);
+}
+
 static inline void crypto_blkcipher_set_iv(struct crypto_blkcipher *tfm,
 					   const u8 *src, unsigned int len)
 {
