From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH] mac80211: port CCMP to cryptoapi's CCM driver
Date: Tue,  8 Oct 2013 13:31:55 +0200
Message-ID: <1381231915-24232-1-git-send-email-ard.biesheuvel@linaro.org>
Cc: patches@linaro.org, johannes@sipsolutions.net,
	linville@tuxdriver.com, Ard Biesheuvel <ard.biesheuvel@linaro.org>
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:42514 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755308Ab3JHLdd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 07:33:33 -0400
Received: by mail-wi0-f176.google.com with SMTP id hi5so564883wib.3
        for <netdev@vger.kernel.org>; Tue, 08 Oct 2013 04:33:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the generic CCM aead chaining mode driver rather than a local
implementation that sits right on top of the core AES cipher.

This allows the use of accelerated implementations of either
CCM as a whole or the CTR mode which it encapsulates.

Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 net/mac80211/Kconfig   |   1 +
 net/mac80211/aes_ccm.c | 165 +++++++++++++++++--------------------------------
 net/mac80211/aes_ccm.h |   8 +--
 net/mac80211/key.h     |   2 +-
 net/mac80211/wpa.c     |  24 +++----
 5 files changed, 71 insertions(+), 129 deletions(-)

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
index be7614b9..ef808d7 100644
--- a/net/mac80211/aes_ccm.c
+++ b/net/mac80211/aes_ccm.c
@@ -2,6 +2,8 @@
  * Copyright 2003-2004, Instant802 Networks, Inc.
  * Copyright 2005-2006, Devicescape Software, Inc.
  *
+ * Rewrite: Copyright (C) 2013 Linaro Ltd <ard.biesheuvel@linaro.org>
+ *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
@@ -17,134 +19,77 @@
 #include "key.h"
 #include "aes_ccm.h"
 
-static void aes_ccm_prepare(struct crypto_cipher *tfm, u8 *scratch, u8 *a)
+void ieee80211_aes_ccm_encrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
+			       u8 *data, size_t data_len, u8 *cdata, u8 *mic)
 {
-	int i;
-	u8 *b_0, *aad, *b, *s_0;
+	struct scatterlist assoc, pt, ct[2];
 
-	b_0 = scratch + 3 * AES_BLOCK_SIZE;
-	aad = scratch + 4 * AES_BLOCK_SIZE;
-	b = scratch;
-	s_0 = scratch + AES_BLOCK_SIZE;
+	/* allocate the variable sized aead_request on the stack */
+	int l = DIV_ROUND_UP(crypto_aead_reqsize(tfm),
+			     sizeof(struct aead_request));
+	struct aead_request req[1 + l];
 
-	crypto_cipher_encrypt_one(tfm, b, b_0);
+	memset(req, 0, sizeof(*req) + crypto_aead_reqsize(tfm));
 
-	/* Extra Authenticate-only data (always two AES blocks) */
-	for (i = 0; i < AES_BLOCK_SIZE; i++)
-		aad[i] ^= b[i];
-	crypto_cipher_encrypt_one(tfm, b, aad);
+	sg_init_one(&pt, data, data_len);
+	sg_init_one(&assoc, &aad[2], be16_to_cpup((__be16 *)aad));
+	sg_init_table(ct, 2);
+	sg_set_buf(&ct[0], cdata, data_len);
+	sg_set_buf(&ct[1], mic, IEEE80211_CCMP_MIC_LEN);
 
-	aad += AES_BLOCK_SIZE;
+	aead_request_set_tfm(req, tfm);
+	aead_request_set_crypt(req, &pt, ct, data_len, b_0);
+	aead_request_set_assoc(req, &assoc, assoc.length);
 
-	for (i = 0; i < AES_BLOCK_SIZE; i++)
-		aad[i] ^= b[i];
-	crypto_cipher_encrypt_one(tfm, a, aad);
+	crypto_aead_encrypt(req);
+}
 
-	/* Mask out bits from auth-only-b_0 */
-	b_0[0] &= 0x07;
+int ieee80211_aes_ccm_decrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
+			      u8 *cdata, size_t data_len, u8 *mic, u8 *data)
+{
+	struct scatterlist assoc, pt, ct[2];
 
-	/* S_0 is used to encrypt T (= MIC) */
-	b_0[14] = 0;
-	b_0[15] = 0;
-	crypto_cipher_encrypt_one(tfm, s_0, b_0);
-}
+	/* allocate the variable sized aead_request on the stack */
+	int l = DIV_ROUND_UP(crypto_aead_reqsize(tfm),
+			     sizeof(struct aead_request));
+	struct aead_request req[1 + l];
 
+	memset(req, 0, sizeof(*req) + crypto_aead_reqsize(tfm));
 
-void ieee80211_aes_ccm_encrypt(struct crypto_cipher *tfm, u8 *scratch,
-			       u8 *data, size_t data_len,
-			       u8 *cdata, u8 *mic)
-{
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
-}
+	sg_init_one(&pt, data, data_len);
+	sg_init_one(&assoc, &aad[2], be16_to_cpup((__be16 *)aad));
+	sg_init_table(ct, 2);
+	sg_set_buf(&ct[0], cdata, data_len);
+	sg_set_buf(&ct[1], mic, IEEE80211_CCMP_MIC_LEN);
 
+	aead_request_set_tfm(req, tfm);
+	aead_request_set_crypt(req, ct, &pt, data_len + IEEE80211_CCMP_MIC_LEN,
+			       b_0);
+	aead_request_set_assoc(req, &assoc, assoc.length);
 
-int ieee80211_aes_ccm_decrypt(struct crypto_cipher *tfm, u8 *scratch,
-			      u8 *cdata, size_t data_len, u8 *mic, u8 *data)
-{
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
+	return crypto_aead_decrypt(req);
 }
 
-
-struct crypto_cipher *ieee80211_aes_key_setup_encrypt(const u8 key[])
+struct crypto_aead *ieee80211_aes_key_setup_encrypt(const u8 key[])
 {
-	struct crypto_cipher *tfm;
+	struct crypto_aead *tfm;
+	int err;
 
-	tfm = crypto_alloc_cipher("aes", 0, CRYPTO_ALG_ASYNC);
-	if (!IS_ERR(tfm))
-		crypto_cipher_setkey(tfm, key, WLAN_KEY_LEN_CCMP);
+	tfm = crypto_alloc_aead("ccm(aes)", 0, CRYPTO_ALG_ASYNC);
+	if (IS_ERR(tfm))
+		return tfm;
 
-	return tfm;
-}
+	err = crypto_aead_setkey(tfm, key, WLAN_KEY_LEN_CCMP);
+	if (!err)
+		err = crypto_aead_setauthsize(tfm, IEEE80211_CCMP_MIC_LEN);
+	if (!err)
+		return tfm;
 
+	crypto_free_aead(tfm);
+	return ERR_PTR(err);
+}
 
-void ieee80211_aes_key_free(struct crypto_cipher *tfm)
+void ieee80211_aes_key_free(struct crypto_aead *tfm)
 {
-	crypto_free_cipher(tfm);
+	crypto_free_aead(tfm);
 }
diff --git a/net/mac80211/aes_ccm.h b/net/mac80211/aes_ccm.h
index 5b7d744..52650b3 100644
--- a/net/mac80211/aes_ccm.h
+++ b/net/mac80211/aes_ccm.h
@@ -12,13 +12,13 @@
 
 #include <linux/crypto.h>
 
-struct crypto_cipher *ieee80211_aes_key_setup_encrypt(const u8 key[]);
-void ieee80211_aes_ccm_encrypt(struct crypto_cipher *tfm, u8 *scratch,
+struct crypto_aead *ieee80211_aes_key_setup_encrypt(const u8 key[]);
+void ieee80211_aes_ccm_encrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
 			       u8 *data, size_t data_len,
 			       u8 *cdata, u8 *mic);
-int ieee80211_aes_ccm_decrypt(struct crypto_cipher *tfm, u8 *scratch,
+int ieee80211_aes_ccm_decrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
 			      u8 *cdata, size_t data_len,
 			      u8 *mic, u8 *data);
-void ieee80211_aes_key_free(struct crypto_cipher *tfm);
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
index c9edfcb..c39ee61 100644
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
 	u16 data_len, len_a;
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
@@ -343,7 +337,7 @@ static void ccmp_special_blocks(struct sk_buff *skb, u8 *pn, u8 *scratch,
 		data_len -= IEEE80211_CCMP_MIC_LEN;
 
 	/* First block, b_0 */
-	b_0[0] = 0x59; /* flags: Adata: 1, M: 011, L: 001 */
+	b_0[0] = 0x1; /* set L := 1, M and Adata flags are implied */
 	/* Nonce: Nonce Flags | A2 | PN
 	 * Nonce Flags: Priority (b0..b3) | Management (b4) | Reserved (b5..b7)
 	 */
@@ -407,7 +401,8 @@ static int ccmp_encrypt_skb(struct ieee80211_tx_data *tx, struct sk_buff *skb)
 	u8 *pos;
 	u8 pn[6];
 	u64 pn64;
-	u8 scratch[6 * AES_BLOCK_SIZE];
+	u8 aad[2 * AES_BLOCK_SIZE];
+	u8 b_0[AES_BLOCK_SIZE];
 
 	if (info->control.hw_key &&
 	    !(info->control.hw_key->flags & IEEE80211_KEY_FLAG_GENERATE_IV) &&
@@ -460,8 +455,8 @@ static int ccmp_encrypt_skb(struct ieee80211_tx_data *tx, struct sk_buff *skb)
 		return 0;
 
 	pos += IEEE80211_CCMP_HDR_LEN;
-	ccmp_special_blocks(skb, pn, scratch, 0);
-	ieee80211_aes_ccm_encrypt(key->u.ccmp.tfm, scratch, pos, len,
+	ccmp_special_blocks(skb, pn, b_0, aad, 0);
+	ieee80211_aes_ccm_encrypt(key->u.ccmp.tfm, b_0, aad, pos, len,
 				  pos, skb_put(skb, IEEE80211_CCMP_MIC_LEN));
 
 	return 0;
@@ -525,12 +520,13 @@ ieee80211_crypto_ccmp_decrypt(struct ieee80211_rx_data *rx)
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
 			    skb->data + skb->len - IEEE80211_CCMP_MIC_LEN,
-- 
1.8.1.2
