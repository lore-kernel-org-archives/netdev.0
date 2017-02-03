From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [RFC PATCH 2/2] mac80211: aes-cmac: switch to shash CMAC driver
Date: Fri,  3 Feb 2017 19:25:55 +0000
Message-ID: <1486149955-11825-3-git-send-email-ard.biesheuvel@linaro.org>
References: <1486149955-11825-1-git-send-email-ard.biesheuvel@linaro.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        jouni@qca.qualcomm.com, Ard Biesheuvel <ard.biesheuvel@linaro.org>
To: johannes@sipsolutions.net, linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:37594 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752012AbdBCT0Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 14:26:25 -0500
Received: by mail-wm0-f48.google.com with SMTP id v77so43263930wmv.0
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 11:26:24 -0800 (PST)
In-Reply-To: <1486149955-11825-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of open coding the CMAC algorithm in the mac80211 driver using
byte wide xors and calls into the crypto layer for each block of data,
instantiate a cmac(aes) synchronous hash and pass all the data into it
directly. This does not only simplify the code, it also allows the use
of more efficient and more secure implementations, especially on
platforms where SIMD ciphers have considerable setup time.

Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 net/mac80211/Kconfig    |   1 +
 net/mac80211/aes_cmac.c | 137 +++++---------------
 net/mac80211/aes_cmac.h |  11 +-
 net/mac80211/key.h      |   2 +-
 4 files changed, 42 insertions(+), 109 deletions(-)

diff --git a/net/mac80211/Kconfig b/net/mac80211/Kconfig
index 3891cbd2adea..76e30f4797fb 100644
--- a/net/mac80211/Kconfig
+++ b/net/mac80211/Kconfig
@@ -6,6 +6,7 @@ config MAC80211
 	select CRYPTO_AES
 	select CRYPTO_CCM
 	select CRYPTO_GCM
+	select CRYPTO_CMAC
 	select CRC32
 	---help---
 	  This option enables the hardware independent IEEE 802.11
diff --git a/net/mac80211/aes_cmac.c b/net/mac80211/aes_cmac.c
index d0bd5fff5f0a..fc004720e77c 100644
--- a/net/mac80211/aes_cmac.c
+++ b/net/mac80211/aes_cmac.c
@@ -22,126 +22,57 @@
 #define CMAC_TLEN_256 16 /* CMAC TLen = 128 bits (16 octets) */
 #define AAD_LEN 20
 
+static const u8 zero[CMAC_TLEN_256];
 
-void gf_mulx(u8 *pad)
+void ieee80211_aes_cmac(struct crypto_shash *tfm, const u8 *aad,
+			const u8 *data, size_t data_len, u8 *mic)
 {
-	int i, carry;
-
-	carry = pad[0] & 0x80;
-	for (i = 0; i < AES_BLOCK_SIZE - 1; i++)
-		pad[i] = (pad[i] << 1) | (pad[i + 1] >> 7);
-	pad[AES_BLOCK_SIZE - 1] <<= 1;
-	if (carry)
-		pad[AES_BLOCK_SIZE - 1] ^= 0x87;
-}
+	struct shash_desc *desc;
+	u8 buf[sizeof(*desc) + crypto_shash_descsize(tfm)] CRYPTO_MINALIGN_ATTR;
+	u8 out[crypto_shash_digestsize(tfm)];
 
-void aes_cmac_vector(struct crypto_cipher *tfm, size_t num_elem,
-		     const u8 *addr[], const size_t *len, u8 *mac,
-		     size_t mac_len)
-{
-	u8 cbc[AES_BLOCK_SIZE], pad[AES_BLOCK_SIZE];
-	const u8 *pos, *end;
-	size_t i, e, left, total_len;
-
-	memset(cbc, 0, AES_BLOCK_SIZE);
-
-	total_len = 0;
-	for (e = 0; e < num_elem; e++)
-		total_len += len[e];
-	left = total_len;
-
-	e = 0;
-	pos = addr[0];
-	end = pos + len[0];
-
-	while (left >= AES_BLOCK_SIZE) {
-		for (i = 0; i < AES_BLOCK_SIZE; i++) {
-			cbc[i] ^= *pos++;
-			if (pos >= end) {
-				e++;
-				pos = addr[e];
-				end = pos + len[e];
-			}
-		}
-		if (left > AES_BLOCK_SIZE)
-			crypto_cipher_encrypt_one(tfm, cbc, cbc);
-		left -= AES_BLOCK_SIZE;
-	}
-
-	memset(pad, 0, AES_BLOCK_SIZE);
-	crypto_cipher_encrypt_one(tfm, pad, pad);
-	gf_mulx(pad);
-
-	if (left || total_len == 0) {
-		for (i = 0; i < left; i++) {
-			cbc[i] ^= *pos++;
-			if (pos >= end) {
-				e++;
-				pos = addr[e];
-				end = pos + len[e];
-			}
-		}
-		cbc[left] ^= 0x80;
-		gf_mulx(pad);
-	}
-
-	for (i = 0; i < AES_BLOCK_SIZE; i++)
-		pad[i] ^= cbc[i];
-	crypto_cipher_encrypt_one(tfm, pad, pad);
-	memcpy(mac, pad, mac_len);
-}
+	desc = (struct shash_desc *)buf;
+	desc->tfm = tfm;
 
+	crypto_shash_init(desc);
+	crypto_shash_update(desc, aad, AAD_LEN);
+	crypto_shash_update(desc, data, data_len - CMAC_TLEN);
+	crypto_shash_finup(desc, zero, CMAC_TLEN, out);
 
-void ieee80211_aes_cmac(struct crypto_cipher *tfm, const u8 *aad,
-			const u8 *data, size_t data_len, u8 *mic)
-{
-	const u8 *addr[3];
-	size_t len[3];
-	u8 zero[CMAC_TLEN];
-
-	memset(zero, 0, CMAC_TLEN);
-	addr[0] = aad;
-	len[0] = AAD_LEN;
-	addr[1] = data;
-	len[1] = data_len - CMAC_TLEN;
-	addr[2] = zero;
-	len[2] = CMAC_TLEN;
-
-	aes_cmac_vector(tfm, 3, addr, len, mic, CMAC_TLEN);
+	memcpy(mic, out, CMAC_TLEN);
 }
 
-void ieee80211_aes_cmac_256(struct crypto_cipher *tfm, const u8 *aad,
+void ieee80211_aes_cmac_256(struct crypto_shash *tfm, const u8 *aad,
 			    const u8 *data, size_t data_len, u8 *mic)
 {
-	const u8 *addr[3];
-	size_t len[3];
-	u8 zero[CMAC_TLEN_256];
-
-	memset(zero, 0, CMAC_TLEN_256);
-	addr[0] = aad;
-	len[0] = AAD_LEN;
-	addr[1] = data;
-	len[1] = data_len - CMAC_TLEN_256;
-	addr[2] = zero;
-	len[2] = CMAC_TLEN_256;
-
-	aes_cmac_vector(tfm, 3, addr, len, mic, CMAC_TLEN_256);
+	struct shash_desc *desc;
+	u8 buf[sizeof(*desc) + crypto_shash_descsize(tfm)] CRYPTO_MINALIGN_ATTR;
+	u8 out[crypto_shash_digestsize(tfm)];
+
+	desc = (struct shash_desc *)buf;
+	desc->tfm = tfm;
+
+	crypto_shash_init(desc);
+	crypto_shash_update(desc, aad, AAD_LEN);
+	crypto_shash_update(desc, data, data_len - CMAC_TLEN_256);
+	crypto_shash_finup(desc, zero, CMAC_TLEN_256, out);
+
+	memcpy(mic, out, CMAC_TLEN_256);
 }
 
-struct crypto_cipher *ieee80211_aes_cmac_key_setup(const u8 key[],
-						   size_t key_len)
+struct crypto_shash *ieee80211_aes_cmac_key_setup(const u8 key[],
+						  size_t key_len)
 {
-	struct crypto_cipher *tfm;
+	struct crypto_shash *tfm;
 
-	tfm = crypto_alloc_cipher("aes", 0, CRYPTO_ALG_ASYNC);
+	tfm = crypto_alloc_shash("cmac(aes)", 0, 0);
 	if (!IS_ERR(tfm))
-		crypto_cipher_setkey(tfm, key, key_len);
+		crypto_shash_setkey(tfm, key, key_len);
 
 	return tfm;
 }
 
-
-void ieee80211_aes_cmac_key_free(struct crypto_cipher *tfm)
+void ieee80211_aes_cmac_key_free(struct crypto_shash *tfm)
 {
-	crypto_free_cipher(tfm);
+	crypto_free_shash(tfm);
 }
diff --git a/net/mac80211/aes_cmac.h b/net/mac80211/aes_cmac.h
index 3702041f44fd..fef531f42003 100644
--- a/net/mac80211/aes_cmac.h
+++ b/net/mac80211/aes_cmac.h
@@ -10,13 +10,14 @@
 #define AES_CMAC_H
 
 #include <linux/crypto.h>
+#include <crypto/hash.h>
 
-struct crypto_cipher *ieee80211_aes_cmac_key_setup(const u8 key[],
-						   size_t key_len);
-void ieee80211_aes_cmac(struct crypto_cipher *tfm, const u8 *aad,
+struct crypto_shash *ieee80211_aes_cmac_key_setup(const u8 key[],
+						  size_t key_len);
+void ieee80211_aes_cmac(struct crypto_shash *tfm, const u8 *aad,
 			const u8 *data, size_t data_len, u8 *mic);
-void ieee80211_aes_cmac_256(struct crypto_cipher *tfm, const u8 *aad,
+void ieee80211_aes_cmac_256(struct crypto_shash *tfm, const u8 *aad,
 			    const u8 *data, size_t data_len, u8 *mic);
-void ieee80211_aes_cmac_key_free(struct crypto_cipher *tfm);
+void ieee80211_aes_cmac_key_free(struct crypto_shash *tfm);
 
 #endif /* AES_CMAC_H */
diff --git a/net/mac80211/key.h b/net/mac80211/key.h
index 4aa20cef0859..ebdb80b85dc3 100644
--- a/net/mac80211/key.h
+++ b/net/mac80211/key.h
@@ -93,7 +93,7 @@ struct ieee80211_key {
 		} ccmp;
 		struct {
 			u8 rx_pn[IEEE80211_CMAC_PN_LEN];
-			struct crypto_cipher *tfm;
+			struct crypto_shash *tfm;
 			u32 replays; /* dot11RSNAStatsCMACReplays */
 			u32 icverrors; /* dot11RSNAStatsCMACICVErrors */
 		} aes_cmac;
-- 
2.7.4
