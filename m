From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH] mac80211: aes_ccm: move struct aead_req off the stack
Date: Fri, 14 Oct 2016 14:09:00 +0100
Message-ID: <1476450540-1760-1-git-send-email-ard.biesheuvel@linaro.org>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
To: johannes@sipsolutions.net, luto@amacapital.net,
        sergey.senozhatsky.work@gmail.com, netdev@vger.kernel.org,
        herbert@gondor.apana.org.au, davem@davemloft.net,
        linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
        j@w1.fi
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some CCM implementations (such as the generic CCM wrapper in crypto/)
use scatterlists to map fields of struct aead_req. This means these
data structures cannot live in the vmalloc area, which means that in
the near future, they can no longer live on the stack either.

Given that these data structures have implementation specific context fields,
it really depends on the particular driver whether this issue is likely to
occur or not, and so it seems best to simply move the entire data structure
into the direct mapped kernel heap.

So use kzalloc/kfree to allocate and free the data structures. This pattern
already exists in the IPsec ESP driver, but in the future, we may need to
improve upon this by either moving the request into the SKB, or using a
slab cache to allocate/free the data structures.

Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---

This only addresses one half of the problem. The other problem, i.e., the
fact that the aad[] array lives on the stack of the caller, is handled
adequately imo by the change proposed by Johannes.

 net/mac80211/aes_ccm.c | 24 ++++++++++----------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/mac80211/aes_ccm.c b/net/mac80211/aes_ccm.c
index 7663c28ba353..a0ae8cebbe4e 100644
--- a/net/mac80211/aes_ccm.c
+++ b/net/mac80211/aes_ccm.c
@@ -23,13 +23,10 @@ void ieee80211_aes_ccm_encrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
 			       size_t mic_len)
 {
 	struct scatterlist sg[3];
+	struct aead_request *aead_req;
 
-	char aead_req_data[sizeof(struct aead_request) +
-			   crypto_aead_reqsize(tfm)]
-		__aligned(__alignof__(struct aead_request));
-	struct aead_request *aead_req = (void *) aead_req_data;
-
-	memset(aead_req, 0, sizeof(aead_req_data));
+	aead_req = kzalloc(sizeof(struct aead_request) +
+			   crypto_aead_reqsize(tfm), GFP_ATOMIC);
 
 	sg_init_table(sg, 3);
 	sg_set_buf(&sg[0], &aad[2], be16_to_cpup((__be16 *)aad));
@@ -41,6 +38,7 @@ void ieee80211_aes_ccm_encrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
 	aead_request_set_ad(aead_req, sg[0].length);
 
 	crypto_aead_encrypt(aead_req);
+	kfree(aead_req);
 }
 
 int ieee80211_aes_ccm_decrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
@@ -48,15 +46,14 @@ int ieee80211_aes_ccm_decrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
 			      size_t mic_len)
 {
 	struct scatterlist sg[3];
-	char aead_req_data[sizeof(struct aead_request) +
-			   crypto_aead_reqsize(tfm)]
-		__aligned(__alignof__(struct aead_request));
-	struct aead_request *aead_req = (void *) aead_req_data;
+	struct aead_request *aead_req;
+	int err;
 
 	if (data_len == 0)
 		return -EINVAL;
 
-	memset(aead_req, 0, sizeof(aead_req_data));
+	aead_req = kzalloc(sizeof(struct aead_request) +
+			   crypto_aead_reqsize(tfm), GFP_ATOMIC);
 
 	sg_init_table(sg, 3);
 	sg_set_buf(&sg[0], &aad[2], be16_to_cpup((__be16 *)aad));
@@ -67,7 +64,10 @@ int ieee80211_aes_ccm_decrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
 	aead_request_set_crypt(aead_req, sg, sg, data_len + mic_len, b_0);
 	aead_request_set_ad(aead_req, sg[0].length);
 
-	return crypto_aead_decrypt(aead_req);
+	err = crypto_aead_decrypt(aead_req);
+	kfree(aead_req);
+
+	return err;
 }
 
 struct crypto_aead *ieee80211_aes_key_setup_encrypt(const u8 key[],
-- 
2.7.4
