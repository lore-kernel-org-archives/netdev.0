From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 6/16] [CRYPTO] padlock: Added block cipher versions of CBC/ECB
Date: Sun, 13 Aug 2006 22:20:11 +1000
Message-ID: <E1GCEwt-0004g6-00@gondolin.me.apana.org.au>
References: <20060813121722.GA16115@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:10249 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751097AbWHMMUZ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Aug 2006 08:20:25 -0400
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[CRYPTO] padlock: Added block cipher versions of CBC/ECB

This patch adds block cipher algorithms for cbc(aes) and ecb(aes) for
the PadLock device.  Once all users to the old cipher type have been
converted the old cbc/ecb PadLock operations will be removed.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 drivers/crypto/padlock-aes.c |  174 +++++++++++++++++++++++++++++++++++++++++--
 drivers/crypto/padlock.h     |    1 
 2 files changed, 168 insertions(+), 7 deletions(-)

diff --git a/drivers/crypto/padlock-aes.c b/drivers/crypto/padlock-aes.c
--- a/drivers/crypto/padlock-aes.c
+++ b/drivers/crypto/padlock-aes.c
@@ -43,11 +43,11 @@
  * ---------------------------------------------------------------------------
  */
 
+#include <crypto/algapi.h>
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/types.h>
 #include <linux/errno.h>
-#include <linux/crypto.h>
 #include <linux/interrupt.h>
 #include <linux/kernel.h>
 #include <asm/byteorder.h>
@@ -297,9 +297,9 @@ aes_hw_extkey_available(uint8_t key_len)
 	return 0;
 }
 
-static inline struct aes_ctx *aes_ctx(struct crypto_tfm *tfm)
+static inline struct aes_ctx *aes_ctx_common(void *ctx)
 {
-	unsigned long addr = (unsigned long)crypto_tfm_ctx(tfm);
+	unsigned long addr = (unsigned long)ctx;
 	unsigned long align = PADLOCK_ALIGNMENT;
 
 	if (align <= crypto_tfm_ctx_alignment())
@@ -307,6 +307,16 @@ static inline struct aes_ctx *aes_ctx(st
 	return (struct aes_ctx *)ALIGN(addr, align);
 }
 
+static inline struct aes_ctx *aes_ctx(struct crypto_tfm *tfm)
+{
+	return aes_ctx_common(crypto_tfm_ctx(tfm));
+}
+
+static inline struct aes_ctx *blk_aes_ctx(struct crypto_blkcipher *tfm)
+{
+	return aes_ctx_common(crypto_blkcipher_ctx(tfm));
+}
+
 static int aes_set_key(struct crypto_tfm *tfm, const u8 *in_key,
 		       unsigned int key_len)
 {
@@ -507,6 +517,141 @@ static struct crypto_alg aes_alg = {
 	}
 };
 
+static int ecb_aes_encrypt(struct blkcipher_desc *desc,
+			   struct scatterlist *dst, struct scatterlist *src,
+			   unsigned int nbytes)
+{
+	struct aes_ctx *ctx = blk_aes_ctx(desc->tfm);
+	struct blkcipher_walk walk;
+	int err;
+
+	blkcipher_walk_init(&walk, dst, src, nbytes);
+	err = blkcipher_walk_virt(desc, &walk);
+
+	while ((nbytes = walk.nbytes)) {
+		padlock_xcrypt_ecb(walk.src.virt.addr, walk.dst.virt.addr,
+				   ctx->E, &ctx->cword.encrypt,
+				   nbytes / AES_BLOCK_SIZE);
+		nbytes &= AES_BLOCK_SIZE - 1;
+		err = blkcipher_walk_done(desc, &walk, nbytes);
+	}
+
+	return err;
+}
+
+static int ecb_aes_decrypt(struct blkcipher_desc *desc,
+			   struct scatterlist *dst, struct scatterlist *src,
+			   unsigned int nbytes)
+{
+	struct aes_ctx *ctx = blk_aes_ctx(desc->tfm);
+	struct blkcipher_walk walk;
+	int err;
+
+	blkcipher_walk_init(&walk, dst, src, nbytes);
+	err = blkcipher_walk_virt(desc, &walk);
+
+	while ((nbytes = walk.nbytes)) {
+		padlock_xcrypt_ecb(walk.src.virt.addr, walk.dst.virt.addr,
+				   ctx->D, &ctx->cword.decrypt,
+				   nbytes / AES_BLOCK_SIZE);
+		nbytes &= AES_BLOCK_SIZE - 1;
+		err = blkcipher_walk_done(desc, &walk, nbytes);
+	}
+
+	return err;
+}
+
+static struct crypto_alg ecb_aes_alg = {
+	.cra_name		=	"ecb(aes)",
+	.cra_driver_name	=	"ecb-aes-padlock",
+	.cra_priority		=	PADLOCK_COMPOSITE_PRIORITY,
+	.cra_flags		=	CRYPTO_ALG_TYPE_BLKCIPHER,
+	.cra_blocksize		=	AES_BLOCK_SIZE,
+	.cra_ctxsize		=	sizeof(struct aes_ctx),
+	.cra_alignmask		=	PADLOCK_ALIGNMENT - 1,
+	.cra_type		=	&crypto_blkcipher_type,
+	.cra_module		=	THIS_MODULE,
+	.cra_list		=	LIST_HEAD_INIT(ecb_aes_alg.cra_list),
+	.cra_u			=	{
+		.blkcipher = {
+			.min_keysize		=	AES_MIN_KEY_SIZE,
+			.max_keysize		=	AES_MAX_KEY_SIZE,
+			.setkey	   		= 	aes_set_key,
+			.encrypt		=	ecb_aes_encrypt,
+			.decrypt		=	ecb_aes_decrypt,
+		}
+	}
+};
+
+static int cbc_aes_encrypt(struct blkcipher_desc *desc,
+			   struct scatterlist *dst, struct scatterlist *src,
+			   unsigned int nbytes)
+{
+	struct aes_ctx *ctx = blk_aes_ctx(desc->tfm);
+	struct blkcipher_walk walk;
+	int err;
+
+	blkcipher_walk_init(&walk, dst, src, nbytes);
+	err = blkcipher_walk_virt(desc, &walk);
+
+	while ((nbytes = walk.nbytes)) {
+		u8 *iv = padlock_xcrypt_cbc(walk.src.virt.addr,
+					    walk.dst.virt.addr, ctx->E,
+					    walk.iv, &ctx->cword.encrypt,
+					    nbytes / AES_BLOCK_SIZE);
+		memcpy(walk.iv, iv, AES_BLOCK_SIZE);
+		nbytes &= AES_BLOCK_SIZE - 1;
+		err = blkcipher_walk_done(desc, &walk, nbytes);
+	}
+
+	return err;
+}
+
+static int cbc_aes_decrypt(struct blkcipher_desc *desc,
+			   struct scatterlist *dst, struct scatterlist *src,
+			   unsigned int nbytes)
+{
+	struct aes_ctx *ctx = blk_aes_ctx(desc->tfm);
+	struct blkcipher_walk walk;
+	int err;
+
+	blkcipher_walk_init(&walk, dst, src, nbytes);
+	err = blkcipher_walk_virt(desc, &walk);
+
+	while ((nbytes = walk.nbytes)) {
+		padlock_xcrypt_cbc(walk.src.virt.addr, walk.dst.virt.addr,
+				   ctx->D, walk.iv, &ctx->cword.decrypt,
+				   nbytes / AES_BLOCK_SIZE);
+		nbytes &= AES_BLOCK_SIZE - 1;
+		err = blkcipher_walk_done(desc, &walk, nbytes);
+	}
+
+	return err;
+}
+
+static struct crypto_alg cbc_aes_alg = {
+	.cra_name		=	"cbc(aes)",
+	.cra_driver_name	=	"cbc-aes-padlock",
+	.cra_priority		=	PADLOCK_COMPOSITE_PRIORITY,
+	.cra_flags		=	CRYPTO_ALG_TYPE_BLKCIPHER,
+	.cra_blocksize		=	AES_BLOCK_SIZE,
+	.cra_ctxsize		=	sizeof(struct aes_ctx),
+	.cra_alignmask		=	PADLOCK_ALIGNMENT - 1,
+	.cra_type		=	&crypto_blkcipher_type,
+	.cra_module		=	THIS_MODULE,
+	.cra_list		=	LIST_HEAD_INIT(cbc_aes_alg.cra_list),
+	.cra_u			=	{
+		.blkcipher = {
+			.min_keysize		=	AES_MIN_KEY_SIZE,
+			.max_keysize		=	AES_MAX_KEY_SIZE,
+			.ivsize			=	AES_BLOCK_SIZE,
+			.setkey	   		= 	aes_set_key,
+			.encrypt		=	cbc_aes_encrypt,
+			.decrypt		=	cbc_aes_decrypt,
+		}
+	}
+};
+
 static int __init padlock_init(void)
 {
 	int ret;
@@ -522,18 +667,33 @@ static int __init padlock_init(void)
 	}
 
 	gen_tabs();
-	if ((ret = crypto_register_alg(&aes_alg))) {
-		printk(KERN_ERR PFX "VIA PadLock AES initialization failed.\n");
-		return ret;
-	}
+	if ((ret = crypto_register_alg(&aes_alg)))
+		goto aes_err;
+
+	if ((ret = crypto_register_alg(&ecb_aes_alg)))
+		goto ecb_aes_err;
+
+	if ((ret = crypto_register_alg(&cbc_aes_alg)))
+		goto cbc_aes_err;
 
 	printk(KERN_NOTICE PFX "Using VIA PadLock ACE for AES algorithm.\n");
 
+out:
 	return ret;
+
+cbc_aes_err:
+	crypto_unregister_alg(&ecb_aes_alg);
+ecb_aes_err:
+	crypto_unregister_alg(&aes_alg);
+aes_err:
+	printk(KERN_ERR PFX "VIA PadLock AES initialization failed.\n");
+	goto out;
 }
 
 static void __exit padlock_fini(void)
 {
+	crypto_unregister_alg(&cbc_aes_alg);
+	crypto_unregister_alg(&ecb_aes_alg);
 	crypto_unregister_alg(&aes_alg);
 }
 
diff --git a/drivers/crypto/padlock.h b/drivers/crypto/padlock.h
--- a/drivers/crypto/padlock.h
+++ b/drivers/crypto/padlock.h
@@ -18,5 +18,6 @@
 #define PFX	"padlock: "
 
 #define PADLOCK_CRA_PRIORITY	300
+#define PADLOCK_COMPOSITE_PRIORITY 400
 
 #endif	/* _CRYPTO_PADLOCK_H */
