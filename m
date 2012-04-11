From: greearb@candelatech.com
Subject: [PATCH 01/10] cfg80211: Add framework to support ethtool stats.
Date: Wed, 11 Apr 2012 10:52:09 -0700
Message-ID: <1334166738-28243-2-git-send-email-greearb@candelatech.com>
References: <1334166738-28243-1-git-send-email-greearb@candelatech.com>
Cc: netdev@vger.kernel.org, Ben Greear <greearb@candelatech.com>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:40890 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756869Ab2DKRwq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2012 13:52:46 -0400
In-Reply-To: <1334166738-28243-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 ae3a3bb... 8bf68f3... M	include/net/cfg80211.h
:100644 100644 9bde4d1... 7eecdf4... M	net/wireless/ethtool.c
 include/net/cfg80211.h |   17 +++++++++++++++++
 net/wireless/ethtool.c |   29 +++++++++++++++++++++++++++++
 2 files changed, 46 insertions(+), 0 deletions(-)

diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
index ae3a3bb..8bf68f3 100644
--- a/include/net/cfg80211.h
+++ b/include/net/cfg80211.h
@@ -1511,6 +1511,16 @@ struct cfg80211_gtk_rekey_data {
  *	later passes to cfg80211_probe_status().
  *
  * @set_noack_map: Set the NoAck Map for the TIDs.
+ *
+ * @get_et_sset_count:  Ethtool API to get string-set count.
+ *	See @ethtool_ops.get_sset_count
+ *
+ * @get_et_stats:  Ethtool API to get a set of u64 stats.
+ *	See @ethtool_ops.get_ethtool_stats
+ *
+ * @get_et_strings:  Ethtool API to get a set of strings to describe stats
+ *	and perhaps other supported types of ethtool data-sets.
+ *	See @ethtool_ops.get_strings
  */
 struct cfg80211_ops {
 	int	(*suspend)(struct wiphy *wiphy, struct cfg80211_wowlan *wow);
@@ -1707,6 +1717,13 @@ struct cfg80211_ops {
 				  u16 noack_map);
 
 	struct ieee80211_channel *(*get_channel)(struct wiphy *wiphy);
+
+	int	(*get_et_sset_count)(struct wiphy *wiphy,
+				     struct net_device *dev, int sset);
+	void	(*get_et_stats)(struct wiphy *wiphy, struct net_device *dev,
+				struct ethtool_stats *stats, u64 *data);
+	void	(*get_et_strings)(struct wiphy *wiphy, struct net_device *dev,
+				  u32 sset, u8 *data);
 };
 
 /*
diff --git a/net/wireless/ethtool.c b/net/wireless/ethtool.c
index 9bde4d1..7eecdf4 100644
--- a/net/wireless/ethtool.c
+++ b/net/wireless/ethtool.c
@@ -68,6 +68,32 @@ static int cfg80211_set_ringparam(struct net_device *dev,
 	return -ENOTSUPP;
 }
 
+static int cfg80211_get_sset_count(struct net_device *dev, int sset)
+{
+	struct wireless_dev *wdev = dev->ieee80211_ptr;
+	struct cfg80211_registered_device *rdev = wiphy_to_dev(wdev->wiphy);
+	if (rdev->ops->get_et_sset_count)
+		return rdev->ops->get_et_sset_count(wdev->wiphy, dev, sset);
+	return -EOPNOTSUPP;
+}
+
+static void cfg80211_get_stats(struct net_device *dev,
+			       struct ethtool_stats *stats, u64 *data)
+{
+	struct wireless_dev *wdev = dev->ieee80211_ptr;
+	struct cfg80211_registered_device *rdev = wiphy_to_dev(wdev->wiphy);
+	if (rdev->ops->get_et_stats)
+		rdev->ops->get_et_stats(wdev->wiphy, dev, stats, data);
+}
+
+static void cfg80211_get_strings(struct net_device *dev, u32 sset, u8 *data)
+{
+	struct wireless_dev *wdev = dev->ieee80211_ptr;
+	struct cfg80211_registered_device *rdev = wiphy_to_dev(wdev->wiphy);
+	if (rdev->ops->get_et_strings)
+		rdev->ops->get_et_strings(wdev->wiphy, dev, sset, data);
+}
+
 const struct ethtool_ops cfg80211_ethtool_ops = {
 	.get_drvinfo = cfg80211_get_drvinfo,
 	.get_regs_len = cfg80211_get_regs_len,
@@ -75,4 +101,7 @@ const struct ethtool_ops cfg80211_ethtool_ops = {
 	.get_link = ethtool_op_get_link,
 	.get_ringparam = cfg80211_get_ringparam,
 	.set_ringparam = cfg80211_set_ringparam,
+	.get_strings = cfg80211_get_strings,
+	.get_ethtool_stats = cfg80211_get_stats,
+	.get_sset_count = cfg80211_get_sset_count,
 };
-- 
1.7.3.4
