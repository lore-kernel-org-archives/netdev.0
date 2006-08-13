From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 8/16] [CRYPTO] tcrypt: Use block ciphers where applicable
Date: Sun, 13 Aug 2006 22:20:14 +1000
Message-ID: <E1GCEww-0004gC-00@gondolin.me.apana.org.au>
References: <20060813121722.GA16115@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:11785 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751077AbWHMMUW
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Aug 2006 08:20:22 -0400
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[CRYPTO] tcrypt: Use block ciphers where applicable

This patch converts tcrypt to use the new block cipher type where
applicable.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 crypto/tcrypt.c |  439 +++++++++++++++++++++++++++++++++-----------------------
 1 files changed, 261 insertions(+), 178 deletions(-)

diff --git a/crypto/tcrypt.c b/crypto/tcrypt.c
--- a/crypto/tcrypt.c
+++ b/crypto/tcrypt.c
@@ -17,6 +17,7 @@
  *
  */
 
+#include <linux/err.h>
 #include <linux/init.h>
 #include <linux/module.h>
 #include <linux/mm.h>
@@ -54,8 +55,6 @@
 */
 #define ENCRYPT 1
 #define DECRYPT 0
-#define MODE_ECB 1
-#define MODE_CBC 0
 
 static unsigned int IDX[8] = { IDX1, IDX2, IDX3, IDX4, IDX5, IDX6, IDX7, IDX8 };
 
@@ -250,28 +249,27 @@ out:
 
 #endif	/* CONFIG_CRYPTO_HMAC */
 
-static void test_cipher(char *algo, int mode, int enc,
+static void test_cipher(char *algo, int enc,
 			struct cipher_testvec *template, unsigned int tcount)
 {
 	unsigned int ret, i, j, k, temp;
 	unsigned int tsize;
+	unsigned int iv_len;
+	unsigned int len;
 	char *q;
-	struct crypto_tfm *tfm;
+	struct crypto_blkcipher *tfm;
 	char *key;
 	struct cipher_testvec *cipher_tv;
+	struct blkcipher_desc desc;
 	struct scatterlist sg[8];
-	const char *e, *m;
+	const char *e;
 
 	if (enc == ENCRYPT)
 	        e = "encryption";
 	else
 		e = "decryption";
-	if (mode == MODE_ECB)
-		m = "ECB";
-	else
-		m = "CBC";
 
-	printk("\ntesting %s %s %s\n", algo, m, e);
+	printk("\ntesting %s %s\n", algo, e);
 
 	tsize = sizeof (struct cipher_testvec);
 	tsize *= tcount;
@@ -285,15 +283,15 @@ static void test_cipher(char *algo, int 
 	memcpy(tvmem, template, tsize);
 	cipher_tv = (void *)tvmem;
 
-	if (mode)
-		tfm = crypto_alloc_tfm(algo, 0);
-	else
-		tfm = crypto_alloc_tfm(algo, CRYPTO_TFM_MODE_CBC);
+	tfm = crypto_alloc_blkcipher(algo, 0, CRYPTO_ALG_ASYNC);
 
-	if (tfm == NULL) {
-		printk("failed to load transform for %s %s\n", algo, m);
+	if (IS_ERR(tfm)) {
+		printk("failed to load transform for %s: %ld\n", algo,
+		       PTR_ERR(tfm));
 		return;
 	}
+	desc.tfm = tfm;
+	desc.flags = 0;
 
 	j = 0;
 	for (i = 0; i < tcount; i++) {
@@ -302,14 +300,17 @@ static void test_cipher(char *algo, int 
 			printk("test %u (%d bit key):\n",
 			j, cipher_tv[i].klen * 8);
 
-			tfm->crt_flags = 0;
+			crypto_blkcipher_clear_flags(tfm, ~0);
 			if (cipher_tv[i].wk)
-				tfm->crt_flags |= CRYPTO_TFM_REQ_WEAK_KEY;
+				crypto_blkcipher_set_flags(
+					tfm, CRYPTO_TFM_REQ_WEAK_KEY);
 			key = cipher_tv[i].key;
 
-			ret = crypto_cipher_setkey(tfm, key, cipher_tv[i].klen);
+			ret = crypto_blkcipher_setkey(tfm, key,
+						      cipher_tv[i].klen);
 			if (ret) {
-				printk("setkey() failed flags=%x\n", tfm->crt_flags);
+				printk("setkey() failed flags=%x\n",
+				       crypto_blkcipher_get_flags(tfm));
 
 				if (!cipher_tv[i].fail)
 					goto out;
@@ -318,19 +319,19 @@ static void test_cipher(char *algo, int 
 			sg_set_buf(&sg[0], cipher_tv[i].input,
 				   cipher_tv[i].ilen);
 
-			if (!mode) {
-				crypto_cipher_set_iv(tfm, cipher_tv[i].iv,
-					crypto_tfm_alg_ivsize(tfm));
-			}
-
-			if (enc)
-				ret = crypto_cipher_encrypt(tfm, sg, sg, cipher_tv[i].ilen);
-			else
-				ret = crypto_cipher_decrypt(tfm, sg, sg, cipher_tv[i].ilen);
-
+			iv_len = crypto_blkcipher_ivsize(tfm);
+			if (iv_len)
+				crypto_blkcipher_set_iv(tfm, cipher_tv[i].iv,
+							iv_len);
+
+			len = cipher_tv[i].ilen;
+			ret = enc ?
+				crypto_blkcipher_encrypt(&desc, sg, sg, len) :
+				crypto_blkcipher_decrypt(&desc, sg, sg, len);
 
 			if (ret) {
-				printk("%s () failed flags=%x\n", e, tfm->crt_flags);
+				printk("%s () failed flags=%x\n", e,
+				       desc.flags);
 				goto out;
 			}
 
@@ -343,7 +344,7 @@ static void test_cipher(char *algo, int 
 		}
 	}
 
-	printk("\ntesting %s %s %s across pages (chunking)\n", algo, m, e);
+	printk("\ntesting %s %s across pages (chunking)\n", algo, e);
 	memset(xbuf, 0, XBUFSIZE);
 
 	j = 0;
@@ -353,14 +354,17 @@ static void test_cipher(char *algo, int 
 			printk("test %u (%d bit key):\n",
 			j, cipher_tv[i].klen * 8);
 
-			tfm->crt_flags = 0;
+			crypto_blkcipher_clear_flags(tfm, ~0);
 			if (cipher_tv[i].wk)
-				tfm->crt_flags |= CRYPTO_TFM_REQ_WEAK_KEY;
+				crypto_blkcipher_set_flags(
+					tfm, CRYPTO_TFM_REQ_WEAK_KEY);
 			key = cipher_tv[i].key;
 
-			ret = crypto_cipher_setkey(tfm, key, cipher_tv[i].klen);
+			ret = crypto_blkcipher_setkey(tfm, key,
+						      cipher_tv[i].klen);
 			if (ret) {
-				printk("setkey() failed flags=%x\n", tfm->crt_flags);
+				printk("setkey() failed flags=%x\n",
+				       crypto_blkcipher_get_flags(tfm));
 
 				if (!cipher_tv[i].fail)
 					goto out;
@@ -376,18 +380,19 @@ static void test_cipher(char *algo, int 
 					   cipher_tv[i].tap[k]);
 			}
 
-			if (!mode) {
-				crypto_cipher_set_iv(tfm, cipher_tv[i].iv,
-						crypto_tfm_alg_ivsize(tfm));
-			}
-
-			if (enc)
-				ret = crypto_cipher_encrypt(tfm, sg, sg, cipher_tv[i].ilen);
-			else
-				ret = crypto_cipher_decrypt(tfm, sg, sg, cipher_tv[i].ilen);
+			iv_len = crypto_blkcipher_ivsize(tfm);
+			if (iv_len)
+				crypto_blkcipher_set_iv(tfm, cipher_tv[i].iv,
+							iv_len);
+
+			len = cipher_tv[i].ilen;
+			ret = enc ?
+				crypto_blkcipher_encrypt(&desc, sg, sg, len) :
+				crypto_blkcipher_decrypt(&desc, sg, sg, len);
 
 			if (ret) {
-				printk("%s () failed flags=%x\n", e, tfm->crt_flags);
+				printk("%s () failed flags=%x\n", e,
+				       desc.flags);
 				goto out;
 			}
 
@@ -406,10 +411,10 @@ static void test_cipher(char *algo, int 
 	}
 
 out:
-	crypto_free_tfm(tfm);
+	crypto_free_blkcipher(tfm);
 }
 
-static int test_cipher_jiffies(struct crypto_tfm *tfm, int enc, char *p,
+static int test_cipher_jiffies(struct blkcipher_desc *desc, int enc, char *p,
 			       int blen, int sec)
 {
 	struct scatterlist sg[1];
@@ -422,9 +427,9 @@ static int test_cipher_jiffies(struct cr
 	for (start = jiffies, end = start + sec * HZ, bcount = 0;
 	     time_before(jiffies, end); bcount++) {
 		if (enc)
-			ret = crypto_cipher_encrypt(tfm, sg, sg, blen);
+			ret = crypto_blkcipher_encrypt(desc, sg, sg, blen);
 		else
-			ret = crypto_cipher_decrypt(tfm, sg, sg, blen);
+			ret = crypto_blkcipher_decrypt(desc, sg, sg, blen);
 
 		if (ret)
 			return ret;
@@ -435,7 +440,7 @@ static int test_cipher_jiffies(struct cr
 	return 0;
 }
 
-static int test_cipher_cycles(struct crypto_tfm *tfm, int enc, char *p,
+static int test_cipher_cycles(struct blkcipher_desc *desc, int enc, char *p,
 			      int blen)
 {
 	struct scatterlist sg[1];
@@ -451,9 +456,9 @@ static int test_cipher_cycles(struct cry
 	/* Warm-up run. */
 	for (i = 0; i < 4; i++) {
 		if (enc)
-			ret = crypto_cipher_encrypt(tfm, sg, sg, blen);
+			ret = crypto_blkcipher_encrypt(desc, sg, sg, blen);
 		else
-			ret = crypto_cipher_decrypt(tfm, sg, sg, blen);
+			ret = crypto_blkcipher_decrypt(desc, sg, sg, blen);
 
 		if (ret)
 			goto out;
@@ -465,9 +470,9 @@ static int test_cipher_cycles(struct cry
 
 		start = get_cycles();
 		if (enc)
-			ret = crypto_cipher_encrypt(tfm, sg, sg, blen);
+			ret = crypto_blkcipher_encrypt(desc, sg, sg, blen);
 		else
-			ret = crypto_cipher_decrypt(tfm, sg, sg, blen);
+			ret = crypto_blkcipher_decrypt(desc, sg, sg, blen);
 		end = get_cycles();
 
 		if (ret)
@@ -487,35 +492,32 @@ out:
 	return ret;
 }
 
-static void test_cipher_speed(char *algo, int mode, int enc, unsigned int sec,
+static void test_cipher_speed(char *algo, int enc, unsigned int sec,
 			      struct cipher_testvec *template,
 			      unsigned int tcount, struct cipher_speed *speed)
 {
 	unsigned int ret, i, j, iv_len;
 	unsigned char *key, *p, iv[128];
-	struct crypto_tfm *tfm;
-	const char *e, *m;
+	struct crypto_blkcipher *tfm;
+	struct blkcipher_desc desc;
+	const char *e;
 
 	if (enc == ENCRYPT)
 	        e = "encryption";
 	else
 		e = "decryption";
-	if (mode == MODE_ECB)
-		m = "ECB";
-	else
-		m = "CBC";
 
-	printk("\ntesting speed of %s %s %s\n", algo, m, e);
+	printk("\ntesting speed of %s %s\n", algo, e);
 
-	if (mode)
-		tfm = crypto_alloc_tfm(algo, 0);
-	else
-		tfm = crypto_alloc_tfm(algo, CRYPTO_TFM_MODE_CBC);
+	tfm = crypto_alloc_blkcipher(algo, 0, CRYPTO_ALG_ASYNC);
 
-	if (tfm == NULL) {
-		printk("failed to load transform for %s %s\n", algo, m);
+	if (IS_ERR(tfm)) {
+		printk("failed to load transform for %s: %ld\n", algo,
+		       PTR_ERR(tfm));
 		return;
 	}
+	desc.tfm = tfm;
+	desc.flags = 0;
 
 	for (i = 0; speed[i].klen != 0; i++) {
 		if ((speed[i].blen + speed[i].klen) > TVMEMSIZE) {
@@ -539,32 +541,33 @@ static void test_cipher_speed(char *algo
 		}
 		p = (unsigned char *)tvmem + speed[i].klen;
 
-		ret = crypto_cipher_setkey(tfm, key, speed[i].klen);
+		ret = crypto_blkcipher_setkey(tfm, key, speed[i].klen);
 		if (ret) {
-			printk("setkey() failed flags=%x\n", tfm->crt_flags);
+			printk("setkey() failed flags=%x\n",
+			       crypto_blkcipher_get_flags(tfm));
 			goto out;
 		}
 
-		if (!mode) {
-			iv_len = crypto_tfm_alg_ivsize(tfm);
+		iv_len = crypto_blkcipher_ivsize(tfm);
+		if (iv_len) {
 			memset(&iv, 0xff, iv_len);
-			crypto_cipher_set_iv(tfm, iv, iv_len);
+			crypto_blkcipher_set_iv(tfm, iv, iv_len);
 		}
 
 		if (sec)
-			ret = test_cipher_jiffies(tfm, enc, p, speed[i].blen,
+			ret = test_cipher_jiffies(&desc, enc, p, speed[i].blen,
 						  sec);
 		else
-			ret = test_cipher_cycles(tfm, enc, p, speed[i].blen);
+			ret = test_cipher_cycles(&desc, enc, p, speed[i].blen);
 
 		if (ret) {
-			printk("%s() failed flags=%x\n", e, tfm->crt_flags);
+			printk("%s() failed flags=%x\n", e, desc.flags);
 			break;
 		}
 	}
 
 out:
-	crypto_free_tfm(tfm);
+	crypto_free_blkcipher(tfm);
 }
 
 static void test_digest_jiffies(struct crypto_tfm *tfm, char *p, int blen,
@@ -784,79 +787,119 @@ static void do_test(void)
 		test_hash("sha1", sha1_tv_template, SHA1_TEST_VECTORS);
 
 		//DES
-		test_cipher ("des", MODE_ECB, ENCRYPT, des_enc_tv_template, DES_ENC_TEST_VECTORS);
-		test_cipher ("des", MODE_ECB, DECRYPT, des_dec_tv_template, DES_DEC_TEST_VECTORS);
-		test_cipher ("des", MODE_CBC, ENCRYPT, des_cbc_enc_tv_template, DES_CBC_ENC_TEST_VECTORS);
-		test_cipher ("des", MODE_CBC, DECRYPT, des_cbc_dec_tv_template, DES_CBC_DEC_TEST_VECTORS);
+		test_cipher("ecb(des)", ENCRYPT, des_enc_tv_template,
+			    DES_ENC_TEST_VECTORS);
+		test_cipher("ecb(des)", DECRYPT, des_dec_tv_template,
+			    DES_DEC_TEST_VECTORS);
+		test_cipher("cbc(des)", ENCRYPT, des_cbc_enc_tv_template,
+			    DES_CBC_ENC_TEST_VECTORS);
+		test_cipher("cbc(des)", DECRYPT, des_cbc_dec_tv_template,
+			    DES_CBC_DEC_TEST_VECTORS);
 
 		//DES3_EDE
-		test_cipher ("des3_ede", MODE_ECB, ENCRYPT, des3_ede_enc_tv_template, DES3_EDE_ENC_TEST_VECTORS);
-		test_cipher ("des3_ede", MODE_ECB, DECRYPT, des3_ede_dec_tv_template, DES3_EDE_DEC_TEST_VECTORS);
+		test_cipher("ecb(des3_ede)", ENCRYPT, des3_ede_enc_tv_template,
+			    DES3_EDE_ENC_TEST_VECTORS);
+		test_cipher("ecb(des3_ede)", DECRYPT, des3_ede_dec_tv_template,
+			    DES3_EDE_DEC_TEST_VECTORS);
 
 		test_hash("md4", md4_tv_template, MD4_TEST_VECTORS);
 
 		test_hash("sha256", sha256_tv_template, SHA256_TEST_VECTORS);
 
 		//BLOWFISH
-		test_cipher ("blowfish", MODE_ECB, ENCRYPT, bf_enc_tv_template, BF_ENC_TEST_VECTORS);
-		test_cipher ("blowfish", MODE_ECB, DECRYPT, bf_dec_tv_template, BF_DEC_TEST_VECTORS);
-		test_cipher ("blowfish", MODE_CBC, ENCRYPT, bf_cbc_enc_tv_template, BF_CBC_ENC_TEST_VECTORS);
-		test_cipher ("blowfish", MODE_CBC, DECRYPT, bf_cbc_dec_tv_template, BF_CBC_DEC_TEST_VECTORS);
+		test_cipher("ecb(blowfish)", ENCRYPT, bf_enc_tv_template,
+			    BF_ENC_TEST_VECTORS);
+		test_cipher("ecb(blowfish)", DECRYPT, bf_dec_tv_template,
+			    BF_DEC_TEST_VECTORS);
+		test_cipher("cbc(blowfish)", ENCRYPT, bf_cbc_enc_tv_template,
+			    BF_CBC_ENC_TEST_VECTORS);
+		test_cipher("cbc(blowfish)", DECRYPT, bf_cbc_dec_tv_template,
+			    BF_CBC_DEC_TEST_VECTORS);
 
 		//TWOFISH
-		test_cipher ("twofish", MODE_ECB, ENCRYPT, tf_enc_tv_template, TF_ENC_TEST_VECTORS);
-		test_cipher ("twofish", MODE_ECB, DECRYPT, tf_dec_tv_template, TF_DEC_TEST_VECTORS);
-		test_cipher ("twofish", MODE_CBC, ENCRYPT, tf_cbc_enc_tv_template, TF_CBC_ENC_TEST_VECTORS);
-		test_cipher ("twofish", MODE_CBC, DECRYPT, tf_cbc_dec_tv_template, TF_CBC_DEC_TEST_VECTORS);
+		test_cipher("ecb(twofish)", ENCRYPT, tf_enc_tv_template,
+			    TF_ENC_TEST_VECTORS);
+		test_cipher("ecb(twofish)", DECRYPT, tf_dec_tv_template,
+			    TF_DEC_TEST_VECTORS);
+		test_cipher("cbc(twofish)", ENCRYPT, tf_cbc_enc_tv_template,
+			    TF_CBC_ENC_TEST_VECTORS);
+		test_cipher("cbc(twofish)", DECRYPT, tf_cbc_dec_tv_template,
+			    TF_CBC_DEC_TEST_VECTORS);
 
 		//SERPENT
-		test_cipher ("serpent", MODE_ECB, ENCRYPT, serpent_enc_tv_template, SERPENT_ENC_TEST_VECTORS);
-		test_cipher ("serpent", MODE_ECB, DECRYPT, serpent_dec_tv_template, SERPENT_DEC_TEST_VECTORS);
+		test_cipher("ecb(serpent)", ENCRYPT, serpent_enc_tv_template,
+			    SERPENT_ENC_TEST_VECTORS);
+		test_cipher("ecb(serpent)", DECRYPT, serpent_dec_tv_template,
+			    SERPENT_DEC_TEST_VECTORS);
 
 		//TNEPRES
-		test_cipher ("tnepres", MODE_ECB, ENCRYPT, tnepres_enc_tv_template, TNEPRES_ENC_TEST_VECTORS);
-		test_cipher ("tnepres", MODE_ECB, DECRYPT, tnepres_dec_tv_template, TNEPRES_DEC_TEST_VECTORS);
+		test_cipher("ecb(tnepres)", ENCRYPT, tnepres_enc_tv_template,
+			    TNEPRES_ENC_TEST_VECTORS);
+		test_cipher("ecb(tnepres)", DECRYPT, tnepres_dec_tv_template,
+			    TNEPRES_DEC_TEST_VECTORS);
 
 		//AES
-		test_cipher ("aes", MODE_ECB, ENCRYPT, aes_enc_tv_template, AES_ENC_TEST_VECTORS);
-		test_cipher ("aes", MODE_ECB, DECRYPT, aes_dec_tv_template, AES_DEC_TEST_VECTORS);
-		test_cipher ("aes", MODE_CBC, ENCRYPT, aes_cbc_enc_tv_template, AES_CBC_ENC_TEST_VECTORS);
-		test_cipher ("aes", MODE_CBC, DECRYPT, aes_cbc_dec_tv_template, AES_CBC_DEC_TEST_VECTORS);
+		test_cipher("ecb(aes)", ENCRYPT, aes_enc_tv_template,
+			    AES_ENC_TEST_VECTORS);
+		test_cipher("ecb(aes)", DECRYPT, aes_dec_tv_template,
+			    AES_DEC_TEST_VECTORS);
+		test_cipher("cbc(aes)", ENCRYPT, aes_cbc_enc_tv_template,
+			    AES_CBC_ENC_TEST_VECTORS);
+		test_cipher("cbc(aes)", DECRYPT, aes_cbc_dec_tv_template,
+			    AES_CBC_DEC_TEST_VECTORS);
 
 		//CAST5
-		test_cipher ("cast5", MODE_ECB, ENCRYPT, cast5_enc_tv_template, CAST5_ENC_TEST_VECTORS);
-		test_cipher ("cast5", MODE_ECB, DECRYPT, cast5_dec_tv_template, CAST5_DEC_TEST_VECTORS);
+		test_cipher("ecb(cast5)", ENCRYPT, cast5_enc_tv_template,
+			    CAST5_ENC_TEST_VECTORS);
+		test_cipher("ecb(cast5)", DECRYPT, cast5_dec_tv_template,
+			    CAST5_DEC_TEST_VECTORS);
 
 		//CAST6
-		test_cipher ("cast6", MODE_ECB, ENCRYPT, cast6_enc_tv_template, CAST6_ENC_TEST_VECTORS);
-		test_cipher ("cast6", MODE_ECB, DECRYPT, cast6_dec_tv_template, CAST6_DEC_TEST_VECTORS);
+		test_cipher("ecb(cast6)", ENCRYPT, cast6_enc_tv_template,
+			    CAST6_ENC_TEST_VECTORS);
+		test_cipher("ecb(cast6)", DECRYPT, cast6_dec_tv_template,
+			    CAST6_DEC_TEST_VECTORS);
 
 		//ARC4
-		test_cipher ("arc4", MODE_ECB, ENCRYPT, arc4_enc_tv_template, ARC4_ENC_TEST_VECTORS);
-		test_cipher ("arc4", MODE_ECB, DECRYPT, arc4_dec_tv_template, ARC4_DEC_TEST_VECTORS);
+		test_cipher("ecb(arc4)", ENCRYPT, arc4_enc_tv_template,
+			    ARC4_ENC_TEST_VECTORS);
+		test_cipher("ecb(arc4)", DECRYPT, arc4_dec_tv_template,
+			    ARC4_DEC_TEST_VECTORS);
 
 		//TEA
-		test_cipher ("tea", MODE_ECB, ENCRYPT, tea_enc_tv_template, TEA_ENC_TEST_VECTORS);
-		test_cipher ("tea", MODE_ECB, DECRYPT, tea_dec_tv_template, TEA_DEC_TEST_VECTORS);
+		test_cipher("ecb(tea)", ENCRYPT, tea_enc_tv_template,
+			    TEA_ENC_TEST_VECTORS);
+		test_cipher("ecb(tea)", DECRYPT, tea_dec_tv_template,
+			    TEA_DEC_TEST_VECTORS);
 
 
 		//XTEA
-		test_cipher ("xtea", MODE_ECB, ENCRYPT, xtea_enc_tv_template, XTEA_ENC_TEST_VECTORS);
-		test_cipher ("xtea", MODE_ECB, DECRYPT, xtea_dec_tv_template, XTEA_DEC_TEST_VECTORS);
+		test_cipher("ecb(xtea)", ENCRYPT, xtea_enc_tv_template,
+			    XTEA_ENC_TEST_VECTORS);
+		test_cipher("ecb(xtea)", DECRYPT, xtea_dec_tv_template,
+			    XTEA_DEC_TEST_VECTORS);
 
 		//KHAZAD
-		test_cipher ("khazad", MODE_ECB, ENCRYPT, khazad_enc_tv_template, KHAZAD_ENC_TEST_VECTORS);
-		test_cipher ("khazad", MODE_ECB, DECRYPT, khazad_dec_tv_template, KHAZAD_DEC_TEST_VECTORS);
+		test_cipher("ecb(khazad)", ENCRYPT, khazad_enc_tv_template,
+			    KHAZAD_ENC_TEST_VECTORS);
+		test_cipher("ecb(khazad)", DECRYPT, khazad_dec_tv_template,
+			    KHAZAD_DEC_TEST_VECTORS);
 
 		//ANUBIS
-		test_cipher ("anubis", MODE_ECB, ENCRYPT, anubis_enc_tv_template, ANUBIS_ENC_TEST_VECTORS);
-		test_cipher ("anubis", MODE_ECB, DECRYPT, anubis_dec_tv_template, ANUBIS_DEC_TEST_VECTORS);
-		test_cipher ("anubis", MODE_CBC, ENCRYPT, anubis_cbc_enc_tv_template, ANUBIS_CBC_ENC_TEST_VECTORS);
-		test_cipher ("anubis", MODE_CBC, DECRYPT, anubis_cbc_dec_tv_template, ANUBIS_CBC_ENC_TEST_VECTORS);
+		test_cipher("ecb(anubis)", ENCRYPT, anubis_enc_tv_template,
+			    ANUBIS_ENC_TEST_VECTORS);
+		test_cipher("ecb(anubis)", DECRYPT, anubis_dec_tv_template,
+			    ANUBIS_DEC_TEST_VECTORS);
+		test_cipher("cbc(anubis)", ENCRYPT, anubis_cbc_enc_tv_template,
+			    ANUBIS_CBC_ENC_TEST_VECTORS);
+		test_cipher("cbc(anubis)", DECRYPT, anubis_cbc_dec_tv_template,
+			    ANUBIS_CBC_ENC_TEST_VECTORS);
 
 		//XETA
-		test_cipher ("xeta", MODE_ECB, ENCRYPT, xeta_enc_tv_template, XETA_ENC_TEST_VECTORS);
-		test_cipher ("xeta", MODE_ECB, DECRYPT, xeta_dec_tv_template, XETA_DEC_TEST_VECTORS);
+		test_cipher("ecb(xeta)", ENCRYPT, xeta_enc_tv_template,
+			    XETA_ENC_TEST_VECTORS);
+		test_cipher("ecb(xeta)", DECRYPT, xeta_dec_tv_template,
+			    XETA_DEC_TEST_VECTORS);
 
 		test_hash("sha384", sha384_tv_template, SHA384_TEST_VECTORS);
 		test_hash("sha512", sha512_tv_template, SHA512_TEST_VECTORS);
@@ -886,15 +929,21 @@ static void do_test(void)
 		break;
 
 	case 3:
-		test_cipher ("des", MODE_ECB, ENCRYPT, des_enc_tv_template, DES_ENC_TEST_VECTORS);
-		test_cipher ("des", MODE_ECB, DECRYPT, des_dec_tv_template, DES_DEC_TEST_VECTORS);
-		test_cipher ("des", MODE_CBC, ENCRYPT, des_cbc_enc_tv_template, DES_CBC_ENC_TEST_VECTORS);
-		test_cipher ("des", MODE_CBC, DECRYPT, des_cbc_dec_tv_template, DES_CBC_DEC_TEST_VECTORS);
+		test_cipher("ecb(des)", ENCRYPT, des_enc_tv_template,
+			    DES_ENC_TEST_VECTORS);
+		test_cipher("ecb(des)", DECRYPT, des_dec_tv_template,
+			    DES_DEC_TEST_VECTORS);
+		test_cipher("cbc(des)", ENCRYPT, des_cbc_enc_tv_template,
+			    DES_CBC_ENC_TEST_VECTORS);
+		test_cipher("cbc(des)", DECRYPT, des_cbc_dec_tv_template,
+			    DES_CBC_DEC_TEST_VECTORS);
 		break;
 
 	case 4:
-		test_cipher ("des3_ede", MODE_ECB, ENCRYPT, des3_ede_enc_tv_template, DES3_EDE_ENC_TEST_VECTORS);
-		test_cipher ("des3_ede", MODE_ECB, DECRYPT, des3_ede_dec_tv_template, DES3_EDE_DEC_TEST_VECTORS);
+		test_cipher("ecb(des3_ede)", ENCRYPT, des3_ede_enc_tv_template,
+			    DES3_EDE_ENC_TEST_VECTORS);
+		test_cipher("ecb(des3_ede)", DECRYPT, des3_ede_dec_tv_template,
+			    DES3_EDE_DEC_TEST_VECTORS);
 		break;
 
 	case 5:
@@ -906,29 +955,43 @@ static void do_test(void)
 		break;
 
 	case 7:
-		test_cipher ("blowfish", MODE_ECB, ENCRYPT, bf_enc_tv_template, BF_ENC_TEST_VECTORS);
-		test_cipher ("blowfish", MODE_ECB, DECRYPT, bf_dec_tv_template, BF_DEC_TEST_VECTORS);
-		test_cipher ("blowfish", MODE_CBC, ENCRYPT, bf_cbc_enc_tv_template, BF_CBC_ENC_TEST_VECTORS);
-		test_cipher ("blowfish", MODE_CBC, DECRYPT, bf_cbc_dec_tv_template, BF_CBC_DEC_TEST_VECTORS);
+		test_cipher("ecb(blowfish)", ENCRYPT, bf_enc_tv_template,
+			    BF_ENC_TEST_VECTORS);
+		test_cipher("ecb(blowfish)", DECRYPT, bf_dec_tv_template,
+			    BF_DEC_TEST_VECTORS);
+		test_cipher("cbc(blowfish)", ENCRYPT, bf_cbc_enc_tv_template,
+			    BF_CBC_ENC_TEST_VECTORS);
+		test_cipher("cbc(blowfish)", DECRYPT, bf_cbc_dec_tv_template,
+			    BF_CBC_DEC_TEST_VECTORS);
 		break;
 
 	case 8:
-		test_cipher ("twofish", MODE_ECB, ENCRYPT, tf_enc_tv_template, TF_ENC_TEST_VECTORS);
-		test_cipher ("twofish", MODE_ECB, DECRYPT, tf_dec_tv_template, TF_DEC_TEST_VECTORS);
-		test_cipher ("twofish", MODE_CBC, ENCRYPT, tf_cbc_enc_tv_template, TF_CBC_ENC_TEST_VECTORS);
-		test_cipher ("twofish", MODE_CBC, DECRYPT, tf_cbc_dec_tv_template, TF_CBC_DEC_TEST_VECTORS);
+		test_cipher("ecb(twofish)", ENCRYPT, tf_enc_tv_template,
+			    TF_ENC_TEST_VECTORS);
+		test_cipher("ecb(twofish)", DECRYPT, tf_dec_tv_template,
+			    TF_DEC_TEST_VECTORS);
+		test_cipher("cbc(twofish)", ENCRYPT, tf_cbc_enc_tv_template,
+			    TF_CBC_ENC_TEST_VECTORS);
+		test_cipher("cbc(twofish)", DECRYPT, tf_cbc_dec_tv_template,
+			    TF_CBC_DEC_TEST_VECTORS);
 		break;
 
 	case 9:
-		test_cipher ("serpent", MODE_ECB, ENCRYPT, serpent_enc_tv_template, SERPENT_ENC_TEST_VECTORS);
-		test_cipher ("serpent", MODE_ECB, DECRYPT, serpent_dec_tv_template, SERPENT_DEC_TEST_VECTORS);
+		test_cipher("ecb(serpent)", ENCRYPT, serpent_enc_tv_template,
+			    SERPENT_ENC_TEST_VECTORS);
+		test_cipher("ecb(serpent)", DECRYPT, serpent_dec_tv_template,
+			    SERPENT_DEC_TEST_VECTORS);
 		break;
 
 	case 10:
-		test_cipher ("aes", MODE_ECB, ENCRYPT, aes_enc_tv_template, AES_ENC_TEST_VECTORS);
-		test_cipher ("aes", MODE_ECB, DECRYPT, aes_dec_tv_template, AES_DEC_TEST_VECTORS);
-		test_cipher ("aes", MODE_CBC, ENCRYPT, aes_cbc_enc_tv_template, AES_CBC_ENC_TEST_VECTORS);
-		test_cipher ("aes", MODE_CBC, DECRYPT, aes_cbc_dec_tv_template, AES_CBC_DEC_TEST_VECTORS);
+		test_cipher("ecb(aes)", ENCRYPT, aes_enc_tv_template,
+			    AES_ENC_TEST_VECTORS);
+		test_cipher("ecb(aes)", DECRYPT, aes_dec_tv_template,
+			    AES_DEC_TEST_VECTORS);
+		test_cipher("cbc(aes)", ENCRYPT, aes_cbc_enc_tv_template,
+			    AES_CBC_ENC_TEST_VECTORS);
+		test_cipher("cbc(aes)", DECRYPT, aes_cbc_dec_tv_template,
+			    AES_CBC_DEC_TEST_VECTORS);
 		break;
 
 	case 11:
@@ -944,18 +1007,24 @@ static void do_test(void)
 		break;
 
 	case 14:
-		test_cipher ("cast5", MODE_ECB, ENCRYPT, cast5_enc_tv_template, CAST5_ENC_TEST_VECTORS);
-		test_cipher ("cast5", MODE_ECB, DECRYPT, cast5_dec_tv_template, CAST5_DEC_TEST_VECTORS);
+		test_cipher("ecb(cast5)", ENCRYPT, cast5_enc_tv_template,
+			    CAST5_ENC_TEST_VECTORS);
+		test_cipher("ecb(cast5)", DECRYPT, cast5_dec_tv_template,
+			    CAST5_DEC_TEST_VECTORS);
 		break;
 
 	case 15:
-		test_cipher ("cast6", MODE_ECB, ENCRYPT, cast6_enc_tv_template, CAST6_ENC_TEST_VECTORS);
-		test_cipher ("cast6", MODE_ECB, DECRYPT, cast6_dec_tv_template, CAST6_DEC_TEST_VECTORS);
+		test_cipher("ecb(cast6)", ENCRYPT, cast6_enc_tv_template,
+			    CAST6_ENC_TEST_VECTORS);
+		test_cipher("ecb(cast6)", DECRYPT, cast6_dec_tv_template,
+			    CAST6_DEC_TEST_VECTORS);
 		break;
 
 	case 16:
-		test_cipher ("arc4", MODE_ECB, ENCRYPT, arc4_enc_tv_template, ARC4_ENC_TEST_VECTORS);
-		test_cipher ("arc4", MODE_ECB, DECRYPT, arc4_dec_tv_template, ARC4_DEC_TEST_VECTORS);
+		test_cipher("ecb(arc4)", ENCRYPT, arc4_enc_tv_template,
+			    ARC4_ENC_TEST_VECTORS);
+		test_cipher("ecb(arc4)", DECRYPT, arc4_dec_tv_template,
+			    ARC4_DEC_TEST_VECTORS);
 		break;
 
 	case 17:
@@ -967,18 +1036,24 @@ static void do_test(void)
 		break;
 
 	case 19:
-		test_cipher ("tea", MODE_ECB, ENCRYPT, tea_enc_tv_template, TEA_ENC_TEST_VECTORS);
-		test_cipher ("tea", MODE_ECB, DECRYPT, tea_dec_tv_template, TEA_DEC_TEST_VECTORS);
+		test_cipher("ecb(tea)", ENCRYPT, tea_enc_tv_template,
+			    TEA_ENC_TEST_VECTORS);
+		test_cipher("ecb(tea)", DECRYPT, tea_dec_tv_template,
+			    TEA_DEC_TEST_VECTORS);
 		break;
 
 	case 20:
-		test_cipher ("xtea", MODE_ECB, ENCRYPT, xtea_enc_tv_template, XTEA_ENC_TEST_VECTORS);
-		test_cipher ("xtea", MODE_ECB, DECRYPT, xtea_dec_tv_template, XTEA_DEC_TEST_VECTORS);
+		test_cipher("ecb(xtea)", ENCRYPT, xtea_enc_tv_template,
+			    XTEA_ENC_TEST_VECTORS);
+		test_cipher("ecb(xtea)", DECRYPT, xtea_dec_tv_template,
+			    XTEA_DEC_TEST_VECTORS);
 		break;
 
 	case 21:
-		test_cipher ("khazad", MODE_ECB, ENCRYPT, khazad_enc_tv_template, KHAZAD_ENC_TEST_VECTORS);
-		test_cipher ("khazad", MODE_ECB, DECRYPT, khazad_dec_tv_template, KHAZAD_DEC_TEST_VECTORS);
+		test_cipher("ecb(khazad)", ENCRYPT, khazad_enc_tv_template,
+			    KHAZAD_ENC_TEST_VECTORS);
+		test_cipher("ecb(khazad)", DECRYPT, khazad_dec_tv_template,
+			    KHAZAD_DEC_TEST_VECTORS);
 		break;
 
 	case 22:
@@ -994,15 +1069,21 @@ static void do_test(void)
 		break;
 
 	case 25:
-		test_cipher ("tnepres", MODE_ECB, ENCRYPT, tnepres_enc_tv_template, TNEPRES_ENC_TEST_VECTORS);
-		test_cipher ("tnepres", MODE_ECB, DECRYPT, tnepres_dec_tv_template, TNEPRES_DEC_TEST_VECTORS);
+		test_cipher("ecb(tnepres)", ENCRYPT, tnepres_enc_tv_template,
+			    TNEPRES_ENC_TEST_VECTORS);
+		test_cipher("ecb(tnepres)", DECRYPT, tnepres_dec_tv_template,
+			    TNEPRES_DEC_TEST_VECTORS);
 		break;
 
 	case 26:
-		test_cipher ("anubis", MODE_ECB, ENCRYPT, anubis_enc_tv_template, ANUBIS_ENC_TEST_VECTORS);
-		test_cipher ("anubis", MODE_ECB, DECRYPT, anubis_dec_tv_template, ANUBIS_DEC_TEST_VECTORS);
-		test_cipher ("anubis", MODE_CBC, ENCRYPT, anubis_cbc_enc_tv_template, ANUBIS_CBC_ENC_TEST_VECTORS);
-		test_cipher ("anubis", MODE_CBC, DECRYPT, anubis_cbc_dec_tv_template, ANUBIS_CBC_ENC_TEST_VECTORS);
+		test_cipher("ecb(anubis)", ENCRYPT, anubis_enc_tv_template,
+			    ANUBIS_ENC_TEST_VECTORS);
+		test_cipher("ecb(anubis)", DECRYPT, anubis_dec_tv_template,
+			    ANUBIS_DEC_TEST_VECTORS);
+		test_cipher("cbc(anubis)", ENCRYPT, anubis_cbc_enc_tv_template,
+			    ANUBIS_CBC_ENC_TEST_VECTORS);
+		test_cipher("cbc(anubis)", DECRYPT, anubis_cbc_dec_tv_template,
+			    ANUBIS_CBC_ENC_TEST_VECTORS);
 		break;
 
 	case 27:
@@ -1019,8 +1100,10 @@ static void do_test(void)
 		break;
 		
 	case 30:
-		test_cipher ("xeta", MODE_ECB, ENCRYPT, xeta_enc_tv_template, XETA_ENC_TEST_VECTORS);
-		test_cipher ("xeta", MODE_ECB, DECRYPT, xeta_dec_tv_template, XETA_DEC_TEST_VECTORS);
+		test_cipher("ecb(xeta)", ENCRYPT, xeta_enc_tv_template,
+			    XETA_ENC_TEST_VECTORS);
+		test_cipher("ecb(xeta)", DECRYPT, xeta_dec_tv_template,
+			    XETA_DEC_TEST_VECTORS);
 		break;
 
 #ifdef CONFIG_CRYPTO_HMAC
@@ -1039,65 +1122,65 @@ static void do_test(void)
 #endif
 
 	case 200:
-		test_cipher_speed("aes", MODE_ECB, ENCRYPT, sec, NULL, 0,
+		test_cipher_speed("ecb(aes)", ENCRYPT, sec, NULL, 0,
 				  aes_speed_template);
-		test_cipher_speed("aes", MODE_ECB, DECRYPT, sec, NULL, 0,
+		test_cipher_speed("ecb(aes)", DECRYPT, sec, NULL, 0,
 				  aes_speed_template);
-		test_cipher_speed("aes", MODE_CBC, ENCRYPT, sec, NULL, 0,
+		test_cipher_speed("cbc(aes)", ENCRYPT, sec, NULL, 0,
 				  aes_speed_template);
-		test_cipher_speed("aes", MODE_CBC, DECRYPT, sec, NULL, 0,
+		test_cipher_speed("cbc(aes)", DECRYPT, sec, NULL, 0,
 				  aes_speed_template);
 		break;
 
 	case 201:
-		test_cipher_speed("des3_ede", MODE_ECB, ENCRYPT, sec,
+		test_cipher_speed("ecb(des3_ede)", ENCRYPT, sec,
 				  des3_ede_enc_tv_template,
 				  DES3_EDE_ENC_TEST_VECTORS,
 				  des3_ede_speed_template);
-		test_cipher_speed("des3_ede", MODE_ECB, DECRYPT, sec,
+		test_cipher_speed("ecb(des3_ede)", DECRYPT, sec,
 				  des3_ede_dec_tv_template,
 				  DES3_EDE_DEC_TEST_VECTORS,
 				  des3_ede_speed_template);
-		test_cipher_speed("des3_ede", MODE_CBC, ENCRYPT, sec,
+		test_cipher_speed("cbc(des3_ede)", ENCRYPT, sec,
 				  des3_ede_enc_tv_template,
 				  DES3_EDE_ENC_TEST_VECTORS,
 				  des3_ede_speed_template);
-		test_cipher_speed("des3_ede", MODE_CBC, DECRYPT, sec,
+		test_cipher_speed("cbc(des3_ede)", DECRYPT, sec,
 				  des3_ede_dec_tv_template,
 				  DES3_EDE_DEC_TEST_VECTORS,
 				  des3_ede_speed_template);
 		break;
 
 	case 202:
-		test_cipher_speed("twofish", MODE_ECB, ENCRYPT, sec, NULL, 0,
+		test_cipher_speed("ecb(twofish)", ENCRYPT, sec, NULL, 0,
 				  twofish_speed_template);
-		test_cipher_speed("twofish", MODE_ECB, DECRYPT, sec, NULL, 0,
+		test_cipher_speed("ecb(twofish)", DECRYPT, sec, NULL, 0,
 				  twofish_speed_template);
-		test_cipher_speed("twofish", MODE_CBC, ENCRYPT, sec, NULL, 0,
+		test_cipher_speed("cbc(twofish)", ENCRYPT, sec, NULL, 0,
 				  twofish_speed_template);
-		test_cipher_speed("twofish", MODE_CBC, DECRYPT, sec, NULL, 0,
+		test_cipher_speed("cbc(twofish)", DECRYPT, sec, NULL, 0,
 				  twofish_speed_template);
 		break;
 
 	case 203:
-		test_cipher_speed("blowfish", MODE_ECB, ENCRYPT, sec, NULL, 0,
+		test_cipher_speed("ecb(blowfish)", ENCRYPT, sec, NULL, 0,
 				  blowfish_speed_template);
-		test_cipher_speed("blowfish", MODE_ECB, DECRYPT, sec, NULL, 0,
+		test_cipher_speed("ecb(blowfish)", DECRYPT, sec, NULL, 0,
 				  blowfish_speed_template);
-		test_cipher_speed("blowfish", MODE_CBC, ENCRYPT, sec, NULL, 0,
+		test_cipher_speed("cbc(blowfish)", ENCRYPT, sec, NULL, 0,
 				  blowfish_speed_template);
-		test_cipher_speed("blowfish", MODE_CBC, DECRYPT, sec, NULL, 0,
+		test_cipher_speed("cbc(blowfish)", DECRYPT, sec, NULL, 0,
 				  blowfish_speed_template);
 		break;
 
 	case 204:
-		test_cipher_speed("des", MODE_ECB, ENCRYPT, sec, NULL, 0,
+		test_cipher_speed("ecb(des)", ENCRYPT, sec, NULL, 0,
 				  des_speed_template);
-		test_cipher_speed("des", MODE_ECB, DECRYPT, sec, NULL, 0,
+		test_cipher_speed("ecb(des)", DECRYPT, sec, NULL, 0,
 				  des_speed_template);
-		test_cipher_speed("des", MODE_CBC, ENCRYPT, sec, NULL, 0,
+		test_cipher_speed("cbc(des)", ENCRYPT, sec, NULL, 0,
 				  des_speed_template);
-		test_cipher_speed("des", MODE_CBC, DECRYPT, sec, NULL, 0,
+		test_cipher_speed("cbc(des)", DECRYPT, sec, NULL, 0,
 				  des_speed_template);
 		break;
 
