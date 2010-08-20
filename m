From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH wireless-next] net/mac80211: Use wiphy_<level>
Date: Fri, 20 Aug 2010 16:25:38 -0700
Message-ID: <1282346738.1960.94.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Standardize logging messages from
	printk(KERN_<level> "%s: " fmt , wiphy_name(foo), args);
to
	wiphy_<level>(foo, fmt, args);

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
---
 net/mac80211/cfg.c      |    6 +++---
 net/mac80211/debugfs.c  |    6 ++++--
 net/mac80211/ibss.c     |    4 ++--
 net/mac80211/iface.c    |    6 ++----
 net/mac80211/key.c      |   14 ++++++--------
 net/mac80211/main.c     |   15 +++++++--------
 net/mac80211/mlme.c     |   17 +++++++++--------
 net/mac80211/rate.c     |    9 ++++-----
 net/mac80211/rx.c       |   13 +++++--------
 net/mac80211/sta_info.c |   21 +++++++++------------
 net/mac80211/status.c   |    9 ++++-----
 net/mac80211/tx.c       |    8 ++++----
 12 files changed, 59 insertions(+), 69 deletions(-)

diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index 94787d2..7693ebc 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -1123,9 +1123,9 @@ static int ieee80211_set_txq_params(struct wiphy *wiphy,
 	p.uapsd = false;
 
 	if (drv_conf_tx(local, params->queue, &p)) {
-		printk(KERN_DEBUG "%s: failed to set TX queue "
-		       "parameters for queue %d\n",
-		       wiphy_name(local->hw.wiphy), params->queue);
+		wiphy_debug(local->hw.wiphy,
+			    "failed to set TX queue parameters for queue %d\n",
+			    params->queue);
 		return -EINVAL;
 	}
 
diff --git a/net/mac80211/debugfs.c b/net/mac80211/debugfs.c
index a694c59..e81ef4e 100644
--- a/net/mac80211/debugfs.c
+++ b/net/mac80211/debugfs.c
@@ -85,13 +85,15 @@ static ssize_t tsf_write(struct file *file,
 	if (strncmp(buf, "reset", 5) == 0) {
 		if (local->ops->reset_tsf) {
 			drv_reset_tsf(local);
-			printk(KERN_INFO "%s: debugfs reset TSF\n", wiphy_name(local->hw.wiphy));
+			wiphy_info(local->hw.wiphy, "debugfs reset TSF\n");
 		}
 	} else {
 		tsf = simple_strtoul(buf, NULL, 0);
 		if (local->ops->set_tsf) {
 			drv_set_tsf(local, tsf);
-			printk(KERN_INFO "%s: debugfs set TSF to %#018llx\n", wiphy_name(local->hw.wiphy), tsf);
+			wiphy_info(local->hw.wiphy,
+				   "debugfs set TSF to %#018llx\n", tsf);
+
 		}
 	}
 
diff --git a/net/mac80211/ibss.c b/net/mac80211/ibss.c
index 32af971..1a3aae5 100644
--- a/net/mac80211/ibss.c
+++ b/net/mac80211/ibss.c
@@ -427,8 +427,8 @@ struct sta_info *ieee80211_ibss_add_sta(struct ieee80211_sub_if_data *sdata,
 		return NULL;
 
 #ifdef CONFIG_MAC80211_VERBOSE_DEBUG
-	printk(KERN_DEBUG "%s: Adding new IBSS station %pM (dev=%s)\n",
-	       wiphy_name(local->hw.wiphy), addr, sdata->name);
+	wiphy_debug(local->hw.wiphy, "Adding new IBSS station %pM (dev=%s)\n",
+		    addr, sdata->name);
 #endif
 
 	sta = sta_info_alloc(sdata, addr, gfp);
diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index 86f434f..9369710 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -1175,8 +1175,7 @@ static u32 ieee80211_idle_off(struct ieee80211_local *local,
 		return 0;
 
 #ifdef CONFIG_MAC80211_VERBOSE_DEBUG
-	printk(KERN_DEBUG "%s: device no longer idle - %s\n",
-	       wiphy_name(local->hw.wiphy), reason);
+	wiphy_debug(local->hw.wiphy, "device no longer idle - %s\n", reason);
 #endif
 
 	local->hw.conf.flags &= ~IEEE80211_CONF_IDLE;
@@ -1189,8 +1188,7 @@ static u32 ieee80211_idle_on(struct ieee80211_local *local)
 		return 0;
 
 #ifdef CONFIG_MAC80211_VERBOSE_DEBUG
-	printk(KERN_DEBUG "%s: device now idle\n",
-	       wiphy_name(local->hw.wiphy));
+	wiphy_debug(local->hw.wiphy, "device now idle\n");
 #endif
 
 	drv_flush(local, false);
diff --git a/net/mac80211/key.c b/net/mac80211/key.c
index 9c27c53..2ce2dbb 100644
--- a/net/mac80211/key.c
+++ b/net/mac80211/key.c
@@ -87,10 +87,9 @@ static void ieee80211_key_enable_hw_accel(struct ieee80211_key *key)
 		key->flags |= KEY_FLAG_UPLOADED_TO_HARDWARE;
 
 	if (ret && ret != -ENOSPC && ret != -EOPNOTSUPP)
-		printk(KERN_ERR "mac80211-%s: failed to set key "
-		       "(%d, %pM) to hardware (%d)\n",
-		       wiphy_name(key->local->hw.wiphy),
-		       key->conf.keyidx, sta ? sta->addr : bcast_addr, ret);
+		wiphy_err(key->local->hw.wiphy,
+			  "failed to set key (%d, %pM) to hardware (%d)\n",
+			  key->conf.keyidx, sta ? sta->addr : bcast_addr, ret);
 }
 
 static void ieee80211_key_disable_hw_accel(struct ieee80211_key *key)
@@ -121,10 +120,9 @@ static void ieee80211_key_disable_hw_accel(struct ieee80211_key *key)
 			  sta, &key->conf);
 
 	if (ret)
-		printk(KERN_ERR "mac80211-%s: failed to remove key "
-		       "(%d, %pM) from hardware (%d)\n",
-		       wiphy_name(key->local->hw.wiphy),
-		       key->conf.keyidx, sta ? sta->addr : bcast_addr, ret);
+		wiphy_err(key->local->hw.wiphy,
+			  "failed to remove key (%d, %pM) from hardware (%d)\n",
+			  key->conf.keyidx, sta ? sta->addr : bcast_addr, ret);
 
 	key->flags &= ~KEY_FLAG_UPLOADED_TO_HARDWARE;
 }
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index a53feac..5756fba 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -713,16 +713,16 @@ int ieee80211_register_hw(struct ieee80211_hw *hw)
 
 	result = ieee80211_wep_init(local);
 	if (result < 0)
-		printk(KERN_DEBUG "%s: Failed to initialize wep: %d\n",
-		       wiphy_name(local->hw.wiphy), result);
+		wiphy_debug(local->hw.wiphy, "Failed to initialize wep: %d\n",
+			    result);
 
 	rtnl_lock();
 
 	result = ieee80211_init_rate_ctrl_alg(local,
 					      hw->rate_control_algorithm);
 	if (result < 0) {
-		printk(KERN_DEBUG "%s: Failed to initialize rate control "
-		       "algorithm\n", wiphy_name(local->hw.wiphy));
+		wiphy_debug(local->hw.wiphy,
+			    "Failed to initialize rate control algorithm\n");
 		goto fail_rate;
 	}
 
@@ -731,8 +731,8 @@ int ieee80211_register_hw(struct ieee80211_hw *hw)
 		result = ieee80211_if_add(local, "wlan%d", NULL,
 					  NL80211_IFTYPE_STATION, NULL);
 		if (result)
-			printk(KERN_WARNING "%s: Failed to add default virtual iface\n",
-			       wiphy_name(local->hw.wiphy));
+			wiphy_warn(local->hw.wiphy,
+				   "Failed to add default virtual iface\n");
 	}
 
 	rtnl_unlock();
@@ -815,8 +815,7 @@ void ieee80211_unregister_hw(struct ieee80211_hw *hw)
 
 	if (skb_queue_len(&local->skb_queue) ||
 	    skb_queue_len(&local->skb_queue_unreliable))
-		printk(KERN_WARNING "%s: skb_queue not empty\n",
-		       wiphy_name(local->hw.wiphy));
+		wiphy_warn(local->hw.wiphy, "skb_queue not empty\n");
 	skb_queue_purge(&local->skb_queue);
 	skb_queue_purge(&local->skb_queue_unreliable);
 
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 38996a4..5282ac1 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -778,16 +778,17 @@ static void ieee80211_sta_wmm_params(struct ieee80211_local *local,
 		params.uapsd = uapsd;
 
 #ifdef CONFIG_MAC80211_VERBOSE_DEBUG
-		printk(KERN_DEBUG "%s: WMM queue=%d aci=%d acm=%d aifs=%d "
-		       "cWmin=%d cWmax=%d txop=%d uapsd=%d\n",
-		       wiphy_name(local->hw.wiphy), queue, aci, acm,
-		       params.aifs, params.cw_min, params.cw_max, params.txop,
-		       params.uapsd);
+		wiphy_debug(local->hw.wiphy,
+			    "WMM queue=%d aci=%d acm=%d aifs=%d "
+			    "cWmin=%d cWmax=%d txop=%d uapsd=%d\n",
+			    queue, aci, acm,
+			    params.aifs, params.cw_min, params.cw_max,
+			    params.txop, params.uapsd);
 #endif
 		if (drv_conf_tx(local, queue, &params))
-			printk(KERN_DEBUG "%s: failed to set TX queue "
-			       "parameters for queue %d\n",
-			       wiphy_name(local->hw.wiphy), queue);
+			wiphy_debug(local->hw.wiphy,
+				    "failed to set TX queue parameters for queue %d\n",
+				    queue);
 	}
 
 	/* enable WMM or activate new settings */
diff --git a/net/mac80211/rate.c b/net/mac80211/rate.c
index 6d0bd19..f77a456 100644
--- a/net/mac80211/rate.c
+++ b/net/mac80211/rate.c
@@ -366,8 +366,8 @@ int ieee80211_init_rate_ctrl_alg(struct ieee80211_local *local,
 
 	ref = rate_control_alloc(name, local);
 	if (!ref) {
-		printk(KERN_WARNING "%s: Failed to select rate control "
-		       "algorithm\n", wiphy_name(local->hw.wiphy));
+		wiphy_warn(local->hw.wiphy,
+			   "Failed to select rate control algorithm\n");
 		return -ENOENT;
 	}
 
@@ -378,9 +378,8 @@ int ieee80211_init_rate_ctrl_alg(struct ieee80211_local *local,
 		sta_info_flush(local, NULL);
 	}
 
-	printk(KERN_DEBUG "%s: Selected rate control "
-	       "algorithm '%s'\n", wiphy_name(local->hw.wiphy),
-	       ref->ops->name);
+	wiphy_debug(local->hw.wiphy, "Selected rate control algorithm '%s'\n",
+		    ref->ops->name);
 
 	return 0;
 }
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index aa41e38..e1844f7 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -605,10 +605,8 @@ static void ieee80211_sta_reorder_release(struct ieee80211_hw *hw,
 
 #ifdef CONFIG_MAC80211_HT_DEBUG
 			if (net_ratelimit())
-				printk(KERN_DEBUG "%s: release an RX reorder "
-				       "frame due to timeout on earlier "
-				       "frames\n",
-				       wiphy_name(hw->wiphy));
+				wiphy_debug(hw->wiphy,
+					    "release an RX reorder frame due to timeout on earlier frames\n");
 #endif
 			ieee80211_release_reorder_frame(hw, tid_agg_rx,
 							j, frames);
@@ -2698,10 +2696,9 @@ static void __ieee80211_rx_handle_packet(struct ieee80211_hw *hw,
 			skb_new = skb_copy(skb, GFP_ATOMIC);
 			if (!skb_new) {
 				if (net_ratelimit())
-					printk(KERN_DEBUG "%s: failed to copy "
-					       "multicast frame for %s\n",
-					       wiphy_name(local->hw.wiphy),
-					       prev->name);
+					wiphy_debug(local->hw.wiphy,
+						    "failed to copy multicast frame for %s\n",
+						    prev->name);
 				goto next;
 			}
 			ieee80211_invoke_rx_handlers(prev, &rx, skb_new);
diff --git a/net/mac80211/sta_info.c b/net/mac80211/sta_info.c
index 6d86f0c..687077e 100644
--- a/net/mac80211/sta_info.c
+++ b/net/mac80211/sta_info.c
@@ -174,8 +174,7 @@ static void __sta_info_free(struct ieee80211_local *local,
 	}
 
 #ifdef CONFIG_MAC80211_VERBOSE_DEBUG
-	printk(KERN_DEBUG "%s: Destroyed STA %pM\n",
-	       wiphy_name(local->hw.wiphy), sta->sta.addr);
+	wiphy_debug(local->hw.wiphy, "Destroyed STA %pM\n", sta->sta.addr);
 #endif /* CONFIG_MAC80211_VERBOSE_DEBUG */
 
 	kfree(sta);
@@ -262,8 +261,7 @@ struct sta_info *sta_info_alloc(struct ieee80211_sub_if_data *sdata,
 		sta->last_seq_ctrl[i] = cpu_to_le16(USHRT_MAX);
 
 #ifdef CONFIG_MAC80211_VERBOSE_DEBUG
-	printk(KERN_DEBUG "%s: Allocated STA %pM\n",
-	       wiphy_name(local->hw.wiphy), sta->sta.addr);
+	wiphy_debug(local->hw.wiphy, "Allocated STA %pM\n", sta->sta.addr);
 #endif /* CONFIG_MAC80211_VERBOSE_DEBUG */
 
 #ifdef CONFIG_MAC80211_MESH
@@ -300,8 +298,9 @@ static int sta_info_finish_insert(struct sta_info *sta, bool async)
 		sta->uploaded = true;
 #ifdef CONFIG_MAC80211_VERBOSE_DEBUG
 		if (async)
-			printk(KERN_DEBUG "%s: Finished adding IBSS STA %pM\n",
-			       wiphy_name(local->hw.wiphy), sta->sta.addr);
+			wiphy_debug(local->hw.wiphy,
+				    "Finished adding IBSS STA %pM\n",
+				    sta->sta.addr);
 #endif
 	}
 
@@ -411,8 +410,8 @@ int sta_info_insert_rcu(struct sta_info *sta) __acquires(RCU)
 		spin_unlock_irqrestore(&local->sta_lock, flags);
 
 #ifdef CONFIG_MAC80211_VERBOSE_DEBUG
-		printk(KERN_DEBUG "%s: Added IBSS STA %pM\n",
-		       wiphy_name(local->hw.wiphy), sta->sta.addr);
+		wiphy_debug(local->hw.wiphy, "Added IBSS STA %pM\n",
+			    sta->sta.addr);
 #endif /* CONFIG_MAC80211_VERBOSE_DEBUG */
 
 		ieee80211_queue_work(&local->hw, &local->sta_finish_work);
@@ -459,8 +458,7 @@ int sta_info_insert_rcu(struct sta_info *sta) __acquires(RCU)
 	}
 
 #ifdef CONFIG_MAC80211_VERBOSE_DEBUG
-	printk(KERN_DEBUG "%s: Inserted STA %pM\n",
-	       wiphy_name(local->hw.wiphy), sta->sta.addr);
+	wiphy_debug(local->hw.wiphy, "Inserted STA %pM\n", sta->sta.addr);
 #endif /* CONFIG_MAC80211_VERBOSE_DEBUG */
 
 	/* move reference to rcu-protected */
@@ -690,8 +688,7 @@ static int __must_check __sta_info_destroy(struct sta_info *sta)
 #endif
 
 #ifdef CONFIG_MAC80211_VERBOSE_DEBUG
-	printk(KERN_DEBUG "%s: Removed STA %pM\n",
-	       wiphy_name(local->hw.wiphy), sta->sta.addr);
+	wiphy_debug(local->hw.wiphy, "Removed STA %pM\n", sta->sta.addr);
 #endif /* CONFIG_MAC80211_VERBOSE_DEBUG */
 	cancel_work_sync(&sta->drv_unblock_wk);
 
diff --git a/net/mac80211/status.c b/net/mac80211/status.c
index 67a3584..571b32b 100644
--- a/net/mac80211/status.c
+++ b/net/mac80211/status.c
@@ -114,11 +114,10 @@ static void ieee80211_handle_filtered_frame(struct ieee80211_local *local,
 
 #ifdef CONFIG_MAC80211_VERBOSE_DEBUG
 	if (net_ratelimit())
-		printk(KERN_DEBUG "%s: dropped TX filtered frame, "
-		       "queue_len=%d PS=%d @%lu\n",
-		       wiphy_name(local->hw.wiphy),
-		       skb_queue_len(&sta->tx_filtered),
-		       !!test_sta_flags(sta, WLAN_STA_PS_STA), jiffies);
+		wiphy_debug(local->hw.wiphy,
+			    "dropped TX filtered frame, queue_len=%d PS=%d @%lu\n",
+			    skb_queue_len(&sta->tx_filtered),
+			    !!test_sta_flags(sta, WLAN_STA_PS_STA), jiffies);
 #endif
 	dev_kfree_skb(skb);
 }
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index bc4fefc..d51ec74 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -351,8 +351,8 @@ static void purge_old_ps_buffers(struct ieee80211_local *local)
 
 	local->total_ps_buffered = total;
 #ifdef CONFIG_MAC80211_VERBOSE_PS_DEBUG
-	printk(KERN_DEBUG "%s: PS buffers full - purged %d frames\n",
-	       wiphy_name(local->hw.wiphy), purged);
+	wiphy_debug(local->hw.wiphy, "PS buffers full - purged %d frames\n",
+		    purged);
 #endif
 }
 
@@ -1513,8 +1513,8 @@ static int ieee80211_skb_resize(struct ieee80211_local *local,
 		I802_DEBUG_INC(local->tx_expand_skb_head);
 
 	if (pskb_expand_head(skb, head_need, tail_need, GFP_ATOMIC)) {
-		printk(KERN_DEBUG "%s: failed to reallocate TX buffer\n",
-		       wiphy_name(local->hw.wiphy));
+		wiphy_debug(local->hw.wiphy,
+			    "failed to reallocate TX buffer\n");
 		return -ENOMEM;
 	}
 


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
