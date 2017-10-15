From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH v9 09/20] crypto: move drbg to generic async completion
Date: Sun, 15 Oct 2017 10:19:54 +0100
Message-ID: <1508059209-25529-10-git-send-email-gilad@benyossef.com>
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

DRBG is starting an async. crypto op and waiting for it complete.
Move it over to generic code doing the same.

The code now also passes CRYPTO_TFM_REQ_MAY_SLEEP flag indicating
crypto request memory allocation may use GFP_KERNEL which should
be perfectly fine as the code is obviously sleeping for the
completion of the request any way.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
---
 crypto/drbg.c         | 36 +++++++++---------------------------
 include/crypto/drbg.h |  3 +--
 2 files changed, 10 insertions(+), 29 deletions(-)

diff --git a/crypto/drbg.c b/crypto/drbg.c
index 7001839..4faa278 100644
--- a/crypto/drbg.c
+++ b/crypto/drbg.c
@@ -1651,16 +1651,6 @@ static int drbg_fini_sym_kernel(struct drbg_state *drbg)
 	return 0;
 }
 
-static void drbg_skcipher_cb(struct crypto_async_request *req, int error)
-{
-	struct drbg_state *drbg = req->data;
-
-	if (error == -EINPROGRESS)
-		return;
-	drbg->ctr_async_err = error;
-	complete(&drbg->ctr_completion);
-}
-
 static int drbg_init_sym_kernel(struct drbg_state *drbg)
 {
 	struct crypto_cipher *tfm;
@@ -1691,7 +1681,7 @@ static int drbg_init_sym_kernel(struct drbg_state *drbg)
 		return PTR_ERR(sk_tfm);
 	}
 	drbg->ctr_handle = sk_tfm;
-	init_completion(&drbg->ctr_completion);
+	crypto_init_wait(&drbg->ctr_wait);
 
 	req = skcipher_request_alloc(sk_tfm, GFP_KERNEL);
 	if (!req) {
@@ -1700,8 +1690,9 @@ static int drbg_init_sym_kernel(struct drbg_state *drbg)
 		return -ENOMEM;
 	}
 	drbg->ctr_req = req;
-	skcipher_request_set_callback(req, CRYPTO_TFM_REQ_MAY_BACKLOG,
-					drbg_skcipher_cb, drbg);
+	skcipher_request_set_callback(req, CRYPTO_TFM_REQ_MAY_BACKLOG |
+						CRYPTO_TFM_REQ_MAY_SLEEP,
+					crypto_req_done, &drbg->ctr_wait);
 
 	alignmask = crypto_skcipher_alignmask(sk_tfm);
 	drbg->ctr_null_value_buf = kzalloc(DRBG_CTR_NULL_LEN + alignmask,
@@ -1762,21 +1753,12 @@ static int drbg_kcapi_sym_ctr(struct drbg_state *drbg,
 		/* Output buffer may not be valid for SGL, use scratchpad */
 		skcipher_request_set_crypt(drbg->ctr_req, &sg_in, &sg_out,
 					   cryptlen, drbg->V);
-		ret = crypto_skcipher_encrypt(drbg->ctr_req);
-		switch (ret) {
-		case 0:
-			break;
-		case -EINPROGRESS:
-		case -EBUSY:
-			wait_for_completion(&drbg->ctr_completion);
-			if (!drbg->ctr_async_err) {
-				reinit_completion(&drbg->ctr_completion);
-				break;
-			}
-		default:
+		ret = crypto_wait_req(crypto_skcipher_encrypt(drbg->ctr_req),
+					&drbg->ctr_wait);
+		if (ret)
 			goto out;
-		}
-		init_completion(&drbg->ctr_completion);
+
+		crypto_init_wait(&drbg->ctr_wait);
 
 		memcpy(outbuf, drbg->outscratchpad, cryptlen);
 
diff --git a/include/crypto/drbg.h b/include/crypto/drbg.h
index 22f884c..8f94110 100644
--- a/include/crypto/drbg.h
+++ b/include/crypto/drbg.h
@@ -126,8 +126,7 @@ struct drbg_state {
 	__u8 *ctr_null_value;			/* CTR mode aligned zero buf */
 	__u8 *outscratchpadbuf;			/* CTR mode output scratchpad */
         __u8 *outscratchpad;			/* CTR mode aligned outbuf */
-	struct completion ctr_completion;	/* CTR mode async handler */
-	int ctr_async_err;			/* CTR mode async error */
+	struct crypto_wait ctr_wait;		/* CTR mode async wait obj */
 
 	bool seeded;		/* DRBG fully seeded? */
 	bool pr;		/* Prediction resistance enabled? */
-- 
2.7.4
