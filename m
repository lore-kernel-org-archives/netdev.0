From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: [RFC][PATCH] XCBC support with new crypto framework
Date: Wed, 9 Aug 2006 19:14:51 +0900
Message-ID: <20060809191451.f36b558c.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 221x116x13x66.ap221.ftth.ucom.ne.jp ([221.116.13.66]:54991 "EHLO
	miyazawa.org") by vger.kernel.org with ESMTP id S1030638AbWHIKPY
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 06:15:24 -0400
To: herbert@gondor.apana.org.au
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Herbert,

I make a patch set of introducing XCBC with your new crypto framework.
I checked the patches work well with the tcrypt module.
However I can not make sure that I completely understand the API.

So I would appreciate if you would give me some comments.

Thank you,

b30befe9e2ef5e59f9b2a8d3bf053489a10e159b
diff --git a/crypto/Kconfig b/crypto/Kconfig
index 12b23a7..5713272 100644
--- a/crypto/Kconfig
+++ b/crypto/Kconfig
@@ -29,6 +29,13 @@ config CRYPTO_HMAC
 	  HMAC: Keyed-Hashing for Message Authentication (RFC2104).
 	  This is required for IPSec.
 
+config CRYPTO_XCBC
+	tristate "XCBC support"
+	depends on CRYPTO
+	help
+	  XCBC: Keyed-Hashing for Message Authentication.
+	  This is required for IPSec.
+
 config CRYPTO_NULL
 	tristate "Null algorithms"
 	select CRYPTO_LOWAPI
diff --git a/crypto/Makefile b/crypto/Makefile
index 03c13fa..10c2ee4 100644
--- a/crypto/Makefile
+++ b/crypto/Makefile
@@ -10,6 +10,7 @@ obj-$(CONFIG_CRYPTO_LOWAPI) += crypto_lo
 
 obj-$(CONFIG_CRYPTO_MANAGER) += cryptomgr.o
 obj-$(CONFIG_CRYPTO_HMAC) += hmac.o
+obj-$(CONFIG_CRYPTO_XCBC) += xcbc.o
 obj-$(CONFIG_CRYPTO_NULL) += crypto_null.o
 obj-$(CONFIG_CRYPTO_MD4) += md4.o
 obj-$(CONFIG_CRYPTO_MD5) += md5.o
diff --git a/crypto/hmac.c b/crypto/hmac.c
index 0571d75..573a07d 100644
--- a/crypto/hmac.c
+++ b/crypto/hmac.c
@@ -117,7 +117,7 @@ static int crypto_hmac_init_tfm(struct c
 	struct crypto_spawn *spawn = crypto_instance_ctx(inst);
 	struct crypto_hmac_ctx *ctx = crypto_hmac_ctx(tfm);
 
-	ctx->child = crypto_spawn_tfm(spawn);
+	ctx->child = crypto_spawn_tfm(spawn, 0);
 	if (IS_ERR(ctx->child))
 		return PTR_ERR(ctx->child);
 
diff --git a/crypto/lowapi.c b/crypto/lowapi.c
index 35f26fb..79ed99a 100644
--- a/crypto/lowapi.c
+++ b/crypto/lowapi.c
@@ -376,7 +376,7 @@ void crypto_drop_spawn(struct crypto_spa
 }
 EXPORT_SYMBOL_GPL(crypto_drop_spawn);
 
-struct crypto_tfm *crypto_spawn_tfm(struct crypto_spawn *spawn)
+struct crypto_tfm *crypto_spawn_tfm(struct crypto_spawn *spawn, u32 flags)
 {
 	struct crypto_alg *alg;
 	struct crypto_alg *alg2;
@@ -395,7 +395,7 @@ struct crypto_tfm *crypto_spawn_tfm(stru
 		return ERR_PTR(-EAGAIN);
 	}
 
-	tfm = __crypto_alloc_tfm(alg, 0);
+	tfm = __crypto_alloc_tfm(alg, flags);
 	if (IS_ERR(tfm))
 		crypto_mod_put(alg);
 
diff --git a/crypto/tcrypt.c b/crypto/tcrypt.c
index f778e40..c07b988 100644
--- a/crypto/tcrypt.c
+++ b/crypto/tcrypt.c
@@ -792,6 +792,9 @@ static void do_test(void)
 		test_hash("hmac(sha256)", hmac_sha256_tv_template,
 			  HMAC_SHA256_TEST_VECTORS);
 
+		test_hash("xcbc(aes)", aes_xcbc128_tv_template,
+			  XCBC_AES_TEST_VECTORS);
+
 		test_hash("michael_mic", michael_mic_tv_template, MICHAEL_MIC_TEST_VECTORS);
 		break;
 
diff --git a/crypto/tcrypt.h b/crypto/tcrypt.h
index dd648f2..6fa65b4 100644
--- a/crypto/tcrypt.h
+++ b/crypto/tcrypt.h
@@ -933,6 +933,74 @@ static struct hash_testvec hmac_sha256_t
 	},
 };
 
+#define XCBC_AES_TEST_VECTORS 6
+
+static struct hash_testvec aes_xcbc128_tv_template[] = {
+	{
+		.key	= { 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
+			    0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f },
+		.plaintext	= { [0 ... 127] = 0 },
+		.digest = { 0x75, 0xf0, 0x25, 0x1d, 0x52, 0x8a, 0xc0, 0x1c,
+			    0x45, 0x73, 0xdf, 0xd5, 0x84, 0xd7, 0x9f, 0x29 },
+		.psize	= 0,
+		.ksize	= 16,
+	}, {
+		.key	= { 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
+			    0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f },
+		.plaintext	= { 0x00, 0x01, 0x02 },
+		.digest	= { 0x5b, 0x37, 0x65, 0x80, 0xae, 0x2f, 0x19, 0xaf,
+			    0xe7, 0x21, 0x9c, 0xee, 0xf1, 0x72, 0x75, 0x6f },
+		.psize	= 3,
+		.ksize	= 16,
+	} , {
+		.key	= { 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
+			    0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f },
+		.plaintext	= { 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
+			    0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f },
+		.digest = { 0xd2, 0xa2, 0x46, 0xfa, 0x34, 0x9b, 0x68, 0xa7,
+			    0x99, 0x98, 0xa4, 0x39, 0x4f, 0xf7, 0xa2, 0x63 },
+		.psize	= 16,
+		.ksize	= 16,
+	}, {
+		.key	= { 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
+			    0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f },
+		.plaintext	= { 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
+			    0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
+			    0x10, 0x11, 0x12, 0x13 },
+		.digest = { 0x47, 0xf5, 0x1b, 0x45, 0x64, 0x96, 0x62, 0x15,
+			    0xb8, 0x98, 0x5c, 0x63, 0x05, 0x5e, 0xd3, 0x08 },
+		.tap	= {10, 10},
+		.psize	= 20,
+		.np	= 2,
+		.ksize	= 16,
+	}, {
+		.key	= { 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
+			    0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f },
+		.plaintext	= { 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
+			    0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
+			    0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17,
+			    0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f },
+		.digest = { 0xf5, 0x4f, 0x0e, 0xc8, 0xd2, 0xb9, 0xf3, 0xd3,
+			    0x68, 0x07, 0x73, 0x4b, 0xd5, 0x28, 0x3f, 0xd4 },
+		.psize	= 32,
+		.ksize	= 16,
+	}, {
+		.key	= { 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
+			    0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f },
+		.plaintext	= { 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
+			    0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
+			    0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17,
+			    0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f,
+			    0x20, 0x21 },
+		.digest = { 0xbe, 0xcb, 0xb3, 0xbc, 0xcd, 0xb5, 0x18, 0xa3,
+			    0x06, 0x77, 0xd5, 0x48, 0x1f, 0xb6, 0xb4, 0xd8 },
+		.tap	= {17,17},
+		.psize	= 34,
+		.np	= 2,
+		.ksize	= 16,
+	}
+};
+
 /*
  * DES test vectors.
  */
diff --git a/crypto/xcbc.c b/crypto/xcbc.c
new file mode 100644
index 0000000..8cee13a
--- /dev/null
+++ b/crypto/xcbc.c
@@ -0,0 +1,360 @@
+/*
+ * Copyright (C)2005 USAGI/WIDE Project
+ * 
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ * 
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ * 
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ *
+ * Author:
+ * 	Kazunori Miyazawa <miyazawa@linux-ipv6.org>
+ */
+
+#include <linux/crypto.h>
+#include <linux/err.h>
+#include <linux/kernel.h>
+#include <linux/mm.h>
+#include <linux/rtnetlink.h>
+#include <linux/slab.h>
+#include <linux/scatterlist.h>
+#include "internal.h"
+
+u_int32_t ks[12] = {0x01010101, 0x01010101, 0x01010101, 0x01010101,
+		    0x02020202, 0x02020202, 0x02020202, 0x02020202,
+		    0x03030303, 0x03030303, 0x03030303, 0x03030303}; 
+
+/*
+ * +------------------------
+ * | <parent tfm>
+ * +------------------------
+ * | prev (block size)
+ * +------------------------
+ * | key (block size)
+ * +------------------------
+ * | consts (block size * 3)
+ * +------------------------
+ * | crypto_xcbc_ctx
+ * +------------------------
+ */
+struct crypto_xcbc_ctx {
+	unsigned int keylen;
+	unsigned int len;
+	struct crypto_tfm *child;
+};
+
+static inline struct crypto_xcbc_ctx *crypto_xcbc_digest_ctx(struct crypto_tfm *parent)
+{
+	int bs = crypto_tfm_alg_blocksize(parent);
+	u8 *prev = crypto_tfm_ctx_aligned(parent);
+	return (struct crypto_xcbc_ctx*)(prev + bs * 5);
+}
+
+static int _crypto_xcbc_digest_setkey(struct crypto_tfm *parent,
+				     const u8 *inkey, unsigned int keylen)
+{
+
+	int bs = crypto_tfm_alg_blocksize(parent);
+	u8 *prev = crypto_tfm_ctx_aligned(parent);
+	u8 *key = prev + bs;
+	u8 *consts = key + bs;
+	struct crypto_xcbc_ctx *ctx = (struct crypto_xcbc_ctx*)(consts + bs * 3);
+	int err = 0;
+	u8 key1[bs];
+
+	if ((err = crypto_cipher_setkey(ctx->child, key, keylen)))
+	    return err;
+
+	ctx->child->__crt_alg->cra_cipher.cia_encrypt(ctx->child, key1,
+			consts);
+
+	return crypto_cipher_setkey(ctx->child, key1, bs);
+}
+
+static int crypto_xcbc_digest_setkey(struct crypto_tfm *parent,
+				     const u8 *inkey, unsigned int keylen)
+{
+
+	int bs = crypto_tfm_alg_blocksize(parent);
+	u8 *prev = crypto_tfm_ctx_aligned(parent);
+	u8 *key = prev + bs;
+	u8 *consts = key + bs;
+	struct crypto_xcbc_ctx *ctx = (struct crypto_xcbc_ctx*)(consts + bs * 3);
+
+	if (keylen != crypto_tfm_alg_blocksize(ctx->child))
+		return -EINVAL;
+
+        if (keylen < crypto_tfm_alg_min_keysize(ctx->child) ||
+	    keylen > crypto_tfm_alg_max_keysize(ctx->child))
+		return -EINVAL;
+
+	ctx->keylen = keylen;
+	memcpy(key, inkey, keylen);
+
+	memset(key + keylen, 0, crypto_tfm_alg_blocksize(ctx->child) - keylen);
+
+	memcpy(consts, ks, sizeof(ks));
+
+	ctx->len = 0;
+	memset(prev, 0, bs);
+	memset(ctx->child->crt_cipher.cit_iv, 0, crypto_tfm_alg_blocksize(ctx->child));
+
+	return _crypto_xcbc_digest_setkey(parent, key, ctx->keylen);
+}
+
+void crypto_xcbc_digest_init(struct crypto_tfm *parent)
+{
+	return;
+}
+
+void crypto_xcbc_digest_update(struct crypto_tfm *parent, struct scatterlist *sg, unsigned int nsg)
+{
+	int bs = crypto_tfm_alg_blocksize(parent);
+	u8 *prev = crypto_tfm_ctx_aligned(parent);
+	struct crypto_xcbc_ctx *ctx = (struct crypto_xcbc_ctx*)(prev + bs * 5);
+	struct crypto_tfm *tfm = ctx->child;
+	unsigned int i;
+
+	if (!(tfm->crt_cipher.cit_mode & CRYPTO_TFM_MODE_CBC))
+		return;
+ 
+	for(i = 0; i < nsg; i++) {
+
+		struct page *pg = sg[i].page;
+		unsigned int offset = sg[i].offset;
+		unsigned int slen = sg[i].length;
+
+		while (slen > 0) {
+			unsigned int len = min(slen, ((unsigned int)(PAGE_SIZE)) - offset);
+			char *p = crypto_kmap(pg, 0) + offset;
+
+			/* checking the data can fill the block */
+			if ((ctx->len + len) <= bs) {
+				memcpy(prev + ctx->len, p, len);
+				ctx->len += len;
+				slen -= len;
+
+				/* checking the rest of the page */
+				if (len + offset >= PAGE_SIZE) {
+					offset = 0;
+					pg++;
+				} else
+					offset += len;
+
+				crypto_kunmap(p, 0);
+				crypto_yield(tfm);
+				continue;
+			}
+
+			/* filling prev with new data and encrypting it */
+			memcpy(prev + ctx->len, p, bs - ctx->len);
+			len -= bs - ctx->len;
+			p += bs - ctx->len;
+			tfm->crt_u.cipher.cit_xor_block(tfm->crt_cipher.cit_iv,
+							prev);
+			tfm->__crt_alg->cra_cipher.cia_encrypt(tfm,
+					tfm->crt_cipher.cit_iv,
+					tfm->crt_cipher.cit_iv);
+
+			/* clearing the length */
+			ctx->len = 0;
+
+			/* encrypting the rest of data */
+			while (len > bs) {
+				tfm->crt_u.cipher.cit_xor_block(tfm->crt_cipher.cit_iv, p);
+				tfm->__crt_alg->cra_cipher.cia_encrypt(tfm,
+						tfm->crt_cipher.cit_iv,
+						tfm->crt_cipher.cit_iv);
+				p += bs;
+				len -= bs;
+			}
+
+			/* keeping the surplus of blocksize */
+			if (len) {
+				memcpy(prev, p, len);
+				ctx->len = len;
+			}
+			crypto_kunmap(p, 0);
+			crypto_yield(tfm);
+			slen -= min(slen, ((unsigned int)(PAGE_SIZE)) - offset);
+			offset = 0;
+			pg++;
+		}
+	}
+}
+
+void crypto_xcbc_digest_final(struct crypto_tfm *parent, u8 *out)
+{
+	int bs = crypto_tfm_alg_blocksize(parent);
+	u8 *prev = crypto_tfm_ctx_aligned(parent);
+	u8 *key = prev + bs;
+	u8 *consts = key + bs;
+	struct crypto_xcbc_ctx *ctx = (struct crypto_xcbc_ctx*)(prev + bs * 5);
+	struct crypto_tfm *tfm = ctx->child;
+
+	if (ctx->len == bs) {
+		u8 key2[bs];
+
+		if ((crypto_cipher_setkey(tfm, key, ctx->keylen)) != 0)
+			return;
+
+		tfm->__crt_alg->cra_cipher.cia_encrypt(tfm, key2, (const u8*)(consts+bs));
+		tfm->crt_u.cipher.cit_xor_block(tfm->crt_cipher.cit_iv, prev);
+		tfm->crt_u.cipher.cit_xor_block(tfm->crt_cipher.cit_iv, key2);
+
+		printk("%s 1\n", __FUNCTION__);
+		_crypto_xcbc_digest_setkey(parent, key, ctx->keylen);
+
+		tfm->__crt_alg->cra_cipher.cia_encrypt(tfm, out, tfm->crt_cipher.cit_iv);
+	} else {
+		u8 key3[bs];
+		unsigned int rlen;
+		u8 *p = prev + ctx->len;
+		*p = 0x80;
+		p++;
+
+		rlen = bs - ctx->len -1;
+		if (rlen)
+			memset(p, 0, rlen);
+
+		if ((crypto_cipher_setkey(tfm, key, ctx->keylen)) != 0)
+			return;
+
+		tfm->__crt_alg->cra_cipher.cia_encrypt(tfm, key3, (const u8*)(consts+bs*2));
+
+		tfm->crt_u.cipher.cit_xor_block(tfm->crt_cipher.cit_iv, prev);
+		tfm->crt_u.cipher.cit_xor_block(tfm->crt_cipher.cit_iv, key3);
+
+		printk("%s 2\n", __FUNCTION__);
+		_crypto_xcbc_digest_setkey(parent, key, ctx->keylen);
+
+		tfm->__crt_alg->cra_cipher.cia_encrypt(tfm, out, tfm->crt_cipher.cit_iv);
+	}
+
+	return;
+}
+
+static int crypto_xcbc_init_tfm(struct crypto_tfm *tfm)
+{
+	struct crypto_instance *inst = (void *)tfm->__crt_alg;
+	struct crypto_spawn *spawn = crypto_instance_ctx(inst);
+	struct crypto_xcbc_ctx *ctx = crypto_xcbc_digest_ctx(tfm);
+
+	ctx->child = crypto_spawn_tfm(spawn, CRYPTO_TFM_MODE_CBC);
+	if (IS_ERR(ctx->child))
+		return PTR_ERR(ctx->child);
+
+	return 0;
+};
+
+static void crypto_xcbc_exit_tfm(struct crypto_tfm *tfm)
+{
+	crypto_free_tfm(crypto_xcbc_digest_ctx(tfm)->child);
+}
+
+static struct crypto_instance *crypto_xcbc_alloc(void *param, unsigned int len)
+{
+	struct rtattr *rta = param;
+	struct crypto_instance *inst;
+	struct crypto_attr_alg *alga;
+	struct crypto_alg *alg;
+	struct crypto_spawn *spawn;
+	int err;
+
+	if (!RTA_OK(rta, len))
+		return ERR_PTR(-EBADR);
+
+	if (rta->rta_type != CRYPTOA_ALG || RTA_PAYLOAD(rta) < sizeof(*alga))
+		return ERR_PTR(-EINVAL);
+
+	alga = RTA_DATA(rta);
+
+	inst = kzalloc(sizeof(*inst) + sizeof(*spawn), GFP_KERNEL);
+	if (!inst)
+		return ERR_PTR(-ENOMEM);
+
+	inst->alg.cra_flags = CRYPTO_ALG_TYPE_DIGEST;
+
+	alg = crypto_alg_mod_lookup(alga->name, CRYPTO_ALG_TYPE_CIPHER,
+				    CRYPTO_ALG_TYPE_MASK);
+
+	err = PTR_ERR(alg);
+	if (IS_ERR(alg))
+		goto err_free_inst;
+
+	err = -ENAMETOOLONG;
+	if (snprintf(inst->alg.cra_name, CRYPTO_MAX_ALG_NAME,
+		     "xcbc(%s)", alg->cra_name) >= CRYPTO_MAX_ALG_NAME)
+		goto put_alg;
+
+	if (snprintf(inst->alg.cra_driver_name, CRYPTO_MAX_ALG_NAME,
+		     "xcbc(%s)", alg->cra_driver_name) >= CRYPTO_MAX_ALG_NAME)
+		goto put_alg;
+
+	spawn = crypto_instance_ctx(inst);
+	err = crypto_init_spawn(spawn, alg, inst);
+
+put_alg:
+	crypto_mod_put(alg);
+	if (err)
+		goto err_free_inst;
+
+	inst->alg.cra_priority = alg->cra_priority;
+	inst->alg.cra_blocksize = alg->cra_blocksize;
+	inst->alg.cra_alignmask = alg->cra_alignmask;
+	inst->alg.cra_digest.dia_digestsize = alg->cra_blocksize;
+
+	inst->alg.cra_ctxsize = sizeof(struct crypto_xcbc_ctx) +
+		inst->alg.cra_blocksize * 5;
+
+	inst->alg.cra_init = crypto_xcbc_init_tfm;
+	inst->alg.cra_exit = crypto_xcbc_exit_tfm;
+
+	inst->alg.cra_digest.dia_init = crypto_xcbc_digest_init;
+	inst->alg.cra_digest.dia_update_sg = crypto_xcbc_digest_update;
+	inst->alg.cra_digest.dia_final = crypto_xcbc_digest_final;
+	inst->alg.cra_digest.dia_setkey = crypto_xcbc_digest_setkey;
+
+	return inst;
+
+err_free_inst:
+	kfree(inst);
+	return ERR_PTR(err);
+}
+
+static void crypto_xcbc_free(struct crypto_instance *inst)
+{
+	crypto_drop_spawn(crypto_instance_ctx(inst));
+	kfree(inst);
+}
+
+static struct crypto_template crypto_xcbc_tmpl = {
+	.name = "xcbc",
+	.alloc = crypto_xcbc_alloc,
+	.free = crypto_xcbc_free,
+	.module = THIS_MODULE,
+};
+
+static int __init crypto_xcbc_module_init(void)
+{
+	return crypto_register_template(&crypto_xcbc_tmpl);
+}
+
+static void __exit crypto_xcbc_module_exit(void)
+{
+	crypto_unregister_template(&crypto_xcbc_tmpl);
+}
+
+module_init(crypto_xcbc_module_init);
+module_exit(crypto_xcbc_module_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("XCBC digest algorithm");
diff --git a/include/crypto/lowapi.h b/include/crypto/lowapi.h
index 03c46e2..5e53b8a 100644
--- a/include/crypto/lowapi.h
+++ b/include/crypto/lowapi.h
@@ -54,7 +54,7 @@ struct crypto_template *crypto_lookup_te
 int crypto_init_spawn(struct crypto_spawn *spawn, struct crypto_alg *alg,
 		      struct crypto_instance *inst);
 void crypto_drop_spawn(struct crypto_spawn *spawn);
-struct crypto_tfm *crypto_spawn_tfm(struct crypto_spawn *spawn);
+struct crypto_tfm *crypto_spawn_tfm(struct crypto_spawn *spawn, u32 flags);
 
 struct crypto_alg *crypto_get_attr_alg(void *param, unsigned int len,
 				       u32 type, u32 mask);
diff --git a/include/linux/pfkeyv2.h b/include/linux/pfkeyv2.h
index d5dd471..636e0fb 100644
--- a/include/linux/pfkeyv2.h
+++ b/include/linux/pfkeyv2.h
@@ -285,6 +285,7 @@ #define SADB_X_AALG_SHA2_256HMAC	5
 #define SADB_X_AALG_SHA2_384HMAC	6
 #define SADB_X_AALG_SHA2_512HMAC	7
 #define SADB_X_AALG_RIPEMD160HMAC	8
+#define SADB_X_AALG_AES_XCBC_MAC	9
 #define SADB_X_AALG_NULL		251	/* kame */
 #define SADB_AALG_MAX			251
 
diff --git a/net/xfrm/xfrm_algo.c b/net/xfrm/xfrm_algo.c
index 2783d4e..6c48292 100644
--- a/net/xfrm/xfrm_algo.c
+++ b/net/xfrm/xfrm_algo.c
@@ -119,6 +119,24 @@ static struct xfrm_algo_desc aalg_list[]
 		.sadb_alg_maxbits = 160
 	}
 },
+{
+	.name = "xcbc(aes)",
+	.compat = "aes_xcbc_128",
+
+	.uinfo = {
+		.auth = {
+			.icv_truncbits = 96,
+			.icv_fullbits = 128,
+		}
+	},
+
+	.desc = {
+		.sadb_alg_id = SADB_X_AALG_AES_XCBC_MAC,
+		.sadb_alg_ivlen = 0,
+		.sadb_alg_minbits = 128,
+		.sadb_alg_maxbits = 128
+	}
+},
 };
 
 static struct xfrm_algo_desc ealg_list[] = {

