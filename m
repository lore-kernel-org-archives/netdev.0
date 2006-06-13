From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: [PATCH 2/2] AES-XCBC-MAC
Date: Wed, 14 Jun 2006 00:44:06 +0900
Message-ID: <1150213447.4200.37.camel@hookipa>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 221x116x13x66.ap221.ftth.ucom.ne.jp ([221.116.13.66]:53389 "EHLO
	miyazawa.org") by vger.kernel.org with ESMTP id S932145AbWFMPoc
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jun 2006 11:44:32 -0400
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduces AES-XCBC-MAC using the "keyed hash" interface.
It accordingly depends on the previous patch.

Signed-off-by: Kazunori MIYAZAWA <miyazawa@linux-ipv6.org>

---
commit f23d1b52e77f339a9eaa89a1b913d6373fe60fb6
tree bab6efc5808414f13dcefb4bb164c3e111000fa3
parent 9c6b9affbacf12fc1e32868eaa14fef279b2696c
author Kazunori MIYAZAWA <kazunori@miyazawa.org> Tue, 13 Jun 2006 10:05:50 +0900
committer Kazunori MIYAZAWA <kazunori@miyazawa.org> Tue, 13 Jun 2006 10:05:50 +0900

 crypto/Kconfig         |    9 ++
 crypto/Makefile        |    1 
 crypto/cipher.c        |   20 ++++
 crypto/internal.h      |   16 +++
 crypto/tcrypt.c        |   99 +++++++++++++++++++++
 crypto/tcrypt.h        |   80 +++++++++++++++++
 crypto/xcbc.c          |  230 ++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/crypto.h |   30 ++++++
 8 files changed, 482 insertions(+), 3 deletions(-)

diff --git a/crypto/Kconfig b/crypto/Kconfig
index c442f2e..8dc28e9 100644
--- a/crypto/Kconfig
+++ b/crypto/Kconfig
@@ -16,6 +16,15 @@ config CRYPTO_HMAC
 	  HMAC: Keyed-Hashing for Message Authentication (RFC2104).
 	  This is required for IPSec.
 
+config CRYPTO_XCBC
+	bool "XCBC support"
+	depends on CRYPTO && EXPERIMENTAL
+	help
+	  XCBC: Keyed-Hashing with encryption algorithm
+		http://www.ietf.org/rfc/rfc3566.txt
+		http://csrc.nist.gov/encryption/modes/proposedmodes/
+                 xcbc-mac/xcbc-mac-spec.pdf
+
 config CRYPTO_NULL
 	tristate "Null algorithms"
 	depends on CRYPTO
diff --git a/crypto/Makefile b/crypto/Makefile
index d287b9e..781712d 100644
--- a/crypto/Makefile
+++ b/crypto/Makefile
@@ -8,6 +8,7 @@ obj-$(CONFIG_CRYPTO) += api.o scatterwal
 			$(proc-crypto-y)
 
 obj-$(CONFIG_CRYPTO_HMAC) += hmac.o
+obj-$(CONFIG_CRYPTO_XCBC) += xcbc.o
 obj-$(CONFIG_CRYPTO_NULL) += crypto_null.o
 obj-$(CONFIG_CRYPTO_MD4) += md4.o
 obj-$(CONFIG_CRYPTO_MD5) += md5.o
diff --git a/crypto/cipher.c b/crypto/cipher.c
index 65bcea0..5605216 100644
--- a/crypto/cipher.c
+++ b/crypto/cipher.c
@@ -402,6 +402,7 @@ int crypto_init_cipher_ops(struct crypto
 		break;
 		
 	case CRYPTO_TFM_MODE_CBC:
+	case CRYPTO_TFM_MODE_XCBC:
 		ops->cit_encrypt = cbc_encrypt;
 		ops->cit_decrypt = cbc_decrypt;
 		ops->cit_encrypt_iv = cbc_encrypt_iv;
@@ -426,7 +427,7 @@ int crypto_init_cipher_ops(struct crypto
 		BUG();
 	}
 	
-	if (ops->cit_mode == CRYPTO_TFM_MODE_CBC) {
+	if (ops->cit_mode & (CRYPTO_TFM_MODE_CBC | CRYPTO_TFM_MODE_XCBC)) {
 		unsigned long align;
 		unsigned long addr;
 	    	
@@ -453,6 +454,16 @@ int crypto_init_cipher_ops(struct crypto
 		addr = ALIGN(addr, align);
 		addr += ALIGN(tfm->__crt_alg->cra_ctxsize, align);
 		ops->cit_iv = (void *)addr;
+#ifdef CONFIG_CRYPTO_XCBC
+		if (ops->cit_mode & CRYPTO_TFM_MODE_XCBC) {
+			tfm->crt_keyedhash.kht_init = crypto_xcbc_init;
+			tfm->crt_keyedhash.kht_update = crypto_xcbc_update;
+			tfm->crt_keyedhash.kht_final = crypto_xcbc_final;
+			tfm->crt_keyedhash.keyed_hash = crypto_xcbc;
+			tfm->crt_keyedhash.kht_digestsize = crypto_tfm_alg_blocksize;
+			ret = crypto_alloc_xcbc_block(tfm);
+		}
+#endif
 	}
 
 out:	
@@ -461,4 +472,11 @@ out:	
 
 void crypto_exit_cipher_ops(struct crypto_tfm *tfm)
 {
+#ifdef CONFIG_CRYPTO_XCBC
+	struct cipher_tfm *ops = &tfm->crt_cipher;
+	if (ops->cit_mode & CRYPTO_TFM_MODE_CBC &&
+		ops->cit_mode & CRYPTO_TFM_MODE_XCBC) {
+		crypto_free_xcbc_block(tfm);
+	}
+#endif
 }
diff --git a/crypto/internal.h b/crypto/internal.h
index 959e602..cc4244f 100644
--- a/crypto/internal.h
+++ b/crypto/internal.h
@@ -62,6 +62,22 @@ static inline void crypto_free_hmac_bloc
 { }
 #endif
 
+#ifdef CONFIG_CRYPTO_XCBC
+int crypto_alloc_xcbc_block(struct crypto_tfm *tfm);
+static inline void crypto_free_xcbc_block(struct crypto_tfm *tfm)
+{
+	kfree(tfm->crt_keyedhash.kht_xcbc_block);
+}
+#else
+static inline int crypto_alloc_xcbc_block(struct crypto_tfm *tfm)
+{
+	return 0;
+}
+
+static inline void crypto_free_xcbc_block(struct crypto_tfm *tfm)
+{ }
+#endif
+
 #ifdef CONFIG_PROC_FS
 void __init crypto_init_proc(void);
 #else
diff --git a/crypto/tcrypt.c b/crypto/tcrypt.c
index 37aeced..0b4117a 100644
--- a/crypto/tcrypt.c
+++ b/crypto/tcrypt.c
@@ -253,6 +253,102 @@ out:
 
 #endif	/* CONFIG_CRYPTO_HMAC */
 
+#ifdef CONFIG_CRYPTO_XCBC
+
+static void
+test_xcbc(char *algo, struct xcbc_testvec * template, unsigned int tcount)
+{
+	char *p;
+	unsigned int i, j, k, temp;
+	struct scatterlist sg[8];
+	char result[64];
+	struct crypto_tfm *tfm;
+	struct xcbc_testvec *xcbc_tv;
+	unsigned int tsize, klen;
+	u_int32_t ks[12] = {0x01010101, 0x01010101, 0x01010101, 0x01010101,
+			    0x02020202, 0x02020202, 0x02020202, 0x02020202,
+			    0x03030303, 0x03030303, 0x03030303, 0x03030303}; 
+
+	tfm = crypto_alloc_tfm(algo, CRYPTO_TFM_MODE_XCBC);
+	if (tfm == NULL) {
+		printk("failed to load transform for %s\n", algo);
+		return;
+	}
+
+	tfm->crt_keyedhash.kht_xcbc_const = (u8*)ks;
+
+	printk("\ntesting xcbc_%s\n", algo);
+	
+	tsize = sizeof (struct xcbc_testvec);
+	tsize *= tcount;
+	if (tsize > TVMEMSIZE) {
+		printk("template (%u) too big for tvmem (%u)\n", tsize,
+		       TVMEMSIZE);
+		goto out;
+	}
+
+	memcpy(tvmem, template, tsize);
+	xcbc_tv = (void *) tvmem;
+
+	for (i = 0; i < tcount; i++) {
+		printk("test %u:\n", i + 1);
+		memset(result, 0, sizeof (result));
+
+		p = xcbc_tv[i].plaintext;
+		klen = xcbc_tv[i].ksize;
+		sg[0].page = virt_to_page(p);
+		sg[0].offset = offset_in_page(p);
+		sg[0].length = xcbc_tv[i].psize;
+
+		crypto_xcbc(tfm, xcbc_tv[i].key, &klen, sg, 1, result);
+
+		hexdump(result, crypto_tfm_alg_blocksize(tfm));
+		printk("%s\n",
+		       memcmp(result, xcbc_tv[i].digest,
+			      crypto_tfm_alg_blocksize(tfm)) ? "fail" :
+		       "pass");
+	}
+
+	printk("\ntesting xcbc_%s across pages\n", algo);
+
+	memset(xbuf, 0, XBUFSIZE);
+	
+	j = 0;
+	for (i = 0; i < tcount; i++) {
+		if (xcbc_tv[i].np) {
+			j++;
+			printk ("test %u:\n",j);
+			memset (result, 0, 64);
+
+			temp = 0;
+			klen = xcbc_tv[i].ksize;
+			for (k = 0; k < xcbc_tv[i].np; k++) {
+				memcpy (&xbuf[IDX[k]], xcbc_tv[i].plaintext + temp, 
+						xcbc_tv[i].tap[k]);	
+				temp += xcbc_tv[i].tap[k];
+				p = &xbuf[IDX[k]];
+				sg[k].page = virt_to_page (p);
+				sg[k].offset = offset_in_page (p);
+				sg[k].length = xcbc_tv[i].tap[k];
+			}
+
+			crypto_xcbc(tfm, xcbc_tv[i].key, &klen, sg, xcbc_tv[i].np, 
+					result);
+			hexdump(result, crypto_tfm_alg_blocksize(tfm));
+			
+			printk("%s\n",
+				memcmp(result, xcbc_tv[i].digest,
+					crypto_tfm_alg_blocksize(tfm)) ? "fail" : 
+				"pass");
+		}
+	}
+out:
+	crypto_free_tfm(tfm);
+}
+
+#endif	/* CONFIG_CRYPTO_XCBC */
+
+
 static void test_cipher(char *algo, int mode, int enc,
 			struct cipher_testvec *template, unsigned int tcount)
 {
@@ -857,6 +953,9 @@ static void do_test(void)
 		test_hmac("md5", hmac_md5_tv_template, HMAC_MD5_TEST_VECTORS);
 		test_hmac("sha1", hmac_sha1_tv_template, HMAC_SHA1_TEST_VECTORS);
 		test_hmac("sha256", hmac_sha256_tv_template, HMAC_SHA256_TEST_VECTORS);
+#endif		
+#ifdef CONFIG_CRYPTO_XCBC
+		test_xcbc("aes", aes_xcbc_tv_template, XCBC_AES_TEST_VECTORS);
 #endif
 
 		test_hash("michael_mic", michael_mic_tv_template, MICHAEL_MIC_TEST_VECTORS);
diff --git a/crypto/tcrypt.h b/crypto/tcrypt.h
index 1f683ba..6c1361f 100644
--- a/crypto/tcrypt.h
+++ b/crypto/tcrypt.h
@@ -46,6 +46,16 @@ struct hmac_testvec {
 	unsigned char np;
 };
 
+struct xcbc_testvec {	
+	char key[128];
+	unsigned char ksize;
+	char plaintext[128];
+	unsigned char psize;
+	char digest[MAX_DIGEST_SIZE];
+	unsigned char np;
+	unsigned char tap[MAX_TAP];		
+};
+
 struct cipher_testvec {
 	char key[MAX_KEYLEN] __attribute__ ((__aligned__(4)));
 	char iv[MAX_IVLEN];
@@ -941,6 +951,76 @@ static struct hmac_testvec hmac_sha256_t
 
 #endif	/* CONFIG_CRYPTO_HMAC */
 
+#define XCBC_AES_TEST_VECTORS 6
+
+#ifdef CONFIG_CRYPTO_XCBC
+static struct xcbc_testvec aes_xcbc_tv_template[] = {
+	{
+		.key	= { 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
+			    0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f },
+		.ksize	= 16,
+		.plaintext	= { [0 ... 127] = 0 },
+		.psize	= 0,
+		.digest = { 0x75, 0xf0, 0x25, 0x1d, 0x52, 0x8a, 0xc0, 0x1c,
+			    0x45, 0x73, 0xdf, 0xd5, 0x84, 0xd7, 0x9f, 0x29 },
+	}, {
+		.key	= { 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
+			    0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f },
+		.ksize	= 16,
+		.plaintext	= { 0x00, 0x01, 0x02 },
+		.psize	= 3,
+		.digest	= { 0x5b, 0x37, 0x65, 0x80, 0xae, 0x2f, 0x19, 0xaf,
+			    0xe7, 0x21, 0x9c, 0xee, 0xf1, 0x72, 0x75, 0x6f },
+	} , {
+		.key	= { 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
+			    0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f },
+		.ksize	= 16,
+		.plaintext	= { 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
+			    0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f },
+		.psize	= 16,
+		.digest = { 0xd2, 0xa2, 0x46, 0xfa, 0x34, 0x9b, 0x68, 0xa7,
+			    0x99, 0x98, 0xa4, 0x39, 0x4f, 0xf7, 0xa2, 0x63 },
+	}, {
+		.key	= { 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
+			    0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f },
+		.ksize	= 16,
+		.plaintext	= { 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
+			    0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
+			    0x10, 0x11, 0x12, 0x13 },
+		.psize	= 20,
+		.digest = { 0x47, 0xf5, 0x1b, 0x45, 0x64, 0x96, 0x62, 0x15,
+			    0xb8, 0x98, 0x5c, 0x63, 0x05, 0x5e, 0xd3, 0x08 },
+		.np	= 2,
+		.tap	= {10, 10},
+	}, {
+		.key	= { 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
+			    0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f },
+		.ksize	= 16,
+		.plaintext	= { 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
+			    0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
+			    0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17,
+			    0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f },
+		.psize	= 32,
+		.digest = { 0xf5, 0x4f, 0x0e, 0xc8, 0xd2, 0xb9, 0xf3, 0xd3,
+			    0x68, 0x07, 0x73, 0x4b, 0xd5, 0x28, 0x3f, 0xd4 },
+	}, {
+		.key	= { 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
+			    0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f },
+		.ksize	= 16,
+		.plaintext	= { 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
+			    0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
+			    0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17,
+			    0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f,
+			    0x20, 0x21 },
+		.psize	= 34,
+		.digest = { 0xbe, 0xcb, 0xb3, 0xbc, 0xcd, 0xb5, 0x18, 0xa3,
+			    0x06, 0x77, 0xd5, 0x48, 0x1f, 0xb6, 0xb4, 0xd8 },
+		.np	= 2,
+		.tap	= {17,17},
+	}
+};
+#endif
+
 /*
  * DES test vectors.
  */
diff --git a/crypto/xcbc.c b/crypto/xcbc.c
new file mode 100644
index 0000000..0cc23f0
--- /dev/null
+++ b/crypto/xcbc.c
@@ -0,0 +1,230 @@
+/*
+ * Copyright (C)2005,2006 USAGI/WIDE Project
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
+#include <linux/mm.h>
+#include <linux/highmem.h>
+#include <linux/slab.h>
+#include <asm/scatterlist.h>
+#include "internal.h"
+
+struct xcbc_ops {
+	unsigned int len;
+	u8 *prev;
+};
+
+int crypto_alloc_xcbc_block(struct crypto_tfm *tfm)
+{
+	struct xcbc_ops *ops;
+
+	BUG_ON(!crypto_tfm_alg_blocksize(tfm));
+
+	ops = kmalloc(sizeof(*ops) + crypto_tfm_alg_blocksize(tfm), GFP_KERNEL);
+	if (ops == NULL)
+		return -ENOMEM;
+	ops->len = 0;
+	ops->prev = (u8*)(ops + 1);
+
+	tfm->crt_keyedhash.kht_xcbc_block = ops;
+	tfm->crt_keyedhash.kht_xcbc_const = NULL;
+
+	return 0;
+}
+
+static int _crypto_xcbc_init(struct crypto_tfm *tfm, u8 *key, unsigned int keylen)
+{
+	const unsigned int bsize = crypto_tfm_alg_blocksize(tfm);
+	u8 key1[bsize];
+	int err;
+
+	if (!(tfm->crt_cipher.cit_mode & CRYPTO_TFM_MODE_XCBC))
+		return -EINVAL;
+
+	if (keylen != crypto_tfm_alg_blocksize(tfm))
+		return -EINVAL;
+
+	if ((err = crypto_cipher_setkey(tfm, key, keylen)))
+	    return err;
+
+	tfm->__crt_alg->cra_cipher.cia_encrypt(crypto_tfm_ctx(tfm), key1,
+			(const u8*)tfm->crt_keyedhash.kht_xcbc_const);
+
+	return crypto_cipher_setkey(tfm, key1, bsize);
+
+}
+
+int crypto_xcbc_init(struct crypto_tfm *tfm, u8 *key, unsigned int *keylen)
+{
+	struct xcbc_ops *ops = (struct xcbc_ops*)tfm->crt_keyedhash.kht_xcbc_block;
+
+	if (tfm->crt_keyedhash.kht_xcbc_const == NULL) 
+		return -EINVAL;
+
+	ops->len = 0;
+	memset(ops->prev, 0, crypto_tfm_alg_blocksize(tfm));
+	memset(tfm->crt_cipher.cit_iv, 0, crypto_tfm_alg_blocksize(tfm));
+	return _crypto_xcbc_init(tfm, key, *keylen);
+}
+
+void crypto_xcbc_update(struct crypto_tfm *tfm, struct scatterlist *sg, unsigned int nsg)
+{
+	struct xcbc_ops *ops = (struct xcbc_ops*)tfm->crt_keyedhash.kht_xcbc_block;
+	const unsigned int bsize = crypto_tfm_alg_blocksize(tfm);
+	unsigned int i;
+
+	if (!(tfm->crt_cipher.cit_mode & CRYPTO_TFM_MODE_XCBC))
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
+			if ((ops->len + len) <= bsize) {
+				memcpy(ops->prev + ops->len, p, len);
+				ops->len += len;
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
+			/* filling ops->prev with new data and encrypting it */
+			memcpy(ops->prev + ops->len, p, bsize - ops->len);
+			len -= bsize - ops->len;
+			p += bsize - ops->len;
+			tfm->crt_u.cipher.cit_xor_block(tfm->crt_cipher.cit_iv,
+							ops->prev);
+			tfm->__crt_alg->cra_cipher.cia_encrypt(
+				crypto_tfm_ctx(tfm), tfm->crt_cipher.cit_iv,
+				tfm->crt_cipher.cit_iv);
+
+			/* clearing the length */
+			ops->len = 0;
+
+			/* encrypting the rest of data */
+			while (len > bsize) {
+				tfm->crt_u.cipher.cit_xor_block(tfm->crt_cipher.cit_iv, p);
+				tfm->__crt_alg->cra_cipher.cia_encrypt(
+					crypto_tfm_ctx(tfm), tfm->crt_cipher.cit_iv,
+					tfm->crt_cipher.cit_iv);
+				p += bsize;
+				len -= bsize;
+			}
+
+			/* keeping the surplus of blocksize */
+			if (len) {
+				memcpy(ops->prev, p, len);
+				ops->len = len;
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
+int crypto_xcbc_final(struct crypto_tfm *tfm, u8 *key, unsigned int *keylen, u8 *out)
+{
+	struct xcbc_ops *ops = (struct xcbc_ops*)tfm->crt_keyedhash.kht_xcbc_block;
+	const unsigned int bsize = crypto_tfm_alg_blocksize(tfm);
+	int ret = 0;
+
+	if (!(tfm->crt_cipher.cit_mode & CRYPTO_TFM_MODE_XCBC))
+		return -EINVAL;
+
+	if (*keylen != bsize)
+		return -EINVAL;
+
+	if (ops->len == bsize) {
+		u8 key2[bsize];
+
+		if ((ret = crypto_cipher_setkey(tfm, key, *keylen)))
+			return ret;
+
+		tfm->__crt_alg->cra_cipher.cia_encrypt(crypto_tfm_ctx(tfm), key2,
+				(const u8*)(tfm->crt_keyedhash.kht_xcbc_const+bsize));
+		tfm->crt_u.cipher.cit_xor_block(tfm->crt_cipher.cit_iv, ops->prev);
+		tfm->crt_u.cipher.cit_xor_block(tfm->crt_cipher.cit_iv, key2);
+
+		_crypto_xcbc_init(tfm, key, *keylen);
+
+		tfm->__crt_alg->cra_cipher.cia_encrypt(crypto_tfm_ctx(tfm), out, tfm->crt_cipher.cit_iv);
+	} else {
+		u8 key3[bsize];
+		unsigned int rlen;
+		u8 *p = ops->prev + ops->len;
+		*p = 0x80;
+		p++;
+
+		rlen = bsize - ops->len -1;
+		if (rlen)
+			memset(p, 0, rlen);
+
+		if ((ret = crypto_cipher_setkey(tfm, key, *keylen)))
+			return ret;
+
+		tfm->__crt_alg->cra_cipher.cia_encrypt(crypto_tfm_ctx(tfm), key3,
+				(const u8*)(tfm->crt_keyedhash.kht_xcbc_const+bsize*2));
+
+		tfm->crt_u.cipher.cit_xor_block(tfm->crt_cipher.cit_iv, ops->prev);
+		tfm->crt_u.cipher.cit_xor_block(tfm->crt_cipher.cit_iv, key3);
+		_crypto_xcbc_init(tfm, key, *keylen);
+		tfm->__crt_alg->cra_cipher.cia_encrypt(crypto_tfm_ctx(tfm), out, tfm->crt_cipher.cit_iv);
+	}
+
+	return ret;
+}
+
+int crypto_xcbc(struct crypto_tfm *tfm, u8 *key, unsigned int *keylen,
+		struct scatterlist *sg, unsigned int nsg, u8 *out)
+{
+	int ret = 0;
+
+	ret = crypto_xcbc_init(tfm, key, keylen);
+	if (ret)
+		return ret;
+	crypto_xcbc_update(tfm, sg, nsg);
+	ret = crypto_xcbc_final(tfm, key, keylen, out);
+
+	return ret;
+}
+
+EXPORT_SYMBOL_GPL(crypto_xcbc_init);
+EXPORT_SYMBOL_GPL(crypto_xcbc_update);
+EXPORT_SYMBOL_GPL(crypto_xcbc_final);
+EXPORT_SYMBOL_GPL(crypto_xcbc);
diff --git a/include/linux/crypto.h b/include/linux/crypto.h
index 1ade651..c4bc3c2 100644
--- a/include/linux/crypto.h
+++ b/include/linux/crypto.h
@@ -45,6 +45,7 @@
 #define CRYPTO_TFM_MODE_CFB		0x00000004
 #define CRYPTO_TFM_MODE_CTR		0x00000008
 #define CRYPTO_TFM_MODE_HMAC		0x00000080
+#define CRYPTO_TFM_MODE_XCBC		0x00000080
 
 #define CRYPTO_TFM_REQ_WEAK_KEY		0x00000100
 #define CRYPTO_TFM_REQ_MAY_SLEEP	0x00000200
@@ -217,9 +218,22 @@ struct compress_tfm {
 #define crt_digest	crt_u.digest
 #define crt_compress	crt_u.compress
 
-#if defined(CONFIG_CRYPTO_HMAC)
+#if defined(CONFIG_CRYPTO_HMAC) || defined(CONFIG_CRYPTO_XCBC)
+struct cit_xcbc_ctx {
+	/*
+	 * XCBC needs 3 constants for the derived keys.
+	 * Each lengh of those must equal the cipher
+	 * block size so that cit_xcbc_const's length is
+	 * 3 times of the blocksize and it contains
+	 * concantinated constants.
+	 */
+	void *_block;
+	u8 *_const;
+};
 
 #define kht_hmac_block	kht_u.hmac_block
+#define kht_xcbc_block	kht_u.xcbc_ctx._block
+#define kht_xcbc_const	kht_u.xcbc_ctx._const
 
 struct keyed_hash_tfm {
 	int (*kht_init)(struct crypto_tfm *tfm, u8 *key, unsigned int *keylen);
@@ -230,6 +244,7 @@ struct keyed_hash_tfm {
 	unsigned int (*kht_digestsize)(struct crypto_tfm *tfm);
 	union {
 		void *hmac_block;
+		struct cit_xcbc_ctx xcbc_ctx;
 	} kht_u;
 };
 #endif
@@ -459,5 +474,16 @@ int crypto_hmac(struct crypto_tfm *tfm, 
                  struct scatterlist *sg, unsigned int nsg, u8 *out);
 #endif	/* CONFIG_CRYPTO_HMAC */
 
-#endif	/* _LINUX_CRYPTO_H */
+/*
+ *  * XCBC support
+ *   */
+#ifdef CONFIG_CRYPTO_XCBC
+int crypto_xcbc_init(struct crypto_tfm *tfm, u8 *key, unsigned int *keylen);
+void crypto_xcbc_update(struct crypto_tfm *tfm, struct scatterlist *sg, unsigned int nsg);
+int crypto_xcbc_final(struct crypto_tfm *tfm, u8 *key, unsigned int *keylen, u8
+		*out);
+int crypto_xcbc(struct crypto_tfm *tfm, u8 *key, unsigned int *keylen,
+		                struct scatterlist *sg, unsigned int nsg, u8 *out);
+#endif /* CONFIG_CRYPTO_XCBC */
+#endif  /* _LINUX_CRYPTO_H */
 


