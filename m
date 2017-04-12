From: Johannes Berg <johannes@sipsolutions.net>
Subject: [RFC 2/3] cfg80211: add API to attach monitor filter program
Date: Wed, 12 Apr 2017 13:07:25 +0200
Message-ID: <20170412110726.9689-2-johannes@sipsolutions.net>
References: <20170412110726.9689-1-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:35290 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753789AbdDLLHh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 07:07:37 -0400
In-Reply-To: <20170412110726.9689-1-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

Some people have suggested that the nl80211 API to look at
management frames should be extended to allow multiple
registrations, in order to allow applications other than
the usual controllers (wpa_supplicant/hostapd) to look out
for frames, e.g. for statistics or similar. Suggestions to
use monitor interfaces were rejected, because the overhead
is too big, even when a socket filter is installed. Adding
this to the nl80211 API is, however, problematic because
it then becomes undefined who is responsible for a frame,
e.g. when action frames have multiple listeners - but only
one can be responsible for handling them.

To solve this problem, we can allow installing a BPF filter
program that gets run on the raw 802.11 frame received from
the driver, before the frame is even considered for copying
the SKB or building the radiotap header for a given monitor
interface.

Add the necessary API to attach a monitor filter program
to a newly created monitor interface, or allow changing
it. Also allow clearing it by passing -1 as the FD.

NOTE/WARNING
We really should first figure out what we want to do with
802.3 frames that are received by the driver. Do they at
all show up on monitor? For the use case described above,
that doesn't matter - however, it's easy to imagine other
use cases, like using BPF for packet statistics (like the
never-merged per-rate statistics), and then seeing data
frames as well would be good. Perhaps the program can get
a different metadata struct rather than __sk_buff, that
indiciates whether the frames has 802.11 or 802.3 format?
However, if it already has 802.3 format, the TA might no
longer be present (in AP -> STA frames), which would then
no longer allow collecting such statistics anyway ...

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 include/net/cfg80211.h       |  3 +++
 include/uapi/linux/nl80211.h |  7 +++++++
 net/wireless/core.c          |  5 +++++
 net/wireless/nl80211.c       | 27 +++++++++++++++++++++++++++
 4 files changed, 42 insertions(+)

diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
index a8faf9f0cac2..a59a8917a74c 100644
--- a/include/net/cfg80211.h
+++ b/include/net/cfg80211.h
@@ -376,6 +376,8 @@ static inline void wiphy_read_of_freq_limits(struct wiphy *wiphy)
  *	belonging to that MU-MIMO groupID; %NULL if not changed
  * @vht_mumimo_follow_addr: MU-MIMO follow address, used for monitoring
  *	MU-MIMO packets going to the specified station; %NULL if not changed
+ * @filter: wifi monitor BPF program, %NULL if not changed, an ERR_PTR()
+ *	if the program should be removed
  */
 struct vif_params {
 	u32 flags;
@@ -383,6 +385,7 @@ struct vif_params {
 	u8 macaddr[ETH_ALEN];
 	const u8 *vht_mumimo_groups;
 	const u8 *vht_mumimo_follow_addr;
+	struct bpf_prog *filter;
 };
 
 /**
diff --git a/include/uapi/linux/nl80211.h b/include/uapi/linux/nl80211.h
index 5ed257c4cd4e..4a33cac2a41a 100644
--- a/include/uapi/linux/nl80211.h
+++ b/include/uapi/linux/nl80211.h
@@ -2012,6 +2012,8 @@ enum nl80211_commands {
  *	u32 attribute with an &enum nl80211_timeout_reason value. This is used,
  *	e.g., with %NL80211_CMD_CONNECT event.
  *
+ * @NL80211_ATTR_BPF_FD: BPF file descriptor (s32), use -1 to remove a program
+ *
  * @NUM_NL80211_ATTR: total number of nl80211_attrs available
  * @NL80211_ATTR_MAX: highest attribute number currently defined
  * @__NL80211_ATTR_AFTER_LAST: internal use
@@ -2423,6 +2425,8 @@ enum nl80211_attrs {
 
 	NL80211_ATTR_TIMEOUT_REASON,
 
+	NL80211_ATTR_BPF_FD,
+
 	/* add attributes here, update the policy in nl80211.c */
 
 	__NL80211_ATTR_AFTER_LAST,
@@ -4753,6 +4757,8 @@ enum nl80211_feature_flags {
  * @NL80211_EXT_FEATURE_SCHED_SCAN_RELATIVE_RSSI: The driver supports sched_scan
  *	for reporting BSSs with better RSSI than the current connected BSS
  *	(%NL80211_ATTR_SCHED_SCAN_RELATIVE_RSSI).
+ * @NL80211_EXT_FEATURE_WIFIMON_BPF: supports running BPF filter programs
+ *	for frames seen on monitor interfaces
  *
  * @NUM_NL80211_EXT_FEATURES: number of extended features.
  * @MAX_NL80211_EXT_FEATURES: highest extended feature index.
@@ -4771,6 +4777,7 @@ enum nl80211_ext_feature_index {
 	NL80211_EXT_FEATURE_MGMT_TX_RANDOM_TA,
 	NL80211_EXT_FEATURE_MGMT_TX_RANDOM_TA_CONNECTED,
 	NL80211_EXT_FEATURE_SCHED_SCAN_RELATIVE_RSSI,
+	NL80211_EXT_FEATURE_WIFIMON_BPF,
 
 	/* add new features before the definition below */
 	NUM_NL80211_EXT_FEATURES,
diff --git a/net/wireless/core.c b/net/wireless/core.c
index e55e05bc4805..6d9a38e9a375 100644
--- a/net/wireless/core.c
+++ b/net/wireless/core.c
@@ -691,6 +691,11 @@ int wiphy_register(struct wiphy *wiphy)
 		    (wiphy->bss_select_support & ~(BIT(__NL80211_BSS_SELECT_ATTR_AFTER_LAST) - 2))))
 		return -EINVAL;
 
+	if (WARN_ON(!IS_ENABLED(CONFIG_BPF_WIFIMON) &&
+		    wiphy_ext_feature_isset(wiphy,
+					    NL80211_EXT_FEATURE_WIFIMON_BPF)))
+		return -EINVAL;
+
 	if (wiphy->addresses)
 		memcpy(wiphy->perm_addr, wiphy->addresses[0].addr, ETH_ALEN);
 
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 9516840b6e5f..505e6db633c6 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -17,6 +17,7 @@
 #include <linux/rtnetlink.h>
 #include <linux/netlink.h>
 #include <linux/etherdevice.h>
+#include <linux/bpf.h>
 #include <net/net_namespace.h>
 #include <net/genetlink.h>
 #include <net/cfg80211.h>
@@ -410,6 +411,7 @@ static const struct nla_policy nl80211_policy[NUM_NL80211_ATTR] = {
 		.len = sizeof(struct nl80211_bss_select_rssi_adjust)
 	},
 	[NL80211_ATTR_TIMEOUT_REASON] = { .type = NLA_U32 },
+	[NL80211_ATTR_BPF_FD] = { .type = NLA_U32 },
 };
 
 /* policy for the key attributes */
@@ -2768,6 +2770,28 @@ static int nl80211_parse_mon_options(struct cfg80211_registered_device *rdev,
 		change = true;
 	}
 
+	if (info->attrs[NL80211_ATTR_BPF_FD]) {
+		struct bpf_prog *prog = ERR_PTR(-ENODATA);
+		int fd = nla_get_s32(info->attrs[NL80211_ATTR_BPF_FD]);
+		u32 cap_flag = NL80211_EXT_FEATURE_WIFIMON_BPF;
+
+		if (!IS_ENABLED(CONFIG_BPF_WIFIMON) ||
+		    !wiphy_ext_feature_isset(&rdev->wiphy, cap_flag))
+			return -EOPNOTSUPP;
+
+		if (type != NL80211_IFTYPE_MONITOR)
+			return -EINVAL;
+
+		if (fd >= 0) {
+			prog = bpf_prog_get_type(fd, BPF_PROG_TYPE_WIFIMON);
+			if (IS_ERR(prog))
+				return PTR_ERR(prog);
+		}
+
+		params->filter = prog;
+		change = true;
+	}
+
 	return change ? 1 : 0;
 }
 
@@ -2857,6 +2881,9 @@ static int nl80211_set_interface(struct sk_buff *skb, struct genl_info *info)
 	else
 		err = 0;
 
+	if (err && params.filter)
+		bpf_prog_put(params.filter);
+
 	if (!err && params.use_4addr != -1)
 		dev->ieee80211_ptr->use_4addr = params.use_4addr;
 
-- 
2.11.0
