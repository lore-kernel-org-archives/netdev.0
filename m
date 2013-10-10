From: Ard Biesheuvel <ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH v3] mac80211: port CCMP to cryptoapi's CCM driver
Date: Thu, 10 Oct 2013 09:55:20 +0200
Message-ID: <1381391720-28771-1-git-send-email-ard.biesheuvel@linaro.org>
Cc: patches-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
	Ard Biesheuvel <ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Use the generic CCM aead chaining mode driver rather than a local
implementation that sits right on top of the core AES cipher.

This allows the use of accelerated implementations of either
CCM as a whole or the CTR mode which it encapsulates.

Signed-off-by: Ard Biesheuvel <ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
---

Changes since v2:
- removed the redundant length setting in vector b_0 (and updated the comment
  accordingly);

Changes since v1:
- use a better way to allocate the variable size aead_request struct on the
  stack;
- pass only a single data pointer argument as we always encrypt/decrypt in
  place;
- add a comment about how vector b_0 is generated.


 net/mac80211/Kconfig   |   1 +
 net/mac80211/aes_ccm.c | 169 ++++++++++++++++---------------------------------
 net/mac80211/aes_ccm.h |  14 ++--
 net/mac80211/key.h     |   2 +-
 net/mac80211/wpa.c     |  44 ++++++-------
 5 files changed, 84 insertions(+), 146 deletions(-)

diff --git a/net/mac80211/Kconfig b/net/mac80211/Kconfig
index 62535fe..dc31ec3 100644
--- a/net/mac80211/Kconfig
+++ b/net/mac80211/Kconfig
@@ -4,6 +4,7 @@ config MAC80211
 	select CRYPTO
 	select CRYPTO_ARC4
 	select CRYPTO_AES
+	select CRYPTO_CCM
 	select CRC32
 	select AVERAGE
 	---help---
diff --git a/net/mac80211/aes_ccm.c b/net/mac80211/aes_ccm.c
index be7614b9..7c7df47 100644
--- a/net/mac80211/aes_ccm.c
+++ b/net/mac80211/aes_ccm.c
@@ -2,6 +2,8 @@
  * Copyright 2003-2004, Instant802 Networks, Inc.
  * Copyright 2005-2006, Devicescape Software, Inc.
  *
+ * Rewrite: Copyright (C) 2013 Linaro Ltd <ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
+ *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
@@ -17,134 +19,75 @@
 #include "key.h"
 #include "aes_ccm.h"
 
-static void aes_ccm_prepare(struct crypto_cipher *tfm, u8 *scratch, u8 *a)
+void ieee80211_aes_ccm_encrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
+			       u8 *data, size_t data_len, u8 *mic)
 {
-	int i;
-	u8 *b_0, *aad, *b, *s_0;
-
-	b_0 = scratch + 3 * AES_BLOCK_SIZE;
-	aad = scratch + 4 * AES_BLOCK_SIZE;
-	b = scratch;
-	s_0 = scratch + AES_BLOCK_SIZE;
-
-	crypto_cipher_encrypt_one(tfm, b, b_0);
+	struct scatterlist assoc, pt, ct[2];
+	struct {
+		struct aead_request	req;
+		u8			priv[crypto_aead_reqsize(tfm)];
+	} aead_req;
 
-	/* Extra Authenticate-only data (always two AES blocks) */
-	for (i = 0; i < AES_BLOCK_SIZE; i++)
-		aad[i] ^= b[i];
-	crypto_cipher_encrypt_one(tfm, b, aad);
+	memset(&aead_req, 0, sizeof(aead_req));
 
-	aad += AES_BLOCK_SIZE;
+	sg_init_one(&pt, data, data_len);
+	sg_init_one(&assoc, &aad[2], be16_to_cpup((__be16 *)aad));
+	sg_init_table(ct, 2);
+	sg_set_buf(&ct[0], data, data_len);
+	sg_set_buf(&ct[1], mic, IEEE80211_CCMP_MIC_LEN);
 
-	for (i = 0; i < AES_BLOCK_SIZE; i++)
-		aad[i] ^= b[i];
-	crypto_cipher_encrypt_one(tfm, a, aad);
+	aead_request_set_tfm(&aead_req.req, tfm);
+	aead_request_set_assoc(&aead_req.req, &assoc, assoc.length);
+	aead_request_set_crypt(&aead_req.req, &pt, ct, data_len, b_0);
 
-	/* Mask out bits from auth-only-b_0 */
-	b_0[0] &= 0x07;
-
-	/* S_0 is used to encrypt T (= MIC) */
-	b_0[14] = 0;
-	b_0[15] = 0;
-	crypto_cipher_encrypt_one(tfm, s_0, b_0);
+	crypto_aead_encrypt(&aead_req.req);
 }
 
-
-void ieee80211_aes_ccm_encrypt(struct crypto_cipher *tfm, u8 *scratch,
-			       u8 *data, size_t data_len,
-			       u8 *cdata, u8 *mic)
+int ieee80211_aes_ccm_decrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
+			      u8 *data, size_t data_len, u8 *mic)
 {
-	int i, j, last_len, num_blocks;
-	u8 *pos, *cpos, *b, *s_0, *e, *b_0;
-
-	b = scratch;
-	s_0 = scratch + AES_BLOCK_SIZE;
-	e = scratch + 2 * AES_BLOCK_SIZE;
-	b_0 = scratch + 3 * AES_BLOCK_SIZE;
-
-	num_blocks = DIV_ROUND_UP(data_len, AES_BLOCK_SIZE);
-	last_len = data_len % AES_BLOCK_SIZE;
-	aes_ccm_prepare(tfm, scratch, b);
-
-	/* Process payload blocks */
-	pos = data;
-	cpos = cdata;
-	for (j = 1; j <= num_blocks; j++) {
-		int blen = (j == num_blocks && last_len) ?
-			last_len : AES_BLOCK_SIZE;
-
-		/* Authentication followed by encryption */
-		for (i = 0; i < blen; i++)
-			b[i] ^= pos[i];
-		crypto_cipher_encrypt_one(tfm, b, b);
-
-		b_0[14] = (j >> 8) & 0xff;
-		b_0[15] = j & 0xff;
-		crypto_cipher_encrypt_one(tfm, e, b_0);
-		for (i = 0; i < blen; i++)
-			*cpos++ = *pos++ ^ e[i];
-	}
-
-	for (i = 0; i < IEEE80211_CCMP_MIC_LEN; i++)
-		mic[i] = b[i] ^ s_0[i];
+	struct scatterlist assoc, pt, ct[2];
+	struct {
+		struct aead_request	req;
+		u8			priv[crypto_aead_reqsize(tfm)];
+	} aead_req;
+
+	memset(&aead_req, 0, sizeof(aead_req));
+
+	sg_init_one(&pt, data, data_len);
+	sg_init_one(&assoc, &aad[2], be16_to_cpup((__be16 *)aad));
+	sg_init_table(ct, 2);
+	sg_set_buf(&ct[0], data, data_len);
+	sg_set_buf(&ct[1], mic, IEEE80211_CCMP_MIC_LEN);
+
+	aead_request_set_tfm(&aead_req.req, tfm);
+	aead_request_set_assoc(&aead_req.req, &assoc, assoc.length);
+	aead_request_set_crypt(&aead_req.req, ct, &pt,
+			       data_len + IEEE80211_CCMP_MIC_LEN, b_0);
+
+	return crypto_aead_decrypt(&aead_req.req);
 }
 
-
-int ieee80211_aes_ccm_decrypt(struct crypto_cipher *tfm, u8 *scratch,
-			      u8 *cdata, size_t data_len, u8 *mic, u8 *data)
+struct crypto_aead *ieee80211_aes_key_setup_encrypt(const u8 key[])
 {
-	int i, j, last_len, num_blocks;
-	u8 *pos, *cpos, *b, *s_0, *a, *b_0;
-
-	b = scratch;
-	s_0 = scratch + AES_BLOCK_SIZE;
-	a = scratch + 2 * AES_BLOCK_SIZE;
-	b_0 = scratch + 3 * AES_BLOCK_SIZE;
-
-	num_blocks = DIV_ROUND_UP(data_len, AES_BLOCK_SIZE);
-	last_len = data_len % AES_BLOCK_SIZE;
-	aes_ccm_prepare(tfm, scratch, a);
-
-	/* Process payload blocks */
-	cpos = cdata;
-	pos = data;
-	for (j = 1; j <= num_blocks; j++) {
-		int blen = (j == num_blocks && last_len) ?
-			last_len : AES_BLOCK_SIZE;
-
-		/* Decryption followed by authentication */
-		b_0[14] = (j >> 8) & 0xff;
-		b_0[15] = j & 0xff;
-		crypto_cipher_encrypt_one(tfm, b, b_0);
-		for (i = 0; i < blen; i++) {
-			*pos = *cpos++ ^ b[i];
-			a[i] ^= *pos++;
-		}
-		crypto_cipher_encrypt_one(tfm, a, a);
-	}
-
-	for (i = 0; i < IEEE80211_CCMP_MIC_LEN; i++) {
-		if ((mic[i] ^ s_0[i]) != a[i])
-			return -1;
-	}
-
-	return 0;
-}
+	struct crypto_aead *tfm;
+	int err;
 
+	tfm = crypto_alloc_aead("ccm(aes)", 0, CRYPTO_ALG_ASYNC);
+	if (IS_ERR(tfm))
+		return tfm;
 
-struct crypto_cipher *ieee80211_aes_key_setup_encrypt(const u8 key[])
-{
-	struct crypto_cipher *tfm;
+	err = crypto_aead_setkey(tfm, key, WLAN_KEY_LEN_CCMP);
+	if (!err)
+		err = crypto_aead_setauthsize(tfm, IEEE80211_CCMP_MIC_LEN);
+	if (!err)
+		return tfm;
 
-	tfm = crypto_alloc_cipher("aes", 0, CRYPTO_ALG_ASYNC);
-	if (!IS_ERR(tfm))
-		crypto_cipher_setkey(tfm, key, WLAN_KEY_LEN_CCMP);
-
-	return tfm;
+	crypto_free_aead(tfm);
+	return ERR_PTR(err);
 }
 
-
-void ieee80211_aes_key_free(struct crypto_cipher *tfm)
+void ieee80211_aes_key_free(struct crypto_aead *tfm)
 {
-	crypto_free_cipher(tfm);
+	crypto_free_aead(tfm);
 }
diff --git a/net/mac80211/aes_ccm.h b/net/mac80211/aes_ccm.h
index 5b7d744..2c7ab19 100644
--- a/net/mac80211/aes_ccm.h
+++ b/net/mac80211/aes_ccm.h
@@ -12,13 +12,11 @@
 
 #include <linux/crypto.h>
 
-struct crypto_cipher *ieee80211_aes_key_setup_encrypt(const u8 key[]);
-void ieee80211_aes_ccm_encrypt(struct crypto_cipher *tfm, u8 *scratch,
-			       u8 *data, size_t data_len,
-			       u8 *cdata, u8 *mic);
-int ieee80211_aes_ccm_decrypt(struct crypto_cipher *tfm, u8 *scratch,
-			      u8 *cdata, size_t data_len,
-			      u8 *mic, u8 *data);
-void ieee80211_aes_key_free(struct crypto_cipher *tfm);
+struct crypto_aead *ieee80211_aes_key_setup_encrypt(const u8 key[]);
+void ieee80211_aes_ccm_encrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
+			       u8 *data, size_t data_len, u8 *mic);
+int ieee80211_aes_ccm_decrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
+			      u8 *data, size_t data_len, u8 *mic);
+void ieee80211_aes_key_free(struct crypto_aead *tfm);
 
 #endif /* AES_CCM_H */
diff --git a/net/mac80211/key.h b/net/mac80211/key.h
index 036d57e..aaae0ed 100644
--- a/net/mac80211/key.h
+++ b/net/mac80211/key.h
@@ -83,7 +83,7 @@ struct ieee80211_key {
 			 * Management frames.
 			 */
 			u8 rx_pn[IEEE80211_NUM_TIDS + 1][IEEE80211_CCMP_PN_LEN];
-			struct crypto_cipher *tfm;
+			struct crypto_aead *tfm;
 			u32 replays; /* dot11RSNAStatsCCMPReplays */
 		} ccmp;
 		struct {
diff --git a/net/mac80211/wpa.c b/net/mac80211/wpa.c
index c9edfcb..d657282 100644
--- a/net/mac80211/wpa.c
+++ b/net/mac80211/wpa.c
@@ -301,22 +301,16 @@ ieee80211_crypto_tkip_decrypt(struct ieee80211_rx_data *rx)
 }
 
 
-static void ccmp_special_blocks(struct sk_buff *skb, u8 *pn, u8 *scratch,
+static void ccmp_special_blocks(struct sk_buff *skb, u8 *pn, u8 *b_0, u8 *aad,
 				int encrypted)
 {
 	__le16 mask_fc;
 	int a4_included, mgmt;
 	u8 qos_tid;
-	u8 *b_0, *aad;
-	u16 data_len, len_a;
+	u16 len_a;
 	unsigned int hdrlen;
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *)skb->data;
 
-	memset(scratch, 0, 6 * AES_BLOCK_SIZE);
-
-	b_0 = scratch + 3 * AES_BLOCK_SIZE;
-	aad = scratch + 4 * AES_BLOCK_SIZE;
-
 	/*
 	 * Mask FC: zero subtype b4 b5 b6 (if not mgmt)
 	 * Retry, PwrMgt, MoreData; set Protected
@@ -338,20 +332,21 @@ static void ccmp_special_blocks(struct sk_buff *skb, u8 *pn, u8 *scratch,
 	else
 		qos_tid = 0;
 
-	data_len = skb->len - hdrlen - IEEE80211_CCMP_HDR_LEN;
-	if (encrypted)
-		data_len -= IEEE80211_CCMP_MIC_LEN;
+	/* In CCM, the initial vectors (IV) used for CTR mode encryption and CBC
+	 * mode authentication are not allowed to collide, yet both are derived
+	 * from this vector b_0. We only set L := 1 here to indicate that the
+	 * data size can be represented in (L+1) bytes. The CCM layer will take
+	 * care of storing the data length in the top (L+1) bytes and setting
+	 * and clearing the other bits as is required to derive the two IVs.
+	 */
+	b_0[0] = 0x1;
 
-	/* First block, b_0 */
-	b_0[0] = 0x59; /* flags: Adata: 1, M: 011, L: 001 */
 	/* Nonce: Nonce Flags | A2 | PN
 	 * Nonce Flags: Priority (b0..b3) | Management (b4) | Reserved (b5..b7)
 	 */
 	b_0[1] = qos_tid | (mgmt << 4);
 	memcpy(&b_0[2], hdr->addr2, ETH_ALEN);
 	memcpy(&b_0[8], pn, IEEE80211_CCMP_PN_LEN);
-	/* l(m) */
-	put_unaligned_be16(data_len, &b_0[14]);
 
 	/* AAD (extra authenticate-only data) / masked 802.11 header
 	 * FC | A1 | A2 | A3 | SC | [A4] | [QC] */
@@ -407,7 +402,8 @@ static int ccmp_encrypt_skb(struct ieee80211_tx_data *tx, struct sk_buff *skb)
 	u8 *pos;
 	u8 pn[6];
 	u64 pn64;
-	u8 scratch[6 * AES_BLOCK_SIZE];
+	u8 aad[2 * AES_BLOCK_SIZE];
+	u8 b_0[AES_BLOCK_SIZE];
 
 	if (info->control.hw_key &&
 	    !(info->control.hw_key->flags & IEEE80211_KEY_FLAG_GENERATE_IV) &&
@@ -460,9 +456,9 @@ static int ccmp_encrypt_skb(struct ieee80211_tx_data *tx, struct sk_buff *skb)
 		return 0;
 
 	pos += IEEE80211_CCMP_HDR_LEN;
-	ccmp_special_blocks(skb, pn, scratch, 0);
-	ieee80211_aes_ccm_encrypt(key->u.ccmp.tfm, scratch, pos, len,
-				  pos, skb_put(skb, IEEE80211_CCMP_MIC_LEN));
+	ccmp_special_blocks(skb, pn, b_0, aad, 0);
+	ieee80211_aes_ccm_encrypt(key->u.ccmp.tfm, b_0, aad, pos, len,
+				  skb_put(skb, IEEE80211_CCMP_MIC_LEN));
 
 	return 0;
 }
@@ -525,16 +521,16 @@ ieee80211_crypto_ccmp_decrypt(struct ieee80211_rx_data *rx)
 	}
 
 	if (!(status->flag & RX_FLAG_DECRYPTED)) {
-		u8 scratch[6 * AES_BLOCK_SIZE];
+		u8 aad[2 * AES_BLOCK_SIZE];
+		u8 b_0[AES_BLOCK_SIZE];
 		/* hardware didn't decrypt/verify MIC */
-		ccmp_special_blocks(skb, pn, scratch, 1);
+		ccmp_special_blocks(skb, pn, b_0, aad, 1);
 
 		if (ieee80211_aes_ccm_decrypt(
-			    key->u.ccmp.tfm, scratch,
+			    key->u.ccmp.tfm, b_0, aad,
 			    skb->data + hdrlen + IEEE80211_CCMP_HDR_LEN,
 			    data_len,
-			    skb->data + skb->len - IEEE80211_CCMP_MIC_LEN,
-			    skb->data + hdrlen + IEEE80211_CCMP_HDR_LEN))
+			    skb->data + skb->len - IEEE80211_CCMP_MIC_LEN))
 			return RX_DROP_UNUSABLE;
 	}
 
-- 
1.8.1.2

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
