From: Jussi Kivilinna <jussi.kivilinna@iki.fi>
Subject: [PATCH 1/2] crypto: add CMAC support to CryptoAPI
Date: Mon, 08 Apr 2013 10:48:44 +0300
Message-ID: <20130408074844.6866.90093.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org, Tom St Denis <tstdenis@elliptictech.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
To: linux-crypto@vger.kernel.org
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patch adds support for NIST recommended block cipher mode CMAC to Crypt=
oAPI.

This work is based on Tom St Denis' earlier patch,
 http://marc.info/?l=3Dlinux-crypto-vger&m=3D135877306305466&w=3D2

Cc: Tom St Denis <tstdenis@elliptictech.com>
Signed-off-by: Jussi Kivilinna <jussi.kivilinna@iki.fi>
---
 crypto/Kconfig   |   11 ++
 crypto/Makefile  |    1=20
 crypto/cmac.c    |  315 ++++++++++++++++++++++++++++++++++++++++++++++=
++++++++
 crypto/tcrypt.c  |   11 ++
 crypto/testmgr.c |   18 +++
 crypto/testmgr.h |  125 +++++++++++++++++++++
 6 files changed, 480 insertions(+), 1 deletion(-)
 create mode 100644 crypto/cmac.c

diff --git a/crypto/Kconfig b/crypto/Kconfig
index 6cc27f1..c1142f3 100644
--- a/crypto/Kconfig
+++ b/crypto/Kconfig
@@ -283,6 +283,17 @@ config CRYPTO_XTS
=20
 comment "Hash modes"
=20
+config CRYPTO_CMAC
+	tristate "CMAC support"
+	select CRYPTO_HASH
+	select CRYPTO_MANAGER
+	help
+	  Cipher-based Message Authentication Code (CMAC) specified by
+	  The National Institute of Standards and Technology (NIST).
+
+	  https://tools.ietf.org/html/rfc4493
+	  http://csrc.nist.gov/publications/nistpubs/800-38B/SP_800-38B.pdf
+
 config CRYPTO_HMAC
 	tristate "HMAC support"
 	select CRYPTO_HASH
diff --git a/crypto/Makefile b/crypto/Makefile
index be1a1be..a8e9b0f 100644
--- a/crypto/Makefile
+++ b/crypto/Makefile
@@ -32,6 +32,7 @@ cryptomgr-y :=3D algboss.o testmgr.o
=20
 obj-$(CONFIG_CRYPTO_MANAGER2) +=3D cryptomgr.o
 obj-$(CONFIG_CRYPTO_USER) +=3D crypto_user.o
+obj-$(CONFIG_CRYPTO_CMAC) +=3D cmac.o
 obj-$(CONFIG_CRYPTO_HMAC) +=3D hmac.o
 obj-$(CONFIG_CRYPTO_VMAC) +=3D vmac.o
 obj-$(CONFIG_CRYPTO_XCBC) +=3D xcbc.o
diff --git a/crypto/cmac.c b/crypto/cmac.c
new file mode 100644
index 0000000..50880cf
--- /dev/null
+++ b/crypto/cmac.c
@@ -0,0 +1,315 @@
+/*
+ * CMAC: Cipher Block Mode for Authentication
+ *
+ * Copyright =C2=A9 2013 Jussi Kivilinna <jussi.kivilinna@iki.fi>
+ *
+ * Based on work by:
+ *  Copyright =C2=A9 2013 Tom St Denis <tstdenis@elliptictech.com>
+ * Based on crypto/xcbc.c:
+ *  Copyright =C2=A9 2006 USAGI/WIDE Project,
+ *   Author: Kazunori Miyazawa <miyazawa@linux-ipv6.org>
+ *
+ * This program is free software; you can redistribute it and/or modif=
y
+ * it under the terms of the GNU General Public License as published b=
y
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ */
+
+#include <crypto/internal/hash.h>
+#include <linux/err.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+
+/*
+ * +------------------------
+ * | <parent tfm>
+ * +------------------------
+ * | cmac_tfm_ctx
+ * +------------------------
+ * | consts (block size * 2)
+ * +------------------------
+ */
+struct cmac_tfm_ctx {
+	struct crypto_cipher *child;
+	u8 ctx[];
+};
+
+/*
+ * +------------------------
+ * | <shash desc>
+ * +------------------------
+ * | cmac_desc_ctx
+ * +------------------------
+ * | odds (block size)
+ * +------------------------
+ * | prev (block size)
+ * +------------------------
+ */
+struct cmac_desc_ctx {
+	unsigned int len;
+	u8 ctx[];
+};
+
+static int crypto_cmac_digest_setkey(struct crypto_shash *parent,
+				     const u8 *inkey, unsigned int keylen)
+{
+	unsigned long alignmask =3D crypto_shash_alignmask(parent);
+	struct cmac_tfm_ctx *ctx =3D crypto_shash_ctx(parent);
+	unsigned int bs =3D crypto_shash_blocksize(parent);
+	__be64 *consts =3D PTR_ALIGN((void *)ctx->ctx, alignmask + 1);
+	u64 _const[2];
+	int i, err =3D 0;
+	u8 msb_mask, gfmask;
+
+	err =3D crypto_cipher_setkey(ctx->child, inkey, keylen);
+	if (err)
+		return err;
+
+	/* encrypt the zero block */
+	memset(consts, 0, bs);
+	crypto_cipher_encrypt_one(ctx->child, (u8 *)consts, (u8 *)consts);
+
+	switch (bs) {
+	case 16:
+		gfmask =3D 0x87;
+		_const[0] =3D be64_to_cpu(consts[1]);
+		_const[1] =3D be64_to_cpu(consts[0]);
+
+		/* gf(2^128) multiply zero-ciphertext with u and u^2 */
+		for (i =3D 0; i < 4; i +=3D 2) {
+			msb_mask =3D ((s64)_const[1] >> 63) & gfmask;
+			_const[1] =3D (_const[1] << 1) | (_const[0] >> 63);
+			_const[0] =3D (_const[0] << 1) ^ msb_mask;
+
+			consts[i + 0] =3D cpu_to_be64(_const[1]);
+			consts[i + 1] =3D cpu_to_be64(_const[0]);
+		}
+
+		break;
+	case 8:
+		gfmask =3D 0x1B;
+		_const[0] =3D be64_to_cpu(consts[0]);
+
+		/* gf(2^64) multiply zero-ciphertext with u and u^2 */
+		for (i =3D 0; i < 2; i++) {
+			msb_mask =3D ((s64)_const[0] >> 63) & gfmask;
+			_const[0] =3D (_const[0] << 1) ^ msb_mask;
+
+			consts[i] =3D cpu_to_be64(_const[0]);
+		}
+
+		break;
+	}
+
+	return 0;
+}
+
+static int crypto_cmac_digest_init(struct shash_desc *pdesc)
+{
+	unsigned long alignmask =3D crypto_shash_alignmask(pdesc->tfm);
+	struct cmac_desc_ctx *ctx =3D shash_desc_ctx(pdesc);
+	int bs =3D crypto_shash_blocksize(pdesc->tfm);
+	u8 *prev =3D PTR_ALIGN((void *)ctx->ctx, alignmask + 1) + bs;
+
+	ctx->len =3D 0;
+	memset(prev, 0, bs);
+
+	return 0;
+}
+
+static int crypto_cmac_digest_update(struct shash_desc *pdesc, const u=
8 *p,
+				     unsigned int len)
+{
+	struct crypto_shash *parent =3D pdesc->tfm;
+	unsigned long alignmask =3D crypto_shash_alignmask(parent);
+	struct cmac_tfm_ctx *tctx =3D crypto_shash_ctx(parent);
+	struct cmac_desc_ctx *ctx =3D shash_desc_ctx(pdesc);
+	struct crypto_cipher *tfm =3D tctx->child;
+	int bs =3D crypto_shash_blocksize(parent);
+	u8 *odds =3D PTR_ALIGN((void *)ctx->ctx, alignmask + 1);
+	u8 *prev =3D odds + bs;
+
+	/* checking the data can fill the block */
+	if ((ctx->len + len) <=3D bs) {
+		memcpy(odds + ctx->len, p, len);
+		ctx->len +=3D len;
+		return 0;
+	}
+
+	/* filling odds with new data and encrypting it */
+	memcpy(odds + ctx->len, p, bs - ctx->len);
+	len -=3D bs - ctx->len;
+	p +=3D bs - ctx->len;
+
+	crypto_xor(prev, odds, bs);
+	crypto_cipher_encrypt_one(tfm, prev, prev);
+
+	/* clearing the length */
+	ctx->len =3D 0;
+
+	/* encrypting the rest of data */
+	while (len > bs) {
+		crypto_xor(prev, p, bs);
+		crypto_cipher_encrypt_one(tfm, prev, prev);
+		p +=3D bs;
+		len -=3D bs;
+	}
+
+	/* keeping the surplus of blocksize */
+	if (len) {
+		memcpy(odds, p, len);
+		ctx->len =3D len;
+	}
+
+	return 0;
+}
+
+static int crypto_cmac_digest_final(struct shash_desc *pdesc, u8 *out)
+{
+	struct crypto_shash *parent =3D pdesc->tfm;
+	unsigned long alignmask =3D crypto_shash_alignmask(parent);
+	struct cmac_tfm_ctx *tctx =3D crypto_shash_ctx(parent);
+	struct cmac_desc_ctx *ctx =3D shash_desc_ctx(pdesc);
+	struct crypto_cipher *tfm =3D tctx->child;
+	int bs =3D crypto_shash_blocksize(parent);
+	u8 *consts =3D PTR_ALIGN((void *)tctx->ctx, alignmask + 1);
+	u8 *odds =3D PTR_ALIGN((void *)ctx->ctx, alignmask + 1);
+	u8 *prev =3D odds + bs;
+	unsigned int offset =3D 0;
+
+	if (ctx->len !=3D bs) {
+		unsigned int rlen;
+		u8 *p =3D odds + ctx->len;
+
+		*p =3D 0x80;
+		p++;
+
+		rlen =3D bs - ctx->len - 1;
+		if (rlen)
+			memset(p, 0, rlen);
+
+		offset +=3D bs;
+	}
+
+	crypto_xor(prev, odds, bs);
+	crypto_xor(prev, consts + offset, bs);
+
+	crypto_cipher_encrypt_one(tfm, out, prev);
+
+	return 0;
+}
+
+static int cmac_init_tfm(struct crypto_tfm *tfm)
+{
+	struct crypto_cipher *cipher;
+	struct crypto_instance *inst =3D (void *)tfm->__crt_alg;
+	struct crypto_spawn *spawn =3D crypto_instance_ctx(inst);
+	struct cmac_tfm_ctx *ctx =3D crypto_tfm_ctx(tfm);
+
+	cipher =3D crypto_spawn_cipher(spawn);
+	if (IS_ERR(cipher))
+		return PTR_ERR(cipher);
+
+	ctx->child =3D cipher;
+
+	return 0;
+};
+
+static void cmac_exit_tfm(struct crypto_tfm *tfm)
+{
+	struct cmac_tfm_ctx *ctx =3D crypto_tfm_ctx(tfm);
+	crypto_free_cipher(ctx->child);
+}
+
+static int cmac_create(struct crypto_template *tmpl, struct rtattr **t=
b)
+{
+	struct shash_instance *inst;
+	struct crypto_alg *alg;
+	unsigned long alignmask;
+	int err;
+
+	err =3D crypto_check_attr_type(tb, CRYPTO_ALG_TYPE_SHASH);
+	if (err)
+		return err;
+
+	alg =3D crypto_get_attr_alg(tb, CRYPTO_ALG_TYPE_CIPHER,
+				  CRYPTO_ALG_TYPE_MASK);
+	if (IS_ERR(alg))
+		return PTR_ERR(alg);
+
+	switch (alg->cra_blocksize) {
+	case 16:
+	case 8:
+		break;
+	default:
+		goto out_put_alg;
+	}
+
+	inst =3D shash_alloc_instance("cmac", alg);
+	err =3D PTR_ERR(inst);
+	if (IS_ERR(inst))
+		goto out_put_alg;
+
+	err =3D crypto_init_spawn(shash_instance_ctx(inst), alg,
+				shash_crypto_instance(inst),
+				CRYPTO_ALG_TYPE_MASK);
+	if (err)
+		goto out_free_inst;
+
+	alignmask =3D alg->cra_alignmask | (sizeof(long) - 1);
+	inst->alg.base.cra_alignmask =3D alignmask;
+	inst->alg.base.cra_priority =3D alg->cra_priority;
+	inst->alg.base.cra_blocksize =3D alg->cra_blocksize;
+
+	inst->alg.digestsize =3D alg->cra_blocksize;
+	inst->alg.descsize =3D
+		ALIGN(sizeof(struct cmac_desc_ctx), crypto_tfm_ctx_alignment())
+		+ (alignmask & ~(crypto_tfm_ctx_alignment() - 1))
+		+ alg->cra_blocksize * 2;
+
+	inst->alg.base.cra_ctxsize =3D
+		ALIGN(sizeof(struct cmac_tfm_ctx), alignmask + 1)
+		+ alg->cra_blocksize * 2;
+
+	inst->alg.base.cra_init =3D cmac_init_tfm;
+	inst->alg.base.cra_exit =3D cmac_exit_tfm;
+
+	inst->alg.init =3D crypto_cmac_digest_init;
+	inst->alg.update =3D crypto_cmac_digest_update;
+	inst->alg.final =3D crypto_cmac_digest_final;
+	inst->alg.setkey =3D crypto_cmac_digest_setkey;
+
+	err =3D shash_register_instance(tmpl, inst);
+	if (err) {
+out_free_inst:
+		shash_free_instance(shash_crypto_instance(inst));
+	}
+
+out_put_alg:
+	crypto_mod_put(alg);
+	return err;
+}
+
+static struct crypto_template crypto_cmac_tmpl =3D {
+	.name =3D "cmac",
+	.create =3D cmac_create,
+	.free =3D shash_free_instance,
+	.module =3D THIS_MODULE,
+};
+
+static int __init crypto_cmac_module_init(void)
+{
+	return crypto_register_template(&crypto_cmac_tmpl);
+}
+
+static void __exit crypto_cmac_module_exit(void)
+{
+	crypto_unregister_template(&crypto_cmac_tmpl);
+}
+
+module_init(crypto_cmac_module_init);
+module_exit(crypto_cmac_module_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("CMAC keyed hash algorithm");
diff --git a/crypto/tcrypt.c b/crypto/tcrypt.c
index 6b911ef..24ea7df 100644
--- a/crypto/tcrypt.c
+++ b/crypto/tcrypt.c
@@ -1095,7 +1095,6 @@ static int do_test(int m)
 		break;
=20
 	case 28:
-
 		ret +=3D tcrypt_test("tgr160");
 		break;
=20
@@ -1118,6 +1117,7 @@ static int do_test(int m)
 		ret +=3D tcrypt_test("lrw(camellia)");
 		ret +=3D tcrypt_test("xts(camellia)");
 		break;
+
 	case 33:
 		ret +=3D tcrypt_test("sha224");
 		break;
@@ -1213,6 +1213,7 @@ static int do_test(int m)
 	case 109:
 		ret +=3D tcrypt_test("vmac(aes)");
 		break;
+
 	case 110:
 		ret +=3D tcrypt_test("hmac(crc32)");
 		break;
@@ -1229,6 +1230,14 @@ static int do_test(int m)
 		ret +=3D tcrypt_test("rfc4543(gcm(aes))");
 		break;
=20
+	case 153:
+		ret +=3D tcrypt_test("cmac(aes)");
+		break;
+
+	case 154:
+		ret +=3D tcrypt_test("cmac(des3_ede)");
+		break;
+
 	case 200:
 		test_cipher_speed("ecb(aes)", ENCRYPT, sec, NULL, 0,
 				speed_template_16_24_32);
diff --git a/crypto/testmgr.c b/crypto/testmgr.c
index f37e544..3807084 100644
--- a/crypto/testmgr.c
+++ b/crypto/testmgr.c
@@ -1913,6 +1913,24 @@ static const struct alg_test_desc alg_test_descs=
[] =3D {
 			}
 		}
 	}, {
+		.alg =3D "cmac(aes)",
+		.test =3D alg_test_hash,
+		.suite =3D {
+			.hash =3D {
+				.vecs =3D aes_cmac128_tv_template,
+				.count =3D CMAC_AES_TEST_VECTORS
+			}
+		}
+	}, {
+		.alg =3D "cmac(des3_ede)",
+		.test =3D alg_test_hash,
+		.suite =3D {
+			.hash =3D {
+				.vecs =3D des3_ede_cmac64_tv_template,
+				.count =3D CMAC_DES3_EDE_TEST_VECTORS
+			}
+		}
+	}, {
 		.alg =3D "compress_null",
 		.test =3D alg_test_null,
 	}, {
diff --git a/crypto/testmgr.h b/crypto/testmgr.h
index 92db37d..d503660 100644
--- a/crypto/testmgr.h
+++ b/crypto/testmgr.h
@@ -1639,6 +1639,131 @@ static struct hash_testvec hmac_sha256_tv_templ=
ate[] =3D {
 	},
 };
=20
+#define CMAC_AES_TEST_VECTORS 6
+
+static struct hash_testvec aes_cmac128_tv_template[] =3D {
+	{ /* From NIST Special Publication 800-38B, AES-128 */
+		.key		=3D "\x2b\x7e\x15\x16\x28\xae\xd2\xa6"
+				  "\xab\xf7\x15\x88\x09\xcf\x4f\x3c",
+		.plaintext	=3D zeroed_string,
+		.digest		=3D "\xbb\x1d\x69\x29\xe9\x59\x37\x28"
+				  "\x7f\xa3\x7d\x12\x9b\x75\x67\x46",
+		.psize		=3D 0,
+		.ksize		=3D 16,
+	}, {
+		.key		=3D "\x2b\x7e\x15\x16\x28\xae\xd2\xa6"
+				  "\xab\xf7\x15\x88\x09\xcf\x4f\x3c",
+		.plaintext	=3D "\x6b\xc1\xbe\xe2\x2e\x40\x9f\x96"
+				  "\xe9\x3d\x7e\x11\x73\x93\x17\x2a",
+		.digest		=3D "\x07\x0a\x16\xb4\x6b\x4d\x41\x44"
+				  "\xf7\x9b\xdd\x9d\xd0\x4a\x28\x7c",
+		.psize		=3D 16,
+		.ksize		=3D 16,
+	}, {
+		.key		=3D "\x2b\x7e\x15\x16\x28\xae\xd2\xa6"
+				  "\xab\xf7\x15\x88\x09\xcf\x4f\x3c",
+		.plaintext	=3D "\x6b\xc1\xbe\xe2\x2e\x40\x9f\x96"
+				  "\xe9\x3d\x7e\x11\x73\x93\x17\x2a"
+				  "\xae\x2d\x8a\x57\x1e\x03\xac\x9c"
+				  "\x9e\xb7\x6f\xac\x45\xaf\x8e\x51"
+				  "\x30\xc8\x1c\x46\xa3\x5c\xe4\x11",
+		.digest		=3D "\xdf\xa6\x67\x47\xde\x9a\xe6\x30"
+				  "\x30\xca\x32\x61\x14\x97\xc8\x27",
+		.psize		=3D 40,
+		.ksize		=3D 16,
+	}, {
+		.key		=3D "\x2b\x7e\x15\x16\x28\xae\xd2\xa6"
+				  "\xab\xf7\x15\x88\x09\xcf\x4f\x3c",
+		.plaintext	=3D "\x6b\xc1\xbe\xe2\x2e\x40\x9f\x96"
+				  "\xe9\x3d\x7e\x11\x73\x93\x17\x2a"
+				  "\xae\x2d\x8a\x57\x1e\x03\xac\x9c"
+				  "\x9e\xb7\x6f\xac\x45\xaf\x8e\x51"
+				  "\x30\xc8\x1c\x46\xa3\x5c\xe4\x11"
+				  "\xe5\xfb\xc1\x19\x1a\x0a\x52\xef"
+				  "\xf6\x9f\x24\x45\xdf\x4f\x9b\x17"
+				  "\xad\x2b\x41\x7b\xe6\x6c\x37\x10",
+		.digest		=3D "\x51\xf0\xbe\xbf\x7e\x3b\x9d\x92"
+				  "\xfc\x49\x74\x17\x79\x36\x3c\xfe",
+		.psize		=3D 64,
+		.ksize		=3D 16,
+	}, { /* From NIST Special Publication 800-38B, AES-256 */
+		.key		=3D "\x60\x3d\xeb\x10\x15\xca\x71\xbe"
+				  "\x2b\x73\xae\xf0\x85\x7d\x77\x81"
+				  "\x1f\x35\x2c\x07\x3b\x61\x08\xd7"
+				  "\x2d\x98\x10\xa3\x09\x14\xdf\xf4",
+		.plaintext	=3D zeroed_string,
+		.digest		=3D "\x02\x89\x62\xf6\x1b\x7b\xf8\x9e"
+				  "\xfc\x6b\x55\x1f\x46\x67\xd9\x83",
+		.psize		=3D 0,
+		.ksize		=3D 32,
+	}, {
+		.key		=3D "\x60\x3d\xeb\x10\x15\xca\x71\xbe"
+				  "\x2b\x73\xae\xf0\x85\x7d\x77\x81"
+				  "\x1f\x35\x2c\x07\x3b\x61\x08\xd7"
+				  "\x2d\x98\x10\xa3\x09\x14\xdf\xf4",
+		.plaintext	=3D "\x6b\xc1\xbe\xe2\x2e\x40\x9f\x96"
+				  "\xe9\x3d\x7e\x11\x73\x93\x17\x2a"
+				  "\xae\x2d\x8a\x57\x1e\x03\xac\x9c"
+				  "\x9e\xb7\x6f\xac\x45\xaf\x8e\x51"
+				  "\x30\xc8\x1c\x46\xa3\x5c\xe4\x11"
+				  "\xe5\xfb\xc1\x19\x1a\x0a\x52\xef"
+				  "\xf6\x9f\x24\x45\xdf\x4f\x9b\x17"
+				  "\xad\x2b\x41\x7b\xe6\x6c\x37\x10",
+		.digest		=3D "\xe1\x99\x21\x90\x54\x9f\x6e\xd5"
+				  "\x69\x6a\x2c\x05\x6c\x31\x54\x10",
+		.psize		=3D 64,
+		.ksize		=3D 32,
+	}
+};
+
+#define CMAC_DES3_EDE_TEST_VECTORS 4
+
+static struct hash_testvec des3_ede_cmac64_tv_template[] =3D {
+/*
+ * From NIST Special Publication 800-38B, Three Key TDEA
+ * Corrected test vectors from:
+ *  http://csrc.nist.gov/publications/nistpubs/800-38B/Updated_CMAC_Ex=
amples.pdf
+ */
+	{
+		.key		=3D "\x8a\xa8\x3b\xf8\xcb\xda\x10\x62"
+				  "\x0b\xc1\xbf\x19\xfb\xb6\xcd\x58"
+				  "\xbc\x31\x3d\x4a\x37\x1c\xa8\xb5",
+		.plaintext	=3D zeroed_string,
+		.digest		=3D "\xb7\xa6\x88\xe1\x22\xff\xaf\x95",
+		.psize		=3D 0,
+		.ksize		=3D 24,
+	}, {
+		.key		=3D "\x8a\xa8\x3b\xf8\xcb\xda\x10\x62"
+				  "\x0b\xc1\xbf\x19\xfb\xb6\xcd\x58"
+				  "\xbc\x31\x3d\x4a\x37\x1c\xa8\xb5",
+		.plaintext	=3D "\x6b\xc1\xbe\xe2\x2e\x40\x9f\x96",
+		.digest		=3D "\x8e\x8f\x29\x31\x36\x28\x37\x97",
+		.psize		=3D 8,
+		.ksize		=3D 24,
+	}, {
+		.key		=3D "\x8a\xa8\x3b\xf8\xcb\xda\x10\x62"
+				  "\x0b\xc1\xbf\x19\xfb\xb6\xcd\x58"
+				  "\xbc\x31\x3d\x4a\x37\x1c\xa8\xb5",
+		.plaintext	=3D "\x6b\xc1\xbe\xe2\x2e\x40\x9f\x96"
+				  "\xe9\x3d\x7e\x11\x73\x93\x17\x2a"
+				  "\xae\x2d\x8a\x57",
+		.digest		=3D "\x74\x3d\xdb\xe0\xce\x2d\xc2\xed",
+		.psize		=3D 20,
+		.ksize		=3D 24,
+	}, {
+		.key		=3D "\x8a\xa8\x3b\xf8\xcb\xda\x10\x62"
+				  "\x0b\xc1\xbf\x19\xfb\xb6\xcd\x58"
+				  "\xbc\x31\x3d\x4a\x37\x1c\xa8\xb5",
+		.plaintext	=3D "\x6b\xc1\xbe\xe2\x2e\x40\x9f\x96"
+				  "\xe9\x3d\x7e\x11\x73\x93\x17\x2a"
+				  "\xae\x2d\x8a\x57\x1e\x03\xac\x9c"
+				  "\x9e\xb7\x6f\xac\x45\xaf\x8e\x51",
+		.digest		=3D "\x33\xe6\xb1\x09\x24\x00\xea\xe5",
+		.psize		=3D 32,
+		.ksize		=3D 24,
+	}
+};
+
 #define XCBC_AES_TEST_VECTORS 6
=20
 static struct hash_testvec aes_xcbc128_tv_template[] =3D {
