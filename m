From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH v10 20/20] crypto: adapt api sample to use async. op wait
Date: Wed, 18 Oct 2017 08:00:52 +0100
Message-ID: <1508310057-25369-21-git-send-email-gilad@benyossef.com>
References: <1508310057-25369-1-git-send-email-gilad@benyossef.com>
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
In-Reply-To: <1508310057-25369-1-git-send-email-gilad@benyossef.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The code sample is waiting for an async. crypto op completion.
Adapt sample to use the new generic infrastructure to do the same.

This also fixes a possible data coruption bug created by the
use of wait_for_completion_interruptible() without dealing
correctly with an interrupt aborting the wait prior to the
async op finishing.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
---
 Documentation/crypto/api-samples.rst | 52 +++++++-----------------------------
 1 file changed, 10 insertions(+), 42 deletions(-)

diff --git a/Documentation/crypto/api-samples.rst b/Documentation/crypto/api-samples.rst
index 2531948..006827e 100644
--- a/Documentation/crypto/api-samples.rst
+++ b/Documentation/crypto/api-samples.rst
@@ -7,59 +7,27 @@ Code Example For Symmetric Key Cipher Operation
 ::
 
 
-    struct tcrypt_result {
-        struct completion completion;
-        int err;
-    };
-
     /* tie all data structures together */
     struct skcipher_def {
         struct scatterlist sg;
         struct crypto_skcipher *tfm;
         struct skcipher_request *req;
-        struct tcrypt_result result;
+        struct crypto_wait wait;
     };
 
-    /* Callback function */
-    static void test_skcipher_cb(struct crypto_async_request *req, int error)
-    {
-        struct tcrypt_result *result = req->data;
-
-        if (error == -EINPROGRESS)
-            return;
-        result->err = error;
-        complete(&result->completion);
-        pr_info("Encryption finished successfully\n");
-    }
-
     /* Perform cipher operation */
     static unsigned int test_skcipher_encdec(struct skcipher_def *sk,
                          int enc)
     {
-        int rc = 0;
+        int rc;
 
         if (enc)
-            rc = crypto_skcipher_encrypt(sk->req);
+            rc = crypto_wait_req(crypto_skcipher_encrypt(sk->req), &sk->wait);
         else
-            rc = crypto_skcipher_decrypt(sk->req);
-
-        switch (rc) {
-        case 0:
-            break;
-        case -EINPROGRESS:
-        case -EBUSY:
-            rc = wait_for_completion_interruptible(
-                &sk->result.completion);
-            if (!rc && !sk->result.err) {
-                reinit_completion(&sk->result.completion);
-                break;
-            }
-        default:
-            pr_info("skcipher encrypt returned with %d result %d\n",
-                rc, sk->result.err);
-            break;
-        }
-        init_completion(&sk->result.completion);
+            rc = crypto_wait_req(crypto_skcipher_decrypt(sk->req), &sk->wait);
+
+	if (rc)
+		pr_info("skcipher encrypt returned with result %d\n", rc);
 
         return rc;
     }
@@ -89,8 +57,8 @@ Code Example For Symmetric Key Cipher Operation
         }
 
         skcipher_request_set_callback(req, CRYPTO_TFM_REQ_MAY_BACKLOG,
-                          test_skcipher_cb,
-                          &sk.result);
+                          crypto_req_done,
+                          &sk.wait);
 
         /* AES 256 with random key */
         get_random_bytes(&key, 32);
@@ -122,7 +90,7 @@ Code Example For Symmetric Key Cipher Operation
         /* We encrypt one block */
         sg_init_one(&sk.sg, scratchpad, 16);
         skcipher_request_set_crypt(req, &sk.sg, &sk.sg, 16, ivdata);
-        init_completion(&sk.result.completion);
+        crypto_init_wait(&sk.wait);
 
         /* encrypt data */
         ret = test_skcipher_encdec(&sk, 1);
-- 
2.7.4
