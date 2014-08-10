From: Luca Clementi <luca.clementi@gmail.com>
Subject: [RFC] crypto: tcrypt: new user interface with debugfs
Date: Sun, 10 Aug 2014 04:04:22 +0000
Message-ID: <1407643462-3355-1-git-send-email-luca.clementi@gmail.com>
Cc: Luca Clementi <luca.clementi@gmail.com>,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

tcrypt is a kernel module which can be used to trigger speed tests on
different parts of the crypto API. To trigger a test, users has to load the
module using various module parameters, e.g.:

 # modprobe tcrypt mode=404 sec=5

All tcrypt tests are implemented in the _init function, their output is sent to
the printk buffer, and once the test is over _init always returns a failure.

This patch modifies tcrypt in order to expose a debugfs user space interface
which can be used to trigger tcrypt tests and to get their output. All tests
output is redirected to an internal ring buffer.

The following files are available in the tcrypt debugfs directory:

 - command: this file can be use to control which test should be run simply
            writing the test name to it. it also supports clearing the 'output'
            buffer and listing all available tests

 - output:  holds a ring buffer with the output of the tests

 - seconds: this file can be used to control the number of seconds that a
            tests should be run consecutively. If zero it uses CPU cycles

This patch is not for inclusion, but I'd like to know if my approach makes
sense and if debugfs is the right place to expose a tcrypt interface.

Some functionalities available in the current version of the module are still
missing in this version (in particular test_available and do_alg_test are not
implemented yet). I also don't like the implementation of the 'fixed_tests' but
as i said, this is just a prototype.

Signed-off-by: Luca Clementi <luca.clementi@gmail.com>
---
 crypto/tcrypt.c |  803 ++++++++++++++++++++++++++++++++++---------------------
 crypto/tcrypt.h |   28 --
 2 files changed, 495 insertions(+), 336 deletions(-)

diff --git a/crypto/tcrypt.c b/crypto/tcrypt.c
index 890449e..4206cfc 100644
--- a/crypto/tcrypt.c
+++ b/crypto/tcrypt.c
@@ -33,6 +33,8 @@
 #include <linux/jiffies.h>
 #include <linux/timex.h>
 #include <linux/interrupt.h>
+#include <linux/debugfs.h>
+#include <linux/ctype.h>
 #include "tcrypt.h"
 #include "internal.h"
 
@@ -53,16 +55,102 @@
 #define get_driver_name(tfm_type, tfm) crypto_tfm_alg_driver_name(tfm_type ## _tfm(tfm))
 
 /*
+ * maximum length of command
+ */
+#define COMMAND_BUFFER_SIZE 128
+#define OUTPUT_BUFFER_LINES 256
+
+
+/*
  * Used by test_cipher_speed()
  */
 static unsigned int sec;
 
-static char *alg = NULL;
-static u32 type;
-static u32 mask;
-static int mode;
 static char *tvmem[TVMEMSIZE];
 
+/**
+ * base level dentry for the tcrypto debugfs
+ */
+static struct dentry *d_basetcrypt;
+static char read_str[] =
+	"tcrypt mini-HOWTO:\n\n"
+	"# echo list > command : disply a list of available test commands\n"
+	"# cat output\n"
+	"hash_speed_<name_of_hash>\n"
+	"ahash_speed_<name_of_hash>\n"
+	"cipher_speed_aes\n"
+	"cipher_speed_des3_ede\n"
+	"[...]\n"
+	"# echo clear > command : to clear the output buffer\n"
+	"# cat output\n"
+	"# echo hash_speed_sha256 > command : run the speed test on sha256\n"
+	"# cat output\n"
+	"some output of the sha256 test\n"
+	"[...]\n"
+	"# echo 2 > seconds : run next tests for 2 seconds\n"
+	"     (it defaults to zero which uses CPU cycles instead)\n";
+
+static struct debugfs_blob_wrapper readme_blob;
+
+static struct tcrypt_data_type {
+	char			*output[OUTPUT_BUFFER_LINES];
+	size_t			cur_start;
+	size_t			cur_stop;
+} tcrypt_data;
+
+/*
+ * tcrypt_output_lock is used to protect the tcrypt_data.output buffer
+ */
+DEFINE_MUTEX(tcrypt_output_lock);
+
+#define get_num_elements() ((OUTPUT_BUFFER_LINES + tcrypt_data.cur_stop - \
+		tcrypt_data.cur_start) % OUTPUT_BUFFER_LINES)
+
+
+#define tc_printf(...)							\
+do {									\
+	mutex_lock_interruptible(&tcrypt_output_lock);			\
+	tc_printf_unlock(__VA_ARGS__);					\
+	mutex_unlock(&tcrypt_output_lock);				\
+} while (0)
+
+static void
+tc_printf_unlock(const char *fmt, ...)
+{
+	va_list ap;
+	char *p;
+
+	va_start(ap, fmt);
+	p = kvasprintf(GFP_KERNEL, fmt, ap);
+	va_end(ap);
+
+	if (!p) {
+		pr_err("tcrypt: Unable to allocate memory (output"
+					" buffer)\n");
+		return;
+	}
+
+	tcrypt_data.output[tcrypt_data.cur_stop] = p;
+
+	tcrypt_data.cur_stop++;
+
+	if (tcrypt_data.cur_stop == OUTPUT_BUFFER_LINES)
+		/* cur_stop wraps */
+		tcrypt_data.cur_stop = 0;
+
+	if (tcrypt_data.cur_stop == tcrypt_data.cur_start) {
+		/* buffer is full we need some space */
+		kfree(tcrypt_data.output[tcrypt_data.cur_start]);
+		tcrypt_data.cur_start++;
+	}
+
+	if (tcrypt_data.cur_start == OUTPUT_BUFFER_LINES)
+		/* double wrap */
+		tcrypt_data.cur_start = 0;
+}
+
+
+
 static char *check[] = {
 	"des", "md5", "des3_ede", "rot13", "sha1", "sha224", "sha256",
 	"blowfish", "twofish", "serpent", "sha384", "sha512", "md4", "aes",
@@ -90,7 +178,7 @@ static int test_cipher_jiffies(struct blkcipher_desc *desc, int enc,
 			return ret;
 	}
 
-	printk("%d operations in %d seconds (%ld bytes)\n",
+	tc_printf("%d operations in %d seconds (%ld bytes)\n",
 	       bcount, secs, (long)bcount * blen);
 	return 0;
 }
@@ -136,7 +224,7 @@ out:
 	local_irq_enable();
 
 	if (ret == 0)
-		printk("1 operation in %lu cycles (%d bytes)\n",
+		tc_printf("1 operation in %lu cycles (%d bytes)\n",
 		       (cycles + 4) / 8, blen);
 
 	return ret;
@@ -160,7 +248,7 @@ static int test_aead_jiffies(struct aead_request *req, int enc,
 			return ret;
 	}
 
-	printk("%d operations in %d seconds (%ld bytes)\n",
+	tc_printf("%d operations in %d seconds (%ld bytes)\n",
 	       bcount, secs, (long)bcount * blen);
 	return 0;
 }
@@ -205,7 +293,7 @@ out:
 	local_irq_enable();
 
 	if (ret == 0)
-		printk("1 operation in %lu cycles (%d bytes)\n",
+		tc_printf("1 operation in %lu cycles (%d bytes)\n",
 		       (cycles + 4) / 8, blen);
 
 	return ret;
@@ -288,7 +376,7 @@ static void test_aead_speed(const char *algo, int enc, unsigned int secs,
 	unsigned int iv_len;
 
 	if (aad_size >= PAGE_SIZE) {
-		pr_err("associate data length (%u) too big\n", aad_size);
+		tc_printf("associate data length (%u) too big\n", aad_size);
 		return;
 	}
 
@@ -313,17 +401,17 @@ static void test_aead_speed(const char *algo, int enc, unsigned int secs,
 	tfm = crypto_alloc_aead(algo, 0, 0);
 
 	if (IS_ERR(tfm)) {
-		pr_err("alg: aead: Failed to load transform for %s: %ld\n", algo,
+		tc_printf("alg: aead: Failed to load transform for %s: %ld\n", algo,
 		       PTR_ERR(tfm));
 		goto out_notfm;
 	}
 
-	printk(KERN_INFO "\ntesting speed of %s (%s) %s\n", algo,
+	tc_printf("\ntesting speed of %s (%s) %s\n", algo,
 			get_driver_name(crypto_aead, tfm), e);
 
 	req = aead_request_alloc(tfm, GFP_KERNEL);
 	if (!req) {
-		pr_err("alg: aead: Failed to allocate request for %s\n",
+		tc_printf("alg: aead: Failed to allocate request for %s\n",
 		       algo);
 		goto out_noreq;
 	}
@@ -337,7 +425,7 @@ static void test_aead_speed(const char *algo, int enc, unsigned int secs,
 			sg_init_one(&asg[0], assoc, aad_size);
 
 			if ((*keysize + *b_size) > TVMEMSIZE * PAGE_SIZE) {
-				pr_err("template (%u) too big for tvmem (%lu)\n",
+				tc_printf("template (%u) too big for tvmem (%lu)\n",
 				       *keysize + *b_size,
 					TVMEMSIZE * PAGE_SIZE);
 				goto out;
@@ -358,14 +446,14 @@ static void test_aead_speed(const char *algo, int enc, unsigned int secs,
 				memset(&iv, 0xff, iv_len);
 
 			crypto_aead_clear_flags(tfm, ~0);
-			printk(KERN_INFO "test %u (%d bit key, %d byte blocks): ",
+			tc_printf("test %u (%d bit key, %d byte blocks): ",
 					i, *keysize * 8, *b_size);
 
 
 			memset(tvmem[0], 0xff, PAGE_SIZE);
 
 			if (ret) {
-				pr_err("setkey() failed flags=%x\n",
+				tc_printf("setkey() failed flags=%x\n",
 						crypto_aead_get_flags(tfm));
 				goto out;
 			}
@@ -386,7 +474,7 @@ static void test_aead_speed(const char *algo, int enc, unsigned int secs,
 				ret = test_aead_cycles(req, enc, *b_size);
 
 			if (ret) {
-				pr_err("%s() failed return code=%d\n", e, ret);
+				tc_printf("%s() failed return code=%d\n", e, ret);
 				break;
 			}
 			b_size++;
@@ -431,14 +519,14 @@ static void test_cipher_speed(const char *algo, int enc, unsigned int secs,
 	tfm = crypto_alloc_blkcipher(algo, 0, CRYPTO_ALG_ASYNC);
 
 	if (IS_ERR(tfm)) {
-		printk("failed to load transform for %s: %ld\n", algo,
+		tc_printf("failed to load transform for %s: %ld\n", algo,
 		       PTR_ERR(tfm));
 		return;
 	}
 	desc.tfm = tfm;
 	desc.flags = 0;
 
-	printk(KERN_INFO "\ntesting speed of %s (%s) %s\n", algo,
+	tc_printf("\ntesting speed of %s (%s) %s\n", algo,
 			get_driver_name(crypto_blkcipher, tfm), e);
 
 	i = 0;
@@ -449,13 +537,13 @@ static void test_cipher_speed(const char *algo, int enc, unsigned int secs,
 			struct scatterlist sg[TVMEMSIZE];
 
 			if ((*keysize + *b_size) > TVMEMSIZE * PAGE_SIZE) {
-				printk("template (%u) too big for "
+				tc_printf("template (%u) too big for "
 				       "tvmem (%lu)\n", *keysize + *b_size,
 				       TVMEMSIZE * PAGE_SIZE);
 				goto out;
 			}
 
-			printk("test %u (%d bit key, %d byte blocks): ", i,
+			tc_printf("test %u (%d bit key, %d byte blocks): ", i,
 					*keysize * 8, *b_size);
 
 			memset(tvmem[0], 0xff, PAGE_SIZE);
@@ -471,7 +559,7 @@ static void test_cipher_speed(const char *algo, int enc, unsigned int secs,
 
 			ret = crypto_blkcipher_setkey(tfm, key, *keysize);
 			if (ret) {
-				printk("setkey() failed flags=%x\n",
+				tc_printf("setkey() failed flags=%x\n",
 						crypto_blkcipher_get_flags(tfm));
 				goto out;
 			}
@@ -498,7 +586,7 @@ static void test_cipher_speed(const char *algo, int enc, unsigned int secs,
 							 *b_size);
 
 			if (ret) {
-				printk("%s() failed flags=%x\n", e, desc.flags);
+				tc_printf("%s() failed flags=%x\n", e, desc.flags);
 				break;
 			}
 			b_size++;
@@ -526,7 +614,7 @@ static int test_hash_jiffies_digest(struct hash_desc *desc,
 			return ret;
 	}
 
-	printk("%6u opers/sec, %9lu bytes/sec\n",
+	tc_printf("%6u opers/sec, %9lu bytes/sec\n",
 	       bcount / secs, ((long)bcount * blen) / secs);
 
 	return 0;
@@ -558,7 +646,7 @@ static int test_hash_jiffies(struct hash_desc *desc, struct scatterlist *sg,
 			return ret;
 	}
 
-	printk("%6u opers/sec, %9lu bytes/sec\n",
+	tc_printf("%6u opers/sec, %9lu bytes/sec\n",
 	       bcount / secs, ((long)bcount * blen) / secs);
 
 	return 0;
@@ -601,7 +689,7 @@ out:
 	if (ret)
 		return ret;
 
-	printk("%6lu cycles/operation, %4lu cycles/byte\n",
+	tc_printf("%6lu cycles/operation, %4lu cycles/byte\n",
 	       cycles / 8, cycles / (8 * blen));
 
 	return 0;
@@ -663,7 +751,7 @@ out:
 	if (ret)
 		return ret;
 
-	printk("%6lu cycles/operation, %4lu cycles/byte\n",
+	tc_printf("%6lu cycles/operation, %4lu cycles/byte\n",
 	       cycles / 8, cycles / (8 * blen));
 
 	return 0;
@@ -681,7 +769,7 @@ static void test_hash_sg_init(struct scatterlist *sg)
 }
 
 static void test_hash_speed(const char *algo, unsigned int secs,
-			    struct hash_speed *speed)
+			    struct hash_speed *speed, unsigned int keylen)
 {
 	struct scatterlist sg[TVMEMSIZE];
 	struct crypto_hash *tfm;
@@ -693,19 +781,19 @@ static void test_hash_speed(const char *algo, unsigned int secs,
 	tfm = crypto_alloc_hash(algo, 0, CRYPTO_ALG_ASYNC);
 
 	if (IS_ERR(tfm)) {
-		printk(KERN_ERR "failed to load transform for %s: %ld\n", algo,
+		tc_printf("failed to load transform for %s: %ld\n", algo,
 		       PTR_ERR(tfm));
 		return;
 	}
 
-	printk(KERN_INFO "\ntesting speed of %s (%s)\n", algo,
+	tc_printf("\ntesting speed of %s (%s)\n", algo,
 			get_driver_name(crypto_hash, tfm));
 
 	desc.tfm = tfm;
 	desc.flags = 0;
 
 	if (crypto_hash_digestsize(tfm) > sizeof(output)) {
-		printk(KERN_ERR "digestsize(%u) > outputbuffer(%zu)\n",
+		tc_printf("digestsize(%u) > outputbuffer(%zu)\n",
 		       crypto_hash_digestsize(tfm), sizeof(output));
 		goto out;
 	}
@@ -713,16 +801,15 @@ static void test_hash_speed(const char *algo, unsigned int secs,
 	test_hash_sg_init(sg);
 	for (i = 0; speed[i].blen != 0; i++) {
 		if (speed[i].blen > TVMEMSIZE * PAGE_SIZE) {
-			printk(KERN_ERR
-			       "template (%u) too big for tvmem (%lu)\n",
+			tc_printf("template (%u) too big for tvmem (%lu)\n",
 			       speed[i].blen, TVMEMSIZE * PAGE_SIZE);
 			goto out;
 		}
 
-		if (speed[i].klen)
-			crypto_hash_setkey(tfm, tvmem[0], speed[i].klen);
+		if (keylen)
+			crypto_hash_setkey(tfm, tvmem[0], keylen);
 
-		printk(KERN_INFO "test%3u "
+		tc_printf("test%3u "
 		       "(%5u byte blocks,%5u bytes per update,%4u updates): ",
 		       i, speed[i].blen, speed[i].plen, speed[i].blen / speed[i].plen);
 
@@ -734,7 +821,7 @@ static void test_hash_speed(const char *algo, unsigned int secs,
 					       speed[i].plen, output);
 
 		if (ret) {
-			printk(KERN_ERR "hashing failed ret=%d\n", ret);
+			tc_printf("hashing failed ret=%d\n", ret);
 			break;
 		}
 	}
@@ -786,7 +873,7 @@ static int test_ahash_jiffies_digest(struct ahash_request *req, int blen,
 			return ret;
 	}
 
-	printk("%6u opers/sec, %9lu bytes/sec\n",
+	tc_printf("%6u opers/sec, %9lu bytes/sec\n",
 	       bcount / secs, ((long)bcount * blen) / secs);
 
 	return 0;
@@ -818,7 +905,7 @@ static int test_ahash_jiffies(struct ahash_request *req, int blen,
 			return ret;
 	}
 
-	pr_cont("%6u opers/sec, %9lu bytes/sec\n",
+	tc_printf("%6u opers/sec, %9lu bytes/sec\n",
 		bcount / secs, ((long)bcount * blen) / secs);
 
 	return 0;
@@ -856,7 +943,7 @@ out:
 	if (ret)
 		return ret;
 
-	pr_cont("%6lu cycles/operation, %4lu cycles/byte\n",
+	tc_printf("%6lu cycles/operation, %4lu cycles/byte\n",
 		cycles / 8, cycles / (8 * blen));
 
 	return 0;
@@ -913,7 +1000,7 @@ out:
 	if (ret)
 		return ret;
 
-	pr_cont("%6lu cycles/operation, %4lu cycles/byte\n",
+	tc_printf("%6lu cycles/operation, %4lu cycles/byte\n",
 		cycles / 8, cycles / (8 * blen));
 
 	return 0;
@@ -931,16 +1018,16 @@ static void test_ahash_speed(const char *algo, unsigned int secs,
 
 	tfm = crypto_alloc_ahash(algo, 0, 0);
 	if (IS_ERR(tfm)) {
-		pr_err("failed to load transform for %s: %ld\n",
+		tc_printf("failed to load transform for %s: %ld\n",
 		       algo, PTR_ERR(tfm));
 		return;
 	}
 
-	printk(KERN_INFO "\ntesting speed of async %s (%s)\n", algo,
+	tc_printf("\ntesting speed of async %s (%s)\n", algo,
 			get_driver_name(crypto_ahash, tfm));
 
 	if (crypto_ahash_digestsize(tfm) > sizeof(output)) {
-		pr_err("digestsize(%u) > outputbuffer(%zu)\n",
+		tc_printf("digestsize(%u) > outputbuffer(%zu)\n",
 		       crypto_ahash_digestsize(tfm), sizeof(output));
 		goto out;
 	}
@@ -948,7 +1035,7 @@ static void test_ahash_speed(const char *algo, unsigned int secs,
 	test_hash_sg_init(sg);
 	req = ahash_request_alloc(tfm, GFP_KERNEL);
 	if (!req) {
-		pr_err("ahash request allocation failure\n");
+		tc_printf("ahash request allocation failure\n");
 		goto out;
 	}
 
@@ -958,12 +1045,12 @@ static void test_ahash_speed(const char *algo, unsigned int secs,
 
 	for (i = 0; speed[i].blen != 0; i++) {
 		if (speed[i].blen > TVMEMSIZE * PAGE_SIZE) {
-			pr_err("template (%u) too big for tvmem (%lu)\n",
+			tc_printf("template (%u) too big for tvmem (%lu)\n",
 			       speed[i].blen, TVMEMSIZE * PAGE_SIZE);
 			break;
 		}
 
-		pr_info("test%3u "
+		tc_printf("test%3u "
 			"(%5u byte blocks,%5u bytes per update,%4u updates): ",
 			i, speed[i].blen, speed[i].plen, speed[i].blen / speed[i].plen);
 
@@ -977,7 +1064,7 @@ static void test_ahash_speed(const char *algo, unsigned int secs,
 						speed[i].plen, output);
 
 		if (ret) {
-			pr_err("hashing failed ret=%d\n", ret);
+			tc_printf("hashing failed ret=%d\n", ret);
 			break;
 		}
 	}
@@ -1022,7 +1109,7 @@ static int test_acipher_jiffies(struct ablkcipher_request *req, int enc,
 			return ret;
 	}
 
-	pr_cont("%d operations in %d seconds (%ld bytes)\n",
+	tc_printf("%d operations in %d seconds (%ld bytes)\n",
 		bcount, secs, (long)bcount * blen);
 	return 0;
 }
@@ -1068,7 +1155,7 @@ static int test_acipher_cycles(struct ablkcipher_request *req, int enc,
 
 out:
 	if (ret == 0)
-		pr_cont("1 operation in %lu cycles (%d bytes)\n",
+		tc_printf("1 operation in %lu cycles (%d bytes)\n",
 			(cycles + 4) / 8, blen);
 
 	return ret;
@@ -1097,17 +1184,17 @@ static void test_acipher_speed(const char *algo, int enc, unsigned int secs,
 	tfm = crypto_alloc_ablkcipher(algo, 0, 0);
 
 	if (IS_ERR(tfm)) {
-		pr_err("failed to load transform for %s: %ld\n", algo,
+		tc_printf("failed to load transform for %s: %ld\n", algo,
 		       PTR_ERR(tfm));
 		return;
 	}
 
-	pr_info("\ntesting speed of async %s (%s) %s\n", algo,
+	tc_printf("\ntesting speed of async %s (%s) %s\n", algo,
 			get_driver_name(crypto_ablkcipher, tfm), e);
 
 	req = ablkcipher_request_alloc(tfm, GFP_KERNEL);
 	if (!req) {
-		pr_err("tcrypt: skcipher: Failed to allocate request for %s\n",
+		tc_printf("tcrypt: skcipher: Failed to allocate request for %s\n",
 		       algo);
 		goto out;
 	}
@@ -1123,13 +1210,13 @@ static void test_acipher_speed(const char *algo, int enc, unsigned int secs,
 			struct scatterlist sg[TVMEMSIZE];
 
 			if ((*keysize + *b_size) > TVMEMSIZE * PAGE_SIZE) {
-				pr_err("template (%u) too big for "
+				tc_printf("template (%u) too big for "
 				       "tvmem (%lu)\n", *keysize + *b_size,
 				       TVMEMSIZE * PAGE_SIZE);
 				goto out_free_req;
 			}
 
-			pr_info("test %u (%d bit key, %d byte blocks): ", i,
+			tc_printf("test %u (%d bit key, %d byte blocks): ", i,
 				*keysize * 8, *b_size);
 
 			memset(tvmem[0], 0xff, PAGE_SIZE);
@@ -1147,7 +1234,7 @@ static void test_acipher_speed(const char *algo, int enc, unsigned int secs,
 
 			ret = crypto_ablkcipher_setkey(tfm, key, *keysize);
 			if (ret) {
-				pr_err("setkey() failed flags=%x\n",
+				tc_printf("setkey() failed flags=%x\n",
 					crypto_ablkcipher_get_flags(tfm));
 				goto out_free_req;
 			}
@@ -1186,7 +1273,7 @@ static void test_acipher_speed(const char *algo, int enc, unsigned int secs,
 							  *b_size);
 
 			if (ret) {
-				pr_err("%s() failed flags=%x\n", e,
+				tc_printf("%s() failed flags=%x\n", e,
 					crypto_ablkcipher_get_flags(tfm));
 				break;
 			}
@@ -1207,8 +1294,8 @@ static void test_available(void)
 	char **name = check;
 
 	while (*name) {
-		printk("alg %s ", *name);
-		printk(crypto_has_alg(*name, 0, 0) ?
+		tc_printf("alg %s ", *name);
+		tc_printf(crypto_has_alg(*name, 0, 0) ?
 		       "found\n" : "not found\n");
 		name++;
 	}
@@ -1225,17 +1312,10 @@ static inline int tcrypt_test(const char *alg)
 	return ret;
 }
 
-static int do_test(int m)
+static int do_test(const char *test)
 {
-	int i;
-	int ret = 0;
-
-	switch (m) {
-	case 0:
-		for (i = 1; i < 200; i++)
-			ret += do_test(i);
-		break;
 
+#if 0
 	case 1:
 		ret += tcrypt_test("md5");
 		break;
@@ -1559,7 +1639,9 @@ static int do_test(int m)
 	case 190:
 		ret += tcrypt_test("authenc(hmac(sha512),cbc(des3_ede))");
 		break;
-	case 200:
+#endif
+
+	if (strcmp(test, "cipher_speed_aes") == 0) {
 		test_cipher_speed("ecb(aes)", ENCRYPT, sec, NULL, 0,
 				speed_template_16_24_32);
 		test_cipher_speed("ecb(aes)", DECRYPT, sec, NULL, 0,
@@ -1580,9 +1662,9 @@ static int do_test(int m)
 				speed_template_16_24_32);
 		test_cipher_speed("ctr(aes)", DECRYPT, sec, NULL, 0,
 				speed_template_16_24_32);
-		break;
 
-	case 201:
+	} else if (strcmp(test, "cipher_speed_des3_ede") == 0) {
+
 		test_cipher_speed("ecb(des3_ede)", ENCRYPT, sec,
 				des3_speed_template, DES3_SPEED_VECTORS,
 				speed_template_24);
@@ -1601,9 +1683,9 @@ static int do_test(int m)
 		test_cipher_speed("ctr(des3_ede)", DECRYPT, sec,
 				des3_speed_template, DES3_SPEED_VECTORS,
 				speed_template_24);
-		break;
 
-	case 202:
+	} else if (strcmp(test, "cipher_speed_twofish") == 0) {
+
 		test_cipher_speed("ecb(twofish)", ENCRYPT, sec, NULL, 0,
 				speed_template_16_24_32);
 		test_cipher_speed("ecb(twofish)", DECRYPT, sec, NULL, 0,
@@ -1624,9 +1706,9 @@ static int do_test(int m)
 				speed_template_32_48_64);
 		test_cipher_speed("xts(twofish)", DECRYPT, sec, NULL, 0,
 				speed_template_32_48_64);
-		break;
 
-	case 203:
+	} else if (strcmp(test, "cipher_speed_blowfish") == 0) {
+
 		test_cipher_speed("ecb(blowfish)", ENCRYPT, sec, NULL, 0,
 				  speed_template_8_32);
 		test_cipher_speed("ecb(blowfish)", DECRYPT, sec, NULL, 0,
@@ -1639,9 +1721,9 @@ static int do_test(int m)
 				  speed_template_8_32);
 		test_cipher_speed("ctr(blowfish)", DECRYPT, sec, NULL, 0,
 				  speed_template_8_32);
-		break;
 
-	case 204:
+	} else if (strcmp(test, "cipher_speed_des") == 0) {
+
 		test_cipher_speed("ecb(des)", ENCRYPT, sec, NULL, 0,
 				  speed_template_8);
 		test_cipher_speed("ecb(des)", DECRYPT, sec, NULL, 0,
@@ -1650,9 +1732,9 @@ static int do_test(int m)
 				  speed_template_8);
 		test_cipher_speed("cbc(des)", DECRYPT, sec, NULL, 0,
 				  speed_template_8);
-		break;
 
-	case 205:
+	} else if (strcmp(test, "cipher_speed_camellia") == 0) {
+
 		test_cipher_speed("ecb(camellia)", ENCRYPT, sec, NULL, 0,
 				speed_template_16_24_32);
 		test_cipher_speed("ecb(camellia)", DECRYPT, sec, NULL, 0,
@@ -1673,14 +1755,14 @@ static int do_test(int m)
 				speed_template_32_48_64);
 		test_cipher_speed("xts(camellia)", DECRYPT, sec, NULL, 0,
 				speed_template_32_48_64);
-		break;
 
-	case 206:
+	} else if (strcmp(test, "cipher_speed_salsa20") == 0) {
+
 		test_cipher_speed("salsa20", ENCRYPT, sec, NULL, 0,
 				  speed_template_16_32);
-		break;
 
-	case 207:
+	} else if (strcmp(test, "cipher_speed_serpent") == 0) {
+
 		test_cipher_speed("ecb(serpent)", ENCRYPT, sec, NULL, 0,
 				  speed_template_16_32);
 		test_cipher_speed("ecb(serpent)", DECRYPT, sec, NULL, 0,
@@ -1701,14 +1783,14 @@ static int do_test(int m)
 				  speed_template_32_64);
 		test_cipher_speed("xts(serpent)", DECRYPT, sec, NULL, 0,
 				  speed_template_32_64);
-		break;
 
-	case 208:
+	} else if (strcmp(test, "cipher_speed_arc4") == 0) {
+
 		test_cipher_speed("ecb(arc4)", ENCRYPT, sec, NULL, 0,
 				  speed_template_8);
-		break;
 
-	case 209:
+	} else if (strcmp(test, "cipher_speed_cast5") == 0) {
+
 		test_cipher_speed("ecb(cast5)", ENCRYPT, sec, NULL, 0,
 				  speed_template_8_16);
 		test_cipher_speed("ecb(cast5)", DECRYPT, sec, NULL, 0,
@@ -1721,9 +1803,9 @@ static int do_test(int m)
 				  speed_template_8_16);
 		test_cipher_speed("ctr(cast5)", DECRYPT, sec, NULL, 0,
 				  speed_template_8_16);
-		break;
 
-	case 210:
+	} else if (strcmp(test, "cipher_speed_cast6") == 0) {
+
 		test_cipher_speed("ecb(cast6)", ENCRYPT, sec, NULL, 0,
 				  speed_template_16_32);
 		test_cipher_speed("ecb(cast6)", DECRYPT, sec, NULL, 0,
@@ -1744,174 +1826,15 @@ static int do_test(int m)
 				  speed_template_32_64);
 		test_cipher_speed("xts(cast6)", DECRYPT, sec, NULL, 0,
 				  speed_template_32_64);
-		break;
 
-	case 211:
+	} else if (strcmp(test, "aead_speed_aes") == 0) {
+
 		test_aead_speed("rfc4106(gcm(aes))", ENCRYPT, sec,
 				NULL, 0, 16, 8, aead_speed_template_20);
-		break;
-
-	case 300:
-		/* fall through */
-
-	case 301:
-		test_hash_speed("md4", sec, generic_hash_speed_template);
-		if (mode > 300 && mode < 400) break;
-
-	case 302:
-		test_hash_speed("md5", sec, generic_hash_speed_template);
-		if (mode > 300 && mode < 400) break;
-
-	case 303:
-		test_hash_speed("sha1", sec, generic_hash_speed_template);
-		if (mode > 300 && mode < 400) break;
-
-	case 304:
-		test_hash_speed("sha256", sec, generic_hash_speed_template);
-		if (mode > 300 && mode < 400) break;
-
-	case 305:
-		test_hash_speed("sha384", sec, generic_hash_speed_template);
-		if (mode > 300 && mode < 400) break;
 
-	case 306:
-		test_hash_speed("sha512", sec, generic_hash_speed_template);
-		if (mode > 300 && mode < 400) break;
 
-	case 307:
-		test_hash_speed("wp256", sec, generic_hash_speed_template);
-		if (mode > 300 && mode < 400) break;
+	} else if (strcmp(test, "acipher_speed_aes") == 0) {
 
-	case 308:
-		test_hash_speed("wp384", sec, generic_hash_speed_template);
-		if (mode > 300 && mode < 400) break;
-
-	case 309:
-		test_hash_speed("wp512", sec, generic_hash_speed_template);
-		if (mode > 300 && mode < 400) break;
-
-	case 310:
-		test_hash_speed("tgr128", sec, generic_hash_speed_template);
-		if (mode > 300 && mode < 400) break;
-
-	case 311:
-		test_hash_speed("tgr160", sec, generic_hash_speed_template);
-		if (mode > 300 && mode < 400) break;
-
-	case 312:
-		test_hash_speed("tgr192", sec, generic_hash_speed_template);
-		if (mode > 300 && mode < 400) break;
-
-	case 313:
-		test_hash_speed("sha224", sec, generic_hash_speed_template);
-		if (mode > 300 && mode < 400) break;
-
-	case 314:
-		test_hash_speed("rmd128", sec, generic_hash_speed_template);
-		if (mode > 300 && mode < 400) break;
-
-	case 315:
-		test_hash_speed("rmd160", sec, generic_hash_speed_template);
-		if (mode > 300 && mode < 400) break;
-
-	case 316:
-		test_hash_speed("rmd256", sec, generic_hash_speed_template);
-		if (mode > 300 && mode < 400) break;
-
-	case 317:
-		test_hash_speed("rmd320", sec, generic_hash_speed_template);
-		if (mode > 300 && mode < 400) break;
-
-	case 318:
-		test_hash_speed("ghash-generic", sec, hash_speed_template_16);
-		if (mode > 300 && mode < 400) break;
-
-	case 319:
-		test_hash_speed("crc32c", sec, generic_hash_speed_template);
-		if (mode > 300 && mode < 400) break;
-
-	case 320:
-		test_hash_speed("crct10dif", sec, generic_hash_speed_template);
-		if (mode > 300 && mode < 400) break;
-
-	case 399:
-		break;
-
-	case 400:
-		/* fall through */
-
-	case 401:
-		test_ahash_speed("md4", sec, generic_hash_speed_template);
-		if (mode > 400 && mode < 500) break;
-
-	case 402:
-		test_ahash_speed("md5", sec, generic_hash_speed_template);
-		if (mode > 400 && mode < 500) break;
-
-	case 403:
-		test_ahash_speed("sha1", sec, generic_hash_speed_template);
-		if (mode > 400 && mode < 500) break;
-
-	case 404:
-		test_ahash_speed("sha256", sec, generic_hash_speed_template);
-		if (mode > 400 && mode < 500) break;
-
-	case 405:
-		test_ahash_speed("sha384", sec, generic_hash_speed_template);
-		if (mode > 400 && mode < 500) break;
-
-	case 406:
-		test_ahash_speed("sha512", sec, generic_hash_speed_template);
-		if (mode > 400 && mode < 500) break;
-
-	case 407:
-		test_ahash_speed("wp256", sec, generic_hash_speed_template);
-		if (mode > 400 && mode < 500) break;
-
-	case 408:
-		test_ahash_speed("wp384", sec, generic_hash_speed_template);
-		if (mode > 400 && mode < 500) break;
-
-	case 409:
-		test_ahash_speed("wp512", sec, generic_hash_speed_template);
-		if (mode > 400 && mode < 500) break;
-
-	case 410:
-		test_ahash_speed("tgr128", sec, generic_hash_speed_template);
-		if (mode > 400 && mode < 500) break;
-
-	case 411:
-		test_ahash_speed("tgr160", sec, generic_hash_speed_template);
-		if (mode > 400 && mode < 500) break;
-
-	case 412:
-		test_ahash_speed("tgr192", sec, generic_hash_speed_template);
-		if (mode > 400 && mode < 500) break;
-
-	case 413:
-		test_ahash_speed("sha224", sec, generic_hash_speed_template);
-		if (mode > 400 && mode < 500) break;
-
-	case 414:
-		test_ahash_speed("rmd128", sec, generic_hash_speed_template);
-		if (mode > 400 && mode < 500) break;
-
-	case 415:
-		test_ahash_speed("rmd160", sec, generic_hash_speed_template);
-		if (mode > 400 && mode < 500) break;
-
-	case 416:
-		test_ahash_speed("rmd256", sec, generic_hash_speed_template);
-		if (mode > 400 && mode < 500) break;
-
-	case 417:
-		test_ahash_speed("rmd320", sec, generic_hash_speed_template);
-		if (mode > 400 && mode < 500) break;
-
-	case 499:
-		break;
-
-	case 500:
 		test_acipher_speed("ecb(aes)", ENCRYPT, sec, NULL, 0,
 				   speed_template_16_24_32);
 		test_acipher_speed("ecb(aes)", DECRYPT, sec, NULL, 0,
@@ -1944,9 +1867,9 @@ static int do_test(int m)
 				   speed_template_20_28_36);
 		test_acipher_speed("rfc3686(ctr(aes))", DECRYPT, sec, NULL, 0,
 				   speed_template_20_28_36);
-		break;
 
-	case 501:
+	} else if (strcmp(test, "aciper_speed_des3_ede") == 0) {
+
 		test_acipher_speed("ecb(des3_ede)", ENCRYPT, sec,
 				   des3_speed_template, DES3_SPEED_VECTORS,
 				   speed_template_24);
@@ -1971,9 +1894,9 @@ static int do_test(int m)
 		test_acipher_speed("ofb(des3_ede)", DECRYPT, sec,
 				   des3_speed_template, DES3_SPEED_VECTORS,
 				   speed_template_24);
-		break;
 
-	case 502:
+	} else if (strcmp(test, "acipher_speed_des") == 0) {
+
 		test_acipher_speed("ecb(des)", ENCRYPT, sec, NULL, 0,
 				   speed_template_8);
 		test_acipher_speed("ecb(des)", DECRYPT, sec, NULL, 0,
@@ -1990,9 +1913,9 @@ static int do_test(int m)
 				   speed_template_8);
 		test_acipher_speed("ofb(des)", DECRYPT, sec, NULL, 0,
 				   speed_template_8);
-		break;
 
-	case 503:
+	} else if (strcmp(test, "acipher_speed_serpent") == 0) {
+
 		test_acipher_speed("ecb(serpent)", ENCRYPT, sec, NULL, 0,
 				   speed_template_16_32);
 		test_acipher_speed("ecb(serpent)", DECRYPT, sec, NULL, 0,
@@ -2013,9 +1936,9 @@ static int do_test(int m)
 				   speed_template_32_64);
 		test_acipher_speed("xts(serpent)", DECRYPT, sec, NULL, 0,
 				   speed_template_32_64);
-		break;
 
-	case 504:
+	} else if (strcmp(test, "acipher_speed_twofish") == 0) {
+
 		test_acipher_speed("ecb(twofish)", ENCRYPT, sec, NULL, 0,
 				   speed_template_16_24_32);
 		test_acipher_speed("ecb(twofish)", DECRYPT, sec, NULL, 0,
@@ -2036,14 +1959,14 @@ static int do_test(int m)
 				   speed_template_32_48_64);
 		test_acipher_speed("xts(twofish)", DECRYPT, sec, NULL, 0,
 				   speed_template_32_48_64);
-		break;
 
-	case 505:
+	} else if (strcmp(test, "acipher_speed_arc4") == 0) {
+
 		test_acipher_speed("ecb(arc4)", ENCRYPT, sec, NULL, 0,
 				   speed_template_8);
-		break;
 
-	case 506:
+	} else if (strcmp(test, "acipher_speed_cast5") == 0) {
+
 		test_acipher_speed("ecb(cast5)", ENCRYPT, sec, NULL, 0,
 				   speed_template_8_16);
 		test_acipher_speed("ecb(cast5)", DECRYPT, sec, NULL, 0,
@@ -2056,9 +1979,9 @@ static int do_test(int m)
 				   speed_template_8_16);
 		test_acipher_speed("ctr(cast5)", DECRYPT, sec, NULL, 0,
 				   speed_template_8_16);
-		break;
 
-	case 507:
+	} else if (strcmp(test, "acipher_speed_cast6") == 0) {
+
 		test_acipher_speed("ecb(cast6)", ENCRYPT, sec, NULL, 0,
 				   speed_template_16_32);
 		test_acipher_speed("ecb(cast6)", DECRYPT, sec, NULL, 0,
@@ -2079,9 +2002,9 @@ static int do_test(int m)
 				   speed_template_32_64);
 		test_acipher_speed("xts(cast6)", DECRYPT, sec, NULL, 0,
 				   speed_template_32_64);
-		break;
 
-	case 508:
+	} else if (strcmp(test, "acipher_speed_camellia") == 0) {
+
 		test_acipher_speed("ecb(camellia)", ENCRYPT, sec, NULL, 0,
 				   speed_template_16_32);
 		test_acipher_speed("ecb(camellia)", DECRYPT, sec, NULL, 0,
@@ -2102,9 +2025,9 @@ static int do_test(int m)
 				   speed_template_32_64);
 		test_acipher_speed("xts(camellia)", DECRYPT, sec, NULL, 0,
 				   speed_template_32_64);
-		break;
 
-	case 509:
+	} else if (strcmp(test, "acipher_speed_blowfish") == 0) {
+
 		test_acipher_speed("ecb(blowfish)", ENCRYPT, sec, NULL, 0,
 				   speed_template_8_32);
 		test_acipher_speed("ecb(blowfish)", DECRYPT, sec, NULL, 0,
@@ -2117,77 +2040,341 @@ static int do_test(int m)
 				   speed_template_8_32);
 		test_acipher_speed("ctr(blowfish)", DECRYPT, sec, NULL, 0,
 				   speed_template_8_32);
-		break;
 
-	case 1000:
-		test_available();
-		break;
-	}
+	} else
+		return 0;
+
+	return 1;
 
-	return ret;
 }
 
+char *fixed_tests[] = {
+	/* generated with
+	 * sed -n 's/\t\(} else \)\?if (strcmp(test, \(".*"\)) == 0) {/\t\2,/p' crypto/tcrypt.c
+	 */
+	"cipher_speed_aes",
+	"cipher_speed_des3_ede",
+	"cipher_speed_twofish",
+	"cipher_speed_blowfish",
+	"cipher_speed_des",
+	"cipher_speed_camellia",
+	"cipher_speed_salsa20",
+	"cipher_speed_serpent",
+	"cipher_speed_arc4",
+	"cipher_speed_cast5",
+	"cipher_speed_cast6",
+	"aead_speed_aes",
+	"acipher_speed_aes",
+	"aciper_speed_des3_ede",
+	"acipher_speed_des",
+	"acipher_speed_serpent",
+	"acipher_speed_twofish",
+	"acipher_speed_arc4",
+	"acipher_speed_cast5",
+	"acipher_speed_cast6",
+	"acipher_speed_camellia",
+	"acipher_speed_blowfish",
+};
+
 static int do_alg_test(const char *alg, u32 type, u32 mask)
 {
 	return crypto_has_alg(alg, type, mask ?: CRYPTO_ALG_TYPE_MASK) ?
 	       0 : -ENOENT;
 }
 
+
+int tcrypt_open_generic(struct inode *inode, struct file *filp)
+{
+	filp->private_data = inode->i_private;
+	return 0;
+}
+
+static ssize_t
+tcrypt_sec_read(struct file *filp, char __user *ubuf,
+				 size_t cnt, loff_t *ppos)
+{
+	char buf[64];
+	int r;
+
+	r = scnprintf(buf, sizeof(buf), "%u\n", sec);
+
+	return simple_read_from_buffer(ubuf, cnt, ppos, buf, r);
+}
+
+
+static ssize_t
+tcrypt_sec_write(struct file *filp, const char __user *ubuf,
+				  size_t cnt, loff_t *ppos)
+{
+	int ret;
+
+	ret = kstrtouint_from_user(ubuf, cnt, 10, &sec);
+	if (ret)
+		return ret;
+
+	*ppos += cnt;
+
+	return cnt;
+}
+
+static const struct file_operations tcrypt_sec_fops = {
+	.read		= tcrypt_sec_read,
+	.write		= tcrypt_sec_write,
+};
+
+
+static void
+clear_buffer(void)
+{
+	size_t i, stop;
+
+	if (tcrypt_data.cur_stop == tcrypt_data.cur_start)
+		return;
+
+	mutex_lock_interruptible(&tcrypt_output_lock);
+	if (tcrypt_data.cur_stop < tcrypt_data.cur_start)
+		stop = tcrypt_data.cur_stop + OUTPUT_BUFFER_LINES;
+	else
+		stop = tcrypt_data.cur_stop;
+
+	for (i = tcrypt_data.cur_start; i < stop; ++i)
+		kfree(tcrypt_data.output[i % OUTPUT_BUFFER_LINES]);
+
+	tcrypt_data.cur_start = 0;
+	tcrypt_data.cur_stop = 0;
+	mutex_unlock(&tcrypt_output_lock);
+}
+
+static int launch_test(const char *buf)
+{
+
+	size_t ret = -EINVAL;
+	int i;
+
+	if (strcmp(buf, "list") == 0) {
+		mutex_lock_interruptible(&tcrypt_output_lock);
+		tc_printf_unlock("hash_speed_<name_of_hash>\n");
+		tc_printf_unlock("ahash_speed_<name_of_hash>\n");
+		for (i = 0; i < ARRAY_SIZE(fixed_tests); i++) {
+			tc_printf_unlock("%s\n", fixed_tests[i]);
+		}
+
+		mutex_unlock(&tcrypt_output_lock);
+		return 0;
+	} else if (strcmp(buf, "clear") == 0) {
+		clear_buffer();
+		return 0;
+	} else if (memcmp(buf, "hash_speed_", 11) == 0) {
+		buf += 11;
+		if (!crypto_has_hash(buf, 0, 0)) {
+			tc_printf("Hash %s does not exist.\n", buf);
+			return ret;
+		}
+
+		if (strcmp(buf, "ghash-generic") == 0)
+			test_hash_speed(buf, sec,
+				generic_hash_speed_template, 16);
+		else
+			test_hash_speed(buf, sec,
+				generic_hash_speed_template, 0);
+
+		return 0;
+	} else if (memcmp(buf, "ahash_speed_", 12) == 0) {
+		buf += 12;
+		if (!crypto_has_hash(buf, 0, CRYPTO_ALG_ASYNC)) {
+			tc_printf("Hash %s does not exist.\n", buf);
+			return ret;
+		}
+
+		test_ahash_speed(buf, sec, generic_hash_speed_template);
+		return 0;
+	} else if (do_test(buf))
+		return 0;
+
+
+	return ret;
+}
+
+static ssize_t
+tcrypt_set_command_write(struct file *filp, const char __user *ubuf,
+			size_t cnt, loff_t *ppos)
+{
+	char buf[COMMAND_BUFFER_SIZE + 1];
+	int i;
+	size_t ret;
+	int err;
+
+	ret = cnt;
+
+	if (cnt > COMMAND_BUFFER_SIZE)
+		cnt = COMMAND_BUFFER_SIZE;
+
+	if (copy_from_user(&buf, ubuf, cnt))
+		return -EFAULT;
+
+	buf[cnt] = 0;
+
+	/* strip ending whitespace. */
+	for (i = cnt - 1; i > 0 && isspace(buf[i]); i--)
+		buf[i] = 0;
+
+	err = launch_test(buf);
+	if (err < 0)
+		return err;
+
+	*ppos += ret;
+
+	return ret;
+}
+
+static const struct file_operations set_tcrypt_fops = {
+	.write		= tcrypt_set_command_write,
+	.llseek		= generic_file_llseek,
+};
+
+
+static void *
+s_start(struct seq_file *m, loff_t *pos)
+{
+	size_t *ptr;
+
+	mutex_lock_interruptible(&tcrypt_output_lock);
+	if (*pos >= get_num_elements())
+		return NULL;
+
+	ptr = kmalloc(sizeof(size_t), GFP_KERNEL);
+	if (!ptr)
+		return NULL;
+
+	*ptr = *pos;
+	return ptr;
+}
+
+static void *
+s_next(struct seq_file *m, void *v, loff_t *pos)
+{
+	size_t *ptr = v;
+
+	++*pos;
+	if (*pos >= get_num_elements())
+		return NULL;
+
+	*ptr = *pos;
+	return ptr;
+}
+
+static int
+s_show(struct seq_file *m, void *v)
+{
+	size_t *ptr = v;
+	size_t temp = (tcrypt_data.cur_start + *ptr) % OUTPUT_BUFFER_LINES;
+
+	seq_printf(m, "%s", tcrypt_data.output[temp]);
+	return 0;
+
+}
+
+static void
+s_stop(struct seq_file *m, void *p)
+{
+	kfree(p);
+	mutex_unlock(&tcrypt_output_lock);
+}
+
+
+
+static const struct seq_operations tcrypt_seq_output_ops = {
+	.start		= s_start,
+	.next		= s_next,
+	.stop		= s_stop,
+	.show		= s_show,
+};
+
+
+static int
+tcrypt_get_output_open(struct inode *inode, struct file *file)
+{
+
+	return seq_open(file, &tcrypt_seq_output_ops);
+}
+
+
+static const struct file_operations show_tcrypt_fops = {
+	.open		= tcrypt_get_output_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
+
 static int __init tcrypt_mod_init(void)
 {
-	int err = -ENOMEM;
 	int i;
 
+	struct dentry *temp_dentry;
+
+	tcrypt_data.cur_start = 0;
+	tcrypt_data.cur_stop = 0;
+
+	d_basetcrypt = debugfs_create_dir("tcrypto", NULL);
+	if (!d_basetcrypt)
+		goto err_free;
+
+	readme_blob.data = read_str;
+	readme_blob.size = strlen(read_str);
+	temp_dentry = debugfs_create_blob("README", 0444, d_basetcrypt, &readme_blob);
+	if (!temp_dentry)
+		goto err_free;
+
+	temp_dentry = debugfs_create_file("command", 0644, d_basetcrypt,
+						NULL, &set_tcrypt_fops);
+	if (!temp_dentry)
+		goto err_free;
+
+	temp_dentry = debugfs_create_file("output", 0644, d_basetcrypt,
+						NULL, &show_tcrypt_fops);
+	if (!temp_dentry)
+		goto err_free;
+
+	temp_dentry = debugfs_create_file("seconds", 0644, d_basetcrypt,
+						NULL, &tcrypt_sec_fops);
+	if (!temp_dentry)
+		goto err_free;
+
+
 	for (i = 0; i < TVMEMSIZE; i++) {
 		tvmem[i] = (void *)__get_free_page(GFP_KERNEL);
 		if (!tvmem[i])
-			goto err_free_tv;
-	}
-
-	if (alg)
-		err = do_alg_test(alg, type, mask);
-	else
-		err = do_test(mode);
-
-	if (err) {
-		printk(KERN_ERR "tcrypt: one or more tests failed!\n");
-		goto err_free_tv;
+			goto err_free;
 	}
 
-	/* We intentionaly return -EAGAIN to prevent keeping the module,
-	 * unless we're running in fips mode. It does all its work from
-	 * init() and doesn't offer any runtime functionality, but in
-	 * the fips case, checking for a successful load is helpful.
-	 * => we don't need it in the memory, do we?
-	 *                                        -- mludvig
-	 */
-	if (!fips_enabled)
-		err = -EAGAIN;
+	return 0;
 
-err_free_tv:
+err_free:
+	pr_err("tcrypt: Unable to allocate memory (init)\n");
 	for (i = 0; i < TVMEMSIZE && tvmem[i]; i++)
 		free_page((unsigned long)tvmem[i]);
+	if (d_basetcrypt)
+		debugfs_remove_recursive(d_basetcrypt);
 
-	return err;
+	return -ENOMEM;
 }
 
 /*
- * If an init function is provided, an exit function must also be provided
- * to allow module unload.
+ * Release debugfs and tvmem
  */
-static void __exit tcrypt_mod_fini(void) { }
+static void __exit tcrypt_mod_fini(void)
+{
+	int i;
+
+	debugfs_remove_recursive(d_basetcrypt);
+	clear_buffer();
+	for (i = 0; i < TVMEMSIZE && tvmem[i]; i++)
+		free_page((unsigned long)tvmem[i]);
+}
 
 module_init(tcrypt_mod_init);
 module_exit(tcrypt_mod_fini);
 
-module_param(alg, charp, 0);
-module_param(type, uint, 0);
-module_param(mask, uint, 0);
-module_param(mode, int, 0);
-module_param(sec, uint, 0);
-MODULE_PARM_DESC(sec, "Length in seconds of speed tests "
-		      "(defaults to zero which uses CPU cycles instead)");
-
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("Quick & dirty crypto testing module");
 MODULE_AUTHOR("James Morris <jmorris@intercode.com.au>");
diff --git a/crypto/tcrypt.h b/crypto/tcrypt.h
index 6c7e21a..12d7400 100644
--- a/crypto/tcrypt.h
+++ b/crypto/tcrypt.h
@@ -98,32 +98,4 @@ static struct hash_speed generic_hash_speed_template[] = {
 	{  .blen = 0,	.plen = 0, }
 };
 
-static struct hash_speed hash_speed_template_16[] = {
-	{ .blen = 16,	.plen = 16,	.klen = 16, },
-	{ .blen = 64,	.plen = 16,	.klen = 16, },
-	{ .blen = 64,	.plen = 64,	.klen = 16, },
-	{ .blen = 256,	.plen = 16,	.klen = 16, },
-	{ .blen = 256,	.plen = 64,	.klen = 16, },
-	{ .blen = 256,	.plen = 256,	.klen = 16, },
-	{ .blen = 1024,	.plen = 16,	.klen = 16, },
-	{ .blen = 1024,	.plen = 256,	.klen = 16, },
-	{ .blen = 1024,	.plen = 1024,	.klen = 16, },
-	{ .blen = 2048,	.plen = 16,	.klen = 16, },
-	{ .blen = 2048,	.plen = 256,	.klen = 16, },
-	{ .blen = 2048,	.plen = 1024,	.klen = 16, },
-	{ .blen = 2048,	.plen = 2048,	.klen = 16, },
-	{ .blen = 4096,	.plen = 16,	.klen = 16, },
-	{ .blen = 4096,	.plen = 256,	.klen = 16, },
-	{ .blen = 4096,	.plen = 1024,	.klen = 16, },
-	{ .blen = 4096,	.plen = 4096,	.klen = 16, },
-	{ .blen = 8192,	.plen = 16,	.klen = 16, },
-	{ .blen = 8192,	.plen = 256,	.klen = 16, },
-	{ .blen = 8192,	.plen = 1024,	.klen = 16, },
-	{ .blen = 8192,	.plen = 4096,	.klen = 16, },
-	{ .blen = 8192,	.plen = 8192,	.klen = 16, },
-
-	/* End marker */
-	{  .blen = 0,	.plen = 0,	.klen = 0, }
-};
-
 #endif	/* _CRYPTO_TCRYPT_H */
-- 
1.7.9.5
