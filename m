From: David Kimdon <david.kimdon@devicescape.com>
Subject: [take1] d80211: switch crypto to use new ciphers API
Date: Mon, 30 Oct 2006 10:08:58 -0800
Message-ID: <20061030180858.GA12593@devicescape.com>
References: <20061025224150.GA7364@devicescape.com> <20061026000624.GA29389@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Kimdon <david.kimdon@devicescape.com>,
	netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:4248 "EHLO
	mail.devicescape.com") by vger.kernel.org with ESMTP
	id S965138AbWJ3SJJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Oct 2006 13:09:09 -0500
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20061026000624.GA29389@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 26, 2006 at 10:06:24AM +1000, Herbert Xu wrote:
> If you're only encrypting/decrypting a single block then you should
> use the cipher interface.  So net/d80211/aes_ccm.c should do that
> instead.  See drivers/net/wirless/airo.c for an example of that.

Thanks Herbert.

Updated patch, now aes, tkip and wep are all tested.

Changes from take0:

Use IS_ERR() to evaluate return value of crypto_alloc_cipher().  Use
ciper interface rather than blkcipher for aes encryption since we only
encrypt a single block at a time.

--------

Switch d80211 software crypto to use the new cipher API.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>

Index: wireless-dev/net/d80211/wep.c
===================================================================
--- wireless-dev.orig/net/d80211/wep.c
+++ wireless-dev/net/d80211/wep.c
@@ -14,6 +14,7 @@
 #include <linux/compiler.h>
 #include <linux/crc32.h>
 #include <linux/crypto.h>
+#include <linux/err.h>
 #include <asm/scatterlist.h>
 
 #include <net/d80211.h>
@@ -26,8 +27,9 @@ int ieee80211_wep_init(struct ieee80211_
 	/* start WEP IV from a random value */
 	get_random_bytes(&local->wep_iv, WEP_IV_LEN);
 
-	local->wep_tfm = crypto_alloc_tfm("arc4", 0);
-	if (!local->wep_tfm)
+	local->wep_tfm = crypto_alloc_blkcipher("ecb(arc4)", 0,
+						CRYPTO_ALG_ASYNC);
+	if (IS_ERR(local->wep_tfm))
 		return -ENOMEM;
 
 	return 0;
@@ -35,7 +37,7 @@ int ieee80211_wep_init(struct ieee80211_
 
 void ieee80211_wep_free(struct ieee80211_local *local)
 {
-	crypto_free_tfm(local->wep_tfm);
+	crypto_free_blkcipher(local->wep_tfm);
 }
 
 static inline int ieee80211_wep_weak_iv(u32 iv, int keylen)
@@ -116,20 +118,21 @@ void ieee80211_wep_remove_iv(struct ieee
 /* Perform WEP encryption using given key. data buffer must have tailroom
  * for 4-byte ICV. data_len must not include this ICV. Note: this function
  * does _not_ add IV. data = RC4(data | CRC32(data)) */
-void ieee80211_wep_encrypt_data(struct crypto_tfm *tfm, u8 *rc4key,
+void ieee80211_wep_encrypt_data(struct crypto_blkcipher *tfm, u8 *rc4key,
 				size_t klen, u8 *data, size_t data_len)
 {
+	struct blkcipher_desc desc = { .tfm = tfm };
 	struct scatterlist sg;
 	__le32 *icv;
 
 	icv = (__le32 *)(data + data_len);
 	*icv = cpu_to_le32(~crc32_le(~0, data, data_len));
 
-	crypto_cipher_setkey(tfm, rc4key, klen);
+	crypto_blkcipher_setkey(tfm, rc4key, klen);
 	sg.page = virt_to_page(data);
 	sg.offset = offset_in_page(data);
 	sg.length = data_len + WEP_ICV_LEN;
-	crypto_cipher_encrypt(tfm, &sg, &sg, sg.length);
+	crypto_blkcipher_encrypt(&desc, &sg, &sg, sg.length);
 }
 
 
@@ -183,17 +186,18 @@ int ieee80211_wep_encrypt(struct ieee802
 /* Perform WEP decryption using given key. data buffer includes encrypted
  * payload, including 4-byte ICV, but _not_ IV. data_len must not include ICV.
  * Return 0 on success and -1 on ICV mismatch. */
-int ieee80211_wep_decrypt_data(struct crypto_tfm *tfm, u8 *rc4key,
+int ieee80211_wep_decrypt_data(struct crypto_blkcipher *tfm, u8 *rc4key,
 			       size_t klen, u8 *data, size_t data_len)
 {
+	struct blkcipher_desc desc = { .tfm = tfm };
 	struct scatterlist sg;
 	__le32 crc;
 
-	crypto_cipher_setkey(tfm, rc4key, klen);
+	crypto_blkcipher_setkey(tfm, rc4key, klen);
 	sg.page = virt_to_page(data);
 	sg.offset = offset_in_page(data);
 	sg.length = data_len + WEP_ICV_LEN;
-	crypto_cipher_decrypt(tfm, &sg, &sg, sg.length);
+	crypto_blkcipher_decrypt(&desc, &sg, &sg, sg.length);
 
 	crc = cpu_to_le32(~crc32_le(~0, data, data_len));
 	if (memcmp(&crc, data + data_len, WEP_ICV_LEN) != 0)
Index: wireless-dev/net/d80211/aes_ccm.c
===================================================================
--- wireless-dev.orig/net/d80211/aes_ccm.c
+++ wireless-dev/net/d80211/aes_ccm.c
@@ -9,6 +9,7 @@
 
 #include <linux/types.h>
 #include <linux/crypto.h>
+#include <linux/err.h>
 #include <asm/scatterlist.h>
 
 #include <net/d80211.h>
@@ -16,24 +17,14 @@
 #include "aes_ccm.h"
 
 
-static void ieee80211_aes_encrypt(struct crypto_tfm *tfm,
+static void ieee80211_aes_encrypt(struct crypto_cipher *tfm,
 				  const u8 pt[16], u8 ct[16])
 {
-	struct scatterlist src, dst;
-
-	src.page = virt_to_page(pt);
-	src.offset = offset_in_page(pt);
-	src.length = AES_BLOCK_LEN;
-
-	dst.page = virt_to_page(ct);
-	dst.offset = offset_in_page(ct);
-	dst.length = AES_BLOCK_LEN;
-
-	crypto_cipher_encrypt(tfm, &dst, &src, AES_BLOCK_LEN);
+	crypto_cipher_encrypt_one(tfm, ct, pt);
 }
 
 
-static inline void aes_ccm_prepare(struct crypto_tfm *tfm, u8 *b_0, u8 *aad,
+static inline void aes_ccm_prepare(struct crypto_cipher *tfm, u8 *b_0, u8 *aad,
 				   u8 *b, u8 *s_0, u8 *a)
 {
 	int i;
@@ -61,7 +52,7 @@ static inline void aes_ccm_prepare(struc
 }
 
 
-void ieee80211_aes_ccm_encrypt(struct crypto_tfm *tfm, u8 *scratch,
+void ieee80211_aes_ccm_encrypt(struct crypto_cipher *tfm, u8 *scratch,
 			       u8 *b_0, u8 *aad, u8 *data, size_t data_len,
 			       u8 *cdata, u8 *mic)
 {
@@ -100,7 +91,7 @@ void ieee80211_aes_ccm_encrypt(struct cr
 }
 
 
-int ieee80211_aes_ccm_decrypt(struct crypto_tfm *tfm, u8 *scratch,
+int ieee80211_aes_ccm_decrypt(struct crypto_cipher *tfm, u8 *scratch,
 			      u8 *b_0, u8 *aad, u8 *cdata, size_t data_len,
 			      u8 *mic, u8 *data)
 {
@@ -143,12 +134,12 @@ int ieee80211_aes_ccm_decrypt(struct cry
 }
 
 
-struct crypto_tfm * ieee80211_aes_key_setup_encrypt(const u8 key[])
+struct crypto_cipher * ieee80211_aes_key_setup_encrypt(const u8 key[])
 {
-	struct crypto_tfm *tfm;
+	struct crypto_cipher *tfm;
 
-	tfm = crypto_alloc_tfm("aes", 0);
-	if (!tfm)
+	tfm = crypto_alloc_cipher("aes", 0, CRYPTO_ALG_ASYNC);
+	if (IS_ERR(tfm))
 		return NULL;
 
 	crypto_cipher_setkey(tfm, key, ALG_CCMP_KEY_LEN);
@@ -157,8 +148,8 @@ struct crypto_tfm * ieee80211_aes_key_se
 }
 
 
-void ieee80211_aes_key_free(struct crypto_tfm *tfm)
+void ieee80211_aes_key_free(struct crypto_cipher *tfm)
 {
 	if (tfm)
-		crypto_free_tfm(tfm);
+		crypto_free_cipher(tfm);
 }
Index: wireless-dev/net/d80211/aes_ccm.h
===================================================================
--- wireless-dev.orig/net/d80211/aes_ccm.h
+++ wireless-dev/net/d80211/aes_ccm.h
@@ -14,13 +14,13 @@
 
 #define AES_BLOCK_LEN 16
 
-struct crypto_tfm * ieee80211_aes_key_setup_encrypt(const u8 key[]);
-void ieee80211_aes_ccm_encrypt(struct crypto_tfm *tfm, u8 *scratch,
+struct crypto_cipher * ieee80211_aes_key_setup_encrypt(const u8 key[]);
+void ieee80211_aes_ccm_encrypt(struct crypto_cipher *tfm, u8 *scratch,
 			       u8 *b_0, u8 *aad, u8 *data, size_t data_len,
 			       u8 *cdata, u8 *mic);
-int ieee80211_aes_ccm_decrypt(struct crypto_tfm *tfm, u8 *scratch,
+int ieee80211_aes_ccm_decrypt(struct crypto_cipher *tfm, u8 *scratch,
 			      u8 *b_0, u8 *aad, u8 *cdata, size_t data_len,
 			      u8 *mic, u8 *data);
-void ieee80211_aes_key_free(struct crypto_tfm *tfm);
+void ieee80211_aes_key_free(struct crypto_cipher *tfm);
 
 #endif /* AES_CCM_H */
Index: wireless-dev/net/d80211/ieee80211_i.h
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211_i.h
+++ wireless-dev/net/d80211/ieee80211_i.h
@@ -401,7 +401,7 @@ struct ieee80211_local {
 	int long_retry_limit; /* dot11LongRetryLimit */
 	int short_preamble; /* use short preamble with IEEE 802.11b */
 
-	struct crypto_tfm *wep_tfm;
+	struct crypto_blkcipher *wep_tfm;
 	u32 wep_iv;
 	int key_tx_rx_threshold; /* number of times any key can be used in TX
 				  * or RX before generating a rekey
Index: wireless-dev/net/d80211/ieee80211_key.h
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211_key.h
+++ wireless-dev/net/d80211/ieee80211_key.h
@@ -12,6 +12,7 @@
 
 #include <linux/types.h>
 #include <linux/kobject.h>
+#include <linux/crypto.h>
 #include <net/d80211.h>
 
 /* ALG_TKIP
@@ -62,7 +63,7 @@ struct ieee80211_key {
 		struct {
 			u8 tx_pn[6];
 			u8 rx_pn[NUM_RX_DATA_QUEUES][6];
-			struct crypto_tfm *tfm;
+			struct crypto_cipher *tfm;
 			u32 replays; /* dot11RSNAStatsCCMPReplays */
 			/* scratch buffers for virt_to_page() (crypto API) */
 #ifndef AES_BLOCK_LEN
Index: wireless-dev/net/d80211/tkip.c
===================================================================
--- wireless-dev.orig/net/d80211/tkip.c
+++ wireless-dev/net/d80211/tkip.c
@@ -196,7 +196,8 @@ u8 * ieee80211_tkip_add_iv(u8 *pos, stru
  * headroom of eight octets for IV and Ext. IV and taildroom of four octets
  * for ICV. @payload_len is the length of payload (_not_ including extra
  * headroom and tailroom). @ta is the transmitter addresses. */
-void ieee80211_tkip_encrypt_data(struct crypto_tfm *tfm, struct ieee80211_key *key,
+void ieee80211_tkip_encrypt_data(struct crypto_blkcipher *tfm,
+				 struct ieee80211_key *key,
 				 u8 *pos, size_t payload_len, u8 *ta)
 {
 	u8 rc4key[16];
@@ -221,7 +222,8 @@ void ieee80211_tkip_encrypt_data(struct 
  * beginning of the buffer containing IEEE 802.11 header payload, i.e.,
  * including IV, Ext. IV, real data, Michael MIC, ICV. @payload_len is the
  * length of payload, including IV, Ext. IV, MIC, ICV.  */
-int ieee80211_tkip_decrypt_data(struct crypto_tfm *tfm, struct ieee80211_key *key,
+int ieee80211_tkip_decrypt_data(struct crypto_blkcipher *tfm,
+				struct ieee80211_key *key,
 				u8 *payload, size_t payload_len, u8 *ta,
 				int only_iv, int queue)
 {
Index: wireless-dev/net/d80211/tkip.h
===================================================================
--- wireless-dev.orig/net/d80211/tkip.h
+++ wireless-dev/net/d80211/tkip.h
@@ -15,7 +15,8 @@
 
 u8 * ieee80211_tkip_add_iv(u8 *pos, struct ieee80211_key *key,
 			   u8 iv0, u8 iv1, u8 iv2);
-void ieee80211_tkip_encrypt_data(struct crypto_tfm *tfm, struct ieee80211_key *key,
+void ieee80211_tkip_encrypt_data(struct crypto_blkcipher *tfm,
+				 struct ieee80211_key *key,
 				 u8 *pos, size_t payload_len, u8 *ta);
 enum {
 	TKIP_DECRYPT_OK = 0,
@@ -23,7 +24,8 @@ enum {
 	TKIP_DECRYPT_INVALID_KEYIDX = -2,
 	TKIP_DECRYPT_REPLAY = -3,
 };
-int ieee80211_tkip_decrypt_data(struct crypto_tfm *tfm, struct ieee80211_key *key,
+int ieee80211_tkip_decrypt_data(struct crypto_blkcipher *tfm,
+				struct ieee80211_key *key,
 				u8 *payload, size_t payload_len, u8 *ta,
 				int only_iv, int queue);
 
Index: wireless-dev/net/d80211/wep.h
===================================================================
--- wireless-dev.orig/net/d80211/wep.h
+++ wireless-dev/net/d80211/wep.h
@@ -26,10 +26,10 @@ u8 * ieee80211_wep_add_iv(struct ieee802
 void ieee80211_wep_remove_iv(struct ieee80211_local *local,
 			     struct sk_buff *skb,
 			     struct ieee80211_key *key);
-void ieee80211_wep_encrypt_data(struct crypto_tfm *tfm, u8 *rc4key, size_t klen,
-				u8 *data, size_t data_len);
-int ieee80211_wep_decrypt_data(struct crypto_tfm *tfm, u8 *rc4key, size_t klen,
-			       u8 *data, size_t data_len);
+void ieee80211_wep_encrypt_data(struct crypto_blkcipher *tfm, u8 *rc4key,
+				size_t klen, u8 *data, size_t data_len);
+int ieee80211_wep_decrypt_data(struct crypto_blkcipher *tfm, u8 *rc4key,
+			       size_t klen, u8 *data, size_t data_len);
 int ieee80211_wep_encrypt(struct ieee80211_local *local, struct sk_buff *skb,
 			  struct ieee80211_key *key);
 int ieee80211_wep_decrypt(struct ieee80211_local *local, struct sk_buff *skb,
