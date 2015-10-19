From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH 1/2] crypto/x509: Fix unaligned access in x509_get_sig_params()
Date: Mon, 19 Oct 2015 17:23:28 -0400
Message-ID: <288f39ff7c8b0bc60693e338fc8f6cea9008d443.1445286755.git.sowmini.varadhan@oracle.com>
References: <cover.1445286755.git.sowmini.varadhan@oracle.com>
Cc: herbert@gondor.apana.org.au, dhowells@redhat.com,
	davem@davemloft.net, zohar@linux.vnet.ibm.com,
	David.Woodhouse@intel.com, sowmini.varadhan@oracle.com,
	steffen.klassert@secunet.com
To: linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1445286755.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1445286755.git.sowmini.varadhan@oracle.com>
References: <cover.1445286755.git.sowmini.varadhan@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

x509_get_sig_params() has the same code pattern as the one in
pkcs7_verify() that is fixed by commit 62f57d05e287 ("crypto: pkcs7 - Fix
unaligned access in pkcs7_verify()") so apply a similar fix here: make
sure that desc is pointing at an algined value past the digest_size,
and take alignment values into consideration when doing kzalloc()

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 crypto/asymmetric_keys/x509_public_key.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/crypto/asymmetric_keys/x509_public_key.c b/crypto/asymmetric_keys/x509_public_key.c
index 1970966..68c3c40 100644
--- a/crypto/asymmetric_keys/x509_public_key.c
+++ b/crypto/asymmetric_keys/x509_public_key.c
@@ -194,14 +194,15 @@ int x509_get_sig_params(struct x509_certificate *cert)
 	 * digest storage space.
 	 */
 	ret = -ENOMEM;
-	digest = kzalloc(digest_size + desc_size, GFP_KERNEL);
+	digest = kzalloc(ALIGN(digest_size, __alignof__(*desc)) + desc_size,
+			 GFP_KERNEL);
 	if (!digest)
 		goto error;
 
 	cert->sig.digest = digest;
 	cert->sig.digest_size = digest_size;
 
-	desc = digest + digest_size;
+	desc = PTR_ALIGN(digest + digest_size, __alignof__(*desc));
 	desc->tfm = tfm;
 	desc->flags = CRYPTO_TFM_REQ_MAY_SLEEP;
 
-- 
1.7.1
