Return-Path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:39866 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752182AbdIEMna (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 5 Sep 2017 08:43:30 -0400
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
Subject: [PATCH v8 17/20] crypto: talitos: move to generic async completion
Date: Tue,  5 Sep 2017 15:38:56 +0300
Message-Id: <1504615144-29770-18-git-send-email-gilad@benyossef.com>
In-Reply-To: <1504615144-29770-1-git-send-email-gilad@benyossef.com>
References: <1504615144-29770-1-git-send-email-gilad@benyossef.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The talitos driver starts several async crypto ops and  waits for their
completions. Move it over to generic code doing the same.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
---
 drivers/crypto/talitos.c | 38 +++++---------------------------------
 1 file changed, 5 insertions(+), 33 deletions(-)

diff --git a/drivers/crypto/talitos.c b/drivers/crypto/talitos.c
index 79791c6..194a307 100644
--- a/drivers/crypto/talitos.c
+++ b/drivers/crypto/talitos.c
@@ -2037,22 +2037,6 @@ static int ahash_import(struct ahash_request *areq, const void *in)
 	return 0;
 }
 
-struct keyhash_result {
-	struct completion completion;
-	int err;
-};
-
-static void keyhash_complete(struct crypto_async_request *req, int err)
-{
-	struct keyhash_result *res = req->data;
-
-	if (err == -EINPROGRESS)
-		return;
-
-	res->err = err;
-	complete(&res->completion);
-}
-
 static int keyhash(struct crypto_ahash *tfm, const u8 *key, unsigned int keylen,
 		   u8 *hash)
 {
@@ -2060,10 +2044,10 @@ static int keyhash(struct crypto_ahash *tfm, const u8 *key, unsigned int keylen,
 
 	struct scatterlist sg[1];
 	struct ahash_request *req;
-	struct keyhash_result hresult;
+	struct crypto_wait wait;
 	int ret;
 
-	init_completion(&hresult.completion);
+	crypto_init_wait(&wait);
 
 	req = ahash_request_alloc(tfm, GFP_KERNEL);
 	if (!req)
@@ -2072,25 +2056,13 @@ static int keyhash(struct crypto_ahash *tfm, const u8 *key, unsigned int keylen,
 	/* Keep tfm keylen == 0 during hash of the long key */
 	ctx->keylen = 0;
 	ahash_request_set_callback(req, CRYPTO_TFM_REQ_MAY_BACKLOG,
-				   keyhash_complete, &hresult);
+				   crypto_req_done, &wait);
 
 	sg_init_one(&sg[0], key, keylen);
 
 	ahash_request_set_crypt(req, sg, hash, keylen);
-	ret = crypto_ahash_digest(req);
-	switch (ret) {
-	case 0:
-		break;
-	case -EINPROGRESS:
-	case -EBUSY:
-		ret = wait_for_completion_interruptible(
-			&hresult.completion);
-		if (!ret)
-			ret = hresult.err;
-		break;
-	default:
-		break;
-	}
+	ret = crypto_wait_req(crypto_ahash_digest(req), &wait);
+
 	ahash_request_free(req);
 
 	return ret;
-- 
2.1.4
