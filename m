From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 3/21] d80211: pointers as extended booleans
Date: Wed, 23 Aug 2006 21:24:11 +0200 (CEST)
Message-ID: <20060823192411.D2B9D483A1@silver.suse.cz>
References: <20060823212316.333159079.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:27600 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S965119AbWHWTYM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 15:24:12 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060823212316.333159079.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes@sipsolutions.net>

This huge patch changes d80211 to treat pointers as "extended booleans",
using "if (!ptr)" and "if (ptr)" instead of comparisons with NULL.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/aes_ccm.c         |    2 +
 net/d80211/ieee80211.c       |   60 ++++++++++++++++-------------------
 net/d80211/ieee80211_iface.c |    6 ++--
 net/d80211/ieee80211_ioctl.c |   48 ++++++++++++++--------------
 net/d80211/ieee80211_scan.c  |   10 +++---
 net/d80211/ieee80211_sta.c   |   72 ++++++++++++++++++++----------------------
 net/d80211/rate_control.c    |    8 ++---
 net/d80211/rate_control.h    |    2 +
 net/d80211/sta_info.c        |   13 ++++----
 net/d80211/wep.c             |   12 ++++---
 net/d80211/wme.c             |    4 +-
 net/d80211/wpa.c             |    2 +
 12 files changed, 116 insertions(+), 123 deletions(-)

3ee6077477530a8082c8eb62de350c30f703e2a2
diff --git a/net/d80211/aes_ccm.c b/net/d80211/aes_ccm.c
index 742ca99..8d1045c 100644
--- a/net/d80211/aes_ccm.c
+++ b/net/d80211/aes_ccm.c
@@ -149,7 +149,7 @@ struct crypto_tfm * ieee80211_aes_key_se
 	struct crypto_tfm *tfm;
 
 	tfm = crypto_alloc_tfm("aes", 0);
-	if (tfm == NULL)
+	if (!tfm)
 		return NULL;
 
 	crypto_cipher_setkey(tfm, key, ALG_CCMP_KEY_LEN);
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 0b3c886..ac0b706 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -68,7 +68,7 @@ ieee80211_key_data2conf(struct ieee80211
 	struct ieee80211_key_conf *conf;
 
 	conf = kmalloc(sizeof(*conf) + data->keylen, GFP_ATOMIC);
-	if (conf == NULL)
+	if (!conf)
 		return NULL;
 
 	conf->hw_key_idx = data->hw_key_idx;
@@ -125,7 +125,7 @@ static int rate_list_match(int *rate_lis
 {
 	int i;
 
-	if (rate_list == NULL)
+	if (!rate_list)
 		return 0;
 
 	for (i = 0; rate_list[i] >= 0; i++)
@@ -222,7 +222,7 @@ static void ieee80211_key_threshold_noti
 
 	skb = dev_alloc_skb(sizeof(struct ieee80211_frame_info) +
 			    sizeof(struct ieee80211_msg_key_notification));
-	if (skb == NULL)
+	if (!skb)
 		return;
 
 	skb_reserve(skb, sizeof(struct ieee80211_frame_info));
@@ -456,7 +456,7 @@ ieee80211_tx_h_fragment(struct ieee80211
 
 	frags = (struct sk_buff **)
 		kmalloc(num_fragm * sizeof(struct sk_buff *), GFP_ATOMIC);
-	if (frags == NULL)
+	if (!frags)
 		goto fail;
 	memset(frags, 0, num_fragm * sizeof(struct sk_buff *));
 
@@ -1105,8 +1105,8 @@ __ieee80211_tx_prepare(struct ieee80211_
 	tx->fragmented = local->fragmentation_threshold <
 		IEEE80211_MAX_FRAG_THRESHOLD && tx->u.tx.unicast &&
 		skb->len + 4 /* FCS */ > local->fragmentation_threshold &&
-		(local->hw->set_frag_threshold == NULL);
-	if (tx->sta == NULL)
+		(!local->hw->set_frag_threshold);
+	if (!tx->sta)
 		control->clear_dst_mask = 1;
 	else if (tx->sta->clear_dst_mask) {
 		control->clear_dst_mask = 1;
@@ -1776,8 +1776,8 @@ struct sk_buff * ieee80211_beacon_get(st
 		dev_put(bdev);
 	}
 
-	if (ap == NULL || sdata->type != IEEE80211_IF_TYPE_AP ||
-	    ap->beacon_head == NULL) {
+	if (!ap || sdata->type != IEEE80211_IF_TYPE_AP ||
+	    !ap->beacon_head) {
 #ifdef CONFIG_D80211_VERBOSE_DEBUG
 		if (net_ratelimit())
 			printk(KERN_DEBUG "no beacon data avail for idx=%d "
@@ -1809,7 +1809,7 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 		extra.endidx = local->num_curr_rates;
 
 		rate = rate_control_get_rate(dev, skb, &extra);
-		if (rate == NULL) {
+		if (!rate) {
 			if (net_ratelimit()) {
 				printk(KERN_DEBUG "%s: ieee80211_beacon_get: no rate "
 				       "found\n", dev->name);
@@ -1854,15 +1854,14 @@ ieee80211_get_buffered_bc(struct net_dev
 		bss = &sdata->u.ap;
 		dev_put(bdev);
 	}
-	if (bss == NULL || sdata->type != IEEE80211_IF_TYPE_AP ||
-	    bss->beacon_head == NULL)
+	if (!bss || sdata->type != IEEE80211_IF_TYPE_AP || !bss->beacon_head)
 		return NULL;
 
 	if (bss->dtim_count != 0)
 		return NULL; /* send buffered bc/mc only after DTIM beacon */
 	skb = skb_dequeue(&bss->ps_bc_buf);
 	memset(control, 0, sizeof(*control));
-	if (skb == NULL)
+	if (!skb)
 		return NULL;
 	local->total_ps_buffered--;
 
@@ -2474,13 +2473,13 @@ ieee80211_rx_h_data(struct ieee80211_txr
 			/* send multicast frames both to higher layers in
 			 * local net stack and back to the wireless media */
 			skb2 = skb_copy(skb, GFP_ATOMIC);
-			if (skb2 == NULL)
+			if (!skb2)
 				printk(KERN_DEBUG "%s: failed to clone "
 				       "multicast frame\n", dev->name);
 		} else {
 			struct sta_info *dsta;
                         dsta = sta_info_get(local, skb->data);
-                        if (dsta && dsta->dev == NULL) {
+			if (dsta && !dsta->dev) {
                                 printk(KERN_DEBUG "Station with null dev "
 				       "structure!\n");
                         } else if (dsta && dsta->dev == dev) {
@@ -2648,7 +2647,7 @@ int ieee80211_radar_status(struct net_de
 	skb = dev_alloc_skb(sizeof(struct ieee80211_frame_info) +
 			    sizeof(struct ieee80211_radar_info));
 
-	if (skb == NULL)
+	if (!skb)
 		return -ENOMEM;
 	skb_reserve(skb, sizeof(struct ieee80211_frame_info));
 
@@ -2672,7 +2671,7 @@ int ieee80211_set_aid_for_sta(struct net
 	skb = dev_alloc_skb(sizeof(struct ieee80211_frame_info) +
 			    sizeof(struct ieee80211_msg_set_aid_for_sta));
 
-        if (skb == NULL)
+	if (!skb)
 		return -ENOMEM;
 	skb_reserve(skb, sizeof(struct ieee80211_frame_info));
 
@@ -2758,7 +2757,7 @@ ieee80211_rx_h_ps_poll(struct ieee80211_
 		return TXRX_CONTINUE;
 
 	skb = skb_dequeue(&rx->sta->tx_filtered);
-	if (skb == NULL) {
+	if (!skb) {
 		skb = skb_dequeue(&rx->sta->ps_tx_buf);
 		if (skb)
 			rx->local->total_ps_buffered--;
@@ -2947,7 +2946,7 @@ ieee80211_rx_h_defragment(struct ieee802
 	if (entry->ccmp) {
 		int i;
 		u8 pn[CCMP_PN_LEN], *rpn;
-		if (rx->key == NULL || rx->key->alg != ALG_CCMP)
+		if (!rx->key || rx->key->alg != ALG_CCMP)
 			return TXRX_DROP;
 		memcpy(pn, entry->last_pn, CCMP_PN_LEN);
 		for (i = CCMP_PN_LEN - 1; i >= 0; i--) {
@@ -3105,10 +3104,9 @@ ieee80211_rx_h_check(struct ieee80211_tx
 			int keyidx = ieee80211_wep_get_keyidx(rx->skb);
 
 			if (keyidx >= 0 && keyidx < NUM_DEFAULT_KEYS &&
-			    (rx->sta == NULL || rx->sta->key == NULL ||
-			     keyidx > 0)) {
+			    (!rx->sta || !rx->sta->key || keyidx > 0))
 				rx->key = rx->sdata->keys[keyidx];
-			}
+
 			if (!rx->key) {
 				if (!rx->u.rx.ra_match)
 					return TXRX_DROP;
@@ -3439,7 +3437,7 @@ static void ieee80211_rx_michael_mic_rep
 	       "failure from " MAC_FMT " to " MAC_FMT " keyidx=%d\n",
 	       dev->name, MAC_ARG(hdr->addr2), MAC_ARG(hdr->addr1), keyidx);
 
-	if (sta == NULL) {
+	if (!sta) {
 		/* Some hardware versions seem to generate incorrect
 		 * Michael MIC reports; ignore them to avoid triggering
 		 * countermeasures. */
@@ -3484,7 +3482,7 @@ static void ieee80211_rx_michael_mic_rep
 	do {
 		union iwreq_data wrqu;
 		char *buf = kmalloc(128, GFP_ATOMIC);
-		if (buf == NULL)
+		if (!buf)
 			break;
 
 		/* TODO: needed parameters: count, key type, TSC */
@@ -3639,12 +3637,11 @@ void __ieee80211_rx(struct net_device *d
 					if (!sdata->promisc)
 						continue;
 					rx.u.rx.ra_match = 0;
-				} else if (sta == NULL) {
+				} else if (!sta)
 					sta = rx.sta =
 						ieee80211_ibss_add_sta(dev, skb, bssid,
 								       hdr->addr2);
 						/* FIXME: call with sdata->dev */
-				}
 				break;
 			case IEEE80211_IF_TYPE_AP:
 				if (!bssid) {
@@ -3675,12 +3672,11 @@ void __ieee80211_rx(struct net_device *d
 
 			if (prev) {
 				skb_new = skb_copy(skb, GFP_ATOMIC);
-				if (skb_new == NULL) {
-					if (net_ratelimit()) {
+				if (!skb_new) {
+					if (net_ratelimit())
 						printk(KERN_DEBUG "%s: failed to copy "
 						       "multicast frame for %s",
 						       dev->name, prev->dev->name);
-					}
 					continue;
 				}
 				rx.skb = skb_new;
@@ -3979,7 +3975,7 @@ static void ieee80211_remove_tx_extra(st
 
 	hdrlen = ieee80211_get_hdrlen_from_skb(skb);
 
-	if (key == NULL)
+	if (!key)
 		goto no_key;
 
 	switch (key->alg) {
@@ -4335,7 +4331,7 @@ struct net_device *ieee80211_alloc_hw(si
 		      NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST) +
 		    priv_data_len;
 	mdev = alloc_netdev(priv_size, "wmaster%d", ether_setup);
-	if (mdev == NULL) {
+	if (!mdev) {
 		ieee80211_dev_free(local);
 		return NULL;
 	}
@@ -4719,9 +4715,9 @@ int ieee80211_rate_control_register(stru
 	struct rate_control_algs *alg;
 
 	alg = kmalloc(sizeof(*alg), GFP_KERNEL);
-	if (alg == NULL) {
+	if (!alg)
 		return -1;
-	}
+
 	memset(alg, 0, sizeof(*alg));
 	alg->next = ieee80211_rate_ctrl_algs;
 	alg->ops = ops;
diff --git a/net/d80211/ieee80211_iface.c b/net/d80211/ieee80211_iface.c
index 12b9d4f..9a9d730 100644
--- a/net/d80211/ieee80211_iface.c
+++ b/net/d80211/ieee80211_iface.c
@@ -49,7 +49,7 @@ int ieee80211_if_add(struct net_device *
 	ASSERT_RTNL();
 	ndev = *new_dev = alloc_netdev(sizeof(struct ieee80211_sub_if_data),
 				       "", ieee80211_if_setup);
-	if (ndev == NULL)
+	if (!ndev)
 		return -ENOMEM;
 
 	ndev->ieee80211_ptr = local;
@@ -58,7 +58,7 @@ int ieee80211_if_add(struct net_device *
 		do {
 			sprintf(ndev->name, "%s.%d", dev->name, i++);
 			tmp_dev = dev_get_by_name(ndev->name);
-			if (tmp_dev == NULL)
+			if (!tmp_dev)
 				break;
 			dev_put(tmp_dev);
 		} while (i < 10000);
@@ -119,7 +119,7 @@ int ieee80211_if_add_mgmt(struct net_dev
 
 	ndev = alloc_netdev(sizeof(struct ieee80211_sub_if_data), "",
 			    ieee80211_if_mgmt_setup);
-	if (ndev == NULL)
+	if (!ndev)
 		return -ENOMEM;
 	ret = dev_alloc_name(ndev, "wmgmt%d");
 	if (ret)
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index b983716..f134f2a 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -172,7 +172,7 @@ static int ieee80211_ioctl_scan(struct n
 {
 	struct ieee80211_local *local = dev->ieee80211_ptr;
 
-	if (local->hw->passive_scan == NULL)
+	if (!local->hw->passive_scan)
 		return -EOPNOTSUPP;
 
 	if ((param->u.scan.now == 1) && (local->scan.in_scan == 1))
@@ -237,7 +237,7 @@ static void ieee80211_send_layer2_update
 	 * bridge devices */
 
 	skb = dev_alloc_skb(sizeof(*msg));
-	if (skb == NULL)
+	if (!skb)
 		return;
 	msg = (struct iapp_layer2_update *) skb_put(skb, sizeof(*msg));
 
@@ -274,9 +274,9 @@ static int ieee80211_ioctl_add_sta(struc
 
 	sta = sta_info_get(local, param->sta_addr);
 
-        if (sta == NULL) {
+	if (!sta) {
 		sta = sta_info_add(local, dev, param->sta_addr);
-		if (sta == NULL)
+		if (!sta)
 			return -ENOMEM;
         }
 
@@ -324,7 +324,7 @@ static int ieee80211_ioctl_add_sta(struc
 	else
 		sta->flags &= ~WLAN_STA_WDS;
 
-	if (add_key_entry && sta->key == NULL && sdata->default_key == NULL &&
+	if (add_key_entry && !sta->key && !sdata->default_key &&
 	    local->hw->set_key) {
 		struct ieee80211_key_conf conf;
 		/* Add key cache entry with NULL key type because this may used
@@ -564,7 +564,7 @@ static int ieee80211_set_encryption(stru
 		}
 
 		sta = sta_info_get(local, sta_addr);
-		if (sta == NULL) {
+		if (!sta) {
 			if (err)
 				*err = HOSTAP_CRYPT_ERR_UNKNOWN_ADDR;
 #ifdef CONFIG_D80211_VERBOSE_DEBUG
@@ -672,7 +672,7 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 			 * packet. */
 			key->u.ccmp.tfm = ieee80211_aes_key_setup_encrypt(
 				key->key);
-			if (key->u.ccmp.tfm == NULL) {
+			if (!key->u.ccmp.tfm) {
 				ret = -ENOMEM;
 				goto err_free;
 			}
@@ -703,7 +703,7 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 		}
 	}
 
-	if (set_tx_key || (sta == NULL && sdata->default_key == NULL && key)) {
+	if (set_tx_key || (!sta && !sdata->default_key && key)) {
 		sdata->default_key = key;
 		if (ieee80211_key_sysfs_add_default(sdata))
 			printk(KERN_WARNING "%s: cannot create symlink to "
@@ -819,7 +819,7 @@ static int ieee80211_ioctl_get_encryptio
 			key = &sdata->keys[param->u.crypt.idx];
 	} else {
 		sta = sta_info_get(local, param->sta_addr);
-		if (sta == NULL) {
+		if (!sta) {
 			param->u.crypt.err = HOSTAP_CRYPT_ERR_UNKNOWN_ADDR;
 			return -EINVAL;
 		}
@@ -828,7 +828,7 @@ static int ieee80211_ioctl_get_encryptio
 	}
 
 	memset(param->u.crypt.seq_counter, 0, HOSTAP_SEQ_COUNTER_SIZE);
-	if (*key == NULL) {
+	if (!*key) {
 		memcpy(param->u.crypt.alg, "none", 5);
 		param->u.crypt.key_len = 0;
 		param->u.crypt.idx = 0xff;
@@ -918,7 +918,7 @@ static int ieee80211_ioctl_wpa_trigger(s
 	}
 
 	sta = sta_info_get(local, param->sta_addr);
-	if (sta == NULL) {
+	if (!sta) {
 		printk(KERN_DEBUG "%s: wpa_trigger - unknown addr\n",
 		       dev->name);
 		return -EINVAL;
@@ -1112,7 +1112,7 @@ static int ieee80211_ioctl_update_if(str
 			}
 		}
 
-		if (wds_dev == NULL || sdata->type != IEEE80211_IF_TYPE_WDS)
+		if (!wds_dev || sdata->type != IEEE80211_IF_TYPE_WDS)
 			return -ENODEV;
 
 		return ieee80211_if_update_wds(wds_dev, wds->remote_addr);
@@ -1250,7 +1250,7 @@ static int ieee80211_set_gen_ie(struct n
 	if (sdata->type == IEEE80211_IF_TYPE_AP) {
 		kfree(sdata->u.ap.generic_elem);
 		sdata->u.ap.generic_elem = kmalloc(len, GFP_KERNEL);
-		if (sdata->u.ap.generic_elem == NULL)
+		if (!sdata->u.ap.generic_elem)
 			return -ENOMEM;
 		memcpy(sdata->u.ap.generic_elem, ie, len);
 		sdata->u.ap.generic_elem_len = len;
@@ -1418,7 +1418,7 @@ static int ieee80211_ioctl_priv_hostapd(
 	}
 
 	param = (struct prism2_hostapd_param *) kmalloc(p->length, GFP_KERNEL);
-	if (param == NULL)
+	if (!param)
 		return -ENOMEM;
 
 	if (copy_from_user(param, p->pointer, p->length)) {
@@ -2285,7 +2285,7 @@ static void ieee80211_key_enable_hwaccel
 	struct ieee80211_key_conf *keyconf;
 	u8 addr[ETH_ALEN];
 
-	if (key == NULL || key->alg != ALG_WEP || !key->force_sw_encrypt ||
+	if (!key || key->alg != ALG_WEP || !key->force_sw_encrypt ||
 	    local->hw->device_hides_wep)
 		return;
 
@@ -2306,7 +2306,7 @@ static void ieee80211_key_disable_hwacce
 	struct ieee80211_key_conf *keyconf;
 	u8 addr[ETH_ALEN];
 
-	if (key == NULL || key->alg != ALG_WEP || key->force_sw_encrypt ||
+	if (!key || key->alg != ALG_WEP || key->force_sw_encrypt ||
 	    local->hw->device_hides_wep)
 		return;
 
@@ -2532,7 +2532,7 @@ static int ieee80211_ioctl_prism2_param(
 	case PRISM2_PARAM_KEY_INDEX:
 		if (value < 0 || value >= NUM_DEFAULT_KEYS)
 			ret = -EINVAL;
-		else if (sdata->keys[value] == NULL)
+		else if (!sdata->keys[value])
 			ret = -ENOENT;
 		else
 			sdata->default_key = sdata->keys[value];
@@ -2594,7 +2594,7 @@ static int ieee80211_ioctl_prism2_param(
 		break;
 	case PRISM2_PARAM_MGMT_IF:
 		if (value == 1) {
-			if (local->apdev == NULL)
+			if (!local->apdev)
 				ret = ieee80211_if_add_mgmt(local->mdev);
 		} else if (value == 0) {
 			if (local->apdev)
@@ -2725,7 +2725,7 @@ static int ieee80211_ioctl_get_prism2_pa
 		break;
 
 	case PRISM2_PARAM_KEY_INDEX:
-		if (sdata->default_key == NULL)
+		if (!sdata->default_key)
 			ret = -ENOENT;
 		else if (sdata->default_key == sdata->keys[0])
 			*param = 0;
@@ -2863,7 +2863,7 @@ static int ieee80211_ioctl_siwencode(str
 	idx = erq->flags & IW_ENCODE_INDEX;
 	if (idx < 1 || idx > 4) {
 		idx = -1;
-		if (sdata->default_key == NULL)
+		if (!sdata->default_key)
 			idx = 0;
 		else for (i = 0; i < NUM_DEFAULT_KEYS; i++) {
 			if (sdata->default_key == sdata->keys[i])
@@ -2885,7 +2885,7 @@ static int ieee80211_ioctl_siwencode(str
 	return ieee80211_set_encryption(
 		dev, bcaddr,
 		idx, erq->length == 0 ? ALG_NONE : ALG_WEP,
-		sdata->default_key == NULL,
+		!sdata->default_key,
 		NULL, keybuf, erq->length);
 
 	return 0;
@@ -2904,7 +2904,7 @@ static int ieee80211_ioctl_giwencode(str
 	idx = erq->flags & IW_ENCODE_INDEX;
 	if (idx < 1 || idx > 4) {
 		idx = -1;
-		if (sdata->default_key == NULL)
+		if (!sdata->default_key)
 			idx = 0;
 		else for (i = 0; i < NUM_DEFAULT_KEYS; i++) {
 			if (sdata->default_key == sdata->keys[i])
@@ -2918,7 +2918,7 @@ static int ieee80211_ioctl_giwencode(str
 
 	erq->flags = idx + 1;
 
-	if (sdata->keys[idx] == NULL) {
+	if (!sdata->keys[idx]) {
 		erq->length = 0;
 		erq->flags |= IW_ENCODE_DISABLED;
 		return 0;
@@ -3050,7 +3050,7 @@ static int ieee80211_ioctl_siwencodeext(
 	idx = erq->flags & IW_ENCODE_INDEX;
 	if (idx < 1 || idx > 4) {
 		idx = -1;
-		if (sdata->default_key == NULL)
+		if (!sdata->default_key)
 			idx = 0;
 		else for (i = 0; i < NUM_DEFAULT_KEYS; i++) {
 			if (sdata->default_key == sdata->keys[i])
diff --git a/net/d80211/ieee80211_scan.c b/net/d80211/ieee80211_scan.c
index 445509e..539b8a2 100644
--- a/net/d80211/ieee80211_scan.c
+++ b/net/d80211/ieee80211_scan.c
@@ -117,7 +117,7 @@ static void ieee80211_scan_start(struct 
 	struct ieee80211_channel *chan = NULL;
 	int ret;
 
-	if (local->hw->passive_scan == 0) {
+	if (!local->hw->passive_scan) {
 		printk(KERN_DEBUG "%s: Scan handler called, yet the hardware "
 		       "does not support passive scanning. Disabled.\n",
 		       dev->name);
@@ -136,7 +136,7 @@ static void ieee80211_scan_start(struct 
 		return;
 	}
 
-	if (local->scan.skb == NULL) {
+	if (!local->scan.skb) {
 		printk(KERN_DEBUG "%s: Scan start called even though scan.skb "
 		       "is not set\n", dev->name);
 	}
@@ -214,7 +214,7 @@ static void ieee80211_scan_stop(struct n
 	struct ieee80211_channel *chan;
 	int wait;
 
-	if (local->hw->passive_scan == NULL)
+	if (!local->hw->passive_scan)
 		return;
 
 	if (local->scan.mode_idx >= local->hw->num_modes) {
@@ -313,7 +313,7 @@ void ieee80211_init_scan(struct net_devi
 	/* Create a CTS from for broadcasting before
 	 * the low level changes channels */
 	local->scan.skb = alloc_skb(len, GFP_KERNEL);
-	if (local->scan.skb == NULL) {
+	if (!local->scan.skb) {
 		printk(KERN_WARNING "%s: Failed to allocate CTS packet for "
 		       "passive scan\n", dev->name);
 		return;
@@ -344,7 +344,7 @@ void ieee80211_stop_scan(struct net_devi
 {
 	struct ieee80211_local *local = dev->ieee80211_ptr;
 
-	if (local->hw->passive_scan != 0) {
+	if (local->hw->passive_scan) {
 		del_timer_sync(&local->scan.timer);
 		dev_kfree_skb(local->scan.skb);
 		local->scan.skb = NULL;
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index 8caf352..645529f 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -252,7 +252,7 @@ static void ieee80211_sta_wmm_params(str
 
 	memset(&params, 0, sizeof(params));
 
-	if (local->hw->conf_tx == NULL)
+	if (!local->hw->conf_tx)
 		return;
 
 	local->wmm_acm = 0;
@@ -316,12 +316,12 @@ static void ieee80211_sta_send_associnfo
 	int i;
 	union iwreq_data wrqu;
 
-	if (ifsta->assocreq_ies == NULL && ifsta->assocresp_ies == NULL)
+	if (!ifsta->assocreq_ies && !ifsta->assocresp_ies)
 		return;
 
 	buf = kmalloc(50 + 2 * (ifsta->assocreq_ies_len +
 				ifsta->assocresp_ies_len), GFP_ATOMIC);
-	if (buf == NULL)
+	if (!buf)
 		return;
 
 	len = sprintf(buf, "ASSOCINFO(");
@@ -418,7 +418,7 @@ static void ieee80211_send_auth(struct n
 	struct ieee80211_mgmt *mgmt;
 
 	skb = dev_alloc_skb(sizeof(*mgmt) + 6 + extra_len);
-	if (skb == NULL) {
+	if (!skb) {
 		printk(KERN_DEBUG "%s: failed to allocate buffer for auth "
 		       "frame\n", dev->name);
 		return;
@@ -479,7 +479,7 @@ static void ieee80211_send_assoc(struct 
 
 	skb = dev_alloc_skb(sizeof(*mgmt) + 200 + ifsta->extra_ie_len +
 			    ifsta->ssid_len);
-	if (skb == NULL) {
+	if (!skb) {
 		printk(KERN_DEBUG "%s: failed to allocate buffer for assoc "
 		       "frame\n", dev->name);
 		return;
@@ -588,7 +588,7 @@ static void ieee80211_send_deauth(struct
 	struct ieee80211_mgmt *mgmt;
 
 	skb = dev_alloc_skb(sizeof(*mgmt));
-	if (skb == NULL) {
+	if (!skb) {
 		printk(KERN_DEBUG "%s: failed to allocate buffer for deauth "
 		       "frame\n", dev->name);
 		return;
@@ -615,7 +615,7 @@ static void ieee80211_send_disassoc(stru
 	struct ieee80211_mgmt *mgmt;
 
 	skb = dev_alloc_skb(sizeof(*mgmt));
-	if (skb == NULL) {
+	if (!skb) {
 		printk(KERN_DEBUG "%s: failed to allocate buffer for disassoc "
 		       "frame\n", dev->name);
 		return;
@@ -641,12 +641,12 @@ static int ieee80211_privacy_mismatch(st
 	struct ieee80211_sta_bss *bss;
 	int res = 0;
 
-	if (ifsta == NULL || ifsta->mixed_cell ||
+	if (!ifsta || ifsta->mixed_cell ||
 	    ifsta->key_mgmt != IEEE80211_KEY_MGMT_NONE)
 		return 0;
 
 	bss = ieee80211_rx_bss_get(dev, ifsta->bssid);
-	if (bss == NULL)
+	if (!bss)
 		return 0;
 
 	if (ieee80211_sta_wep_configured(dev) !=
@@ -700,7 +700,7 @@ static void ieee80211_associated(struct 
 	ifsta->state = IEEE80211_ASSOCIATED;
 
 	sta = sta_info_get(local, ifsta->bssid);
-	if (sta == NULL) {
+	if (!sta) {
 		printk(KERN_DEBUG "%s: No STA entry for own AP " MAC_FMT "\n",
 		       dev->name, MAC_ARG(ifsta->bssid));
 		disassoc = 1;
@@ -756,7 +756,7 @@ static void ieee80211_send_probe_req(str
 	int i;
 
 	skb = dev_alloc_skb(sizeof(*mgmt) + 200);
-	if (skb == NULL) {
+	if (!skb) {
 		printk(KERN_DEBUG "%s: failed to allocate buffer for probe "
 		       "request\n", dev->name);
 		return;
@@ -811,7 +811,7 @@ static void ieee80211_send_probe_req(str
 static int ieee80211_sta_wep_configured(struct net_device *dev)
 {
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-	if (sdata == NULL || sdata->default_key == NULL ||
+	if (!sdata || !sdata->default_key ||
 	    sdata->default_key->alg != ALG_WEP)
 		return 0;
 	return 1;
@@ -844,7 +844,7 @@ static void ieee80211_auth_challenge(str
 		       dev->name);
 		return;
 	}
-	if (elems.challenge == NULL) {
+	if (!elems.challenge) {
 		printk(KERN_DEBUG "%s: no challenge IE in shared key auth "
 		       "frame\n", dev->name);
 		return;
@@ -1139,7 +1139,7 @@ static void ieee80211_rx_mgmt_assoc_resp
 		return;
 	}
 
-	if (elems.supp_rates == NULL) {
+	if (!elems.supp_rates) {
 		printk(KERN_DEBUG "%s: no SuppRates element in AssocResp\n",
 		       dev->name);
 		return;
@@ -1159,9 +1159,9 @@ static void ieee80211_rx_mgmt_assoc_resp
 
 	/* Add STA entry for the AP */
 	sta = sta_info_get(local, ifsta->bssid);
-	if (sta == NULL) {
+	if (!sta) {
 		sta = sta_info_add(local, dev, ifsta->bssid);
-		if (sta == NULL) {
+		if (!sta) {
 			printk(KERN_DEBUG "%s: failed to add STA entry for the"
 			       " AP\n", dev->name);
 			return;
@@ -1225,12 +1225,11 @@ static void __ieee80211_rx_bss_hash_del(
 	b = local->sta_bss_hash[STA_HASH(bss->bssid)];
 	while (b) {
 		if (b == bss) {
-			if (prev == NULL) {
+			if (!prev)
 				local->sta_bss_hash[STA_HASH(bss->bssid)] =
 					bss->hnext;
-			} else {
+			else
 				prev->hnext = bss->hnext;
-			}
 			break;
 		}
 		prev = b;
@@ -1246,7 +1245,7 @@ ieee80211_rx_bss_add(struct net_device *
 	struct ieee80211_sta_bss *bss;
 
 	bss = kmalloc(sizeof(*bss), GFP_ATOMIC);
-	if (bss == NULL)
+	if (!bss)
 		return NULL;
 	memset(bss, 0, sizeof(*bss));
 	atomic_inc(&bss->users);
@@ -1441,7 +1440,7 @@ #endif /* IEEE80211_IBSS_DEBUG */
 		sta_info_put(sta);
 	}
 
-	if (elems.ssid == NULL)
+	if (!elems.ssid)
 		return;
 
 	if (elems.ds_params && elems.ds_params_len == 1)
@@ -1450,9 +1449,9 @@ #endif /* IEEE80211_IBSS_DEBUG */
 		channel = rx_status->channel;
 
 	bss = ieee80211_rx_bss_get(dev, mgmt->bssid);
-	if (bss == NULL) {
+	if (!bss) {
 		bss = ieee80211_rx_bss_add(dev, mgmt->bssid);
-		if (bss == NULL)
+		if (!bss)
 			return;
 	} else {
 #if 0
@@ -1495,7 +1494,7 @@ #endif
 	}
 
 	if (elems.wpa &&
-	    (bss->wpa_ie == NULL || bss->wpa_ie_len != elems.wpa_len ||
+	    (!bss->wpa_ie || bss->wpa_ie_len != elems.wpa_len ||
 	     memcmp(bss->wpa_ie, elems.wpa, elems.wpa_len))) {
 		kfree(bss->wpa_ie);
 		bss->wpa_ie = kmalloc(elems.wpa_len + 2, GFP_ATOMIC);
@@ -1511,7 +1510,7 @@ #endif
 	}
 
 	if (elems.rsn &&
-	    (bss->rsn_ie == NULL || bss->rsn_ie_len != elems.rsn_len ||
+	    (!bss->rsn_ie || bss->rsn_ie_len != elems.rsn_len ||
 	     memcmp(bss->rsn_ie, elems.rsn, elems.rsn_len))) {
 		kfree(bss->rsn_ie);
 		bss->rsn_ie = kmalloc(elems.rsn_len + 2, GFP_ATOMIC);
@@ -1527,7 +1526,7 @@ #endif
 	}
 
 	if (elems.wmm_param &&
-	    (bss->wmm_ie == NULL || bss->wmm_ie_len != elems.wmm_param_len ||
+	    (!bss->wmm_ie || bss->wmm_ie_len != elems.wmm_param_len ||
 	     memcmp(bss->wmm_ie, elems.wmm_param, elems.wmm_param_len))) {
 		kfree(bss->wmm_ie);
 		bss->wmm_ie = kmalloc(elems.wmm_param_len + 2, GFP_ATOMIC);
@@ -1649,7 +1648,7 @@ static void ieee80211_rx_mgmt_probe_req(
 
 	if (sdata->type != IEEE80211_IF_TYPE_IBSS ||
 	    ifsta->state != IEEE80211_IBSS_JOINED ||
-	    len < 24 + 2 || ifsta->probe_resp == NULL)
+	    len < 24 + 2 || !ifsta->probe_resp)
 		return;
 
 	if (local->hw->tx_last_beacon)
@@ -1691,7 +1690,7 @@ #endif /* IEEE80211_IBSS_DEBUG */
 
 	/* Reply with ProbeResp */
 	skb = skb_copy(ifsta->probe_resp, GFP_ATOMIC);
-	if (skb == NULL)
+	if (!skb)
 		return;
 
 	resp = (struct ieee80211_mgmt *) skb->data;
@@ -2012,7 +2011,7 @@ static int ieee80211_sta_join_ibss(struc
 	/* Set beacon template based on scan results */
 	skb = dev_alloc_skb(400);
 	do {
-		if (skb == NULL)
+		if (!skb)
 			break;
 
 		mgmt = (struct ieee80211_mgmt *)
@@ -2065,7 +2064,7 @@ static int ieee80211_sta_join_ibss(struc
 		memset(&extra, 0, sizeof(extra));
 		extra.endidx = local->num_curr_rates;
 		rate = rate_control_get_rate(dev, skb, &extra);
-		if (rate == NULL) {
+		if (!rate) {
 			printk(KERN_DEBUG "%s: Failed to determine TX rate "
 			       "for IBSS beacon\n", dev->name);
 			break;
@@ -2152,7 +2151,7 @@ #endif
 	       dev->name, MAC_ARG(bssid));
 
 	bss = ieee80211_rx_bss_add(dev, bssid);
-	if (bss == NULL)
+	if (!bss)
 		return -ENOMEM;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
@@ -2593,7 +2592,7 @@ ieee80211_sta_scan_result(struct net_dev
 		return current_ev;
 
 	if (local->scan_flags & IEEE80211_SCAN_WPA_ONLY &&
-	    bss->wpa_ie == NULL && bss->rsn_ie == NULL)
+	    !bss->wpa_ie && !bss->rsn_ie)
 		return current_ev;
 
 	if (local->scan_flags & IEEE80211_SCAN_MATCH_SSID &&
@@ -2700,7 +2699,7 @@ ieee80211_sta_scan_result(struct net_dev
 			break;
 
 		buf = kmalloc(100, GFP_ATOMIC);
-		if (buf == NULL)
+		if (!buf)
 			break;
 
 		memset(&iwe, 0, sizeof(iwe));
@@ -2772,7 +2771,7 @@ int ieee80211_sta_set_extra_ie(struct ne
 		return 0;
 	}
 	ifsta->extra_ie = kmalloc(len, GFP_KERNEL);
-	if (ifsta->extra_ie == NULL) {
+	if (!ifsta->extra_ie) {
 		ifsta->extra_ie_len = 0;
 		return -ENOMEM;
 	}
@@ -2816,16 +2815,15 @@ struct sta_info * ieee80211_ibss_add_sta
 	}
 	spin_unlock_bh(&local->sub_if_lock);
 
-	if (sta_dev == NULL)
+	if (!sta_dev)
 		return NULL;
 
 	printk(KERN_DEBUG "%s: Adding new IBSS station " MAC_FMT " (dev=%s)\n",
 	       dev->name, MAC_ARG(addr), sta_dev->name);
 
 	sta = sta_info_add(local, dev, addr);
-	if (sta == NULL) {
+	if (!sta)
 		return NULL;
-	}
 
 	sta->dev = sta_dev;
 	sta->supp_rates = sdata->u.sta.supp_rates_bits;
diff --git a/net/d80211/rate_control.c b/net/d80211/rate_control.c
index 1d40e88..4f1ffbd 100644
--- a/net/d80211/rate_control.c
+++ b/net/d80211/rate_control.c
@@ -288,9 +288,9 @@ static void * rate_control_simple_alloc(
 	struct global_rate_control *rctrl;
 
 	rctrl = kmalloc(sizeof(*rctrl), GFP_ATOMIC);
-	if (rctrl == NULL) {
+	if (!rctrl)
 		return NULL;
-	}
+
 	memset(rctrl, 0, sizeof(*rctrl));
 	return rctrl;
 }
@@ -313,9 +313,9 @@ static void * rate_control_simple_alloc_
 	struct sta_rate_control *rctrl;
 
 	rctrl = kmalloc(sizeof(*rctrl), GFP_ATOMIC);
-	if (rctrl == NULL) {
+	if (!rctrl)
 		return NULL;
-	}
+
 	memset(rctrl, 0, sizeof(*rctrl));
 	return rctrl;
 }
diff --git a/net/d80211/rate_control.h b/net/d80211/rate_control.h
index d8bdfed..08a8add 100644
--- a/net/d80211/rate_control.h
+++ b/net/d80211/rate_control.h
@@ -101,7 +101,7 @@ static inline void * rate_control_alloc(
 
 static inline void rate_control_free(struct ieee80211_local *local)
 {
-	if (local->rate_ctrl == NULL || local->rate_ctrl_priv == NULL)
+	if (!local->rate_ctrl || !local->rate_ctrl_priv)
 		return;
 	local->rate_ctrl->free(local->rate_ctrl_priv);
 	local->rate_ctrl_priv = NULL;
diff --git a/net/d80211/sta_info.c b/net/d80211/sta_info.c
index 7f5febe..d8f044e 100644
--- a/net/d80211/sta_info.c
+++ b/net/d80211/sta_info.c
@@ -38,17 +38,16 @@ static void sta_info_hash_del(struct iee
 	struct sta_info *s;
 
 	s = local->sta_hash[STA_HASH(sta->addr)];
-	if (s == NULL)
+	if (!s)
 		return;
 	if (memcmp(s->addr, sta->addr, ETH_ALEN) == 0) {
 		local->sta_hash[STA_HASH(sta->addr)] = s->hnext;
 		return;
 	}
 
-	while (s->hnext != NULL &&
-	       memcmp(s->hnext->addr, sta->addr, ETH_ALEN) != 0)
+	while (s->hnext && memcmp(s->hnext->addr, sta->addr, ETH_ALEN) != 0)
 		s = s->hnext;
-	if (s->hnext != NULL)
+	if (s->hnext)
 		s->hnext = s->hnext->hnext;
 	else
 		printk(KERN_ERR "%s: could not remove STA " MAC_FMT " from "
@@ -147,7 +146,7 @@ struct sta_info * sta_info_add(struct ie
 	kobject_init(&sta->kobj);
 
 	sta->rate_ctrl_priv = rate_control_alloc_sta(local);
-	if (sta->rate_ctrl_priv == NULL) {
+	if (!sta->rate_ctrl_priv) {
 		kobject_put(&sta->kobj);
 		kfree(sta);
 		return NULL;
@@ -429,7 +428,7 @@ void sta_info_remove_aid_ptr(struct sta_
 	sdata->bss->sta_aid[sta->aid - 1] = NULL;
 	if (sta->aid == sdata->bss->max_aid) {
 		while (sdata->bss->max_aid > 0 &&
-		       sdata->bss->sta_aid[sdata->bss->max_aid - 1] == NULL)
+		       !sdata->bss->sta_aid[sdata->bss->max_aid - 1])
 			sdata->bss->max_aid--;
 	}
 }
@@ -448,7 +447,7 @@ void sta_info_flush(struct ieee80211_loc
 
 	list_for_each_safe(ptr, n, &local->sta_list) {
 		struct sta_info *sta = list_entry(ptr, struct sta_info, list);
-		if (dev == NULL || dev == sta->dev)
+		if (!dev || dev == sta->dev)
 			sta_info_free(sta, 1);
 	}
 	spin_unlock_bh(&local->sta_lock);
diff --git a/net/d80211/wep.c b/net/d80211/wep.c
index 0473f3c..097a7e9 100644
--- a/net/d80211/wep.c
+++ b/net/d80211/wep.c
@@ -61,7 +61,7 @@ void ieee80211_wep_get_iv(struct ieee802
 	if (ieee80211_wep_weak_iv(local->wep_iv, key->keylen))
 		local->wep_iv += 0x0100;
 
-	if (iv == NULL)
+	if (!iv)
 		return;
 
 	*iv++ = (local->wep_iv >> 16) & 0xff;
@@ -149,16 +149,16 @@ int ieee80211_wep_encrypt(struct ieee802
 	u8 *rc4key, *iv;
 	size_t len;
 
-	if (key == NULL || key->alg != ALG_WEP)
+	if (!key || key->alg != ALG_WEP)
 		return -1;
 
 	klen = 3 + key->keylen;
 	rc4key = kmalloc(klen, GFP_ATOMIC);
-	if (rc4key == NULL)
+	if (!rc4key)
 		return -1;
 
 	iv = ieee80211_wep_add_iv(local, skb, key);
-	if (iv == NULL) {
+	if (!iv) {
 		kfree(rc4key);
 		return -1;
 	}
@@ -239,13 +239,13 @@ int ieee80211_wep_decrypt(struct ieee802
 
 	keyidx = skb->data[hdrlen + 3] >> 6;
 
-	if (key == NULL || keyidx != key->keyidx || key->alg != ALG_WEP)
+	if (!key || keyidx != key->keyidx || key->alg != ALG_WEP)
 		return -1;
 
 	klen = 3 + key->keylen;
 
 	rc4key = kmalloc(klen, GFP_ATOMIC);
-	if (rc4key == NULL)
+	if (!rc4key)
 		return -1;
 
 	/* Prepend 24-bit IV to RC4 key */
diff --git a/net/d80211/wme.c b/net/d80211/wme.c
index fc2a113..8f1862c 100644
--- a/net/d80211/wme.c
+++ b/net/d80211/wme.c
@@ -470,7 +470,7 @@ static int wme_classop_graft(struct Qdis
 	if (queue >= hw->queues)
 		return -EINVAL;
 
-	if (new == NULL)
+	if (!new)
 		new = &noop_qdisc;
 
 	sch_tree_lock(qd);
@@ -660,7 +660,7 @@ void ieee80211_install_qdisc(struct net_
 	struct Qdisc *qdisc;
 
 	qdisc = qdisc_create_dflt(dev, &wme_qdisc_ops);
-	if (qdisc == NULL) {
+	if (!qdisc) {
 		printk(KERN_ERR "%s: qdisc installation failed\n", dev->name);
 		return;
 	}
diff --git a/net/d80211/wpa.c b/net/d80211/wpa.c
index fe5861f..5270b8c 100644
--- a/net/d80211/wpa.c
+++ b/net/d80211/wpa.c
@@ -260,7 +260,7 @@ #endif /* CONFIG_HOSTAPD_WPA_TESTING */
 			struct ieee80211_hdr *hdr;
 			union iwreq_data wrqu;
 			char *buf = kmalloc(128, GFP_ATOMIC);
-			if (buf == NULL)
+			if (!buf)
 				break;
 
 			/* TODO: needed parameters: count, key type, TSC */
-- 
1.3.0

