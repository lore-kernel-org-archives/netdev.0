From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 11/13] d80211: remove IEEE80211_CONF_SW_{EN,DE}CRYPT
Date: Sun, 19 Nov 2006 20:31:48 +0100
Message-ID: <1163964708.15473.61.camel@johannes.berg>
References: <1163802439.3392.47.camel@johannes.berg>
	 <1163963898.15473.36.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Jouni Malinen <jkm@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>,
	Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:64438 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S933070AbWKSTe3
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Nov 2006 14:34:29 -0500
To: netdev@vger.kernel.org
In-Reply-To: <1163963898.15473.36.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There's no point in trying to tell a driver globally whether sw or hw
crypto is used, if it's sw then we just don't give it keys...

Besides, these weren't ever used!
Remove IEEE80211_CONF_SW_DECRYPT and IEEE80211_CONF_SW_ENCRYPT.

Acked-by: Michael Buesch <mb@bu3sch.de>
Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

--- wireless-dev.orig/include/net/d80211.h	2006-11-19 20:14:00.639275208 +0100
+++ wireless-dev/include/net/d80211.h	2006-11-19 20:14:02.289275208 +0100
@@ -244,11 +244,9 @@ struct ieee80211_conf {
 
         int beacon_int;
 
-#define IEEE80211_CONF_SW_ENCRYPT	(1<<0)
-#define IEEE80211_CONF_SW_DECRYPT	(1<<1)
-#define IEEE80211_CONF_SHORT_SLOT_TIME	(1<<2) /* use IEEE 802.11g Short Slot
+#define IEEE80211_CONF_SHORT_SLOT_TIME	(1<<0) /* use IEEE 802.11g Short Slot
 						* Time */
-#define IEEE80211_CONF_SSID_HIDDEN	(1<<3) /* do not broadcast the ssid */
+#define IEEE80211_CONF_SSID_HIDDEN	(1<<1) /* do not broadcast the ssid */
 	u32 flags;			/* configuration flags defined above */
 
         u8 power_level;			/* transmit power limit for current
--- wireless-dev.orig/net/d80211/ieee80211.c	2006-11-19 20:14:00.039275208 +0100
+++ wireless-dev/net/d80211/ieee80211.c	2006-11-19 20:14:02.299275208 +0100
@@ -516,8 +516,7 @@ ieee80211_tx_h_fragment(struct ieee80211
 
 static int wep_encrypt_skb(struct ieee80211_txrx_data *tx, struct sk_buff *skb)
 {
-	if (tx->key->force_sw_encrypt ||
-	    (tx->local->hw.conf.flags & IEEE80211_CONF_SW_ENCRYPT)) {
+	if (tx->key->force_sw_encrypt) {
 		if (ieee80211_wep_encrypt(tx->local, skb, tx->key))
 			return -1;
 	} else {
@@ -3268,8 +3267,7 @@ ieee80211_rx_h_wep_weak_iv_detection(str
 
 	/* Check for weak IVs, if hwaccel did not remove IV from the frame */
 	if ((rx->local->hw.flags & IEEE80211_HW_WEP_INCLUDE_IV) ||
-	    rx->key->force_sw_encrypt ||
-	    (rx->local->hw.conf.flags & IEEE80211_CONF_SW_ENCRYPT)) {
+	    rx->key->force_sw_encrypt) {
 		u8 *iv = ieee80211_wep_is_weak_iv(rx->skb, rx->key);
 		if (iv) {
 			rx->sta->wep_weak_iv_count++;
@@ -3301,8 +3299,7 @@ ieee80211_rx_h_wep_decrypt(struct ieee80
 	}
 
 	if (!(rx->u.rx.status->flag & RX_FLAG_DECRYPTED) ||
-	    rx->key->force_sw_encrypt ||
-	    (rx->local->hw.conf.flags & IEEE80211_CONF_SW_DECRYPT)) {
+	    rx->key->force_sw_encrypt) {
 		if (ieee80211_wep_decrypt(rx->local, rx->skb, rx->key)) {
 			printk(KERN_DEBUG "%s: RX WEP frame, decrypt "
 			       "failed\n", rx->dev->name);
--- wireless-dev.orig/net/d80211/ieee80211_ioctl.c	2006-11-19 20:13:58.049275208 +0100
+++ wireless-dev/net/d80211/ieee80211_ioctl.c	2006-11-19 20:14:02.299275208 +0100
@@ -492,9 +492,7 @@ int ieee80211_set_hw_encryption(struct n
 		key->force_sw_encrypt = 1;
 
 	if (key && local->ops->set_key &&
-	    (!(local->hw.conf.flags & IEEE80211_CONF_SW_ENCRYPT) ||
-	     !(local->hw.conf.flags & IEEE80211_CONF_SW_DECRYPT)) &&
-	    (keyconf = ieee80211_key_data2conf(local, key)) != NULL) {
+	    (keyconf = ieee80211_key_data2conf(local, key))) {
 		if (local->ops->set_key(local_to_hw(local), SET_KEY, addr,
 				       keyconf, sta ? sta->aid : 0)) {
 			rc = HOSTAP_CRYPT_ERR_KEY_SET_FAILED;
--- wireless-dev.orig/net/d80211/wpa.c	2006-11-19 20:13:58.069275208 +0100
+++ wireless-dev/net/d80211/wpa.c	2006-11-19 20:14:02.309275208 +0100
@@ -104,7 +104,6 @@ ieee80211_tx_h_michael_mic_add(struct ie
 #endif /* CONFIG_HOSTAPD_WPA_TESTING */
 
 	if (!tx->key->force_sw_encrypt &&
-	    !(tx->local->hw.conf.flags & IEEE80211_CONF_SW_DECRYPT) &&
 	    !tx->fragmented &&
 	    !(tx->local->hw.flags & IEEE80211_HW_TKIP_INCLUDE_MMIC) &&
 	    !wpa_test) {
@@ -186,8 +185,7 @@ ieee80211_rx_h_michael_mic_verify(struct
 #endif /* CONFIG_HOSTAPD_WPA_TESTING */
 
 	if ((rx->u.rx.status->flag & RX_FLAG_DECRYPTED) &&
-	    !rx->key->force_sw_encrypt &&
-	    !(rx->local->hw.conf.flags & IEEE80211_CONF_SW_DECRYPT)) {
+	    !rx->key->force_sw_encrypt) {
 		if (rx->local->hw.flags & IEEE80211_HW_WEP_INCLUDE_IV) {
 			if (skb->len < MICHAEL_MIC_LEN)
 				return TXRX_DROP;
@@ -297,9 +295,7 @@ static int tkip_encrypt_skb(struct ieee8
 	hdrlen = ieee80211_get_hdrlen(fc);
 	len = skb->len - hdrlen;
 
-	tailneed = (!tx->key->force_sw_encrypt &&
-		    !(tx->local->hw.conf.flags & IEEE80211_CONF_SW_DECRYPT))
-		? 0 : TKIP_ICV_LEN;
+	tailneed = !tx->key->force_sw_encrypt ? 0 : TKIP_ICV_LEN;
 	if ((skb_headroom(skb) < TKIP_IV_LEN ||
 	     skb_tailroom(skb) < tailneed)) {
 		I802_DEBUG_INC(tx->local->tx_expand_skb_head);
@@ -331,8 +327,7 @@ iv_inc:
 skip_iv_inc:
 #endif /* CONFIG_HOSTAPD_WPA_TESTING */
 
-	if (!tx->key->force_sw_encrypt &&
-	    !(tx->local->hw.conf.flags & IEEE80211_CONF_SW_DECRYPT)
+	if (!tx->key->force_sw_encrypt
 #ifdef CONFIG_HOSTAPD_WPA_TESTING
 	    && !tx->wpa_test
 #endif /* CONFIG_HOSTAPD_WPA_TESTING */
@@ -427,7 +422,6 @@ ieee80211_tx_h_tkip_encrypt(struct ieee8
 #endif /* CONFIG_HOSTAPD_WPA_TESTING */
 
 	if (!tx->key->force_sw_encrypt &&
-	    !(tx->local->hw.conf.flags & IEEE80211_CONF_SW_DECRYPT) &&
 	    !(tx->local->hw.flags & IEEE80211_HW_WEP_INCLUDE_IV) &&
 	    !wpa_test) {
 		/* hwaccel - with no need for preallocated room for IV/ICV */
@@ -506,8 +500,7 @@ ieee80211_rx_h_tkip_decrypt(struct ieee8
 #endif /* CONFIG_HOSTAPD_WPA_TESTING */
 
 	if ((rx->u.rx.status->flag & RX_FLAG_DECRYPTED) &&
-	    !rx->key->force_sw_encrypt &&
-	    !(rx->local->hw.conf.flags & IEEE80211_CONF_SW_DECRYPT)) {
+	    !rx->key->force_sw_encrypt) {
 		if (!(rx->local->hw.flags & IEEE80211_HW_WEP_INCLUDE_IV)) {
 			/* Hardware takes care of all processing, including
 			 * replay protection, so no need to continue here. */
@@ -651,9 +644,7 @@ static int ccmp_encrypt_skb(struct ieee8
 	hdrlen = ieee80211_get_hdrlen(fc);
 	len = skb->len - hdrlen;
 
-	tailneed = (!key->force_sw_encrypt &&
-		    !(tx->local->hw.conf.flags & IEEE80211_CONF_SW_DECRYPT))
-		? 0 : CCMP_MIC_LEN;
+	tailneed = !key->force_sw_encrypt ? 0 : CCMP_MIC_LEN;
 
 	if ((skb_headroom(skb) < CCMP_HDR_LEN ||
 	     skb_tailroom(skb) < tailneed)) {
@@ -693,8 +684,7 @@ skip_pn_inc:
 
 	ccmp_pn2hdr(pos, pn, key->keyidx);
 
-	if (!key->force_sw_encrypt &&
-	    !(tx->local->hw.conf.flags & IEEE80211_CONF_SW_DECRYPT)) {
+	if (!key->force_sw_encrypt) {
 		/* hwaccel - with preallocated room for CCMP header */
 		tx->u.tx.control->key_idx = key->hw_key_idx;
 		return 0;
@@ -749,7 +739,6 @@ ieee80211_tx_h_ccmp_encrypt(struct ieee8
 	ieee80211_tx_set_iswep(tx);
 
 	if (!tx->key->force_sw_encrypt &&
-	    !(tx->local->hw.conf.flags & IEEE80211_CONF_SW_DECRYPT) &&
 	    !(tx->local->hw.flags & IEEE80211_HW_WEP_INCLUDE_IV)) {
 		/* hwaccel - with no need for preallocated room for CCMP "
 		 * header or MIC fields */
@@ -802,7 +791,6 @@ ieee80211_rx_h_ccmp_decrypt(struct ieee8
 
 	if ((rx->u.rx.status->flag & RX_FLAG_DECRYPTED) &&
 	    !key->force_sw_encrypt &&
-	    !(rx->local->hw.conf.flags & IEEE80211_CONF_SW_DECRYPT) &&
 	    !(rx->local->hw.flags & IEEE80211_HW_WEP_INCLUDE_IV))
 		return TXRX_CONTINUE;
 
@@ -823,8 +811,7 @@ ieee80211_rx_h_ccmp_decrypt(struct ieee8
 	}
 
 	if ((rx->u.rx.status->flag & RX_FLAG_DECRYPTED) &&
-	    !key->force_sw_encrypt &&
-	    !(rx->local->hw.conf.flags & IEEE80211_CONF_SW_DECRYPT)) {
+	    !key->force_sw_encrypt) {
 		/* hwaccel has already decrypted frame and verified MIC */
 	} else {
 		u8 *scratch, *b_0, *aad;


