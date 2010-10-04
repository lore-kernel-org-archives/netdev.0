From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [PATCH 4/4] nl80211: reduce dumping boilerplate
Date: Mon, 04 Oct 2010 21:14:06 +0200
Message-ID: <20101004191839.342723640@sipsolutions.net>
References: <20101004191402.183055479@sipsolutions.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline; filename=015-nl80211-consolidate-dump.patch
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

Consolidate boilerplate code needed for .dumpit
calls operating on netdevs.

Signed-off-by: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 net/wireless/nl80211.c |  151 +++++++++++++++++++------------------------------
 1 file changed, 59 insertions(+), 92 deletions(-)

--- wireless-testing.orig/net/wireless/nl80211.c	2010-10-01 11:14:46.000000000 +0200
+++ wireless-testing/net/wireless/nl80211.c	2010-10-01 11:27:47.000000000 +0200
@@ -198,6 +198,47 @@ static int nl80211_get_ifidx(struct netl
 	return res;
 }
 
+static int nl80211_prepare_netdev_dump(struct sk_buff *skb,
+				       struct netlink_callback *cb,
+				       struct cfg80211_registered_device **rdev,
+				       struct net_device **dev)
+{
+	int ifidx = cb->args[0];
+	int err;
+
+	if (!ifidx)
+		ifidx = nl80211_get_ifidx(cb);
+	if (ifidx < 0)
+		return ifidx;
+
+	cb->args[0] = ifidx;
+
+	rtnl_lock();
+
+	*dev = __dev_get_by_index(sock_net(skb->sk), ifidx);
+	if (!*dev) {
+		err = -ENODEV;
+		goto out_rtnl;
+	}
+
+	*rdev = cfg80211_get_dev_from_ifindex(sock_net(skb->sk), ifidx);
+	if (IS_ERR(dev)) {
+		err = PTR_ERR(dev);
+		goto out_rtnl;
+	}
+
+	return 0;
+ out_rtnl:
+	rtnl_unlock();
+	return err;
+}
+
+static void nl80211_finish_netdev_dump(struct cfg80211_registered_device *rdev)
+{
+	cfg80211_unlock_rdev(rdev);
+	rtnl_unlock();
+}
+
 /* IE validation */
 static bool is_valid_ie_attr(const struct nlattr *attr)
 {
@@ -1748,28 +1789,12 @@ static int nl80211_dump_station(struct s
 	struct cfg80211_registered_device *dev;
 	struct net_device *netdev;
 	u8 mac_addr[ETH_ALEN];
-	int ifidx = cb->args[0];
 	int sta_idx = cb->args[1];
 	int err;
 
-	if (!ifidx)
-		ifidx = nl80211_get_ifidx(cb);
-	if (ifidx < 0)
-		return ifidx;
-
-	rtnl_lock();
-
-	netdev = __dev_get_by_index(sock_net(skb->sk), ifidx);
-	if (!netdev) {
-		err = -ENODEV;
-		goto out_rtnl;
-	}
-
-	dev = cfg80211_get_dev_from_ifindex(sock_net(skb->sk), ifidx);
-	if (IS_ERR(dev)) {
-		err = PTR_ERR(dev);
-		goto out_rtnl;
-	}
+	err = nl80211_prepare_netdev_dump(skb, cb, &dev, &netdev);
+	if (err)
+		return err;
 
 	if (!dev->ops->dump_station) {
 		err = -EOPNOTSUPP;
@@ -1799,9 +1824,7 @@ static int nl80211_dump_station(struct s
 	cb->args[1] = sta_idx;
 	err = skb->len;
  out_err:
-	cfg80211_unlock_rdev(dev);
- out_rtnl:
-	rtnl_unlock();
+	nl80211_finish_netdev_dump(dev);
 
 	return err;
 }
@@ -2121,28 +2144,12 @@ static int nl80211_dump_mpath(struct sk_
 	struct net_device *netdev;
 	u8 dst[ETH_ALEN];
 	u8 next_hop[ETH_ALEN];
-	int ifidx = cb->args[0];
 	int path_idx = cb->args[1];
 	int err;
 
-	if (!ifidx)
-		ifidx = nl80211_get_ifidx(cb);
-	if (ifidx < 0)
-		return ifidx;
-
-	rtnl_lock();
-
-	netdev = __dev_get_by_index(sock_net(skb->sk), ifidx);
-	if (!netdev) {
-		err = -ENODEV;
-		goto out_rtnl;
-	}
-
-	dev = cfg80211_get_dev_from_ifindex(sock_net(skb->sk), ifidx);
-	if (IS_ERR(dev)) {
-		err = PTR_ERR(dev);
-		goto out_rtnl;
-	}
+	err = nl80211_prepare_netdev_dump(skb, cb, &dev, &netdev);
+	if (err)
+		return err;
 
 	if (!dev->ops->dump_mpath) {
 		err = -EOPNOTSUPP;
@@ -2176,10 +2183,7 @@ static int nl80211_dump_mpath(struct sk_
 	cb->args[1] = path_idx;
 	err = skb->len;
  out_err:
-	cfg80211_unlock_rdev(dev);
- out_rtnl:
-	rtnl_unlock();
-
+	nl80211_finish_netdev_dump(dev);
 	return err;
 }
 
@@ -2986,25 +2990,12 @@ static int nl80211_dump_scan(struct sk_b
 	struct net_device *dev;
 	struct cfg80211_internal_bss *scan;
 	struct wireless_dev *wdev;
-	int ifidx = cb->args[0];
 	int start = cb->args[1], idx = 0;
 	int err;
 
-	if (!ifidx)
-		ifidx = nl80211_get_ifidx(cb);
-	if (ifidx < 0)
-		return ifidx;
-	cb->args[0] = ifidx;
-
-	dev = dev_get_by_index(sock_net(skb->sk), ifidx);
-	if (!dev)
-		return -ENODEV;
-
-	rdev = cfg80211_get_dev_from_ifindex(sock_net(skb->sk), ifidx);
-	if (IS_ERR(rdev)) {
-		err = PTR_ERR(rdev);
-		goto out_put_netdev;
-	}
+	err = nl80211_prepare_netdev_dump(skb, cb, &rdev, &dev);
+	if (err)
+		return err;
 
 	wdev = dev->ieee80211_ptr;
 
@@ -3020,21 +3011,17 @@ static int nl80211_dump_scan(struct sk_b
 				cb->nlh->nlmsg_seq, NLM_F_MULTI,
 				rdev, wdev, scan) < 0) {
 			idx--;
-			goto out;
+			break;
 		}
 	}
 
- out:
 	spin_unlock_bh(&rdev->bss_lock);
 	wdev_unlock(wdev);
 
 	cb->args[1] = idx;
-	err = skb->len;
-	cfg80211_unlock_rdev(rdev);
- out_put_netdev:
-	dev_put(dev);
+	nl80211_finish_netdev_dump(rdev);
 
-	return err;
+	return skb->len;
 }
 
 static int nl80211_send_survey(struct sk_buff *msg, u32 pid, u32 seq,
@@ -3080,29 +3067,12 @@ static int nl80211_dump_survey(struct sk
 	struct survey_info survey;
 	struct cfg80211_registered_device *dev;
 	struct net_device *netdev;
-	int ifidx = cb->args[0];
 	int survey_idx = cb->args[1];
 	int res;
 
-	if (!ifidx)
-		ifidx = nl80211_get_ifidx(cb);
-	if (ifidx < 0)
-		return ifidx;
-	cb->args[0] = ifidx;
-
-	rtnl_lock();
-
-	netdev = __dev_get_by_index(sock_net(skb->sk), ifidx);
-	if (!netdev) {
-		res = -ENODEV;
-		goto out_rtnl;
-	}
-
-	dev = cfg80211_get_dev_from_ifindex(sock_net(skb->sk), ifidx);
-	if (IS_ERR(dev)) {
-		res = PTR_ERR(dev);
-		goto out_rtnl;
-	}
+	res = nl80211_prepare_netdev_dump(skb, cb, &dev, &netdev);
+	if (res)
+		return res;
 
 	if (!dev->ops->dump_survey) {
 		res = -EOPNOTSUPP;
@@ -3130,10 +3100,7 @@ static int nl80211_dump_survey(struct sk
 	cb->args[1] = survey_idx;
 	res = skb->len;
  out_err:
-	cfg80211_unlock_rdev(dev);
- out_rtnl:
-	rtnl_unlock();
