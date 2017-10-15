From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH v9 17/20] crypto: talitos: move to generic async completion
Date: Sun, 15 Oct 2017 10:20:02 +0100
Message-ID: <1508059209-25529-18-git-send-email-gilad@benyossef.com>
References: <1508059209-25529-1-git-send-email-gilad@benyossef.com>
Cc: Ofir Drang <ofir.drang@arm.com>, linux-crypto@vger.kernel.org,
        linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
        keyrings@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-mediatek@lists.infradead.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-fscrypt@vger.kernel.org,
        netdev@vger.kernel.org, linux-ima-devel@lists.sourceforge.net,
        linux-ima-user@lists.sourceforge.net,
        linux-security-module@vger.kernel.org
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
        Steve French <sfrench@samba.org>,
        "Theodore Y. Ts'o" <tytso@mit.edu>,
        Jaegeuk Kim <jaegeuk@kernel.org>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Mimi Zohar <zohar@linux.vnet.ibm.com>,
        Dmitry Kasatkin <dmitry.ka
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508059209-25529-1-git-send-email-gilad@benyossef.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The talitos driver starts several async crypto ops and  waits for their
completions. Move it over to generic code doing the same.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
---
 drivers/crypto/talitos.c | 38 +++++---------------------------------
 1 file changed, 5 insertions(+), 33 deletions(-)

diff --git a/drivers/crypto/talitos.c b/drivers/crypto/talitos.c
index 5bd8191..9c80e0c 100644
--- a/drivers/crypto/talitos.c
+++ b/drivers/crypto/talitos.c
@@ -2160,22 +2160,6 @@ static int ahash_import(struct ahash_request *areq, const void *in)
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
@@ -2183,10 +2167,10 @@ static int keyhash(struct crypto_ahash *tfm, const u8 *key, unsigned int keylen,
 
 	struct scatterlist sg[1];
 	struct ahash_request *req;
-	struct keyhash_result hresult;
+	struct crypto_wait wait;
 	int ret;
 
-	init_completion(&hresult.completion);
+	crypto_init_wait(&wait);
 
 	req = ahash_request_alloc(tfm, GFP_KERNEL);
 	if (!req)
@@ -2195,25 +2179,13 @@ static int keyhash(struct crypto_ahash *tfm, const u8 *key, unsigned int keylen,
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
2.7.4
