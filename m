From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [PATCH v4] mac80211: move extra crypto data off the stack
Date: Mon, 17 Oct 2016 10:33:15 +0200
Message-ID: <1476693195-14071-1-git-send-email-johannes@sipsolutions.net>
Cc: Ard Biesheuvel <ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Sergey Senozhatsky <sergey.senozhatsky.work-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org,
        Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

As the stack can (on x86-64) now be virtually mapped rather than
using "normal" kernel memory, Sergey noticed mac80211 isn't using
the SG APIs correctly by putting on-stack buffers into SG tables.
This leads to kernel crashes.

Fix this by allocating the extra fields dynamically on the fly as
needed, using a kmem cache.

I used per-CPU memory in a previous iteration of this patch, but
Ard Biesheuvel pointed out that was also vmalloc'ed on some
architectures.

Reported-by: Sergey Senozhatsky <sergey.senozhatsky.work-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 net/mac80211/aes_cmac.c    |   5 +-
 net/mac80211/aes_cmac.h    |   2 +
 net/mac80211/aes_gmac.c    |   9 ++-
 net/mac80211/aes_gmac.h    |   5 +-
 net/mac80211/ieee80211_i.h |   7 ++
 net/mac80211/main.c        |   8 +++
 net/mac80211/wpa.c         | 173 ++++++++++++++++++++++++++++++++++++---------
 7 files changed, 166 insertions(+), 43 deletions(-)

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
diff --git a/net/mac80211/aes_gmac.c b/net/mac80211/aes_gmac.c
index 6951af9715c0..86892e2e3c8c 100644
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
@@ -47,7 +46,7 @@ int ieee80211_aes_gmac(struct crypto_aead *tfm, const u8 *aad, u8 *nonce,
 	iv[AES_BLOCK_SIZE - 1] = 0x01;
 
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
index 34c2add2c455..a63593f6b645 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -1128,6 +1128,13 @@ enum mac80211_scan_state {
 	SCAN_ABORT,
 };
 
+struct ieee80211_crypto_bufs {
+	u8 buf1[32];
+	u8 buf2[16];
+} ____cacheline_aligned_in_smp;
+
+extern struct kmem_cache *ieee80211_crypto_bufs_cache;
+
 struct ieee80211_local {
 	/* embed the driver visible part.
 	 * don't cast (use the static inlines below), but we keep
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index 1075ac24c8c5..c6303a8a12d2 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -33,6 +33,8 @@
 #include "led.h"
 #include "debugfs.h"
 
+struct kmem_cache *ieee80211_crypto_bufs_cache;
+
 void ieee80211_configure_filter(struct ieee80211_local *local)
 {
 	u64 mc;
@@ -1234,6 +1236,10 @@ static int __init ieee80211_init(void)
 	BUILD_BUG_ON(offsetof(struct ieee80211_tx_info, driver_data) +
 		     IEEE80211_TX_INFO_DRIVER_DATA_SIZE > sizeof(skb->cb));
 
+	ieee80211_crypto_bufs_cache = KMEM_CACHE(ieee80211_crypto_bufs, 0);
+	if (!ieee80211_crypto_bufs_cache)
+		return -ENOMEM;
+
 	ret = rc80211_minstrel_init();
 	if (ret)
 		return ret;
@@ -1264,6 +1270,8 @@ static void __exit ieee80211_exit(void)
 
 	ieee80211_iface_exit();
 
+	kmem_cache_destroy(ieee80211_crypto_bufs_cache);
+
 	rcu_barrier();
 }
 
diff --git a/net/mac80211/wpa.c b/net/mac80211/wpa.c
index 2e366438f8ef..ee9105d57545 100644
--- a/net/mac80211/wpa.c
+++ b/net/mac80211/wpa.c
@@ -405,8 +405,6 @@ static int ccmp_encrypt_skb(struct ieee80211_tx_data *tx, struct sk_buff *skb,
 	u8 *pos;
 	u8 pn[6];
 	u64 pn64;
-	u8 aad[2 * AES_BLOCK_SIZE];
-	u8 b_0[AES_BLOCK_SIZE];
 
 	if (info->control.hw_key &&
 	    !(info->control.hw_key->flags & IEEE80211_KEY_FLAG_GENERATE_IV) &&
@@ -456,13 +454,34 @@ static int ccmp_encrypt_skb(struct ieee80211_tx_data *tx, struct sk_buff *skb,
 	ccmp_pn2hdr(pos, pn, key->conf.keyidx);
 
 	/* hwaccel - with software CCMP header */
-	if (info->control.hw_key)
-		return 0;
+	if (unlikely(!info->control.hw_key)) {
+		struct ieee80211_crypto_bufs *bufs;
+		int err;
+		u8 *aad;
+		u8 *b_0;
+
+		bufs = kmem_cache_alloc(ieee80211_crypto_bufs_cache,
+					GFP_ATOMIC);
+		if (!bufs)
+			return -ENOMEM;
+
+		BUILD_BUG_ON(sizeof(bufs->buf1) < 2 * AES_BLOCK_SIZE);
+		BUILD_BUG_ON(sizeof(bufs->buf2) < AES_BLOCK_SIZE);
+
+		aad = bufs->buf1;
+		b_0 = bufs->buf2;
+
+		pos += IEEE80211_CCMP_HDR_LEN;
+		ccmp_special_blocks(skb, pn, b_0, aad);
+		err = ieee80211_aes_ccm_encrypt(key->u.ccmp.tfm, b_0, aad,
+						pos, len,
+						skb_put(skb, mic_len),
+						mic_len);
+		kmem_cache_free(ieee80211_crypto_bufs_cache, bufs);
+		return err;
+	}
 
-	pos += IEEE80211_CCMP_HDR_LEN;
-	ccmp_special_blocks(skb, pn, b_0, aad);
-	return ieee80211_aes_ccm_encrypt(key->u.ccmp.tfm, b_0, aad, pos, len,
-					 skb_put(skb, mic_len), mic_len);
+	return 0;
 }
 
 
@@ -532,16 +551,33 @@ ieee80211_crypto_ccmp_decrypt(struct ieee80211_rx_data *rx,
 		}
 
 		if (!(status->flag & RX_FLAG_DECRYPTED)) {
-			u8 aad[2 * AES_BLOCK_SIZE];
-			u8 b_0[AES_BLOCK_SIZE];
+			struct ieee80211_crypto_bufs *bufs;
+			int err;
+			u8 *aad;
+			u8 *b_0;
+
+			bufs = kmem_cache_alloc(ieee80211_crypto_bufs_cache,
+						GFP_ATOMIC);
+			if (!bufs)
+				return -ENOMEM;
+
+			BUILD_BUG_ON(sizeof(bufs->buf1) < 2 * AES_BLOCK_SIZE);
+			BUILD_BUG_ON(sizeof(bufs->buf2) < AES_BLOCK_SIZE);
+
+			aad = bufs->buf1;
+			b_0 = bufs->buf2;
+
 			/* hardware didn't decrypt/verify MIC */
 			ccmp_special_blocks(skb, pn, b_0, aad);
 
-			if (ieee80211_aes_ccm_decrypt(
+			err = ieee80211_aes_ccm_decrypt(
 				    key->u.ccmp.tfm, b_0, aad,
 				    skb->data + hdrlen + IEEE80211_CCMP_HDR_LEN,
 				    data_len,
-				    skb->data + skb->len - mic_len, mic_len))
+				    skb->data + skb->len - mic_len, mic_len);
+			kmem_cache_free(ieee80211_crypto_bufs_cache, bufs);
+
+			if (err)
 				return RX_DROP_UNUSABLE;
 		}
 
@@ -637,8 +673,6 @@ static int gcmp_encrypt_skb(struct ieee80211_tx_data *tx, struct sk_buff *skb)
 	u8 *pos;
 	u8 pn[6];
 	u64 pn64;
-	u8 aad[2 * AES_BLOCK_SIZE];
-	u8 j_0[AES_BLOCK_SIZE];
 
 	if (info->control.hw_key &&
 	    !(info->control.hw_key->flags & IEEE80211_KEY_FLAG_GENERATE_IV) &&
@@ -689,13 +723,34 @@ static int gcmp_encrypt_skb(struct ieee80211_tx_data *tx, struct sk_buff *skb)
 	gcmp_pn2hdr(pos, pn, key->conf.keyidx);
 
 	/* hwaccel - with software GCMP header */
-	if (info->control.hw_key)
-		return 0;
+	if (unlikely(!info->control.hw_key)) {
+		struct ieee80211_crypto_bufs *bufs;
+		int err;
+		u8 *aad;
+		u8 *j_0;
+		u8 *mic = skb_put(skb, IEEE80211_GCMP_MIC_LEN);
+
+		bufs = kmem_cache_alloc(ieee80211_crypto_bufs_cache,
+					GFP_ATOMIC);
+		if (!bufs)
+			return -ENOMEM;
+
+		BUILD_BUG_ON(sizeof(bufs->buf1) < 2 * AES_BLOCK_SIZE);
+		BUILD_BUG_ON(sizeof(bufs->buf2) < AES_BLOCK_SIZE);
+
+		aad = bufs->buf1;
+		j_0 = bufs->buf2;
+
+		pos += IEEE80211_GCMP_HDR_LEN;
+		gcmp_special_blocks(skb, pn, j_0, aad);
+		err = ieee80211_aes_gcm_encrypt(key->u.gcmp.tfm, j_0, aad,
+						pos, len, mic);
+		kmem_cache_free(ieee80211_crypto_bufs_cache, bufs);
+
+		return err;
+	}
 
-	pos += IEEE80211_GCMP_HDR_LEN;
-	gcmp_special_blocks(skb, pn, j_0, aad);
-	return ieee80211_aes_gcm_encrypt(key->u.gcmp.tfm, j_0, aad, pos, len,
-					 skb_put(skb, IEEE80211_GCMP_MIC_LEN));
+	return 0;
 }
 
 ieee80211_tx_result
@@ -760,17 +815,34 @@ ieee80211_crypto_gcmp_decrypt(struct ieee80211_rx_data *rx)
 		}
 
 		if (!(status->flag & RX_FLAG_DECRYPTED)) {
-			u8 aad[2 * AES_BLOCK_SIZE];
-			u8 j_0[AES_BLOCK_SIZE];
+			struct ieee80211_crypto_bufs *bufs;
+			int err;
+			u8 *aad;
+			u8 *j_0;
+
+			bufs = kmem_cache_alloc(ieee80211_crypto_bufs_cache,
+						GFP_ATOMIC);
+			if (!bufs)
+				return -ENOMEM;
+
+			BUILD_BUG_ON(sizeof(bufs->buf1) < 2 * AES_BLOCK_SIZE);
+			BUILD_BUG_ON(sizeof(bufs->buf2) < AES_BLOCK_SIZE);
+
+			aad = bufs->buf1;
+			j_0 = bufs->buf2;
+
 			/* hardware didn't decrypt/verify MIC */
 			gcmp_special_blocks(skb, pn, j_0, aad);
 
-			if (ieee80211_aes_gcm_decrypt(
+			err = ieee80211_aes_gcm_decrypt(
 				    key->u.gcmp.tfm, j_0, aad,
 				    skb->data + hdrlen + IEEE80211_GCMP_HDR_LEN,
 				    data_len,
 				    skb->data + skb->len -
-				    IEEE80211_GCMP_MIC_LEN))
+				    IEEE80211_GCMP_MIC_LEN);
+			kmem_cache_free(ieee80211_crypto_bufs_cache, bufs);
+
+			if (err)
 				return RX_DROP_UNUSABLE;
 		}
 
@@ -1119,9 +1191,12 @@ ieee80211_crypto_aes_gmac_encrypt(struct ieee80211_tx_data *tx)
 	struct ieee80211_key *key = tx->key;
 	struct ieee80211_mmie_16 *mmie;
 	struct ieee80211_hdr *hdr;
-	u8 aad[20];
 	u64 pn64;
 	u8 nonce[12];
+	struct ieee80211_crypto_bufs *bufs;
+	int err;
+	u8 *aad;
+	u8 *zero;
 
 	if (WARN_ON(skb_queue_len(&tx->skbs) != 1))
 		return TX_DROP;
@@ -1136,6 +1211,16 @@ ieee80211_crypto_aes_gmac_encrypt(struct ieee80211_tx_data *tx)
 	if (WARN_ON(skb_tailroom(skb) < sizeof(*mmie)))
 		return TX_DROP;
 
+	bufs = kmem_cache_alloc(ieee80211_crypto_bufs_cache, GFP_ATOMIC);
+	if (!bufs)
+		return TX_DROP;
+
+	BUILD_BUG_ON(sizeof(bufs->buf1) < GMAC_AAD_LEN);
+	BUILD_BUG_ON(sizeof(bufs->buf2) < GMAC_MIC_LEN);
+
+	aad = bufs->buf1;
+	zero = bufs->buf2;
+
 	mmie = (struct ieee80211_mmie_16 *)skb_put(skb, sizeof(*mmie));
 	mmie->element_id = WLAN_EID_MMIE;
 	mmie->length = sizeof(*mmie) - 2;
@@ -1153,11 +1238,13 @@ ieee80211_crypto_aes_gmac_encrypt(struct ieee80211_tx_data *tx)
 	bip_ipn_swap(nonce + ETH_ALEN, mmie->sequence_number);
 
 	/* MIC = AES-GMAC(IGTK, AAD || Management Frame Body || MMIE, 128) */
-	if (ieee80211_aes_gmac(key->u.aes_gmac.tfm, aad, nonce,
-			       skb->data + 24, skb->len - 24, mmie->mic) < 0)
-		return TX_DROP;
+	err = ieee80211_aes_gmac(key->u.aes_gmac.tfm, aad, nonce,
+				 skb->data + 24, skb->len - 24, mmie->mic,
+				 zero);
 
-	return TX_CONTINUE;
+	kmem_cache_free(ieee80211_crypto_bufs_cache, bufs);
+
+	return err < 0 ? TX_DROP : TX_CONTINUE;
 }
 
 ieee80211_rx_result
@@ -1167,7 +1254,7 @@ ieee80211_crypto_aes_gmac_decrypt(struct ieee80211_rx_data *rx)
 	struct ieee80211_rx_status *status = IEEE80211_SKB_RXCB(skb);
 	struct ieee80211_key *key = rx->key;
 	struct ieee80211_mmie_16 *mmie;
-	u8 aad[20], mic[16], ipn[6], nonce[12];
+	u8 mic[16], ipn[6], nonce[12];
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *)skb->data;
 
 	if (!ieee80211_is_mgmt(hdr->frame_control))
@@ -1192,16 +1279,34 @@ ieee80211_crypto_aes_gmac_decrypt(struct ieee80211_rx_data *rx)
 	}
 
 	if (!(status->flag & RX_FLAG_DECRYPTED)) {
+		struct ieee80211_crypto_bufs *bufs;
+		int err;
+		u8 *aad;
+		u8 *zero;
+
+		bufs = kmem_cache_alloc(ieee80211_crypto_bufs_cache,
+					GFP_ATOMIC);
+		if (!bufs)
+			return RX_DROP_UNUSABLE;
+
+		BUILD_BUG_ON(sizeof(bufs->buf1) < GMAC_AAD_LEN);
+		BUILD_BUG_ON(sizeof(bufs->buf2) < GMAC_MIC_LEN);
+
+		aad = bufs->buf1;
+		zero = bufs->buf2;
+
 		/* hardware didn't decrypt/verify MIC */
 		bip_aad(skb, aad);
 
 		memcpy(nonce, hdr->addr2, ETH_ALEN);
 		memcpy(nonce + ETH_ALEN, ipn, 6);
 
-		if (ieee80211_aes_gmac(key->u.aes_gmac.tfm, aad, nonce,
-				       skb->data + 24, skb->len - 24,
-				       mic) < 0 ||
-		    memcmp(mic, mmie->mic, sizeof(mmie->mic)) != 0) {
+		err = ieee80211_aes_gmac(key->u.aes_gmac.tfm, aad, nonce,
+					 skb->data + 24, skb->len - 24,
+					 mic, zero);
+		kmem_cache_free(ieee80211_crypto_bufs_cache, bufs);
+
+		if (err < 0 || memcmp(mic, mmie->mic, sizeof(mmie->mic)) != 0) {
 			key->u.aes_gmac.icverrors++;
 			return RX_DROP_UNUSABLE;
 		}
-- 
2.8.1
