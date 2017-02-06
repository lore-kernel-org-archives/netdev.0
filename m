From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH v3 1/2] mac80211: fils_aead: Use crypto api CMAC shash rather than bare cipher
Date: Mon,  6 Feb 2017 10:49:27 +0000
Message-ID: <1486378168-31028-2-git-send-email-ard.biesheuvel@linaro.org>
References: <1486378168-31028-1-git-send-email-ard.biesheuvel@linaro.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        jouni@qca.qualcomm.com, Ard Biesheuvel <ard.biesheuvel@linaro.org>
To: johannes@sipsolutions.net, linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f177.google.com ([209.85.128.177]:33214 "EHLO
        mail-wr0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751038AbdBFKtq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 05:49:46 -0500
Received: by mail-wr0-f177.google.com with SMTP id i10so21388401wrb.0
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 02:49:45 -0800 (PST)
In-Reply-To: <1486378168-31028-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Switch the FILS AEAD code to use a cmac(aes) shash instantiated by the
crypto API rather than reusing the open coded implementation in
aes_cmac_vector(). This makes the code more understandable, and allows
platforms to implement cmac(aes) in a more secure (*) and efficient way
than is typically possible when using the AES cipher directly.

So replace the crypto_cipher by a crypto_shash, and update the aes_s2v()
routine to call the shash interface directly.

* In particular, the generic table based AES implementation is sensitive
  to known-plaintext timing attacks on the key, to which AES based MAC
  algorithms are especially vulnerable, given that their plaintext is not
  usually secret. Time invariant alternatives are available (e.g., based
  on SIMD algorithms), but may incur a setup cost that is prohibitive when
  operating on a single block at a time, which is why they don't usually
  expose the cipher API.

Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 net/mac80211/Kconfig     |  1 +
 net/mac80211/aes_cmac.h  |  4 --
 net/mac80211/fils_aead.c | 74 +++++++++-----------
 3 files changed, 34 insertions(+), 45 deletions(-)

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
diff --git a/net/mac80211/aes_cmac.h b/net/mac80211/aes_cmac.h
index c827e1d5de8b..3702041f44fd 100644
--- a/net/mac80211/aes_cmac.h
+++ b/net/mac80211/aes_cmac.h
@@ -11,10 +11,6 @@
 
 #include <linux/crypto.h>
 
-void gf_mulx(u8 *pad);
-void aes_cmac_vector(struct crypto_cipher *tfm, size_t num_elem,
-		     const u8 *addr[], const size_t *len, u8 *mac,
-		     size_t mac_len);
 struct crypto_cipher *ieee80211_aes_cmac_key_setup(const u8 key[],
 						   size_t key_len);
 void ieee80211_aes_cmac(struct crypto_cipher *tfm, const u8 *aad,
diff --git a/net/mac80211/fils_aead.c b/net/mac80211/fils_aead.c
index 5c3af5eb4052..3cfb1e2ab7ac 100644
--- a/net/mac80211/fils_aead.c
+++ b/net/mac80211/fils_aead.c
@@ -9,66 +9,58 @@
 
 #include <crypto/aes.h>
 #include <crypto/algapi.h>
+#include <crypto/hash.h>
 #include <crypto/skcipher.h>
 
 #include "ieee80211_i.h"
 #include "aes_cmac.h"
 #include "fils_aead.h"
 
-static int aes_s2v(struct crypto_cipher *tfm,
+static void gf_mulx(u8 *pad)
+{
+	u64 a = get_unaligned_be64(pad);
+	u64 b = get_unaligned_be64(pad + 8);
+
+	put_unaligned_be64((a << 1) | (b >> 63), pad);
+	put_unaligned_be64((b << 1) ^ ((a >> 63) ? 0x87 : 0), pad + 8);
+}
+
+static int aes_s2v(struct crypto_shash *tfm,
 		   size_t num_elem, const u8 *addr[], size_t len[], u8 *v)
 {
-	u8 d[AES_BLOCK_SIZE], tmp[AES_BLOCK_SIZE];
+	u8 d[AES_BLOCK_SIZE], tmp[AES_BLOCK_SIZE] = {};
+	SHASH_DESC_ON_STACK(desc, tfm);
 	size_t i;
-	const u8 *data[2];
-	size_t data_len[2], data_elems;
+
+	desc->tfm = tfm;
 
 	/* D = AES-CMAC(K, <zero>) */
-	memset(tmp, 0, AES_BLOCK_SIZE);
-	data[0] = tmp;
-	data_len[0] = AES_BLOCK_SIZE;
-	aes_cmac_vector(tfm, 1, data, data_len, d, AES_BLOCK_SIZE);
+	crypto_shash_digest(desc, tmp, AES_BLOCK_SIZE, d);
 
 	for (i = 0; i < num_elem - 1; i++) {
 		/* D = dbl(D) xor AES_CMAC(K, Si) */
 		gf_mulx(d); /* dbl */
-		aes_cmac_vector(tfm, 1, &addr[i], &len[i], tmp,
-				AES_BLOCK_SIZE);
+		crypto_shash_digest(desc, addr[i], len[i], tmp);
 		crypto_xor(d, tmp, AES_BLOCK_SIZE);
 	}
 
+	crypto_shash_init(desc);
+
 	if (len[i] >= AES_BLOCK_SIZE) {
 		/* len(Sn) >= 128 */
-		size_t j;
-		const u8 *pos;
-
 		/* T = Sn xorend D */
-
-		/* Use a temporary buffer to perform xorend on Sn (addr[i]) to
-		 * avoid modifying the const input argument.
-		 */
-		data[0] = addr[i];
-		data_len[0] = len[i] - AES_BLOCK_SIZE;
-		pos = addr[i] + data_len[0];
-		for (j = 0; j < AES_BLOCK_SIZE; j++)
-			tmp[j] = pos[j] ^ d[j];
-		data[1] = tmp;
-		data_len[1] = AES_BLOCK_SIZE;
-		data_elems = 2;
+		crypto_shash_update(desc, addr[i], len[i] - AES_BLOCK_SIZE);
+		crypto_xor(d, addr[i] + len[i] - AES_BLOCK_SIZE,
+			   AES_BLOCK_SIZE);
 	} else {
 		/* len(Sn) < 128 */
 		/* T = dbl(D) xor pad(Sn) */
 		gf_mulx(d); /* dbl */
-		memset(tmp, 0, AES_BLOCK_SIZE);
-		memcpy(tmp, addr[i], len[i]);
-		tmp[len[i]] = 0x80;
-		crypto_xor(d, tmp, AES_BLOCK_SIZE);
-		data[0] = d;
-		data_len[0] = sizeof(d);
-		data_elems = 1;
+		crypto_xor(d, addr[i], len[i]);
+		d[len[i]] ^= 0x80;
 	}
 	/* V = AES-CMAC(K, T) */
-	aes_cmac_vector(tfm, data_elems, data, data_len, v, AES_BLOCK_SIZE);
+	crypto_shash_finup(desc, d, AES_BLOCK_SIZE, v);
 
 	return 0;
 }
@@ -80,7 +72,7 @@ static int aes_siv_encrypt(const u8 *key, size_t key_len,
 			   size_t len[], u8 *out)
 {
 	u8 v[AES_BLOCK_SIZE];
-	struct crypto_cipher *tfm;
+	struct crypto_shash *tfm;
 	struct crypto_skcipher *tfm2;
 	struct skcipher_request *req;
 	int res;
@@ -95,14 +87,14 @@ static int aes_siv_encrypt(const u8 *key, size_t key_len,
 
 	/* S2V */
 
-	tfm = crypto_alloc_cipher("aes", 0, 0);
+	tfm = crypto_alloc_shash("cmac(aes)", 0, 0);
 	if (IS_ERR(tfm))
 		return PTR_ERR(tfm);
 	/* K1 for S2V */
-	res = crypto_cipher_setkey(tfm, key, key_len);
+	res = crypto_shash_setkey(tfm, key, key_len);
 	if (!res)
 		res = aes_s2v(tfm, num_elem, addr, len, v);
-	crypto_free_cipher(tfm);
+	crypto_free_shash(tfm);
 	if (res)
 		return res;
 
@@ -157,7 +149,7 @@ static int aes_siv_decrypt(const u8 *key, size_t key_len,
 			   size_t num_elem, const u8 *addr[], size_t len[],
 			   u8 *out)
 {
-	struct crypto_cipher *tfm;
+	struct crypto_shash *tfm;
 	struct crypto_skcipher *tfm2;
 	struct skcipher_request *req;
 	struct scatterlist src[1], dst[1];
@@ -210,14 +202,14 @@ static int aes_siv_decrypt(const u8 *key, size_t key_len,
 
 	/* S2V */
 
-	tfm = crypto_alloc_cipher("aes", 0, 0);
+	tfm = crypto_alloc_shash("cmac(aes)", 0, 0);
 	if (IS_ERR(tfm))
 		return PTR_ERR(tfm);
 	/* K1 for S2V */
-	res = crypto_cipher_setkey(tfm, key, key_len);
+	res = crypto_shash_setkey(tfm, key, key_len);
 	if (!res)
 		res = aes_s2v(tfm, num_elem, addr, len, check);
-	crypto_free_cipher(tfm);
+	crypto_free_shash(tfm);
 	if (res)
 		return res;
 	if (memcmp(check, frame_iv, AES_BLOCK_SIZE) != 0)
-- 
2.7.4
