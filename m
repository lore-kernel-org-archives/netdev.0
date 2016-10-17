From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH v3] mac80211: move extra crypto data off the stack
Date: Mon, 17 Oct 2016 10:02:22 +0200
Message-ID: <1476691342-22347-1-git-send-email-johannes@sipsolutions.net>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>,
        Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
        netdev@vger.kernel.org, herbert@gondor.apana.org.au,
        Johannes Berg <johannes.berg@intel.com>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:49153 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758435AbcJQICc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Oct 2016 04:02:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

As the stack can (on x86-64) now be virtually mapped rather than
using "normal" kernel memory, Sergey noticed mac80211 isn't using
the SG APIs correctly by putting on-stack buffers into SG tables.
This leads to kernel crashes.

Fix this by allocating a bit of per-CPU memory for the extra data
that encryption/decryption/verification needs, instead of having
it stored on the stack.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 net/mac80211/aes_ccm.c     |  2 --
 net/mac80211/aes_cmac.c    |  5 ++-
 net/mac80211/aes_cmac.h    |  2 ++
 net/mac80211/aes_gcm.c     |  2 --
 net/mac80211/aes_gmac.c    | 10 +++---
 net/mac80211/aes_gmac.h    |  5 ++-
 net/mac80211/ieee80211_i.h |  7 ++++
 net/mac80211/main.c        |  8 +++++
 net/mac80211/wpa.c         | 86 +++++++++++++++++++++++++++++++++++++---------
 9 files changed, 97 insertions(+), 30 deletions(-)

diff --git a/net/mac80211/aes_ccm.c b/net/mac80211/aes_ccm.c
index 5c9fe00be6cc..8e898a6e8de8 100644
--- a/net/mac80211/aes_ccm.c
+++ b/net/mac80211/aes_ccm.c
@@ -34,7 +34,6 @@ int ieee80211_aes_ccm_encrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
 	sg_set_buf(&sg[1], data, data_len);
 	sg_set_buf(&sg[2], mic, mic_len);
 
-	aead_request_set_tfm(aead_req, tfm);
 	aead_request_set_crypt(aead_req, sg, sg, data_len, b_0);
 	aead_request_set_ad(aead_req, sg[0].length);
 
@@ -64,7 +63,6 @@ int ieee80211_aes_ccm_decrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
 	sg_set_buf(&sg[1], data, data_len);
 	sg_set_buf(&sg[2], mic, mic_len);
 
-	aead_request_set_tfm(aead_req, tfm);
 	aead_request_set_crypt(aead_req, sg, sg, data_len + mic_len, b_0);
 	aead_request_set_ad(aead_req, sg[0].length);
 
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
index 3702041f44fd..6645f8963278 100644
--- a/net/mac80211/aes_cmac.h
+++ b/net/mac80211/aes_cmac.h
@@ -11,6 +11,8 @@
 
 #include <linux/crypto.h>
 
+#define CMAC_AAD_LEN 20
+
 struct crypto_cipher *ieee80211_aes_cmac_key_setup(const u8 key[],
 						   size_t key_len);
 void ieee80211_aes_cmac(struct crypto_cipher *tfm, const u8 *aad,
diff --git a/net/mac80211/aes_gcm.c b/net/mac80211/aes_gcm.c
index aa8eb2718bc1..831054c6c756 100644
--- a/net/mac80211/aes_gcm.c
+++ b/net/mac80211/aes_gcm.c
@@ -30,7 +30,6 @@ int ieee80211_aes_gcm_encrypt(struct crypto_aead *tfm, u8 *j_0, u8 *aad,
 	sg_set_buf(&sg[1], data, data_len);
 	sg_set_buf(&sg[2], mic, IEEE80211_GCMP_MIC_LEN);
 
-	aead_request_set_tfm(aead_req, tfm);
 	aead_request_set_crypt(aead_req, sg, sg, data_len, j_0);
 	aead_request_set_ad(aead_req, sg[0].length);
 
@@ -58,7 +57,6 @@ int ieee80211_aes_gcm_decrypt(struct crypto_aead *tfm, u8 *j_0, u8 *aad,
 	sg_set_buf(&sg[1], data, data_len);
 	sg_set_buf(&sg[2], mic, IEEE80211_GCMP_MIC_LEN);
 
-	aead_request_set_tfm(aead_req, tfm);
 	aead_request_set_crypt(aead_req, sg, sg,
 			       data_len + IEEE80211_GCMP_MIC_LEN, j_0);
 	aead_request_set_ad(aead_req, sg[0].length);
diff --git a/net/mac80211/aes_gmac.c b/net/mac80211/aes_gmac.c
index 15cfcebf0884..86892e2e3c8c 100644
--- a/net/mac80211/aes_gmac.c
+++ b/net/mac80211/aes_gmac.c
@@ -19,13 +19,12 @@
 
 #define GMAC_MIC_LEN 16
 #define GMAC_NONCE_LEN 12
-#define AAD_LEN 20
 
 int ieee80211_aes_gmac(struct crypto_aead *tfm, const u8 *aad, u8 *nonce,
-		       const u8 *data, size_t data_len, u8 *mic)
+		       const u8 *data, size_t data_len, u8 *mic, u8 *zero)
 {
 	struct scatterlist sg[4];
-	u8 zero[GMAC_MIC_LEN], iv[AES_BLOCK_SIZE];
+	u8 iv[AES_BLOCK_SIZE];
 	struct aead_request *aead_req;
 
 	if (data_len < GMAC_MIC_LEN)
@@ -37,7 +36,7 @@ int ieee80211_aes_gmac(struct crypto_aead *tfm, const u8 *aad, u8 *nonce,
 
 	memset(zero, 0, GMAC_MIC_LEN);
 	sg_init_table(sg, 4);
-	sg_set_buf(&sg[0], aad, AAD_LEN);
+	sg_set_buf(&sg[0], aad, GMAC_AAD_LEN);
 	sg_set_buf(&sg[1], data, data_len - GMAC_MIC_LEN);
 	sg_set_buf(&sg[2], zero, GMAC_MIC_LEN);
 	sg_set_buf(&sg[3], mic, GMAC_MIC_LEN);
@@ -46,9 +45,8 @@ int ieee80211_aes_gmac(struct crypto_aead *tfm, const u8 *aad, u8 *nonce,
 	memset(iv + GMAC_NONCE_LEN, 0, sizeof(iv) - GMAC_NONCE_LEN);
 	iv[AES_BLOCK_SIZE - 1] = 0x01;
 
-	aead_request_set_tfm(aead_req, tfm);
 	aead_request_set_crypt(aead_req, sg, sg, 0, iv);
-	aead_request_set_ad(aead_req, AAD_LEN + data_len);
+	aead_request_set_ad(aead_req, GMAC_AAD_LEN + data_len);
 
 	crypto_aead_encrypt(aead_req);
 	aead_request_free(aead_req);
diff --git a/net/mac80211/aes_gmac.h b/net/mac80211/aes_gmac.h
index d328204d73a8..f06833c9095f 100644
--- a/net/mac80211/aes_gmac.h
+++ b/net/mac80211/aes_gmac.h
@@ -11,10 +11,13 @@
 
 #include <linux/crypto.h>
 
+#define GMAC_MIC_LEN 16
+#define GMAC_AAD_LEN 20
+
 struct crypto_aead *ieee80211_aes_gmac_key_setup(const u8 key[],
 						 size_t key_len);
 int ieee80211_aes_gmac(struct crypto_aead *tfm, const u8 *aad, u8 *nonce,
-		       const u8 *data, size_t data_len, u8 *mic);
+		       const u8 *data, size_t data_len, u8 *mic, u8 *zero);
 void ieee80211_aes_gmac_key_free(struct crypto_aead *tfm);
 
 #endif /* AES_GMAC_H */
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 34c2add2c455..d68aae40b8d5 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -1128,6 +1128,13 @@ enum mac80211_scan_state {
 	SCAN_ABORT,
 };
 
+struct ieee80211_crypto_bufs {
+	u8 buf1[32];
+	u8 buf2[16];
+};
+
+extern struct ieee80211_crypto_bufs __percpu *ieee80211_crypto_bufs;
+
 struct ieee80211_local {
 	/* embed the driver visible part.
 	 * don't cast (use the static inlines below), but we keep
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index 1075ac24c8c5..6175cde94c53 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -33,6 +33,8 @@
 #include "led.h"
 #include "debugfs.h"
 
+struct ieee80211_crypto_bufs __percpu *ieee80211_crypto_bufs;
+
 void ieee80211_configure_filter(struct ieee80211_local *local)
 {
 	u64 mc;
@@ -1234,6 +1236,10 @@ static int __init ieee80211_init(void)
 	BUILD_BUG_ON(offsetof(struct ieee80211_tx_info, driver_data) +
 		     IEEE80211_TX_INFO_DRIVER_DATA_SIZE > sizeof(skb->cb));
 
+	ieee80211_crypto_bufs = alloc_percpu(struct ieee80211_crypto_bufs);
+	if (!ieee80211_crypto_bufs)
+		return -ENOMEM;
+
 	ret = rc80211_minstrel_init();
 	if (ret)
 		return ret;
@@ -1264,6 +1270,8 @@ static void __exit ieee80211_exit(void)
 
 	ieee80211_iface_exit();
 
+	free_percpu(ieee80211_crypto_bufs);
+
 	rcu_barrier();
 }
 
diff --git a/net/mac80211/wpa.c b/net/mac80211/wpa.c
index 2e366438f8ef..3a83a6763664 100644
--- a/net/mac80211/wpa.c
+++ b/net/mac80211/wpa.c
@@ -405,8 +405,13 @@ static int ccmp_encrypt_skb(struct ieee80211_tx_data *tx, struct sk_buff *skb,
 	u8 *pos;
 	u8 pn[6];
 	u64 pn64;
-	u8 aad[2 * AES_BLOCK_SIZE];
-	u8 b_0[AES_BLOCK_SIZE];
+	struct ieee80211_crypto_bufs *bufs =
+		this_cpu_ptr(ieee80211_crypto_bufs);
+	u8 *aad = bufs->buf1;
+	u8 *b_0 = bufs->buf2;
+
+	BUILD_BUG_ON(sizeof(bufs->buf1) < 2 * AES_BLOCK_SIZE);
+	BUILD_BUG_ON(sizeof(bufs->buf2) < AES_BLOCK_SIZE);
 
 	if (info->control.hw_key &&
 	    !(info->control.hw_key->flags & IEEE80211_KEY_FLAG_GENERATE_IV) &&
@@ -532,8 +537,14 @@ ieee80211_crypto_ccmp_decrypt(struct ieee80211_rx_data *rx,
 		}
 
 		if (!(status->flag & RX_FLAG_DECRYPTED)) {
-			u8 aad[2 * AES_BLOCK_SIZE];
-			u8 b_0[AES_BLOCK_SIZE];
+			struct ieee80211_crypto_bufs *bufs =
+				this_cpu_ptr(ieee80211_crypto_bufs);
+			u8 *aad = bufs->buf1;
+			u8 *b_0 = bufs->buf2;
+
+			BUILD_BUG_ON(sizeof(bufs->buf1) < 2 * AES_BLOCK_SIZE);
+			BUILD_BUG_ON(sizeof(bufs->buf2) < AES_BLOCK_SIZE);
+
 			/* hardware didn't decrypt/verify MIC */
 			ccmp_special_blocks(skb, pn, b_0, aad);
 
@@ -637,8 +648,13 @@ static int gcmp_encrypt_skb(struct ieee80211_tx_data *tx, struct sk_buff *skb)
 	u8 *pos;
 	u8 pn[6];
 	u64 pn64;
-	u8 aad[2 * AES_BLOCK_SIZE];
-	u8 j_0[AES_BLOCK_SIZE];
+	struct ieee80211_crypto_bufs *bufs =
+		this_cpu_ptr(ieee80211_crypto_bufs);
+	u8 *aad = bufs->buf1;
+	u8 *j_0 = bufs->buf2;
+
+	BUILD_BUG_ON(sizeof(bufs->buf1) < 2 * AES_BLOCK_SIZE);
+	BUILD_BUG_ON(sizeof(bufs->buf2) < AES_BLOCK_SIZE);
 
 	if (info->control.hw_key &&
 	    !(info->control.hw_key->flags & IEEE80211_KEY_FLAG_GENERATE_IV) &&
@@ -760,8 +776,14 @@ ieee80211_crypto_gcmp_decrypt(struct ieee80211_rx_data *rx)
 		}
 
 		if (!(status->flag & RX_FLAG_DECRYPTED)) {
-			u8 aad[2 * AES_BLOCK_SIZE];
-			u8 j_0[AES_BLOCK_SIZE];
+			struct ieee80211_crypto_bufs *bufs =
+				this_cpu_ptr(ieee80211_crypto_bufs);
+			u8 *aad = bufs->buf1;
+			u8 *j_0 = bufs->buf2;
+
+			BUILD_BUG_ON(sizeof(bufs->buf1) < 2 * AES_BLOCK_SIZE);
+			BUILD_BUG_ON(sizeof(bufs->buf2) < AES_BLOCK_SIZE);
+
 			/* hardware didn't decrypt/verify MIC */
 			gcmp_special_blocks(skb, pn, j_0, aad);
 
@@ -931,8 +953,12 @@ ieee80211_crypto_aes_cmac_encrypt(struct ieee80211_tx_data *tx)
 	struct ieee80211_tx_info *info;
 	struct ieee80211_key *key = tx->key;
 	struct ieee80211_mmie *mmie;
-	u8 aad[20];
 	u64 pn64;
+	struct ieee80211_crypto_bufs *bufs =
+		this_cpu_ptr(ieee80211_crypto_bufs);
+	u8 *aad = bufs->buf1;
+
+	BUILD_BUG_ON(sizeof(bufs->buf1) < CMAC_AAD_LEN);
 
 	if (WARN_ON(skb_queue_len(&tx->skbs) != 1))
 		return TX_DROP;
@@ -975,8 +1001,12 @@ ieee80211_crypto_aes_cmac_256_encrypt(struct ieee80211_tx_data *tx)
 	struct ieee80211_tx_info *info;
 	struct ieee80211_key *key = tx->key;
 	struct ieee80211_mmie_16 *mmie;
-	u8 aad[20];
 	u64 pn64;
+	struct ieee80211_crypto_bufs *bufs =
+		this_cpu_ptr(ieee80211_crypto_bufs);
+	u8 *aad = bufs->buf1;
+
+	BUILD_BUG_ON(sizeof(bufs->buf1) < CMAC_AAD_LEN);
 
 	if (WARN_ON(skb_queue_len(&tx->skbs) != 1))
 		return TX_DROP;
@@ -1018,8 +1048,13 @@ ieee80211_crypto_aes_cmac_decrypt(struct ieee80211_rx_data *rx)
 	struct ieee80211_rx_status *status = IEEE80211_SKB_RXCB(skb);
 	struct ieee80211_key *key = rx->key;
 	struct ieee80211_mmie *mmie;
-	u8 aad[20], mic[8], ipn[6];
+	u8 mic[8], ipn[6];
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
+	struct ieee80211_crypto_bufs *bufs =
+		this_cpu_ptr(ieee80211_crypto_bufs);
+	u8 *aad = bufs->buf1;
+
+	BUILD_BUG_ON(sizeof(bufs->buf1) < CMAC_AAD_LEN);
 
 	if (!ieee80211_is_mgmt(hdr->frame_control))
 		return RX_CONTINUE;
@@ -1068,8 +1103,13 @@ ieee80211_crypto_aes_cmac_256_decrypt(struct ieee80211_rx_data *rx)
 	struct ieee80211_rx_status *status = IEEE80211_SKB_RXCB(skb);
 	struct ieee80211_key *key = rx->key;
 	struct ieee80211_mmie_16 *mmie;
-	u8 aad[20], mic[16], ipn[6];
+	u8 mic[16], ipn[6];
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *)skb->data;
+	struct ieee80211_crypto_bufs *bufs =
+		this_cpu_ptr(ieee80211_crypto_bufs);
+	u8 *aad = bufs->buf1;
+
+	BUILD_BUG_ON(sizeof(bufs->buf1) < CMAC_AAD_LEN);
 
 	if (!ieee80211_is_mgmt(hdr->frame_control))
 		return RX_CONTINUE;
@@ -1119,9 +1159,15 @@ ieee80211_crypto_aes_gmac_encrypt(struct ieee80211_tx_data *tx)
 	struct ieee80211_key *key = tx->key;
 	struct ieee80211_mmie_16 *mmie;
 	struct ieee80211_hdr *hdr;
-	u8 aad[20];
 	u64 pn64;
 	u8 nonce[12];
+	struct ieee80211_crypto_bufs *bufs =
+		this_cpu_ptr(ieee80211_crypto_bufs);
+	u8 *aad = bufs->buf1;
+	u8 *zero = bufs->buf2;
+
+	BUILD_BUG_ON(sizeof(bufs->buf1) < GMAC_AAD_LEN);
+	BUILD_BUG_ON(sizeof(bufs->buf2) < GMAC_MIC_LEN);
 
 	if (WARN_ON(skb_queue_len(&tx->skbs) != 1))
 		return TX_DROP;
@@ -1154,7 +1200,8 @@ ieee80211_crypto_aes_gmac_encrypt(struct ieee80211_tx_data *tx)
 
 	/* MIC = AES-GMAC(IGTK, AAD || Management Frame Body || MMIE, 128) */
 	if (ieee80211_aes_gmac(key->u.aes_gmac.tfm, aad, nonce,
-			       skb->data + 24, skb->len - 24, mmie->mic) < 0)
+			       skb->data + 24, skb->len - 24, mmie->mic,
+			       zero) < 0)
 		return TX_DROP;
 
 	return TX_CONTINUE;
@@ -1167,8 +1214,15 @@ ieee80211_crypto_aes_gmac_decrypt(struct ieee80211_rx_data *rx)
 	struct ieee80211_rx_status *status = IEEE80211_SKB_RXCB(skb);
 	struct ieee80211_key *key = rx->key;
 	struct ieee80211_mmie_16 *mmie;
-	u8 aad[20], mic[16], ipn[6], nonce[12];
+	u8 mic[16], ipn[6], nonce[12];
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *)skb->data;
+	struct ieee80211_crypto_bufs *bufs =
+		this_cpu_ptr(ieee80211_crypto_bufs);
+	u8 *aad = bufs->buf1;
+	u8 *zero = bufs->buf2;
+
+	BUILD_BUG_ON(sizeof(bufs->buf1) < GMAC_AAD_LEN);
+	BUILD_BUG_ON(sizeof(bufs->buf2) < GMAC_MIC_LEN);
 
 	if (!ieee80211_is_mgmt(hdr->frame_control))
 		return RX_CONTINUE;
@@ -1200,7 +1254,7 @@ ieee80211_crypto_aes_gmac_decrypt(struct ieee80211_rx_data *rx)
 
 		if (ieee80211_aes_gmac(key->u.aes_gmac.tfm, aad, nonce,
 				       skb->data + 24, skb->len - 24,
-				       mic) < 0 ||
+				       mic, zero) < 0 ||
 		    memcmp(mic, mmie->mic, sizeof(mmie->mic)) != 0) {
 			key->u.aes_gmac.icverrors++;
 			return RX_DROP_UNUSABLE;
-- 
2.8.1
