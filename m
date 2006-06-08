From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 12/12] d80211: remove procfs files
Date: Thu,  8 Jun 2006 09:49:16 +0200 (CEST)
Message-ID: <20060608074916.A1D2048398@silver.suse.cz>
References: <20060608094822.014829000.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:53912 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S964778AbWFHHsG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2006 03:48:06 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060608094822.014829000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove procfs support.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/Makefile          |    1 
 net/d80211/ieee80211.c       |    7 
 net/d80211/ieee80211_iface.c |    3 
 net/d80211/ieee80211_proc.c  |  768 ------------------------------------------
 net/d80211/ieee80211_proc.h  |   48 ---
 net/d80211/ieee80211_sysfs.c |   33 ++
 net/d80211/rate_control.c    |   25 -
 net/d80211/rate_control.h    |   17 -
 net/d80211/sta_info.c        |    4 
 9 files changed, 32 insertions(+), 874 deletions(-)
 delete mode 100644 net/d80211/ieee80211_proc.c
 delete mode 100644 net/d80211/ieee80211_proc.h

89c13fc02b12796d1f57c33c7fae1bcf875d846b
diff --git a/net/d80211/Makefile b/net/d80211/Makefile
index 7d1ec29..c21e882 100644
--- a/net/d80211/Makefile
+++ b/net/d80211/Makefile
@@ -6,7 +6,6 @@ obj-$(CONFIG_D80211) += 80211.o rate_con
 	sta_info.o \
 	wep.o \
 	wpa.o \
-	ieee80211_proc.o \
 	ieee80211_scan.o \
 	ieee80211_sta.o \
 	ieee80211_dev.o \
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 1a03f07..a8ca8d1 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -25,7 +25,6 @@ #include <net/d80211.h>
 #include <net/d80211_common.h>
 #include <net/d80211_mgmt.h>
 #include "ieee80211_i.h"
-#include "ieee80211_proc.h"
 #include "rate_control.h"
 #include "wep.h"
 #include "wpa.h"
@@ -4256,7 +4255,6 @@ int ieee80211_register_hw(struct net_dev
 	ieee80211_install_qdisc(dev);
 
         ieee80211_wep_init(local);
-	ieee80211_proc_init_interface(local);
 
 	/* add one default STA interface */
 	rtnl_lock();
@@ -4359,8 +4357,6 @@ void ieee80211_unregister_hw(struct net_
 		kfree(local->basic_rates[i]);
         }
 
-	ieee80211_proc_deinit_interface(local);
-
 	if (skb_queue_len(&local->skb_queue)
 			|| skb_queue_len(&local->skb_queue_unreliable))
 		printk(KERN_WARNING "%s: skb_queue not empty", dev->name);
@@ -4520,14 +4516,12 @@ static int __init ieee80211_init(void)
 		return ret;
 	}
 
-	ieee80211_proc_init();
 	{
 		ret = ieee80211_wme_register();
 		if (ret) {
 			printk(KERN_DEBUG "ieee80211_init: failed to "
 			       "initialize WME (err=%d)\n", ret);
 			ieee80211_sysfs_deinit();
-			ieee80211_proc_deinit();
 			return ret;
 		}
 	}
@@ -4539,7 +4533,6 @@ static int __init ieee80211_init(void)
 static void __exit ieee80211_exit(void)
 {
 	ieee80211_wme_unregister();
-	ieee80211_proc_deinit();
 	ieee80211_sysfs_deinit();
 }
 
diff --git a/net/d80211/ieee80211_iface.c b/net/d80211/ieee80211_iface.c
index 960a90e..5abd713 100644
--- a/net/d80211/ieee80211_iface.c
+++ b/net/d80211/ieee80211_iface.c
@@ -14,7 +14,6 @@ #include <linux/rtnetlink.h>
 #include <net/d80211.h>
 #include <net/d80211_mgmt.h>
 #include "ieee80211_i.h"
-#include "ieee80211_proc.h"
 #include "sta_info.h"
 
 void ieee80211_if_sdata_init(struct ieee80211_sub_if_data *sdata)
@@ -85,7 +84,6 @@ int ieee80211_if_add(struct net_device *
 	}
 
 	list_add(&sdata->list, &local->sub_if_list);
-	ieee80211_proc_init_virtual(ndev);
 
 	return 0;
 
@@ -307,7 +305,6 @@ void __ieee80211_if_del(struct ieee80211
 
 	ieee80211_if_reinit(dev);
 	list_del(&sdata->list);
-	ieee80211_proc_deinit_virtual(dev);
 	ieee80211_sysfs_remove_netdevice(dev);
 	unregister_netdevice(dev);
 	/* Except master interface, the net_device will be freed by
diff --git a/net/d80211/ieee80211_proc.c b/net/d80211/ieee80211_proc.c
deleted file mode 100644
index 4bb3179..0000000
--- a/net/d80211/ieee80211_proc.c
+++ /dev/null
@@ -1,768 +0,0 @@
-/*
- * Copyright 2003-2005, Devicescape Software, Inc.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#include <linux/config.h>
-#include <linux/version.h>
-#include <linux/module.h>
-#include <linux/netdevice.h>
-#include <linux/proc_fs.h>
-#include <linux/delay.h>
-
-#ifdef CONFIG_PROC_FS
-
-#include <net/d80211.h>
-#include <net/d80211_common.h>
-#include <net/d80211_mgmt.h>
-#include "ieee80211_i.h"
-#include "sta_info.h"
-#include "ieee80211_proc.h"
-#include "rate_control.h"
-
-
-static struct proc_dir_entry *ieee80211_proc;
-
-#define PROC_LIMIT (PAGE_SIZE - 80)
-
-
-static char * ieee80211_proc_key(char *p, struct ieee80211_key *key,
-				 int idx, int def_key)
-{
-	int i;
-	u8 *tpn, *rpn;
-
-	if (!key)
-		return p;
-
-	p += sprintf(p, "key[%d]%s len=%d sw_encrypt=%d idx=%d hwidx=%d "
-		     "tx_rx_count=%d",
-		     idx, def_key ? "*" : "", key->keylen,
-		     key->force_sw_encrypt, key->keyidx, key->hw_key_idx,
-		     key->tx_rx_count);
-	switch (key->alg) {
-	case ALG_WEP:
-		p += sprintf(p, " alg=WEP");
-		break;
-	case ALG_TKIP:
-		p += sprintf(p, " alg=TKIP iv(tx)=%08x %04x",
-			     key->u.tkip.iv32, key->u.tkip.iv16);
-		for (i = 0; i < NUM_RX_DATA_QUEUES; i++) {
-			if (key->u.tkip.iv32_rx[i] == 0 &&
-			    key->u.tkip.iv16_rx[i] == 0)
-				continue;
-			p += sprintf(p, " iv(rx %d)=%08x %04x", i,
-				     key->u.tkip.iv32_rx[i],
-				     key->u.tkip.iv16_rx[i]);
-		}
-		break;
-	case ALG_CCMP:
-		tpn = key->u.ccmp.tx_pn;
-		p += sprintf(p, " alg=CCMP PN(tx)=%02x%02x%02x%02x%02x%02x",
-			     tpn[0], tpn[1], tpn[2], tpn[3], tpn[4], tpn[5]);
-		for (i = 0; i < NUM_RX_DATA_QUEUES; i++) {
-			rpn = key->u.ccmp.rx_pn[i];
-			if (memcmp(rpn, "\x00\x00\x00\x00\x00\x00", 6) == 0)
-				continue;
-			p += sprintf(p, " PN(rx %d)=%02x%02x%02x%02x%02x%02x",
-				     i, rpn[0], rpn[1], rpn[2], rpn[3], rpn[4],
-				     rpn[5]);
-		}
-		p += sprintf(p, " replays=%u", key->u.ccmp.replays);
-		break;
-	default:
-		break;
-	}
-
-	p += sprintf(p, " key=");
-	for (i = 0; i < key->keylen; i++)
-		p += sprintf(p, "%02x", key->key[i]);
-	p += sprintf(p, "\n");
-	return p;
-}
-
-
-static char * ieee80211_proc_sub_if_ap(char *p,
-				       struct ieee80211_if_ap *ap)
-{
-	p += sprintf(p, "type=ap\n");
-	if (ap->beacon_head)
-		p += sprintf(p, "beacon_head_len=%d\n", ap->beacon_head_len);
-	if (ap->beacon_tail)
-		p += sprintf(p, "beacon_tail_len=%d\n", ap->beacon_tail_len);
-	p += sprintf(p,
-		     "max_aid=%d\n"
-		     "num_sta_ps=%d\n"
-		     "num_buffered_multicast=%u\n"
-		     "dtim_period=%d\n"
-		     "dtim_count=%d\n"
-		     "num_beacons=%d\n"
-		     "force_unicast_rateidx=%d\n"
-		     "max_ratectrl_rateidx=%d\n",
-		     ap->max_aid, atomic_read(&ap->num_sta_ps),
-		     skb_queue_len(&ap->ps_bc_buf),
-		     ap->dtim_period, ap->dtim_count, ap->num_beacons,
-		     ap->force_unicast_rateidx, ap->max_ratectrl_rateidx);
-	return p;
-}
-
-
-static char * ieee80211_proc_sub_if_sta(char *p, int ibss,
-					struct ieee80211_if_sta *ifsta)
-{
-	if (ibss)
-		p += sprintf(p, "type=ibss\n");
-	else
-		p += sprintf(p, "type=sta\n");
-	p += sprintf(p,
-		     "state=%d\n"
-		     "bssid=" MACSTR "\n"
-		     "prev_bssid=" MACSTR "\n"
-		     "ssid_len=%zd\n"
-		     "aid=%d\n"
-		     "ap_capab=0x%x\n"
-		     "capab=0x%x\n"
-		     "extra_ie_len=%zd\n"
-		     "auth_tries=%d\n"
-		     "assoc_tries=%d\n"
-		     "flags=%s%s%s%s%s%s%s\n"
-		     "auth_algs=0x%x\n"
-		     "auth_alg=%d\n"
-		     "auth_transaction=%d\n",
-		     ifsta->state,
-		     MAC2STR(ifsta->bssid),
-		     MAC2STR(ifsta->prev_bssid),
-		     ifsta->ssid_len,
-		     ifsta->aid,
-		     ifsta->ap_capab,
-		     ifsta->capab,
-		     ifsta->extra_ie_len,
-		     ifsta->auth_tries,
-		     ifsta->assoc_tries,
-		     ifsta->ssid_set ? "[SSID]" : "",
-		     ifsta->bssid_set ? "[BSSID]" : "",
-		     ifsta->prev_bssid_set ? "[prev BSSID" : "",
-		     ifsta->authenticated ? "[AUTH]" : "",
-		     ifsta->associated ? "[ASSOC]" : "",
-		     ifsta->probereq_poll ? "[PROBEREQ POLL]" : "",
-		     ifsta->use_protection ? "[CTS prot]" : "",
-		     ifsta->auth_algs,
-		     ifsta->auth_alg,
-		     ifsta->auth_transaction);
-	return p;
-}
-
-
-static char * ieee80211_proc_sub_if(char *p,
-				    struct ieee80211_sub_if_data *sdata)
-{
-	if (sdata == NULL)
-		return p;
-
-	if (sdata->bss)
-		p += sprintf(p, "bss=%p\n", sdata->bss);
-
-	switch (sdata->type) {
-	case IEEE80211_IF_TYPE_AP:
-		p = ieee80211_proc_sub_if_ap(p, &sdata->u.ap);
-		break;
-	case IEEE80211_IF_TYPE_WDS:
-		p += sprintf(p, "type=wds\n");
-		p += sprintf(p, "wds.peer=" MACSTR "\n",
-			     MAC2STR(sdata->u.wds.remote_addr));
-		break;
-	case IEEE80211_IF_TYPE_VLAN:
-		p += sprintf(p, "type=vlan\n");
-		p += sprintf(p, "vlan.id=%d\n", sdata->u.vlan.id);
-		break;
-	case IEEE80211_IF_TYPE_STA:
-		p = ieee80211_proc_sub_if_sta(p, 0, &sdata->u.sta);
-		break;
-	case IEEE80211_IF_TYPE_IBSS:
-		p = ieee80211_proc_sub_if_sta(p, 1, &sdata->u.sta);
-		break;
-	}
-	p += sprintf(p, "channel_use=%d\n", sdata->channel_use);
-	p += sprintf(p, "drop_unencrypted=%d\n", sdata->drop_unencrypted);
-	p += sprintf(p, "eapol=%d\n", sdata->eapol);
-	p += sprintf(p, "ieee802_1x=%d\n", sdata->ieee802_1x);
-
-	return p;
-}
-
-
-static int ieee80211_proc_iface_read(char *page, char **start, off_t off,
-				     int count, int *eof, void *data)
-{
-	char *p = page;
-	struct net_device *dev = (struct net_device *) data;
-	struct ieee80211_sub_if_data *sdata;
-	int i;
-
-	if (off != 0) {
-		*eof = 1;
-		return 0;
-	}
-
-	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-	if (!sdata)
-		return -1;
-
-        p = ieee80211_proc_sub_if(p, sdata);
-
-	for (i = 0; i < NUM_DEFAULT_KEYS; i++) {
-		if (sdata->keys[i] == NULL)
-			continue;
-
-		p = ieee80211_proc_key(p, sdata->keys[i], i,
-				       sdata->keys[i] == sdata->default_key);
-	}
-
-	return (p - page);
-}
-
-
-static int ieee80211_proc_sta_read(char *page, char **start, off_t off,
-				   int count, int *eof, void *data)
-{
-	char *p = page;
-	struct sta_info *sta = (struct sta_info *) data;
-	struct ieee80211_local *local;
-	int inactive, i;
-
-	if (off != 0) {
-		*eof = 1;
-		return 0;
-	}
-
-	if (!sta || !sta->dev)
-		return -1;
-
-	p += sprintf(p, "aid=%d\n", sta->aid);
-	p += sprintf(p, "flags=0x%x %s%s%s%s%s%s%s%s%s%s\n", sta->flags,
-		     sta->flags & WLAN_STA_AUTH ? "[AUTH]" : "",
-		     sta->flags & WLAN_STA_ASSOC ? "[ASSOC]" : "",
-		     sta->flags & WLAN_STA_PS ? "[PS]" : "",
-		     sta->flags & WLAN_STA_TIM ? "[TIM]" : "",
-		     sta->flags & WLAN_STA_PERM ? "[PERM]" : "",
-		     sta->flags & WLAN_STA_AUTHORIZED ? "[AUTHORIZED]" : "",
-		     sta->flags & WLAN_STA_SHORT_PREAMBLE ?
-		     "[SHORT PREAMBLE]" : "",
-		     sta->flags & WLAN_STA_WME ? "[WME]" : "",
-		     sta->flags & WLAN_STA_WDS ? "[WDS]" : "",
-		     sta->flags & WLAN_STA_XR ? "[XR]" : "");
-	p += sprintf(p, "key_idx_compression=%d\n",
-		     sta->key_idx_compression);
-	p += sprintf(p, "dev=%s\n", sta->dev->name);
-	if (sta->vlan_id > 0)
-		p += sprintf(p, "vlan_id=%d\n", sta->vlan_id);
-	p += sprintf(p, "rx_packets=%lu\ntx_packets=%lu\nrx_bytes=%lu\n"
-		     "tx_bytes=%lu\nrx_duplicates=%lu\nrx_fragments=%lu\n"
-		     "rx_dropped=%lu\ntx_fragments=%lu\ntx_filtered=%lu\n",
-		     sta->rx_packets, sta->tx_packets,
-		     sta->rx_bytes, sta->tx_bytes,
-		     sta->num_duplicates, sta->rx_fragments, sta->rx_dropped,
-		     sta->tx_fragments, sta->tx_filtered_count);
-	p = ieee80211_proc_key(p, sta->key, 0, 1);
-
-	local = (struct ieee80211_local *) sta->dev->ieee80211_ptr;
-	if (sta->txrate >= 0 && sta->txrate < local->num_curr_rates) {
-		p += sprintf(p, "txrate=%d\n",
-			     local->curr_rates[sta->txrate].rate);
-	}
-	if (sta->last_txrate >= 0 &&
-	    sta->last_txrate < local->num_curr_rates) {
-		p += sprintf(p, "last_txrate=%d\n",
-			     local->curr_rates[sta->last_txrate].rate);
-	}
-	p += sprintf(p, "num_ps_buf_frames=%u\n",
-		     skb_queue_len(&sta->ps_tx_buf));
-	p += sprintf(p, "tx_retry_failed=%lu\n", sta->tx_retry_failed);
-	p += sprintf(p, "tx_retry_count=%lu\n", sta->tx_retry_count);
-	p += sprintf(p, "last_rssi=%d\n", sta->last_rssi);
-	p += sprintf(p, "last_ack_rssi=%d %d %d\n",
-		     sta->last_ack_rssi[0], sta->last_ack_rssi[1],
-		     sta->last_ack_rssi[2]);
-	if (sta->last_ack)
-		p += sprintf(p, "last_ack_ms=%d\n",
-			     jiffies_to_msecs(jiffies - sta->last_ack));
-	inactive = jiffies - sta->last_rx;
-	p += sprintf(p, "inactive_msec=%d\n", jiffies_to_msecs(inactive));
-	p += sprintf(p, "channel_use=%d\n", sta->channel_use);
-	p += sprintf(p, "wep_weak_iv_count=%d\n", sta->wep_weak_iv_count);
-#ifdef CONFIG_D80211_DEBUG_COUNTERS
-	p += sprintf(p, "wme_rx_queue=");
-	for (i = 0; i < NUM_RX_DATA_QUEUES; i++)
-		p += sprintf(p, "%u ", sta->wme_rx_queue[i]);
-	p += sprintf(p, "\n");
-
-	p += sprintf(p, "wme_tx_queue=");
-	for (i = 0; i < NUM_RX_DATA_QUEUES; i++)
-		p += sprintf(p, "%u ", sta->wme_tx_queue[i]);
-	p += sprintf(p, "\n");
-#endif /* CONFIG_D80211_DEBUG_COUNTERS */
-	p += sprintf(p, "last_seq_ctrl=");
-	for (i = 0; i < NUM_RX_DATA_QUEUES; i++) {
-			p += sprintf(p, "%x ", sta->last_seq_ctrl[i]);
-	}
-	p += sprintf(p, "\n");
-
-	p += rate_control_status_sta(local, sta, p);
-
-	return (p - page);
-}
-
-
-static int ieee80211_proc_counters_read(char *page, char **start, off_t off,
-					int count, int *eof, void *data)
-{
-	char *p = page;
-	struct ieee80211_local *local = (struct ieee80211_local *) data;
-        struct ieee80211_low_level_stats stats;
-
-	if (off != 0) {
-		*eof = 1;
-		return 0;
-	}
-
-	p += sprintf(p,
-		     "TransmittedFragmentCount=%u\n"
-		     "MulticastTransmittedFrameCount=%u\n"
-		     "FailedCount=%u\n"
-		     "RetryCount=%u\n"
-		     "MultipleRetryCount=%d\n"
-		     "FrameDuplicateCount=%d\n"
-		     "ReceivedFragmentCount=%u\n"
-		     "MulticastReceivedFrameCount=%u\n"
-		     "TransmittedFrameCount=%u\n"
-		     "WEPUndecryptableCount=%u\n",
-		     local->dot11TransmittedFragmentCount,
-		     local->dot11MulticastTransmittedFrameCount,
-		     local->dot11FailedCount,
-		     local->dot11RetryCount,
-		     local->dot11MultipleRetryCount,
-		     local->dot11FrameDuplicateCount,
-		     local->dot11ReceivedFragmentCount,
-		     local->dot11MulticastReceivedFrameCount,
-		     local->dot11TransmittedFrameCount,
-		     local->dot11WEPUndecryptableCount);
-
-	memset(&stats, 0, sizeof(stats));
-	if (local->hw->get_stats &&
-	    local->hw->get_stats(local->mdev, &stats) == 0) {
-		p += sprintf(p,
-			     "ACKFailureCount=%u\n"
-			     "RTSFailureCount=%u\n"
-			     "FCSErrorCount=%u\n"
-			     "RTSSuccessCount=%u\n",
-			     stats.dot11ACKFailureCount,
-			     stats.dot11RTSFailureCount,
-			     stats.dot11FCSErrorCount,
-			     stats.dot11RTSSuccessCount);
-	}
-
-	return (p - page);
-}
-
-
-static int ieee80211_proc_debug_read(char *page, char **start, off_t off,
-				     int count, int *eof, void *data)
-{
-	char *p = page;
-	struct ieee80211_local *local = (struct ieee80211_local *) data;
-
-	if (off != 0) {
-		*eof = 1;
-		return 0;
-	}
-
-#ifdef CONFIG_D80211_DEBUG_COUNTERS
-	p += sprintf(p,
-		     "tx_handlers_drop=%u\n"
-		     "tx_handlers_queued=%u\n"
-		     "tx_handlers_drop_unencrypted=%u\n"
-		     "tx_handlers_drop_fragment=%u\n"
-		     "tx_handlers_drop_wep=%u\n"
-		     "tx_handlers_drop_rate_limit=%u\n"
-		     "tx_handlers_drop_not_assoc=%u\n"
-		     "tx_handlers_drop_unauth_port=%u\n"
-		     "rx_handlers_drop=%u\n"
-		     "rx_handlers_queued=%u\n"
-		     "rx_handlers_drop_nullfunc=%u\n"
-		     "rx_handlers_drop_defrag=%u\n"
-		     "rx_handlers_drop_short=%u\n"
-		     "rx_handlers_drop_passive_scan=%u\n"
-		     "tx_expand_skb_head=%u\n"
-		     "tx_expand_skb_head_cloned=%u\n"
-		     "rx_expand_skb_head=%u\n"
-		     "rx_expand_skb_head2=%u\n"
-		     "rx_handlers_fragments=%u\n"
-		     "tx_status_drop=%u\n",
-		     local->tx_handlers_drop,
-		     local->tx_handlers_queued,
-		     local->tx_handlers_drop_unencrypted,
-		     local->tx_handlers_drop_fragment,
-		     local->tx_handlers_drop_wep,
-		     local->tx_handlers_drop_rate_limit,
-		     local->tx_handlers_drop_not_assoc,
-		     local->tx_handlers_drop_unauth_port,
-		     local->rx_handlers_drop,
-		     local->rx_handlers_queued,
-		     local->rx_handlers_drop_nullfunc,
-		     local->rx_handlers_drop_defrag,
-		     local->rx_handlers_drop_short,
-		     local->rx_handlers_drop_passive_scan,
-		     local->tx_expand_skb_head,
-		     local->tx_expand_skb_head_cloned,
-		     local->rx_expand_skb_head,
-		     local->rx_expand_skb_head2,
-		     local->rx_handlers_fragments,
-		     local->tx_status_drop);
-	{
-		int i;
-		p += sprintf(p, "wme_rx_queue=");
-		for (i = 0; i < NUM_RX_DATA_QUEUES; i++)
-			p += sprintf(p, " %u", local->wme_rx_queue[i]);
-		p += sprintf(p, "\n");
-
-		p += sprintf(p, "wme_tx_queue=");
-		for (i = 0; i < NUM_RX_DATA_QUEUES; i++)
-			p += sprintf(p, " %u", local->wme_tx_queue[i]);
-		p += sprintf(p, "\n");
-	}
-#endif /* CONFIG_D80211_DEBUG_COUNTERS */
-
-	p += sprintf(p, "num_scans=%u\n", local->scan.num_scans);
-
-	return (p - page);
-}
-
-
-const char *ieee80211_mode_str_short(int mode)
-{
-	switch (mode) {
-	case MODE_IEEE80211A:
-		return "802.11a";
-	case MODE_IEEE80211B:
-		return "802.11b";
-	case MODE_IEEE80211G:
-		return "802.11g";
-	case MODE_ATHEROS_TURBO:
-		return "AtherosTurbo";
-	default:
-		return "UNKNOWN";
-	}
-}
-
-
-const char *ieee80211_mode_str(int mode)
-{
-	switch (mode) {
-	case MODE_IEEE80211A:
-		return "IEEE 802.11a";
-	case MODE_IEEE80211B:
-		return "IEEE 802.11b";
-	case MODE_IEEE80211G:
-		return "IEEE 802.11g";
-	case MODE_ATHEROS_TURBO:
-		return "Atheros Turbo (5 GHz)";
-	default:
-		return "UNKNOWN";
-	}
-}
-
-
-static int ieee80211_proc_info_read(char *page, char **start, off_t off,
-				    int count, int *eof, void *data)
-{
-	char *p = page;
-	struct ieee80211_local *local = (struct ieee80211_local *) data;
-	int m;
-	struct ieee80211_hw_modes *mode;
-
-	if (off != 0) {
-		*eof = 1;
-		return 0;
-	}
-
-	p += sprintf(p, "hw_name=%s\n", local->hw->name);
-	p += sprintf(p, "modes=");
-	for (m = 0; m < local->hw->num_modes; m++) {
-		mode = &local->hw->modes[m];
-		p += sprintf(p, "[%s]", ieee80211_mode_str_short(mode->mode));
-	}
-	p += sprintf(p, "\n");
-	if (local->rate_ctrl && local->rate_ctrl_priv)
-		p+= sprintf(p, "rate_ctrl_alg=%s\n", local->rate_ctrl->name);
-	return (p - page);
-}
-
-
-static int ieee80211_proc_config_read(char *page, char **start, off_t off,
-				      int count, int *eof, void *data)
-{
-	char *p = page;
-	struct ieee80211_local *local = (struct ieee80211_local *) data;
-
-	if (off != 0) {
-		*eof = 1;
-		return 0;
-	}
-
-	p += sprintf(p,
-		     "low_level_driver=%s\n"
-		     "channel=%d\n"
-		     "freq=%d\n"
-		     "mode=%s\n"
-			 "802.11h=%d\n"
-		     "wep_iv=0x%06x\n"
-		     "antenna_sel=%d\n"
-		     "calib_int=%d\n"
-		     "tx_power_reduction=%d.%d dBm\n"
-		     "bridge_packets=%d\n"
-		     "key_tx_rx_threshold=%d\n"
-		     "rts_threshold=%d\n"
-		     "fragmentation_threshold=%d\n"
-		     "short_retry_limit=%d\n"
-		     "long_retry_limit=%d\n"
-		     "total_ps_buffered=%d\n",
-		     local->hw->name ? local->hw->name : "N/A",
-		     local->conf.channel,
-		     local->conf.freq,
-		     ieee80211_mode_str(local->conf.phymode),
-			 local->conf.radar_detect,
-		     local->wep_iv & 0xffffff,
-		     local->conf.antenna_sel,
-		     local->conf.calib_int,
-		     local->conf.tx_power_reduction / 10,
-		     local->conf.tx_power_reduction % 10,
-		     local->bridge_packets,
-		     local->key_tx_rx_threshold,
-		     local->rts_threshold,
-		     local->fragmentation_threshold,
-		     local->short_retry_limit,
-		     local->long_retry_limit,
-		     local->total_ps_buffered);
-
-	return (p - page);
-}
-
-
-static int ieee80211_proc_channels_read(char *page, char **start, off_t off,
-					int count, int *eof, void *data)
-{
-	char *p = page;
-	struct ieee80211_local *local = (struct ieee80211_local *) data;
-	int m, c;
-	struct ieee80211_hw_modes *mode;
-	struct ieee80211_channel *chan;
-
-	if (off != 0) {
-		*eof = 1;
-		return 0;
-	}
-
-	p += sprintf(p, "MODE CHAN FREQ TXPOWER ANTMAX FLAGS\n");
-	for (m = 0; m < local->hw->num_modes; m++) {
-		mode = &local->hw->modes[m];
-		for (c = 0; c < mode->num_channels; c++) {
-			chan = &mode->channels[c];
-			p += sprintf(p, "%d %d %d %d %d %s%s%s\n",
-				     mode->mode, chan->chan, chan->freq,
-				     chan->power_level, chan->antenna_max,
-				     chan->flag & IEEE80211_CHAN_W_SCAN ?
-				     "[W_SCAN]" : "",
-				     chan->flag & IEEE80211_CHAN_W_ACTIVE_SCAN
-				     ? "[W_ACTIVE_SCAN]" : "",
-				     chan->flag & IEEE80211_CHAN_W_IBSS ?
-				     "[W_IBSS]" : "");
-		}
-	}
-	return (p - page);
-}
-
-
-static int ieee80211_proc_rates_read(char *page, char **start, off_t off,
-				     int count, int *eof, void *data)
-{
-	char *p = page;
-	struct ieee80211_local *local = (struct ieee80211_local *) data;
-	int r;
-	struct ieee80211_rate *rate;
-
-	if (off != 0) {
-		*eof = 1;
-		return 0;
-	}
-
-	p += sprintf(p, "RATE VAL VAL2 MIN_RSSI_ACK MIN_RSSI_ACK_DELTA "
-		     "FLAGS\n");
-	for (r = 0; r < local->num_curr_rates; r++) {
-		rate = &local->curr_rates[r];
-		p += sprintf(p, "%d %d %d %d %d 0x%x %s%s%s%s%s%s%s%s\n",
-			     rate->rate, rate->val, rate->val2,
-			     rate->min_rssi_ack, rate->min_rssi_ack_delta,
-			     rate->flags,
-			     rate->flags & IEEE80211_RATE_ERP ? "[ERP]" : "",
-			     rate->flags & IEEE80211_RATE_BASIC ?
-			     "[BASIC]" : "",
-			     rate->flags & IEEE80211_RATE_PREAMBLE2 ?
-			     "[PREAMBLE2]" : "",
-			     rate->flags & IEEE80211_RATE_SUPPORTED ?
-			     "[SUPPORTED]" : "",
-			     rate->flags & IEEE80211_RATE_OFDM ? "[OFDM]" : "",
-			     rate->flags & IEEE80211_RATE_CCK ? "[CCK]" : "",
-			     rate->flags & IEEE80211_RATE_TURBO ?
-			     "[TURBO]" : "",
-			     rate->flags & IEEE80211_RATE_MANDATORY ?
-			     "[MANDATORY]" : "");
-	}
-	return (p - page);
-}
-
-
-static int ieee80211_proc_multicast_read(char *page, char **start, off_t off,
-					 int count, int *eof, void *data)
-{
-	char *p = page;
-	struct ieee80211_local *local = (struct ieee80211_local *) data;
-
-	if (off != 0) {
-		*eof = 1;
-		return 0;
-	}
-
-	return rate_control_status_global(local, p);
-
-}
-
-
-void ieee80211_proc_init_sta(struct ieee80211_local *local,
-			     struct sta_info *sta)
-{
-	char buf[30];
-	struct proc_dir_entry *entry;
-
-	sprintf(buf, MACSTR, MAC2STR(sta->addr));
-
-	if (!local->proc_sta)
-		return;
-
-	entry = create_proc_read_entry(buf, 0, local->proc_sta,
-				       ieee80211_proc_sta_read, sta);
-	if (entry) {
-		entry->mode &= ~(S_IRWXG | S_IRWXO);
-	}
-}
-
-
-void ieee80211_proc_deinit_sta(struct ieee80211_local *local,
-			       struct sta_info *sta)
-{
-	char buf[30];
-	sprintf(buf, MACSTR, MAC2STR(sta->addr));
-	if (local->proc_sta) {
-		remove_proc_entry(buf, local->proc_sta);
-	}
-}
-
-
-void ieee80211_proc_init_virtual(struct net_device *dev)
-{
-	struct proc_dir_entry *entry;
-	struct ieee80211_local *local = dev->ieee80211_ptr;
-
-	if (!local->proc_iface)
-		return;
-
-	entry = create_proc_read_entry(dev->name, 0, local->proc_iface,
-				       ieee80211_proc_iface_read, dev);
-	if (entry)
-		entry->mode &= ~(S_IRWXG | S_IRWXO);
-}
-
-
-void ieee80211_proc_deinit_virtual(struct net_device *dev)
-{
-	struct ieee80211_local *local = dev->ieee80211_ptr;
-
-	if (local->proc_iface)
-		remove_proc_entry(dev->name, local->proc_iface);
-}
-
-
-void ieee80211_proc_init_interface(struct ieee80211_local *local)
-{
-	if (!ieee80211_proc)
-		return;
-
-	local->proc = proc_mkdir(local->mdev->name, ieee80211_proc);
-	if (!local->proc)
-		return;
-
-	local->proc_sta = proc_mkdir("sta", local->proc);
-	local->proc_iface = proc_mkdir("iface", local->proc);
-	create_proc_read_entry("counters", 0, local->proc,
-                               ieee80211_proc_counters_read, local);
-	create_proc_read_entry("config", 0, local->proc,
-                               ieee80211_proc_config_read, local);
-	create_proc_read_entry("channels", 0, local->proc,
-                               ieee80211_proc_channels_read, local);
-	create_proc_read_entry("rates", 0, local->proc,
-			       ieee80211_proc_rates_read, local);
-	create_proc_read_entry("multicast", 0, local->proc,
-			       ieee80211_proc_multicast_read, local);
-	create_proc_read_entry("debug", 0, local->proc,
-                               ieee80211_proc_debug_read, local);
-	create_proc_read_entry("info", 0, local->proc,
-			       ieee80211_proc_info_read, local);
-	ieee80211_proc_init_virtual(local->mdev);
-}
-
-
-void ieee80211_proc_deinit_interface(struct ieee80211_local *local)
-{
-	if (!local->proc)
-		return;
-
-	ieee80211_proc_deinit_virtual(local->mdev);
-	remove_proc_entry("iface", local->proc);
-	remove_proc_entry("sta", local->proc);
-        remove_proc_entry("counters", local->proc);
-        remove_proc_entry("debug", local->proc);
-        remove_proc_entry("config", local->proc);
-        remove_proc_entry("channels", local->proc);
-	remove_proc_entry("rates", local->proc);
-	remove_proc_entry("multicast", local->proc);
-	remove_proc_entry("info", local->proc);
-	local->proc = NULL;
-	remove_proc_entry(local->mdev->name, ieee80211_proc);
-}
-
-
-void ieee80211_proc_init(void)
-{
-	if (proc_net == NULL) {
-		ieee80211_proc = NULL;
-		return;
-	}
-
-	ieee80211_proc = proc_mkdir("ieee80211", proc_net);
-	if (!ieee80211_proc)
-		printk(KERN_WARNING "Failed to mkdir /proc/net/ieee80211\n");
-}
-
-
-void ieee80211_proc_deinit(void)
-{
-	if (!ieee80211_proc)
-		return;
-
-	ieee80211_proc = NULL;
-	remove_proc_entry("ieee80211", proc_net);
-}
-
-#endif /* CONFIG_PROC_FS */
diff --git a/net/d80211/ieee80211_proc.h b/net/d80211/ieee80211_proc.h
deleted file mode 100644
index 4519d26..0000000
--- a/net/d80211/ieee80211_proc.h
+++ /dev/null
@@ -1,48 +0,0 @@
-/*
- * Copyright 2003-2004, Instant802 Networks, Inc.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#ifndef IEEE80211_PROC_H
-#define IEEE80211_PROC_H
-
-#include <linux/netdevice.h>
-#include "ieee80211_i.h"
-#include "sta_info.h"
-
-#ifdef CONFIG_PROC_FS
-
-void ieee80211_proc_init_sta(struct ieee80211_local *local,
-			     struct sta_info *sta);
-void ieee80211_proc_deinit_sta(struct ieee80211_local *local,
-			       struct sta_info *sta);
-void ieee80211_proc_init_virtual(struct net_device *dev);
-void ieee80211_proc_deinit_virtual(struct net_device *dev);
-void ieee80211_proc_init_interface(struct ieee80211_local *local);
-void ieee80211_proc_deinit_interface(struct ieee80211_local *local);
-void ieee80211_proc_init(void);
-void ieee80211_proc_deinit(void);
-
-#else /* CONFIG_PROC_FS */
-
-static inline void ieee80211_proc_init_sta(struct ieee80211_local *local,
-					   struct sta_info *sta) {}
-static inline void ieee80211_proc_deinit_sta(struct ieee80211_local *local,
-					     struct sta_info *sta) {}
-static inline void ieee80211_proc_init_virtual(struct net_device *dev) {}
-static inline void ieee80211_proc_deinit_virtual(struct net_device *dev) {}
-static inline void
-ieee80211_proc_init_interface(struct ieee80211_local *local) {}
-static inline void
-ieee80211_proc_deinit_interface(struct ieee80211_local *local) {}
-static inline void ieee80211_proc_init(void) {}
-static inline void ieee80211_proc_deinit(void) {}
-#endif /* CONFIG_PROC_FS */
-
-const char *ieee80211_mode_str(int mode);
-const char *ieee80211_mode_str_short(int mode);
-
-#endif /* IEEE80211_PROC_H */
diff --git a/net/d80211/ieee80211_sysfs.c b/net/d80211/ieee80211_sysfs.c
index 10bf45c..fb1c6b5 100644
--- a/net/d80211/ieee80211_sysfs.c
+++ b/net/d80211/ieee80211_sysfs.c
@@ -14,7 +14,6 @@ #include <linux/netdevice.h>
 #include <linux/rtnetlink.h>
 #include <net/d80211.h>
 #include "ieee80211_i.h"
-#include "ieee80211_proc.h"
 #include "rate_control.h"
 
 #define to_ieee80211_local(class)	container_of(class, struct ieee80211_local, class_dev)
@@ -30,6 +29,38 @@ static inline int rtnl_lock_local(struct
 	return 0;
 }
 
+static const char *ieee80211_mode_str_short(int mode)
+{
+	switch (mode) {
+	case MODE_IEEE80211A:
+		return "802.11a";
+	case MODE_IEEE80211B:
+		return "802.11b";
+	case MODE_IEEE80211G:
+		return "802.11g";
+	case MODE_ATHEROS_TURBO:
+		return "AtherosTurbo";
+	default:
+		return "UNKNOWN";
+	}
+}
+
+static const char *ieee80211_mode_str(int mode)
+{
+	switch (mode) {
+	case MODE_IEEE80211A:
+		return "IEEE 802.11a";
+	case MODE_IEEE80211B:
+		return "IEEE 802.11b";
+	case MODE_IEEE80211G:
+		return "IEEE 802.11g";
+	case MODE_ATHEROS_TURBO:
+		return "Atheros Turbo (5 GHz)";
+	default:
+		return "UNKNOWN";
+	}
+}
+
 /* attributes in /sys/class/ieee80211/phyX/ */
 
 static ssize_t store_add_iface(struct class_device *dev,
diff --git a/net/d80211/rate_control.c b/net/d80211/rate_control.c
index 33ba8e2..bf797ec 100644
--- a/net/d80211/rate_control.c
+++ b/net/d80211/rate_control.c
@@ -327,29 +327,6 @@ static void rate_control_simple_free_sta
 	kfree(rctrl);
 }
 
-
-static int rate_control_simple_status_sta(struct ieee80211_local *local,
-					  struct sta_info *sta, char *buf)
-{
-	char *p = buf;
-	struct sta_rate_control *srctrl = sta->rate_ctrl_priv;
-
-	p += sprintf(p, "tx_avg_rate_sum=%d\n", srctrl->tx_avg_rate_sum);
-	p += sprintf(p, "tx_avg_rate_num=%d\n", srctrl->tx_avg_rate_num);
-	if (srctrl->tx_avg_rate_num)
-		p += sprintf(p, "tx_avg_rate_avg=%d\n",
-			     srctrl->tx_avg_rate_sum /
-			     srctrl->tx_avg_rate_num);
-	return p - buf;
-}
-
-
-static int rate_control_simple_status_global(struct ieee80211_local *local,
-					     char *buf)
-{
-	return 0;
-}
-
 static ssize_t show_sta_tx_avg_rate_sum(const struct sta_info *sta, char *buf)
 {
 	struct sta_rate_control *srctrl = sta->rate_ctrl_priv;
@@ -397,8 +374,6 @@ static struct rate_control_ops rate_cont
 	.get_rate = rate_control_simple_get_rate,
 	.rate_init = rate_control_simple_rate_init,
 	.clear = rate_control_simple_clear,
-	.status_sta = rate_control_simple_status_sta,
-	.status_global = rate_control_simple_status_global,
 	.alloc = rate_control_simple_alloc,
 	.free = rate_control_simple_free,
 	.alloc_sta = rate_control_simple_alloc_sta,
diff --git a/net/d80211/rate_control.h b/net/d80211/rate_control.h
index 7705fb2..d8bdfed 100644
--- a/net/d80211/rate_control.h
+++ b/net/d80211/rate_control.h
@@ -45,9 +45,6 @@ struct rate_control_ops {
 		    struct rate_control_extra *extra);
 	void (*rate_init)(struct ieee80211_local *local, struct sta_info *sta);
 	void (*clear)(void *priv);
-	int (*status_sta)(struct ieee80211_local *local,
-			  struct sta_info *sta, char *buf);
-	int (*status_global)(struct ieee80211_local *local, char *buf);
 
 	void * (*alloc)(struct ieee80211_local *local);
 	void (*free)(void *priv);
@@ -96,20 +93,6 @@ static inline void rate_control_clear(st
 }
 
 
-static inline int rate_control_status_sta(struct ieee80211_local *local,
-					  struct sta_info *sta, char *buf)
-{
-	return local->rate_ctrl->status_sta(local, sta, buf);
-}
-
-
-static inline int rate_control_status_global(struct ieee80211_local *local,
-					     char *buf)
-{
-	return local->rate_ctrl->status_global(local, buf);
-}
-
-
 static inline void * rate_control_alloc(struct ieee80211_local *local)
 {
 	return local->rate_ctrl->alloc(local);
diff --git a/net/d80211/sta_info.c b/net/d80211/sta_info.c
index 96e8dc4..d3b4b42 100644
--- a/net/d80211/sta_info.c
+++ b/net/d80211/sta_info.c
@@ -19,7 +19,6 @@ #include <linux/if_arp.h>
 
 #include <net/d80211.h>
 #include "ieee80211_i.h"
-#include "ieee80211_proc.h"
 #include "rate_control.h"
 
 
@@ -180,7 +179,6 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 		ieee80211_sta_sysfs_add(sta);
 		rate_control_add_sta_attrs(local, sta->rate_ctrl_priv,
 					   &sta->kobj);
-		ieee80211_proc_init_sta(local, sta);
 	} else {
 		/* procfs entry adding might sleep, so schedule process context
 		 * task for adding proc entry for STAs that do not yet have
@@ -200,7 +198,6 @@ #ifdef CONFIG_D80211_VERBOSE_DEBUG
 #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 
 	rate_control_remove_sta_attrs(local, sta->rate_ctrl_priv, &sta->kobj);
-	ieee80211_proc_deinit_sta(local, sta);
 	ieee80211_sta_sysfs_remove(sta);
 
 	sta_info_put(sta);
@@ -371,7 +368,6 @@ static void sta_info_proc_add_task(void 
 		sta->sysfs_registered = 1;
 		ieee80211_sta_sysfs_add(sta);
 		rate_control_add_sta_attrs(local, sta->rate_ctrl_priv, &sta->kobj);
-		ieee80211_proc_init_sta(local, sta);
 		sta_info_put(sta);
 	}
 }
-- 
1.3.0

