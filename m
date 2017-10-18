From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH v10 04/20] crypto: remove redundant backlog
	checks on EBUSY
Date: Wed, 18 Oct 2017 08:00:36 +0100
Message-ID: <1508310057-25369-5-git-send-email-gilad@benyossef.com>
References: <1508310057-25369-1-git-send-email-gilad@benyossef.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-cifs@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-ima-user@lists.sourceforge.net, netdev@vger.kernel.org,
	samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
	linux-fscrypt@vger.kernel.org, keyrings@vger.kernel.org,
	linux-mediatek@lists.infradead.org, linux-crypto@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	linux-ima-devel@lists.sourceforge.net,
	linux-arm-kernel@lists.infradead.org, Ofir Drang <ofir.drang@arm.com>
To: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	Jonathan Corbet <corbet@lwn.net>, David Howells <dhowells@redhat.com>,
	Tom Lendacky <thomas.lendacky@amd.com>, Gary Hook <gary.hook@amd.com>,
	Boris Brezillon <boris.brezillon@free-electrons.com>,
	Arnaud Ebalard <arno@natisbad.org>,
	Matthias Brugger <matthias.bgg@gmail.com>,
	Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@redhat.com>,
	dm-devel@redhat.com, Steve French <sfrench@samba.org>,
	"Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Mimi Zohar <zohar@linux.vnet.ibm.com>,
	Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
	James Morris <james.l.morris@oracle.com>,
	"Serge E. Hallyn" <serge@hallyn.com>
Return-path: <dm-devel-bounces@redhat.com>
In-Reply-To: <1508310057-25369-1-git-send-email-gilad@benyossef.com>
List-Unsubscribe: <https://www.redhat.com/mailman/options/dm-devel>,
	<mailto:dm-devel-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/dm-devel>
List-Post: <mailto:dm-devel@redhat.com>
List-Help: <mailto:dm-devel-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/dm-devel>,
	<mailto:dm-devel-request@redhat.com?subject=subscribe>
Sender: dm-devel-bounces@redhat.com
Errors-To: dm-devel-bounces@redhat.com
List-Id: netdev.vger.kernel.org

Now that -EBUSY return code only indicates backlog queueing
we can safely remove the now redundant check for the
CRYPTO_TFM_REQ_MAY_BACKLOG flag when -EBUSY is returned.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
---
 crypto/ahash.c        | 12 +++---------
 crypto/cts.c          |  6 ++----
 crypto/lrw.c          |  8 ++------
 crypto/rsa-pkcs1pad.c | 16 ++++------------
 crypto/xts.c          |  8 ++------
 5 files changed, 13 insertions(+), 37 deletions(-)

diff --git a/crypto/ahash.c b/crypto/ahash.c
index 5e8666e..3a35d67 100644
--- a/crypto/ahash.c
+++ b/crypto/ahash.c
@@ -334,9 +334,7 @@ static int ahash_op_unaligned(struct ahash_request *req,
 		return err;
 
 	err = op(req);
-	if (err == -EINPROGRESS ||
-	    (err == -EBUSY && (ahash_request_flags(req) &
-			       CRYPTO_TFM_REQ_MAY_BACKLOG)))
+	if (err == -EINPROGRESS || err == -EBUSY)
 		return err;
 
 	ahash_restore_req(req, err);
@@ -394,9 +392,7 @@ static int ahash_def_finup_finish1(struct ahash_request *req, int err)
 	req->base.complete = ahash_def_finup_done2;
 
 	err = crypto_ahash_reqtfm(req)->final(req);
-	if (err == -EINPROGRESS ||
-	    (err == -EBUSY && (ahash_request_flags(req) &
-			       CRYPTO_TFM_REQ_MAY_BACKLOG)))
+	if (err == -EINPROGRESS || err == -EBUSY)
 		return err;
 
 out:
@@ -432,9 +428,7 @@ static int ahash_def_finup(struct ahash_request *req)
 		return err;
 
 	err = tfm->update(req);
-	if (err == -EINPROGRESS ||
-	    (err == -EBUSY && (ahash_request_flags(req) &
-			       CRYPTO_TFM_REQ_MAY_BACKLOG)))
+	if (err == -EINPROGRESS || err == -EBUSY)
 		return err;
 
 	return ahash_def_finup_finish1(req, err);
diff --git a/crypto/cts.c b/crypto/cts.c
index 243f591..4773c18 100644
--- a/crypto/cts.c
+++ b/crypto/cts.c
@@ -136,8 +136,7 @@ static void crypto_cts_encrypt_done(struct crypto_async_request *areq, int err)
 		goto out;
 
 	err = cts_cbc_encrypt(req);
-	if (err == -EINPROGRESS ||
-	    (err == -EBUSY && req->base.flags & CRYPTO_TFM_REQ_MAY_BACKLOG))
+	if (err == -EINPROGRESS || err == -EBUSY)
 		return;
 
 out:
@@ -229,8 +228,7 @@ static void crypto_cts_decrypt_done(struct crypto_async_request *areq, int err)
 		goto out;
 
 	err = cts_cbc_decrypt(req);
-	if (err == -EINPROGRESS ||
-	    (err == -EBUSY && req->base.flags & CRYPTO_TFM_REQ_MAY_BACKLOG))
+	if (err == -EINPROGRESS || err == -EBUSY)
 		return;
 
 out:
diff --git a/crypto/lrw.c b/crypto/lrw.c
index 92df312..cbbd7c5 100644
--- a/crypto/lrw.c
+++ b/crypto/lrw.c
@@ -328,9 +328,7 @@ static int do_encrypt(struct skcipher_request *req, int err)
 		      crypto_skcipher_encrypt(subreq) ?:
 		      post_crypt(req);
 
-		if (err == -EINPROGRESS ||
-		    (err == -EBUSY &&
-		     req->base.flags & CRYPTO_TFM_REQ_MAY_BACKLOG))
+		if (err == -EINPROGRESS || err == -EBUSY)
 			return err;
 	}
 
@@ -380,9 +378,7 @@ static int do_decrypt(struct skcipher_request *req, int err)
 		      crypto_skcipher_decrypt(subreq) ?:
 		      post_crypt(req);
 
-		if (err == -EINPROGRESS ||
-		    (err == -EBUSY &&
-		     req->base.flags & CRYPTO_TFM_REQ_MAY_BACKLOG))
+		if (err == -EINPROGRESS || err == -EBUSY)
 			return err;
 	}
 
diff --git a/crypto/rsa-pkcs1pad.c b/crypto/rsa-pkcs1pad.c
index 407c64b..2908f93 100644
--- a/crypto/rsa-pkcs1pad.c
+++ b/crypto/rsa-pkcs1pad.c
@@ -279,9 +279,7 @@ static int pkcs1pad_encrypt(struct akcipher_request *req)
 				   req->dst, ctx->key_size - 1, req->dst_len);
 
 	err = crypto_akcipher_encrypt(&req_ctx->child_req);
-	if (err != -EINPROGRESS &&
-			(err != -EBUSY ||
-			 !(req->base.flags & CRYPTO_TFM_REQ_MAY_BACKLOG)))
+	if (err != -EINPROGRESS && err != -EBUSY)
 		return pkcs1pad_encrypt_sign_complete(req, err);
 
 	return err;
@@ -383,9 +381,7 @@ static int pkcs1pad_decrypt(struct akcipher_request *req)
 				   ctx->key_size);
 
 	err = crypto_akcipher_decrypt(&req_ctx->child_req);
-	if (err != -EINPROGRESS &&
-			(err != -EBUSY ||
-			 !(req->base.flags & CRYPTO_TFM_REQ_MAY_BACKLOG)))
+	if (err != -EINPROGRESS && err != -EBUSY)
 		return pkcs1pad_decrypt_complete(req, err);
 
 	return err;
@@ -440,9 +436,7 @@ static int pkcs1pad_sign(struct akcipher_request *req)
 				   req->dst, ctx->key_size - 1, req->dst_len);
 
 	err = crypto_akcipher_sign(&req_ctx->child_req);
-	if (err != -EINPROGRESS &&
-			(err != -EBUSY ||
-			 !(req->base.flags & CRYPTO_TFM_REQ_MAY_BACKLOG)))
+	if (err != -EINPROGRESS && err != -EBUSY)
 		return pkcs1pad_encrypt_sign_complete(req, err);
 
 	return err;
@@ -561,9 +555,7 @@ static int pkcs1pad_verify(struct akcipher_request *req)
 				   ctx->key_size);
 
 	err = crypto_akcipher_verify(&req_ctx->child_req);
-	if (err != -EINPROGRESS &&
-			(err != -EBUSY ||
-			 !(req->base.flags & CRYPTO_TFM_REQ_MAY_BACKLOG)))
+	if (err != -EINPROGRESS && err != -EBUSY)
 		return pkcs1pad_verify_complete(req, err);
 
 	return err;
diff --git a/crypto/xts.c b/crypto/xts.c
index e31828e..f317c48 100644
--- a/crypto/xts.c
+++ b/crypto/xts.c
@@ -269,9 +269,7 @@ static int do_encrypt(struct skcipher_request *req, int err)
 		      crypto_skcipher_encrypt(subreq) ?:
 		      post_crypt(req);
 
-		if (err == -EINPROGRESS ||
-		    (err == -EBUSY &&
-		     req->base.flags & CRYPTO_TFM_REQ_MAY_BACKLOG))
+		if (err == -EINPROGRESS || err == -EBUSY)
 			return err;
 	}
 
@@ -321,9 +319,7 @@ static int do_decrypt(struct skcipher_request *req, int err)
 		      crypto_skcipher_decrypt(subreq) ?:
 		      post_crypt(req);
 
-		if (err == -EINPROGRESS ||
-		    (err == -EBUSY &&
-		     req->base.flags & CRYPTO_TFM_REQ_MAY_BACKLOG))
+		if (err == -EINPROGRESS || err == -EBUSY)
 			return err;
 	}
 
-- 
2.7.4
