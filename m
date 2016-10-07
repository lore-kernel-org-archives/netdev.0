From: Michael Braun <michael-dev@fami-braun.de>
Subject: [PATCH v5 4/4] mac80211: multicast to unicast conversion
Date: Fri,  7 Oct 2016 20:39:34 +0200
Message-ID: <1475865574-5384-4-git-send-email-michael-dev@fami-braun.de>
References: <1475865574-5384-1-git-send-email-michael-dev@fami-braun.de>
Cc: Michael Braun <michael-dev@fami-braun.de>,
        linux-wireless@vger.kernel.org, projekt-wlan@fem.tu-ilmenau.de,
        netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.fem.tu-ilmenau.de ([141.24.220.54]:59447 "EHLO
        mail.fem.tu-ilmenau.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932229AbcJGSjl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2016 14:39:41 -0400
In-Reply-To: <1475865574-5384-1-git-send-email-michael-dev@fami-braun.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for sending multicast data packets with ARP, IPv4
and IPv6 payload (possible 802.1q tagged) as 802.11 unicast frames to all
stations.

IEEE 802.11 multicast has well known issues, among them:
 1. packets are not acked and hence not retransmitted, resulting in
    decreased reliablity
 2. packets are send at low rate, increasing time required on air

When used with AP_VLAN, there is another disadvantage:
 3. all stations in the BSS are woken up, regardsless of their AP_VLAN
    assignment.

By doing multicast to unicast conversion, all three issus are solved.

IEEE802.11-2012 proposes directed multicast service (DMS) using A-MSDU
frames and a station initiated control protocol. It has the advantage that
the station can recover the destination multicast mac address, but it is
not backward compatible with non QOS stations and does not enable the
administrator of a BSS to force this mode of operation within a BSS.
Additionally, it would require both the ap and the station to implement
the control protocol, which is optional on both ends. Furthermore, I've
seen a few mobile phone stations locally that indicate qos support but
won't complete DHCP if their broadcasts are encapsulated as A-MSDU. Though
they work fine with this series approach.

This patch therefore does not opt to implement DMS but instead just
replicates the packet and changes the destination address. As this works
fine with ARP, IPv4 and IPv6, it is limited to these protocols and normal
802.11 multicast frames are send out for all other payload protocols.

There is a runtime toggle to enable multicast conversion in a per-bss
fashion.

When there is only a single station assigned to the AP_VLAN interface, no
packet replication will occur. 4addr mode of operation is unchanged.

This change opts for iterating all BSS stations for finding the stations
assigned to this AP/AP_VLAN interface, as there currently is no per
AP_VLAN list to iterate and multicast packets are expected to be few.
If needed, such a list could be added later.

Signed-off-by: Michael Braun <michael-dev@fami-braun.de>

--
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
 net/mac80211/cfg.c            |  15 +++++++
 net/mac80211/debugfs_netdev.c |   3 ++
 net/mac80211/ieee80211_i.h    |   1 +
 net/mac80211/tx.c             | 101 ++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 120 insertions(+)

diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index 1edb017..1db4c3e 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -2242,6 +2242,20 @@ static int ieee80211_set_wds_peer(struct wiphy *wiphy, struct net_device *dev,
 	return 0;
 }
 
+static int ieee80211_set_multicast_to_unicast(struct wiphy *wiphy,
+					      struct net_device *dev,
+					      const bool enabled)
+{
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+
+	if (sdata->vif.type != NL80211_IFTYPE_AP)
+		return -1;
+
+	sdata->u.ap.multicast_to_unicast = enabled;
+
+	return 0;
+}
+
 static void ieee80211_rfkill_poll(struct wiphy *wiphy)
 {
 	struct ieee80211_local *local = wiphy_priv(wiphy);
@@ -3400,6 +3414,7 @@ const struct cfg80211_ops mac80211_config_ops = {
 	.set_tx_power = ieee80211_set_tx_power,
 	.get_tx_power = ieee80211_get_tx_power,
 	.set_wds_peer = ieee80211_set_wds_peer,
+	.set_multicast_to_unicast = ieee80211_set_multicast_to_unicast,
 	.rfkill_poll = ieee80211_rfkill_poll,
 	CFG80211_TESTMODE_CMD(ieee80211_testmode_cmd)
 	CFG80211_TESTMODE_DUMP(ieee80211_testmode_dump)
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
index c3ce86e..142201d 100644
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
@@ -1770,6 +1771,102 @@ bool ieee80211_tx_prepare_skb(struct ieee80211_hw *hw,
 }
 EXPORT_SYMBOL(ieee80211_tx_prepare_skb);
 
+/* rewrite destination mac address */
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
+/* Check if multicast to unicast conversion is needed and do it.
+ * Returns 1 if skb was freed and should not be send out.
+ */
+static int
+ieee80211_tx_multicast_to_unicast(struct ieee80211_sub_if_data *sdata,
+				  struct sk_buff *skb, u32  info_flags)
+{
+	struct ieee80211_local *local = sdata->local;
+	const struct ethhdr *eth = (void *)skb->data;
+	const struct vlan_ethhdr *ethvlan = (void *)skb->data;
+	struct sta_info *sta, *prev = NULL;
+	struct sk_buff *cloned_skb;
+	u16 ethertype;
+
+	/* check if this is a multicast frame */
+	if (!is_multicast_ether_addr(eth->h_dest))
+		return 0;
+
+	/* multicast to unicast conversion only for AP interfaces */
+	switch (sdata->vif.type) {
+	case NL80211_IFTYPE_AP_VLAN:
+		sta = rcu_dereference(sdata->u.vlan.sta);
+		if (sta) /* 4addr */
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
+	/* info_flags would not get preserved, used only by TLDS */
+	if (info_flags)
+		return 0;
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
+	/* clone packets and update destination mac */
+	list_for_each_entry_rcu(sta, &local->sta_list, list) {
+		if (sdata != sta->sdata)
+			continue;
+		if (unlikely(!ether_addr_equal(eth->h_source, sta->sta.addr)))
+			/* do not send back to source */
+			continue;
+		if (!prev) {
+			prev = sta;
+			continue;
+		}
+		cloned_skb = skb_clone(skb, GFP_ATOMIC);
+		if (unlikely(ieee80211_change_da(cloned_skb, prev))) {
+			dev_kfree_skb(cloned_skb);
+			continue;
+		}
+		__ieee80211_subif_start_xmit(cloned_skb, cloned_skb->dev, 0);
+		prev = sta;
+	}
+
+	if (likely(prev)) {
+		ieee80211_change_da(skb, prev);
+		return 0;
+	}
+
+	/* no STA connected, drop */
+	return 1;
+}
+
 /*
  * Returns false if the frame couldn't be transmitted but was queued instead.
  */
@@ -3353,6 +3450,10 @@ void __ieee80211_subif_start_xmit(struct sk_buff *skb,
 
 	rcu_read_lock();
 
+	/* AP multicast to unicast conversion */
+	if (ieee80211_tx_multicast_to_unicast(sdata, skb, info_flags))
+		goto out_free;
+
 	if (ieee80211_lookup_ra_sta(sdata, skb, &sta))
 		goto out_free;
 
-- 
2.1.4
