From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: [PATCH 2/4][CRYPTO][IPsec] add xcbc support
Date: Wed, 18 Oct 2006 11:26:12 +0900
Message-ID: <20061018112612.e8f1f509.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 221x116x13x66.ap221.ftth.ucom.ne.jp ([221.116.13.66]:58859 "EHLO
	miyazawa.org") by vger.kernel.org with ESMTP id S1751168AbWJRC0N
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 22:26:13 -0400
To: davem@davemloft.net, herbert@gondor.apana.org.au
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is core code of XCBC.

Signed-off-by: Kazunori MIYAZAWA <miyazawa@linux-ipv6.org>
---
 crypto/Kconfig  |   10 ++
 crypto/Makefile |    1 
 crypto/xcbc.c   |  328 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 339 insertions(+), 0 deletions(-)

diff --git a/crypto/Kconfig b/crypto/Kconfig
index 1e2f39c..f20ef70 100644
--- a/crypto/Kconfig
+++ b/crypto/Kconfig
@@ -39,6 +39,16 @@ config CRYPTO_HMAC
 	  HMAC: Keyed-Hashing for Message Authentication (RFC2104).
 	  This is required for IPSec.
 
+config CRYPTO_XCBC
+        tristate "XCBC support"
+        depends on EXPERIMENTAL
+	select CRYPTO_MANAGER
+        help
+          XCBC: Keyed-Hashing with encryption algorithm
+                http://www.ietf.org/rfc/rfc3566.txt
+                http://csrc.nist.gov/encryption/modes/proposedmodes/
+                 xcbc-mac/xcbc-mac-spec.pdf
+
 config CRYPTO_NULL
 	tristate "Null algorithms"
 	select CRYPTO_ALGAPI
diff --git a/crypto/Makefile b/crypto/Makefile
index 7236620..aba9625 100644
--- a/crypto/Makefile
+++ b/crypto/Makefile
@@ -15,6 +15,7 @@ obj-$(CONFIG_CRYPTO_HASH) += crypto_hash
 
 obj-$(CONFIG_CRYPTO_MANAGER) += cryptomgr.o
 obj-$(CONFIG_CRYPTO_HMAC) += hmac.o
+obj-$(CONFIG_CRYPTO_XCBC) += xcbc.o
 obj-$(CONFIG_CRYPTO_NULL) += crypto_null.o
 obj-$(CONFIG_CRYPTO_MD4) += md4.o
 obj-$(CONFIG_CRYPTO_MD5) += md5.o
diff --git a/crypto/xcbc.c b/crypto/xcbc.c
new file mode 100644
index 0000000..eb1641b
--- /dev/null
+++ b/crypto/xcbc.c
@@ -0,0 +1,328 @@
+/*
+ * Copyright (C)2006 USAGI/WIDE Project
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
+/*
+ * +------------------------
+ * | <parent tfm>
+ * +------------------------
+ * | crypto_xcbc_ctx
+ * +------------------------
+ * | prev (block size)
+ * +------------------------
+ * | key (block size)
+ * +------------------------
+ * | consts (block size * 3)
+ * +------------------------
+ */
+struct crypto_xcbc_ctx {
+	struct crypto_tfm *child;
+	u8 *prev;
+	u8 *key;
+	u8 *consts;
+	unsigned int keylen;
+	unsigned int len;
+};
+
+static int _crypto_xcbc_digest_setkey(struct crypto_hash *parent,
+				      struct crypto_xcbc_ctx *ctx)
+{
+	int bs = crypto_hash_blocksize(parent);
+	int err = 0;
+	u8 key1[bs];
+
+	if ((err = crypto_cipher_setkey(ctx->child, ctx->key, ctx->keylen)))
+	    return err;
+
+	ctx->child->__crt_alg->cra_cipher.cia_encrypt(ctx->child, key1,
+			ctx->consts);
+
+	return crypto_cipher_setkey(ctx->child, key1, bs);
+}
+
+static int crypto_xcbc_digest_setkey(struct crypto_hash *parent,
+				     const u8 *inkey, unsigned int keylen)
+{
+	struct crypto_xcbc_ctx *ctx = crypto_hash_ctx_aligned(parent);
+
+	if (keylen != crypto_tfm_alg_blocksize(ctx->child))
+		return -EINVAL;
+
+	ctx->keylen = keylen;
+	memcpy(ctx->key, inkey, keylen);
+	memcpy(ctx->consts, ks, sizeof(ks));
+
+	return _crypto_xcbc_digest_setkey(parent, ctx);
+}
+
+int crypto_xcbc_digest_init(struct hash_desc *pdesc)
+{
+	struct crypto_xcbc_ctx *ctx = crypto_hash_ctx_aligned(pdesc->tfm);
+	int bs = crypto_hash_blocksize(pdesc->tfm);
+
+	ctx->len = 0;
+	memset(ctx->prev, 0, bs);
+	memset(ctx->child->crt_cipher.cit_iv, 0, crypto_tfm_alg_blocksize(ctx->child));
+
+	return 0;
+}
+
+int crypto_xcbc_digest_update(struct hash_desc *pdesc, struct scatterlist *sg, unsigned int nbytes)
+{
+	struct crypto_hash *parent = pdesc->tfm;
+	struct crypto_xcbc_ctx *ctx = crypto_hash_ctx_aligned(parent);
+	struct crypto_tfm *tfm = ctx->child;
+	int bs = crypto_hash_blocksize(parent);
+	unsigned int i = 0;
+
+	if (!(tfm->crt_cipher.cit_mode & CRYPTO_TFM_MODE_CBC))
+		return -EINVAL;
+ 
+	do {
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
+				memcpy(ctx->prev + ctx->len, p, len);
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
+				crypto_yield(tfm->crt_flags);
+				continue;
+			}
+
+			/* filling prev with new data and encrypting it */
+			memcpy(ctx->prev + ctx->len, p, bs - ctx->len);
+			len -= bs - ctx->len;
+			p += bs - ctx->len;
+			crypto_cipher_crt(tfm)->cit_xor_block(tfm->crt_cipher.cit_iv,
+							ctx->prev);
+			tfm->__crt_alg->cra_cipher.cia_encrypt(tfm,
+					tfm->crt_cipher.cit_iv,
+					tfm->crt_cipher.cit_iv);
+
+			/* clearing the length */
+			ctx->len = 0;
+
+			/* encrypting the rest of data */
+			while (len > bs) {
+				crypto_cipher_crt(tfm)->cit_xor_block(tfm->crt_cipher.cit_iv, p);
+				tfm->__crt_alg->cra_cipher.cia_encrypt(tfm,
+						tfm->crt_cipher.cit_iv,
+						tfm->crt_cipher.cit_iv);
+				p += bs;
+				len -= bs;
+			}
+
+			/* keeping the surplus of blocksize */
+			if (len) {
+				memcpy(ctx->prev, p, len);
+				ctx->len = len;
+			}
+			crypto_kunmap(p, 0);
+			crypto_yield(tfm->crt_flags);
+			slen -= min(slen, ((unsigned int)(PAGE_SIZE)) - offset);
+			offset = 0;
+			pg++;
+		}
+		nbytes-=sg[i].length;
+		i++;
+	} while (nbytes>0);
+
+	return 0;
+}
+
+int crypto_xcbc_digest_final(struct hash_desc *pdesc, u8 *out)
+{
+	struct crypto_hash *parent = pdesc->tfm;
+	struct crypto_xcbc_ctx *ctx = crypto_hash_ctx_aligned(parent);
+	struct crypto_tfm *tfm = ctx->child;
+	int bs = crypto_hash_blocksize(parent);
+	int err = 0;
+
+	if (ctx->len == bs) {
+		u8 key2[bs];
+
+		if ((err = crypto_cipher_setkey(tfm, ctx->key, ctx->keylen)) != 0)
+			return err;
+
+		tfm->__crt_alg->cra_cipher.cia_encrypt(tfm, key2, (const u8*)(ctx->consts+bs));
+		crypto_cipher_crt(tfm)->cit_xor_block(tfm->crt_cipher.cit_iv, ctx->prev);
+		crypto_cipher_crt(tfm)->cit_xor_block(tfm->crt_cipher.cit_iv, key2);
+
+		_crypto_xcbc_digest_setkey(parent, ctx);
+
+		tfm->__crt_alg->cra_cipher.cia_encrypt(tfm, out, tfm->crt_cipher.cit_iv);
+	} else {
+		u8 key3[bs];
+		unsigned int rlen;
+		u8 *p = ctx->prev + ctx->len;
+		*p = 0x80;
+		p++;
+
+		rlen = bs - ctx->len -1;
+		if (rlen)
+			memset(p, 0, rlen);
+
+		if ((err = crypto_cipher_setkey(tfm, ctx->key, ctx->keylen)) != 0)
+			return err;
+
+		tfm->__crt_alg->cra_cipher.cia_encrypt(tfm, key3, (const u8*)(ctx->consts+bs*2));
+
+		crypto_cipher_crt(tfm)->cit_xor_block(tfm->crt_cipher.cit_iv, ctx->prev);
+		crypto_cipher_crt(tfm)->cit_xor_block(tfm->crt_cipher.cit_iv, key3);
+
+		_crypto_xcbc_digest_setkey(parent, ctx);
+
+		tfm->__crt_alg->cra_cipher.cia_encrypt(tfm, out, tfm->crt_cipher.cit_iv);
+	}
+
+	return 0;
+}
+
+static int crypto_xcbc_digest(struct hash_desc *pdesc,
+		  struct scatterlist *sg, unsigned int nbytes, u8 *out)
+{
+	crypto_xcbc_digest_init(pdesc);
+	crypto_xcbc_digest_update(pdesc, sg, nbytes);
+	return crypto_xcbc_digest_final(pdesc, out);
+}
+
+static int xcbc_init_tfm(struct crypto_tfm *tfm)
+{
+	struct crypto_instance *inst = (void *)tfm->__crt_alg;
+	struct crypto_spawn *spawn = crypto_instance_ctx(inst);
+	struct crypto_xcbc_ctx *ctx = crypto_hash_ctx_aligned(__crypto_hash_cast(tfm));
+	int bs = crypto_hash_blocksize(__crypto_hash_cast(tfm));
+
+	spawn->flags = CRYPTO_TFM_MODE_CBC;
+
+	tfm = crypto_spawn_tfm(spawn);
+	if (IS_ERR(tfm))
+		return PTR_ERR(tfm);
+	ctx->child = crypto_cipher_cast(tfm);
+	ctx->prev = (u8*)(ctx+1);
+	ctx->key = ctx->prev + bs;
+	ctx->consts = ctx->key + bs;
+
+	return 0;
+};
+
+static void xcbc_exit_tfm(struct crypto_tfm *tfm)
+{
+	struct crypto_xcbc_ctx *ctx = crypto_hash_ctx_aligned(__crypto_hash_cast(tfm));
+	crypto_free_cipher(ctx->child);
+}
+
+static struct crypto_instance *xcbc_alloc(void *param, unsigned int len)
+{
+	struct crypto_instance *inst;
+	struct crypto_alg *alg;
+	alg = crypto_get_attr_alg(param, len, CRYPTO_ALG_TYPE_CIPHER,
+				  CRYPTO_ALG_TYPE_HASH_MASK | CRYPTO_ALG_ASYNC);
+	if (IS_ERR(alg))
+		return ERR_PTR(PTR_ERR(alg));
+
+
+	inst = crypto_alloc_instance("xcbc", alg);
+	if (IS_ERR(inst))
+		goto out_put_alg;
+
+	inst->alg.cra_flags = CRYPTO_ALG_TYPE_HASH;
+	inst->alg.cra_priority = alg->cra_priority;
+	inst->alg.cra_blocksize = alg->cra_blocksize;
+	inst->alg.cra_alignmask = alg->cra_alignmask;
+	inst->alg.cra_type = &crypto_hash_type;
+
+	inst->alg.cra_hash.digestsize =
+		(alg->cra_flags & CRYPTO_ALG_TYPE_MASK) ==
+		CRYPTO_ALG_TYPE_HASH ? alg->cra_hash.digestsize :
+		      		       alg->cra_blocksize;
+	inst->alg.cra_ctxsize = sizeof(struct crypto_xcbc_ctx) +
+				ALIGN(inst->alg.cra_blocksize * 6, sizeof(void *));
+	inst->alg.cra_init = xcbc_init_tfm;
+	inst->alg.cra_exit = xcbc_exit_tfm;
+
+	inst->alg.cra_hash.init = crypto_xcbc_digest_init;
+	inst->alg.cra_hash.update = crypto_xcbc_digest_update;
+	inst->alg.cra_hash.final = crypto_xcbc_digest_final;
+	inst->alg.cra_hash.digest = crypto_xcbc_digest;
+	inst->alg.cra_hash.setkey = crypto_xcbc_digest_setkey;
+
+out_put_alg:
+	crypto_mod_put(alg);
+	return inst;
+}
+
+static void xcbc_free(struct crypto_instance *inst)
+{
+	crypto_drop_spawn(crypto_instance_ctx(inst));
+	kfree(inst);
+}
+
+static struct crypto_template crypto_xcbc_tmpl = {
+	.name = "xcbc",
+	.alloc = xcbc_alloc,
+	.free = xcbc_free,
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
+MODULE_DESCRIPTION("XCBC keyed hash algorithm");
-- 
1.4.2
