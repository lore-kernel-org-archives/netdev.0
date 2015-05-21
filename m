From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 7/7] mac80211: Switch to new AEAD interface
Date: Thu, 21 May 2015 18:44:10 +0800
Message-ID: <E1YvNxS-00063i-AZ@gondolin.me.apana.org.au>
References: <20150521103938.GA23035@gondor.apana.org.au>
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes use of the new AEAD interface which uses a single
SG list instead of separate lists for the AD and plain text.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/mac80211/aes_ccm.c  |   30 ++++++++++++++----------------
 net/mac80211/aes_gcm.c  |   30 ++++++++++++++----------------
 net/mac80211/aes_gmac.c |   14 +++++---------
 3 files changed, 33 insertions(+), 41 deletions(-)

diff --git a/net/mac80211/aes_ccm.c b/net/mac80211/aes_ccm.c
index 70d53da..42575ef 100644
--- a/net/mac80211/aes_ccm.c
+++ b/net/mac80211/aes_ccm.c
@@ -22,7 +22,7 @@ void ieee80211_aes_ccm_encrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
 			       u8 *data, size_t data_len, u8 *mic,
 			       size_t mic_len)
 {
-	struct scatterlist assoc, pt, ct[2];
+	struct scatterlist sg[3];
 
 	char aead_req_data[sizeof(struct aead_request) +
 			   crypto_aead_reqsize(tfm)]
@@ -31,15 +31,14 @@ void ieee80211_aes_ccm_encrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
 
 	memset(aead_req, 0, sizeof(aead_req_data));
 
-	sg_init_one(&pt, data, data_len);
-	sg_init_one(&assoc, &aad[2], be16_to_cpup((__be16 *)aad));
-	sg_init_table(ct, 2);
-	sg_set_buf(&ct[0], data, data_len);
-	sg_set_buf(&ct[1], mic, mic_len);
+	sg_init_table(sg, 3);
+	sg_set_buf(&sg[0], &aad[2], be16_to_cpup((__be16 *)aad));
+	sg_set_buf(&sg[1], data, data_len);
+	sg_set_buf(&sg[2], mic, mic_len);
 
 	aead_request_set_tfm(aead_req, tfm);
-	aead_request_set_assoc(aead_req, &assoc, assoc.length);
-	aead_request_set_crypt(aead_req, &pt, ct, data_len, b_0);
+	aead_request_set_crypt(aead_req, sg, sg, data_len, b_0);
+	aead_request_set_ad(aead_req, sg[0].length, 0);
 
 	crypto_aead_encrypt(aead_req);
 }
@@ -48,7 +47,7 @@ int ieee80211_aes_ccm_decrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
 			      u8 *data, size_t data_len, u8 *mic,
 			      size_t mic_len)
 {
-	struct scatterlist assoc, pt, ct[2];
+	struct scatterlist sg[3];
 	char aead_req_data[sizeof(struct aead_request) +
 			   crypto_aead_reqsize(tfm)]
 		__aligned(__alignof__(struct aead_request));
@@ -59,15 +58,14 @@ int ieee80211_aes_ccm_decrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
 
 	memset(aead_req, 0, sizeof(aead_req_data));
 
-	sg_init_one(&pt, data, data_len);
-	sg_init_one(&assoc, &aad[2], be16_to_cpup((__be16 *)aad));
-	sg_init_table(ct, 2);
-	sg_set_buf(&ct[0], data, data_len);
-	sg_set_buf(&ct[1], mic, mic_len);
+	sg_init_table(sg, 3);
+	sg_set_buf(&sg[0], &aad[2], be16_to_cpup((__be16 *)aad));
+	sg_set_buf(&sg[1], data, data_len);
+	sg_set_buf(&sg[2], mic, mic_len);
 
 	aead_request_set_tfm(aead_req, tfm);
-	aead_request_set_assoc(aead_req, &assoc, assoc.length);
-	aead_request_set_crypt(aead_req, ct, &pt, data_len + mic_len, b_0);
+	aead_request_set_crypt(aead_req, sg, sg, data_len + mic_len, b_0);
+	aead_request_set_ad(aead_req, sg[0].length, 0);
 
 	return crypto_aead_decrypt(aead_req);
 }
diff --git a/net/mac80211/aes_gcm.c b/net/mac80211/aes_gcm.c
index b91c9d7..12dcd66 100644
--- a/net/mac80211/aes_gcm.c
+++ b/net/mac80211/aes_gcm.c
@@ -18,7 +18,7 @@
 void ieee80211_aes_gcm_encrypt(struct crypto_aead *tfm, u8 *j_0, u8 *aad,
 			       u8 *data, size_t data_len, u8 *mic)
 {
-	struct scatterlist assoc, pt, ct[2];
+	struct scatterlist sg[3];
 
 	char aead_req_data[sizeof(struct aead_request) +
 			   crypto_aead_reqsize(tfm)]
@@ -27,15 +27,14 @@ void ieee80211_aes_gcm_encrypt(struct crypto_aead *tfm, u8 *j_0, u8 *aad,
 
 	memset(aead_req, 0, sizeof(aead_req_data));
 
-	sg_init_one(&pt, data, data_len);
-	sg_init_one(&assoc, &aad[2], be16_to_cpup((__be16 *)aad));
-	sg_init_table(ct, 2);
-	sg_set_buf(&ct[0], data, data_len);
-	sg_set_buf(&ct[1], mic, IEEE80211_GCMP_MIC_LEN);
+	sg_init_table(sg, 3);
+	sg_set_buf(&sg[0], &aad[2], be16_to_cpup((__be16 *)aad));
+	sg_set_buf(&sg[1], data, data_len);
+	sg_set_buf(&sg[2], mic, IEEE80211_GCMP_MIC_LEN);
 
 	aead_request_set_tfm(aead_req, tfm);
-	aead_request_set_assoc(aead_req, &assoc, assoc.length);
-	aead_request_set_crypt(aead_req, &pt, ct, data_len, j_0);
+	aead_request_set_crypt(aead_req, sg, sg, data_len, j_0);
+	aead_request_set_ad(aead_req, sg[0].length, 0);
 
 	crypto_aead_encrypt(aead_req);
 }
@@ -43,7 +42,7 @@ void ieee80211_aes_gcm_encrypt(struct crypto_aead *tfm, u8 *j_0, u8 *aad,
 int ieee80211_aes_gcm_decrypt(struct crypto_aead *tfm, u8 *j_0, u8 *aad,
 			      u8 *data, size_t data_len, u8 *mic)
 {
-	struct scatterlist assoc, pt, ct[2];
+	struct scatterlist sg[3];
 	char aead_req_data[sizeof(struct aead_request) +
 			   crypto_aead_reqsize(tfm)]
 		__aligned(__alignof__(struct aead_request));
@@ -54,16 +53,15 @@ int ieee80211_aes_gcm_decrypt(struct crypto_aead *tfm, u8 *j_0, u8 *aad,
 
 	memset(aead_req, 0, sizeof(aead_req_data));
 
-	sg_init_one(&pt, data, data_len);
-	sg_init_one(&assoc, &aad[2], be16_to_cpup((__be16 *)aad));
-	sg_init_table(ct, 2);
-	sg_set_buf(&ct[0], data, data_len);
-	sg_set_buf(&ct[1], mic, IEEE80211_GCMP_MIC_LEN);
+	sg_init_table(sg, 3);
+	sg_set_buf(&sg[0], &aad[2], be16_to_cpup((__be16 *)aad));
+	sg_set_buf(&sg[1], data, data_len);
+	sg_set_buf(&sg[2], mic, IEEE80211_GCMP_MIC_LEN);
 
 	aead_request_set_tfm(aead_req, tfm);
-	aead_request_set_assoc(aead_req, &assoc, assoc.length);
-	aead_request_set_crypt(aead_req, ct, &pt,
+	aead_request_set_crypt(aead_req, sg, sg,
 			       data_len + IEEE80211_GCMP_MIC_LEN, j_0);
+	aead_request_set_ad(aead_req, sg[0].length, 0);
 
 	return crypto_aead_decrypt(aead_req);
 }
diff --git a/net/mac80211/aes_gmac.c b/net/mac80211/aes_gmac.c
index c34b06ca..7eee32b 100644
--- a/net/mac80211/aes_gmac.c
+++ b/net/mac80211/aes_gmac.c
@@ -24,34 +24,30 @@
 int ieee80211_aes_gmac(struct crypto_aead *tfm, const u8 *aad, u8 *nonce,
 		       const u8 *data, size_t data_len, u8 *mic)
 {
-	struct scatterlist sg[3], ct[1];
+	struct scatterlist sg[3];
 	char aead_req_data[sizeof(struct aead_request) +
 			   crypto_aead_reqsize(tfm)]
 		__aligned(__alignof__(struct aead_request));
 	struct aead_request *aead_req = (void *)aead_req_data;
-	u8 zero[GMAC_MIC_LEN], iv[AES_BLOCK_SIZE];
+	u8 iv[AES_BLOCK_SIZE];
 
 	if (data_len < GMAC_MIC_LEN)
 		return -EINVAL;
 
 	memset(aead_req, 0, sizeof(aead_req_data));
 
-	memset(zero, 0, GMAC_MIC_LEN);
 	sg_init_table(sg, 3);
 	sg_set_buf(&sg[0], aad, AAD_LEN);
 	sg_set_buf(&sg[1], data, data_len - GMAC_MIC_LEN);
-	sg_set_buf(&sg[2], zero, GMAC_MIC_LEN);
+	sg_set_buf(&sg[2], mic, GMAC_MIC_LEN);
 
 	memcpy(iv, nonce, GMAC_NONCE_LEN);
 	memset(iv + GMAC_NONCE_LEN, 0, sizeof(iv) - GMAC_NONCE_LEN);
 	iv[AES_BLOCK_SIZE - 1] = 0x01;
 
-	sg_init_table(ct, 1);
-	sg_set_buf(&ct[0], mic, GMAC_MIC_LEN);
-
 	aead_request_set_tfm(aead_req, tfm);
-	aead_request_set_assoc(aead_req, sg, AAD_LEN + data_len);
-	aead_request_set_crypt(aead_req, NULL, ct, 0, iv);
+	aead_request_set_crypt(aead_req, sg, sg, 0, iv);
+	aead_request_set_ad(aead_req, AAD_LEN + data_len, 0);
 
 	crypto_aead_encrypt(aead_req);
 
