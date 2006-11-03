From: Hong Liu <hong.liu@intel.com>
Subject: [patch] d80211: fix key access race
Date: Fri, 03 Nov 2006 11:48:22 +0800
Message-ID: <1162525702.1726.10.camel@devlinux-hong>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:27001 "EHLO mga02.intel.com")
	by vger.kernel.org with ESMTP id S1753038AbWKCDzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2006 22:55:50 -0500
To: Jiri Benc <jbenc@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It seems we don't have any protection when accessing the key.
The RX/TX path may acquire a key which can be freed by the
ioctl cmd.

I put a key_lock spinlock to protect all the accesses to the key
(whether the sta_info->key or ieee80211_sub_if_data->keys[]). 
Don't find a good way to handle it :(

Thanks,
Hong

Signed-off-by: Hong Liu <hong.liu@intel.com>

diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 751bc76..1a1f6fb 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -99,12 +99,38 @@ struct ieee80211_key *ieee80211_key_allo
 	return key;
 }
 
-void ieee80211_key_free(struct ieee80211_key *key)
+void ieee80211_key_put(struct ieee80211_key *key)
 {
 	if (key)
 		kobject_put(&key->kobj);
 }
 
+void ieee80211_key_get(struct ieee80211_key *key)
+{
+	if (key)
+		kobject_get(&key->kobj);
+}
+
+void ieee80211_key_free(struct ieee80211_local *local,
+			struct ieee80211_key **key,
+			struct ieee80211_sub_if_data *sdata)
+{
+	int remove_def = 0;
+
+	if (*key && sdata && sdata->default_key == *key) {
+		ieee80211_key_sysfs_remove_default(sdata);
+		remove_def = 1;
+	}
+	ieee80211_key_sysfs_remove(*key);
+
+	spin_lock_bh(&local->key_lock);
+	if (remove_def)
+		sdata->default_key = NULL;
+	*key = NULL;
+	ieee80211_key_put(*key);
+	spin_unlock_bh(&local->key_lock);
+}
+
 void ieee80211_key_release(struct kobject *kobj)
 {
 	struct ieee80211_key *key;
@@ -402,6 +428,7 @@ ieee80211_tx_h_select_key(struct ieee802
 	else
 		tx->u.tx.control->key_idx = HW_KEY_IDX_INVALID;
 
+	spin_lock_bh(&tx->local->key_lock);
 	if (unlikely(tx->u.tx.control->flags & IEEE80211_TXCTL_DO_NOT_ENCRYPT))
 		tx->key = NULL;
 	else if (tx->sta && tx->sta->key)
@@ -410,11 +437,16 @@ ieee80211_tx_h_select_key(struct ieee802
 		tx->key = tx->sdata->default_key;
 	else if (tx->sdata->drop_unencrypted &&
 		 !(tx->sdata->eapol && ieee80211_is_eapol(tx->skb))) {
+		spin_unlock_bh(&tx->local->key_lock);
 		I802_DEBUG_INC(tx->local->tx_handlers_drop_unencrypted);
 		return TXRX_DROP;
 	} else
 		tx->key = NULL;
 
+	if (tx->key)
+		ieee80211_key_get(tx->key);
+	spin_unlock_bh(&tx->local->key_lock);
+
 	if (tx->key) {
 		tx->key->tx_rx_count++;
 		if (unlikely(tx->local->key_tx_rx_threshold &&
@@ -1216,6 +1248,9 @@ static int ieee80211_tx(struct net_devic
 
 	skb = tx.skb; /* handlers are allowed to change skb */
 
+	if (tx.key)
+		ieee80211_key_put(tx.key);
+
 	if (sta)
 		sta_info_put(sta);
 
@@ -3092,6 +3127,7 @@ ieee80211_rx_h_check(struct ieee80211_tx
 	else
 		always_sta_key = 1;
 
+	spin_lock(&rx->local->key_lock);
 	if (rx->sta && rx->sta->key && always_sta_key) {
 		rx->key = rx->sta->key;
         } else {
@@ -3109,6 +3145,7 @@ ieee80211_rx_h_check(struct ieee80211_tx
 				rx->key = rx->sdata->keys[keyidx];
 
 			if (!rx->key) {
+				spin_unlock(&rx->local->key_lock);
 				if (!rx->u.rx.ra_match)
 					return TXRX_DROP;
 				printk(KERN_DEBUG "%s: RX WEP frame with "
@@ -3126,6 +3163,10 @@ ieee80211_rx_h_check(struct ieee80211_tx
 		}
         }
 
+	if (rx->key)
+		ieee80211_key_get(rx->key);
+	spin_unlock(&rx->local->key_lock);
+
 	if (rx->fc & IEEE80211_FCTL_PROTECTED && rx->key && rx->u.rx.ra_match) {
 		rx->key->tx_rx_count++;
 		if (unlikely(rx->local->key_tx_rx_threshold &&
@@ -3705,6 +3746,8 @@ void __ieee80211_rx(struct net_device *d
 	}
 
   end:
+	if (rx.key)
+		ieee80211_key_put(rx.key);
 	if (sta)
 		sta_info_put(sta);
 }
@@ -4411,6 +4454,7 @@ struct net_device *ieee80211_alloc_hw(si
         init_timer(&local->scan.timer); /* clear it out */
 
         spin_lock_init(&local->generic_lock);
+	spin_lock_init(&local->key_lock);
 	init_timer(&local->stat_timer);
 	local->stat_timer.function = ieee80211_stat_refresh;
 	local->stat_timer.data = (unsigned long) local;
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index 89666ec..8e2a4a3 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -361,6 +361,7 @@ #define IEEE80211_IRQSAFE_QUEUE_LIMIT 12
 	} ieee80211_msg_enum;
 
         spinlock_t generic_lock;
+	spinlock_t key_lock;
 	/* Station data structures */
 	struct kset sta_kset;
 	spinlock_t sta_lock; /* mutex for STA data structures */
@@ -568,7 +569,11 @@ ieee80211_key_data2conf(struct ieee80211
 			struct ieee80211_key *data);
 struct ieee80211_key *ieee80211_key_alloc(struct ieee80211_sub_if_data *sdata,
 					  int idx, size_t key_len, gfp_t flags);
-void ieee80211_key_free(struct ieee80211_key *key);
+void ieee80211_key_get(struct ieee80211_key *key);
+void ieee80211_key_put(struct ieee80211_key *key);
+void ieee80211_key_free(struct ieee80211_local *local,
+			struct ieee80211_key **key,
+			struct ieee80211_sub_if_data *sdata);
 void ieee80211_key_release(struct kobject *kobj);
 void ieee80211_rx_mgmt(struct net_device *dev, struct sk_buff *skb,
 		       struct ieee80211_rx_status *status, u32 msg_type);
diff --git a/net/d80211/ieee80211_iface.c b/net/d80211/ieee80211_iface.c
index 9a187af..4455bd2 100644
--- a/net/d80211/ieee80211_iface.c
+++ b/net/d80211/ieee80211_iface.c
@@ -239,7 +239,7 @@ #if 0
 			local->hw->set_key(dev, DISABLE_KEY, addr,
 					   local->keys[i], 0);
 #endif
-		ieee80211_key_free(sdata->keys[i]);
+		ieee80211_key_free(local, &sdata->keys[i], NULL);
 	}
 
 	/* Shouldn't be necessary but won't hurt */
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index 7179cdc..0ee51da 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -521,7 +521,7 @@ static int ieee80211_set_encryption(stru
 	struct ieee80211_local *local = dev->ieee80211_ptr;
 	int ret = 0;
 	struct sta_info *sta;
-	struct ieee80211_key *key, *old_key;
+	struct ieee80211_key **key;
 	int try_hwaccel = 1;
         struct ieee80211_key_conf *keyconf;
         struct ieee80211_sub_if_data *sdata;
@@ -537,7 +537,7 @@ static int ieee80211_set_encryption(stru
 			       dev->name, idx);
 			return -EINVAL;
 		}
-		key = sdata->keys[idx];
+		key = &sdata->keys[idx];
 
 		/* Disable hwaccel for default keys when the interface is not
 		 * the default one.
@@ -576,7 +576,7 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 			return -ENOENT;
 		}
 
-		key = sta->key;
+		key = &sta->key;
 	}
 
 	/* FIX:
@@ -623,8 +623,8 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 
 	if (alg == ALG_NONE) {
 		keyconf = NULL;
-		if (try_hwaccel && key && local->hw->set_key &&
-		    (keyconf = ieee80211_key_data2conf(local, key)) != NULL &&
+		if (try_hwaccel && *key && local->hw->set_key &&
+		    (keyconf = ieee80211_key_data2conf(local, *key)) != NULL &&
 		    local->hw->set_key(dev, DISABLE_KEY, sta_addr,
 				       keyconf, sta ? sta->aid : 0)) {
 			if (err)
@@ -635,77 +635,62 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 		}
 		kfree(keyconf);
 
-		if (key && sdata->default_key == key) {
-			ieee80211_key_sysfs_remove_default(sdata);
-			sdata->default_key = NULL;
-		}
-		ieee80211_key_sysfs_remove(key);
-		if (sta)
-			sta->key = NULL;
-		else
-			sdata->keys[idx] = NULL;
-		ieee80211_key_free(key);
-		key = NULL;
+		ieee80211_key_free(local, key, sdata);
 	} else {
-		old_key = key;
-		key = ieee80211_key_alloc(sta ? NULL : sdata, idx, key_len,
+		struct ieee80211_key *tmp;
+		tmp = ieee80211_key_alloc(sta ? NULL : sdata, idx, key_len,
 					  GFP_KERNEL);
-		if (!key) {
+		if (!tmp) {
 			ret = -ENOMEM;
 			goto err_out;
 		}
 
 		/* default to sw encryption; low-level driver sets these if the
 		 * requested encryption is supported */
-		key->hw_key_idx = HW_KEY_IDX_INVALID;
-		key->force_sw_encrypt = 1;
+		tmp->hw_key_idx = HW_KEY_IDX_INVALID;
+		tmp->force_sw_encrypt = 1;
 
-		key->alg = alg;
-		key->keyidx = idx;
-		key->keylen = key_len;
-		memcpy(key->key, _key, key_len);
+		tmp->alg = alg;
+		tmp->keyidx = idx;
+		tmp->keylen = key_len;
+		memcpy(tmp->key, _key, key_len);
 		if (set_tx_key)
-			key->default_tx_key = 1;
+			tmp->default_tx_key = 1;
 
 		if (alg == ALG_CCMP) {
 			/* Initialize AES key state here as an optimization
 			 * so that it does not need to be initialized for every
 			 * packet. */
-			key->u.ccmp.tfm = ieee80211_aes_key_setup_encrypt(
-				key->key);
-			if (!key->u.ccmp.tfm) {
+			tmp->u.ccmp.tfm = ieee80211_aes_key_setup_encrypt(
+				tmp->key);
+			if (!tmp->u.ccmp.tfm) {
 				ret = -ENOMEM;
-				goto err_free;
+				kfree(tmp);
+				goto err_out;
 			}
 		}
 
-		if (old_key && sdata->default_key == old_key) {
-			ieee80211_key_sysfs_remove_default(sdata);
-			sdata->default_key = NULL;
-		}
-		ieee80211_key_sysfs_remove(old_key);
-		if (sta)
-			sta->key = key;
-		else
-			sdata->keys[idx] = key;
-		ieee80211_key_free(old_key);
+		ieee80211_key_free(local, key, sdata);
+		spin_lock_bh(&local->key_lock);
+		*key = tmp;
+		spin_unlock_bh(&local->key_lock);
 		if (sta)
-			key->kobj.parent = &sta->kobj;
-		ret = ieee80211_key_sysfs_add(key);
+			(*key)->kobj.parent = &sta->kobj;
+		ret = ieee80211_key_sysfs_add(*key);
 		if (ret)
 			goto err_null;
 
 		if (try_hwaccel &&
 		    (alg == ALG_WEP || alg == ALG_TKIP || alg == ALG_CCMP)) {
 			int e = ieee80211_set_hw_encryption(dev, sta, sta_addr,
-							    key);
+							    *key);
 			if (err)
 				*err = e;
 		}
 	}
 
-	if (set_tx_key || (!sta && !sdata->default_key && key)) {
-		sdata->default_key = key;
+	if (set_tx_key || (!sta && !sdata->default_key && *key)) {
+		sdata->default_key = *key;
 		if (ieee80211_key_sysfs_add_default(sdata))
 			printk(KERN_WARNING "%s: cannot create symlink to "
 			       "default key\n", dev->name);
@@ -721,12 +706,7 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 	return 0;
 
 err_null:
-	if (sta)
-		sta->key = NULL;
-	else
-		sdata->keys[idx] = NULL;
-err_free:
-	ieee80211_key_free(key);
+	ieee80211_key_free(local, key, NULL);
 err_out:
 	if (sta)
 		sta_info_put(sta);
@@ -2199,10 +2179,8 @@ static int ieee80211_ioctl_clear_keys(st
 				local->hw->set_key(dev, DISABLE_KEY, addr,
 						   keyconf, 0);
 			kfree(keyconf);
-			ieee80211_key_free(sdata->keys[i]);
-			sdata->keys[i] = NULL;
+			ieee80211_key_free(local, &sdata->keys[i], sdata);
 		}
-		sdata->default_key = NULL;
 	}
 
 	spin_lock_bh(&local->sta_lock);
@@ -2214,8 +2192,7 @@ static int ieee80211_ioctl_clear_keys(st
 			local->hw->set_key(dev, DISABLE_KEY, sta->addr,
 					   keyconf, sta->aid);
 		kfree(keyconf);
-		ieee80211_key_free(sta->key);
-		sta->key = NULL;
+		ieee80211_key_free(local, &sta->key, NULL);
 	}
 	spin_unlock_bh(&local->sta_lock);
 
diff --git a/net/d80211/sta_info.c b/net/d80211/sta_info.c
index 6e73fab..246ae34 100644
--- a/net/d80211/sta_info.c
+++ b/net/d80211/sta_info.c
@@ -197,11 +197,7 @@ #ifdef CONFIG_D80211_VERBOSE_DEBUG
 	       local->mdev->name, MAC_ARG(sta->addr));
 #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 
-	if (sta->key) {
-		ieee80211_key_sysfs_remove(sta->key);
-		ieee80211_key_free(sta->key);
-		sta->key = NULL;
-	}
+	ieee80211_key_free(local, &sta->key, NULL);
 
 	rate_control_remove_sta_attrs(sta, &sta->kobj);
 	ieee80211_sta_sysfs_remove(sta);
