From: Christian Engelmayer <cengelma-RbZlAiThDcE@public.gmane.org>
Subject: [PATCH] nl80211: Fix possible leak in nl80211_new_interface on MONITOR_FLAG_ACTIVE
Date: Sat, 14 Feb 2015 20:52:01 +0100
Message-ID: <1423943521-2896-1-git-send-email-cengelma@gmx.at>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Christian Engelmayer <cengelma-RbZlAiThDcE@public.gmane.org>
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

In case of NL80211_IFTYPE_MONITOR and flag MONITOR_FLAG_ACTIVE, the already
allocated sk_buff 'msg' is not freed, when the function exits in case the
feature is not supported. Detected by Coverity CID 1269116.

Signed-off-by: Christian Engelmayer <cengelma-RbZlAiThDcE@public.gmane.org>
---
Compile tested only. Applies against linux-next.
---
 net/wireless/nl80211.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index d78fd8b54515..38a7477dda81 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -2663,8 +2663,10 @@ static int nl80211_new_interface(struct sk_buff *skb, struct genl_info *info)
 				  &flags);
 
 	if (!err && (flags & MONITOR_FLAG_ACTIVE) &&
-	    !(rdev->wiphy.features & NL80211_FEATURE_ACTIVE_MONITOR))
+	    !(rdev->wiphy.features & NL80211_FEATURE_ACTIVE_MONITOR)) {
+		nlmsg_free(msg);
 		return -EOPNOTSUPP;
+	}
 
 	wdev = rdev_add_virtual_intf(rdev,
 				nla_data(info->attrs[NL80211_ATTR_IFNAME]),
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
