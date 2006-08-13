From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 14/16] [CRYPTO] users: Use block ciphers where applicable
Date: Sun, 13 Aug 2006 22:20:24 +1000
Message-ID: <E1GCEx6-0004gV-00@gondolin.me.apana.org.au>
References: <20060813121722.GA16115@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:24585 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751032AbWHMMWg
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Aug 2006 08:22:36 -0400
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[CRYPTO] users: Use block ciphers where applicable

This patch converts all remaining users to use the new block cipher type
where applicable.  It also changes all simple cipher operations to use
the new encrypt_one/decrypt_one interface.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 drivers/net/ppp_mppe.c               |   32 +++++++++++++++++++-------------
 drivers/net/wireless/airo.c          |   18 +++++++++---------
 net/ieee80211/ieee80211_crypt_ccmp.c |   28 +++++++++-------------------
 net/ieee80211/ieee80211_crypt_tkip.c |   34 ++++++++++++++++++++++------------
 net/ieee80211/ieee80211_crypt_wep.c  |   25 ++++++++++++++-----------
 5 files changed, 73 insertions(+), 64 deletions(-)

diff --git a/drivers/net/ppp_mppe.c b/drivers/net/ppp_mppe.c
--- a/drivers/net/ppp_mppe.c
+++ b/drivers/net/ppp_mppe.c
@@ -43,6 +43,7 @@
  *                    deprecated in 2.6
  */
 
+#include <linux/err.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/version.h>
@@ -95,7 +96,7 @@ static inline void sha_pad_init(struct s
  * State for an MPPE (de)compressor.
  */
 struct ppp_mppe_state {
-	struct crypto_tfm *arc4;
+	struct crypto_blkcipher *arc4;
 	struct crypto_tfm *sha1;
 	unsigned char *sha1_digest;
 	unsigned char master_key[MPPE_MAX_KEY_LEN];
@@ -156,14 +157,15 @@ static void mppe_rekey(struct ppp_mppe_s
 {
 	unsigned char InterimKey[MPPE_MAX_KEY_LEN];
 	struct scatterlist sg_in[1], sg_out[1];
+	struct blkcipher_desc desc = { .tfm = state->arc4 };
 
 	get_new_key_from_sha(state, InterimKey);
 	if (!initial_key) {
-		crypto_cipher_setkey(state->arc4, InterimKey, state->keylen);
+		crypto_blkcipher_setkey(state->arc4, InterimKey, state->keylen);
 		setup_sg(sg_in, InterimKey, state->keylen);
 		setup_sg(sg_out, state->session_key, state->keylen);
-		if (crypto_cipher_encrypt(state->arc4, sg_out, sg_in,
-				      state->keylen) != 0) {
+		if (crypto_blkcipher_encrypt(&desc, sg_out, sg_in,
+					     state->keylen) != 0) {
     		    printk(KERN_WARNING "mppe_rekey: cipher_encrypt failed\n");
 		}
 	} else {
@@ -175,7 +177,7 @@ static void mppe_rekey(struct ppp_mppe_s
 		state->session_key[1] = 0x26;
 		state->session_key[2] = 0x9e;
 	}
-	crypto_cipher_setkey(state->arc4, state->session_key, state->keylen);
+	crypto_blkcipher_setkey(state->arc4, state->session_key, state->keylen);
 }
 
 /*
@@ -196,9 +198,11 @@ static void *mppe_alloc(unsigned char *o
 
 	memset(state, 0, sizeof(*state));
 
-	state->arc4 = crypto_alloc_tfm("arc4", 0);
-	if (!state->arc4)
+	state->arc4 = crypto_alloc_blkcipher("ecb(arc4)", 0, CRYPTO_ALG_ASYNC);
+	if (IS_ERR(state->arc4)) {
+		state->arc4 = NULL;
 		goto out_free;
+	}
 
 	state->sha1 = crypto_alloc_tfm("sha1", 0);
 	if (!state->sha1)
@@ -231,7 +235,7 @@ static void *mppe_alloc(unsigned char *o
 	    if (state->sha1)
 		crypto_free_tfm(state->sha1);
 	    if (state->arc4)
-		crypto_free_tfm(state->arc4);
+		crypto_free_blkcipher(state->arc4);
 	    kfree(state);
 	out:
 	return NULL;
@@ -249,7 +253,7 @@ static void mppe_free(void *arg)
 	    if (state->sha1)
 		crypto_free_tfm(state->sha1);
 	    if (state->arc4)
-		crypto_free_tfm(state->arc4);
+		crypto_free_blkcipher(state->arc4);
 	    kfree(state);
 	}
 }
@@ -356,6 +360,7 @@ mppe_compress(void *arg, unsigned char *
 	      int isize, int osize)
 {
 	struct ppp_mppe_state *state = (struct ppp_mppe_state *) arg;
+	struct blkcipher_desc desc = { .tfm = state->arc4 };
 	int proto;
 	struct scatterlist sg_in[1], sg_out[1];
 
@@ -413,7 +418,7 @@ mppe_compress(void *arg, unsigned char *
 	/* Encrypt packet */
 	setup_sg(sg_in, ibuf, isize);
 	setup_sg(sg_out, obuf, osize);
-	if (crypto_cipher_encrypt(state->arc4, sg_out, sg_in, isize) != 0) {
+	if (crypto_blkcipher_encrypt(&desc, sg_out, sg_in, isize) != 0) {
 		printk(KERN_DEBUG "crypto_cypher_encrypt failed\n");
 		return -1;
 	}
@@ -462,6 +467,7 @@ mppe_decompress(void *arg, unsigned char
 		int osize)
 {
 	struct ppp_mppe_state *state = (struct ppp_mppe_state *) arg;
+	struct blkcipher_desc desc = { .tfm = state->arc4 };
 	unsigned ccount;
 	int flushed = MPPE_BITS(ibuf) & MPPE_BIT_FLUSHED;
 	int sanity = 0;
@@ -599,7 +605,7 @@ mppe_decompress(void *arg, unsigned char
 	 */
 	setup_sg(sg_in, ibuf, 1);
 	setup_sg(sg_out, obuf, 1);
-	if (crypto_cipher_decrypt(state->arc4, sg_out, sg_in, 1) != 0) {
+	if (crypto_blkcipher_decrypt(&desc, sg_out, sg_in, 1) != 0) {
 		printk(KERN_DEBUG "crypto_cypher_decrypt failed\n");
 		return DECOMP_ERROR;
 	}
@@ -619,7 +625,7 @@ mppe_decompress(void *arg, unsigned char
 	/* And finally, decrypt the rest of the packet. */
 	setup_sg(sg_in, ibuf + 1, isize - 1);
 	setup_sg(sg_out, obuf + 1, osize - 1);
-	if (crypto_cipher_decrypt(state->arc4, sg_out, sg_in, isize - 1) != 0) {
+	if (crypto_blkcipher_decrypt(&desc, sg_out, sg_in, isize - 1)) {
 		printk(KERN_DEBUG "crypto_cypher_decrypt failed\n");
 		return DECOMP_ERROR;
 	}
@@ -694,7 +700,7 @@ static struct compressor ppp_mppe = {
 static int __init ppp_mppe_init(void)
 {
 	int answer;
-	if (!(crypto_alg_available("arc4", 0) &&
+	if (!(crypto_alg_available("ecb(arc4)", 0) &&
 	      crypto_alg_available("sha1", 0)))
 		return -ENODEV;
 
diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -1203,7 +1203,7 @@ struct airo_info {
 	struct iw_spy_data	spy_data;
 	struct iw_public_data	wireless_data;
 	/* MIC stuff */
-	struct crypto_tfm	*tfm;
+	struct crypto_cipher	*tfm;
 	mic_module		mod[2];
 	mic_statistics		micstats;
 	HostRxDesc rxfids[MPI_MAX_FIDS]; // rx/tx/config MPI350 descriptors
@@ -1271,7 +1271,8 @@ static int flashrestart(struct airo_info
 
 static int RxSeqValid (struct airo_info *ai,miccntx *context,int mcast,u32 micSeq);
 static void MoveWindow(miccntx *context, u32 micSeq);
-static void emmh32_setseed(emmh32_context *context, u8 *pkey, int keylen, struct crypto_tfm *);
+static void emmh32_setseed(emmh32_context *context, u8 *pkey, int keylen,
+			   struct crypto_cipher *tfm);
 static void emmh32_init(emmh32_context *context);
 static void emmh32_update(emmh32_context *context, u8 *pOctets, int len);
 static void emmh32_final(emmh32_context *context, u8 digest[4]);
@@ -1339,7 +1340,7 @@ static int micsetup(struct airo_info *ai
 	int i;
 
 	if (ai->tfm == NULL)
-	        ai->tfm = crypto_alloc_tfm("aes", CRYPTO_TFM_REQ_MAY_SLEEP);
+	        ai->tfm = crypto_alloc_cipher("aes", 0, CRYPTO_ALG_ASYNC);
 
         if (ai->tfm == NULL) {
                 airo_print_err(ai->dev->name, "failed to load transform for AES");
@@ -1608,7 +1609,8 @@ static void MoveWindow(miccntx *context,
 static unsigned char aes_counter[16];
 
 /* expand the key to fill the MMH coefficient array */
-static void emmh32_setseed(emmh32_context *context, u8 *pkey, int keylen, struct crypto_tfm *tfm)
+static void emmh32_setseed(emmh32_context *context, u8 *pkey, int keylen,
+			   struct crypto_cipher *tfm)
 {
   /* take the keying material, expand if necessary, truncate at 16-bytes */
   /* run through AES counter mode to generate context->coeff[] */
@@ -1616,7 +1618,6 @@ static void emmh32_setseed(emmh32_contex
 	int i,j;
 	u32 counter;
 	u8 *cipher, plain[16];
-	struct scatterlist sg[1];
 
 	crypto_cipher_setkey(tfm, pkey, 16);
 	counter = 0;
@@ -1627,9 +1628,8 @@ static void emmh32_setseed(emmh32_contex
 		aes_counter[12] = (u8)(counter >> 24);
 		counter++;
 		memcpy (plain, aes_counter, 16);
-		sg_set_buf(sg, plain, 16);
-		crypto_cipher_encrypt(tfm, sg, sg, 16);
-		cipher = kmap(sg->page) + sg->offset;
+		crypto_cipher_encrypt_one(tfm, plain, plain);
+		cipher = plain;
 		for (j=0; (j<16) && (i< (sizeof(context->coeff)/sizeof(context->coeff[0]))); ) {
 			context->coeff[i++] = ntohl(*(u32 *)&cipher[j]);
 			j += 4;
@@ -2432,7 +2432,7 @@ void stop_airo_card( struct net_device *
 				ai->shared, ai->shared_dma);
 		}
         }
-	crypto_free_tfm(ai->tfm);
+	crypto_free_cipher(ai->tfm);
 	del_airo_dev( dev );
 	free_netdev( dev );
 }
diff --git a/net/ieee80211/ieee80211_crypt_ccmp.c b/net/ieee80211/ieee80211_crypt_ccmp.c
--- a/net/ieee80211/ieee80211_crypt_ccmp.c
+++ b/net/ieee80211/ieee80211_crypt_ccmp.c
@@ -48,7 +48,7 @@ struct ieee80211_ccmp_data {
 
 	int key_idx;
 
-	struct crypto_tfm *tfm;
+	struct crypto_cipher *tfm;
 
 	/* scratch buffers for virt_to_page() (crypto API) */
 	u8 tx_b0[AES_BLOCK_LEN], tx_b[AES_BLOCK_LEN],
@@ -56,20 +56,10 @@ struct ieee80211_ccmp_data {
 	u8 rx_b0[AES_BLOCK_LEN], rx_b[AES_BLOCK_LEN], rx_a[AES_BLOCK_LEN];
 };
 
-static void ieee80211_ccmp_aes_encrypt(struct crypto_tfm *tfm,
-				       const u8 pt[16], u8 ct[16])
+static inline void ieee80211_ccmp_aes_encrypt(struct crypto_cipher *tfm,
+					      const u8 pt[16], u8 ct[16])
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
 
 static void *ieee80211_ccmp_init(int key_idx)
@@ -82,7 +72,7 @@ static void *ieee80211_ccmp_init(int key
 	memset(priv, 0, sizeof(*priv));
 	priv->key_idx = key_idx;
 
-	priv->tfm = crypto_alloc_tfm("aes", 0);
+	priv->tfm = crypto_alloc_cipher("aes", 0, CRYPTO_ALG_ASYNC);
 	if (priv->tfm == NULL) {
 		printk(KERN_DEBUG "ieee80211_crypt_ccmp: could not allocate "
 		       "crypto API aes\n");
@@ -94,7 +84,7 @@ static void *ieee80211_ccmp_init(int key
       fail:
 	if (priv) {
 		if (priv->tfm)
-			crypto_free_tfm(priv->tfm);
+			crypto_free_cipher(priv->tfm);
 		kfree(priv);
 	}
 
@@ -105,7 +95,7 @@ static void ieee80211_ccmp_deinit(void *
 {
 	struct ieee80211_ccmp_data *_priv = priv;
 	if (_priv && _priv->tfm)
-		crypto_free_tfm(_priv->tfm);
+		crypto_free_cipher(_priv->tfm);
 	kfree(priv);
 }
 
@@ -116,7 +106,7 @@ static inline void xor_block(u8 * b, u8 
 		b[i] ^= a[i];
 }
 
-static void ccmp_init_blocks(struct crypto_tfm *tfm,
+static void ccmp_init_blocks(struct crypto_cipher *tfm,
 			     struct ieee80211_hdr_4addr *hdr,
 			     u8 * pn, size_t dlen, u8 * b0, u8 * auth, u8 * s0)
 {
@@ -378,7 +368,7 @@ static int ieee80211_ccmp_set_key(void *
 {
 	struct ieee80211_ccmp_data *data = priv;
 	int keyidx;
-	struct crypto_tfm *tfm = data->tfm;
+	struct crypto_cipher *tfm = data->tfm;
 
 	keyidx = data->key_idx;
 	memset(data, 0, sizeof(*data));
diff --git a/net/ieee80211/ieee80211_crypt_tkip.c b/net/ieee80211/ieee80211_crypt_tkip.c
--- a/net/ieee80211/ieee80211_crypt_tkip.c
+++ b/net/ieee80211/ieee80211_crypt_tkip.c
@@ -9,6 +9,7 @@
  * more details.
  */
 
+#include <linux/err.h>
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/slab.h>
@@ -52,7 +53,7 @@ struct ieee80211_tkip_data {
 
 	int key_idx;
 
-	struct crypto_tfm *tfm_arc4;
+	struct crypto_blkcipher *tfm_arc4;
 	struct crypto_tfm *tfm_michael;
 
 	/* scratch buffers for virt_to_page() (crypto API) */
@@ -85,10 +86,12 @@ static void *ieee80211_tkip_init(int key
 
 	priv->key_idx = key_idx;
 
-	priv->tfm_arc4 = crypto_alloc_tfm("arc4", 0);
-	if (priv->tfm_arc4 == NULL) {
+	priv->tfm_arc4 = crypto_alloc_blkcipher("ecb(arc4)", 0,
+						CRYPTO_ALG_ASYNC);
+	if (IS_ERR(priv->tfm_arc4)) {
 		printk(KERN_DEBUG "ieee80211_crypt_tkip: could not allocate "
 		       "crypto API arc4\n");
+		priv->tfm_arc4 = NULL;
 		goto fail;
 	}
 
@@ -106,7 +109,7 @@ static void *ieee80211_tkip_init(int key
 		if (priv->tfm_michael)
 			crypto_free_tfm(priv->tfm_michael);
 		if (priv->tfm_arc4)
-			crypto_free_tfm(priv->tfm_arc4);
+			crypto_free_blkcipher(priv->tfm_arc4);
 		kfree(priv);
 	}
 
@@ -119,7 +122,7 @@ static void ieee80211_tkip_deinit(void *
 	if (_priv && _priv->tfm_michael)
 		crypto_free_tfm(_priv->tfm_michael);
 	if (_priv && _priv->tfm_arc4)
-		crypto_free_tfm(_priv->tfm_arc4);
+		crypto_free_blkcipher(_priv->tfm_arc4);
 	kfree(priv);
 }
 
@@ -318,6 +321,7 @@ static int ieee80211_tkip_hdr(struct sk_
 static int ieee80211_tkip_encrypt(struct sk_buff *skb, int hdr_len, void *priv)
 {
 	struct ieee80211_tkip_data *tkey = priv;
+	struct blkcipher_desc desc = { .tfm = tkey->tfm_arc4 };
 	int len;
 	u8 rc4key[16], *pos, *icv;
 	u32 crc;
@@ -351,18 +355,17 @@ static int ieee80211_tkip_encrypt(struct
 	icv[2] = crc >> 16;
 	icv[3] = crc >> 24;
 
-	crypto_cipher_setkey(tkey->tfm_arc4, rc4key, 16);
+	crypto_blkcipher_setkey(tkey->tfm_arc4, rc4key, 16);
 	sg.page = virt_to_page(pos);
 	sg.offset = offset_in_page(pos);
 	sg.length = len + 4;
-	crypto_cipher_encrypt(tkey->tfm_arc4, &sg, &sg, len + 4);
-
-	return 0;
+	return crypto_blkcipher_encrypt(&desc, &sg, &sg, len + 4);
 }
 
 static int ieee80211_tkip_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 {
 	struct ieee80211_tkip_data *tkey = priv;
+	struct blkcipher_desc desc = { .tfm = tkey->tfm_arc4 };
 	u8 rc4key[16];
 	u8 keyidx, *pos;
 	u32 iv32;
@@ -434,11 +437,18 @@ static int ieee80211_tkip_decrypt(struct
 
 	plen = skb->len - hdr_len - 12;
 
-	crypto_cipher_setkey(tkey->tfm_arc4, rc4key, 16);
+	crypto_blkcipher_setkey(tkey->tfm_arc4, rc4key, 16);
 	sg.page = virt_to_page(pos);
 	sg.offset = offset_in_page(pos);
 	sg.length = plen + 4;
-	crypto_cipher_decrypt(tkey->tfm_arc4, &sg, &sg, plen + 4);
+	if (crypto_blkcipher_decrypt(&desc, &sg, &sg, plen + 4)) {
+		if (net_ratelimit()) {
+			printk(KERN_DEBUG ": TKIP: failed to decrypt "
+			       "received packet from " MAC_FMT "\n",
+			       MAC_ARG(hdr->addr2));
+		}
+		return -7;
+	}
 
 	crc = ~crc32_le(~0, pos, plen);
 	icv[0] = crc;
@@ -619,7 +629,7 @@ static int ieee80211_tkip_set_key(void *
 	struct ieee80211_tkip_data *tkey = priv;
 	int keyidx;
 	struct crypto_tfm *tfm = tkey->tfm_michael;
-	struct crypto_tfm *tfm2 = tkey->tfm_arc4;
+	struct crypto_blkcipher *tfm2 = tkey->tfm_arc4;
 
 	keyidx = tkey->key_idx;
 	memset(tkey, 0, sizeof(*tkey));
diff --git a/net/ieee80211/ieee80211_crypt_wep.c b/net/ieee80211/ieee80211_crypt_wep.c
--- a/net/ieee80211/ieee80211_crypt_wep.c
+++ b/net/ieee80211/ieee80211_crypt_wep.c
@@ -9,6 +9,7 @@
  * more details.
  */
 
+#include <linux/err.h>
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/slab.h>
@@ -32,7 +33,7 @@ struct prism2_wep_data {
 	u8 key[WEP_KEY_LEN + 1];
 	u8 key_len;
 	u8 key_idx;
-	struct crypto_tfm *tfm;
+	struct crypto_blkcipher *tfm;
 };
 
 static void *prism2_wep_init(int keyidx)
@@ -45,10 +46,11 @@ static void *prism2_wep_init(int keyidx)
 	memset(priv, 0, sizeof(*priv));
 	priv->key_idx = keyidx;
 
-	priv->tfm = crypto_alloc_tfm("arc4", 0);
-	if (priv->tfm == NULL) {
+	priv->tfm = crypto_alloc_blkcipher("ecb(arc4)", 0, CRYPTO_ALG_ASYNC);
+	if (IS_ERR(priv->tfm)) {
 		printk(KERN_DEBUG "ieee80211_crypt_wep: could not allocate "
 		       "crypto API arc4\n");
+		priv->tfm = NULL;
 		goto fail;
 	}
 
@@ -60,7 +62,7 @@ static void *prism2_wep_init(int keyidx)
       fail:
 	if (priv) {
 		if (priv->tfm)
-			crypto_free_tfm(priv->tfm);
+			crypto_free_blkcipher(priv->tfm);
 		kfree(priv);
 	}
 	return NULL;
@@ -70,7 +72,7 @@ static void prism2_wep_deinit(void *priv
 {
 	struct prism2_wep_data *_priv = priv;
 	if (_priv && _priv->tfm)
-		crypto_free_tfm(_priv->tfm);
+		crypto_free_blkcipher(_priv->tfm);
 	kfree(priv);
 }
 
@@ -121,6 +123,7 @@ static int prism2_wep_build_iv(struct sk
 static int prism2_wep_encrypt(struct sk_buff *skb, int hdr_len, void *priv)
 {
 	struct prism2_wep_data *wep = priv;
+	struct blkcipher_desc desc = { .tfm = wep->tfm };
 	u32 crc, klen, len;
 	u8 *pos, *icv;
 	struct scatterlist sg;
@@ -152,13 +155,11 @@ static int prism2_wep_encrypt(struct sk_
 	icv[2] = crc >> 16;
 	icv[3] = crc >> 24;
 
-	crypto_cipher_setkey(wep->tfm, key, klen);
+	crypto_blkcipher_setkey(wep->tfm, key, klen);
 	sg.page = virt_to_page(pos);
 	sg.offset = offset_in_page(pos);
 	sg.length = len + 4;
-	crypto_cipher_encrypt(wep->tfm, &sg, &sg, len + 4);
-
-	return 0;
+	return crypto_blkcipher_encrypt(&desc, &sg, &sg, len + 4);
 }
 
 /* Perform WEP decryption on given buffer. Buffer includes whole WEP part of
@@ -171,6 +172,7 @@ static int prism2_wep_encrypt(struct sk_
 static int prism2_wep_decrypt(struct sk_buff *skb, int hdr_len, void *priv)
 {
 	struct prism2_wep_data *wep = priv;
+	struct blkcipher_desc desc = { .tfm = wep->tfm };
 	u32 crc, klen, plen;
 	u8 key[WEP_KEY_LEN + 3];
 	u8 keyidx, *pos, icv[4];
@@ -195,11 +197,12 @@ static int prism2_wep_decrypt(struct sk_
 	/* Apply RC4 to data and compute CRC32 over decrypted data */
 	plen = skb->len - hdr_len - 8;
 
-	crypto_cipher_setkey(wep->tfm, key, klen);
+	crypto_blkcipher_setkey(wep->tfm, key, klen);
 	sg.page = virt_to_page(pos);
 	sg.offset = offset_in_page(pos);
 	sg.length = plen + 4;
-	crypto_cipher_decrypt(wep->tfm, &sg, &sg, plen + 4);
+	if (crypto_blkcipher_decrypt(&desc, &sg, &sg, plen + 4))
+		return -7;
 
 	crc = ~crc32_le(~0, pos, plen);
 	icv[0] = crc;
