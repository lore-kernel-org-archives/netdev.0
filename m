Return-Path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:39516 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751149AbdIEMmC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 5 Sep 2017 08:42:02 -0400
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
Subject: [PATCH v8 11/20] crypto: move testmgr to generic async completion
Date: Tue,  5 Sep 2017 15:38:50 +0300
Message-Id: <1504615144-29770-12-git-send-email-gilad@benyossef.com>
In-Reply-To: <1504615144-29770-1-git-send-email-gilad@benyossef.com>
References: <1504615144-29770-1-git-send-email-gilad@benyossef.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

testmgr is starting async. crypto ops and waiting for them to complete.
Move it over to generic code doing the same.

This also provides a test of the generic crypto async. wait code.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
---
 crypto/testmgr.c | 204 ++++++++++++++++++-------------------------------------
 1 file changed, 66 insertions(+), 138 deletions(-)

diff --git a/crypto/testmgr.c b/crypto/testmgr.c
index 8a124d3..af968f4 100644
--- a/crypto/testmgr.c
+++ b/crypto/testmgr.c
@@ -76,11 +76,6 @@ int alg_test(const char *driver, const char *alg, u32 type, u32 mask)
 #define ENCRYPT 1
 #define DECRYPT 0
 
-struct tcrypt_result {
-	struct completion completion;
-	int err;
-};
-
 struct aead_test_suite {
 	struct {
 		const struct aead_testvec *vecs;
@@ -155,17 +150,6 @@ static void hexdump(unsigned char *buf, unsigned int len)
 			buf, len, false);
 }
 
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
 static int testmgr_alloc_buf(char *buf[XBUFSIZE])
 {
 	int i;
@@ -193,20 +177,10 @@ static void testmgr_free_buf(char *buf[XBUFSIZE])
 		free_page((unsigned long)buf[i]);
 }
 
-static int wait_async_op(struct tcrypt_result *tr, int ret)
-{
-	if (ret == -EINPROGRESS || ret == -EBUSY) {
-		wait_for_completion(&tr->completion);
-		reinit_completion(&tr->completion);
-		ret = tr->err;
-	}
-	return ret;
-}
-
 static int ahash_partial_update(struct ahash_request **preq,
 	struct crypto_ahash *tfm, const struct hash_testvec *template,
 	void *hash_buff, int k, int temp, struct scatterlist *sg,
-	const char *algo, char *result, struct tcrypt_result *tresult)
+	const char *algo, char *result, struct crypto_wait *wait)
 {
 	char *state;
 	struct ahash_request *req;
@@ -236,7 +210,7 @@ static int ahash_partial_update(struct ahash_request **preq,
 	}
 	ahash_request_set_callback(req,
 		CRYPTO_TFM_REQ_MAY_BACKLOG,
-		tcrypt_complete, tresult);
+		crypto_req_done, wait);
 
 	memcpy(hash_buff, template->plaintext + temp,
 		template->tap[k]);
@@ -247,7 +221,7 @@ static int ahash_partial_update(struct ahash_request **preq,
 		pr_err("alg: hash: Failed to import() for %s\n", algo);
 		goto out;
 	}
-	ret = wait_async_op(tresult, crypto_ahash_update(req));
+	ret = crypto_wait_req(crypto_ahash_update(req), wait);
 	if (ret)
 		goto out;
 	*preq = req;
@@ -272,7 +246,7 @@ static int __test_hash(struct crypto_ahash *tfm,
 	char *result;
 	char *key;
 	struct ahash_request *req;
-	struct tcrypt_result tresult;
+	struct crypto_wait wait;
 	void *hash_buff;
 	char *xbuf[XBUFSIZE];
 	int ret = -ENOMEM;
@@ -286,7 +260,7 @@ static int __test_hash(struct crypto_ahash *tfm,
 	if (testmgr_alloc_buf(xbuf))
 		goto out_nobuf;
 
-	init_completion(&tresult.completion);
+	crypto_init_wait(&wait);
 
 	req = ahash_request_alloc(tfm, GFP_KERNEL);
 	if (!req) {
@@ -295,7 +269,7 @@ static int __test_hash(struct crypto_ahash *tfm,
 		goto out_noreq;
 	}
 	ahash_request_set_callback(req, CRYPTO_TFM_REQ_MAY_BACKLOG,
-				   tcrypt_complete, &tresult);
+				   crypto_req_done, &wait);
 
 	j = 0;
 	for (i = 0; i < tcount; i++) {
@@ -335,26 +309,26 @@ static int __test_hash(struct crypto_ahash *tfm,
 
 		ahash_request_set_crypt(req, sg, result, template[i].psize);
 		if (use_digest) {
-			ret = wait_async_op(&tresult, crypto_ahash_digest(req));
+			ret = crypto_wait_req(crypto_ahash_digest(req), &wait);
 			if (ret) {
 				pr_err("alg: hash: digest failed on test %d "
 				       "for %s: ret=%d\n", j, algo, -ret);
 				goto out;
 			}
 		} else {
-			ret = wait_async_op(&tresult, crypto_ahash_init(req));
+			ret = crypto_wait_req(crypto_ahash_init(req), &wait);
 			if (ret) {
 				pr_err("alg: hash: init failed on test %d "
 				       "for %s: ret=%d\n", j, algo, -ret);
 				goto out;
 			}
-			ret = wait_async_op(&tresult, crypto_ahash_update(req));
+			ret = crypto_wait_req(crypto_ahash_update(req), &wait);
 			if (ret) {
 				pr_err("alg: hash: update failed on test %d "
 				       "for %s: ret=%d\n", j, algo, -ret);
 				goto out;
 			}
-			ret = wait_async_op(&tresult, crypto_ahash_final(req));
+			ret = crypto_wait_req(crypto_ahash_final(req), &wait);
 			if (ret) {
 				pr_err("alg: hash: final failed on test %d "
 				       "for %s: ret=%d\n", j, algo, -ret);
@@ -420,22 +394,10 @@ static int __test_hash(struct crypto_ahash *tfm,
 		}
 
 		ahash_request_set_crypt(req, sg, result, template[i].psize);
-		ret = crypto_ahash_digest(req);
-		switch (ret) {
-		case 0:
-			break;
-		case -EINPROGRESS:
-		case -EBUSY:
-			wait_for_completion(&tresult.completion);
-			reinit_completion(&tresult.completion);
-			ret = tresult.err;
-			if (!ret)
-				break;
-			/* fall through */
-		default:
-			printk(KERN_ERR "alg: hash: digest failed "
-			       "on chunking test %d for %s: "
-			       "ret=%d\n", j, algo, -ret);
+		ret = crypto_wait_req(crypto_ahash_digest(req), &wait);
+		if (ret) {
+			pr_err("alg: hash: digest failed on chunking test %d for %s: ret=%d\n",
+			       j, algo, -ret);
 			goto out;
 		}
 
@@ -486,13 +448,13 @@ static int __test_hash(struct crypto_ahash *tfm,
 		}
 
 		ahash_request_set_crypt(req, sg, result, template[i].tap[0]);
-		ret = wait_async_op(&tresult, crypto_ahash_init(req));
+		ret = crypto_wait_req(crypto_ahash_init(req), &wait);
 		if (ret) {
 			pr_err("alg: hash: init failed on test %d for %s: ret=%d\n",
 				j, algo, -ret);
 			goto out;
 		}
-		ret = wait_async_op(&tresult, crypto_ahash_update(req));
+		ret = crypto_wait_req(crypto_ahash_update(req), &wait);
 		if (ret) {
 			pr_err("alg: hash: update failed on test %d for %s: ret=%d\n",
 				j, algo, -ret);
@@ -503,7 +465,7 @@ static int __test_hash(struct crypto_ahash *tfm,
 		for (k = 1; k < template[i].np; k++) {
 			ret = ahash_partial_update(&req, tfm, &template[i],
 				hash_buff, k, temp, &sg[0], algo, result,
-				&tresult);
+				&wait);
 			if (ret) {
 				pr_err("alg: hash: partial update failed on test %d for %s: ret=%d\n",
 					j, algo, -ret);
@@ -511,7 +473,7 @@ static int __test_hash(struct crypto_ahash *tfm,
 			}
 			temp += template[i].tap[k];
 		}
-		ret = wait_async_op(&tresult, crypto_ahash_final(req));
+		ret = crypto_wait_req(crypto_ahash_final(req), &wait);
 		if (ret) {
 			pr_err("alg: hash: final failed on test %d for %s: ret=%d\n",
 				j, algo, -ret);
@@ -580,7 +542,7 @@ static int __test_aead(struct crypto_aead *tfm, int enc,
 	struct scatterlist *sg;
 	struct scatterlist *sgout;
 	const char *e, *d;
-	struct tcrypt_result result;
+	struct crypto_wait wait;
 	unsigned int authsize, iv_len;
 	void *input;
 	void *output;
@@ -619,7 +581,7 @@ static int __test_aead(struct crypto_aead *tfm, int enc,
 	else
 		e = "decryption";
 
-	init_completion(&result.completion);
+	crypto_init_wait(&wait);
 
 	req = aead_request_alloc(tfm, GFP_KERNEL);
 	if (!req) {
@@ -629,7 +591,7 @@ static int __test_aead(struct crypto_aead *tfm, int enc,
 	}
 
 	aead_request_set_callback(req, CRYPTO_TFM_REQ_MAY_BACKLOG,
-				  tcrypt_complete, &result);
+				  crypto_req_done, &wait);
 
 	iv_len = crypto_aead_ivsize(tfm);
 
@@ -709,7 +671,8 @@ static int __test_aead(struct crypto_aead *tfm, int enc,
 
 		aead_request_set_ad(req, template[i].alen);
 
-		ret = enc ? crypto_aead_encrypt(req) : crypto_aead_decrypt(req);
+		ret = crypto_wait_req(enc ? crypto_aead_encrypt(req)
+				      : crypto_aead_decrypt(req), &wait);
 
 		switch (ret) {
 		case 0:
@@ -722,13 +685,6 @@ static int __test_aead(struct crypto_aead *tfm, int enc,
 				goto out;
 			}
 			break;
-		case -EINPROGRESS:
-		case -EBUSY:
-			wait_for_completion(&result.completion);
-			reinit_completion(&result.completion);
-			ret = result.err;
-			if (!ret)
-				break;
 		case -EBADMSG:
 			if (template[i].novrfy)
 				/* verification failure was expected */
@@ -866,7 +822,8 @@ static int __test_aead(struct crypto_aead *tfm, int enc,
 
 		aead_request_set_ad(req, template[i].alen);
 
-		ret = enc ? crypto_aead_encrypt(req) : crypto_aead_decrypt(req);
+		ret = crypto_wait_req(enc ? crypto_aead_encrypt(req)
+				      : crypto_aead_decrypt(req), &wait);
 
 		switch (ret) {
 		case 0:
@@ -879,13 +836,6 @@ static int __test_aead(struct crypto_aead *tfm, int enc,
 				goto out;
 			}
 			break;
-		case -EINPROGRESS:
-		case -EBUSY:
-			wait_for_completion(&result.completion);
-			reinit_completion(&result.completion);
-			ret = result.err;
-			if (!ret)
-				break;
 		case -EBADMSG:
 			if (template[i].novrfy)
 				/* verification failure was expected */
@@ -1083,7 +1033,7 @@ static int __test_skcipher(struct crypto_skcipher *tfm, int enc,
 	struct scatterlist sg[8];
 	struct scatterlist sgout[8];
 	const char *e, *d;
-	struct tcrypt_result result;
+	struct crypto_wait wait;
 	void *data;
 	char iv[MAX_IVLEN];
 	char *xbuf[XBUFSIZE];
@@ -1107,7 +1057,7 @@ static int __test_skcipher(struct crypto_skcipher *tfm, int enc,
 	else
 		e = "decryption";
 
-	init_completion(&result.completion);
+	crypto_init_wait(&wait);
 
 	req = skcipher_request_alloc(tfm, GFP_KERNEL);
 	if (!req) {
@@ -1117,7 +1067,7 @@ static int __test_skcipher(struct crypto_skcipher *tfm, int enc,
 	}
 
 	skcipher_request_set_callback(req, CRYPTO_TFM_REQ_MAY_BACKLOG,
-				      tcrypt_complete, &result);
+				      crypto_req_done, &wait);
 
 	j = 0;
 	for (i = 0; i < tcount; i++) {
@@ -1164,21 +1114,10 @@ static int __test_skcipher(struct crypto_skcipher *tfm, int enc,
 
 		skcipher_request_set_crypt(req, sg, (diff_dst) ? sgout : sg,
 					   template[i].ilen, iv);
-		ret = enc ? crypto_skcipher_encrypt(req) :
-			    crypto_skcipher_decrypt(req);
+		ret = crypto_wait_req(enc ? crypto_skcipher_encrypt(req) :
+				      crypto_skcipher_decrypt(req), &wait);
 
-		switch (ret) {
-		case 0:
-			break;
-		case -EINPROGRESS:
-		case -EBUSY:
-			wait_for_completion(&result.completion);
-			reinit_completion(&result.completion);
-			ret = result.err;
-			if (!ret)
-				break;
-			/* fall through */
-		default:
+		if (ret) {
 			pr_err("alg: skcipher%s: %s failed on test %d for %s: ret=%d\n",
 			       d, e, j, algo, -ret);
 			goto out;
@@ -1272,21 +1211,10 @@ static int __test_skcipher(struct crypto_skcipher *tfm, int enc,
 		skcipher_request_set_crypt(req, sg, (diff_dst) ? sgout : sg,
 					   template[i].ilen, iv);
 
-		ret = enc ? crypto_skcipher_encrypt(req) :
-			    crypto_skcipher_decrypt(req);
+		ret = crypto_wait_req(enc ? crypto_skcipher_encrypt(req) :
+				      crypto_skcipher_decrypt(req), &wait);
 
-		switch (ret) {
-		case 0:
-			break;
-		case -EINPROGRESS:
-		case -EBUSY:
-			wait_for_completion(&result.completion);
-			reinit_completion(&result.completion);
-			ret = result.err;
-			if (!ret)
-				break;
-			/* fall through */
-		default:
+		if (ret) {
 			pr_err("alg: skcipher%s: %s failed on chunk test %d for %s: ret=%d\n",
 			       d, e, j, algo, -ret);
 			goto out;
@@ -1462,7 +1390,7 @@ static int test_acomp(struct crypto_acomp *tfm,
 	int ret;
 	struct scatterlist src, dst;
 	struct acomp_req *req;
-	struct tcrypt_result result;
+	struct crypto_wait wait;
 
 	output = kmalloc(COMP_BUF_SIZE, GFP_KERNEL);
 	if (!output)
@@ -1486,7 +1414,7 @@ static int test_acomp(struct crypto_acomp *tfm,
 		}
 
 		memset(output, 0, dlen);
-		init_completion(&result.completion);
+		crypto_init_wait(&wait);
 		sg_init_one(&src, input_vec, ilen);
 		sg_init_one(&dst, output, dlen);
 
@@ -1501,9 +1429,9 @@ static int test_acomp(struct crypto_acomp *tfm,
 
 		acomp_request_set_params(req, &src, &dst, ilen, dlen);
 		acomp_request_set_callback(req, CRYPTO_TFM_REQ_MAY_BACKLOG,
-					   tcrypt_complete, &result);
+					   crypto_req_done, &wait);
 
-		ret = wait_async_op(&result, crypto_acomp_compress(req));
+		ret = crypto_wait_req(crypto_acomp_compress(req), &wait);
 		if (ret) {
 			pr_err("alg: acomp: compression failed on test %d for %s: ret=%d\n",
 			       i + 1, algo, -ret);
@@ -1516,10 +1444,10 @@ static int test_acomp(struct crypto_acomp *tfm,
 		dlen = COMP_BUF_SIZE;
 		sg_init_one(&src, output, ilen);
 		sg_init_one(&dst, decomp_out, dlen);
-		init_completion(&result.completion);
+		crypto_init_wait(&wait);
 		acomp_request_set_params(req, &src, &dst, ilen, dlen);
 
-		ret = wait_async_op(&result, crypto_acomp_decompress(req));
+		ret = crypto_wait_req(crypto_acomp_decompress(req), &wait);
 		if (ret) {
 			pr_err("alg: acomp: compression failed on test %d for %s: ret=%d\n",
 			       i + 1, algo, -ret);
@@ -1563,7 +1491,7 @@ static int test_acomp(struct crypto_acomp *tfm,
 		}
 
 		memset(output, 0, dlen);
-		init_completion(&result.completion);
+		crypto_init_wait(&wait);
 		sg_init_one(&src, input_vec, ilen);
 		sg_init_one(&dst, output, dlen);
 
@@ -1578,9 +1506,9 @@ static int test_acomp(struct crypto_acomp *tfm,
 
 		acomp_request_set_params(req, &src, &dst, ilen, dlen);
 		acomp_request_set_callback(req, CRYPTO_TFM_REQ_MAY_BACKLOG,
-					   tcrypt_complete, &result);
+					   crypto_req_done, &wait);
 
-		ret = wait_async_op(&result, crypto_acomp_decompress(req));
+		ret = crypto_wait_req(crypto_acomp_decompress(req), &wait);
 		if (ret) {
 			pr_err("alg: acomp: decompression failed on test %d for %s: ret=%d\n",
 			       i + 1, algo, -ret);
@@ -2000,7 +1928,7 @@ static int do_test_kpp(struct crypto_kpp *tfm, const struct kpp_testvec *vec,
 	void *a_public = NULL;
 	void *a_ss = NULL;
 	void *shared_secret = NULL;
-	struct tcrypt_result result;
+	struct crypto_wait wait;
 	unsigned int out_len_max;
 	int err = -ENOMEM;
 	struct scatterlist src, dst;
@@ -2009,7 +1937,7 @@ static int do_test_kpp(struct crypto_kpp *tfm, const struct kpp_testvec *vec,
 	if (!req)
 		return err;
 
-	init_completion(&result.completion);
+	crypto_init_wait(&wait);
 
 	err = crypto_kpp_set_secret(tfm, vec->secret, vec->secret_size);
 	if (err < 0)
@@ -2027,10 +1955,10 @@ static int do_test_kpp(struct crypto_kpp *tfm, const struct kpp_testvec *vec,
 	sg_init_one(&dst, output_buf, out_len_max);
 	kpp_request_set_output(req, &dst, out_len_max);
 	kpp_request_set_callback(req, CRYPTO_TFM_REQ_MAY_BACKLOG,
-				 tcrypt_complete, &result);
+				 crypto_req_done, &wait);
 
 	/* Compute party A's public key */
-	err = wait_async_op(&result, crypto_kpp_generate_public_key(req));
+	err = crypto_wait_req(crypto_kpp_generate_public_key(req), &wait);
 	if (err) {
 		pr_err("alg: %s: Party A: generate public key test failed. err %d\n",
 		       alg, err);
@@ -2069,8 +1997,8 @@ static int do_test_kpp(struct crypto_kpp *tfm, const struct kpp_testvec *vec,
 	kpp_request_set_input(req, &src, vec->b_public_size);
 	kpp_request_set_output(req, &dst, out_len_max);
 	kpp_request_set_callback(req, CRYPTO_TFM_REQ_MAY_BACKLOG,
-				 tcrypt_complete, &result);
-	err = wait_async_op(&result, crypto_kpp_compute_shared_secret(req));
+				 crypto_req_done, &wait);
+	err = crypto_wait_req(crypto_kpp_compute_shared_secret(req), &wait);
 	if (err) {
 		pr_err("alg: %s: Party A: compute shared secret test failed. err %d\n",
 		       alg, err);
@@ -2100,9 +2028,9 @@ static int do_test_kpp(struct crypto_kpp *tfm, const struct kpp_testvec *vec,
 		kpp_request_set_input(req, &src, vec->expected_a_public_size);
 		kpp_request_set_output(req, &dst, out_len_max);
 		kpp_request_set_callback(req, CRYPTO_TFM_REQ_MAY_BACKLOG,
-					 tcrypt_complete, &result);
-		err = wait_async_op(&result,
-				    crypto_kpp_compute_shared_secret(req));
+					 crypto_req_done, &wait);
+		err = crypto_wait_req(crypto_kpp_compute_shared_secret(req),
+				      &wait);
 		if (err) {
 			pr_err("alg: %s: Party B: compute shared secret failed. err %d\n",
 			       alg, err);
@@ -2179,7 +2107,7 @@ static int test_akcipher_one(struct crypto_akcipher *tfm,
 	struct akcipher_request *req;
 	void *outbuf_enc = NULL;
 	void *outbuf_dec = NULL;
-	struct tcrypt_result result;
+	struct crypto_wait wait;
 	unsigned int out_len_max, out_len = 0;
 	int err = -ENOMEM;
 	struct scatterlist src, dst, src_tab[2];
@@ -2191,7 +2119,7 @@ static int test_akcipher_one(struct crypto_akcipher *tfm,
 	if (!req)
 		goto free_xbuf;
 
-	init_completion(&result.completion);
+	crypto_init_wait(&wait);
 
 	if (vecs->public_key_vec)
 		err = crypto_akcipher_set_pub_key(tfm, vecs->key,
@@ -2220,13 +2148,13 @@ static int test_akcipher_one(struct crypto_akcipher *tfm,
 	akcipher_request_set_crypt(req, src_tab, &dst, vecs->m_size,
 				   out_len_max);
 	akcipher_request_set_callback(req, CRYPTO_TFM_REQ_MAY_BACKLOG,
-				      tcrypt_complete, &result);
+				      crypto_req_done, &wait);
 
-	err = wait_async_op(&result, vecs->siggen_sigver_test ?
-				     /* Run asymmetric signature generation */
-				     crypto_akcipher_sign(req) :
-				     /* Run asymmetric encrypt */
-				     crypto_akcipher_encrypt(req));
+	err = crypto_wait_req(vecs->siggen_sigver_test ?
+			      /* Run asymmetric signature generation */
+			      crypto_akcipher_sign(req) :
+			      /* Run asymmetric encrypt */
+			      crypto_akcipher_encrypt(req), &wait);
 	if (err) {
 		pr_err("alg: akcipher: encrypt test failed. err %d\n", err);
 		goto free_all;
@@ -2261,14 +2189,14 @@ static int test_akcipher_one(struct crypto_akcipher *tfm,
 
 	sg_init_one(&src, xbuf[0], vecs->c_size);
 	sg_init_one(&dst, outbuf_dec, out_len_max);
-	init_completion(&result.completion);
+	crypto_init_wait(&wait);
 	akcipher_request_set_crypt(req, &src, &dst, vecs->c_size, out_len_max);
 
-	err = wait_async_op(&result, vecs->siggen_sigver_test ?
-				     /* Run asymmetric signature verification */
-				     crypto_akcipher_verify(req) :
-				     /* Run asymmetric decrypt */
-				     crypto_akcipher_decrypt(req));
+	err = crypto_wait_req(vecs->siggen_sigver_test ?
+			      /* Run asymmetric signature verification */
+			      crypto_akcipher_verify(req) :
+			      /* Run asymmetric decrypt */
+			      crypto_akcipher_decrypt(req), &wait);
 	if (err) {
 		pr_err("alg: akcipher: decrypt test failed. err %d\n", err);
 		goto free_all;
-- 
2.1.4
