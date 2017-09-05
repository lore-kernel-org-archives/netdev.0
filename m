From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH v8 18/20] crypto: qce: move to generic async completion
Date: Tue,  5 Sep 2017 15:38:57 +0300
Message-ID: <1504615144-29770-19-git-send-email-gilad__22401.0790967897$1504615575$gmane$org@benyossef.com>
References: <1504615144-29770-1-git-send-email-gilad@benyossef.com>
Cc: Ofir Drang <ofir.drang@arm.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:39922 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752282AbdIEMno (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 5 Sep 2017 08:43:44 -0400
In-Reply-To: <1504615144-29770-1-git-send-email-gilad@benyossef.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The qce driver starts several async crypto ops and  waits for their
completions. Move it over to generic code doing the same.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
---
 drivers/crypto/qce/sha.c | 30 ++++--------------------------
 1 file changed, 4 insertions(+), 26 deletions(-)

diff --git a/drivers/crypto/qce/sha.c b/drivers/crypto/qce/sha.c
index 47e114a..53227d7 100644
--- a/drivers/crypto/qce/sha.c
+++ b/drivers/crypto/qce/sha.c
@@ -349,28 +349,12 @@ static int qce_ahash_digest(struct ahash_request *req)
 	return qce->async_req_enqueue(tmpl->qce, &req->base);
 }
 
-struct qce_ahash_result {
-	struct completion completion;
-	int error;
-};
-
-static void qce_digest_complete(struct crypto_async_request *req, int error)
-{
-	struct qce_ahash_result *result = req->data;
-
-	if (error == -EINPROGRESS)
-		return;
-
-	result->error = error;
-	complete(&result->completion);
-}
-
 static int qce_ahash_hmac_setkey(struct crypto_ahash *tfm, const u8 *key,
 				 unsigned int keylen)
 {
 	unsigned int digestsize = crypto_ahash_digestsize(tfm);
 	struct qce_sha_ctx *ctx = crypto_tfm_ctx(&tfm->base);
-	struct qce_ahash_result result;
+	struct crypto_wait wait;
 	struct ahash_request *req;
 	struct scatterlist sg;
 	unsigned int blocksize;
@@ -405,9 +389,9 @@ static int qce_ahash_hmac_setkey(struct crypto_ahash *tfm, const u8 *key,
 		goto err_free_ahash;
 	}
 
-	init_completion(&result.completion);
+	crypto_init_wait(&wait);
 	ahash_request_set_callback(req, CRYPTO_TFM_REQ_MAY_BACKLOG,
-				   qce_digest_complete, &result);
+				   crypto_req_done, &wait);
 	crypto_ahash_clear_flags(ahash_tfm, ~0);
 
 	buf = kzalloc(keylen + QCE_MAX_ALIGN_SIZE, GFP_KERNEL);
@@ -420,13 +404,7 @@ static int qce_ahash_hmac_setkey(struct crypto_ahash *tfm, const u8 *key,
 	sg_init_one(&sg, buf, keylen);
 	ahash_request_set_crypt(req, &sg, ctx->authkey, keylen);
 
-	ret = crypto_ahash_digest(req);
-	if (ret == -EINPROGRESS || ret == -EBUSY) {
-		ret = wait_for_completion_interruptible(&result.completion);
-		if (!ret)
-			ret = result.error;
-	}
-
+	ret = crypto_wait_req(crypto_ahash_digest(req), &wait);
 	if (ret)
 		crypto_ahash_set_flags(tfm, CRYPTO_TFM_RES_BAD_KEY_LEN);
 
-- 
2.1.4
