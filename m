From: Wei-Ning Huang <wnhuang@chromium.org>
Subject: [PATCH] cfg80211/nl80211: add wifi tx power mode switching support
Date: Thu,  5 May 2016 14:44:23 +0800
Message-ID: <1462430663-9448-1-git-send-email-wnhuang@chromium.org>
Cc: LKML <linux-kernel@vger.kernel.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Sameer Nanda <snanda@chromium.org>,
	Todd Broch <tbroch@chromium.org>,
	Wei-Ning Huang <wnhuang@chromium.org>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Linux-Wireless <linux-wireless@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Recent new hardware has the ability to switch between tablet mode and
clamshell mode. To optimize WiFi performance, we want to be able to use
different power table between modes. This patch adds a new netlink
message type and cfg80211_ops function to allow userspace to trigger a
power mode switch for a given wireless interface.

Signed-off-by: Wei-Ning Huang <wnhuang@chromium.org>
---
 include/net/cfg80211.h       | 11 +++++++++++
 include/uapi/linux/nl80211.h | 21 +++++++++++++++++++++
 net/wireless/nl80211.c       | 16 ++++++++++++++++
 net/wireless/rdev-ops.h      | 22 ++++++++++++++++++++++
 net/wireless/trace.h         | 20 ++++++++++++++++++++
 5 files changed, 90 insertions(+)

diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
index 9e1b24c..aa77fa0 100644
--- a/include/net/cfg80211.h
+++ b/include/net/cfg80211.h
@@ -2370,6 +2370,12 @@ struct cfg80211_qos_map {
  * @get_tx_power: store the current TX power into the dbm variable;
  *	return 0 if successful
  *
+ * @set_tx_power_mode: set the transmit power mode. Some device have the ability
+ *	to transform between different mode such as clamshell and tablet mode.
+ *	set_tx_power_mode allows setting of different TX power mode at runtime.
+ * @get_tx_power_mode: store the current TX power mode into the mode variable;
+ *	return 0 if successful
+ *
  * @set_wds_peer: set the WDS peer for a WDS interface
  *
  * @rfkill_poll: polls the hw rfkill line, use cfg80211 reporting
@@ -2631,6 +2637,11 @@ struct cfg80211_ops {
 	int	(*get_tx_power)(struct wiphy *wiphy, struct wireless_dev *wdev,
 				int *dbm);
 
+	int	(*set_tx_power_mode)(struct wiphy *wiphy,
+				     enum nl80211_tx_power_mode mode);
+	int	(*get_tx_power_mode)(struct wiphy *wiphy,
+				     enum nl80211_tx_power_mode *mode);
+
 	int	(*set_wds_peer)(struct wiphy *wiphy, struct net_device *dev,
 				const u8 *addr);
 
diff --git a/include/uapi/linux/nl80211.h b/include/uapi/linux/nl80211.h
index 5a30a75..9b1888a 100644
--- a/include/uapi/linux/nl80211.h
+++ b/include/uapi/linux/nl80211.h
@@ -1796,6 +1796,9 @@ enum nl80211_commands {
  *	connecting to a PCP, and in %NL80211_CMD_START_AP to start
  *	a PCP instead of AP. Relevant for DMG networks only.
  *
+ * @NL80211_ATTR_WIPHY_TX_POWER_MODE: Transmit power mode. See
+ *      &enum nl80211_tx_power_mode for possible values.
+ *
  * @NUM_NL80211_ATTR: total number of nl80211_attrs available
  * @NL80211_ATTR_MAX: highest attribute number currently defined
  * @__NL80211_ATTR_AFTER_LAST: internal use
@@ -2172,6 +2175,8 @@ enum nl80211_attrs {
 
 	NL80211_ATTR_PBSS,
 
+	NL80211_ATTR_WIPHY_TX_POWER_MODE,
+
 	/* add attributes here, update the policy in nl80211.c */
 
 	__NL80211_ATTR_AFTER_LAST,
@@ -3703,6 +3708,22 @@ enum nl80211_tx_power_setting {
 };
 
 /**
+ * enum nl80211_tx_power_mode - TX power mode setting
+ * @NL80211_TX_POWER_LOW: general low TX power mode
+ * @NL80211_TX_POWER_MEDIUM: general medium TX power mode
+ * @NL80211_TX_POWER_HIGH: general high TX power mode
+ * @NL80211_TX_POWER_CLAMSHELL: clamshell mode TX power mode
+ * @NL80211_TX_POWER_TABLET: tablet mode TX power mode
+ */
+enum nl80211_tx_power_mode {
+	NL80211_TX_POWER_LOW,
+	NL80211_TX_POWER_MEDIUM,
+	NL80211_TX_POWER_HIGH,
+	NL80211_TX_POWER_CLAMSHELL,
+	NL80211_TX_POWER_TABLET,
+};
+
+/**
  * enum nl80211_packet_pattern_attr - packet pattern attribute
  * @__NL80211_PKTPAT_INVALID: invalid number for nested attribute
  * @NL80211_PKTPAT_PATTERN: the pattern, values where the mask has
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 056a730..61b474d 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -402,6 +402,7 @@ static const struct nla_policy nl80211_policy[NUM_NL80211_ATTR] = {
 	[NL80211_ATTR_SCHED_SCAN_DELAY] = { .type = NLA_U32 },
 	[NL80211_ATTR_REG_INDOOR] = { .type = NLA_FLAG },
 	[NL80211_ATTR_PBSS] = { .type = NLA_FLAG },
+	[NL80211_ATTR_WIPHY_TX_POWER_MODE] = { .type = NLA_U32 },
 };
 
 /* policy for the key attributes */
@@ -2218,6 +2219,21 @@ static int nl80211_set_wiphy(struct sk_buff *skb, struct genl_info *info)
 			return result;
 	}
 
+	if (info->attrs[NL80211_ATTR_WIPHY_TX_POWER_MODE]) {
+		enum nl80211_tx_power_mode mode;
+		int idx = 0;
+
+		if (!rdev->ops->set_tx_power_mode)
+			return -EOPNOTSUPP;
+
+		idx = NL80211_ATTR_WIPHY_TX_POWER_MODE;
+		mode = nla_get_u32(info->attrs[idx]);
+
+		result = rdev_set_tx_power_mode(rdev, mode);
+		if (result)
+			return result;
+	}
+
 	if (info->attrs[NL80211_ATTR_WIPHY_ANTENNA_TX] &&
 	    info->attrs[NL80211_ATTR_WIPHY_ANTENNA_RX]) {
 		u32 tx_ant, rx_ant;
diff --git a/net/wireless/rdev-ops.h b/net/wireless/rdev-ops.h
index 8ae0c04..c3a1035 100644
--- a/net/wireless/rdev-ops.h
+++ b/net/wireless/rdev-ops.h
@@ -552,6 +552,28 @@ static inline int rdev_get_tx_power(struct cfg80211_registered_device *rdev,
 	return ret;
 }
 
+static inline int
+rdev_set_tx_power_mode(struct cfg80211_registered_device *rdev,
+		       enum nl80211_tx_power_mode mode)
+{
+	int ret;
+	trace_rdev_set_tx_power_mode(&rdev->wiphy, mode);
+	ret = rdev->ops->set_tx_power_mode(&rdev->wiphy, mode);
+	trace_rdev_return_int(&rdev->wiphy, ret);
+	return ret;
+}
+
+static inline int
+rdev_get_tx_power_mode(struct cfg80211_registered_device *rdev,
+		       enum nl80211_tx_power_mode *mode)
+{
+	int ret;
+	trace_rdev_get_tx_power_mode(&rdev->wiphy);
+	ret = rdev->ops->get_tx_power_mode(&rdev->wiphy, mode);
+	trace_rdev_return_int_int(&rdev->wiphy, ret, *mode);
+	return ret;
+}
+
 static inline int rdev_set_wds_peer(struct cfg80211_registered_device *rdev,
 				    struct net_device *dev, const u8 *addr)
 {
diff --git a/net/wireless/trace.h b/net/wireless/trace.h
index 09b242b..132c8c2 100644
--- a/net/wireless/trace.h
+++ b/net/wireless/trace.h
@@ -1420,6 +1420,26 @@ TRACE_EVENT(rdev_set_tx_power,
 		  WIPHY_PR_ARG, WDEV_PR_ARG,__entry->type, __entry->mbm)
 );
 
+DEFINE_EVENT(wiphy_only_evt, rdev_get_tx_power_mode,
+	TP_PROTO(struct wiphy *wiphy),
+	TP_ARGS(wiphy)
+);
+
+TRACE_EVENT(rdev_set_tx_power_mode,
+	TP_PROTO(struct wiphy *wiphy, enum nl80211_tx_power_mode mode),
+	TP_ARGS(wiphy, mode),
+	TP_STRUCT__entry(
+		WIPHY_ENTRY
+		__field(enum nl80211_tx_power_mode, mode)
+	),
+	TP_fast_assign(
+		WIPHY_ASSIGN;
+		__entry->mode = mode;
+	),
+	TP_printk(WIPHY_PR_FMT ", mode: %d",
+		  WIPHY_PR_ARG, __entry->mode)
+);
+
 TRACE_EVENT(rdev_return_int_int,
 	TP_PROTO(struct wiphy *wiphy, int func_ret, int func_fill),
 	TP_ARGS(wiphy, func_ret, func_fill),
-- 
2.1.2
