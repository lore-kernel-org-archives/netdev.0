From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH v3] mac80211: move struct aead_req off the stack
Date: Mon, 17 Oct 2016 10:03:51 +0200
Message-ID: <1476691431-27693-1-git-send-email-johannes@sipsolutions.net>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>,
        Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
        netdev@vger.kernel.org, herbert@gondor.apana.org.au,
        Johannes Berg <johannes.berg@intel.com>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:49159 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758505AbcJQIEE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Oct 2016 04:04:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

Some crypto implementations (such as the generic CCM wrapper in crypto/)
use scatterlists to map fields of private data in their struct aead_req.
This means these data structures cannot live in the vmalloc area, which
means that they cannot live on the stack (with CONFIG_VMAP_STACK.)

This currently occurs only with the generic software implementation, but
the private data and usage is implementation specific, so move the whole
data structures off the stack into heap by allocating every time we need
to use them.

This pattern already exists in the IPsec ESP driver, but in the future,
we may want/need to improve upon this, e.g. by using a slab cache.

(Based on Ard's patch, but that was missing error handling and GCM/GMAC)

Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
v3: remove superfluous aead_request_set_tfm() calls
---
 net/mac80211/aes_ccm.c  | 36 +++++++++++++++++++-----------------
 net/mac80211/aes_ccm.h  |  6 +++---
 net/mac80211/aes_gcm.c  | 33 +++++++++++++++++----------------
 net/mac80211/aes_gcm.h  |  4 ++--
 net/mac80211/aes_gmac.c | 11 +++++------
 net/mac80211/wpa.c      | 12 ++++--------
 6 files changed, 50 insertions(+), 52 deletions(-)

diff --git a/net/mac80211/aes_ccm.c b/net/mac80211/aes_ccm.c
index 7663c28ba353..8e898a6e8de8 100644
--- a/net/mac80211/aes_ccm.c
+++ b/net/mac80211/aes_ccm.c
@@ -18,29 +18,29 @@
 #include "key.h"
 #include "aes_ccm.h"
 
-void ieee80211_aes_ccm_encrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
-			       u8 *data, size_t data_len, u8 *mic,
-			       size_t mic_len)
+int ieee80211_aes_ccm_encrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
+			      u8 *data, size_t data_len, u8 *mic,
+			      size_t mic_len)
 {
 	struct scatterlist sg[3];
+	struct aead_request *aead_req;
 
-	char aead_req_data[sizeof(struct aead_request) +
-			   crypto_aead_reqsize(tfm)]
-		__aligned(__alignof__(struct aead_request));
-	struct aead_request *aead_req = (void *) aead_req_data;
-
-	memset(aead_req, 0, sizeof(aead_req_data));
+	aead_req = aead_request_alloc(tfm, GFP_ATOMIC);
+	if (!aead_req)
+		return -ENOMEM;
 
 	sg_init_table(sg, 3);
 	sg_set_buf(&sg[0], &aad[2], be16_to_cpup((__be16 *)aad));
 	sg_set_buf(&sg[1], data, data_len);
 	sg_set_buf(&sg[2], mic, mic_len);
 
-	aead_request_set_tfm(aead_req, tfm);
 	aead_request_set_crypt(aead_req, sg, sg, data_len, b_0);
 	aead_request_set_ad(aead_req, sg[0].length);
 
 	crypto_aead_encrypt(aead_req);
+	aead_request_free(aead_req);
+
+	return 0;
 }
 
 int ieee80211_aes_ccm_decrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
@@ -48,26 +48,28 @@ int ieee80211_aes_ccm_decrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
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
+	aead_req = aead_request_alloc(tfm, GFP_ATOMIC);
+	if (!aead_req)
+		return -ENOMEM;
 
 	sg_init_table(sg, 3);
 	sg_set_buf(&sg[0], &aad[2], be16_to_cpup((__be16 *)aad));
 	sg_set_buf(&sg[1], data, data_len);
 	sg_set_buf(&sg[2], mic, mic_len);
 
-	aead_request_set_tfm(aead_req, tfm);
 	aead_request_set_crypt(aead_req, sg, sg, data_len + mic_len, b_0);
 	aead_request_set_ad(aead_req, sg[0].length);
 
-	return crypto_aead_decrypt(aead_req);
+	err = crypto_aead_decrypt(aead_req);
+	aead_request_free(aead_req);
+
+	return err;
 }
 
 struct crypto_aead *ieee80211_aes_key_setup_encrypt(const u8 key[],
diff --git a/net/mac80211/aes_ccm.h b/net/mac80211/aes_ccm.h
index 6a73d1e4d186..03e21b0995e3 100644
--- a/net/mac80211/aes_ccm.h
+++ b/net/mac80211/aes_ccm.h
@@ -15,9 +15,9 @@
 struct crypto_aead *ieee80211_aes_key_setup_encrypt(const u8 key[],
 						    size_t key_len,
 						    size_t mic_len);
-void ieee80211_aes_ccm_encrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
-			       u8 *data, size_t data_len, u8 *mic,
-			       size_t mic_len);
+int ieee80211_aes_ccm_encrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
+			      u8 *data, size_t data_len, u8 *mic,
+			      size_t mic_len);
 int ieee80211_aes_ccm_decrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
 			      u8 *data, size_t data_len, u8 *mic,
 			      size_t mic_len);
diff --git a/net/mac80211/aes_gcm.c b/net/mac80211/aes_gcm.c
index 3afe361fd27c..831054c6c756 100644
--- a/net/mac80211/aes_gcm.c
+++ b/net/mac80211/aes_gcm.c
@@ -15,55 +15,56 @@
 #include "key.h"
 #include "aes_gcm.h"
 
-void ieee80211_aes_gcm_encrypt(struct crypto_aead *tfm, u8 *j_0, u8 *aad,
-			       u8 *data, size_t data_len, u8 *mic)
+int ieee80211_aes_gcm_encrypt(struct crypto_aead *tfm, u8 *j_0, u8 *aad,
+			      u8 *data, size_t data_len, u8 *mic)
 {
 	struct scatterlist sg[3];
+	struct aead_request *aead_req;
 
-	char aead_req_data[sizeof(struct aead_request) +
-			   crypto_aead_reqsize(tfm)]
-		__aligned(__alignof__(struct aead_request));
-	struct aead_request *aead_req = (void *)aead_req_data;
-
-	memset(aead_req, 0, sizeof(aead_req_data));
+	aead_req = aead_request_alloc(tfm, GFP_ATOMIC);
+	if (!aead_req)
+		return -ENOMEM;
 
 	sg_init_table(sg, 3);
 	sg_set_buf(&sg[0], &aad[2], be16_to_cpup((__be16 *)aad));
 	sg_set_buf(&sg[1], data, data_len);
 	sg_set_buf(&sg[2], mic, IEEE80211_GCMP_MIC_LEN);
 
-	aead_request_set_tfm(aead_req, tfm);
 	aead_request_set_crypt(aead_req, sg, sg, data_len, j_0);
 	aead_request_set_ad(aead_req, sg[0].length);
 
 	crypto_aead_encrypt(aead_req);
+	aead_request_free(aead_req);
+	return 0;
 }
 
 int ieee80211_aes_gcm_decrypt(struct crypto_aead *tfm, u8 *j_0, u8 *aad,
 			      u8 *data, size_t data_len, u8 *mic)
 {
 	struct scatterlist sg[3];
-	char aead_req_data[sizeof(struct aead_request) +
-			   crypto_aead_reqsize(tfm)]
-		__aligned(__alignof__(struct aead_request));
-	struct aead_request *aead_req = (void *)aead_req_data;
+	struct aead_request *aead_req;
+	int err;
 
 	if (data_len == 0)
 		return -EINVAL;
 
-	memset(aead_req, 0, sizeof(aead_req_data));
+	aead_req = aead_request_alloc(tfm, GFP_ATOMIC);
+	if (!aead_req)
+		return -ENOMEM;
 
 	sg_init_table(sg, 3);
 	sg_set_buf(&sg[0], &aad[2], be16_to_cpup((__be16 *)aad));
 	sg_set_buf(&sg[1], data, data_len);
 	sg_set_buf(&sg[2], mic, IEEE80211_GCMP_MIC_LEN);
 
-	aead_request_set_tfm(aead_req, tfm);
 	aead_request_set_crypt(aead_req, sg, sg,
 			       data_len + IEEE80211_GCMP_MIC_LEN, j_0);
 	aead_request_set_ad(aead_req, sg[0].length);
 
-	return crypto_aead_decrypt(aead_req);
+	err = crypto_aead_decrypt(aead_req);
+	aead_request_free(aead_req);
+
+	return err;
 }
 
 struct crypto_aead *ieee80211_aes_gcm_key_setup_encrypt(const u8 key[],
diff --git a/net/mac80211/aes_gcm.h b/net/mac80211/aes_gcm.h
index 1347fda6b76a..b36503cd7716 100644
--- a/net/mac80211/aes_gcm.h
+++ b/net/mac80211/aes_gcm.h
@@ -11,8 +11,8 @@
 
 #include <linux/crypto.h>
 
-void ieee80211_aes_gcm_encrypt(struct crypto_aead *tfm, u8 *j_0, u8 *aad,
-			       u8 *data, size_t data_len, u8 *mic);
+int ieee80211_aes_gcm_encrypt(struct crypto_aead *tfm, u8 *j_0, u8 *aad,
+			      u8 *data, size_t data_len, u8 *mic);
 int ieee80211_aes_gcm_decrypt(struct crypto_aead *tfm, u8 *j_0, u8 *aad,
 			      u8 *data, size_t data_len, u8 *mic);
 struct crypto_aead *ieee80211_aes_gcm_key_setup_encrypt(const u8 key[],
diff --git a/net/mac80211/aes_gmac.c b/net/mac80211/aes_gmac.c
index 3ddd927aaf30..6951af9715c0 100644
--- a/net/mac80211/aes_gmac.c
+++ b/net/mac80211/aes_gmac.c
@@ -25,16 +25,15 @@ int ieee80211_aes_gmac(struct crypto_aead *tfm, const u8 *aad, u8 *nonce,
 		       const u8 *data, size_t data_len, u8 *mic)
 {
 	struct scatterlist sg[4];
-	char aead_req_data[sizeof(struct aead_request) +
-			   crypto_aead_reqsize(tfm)]
-		__aligned(__alignof__(struct aead_request));
-	struct aead_request *aead_req = (void *)aead_req_data;
 	u8 zero[GMAC_MIC_LEN], iv[AES_BLOCK_SIZE];
+	struct aead_request *aead_req;
 
 	if (data_len < GMAC_MIC_LEN)
 		return -EINVAL;
 
-	memset(aead_req, 0, sizeof(aead_req_data));
+	aead_req = aead_request_alloc(tfm, GFP_ATOMIC);
+	if (!aead_req)
+		return -ENOMEM;
 
 	memset(zero, 0, GMAC_MIC_LEN);
 	sg_init_table(sg, 4);
@@ -47,11 +46,11 @@ int ieee80211_aes_gmac(struct crypto_aead *tfm, const u8 *aad, u8 *nonce,
 	memset(iv + GMAC_NONCE_LEN, 0, sizeof(iv) - GMAC_NONCE_LEN);
 	iv[AES_BLOCK_SIZE - 1] = 0x01;
 
-	aead_request_set_tfm(aead_req, tfm);
 	aead_request_set_crypt(aead_req, sg, sg, 0, iv);
 	aead_request_set_ad(aead_req, AAD_LEN + data_len);
 
 	crypto_aead_encrypt(aead_req);
+	aead_request_free(aead_req);
 
 	return 0;
 }
diff --git a/net/mac80211/wpa.c b/net/mac80211/wpa.c
index b48c1e13e281..2e366438f8ef 100644
--- a/net/mac80211/wpa.c
+++ b/net/mac80211/wpa.c
@@ -461,10 +461,8 @@ static int ccmp_encrypt_skb(struct ieee80211_tx_data *tx, struct sk_buff *skb,
 
 	pos += IEEE80211_CCMP_HDR_LEN;
 	ccmp_special_blocks(skb, pn, b_0, aad);
-	ieee80211_aes_ccm_encrypt(key->u.ccmp.tfm, b_0, aad, pos, len,
-				  skb_put(skb, mic_len), mic_len);
-
-	return 0;
+	return ieee80211_aes_ccm_encrypt(key->u.ccmp.tfm, b_0, aad, pos, len,
+					 skb_put(skb, mic_len), mic_len);
 }
 
 
@@ -696,10 +694,8 @@ static int gcmp_encrypt_skb(struct ieee80211_tx_data *tx, struct sk_buff *skb)
 
 	pos += IEEE80211_GCMP_HDR_LEN;
 	gcmp_special_blocks(skb, pn, j_0, aad);
-	ieee80211_aes_gcm_encrypt(key->u.gcmp.tfm, j_0, aad, pos, len,
-				  skb_put(skb, IEEE80211_GCMP_MIC_LEN));
-
-	return 0;
+	return ieee80211_aes_gcm_encrypt(key->u.gcmp.tfm, j_0, aad, pos, len,
+					 skb_put(skb, IEEE80211_GCMP_MIC_LEN));
 }
 
 ieee80211_tx_result
-- 
2.8.1
