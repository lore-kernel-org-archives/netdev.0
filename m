From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 3/7] [CRYPTO] tcrypt: Use HMAC template and hash interface
Date: Tue, 22 Aug 2006 00:27:47 +1000
Message-ID: <E1GFAkl-00074N-00@gondolin.me.apana.org.au>
References: <20060821142407.GA26988@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[CRYPTO] tcrypt: Use HMAC template and hash interface

This patch converts tcrypt to use the new HMAC template rather than the
hard-coded version of HMAC.  It also converts all digest users to use
the new cipher interface.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: David S. Miller <davem@davemloft.net>
---

 crypto/tcrypt.c |  355 ++++++++++++++++++++++++++++++++------------------------
 crypto/tcrypt.h |   23 ---
 2 files changed, 213 insertions(+), 165 deletions(-)

diff --git a/crypto/tcrypt.c b/crypto/tcrypt.c
--- a/crypto/tcrypt.c
+++ b/crypto/tcrypt.c
@@ -88,9 +88,11 @@ static void test_hash(char *algo, struct
 	unsigned int i, j, k, temp;
 	struct scatterlist sg[8];
 	char result[64];
-	struct crypto_tfm *tfm;
+	struct crypto_hash *tfm;
+	struct hash_desc desc;
 	struct hash_testvec *hash_tv;
 	unsigned int tsize;
+	int ret;
 
 	printk("\ntesting %s\n", algo);
 
@@ -104,27 +106,42 @@ static void test_hash(char *algo, struct
 
 	memcpy(tvmem, template, tsize);
 	hash_tv = (void *)tvmem;
-	tfm = crypto_alloc_tfm(algo, 0);
-	if (tfm == NULL) {
-		printk("failed to load transform for %s\n", algo);
+
+	tfm = crypto_alloc_hash(algo, 0, CRYPTO_ALG_ASYNC);
+	if (IS_ERR(tfm)) {
+		printk("failed to load transform for %s: %ld\n", algo,
+		       PTR_ERR(tfm));
 		return;
 	}
 
+	desc.tfm = tfm;
+	desc.flags = 0;
+
 	for (i = 0; i < tcount; i++) {
 		printk("test %u:\n", i + 1);
 		memset(result, 0, 64);
 
 		sg_set_buf(&sg[0], hash_tv[i].plaintext, hash_tv[i].psize);
 
-		crypto_digest_init(tfm);
-		crypto_digest_setkey(tfm, hash_tv[i].key, hash_tv[i].ksize);
-		crypto_digest_update(tfm, sg, 1);
-		crypto_digest_final(tfm, result);
+		if (hash_tv[i].ksize) {
+			ret = crypto_hash_setkey(tfm, hash_tv[i].key,
+						 hash_tv[i].ksize);
+			if (ret) {
+				printk("setkey() failed ret=%d\n", ret);
+				goto out;
+			}
+		}
+
+		ret = crypto_hash_digest(&desc, sg, hash_tv[i].psize, result);
+		if (ret) {
+			printk("digest () failed ret=%d\n", ret);
+			goto out;
+		}
 
-		hexdump(result, crypto_tfm_alg_digestsize(tfm));
+		hexdump(result, crypto_hash_digestsize(tfm));
 		printk("%s\n",
 		       memcmp(result, hash_tv[i].digest,
-			      crypto_tfm_alg_digestsize(tfm)) ?
+			      crypto_hash_digestsize(tfm)) ?
 		       "fail" : "pass");
 	}
 
@@ -150,105 +167,35 @@ static void test_hash(char *algo, struct
 					    hash_tv[i].tap[k]);
 			}
 
-			crypto_digest_digest(tfm, sg, hash_tv[i].np, result);
-
-			hexdump(result, crypto_tfm_alg_digestsize(tfm));
-			printk("%s\n",
-			       memcmp(result, hash_tv[i].digest,
-				      crypto_tfm_alg_digestsize(tfm)) ?
-			       "fail" : "pass");
-		}
-	}
-
-	crypto_free_tfm(tfm);
-}
-
-
-#ifdef CONFIG_CRYPTO_HMAC
-
-static void test_hmac(char *algo, struct hmac_testvec *template,
-		      unsigned int tcount)
-{
-	unsigned int i, j, k, temp;
-	struct scatterlist sg[8];
-	char result[64];
-	struct crypto_tfm *tfm;
-	struct hmac_testvec *hmac_tv;
-	unsigned int tsize, klen;
-
-	tfm = crypto_alloc_tfm(algo, 0);
-	if (tfm == NULL) {
-		printk("failed to load transform for %s\n", algo);
-		return;
-	}
-
-	printk("\ntesting hmac_%s\n", algo);
-
-	tsize = sizeof(struct hmac_testvec);
-	tsize *= tcount;
-	if (tsize > TVMEMSIZE) {
-		printk("template (%u) too big for tvmem (%u)\n", tsize,
-		       TVMEMSIZE);
-		goto out;
-	}
-
-	memcpy(tvmem, template, tsize);
-	hmac_tv = (void *)tvmem;
-
-	for (i = 0; i < tcount; i++) {
-		printk("test %u:\n", i + 1);
-		memset(result, 0, sizeof (result));
-
-		klen = hmac_tv[i].ksize;
-		sg_set_buf(&sg[0], hmac_tv[i].plaintext, hmac_tv[i].psize);
+			if (hash_tv[i].ksize) {
+				ret = crypto_hash_setkey(tfm, hash_tv[i].key,
+							 hash_tv[i].ksize);
 
-		crypto_hmac(tfm, hmac_tv[i].key, &klen, sg, 1, result);
-
-		hexdump(result, crypto_tfm_alg_digestsize(tfm));
-		printk("%s\n",
-		       memcmp(result, hmac_tv[i].digest,
-			      crypto_tfm_alg_digestsize(tfm)) ? "fail" :
-		       "pass");
-	}
-
-	printk("\ntesting hmac_%s across pages\n", algo);
-
-	memset(xbuf, 0, XBUFSIZE);
-
-	j = 0;
-	for (i = 0; i < tcount; i++) {
-		if (hmac_tv[i].np) {
-			j++;
-			printk("test %u:\n",j);
-			memset(result, 0, 64);
-
-			temp = 0;
-			klen = hmac_tv[i].ksize;
-			for (k = 0; k < hmac_tv[i].np; k++) {
-				memcpy(&xbuf[IDX[k]],
-				       hmac_tv[i].plaintext + temp,
-				       hmac_tv[i].tap[k]);
-				temp += hmac_tv[i].tap[k];
-				sg_set_buf(&sg[k], &xbuf[IDX[k]],
-					    hmac_tv[i].tap[k]);
+				if (ret) {
+					printk("setkey() failed ret=%d\n", ret);
+					goto out;
+				}
 			}
 
-			crypto_hmac(tfm, hmac_tv[i].key, &klen, sg,
-				    hmac_tv[i].np, result);
-			hexdump(result, crypto_tfm_alg_digestsize(tfm));
+			ret = crypto_hash_digest(&desc, sg, hash_tv[i].psize,
+						 result);
+			if (ret) {
+				printk("digest () failed ret=%d\n", ret);
+				goto out;
+			}
 
+			hexdump(result, crypto_hash_digestsize(tfm));
 			printk("%s\n",
-			       memcmp(result, hmac_tv[i].digest,
-				      crypto_tfm_alg_digestsize(tfm)) ?
+			       memcmp(result, hash_tv[i].digest,
+				      crypto_hash_digestsize(tfm)) ?
 			       "fail" : "pass");
 		}
 	}
+
 out:
-	crypto_free_tfm(tfm);
+	crypto_free_hash(tfm);
 }
 
-#endif	/* CONFIG_CRYPTO_HMAC */
-
 static void test_cipher(char *algo, int enc,
 			struct cipher_testvec *template, unsigned int tcount)
 {
@@ -570,97 +517,202 @@ out:
 	crypto_free_blkcipher(tfm);
 }
 
-static void test_digest_jiffies(struct crypto_tfm *tfm, char *p, int blen,
-				int plen, char *out, int sec)
+static int test_hash_jiffies_digest(struct hash_desc *desc, char *p, int blen,
+				    char *out, int sec)
+{
+	struct scatterlist sg[1];
+	unsigned long start, end;
+	int bcount;
+	int ret;
+
+	for (start = jiffies, end = start + sec * HZ, bcount = 0;
+	     time_before(jiffies, end); bcount++) {
+		sg_set_buf(sg, p, blen);
+		ret = crypto_hash_digest(desc, sg, blen, out);
+		if (ret)
+			return ret;
+	}
+
+	printk("%6u opers/sec, %9lu bytes/sec\n",
+	       bcount / sec, ((long)bcount * blen) / sec);
+
+	return 0;
+}
+
+static int test_hash_jiffies(struct hash_desc *desc, char *p, int blen,
+			     int plen, char *out, int sec)
 {
 	struct scatterlist sg[1];
 	unsigned long start, end;
 	int bcount, pcount;
+	int ret;
+
+	if (plen == blen)
+		return test_hash_jiffies_digest(desc, p, blen, out, sec);
 
 	for (start = jiffies, end = start + sec * HZ, bcount = 0;
 	     time_before(jiffies, end); bcount++) {
-		crypto_digest_init(tfm);
+		ret = crypto_hash_init(desc);
+		if (ret)
+			return ret;
 		for (pcount = 0; pcount < blen; pcount += plen) {
 			sg_set_buf(sg, p + pcount, plen);
-			crypto_digest_update(tfm, sg, 1);
+			ret = crypto_hash_update(desc, sg, plen);
+			if (ret)
+				return ret;
 		}
 		/* we assume there is enough space in 'out' for the result */
-		crypto_digest_final(tfm, out);
+		ret = crypto_hash_final(desc, out);
+		if (ret)
+			return ret;
 	}
 
 	printk("%6u opers/sec, %9lu bytes/sec\n",
 	       bcount / sec, ((long)bcount * blen) / sec);
 
-	return;
+	return 0;
+}
+
+static int test_hash_cycles_digest(struct hash_desc *desc, char *p, int blen,
+				   char *out)
+{
+	struct scatterlist sg[1];
+	unsigned long cycles = 0;
+	int i;
+	int ret;
+
+	local_bh_disable();
+	local_irq_disable();
+
+	/* Warm-up run. */
+	for (i = 0; i < 4; i++) {
+		sg_set_buf(sg, p, blen);
+		ret = crypto_hash_digest(desc, sg, blen, out);
+		if (ret)
+			goto out;
+	}
+
+	/* The real thing. */
+	for (i = 0; i < 8; i++) {
+		cycles_t start, end;
+
+		start = get_cycles();
+
+		sg_set_buf(sg, p, blen);
+		ret = crypto_hash_digest(desc, sg, blen, out);
+		if (ret)
+			goto out;
+
+		end = get_cycles();
+
+		cycles += end - start;
+	}
+
+out:
+	local_irq_enable();
+	local_bh_enable();
+
+	if (ret)
+		return ret;
+
+	printk("%6lu cycles/operation, %4lu cycles/byte\n",
+	       cycles / 8, cycles / (8 * blen));
+
+	return 0;
 }
 
-static void test_digest_cycles(struct crypto_tfm *tfm, char *p, int blen,
-			       int plen, char *out)
+static int test_hash_cycles(struct hash_desc *desc, char *p, int blen,
+			    int plen, char *out)
 {
 	struct scatterlist sg[1];
 	unsigned long cycles = 0;
 	int i, pcount;
+	int ret;
+
+	if (plen == blen)
+		return test_hash_cycles_digest(desc, p, blen, out);
 
 	local_bh_disable();
 	local_irq_disable();
 
 	/* Warm-up run. */
 	for (i = 0; i < 4; i++) {
-		crypto_digest_init(tfm);
+		ret = crypto_hash_init(desc);
+		if (ret)
+			goto out;
 		for (pcount = 0; pcount < blen; pcount += plen) {
 			sg_set_buf(sg, p + pcount, plen);
-			crypto_digest_update(tfm, sg, 1);
+			ret = crypto_hash_update(desc, sg, plen);
+			if (ret)
+				goto out;
 		}
-		crypto_digest_final(tfm, out);
+		crypto_hash_final(desc, out);
+		if (ret)
+			goto out;
 	}
 
 	/* The real thing. */
 	for (i = 0; i < 8; i++) {
 		cycles_t start, end;
 
-		crypto_digest_init(tfm);
-
 		start = get_cycles();
 
+		ret = crypto_hash_init(desc);
+		if (ret)
+			goto out;
 		for (pcount = 0; pcount < blen; pcount += plen) {
 			sg_set_buf(sg, p + pcount, plen);
-			crypto_digest_update(tfm, sg, 1);
+			ret = crypto_hash_update(desc, sg, plen);
+			if (ret)
+				goto out;
 		}
-		crypto_digest_final(tfm, out);
+		ret = crypto_hash_final(desc, out);
+		if (ret)
+			goto out;
 
 		end = get_cycles();
 
 		cycles += end - start;
 	}
 
+out:
 	local_irq_enable();
 	local_bh_enable();
 
+	if (ret)
+		return ret;
+
 	printk("%6lu cycles/operation, %4lu cycles/byte\n",
 	       cycles / 8, cycles / (8 * blen));
 
-	return;
+	return 0;
 }
 
-static void test_digest_speed(char *algo, unsigned int sec,
-			      struct digest_speed *speed)
+static void test_hash_speed(char *algo, unsigned int sec,
+			      struct hash_speed *speed)
 {
-	struct crypto_tfm *tfm;
+	struct crypto_hash *tfm;
+	struct hash_desc desc;
 	char output[1024];
 	int i;
+	int ret;
 
 	printk("\ntesting speed of %s\n", algo);
 
-	tfm = crypto_alloc_tfm(algo, 0);
+	tfm = crypto_alloc_hash(algo, 0, CRYPTO_ALG_ASYNC);
 
-	if (tfm == NULL) {
-		printk("failed to load transform for %s\n", algo);
+	if (IS_ERR(tfm)) {
+		printk("failed to load transform for %s: %ld\n", algo,
+		       PTR_ERR(tfm));
 		return;
 	}
 
-	if (crypto_tfm_alg_digestsize(tfm) > sizeof(output)) {
+	desc.tfm = tfm;
+	desc.flags = 0;
+
+	if (crypto_hash_digestsize(tfm) > sizeof(output)) {
 		printk("digestsize(%u) > outputbuffer(%zu)\n",
-		       crypto_tfm_alg_digestsize(tfm), sizeof(output));
+		       crypto_hash_digestsize(tfm), sizeof(output));
 		goto out;
 	}
 
@@ -677,13 +729,20 @@ static void test_digest_speed(char *algo
 		memset(tvmem, 0xff, speed[i].blen);
 
 		if (sec)
-			test_digest_jiffies(tfm, tvmem, speed[i].blen, speed[i].plen, output, sec);
+			ret = test_hash_jiffies(&desc, tvmem, speed[i].blen,
+						speed[i].plen, output, sec);
 		else
-			test_digest_cycles(tfm, tvmem, speed[i].blen, speed[i].plen, output);
+			ret = test_hash_cycles(&desc, tvmem, speed[i].blen,
+					       speed[i].plen, output);
+
+		if (ret) {
+			printk("hashing failed ret=%d\n", ret);
+			break;
+		}
 	}
 
 out:
-	crypto_free_tfm(tfm);
+	crypto_free_hash(tfm);
 }
 
 static void test_deflate(void)
@@ -911,11 +970,12 @@ static void do_test(void)
 		test_hash("tgr128", tgr128_tv_template, TGR128_TEST_VECTORS);
 		test_deflate();
 		test_hash("crc32c", crc32c_tv_template, CRC32C_TEST_VECTORS);
-#ifdef CONFIG_CRYPTO_HMAC
-		test_hmac("md5", hmac_md5_tv_template, HMAC_MD5_TEST_VECTORS);
-		test_hmac("sha1", hmac_sha1_tv_template, HMAC_SHA1_TEST_VECTORS);
-		test_hmac("sha256", hmac_sha256_tv_template, HMAC_SHA256_TEST_VECTORS);
-#endif
+		test_hash("hmac(md5)", hmac_md5_tv_template,
+			  HMAC_MD5_TEST_VECTORS);
+		test_hash("hmac(sha1)", hmac_sha1_tv_template,
+			  HMAC_SHA1_TEST_VECTORS);
+		test_hash("hmac(sha256)", hmac_sha256_tv_template,
+			  HMAC_SHA256_TEST_VECTORS);
 
 		test_hash("michael_mic", michael_mic_tv_template, MICHAEL_MIC_TEST_VECTORS);
 		break;
@@ -1106,20 +1166,21 @@ static void do_test(void)
 			    XETA_DEC_TEST_VECTORS);
 		break;
 
-#ifdef CONFIG_CRYPTO_HMAC
 	case 100:
-		test_hmac("md5", hmac_md5_tv_template, HMAC_MD5_TEST_VECTORS);
+		test_hash("hmac(md5)", hmac_md5_tv_template,
+			  HMAC_MD5_TEST_VECTORS);
 		break;
 
 	case 101:
-		test_hmac("sha1", hmac_sha1_tv_template, HMAC_SHA1_TEST_VECTORS);
+		test_hash("hmac(sha1)", hmac_sha1_tv_template,
+			  HMAC_SHA1_TEST_VECTORS);
 		break;
 
 	case 102:
-		test_hmac("sha256", hmac_sha256_tv_template, HMAC_SHA256_TEST_VECTORS);
+		test_hash("hmac(sha256)", hmac_sha256_tv_template,
+			  HMAC_SHA256_TEST_VECTORS);
 		break;
 
-#endif
 
 	case 200:
 		test_cipher_speed("ecb(aes)", ENCRYPT, sec, NULL, 0,
@@ -1188,51 +1249,51 @@ static void do_test(void)
 		/* fall through */
 
 	case 301:
-		test_digest_speed("md4", sec, generic_digest_speed_template);
+		test_hash_speed("md4", sec, generic_hash_speed_template);
 		if (mode > 300 && mode < 400) break;
 
 	case 302:
-		test_digest_speed("md5", sec, generic_digest_speed_template);
+		test_hash_speed("md5", sec, generic_hash_speed_template);
 		if (mode > 300 && mode < 400) break;
 
 	case 303:
-		test_digest_speed("sha1", sec, generic_digest_speed_template);
+		test_hash_speed("sha1", sec, generic_hash_speed_template);
 		if (mode > 300 && mode < 400) break;
 
 	case 304:
-		test_digest_speed("sha256", sec, generic_digest_speed_template);
+		test_hash_speed("sha256", sec, generic_hash_speed_template);
 		if (mode > 300 && mode < 400) break;
 
 	case 305:
-		test_digest_speed("sha384", sec, generic_digest_speed_template);
+		test_hash_speed("sha384", sec, generic_hash_speed_template);
 		if (mode > 300 && mode < 400) break;
 
 	case 306:
-		test_digest_speed("sha512", sec, generic_digest_speed_template);
+		test_hash_speed("sha512", sec, generic_hash_speed_template);
 		if (mode > 300 && mode < 400) break;
 
 	case 307:
-		test_digest_speed("wp256", sec, generic_digest_speed_template);
+		test_hash_speed("wp256", sec, generic_hash_speed_template);
 		if (mode > 300 && mode < 400) break;
 
 	case 308:
-		test_digest_speed("wp384", sec, generic_digest_speed_template);
+		test_hash_speed("wp384", sec, generic_hash_speed_template);
 		if (mode > 300 && mode < 400) break;
 
 	case 309:
-		test_digest_speed("wp512", sec, generic_digest_speed_template);
+		test_hash_speed("wp512", sec, generic_hash_speed_template);
 		if (mode > 300 && mode < 400) break;
 
 	case 310:
-		test_digest_speed("tgr128", sec, generic_digest_speed_template);
+		test_hash_speed("tgr128", sec, generic_hash_speed_template);
 		if (mode > 300 && mode < 400) break;
 
 	case 311:
-		test_digest_speed("tgr160", sec, generic_digest_speed_template);
+		test_hash_speed("tgr160", sec, generic_hash_speed_template);
 		if (mode > 300 && mode < 400) break;
 
 	case 312:
-		test_digest_speed("tgr192", sec, generic_digest_speed_template);
+		test_hash_speed("tgr192", sec, generic_hash_speed_template);
 		if (mode > 300 && mode < 400) break;
 
 	case 399:
diff --git a/crypto/tcrypt.h b/crypto/tcrypt.h
--- a/crypto/tcrypt.h
+++ b/crypto/tcrypt.h
@@ -36,16 +36,6 @@ struct hash_testvec {
 	unsigned char ksize;
 };
 
-struct hmac_testvec {
-	char key[128];
-	char plaintext[128];
-	char digest[MAX_DIGEST_SIZE];
-	unsigned char tap[MAX_TAP];
-	unsigned char ksize;
-	unsigned char psize;
-	unsigned char np;
-};
-
 struct cipher_testvec {
 	char key[MAX_KEYLEN] __attribute__ ((__aligned__(4)));
 	char iv[MAX_IVLEN];
@@ -65,7 +55,7 @@ struct cipher_speed {
 	unsigned int blen;
 };
 
-struct digest_speed {
+struct hash_speed {
 	unsigned int blen;	/* buffer length */
 	unsigned int plen;	/* per-update length */
 };
@@ -697,14 +687,13 @@ static struct hash_testvec tgr128_tv_tem
 	},
 };
 
-#ifdef CONFIG_CRYPTO_HMAC
 /*
  * HMAC-MD5 test vectors from RFC2202
  * (These need to be fixed to not use strlen).
  */
 #define HMAC_MD5_TEST_VECTORS	7
 
-static struct hmac_testvec hmac_md5_tv_template[] =
+static struct hash_testvec hmac_md5_tv_template[] =
 {
 	{
 		.key	= { [0 ... 15] =  0x0b },
@@ -768,7 +757,7 @@ static struct hmac_testvec hmac_md5_tv_t
  */
 #define HMAC_SHA1_TEST_VECTORS	7
 
-static struct hmac_testvec hmac_sha1_tv_template[] = {
+static struct hash_testvec hmac_sha1_tv_template[] = {
 	{
 		.key	= { [0 ... 19] = 0x0b },
 		.ksize	= 20,
@@ -833,7 +822,7 @@ static struct hmac_testvec hmac_sha1_tv_
  */
 #define HMAC_SHA256_TEST_VECTORS	10
 
-static struct hmac_testvec hmac_sha256_tv_template[] = {
+static struct hash_testvec hmac_sha256_tv_template[] = {
 	{
 		.key	= { 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
 			    0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x10,
@@ -944,8 +933,6 @@ static struct hmac_testvec hmac_sha256_t
 	},
 };
 
-#endif	/* CONFIG_CRYPTO_HMAC */
-
 /*
  * DES test vectors.
  */
@@ -3160,7 +3147,7 @@ static struct cipher_speed des_speed_tem
 /*
  * Digest speed tests
  */
-static struct digest_speed generic_digest_speed_template[] = {
+static struct hash_speed generic_hash_speed_template[] = {
 	{ .blen = 16, 	.plen = 16, },
 	{ .blen = 64,	.plen = 16, },
 	{ .blen = 64,	.plen = 64, },
