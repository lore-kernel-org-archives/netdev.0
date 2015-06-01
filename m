From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 7/7] mac80211: Switch to new AEAD interface
Date: Mon, 01 Jun 2015 16:35:26 +0200
Message-ID: <1433169326.3505.12.camel@sipsolutions.net>
References: <20150521103938.GA23035@gondor.apana.org.au>
	 <1706098.2opyZ2hT8S@tachyon.chronox.de>
	 <1433166161.3505.7.camel@sipsolutions.net> <2141601.IbD2v8KjaT@tauon>
	 <1433167519.3505.11.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: Stephan Mueller <smueller@chronox.de>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1433167519.3505.11.camel@sipsolutions.net>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-06-01 at 16:05 +0200, Johannes Berg wrote:

> Ok - here the length is kinda passed a part of the AAD buffer, but this
> is really just some arcane code that should be fixed to use a proper
> struct. The value there, even though it is __be16 and looks like it came
> from the data, is actually created locally, see ccmp_special_blocks()
> and gcmp_special_blocks().

IOW, I think something like this would make sense:

(but I'll hold it until after Herbert's patches I guess)

>From 20bd0e92ab0d7ef545687da762228622bcdabeec Mon Sep 17 00:00:00 2001
From: Johannes Berg <johannes.berg@intel.com>
Date: Mon, 1 Jun 2015 16:33:11 +0200
Subject: [PATCH] mac80211: move AAD length out of AAD buffer

The code currently passes the AAD buffer as a __be16 with the
length, followed by the actual data, but doesn't use a struct
or make this explicit in any other way, so it's confusing.

Change the code to pass the AAD length explicity outside of
the buffer.

Reported-by: Stephan Mueller <smueller@chronox.de>
Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 net/mac80211/aes_ccm.c | 18 +++++++-------
 net/mac80211/aes_ccm.h | 14 ++++++-----
 net/mac80211/aes_gcm.c | 10 ++++----
 net/mac80211/aes_gcm.h |  6 +++--
 net/mac80211/wpa.c     | 64 +++++++++++++++++++++++++++-----------------------
 5 files changed, 62 insertions(+), 50 deletions(-)

diff --git a/net/mac80211/aes_ccm.c b/net/mac80211/aes_ccm.c
index 208df7c0b6ea..b6e2f096127a 100644
--- a/net/mac80211/aes_ccm.c
+++ b/net/mac80211/aes_ccm.c
@@ -19,9 +19,10 @@
 #include "key.h"
 #include "aes_ccm.h"
 
-void ieee80211_aes_ccm_encrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
-			       u8 *data, size_t data_len, u8 *mic,
-			       size_t mic_len)
+void ieee80211_aes_ccm_encrypt(struct crypto_aead *tfm, u8 *b_0,
+			       u8 *aad, size_t aad_len,
+			       u8 *data, size_t data_len,
+			       u8 *mic, size_t mic_len)
 {
 	struct scatterlist assoc, pt, ct[2];
 
@@ -33,7 +34,7 @@ void ieee80211_aes_ccm_encrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
 	memset(aead_req, 0, sizeof(aead_req_data));
 
 	sg_init_one(&pt, data, data_len);
-	sg_init_one(&assoc, &aad[2], be16_to_cpup((__be16 *)aad));
+	sg_init_one(&assoc, aad, aad_len);
 	sg_init_table(ct, 2);
 	sg_set_buf(&ct[0], data, data_len);
 	sg_set_buf(&ct[1], mic, mic_len);
@@ -45,9 +46,10 @@ void ieee80211_aes_ccm_encrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
 	crypto_aead_encrypt(aead_req);
 }
 
-int ieee80211_aes_ccm_decrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
-			      u8 *data, size_t data_len, u8 *mic,
-			      size_t mic_len)
+int ieee80211_aes_ccm_decrypt(struct crypto_aead *tfm, u8 *b_0,
+			      u8 *aad, size_t aad_len,
+			      u8 *data, size_t data_len,
+			      u8 *mic, size_t mic_len)
 {
 	struct scatterlist assoc, pt, ct[2];
 	char aead_req_data[sizeof(struct aead_request) +
@@ -61,7 +63,7 @@ int ieee80211_aes_ccm_decrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
 	memset(aead_req, 0, sizeof(aead_req_data));
 
 	sg_init_one(&pt, data, data_len);
-	sg_init_one(&assoc, &aad[2], be16_to_cpup((__be16 *)aad));
+	sg_init_one(&assoc, aad, aad_len);
 	sg_init_table(ct, 2);
 	sg_set_buf(&ct[0], data, data_len);
 	sg_set_buf(&ct[1], mic, mic_len);
diff --git a/net/mac80211/aes_ccm.h b/net/mac80211/aes_ccm.h
index 6a73d1e4d186..bfe355e4a680 100644
--- a/net/mac80211/aes_ccm.h
+++ b/net/mac80211/aes_ccm.h
@@ -15,12 +15,14 @@
 struct crypto_aead *ieee80211_aes_key_setup_encrypt(const u8 key[],
 						    size_t key_len,
 						    size_t mic_len);
-void ieee80211_aes_ccm_encrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
-			       u8 *data, size_t data_len, u8 *mic,
-			       size_t mic_len);
-int ieee80211_aes_ccm_decrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
-			      u8 *data, size_t data_len, u8 *mic,
-			      size_t mic_len);
+void ieee80211_aes_ccm_encrypt(struct crypto_aead *tfm, u8 *b_0,
+			       u8 *aad, size_t aad_len,
+			       u8 *data, size_t data_len,
+			       u8 *mic, size_t mic_len);
+int ieee80211_aes_ccm_decrypt(struct crypto_aead *tfm, u8 *b_0,
+			      u8 *aad, size_t aad_len,
+			      u8 *data, size_t data_len,
+			      u8 *mic, size_t mic_len);
 void ieee80211_aes_key_free(struct crypto_aead *tfm);
 
 #endif /* AES_CCM_H */
diff --git a/net/mac80211/aes_gcm.c b/net/mac80211/aes_gcm.c
index fd278bbe1b0d..fb6823c5e381 100644
--- a/net/mac80211/aes_gcm.c
+++ b/net/mac80211/aes_gcm.c
@@ -16,7 +16,8 @@
 #include "key.h"
 #include "aes_gcm.h"
 
-void ieee80211_aes_gcm_encrypt(struct crypto_aead *tfm, u8 *j_0, u8 *aad,
+void ieee80211_aes_gcm_encrypt(struct crypto_aead *tfm, u8 *j_0,
+			       u8 *aad, size_t aad_len,
 			       u8 *data, size_t data_len, u8 *mic)
 {
 	struct scatterlist assoc, pt, ct[2];
@@ -29,7 +30,7 @@ void ieee80211_aes_gcm_encrypt(struct crypto_aead *tfm, u8 *j_0, u8 *aad,
 	memset(aead_req, 0, sizeof(aead_req_data));
 
 	sg_init_one(&pt, data, data_len);
-	sg_init_one(&assoc, &aad[2], be16_to_cpup((__be16 *)aad));
+	sg_init_one(&assoc, aad, aad_len);
 	sg_init_table(ct, 2);
 	sg_set_buf(&ct[0], data, data_len);
 	sg_set_buf(&ct[1], mic, IEEE80211_GCMP_MIC_LEN);
@@ -41,7 +42,8 @@ void ieee80211_aes_gcm_encrypt(struct crypto_aead *tfm, u8 *j_0, u8 *aad,
 	crypto_aead_encrypt(aead_req);
 }
 
-int ieee80211_aes_gcm_decrypt(struct crypto_aead *tfm, u8 *j_0, u8 *aad,
+int ieee80211_aes_gcm_decrypt(struct crypto_aead *tfm, u8 *j_0,
+			      u8 *aad, size_t aad_len,
 			      u8 *data, size_t data_len, u8 *mic)
 {
 	struct scatterlist assoc, pt, ct[2];
@@ -56,7 +58,7 @@ int ieee80211_aes_gcm_decrypt(struct crypto_aead *tfm, u8 *j_0, u8 *aad,
 	memset(aead_req, 0, sizeof(aead_req_data));
 
 	sg_init_one(&pt, data, data_len);
-	sg_init_one(&assoc, &aad[2], be16_to_cpup((__be16 *)aad));
+	sg_init_one(&assoc, aad, aad_len);
 	sg_init_table(ct, 2);
 	sg_set_buf(&ct[0], data, data_len);
 	sg_set_buf(&ct[1], mic, IEEE80211_GCMP_MIC_LEN);
diff --git a/net/mac80211/aes_gcm.h b/net/mac80211/aes_gcm.h
index 1347fda6b76a..67ca10e3e7a4 100644
--- a/net/mac80211/aes_gcm.h
+++ b/net/mac80211/aes_gcm.h
@@ -11,9 +11,11 @@
 
 #include <linux/crypto.h>
 
-void ieee80211_aes_gcm_encrypt(struct crypto_aead *tfm, u8 *j_0, u8 *aad,
+void ieee80211_aes_gcm_encrypt(struct crypto_aead *tfm, u8 *j_0,
+			       u8 *aad, size_t aad_len,
 			       u8 *data, size_t data_len, u8 *mic);
-int ieee80211_aes_gcm_decrypt(struct crypto_aead *tfm, u8 *j_0, u8 *aad,
+int ieee80211_aes_gcm_decrypt(struct crypto_aead *tfm, u8 *j_0,
+			      u8 *aad, size_t aad_len,
 			      u8 *data, size_t data_len, u8 *mic);
 struct crypto_aead *ieee80211_aes_gcm_key_setup_encrypt(const u8 key[],
 							size_t key_len);
diff --git a/net/mac80211/wpa.c b/net/mac80211/wpa.c
index 9d63d93c836e..b32c043b48b1 100644
--- a/net/mac80211/wpa.c
+++ b/net/mac80211/wpa.c
@@ -304,7 +304,7 @@ ieee80211_crypto_tkip_decrypt(struct ieee80211_rx_data *rx)
 }
 
 
-static void ccmp_special_blocks(struct sk_buff *skb, u8 *pn, u8 *b_0, u8 *aad)
+static u16 ccmp_special_blocks(struct sk_buff *skb, u8 *pn, u8 *b_0, u8 *aad)
 {
 	__le16 mask_fc;
 	int a4_included, mgmt;
@@ -352,22 +352,23 @@ static void ccmp_special_blocks(struct sk_buff *skb, u8 *pn, u8 *b_0, u8 *aad)
 
 	/* AAD (extra authenticate-only data) / masked 802.11 header
 	 * FC | A1 | A2 | A3 | SC | [A4] | [QC] */
-	put_unaligned_be16(len_a, &aad[0]);
-	put_unaligned(mask_fc, (__le16 *)&aad[2]);
-	memcpy(&aad[4], &hdr->addr1, 3 * ETH_ALEN);
+	put_unaligned(mask_fc, (__le16 *)aad);
+	memcpy(&aad[2], &hdr->addr1, 3 * ETH_ALEN);
 
 	/* Mask Seq#, leave Frag# */
-	aad[22] = *((u8 *) &hdr->seq_ctrl) & 0x0f;
-	aad[23] = 0;
+	aad[20] = *((u8 *) &hdr->seq_ctrl) & 0x0f;
+	aad[21] = 0;
 
 	if (a4_included) {
-		memcpy(&aad[24], hdr->addr4, ETH_ALEN);
-		aad[30] = qos_tid;
-		aad[31] = 0;
+		memcpy(&aad[22], hdr->addr4, ETH_ALEN);
+		aad[28] = qos_tid;
+		aad[29] = 0;
 	} else {
-		memset(&aad[24], 0, ETH_ALEN + IEEE80211_QOS_CTL_LEN);
-		aad[24] = qos_tid;
+		memset(&aad[22], 0, ETH_ALEN + IEEE80211_QOS_CTL_LEN);
+		aad[22] = qos_tid;
 	}
+
+	return len_a;
 }
 
 
@@ -407,6 +408,7 @@ static int ccmp_encrypt_skb(struct ieee80211_tx_data *tx, struct sk_buff *skb,
 	u64 pn64;
 	u8 aad[2 * AES_BLOCK_SIZE];
 	u8 b_0[AES_BLOCK_SIZE];
+	size_t aad_len;
 
 	if (info->control.hw_key &&
 	    !(info->control.hw_key->flags & IEEE80211_KEY_FLAG_GENERATE_IV) &&
@@ -460,8 +462,8 @@ static int ccmp_encrypt_skb(struct ieee80211_tx_data *tx, struct sk_buff *skb,
 		return 0;
 
 	pos += IEEE80211_CCMP_HDR_LEN;
-	ccmp_special_blocks(skb, pn, b_0, aad);
-	ieee80211_aes_ccm_encrypt(key->u.ccmp.tfm, b_0, aad, pos, len,
+	aad_len = ccmp_special_blocks(skb, pn, b_0, aad);
+	ieee80211_aes_ccm_encrypt(key->u.ccmp.tfm, b_0, aad, aad_len, pos, len,
 				  skb_put(skb, mic_len), mic_len);
 
 	return 0;
@@ -529,10 +531,10 @@ ieee80211_crypto_ccmp_decrypt(struct ieee80211_rx_data *rx,
 		u8 aad[2 * AES_BLOCK_SIZE];
 		u8 b_0[AES_BLOCK_SIZE];
 		/* hardware didn't decrypt/verify MIC */
-		ccmp_special_blocks(skb, pn, b_0, aad);
+		size_t aad_len = ccmp_special_blocks(skb, pn, b_0, aad);
 
 		if (ieee80211_aes_ccm_decrypt(
-			    key->u.ccmp.tfm, b_0, aad,
+			    key->u.ccmp.tfm, b_0, aad, aad_len,
 			    skb->data + hdrlen + IEEE80211_CCMP_HDR_LEN,
 			    data_len,
 			    skb->data + skb->len - mic_len, mic_len))
@@ -550,7 +552,7 @@ ieee80211_crypto_ccmp_decrypt(struct ieee80211_rx_data *rx,
 	return RX_CONTINUE;
 }
 
-static void gcmp_special_blocks(struct sk_buff *skb, u8 *pn, u8 *j_0, u8 *aad)
+static u16 gcmp_special_blocks(struct sk_buff *skb, u8 *pn, u8 *j_0, u8 *aad)
 {
 	__le16 mask_fc;
 	u8 qos_tid;
@@ -565,7 +567,6 @@ static void gcmp_special_blocks(struct sk_buff *skb, u8 *pn, u8 *j_0, u8 *aad)
 	/* AAD (extra authenticate-only data) / masked 802.11 header
 	 * FC | A1 | A2 | A3 | SC | [A4] | [QC]
 	 */
-	put_unaligned_be16(ieee80211_hdrlen(hdr->frame_control) - 2, &aad[0]);
 	/* Mask FC: zero subtype b4 b5 b6 (if not mgmt)
 	 * Retry, PwrMgt, MoreData; set Protected
 	 */
@@ -576,12 +577,12 @@ static void gcmp_special_blocks(struct sk_buff *skb, u8 *pn, u8 *j_0, u8 *aad)
 		mask_fc &= ~cpu_to_le16(0x0070);
 	mask_fc |= cpu_to_le16(IEEE80211_FCTL_PROTECTED);
 
-	put_unaligned(mask_fc, (__le16 *)&aad[2]);
-	memcpy(&aad[4], &hdr->addr1, 3 * ETH_ALEN);
+	put_unaligned(mask_fc, (__le16 *)aad);
+	memcpy(&aad[2], &hdr->addr1, 3 * ETH_ALEN);
 
 	/* Mask Seq#, leave Frag# */
-	aad[22] = *((u8 *)&hdr->seq_ctrl) & 0x0f;
-	aad[23] = 0;
+	aad[20] = *((u8 *)&hdr->seq_ctrl) & 0x0f;
+	aad[21] = 0;
 
 	if (ieee80211_is_data_qos(hdr->frame_control))
 		qos_tid = *ieee80211_get_qos_ctl(hdr) &
@@ -590,13 +591,15 @@ static void gcmp_special_blocks(struct sk_buff *skb, u8 *pn, u8 *j_0, u8 *aad)
 		qos_tid = 0;
 
 	if (ieee80211_has_a4(hdr->frame_control)) {
-		memcpy(&aad[24], hdr->addr4, ETH_ALEN);
-		aad[30] = qos_tid;
-		aad[31] = 0;
+		memcpy(&aad[22], hdr->addr4, ETH_ALEN);
+		aad[28] = qos_tid;
+		aad[29] = 0;
 	} else {
-		memset(&aad[24], 0, ETH_ALEN + IEEE80211_QOS_CTL_LEN);
-		aad[24] = qos_tid;
+		memset(&aad[22], 0, ETH_ALEN + IEEE80211_QOS_CTL_LEN);
+		aad[22] = qos_tid;
 	}
+
+	return ieee80211_hdrlen(hdr->frame_control) - 2;
 }
 
 static inline void gcmp_pn2hdr(u8 *hdr, const u8 *pn, int key_id)
@@ -632,6 +635,7 @@ static int gcmp_encrypt_skb(struct ieee80211_tx_data *tx, struct sk_buff *skb)
 	u64 pn64;
 	u8 aad[2 * AES_BLOCK_SIZE];
 	u8 j_0[AES_BLOCK_SIZE];
+	size_t aad_len;
 
 	if (info->control.hw_key &&
 	    !(info->control.hw_key->flags & IEEE80211_KEY_FLAG_GENERATE_IV) &&
@@ -686,8 +690,8 @@ static int gcmp_encrypt_skb(struct ieee80211_tx_data *tx, struct sk_buff *skb)
 		return 0;
 
 	pos += IEEE80211_GCMP_HDR_LEN;
-	gcmp_special_blocks(skb, pn, j_0, aad);
-	ieee80211_aes_gcm_encrypt(key->u.gcmp.tfm, j_0, aad, pos, len,
+	aad_len = gcmp_special_blocks(skb, pn, j_0, aad);
+	ieee80211_aes_gcm_encrypt(key->u.gcmp.tfm, j_0, aad, aad_len, pos, len,
 				  skb_put(skb, IEEE80211_GCMP_MIC_LEN));
 
 	return 0;
@@ -752,10 +756,10 @@ ieee80211_crypto_gcmp_decrypt(struct ieee80211_rx_data *rx)
 		u8 aad[2 * AES_BLOCK_SIZE];
 		u8 j_0[AES_BLOCK_SIZE];
 		/* hardware didn't decrypt/verify MIC */
-		gcmp_special_blocks(skb, pn, j_0, aad);
+		size_t aad_len = gcmp_special_blocks(skb, pn, j_0, aad);
 
 		if (ieee80211_aes_gcm_decrypt(
-			    key->u.gcmp.tfm, j_0, aad,
+			    key->u.gcmp.tfm, j_0, aad, aad_len,
 			    skb->data + hdrlen + IEEE80211_GCMP_HDR_LEN,
 			    data_len,
 			    skb->data + skb->len - IEEE80211_GCMP_MIC_LEN))
-- 
2.1.4
