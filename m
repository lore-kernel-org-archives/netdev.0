From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [mac80211] BUG_ON with current -git (4.8.0-11417-g24532f7)
Date: Wed, 12 Oct 2016 16:22:07 +0200
Message-ID: <1476282127.5271.30.camel@sipsolutions.net>
References: <20161010150358.GA514@swordfish>
         <20161010153050.GA836@swordfish>
         <1476263106.5271.23.camel@sipsolutions.net>
         <20161012141245.GA436@swordfish> (sfid-20161012_161343_857870_9D4F9CC9)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andy Lutomirski <luto@kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
        linux-next@vger.kernel.org,
        Stephen Rothwell <sfr@canb.auug.org.au>,
        Herbert Xu <herbert@gondor.apana.org.au>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:43653 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932984AbcJLOWS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Oct 2016 10:22:18 -0400
In-Reply-To: <20161012141245.GA436@swordfish> (sfid-20161012_161343_857870_9D4F9CC9)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> > Can you elaborate on how exactly it kills your system?
> 
> the last time I saw it it was a NULL deref at
> ieee80211_aes_ccm_decrypt.

Hm. I was expecting something within the crypto code would cause the
crash, this seems strange.

Anyway, I'm surely out of my depth wrt. the actual cause. Something
like the patch below probably works around it, but it's horribly
inefficient due to the locking and doesn't cover CMAC/GMAC either.

johannes

diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 103187ca9474..e820f437f02e 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -27,6 +27,7 @@
 #include <linux/leds.h>
 #include <linux/idr.h>
 #include <linux/rhashtable.h>
+#include <crypto/aes.h>
 #include <net/ieee80211_radiotap.h>
 #include <net/cfg80211.h>
 #include <net/mac80211.h>
@@ -1224,6 +1225,10 @@ struct ieee80211_local {
 
 	spinlock_t rx_path_lock;
 
+	/* temporary buffers for software crypto */
+	u8 aad[2 * AES_BLOCK_SIZE];
+	u8 b_0[AES_BLOCK_SIZE];
+
 	/* Station data */
 	/*
 	 * The mutex only protects the list, hash table and
diff --git a/net/mac80211/wpa.c b/net/mac80211/wpa.c
index b48c1e13e281..a3f17a710b85 100644
--- a/net/mac80211/wpa.c
+++ b/net/mac80211/wpa.c
@@ -405,8 +405,8 @@ static int ccmp_encrypt_skb(struct ieee80211_tx_data *tx, struct sk_buff *skb,
 	u8 *pos;
 	u8 pn[6];
 	u64 pn64;
-	u8 aad[2 * AES_BLOCK_SIZE];
-	u8 b_0[AES_BLOCK_SIZE];
+	u8 *aad = tx->local->aad;
+	u8 *b_0 = tx->local->b_0;
 
 	if (info->control.hw_key &&
 	    !(info->control.hw_key->flags & IEEE80211_KEY_FLAG_GENERATE_IV) &&
@@ -460,9 +460,11 @@ static int ccmp_encrypt_skb(struct ieee80211_tx_data *tx, struct sk_buff *skb,
 		return 0;
 
 	pos += IEEE80211_CCMP_HDR_LEN;
+	spin_lock_bh(&tx->local->rx_path_lock);
 	ccmp_special_blocks(skb, pn, b_0, aad);
 	ieee80211_aes_ccm_encrypt(key->u.ccmp.tfm, b_0, aad, pos, len,
 				  skb_put(skb, mic_len), mic_len);
+	spin_unlock_bh(&tx->local->rx_path_lock);
 
 	return 0;
 }
@@ -534,8 +536,9 @@ ieee80211_crypto_ccmp_decrypt(struct ieee80211_rx_data *rx,
 		}
 
 		if (!(status->flag & RX_FLAG_DECRYPTED)) {
-			u8 aad[2 * AES_BLOCK_SIZE];
-			u8 b_0[AES_BLOCK_SIZE];
+			u8 *aad = rx->local->aad;
+			u8 *b_0 = rx->local->b_0;
+
 			/* hardware didn't decrypt/verify MIC */
 			ccmp_special_blocks(skb, pn, b_0, aad);
 
@@ -639,8 +642,8 @@ static int gcmp_encrypt_skb(struct ieee80211_tx_data *tx, struct sk_buff *skb)
 	u8 *pos;
 	u8 pn[6];
 	u64 pn64;
-	u8 aad[2 * AES_BLOCK_SIZE];
-	u8 j_0[AES_BLOCK_SIZE];
+	u8 *aad = tx->local->aad;
+	u8 *j_0 = tx->local->b_0;
 
 	if (info->control.hw_key &&
 	    !(info->control.hw_key->flags & IEEE80211_KEY_FLAG_GENERATE_IV) &&
@@ -695,9 +698,11 @@ static int gcmp_encrypt_skb(struct ieee80211_tx_data *tx, struct sk_buff *skb)
 		return 0;
 
 	pos += IEEE80211_GCMP_HDR_LEN;
+	spin_lock_bh(&tx->local->rx_path_lock);
 	gcmp_special_blocks(skb, pn, j_0, aad);
 	ieee80211_aes_gcm_encrypt(key->u.gcmp.tfm, j_0, aad, pos, len,
 				  skb_put(skb, IEEE80211_GCMP_MIC_LEN));
+	spin_unlock_bh(&tx->local->rx_path_lock);
 
 	return 0;
 }
@@ -764,8 +769,9 @@ ieee80211_crypto_gcmp_decrypt(struct ieee80211_rx_data *rx)
 		}
 
 		if (!(status->flag & RX_FLAG_DECRYPTED)) {
-			u8 aad[2 * AES_BLOCK_SIZE];
-			u8 j_0[AES_BLOCK_SIZE];
+			u8 *aad = rx->local->aad;
+			u8 *j_0 = rx->local->b_0;
+
 			/* hardware didn't decrypt/verify MIC */
 			gcmp_special_blocks(skb, pn, j_0, aad);
 
