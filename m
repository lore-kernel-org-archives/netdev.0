From: David Kimdon <david.kimdon@devicescape.com>
Subject: [take4 3/5] d80211: remove bitfields from ieee80211_key_conf
Date: Sun, 12 Nov 2006 09:52:46 -0800
Message-ID: <20061112175246.GD11728@devicescape.com>
References: <20061112175216.027653000@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	David Kimdon <david.kimdon@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:8406 "EHLO
	mail.devicescape.com") by vger.kernel.org with ESMTP
	id S1750993AbWKLRwq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Nov 2006 12:52:46 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline; filename="key_conf_bitfields.patch"
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All three one-bit bitfields have been subsumed into the new 'flags'
structure member and the new IEEE80211_KEY_* definitions. The 8 bit
keyidx bitfield is converted to type s8.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>

Index: wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
@@ -3667,7 +3667,7 @@ static int bcm43xx_net_set_key(struct ne
 	}
 	if (bcm43xx_current_phy(bcm)->fw == BCM43xx_FW_3) {
 		/* No support for HW-crypto with v3 firmware. */
-		key->force_sw_encrypt = 1;
+		key->flags |= IEEE80211_KEY_FORCE_SW_ENCRYPT;
 		err = 0;
 		goto out_unlock;
 	}
@@ -3678,7 +3678,7 @@ static int bcm43xx_net_set_key(struct ne
 		if (algorithm == BCM43xx_SEC_ALGO_TKIP) {
 			/* FIXME: No TKIP hardware encryption for now. */
 			err = 0;
-			key->force_sw_encrypt = 1;
+			key->flags |= IEEE80211_KEY_FORCE_SW_ENCRYPT;
 			goto out_unlock;
 		}
 
@@ -3702,7 +3702,7 @@ static int bcm43xx_net_set_key(struct ne
 					 bcm43xx_hf_read(bcm) &
 					 ~BCM43xx_HF_USEDEFKEYS);
 		}
-		key->force_sw_encrypt = 0;
+		key->flags &= ~IEEE80211_KEY_FORCE_SW_ENCRYPT;
 		break;
 	case DISABLE_KEY:
 		if (is_broadcast_ether_addr(addr)) {
@@ -3735,7 +3735,8 @@ out:
 	if (!err) {
 		dprintk(KERN_DEBUG PFX "Using %s based encryption for keyidx: %d, "
 			"mac: " MAC_FMT "\n",
-			(key->force_sw_encrypt) ? "software" : "hardware",
+			(key->flags & IEEE80211_KEY_FORCE_SW_ENCRYPT) ?
+			"software" : "hardware",
 			key->keyidx, MAC_ARG(addr));
 	}
 	return err;
Index: wireless-dev/include/net/d80211.h
===================================================================
--- wireless-dev.orig/include/net/d80211.h
+++ wireless-dev/include/net/d80211.h
@@ -368,13 +368,19 @@ struct ieee80211_key_conf {
 	ieee80211_key_alg alg;
 	int keylen;
 
-	unsigned int force_sw_encrypt:1;/* to be cleared by low-level driver */
-	int keyidx:8;			/* WEP key index */
-	unsigned int default_tx_key:1;	/* This key is the new default TX key
-			       		 * (used only for broadcast keys). */
-	unsigned int default_wep_only:1;/* static WEP is the only configured security
-					 * policy; this allows some low-level drivers
-					 * to determine when hwaccel can be used */
+#define IEEE80211_KEY_FORCE_SW_ENCRYPT (1<<0) /* to be cleared by low-level
+						 driver */
+#define IEEE80211_KEY_DEFAULT_TX_KEY   (1<<1) /* This key is the new default TX
+						 key (used only for broadcast
+						 keys). */
+#define IEEE80211_KEY_DEFAULT_WEP_ONLY (1<<2) /* static WEP is the only
+						 configured security policy;
+						 this allows some low-level
+						 drivers to determine when
+						 hwaccel can be used */
+	u32 flags; /* key configuration flags defined above */
+
+	s8 keyidx;			/* WEP key index */
         u8 key[0];
 };
 
Index: wireless-dev/net/d80211/ieee80211.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211.c
+++ wireless-dev/net/d80211/ieee80211.c
@@ -64,10 +64,14 @@ ieee80211_key_data2conf(struct ieee80211
 	conf->hw_key_idx = data->hw_key_idx;
 	conf->alg = data->alg;
 	conf->keylen = data->keylen;
-	conf->force_sw_encrypt = data->force_sw_encrypt;
+	conf->flags = 0;
+       if (data->force_sw_encrypt)
+		conf->flags |= IEEE80211_KEY_FORCE_SW_ENCRYPT;
 	conf->keyidx = data->keyidx;
-	conf->default_tx_key = data->default_tx_key;
-	conf->default_wep_only = local->default_wep_only;
+	if (data->default_tx_key)
+		conf->flags |= IEEE80211_KEY_DEFAULT_TX_KEY;
+	if (local->default_wep_only)
+		conf->flags |= IEEE80211_KEY_DEFAULT_WEP_ONLY;
 	memcpy(conf->key, data->key, data->keylen);
 
 	return conf;
Index: wireless-dev/net/d80211/ieee80211_ioctl.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211_ioctl.c
+++ wireless-dev/net/d80211/ieee80211_ioctl.c
@@ -331,7 +331,7 @@ static int ieee80211_ioctl_add_sta(struc
 		memset(&conf, 0, sizeof(conf));
 		conf.hw_key_idx = HW_KEY_IDX_INVALID;
 		conf.alg = ALG_NULL;
-		conf.force_sw_encrypt = 1;
+		conf.flags |= IEEE80211_KEY_FORCE_SW_ENCRYPT;
 		if (local->hw->set_key(dev, SET_KEY, sta->addr, &conf,
 				       sta->aid)) {
 			sta->key_idx_compression = HW_KEY_IDX_INVALID;
@@ -501,7 +501,7 @@ int ieee80211_set_hw_encryption(struct n
 			key->hw_key_idx = HW_KEY_IDX_INVALID;
 		} else {
 			key->force_sw_encrypt =
-				keyconf->force_sw_encrypt;
+				!!(keyconf->flags & IEEE80211_KEY_FORCE_SW_ENCRYPT);
 			key->hw_key_idx =
 				keyconf->hw_key_idx;
 
@@ -2304,7 +2304,8 @@ static void ieee80211_key_enable_hwaccel
 	keyconf = ieee80211_key_data2conf(local, key);
 	if (keyconf && local->hw->set_key &&
 	    local->hw->set_key(local->mdev, SET_KEY, addr, keyconf, 0) == 0) {
-		key->force_sw_encrypt = keyconf->force_sw_encrypt;
+		key->force_sw_encrypt =
+			!!(keyconf->flags & IEEE80211_KEY_FORCE_SW_ENCRYPT);
 		key->hw_key_idx = keyconf->hw_key_idx;
 	}
 	kfree(keyconf);
Index: wireless-dev/net/d80211/sta_info.c
===================================================================
--- wireless-dev.orig/net/d80211/sta_info.c
+++ wireless-dev/net/d80211/sta_info.c
@@ -255,7 +255,7 @@ void sta_info_free(struct sta_info *sta,
 		memset(&conf, 0, sizeof(conf));
 		conf.hw_key_idx = sta->key_idx_compression;
 		conf.alg = ALG_NULL;
-		conf.force_sw_encrypt = 1;
+		conf.flags |= IEEE80211_KEY_FORCE_SW_ENCRYPT;
 		local->hw->set_key(local->mdev, DISABLE_KEY, sta->addr, &conf,
 				   sta->aid);
 		sta->key_idx_compression = HW_KEY_IDX_INVALID;

--
