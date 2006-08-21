From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 6/7] ieee80211: Fix TKIP and WEP decryption error on SMP machines
Date: Mon, 21 Aug 2006 11:33:56 +0800
Message-ID: <20060821033356.GA4811@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:28791 "EHLO
	orsmga102-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S932550AbWHUDfw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Aug 2006 23:35:52 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The IEEE80211 TKIP and WEP Tx and Rx paths use the same crypto_tfm to encrypt
and decrypt data. During the encrypt and decrypt process, both of them will
set a new key to crypto_tfm. If they happen on the same time, it will
corrupt the crypto_tfm. Thus users will receive an ICV error or Michael MIC
error. This only likely to happen on SMP box with heavy traffic both on Tx
and Rx. The patch use two sets of crypto_tfms to avoid this problem.

Signed-off-by: Hong Liu <hong.liu@intel.com>
Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 net/ieee80211/ieee80211_crypt_tkip.c |   90 +++++++++++++++++++++++-----------
 net/ieee80211/ieee80211_crypt_wep.c  |   35 +++++++++----
 2 files changed, 84 insertions(+), 41 deletions(-)

202a8ffe2b736cbe6f5ea61ff04a10e24b901ed4
diff --git a/net/ieee80211/ieee80211_crypt_tkip.c b/net/ieee80211/ieee80211_crypt_tkip.c
index 02abf29..f2df2f5 100644
--- a/net/ieee80211/ieee80211_crypt_tkip.c
+++ b/net/ieee80211/ieee80211_crypt_tkip.c
@@ -52,8 +52,10 @@ struct ieee80211_tkip_data {
 
 	int key_idx;
 
-	struct crypto_tfm *tfm_arc4;
-	struct crypto_tfm *tfm_michael;
+	struct crypto_tfm *tx_tfm_arc4;
+	struct crypto_tfm *tx_tfm_michael;
+	struct crypto_tfm *rx_tfm_arc4;
+	struct crypto_tfm *rx_tfm_michael;
 
 	/* scratch buffers for virt_to_page() (crypto API) */
 	u8 rx_hdr[16], tx_hdr[16];
@@ -85,15 +87,29 @@ static void *ieee80211_tkip_init(int key
 
 	priv->key_idx = key_idx;
 
-	priv->tfm_arc4 = crypto_alloc_tfm("arc4", 0);
-	if (priv->tfm_arc4 == NULL) {
+	priv->tx_tfm_arc4 = crypto_alloc_tfm("arc4", 0);
+	if (priv->tx_tfm_arc4 == NULL) {
 		printk(KERN_DEBUG "ieee80211_crypt_tkip: could not allocate "
 		       "crypto API arc4\n");
 		goto fail;
 	}
 
-	priv->tfm_michael = crypto_alloc_tfm("michael_mic", 0);
-	if (priv->tfm_michael == NULL) {
+	priv->tx_tfm_michael = crypto_alloc_tfm("michael_mic", 0);
+	if (priv->tx_tfm_michael == NULL) {
+		printk(KERN_DEBUG "ieee80211_crypt_tkip: could not allocate "
+		       "crypto API michael_mic\n");
+		goto fail;
+	}
+
+	priv->rx_tfm_arc4 = crypto_alloc_tfm("arc4", 0);
+	if (priv->rx_tfm_arc4 == NULL) {
+		printk(KERN_DEBUG "ieee80211_crypt_tkip: could not allocate "
+		       "crypto API arc4\n");
+		goto fail;
+	}
+
+	priv->rx_tfm_michael = crypto_alloc_tfm("michael_mic", 0);
+	if (priv->rx_tfm_michael == NULL) {
 		printk(KERN_DEBUG "ieee80211_crypt_tkip: could not allocate "
 		       "crypto API michael_mic\n");
 		goto fail;
@@ -103,10 +119,14 @@ static void *ieee80211_tkip_init(int key
 
       fail:
 	if (priv) {
-		if (priv->tfm_michael)
-			crypto_free_tfm(priv->tfm_michael);
-		if (priv->tfm_arc4)
-			crypto_free_tfm(priv->tfm_arc4);
+		if (priv->tx_tfm_michael)
+			crypto_free_tfm(priv->tx_tfm_michael);
+		if (priv->tx_tfm_arc4)
+			crypto_free_tfm(priv->tx_tfm_arc4);
+		if (priv->rx_tfm_michael)
+			crypto_free_tfm(priv->rx_tfm_michael);
+		if (priv->rx_tfm_arc4)
+			crypto_free_tfm(priv->rx_tfm_arc4);
 		kfree(priv);
 	}
 
@@ -116,10 +136,16 @@ static void *ieee80211_tkip_init(int key
 static void ieee80211_tkip_deinit(void *priv)
 {
 	struct ieee80211_tkip_data *_priv = priv;
-	if (_priv && _priv->tfm_michael)
-		crypto_free_tfm(_priv->tfm_michael);
-	if (_priv && _priv->tfm_arc4)
-		crypto_free_tfm(_priv->tfm_arc4);
+	if (_priv) {
+		if (_priv->tx_tfm_michael)
+			crypto_free_tfm(_priv->tx_tfm_michael);
+		if (_priv->tx_tfm_arc4)
+			crypto_free_tfm(_priv->tx_tfm_arc4);
+		if (_priv->rx_tfm_michael)
+			crypto_free_tfm(_priv->rx_tfm_michael);
+		if (_priv->rx_tfm_arc4)
+			crypto_free_tfm(_priv->rx_tfm_arc4);
+	}
 	kfree(priv);
 }
 
@@ -351,11 +377,11 @@ static int ieee80211_tkip_encrypt(struct
 	icv[2] = crc >> 16;
 	icv[3] = crc >> 24;
 
-	crypto_cipher_setkey(tkey->tfm_arc4, rc4key, 16);
+	crypto_cipher_setkey(tkey->tx_tfm_arc4, rc4key, 16);
 	sg.page = virt_to_page(pos);
 	sg.offset = offset_in_page(pos);
 	sg.length = len + 4;
-	crypto_cipher_encrypt(tkey->tfm_arc4, &sg, &sg, len + 4);
+	crypto_cipher_encrypt(tkey->tx_tfm_arc4, &sg, &sg, len + 4);
 
 	return 0;
 }
@@ -446,11 +472,11 @@ static int ieee80211_tkip_decrypt(struct
 
 	plen = skb->len - hdr_len - 12;
 
-	crypto_cipher_setkey(tkey->tfm_arc4, rc4key, 16);
+	crypto_cipher_setkey(tkey->rx_tfm_arc4, rc4key, 16);
 	sg.page = virt_to_page(pos);
 	sg.offset = offset_in_page(pos);
 	sg.length = plen + 4;
-	crypto_cipher_decrypt(tkey->tfm_arc4, &sg, &sg, plen + 4);
+	crypto_cipher_decrypt(tkey->rx_tfm_arc4, &sg, &sg, plen + 4);
 
 	crc = ~crc32_le(~0, pos, plen);
 	icv[0] = crc;
@@ -484,12 +510,12 @@ static int ieee80211_tkip_decrypt(struct
 	return keyidx;
 }
 
-static int michael_mic(struct ieee80211_tkip_data *tkey, u8 * key, u8 * hdr,
+static int michael_mic(struct crypto_tfm *tfm_michael, u8 * key, u8 * hdr,
 		       u8 * data, size_t data_len, u8 * mic)
 {
 	struct scatterlist sg[2];
 
-	if (tkey->tfm_michael == NULL) {
+	if (tfm_michael == NULL) {
 		printk(KERN_WARNING "michael_mic: tfm_michael == NULL\n");
 		return -1;
 	}
@@ -501,10 +527,10 @@ static int michael_mic(struct ieee80211_
 	sg[1].offset = offset_in_page(data);
 	sg[1].length = data_len;
 
-	crypto_digest_init(tkey->tfm_michael);
-	crypto_digest_setkey(tkey->tfm_michael, key, 8);
-	crypto_digest_update(tkey->tfm_michael, sg, 2);
-	crypto_digest_final(tkey->tfm_michael, mic);
+	crypto_digest_init(tfm_michael);
+	crypto_digest_setkey(tfm_michael, key, 8);
+	crypto_digest_update(tfm_michael, sg, 2);
+	crypto_digest_final(tfm_michael, mic);
 
 	return 0;
 }
@@ -562,7 +588,7 @@ static int ieee80211_michael_mic_add(str
 
 	michael_mic_hdr(skb, tkey->tx_hdr);
 	pos = skb_put(skb, 8);
-	if (michael_mic(tkey, &tkey->key[16], tkey->tx_hdr,
+	if (michael_mic(tkey->tx_tfm_michael, &tkey->key[16], tkey->tx_hdr,
 			skb->data + hdr_len, skb->len - 8 - hdr_len, pos))
 		return -1;
 
@@ -600,7 +626,7 @@ static int ieee80211_michael_mic_verify(
 		return -1;
 
 	michael_mic_hdr(skb, tkey->rx_hdr);
-	if (michael_mic(tkey, &tkey->key[24], tkey->rx_hdr,
+	if (michael_mic(tkey->rx_tfm_michael, &tkey->key[24], tkey->rx_hdr,
 			skb->data + hdr_len, skb->len - 8 - hdr_len, mic))
 		return -1;
 	if (memcmp(mic, skb->data + skb->len - 8, 8) != 0) {
@@ -630,14 +656,18 @@ static int ieee80211_tkip_set_key(void *
 {
 	struct ieee80211_tkip_data *tkey = priv;
 	int keyidx;
-	struct crypto_tfm *tfm = tkey->tfm_michael;
-	struct crypto_tfm *tfm2 = tkey->tfm_arc4;
+	struct crypto_tfm *tfm = tkey->tx_tfm_michael;
+	struct crypto_tfm *tfm2 = tkey->tx_tfm_arc4;
+	struct crypto_tfm *tfm3 = tkey->rx_tfm_michael;
+	struct crypto_tfm *tfm4 = tkey->rx_tfm_arc4;
 
 	keyidx = tkey->key_idx;
 	memset(tkey, 0, sizeof(*tkey));
 	tkey->key_idx = keyidx;
-	tkey->tfm_michael = tfm;
-	tkey->tfm_arc4 = tfm2;
+	tkey->tx_tfm_michael = tfm;
+	tkey->tx_tfm_arc4 = tfm2;
+	tkey->rx_tfm_michael = tfm3;
+	tkey->rx_tfm_arc4 = tfm4;
 	if (len == TKIP_KEY_LEN) {
 		memcpy(tkey->key, key, TKIP_KEY_LEN);
 		tkey->key_set = 1;
diff --git a/net/ieee80211/ieee80211_crypt_wep.c b/net/ieee80211/ieee80211_crypt_wep.c
index 0ebf235..b435b28 100644
--- a/net/ieee80211/ieee80211_crypt_wep.c
+++ b/net/ieee80211/ieee80211_crypt_wep.c
@@ -32,7 +32,8 @@ struct prism2_wep_data {
 	u8 key[WEP_KEY_LEN + 1];
 	u8 key_len;
 	u8 key_idx;
-	struct crypto_tfm *tfm;
+	struct crypto_tfm *tx_tfm;
+	struct crypto_tfm *rx_tfm;
 };
 
 static void *prism2_wep_init(int keyidx)
@@ -44,13 +45,19 @@ static void *prism2_wep_init(int keyidx)
 		goto fail;
 	priv->key_idx = keyidx;
 
-	priv->tfm = crypto_alloc_tfm("arc4", 0);
-	if (priv->tfm == NULL) {
+	priv->tx_tfm = crypto_alloc_tfm("arc4", 0);
+	if (priv->tx_tfm == NULL) {
 		printk(KERN_DEBUG "ieee80211_crypt_wep: could not allocate "
 		       "crypto API arc4\n");
 		goto fail;
 	}
 
+	priv->rx_tfm = crypto_alloc_tfm("arc4", 0);
+	if (priv->rx_tfm == NULL) {
+		printk(KERN_DEBUG "ieee80211_crypt_wep: could not allocate "
+		       "crypto API arc4\n");
+		goto fail;
+	}
 	/* start WEP IV from a random value */
 	get_random_bytes(&priv->iv, 4);
 
@@ -58,8 +65,10 @@ static void *prism2_wep_init(int keyidx)
 
       fail:
 	if (priv) {
-		if (priv->tfm)
-			crypto_free_tfm(priv->tfm);
+		if (priv->tx_tfm)
+			crypto_free_tfm(priv->tx_tfm);
+		if (priv->rx_tfm)
+			crypto_free_tfm(priv->rx_tfm);
 		kfree(priv);
 	}
 	return NULL;
@@ -68,8 +77,12 @@ static void *prism2_wep_init(int keyidx)
 static void prism2_wep_deinit(void *priv)
 {
 	struct prism2_wep_data *_priv = priv;
-	if (_priv && _priv->tfm)
-		crypto_free_tfm(_priv->tfm);
+	if (_priv) {
+		if (_priv->tx_tfm)
+			crypto_free_tfm(_priv->tx_tfm);
+		if (_priv->rx_tfm)
+			crypto_free_tfm(_priv->rx_tfm);
+	}
 	kfree(priv);
 }
 
@@ -151,11 +164,11 @@ static int prism2_wep_encrypt(struct sk_
 	icv[2] = crc >> 16;
 	icv[3] = crc >> 24;
 
-	crypto_cipher_setkey(wep->tfm, key, klen);
+	crypto_cipher_setkey(wep->tx_tfm, key, klen);
 	sg.page = virt_to_page(pos);
 	sg.offset = offset_in_page(pos);
 	sg.length = len + 4;
-	crypto_cipher_encrypt(wep->tfm, &sg, &sg, len + 4);
+	crypto_cipher_encrypt(wep->tx_tfm, &sg, &sg, len + 4);
 
 	return 0;
 }
@@ -194,11 +207,11 @@ static int prism2_wep_decrypt(struct sk_
 	/* Apply RC4 to data and compute CRC32 over decrypted data */
 	plen = skb->len - hdr_len - 8;
 
-	crypto_cipher_setkey(wep->tfm, key, klen);
+	crypto_cipher_setkey(wep->rx_tfm, key, klen);
 	sg.page = virt_to_page(pos);
 	sg.offset = offset_in_page(pos);
 	sg.length = plen + 4;
-	crypto_cipher_decrypt(wep->tfm, &sg, &sg, plen + 4);
+	crypto_cipher_decrypt(wep->rx_tfm, &sg, &sg, plen + 4);
 
 	crc = ~crc32_le(~0, pos, plen);
 	icv[0] = crc;
-- 
1.2.6
