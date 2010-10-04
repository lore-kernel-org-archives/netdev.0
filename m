From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [PATCH 3/4] nl80211: use generic check for netif_running
Date: Mon, 04 Oct 2010 21:14:05 +0200
Message-ID: <20101004191839.154151720@sipsolutions.net>
References: <20101004191402.183055479@sipsolutions.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline; filename=014-nl80211-generic-running.patch
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

Use a new flag that requires the netdev to be
UP and use it to check instead of coding the
check into all functions that require it.

Signed-off-by: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 net/wireless/nl80211.c |   97 ++++++++++++++-----------------------------------
 1 file changed, 28 insertions(+), 69 deletions(-)

--- wireless-testing.orig/net/wireless/nl80211.c	2010-10-01 11:10:58.000000000 +0200
+++ wireless-testing/net/wireless/nl80211.c	2010-10-01 11:10:58.000000000 +0200
@@ -411,9 +411,6 @@ static int nl80211_key_allowed(struct wi
 {
 	ASSERT_WDEV_LOCK(wdev);
 
-	if (!netif_running(wdev->netdev))
-		return -ENETDOWN;
-
 	switch (wdev->iftype) {
 	case NL80211_IFTYPE_AP:
 	case NL80211_IFTYPE_AP_VLAN:
@@ -2035,11 +2032,6 @@ static int nl80211_new_station(struct sk
 		goto out;
 	}
 
-	if (!netif_running(dev)) {
-		err = -ENETDOWN;
-		goto out;
-	}
-
 	err = rdev->ops->add_station(&rdev->wiphy, dev, mac_addr, &params);
 
  out:
@@ -2253,9 +2245,6 @@ static int nl80211_set_mpath(struct sk_b
 	if (dev->ieee80211_ptr->iftype != NL80211_IFTYPE_MESH_POINT)
 		return -EOPNOTSUPP;
 
-	if (!netif_running(dev))
-		return -ENETDOWN;
-
 	return rdev->ops->change_mpath(&rdev->wiphy, dev, dst, next_hop);
 }
 
@@ -2281,9 +2270,6 @@ static int nl80211_new_mpath(struct sk_b
 	if (dev->ieee80211_ptr->iftype != NL80211_IFTYPE_MESH_POINT)
 		return -EOPNOTSUPP;
 
-	if (!netif_running(dev))
-		return -ENETDOWN;
-
 	return rdev->ops->add_mpath(&rdev->wiphy, dev, dst, next_hop);
 }
 
@@ -2775,9 +2761,6 @@ static int nl80211_trigger_scan(struct s
 	if (!rdev->ops->scan)
 		return -EOPNOTSUPP;
 
-	if (!netif_running(dev))
-		return -ENETDOWN;
-
 	if (rdev->scan_req)
 		return -EBUSY;
 
@@ -3246,9 +3229,6 @@ static int nl80211_authenticate(struct s
 	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_P2P_CLIENT)
 		return -EOPNOTSUPP;
 
-	if (!netif_running(dev))
-		return -ENETDOWN;
-
 	bssid = nla_data(info->attrs[NL80211_ATTR_MAC]);
 	chan = ieee80211_get_channel(&rdev->wiphy,
 		nla_get_u32(info->attrs[NL80211_ATTR_WIPHY_FREQ]));
@@ -3379,9 +3359,6 @@ static int nl80211_associate(struct sk_b
 	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_P2P_CLIENT)
 		return -EOPNOTSUPP;
 
-	if (!netif_running(dev))
-		return -ENETDOWN;
-
 	bssid = nla_data(info->attrs[NL80211_ATTR_MAC]);
 
 	chan = ieee80211_get_channel(&rdev->wiphy,
@@ -3443,9 +3420,6 @@ static int nl80211_deauthenticate(struct
 	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_P2P_CLIENT)
 		return -EOPNOTSUPP;
 
-	if (!netif_running(dev))
-		return -ENETDOWN;
-
 	bssid = nla_data(info->attrs[NL80211_ATTR_MAC]);
 
 	reason_code = nla_get_u16(info->attrs[NL80211_ATTR_REASON_CODE]);
@@ -3490,9 +3464,6 @@ static int nl80211_disassociate(struct s
 	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_P2P_CLIENT)
 		return -EOPNOTSUPP;
 
-	if (!netif_running(dev))
-		return -ENETDOWN;
-
 	bssid = nla_data(info->attrs[NL80211_ATTR_MAC]);
 
 	reason_code = nla_get_u16(info->attrs[NL80211_ATTR_REASON_CODE]);
@@ -3546,9 +3517,6 @@ static int nl80211_join_ibss(struct sk_b
 	if (dev->ieee80211_ptr->iftype != NL80211_IFTYPE_ADHOC)
 		return -EOPNOTSUPP;
 
-	if (!netif_running(dev))
-		return -ENETDOWN;
-
 	wiphy = &rdev->wiphy;
 
 	if (info->attrs[NL80211_ATTR_MAC])
@@ -3623,9 +3591,6 @@ static int nl80211_leave_ibss(struct sk_
 	if (dev->ieee80211_ptr->iftype != NL80211_IFTYPE_ADHOC)
 		return -EOPNOTSUPP;
 
-	if (!netif_running(dev))
-		return -ENETDOWN;
-
 	return cfg80211_leave_ibss(rdev, dev, false);
 }
 
@@ -3776,9 +3741,6 @@ static int nl80211_connect(struct sk_buf
 	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_P2P_CLIENT)
 		return -EOPNOTSUPP;
 
-	if (!netif_running(dev))
-		return -ENETDOWN;
-
 	wiphy = &rdev->wiphy;
 
 	if (info->attrs[NL80211_ATTR_MAC])
@@ -3831,9 +3793,6 @@ static int nl80211_disconnect(struct sk_
 	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_P2P_CLIENT)
 		return -EOPNOTSUPP;
 
-	if (!netif_running(dev))
-		return -ENETDOWN;
-
 	return cfg80211_disconnect(rdev, dev, reason, true);
 }
 
@@ -3948,9 +3907,6 @@ static int nl80211_remain_on_channel(str
 	if (!rdev->ops->remain_on_channel)
 		return -EOPNOTSUPP;
 
-	if (!netif_running(dev))
-		return -ENETDOWN;
-
 	if (info->attrs[NL80211_ATTR_WIPHY_CHANNEL_TYPE]) {
 		channel_type = nla_get_u32(
 			info->attrs[NL80211_ATTR_WIPHY_CHANNEL_TYPE]);
@@ -4010,9 +3966,6 @@ static int nl80211_cancel_remain_on_chan
 	if (!rdev->ops->cancel_remain_on_channel)
 		return -EOPNOTSUPP;
 
-	if (!netif_running(dev))
-		return -ENETDOWN;
-
 	cookie = nla_get_u64(info->attrs[NL80211_ATTR_COOKIE]);
 
 	return rdev->ops->cancel_remain_on_channel(&rdev->wiphy, dev, cookie);
@@ -4157,9 +4110,6 @@ static int nl80211_tx_mgmt(struct sk_buf
 	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_P2P_GO)
 		return -EOPNOTSUPP;
 
-	if (!netif_running(dev))
-		return -ENETDOWN;
-
 	if (info->attrs[NL80211_ATTR_WIPHY_CHANNEL_TYPE]) {
 		channel_type = nla_get_u32(
 			info->attrs[NL80211_ATTR_WIPHY_CHANNEL_TYPE]);
@@ -4348,6 +4298,9 @@ out:
 #define NL80211_FLAG_NEED_WIPHY		0x01
 #define NL80211_FLAG_NEED_NETDEV	0x02
 #define NL80211_FLAG_NEED_RTNL		0x04
+#define NL80211_FLAG_CHECK_NETDEV_UP	0x08
+#define NL80211_FLAG_NEED_NETDEV_UP	(NL80211_FLAG_NEED_NETDEV |\
+					 NL80211_FLAG_CHECK_NETDEV_UP)
 
 static int nl80211_pre_doit(struct genl_ops *ops, struct sk_buff *skb,
 			    struct genl_info *info)
@@ -4375,6 +4328,12 @@ static int nl80211_pre_doit(struct genl_
 				rtnl_unlock();
 			return err;
 		}
+		if (ops->internal_flags & NL80211_FLAG_CHECK_NETDEV_UP &&
+		    !netif_running(dev)) {
+			if (rtnl)
+				rtnl_unlock();
+			return -ENETDOWN;
+		}
 		info->user_ptr[0] = rdev;
 		info->user_ptr[1] = dev;
 	}
@@ -4454,7 +4413,7 @@ static struct genl_ops nl80211_ops[] = {
 		.doit = nl80211_set_key,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
-		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
@@ -4462,7 +4421,7 @@ static struct genl_ops nl80211_ops[] = {
 		.doit = nl80211_new_key,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
-		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
@@ -4470,7 +4429,7 @@ static struct genl_ops nl80211_ops[] = {
 		.doit = nl80211_del_key,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
-		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
@@ -4518,7 +4477,7 @@ static struct genl_ops nl80211_ops[] = {
 		.doit = nl80211_new_station,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
-		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
@@ -4535,7 +4494,7 @@ static struct genl_ops nl80211_ops[] = {
 		.dumpit = nl80211_dump_mpath,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
-		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
@@ -4543,7 +4502,7 @@ static struct genl_ops nl80211_ops[] = {
 		.doit = nl80211_set_mpath,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
-		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
@@ -4551,7 +4510,7 @@ static struct genl_ops nl80211_ops[] = {
 		.doit = nl80211_new_mpath,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
-		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
@@ -4609,7 +4568,7 @@ static struct genl_ops nl80211_ops[] = {
 		.doit = nl80211_trigger_scan,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
-		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
@@ -4622,7 +4581,7 @@ static struct genl_ops nl80211_ops[] = {
 		.doit = nl80211_authenticate,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
-		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
@@ -4630,7 +4589,7 @@ static struct genl_ops nl80211_ops[] = {
 		.doit = nl80211_associate,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
-		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
@@ -4638,7 +4597,7 @@ static struct genl_ops nl80211_ops[] = {
 		.doit = nl80211_deauthenticate,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
-		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
@@ -4646,7 +4605,7 @@ static struct genl_ops nl80211_ops[] = {
 		.doit = nl80211_disassociate,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
-		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
@@ -4654,7 +4613,7 @@ static struct genl_ops nl80211_ops[] = {
 		.doit = nl80211_join_ibss,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
-		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
@@ -4662,7 +4621,7 @@ static struct genl_ops nl80211_ops[] = {
 		.doit = nl80211_leave_ibss,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
-		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
 #ifdef CONFIG_NL80211_TESTMODE
@@ -4680,7 +4639,7 @@ static struct genl_ops nl80211_ops[] = {
 		.doit = nl80211_connect,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
-		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
@@ -4688,7 +4647,7 @@ static struct genl_ops nl80211_ops[] = {
 		.doit = nl80211_disconnect,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
-		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
@@ -4733,7 +4692,7 @@ static struct genl_ops nl80211_ops[] = {
 		.doit = nl80211_remain_on_channel,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
-		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
@@ -4741,7 +4700,7 @@ static struct genl_ops nl80211_ops[] = {
 		.doit = nl80211_cancel_remain_on_channel,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
-		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
@@ -4765,7 +4724,7 @@ static struct genl_ops nl80211_ops[] = {
 		.doit = nl80211_tx_mgmt,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
-		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+		.internal_flags = NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
 	{


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
