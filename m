From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 8/9] d80211: Replace rc4 code with crypto api arc4
Date: Tue, 18 Jul 2006 17:45:29 +0200 (CEST)
Message-ID: <20060718154529.2656F483BB@silver.suse.cz>
References: <20060718174442.485760904.midnight@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:41353 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S932291AbWGRPnm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2006 11:43:42 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060718174442.485760904.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Wu <flamingice@sourmilk.net>

This patch replaces the rc4 code used in wep.c with crypto api's arc4
cipher. The struct crypto_tfm passing in tkip isn't great, but it'll get fixed
when tkip is converted to use crypto api entirely. (michael_mic)

Signed-off-by: Michael Wu <flamingice@sourmilk.net>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/Kconfig       |    1 
 net/d80211/ieee80211.c   |   10 ++
 net/d80211/ieee80211_i.h |    1 
 net/d80211/tkip.c        |   14 ++-
 net/d80211/tkip.h        |   10 +-
 net/d80211/wep.c         |  193 ++++++++++------------------------------------
 net/d80211/wep.h         |   11 +--
 net/d80211/wpa.c         |    4 -
 8 files changed, 73 insertions(+), 171 deletions(-)

a495f8ec7590d6df5edc36bff419f25b8c3440de
diff --git a/net/d80211/Kconfig b/net/d80211/Kconfig
index e61e189..36df52d 100644
--- a/net/d80211/Kconfig
+++ b/net/d80211/Kconfig
@@ -1,6 +1,7 @@
 config D80211
 	tristate "Generic IEEE 802.11 Networking Stack (dscape)"
 	select CRYPTO
+	select CRYPTO_ARC4
 	select CRYPTO_AES
 	---help---
 	This option enables the hardware independent IEEE 802.11
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index cc06675..4e80767 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -4475,11 +4475,16 @@ int ieee80211_register_hw(struct net_dev
 		goto fail_rate_attrs;
 	}
 
+	result = ieee80211_wep_init(local);
+
+	if (result < 0) {
+		printk(KERN_DEBUG "%s: Failed to initialize wep\n", dev->name);
+		goto fail_rate_attrs;
+	}
+
 	/* TODO: add rtnl locking around device creation and qdisc install */
 	ieee80211_install_qdisc(dev);
 
-        ieee80211_wep_init(local);
-
 	/* add one default STA interface */
 	rtnl_lock();
 	result = ieee80211_if_add(dev, "wlan%d", 1, &sta_dev);
@@ -4592,6 +4597,7 @@ void ieee80211_free_hw(struct net_device
 	struct ieee80211_local *local = dev->ieee80211_ptr;
 
 	ieee80211_if_free(dev);
+	ieee80211_wep_free(local);
 	ieee80211_dev_free(local);
 }
 
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index b4e294c..9e1e5e8 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -406,6 +406,7 @@ #define IEEE80211_IRQSAFE_QUEUE_LIMIT 12
 	int long_retry_limit; /* dot11LongRetryLimit */
 	int short_preamble; /* use short preamble with IEEE 802.11b */
 
+	struct crypto_tfm *wep_tfm;
 	u32 wep_iv;
 	int key_tx_rx_threshold; /* number of times any key can be used in TX
 				  * or RX before generating a rekey
diff --git a/net/d80211/tkip.c b/net/d80211/tkip.c
index a487673..337e31a 100644
--- a/net/d80211/tkip.c
+++ b/net/d80211/tkip.c
@@ -211,8 +211,8 @@ u8 * ieee80211_tkip_add_iv(u8 *pos, stru
  * headroom of eight octets for IV and Ext. IV and taildroom of four octets
  * for ICV. @payload_len is the length of payload (_not_ including extra
  * headroom and tailroom). @ta is the transmitter addresses. */
-void ieee80211_tkip_encrypt_data(struct ieee80211_key *key, u8 *pos,
-				 size_t payload_len, u8 *ta)
+void ieee80211_tkip_encrypt_data(struct crypto_tfm *tfm, struct ieee80211_key *key,
+				 u8 *pos, size_t payload_len, u8 *ta)
 {
 	u8 rc4key[16];
 
@@ -228,7 +228,7 @@ void ieee80211_tkip_encrypt_data(struct 
 			   key->u.tkip.iv16, rc4key);
 
 	pos = ieee80211_tkip_add_iv(pos, key, rc4key[0], rc4key[1], rc4key[2]);
-	ieee80211_wep_encrypt_data(rc4key, 16, pos, payload_len);
+	ieee80211_wep_encrypt_data(tfm, rc4key, 16, pos, payload_len);
 }
 
 
@@ -236,9 +236,9 @@ void ieee80211_tkip_encrypt_data(struct 
  * beginning of the buffer containing IEEE 802.11 header payload, i.e.,
  * including IV, Ext. IV, real data, Michael MIC, ICV. @payload_len is the
  * length of payload, including IV, Ext. IV, MIC, ICV.  */
-int ieee80211_tkip_decrypt_data(struct ieee80211_key *key, u8 *payload,
-				size_t payload_len, u8 *ta, int only_iv,
-				int queue)
+int ieee80211_tkip_decrypt_data(struct crypto_tfm *tfm, struct ieee80211_key *key,
+				u8 *payload, size_t payload_len, u8 *ta,
+				int only_iv, int queue)
 {
 	u32 iv32;
 	u32 iv16;
@@ -325,7 +325,7 @@ #ifdef CONFIG_TKIP_DEBUG
 	}
 #endif /* CONFIG_TKIP_DEBUG */
 
-	res = ieee80211_wep_decrypt_data(rc4key, 16, pos, payload_len - 12);
+	res = ieee80211_wep_decrypt_data(tfm, rc4key, 16, pos, payload_len - 12);
  done:
 	if (res == TKIP_DECRYPT_OK) {
 		/* FIX: these should be updated only after Michael MIC has been
diff --git a/net/d80211/tkip.h b/net/d80211/tkip.h
index 4239cec..dc66421 100644
--- a/net/d80211/tkip.h
+++ b/net/d80211/tkip.h
@@ -14,16 +14,16 @@ #include "ieee80211_key.h"
 
 u8 * ieee80211_tkip_add_iv(u8 *pos, struct ieee80211_key *key,
 			   u8 iv0, u8 iv1, u8 iv2);
-void ieee80211_tkip_encrypt_data(struct ieee80211_key *key, u8 *pos,
-				 size_t payload_len, u8 *ta);
+void ieee80211_tkip_encrypt_data(struct crypto_tfm *tfm, struct ieee80211_key *key,
+				 u8 *pos, size_t payload_len, u8 *ta);
 enum {
 	TKIP_DECRYPT_OK = 0,
 	TKIP_DECRYPT_NO_EXT_IV = -1,
 	TKIP_DECRYPT_INVALID_KEYIDX = -2,
 	TKIP_DECRYPT_REPLAY = -3,
 };
-int ieee80211_tkip_decrypt_data(struct ieee80211_key *key, u8 *payload,
-				size_t payload_len, u8 *ta, int only_iv,
-				int queue);
+int ieee80211_tkip_decrypt_data(struct crypto_tfm *tfm, struct ieee80211_key *key,
+				u8 *payload, size_t payload_len, u8 *ta,
+				int only_iv, int queue);
 
 #endif /* TKIP_H */
diff --git a/net/d80211/wep.c b/net/d80211/wep.c
index 172b4a1..f60e449 100644
--- a/net/d80211/wep.c
+++ b/net/d80211/wep.c
@@ -14,74 +14,31 @@ #include <linux/netdevice.h>
 #include <linux/types.h>
 #include <linux/random.h>
 #include <linux/compiler.h>
+#include <linux/crc32.h>
+#include <linux/crypto.h>
+#include <asm/scatterlist.h>
 
 #include <net/d80211.h>
 #include "ieee80211_i.h"
 #include "wep.h"
 
 
-static const __u32 crc32_table[256] = {
-	0x00000000L, 0x77073096L, 0xee0e612cL, 0x990951baL, 0x076dc419L,
-	0x706af48fL, 0xe963a535L, 0x9e6495a3L, 0x0edb8832L, 0x79dcb8a4L,
-	0xe0d5e91eL, 0x97d2d988L, 0x09b64c2bL, 0x7eb17cbdL, 0xe7b82d07L,
-	0x90bf1d91L, 0x1db71064L, 0x6ab020f2L, 0xf3b97148L, 0x84be41deL,
-	0x1adad47dL, 0x6ddde4ebL, 0xf4d4b551L, 0x83d385c7L, 0x136c9856L,
-	0x646ba8c0L, 0xfd62f97aL, 0x8a65c9ecL, 0x14015c4fL, 0x63066cd9L,
-	0xfa0f3d63L, 0x8d080df5L, 0x3b6e20c8L, 0x4c69105eL, 0xd56041e4L,
-	0xa2677172L, 0x3c03e4d1L, 0x4b04d447L, 0xd20d85fdL, 0xa50ab56bL,
-	0x35b5a8faL, 0x42b2986cL, 0xdbbbc9d6L, 0xacbcf940L, 0x32d86ce3L,
-	0x45df5c75L, 0xdcd60dcfL, 0xabd13d59L, 0x26d930acL, 0x51de003aL,
-	0xc8d75180L, 0xbfd06116L, 0x21b4f4b5L, 0x56b3c423L, 0xcfba9599L,
-	0xb8bda50fL, 0x2802b89eL, 0x5f058808L, 0xc60cd9b2L, 0xb10be924L,
-	0x2f6f7c87L, 0x58684c11L, 0xc1611dabL, 0xb6662d3dL, 0x76dc4190L,
-	0x01db7106L, 0x98d220bcL, 0xefd5102aL, 0x71b18589L, 0x06b6b51fL,
-	0x9fbfe4a5L, 0xe8b8d433L, 0x7807c9a2L, 0x0f00f934L, 0x9609a88eL,
-	0xe10e9818L, 0x7f6a0dbbL, 0x086d3d2dL, 0x91646c97L, 0xe6635c01L,
-	0x6b6b51f4L, 0x1c6c6162L, 0x856530d8L, 0xf262004eL, 0x6c0695edL,
-	0x1b01a57bL, 0x8208f4c1L, 0xf50fc457L, 0x65b0d9c6L, 0x12b7e950L,
-	0x8bbeb8eaL, 0xfcb9887cL, 0x62dd1ddfL, 0x15da2d49L, 0x8cd37cf3L,
-	0xfbd44c65L, 0x4db26158L, 0x3ab551ceL, 0xa3bc0074L, 0xd4bb30e2L,
-	0x4adfa541L, 0x3dd895d7L, 0xa4d1c46dL, 0xd3d6f4fbL, 0x4369e96aL,
-	0x346ed9fcL, 0xad678846L, 0xda60b8d0L, 0x44042d73L, 0x33031de5L,
-	0xaa0a4c5fL, 0xdd0d7cc9L, 0x5005713cL, 0x270241aaL, 0xbe0b1010L,
-	0xc90c2086L, 0x5768b525L, 0x206f85b3L, 0xb966d409L, 0xce61e49fL,
-	0x5edef90eL, 0x29d9c998L, 0xb0d09822L, 0xc7d7a8b4L, 0x59b33d17L,
-	0x2eb40d81L, 0xb7bd5c3bL, 0xc0ba6cadL, 0xedb88320L, 0x9abfb3b6L,
-	0x03b6e20cL, 0x74b1d29aL, 0xead54739L, 0x9dd277afL, 0x04db2615L,
-	0x73dc1683L, 0xe3630b12L, 0x94643b84L, 0x0d6d6a3eL, 0x7a6a5aa8L,
-	0xe40ecf0bL, 0x9309ff9dL, 0x0a00ae27L, 0x7d079eb1L, 0xf00f9344L,
-	0x8708a3d2L, 0x1e01f268L, 0x6906c2feL, 0xf762575dL, 0x806567cbL,
-	0x196c3671L, 0x6e6b06e7L, 0xfed41b76L, 0x89d32be0L, 0x10da7a5aL,
-	0x67dd4accL, 0xf9b9df6fL, 0x8ebeeff9L, 0x17b7be43L, 0x60b08ed5L,
-	0xd6d6a3e8L, 0xa1d1937eL, 0x38d8c2c4L, 0x4fdff252L, 0xd1bb67f1L,
-	0xa6bc5767L, 0x3fb506ddL, 0x48b2364bL, 0xd80d2bdaL, 0xaf0a1b4cL,
-	0x36034af6L, 0x41047a60L, 0xdf60efc3L, 0xa867df55L, 0x316e8eefL,
-	0x4669be79L, 0xcb61b38cL, 0xbc66831aL, 0x256fd2a0L, 0x5268e236L,
-	0xcc0c7795L, 0xbb0b4703L, 0x220216b9L, 0x5505262fL, 0xc5ba3bbeL,
-	0xb2bd0b28L, 0x2bb45a92L, 0x5cb36a04L, 0xc2d7ffa7L, 0xb5d0cf31L,
-	0x2cd99e8bL, 0x5bdeae1dL, 0x9b64c2b0L, 0xec63f226L, 0x756aa39cL,
-	0x026d930aL, 0x9c0906a9L, 0xeb0e363fL, 0x72076785L, 0x05005713L,
-	0x95bf4a82L, 0xe2b87a14L, 0x7bb12baeL, 0x0cb61b38L, 0x92d28e9bL,
-	0xe5d5be0dL, 0x7cdcefb7L, 0x0bdbdf21L, 0x86d3d2d4L, 0xf1d4e242L,
-	0x68ddb3f8L, 0x1fda836eL, 0x81be16cdL, 0xf6b9265bL, 0x6fb077e1L,
-	0x18b74777L, 0x88085ae6L, 0xff0f6a70L, 0x66063bcaL, 0x11010b5cL,
-	0x8f659effL, 0xf862ae69L, 0x616bffd3L, 0x166ccf45L, 0xa00ae278L,
-	0xd70dd2eeL, 0x4e048354L, 0x3903b3c2L, 0xa7672661L, 0xd06016f7L,
-	0x4969474dL, 0x3e6e77dbL, 0xaed16a4aL, 0xd9d65adcL, 0x40df0b66L,
-	0x37d83bf0L, 0xa9bcae53L, 0xdebb9ec5L, 0x47b2cf7fL, 0x30b5ffe9L,
-	0xbdbdf21cL, 0xcabac28aL, 0x53b39330L, 0x24b4a3a6L, 0xbad03605L,
-	0xcdd70693L, 0x54de5729L, 0x23d967bfL, 0xb3667a2eL, 0xc4614ab8L,
-	0x5d681b02L, 0x2a6f2b94L, 0xb40bbe37L, 0xc30c8ea1L, 0x5a05df1bL,
-	0x2d02ef8dL
-};
-
-
-void ieee80211_wep_init(struct ieee80211_local *local)
+int ieee80211_wep_init(struct ieee80211_local *local)
 {
 	/* start WEP IV from a random value */
 	get_random_bytes(&local->wep_iv, WEP_IV_LEN);
+
+	local->wep_tfm = crypto_alloc_tfm("arc4", 0);
+	if (!local->wep_tfm)
+		return -ENOMEM;
+
+	return 0;
 }
 
+void ieee80211_wep_free(struct ieee80211_local *local)
+{
+	crypto_free_tfm(local->wep_tfm);
+}
 
 static inline int ieee80211_wep_weak_iv(u32 iv, int keylen)
 {
@@ -161,51 +118,20 @@ void ieee80211_wep_remove_iv(struct ieee
 /* Perform WEP encryption using given key. data buffer must have tailroom
  * for 4-byte ICV. data_len must not include this ICV. Note: this function
  * does _not_ add IV. data = RC4(data | CRC32(data)) */
-void ieee80211_wep_encrypt_data(u8 *rc4key, size_t klen, u8 *data,
-				size_t data_len)
+void ieee80211_wep_encrypt_data(struct crypto_tfm *tfm, u8 *rc4key,
+				size_t klen, u8 *data, size_t data_len)
 {
-	u32 i, j, k, crc;
-	u8 S[256];
-	u8 kpos, *pos;
-#define S_SWAP(a,b) do { u8 t = S[a]; S[a] = S[b]; S[b] = t; } while(0)
-
-	/* Setup RC4 state */
-	for (i = 0; i < 256; i++)
-		S[i] = i;
-	j = 0;
-	kpos = 0;
-	for (i = 0; i < 256; i++) {
-		j = (j + S[i] + rc4key[kpos]) & 0xff;
-		kpos++;
-		if (kpos >= klen)
-			kpos = 0;
-		S_SWAP(i, j);
-	}
+	struct scatterlist sg;
+	u32 *icv;
 
-	/* Compute CRC32 over unencrypted data and apply RC4 to data */
-	pos = data;
-	crc = ~0;
-	i = j = 0;
-	for (k = 0; k < data_len; k++) {
-		crc = crc32_table[(crc ^ *pos) & 0xff] ^ (crc >> 8);
-		i = (i + 1) & 0xff;
-		j = (j + S[i]) & 0xff;
-		S_SWAP(i, j);
-		*pos++ ^= S[(S[i] + S[j]) & 0xff];
-	}
-	crc = ~crc;
-
-	/* Append little-endian CRC32 and encrypt it to produce ICV */
-	pos[0] = crc;
-	pos[1] = crc >> 8;
-	pos[2] = crc >> 16;
-	pos[3] = crc >> 24;
-	for (k = 0; k < 4; k++) {
-		i = (i + 1) & 0xff;
-		j = (j + S[i]) & 0xff;
-		S_SWAP(i, j);
-		*pos++ ^= S[(S[i] + S[j]) & 0xff];
-	}
+	icv = (u32 *)(data + data_len);
+	*icv = ~crc32_le(~0, data, data_len);
+
+	crypto_cipher_setkey(tfm, rc4key, klen);
+	sg.page = virt_to_page(data);
+	sg.offset = offset_in_page(data);
+	sg.length = data_len + WEP_ICV_LEN;
+	crypto_cipher_encrypt(tfm, &sg, &sg, sg.length);
 }
 
 
@@ -248,7 +174,7 @@ int ieee80211_wep_encrypt(struct ieee802
 	/* Add room for ICV */
 	skb_put(skb, WEP_ICV_LEN);
 
-	ieee80211_wep_encrypt_data(rc4key, klen, iv + WEP_IV_LEN, len);
+	ieee80211_wep_encrypt_data(local->wep_tfm, rc4key, klen, iv + WEP_IV_LEN, len);
 
 	kfree(rc4key);
 
@@ -259,55 +185,22 @@ int ieee80211_wep_encrypt(struct ieee802
 /* Perform WEP decryption using given key. data buffer includes encrypted
  * payload, including 4-byte ICV, but _not_ IV. data_len must not include ICV.
  * Return 0 on success and -1 on ICV mismatch. */
-int ieee80211_wep_decrypt_data(u8 *rc4key, size_t klen, u8 *data,
-			       size_t data_len)
+int ieee80211_wep_decrypt_data(struct crypto_tfm *tfm, u8 *rc4key,
+			       size_t klen, u8 *data, size_t data_len)
 {
-	u32 i, j, k, crc;
-	u8 S[256];
-	u8 kpos, *pos, crcbuf[WEP_ICV_LEN], *cpos;
-
-	/* Setup RC4 state */
-	for (i = 0; i < 256; i++)
-		S[i] = i;
-	j = 0;
-	kpos = 0;
-	for (i = 0; i < 256; i++) {
-		j = (j + S[i] + rc4key[kpos]) & 0xff;
-		kpos++;
-		if (kpos >= klen)
-			kpos = 0;
-		S_SWAP(i, j);
-	}
-
-	/* Apply RC4 to data and compute CRC32 over decrypted data */
-	pos = data;
-	crc = ~0;
-	i = j = 0;
-	for (k = 0; k < data_len; k++) {
-		i = (i + 1) & 0xff;
-		j = (j + S[i]) & 0xff;
-		S_SWAP(i, j);
-		*pos ^= S[(S[i] + S[j]) & 0xff];
-		crc = crc32_table[(crc ^ *pos++) & 0xff] ^ (crc >> 8);
-	}
-	crc = ~crc;
-
-	/* Decrypt little-endian CRC32 and verify that it matches with the
-	 * received ICV */
-	cpos = crcbuf;
-	crcbuf[0] = crc;
-	crcbuf[1] = crc >> 8;
-	crcbuf[2] = crc >> 16;
-	crcbuf[3] = crc >> 24;
-	for (k = 0; k < WEP_ICV_LEN; k++) {
-		i = (i + 1) & 0xff;
-		j = (j + S[i]) & 0xff;
-		S_SWAP(i, j);
-		if (*cpos++ != (*pos++ ^ S[(S[i] + S[j]) & 0xff])) {
-			/* ICV mismatch */
-			return -1;
-		}
-	}
+	struct scatterlist sg;
+	u32 crc;
+
+	crypto_cipher_setkey(tfm, rc4key, klen);
+	sg.page = virt_to_page(data);
+	sg.offset = offset_in_page(data);
+	sg.length = data_len + WEP_ICV_LEN;
+	crypto_cipher_decrypt(tfm, &sg, &sg, sg.length);
+
+	crc = ~crc32_le(~0, data, data_len);
+	if (memcmp(&crc, data + data_len, WEP_ICV_LEN) != 0)
+		/* ICV mismatch */
+		return -1;
 
 	return 0;
 }
@@ -361,7 +254,7 @@ int ieee80211_wep_decrypt(struct ieee802
 	/* Copy rest of the WEP key (the secret part) */
 	memcpy(rc4key + 3, key->key, key->keylen);
 
-	if (ieee80211_wep_decrypt_data(rc4key, klen,
+	if (ieee80211_wep_decrypt_data(local->wep_tfm, rc4key, klen,
 				       skb->data + hdrlen + WEP_IV_LEN,
 				       len)) {
 		printk(KERN_DEBUG "WEP decrypt failed (ICV)\n");
diff --git a/net/d80211/wep.h b/net/d80211/wep.h
index 1d76639..e019b19 100644
--- a/net/d80211/wep.h
+++ b/net/d80211/wep.h
@@ -16,7 +16,8 @@ #include <linux/types.h>
 #include "ieee80211_i.h"
 #include "ieee80211_key.h"
 
-void ieee80211_wep_init(struct ieee80211_local *local);
+int ieee80211_wep_init(struct ieee80211_local *local);
+void ieee80211_wep_free(struct ieee80211_local *local);
 void ieee80211_wep_get_iv(struct ieee80211_local *local,
 			  struct ieee80211_key *key, u8 *iv);
 u8 * ieee80211_wep_add_iv(struct ieee80211_local *local,
@@ -25,10 +26,10 @@ u8 * ieee80211_wep_add_iv(struct ieee802
 void ieee80211_wep_remove_iv(struct ieee80211_local *local,
 			     struct sk_buff *skb,
 			     struct ieee80211_key *key);
-void ieee80211_wep_encrypt_data(u8 *rc4key, size_t klen, u8 *data,
-				size_t data_len);
-int ieee80211_wep_decrypt_data(u8 *rc4key, size_t klen, u8 *data,
-			       size_t data_len);
+void ieee80211_wep_encrypt_data(struct crypto_tfm *tfm, u8 *rc4key, size_t klen,
+				u8 *data, size_t data_len);
+int ieee80211_wep_decrypt_data(struct crypto_tfm *tfm, u8 *rc4key, size_t klen,
+			       u8 *data, size_t data_len);
 int ieee80211_wep_encrypt(struct ieee80211_local *local, struct sk_buff *skb,
 			  struct ieee80211_key *key);
 int ieee80211_wep_decrypt(struct ieee80211_local *local, struct sk_buff *skb,
diff --git a/net/d80211/wpa.c b/net/d80211/wpa.c
index 37f5af4..811a107 100644
--- a/net/d80211/wpa.c
+++ b/net/d80211/wpa.c
@@ -359,7 +359,7 @@ #endif /* CONFIG_HOSTAPD_WPA_TESTING */
 	skb_put(skb, TKIP_ICV_LEN);
 
 	hdr = (struct ieee80211_hdr *) skb->data;
-	ieee80211_tkip_encrypt_data(key, pos, len, hdr->addr2);
+	ieee80211_tkip_encrypt_data(tx->local->wep_tfm, key, pos, len, hdr->addr2);
 	return 0;
 }
 
@@ -502,7 +502,7 @@ #endif /* CONFIG_HOSTAPD_WPA_TESTING */
 		hwaccel = 1;
 	}
 
-	res = ieee80211_tkip_decrypt_data(key, skb->data + hdrlen,
+	res = ieee80211_tkip_decrypt_data(rx->local->wep_tfm, key, skb->data + hdrlen,
 					  skb->len - hdrlen, rx->sta->addr,
 					  hwaccel, rx->u.rx.queue);
 	if (res != TKIP_DECRYPT_OK || wpa_test) {
-- 
1.3.0

