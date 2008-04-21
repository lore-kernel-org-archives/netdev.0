From: Adrian Bunk <bunk@kernel.org>
Subject: [RFC: 2.6 patch] remove ieee80211_tx_frame()
Date: Mon, 21 Apr 2008 11:48:28 +0300
Message-ID: <20080421084828.GO26897@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5.pp.htv.fi ([213.243.153.39]:58345 "EHLO smtp5.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757231AbYDUIs4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Apr 2008 04:48:56 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After the softmac removal ieee80211_tx_frame() was no longer used.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 include/net/ieee80211.h      |    3 -
 net/ieee80211/ieee80211_tx.c |   86 -----------------------------------
 2 files changed, 89 deletions(-)

4a7693d458d04a2dbdc471ad82cded9702deacc3 diff --git a/include/net/ieee80211.h b/include/net/ieee80211.h
index 529816b..facd0ff 100644
--- a/include/net/ieee80211.h
+++ b/include/net/ieee80211.h
@@ -1262,9 +1262,6 @@ extern int ieee80211_set_encryption(struct ieee80211_device *ieee);
 /* ieee80211_tx.c */
 extern int ieee80211_xmit(struct sk_buff *skb, struct net_device *dev);
 extern void ieee80211_txb_free(struct ieee80211_txb *);
-extern int ieee80211_tx_frame(struct ieee80211_device *ieee,
-			      struct ieee80211_hdr *frame, int hdr_len,
-			      int total_len, int encrypt_mpdu);
 
 /* ieee80211_rx.c */
 extern void ieee80211_rx_any(struct ieee80211_device *ieee,
diff --git a/net/ieee80211/ieee80211_tx.c b/net/ieee80211/ieee80211_tx.c
index d8b0260..d996547 100644
--- a/net/ieee80211/ieee80211_tx.c
+++ b/net/ieee80211/ieee80211_tx.c
@@ -542,90 +542,4 @@ int ieee80211_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 1;
 }
 
-/* Incoming 802.11 strucure is converted to a TXB
- * a block of 802.11 fragment packets (stored as skbs) */
-int ieee80211_tx_frame(struct ieee80211_device *ieee,
-		       struct ieee80211_hdr *frame, int hdr_len, int total_len,
-		       int encrypt_mpdu)
-{
-	struct ieee80211_txb *txb = NULL;
-	unsigned long flags;
-	struct net_device_stats *stats = &ieee->stats;
-	struct sk_buff *skb_frag;
-	int priority = -1;
-	int fraglen = total_len;
-	int headroom = ieee->tx_headroom;
-	struct ieee80211_crypt_data *crypt = ieee->crypt[ieee->tx_keyidx];
-
-	spin_lock_irqsave(&ieee->lock, flags);
-
-	if (encrypt_mpdu && (!ieee->sec.encrypt || !crypt))
-		encrypt_mpdu = 0;
-
-	/* If there is no driver handler to take the TXB, dont' bother
-	 * creating it... */
-	if (!ieee->hard_start_xmit) {
-		printk(KERN_WARNING "%s: No xmit handler.\n", ieee->dev->name);
-		goto success;
-	}
-
-	if (unlikely(total_len < 24)) {
-		printk(KERN_WARNING "%s: skb too small (%d).\n",
-		       ieee->dev->name, total_len);
-		goto success;
-	}
-
-	if (encrypt_mpdu) {
-		frame->frame_ctl |= cpu_to_le16(IEEE80211_FCTL_PROTECTED);
-		fraglen += crypt->ops->extra_mpdu_prefix_len +
-			   crypt->ops->extra_mpdu_postfix_len;
-		headroom += crypt->ops->extra_mpdu_prefix_len;
-	}
-
-	/* When we allocate the TXB we allocate enough space for the reserve
-	 * and full fragment bytes (bytes_per_frag doesn't include prefix,
-	 * postfix, header, FCS, etc.) */
-	txb = ieee80211_alloc_txb(1, fraglen, headroom, GFP_ATOMIC);
-	if (unlikely(!txb)) {
-		printk(KERN_WARNING "%s: Could not allocate TXB\n",
-		       ieee->dev->name);
-		goto failed;
-	}
-	txb->encrypted = 0;
-	txb->payload_size = fraglen;
-
-	skb_frag = txb->fragments[0];
-
-	memcpy(skb_put(skb_frag, total_len), frame, total_len);
-
-	if (ieee->config &
-	    (CFG_IEEE80211_COMPUTE_FCS | CFG_IEEE80211_RESERVE_FCS))
-		skb_put(skb_frag, 4);
-
-	/* To avoid overcomplicating things, we do the corner-case frame
-	 * encryption in software. The only real situation where encryption is
-	 * needed here is during software-based shared key authentication. */
-	if (encrypt_mpdu)
-		ieee80211_encrypt_fragment(ieee, skb_frag, hdr_len);
-
-      success:
-	spin_unlock_irqrestore(&ieee->lock, flags);
-
-	if (txb) {
-		if ((*ieee->hard_start_xmit) (txb, ieee->dev, priority) == 0) {
-			stats->tx_packets++;
-			stats->tx_bytes += txb->payload_size;
-			return 0;
-		}
-		ieee80211_txb_free(txb);
-	}
-	return 0;
-
-      failed:
-	spin_unlock_irqrestore(&ieee->lock, flags);
-	stats->tx_errors++;
-	return 1;
-}
-
-EXPORT_SYMBOL(ieee80211_tx_frame);
 EXPORT_SYMBOL(ieee80211_txb_free);

