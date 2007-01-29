From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 4/6] d80211: don't display name of invisible network device
Date: Mon, 29 Jan 2007 18:48:09 +0100 (CET)
Message-ID: <20070129174809.6401B48499@silver.suse.cz>
References: <20070129184707.885764375.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:41733 "EHLO silver.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752524AbXA2Rr6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jan 2007 12:47:58 -0500
In-Reply-To: <20070129184707.885764375.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Invisible master interface does not have meaningful name. Display the wiphy
identifier in kernel messages instead.

Also, remove the allocation of master interface name as it is purposeless
now.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---
 net/d80211/ieee80211.c      |   98 +++++++++++++++++++++-----------------------
 net/d80211/ieee80211_scan.c |   28 ++++++------
 net/d80211/sta_info.c       |   12 ++---
 net/d80211/wme.c            |    8 ++-
 4 files changed, 74 insertions(+), 72 deletions(-)

--- dscape.orig/net/d80211/ieee80211.c
+++ dscape/net/d80211/ieee80211.c
@@ -284,14 +284,14 @@ int ieee80211_get_hdrlen_from_skb(struct
 EXPORT_SYMBOL(ieee80211_get_hdrlen_from_skb);
 
 #ifdef CONFIG_D80211_LOWTX_FRAME_DUMP
-static void ieee80211_dump_frame(const char *ifname, const char *title,
+static void ieee80211_dump_frame(int hwindex, const char *title,
 				 struct sk_buff *skb)
 {
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
 	u16 fc;
 	int hdrlen;
 
-	printk(KERN_DEBUG "%s: %s (len=%d)", ifname, title, skb->len);
+	printk(KERN_DEBUG "wiphy%d: %s (len=%d)", hwindex, title, skb->len);
 	if (skb->len < 4) {
 		printk("\n");
 		return;
@@ -315,7 +315,7 @@ static void ieee80211_dump_frame(const c
 	printk("\n");
 }
 #else /* CONFIG_D80211_LOWTX_FRAME_DUMP */
-static inline void ieee80211_dump_frame(const char *ifname, const char *title,
+static inline void ieee80211_dump_frame(int hwindex, const char *title,
 					struct sk_buff *skb)
 {
 }
@@ -945,8 +945,8 @@ static void purge_old_ps_buffers(struct 
 	spin_unlock_bh(&local->sta_lock);
 
 	local->total_ps_buffered = total;
-	printk(KERN_DEBUG "%s: PS buffers full - purged %d frames\n",
-	       local->mdev->name, purged);
+	printk(KERN_DEBUG "wiphy%d: PS buffers full - purged %d frames\n",
+	       local->hw.index, purged);
 }
 
 
@@ -1147,7 +1147,7 @@ static int __ieee80211_tx(struct ieee802
 	int ret, i;
 
 	if (skb) {
-		ieee80211_dump_frame(local->mdev->name, "TX to low-level driver", skb);
+		ieee80211_dump_frame(local->hw.index, "TX to low-level driver", skb);
 		ret = local->ops->tx(local_to_hw(local), skb, control);
 		if (ret)
 			return IEEE80211_TX_AGAIN;
@@ -1174,7 +1174,7 @@ static int __ieee80211_tx(struct ieee802
 						~IEEE80211_TXCTL_RATE_CTRL_PROBE;
 			}
 
-			ieee80211_dump_frame(local->mdev->name,
+			ieee80211_dump_frame(local->hw.index,
 					     "TX to low-level driver", skb);
 			ret = local->ops->tx(local_to_hw(local),
 					    tx->u.tx.extra_frag[i],
@@ -1375,8 +1375,10 @@ static int ieee80211_master_start_xmit(s
 	}
 	if (unlikely(!odev)) {
 #ifdef CONFIG_D80211_VERBOSE_DEBUG
-		printk(KERN_DEBUG "%s: Discarded packet with nonexistent "
-		       "originating device\n", dev->name);
+		struct ieee80211_local *local = dev->ieee80211_ptr;
+
+		printk(KERN_DEBUG "wiphy%d: Discarded packet with nonexistent "
+		       "originating device\n", local->hw.index);
 #endif
 		dev_kfree_skb(skb);
 		return 0;
@@ -1764,8 +1766,8 @@ struct sk_buff * ieee80211_beacon_get(st
 		rate = rate_control_get_rate(local, local->mdev, skb, &extra);
 		if (!rate) {
 			if (net_ratelimit()) {
-				printk(KERN_DEBUG "%s: ieee80211_beacon_get: no rate "
-				       "found\n", local->mdev->name);
+				printk(KERN_DEBUG "wiphy%d: ieee80211_beacon_get: no rate "
+				       "found\n", local->hw.index);
 			}
 			dev_kfree_skb(skb);
 			return NULL;
@@ -1977,10 +1979,11 @@ static void ieee80211_tx_timeout(struct 
 {
 	struct ieee80211_local *local = dev->ieee80211_ptr;
 
-	printk(KERN_WARNING "%s: resetting interface.\n", dev->name);
+	printk(KERN_WARNING "wiphy%d: resetting interface.\n", local->hw.index);
 
 	if (local->ops->reset(local_to_hw(local)))
-		printk(KERN_ERR "%s: failed to reset interface.\n", dev->name);
+		printk(KERN_ERR "wiphy%d: failed to reset interface.\n",
+		       local->hw.index);
 	else
 		netif_wake_queue(dev);
 }
@@ -3493,24 +3496,25 @@ static void ieee80211_rx_michael_mic_rep
 
 	/* TODO: verify that this is not triggered by fragmented
 	 * frames (hw does not verify MIC for them). */
-	printk(KERN_DEBUG "%s: TKIP hwaccel reported Michael MIC "
+	printk(KERN_DEBUG "wiphy%d: TKIP hwaccel reported Michael MIC "
 	       "failure from " MAC_FMT " to " MAC_FMT " keyidx=%d\n",
-	       dev->name, MAC_ARG(hdr->addr2), MAC_ARG(hdr->addr1), keyidx);
+	       rx->local->hw.index, MAC_ARG(hdr->addr2), MAC_ARG(hdr->addr1),
+	       keyidx);
 
 	if (!sta) {
 		/* Some hardware versions seem to generate incorrect
 		 * Michael MIC reports; ignore them to avoid triggering
 		 * countermeasures. */
-		printk(KERN_DEBUG "%s: ignored spurious Michael MIC "
+		printk(KERN_DEBUG "wiphy%d: ignored spurious Michael MIC "
 		       "error for unknown address " MAC_FMT "\n",
-		       dev->name, MAC_ARG(hdr->addr2));
+		       rx->local->hw.index, MAC_ARG(hdr->addr2));
 		goto ignore;
 	}
 
 	if (!(rx->fc & IEEE80211_FCTL_PROTECTED)) {
-		printk(KERN_DEBUG "%s: ignored spurious Michael MIC "
+		printk(KERN_DEBUG "wiphy%d: ignored spurious Michael MIC "
 		       "error for a frame with no ISWEP flag (src "
-		       MAC_FMT ")\n", dev->name, MAC_ARG(hdr->addr2));
+		       MAC_FMT ")\n", rx->local->hw.index, MAC_ARG(hdr->addr2));
 		goto ignore;
 	}
 
@@ -3522,9 +3526,10 @@ static void ieee80211_rx_michael_mic_rep
 		 * for group keys and only the AP is sending real multicast
 		 * frames in BSS. */
 		if (keyidx) {
-			printk(KERN_DEBUG "%s: ignored Michael MIC error for "
+			printk(KERN_DEBUG "wiphy%d: ignored Michael MIC error for "
 			       "a frame with non-zero keyidx (%d) (src " MAC_FMT
-			       ")\n", dev->name, keyidx, MAC_ARG(hdr->addr2));
+			       ")\n", rx->local->hw.index, keyidx,
+			       MAC_ARG(hdr->addr2));
 			goto ignore;
 		}
 	}
@@ -3532,10 +3537,10 @@ static void ieee80211_rx_michael_mic_rep
 	if ((rx->fc & IEEE80211_FCTL_FTYPE) != IEEE80211_FTYPE_DATA &&
 	    ((rx->fc & IEEE80211_FCTL_FTYPE) != IEEE80211_FTYPE_MGMT ||
 	     (rx->fc & IEEE80211_FCTL_STYPE) != IEEE80211_STYPE_AUTH)) {
-		printk(KERN_DEBUG "%s: ignored spurious Michael MIC "
+		printk(KERN_DEBUG "wiphy%d: ignored spurious Michael MIC "
 		       "error for a frame that cannot be encrypted "
 		       "(fc=0x%04x) (src " MAC_FMT ")\n",
-		       dev->name, rx->fc, MAC_ARG(hdr->addr2));
+		       rx->local->hw.index, rx->fc, MAC_ARG(hdr->addr2));
 		goto ignore;
 	}
 
@@ -3740,9 +3745,9 @@ void __ieee80211_rx(struct ieee80211_hw 
 				skb_new = skb_copy(skb, GFP_ATOMIC);
 				if (!skb_new) {
 					if (net_ratelimit())
-						printk(KERN_DEBUG "%s: failed to copy "
+						printk(KERN_DEBUG "wiphy%d: failed to copy "
 						       "multicast frame for %s",
-						       local->mdev->name, prev->dev->name);
+						       local->hw.index, prev->dev->name);
 					continue;
 				}
 				rx.skb = skb_new;
@@ -4019,8 +4024,8 @@ static void ieee80211_tasklet_handler(un
 			kfree(tx_status);
 			break;
 		default: /* should never get here! */
-			printk(KERN_ERR "%s: Unknown message type (%d)\n",
-			       local->mdev->name, skb->pkt_type);
+			printk(KERN_ERR "wiphy%d: Unknown message type (%d)\n",
+			       local->hw.index, skb->pkt_type);
 			dev_kfree_skb(skb);
 			break;
                 }
@@ -4102,8 +4107,8 @@ void ieee80211_tx_status(struct ieee8021
 
 	if (!status) {
                 printk(KERN_ERR
-		       "%s: ieee80211_tx_status called with NULL status\n",
-		       local->mdev->name);
+		       "wiphy%d: ieee80211_tx_status called with NULL status\n",
+		       local->hw.index);
 		dev_kfree_skb(skb);
 		return;
 	}
@@ -4157,10 +4162,10 @@ void ieee80211_tx_status(struct ieee8021
 				dev_queue_xmit(skb);
 			} else {
 				if (net_ratelimit()) {
-					printk(KERN_DEBUG "%s: dropped TX "
+					printk(KERN_DEBUG "wiphy%d: dropped TX "
 					       "filtered frame queue_len=%d "
 					       "PS=%d @%lu\n",
-					       local->mdev->name,
+					       local->hw.index,
 					       skb_queue_len(
 						       &sta->tx_filtered),
 					       !!(sta->flags & WLAN_STA_PS),
@@ -4360,14 +4365,14 @@ int ieee80211_init_rate_ctrl_alg(struct 
 
 	ref = rate_control_alloc(name, local);
 	if (!ref) {
-		printk(KERN_WARNING "%s: Failed to select rate control "
-		       "algorithm\n", local->mdev->name);
+		printk(KERN_WARNING "wiphy%d: Failed to select rate control "
+		       "algorithm\n", local->hw.index);
 		return -ENOENT;
 	}
 	res = rate_control_add_attrs(ref, &local->class_dev.kobj);
 	if (res < 0) {
-		printk(KERN_DEBUG "%s: Failed to register sysfs attributes "
-		       "for rate control\n", local->mdev->name);
+		printk(KERN_DEBUG "wiphy%d: Failed to register sysfs attributes "
+		       "for rate control\n", local->hw.index);
 		rate_control_put(ref);
 		return res;
 	}
@@ -4380,10 +4385,8 @@ int ieee80211_init_rate_ctrl_alg(struct 
 		sta_info_flush(local, NULL);
 	}
 
-	printk(KERN_DEBUG "%s: Selected rate control "
-	       "algorithm '%s'\n", local->mdev->name,
-	       ref->ops->name);
-
+	printk(KERN_DEBUG "wiphy%d: Selected rate control "
+	       "algorithm '%s'\n", local->hw.index, ref->ops->name);
 
 	return 0;
 }
@@ -4535,11 +4538,6 @@ int ieee80211_register_hw(struct ieee802
 	if (hw->flags & IEEE80211_HW_FRAGLIST)
 		local->mdev->features |= NETIF_F_FRAGLIST;
 	rtnl_lock();
-	result = dev_alloc_name(local->mdev, local->mdev->name);
-	if (result < 0) {
-		rtnl_unlock();
-		goto fail_dev;
-	}
 
 	memcpy(local->mdev->dev_addr, local->hw.perm_addr, ETH_ALEN);
 	SET_NETDEV_DEV(local->mdev, local->hw.dev);
@@ -4553,16 +4551,16 @@ int ieee80211_register_hw(struct ieee802
 	result = ieee80211_init_rate_ctrl_alg(local, NULL);
 	rtnl_unlock();
 	if (result < 0) {
-		printk(KERN_DEBUG "%s: Failed to initialize rate control "
-		       "algorithm\n", local->mdev->name);
+		printk(KERN_DEBUG "wiphy%d: Failed to initialize rate control "
+		       "algorithm\n", local->hw.index);
 		goto fail_rate;
 	}
 
 	result = ieee80211_wep_init(local);
 
 	if (result < 0) {
-		printk(KERN_DEBUG "%s: Failed to initialize wep\n",
-		       local->mdev->name);
+		printk(KERN_DEBUG "wiphy%d: Failed to initialize wep\n",
+		       local->hw.index);
 		goto fail_wep;
 	}
 
@@ -4673,8 +4671,8 @@ void ieee80211_unregister_hw(struct ieee
 
 	if (skb_queue_len(&local->skb_queue)
 			|| skb_queue_len(&local->skb_queue_unreliable))
-		printk(KERN_WARNING "%s: skb_queue not empty\n",
-		       local->mdev->name);
+		printk(KERN_WARNING "wiphy%d: skb_queue not empty\n",
+		       local->hw.index);
 	skb_queue_purge(&local->skb_queue);
 	skb_queue_purge(&local->skb_queue_unreliable);
 
--- dscape.orig/net/d80211/ieee80211_scan.c
+++ dscape/net/d80211/ieee80211_scan.c
@@ -116,9 +116,9 @@ static void ieee80211_scan_start(struct 
 	int ret;
 
 	if (!local->ops->passive_scan) {
-		printk(KERN_DEBUG "%s: Scan handler called, yet the hardware "
+		printk(KERN_DEBUG "wiphy%d: Scan handler called, yet the hardware "
 		       "does not support passive scanning. Disabled.\n",
-		       local->mdev->name);
+		       local->hw.index);
 		return;
 	}
 
@@ -135,8 +135,8 @@ static void ieee80211_scan_start(struct 
 	}
 
 	if (!local->scan.skb) {
-		printk(KERN_DEBUG "%s: Scan start called even though scan.skb "
-		       "is not set\n", local->mdev->name);
+		printk(KERN_DEBUG "wiphy%d: Scan start called even though scan.skb "
+		       "is not set\n", local->hw.index);
 	}
 
 	if (local->scan.our_mode_only) {
@@ -161,9 +161,9 @@ static void ieee80211_scan_start(struct 
 		skb_clone(local->scan.skb, GFP_ATOMIC) : NULL;
 	conf->tx_control = &local->scan.tx_control;
 #if 0
-	printk(KERN_DEBUG "%s: Doing scan on mode: %d freq: %d chan: %d "
+	printk(KERN_DEBUG "wiphy%d: Doing scan on mode: %d freq: %d chan: %d "
 	       "for %d ms\n",
-	       local->mdev->name, conf->scan_phymode, conf->scan_freq,
+	       local->hw.index, conf->scan_phymode, conf->scan_freq,
 	       conf->scan_channel, conf->scan_time);
 #endif
 	local->scan.rx_packets = 0;
@@ -193,8 +193,8 @@ static void ieee80211_scan_start(struct 
 			local->scan.mode = old_mode;
 			local->scan.chan_idx = old_chan_idx;
 		} else {
-			printk(KERN_DEBUG "%s: Got unknown error from "
-			       "passive_scan %d\n", local->mdev->name, ret);
+			printk(KERN_DEBUG "wiphy%d: Got unknown error from "
+			       "passive_scan %d\n", local->hw.index, ret);
 			local->scan.timer.expires = jiffies +
 				(local->scan.interval * HZ);
 		}
@@ -226,9 +226,9 @@ static void ieee80211_scan_stop(struct i
 				conf);
 
 #ifdef CONFIG_D80211_VERBOSE_DEBUG
-	printk(KERN_DEBUG "%s: Did scan on mode: %d freq: %d chan: %d "
+	printk(KERN_DEBUG "wiphy%d: Did scan on mode: %d freq: %d chan: %d "
 	       "GOT: %d Beacon: %d (%d)\n",
-	       local->mdev->name,
+	       local->hw.index,
 	       mode->mode, chan->freq, chan->chan,
 	       local->scan.rx_packets, local->scan.rx_beacon,
 	       local->scan.tries);
@@ -288,8 +288,8 @@ void ieee80211_init_scan(struct ieee8021
 		local->scan.skb = NULL;
 		memset(&local->scan.tx_control, 0,
 		       sizeof(local->scan.tx_control));
-		printk(KERN_DEBUG "%s: Does not support passive scan, "
-		       "disabled\n", local->mdev->name);
+		printk(KERN_DEBUG "wiphy%d: Does not support passive scan, "
+		       "disabled\n", local->hw.index);
 		return;
 	}
 
@@ -305,8 +305,8 @@ void ieee80211_init_scan(struct ieee8021
 	 * the low level changes channels */
 	local->scan.skb = alloc_skb(len, GFP_KERNEL);
 	if (!local->scan.skb) {
-		printk(KERN_WARNING "%s: Failed to allocate CTS packet for "
-		       "passive scan\n", local->mdev->name);
+		printk(KERN_WARNING "wiphy%d: Failed to allocate CTS packet for "
+		       "passive scan\n", local->hw.index);
 		return;
 	}
 
--- dscape.orig/net/d80211/sta_info.c
+++ dscape/net/d80211/sta_info.c
@@ -49,8 +49,8 @@ static void sta_info_hash_del(struct iee
 	if (s->hnext)
 		s->hnext = s->hnext->hnext;
 	else
-		printk(KERN_ERR "%s: could not remove STA " MAC_FMT " from "
-		       "hash table\n", local->mdev->name, MAC_ARG(sta->addr));
+		printk(KERN_ERR "wiphy%d: could not remove STA " MAC_FMT " from "
+		       "hash table\n", local->hw.index, MAC_ARG(sta->addr));
 }
 
 static inline struct sta_info *__sta_info_get(struct sta_info *sta)
@@ -172,8 +172,8 @@ struct sta_info * sta_info_add(struct ie
 	sta->key_idx_compression = HW_KEY_IDX_INVALID;
 
 #ifdef CONFIG_D80211_VERBOSE_DEBUG
-	printk(KERN_DEBUG "%s: Added STA " MAC_FMT "\n",
-	       local->mdev->name, MAC_ARG(addr));
+	printk(KERN_DEBUG "wiphy%d: Added STA " MAC_FMT "\n",
+	       local->hw.index, MAC_ARG(addr));
 #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 
 	if (!in_interrupt()) {
@@ -194,8 +194,8 @@ static void finish_sta_info_free(struct 
 				 struct sta_info *sta)
 {
 #ifdef CONFIG_D80211_VERBOSE_DEBUG
-	printk(KERN_DEBUG "%s: Removed STA " MAC_FMT "\n",
-	       local->mdev->name, MAC_ARG(sta->addr));
+	printk(KERN_DEBUG "wiphy%d: Removed STA " MAC_FMT "\n",
+	       local->hw.index, MAC_ARG(sta->addr));
 #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 
 	if (sta->key) {
--- dscape.orig/net/d80211/wme.c
+++ dscape/net/d80211/wme.c
@@ -421,7 +421,8 @@ static int wme_qdiscop_init(struct Qdisc
 						 qd->handle);
 		if (q->queues[i] == 0) {
 			q->queues[i] = &noop_qdisc;
-			printk(KERN_ERR "%s child qdisc %i creation failed", dev->name, i);
+			printk(KERN_ERR "wiphy%d: child qdisc %i creation failed",
+			       local->hw.index, i);
 		}
 	}
 
@@ -646,7 +647,10 @@ void ieee80211_install_qdisc(struct net_
 
 	qdisc = qdisc_create_dflt(dev, &wme_qdisc_ops, TC_H_ROOT);
 	if (!qdisc) {
-		printk(KERN_ERR "%s: qdisc installation failed\n", dev->name);
+		struct ieee80211_local *local = dev->ieee80211_ptr;
+
+		printk(KERN_ERR "wiphy%d: qdisc installation failed\n",
+		       local->hw.index);
 		return;
 	}
 
