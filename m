From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [RFC PATCH 1/2] mac80211: aes_ccm: prepare key struct for storing context data
Date: Tue, 18 Oct 2016 15:08:32 +0100
Message-ID: <1476799713-16188-2-git-send-email-ard.biesheuvel@linaro.org>
References: <1476799713-16188-1-git-send-email-ard.biesheuvel@linaro.org>
Cc: herbert@gondor.apana.org.au, j@w1.fi, luto@amacapital.net,
        Ard Biesheuvel <ard.biesheuvel@linaro.org>
To: linux-wireless@vger.kernel.org, johannes@sipsolutions.net,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:33737 "EHLO
        mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758891AbcJROIo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 10:08:44 -0400
Received: by mail-qk0-f172.google.com with SMTP id n189so294583023qke.0
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2016 07:08:43 -0700 (PDT)
In-Reply-To: <1476799713-16188-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As a prepatory change to allow per CPU caching of request structures,
refactor the key allocation routine so we can access per key data
beyond the core AEAD transform easily.

Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 net/mac80211/aes_ccm.c | 35 +++++++++++---------
 net/mac80211/aes_ccm.h | 16 ++++-----
 net/mac80211/key.c     | 16 ++++-----
 net/mac80211/key.h     |  2 +-
 net/mac80211/wpa.c     |  4 +--
 5 files changed, 37 insertions(+), 36 deletions(-)

diff --git a/net/mac80211/aes_ccm.c b/net/mac80211/aes_ccm.c
index a4e0d59a40dd..58e0338a2c34 100644
--- a/net/mac80211/aes_ccm.c
+++ b/net/mac80211/aes_ccm.c
@@ -10,6 +10,7 @@
  */
 
 #include <linux/kernel.h>
+#include <linux/percpu.h>
 #include <linux/types.h>
 #include <linux/err.h>
 #include <crypto/aead.h>
@@ -18,13 +19,13 @@
 #include "key.h"
 #include "aes_ccm.h"
 
-int ieee80211_aes_ccm_encrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
-			      u8 *data, size_t data_len, u8 *mic,
+int ieee80211_aes_ccm_encrypt(struct ieee80211_ccmp_aead *ccmp, u8 *b_0,
+			      u8 *aad, u8 *data, size_t data_len, u8 *mic,
 			      size_t mic_len)
 {
 	struct scatterlist sg[3];
 	struct aead_request *aead_req;
-	int reqsize = sizeof(*aead_req) + crypto_aead_reqsize(tfm);
+	int reqsize = sizeof(*aead_req) + crypto_aead_reqsize(ccmp->tfm);
 	u8 *__aad;
 
 	aead_req = kzalloc(reqsize + CCM_AAD_LEN, GFP_ATOMIC);
@@ -39,7 +40,7 @@ int ieee80211_aes_ccm_encrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
 	sg_set_buf(&sg[1], data, data_len);
 	sg_set_buf(&sg[2], mic, mic_len);
 
-	aead_request_set_tfm(aead_req, tfm);
+	aead_request_set_tfm(aead_req, ccmp->tfm);
 	aead_request_set_crypt(aead_req, sg, sg, data_len, b_0);
 	aead_request_set_ad(aead_req, sg[0].length);
 
@@ -49,13 +50,13 @@ int ieee80211_aes_ccm_encrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
 	return 0;
 }
 
-int ieee80211_aes_ccm_decrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
-			      u8 *data, size_t data_len, u8 *mic,
+int ieee80211_aes_ccm_decrypt(struct ieee80211_ccmp_aead *ccmp, u8 *b_0,
+			      u8 *aad, u8 *data, size_t data_len, u8 *mic,
 			      size_t mic_len)
 {
 	struct scatterlist sg[3];
 	struct aead_request *aead_req;
-	int reqsize = sizeof(*aead_req) + crypto_aead_reqsize(tfm);
+	int reqsize = sizeof(*aead_req) + crypto_aead_reqsize(ccmp->tfm);
 	u8 *__aad;
 	int err;
 
@@ -74,7 +75,7 @@ int ieee80211_aes_ccm_decrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
 	sg_set_buf(&sg[1], data, data_len);
 	sg_set_buf(&sg[2], mic, mic_len);
 
-	aead_request_set_tfm(aead_req, tfm);
+	aead_request_set_tfm(aead_req, ccmp->tfm);
 	aead_request_set_crypt(aead_req, sg, sg, data_len + mic_len, b_0);
 	aead_request_set_ad(aead_req, sg[0].length);
 
@@ -84,16 +85,17 @@ int ieee80211_aes_ccm_decrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
 	return err;
 }
 
-struct crypto_aead *ieee80211_aes_key_setup_encrypt(const u8 key[],
-						    size_t key_len,
-						    size_t mic_len)
+int ieee80211_aes_key_setup_encrypt(struct ieee80211_ccmp_aead *ccmp,
+				    const u8 key[],
+				    size_t key_len,
+				    size_t mic_len)
 {
 	struct crypto_aead *tfm;
 	int err;
 
 	tfm = crypto_alloc_aead("ccm(aes)", 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(tfm))
-		return tfm;
+		return PTR_ERR(tfm);
 
 	err = crypto_aead_setkey(tfm, key, key_len);
 	if (err)
@@ -102,14 +104,15 @@ struct crypto_aead *ieee80211_aes_key_setup_encrypt(const u8 key[],
 	if (err)
 		goto free_aead;
 
-	return tfm;
+	ccmp->tfm = tfm;
+	return 0;
 
 free_aead:
 	crypto_free_aead(tfm);
-	return ERR_PTR(err);
+	return err;
 }
 
-void ieee80211_aes_key_free(struct crypto_aead *tfm)
+void ieee80211_aes_key_free(struct ieee80211_ccmp_aead *ccmp)
 {
-	crypto_free_aead(tfm);
+	crypto_free_aead(ccmp->tfm);
 }
diff --git a/net/mac80211/aes_ccm.h b/net/mac80211/aes_ccm.h
index fcd3254c5cf0..82e91c6ec41f 100644
--- a/net/mac80211/aes_ccm.h
+++ b/net/mac80211/aes_ccm.h
@@ -14,15 +14,15 @@
 
 #define CCM_AAD_LEN	32
 
-struct crypto_aead *ieee80211_aes_key_setup_encrypt(const u8 key[],
-						    size_t key_len,
-						    size_t mic_len);
-int ieee80211_aes_ccm_encrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
-			      u8 *data, size_t data_len, u8 *mic,
+int ieee80211_aes_key_setup_encrypt(struct ieee80211_ccmp_aead *ccmp,
+				    const u8 key[], size_t key_len,
+				    size_t mic_len);
+int ieee80211_aes_ccm_encrypt(struct ieee80211_ccmp_aead *ccmp, u8 *b_0,
+			      u8 *aad, u8 *data, size_t data_len, u8 *mic,
 			      size_t mic_len);
-int ieee80211_aes_ccm_decrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
-			      u8 *data, size_t data_len, u8 *mic,
+int ieee80211_aes_ccm_decrypt(struct ieee80211_ccmp_aead *ccmp, u8 *b_0,
+			      u8 *aad, u8 *data, size_t data_len, u8 *mic,
 			      size_t mic_len);
-void ieee80211_aes_key_free(struct crypto_aead *tfm);
+void ieee80211_aes_key_free(struct ieee80211_ccmp_aead *ccmp);
 
 #endif /* AES_CCM_H */
diff --git a/net/mac80211/key.c b/net/mac80211/key.c
index edd6f2945f69..6d1a066e3c4e 100644
--- a/net/mac80211/key.c
+++ b/net/mac80211/key.c
@@ -431,10 +431,9 @@ ieee80211_key_alloc(u32 cipher, int idx, size_t key_len,
 		 * Initialize AES key state here as an optimization so that
 		 * it does not need to be initialized for every packet.
 		 */
-		key->u.ccmp.tfm = ieee80211_aes_key_setup_encrypt(
-			key_data, key_len, IEEE80211_CCMP_MIC_LEN);
-		if (IS_ERR(key->u.ccmp.tfm)) {
-			err = PTR_ERR(key->u.ccmp.tfm);
+		err = ieee80211_aes_key_setup_encrypt(&key->u.ccmp, key_data,
+					key_len, IEEE80211_CCMP_MIC_LEN);
+		if (err) {
 			kfree(key);
 			return ERR_PTR(err);
 		}
@@ -449,10 +448,9 @@ ieee80211_key_alloc(u32 cipher, int idx, size_t key_len,
 		/* Initialize AES key state here as an optimization so that
 		 * it does not need to be initialized for every packet.
 		 */
-		key->u.ccmp.tfm = ieee80211_aes_key_setup_encrypt(
-			key_data, key_len, IEEE80211_CCMP_256_MIC_LEN);
-		if (IS_ERR(key->u.ccmp.tfm)) {
-			err = PTR_ERR(key->u.ccmp.tfm);
+		err = ieee80211_aes_key_setup_encrypt(&key->u.ccmp, key_data,
+					key_len, IEEE80211_CCMP_256_MIC_LEN);
+		if (err) {
 			kfree(key);
 			return ERR_PTR(err);
 		}
@@ -545,7 +543,7 @@ static void ieee80211_key_free_common(struct ieee80211_key *key)
 	switch (key->conf.cipher) {
 	case WLAN_CIPHER_SUITE_CCMP:
 	case WLAN_CIPHER_SUITE_CCMP_256:
-		ieee80211_aes_key_free(key->u.ccmp.tfm);
+		ieee80211_aes_key_free(&key->u.ccmp);
 		break;
 	case WLAN_CIPHER_SUITE_AES_CMAC:
 	case WLAN_CIPHER_SUITE_BIP_CMAC_256:
diff --git a/net/mac80211/key.h b/net/mac80211/key.h
index 4aa20cef0859..1ec7a737ab79 100644
--- a/net/mac80211/key.h
+++ b/net/mac80211/key.h
@@ -80,7 +80,7 @@ struct ieee80211_key {
 			/* number of mic failures */
 			u32 mic_failures;
 		} tkip;
-		struct {
+		struct ieee80211_ccmp_aead {
 			/*
 			 * Last received packet number. The first
 			 * IEEE80211_NUM_TIDS counters are used with Data
diff --git a/net/mac80211/wpa.c b/net/mac80211/wpa.c
index 14b28998c571..694af013494f 100644
--- a/net/mac80211/wpa.c
+++ b/net/mac80211/wpa.c
@@ -461,7 +461,7 @@ static int ccmp_encrypt_skb(struct ieee80211_tx_data *tx, struct sk_buff *skb,
 
 	pos += IEEE80211_CCMP_HDR_LEN;
 	ccmp_special_blocks(skb, pn, b_0, aad);
-	return ieee80211_aes_ccm_encrypt(key->u.ccmp.tfm, b_0, aad, pos, len,
+	return ieee80211_aes_ccm_encrypt(&key->u.ccmp, b_0, aad, pos, len,
 					 skb_put(skb, mic_len), mic_len);
 }
 
@@ -538,7 +538,7 @@ ieee80211_crypto_ccmp_decrypt(struct ieee80211_rx_data *rx,
 			ccmp_special_blocks(skb, pn, b_0, aad);
 
 			if (ieee80211_aes_ccm_decrypt(
-				    key->u.ccmp.tfm, b_0, aad,
+				    &key->u.ccmp, b_0, aad,
 				    skb->data + hdrlen + IEEE80211_CCMP_HDR_LEN,
 				    data_len,
 				    skb->data + skb->len - mic_len, mic_len))
-- 
2.7.4
