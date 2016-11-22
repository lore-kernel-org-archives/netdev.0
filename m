From: Michael Braun <michael-dev@fami-braun.de>
Subject: [PATCH v8] mac80211: multicast to unicast conversion
Date: Tue, 22 Nov 2016 11:52:18 +0100
Message-ID: <1479811938-728-1-git-send-email-michael-dev@fami-braun.de>
Cc: Michael Braun <michael-dev@fami-braun.de>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        projekt-wlan@fem.tu-ilmenau.de
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.fem.tu-ilmenau.de ([141.24.220.54]:35976 "EHLO
        mail.fem.tu-ilmenau.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932274AbcKVKw2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 05:52:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the ability for an AP (and associated VLANs) to perform
multicast-to-unicast conversion for ARP, IPv4 and IPv6 frames
(possibly within 802.1Q). If enabled, such frames are to be sent
to each station separately, with the DA replaced by their own
MAC address rather than the group address.

Note that this may break certain expectations of the receiver,
such as the ability to drop unicast IP packets received within
multicast L2 frames, or the ability to not send ICMP destination
unreachable messages for packets received in L2 multicast (which
is required, but the receiver can't tell the difference if this
new option is enabled.)

This also doesn't implement the 802.11 DMS (directed multicast
service).

Signed-off-by: Michael Braun <michael-dev@fami-braun.de>

--
v8:
  - remove superflous check
  - change return type to bool
v7:
  - avoid recursion
  - style and description
v5:
  - rename bss->unicast to bss->multicast_to_unicast
  - access sdata->bss only after checking iftype
v4:
  - rename MULTICAST_TO_UNICAST to MULTICAST_TO_UNICAST
v3: fix compile error for trace.h
v2: add nl80211 toggle
    rename tx_dnat to change_da
    change int to bool unicast
---
 net/mac80211/cfg.c            |  12 +++++
 net/mac80211/debugfs_netdev.c |   3 ++
 net/mac80211/ieee80211_i.h    |   1 +
 net/mac80211/tx.c             | 122 +++++++++++++++++++++++++++++++++++++++++-
 4 files changed, 137 insertions(+), 1 deletion(-)

diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index 1edb017..7de342a 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -3345,6 +3345,17 @@ static int ieee80211_del_tx_ts(struct wiphy *wiphy, struct net_device *dev,
 	return -ENOENT;
 }
 
+static int ieee80211_set_multicast_to_unicast(struct wiphy *wiphy,
+					      struct net_device *dev,
+					      const bool enabled)
+{
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+
+	sdata->u.ap.multicast_to_unicast = enabled;
+
+	return 0;
+}
+
 const struct cfg80211_ops mac80211_config_ops = {
 	.add_virtual_intf = ieee80211_add_iface,
 	.del_virtual_intf = ieee80211_del_iface,
@@ -3430,4 +3441,5 @@ const struct cfg80211_ops mac80211_config_ops = {
 	.set_ap_chanwidth = ieee80211_set_ap_chanwidth,
 	.add_tx_ts = ieee80211_add_tx_ts,
 	.del_tx_ts = ieee80211_del_tx_ts,
+	.set_multicast_to_unicast = ieee80211_set_multicast_to_unicast,
 };
diff --git a/net/mac80211/debugfs_netdev.c b/net/mac80211/debugfs_netdev.c
index ed7bff4..509c6c3 100644
--- a/net/mac80211/debugfs_netdev.c
+++ b/net/mac80211/debugfs_netdev.c
@@ -487,6 +487,8 @@ static ssize_t ieee80211_if_fmt_num_buffered_multicast(
 }
 IEEE80211_IF_FILE_R(num_buffered_multicast);
 
+IEEE80211_IF_FILE(multicast_to_unicast, u.ap.multicast_to_unicast, HEX);
+
 /* IBSS attributes */
 static ssize_t ieee80211_if_fmt_tsf(
 	const struct ieee80211_sub_if_data *sdata, char *buf, int buflen)
@@ -642,6 +644,7 @@ static void add_ap_files(struct ieee80211_sub_if_data *sdata)
 	DEBUGFS_ADD(dtim_count);
 	DEBUGFS_ADD(num_buffered_multicast);
 	DEBUGFS_ADD_MODE(tkip_mic_test, 0200);
+	DEBUGFS_ADD_MODE(multicast_to_unicast, 0600);
 }
 
 static void add_vlan_files(struct ieee80211_sub_if_data *sdata)
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 70c0963..84374ed 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -293,6 +293,7 @@ struct ieee80211_if_ap {
 			 driver_smps_mode; /* smps mode request */
 
 	struct work_struct request_smps_work;
+	bool multicast_to_unicast;
 };
 
 struct ieee80211_if_wds {
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index c3ce86e..5effffd 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -16,6 +16,7 @@
 #include <linux/kernel.h>
 #include <linux/slab.h>
 #include <linux/skbuff.h>
+#include <linux/if_vlan.h>
 #include <linux/etherdevice.h>
 #include <linux/bitmap.h>
 #include <linux/rcupdate.h>
@@ -3418,6 +3419,115 @@ void __ieee80211_subif_start_xmit(struct sk_buff *skb,
 	rcu_read_unlock();
 }
 
+static int ieee80211_change_da(struct sk_buff *skb, struct sta_info *sta)
+{
+	struct ethhdr *eth;
+	int err;
+
+	err = skb_ensure_writable(skb, ETH_HLEN);
+	if (unlikely(err))
+		return err;
+
+	eth = (void *)skb->data;
+	ether_addr_copy(eth->h_dest, sta->sta.addr);
+
+	return 0;
+}
+
+static inline bool
+ieee80211_multicast_to_unicast(struct sk_buff *skb, struct net_device *dev)
+{
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	const struct ethhdr *eth = (void *)skb->data;
+	const struct vlan_ethhdr *ethvlan = (void *)skb->data;
+	u16 ethertype;
+
+	if (likely(!is_multicast_ether_addr(eth->h_dest)))
+		return 0;
+
+	switch (sdata->vif.type) {
+	case NL80211_IFTYPE_AP_VLAN:
+		if (sdata->u.vlan.sta)
+			return 0;
+		if (sdata->wdev.use_4addr)
+			return 0;
+		/* fall through */
+	case NL80211_IFTYPE_AP:
+		/* check runtime toggle for this bss */
+		if (!sdata->bss->multicast_to_unicast)
+			return 0;
+		break;
+	default:
+		return 0;
+	}
+
+	/* multicast to unicast conversion only for some payload */
+	ethertype = ntohs(eth->h_proto);
+	if (ethertype == ETH_P_8021Q && skb->len >= VLAN_ETH_HLEN)
+		ethertype = ntohs(ethvlan->h_vlan_encapsulated_proto);
+	switch (ethertype) {
+	case ETH_P_ARP:
+	case ETH_P_IP:
+	case ETH_P_IPV6:
+		break;
+	default:
+		return 0;
+	}
+
+	return 1;
+}
+
+static void
+ieee80211_convert_to_unicast(struct sk_buff *skb, struct net_device *dev,
+			     struct sk_buff_head *queue)
+{
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	struct ieee80211_local *local = sdata->local;
+	const struct ethhdr *eth = (struct ethhdr *)skb->data;
+	struct sta_info *sta, *first = NULL;
+	struct sk_buff *cloned_skb;
+
+	rcu_read_lock();
+
+	list_for_each_entry_rcu(sta, &local->sta_list, list) {
+		if (sdata != sta->sdata)
+			/* AP-VLAN mismatch */
+			continue;
+		if (unlikely(ether_addr_equal(eth->h_source, sta->sta.addr)))
+			/* do not send back to source */
+			continue;
+		if (!first) {
+			first = sta;
+			continue;
+		}
+		cloned_skb = skb_clone(skb, GFP_ATOMIC);
+		if (!cloned_skb)
+			goto unicast;
+		if (unlikely(ieee80211_change_da(cloned_skb, sta))) {
+			dev_kfree_skb(cloned_skb);
+			goto unicast;
+		}
+		__skb_queue_tail(queue, cloned_skb);
+	}
+
+	if (likely(first)) {
+		if (unlikely(ieee80211_change_da(skb, first)))
+			goto unicast;
+		__skb_queue_tail(queue, skb);
+	} else {
+		/* no STA connected, drop */
+		kfree_skb(skb);
+		skb = NULL;
+	}
+
+	goto out;
+unicast:
+	__skb_queue_purge(queue);
+	__skb_queue_tail(queue, skb);
+out:
+	rcu_read_unlock();
+}
+
 /**
  * ieee80211_subif_start_xmit - netif start_xmit function for 802.3 vifs
  * @skb: packet to be sent
@@ -3428,7 +3538,17 @@ void __ieee80211_subif_start_xmit(struct sk_buff *skb,
 netdev_tx_t ieee80211_subif_start_xmit(struct sk_buff *skb,
 				       struct net_device *dev)
 {
-	__ieee80211_subif_start_xmit(skb, dev, 0);
+	if (unlikely(ieee80211_multicast_to_unicast(skb, dev))) {
+		struct sk_buff_head queue;
+
+		__skb_queue_head_init(&queue);
+		ieee80211_convert_to_unicast(skb, dev, &queue);
+		while ((skb = __skb_dequeue(&queue)))
+			__ieee80211_subif_start_xmit(skb, dev, 0);
+	} else {
+		__ieee80211_subif_start_xmit(skb, dev, 0);
+	}
+
 	return NETDEV_TX_OK;
 }
 
-- 
2.1.4
