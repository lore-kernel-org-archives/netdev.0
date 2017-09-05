Return-Path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:39814 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751036AbdIEMnN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 5 Sep 2017 08:43:13 -0400
From: Gilad Ben-Yossef <gilad@benyossef.com>
To: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        Jonathan Corbet <corbet@lwn.net>,
        David Howells <dhowells@redhat.com>,
        Tom Lendacky <thomas.lendacky@amd.com>,
        Gary Hook <gary.hook@amd.com>,
        Boris Brezillon <boris.brezillon@free-electrons.com>,
        Arnaud Ebalard <arno@natisbad.org>,
        Matthias Brugger <matthias.bgg@gmail.com>,
        Alasdair Kergon <agk@redhat.com>,
        Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com,
        Shaohua Li <shli@kernel.org>, Steve French <sfrench@samba.org>,
        "Theodore Y. Ts'o" <tytso@mit.edu>,
        Jaegeuk Kim <jaegeuk@kernel.org>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Mimi Zohar <zohar@linux.vnet.ibm.com>,
        Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
        James Morris <james.l.morris@oracle.com>,
        "Serge E. Hallyn" <serge@hallyn.com>, linux-crypto@vger.kernel.org,
        linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
        keyrings@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-mediatek@lists.infradead.org, linux-raid@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-fscrypt@vger.kernel.org, netdev@vger.kernel.org,
        linux-ima-devel@lists.sourceforge.net,
        linux-ima-user@lists.sourceforge.net,
        linux-security-module@vger.kernel.org
Cc: Ofir Drang <ofir.drang@arm.com>
Subject: [PATCH v8 16/20] crypto: tcrypt: move to generic async completion
Date: Tue,  5 Sep 2017 15:38:55 +0300
Message-Id: <1504615144-29770-17-git-send-email-gilad@benyossef.com>
In-Reply-To: <1504615144-29770-1-git-send-email-gilad@benyossef.com>
References: <1504615144-29770-1-git-send-email-gilad@benyossef.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcrypt starts several async crypto ops and  waits for their completions.
Move it over to generic code doing the same.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
---
 crypto/tcrypt.c | 84 +++++++++++++++++----------------------------------------
 1 file changed, 25 insertions(+), 59 deletions(-)

diff --git a/crypto/tcrypt.c b/crypto/tcrypt.c
index 0022a18..802aa81 100644
--- a/crypto/tcrypt.c
+++ b/crypto/tcrypt.c
@@ -79,34 +79,11 @@ static char *check[] = {
 	NULL
 };
 
-struct tcrypt_result {
-	struct completion completion;
-	int err;
-};
-
-static void tcrypt_complete(struct crypto_async_request *req, int err)
-{
-	struct tcrypt_result *res = req->data;
-
-	if (err == -EINPROGRESS)
-		return;
-
-	res->err = err;
-	complete(&res->completion);
-}
-
 static inline int do_one_aead_op(struct aead_request *req, int ret)
 {
-	if (ret == -EINPROGRESS || ret == -EBUSY) {
-		struct tcrypt_result *tr = req->base.data;
+	struct crypto_wait *wait = req->base.data;
 
-		ret = wait_for_completion_interruptible(&tr->completion);
-		if (!ret)
-			ret = tr->err;
-		reinit_completion(&tr->completion);
-	}
-
-	return ret;
+	return crypto_wait_req(ret, wait);
 }
 
 static int test_aead_jiffies(struct aead_request *req, int enc,
@@ -248,7 +225,7 @@ static void test_aead_speed(const char *algo, int enc, unsigned int secs,
 	char *axbuf[XBUFSIZE];
 	unsigned int *b_size;
 	unsigned int iv_len;
-	struct tcrypt_result result;
+	struct crypto_wait wait;
 
 	iv = kzalloc(MAX_IVLEN, GFP_KERNEL);
 	if (!iv)
@@ -284,7 +261,7 @@ static void test_aead_speed(const char *algo, int enc, unsigned int secs,
 		goto out_notfm;
 	}
 
-	init_completion(&result.completion);
+	crypto_init_wait(&wait);
 	printk(KERN_INFO "\ntesting speed of %s (%s) %s\n", algo,
 			get_driver_name(crypto_aead, tfm), e);
 
@@ -296,7 +273,7 @@ static void test_aead_speed(const char *algo, int enc, unsigned int secs,
 	}
 
 	aead_request_set_callback(req, CRYPTO_TFM_REQ_MAY_BACKLOG,
-				  tcrypt_complete, &result);
+				  crypto_req_done, &wait);
 
 	i = 0;
 	do {
@@ -397,21 +374,16 @@ static void test_hash_sg_init(struct scatterlist *sg)
 
 static inline int do_one_ahash_op(struct ahash_request *req, int ret)
 {
-	if (ret == -EINPROGRESS || ret == -EBUSY) {
-		struct tcrypt_result *tr = req->base.data;
+	struct crypto_wait *wait = req->base.data;
 
-		wait_for_completion(&tr->completion);
-		reinit_completion(&tr->completion);
-		ret = tr->err;
-	}
-	return ret;
+	return crypto_wait_req(ret, wait);
 }
 
 struct test_mb_ahash_data {
 	struct scatterlist sg[TVMEMSIZE];
 	char result[64];
 	struct ahash_request *req;
-	struct tcrypt_result tresult;
+	struct crypto_wait wait;
 	char *xbuf[XBUFSIZE];
 };
 
@@ -440,7 +412,7 @@ static void test_mb_ahash_speed(const char *algo, unsigned int sec,
 		if (testmgr_alloc_buf(data[i].xbuf))
 			goto out;
 
-		init_completion(&data[i].tresult.completion);
+		crypto_init_wait(&data[i].wait);
 
 		data[i].req = ahash_request_alloc(tfm, GFP_KERNEL);
 		if (!data[i].req) {
@@ -449,8 +421,8 @@ static void test_mb_ahash_speed(const char *algo, unsigned int sec,
 			goto out;
 		}
 
-		ahash_request_set_callback(data[i].req, 0,
-					   tcrypt_complete, &data[i].tresult);
+		ahash_request_set_callback(data[i].req, 0, crypto_req_done,
+					   &data[i].wait);
 		test_hash_sg_init(data[i].sg);
 	}
 
@@ -492,16 +464,16 @@ static void test_mb_ahash_speed(const char *algo, unsigned int sec,
 			if (ret)
 				break;
 
-			complete(&data[k].tresult.completion);
-			data[k].tresult.err = 0;
+			crypto_req_done(&data[k].req->base, 0);
 		}
 
 		for (j = 0; j < k; j++) {
-			struct tcrypt_result *tr = &data[j].tresult;
+			struct crypto_wait *wait = &data[j].wait;
+			int wait_ret;
 
-			wait_for_completion(&tr->completion);
-			if (tr->err)
-				ret = tr->err;
+			wait_ret = crypto_wait_req(-EINPROGRESS, wait);
+			if (wait_ret)
+				ret = wait_ret;
 		}
 
 		end = get_cycles();
@@ -679,7 +651,7 @@ static void test_ahash_speed_common(const char *algo, unsigned int secs,
 				    struct hash_speed *speed, unsigned mask)
 {
 	struct scatterlist sg[TVMEMSIZE];
-	struct tcrypt_result tresult;
+	struct crypto_wait wait;
 	struct ahash_request *req;
 	struct crypto_ahash *tfm;
 	char *output;
@@ -708,9 +680,9 @@ static void test_ahash_speed_common(const char *algo, unsigned int secs,
 		goto out;
 	}
 
-	init_completion(&tresult.completion);
+	crypto_init_wait(&wait);
 	ahash_request_set_callback(req, CRYPTO_TFM_REQ_MAY_BACKLOG,
-				   tcrypt_complete, &tresult);
+				   crypto_req_done, &wait);
 
 	output = kmalloc(MAX_DIGEST_SIZE, GFP_KERNEL);
 	if (!output)
@@ -765,15 +737,9 @@ static void test_hash_speed(const char *algo, unsigned int secs,
 
 static inline int do_one_acipher_op(struct skcipher_request *req, int ret)
 {
-	if (ret == -EINPROGRESS || ret == -EBUSY) {
-		struct tcrypt_result *tr = req->base.data;
-
-		wait_for_completion(&tr->completion);
-		reinit_completion(&tr->completion);
-		ret = tr->err;
-	}
+	struct crypto_wait *wait = req->base.data;
 
-	return ret;
+	return crypto_wait_req(ret, wait);
 }
 
 static int test_acipher_jiffies(struct skcipher_request *req, int enc,
@@ -853,7 +819,7 @@ static void test_skcipher_speed(const char *algo, int enc, unsigned int secs,
 				unsigned int tcount, u8 *keysize, bool async)
 {
 	unsigned int ret, i, j, k, iv_len;
-	struct tcrypt_result tresult;
+	struct crypto_wait wait;
 	const char *key;
 	char iv[128];
 	struct skcipher_request *req;
@@ -866,7 +832,7 @@ static void test_skcipher_speed(const char *algo, int enc, unsigned int secs,
 	else
 		e = "decryption";
 
-	init_completion(&tresult.completion);
+	crypto_init_wait(&wait);
 
 	tfm = crypto_alloc_skcipher(algo, 0, async ? 0 : CRYPTO_ALG_ASYNC);
 
@@ -887,7 +853,7 @@ static void test_skcipher_speed(const char *algo, int enc, unsigned int secs,
 	}
 
 	skcipher_request_set_callback(req, CRYPTO_TFM_REQ_MAY_BACKLOG,
-				      tcrypt_complete, &tresult);
+				      crypto_req_done, &wait);
 
 	i = 0;
 	do {
-- 
2.1.4
