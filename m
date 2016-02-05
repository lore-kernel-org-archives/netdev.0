From: Cedric DEBARGE <cedric.debarge-eYuUwLwYA0BQFI55V6+gNQ@public.gmane.org>
Subject: [RFC 2/2] nl80211: add nl attribute to set ht_caps mcs rxmask override
Date: Fri,  5 Feb 2016 16:42:00 +0100
Message-ID: <ac5a5448d9afba8a13a6b04294d1bca00eec0757.1454685673.git.cedric.debarge@acksys.fr>
References: <cover.1454685673.git.cedric.debarge@acksys.fr>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Cedric DEBARGE <cedric.debarge-eYuUwLwYA0BQFI55V6+gNQ@public.gmane.org>
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cover.1454685673.git.cedric.debarge-eYuUwLwYA0BQFI55V6+gNQ@public.gmane.org>
In-Reply-To: <cover.1454685673.git.cedric.debarge-eYuUwLwYA0BQFI55V6+gNQ@public.gmane.org>
References: <cover.1454685673.git.cedric.debarge-eYuUwLwYA0BQFI55V6+gNQ@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This adds the NL80211_ATTR_WIPHY_HTCAP_RXMASK attribute to
NL80211_CMD_SET_WIPHY in order for the user to specify the ht_caps mcs
rxmask.

Signed-off-by: Cedric Debarge <cedric.debarge-eYuUwLwYA0BQFI55V6+gNQ@public.gmane.org>
---
 include/uapi/linux/nl80211.h |  5 +++++
 net/wireless/nl80211.c       | 18 ++++++++++++++++++
 net/wireless/rdev-ops.h      | 11 +++++++++++
 net/wireless/trace.h         | 15 +++++++++++++++
 4 files changed, 49 insertions(+)

diff --git a/include/uapi/linux/nl80211.h b/include/uapi/linux/nl80211.h
index 7758969..50a53d8 100644
--- a/include/uapi/linux/nl80211.h
+++ b/include/uapi/linux/nl80211.h
@@ -1794,6 +1794,9 @@ enum nl80211_commands {
  *	connecting to a PCP, and in %NL80211_CMD_START_AP to start
  *	a PCP instead of AP. Relevant for DMG networks only.
  *
+ * @NL80211_ATTR_WIPHY_HTCAP_RXMASK: Override hardware capabilities for ht_caps
+ *	mcs rxmask.
+ *
  * @NUM_NL80211_ATTR: total number of nl80211_attrs available
  * @NL80211_ATTR_MAX: highest attribute number currently defined
  * @__NL80211_ATTR_AFTER_LAST: internal use
@@ -2170,6 +2173,8 @@ enum nl80211_attrs {
 
 	NL80211_ATTR_PBSS,
 
+	NL80211_ATTR_WIPHY_HTCAP_RXMASK,
+
 	/* add attributes here, update the policy in nl80211.c */
 
 	__NL80211_ATTR_AFTER_LAST,
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 268cb49..ef5ec8b 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -402,6 +402,9 @@ static const struct nla_policy nl80211_policy[NUM_NL80211_ATTR] = {
 	[NL80211_ATTR_SCHED_SCAN_DELAY] = { .type = NLA_U32 },
 	[NL80211_ATTR_REG_INDOOR] = { .type = NLA_FLAG },
 	[NL80211_ATTR_PBSS] = { .type = NLA_FLAG },
+	[NL80211_ATTR_WIPHY_HTCAP_RXMASK] = { .type = NLA_BINARY,
+					      .len = IEEE80211_HT_MCS_MASK_LEN
+	},
 };
 
 /* policy for the key attributes */
@@ -2243,6 +2246,21 @@ static int nl80211_set_wiphy(struct sk_buff *skb, struct genl_info *info)
 			return result;
 	}
 
+	if (info->attrs[NL80211_ATTR_WIPHY_HTCAP_RXMASK]) {
+		u8 rxmask[IEEE80211_HT_MCS_MASK_LEN];
+
+		if (wdev)
+			return -EOPNOTSUPP;
+
+		memcpy(rxmask,
+		       nla_data(info->attrs[NL80211_ATTR_WIPHY_HTCAP_RXMASK]),
+		       IEEE80211_HT_MCS_MASK_LEN);
+
+		result = rdev_set_htcap_rxmask(rdev, rxmask);
+		if (result)
+			return result;
+	}
+
 	changed = 0;
 
 	if (info->attrs[NL80211_ATTR_WIPHY_RETRY_SHORT]) {
diff --git a/net/wireless/rdev-ops.h b/net/wireless/rdev-ops.h
index 8ae0c04..488adb9 100644
--- a/net/wireless/rdev-ops.h
+++ b/net/wireless/rdev-ops.h
@@ -1071,4 +1071,15 @@ rdev_set_coalesce(struct cfg80211_registered_device *rdev,
 	trace_rdev_return_int(&rdev->wiphy, ret);
 	return ret;
 }
+
+static inline int
+rdev_set_htcap_rxmask(struct cfg80211_registered_device *rdev, uint8_t *rxmask)
+{
+	int ret;
+
+	trace_rdev_set_htcap_rxmask(&rdev->wiphy, rxmask);
+	ret = rdev->ops->set_htcap_rxmask(&rdev->wiphy, rxmask);
+	trace_rdev_return_int(&rdev->wiphy, ret);
+	return ret;
+}
 #endif /* __CFG80211_RDEV_OPS */
diff --git a/net/wireless/trace.h b/net/wireless/trace.h
index 09b242b..d7c8c3c 100644
--- a/net/wireless/trace.h
+++ b/net/wireless/trace.h
@@ -2120,6 +2120,21 @@ TRACE_EVENT(rdev_tdls_cancel_channel_switch,
 		  WIPHY_PR_ARG, NETDEV_PR_ARG, MAC_PR_ARG(addr))
 );
 
+TRACE_EVENT(rdev_set_htcap_rxmask,
+	TP_PROTO(struct wiphy *wiphy, uint8_t *rxmask),
+	TP_ARGS(wiphy, rxmask),
+	TP_STRUCT__entry(
+		WIPHY_ENTRY
+		__array(uint8_t, rxmask, IEEE80211_HT_MCS_MASK_LEN)
+	),
+	TP_fast_assign(
+		WIPHY_ASSIGN;
+		memcpy(__entry->rxmask, rxmask, IEEE80211_HT_MCS_MASK_LEN);
+	),
+	TP_printk(WIPHY_PR_FMT ", %*ph",
+		  WIPHY_PR_ARG, IEEE80211_HT_MCS_MASK_LEN, &__entry->rxmask[0])
+);
+
 /*************************************************************
  *	     cfg80211 exported functions traces		     *
  *************************************************************/
-- 
1.9.1
