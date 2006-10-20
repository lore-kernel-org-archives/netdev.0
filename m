From: Hong Liu <hong.liu@intel.com>
Subject: [patch 2/2] d80211: fix wep_tfm race
Date: Fri, 20 Oct 2006 17:20:36 +0800
Message-ID: <1161336034.21402.15.camel@devlinux-hong>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:56915 "EHLO mga02.intel.com")
	by vger.kernel.org with ESMTP id S932241AbWJTJ1L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2006 05:27:11 -0400
To: Jiri Benc <jbenc@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The TX/RX path all use the local->wep_tfm to encrypt and decrypt
packets. Each {en|de}crypt operation need set a new RC4key,
this may corrupt the previous set key that is still being used.
Thus cause a lot of decrypton error or encryption with the wrong key.
Use two tfm (tx_tfm and rx_tfm) to avoid this race.

Signed-off-by: Hong Liu <hong.liu@intel.com>

---

 net/d80211/ieee80211_i.h |    3 ++-
 net/d80211/wep.c         |   18 +++++++++++++-----
 net/d80211/wpa.c         |    6 ++++--
 3 files changed, 19 insertions(+), 8 deletions(-)

634c9615ce3cd06dc7f6aff05e43e61490a53472
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index 425fc9b..152b41a 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -402,7 +402,8 @@ #define IEEE80211_IRQSAFE_QUEUE_LIMIT 12
 	int long_retry_limit; /* dot11LongRetryLimit */
 	int short_preamble; /* use short preamble with IEEE 802.11b */
 
-	struct crypto_tfm *wep_tfm;
+	struct crypto_tfm *wep_tx_tfm;
+	struct crypto_tfm *wep_rx_tfm;
 	u32 wep_iv;
 	int key_tx_rx_threshold; /* number of times any key can be used in TX
 				  * or RX before generating a rekey
diff --git a/net/d80211/wep.c b/net/d80211/wep.c
index 22c2e53..06e0230 100644
--- a/net/d80211/wep.c
+++ b/net/d80211/wep.c
@@ -26,16 +26,23 @@ int ieee80211_wep_init(struct ieee80211_
 	/* start WEP IV from a random value */
 	get_random_bytes(&local->wep_iv, WEP_IV_LEN);
 
-	local->wep_tfm = crypto_alloc_tfm("arc4", 0);
-	if (!local->wep_tfm)
+	local->wep_tx_tfm = crypto_alloc_tfm("arc4", 0);
+	if (!local->wep_tx_tfm)
 		return -ENOMEM;
 
+	local->wep_rx_tfm = crypto_alloc_tfm("arc4", 0);
+	if (!local->wep_rx_tfm) {
+		crypto_free_tfm(local->wep_tx_tfm);
+		return -ENOMEM;
+	}
+
 	return 0;
 }
 
 void ieee80211_wep_free(struct ieee80211_local *local)
 {
-	crypto_free_tfm(local->wep_tfm);
+	crypto_free_tfm(local->wep_tx_tfm);
+	crypto_free_tfm(local->wep_rx_tfm);
 }
 
 static inline int ieee80211_wep_weak_iv(u32 iv, int keylen)
@@ -172,7 +179,8 @@ int ieee80211_wep_encrypt(struct ieee802
 	/* Add room for ICV */
 	skb_put(skb, WEP_ICV_LEN);
 
-	ieee80211_wep_encrypt_data(local->wep_tfm, rc4key, klen, iv + WEP_IV_LEN, len);
+	ieee80211_wep_encrypt_data(local->wep_tx_tfm, rc4key, klen,
+				   iv + WEP_IV_LEN, len);
 
 	kfree(rc4key);
 
@@ -252,7 +260,7 @@ int ieee80211_wep_decrypt(struct ieee802
 	/* Copy rest of the WEP key (the secret part) */
 	memcpy(rc4key + 3, key->key, key->keylen);
 
-	if (ieee80211_wep_decrypt_data(local->wep_tfm, rc4key, klen,
+	if (ieee80211_wep_decrypt_data(local->wep_rx_tfm, rc4key, klen,
 				       skb->data + hdrlen + WEP_IV_LEN,
 				       len)) {
 		printk(KERN_DEBUG "WEP decrypt failed (ICV)\n");
diff --git a/net/d80211/wpa.c b/net/d80211/wpa.c
index 5e62464..ef707ad 100644
--- a/net/d80211/wpa.c
+++ b/net/d80211/wpa.c
@@ -352,7 +352,8 @@ #endif /* CONFIG_HOSTAPD_WPA_TESTING */
 	skb_put(skb, TKIP_ICV_LEN);
 
 	hdr = (struct ieee80211_hdr *) skb->data;
-	ieee80211_tkip_encrypt_data(tx->local->wep_tfm, key, pos, len, hdr->addr2);
+	ieee80211_tkip_encrypt_data(tx->local->wep_tx_tfm,
+				    key, pos, len, hdr->addr2);
 	return 0;
 }
 
@@ -495,7 +496,8 @@ #endif /* CONFIG_HOSTAPD_WPA_TESTING */
 		hwaccel = 1;
 	}
 
-	res = ieee80211_tkip_decrypt_data(rx->local->wep_tfm, key, skb->data + hdrlen,
+	res = ieee80211_tkip_decrypt_data(rx->local->wep_rx_tfm,
+					  key, skb->data + hdrlen,
 					  skb->len - hdrlen, rx->sta->addr,
 					  hwaccel, rx->u.rx.queue);
 	if (res != TKIP_DECRYPT_OK || wpa_test) {
-- 
1.3.3

