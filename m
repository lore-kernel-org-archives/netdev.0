From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [RFC] mac80211: clean up skb reallocation code
Date: Sun, 04 May 2008 23:27:53 +0200
Message-ID: <1209936473.7304.12.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This cleans up the skb reallocation code to avoid problems with
skb->truesize and not resize an skb twice for a single output
path because we didn't expand it enough during the first copy.

Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
---
 net/mac80211/tx.c  |   97 +++++++++++++++++++++++++++++++++++++----------------
 net/mac80211/wep.c |   10 +----
 net/mac80211/wpa.c |   51 ++++++++++-----------------
 3 files changed, 91 insertions(+), 67 deletions(-)

--- everything.orig/net/mac80211/tx.c	2008-05-04 20:54:25.000000000 +0200
+++ everything/net/mac80211/tx.c	2008-05-04 21:57:40.000000000 +0200
@@ -1269,6 +1269,45 @@ static bool validate_control(struct ieee
 	return false;
 }
 
+static int ieee80211_skb_resize(struct ieee80211_local *local,
+				struct sk_buff *skb,
+				int head_need, bool encrypt)
+{
+	int tail_need = 0;
+
+	/*
+	 * This could be optimised, devices that do full hardware
+	 * crypto need no tailroom... But we have no drivers for
+	 * such devices currently.
+	 */
+	if (encrypt) {
+		tail_need = IEEE80211_ENCRYPT_TAILROOM;
+		tail_need -= skb_tailroom(skb);
+		tail_need = max_t(int, tail_need, 0);
+	}
+
+	if (head_need || tail_need) {
+		/* Sorry. Can't account for this any more */
+		skb_orphan(skb);
+	}
+
+	if (skb_cloned(skb))
+		I802_DEBUG_INC(local->tx_expand_skb_head_cloned);
+	else
+		I802_DEBUG_INC(local->tx_expand_skb_head);
+
+	if (pskb_expand_head(skb, head_need, tail_need, GFP_ATOMIC)) {
+		printk(KERN_DEBUG "%s: failed to reallocate TX buffer\n",
+		       wiphy_name(local->hw.wiphy));
+		return -ENOMEM;
+	}
+
+	/* update truesize too */
+	skb->truesize += head_need + tail_need;
+
+	return 0;
+}
+
 int ieee80211_master_start_xmit(struct sk_buff *skb,
 				struct net_device *dev)
 {
@@ -1276,6 +1315,7 @@ int ieee80211_master_start_xmit(struct s
 	struct net_device *odev = NULL;
 	struct ieee80211_sub_if_data *osdata;
 	int headroom;
+	bool encrypt;
 	int ret;
 
 	if (info->flags & IEEE80211_TX_CTL_READY_FOR_TX) {
@@ -1317,13 +1357,18 @@ int ieee80211_master_start_xmit(struct s
 	}
 	osdata = IEEE80211_DEV_TO_SUB_IF(odev);
 
-	headroom = osdata->local->tx_headroom + IEEE80211_ENCRYPT_HEADROOM;
-	if (skb_headroom(skb) < headroom) {
-		if (pskb_expand_head(skb, headroom, 0, GFP_ATOMIC)) {
-			dev_kfree_skb(skb);
-			dev_put(odev);
-			return 0;
-		}
+	encrypt = !(info->flags & IEEE80211_TX_CTL_DO_NOT_ENCRYPT);
+
+	headroom = osdata->local->tx_headroom;
+	if (encrypt)
+		headroom += IEEE80211_ENCRYPT_HEADROOM;
+	headroom -= skb_headroom(skb);
+	headroom = max_t(int, 0, headroom);
+
+	if (ieee80211_skb_resize(osdata->local, skb, headroom, encrypt)) {
+		dev_kfree_skb(skb);
+		dev_put(odev);
+		return NETDEV_TX_OK;
 	}
 
 	info->control.vif = &osdata->vif;
@@ -1572,32 +1617,26 @@ int ieee80211_subif_start_xmit(struct sk
 	nh_pos -= skip_header_bytes;
 	h_pos -= skip_header_bytes;
 
-	head_need = hdrlen + encaps_len + meshhdrlen + local->tx_headroom;
-	head_need -= skb_headroom(skb);
+	head_need = hdrlen + encaps_len + meshhdrlen - skb_headroom(skb);
 
-	/* We are going to modify skb data, so make a copy of it if happens to
-	 * be cloned. This could happen, e.g., with Linux bridge code passing
-	 * us broadcast frames. */
+	/*
+	 * So we need to modify the skb header and hence need a copy of
+	 * that. The head_need variable above doesn't, so far, include
+	 * the needed header space that we don't need right away. If we
+	 * can, then we don't reallocate right now but only after the
+	 * frame arrives at the master device (if it does...)
+	 *
+	 * If we cannot, however, then we will reallocate to include all
+	 * the ever needed space and, if necessary, orphan the skb. Also,
+	 * if the skb is cloned then copy only once.
+	 */
 
 	if (head_need > 0 || skb_cloned(skb)) {
-#if 0
-		printk(KERN_DEBUG "%s: need to reallocate buffer for %d bytes "
-		       "of headroom\n", dev->name, head_need);
-#endif
-
-		if (skb_cloned(skb))
-			I802_DEBUG_INC(local->tx_expand_skb_head_cloned);
-		else
-			I802_DEBUG_INC(local->tx_expand_skb_head);
-		/* Since we have to reallocate the buffer, make sure that there
-		 * is enough room for possible WEP IV/ICV and TKIP (8 bytes
-		 * before payload and 12 after). */
-		if (pskb_expand_head(skb, (head_need > 0 ? head_need + 8 : 8),
-				     12, GFP_ATOMIC)) {
-			printk(KERN_DEBUG "%s: failed to reallocate TX buffer"
-			       "\n", dev->name);
+		head_need += IEEE80211_ENCRYPT_HEADROOM;
+		head_need += local->tx_headroom;
+		head_need = max_t(int, 0, head_need);
+		if (ieee80211_skb_resize(local, skb, head_need, 1))
 			goto fail;
-		}
 	}
 
 	if (encaps_data) {
--- everything.orig/net/mac80211/wep.c	2008-05-04 20:54:25.000000000 +0200
+++ everything/net/mac80211/wep.c	2008-05-04 21:50:10.000000000 +0200
@@ -93,13 +93,9 @@ static u8 *ieee80211_wep_add_iv(struct i
 	fc |= IEEE80211_FCTL_PROTECTED;
 	hdr->frame_control = cpu_to_le16(fc);
 
-	if ((skb_headroom(skb) < WEP_IV_LEN ||
-	     skb_tailroom(skb) < WEP_ICV_LEN)) {
-		I802_DEBUG_INC(local->tx_expand_skb_head);
-		if (unlikely(pskb_expand_head(skb, WEP_IV_LEN, WEP_ICV_LEN,
-					      GFP_ATOMIC)))
-			return NULL;
-	}
+	if (WARN_ON(skb_tailroom(skb) < WEP_ICV_LEN ||
+		    skb_headroom(skb) < WEP_IV_LEN))
+		return NULL;
 
 	hdrlen = ieee80211_get_hdrlen(fc);
 	newhdr = skb_push(skb, WEP_IV_LEN);
--- everything.orig/net/mac80211/wpa.c	2008-05-04 20:54:25.000000000 +0200
+++ everything/net/mac80211/wpa.c	2008-05-04 21:54:20.000000000 +0200
@@ -79,6 +79,7 @@ ieee80211_tx_h_michael_mic_add(struct ie
 	struct sk_buff *skb = tx->skb;
 	int authenticator;
 	int wpa_test = 0;
+	int tail;
 
 	fc = tx->fc;
 
@@ -98,16 +99,13 @@ ieee80211_tx_h_michael_mic_add(struct ie
 		return TX_CONTINUE;
 	}
 
-	if (skb_tailroom(skb) < MICHAEL_MIC_LEN) {
-		I802_DEBUG_INC(tx->local->tx_expand_skb_head);
-		if (unlikely(pskb_expand_head(skb, TKIP_IV_LEN,
-					      MICHAEL_MIC_LEN + TKIP_ICV_LEN,
-					      GFP_ATOMIC))) {
-			printk(KERN_DEBUG "%s: failed to allocate more memory "
-			       "for Michael MIC\n", tx->dev->name);
-			return TX_DROP;
-		}
-	}
+	tail = MICHAEL_MIC_LEN;
+	if (!(tx->key->flags & KEY_FLAG_UPLOADED_TO_HARDWARE))
+		tail += TKIP_ICV_LEN;
+
+	if (WARN_ON(skb_tailroom(skb) < tail ||
+		    skb_headroom(skb) < TKIP_IV_LEN))
+		return TX_DROP;
 
 #if 0
 	authenticator = fc & IEEE80211_FCTL_FROMDS; /* FIX */
@@ -189,7 +187,7 @@ static int tkip_encrypt_skb(struct ieee8
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
 	struct ieee80211_key *key = tx->key;
 	struct ieee80211_tx_info *info = (void *)skb->cb;
-	int hdrlen, len, tailneed;
+	int hdrlen, len, tail;
 	u16 fc;
 	u8 *pos;
 
@@ -210,17 +208,13 @@ static int tkip_encrypt_skb(struct ieee8
 	len = skb->len - hdrlen;
 
 	if (tx->key->flags & KEY_FLAG_UPLOADED_TO_HARDWARE)
-		tailneed = 0;
+		tail = 0;
 	else
-		tailneed = TKIP_ICV_LEN;
+		tail = TKIP_ICV_LEN;
 
-	if ((skb_headroom(skb) < TKIP_IV_LEN ||
-	     skb_tailroom(skb) < tailneed)) {
-		I802_DEBUG_INC(tx->local->tx_expand_skb_head);
-		if (unlikely(pskb_expand_head(skb, TKIP_IV_LEN, tailneed,
-					      GFP_ATOMIC)))
-			return -1;
-	}
+	if (WARN_ON(skb_tailroom(skb) < tail ||
+		    skb_headroom(skb) < TKIP_IV_LEN))
+		return TX_DROP;
 
 	pos = skb_push(skb, TKIP_IV_LEN);
 	memmove(pos, pos + TKIP_IV_LEN, hdrlen);
@@ -432,7 +426,7 @@ static int ccmp_encrypt_skb(struct ieee8
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
 	struct ieee80211_key *key = tx->key;
 	struct ieee80211_tx_info *info = (void *)skb->cb;
-	int hdrlen, len, tailneed;
+	int hdrlen, len, tail;
 	u16 fc;
 	u8 *pos, *pn, *b_0, *aad, *scratch;
 	int i;
@@ -449,7 +443,6 @@ static int ccmp_encrypt_skb(struct ieee8
 		return 0;
 	}
 
-
 	scratch = key->u.ccmp.tx_crypto_buf;
 	b_0 = scratch + 3 * AES_BLOCK_LEN;
 	aad = scratch + 4 * AES_BLOCK_LEN;
@@ -459,17 +452,13 @@ static int ccmp_encrypt_skb(struct ieee8
 	len = skb->len - hdrlen;
 
 	if (key->flags & KEY_FLAG_UPLOADED_TO_HARDWARE)
-		tailneed = 0;
+		tail = 0;
 	else
-		tailneed = CCMP_MIC_LEN;
+		tail = CCMP_MIC_LEN;
 
-	if ((skb_headroom(skb) < CCMP_HDR_LEN ||
-	     skb_tailroom(skb) < tailneed)) {
-		I802_DEBUG_INC(tx->local->tx_expand_skb_head);
-		if (unlikely(pskb_expand_head(skb, CCMP_HDR_LEN, tailneed,
-					      GFP_ATOMIC)))
-			return -1;
-	}
+	if (WARN_ON(skb_tailroom(skb) < tail ||
+		    skb_headroom(skb) < CCMP_HDR_LEN))
+		return TX_DROP;
 
 	pos = skb_push(skb, CCMP_HDR_LEN);
 	memmove(pos, pos + CCMP_HDR_LEN, hdrlen);


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
