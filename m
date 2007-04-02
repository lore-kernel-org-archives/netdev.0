From: David Howells <dhowells@redhat.com>
Subject: [PATCH 1/9] AF_RXRPC: Add blkcipher accessors for using kernel data
	directly
Date: Mon, 02 Apr 2007 23:44:58 +0100
Message-ID: <20070402224458.31568.45303.stgit@warthog.cambridge.redhat.com>
References: <20070402224449.31568.17833.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, dhowells@redhat.com
To: torvalds@osdl.org, akpm@osdl.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070402224449.31568.17833.stgit@warthog.cambridge.redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add blkcipher accessors for using kernel data directly without the use of
scatter lists.

Also add a CRYPTO_ALG_DMA algorithm capability flag to permit or deny the use
of DMA and hardware accelerators.  A hardware accelerator may not be used to
access any arbitrary piece of kernel memory lest it not be in a DMA'able
region.  Only software algorithms may do that.

If kernel data is going to be accessed directly, then CRYPTO_ALG_DMA must, for
instance, be passed in the mask of crypto_alloc_blkcipher(), but not the type.

This is used by AF_RXRPC to do quick encryptions, where the size of the data
being encrypted or decrypted is 8 bytes or, occasionally, 16 bytes (ie: one or
two chunks only), and since these data are generally on the stack they may be
split over two pages.  Because they're so small, and because they may be
misaligned, setting up a scatter-gather list is overly expensive.  It is very
unlikely that a hardware FCrypt PCBC engine will be encountered (there is not,
as far as I know, any such thing), and even if one is encountered, the
setup/teardown costs for such small transactions will almost certainly be
prohibitive.

Encrypting and decrypting whole packets, on the other hand, is done through the
scatter-gather list interface as the amount of data is sufficient that the
expense of doing virtual address to page calculations is sufficiently small by
comparison.

Signed-Off-By: David Howells <dhowells@redhat.com>
---

 crypto/blkcipher.c     |    2 +
 crypto/pcbc.c          |   62 +++++++++++++++++++++++++
 include/linux/crypto.h |  118 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 181 insertions(+), 1 deletions(-)

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
index 779aa78..17e786a 100644
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
@@ -529,6 +545,56 @@ static inline int crypto_blkcipher_encrypt_iv(struct blkcipher_desc *desc,
 	return crypto_blkcipher_crt(desc->tfm)->encrypt(desc, dst, src, nbytes);
 }
 
+/**
+ * crypto_blkcipher_encrypt_kernel - Encrypt flat kernel buffer
+ * - @desc - block cipher descriptor indicating the encryption to apply
+ * - @dst - output buffer
+ * - @src - input data
+ * - @nbytes - amount of data
+ *
+ * Encrypt data contained in a flat kernel buffer into another flat kernel
+ * buffer.  This avoids the need to spend resources to set up a scatterlist for
+ * a very small amount of data.  The encryption begins by selecting the
+ * initialisation vector of the actual block cipher as the initialisation
+ * vector to use and update.  This leaves the IV in the cipher altered.
+ *
+ * This should not be used with a cipher that's marked CRYPTO_ALG_DMA as the
+ * DMA process requires a scatterlist to locate the physical pages on which the
+ * data resides.
+ */
+static inline void crypto_blkcipher_encrypt_kernel(struct blkcipher_desc *desc,
+						   u8 *dst, const u8 *src,
+						   unsigned int nbytes)
+{
+	desc->info = crypto_blkcipher_crt(desc->tfm)->iv;
+	crypto_blkcipher_crt(desc->tfm)->encrypt_kernel(desc, dst, src,
+							nbytes);
+}
+
+/**
+ * crypto_blkcipher_encrypt_kernel_iv - Encrypt flat kernel buffer
+ * - @desc - block cipher descriptor indicating the encryption to apply
+ * - @dst - output buffer
+ * - @src - input data
+ * - @nbytes - amount of data
+ *
+ * Encrypt data contained in a flat kernel buffer into another flat kernel
+ * buffer.  This avoids the need to spend resources to set up a scatterlist for
+ * a very small amount of data.  The encryption proceeds from the
+ * initialisation vector held within the block cipher descriptor.
+ *
+ * This should not be used with a cipher that's marked CRYPTO_ALG_DMA as the
+ * DMA process requires a scatterlist to locate the physical pages on which the
+ * data resides.
+ */
+static inline void crypto_blkcipher_encrypt_kernel_iv(
+	struct blkcipher_desc *desc, u8 *dst, const u8 *src,
+	unsigned int nbytes)
+{
+	crypto_blkcipher_crt(desc->tfm)->encrypt_kernel(desc, dst, src,
+							nbytes);
+}
+
 static inline int crypto_blkcipher_decrypt(struct blkcipher_desc *desc,
 					   struct scatterlist *dst,
 					   struct scatterlist *src,
@@ -546,6 +612,56 @@ static inline int crypto_blkcipher_decrypt_iv(struct blkcipher_desc *desc,
 	return crypto_blkcipher_crt(desc->tfm)->decrypt(desc, dst, src, nbytes);
 }
 
+/**
+ * crypto_blkcipher_decrypt_kernel - Decrypt flat kernel buffer
+ * - @desc - block cipher descriptor indicating the decryption to apply
+ * - @dst - output buffer
+ * - @src - input data
+ * - @nbytes - amount of data
+ *
+ * Decrypt data contained in a flat kernel buffer into another flat kernel
+ * buffer.  This avoids the need to spend resources to set up a scatterlist for
+ * a very small amount of data.  The decryption begins by selecting the
+ * initialisation vector of the actual block cipher as the initialisation
+ * vector to use and update.  This leaves the IV in the cipher altered.
+ *
+ * This should not be used with a cipher that's marked CRYPTO_ALG_DMA as the
+ * DMA process requires a scatterlist to locate the physical pages on which the
+ * data resides.
+ */
+static inline void crypto_blkcipher_decrypt_kernel(struct blkcipher_desc *desc,
+						   u8 *dst, const u8 *src,
+						   unsigned int nbytes)
+{
+	desc->info = crypto_blkcipher_crt(desc->tfm)->iv;
+	crypto_blkcipher_crt(desc->tfm)->decrypt_kernel(desc, dst, src,
+							nbytes);
+}
+
+/**
+ * crypto_blkcipher_decrypt_kernel_iv - Decrypt flat kernel buffer
+ * - @desc - block cipher descriptor indicating the decryption to apply
+ * - @dst - output buffer
+ * - @src - input data
+ * - @nbytes - amount of data
+ *
+ * Encrypt data contained in a flat kernel buffer into another flat kernel
+ * buffer.  This avoids the need to spend resources to set up a scatterlist for
+ * a very small amount of data.  The decryption proceeds from the
+ * initialisation vector held within the block cipher descriptor.
+ *
+ * This should not be used with a cipher that's marked CRYPTO_ALG_DMA as the
+ * DMA process requires a scatterlist to locate the physical pages on which the
+ * data resides.
+ */
+static inline void crypto_blkcipher_decrypt_kernel_iv(
+	struct blkcipher_desc *desc, u8 *dst, const u8 *src,
+	unsigned int nbytes)
+{
+	crypto_blkcipher_crt(desc->tfm)->decrypt_kernel(desc, dst, src,
+							nbytes);
+}
+
 static inline void crypto_blkcipher_set_iv(struct crypto_blkcipher *tfm,
 					   const u8 *src, unsigned int len)
 {

