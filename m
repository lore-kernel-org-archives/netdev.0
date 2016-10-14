From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [mac80211] BUG_ON with current -git (4.8.0-11417-g24532f7)
Date: Fri, 14 Oct 2016 10:53:21 +0200
Message-ID: <1476435201.31114.12.camel@sipsolutions.net>
References: <20161010150358.GA514@swordfish>
         <20161010153050.GA836@swordfish>
         <1476263106.5271.23.camel@sipsolutions.net>
         <20161012141245.GA436@swordfish>
         <1476282127.5271.30.camel@sipsolutions.net>
         <CALCETrXg9-OpJx5Rqz8afyaug+0DjzxvpdbOV9q6i01=zCZbcQ@mail.gmail.com>
         <1476338524.4904.1.camel@sipsolutions.net> <20161013134252.GA583@swordfish>
         <1476366354.4904.31.camel@sipsolutions.net>
         <CALCETrW8imkGTtR9-mFB=e=Gdr1QXVuhXN3GRs2B6wbmPaaGhA@mail.gmail.com>
         (sfid-20161013_235018_225755_5BCF27D2) <1476429916.4382.12.camel@sipsolutions.net>
         (sfid-20161014_092541_208009_922C51BD)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
        "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
        Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
        Network Development <netdev@vger.kernel.org>,
        Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Wireless List <linux-wireless@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Ard Biesheuvel <ard.biesheuvel@linaro.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1476429916.4382.12.camel@sipsolutions.net> (sfid-20161014_092541_208009_922C51BD)
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For reference, this was my patch moving the mac80211 buffers to percpu.

diff --git a/net/mac80211/aes_ccm.c b/net/mac80211/aes_ccm.c
index 7663c28ba353..c3709ddf71e9 100644
--- a/net/mac80211/aes_ccm.c
+++ b/net/mac80211/aes_ccm.c
@@ -29,6 +29,8 @@ void ieee80211_aes_ccm_encrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
 		__aligned(__alignof__(struct aead_request));
 	struct aead_request *aead_req = (void *) aead_req_data;
 
+	printk(KERN_INFO "ccm size: %d\n", sizeof(aead_req_data));
+
 	memset(aead_req, 0, sizeof(aead_req_data));
 
 	sg_init_table(sg, 3);
@@ -37,6 +39,9 @@ void ieee80211_aes_ccm_encrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
 	sg_set_buf(&sg[2], mic, mic_len);
 
 	aead_request_set_tfm(aead_req, tfm);
+
+	printk(KERN_INFO "aead: %pf\n", crypto_aead_alg(crypto_aead_reqtfm(aead_req))->encrypt);
+
 	aead_request_set_crypt(aead_req, sg, sg, data_len, b_0);
 	aead_request_set_ad(aead_req, sg[0].length);
 
@@ -67,6 +72,8 @@ int ieee80211_aes_ccm_decrypt(struct crypto_aead *tfm, u8 *b_0, u8 *aad,
 	aead_request_set_crypt(aead_req, sg, sg, data_len + mic_len, b_0);
 	aead_request_set_ad(aead_req, sg[0].length);
 
+	printk(KERN_INFO "aead: %pf\n", crypto_aead_alg(crypto_aead_reqtfm(aead_req))->decrypt);
+
 	return crypto_aead_decrypt(aead_req);
 }
 
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
diff --git a/net/mac80211/aes_gcm.c b/net/mac80211/aes_gcm.c
index 3afe361fd27c..13e64d383c46 100644
--- a/net/mac80211/aes_gcm.c
+++ b/net/mac80211/aes_gcm.c
@@ -25,6 +25,8 @@ void ieee80211_aes_gcm_encrypt(struct crypto_aead *tfm, u8 *j_0, u8 *aad,
 		__aligned(__alignof__(struct aead_request));
 	struct aead_request *aead_req = (void *)aead_req_data;
 
+	printk(KERN_DEBUG "gcm size: %d\n", sizeof(aead_req_data));
+
 	memset(aead_req, 0, sizeof(aead_req_data));
 
 	sg_init_table(sg, 3);
diff --git a/net/mac80211/aes_gmac.c b/net/mac80211/aes_gmac.c
index 3ddd927aaf30..a2fc69ec5ca9 100644
--- a/net/mac80211/aes_gmac.c
+++ b/net/mac80211/aes_gmac.c
@@ -19,17 +19,18 @@
 
 #define GMAC_MIC_LEN 16
 #define GMAC_NONCE_LEN 12
-#define AAD_LEN 20
 
 int ieee80211_aes_gmac(struct crypto_aead *tfm, const u8 *aad, u8 *nonce,
-		       const u8 *data, size_t data_len, u8 *mic)
+		       const u8 *data, size_t data_len, u8 *mic, u8 *zero)
 {
 	struct scatterlist sg[4];
 	char aead_req_data[sizeof(struct aead_request) +
 			   crypto_aead_reqsize(tfm)]
 		__aligned(__alignof__(struct aead_request));
 	struct aead_request *aead_req = (void *)aead_req_data;
-	u8 zero[GMAC_MIC_LEN], iv[AES_BLOCK_SIZE];
+	u8 iv[AES_BLOCK_SIZE];
+
+	printk(KERN_DEBUG "gmac size: %d\n", sizeof(aead_req_data));
 
 	if (data_len < GMAC_MIC_LEN)
 		return -EINVAL;
@@ -38,7 +39,7 @@ int ieee80211_aes_gmac(struct crypto_aead *tfm, const u8 *aad, u8 *nonce,
 
 	memset(zero, 0, GMAC_MIC_LEN);
 	sg_init_table(sg, 4);
-	sg_set_buf(&sg[0], aad, AAD_LEN);
+	sg_set_buf(&sg[0], aad, GMAC_AAD_LEN);
 	sg_set_buf(&sg[1], data, data_len - GMAC_MIC_LEN);
 	sg_set_buf(&sg[2], zero, GMAC_MIC_LEN);
 	sg_set_buf(&sg[3], mic, GMAC_MIC_LEN);
@@ -49,7 +50,7 @@ int ieee80211_aes_gmac(struct crypto_aead *tfm, const u8 *aad, u8 *nonce,
 
 	aead_request_set_tfm(aead_req, tfm);
 	aead_request_set_crypt(aead_req, sg, sg, 0, iv);
-	aead_request_set_ad(aead_req, AAD_LEN + data_len);
+	aead_request_set_ad(aead_req, GMAC_AAD_LEN + data_len);
 
 	crypto_aead_encrypt(aead_req);
 
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
index 103187ca9474..bc2a3282e0a1 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -1129,6 +1129,14 @@ enum mac80211_scan_state {
 	SCAN_ABORT,
 };
 
+struct ieee80211_crypto_bufs {
+	
+	u8 buf1[32];
+	u8 buf2[16];
+};
+
+extern struct ieee80211_crypto_bufs __percpu *ieee80211_crypto_bufs;
+
 struct ieee80211_local {
 	/* embed the driver visible part.
 	 * don't cast (use the static inlines below), but we keep
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index 1075ac24c8c5..6175cde94c53 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -33,6 +33,8 @@
 #include "led.h"
 #include "debugfs.h"
 
+struct ieee80211_crypto_bufs __percpu *ieee80211_crypto_bufs;
+
 void ieee80211_configure_filter(struct ieee80211_local *local)
 {
 	u64 mc;
@@ -1234,6 +1236,10 @@ static int __init ieee80211_init(void)
 	BUILD_BUG_ON(offsetof(struct ieee80211_tx_info, driver_data) +
 		     IEEE80211_TX_INFO_DRIVER_DATA_SIZE > sizeof(skb->cb));
 
+	ieee80211_crypto_bufs = alloc_percpu(struct ieee80211_crypto_bufs);
+	if (!ieee80211_crypto_bufs)
+		return -ENOMEM;
+
 	ret = rc80211_minstrel_init();
 	if (ret)
 		return ret;
@@ -1264,6 +1270,8 @@ static void __exit ieee80211_exit(void)
 
 	ieee80211_iface_exit();
 
+	free_percpu(ieee80211_crypto_bufs);
+
 	rcu_barrier();
 }
 
diff --git a/net/mac80211/wpa.c b/net/mac80211/wpa.c
index b48c1e13e281..c02634c4210c 100644
--- a/net/mac80211/wpa.c
+++ b/net/mac80211/wpa.c
@@ -405,8 +405,13 @@ static int ccmp_encrypt_skb(struct ieee80211_tx_data *tx, struct sk_buff *skb,
 	u8 *pos;
 	u8 pn[6];
 	u64 pn64;
-	u8 aad[2 * AES_BLOCK_SIZE];
-	u8 b_0[AES_BLOCK_SIZE];
+	struct ieee80211_crypto_bufs *bufs =
+		this_cpu_ptr(ieee80211_crypto_bufs);
+	u8 *aad = bufs->buf1;
+	u8 *b_0 = bufs->buf2;
+
+	BUILD_BUG_ON(sizeof(bufs->buf1) < 2 * AES_BLOCK_SIZE);
+	BUILD_BUG_ON(sizeof(bufs->buf2) < AES_BLOCK_SIZE);
 
 	if (info->control.hw_key &&
 	    !(info->control.hw_key->flags & IEEE80211_KEY_FLAG_GENERATE_IV) &&
@@ -534,8 +539,14 @@ ieee80211_crypto_ccmp_decrypt(struct ieee80211_rx_data *rx,
 		}
 
 		if (!(status->flag & RX_FLAG_DECRYPTED)) {
-			u8 aad[2 * AES_BLOCK_SIZE];
-			u8 b_0[AES_BLOCK_SIZE];
+			struct ieee80211_crypto_bufs *bufs =
+				this_cpu_ptr(ieee80211_crypto_bufs);
+			u8 *aad = bufs->buf1;
+			u8 *b_0 = bufs->buf2;
+
+			BUILD_BUG_ON(sizeof(bufs->buf1) < 2 * AES_BLOCK_SIZE);
+			BUILD_BUG_ON(sizeof(bufs->buf2) < AES_BLOCK_SIZE);
+
 			/* hardware didn't decrypt/verify MIC */
 			ccmp_special_blocks(skb, pn, b_0, aad);
 
@@ -639,8 +650,13 @@ static int gcmp_encrypt_skb(struct ieee80211_tx_data *tx, struct sk_buff *skb)
 	u8 *pos;
 	u8 pn[6];
 	u64 pn64;
-	u8 aad[2 * AES_BLOCK_SIZE];
-	u8 j_0[AES_BLOCK_SIZE];
+	struct ieee80211_crypto_bufs *bufs =
+		this_cpu_ptr(ieee80211_crypto_bufs);
+	u8 *aad = bufs->buf1;
+	u8 *j_0 = bufs->buf2;
+
+	BUILD_BUG_ON(sizeof(bufs->buf1) < 2 * AES_BLOCK_SIZE);
+	BUILD_BUG_ON(sizeof(bufs->buf2) < AES_BLOCK_SIZE);
 
 	if (info->control.hw_key &&
 	    !(info->control.hw_key->flags & IEEE80211_KEY_FLAG_GENERATE_IV) &&
@@ -764,8 +780,14 @@ ieee80211_crypto_gcmp_decrypt(struct ieee80211_rx_data *rx)
 		}
 
 		if (!(status->flag & RX_FLAG_DECRYPTED)) {
-			u8 aad[2 * AES_BLOCK_SIZE];
-			u8 j_0[AES_BLOCK_SIZE];
+			struct ieee80211_crypto_bufs *bufs =
+				this_cpu_ptr(ieee80211_crypto_bufs);
+			u8 *aad = bufs->buf1;
+			u8 *j_0 = bufs->buf2;
+
+			BUILD_BUG_ON(sizeof(bufs->buf1) < 2 * AES_BLOCK_SIZE);
+			BUILD_BUG_ON(sizeof(bufs->buf2) < AES_BLOCK_SIZE);
+
 			/* hardware didn't decrypt/verify MIC */
 			gcmp_special_blocks(skb, pn, j_0, aad);
 
@@ -935,8 +957,12 @@ ieee80211_crypto_aes_cmac_encrypt(struct ieee80211_tx_data *tx)
 	struct ieee80211_tx_info *info;
 	struct ieee80211_key *key = tx->key;
 	struct ieee80211_mmie *mmie;
-	u8 aad[20];
 	u64 pn64;
+	struct ieee80211_crypto_bufs *bufs =
+		this_cpu_ptr(ieee80211_crypto_bufs);
+	u8 *aad = bufs->buf1;
+
+	BUILD_BUG_ON(sizeof(bufs->buf1) < CMAC_AAD_LEN);
 
 	if (WARN_ON(skb_queue_len(&tx->skbs) != 1))
 		return TX_DROP;
@@ -979,8 +1005,12 @@ ieee80211_crypto_aes_cmac_256_encrypt(struct ieee80211_tx_data *tx)
 	struct ieee80211_tx_info *info;
 	struct ieee80211_key *key = tx->key;
 	struct ieee80211_mmie_16 *mmie;
-	u8 aad[20];
 	u64 pn64;
+	struct ieee80211_crypto_bufs *bufs =
+		this_cpu_ptr(ieee80211_crypto_bufs);
+	u8 *aad = bufs->buf1;
+
+	BUILD_BUG_ON(sizeof(bufs->buf1) < CMAC_AAD_LEN);
 
 	if (WARN_ON(skb_queue_len(&tx->skbs) != 1))
 		return TX_DROP;
@@ -1022,8 +1052,13 @@ ieee80211_crypto_aes_cmac_decrypt(struct ieee80211_rx_data *rx)
 	struct ieee80211_rx_status *status = IEEE80211_SKB_RXCB(skb);
 	struct ieee80211_key *key = rx->key;
 	struct ieee80211_mmie *mmie;
-	u8 aad[20], mic[8], ipn[6];
+	u8 mic[8], ipn[6];
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
+	struct ieee80211_crypto_bufs *bufs =
+		this_cpu_ptr(ieee80211_crypto_bufs);
+	u8 *aad = bufs->buf1;
+
+	BUILD_BUG_ON(sizeof(bufs->buf1) < CMAC_AAD_LEN);
 
 	if (!ieee80211_is_mgmt(hdr->frame_control))
 		return RX_CONTINUE;
@@ -1072,8 +1107,13 @@ ieee80211_crypto_aes_cmac_256_decrypt(struct ieee80211_rx_data *rx)
 	struct ieee80211_rx_status *status = IEEE80211_SKB_RXCB(skb);
 	struct ieee80211_key *key = rx->key;
 	struct ieee80211_mmie_16 *mmie;
-	u8 aad[20], mic[16], ipn[6];
+	u8 mic[16], ipn[6];
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *)skb->data;
+	struct ieee80211_crypto_bufs *bufs =
+		this_cpu_ptr(ieee80211_crypto_bufs);
+	u8 *aad = bufs->buf1;
+
+	BUILD_BUG_ON(sizeof(bufs->buf1) < CMAC_AAD_LEN);
 
 	if (!ieee80211_is_mgmt(hdr->frame_control))
 		return RX_CONTINUE;
@@ -1123,9 +1163,15 @@ ieee80211_crypto_aes_gmac_encrypt(struct ieee80211_tx_data *tx)
 	struct ieee80211_key *key = tx->key;
 	struct ieee80211_mmie_16 *mmie;
 	struct ieee80211_hdr *hdr;
-	u8 aad[20];
 	u64 pn64;
 	u8 nonce[12];
+	struct ieee80211_crypto_bufs *bufs =
+		this_cpu_ptr(ieee80211_crypto_bufs);
+	u8 *aad = bufs->buf1;
+	u8 *zero = bufs->buf2;
+
+	BUILD_BUG_ON(sizeof(bufs->buf1) < GMAC_AAD_LEN);
+	BUILD_BUG_ON(sizeof(bufs->buf2) < GMAC_MIC_LEN);
 
 	if (WARN_ON(skb_queue_len(&tx->skbs) != 1))
 		return TX_DROP;
@@ -1158,7 +1204,8 @@ ieee80211_crypto_aes_gmac_encrypt(struct ieee80211_tx_data *tx)
 
 	/* MIC = AES-GMAC(IGTK, AAD || Management Frame Body || MMIE, 128) */
 	if (ieee80211_aes_gmac(key->u.aes_gmac.tfm, aad, nonce,
-			       skb->data + 24, skb->len - 24, mmie->mic) < 0)
+			       skb->data + 24, skb->len - 24, mmie->mic,
+			       zero) < 0)
 		return TX_DROP;
 
 	return TX_CONTINUE;
@@ -1171,8 +1218,15 @@ ieee80211_crypto_aes_gmac_decrypt(struct ieee80211_rx_data *rx)
 	struct ieee80211_rx_status *status = IEEE80211_SKB_RXCB(skb);
 	struct ieee80211_key *key = rx->key;
 	struct ieee80211_mmie_16 *mmie;
-	u8 aad[20], mic[16], ipn[6], nonce[12];
+	u8 mic[16], ipn[6], nonce[12];
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *)skb->data;
+	struct ieee80211_crypto_bufs *bufs =
+		this_cpu_ptr(ieee80211_crypto_bufs);
+	u8 *aad = bufs->buf1;
+	u8 *zero = bufs->buf2;
+
+	BUILD_BUG_ON(sizeof(bufs->buf1) < GMAC_AAD_LEN);
+	BUILD_BUG_ON(sizeof(bufs->buf2) < GMAC_MIC_LEN);
 
 	if (!ieee80211_is_mgmt(hdr->frame_control))
 		return RX_CONTINUE;
@@ -1204,7 +1258,7 @@ ieee80211_crypto_aes_gmac_decrypt(struct ieee80211_rx_data *rx)
 
 		if (ieee80211_aes_gmac(key->u.aes_gmac.tfm, aad, nonce,
 				       skb->data + 24, skb->len - 24,
-				       mic) < 0 ||
+				       mic, zero) < 0 ||
 		    memcmp(mic, mmie->mic, sizeof(mmie->mic)) != 0) {
 			key->u.aes_gmac.icverrors++;
 			return RX_DROP_UNUSABLE;
