From: David Howells <dhowells@redhat.com>
Subject: [PATCH 1/5] AF_RXRPC: Add blkcipher accessors for using kernel data
	directly
Date: Thu, 08 Mar 2007 22:48:29 +0000
Message-ID: <20070308224829.17456.97200.stgit@warthog.cambridge.redhat.com>
References: <20070308224806.17456.13944.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, hch@infradead.org,
	arjan@infradead.org, dhowells@redhat.com
To: davem@davemloft.net, netdev@vger.kernel.org, herbert.xu@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:35297 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030818AbXCHWtD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Mar 2007 17:49:03 -0500
In-Reply-To: <20070308224806.17456.13944.stgit@warthog.cambridge.redhat.com>
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
 crypto/pcbc.c          |   62 ++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/crypto.h |   53 ++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 116 insertions(+), 1 deletions(-)

diff --git a/crypto/blkcipher.c b/crypto/blkcipher.c
index b5befe8..4498b2d 100644
--- a/crypto/blkcipher.c
+++ b/crypto/blkcipher.c
@@ -376,6 +376,8 @@ static int crypto_init_blkcipher_ops(struct crypto_tfm *tfm, u32 type, u32 mask)
 	crt->setkey = setkey;
 	crt->encrypt = alg->encrypt;
 	crt->decrypt = alg->decrypt;
+	crt->encrypt_kernel = alg->encrypt_kernel;
+	crt->decrypt_kernel = alg->decrypt_kernel;
 
 	addr = (unsigned long)crypto_tfm_ctx(tfm);
 	addr = ALIGN(addr, align);
diff --git a/crypto/pcbc.c b/crypto/pcbc.c
index 5174d7f..fa76111 100644
--- a/crypto/pcbc.c
+++ b/crypto/pcbc.c
@@ -126,6 +126,36 @@ static int crypto_pcbc_encrypt(struct blkcipher_desc *desc,
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
+	BUG_ON(crypto_tfm_alg_capabilities(crypto_cipher_tfm(child)) &
+	       CRYPTO_ALG_DMA);
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
@@ -211,6 +241,36 @@ static int crypto_pcbc_decrypt(struct blkcipher_desc *desc,
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
+	BUG_ON(crypto_tfm_alg_capabilities(crypto_cipher_tfm(child)) &
+		CRYPTO_ALG_DMA);
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
@@ -313,6 +373,8 @@ static struct crypto_instance *crypto_pcbc_alloc(void *param, unsigned int len)
 	inst->alg.cra_blkcipher.setkey = crypto_pcbc_setkey;
 	inst->alg.cra_blkcipher.encrypt = crypto_pcbc_encrypt;
 	inst->alg.cra_blkcipher.decrypt = crypto_pcbc_decrypt;
+	inst->alg.cra_blkcipher.encrypt_kernel = crypto_pcbc_encrypt_kernel;
+	inst->alg.cra_blkcipher.decrypt_kernel = crypto_pcbc_decrypt_kernel;
 
 out_put_alg:
 	crypto_mod_put(alg);
diff --git a/include/linux/crypto.h b/include/linux/crypto.h
index 779aa78..ce092fe 100644
--- a/include/linux/crypto.h
+++ b/include/linux/crypto.h
@@ -40,7 +40,10 @@
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
@@ -125,6 +128,10 @@ struct blkcipher_alg {
 	int (*decrypt)(struct blkcipher_desc *desc,
 		       struct scatterlist *dst, struct scatterlist *src,
 		       unsigned int nbytes);
+	int (*encrypt_kernel)(struct blkcipher_desc *desc, u8 *dst,
+			      const u8 *src, unsigned int nbytes);
+	int (*decrypt_kernel)(struct blkcipher_desc *desc, u8 *dst,
+			      const u8 *src, unsigned int nbytes);
 
 	unsigned int min_keysize;
 	unsigned int max_keysize;
@@ -240,6 +247,10 @@ struct blkcipher_tfm {
 		       struct scatterlist *src, unsigned int nbytes);
 	int (*decrypt)(struct blkcipher_desc *desc, struct scatterlist *dst,
 		       struct scatterlist *src, unsigned int nbytes);
+	int (*encrypt_kernel)(struct blkcipher_desc *desc, u8 *dst,
+			      const u8 *src, unsigned int nbytes);
+	int (*decrypt_kernel)(struct blkcipher_desc *desc, u8 *dst,
+			      const u8 *src, unsigned int nbytes);
 };
 
 struct cipher_tfm {
@@ -372,6 +383,11 @@ static inline u32 crypto_tfm_alg_type(struct crypto_tfm *tfm)
 	return tfm->__crt_alg->cra_flags & CRYPTO_ALG_TYPE_MASK;
 }
 
+static inline u32 crypto_tfm_alg_capabilities(struct crypto_tfm *tfm)
+{
+	return tfm->__crt_alg->cra_flags & CRYPTO_ALG_CAP_MASK;
+}
+
 static inline unsigned int crypto_tfm_alg_blocksize(struct crypto_tfm *tfm)
 {
 	return tfm->__crt_alg->cra_blocksize;
@@ -529,6 +545,23 @@ static inline int crypto_blkcipher_encrypt_iv(struct blkcipher_desc *desc,
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
@@ -546,6 +579,24 @@ static inline int crypto_blkcipher_decrypt_iv(struct blkcipher_desc *desc,
 	return crypto_blkcipher_crt(desc->tfm)->decrypt(desc, dst, src, nbytes);
 }
 
+static inline void crypto_blkcipher_decrypt_kernel(struct blkcipher_desc *desc,
+						   u8 *dst, const u8 *src,
+						   unsigned int nbytes)
+{
+	desc->info = crypto_blkcipher_crt(desc->tfm)->iv;
+	crypto_blkcipher_crt(desc->tfm)->decrypt_kernel(desc, dst, src,
+							nbytes);
+}
+
+static inline
+void crypto_blkcipher_decrypt_kernel_iv(struct blkcipher_desc *desc,
+					u8 *dst, const u8 *src,
+					unsigned int nbytes)
+{
+	crypto_blkcipher_crt(desc->tfm)->decrypt_kernel(desc, dst, src,
+							nbytes);
+}
+
 static inline void crypto_blkcipher_set_iv(struct crypto_blkcipher *tfm,
 					   const u8 *src, unsigned int len)
 {

