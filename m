From: Ard Biesheuvel <ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH v4] mac80211: move struct aead_req off the stack
Date: Mon, 17 Oct 2016 15:05:33 +0100
Message-ID: <1476713133-18355-1-git-send-email-ard.biesheuvel@linaro.org>
Cc: herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, sergey.senozhatsky.work-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Ard Biesheuvel <ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

Some crypto implementations (such as the generic CCM wrapper in crypto/)
use scatterlists to map fields of private data in their struct aead_req.
This means these data structures cannot live in the vmalloc area, which
means that they cannot live on the stack (with CONFIG_VMAP_STACK.)

This currently occurs only with the generic software implementation, but
the private data and usage is implementation specific, so move the whole
data structures off the stack into heap by allocating every time we need
to use them.

In addition, take care not to put any of our own stack allocations into
scatterlists. This involves reserving some extra room when allocating the
aead_request structures, and referring to those allocations in the scatter-
lists (while copying the data from/to the stack before/after the crypto
operation, as appropriate)

Signed-off-by: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Ard Biesheuvel <ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
---
 net/mac80211/aes_ccm.c  | 46 +++++++++++++-------
 net/mac80211/aes_ccm.h  |  8 ++--
 net/mac80211/aes_cmac.c |  5 +--
 net/mac80211/aes_cmac.h |  2 +
 net/mac80211/aes_gcm.c  | 43 +++++++++++-------
 net/mac80211/aes_gcm.h  |  6 ++-
 net/mac80211/aes_gmac.c | 26 +++++------
 net/mac80211/aes_gmac.h |  4 ++
 net/mac80211/wpa.c      | 22 ++++------
 9 files changed, 97 insertions(+), 65 deletions(-)

diff --git a/net/mac80211/aes_ccm.c b/net/mac80211/aes_ccm.c
index 7663c28ba353..a4e0d59a40dd 100644
--- a/net/mac80211/aes_ccm.c
+++ b/net/mac80211/aes_ccm.c
@@ -18,21 +18,24 @@
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
+	int reqsize = sizeof(*aead_req) + crypto_aead_reqsize(tfm);
+	u8 *__aad;
 
-	char aead_req_data[sizeof(struct aead_request) +
-			   crypto_aead_reqsize(tfm)]
-		__aligned(__alignof__(struct aead_request));
-	struct aead_request *aead_req = (void *) aead_req_data;
+	aead_req = kzalloc(reqsize + CCM_AAD_LEN, GFP_ATOMIC);
+	if (!aead_req)
+		return -ENOMEM;
 
-	memset(aead_req, 0, sizeof(aead_req_data));
+	__aad = (u8 *)aead_req + reqsize;
+	memcpy(__aad, aad, CCM_AAD_LEN);
 
 	sg_init_table(sg, 3);
-	sg_set_buf(&sg[0], &aad[2], be16_to_cpup((__be16 *)aad));
+	sg_set_buf(&sg[0], &__aad[2], be16_to_cpup((__be16 *)__aad));
 	sg_set_buf(&sg[1], data, data_len);
 	sg_set_buf(&sg[2], mic, mic_len);
 
@@ -41,6 +44,9 @@ void ieee80211_aes_ccm_encrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
 	aead_request_set_ad(aead_req, sg[0].length);
 
 	crypto_aead_encrypt(aead_req);
+	kzfree(aead_req);
+
+	return 0;
 }
 
 int ieee80211_aes_ccm_decrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
@@ -48,18 +54,23 @@ int ieee80211_aes_ccm_decrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
 			      size_t mic_len)
 {
 	struct scatterlist sg[3];
-	char aead_req_data[sizeof(struct aead_request) +
-			   crypto_aead_reqsize(tfm)]
-		__aligned(__alignof__(struct aead_request));
-	struct aead_request *aead_req = (void *) aead_req_data;
+	struct aead_request *aead_req;
+	int reqsize = sizeof(*aead_req) + crypto_aead_reqsize(tfm);
+	u8 *__aad;
+	int err;
 
 	if (data_len == 0)
 		return -EINVAL;
 
-	memset(aead_req, 0, sizeof(aead_req_data));
+	aead_req = kzalloc(reqsize + CCM_AAD_LEN, GFP_ATOMIC);
+	if (!aead_req)
+		return -ENOMEM;
+
+	__aad = (u8 *)aead_req + reqsize;
+	memcpy(__aad, aad, CCM_AAD_LEN);
 
 	sg_init_table(sg, 3);
-	sg_set_buf(&sg[0], &aad[2], be16_to_cpup((__be16 *)aad));
+	sg_set_buf(&sg[0], &__aad[2], be16_to_cpup((__be16 *)__aad));
 	sg_set_buf(&sg[1], data, data_len);
 	sg_set_buf(&sg[2], mic, mic_len);
 
@@ -67,7 +78,10 @@ int ieee80211_aes_ccm_decrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
 	aead_request_set_crypt(aead_req, sg, sg, data_len + mic_len, b_0);
 	aead_request_set_ad(aead_req, sg[0].length);
 
-	return crypto_aead_decrypt(aead_req);
+	err = crypto_aead_decrypt(aead_req);
+	kzfree(aead_req);
+
+	return err;
 }
 
 struct crypto_aead *ieee80211_aes_key_setup_encrypt(const u8 key[],
diff --git a/net/mac80211/aes_ccm.h b/net/mac80211/aes_ccm.h
index 6a73d1e4d186..fcd3254c5cf0 100644
--- a/net/mac80211/aes_ccm.h
+++ b/net/mac80211/aes_ccm.h
@@ -12,12 +12,14 @@
 
 #include <linux/crypto.h>
 
+#define CCM_AAD_LEN	32
+
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
diff --git a/net/mac80211/aes_cmac.c b/net/mac80211/aes_cmac.c
index bdf0790d89cc..ebb8c2dc9928 100644
--- a/net/mac80211/aes_cmac.c
+++ b/net/mac80211/aes_cmac.c
@@ -20,7 +20,6 @@
 
 #define CMAC_TLEN 8 /* CMAC TLen = 64 bits (8 octets) */
 #define CMAC_TLEN_256 16 /* CMAC TLen = 128 bits (16 octets) */
-#define AAD_LEN 20
 
 
 static void gf_mulx(u8 *pad)
@@ -101,7 +100,7 @@ void ieee80211_aes_cmac(struct crypto_cipher *tfm, const u8 *aad,
 
 	memset(zero, 0, CMAC_TLEN);
 	addr[0] = aad;
-	len[0] = AAD_LEN;
+	len[0] = CMAC_AAD_LEN;
 	addr[1] = data;
 	len[1] = data_len - CMAC_TLEN;
 	addr[2] = zero;
@@ -119,7 +118,7 @@ void ieee80211_aes_cmac_256(struct crypto_cipher *tfm, const u8 *aad,
 
 	memset(zero, 0, CMAC_TLEN_256);
 	addr[0] = aad;
-	len[0] = AAD_LEN;
+	len[0] = CMAC_AAD_LEN;
 	addr[1] = data;
 	len[1] = data_len - CMAC_TLEN_256;
 	addr[2] = zero;
diff --git a/net/mac80211/aes_cmac.h b/net/mac80211/aes_cmac.h
index 3702041f44fd..0afb17aa2914 100644
--- a/net/mac80211/aes_cmac.h
+++ b/net/mac80211/aes_cmac.h
@@ -11,6 +11,8 @@
 
 #include <linux/crypto.h>
 
+#define CMAC_AAD_LEN	20
+
 struct crypto_cipher *ieee80211_aes_cmac_key_setup(const u8 key[],
 						   size_t key_len);
 void ieee80211_aes_cmac(struct crypto_cipher *tfm, const u8 *aad,
diff --git a/net/mac80211/aes_gcm.c b/net/mac80211/aes_gcm.c
index 3afe361fd27c..8a4397cc1b08 100644
--- a/net/mac80211/aes_gcm.c
+++ b/net/mac80211/aes_gcm.c
@@ -15,20 +15,23 @@
 #include "key.h"
 #include "aes_gcm.h"
 
-void ieee80211_aes_gcm_encrypt(struct crypto_aead *tfm, u8 *j_0, u8 *aad,
-			       u8 *data, size_t data_len, u8 *mic)
+int ieee80211_aes_gcm_encrypt(struct crypto_aead *tfm, u8 *j_0, u8 *aad,
+			      u8 *data, size_t data_len, u8 *mic)
 {
 	struct scatterlist sg[3];
+	struct aead_request *aead_req;
+	int reqsize = sizeof(*aead_req) + crypto_aead_reqsize(tfm);
+	u8 *__aad;
 
-	char aead_req_data[sizeof(struct aead_request) +
-			   crypto_aead_reqsize(tfm)]
-		__aligned(__alignof__(struct aead_request));
-	struct aead_request *aead_req = (void *)aead_req_data;
+	aead_req = kzalloc(reqsize + GCM_AAD_LEN, GFP_ATOMIC);
+	if (!aead_req)
+		return -ENOMEM;
 
-	memset(aead_req, 0, sizeof(aead_req_data));
+	__aad = (u8 *)aead_req + reqsize;
+	memcpy(__aad, aad, GCM_AAD_LEN);
 
 	sg_init_table(sg, 3);
-	sg_set_buf(&sg[0], &aad[2], be16_to_cpup((__be16 *)aad));
+	sg_set_buf(&sg[0], &__aad[2], be16_to_cpup((__be16 *)__aad));
 	sg_set_buf(&sg[1], data, data_len);
 	sg_set_buf(&sg[2], mic, IEEE80211_GCMP_MIC_LEN);
 
@@ -37,24 +40,31 @@ void ieee80211_aes_gcm_encrypt(struct crypto_aead *tfm, u8 *j_0, u8 *aad,
 	aead_request_set_ad(aead_req, sg[0].length);
 
 	crypto_aead_encrypt(aead_req);
+	kzfree(aead_req);
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
+	int reqsize = sizeof(*aead_req) + crypto_aead_reqsize(tfm);
+	u8 *__aad;
+	int err;
 
 	if (data_len == 0)
 		return -EINVAL;
 
-	memset(aead_req, 0, sizeof(aead_req_data));
+	aead_req = kzalloc(reqsize + GCM_AAD_LEN, GFP_ATOMIC);
+	if (!aead_req)
+		return -ENOMEM;
+
+	__aad = (u8 *)aead_req + reqsize;
+	memcpy(__aad, aad, GCM_AAD_LEN);
 
 	sg_init_table(sg, 3);
-	sg_set_buf(&sg[0], &aad[2], be16_to_cpup((__be16 *)aad));
+	sg_set_buf(&sg[0], &__aad[2], be16_to_cpup((__be16 *)__aad));
 	sg_set_buf(&sg[1], data, data_len);
 	sg_set_buf(&sg[2], mic, IEEE80211_GCMP_MIC_LEN);
 
@@ -63,7 +73,10 @@ int ieee80211_aes_gcm_decrypt(struct crypto_aead *tfm, u8 *j_0, u8 *aad,
 			       data_len + IEEE80211_GCMP_MIC_LEN, j_0);
 	aead_request_set_ad(aead_req, sg[0].length);
 
-	return crypto_aead_decrypt(aead_req);
+	err = crypto_aead_decrypt(aead_req);
+	kzfree(aead_req);
+
+	return err;
 }
 
 struct crypto_aead *ieee80211_aes_gcm_key_setup_encrypt(const u8 key[],
diff --git a/net/mac80211/aes_gcm.h b/net/mac80211/aes_gcm.h
index 1347fda6b76a..55aed5352494 100644
--- a/net/mac80211/aes_gcm.h
+++ b/net/mac80211/aes_gcm.h
@@ -11,8 +11,10 @@
 
 #include <linux/crypto.h>
 
-void ieee80211_aes_gcm_encrypt(struct crypto_aead *tfm, u8 *j_0, u8 *aad,
-			       u8 *data, size_t data_len, u8 *mic);
+#define GCM_AAD_LEN	32
+
+int ieee80211_aes_gcm_encrypt(struct crypto_aead *tfm, u8 *j_0, u8 *aad,
+			      u8 *data, size_t data_len, u8 *mic);
 int ieee80211_aes_gcm_decrypt(struct crypto_aead *tfm, u8 *j_0, u8 *aad,
 			      u8 *data, size_t data_len, u8 *mic);
 struct crypto_aead *ieee80211_aes_gcm_key_setup_encrypt(const u8 key[],
diff --git a/net/mac80211/aes_gmac.c b/net/mac80211/aes_gmac.c
index 3ddd927aaf30..bd72a862ddb7 100644
--- a/net/mac80211/aes_gmac.c
+++ b/net/mac80211/aes_gmac.c
@@ -17,28 +17,27 @@
 #include "key.h"
 #include "aes_gmac.h"
 
-#define GMAC_MIC_LEN 16
-#define GMAC_NONCE_LEN 12
-#define AAD_LEN 20
-
 int ieee80211_aes_gmac(struct crypto_aead *tfm, const u8 *aad, u8 *nonce,
 		       const u8 *data, size_t data_len, u8 *mic)
 {
 	struct scatterlist sg[4];
-	char aead_req_data[sizeof(struct aead_request) +
-			   crypto_aead_reqsize(tfm)]
-		__aligned(__alignof__(struct aead_request));
-	struct aead_request *aead_req = (void *)aead_req_data;
-	u8 zero[GMAC_MIC_LEN], iv[AES_BLOCK_SIZE];
+	u8 *zero, *__aad, iv[AES_BLOCK_SIZE];
+	struct aead_request *aead_req;
+	int reqsize = sizeof(*aead_req) + crypto_aead_reqsize(tfm);
 
 	if (data_len < GMAC_MIC_LEN)
 		return -EINVAL;
 
-	memset(aead_req, 0, sizeof(aead_req_data));
+	aead_req = kzalloc(reqsize + GMAC_MIC_LEN + GMAC_AAD_LEN, GFP_ATOMIC);
+	if (!aead_req)
+		return -ENOMEM;
+
+	zero = (u8 *)aead_req + reqsize;
+	__aad = zero + GMAC_MIC_LEN;
+	memcpy(__aad, aad, GMAC_AAD_LEN);
 
-	memset(zero, 0, GMAC_MIC_LEN);
 	sg_init_table(sg, 4);
-	sg_set_buf(&sg[0], aad, AAD_LEN);
+	sg_set_buf(&sg[0], __aad, GMAC_AAD_LEN);
 	sg_set_buf(&sg[1], data, data_len - GMAC_MIC_LEN);
 	sg_set_buf(&sg[2], zero, GMAC_MIC_LEN);
 	sg_set_buf(&sg[3], mic, GMAC_MIC_LEN);
@@ -49,9 +48,10 @@ int ieee80211_aes_gmac(struct crypto_aead *tfm, const u8 *aad, u8 *nonce,
 
 	aead_request_set_tfm(aead_req, tfm);
 	aead_request_set_crypt(aead_req, sg, sg, 0, iv);
-	aead_request_set_ad(aead_req, AAD_LEN + data_len);
+	aead_request_set_ad(aead_req, GMAC_AAD_LEN + data_len);
 
 	crypto_aead_encrypt(aead_req);
+	kzfree(aead_req);
 
 	return 0;
 }
diff --git a/net/mac80211/aes_gmac.h b/net/mac80211/aes_gmac.h
index d328204d73a8..32e6442c95be 100644
--- a/net/mac80211/aes_gmac.h
+++ b/net/mac80211/aes_gmac.h
@@ -11,6 +11,10 @@
 
 #include <linux/crypto.h>
 
+#define GMAC_AAD_LEN	20
+#define GMAC_MIC_LEN	16
+#define GMAC_NONCE_LEN	12
+
 struct crypto_aead *ieee80211_aes_gmac_key_setup(const u8 key[],
 						 size_t key_len);
 int ieee80211_aes_gmac(struct crypto_aead *tfm, const u8 *aad, u8 *nonce,
diff --git a/net/mac80211/wpa.c b/net/mac80211/wpa.c
index b48c1e13e281..14b28998c571 100644
--- a/net/mac80211/wpa.c
+++ b/net/mac80211/wpa.c
@@ -405,7 +405,7 @@ static int ccmp_encrypt_skb(struct ieee80211_tx_data *tx, struct sk_buff *skb,
 	u8 *pos;
 	u8 pn[6];
 	u64 pn64;
-	u8 aad[2 * AES_BLOCK_SIZE];
+	u8 aad[CCM_AAD_LEN];
 	u8 b_0[AES_BLOCK_SIZE];
 
 	if (info->control.hw_key &&
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
 
 
@@ -639,7 +637,7 @@ static int gcmp_encrypt_skb(struct ieee80211_tx_data *tx, struct sk_buff *skb)
 	u8 *pos;
 	u8 pn[6];
 	u64 pn64;
-	u8 aad[2 * AES_BLOCK_SIZE];
+	u8 aad[GCM_AAD_LEN];
 	u8 j_0[AES_BLOCK_SIZE];
 
 	if (info->control.hw_key &&
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
@@ -1123,9 +1119,9 @@ ieee80211_crypto_aes_gmac_encrypt(struct ieee80211_tx_data *tx)
 	struct ieee80211_key *key = tx->key;
 	struct ieee80211_mmie_16 *mmie;
 	struct ieee80211_hdr *hdr;
-	u8 aad[20];
+	u8 aad[GMAC_AAD_LEN];
 	u64 pn64;
-	u8 nonce[12];
+	u8 nonce[GMAC_NONCE_LEN];
 
 	if (WARN_ON(skb_queue_len(&tx->skbs) != 1))
 		return TX_DROP;
@@ -1171,7 +1167,7 @@ ieee80211_crypto_aes_gmac_decrypt(struct ieee80211_rx_data *rx)
 	struct ieee80211_rx_status *status = IEEE80211_SKB_RXCB(skb);
 	struct ieee80211_key *key = rx->key;
 	struct ieee80211_mmie_16 *mmie;
-	u8 aad[20], mic[16], ipn[6], nonce[12];
+	u8 aad[GMAC_AAD_LEN], mic[GMAC_MIC_LEN], ipn[6], nonce[GMAC_NONCE_LEN];
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *)skb->data;
 
 	if (!ieee80211_is_mgmt(hdr->frame_control))
-- 
2.7.4
