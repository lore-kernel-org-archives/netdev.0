From: Johannes Berg <johannes@sipsolutions.net>
Subject: [RFC 3/3] mac80211: support bpf monitor filter
Date: Wed, 12 Apr 2017 13:07:26 +0200
Message-ID: <20170412110726.9689-3-johannes@sipsolutions.net>
References: <20170412110726.9689-1-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:35294 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753792AbdDLLHh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 07:07:37 -0400
In-Reply-To: <20170412110726.9689-1-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

Add the necessary hooks for running monitor filter programs
in mac80211's RX path, before a frame is handed off to a
monitor interface. If the frame isn't accepted then this
will save the overhead of creating a new SKB and building
the radiotap header.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 net/mac80211/Kconfig       |  1 +
 net/mac80211/cfg.c         | 13 +++++++++++++
 net/mac80211/ieee80211_i.h |  6 ++++++
 net/mac80211/iface.c       |  9 ++++++++-
 net/mac80211/main.c        |  3 +++
 net/mac80211/rx.c          | 45 +++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 76 insertions(+), 1 deletion(-)

diff --git a/net/mac80211/Kconfig b/net/mac80211/Kconfig
index 76e30f4797fb..080e0c705c72 100644
--- a/net/mac80211/Kconfig
+++ b/net/mac80211/Kconfig
@@ -8,6 +8,7 @@ config MAC80211
 	select CRYPTO_GCM
 	select CRYPTO_CMAC
 	select CRC32
+	select WANT_BPF_WIFIMON
 	---help---
 	  This option enables the hardware independent IEEE 802.11
 	  networking stack.
diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index 4ff03c88022e..c394c08ed0e0 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -106,6 +106,19 @@ static int ieee80211_set_mon_options(struct ieee80211_sub_if_data *sdata,
 		}
 	}
 
+	if (params->filter) {
+		struct bpf_prog *old = rtnl_dereference(sdata->u.mntr.filter);
+
+		if (IS_ERR(params->filter))
+			RCU_INIT_POINTER(sdata->u.mntr.filter, NULL);
+		else
+			rcu_assign_pointer(sdata->u.mntr.filter,
+					   params->filter);
+
+		if (old)
+			bpf_prog_put(old);
+	}
+
 	return 0;
 }
 
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 0e718437d080..06a2e2cdde83 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -27,6 +27,8 @@
 #include <linux/leds.h>
 #include <linux/idr.h>
 #include <linux/rhashtable.h>
+#include <linux/filter.h>
+#include <linux/bpf.h>
 #include <net/ieee80211_radiotap.h>
 #include <net/cfg80211.h>
 #include <net/mac80211.h>
@@ -839,6 +841,10 @@ struct txq_info {
 struct ieee80211_if_mntr {
 	u32 flags;
 	u8 mu_follow_addr[ETH_ALEN] __aligned(2);
+#ifdef CONFIG_BPF_WIFIMON
+	struct bpf_prog *filter;
+	bool deliver;
+#endif
 };
 
 /**
diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index 5bb0c5012819..05258fd9dda2 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -1107,8 +1107,15 @@ static void ieee80211_teardown_sdata(struct ieee80211_sub_if_data *sdata)
 		__skb_queue_purge(&sdata->fragments[i].skb_list);
 	sdata->fragment_next = 0;
 
-	if (ieee80211_vif_is_mesh(&sdata->vif))
+	if (ieee80211_vif_is_mesh(&sdata->vif)) {
 		ieee80211_mesh_teardown_sdata(sdata);
+	} else if (sdata->vif.type == NL80211_IFTYPE_MONITOR) {
+		struct bpf_prog *old = rtnl_dereference(sdata->u.mntr.filter);
+
+		RCU_INIT_POINTER(sdata->u.mntr.filter, NULL);
+		if (old)
+			bpf_prog_put(old);
+	}
 }
 
 static void ieee80211_uninit(struct net_device *dev)
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index 56fb47953b72..e9d13dedcca4 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -551,6 +551,9 @@ struct ieee80211_hw *ieee80211_alloc_hw_nm(size_t priv_data_len,
 			   NL80211_FEATURE_FULL_AP_CLIENT_STATE;
 	wiphy_ext_feature_set(wiphy, NL80211_EXT_FEATURE_FILS_STA);
 
+	if (IS_ENABLED(CONFIG_BPF_WIFIMON))
+		wiphy_ext_feature_isset(wiphy, NL80211_EXT_FEATURE_WIFIMON_BPF);
+
 	if (!ops->hw_scan)
 		wiphy->features |= NL80211_FEATURE_LOW_PRIORITY_SCAN |
 				   NL80211_FEATURE_AP_SCAN;
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 335c7843169f..8c811deaf3cd 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -508,6 +508,7 @@ ieee80211_rx_monitor(struct ieee80211_local *local, struct sk_buff *origskb,
 	struct ieee80211_mgmt *mgmt;
 	struct ieee80211_sub_if_data *monitor_sdata =
 		rcu_dereference(local->monitor_sdata);
+	bool deliver __maybe_unused = false;
 
 	if (unlikely(status->flag & RX_FLAG_RADIOTAP_VENDOR_DATA)) {
 		struct ieee80211_vendor_radiotap *rtap = (void *)origskb->data;
@@ -552,6 +553,45 @@ ieee80211_rx_monitor(struct ieee80211_local *local, struct sk_buff *origskb,
 		return origskb;
 	}
 
+#ifdef CONFIG_BPF_WIFIMON
+	/* pretend all the monitor info isn't there */
+	__pskb_pull(origskb, rtap_vendor_space);
+	origskb->len -= present_fcs_len;
+
+	list_for_each_entry_rcu(sdata, &local->interfaces, list) {
+		const struct bpf_prog *filter;
+
+		if (sdata->vif.type != NL80211_IFTYPE_MONITOR)
+			continue;
+
+		if (sdata->u.mntr.flags & MONITOR_FLAG_COOK_FRAMES)
+			continue;
+
+		if (!ieee80211_sdata_running(sdata))
+			continue;
+
+		filter = rcu_dereference(sdata->u.mntr.filter);
+		if (filter) {
+			sdata->u.mntr.deliver = BPF_PROG_RUN(filter, origskb);
+			if (sdata->u.mntr.deliver)
+				deliver = true;
+		} else {
+			sdata->u.mntr.deliver = true;
+			deliver = true;
+		}
+	}
+
+	/* stop pretending the monitor info isn't there */
+	origskb->len += present_fcs_len;
+	__skb_push(origskb, rtap_vendor_space);
+
+	if (!deliver) {
+		remove_monitor_info(local, origskb, present_fcs_len,
+				    rtap_vendor_space);
+		return origskb;
+	}
+#endif
+
 	/* room for the radiotap header based on driver features */
 	rt_hdrlen = ieee80211_rx_radiotap_hdrlen(local, status, origskb);
 	needed_headroom = rt_hdrlen - rtap_vendor_space;
@@ -598,11 +638,16 @@ ieee80211_rx_monitor(struct ieee80211_local *local, struct sk_buff *origskb,
 		if (sdata->vif.type != NL80211_IFTYPE_MONITOR)
 			continue;
 
+#ifdef CONFIG_BPF_WIFIMON
+		if (!sdata->u.mntr.deliver)
+			continue;
+#else
 		if (sdata->u.mntr.flags & MONITOR_FLAG_COOK_FRAMES)
 			continue;
 
 		if (!ieee80211_sdata_running(sdata))
 			continue;
+#endif
 
 		if (prev_dev) {
 			skb2 = skb_clone(skb, GFP_ATOMIC);
-- 
2.11.0
