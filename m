From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: [PATCH wireless-2.6] Re: hostap crypto bugs
Date: Wed, 2 Jun 2004 23:34:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040603063432.GA7600@jm.kir.nu>
References: <20040602213634.11ec61bf.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040602213634.11ec61bf.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jun 02, 2004 at 09:36:34PM -0700, David S. Miller wrote:

> You cannot invoke virt_to_page() on addresses on the kernel stack,
> and that is what the various HostAP crypto modules are doing.
> 
> This happens to work on some platforms, but it is going to explode
> on others.

Thanks! I have not updated my non-x86 platforms to 2.6 kernels, so I had
not yet had a change to explode anything with this..

> Allocate these little header scratch area blobs in the per-crypto-instance
> structs you kmalloc instead.

This patch (for wireless-2.6) should do this. I used separate buffers
for RX and TX because they could be in theory called concurrently.
Better to get this first working, but it might be worthwhile to consider
the memory use at some point. This version uses 112 bytes of additional
scratch buffers per key for CCMP.



diff -u wireless-2.6/drivers/net/wireless/hostap/hostap_crypt_ccmp.c jm-wireless-2.6/drivers/net/wireless/hostap/hostap_crypt_ccmp.c
--- wireless-2.6/drivers/net/wireless/hostap/hostap_crypt_ccmp.c	2004-06-02 23:16:06.430130552 -0700
+++ jm-wireless-2.6/drivers/net/wireless/hostap/hostap_crypt_ccmp.c	2004-06-02 22:51:28.000000000 -0700
@@ -59,6 +59,11 @@
 	int key_idx;
 
 	struct crypto_tfm *tfm;
+
+	/* scratch buffers for virt_to_page() (crypto API) */
+	u8 tx_b0[AES_BLOCK_LEN], tx_b[AES_BLOCK_LEN],
+		tx_e[AES_BLOCK_LEN], tx_s0[AES_BLOCK_LEN];
+	u8 rx_b0[AES_BLOCK_LEN], rx_b[AES_BLOCK_LEN], rx_a[AES_BLOCK_LEN];
 };
 
 
@@ -133,13 +138,14 @@
 
 static void ccmp_init_blocks(struct crypto_tfm *tfm,
 			     struct hostap_ieee80211_hdr *hdr,
-			     u8 *pn, size_t dlen, u8 *b0, u8 *aad, u8 *auth,
+			     u8 *pn, size_t dlen, u8 *b0, u8 *auth,
 			     u8 *s0)
 {
 	u8 *pos, qc = 0;
 	size_t aad_len;
 	u16 fc;
 	int a4_included, qc_included;
+	u8 aad[2 * AES_BLOCK_LEN];
 
 	fc = le16_to_cpu(hdr->frame_control);
 	a4_included = ((fc & (WLAN_FC_TODS | WLAN_FC_FROMDS)) ==
@@ -211,8 +217,10 @@
 	int data_len, i, blocks, last, len;
 	u8 *pos, *mic;
 	struct hostap_ieee80211_hdr *hdr;
-	u8 aad[2 * AES_BLOCK_LEN], b0[AES_BLOCK_LEN], b[AES_BLOCK_LEN],
-		e[AES_BLOCK_LEN], s0[AES_BLOCK_LEN];
+	u8 *b0 = key->tx_b0;
+	u8 *b = key->tx_b;
+	u8 *e = key->tx_e;
+	u8 *s0 = key->tx_s0;
 
 	if (skb_headroom(skb) < CCMP_HDR_LEN ||
 	    skb_tailroom(skb) < CCMP_MIC_LEN ||
@@ -243,7 +251,7 @@
 	*pos++ = key->tx_pn[0];
 
 	hdr = (struct hostap_ieee80211_hdr *) skb->data;
-	ccmp_init_blocks(key->tfm, hdr, key->tx_pn, data_len, b0, aad, b, s0);
+	ccmp_init_blocks(key->tfm, hdr, key->tx_pn, data_len, b0, b, s0);
 
 	blocks = (data_len + AES_BLOCK_LEN - 1) / AES_BLOCK_LEN;
 	last = data_len % AES_BLOCK_LEN;
@@ -273,8 +281,9 @@
 	struct hostap_ccmp_data *key = priv;
 	u8 keyidx, *pos;
 	struct hostap_ieee80211_hdr *hdr;
-	u8 aad[2 * AES_BLOCK_LEN], b0[AES_BLOCK_LEN], b[AES_BLOCK_LEN],
-		a[AES_BLOCK_LEN];
+	u8 *b0 = key->rx_b0;
+	u8 *b = key->rx_b;
+	u8 *a = key->rx_a;
 	u8 pn[6];
 	int i, blocks, last, len;
 	size_t data_len = skb->len - hdr_len - CCMP_HDR_LEN - CCMP_MIC_LEN;
@@ -331,7 +340,7 @@
 		return -4;
 	}
 
-	ccmp_init_blocks(key->tfm, hdr, pn, data_len, b0, aad, a, b);
+	ccmp_init_blocks(key->tfm, hdr, pn, data_len, b0, a, b);
 	xor_block(mic, b, CCMP_MIC_LEN);
 
 	blocks = (data_len + AES_BLOCK_LEN - 1) / AES_BLOCK_LEN;
diff -u wireless-2.6/drivers/net/wireless/hostap/hostap_crypt_tkip.c jm-wireless-2.6/drivers/net/wireless/hostap/hostap_crypt_tkip.c
--- wireless-2.6/drivers/net/wireless/hostap/hostap_crypt_tkip.c	2004-06-02 23:16:06.441128880 -0700
+++ jm-wireless-2.6/drivers/net/wireless/hostap/hostap_crypt_tkip.c	2004-06-02 23:01:06.000000000 -0700
@@ -65,6 +65,9 @@
 
 	struct crypto_tfm *tfm_arc4;
 	struct crypto_tfm *tfm_michael;
+
+	/* scratch buffers for virt_to_page() (crypto API) */
+	u8 rx_hdr[16], tx_hdr[16];
 };
 
 
@@ -499,7 +502,6 @@
 {
 	struct hostap_tkip_data *tkey = priv;
 	u8 *pos;
-	u8 hdr[16];
 
 	if (skb_tailroom(skb) < 8 || skb->len < hdr_len) {
 		printk(KERN_DEBUG "Invalid packet for Michael MIC add "
@@ -508,9 +510,9 @@
 		return -1;
 	}
 
-	michael_mic_hdr(skb, hdr);
+	michael_mic_hdr(skb, tkey->tx_hdr);
 	pos = skb_put(skb, 8);
-	if (michael_mic(tkey, &tkey->key[16], hdr,
+	if (michael_mic(tkey, &tkey->key[16], tkey->tx_hdr,
 			skb->data + hdr_len, skb->len - 8 - hdr_len, pos))
 		return -1;
 
@@ -539,14 +541,13 @@
 				     int hdr_len, void *priv)
 {
 	struct hostap_tkip_data *tkey = priv;
-	u8 hdr[16];
 	u8 mic[8];
 
 	if (!tkey->key_set)
 		return -1;
 
-	michael_mic_hdr(skb, hdr);
-	if (michael_mic(tkey, &tkey->key[24], hdr,
+	michael_mic_hdr(skb, tkey->rx_hdr);
+	if (michael_mic(tkey, &tkey->key[24], tkey->rx_hdr,
 			skb->data + hdr_len, skb->len - 8 - hdr_len, mic))
 		return -1;
 	if (memcmp(mic, skb->data + skb->len - 8, 8) != 0) {



-- 
Jouni Malinen                                            PGP id EFC895FA
