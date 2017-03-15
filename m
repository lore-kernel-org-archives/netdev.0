From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] nl80211: fix dumpit error path RTNL deadlocks
Date: Wed, 15 Mar 2017 14:29:13 +0100
Message-ID: <20170315132913.26088-1-johannes@sipsolutions.net>
Cc: netdev@vger.kernel.org,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Johannes Berg <johannes.berg@intel.com>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:54412 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751764AbdCON3U (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Mar 2017 09:29:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

Sowmini pointed out Dmitry's RTNL deadlock report to me, and it turns out
to be perfectly accurate - there are various error paths that miss unlock
of the RTNL.

To fix those, change the locking a bit to not be conditional in all those
nl80211_prepare_*_dump() functions, but make those require the RTNL to
start with, and fix the buggy error paths. This also let me use sparse
(by appropriately overriding the rtnl_lock/rtnl_unlock functions) to
validate the changes.

Reported-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Reported-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 net/wireless/nl80211.c | 127 ++++++++++++++++++++++---------------------------
 1 file changed, 56 insertions(+), 71 deletions(-)

diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index b15903b9c0ab..26192275e596 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -545,22 +545,18 @@ static int nl80211_prepare_wdev_dump(struct sk_buff *skb,
 {
 	int err;
 
-	rtnl_lock();
-
 	if (!cb->args[0]) {
 		err = nlmsg_parse(cb->nlh, GENL_HDRLEN + nl80211_fam.hdrsize,
 				  genl_family_attrbuf(&nl80211_fam),
 				  nl80211_fam.maxattr, nl80211_policy);
 		if (err)
-			goto out_unlock;
+			return err;
 
 		*wdev = __cfg80211_wdev_from_attrs(
 					sock_net(skb->sk),
 					genl_family_attrbuf(&nl80211_fam));
-		if (IS_ERR(*wdev)) {
-			err = PTR_ERR(*wdev);
-			goto out_unlock;
-		}
+		if (IS_ERR(*wdev))
+			return PTR_ERR(*wdev);
 		*rdev = wiphy_to_rdev((*wdev)->wiphy);
 		/* 0 is the first index - add 1 to parse only once */
 		cb->args[0] = (*rdev)->wiphy_idx + 1;
@@ -570,10 +566,8 @@ static int nl80211_prepare_wdev_dump(struct sk_buff *skb,
 		struct wiphy *wiphy = wiphy_idx_to_wiphy(cb->args[0] - 1);
 		struct wireless_dev *tmp;
 
-		if (!wiphy) {
-			err = -ENODEV;
-			goto out_unlock;
-		}
+		if (!wiphy)
+			return -ENODEV;
 		*rdev = wiphy_to_rdev(wiphy);
 		*wdev = NULL;
 
@@ -584,21 +578,11 @@ static int nl80211_prepare_wdev_dump(struct sk_buff *skb,
 			}
 		}
 
-		if (!*wdev) {
-			err = -ENODEV;
-			goto out_unlock;
-		}
+		if (!*wdev)
+			return -ENODEV;
 	}
 
 	return 0;
- out_unlock:
-	rtnl_unlock();
-	return err;
-}
-
-static void nl80211_finish_wdev_dump(struct cfg80211_registered_device *rdev)
-{
-	rtnl_unlock();
 }
 
 /* IE validation */
@@ -2608,17 +2592,17 @@ static int nl80211_dump_interface(struct sk_buff *skb, struct netlink_callback *
 	int filter_wiphy = -1;
 	struct cfg80211_registered_device *rdev;
 	struct wireless_dev *wdev;
+	int ret;
 
 	rtnl_lock();
 	if (!cb->args[2]) {
 		struct nl80211_dump_wiphy_state state = {
 			.filter_wiphy = -1,
 		};
-		int ret;
 
 		ret = nl80211_dump_wiphy_parse(skb, cb, &state);
 		if (ret)
-			return ret;
+			goto out_unlock;
 
 		filter_wiphy = state.filter_wiphy;
 
@@ -2663,12 +2647,14 @@ static int nl80211_dump_interface(struct sk_buff *skb, struct netlink_callback *
 		wp_idx++;
 	}
  out:
-	rtnl_unlock();
-
 	cb->args[0] = wp_idx;
 	cb->args[1] = if_idx;
 
-	return skb->len;
+	ret = skb->len;
+ out_unlock:
+	rtnl_unlock();
+
+	return ret;
 }
 
 static int nl80211_get_interface(struct sk_buff *skb, struct genl_info *info)
@@ -4452,9 +4438,10 @@ static int nl80211_dump_station(struct sk_buff *skb,
 	int sta_idx = cb->args[2];
 	int err;
 
+	rtnl_lock();
 	err = nl80211_prepare_wdev_dump(skb, cb, &rdev, &wdev);
 	if (err)
-		return err;
+		goto out_err;
 
 	if (!wdev->netdev) {
 		err = -EINVAL;
@@ -4489,7 +4476,7 @@ static int nl80211_dump_station(struct sk_buff *skb,
 	cb->args[2] = sta_idx;
 	err = skb->len;
  out_err:
-	nl80211_finish_wdev_dump(rdev);
+	rtnl_unlock();
 
 	return err;
 }
@@ -5275,9 +5262,10 @@ static int nl80211_dump_mpath(struct sk_buff *skb,
 	int path_idx = cb->args[2];
 	int err;
 
+	rtnl_lock();
 	err = nl80211_prepare_wdev_dump(skb, cb, &rdev, &wdev);
 	if (err)
-		return err;
+		goto out_err;
 
 	if (!rdev->ops->dump_mpath) {
 		err = -EOPNOTSUPP;
@@ -5310,7 +5298,7 @@ static int nl80211_dump_mpath(struct sk_buff *skb,
 	cb->args[2] = path_idx;
 	err = skb->len;
  out_err:
-	nl80211_finish_wdev_dump(rdev);
+	rtnl_unlock();
 	return err;
 }
 
@@ -5470,9 +5458,10 @@ static int nl80211_dump_mpp(struct sk_buff *skb,
 	int path_idx = cb->args[2];
 	int err;
 
+	rtnl_lock();
 	err = nl80211_prepare_wdev_dump(skb, cb, &rdev, &wdev);
 	if (err)
-		return err;
+		goto out_err;
 
 	if (!rdev->ops->dump_mpp) {
 		err = -EOPNOTSUPP;
@@ -5505,7 +5494,7 @@ static int nl80211_dump_mpp(struct sk_buff *skb,
 	cb->args[2] = path_idx;
 	err = skb->len;
  out_err:
-	nl80211_finish_wdev_dump(rdev);
+	rtnl_unlock();
 	return err;
 }
 
@@ -7706,9 +7695,12 @@ static int nl80211_dump_scan(struct sk_buff *skb, struct netlink_callback *cb)
 	int start = cb->args[2], idx = 0;
 	int err;
 
+	rtnl_lock();
 	err = nl80211_prepare_wdev_dump(skb, cb, &rdev, &wdev);
-	if (err)
+	if (err) {
+		rtnl_unlock();
 		return err;
+	}
 
 	wdev_lock(wdev);
 	spin_lock_bh(&rdev->bss_lock);
@@ -7731,7 +7723,7 @@ static int nl80211_dump_scan(struct sk_buff *skb, struct netlink_callback *cb)
 	wdev_unlock(wdev);
 
 	cb->args[2] = idx;
-	nl80211_finish_wdev_dump(rdev);
+	rtnl_unlock();
 
 	return skb->len;
 }
@@ -7816,9 +7808,10 @@ static int nl80211_dump_survey(struct sk_buff *skb, struct netlink_callback *cb)
 	int res;
 	bool radio_stats;
 
+	rtnl_lock();
 	res = nl80211_prepare_wdev_dump(skb, cb, &rdev, &wdev);
 	if (res)
-		return res;
+		goto out_err;
 
 	/* prepare_wdev_dump parsed the attributes */
 	radio_stats = attrbuf[NL80211_ATTR_SURVEY_RADIO_STATS];
@@ -7859,7 +7852,7 @@ static int nl80211_dump_survey(struct sk_buff *skb, struct netlink_callback *cb)
 	cb->args[2] = survey_idx;
 	res = skb->len;
  out_err:
-	nl80211_finish_wdev_dump(rdev);
+	rtnl_unlock();
 	return res;
 }
 
@@ -11661,17 +11654,13 @@ static int nl80211_prepare_vendor_dump(struct sk_buff *skb,
 	void *data = NULL;
 	unsigned int data_len = 0;
 
-	rtnl_lock();
-
 	if (cb->args[0]) {
 		/* subtract the 1 again here */
 		struct wiphy *wiphy = wiphy_idx_to_wiphy(cb->args[0] - 1);
 		struct wireless_dev *tmp;
 
-		if (!wiphy) {
-			err = -ENODEV;
-			goto out_unlock;
-		}
+		if (!wiphy)
+			return -ENODEV;
 		*rdev = wiphy_to_rdev(wiphy);
 		*wdev = NULL;
 
@@ -11691,23 +11680,19 @@ static int nl80211_prepare_vendor_dump(struct sk_buff *skb,
 	err = nlmsg_parse(cb->nlh, GENL_HDRLEN + nl80211_fam.hdrsize,
 			  attrbuf, nl80211_fam.maxattr, nl80211_policy);
 	if (err)
-		goto out_unlock;
+		return err;
 
 	if (!attrbuf[NL80211_ATTR_VENDOR_ID] ||
-	    !attrbuf[NL80211_ATTR_VENDOR_SUBCMD]) {
-		err = -EINVAL;
-		goto out_unlock;
-	}
+	    !attrbuf[NL80211_ATTR_VENDOR_SUBCMD])
+		return -EINVAL;
 
 	*wdev = __cfg80211_wdev_from_attrs(sock_net(skb->sk), attrbuf);
 	if (IS_ERR(*wdev))
 		*wdev = NULL;
 
 	*rdev = __cfg80211_rdev_from_attrs(sock_net(skb->sk), attrbuf);
-	if (IS_ERR(*rdev)) {
-		err = PTR_ERR(*rdev);
-		goto out_unlock;
-	}
+	if (IS_ERR(*rdev))
+		return PTR_ERR(*rdev);
 
 	vid = nla_get_u32(attrbuf[NL80211_ATTR_VENDOR_ID]);
 	subcmd = nla_get_u32(attrbuf[NL80211_ATTR_VENDOR_SUBCMD]);
@@ -11720,19 +11705,15 @@ static int nl80211_prepare_vendor_dump(struct sk_buff *skb,
 		if (vcmd->info.vendor_id != vid || vcmd->info.subcmd != subcmd)
 			continue;
 
-		if (!vcmd->dumpit) {
-			err = -EOPNOTSUPP;
-			goto out_unlock;
-		}
+		if (!vcmd->dumpit)
+			return -EOPNOTSUPP;
 
 		vcmd_idx = i;
 		break;
 	}
 
-	if (vcmd_idx < 0) {
-		err = -EOPNOTSUPP;
-		goto out_unlock;
-	}
+	if (vcmd_idx < 0)
+		return -EOPNOTSUPP;
 
 	if (attrbuf[NL80211_ATTR_VENDOR_DATA]) {
 		data = nla_data(attrbuf[NL80211_ATTR_VENDOR_DATA]);
@@ -11749,9 +11730,6 @@ static int nl80211_prepare_vendor_dump(struct sk_buff *skb,
 
 	/* keep rtnl locked in successful case */
 	return 0;
- out_unlock:
-	rtnl_unlock();
-	return err;
 }
 
 static int nl80211_vendor_cmd_dump(struct sk_buff *skb,
@@ -11766,9 +11744,10 @@ static int nl80211_vendor_cmd_dump(struct sk_buff *skb,
 	int err;
 	struct nlattr *vendor_data;
 
+	rtnl_lock();
 	err = nl80211_prepare_vendor_dump(skb, cb, &rdev, &wdev);
 	if (err)
-		return err;
+		goto out;
 
 	vcmd_idx = cb->args[2];
 	data = (void *)cb->args[3];
@@ -11777,15 +11756,21 @@ static int nl80211_vendor_cmd_dump(struct sk_buff *skb,
 
 	if (vcmd->flags & (WIPHY_VENDOR_CMD_NEED_WDEV |
 			   WIPHY_VENDOR_CMD_NEED_NETDEV)) {
-		if (!wdev)
-			return -EINVAL;
+		if (!wdev) {
+			err = -EINVAL;
+			goto out;
+		}
 		if (vcmd->flags & WIPHY_VENDOR_CMD_NEED_NETDEV &&
-		    !wdev->netdev)
-			return -EINVAL;
+		    !wdev->netdev) {
+			err = -EINVAL;
+			goto out;
+		}
 
 		if (vcmd->flags & WIPHY_VENDOR_CMD_NEED_RUNNING) {
-			if (!wdev_running(wdev))
-				return -ENETDOWN;
+			if (!wdev_running(wdev)) {
+				err = -ENETDOWN;
+				goto out;
+			}
 		}
 	}
 
-- 
2.11.0
