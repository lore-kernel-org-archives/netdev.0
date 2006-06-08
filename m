From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 7/12] d80211: rename sta_info_relase to sta_info_put
Date: Thu,  8 Jun 2006 09:49:11 +0200 (CEST)
Message-ID: <20060608074911.5860548394@silver.suse.cz>
References: <20060608094822.014829000.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:52632 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S964778AbWFHHsA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2006 03:48:00 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060608094822.014829000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

sta_info structure has reference counting (will be converted to kobject in
next patch). Therefore, sta_info_release should be divided into two
functions - one for decrementing reference count and one for freeing the
structure when the count drops to zero. sta_info_release is the name
suitable for the second function.

This patch renames sta_info_release to sta_info_put to let next patch
introduce a new sta_info_release function.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c       |   18 +++++++++---------
 net/d80211/ieee80211_iface.c |    2 +-
 net/d80211/ieee80211_ioctl.c |   18 +++++++++---------
 net/d80211/ieee80211_sta.c   |    8 ++++----
 net/d80211/rate_control.c    |    4 ++--
 net/d80211/sta_info.c        |   10 +++++-----
 net/d80211/sta_info.h        |    2 +-
 7 files changed, 31 insertions(+), 31 deletions(-)

4ddde98ebbdede0d0b16a85156e1b9c192c0e764
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index c983d70..0c23607 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -1153,7 +1153,7 @@ static int ieee80211_tx(struct net_devic
 	skb = tx.skb; /* handlers are allowed to change skb */
 
 	if (sta)
-		sta_info_release(local, sta);
+		sta_info_put(local, sta);
 
 	if (unlikely(res == TXRX_DROP)) {
 		I802_DEBUG_INC(local->tx_handlers_drop);
@@ -1373,7 +1373,7 @@ static int ieee80211_subif_start_xmit(st
 			fc |= WLAN_FC_STYPE_QOS_DATA << 4;
 			hdrlen += 2;
 		}
-		sta_info_release(local, sta);
+		sta_info_put(local, sta);
 	}
 
 	hdr.frame_control = cpu_to_le16(fc);
@@ -1743,7 +1743,7 @@ ieee80211_get_buffered_bc(struct net_dev
 	}
 
 	if (sta)
-		sta_info_release(local, sta);
+		sta_info_put(local, sta);
 
 	return skb;
 }
@@ -2330,7 +2330,7 @@ ieee80211_rx_h_data(struct ieee80211_txr
 				skb = NULL;
 			}
 			if (dsta)
-				sta_info_release(local, dsta);
+				sta_info_put(local, dsta);
 		}
 	}
 
@@ -3469,7 +3469,7 @@ void __ieee80211_rx(struct net_device *d
 
   end:
 	if (sta)
-                sta_info_release(local, sta);
+		sta_info_put(local, sta);
 }
 
 
@@ -3806,7 +3806,7 @@ void ieee80211_tx_status(struct net_devi
 				status->excessive_retries = 0;
 				status->tx_filtered = 1;
 			}
-			sta_info_release(local, sta);
+			sta_info_put(local, sta);
 		}
 	}
 
@@ -3855,7 +3855,7 @@ void ieee80211_tx_status(struct net_devi
 				}
 				dev_kfree_skb(skb);
 			}
-			sta_info_release(local, sta);
+			sta_info_put(local, sta);
 			return;
 		}
 	} else {
@@ -3978,7 +3978,7 @@ int ieee80211_if_update_wds(struct net_d
 	/* Remove STA entry for the old peer */
 	sta = sta_info_get(local, sdata->u.wds.remote_addr);
 	if (sta) {
-		sta_info_release(local, sta);
+		sta_info_put(local, sta);
 		sta_info_free(local, sta, 0);
 	} else {
 		printk(KERN_DEBUG "%s: could not find STA entry for WDS link "
@@ -4522,7 +4522,7 @@ EXPORT_SYMBOL(ieee80211_get_hdrlen_from_
 EXPORT_SYMBOL(ieee80211_rate_control_register);
 EXPORT_SYMBOL(ieee80211_rate_control_unregister);
 EXPORT_SYMBOL(sta_info_get);
-EXPORT_SYMBOL(sta_info_release);
+EXPORT_SYMBOL(sta_info_put);
 EXPORT_SYMBOL(ieee80211_radar_status);
 EXPORT_SYMBOL(ieee80211_get_mc_list_item);
 
diff --git a/net/d80211/ieee80211_iface.c b/net/d80211/ieee80211_iface.c
index 727b5e3..467dcba 100644
--- a/net/d80211/ieee80211_iface.c
+++ b/net/d80211/ieee80211_iface.c
@@ -261,7 +261,7 @@ #endif
 	case IEEE80211_IF_TYPE_WDS:
 		sta = sta_info_get(local, sdata->u.wds.remote_addr);
 		if (sta) {
-			sta_info_release(local, sta);
+			sta_info_put(local, sta);
 			sta_info_free(local, sta, 0);
 		} else {
 #ifdef CONFIG_D80211_VERBOSE_DEBUG
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index 8d593e8..e1bdc03 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -294,7 +294,7 @@ static int ieee80211_ioctl_add_sta(struc
 		}
 	}
 
-	sta_info_release(local, sta);
+	sta_info_put(local, sta);
 
 	return 0;
 }
@@ -308,7 +308,7 @@ static int ieee80211_ioctl_remove_sta(st
 
 	sta = sta_info_get(local, param->sta_addr);
 	if (sta) {
-		sta_info_release(local, sta);
+		sta_info_put(local, sta);
 		sta_info_free(local, sta, 1);
 	}
 
@@ -393,7 +393,7 @@ static int ieee80211_ioctl_get_info_sta(
 	param->u.get_info_sta.last_rssi = sta->last_rssi;
 	param->u.get_info_sta.last_ack_rssi = sta->last_ack_rssi[2];
 
-	sta_info_release(local, sta);
+	sta_info_put(local, sta);
 
 	return 0;
 }
@@ -421,7 +421,7 @@ static int ieee80211_ioctl_set_flags_sta
 			printk(KERN_DEBUG "%s: failed to set low-level driver "
 			       "PAE state (unauthorized) for " MACSTR "\n",
 			       dev->name, MAC2STR(sta->addr));
-		sta_info_release(local, sta);
+		sta_info_put(local, sta);
 	}
 
 	return sta ? 0 : -ENOENT;
@@ -563,7 +563,7 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 				if (sta->flags & WLAN_STA_WME) {
 					try_hwaccel = 0;
 				}
-				sta_info_release(local, sta);
+				sta_info_put(local, sta);
 				sta = NULL;
 			}
 		}
@@ -643,7 +643,7 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 
  done:
 	if (sta)
-		sta_info_release(local, sta);
+		sta_info_put(local, sta);
 
 	return ret;
 }
@@ -813,7 +813,7 @@ static int ieee80211_ioctl_get_encryptio
 	}
 
 	if (sta)
-		sta_info_release(local, sta);
+		sta_info_put(local, sta);
 
 	return ret;
 }
@@ -842,7 +842,7 @@ static int ieee80211_ioctl_wpa_trigger(s
 
 	sta->wpa_trigger = param->u.wpa_trigger.trigger;
 
-	sta_info_release(local, sta);
+	sta_info_put(local, sta);
 	return 0;
 }
 #endif /* CONFIG_HOSTAPD_WPA_TESTING */
@@ -1136,7 +1136,7 @@ #endif
 			sta->vlan_id = param->u.set_sta_vlan.vlan_id;
                         dev_put(new_vlan_dev);
                 }
-		sta_info_release(local, sta);
+		sta_info_put(local, sta);
 	}
 
 	return sta ? 0 : -ENOENT;
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index 66a4575..a42c387 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -730,7 +730,7 @@ static void ieee80211_associated(struct 
 							 ifsta->ssid_len);
 			}
 		}
-		sta_info_release(local, sta);
+		sta_info_put(local, sta);
 	}
 	if (disassoc) {
 		union iwreq_data wrqu;
@@ -1200,7 +1200,7 @@ static void ieee80211_rx_mgmt_assoc_resp
 	}
 
 
-	sta_info_release(local, sta);
+	sta_info_put(local, sta);
 
 	ieee80211_associated(dev, ifsta);
 }
@@ -1443,7 +1443,7 @@ #endif /* IEEE80211_IBSS_DEBUG */
 			       dev->name, MAC2STR(sta->addr), prev_rates,
 			       supp_rates, sta->supp_rates);
 		}
-		sta_info_release(local, sta);
+		sta_info_put(local, sta);
 	}
 
 	if (elems.ssid == NULL)
@@ -2834,7 +2834,7 @@ struct sta_info * ieee80211_ibss_add_sta
 
 	rate_control_rate_init(local, sta);
 
-	return sta; /* caller will call sta_info_release() */
+	return sta; /* caller will call sta_info_put() */
 }
 
 
diff --git a/net/d80211/rate_control.c b/net/d80211/rate_control.c
index 3485302..9bcb8fc 100644
--- a/net/d80211/rate_control.c
+++ b/net/d80211/rate_control.c
@@ -209,7 +209,7 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 		}
 	}
 
-	sta_info_release(local, sta);
+	sta_info_put(local, sta);
 }
 
 
@@ -260,7 +260,7 @@ rate_control_simple_get_rate(struct net_
 	extra->nonerp_idx = nonerp_idx;
 	extra->nonerp = &local->curr_rates[extra->nonerp_idx];
 
-	sta_info_release(local, sta);
+	sta_info_put(local, sta);
 
 	return &local->curr_rates[rateidx];
 }
diff --git a/net/d80211/sta_info.c b/net/d80211/sta_info.c
index de14821..9565c29 100644
--- a/net/d80211/sta_info.c
+++ b/net/d80211/sta_info.c
@@ -98,7 +98,7 @@ int sta_info_min_txrate_get(struct ieee8
 }
 
 
-void sta_info_release(struct ieee80211_local *local, struct sta_info *sta)
+void sta_info_put(struct ieee80211_local *local, struct sta_info *sta)
 {
 	struct sk_buff *skb;
 
@@ -145,7 +145,7 @@ struct sta_info * sta_info_add(struct ie
 	atomic_inc(&sta->users); /* sta in hashlist etc, decremented by
 				  * sta_info_free() */
 	atomic_inc(&sta->users); /* sta used by caller, decremented by
-				  * sta_info_release() */
+				  * sta_info_put() */
 	spin_lock_bh(&local->sta_lock);
 	list_add(&sta->list, &local->sta_list);
 	local->num_sta++;
@@ -237,13 +237,13 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 	if (atomic_read(&sta->users) != 1) {
 		/* This is OK, but printed for debugging. The station structure
 		 * will be removed when the other user of the data calls
-		 * sta_info_release(). */
+		 * sta_info_put(). */
 		printk(KERN_DEBUG "%s: STA " MACSTR " users count %d when "
 		       "removing it\n", local->mdev->name, MAC2STR(sta->addr),
 		       atomic_read(&sta->users));
 	}
 
-	sta_info_release(local, sta);
+	sta_info_put(local, sta);
 }
 
 
@@ -302,7 +302,7 @@ static void sta_info_cleanup(unsigned lo
 		struct sta_info *sta = (struct sta_info *) ptr;
 		atomic_inc(&sta->users);
 		sta_info_cleanup_expire_buffered(local, sta);
-		sta_info_release(local, sta);
+		sta_info_put(local, sta);
 		ptr = ptr->next;
 	}
 	spin_unlock_bh(&local->sta_lock);
diff --git a/net/d80211/sta_info.h b/net/d80211/sta_info.h
index 294cb0a..fddc80e 100644
--- a/net/d80211/sta_info.h
+++ b/net/d80211/sta_info.h
@@ -134,7 +134,7 @@ struct ieee80211_local;
 
 struct sta_info * sta_info_get(struct ieee80211_local *local, u8 *addr);
 int sta_info_min_txrate_get(struct ieee80211_local *local);
-void sta_info_release(struct ieee80211_local *local, struct sta_info *sta);
+void sta_info_put(struct ieee80211_local *local, struct sta_info *sta);
 struct sta_info * sta_info_add(struct ieee80211_local *local,
 			       struct net_device *dev, u8 *addr);
 void sta_info_free(struct ieee80211_local *local, struct sta_info *sta,
-- 
1.3.0

