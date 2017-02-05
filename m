From: Ard Biesheuvel <ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH v2 2/2] mac80211: aes-cmac: switch to shash CMAC driver
Date: Sun,  5 Feb 2017 15:23:28 +0000
Message-ID: <1486308208-3252-3-git-send-email-ard.biesheuvel@linaro.org>
References: <1486308208-3252-1-git-send-email-ard.biesheuvel@linaro.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        Ard Biesheuvel <ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, jouni-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1486308208-3252-1-git-send-email-ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Instead of open coding the CMAC algorithm in the mac80211 driver using
byte wide xors and calls into the crypto layer for each block of data,
instantiate a cmac(aes) synchronous hash and pass all the data into it
directly. This does not only simplify the code, it also allows the use
of more efficient and more secure implementations, especially on
platforms where SIMD ciphers have considerable setup time.

Signed-off-by: Ard Biesheuvel <ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
---
 net/mac80211/aes_cmac.c | 130 +++++---------------
 net/mac80211/aes_cmac.h |  11 +-
 net/mac80211/key.h      |   2 +-
 3 files changed, 35 insertions(+), 108 deletions(-)

diff --git a/net/mac80211/aes_cmac.c b/net/mac80211/aes_cmac.c
index d0bd5fff5f0a..0d4d2af52a56 100644
--- a/net/mac80211/aes_cmac.c
+++ b/net/mac80211/aes_cmac.c
@@ -22,126 +22,52 @@
 #define CMAC_TLEN_256 16 /* CMAC TLen = 128 bits (16 octets) */
 #define AAD_LEN 20
 
-
-void gf_mulx(u8 *pad)
-{
-	int i, carry;
-
-	carry = pad[0] & 0x80;
-	for (i = 0; i < AES_BLOCK_SIZE - 1; i++)
-		pad[i] = (pad[i] << 1) | (pad[i + 1] >> 7);
-	pad[AES_BLOCK_SIZE - 1] <<= 1;
-	if (carry)
-		pad[AES_BLOCK_SIZE - 1] ^= 0x87;
-}
-
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
-
-
-void ieee80211_aes_cmac(struct crypto_cipher *tfm, const u8 *aad,
+void ieee80211_aes_cmac(struct crypto_shash *tfm, const u8 *aad,
 			const u8 *data, size_t data_len, u8 *mic)
 {
-	const u8 *addr[3];
-	size_t len[3];
-	u8 zero[CMAC_TLEN];
+	struct shash_desc *desc;
+	u8 buf[sizeof(*desc) + crypto_shash_descsize(tfm)] CRYPTO_MINALIGN_ATTR;
+	u8 out[crypto_shash_digestsize(tfm)];
 
-	memset(zero, 0, CMAC_TLEN);
-	addr[0] = aad;
-	len[0] = AAD_LEN;
-	addr[1] = data;
-	len[1] = data_len - CMAC_TLEN;
-	addr[2] = zero;
-	len[2] = CMAC_TLEN;
+	desc = (struct shash_desc *)buf;
+	desc->tfm = tfm;
 
-	aes_cmac_vector(tfm, 3, addr, len, mic, CMAC_TLEN);
+	crypto_shash_init(desc);
+	crypto_shash_update(desc, aad, AAD_LEN);
+	crypto_shash_update(desc, data, data_len - CMAC_TLEN);
+	crypto_shash_finup(desc, (u8[CMAC_TLEN]){}, CMAC_TLEN, out);
+
+	memcpy(mic, out, CMAC_TLEN);
 }
 
-void ieee80211_aes_cmac_256(struct crypto_cipher *tfm, const u8 *aad,
+void ieee80211_aes_cmac_256(struct crypto_shash *tfm, const u8 *aad,
 			    const u8 *data, size_t data_len, u8 *mic)
 {
-	const u8 *addr[3];
-	size_t len[3];
-	u8 zero[CMAC_TLEN_256];
+	struct shash_desc *desc;
+	u8 buf[sizeof(*desc) + crypto_shash_descsize(tfm)] CRYPTO_MINALIGN_ATTR;
 
-	memset(zero, 0, CMAC_TLEN_256);
-	addr[0] = aad;
-	len[0] = AAD_LEN;
-	addr[1] = data;
-	len[1] = data_len - CMAC_TLEN_256;
-	addr[2] = zero;
-	len[2] = CMAC_TLEN_256;
+	desc = (struct shash_desc *)buf;
+	desc->tfm = tfm;
 
-	aes_cmac_vector(tfm, 3, addr, len, mic, CMAC_TLEN_256);
+	crypto_shash_init(desc);
+	crypto_shash_update(desc, aad, AAD_LEN);
+	crypto_shash_update(desc, data, data_len - CMAC_TLEN_256);
+	crypto_shash_finup(desc, (u8[CMAC_TLEN_256]){}, CMAC_TLEN_256, mic);
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
