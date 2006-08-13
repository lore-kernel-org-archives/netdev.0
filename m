From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 7/16] [CRYPTO] s390: Added block cipher versions of CBC/ECB
Date: Sun, 13 Aug 2006 22:20:12 +1000
Message-ID: <E1GCEwu-0004g9-00@gondolin.me.apana.org.au>
References: <20060813121722.GA16115@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:11017 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751090AbWHMMU2
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Aug 2006 08:20:28 -0400
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[CRYPTO] s390: Added block cipher versions of CBC/ECB

This patch adds block cipher algorithms for S390.  Once all users of the
old cipher type have been converted the existing CBC/ECB non-block cipher
operations will be removed.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 arch/s390/crypto/aes_s390.c   |  218 +++++++++++++++++++++++
 arch/s390/crypto/crypt_s390.h |    1 
 arch/s390/crypto/des_s390.c   |  385 ++++++++++++++++++++++++++++++++++++++++--
 3 files changed, 590 insertions(+), 14 deletions(-)

diff --git a/arch/s390/crypto/aes_s390.c b/arch/s390/crypto/aes_s390.c
--- a/arch/s390/crypto/aes_s390.c
+++ b/arch/s390/crypto/aes_s390.c
@@ -16,9 +16,9 @@
  *
  */
 
+#include <crypto/algapi.h>
 #include <linux/module.h>
 #include <linux/init.h>
-#include <linux/crypto.h>
 #include "crypt_s390.h"
 
 #define AES_MIN_KEY_SIZE	16
@@ -34,6 +34,8 @@ int has_aes_256 = 0;
 struct s390_aes_ctx {
 	u8 iv[AES_BLOCK_SIZE];
 	u8 key[AES_MAX_KEY_SIZE];
+	long enc;
+	long dec;
 	int key_len;
 };
 
@@ -244,6 +246,189 @@ static struct crypto_alg aes_alg = {
 	}
 };
 
+static int ecb_aes_set_key(struct crypto_tfm *tfm, const u8 *in_key,
+			   unsigned int key_len)
+{
+	struct s390_aes_ctx *sctx = crypto_tfm_ctx(tfm);
+
+	switch (key_len) {
+	case 16:
+		sctx->enc = KM_AES_128_ENCRYPT;
+		sctx->dec = KM_AES_128_DECRYPT;
+		break;
+	case 24:
+		sctx->enc = KM_AES_192_ENCRYPT;
+		sctx->dec = KM_AES_192_DECRYPT;
+		break;
+	case 32:
+		sctx->enc = KM_AES_256_ENCRYPT;
+		sctx->dec = KM_AES_256_DECRYPT;
+		break;
+	}
+
+	return aes_set_key(tfm, in_key, key_len);
+}
+
+static int ecb_aes_crypt(struct blkcipher_desc *desc, long func, void *param,
+			 struct blkcipher_walk *walk)
+{
+	int ret = blkcipher_walk_virt(desc, walk);
+	unsigned int nbytes;
+
+	while ((nbytes = walk->nbytes)) {
+		/* only use complete blocks */
+		unsigned int n = nbytes & ~(AES_BLOCK_SIZE - 1);
+		u8 *out = walk->dst.virt.addr;
+		u8 *in = walk->src.virt.addr;
+
+		ret = crypt_s390_km(func, param, out, in, n);
+		BUG_ON((ret < 0) || (ret != n));
+
+		nbytes &= AES_BLOCK_SIZE - 1;
+		ret = blkcipher_walk_done(desc, walk, nbytes);
+	}
+
+	return ret;
+}
+
+static int ecb_aes_encrypt(struct blkcipher_desc *desc,
+			   struct scatterlist *dst, struct scatterlist *src,
+			   unsigned int nbytes)
+{
+	struct s390_aes_ctx *sctx = crypto_blkcipher_ctx(desc->tfm);
+	struct blkcipher_walk walk;
+
+	blkcipher_walk_init(&walk, dst, src, nbytes);
+	return ecb_aes_crypt(desc, sctx->enc, sctx->key, &walk);
+}
+
+static int ecb_aes_decrypt(struct blkcipher_desc *desc,
+			   struct scatterlist *dst, struct scatterlist *src,
+			   unsigned int nbytes)
+{
+	struct s390_aes_ctx *sctx = crypto_blkcipher_ctx(desc->tfm);
+	struct blkcipher_walk walk;
+
+	blkcipher_walk_init(&walk, dst, src, nbytes);
+	return ecb_aes_crypt(desc, sctx->dec, sctx->key, &walk);
+}
+
+static struct crypto_alg ecb_aes_alg = {
+	.cra_name		=	"ecb(aes)",
+	.cra_driver_name	=	"ecb-aes-s390",
+	.cra_priority		=	CRYPT_S390_COMPOSITE_PRIORITY,
+	.cra_flags		=	CRYPTO_ALG_TYPE_BLKCIPHER,
+	.cra_blocksize		=	AES_BLOCK_SIZE,
+	.cra_ctxsize		=	sizeof(struct s390_aes_ctx),
+	.cra_type		=	&crypto_blkcipher_type,
+	.cra_module		=	THIS_MODULE,
+	.cra_list		=	LIST_HEAD_INIT(ecb_aes_alg.cra_list),
+	.cra_u			=	{
+		.blkcipher = {
+			.min_keysize		=	AES_MIN_KEY_SIZE,
+			.max_keysize		=	AES_MAX_KEY_SIZE,
+			.setkey			=	ecb_aes_set_key,
+			.encrypt		=	ecb_aes_encrypt,
+			.decrypt		=	ecb_aes_decrypt,
+		}
+	}
+};
+
+static int cbc_aes_set_key(struct crypto_tfm *tfm, const u8 *in_key,
+			   unsigned int key_len)
+{
+	struct s390_aes_ctx *sctx = crypto_tfm_ctx(tfm);
+
+	switch (key_len) {
+	case 16:
+		sctx->enc = KMC_AES_128_ENCRYPT;
+		sctx->dec = KMC_AES_128_DECRYPT;
+		break;
+	case 24:
+		sctx->enc = KMC_AES_192_ENCRYPT;
+		sctx->dec = KMC_AES_192_DECRYPT;
+		break;
+	case 32:
+		sctx->enc = KMC_AES_256_ENCRYPT;
+		sctx->dec = KMC_AES_256_DECRYPT;
+		break;
+	}
+
+	return aes_set_key(tfm, in_key, key_len);
+}
+
+static int cbc_aes_crypt(struct blkcipher_desc *desc, long func, void *param,
+			 struct blkcipher_walk *walk)
+{
+	int ret = blkcipher_walk_virt(desc, walk);
+	unsigned int nbytes = walk->nbytes;
+
+	if (!nbytes)
+		goto out;
+
+	memcpy(param, walk->iv, AES_BLOCK_SIZE);
+	do {
+		/* only use complete blocks */
+		unsigned int n = nbytes & ~(AES_BLOCK_SIZE - 1);
+		u8 *out = walk->dst.virt.addr;
+		u8 *in = walk->src.virt.addr;
+
+		ret = crypt_s390_kmc(func, param, out, in, n);
+		BUG_ON((ret < 0) || (ret != n));
+
+		nbytes &= AES_BLOCK_SIZE - 1;
+		ret = blkcipher_walk_done(desc, walk, nbytes);
+	} while ((nbytes = walk->nbytes));
+	memcpy(walk->iv, param, AES_BLOCK_SIZE);
+
+out:
+	return ret;
+}
+
+static int cbc_aes_encrypt(struct blkcipher_desc *desc,
+			   struct scatterlist *dst, struct scatterlist *src,
+			   unsigned int nbytes)
+{
+	struct s390_aes_ctx *sctx = crypto_blkcipher_ctx(desc->tfm);
+	struct blkcipher_walk walk;
+
+	blkcipher_walk_init(&walk, dst, src, nbytes);
+	return cbc_aes_crypt(desc, sctx->enc, sctx->iv, &walk);
+}
+
+static int cbc_aes_decrypt(struct blkcipher_desc *desc,
+			   struct scatterlist *dst, struct scatterlist *src,
+			   unsigned int nbytes)
+{
+	struct s390_aes_ctx *sctx = crypto_blkcipher_ctx(desc->tfm);
+	struct blkcipher_walk walk;
+
+	blkcipher_walk_init(&walk, dst, src, nbytes);
+	return cbc_aes_crypt(desc, sctx->dec, sctx->iv, &walk);
+}
+
+static struct crypto_alg cbc_aes_alg = {
+	.cra_name		=	"cbc(aes)",
+	.cra_driver_name	=	"cbc-aes-s390",
+	.cra_priority		=	CRYPT_S390_COMPOSITE_PRIORITY,
+	.cra_flags		=	CRYPTO_ALG_TYPE_BLKCIPHER,
+	.cra_blocksize		=	AES_BLOCK_SIZE,
+	.cra_ctxsize		=	sizeof(struct s390_aes_ctx),
+	.cra_type		=	&crypto_blkcipher_type,
+	.cra_module		=	THIS_MODULE,
+	.cra_list		=	LIST_HEAD_INIT(cbc_aes_alg.cra_list),
+	.cra_u			=	{
+		.blkcipher = {
+			.min_keysize		=	AES_MIN_KEY_SIZE,
+			.max_keysize		=	AES_MAX_KEY_SIZE,
+			.ivsize			=	AES_BLOCK_SIZE,
+			.setkey			=	cbc_aes_set_key,
+			.encrypt		=	cbc_aes_encrypt,
+			.decrypt		=	cbc_aes_decrypt,
+		}
+	}
+};
+
 static int __init aes_init(void)
 {
 	int ret;
@@ -259,13 +444,40 @@ static int __init aes_init(void)
 		return -ENOSYS;
 
 	ret = crypto_register_alg(&aes_alg);
-	if (ret != 0)
-		printk(KERN_INFO "crypt_s390: aes_s390 couldn't be loaded.\n");
+	if (ret != 0) {
+		printk(KERN_INFO "crypt_s390: aes-s390 couldn't be loaded.\n");
+		goto aes_err;
+	}
+
+	ret = crypto_register_alg(&ecb_aes_alg);
+	if (ret != 0) {
+		printk(KERN_INFO
+		       "crypt_s390: ecb-aes-s390 couldn't be loaded.\n");
+		goto ecb_aes_err;
+	}
+
+	ret = crypto_register_alg(&cbc_aes_alg);
+	if (ret != 0) {
+		printk(KERN_INFO
+		       "crypt_s390: cbc-aes-s390 couldn't be loaded.\n");
+		goto cbc_aes_err;
+	}
+
+out:
 	return ret;
+
+cbc_aes_err:
+	crypto_unregister_alg(&ecb_aes_alg);
+ecb_aes_err:
+	crypto_unregister_alg(&aes_alg);
+aes_err:
+	goto out;
 }
 
 static void __exit aes_fini(void)
 {
+	crypto_unregister_alg(&cbc_aes_alg);
+	crypto_unregister_alg(&ecb_aes_alg);
 	crypto_unregister_alg(&aes_alg);
 }
 
diff --git a/arch/s390/crypto/crypt_s390.h b/arch/s390/crypto/crypt_s390.h
--- a/arch/s390/crypto/crypt_s390.h
+++ b/arch/s390/crypto/crypt_s390.h
@@ -21,6 +21,7 @@
 #define CRYPT_S390_FUNC_MASK 0x00FF
 
 #define CRYPT_S390_PRIORITY 300
+#define CRYPT_S390_COMPOSITE_PRIORITY 400
 
 /* s930 cryptographic operations */
 enum crypt_s390_operations {
diff --git a/arch/s390/crypto/des_s390.c b/arch/s390/crypto/des_s390.c
--- a/arch/s390/crypto/des_s390.c
+++ b/arch/s390/crypto/des_s390.c
@@ -13,9 +13,10 @@
  * (at your option) any later version.
  *
  */
+
+#include <crypto/algapi.h>
 #include <linux/init.h>
 #include <linux/module.h>
-#include <linux/crypto.h>
 
 #include "crypt_s390.h"
 #include "crypto_des.h"
@@ -157,6 +158,143 @@ static struct crypto_alg des_alg = {
 	}
 };
 
+static int ecb_desall_crypt(struct blkcipher_desc *desc, long func,
+			    void *param, struct blkcipher_walk *walk)
+{
+	int ret = blkcipher_walk_virt(desc, walk);
+	unsigned int nbytes;
+
+	while ((nbytes = walk->nbytes)) {
+		/* only use complete blocks */
+		unsigned int n = nbytes & ~(DES_BLOCK_SIZE - 1);
+		u8 *out = walk->dst.virt.addr;
+		u8 *in = walk->src.virt.addr;
+
+		ret = crypt_s390_km(func, param, out, in, n);
+		BUG_ON((ret < 0) || (ret != n));
+
+		nbytes &= DES_BLOCK_SIZE - 1;
+		ret = blkcipher_walk_done(desc, walk, nbytes);
+	}
+
+	return ret;
+}
+
+static int cbc_desall_crypt(struct blkcipher_desc *desc, long func,
+			    void *param, struct blkcipher_walk *walk)
+{
+	int ret = blkcipher_walk_virt(desc, walk);
+	unsigned int nbytes = walk->nbytes;
+
+	if (!nbytes)
+		goto out;
+
+	memcpy(param, walk->iv, DES_BLOCK_SIZE);
+	do {
+		/* only use complete blocks */
+		unsigned int n = nbytes & ~(DES_BLOCK_SIZE - 1);
+		u8 *out = walk->dst.virt.addr;
+		u8 *in = walk->src.virt.addr;
+
+		ret = crypt_s390_kmc(func, param, out, in, n);
+		BUG_ON((ret < 0) || (ret != n));
+
+		nbytes &= DES_BLOCK_SIZE - 1;
+		ret = blkcipher_walk_done(desc, walk, nbytes);
+	} while ((nbytes = walk->nbytes));
+	memcpy(walk->iv, param, DES_BLOCK_SIZE);
+
+out:
+	return ret;
+}
+
+static int ecb_des_encrypt(struct blkcipher_desc *desc,
+			   struct scatterlist *dst, struct scatterlist *src,
+			   unsigned int nbytes)
+{
+	struct crypt_s390_des_ctx *sctx = crypto_blkcipher_ctx(desc->tfm);
+	struct blkcipher_walk walk;
+
+	blkcipher_walk_init(&walk, dst, src, nbytes);
+	return ecb_desall_crypt(desc, KM_DEA_ENCRYPT, sctx->key, &walk);
+}
+
+static int ecb_des_decrypt(struct blkcipher_desc *desc,
+			   struct scatterlist *dst, struct scatterlist *src,
+			   unsigned int nbytes)
+{
+	struct crypt_s390_des_ctx *sctx = crypto_blkcipher_ctx(desc->tfm);
+	struct blkcipher_walk walk;
+
+	blkcipher_walk_init(&walk, dst, src, nbytes);
+	return ecb_desall_crypt(desc, KM_DEA_DECRYPT, sctx->key, &walk);
+}
+
+static struct crypto_alg ecb_des_alg = {
+	.cra_name		=	"ecb(des)",
+	.cra_driver_name	=	"ecb-des-s390",
+	.cra_priority		=	CRYPT_S390_COMPOSITE_PRIORITY,
+	.cra_flags		=	CRYPTO_ALG_TYPE_BLKCIPHER,
+	.cra_blocksize		=	DES_BLOCK_SIZE,
+	.cra_ctxsize		=	sizeof(struct crypt_s390_des_ctx),
+	.cra_type		=	&crypto_blkcipher_type,
+	.cra_module		=	THIS_MODULE,
+	.cra_list		=	LIST_HEAD_INIT(ecb_des_alg.cra_list),
+	.cra_u			=	{
+		.blkcipher = {
+			.min_keysize		=	DES_KEY_SIZE,
+			.max_keysize		=	DES_KEY_SIZE,
+			.setkey			=	des_setkey,
+			.encrypt		=	ecb_des_encrypt,
+			.decrypt		=	ecb_des_decrypt,
+		}
+	}
+};
+
+static int cbc_des_encrypt(struct blkcipher_desc *desc,
+			   struct scatterlist *dst, struct scatterlist *src,
+			   unsigned int nbytes)
+{
+	struct crypt_s390_des_ctx *sctx = crypto_blkcipher_ctx(desc->tfm);
+	struct blkcipher_walk walk;
+
+	blkcipher_walk_init(&walk, dst, src, nbytes);
+	return cbc_desall_crypt(desc, KMC_DEA_ENCRYPT, sctx->iv, &walk);
+}
+
+static int cbc_des_decrypt(struct blkcipher_desc *desc,
+			   struct scatterlist *dst, struct scatterlist *src,
+			   unsigned int nbytes)
+{
+	struct crypt_s390_des_ctx *sctx = crypto_blkcipher_ctx(desc->tfm);
+	struct blkcipher_walk walk;
+
+	blkcipher_walk_init(&walk, dst, src, nbytes);
+	return cbc_desall_crypt(desc, KMC_DEA_DECRYPT, sctx->iv, &walk);
+}
+
+static struct crypto_alg cbc_des_alg = {
+	.cra_name		=	"cbc(des)",
+	.cra_driver_name	=	"cbc-des-s390",
+	.cra_priority		=	CRYPT_S390_COMPOSITE_PRIORITY,
+	.cra_flags		=	CRYPTO_ALG_TYPE_BLKCIPHER,
+	.cra_blocksize		=	DES_BLOCK_SIZE,
+	.cra_ctxsize		=	sizeof(struct crypt_s390_des_ctx),
+	.cra_type		=	&crypto_blkcipher_type,
+	.cra_module		=	THIS_MODULE,
+	.cra_list		=	LIST_HEAD_INIT(cbc_des_alg.cra_list),
+	.cra_u			=	{
+		.blkcipher = {
+			.min_keysize		=	DES_KEY_SIZE,
+			.max_keysize		=	DES_KEY_SIZE,
+			.ivsize			=	DES_BLOCK_SIZE,
+			.setkey			=	des_setkey,
+			.encrypt		=	cbc_des_encrypt,
+			.decrypt		=	cbc_des_decrypt,
+		}
+	}
+};
+
 /*
  * RFC2451:
  *
@@ -295,6 +433,95 @@ static struct crypto_alg des3_128_alg = 
 	}
 };
 
+static int ecb_des3_128_encrypt(struct blkcipher_desc *desc,
+				struct scatterlist *dst,
+				struct scatterlist *src, unsigned int nbytes)
+{
+	struct crypt_s390_des3_128_ctx *sctx = crypto_blkcipher_ctx(desc->tfm);
+	struct blkcipher_walk walk;
+
+	blkcipher_walk_init(&walk, dst, src, nbytes);
+	return ecb_desall_crypt(desc, KM_TDEA_128_ENCRYPT, sctx->key, &walk);
+}
+
+static int ecb_des3_128_decrypt(struct blkcipher_desc *desc,
+				struct scatterlist *dst,
+				struct scatterlist *src, unsigned int nbytes)
+{
+	struct crypt_s390_des3_128_ctx *sctx = crypto_blkcipher_ctx(desc->tfm);
+	struct blkcipher_walk walk;
+
+	blkcipher_walk_init(&walk, dst, src, nbytes);
+	return ecb_desall_crypt(desc, KM_TDEA_128_DECRYPT, sctx->key, &walk);
+}
+
+static struct crypto_alg ecb_des3_128_alg = {
+	.cra_name		=	"ecb(des3_ede128)",
+	.cra_driver_name	=	"ecb-des3_ede128-s390",
+	.cra_priority		=	CRYPT_S390_COMPOSITE_PRIORITY,
+	.cra_flags		=	CRYPTO_ALG_TYPE_BLKCIPHER,
+	.cra_blocksize		=	DES3_128_BLOCK_SIZE,
+	.cra_ctxsize		=	sizeof(struct crypt_s390_des3_128_ctx),
+	.cra_type		=	&crypto_blkcipher_type,
+	.cra_module		=	THIS_MODULE,
+	.cra_list		=	LIST_HEAD_INIT(
+						ecb_des3_128_alg.cra_list),
+	.cra_u			=	{
+		.blkcipher = {
+			.min_keysize		=	DES3_128_KEY_SIZE,
+			.max_keysize		=	DES3_128_KEY_SIZE,
+			.setkey			=	des3_128_setkey,
+			.encrypt		=	ecb_des3_128_encrypt,
+			.decrypt		=	ecb_des3_128_decrypt,
+		}
+	}
+};
+
+static int cbc_des3_128_encrypt(struct blkcipher_desc *desc,
+				struct scatterlist *dst,
+				struct scatterlist *src, unsigned int nbytes)
+{
+	struct crypt_s390_des3_128_ctx *sctx = crypto_blkcipher_ctx(desc->tfm);
+	struct blkcipher_walk walk;
+
+	blkcipher_walk_init(&walk, dst, src, nbytes);
+	return cbc_desall_crypt(desc, KMC_TDEA_128_ENCRYPT, sctx->iv, &walk);
+}
+
+static int cbc_des3_128_decrypt(struct blkcipher_desc *desc,
+				struct scatterlist *dst,
+				struct scatterlist *src, unsigned int nbytes)
+{
+	struct crypt_s390_des3_128_ctx *sctx = crypto_blkcipher_ctx(desc->tfm);
+	struct blkcipher_walk walk;
+
+	blkcipher_walk_init(&walk, dst, src, nbytes);
+	return cbc_desall_crypt(desc, KMC_TDEA_128_DECRYPT, sctx->iv, &walk);
+}
+
+static struct crypto_alg cbc_des3_128_alg = {
+	.cra_name		=	"cbc(des3_ede128)",
+	.cra_driver_name	=	"cbc-des3_ede128-s390",
+	.cra_priority		=	CRYPT_S390_COMPOSITE_PRIORITY,
+	.cra_flags		=	CRYPTO_ALG_TYPE_BLKCIPHER,
+	.cra_blocksize		=	DES3_128_BLOCK_SIZE,
+	.cra_ctxsize		=	sizeof(struct crypt_s390_des3_128_ctx),
+	.cra_type		=	&crypto_blkcipher_type,
+	.cra_module		=	THIS_MODULE,
+	.cra_list		=	LIST_HEAD_INIT(
+						cbc_des3_128_alg.cra_list),
+	.cra_u			=	{
+		.blkcipher = {
+			.min_keysize		=	DES3_128_KEY_SIZE,
+			.max_keysize		=	DES3_128_KEY_SIZE,
+			.ivsize			=	DES3_128_BLOCK_SIZE,
+			.setkey			=	des3_128_setkey,
+			.encrypt		=	cbc_des3_128_encrypt,
+			.decrypt		=	cbc_des3_128_decrypt,
+		}
+	}
+};
+
 /*
  * RFC2451:
  *
@@ -437,6 +664,95 @@ static struct crypto_alg des3_192_alg = 
 	}
 };
 
+static int ecb_des3_192_encrypt(struct blkcipher_desc *desc,
+				struct scatterlist *dst,
+				struct scatterlist *src, unsigned int nbytes)
+{
+	struct crypt_s390_des3_192_ctx *sctx = crypto_blkcipher_ctx(desc->tfm);
+	struct blkcipher_walk walk;
+
+	blkcipher_walk_init(&walk, dst, src, nbytes);
+	return ecb_desall_crypt(desc, KM_TDEA_192_ENCRYPT, sctx->key, &walk);
+}
+
+static int ecb_des3_192_decrypt(struct blkcipher_desc *desc,
+				struct scatterlist *dst,
+				struct scatterlist *src, unsigned int nbytes)
+{
+	struct crypt_s390_des3_192_ctx *sctx = crypto_blkcipher_ctx(desc->tfm);
+	struct blkcipher_walk walk;
+
+	blkcipher_walk_init(&walk, dst, src, nbytes);
+	return ecb_desall_crypt(desc, KM_TDEA_192_DECRYPT, sctx->key, &walk);
+}
+
+static struct crypto_alg ecb_des3_192_alg = {
+	.cra_name		=	"ecb(des3_ede)",
+	.cra_driver_name	=	"ecb-des3_ede-s390",
+	.cra_priority		=	CRYPT_S390_COMPOSITE_PRIORITY,
+	.cra_flags		=	CRYPTO_ALG_TYPE_BLKCIPHER,
+	.cra_blocksize		=	DES3_192_BLOCK_SIZE,
+	.cra_ctxsize		=	sizeof(struct crypt_s390_des3_192_ctx),
+	.cra_type		=	&crypto_blkcipher_type,
+	.cra_module		=	THIS_MODULE,
+	.cra_list		=	LIST_HEAD_INIT(
+						ecb_des3_192_alg.cra_list),
+	.cra_u			=	{
+		.blkcipher = {
+			.min_keysize		=	DES3_192_KEY_SIZE,
+			.max_keysize		=	DES3_192_KEY_SIZE,
+			.setkey			=	des3_192_setkey,
+			.encrypt		=	ecb_des3_192_encrypt,
+			.decrypt		=	ecb_des3_192_decrypt,
+		}
+	}
+};
+
+static int cbc_des3_192_encrypt(struct blkcipher_desc *desc,
+				struct scatterlist *dst,
+				struct scatterlist *src, unsigned int nbytes)
+{
+	struct crypt_s390_des3_192_ctx *sctx = crypto_blkcipher_ctx(desc->tfm);
+	struct blkcipher_walk walk;
+
+	blkcipher_walk_init(&walk, dst, src, nbytes);
+	return cbc_desall_crypt(desc, KMC_TDEA_192_ENCRYPT, sctx->iv, &walk);
+}
+
+static int cbc_des3_192_decrypt(struct blkcipher_desc *desc,
+				struct scatterlist *dst,
+				struct scatterlist *src, unsigned int nbytes)
+{
+	struct crypt_s390_des3_192_ctx *sctx = crypto_blkcipher_ctx(desc->tfm);
+	struct blkcipher_walk walk;
+
+	blkcipher_walk_init(&walk, dst, src, nbytes);
+	return cbc_desall_crypt(desc, KMC_TDEA_192_DECRYPT, sctx->iv, &walk);
+}
+
+static struct crypto_alg cbc_des3_192_alg = {
+	.cra_name		=	"cbc(des3_ede)",
+	.cra_driver_name	=	"cbc-des3_ede-s390",
+	.cra_priority		=	CRYPT_S390_COMPOSITE_PRIORITY,
+	.cra_flags		=	CRYPTO_ALG_TYPE_BLKCIPHER,
+	.cra_blocksize		=	DES3_192_BLOCK_SIZE,
+	.cra_ctxsize		=	sizeof(struct crypt_s390_des3_192_ctx),
+	.cra_type		=	&crypto_blkcipher_type,
+	.cra_module		=	THIS_MODULE,
+	.cra_list		=	LIST_HEAD_INIT(
+						cbc_des3_192_alg.cra_list),
+	.cra_u			=	{
+		.blkcipher = {
+			.min_keysize		=	DES3_192_KEY_SIZE,
+			.max_keysize		=	DES3_192_KEY_SIZE,
+			.ivsize			=	DES3_192_BLOCK_SIZE,
+			.setkey			=	des3_192_setkey,
+			.encrypt		=	cbc_des3_192_encrypt,
+			.decrypt		=	cbc_des3_192_decrypt,
+		}
+	}
+};
+
 static int init(void)
 {
 	int ret = 0;
@@ -446,22 +762,69 @@ static int init(void)
 	    !crypt_s390_func_available(KM_TDEA_192_ENCRYPT))
 		return -ENOSYS;
 
-	ret |= (crypto_register_alg(&des_alg) == 0) ? 0:1;
-	ret |= (crypto_register_alg(&des3_128_alg) == 0) ? 0:2;
-	ret |= (crypto_register_alg(&des3_192_alg) == 0) ? 0:4;
-	if (ret) {
-		crypto_unregister_alg(&des3_192_alg);
-		crypto_unregister_alg(&des3_128_alg);
-		crypto_unregister_alg(&des_alg);
-		return -EEXIST;
-	}
-	return 0;
+	ret = crypto_register_alg(&des_alg);
+	if (ret)
+		goto des_err;
+	ret = crypto_register_alg(&ecb_des_alg);
+	if (ret)
+		goto ecb_des_err;
+	ret = crypto_register_alg(&cbc_des_alg);
+	if (ret)
+		goto cbc_des_err;
+
+	ret = crypto_register_alg(&des3_128_alg);
+	if (ret)
+		goto des3_128_err;
+	ret = crypto_register_alg(&ecb_des3_128_alg);
+	if (ret)
+		goto ecb_des3_128_err;
+	ret = crypto_register_alg(&cbc_des3_128_alg);
+	if (ret)
+		goto cbc_des3_128_err;
+
+	ret = crypto_register_alg(&des3_192_alg);
+	if (ret)
+		goto des3_192_err;
+	ret = crypto_register_alg(&ecb_des3_192_alg);
+	if (ret)
+		goto ecb_des3_192_err;
+	ret = crypto_register_alg(&cbc_des3_192_alg);
+	if (ret)
+		goto cbc_des3_192_err;
+
+out:
+	return ret;
+
+cbc_des3_192_err:
+	crypto_unregister_alg(&ecb_des3_192_alg);
+ecb_des3_192_err:
+	crypto_unregister_alg(&des3_192_alg);
+des3_192_err:
+	crypto_unregister_alg(&cbc_des3_128_alg);
+cbc_des3_128_err:
+	crypto_unregister_alg(&ecb_des3_128_alg);
+ecb_des3_128_err:
+	crypto_unregister_alg(&des3_128_alg);
+des3_128_err:
+	crypto_unregister_alg(&cbc_des_alg);
+cbc_des_err:
+	crypto_unregister_alg(&ecb_des_alg);
+ecb_des_err:
+	crypto_unregister_alg(&des_alg);
+des_err:
+	goto out;
 }
 
 static void __exit fini(void)
 {
+	crypto_unregister_alg(&cbc_des3_192_alg);
+	crypto_unregister_alg(&ecb_des3_192_alg);
 	crypto_unregister_alg(&des3_192_alg);
+	crypto_unregister_alg(&cbc_des3_128_alg);
+	crypto_unregister_alg(&ecb_des3_128_alg);
 	crypto_unregister_alg(&des3_128_alg);
+	crypto_unregister_alg(&cbc_des_alg);
+	crypto_unregister_alg(&ecb_des_alg);
 	crypto_unregister_alg(&des_alg);
 }
 
