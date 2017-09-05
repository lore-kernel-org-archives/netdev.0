Return-Path: <linux-kernel-owner@vger.kernel.org>
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
Subject: [PATCH v8 08/20] crypto: move pub key to generic async completion
Date: Tue,  5 Sep 2017 15:38:47 +0300
Message-Id: <1504615144-29770-9-git-send-email-gilad@benyossef.com>
In-Reply-To: <1504615144-29770-1-git-send-email-gilad@benyossef.com>
References: <1504615144-29770-1-git-send-email-gilad@benyossef.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

public_key_verify_signature() is starting an async crypto op and
waiting for it to complete. Move it over to generic code doing
the same.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
---
 crypto/asymmetric_keys/public_key.c | 28 ++++------------------------
 1 file changed, 4 insertions(+), 24 deletions(-)

diff --git a/crypto/asymmetric_keys/public_key.c b/crypto/asymmetric_keys/public_key.c
index 3cd6e12..d916235 100644
--- a/crypto/asymmetric_keys/public_key.c
+++ b/crypto/asymmetric_keys/public_key.c
@@ -57,29 +57,13 @@ static void public_key_destroy(void *payload0, void *payload3)
 	public_key_signature_free(payload3);
 }
 
-struct public_key_completion {
-	struct completion completion;
-	int err;
-};
-
-static void public_key_verify_done(struct crypto_async_request *req, int err)
-{
-	struct public_key_completion *compl = req->data;
-
-	if (err == -EINPROGRESS)
-		return;
-
-	compl->err = err;
-	complete(&compl->completion);
-}
-
 /*
  * Verify a signature using a public key.
  */
 int public_key_verify_signature(const struct public_key *pkey,
 				const struct public_key_signature *sig)
 {
-	struct public_key_completion compl;
+	struct crypto_wait cwait;
 	struct crypto_akcipher *tfm;
 	struct akcipher_request *req;
 	struct scatterlist sig_sg, digest_sg;
@@ -131,20 +115,16 @@ int public_key_verify_signature(const struct public_key *pkey,
 	sg_init_one(&digest_sg, output, outlen);
 	akcipher_request_set_crypt(req, &sig_sg, &digest_sg, sig->s_size,
 				   outlen);
-	init_completion(&compl.completion);
+	crypto_init_wait(&cwait);
 	akcipher_request_set_callback(req, CRYPTO_TFM_REQ_MAY_BACKLOG |
 				      CRYPTO_TFM_REQ_MAY_SLEEP,
-				      public_key_verify_done, &compl);
+				      crypto_req_done, &cwait);
 
 	/* Perform the verification calculation.  This doesn't actually do the
 	 * verification, but rather calculates the hash expected by the
 	 * signature and returns that to us.
 	 */
-	ret = crypto_akcipher_verify(req);
-	if ((ret == -EINPROGRESS) || (ret == -EBUSY)) {
-		wait_for_completion(&compl.completion);
-		ret = compl.err;
-	}
+	ret = crypto_wait_req(crypto_akcipher_verify(req), &cwait);
 	if (ret < 0)
 		goto out_free_output;
 
-- 
2.1.4
