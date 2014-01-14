From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 10/10] net: nl80211: __dev_get_by_index instead of dev_get_by_index to find interface
Date: Tue, 14 Jan 2014 15:41:09 +0800
Message-ID: <1389685269-18600-11-git-send-email-ying.xue@windriver.com>
References: <1389685269-18600-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <vfalico@redhat.com>, <john.r.fastabend@intel.com>,
	<stephen@networkplumber.org>, <antonio@meshcoding.com>,
	<dmitry.tarnyagin@lockless.no>, <socketcan@hartkopp.net>,
	<johannes@sipsolutions.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389685269-18600-1-git-send-email-ying.xue@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As __cfg80211_rdev_from_attrs(), nl80211_dump_wiphy_parse() and
nl80211_set_wiphy() are all under rtnl_lock protection,
__dev_get_by_index() instead of dev_get_by_index() should be used
to find interface handler in them allowing us to avoid to change
interface reference counter.

Cc: Johannes Berg <johannes@sipsolutions.net>
Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 net/wireless/nl80211.c |  100 +++++++++++++++++-------------------------------
 1 file changed, 36 insertions(+), 64 deletions(-)

diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index b4f40fe..0d4d7fd 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -165,7 +165,7 @@ __cfg80211_rdev_from_attrs(struct net *netns, struct nlattr **attrs)
 
 	if (attrs[NL80211_ATTR_IFINDEX]) {
 		int ifindex = nla_get_u32(attrs[NL80211_ATTR_IFINDEX]);
-		netdev = dev_get_by_index(netns, ifindex);
+		netdev = __dev_get_by_index(netns, ifindex);
 		if (netdev) {
 			if (netdev->ieee80211_ptr)
 				tmp = wiphy_to_dev(
@@ -173,8 +173,6 @@ __cfg80211_rdev_from_attrs(struct net *netns, struct nlattr **attrs)
 			else
 				tmp = NULL;
 
-			dev_put(netdev);
-
 			/* not wireless device -- return error */
 			if (!tmp)
 				return ERR_PTR(-EINVAL);
@@ -1656,7 +1654,7 @@ static int nl80211_dump_wiphy_parse(struct sk_buff *skb,
 		struct cfg80211_registered_device *rdev;
 		int ifidx = nla_get_u32(tb[NL80211_ATTR_IFINDEX]);
 
-		netdev = dev_get_by_index(sock_net(skb->sk), ifidx);
+		netdev = __dev_get_by_index(sock_net(skb->sk), ifidx);
 		if (!netdev)
 			return -ENODEV;
 		if (netdev->ieee80211_ptr) {
@@ -1664,7 +1662,6 @@ static int nl80211_dump_wiphy_parse(struct sk_buff *skb,
 				netdev->ieee80211_ptr->wiphy);
 			state->filter_wiphy = rdev->wiphy_idx;
 		}
-		dev_put(netdev);
 	}
 
 	return 0;
@@ -1987,7 +1984,7 @@ static int nl80211_set_wiphy(struct sk_buff *skb, struct genl_info *info)
 	if (info->attrs[NL80211_ATTR_IFINDEX]) {
 		int ifindex = nla_get_u32(info->attrs[NL80211_ATTR_IFINDEX]);
 
-		netdev = dev_get_by_index(genl_info_net(info), ifindex);
+		netdev = __dev_get_by_index(genl_info_net(info), ifindex);
 		if (netdev && netdev->ieee80211_ptr)
 			rdev = wiphy_to_dev(netdev->ieee80211_ptr->wiphy);
 		else
@@ -2015,32 +2012,24 @@ static int nl80211_set_wiphy(struct sk_buff *skb, struct genl_info *info)
 			rdev, nla_data(info->attrs[NL80211_ATTR_WIPHY_NAME]));
 
 	if (result)
-		goto bad_res;
+		return result;
 
 	if (info->attrs[NL80211_ATTR_WIPHY_TXQ_PARAMS]) {
 		struct ieee80211_txq_params txq_params;
 		struct nlattr *tb[NL80211_TXQ_ATTR_MAX + 1];
 
-		if (!rdev->ops->set_txq_params) {
-			result = -EOPNOTSUPP;
-			goto bad_res;
-		}
+		if (!rdev->ops->set_txq_params)
+			return -EOPNOTSUPP;
 
-		if (!netdev) {
-			result = -EINVAL;
-			goto bad_res;
-		}
+		if (!netdev)
+			return -EINVAL;
 
 		if (netdev->ieee80211_ptr->iftype != NL80211_IFTYPE_AP &&
-		    netdev->ieee80211_ptr->iftype != NL80211_IFTYPE_P2P_GO) {
-			result = -EINVAL;
-			goto bad_res;
-		}
+		    netdev->ieee80211_ptr->iftype != NL80211_IFTYPE_P2P_GO)
+			return -EINVAL;
 
-		if (!netif_running(netdev)) {
-			result = -ENETDOWN;
-			goto bad_res;
-		}
+		if (!netif_running(netdev))
+			return -ENETDOWN;
 
 		nla_for_each_nested(nl_txq_params,
 				    info->attrs[NL80211_ATTR_WIPHY_TXQ_PARAMS],
@@ -2051,12 +2040,12 @@ static int nl80211_set_wiphy(struct sk_buff *skb, struct genl_info *info)
 				  txq_params_policy);
 			result = parse_txq_params(tb, &txq_params);
 			if (result)
-				goto bad_res;
+				return result;
 
 			result = rdev_set_txq_params(rdev, netdev,
 						     &txq_params);
 			if (result)
-				goto bad_res;
+				return result;
 		}
 	}
 
@@ -2065,7 +2054,7 @@ static int nl80211_set_wiphy(struct sk_buff *skb, struct genl_info *info)
 				nl80211_can_set_dev_channel(wdev) ? wdev : NULL,
 				info);
 		if (result)
-			goto bad_res;
+			return result;
 	}
 
 	if (info->attrs[NL80211_ATTR_WIPHY_TX_POWER_SETTING]) {
@@ -2076,19 +2065,15 @@ static int nl80211_set_wiphy(struct sk_buff *skb, struct genl_info *info)
 		if (!(rdev->wiphy.features & NL80211_FEATURE_VIF_TXPOWER))
 			txp_wdev = NULL;
 
-		if (!rdev->ops->set_tx_power) {
-			result = -EOPNOTSUPP;
-			goto bad_res;
-		}
+		if (!rdev->ops->set_tx_power)
+			return -EOPNOTSUPP;
 
 		idx = NL80211_ATTR_WIPHY_TX_POWER_SETTING;
 		type = nla_get_u32(info->attrs[idx]);
 
 		if (!info->attrs[NL80211_ATTR_WIPHY_TX_POWER_LEVEL] &&
-		    (type != NL80211_TX_POWER_AUTOMATIC)) {
-			result = -EINVAL;
-			goto bad_res;
-		}
+		    (type != NL80211_TX_POWER_AUTOMATIC))
+			return -EINVAL;
 
 		if (type != NL80211_TX_POWER_AUTOMATIC) {
 			idx = NL80211_ATTR_WIPHY_TX_POWER_LEVEL;
@@ -2097,7 +2082,7 @@ static int nl80211_set_wiphy(struct sk_buff *skb, struct genl_info *info)
 
 		result = rdev_set_tx_power(rdev, txp_wdev, type, mbm);
 		if (result)
-			goto bad_res;
+			return result;
 	}
 
 	if (info->attrs[NL80211_ATTR_WIPHY_ANTENNA_TX] &&
@@ -2105,10 +2090,8 @@ static int nl80211_set_wiphy(struct sk_buff *skb, struct genl_info *info)
 		u32 tx_ant, rx_ant;
 		if ((!rdev->wiphy.available_antennas_tx &&
 		     !rdev->wiphy.available_antennas_rx) ||
-		    !rdev->ops->set_antenna) {
-			result = -EOPNOTSUPP;
-			goto bad_res;
-		}
+		    !rdev->ops->set_antenna)
+			return -EOPNOTSUPP;
 
 		tx_ant = nla_get_u32(info->attrs[NL80211_ATTR_WIPHY_ANTENNA_TX]);
 		rx_ant = nla_get_u32(info->attrs[NL80211_ATTR_WIPHY_ANTENNA_RX]);
@@ -2116,17 +2099,15 @@ static int nl80211_set_wiphy(struct sk_buff *skb, struct genl_info *info)
 		/* reject antenna configurations which don't match the
 		 * available antenna masks, except for the "all" mask */
 		if ((~tx_ant && (tx_ant & ~rdev->wiphy.available_antennas_tx)) ||
-		    (~rx_ant && (rx_ant & ~rdev->wiphy.available_antennas_rx))) {
-			result = -EINVAL;
-			goto bad_res;
-		}
+		    (~rx_ant && (rx_ant & ~rdev->wiphy.available_antennas_rx)))
+			return -EINVAL;
 
 		tx_ant = tx_ant & rdev->wiphy.available_antennas_tx;
 		rx_ant = rx_ant & rdev->wiphy.available_antennas_rx;
 
 		result = rdev_set_antenna(rdev, tx_ant, rx_ant);
 		if (result)
-			goto bad_res;
+			return result;
 	}
 
 	changed = 0;
@@ -2134,30 +2115,27 @@ static int nl80211_set_wiphy(struct sk_buff *skb, struct genl_info *info)
 	if (info->attrs[NL80211_ATTR_WIPHY_RETRY_SHORT]) {
 		retry_short = nla_get_u8(
 			info->attrs[NL80211_ATTR_WIPHY_RETRY_SHORT]);
-		if (retry_short == 0) {
-			result = -EINVAL;
-			goto bad_res;
-		}
+		if (retry_short == 0)
+			return -EINVAL;
+
 		changed |= WIPHY_PARAM_RETRY_SHORT;
 	}
 
 	if (info->attrs[NL80211_ATTR_WIPHY_RETRY_LONG]) {
 		retry_long = nla_get_u8(
 			info->attrs[NL80211_ATTR_WIPHY_RETRY_LONG]);
-		if (retry_long == 0) {
-			result = -EINVAL;
-			goto bad_res;
-		}
+		if (retry_long == 0)
+			return -EINVAL;
+
 		changed |= WIPHY_PARAM_RETRY_LONG;
 	}
 
 	if (info->attrs[NL80211_ATTR_WIPHY_FRAG_THRESHOLD]) {
 		frag_threshold = nla_get_u32(
 			info->attrs[NL80211_ATTR_WIPHY_FRAG_THRESHOLD]);
-		if (frag_threshold < 256) {
-			result = -EINVAL;
-			goto bad_res;
-		}
+		if (frag_threshold < 256)
+			return -EINVAL;
+
 		if (frag_threshold != (u32) -1) {
 			/*
 			 * Fragments (apart from the last one) are required to
@@ -2187,10 +2165,8 @@ static int nl80211_set_wiphy(struct sk_buff *skb, struct genl_info *info)
 		u32 old_frag_threshold, old_rts_threshold;
 		u8 old_coverage_class;
 
-		if (!rdev->ops->set_wiphy_params) {
-			result = -EOPNOTSUPP;
-			goto bad_res;
-		}
+		if (!rdev->ops->set_wiphy_params)
+			return -EOPNOTSUPP;
 
 		old_retry_short = rdev->wiphy.retry_short;
 		old_retry_long = rdev->wiphy.retry_long;
@@ -2218,10 +2194,6 @@ static int nl80211_set_wiphy(struct sk_buff *skb, struct genl_info *info)
 			rdev->wiphy.coverage_class = old_coverage_class;
 		}
 	}
-
- bad_res:
-	if (netdev)
-		dev_put(netdev);
 	return result;
 }
 
-- 
1.7.9.5
