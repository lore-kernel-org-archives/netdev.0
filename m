From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [PATCH 2/4 v2] nl80211: use the new genetlink pre/post_doit hooks
Date: Mon, 04 Oct 2010 21:36:35 +0200
Message-ID: <1286220995.3620.60.camel@jlt3.sipsolutions.net>
References: <20101004191402.183055479@sipsolutions.net>
	 <20101004191838.964614880@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20101004191838.964614880-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

This makes nl80211 use the new genetlink
pre_doit/post_doit hooks for locking and
checking the interface/wiphy index.

This significantly reduces the code size
and the likelihood of locking errors.

Signed-off-by: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
v2: updated commit message

 net/wireless/nl80211.c | 1735 +++++++++++++++----------------------------------
 1 file changed, 532 insertions(+), 1203 deletions(-)

--- wireless-testing.orig/net/wireless/nl80211.c	2010-10-01 00:15:08.000000000 +0200
+++ wireless-testing/net/wireless/nl80211.c	2010-10-01 11:09:34.000000000 +0200
@@ -23,6 +23,11 @@
 #include "nl80211.h"
 #include "reg.h"
 
+static int nl80211_pre_doit(struct genl_ops *ops, struct sk_buff *skb,
+			    struct genl_info *info);
+static void nl80211_post_doit(struct genl_ops *ops, struct sk_buff *skb,
+			      struct genl_info *info);
+
 /* the netlink family */
 static struct genl_family nl80211_fam = {
 	.id = GENL_ID_GENERATE,	/* don't bother with a hardcoded ID */
@@ -31,6 +36,8 @@ static struct genl_family nl80211_fam =
 	.version = 1,		/* no particular meaning now */
 	.maxattr = NL80211_ATTR_MAX,
 	.netnsok = true,
+	.pre_doit = nl80211_pre_doit,
+	.post_doit = nl80211_post_doit,
 };
 
 /* internal helper: get rdev and dev */
@@ -703,28 +710,18 @@ static int nl80211_dump_wiphy(struct sk_
 static int nl80211_get_wiphy(struct sk_buff *skb, struct genl_info *info)
 {
 	struct sk_buff *msg;
-	struct cfg80211_registered_device *dev;
-
-	dev = cfg80211_get_dev_from_info(info);
-	if (IS_ERR(dev))
-		return PTR_ERR(dev);
+	struct cfg80211_registered_device *dev = info->user_ptr[0];
 
 	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
 	if (!msg)
-		goto out_err;
-
-	if (nl80211_send_wiphy(msg, info->snd_pid, info->snd_seq, 0, dev) < 0)
-		goto out_free;
+		return -ENOMEM;
 
-	cfg80211_unlock_rdev(dev);
+	if (nl80211_send_wiphy(msg, info->snd_pid, info->snd_seq, 0, dev) < 0) {
+		nlmsg_free(msg);
+		return -ENOBUFS;
+	}
 
 	return genlmsg_reply(msg, info);
-
- out_free:
-	nlmsg_free(msg);
- out_err:
-	cfg80211_unlock_rdev(dev);
-	return -ENOBUFS;
 }
 
 static const struct nla_policy txq_params_policy[NL80211_TXQ_ATTR_MAX + 1] = {
@@ -813,24 +810,10 @@ static int __nl80211_set_channel(struct
 
 static int nl80211_set_channel(struct sk_buff *skb, struct genl_info *info)
 {
-	struct cfg80211_registered_device *rdev;
-	struct net_device *netdev;
-	int result;
-
-	rtnl_lock();
-
-	result = get_rdev_dev_by_info_ifindex(info, &rdev, &netdev);
-	if (result)
-		goto unlock_rtnl;
-
-	result = __nl80211_set_channel(rdev, netdev->ieee80211_ptr, info);
-
-	dev_put(netdev);
-	cfg80211_unlock_rdev(rdev);
- unlock_rtnl:
-	rtnl_unlock();
+	struct cfg80211_registered_device *rdev = info->user_ptr[0];
+	struct net_device *netdev = info->user_ptr[1];
 
-	return result;
+	return __nl80211_set_channel(rdev, netdev->ieee80211_ptr, info);
 }
 
 static int nl80211_set_wiphy(struct sk_buff *skb, struct genl_info *info)
@@ -845,8 +828,6 @@ static int nl80211_set_wiphy(struct sk_b
 	u32 frag_threshold = 0, rts_threshold = 0;
 	u8 coverage_class = 0;
 
-	rtnl_lock();
-
 	/*
 	 * Try to find the wiphy and netdev. Normally this
 	 * function shouldn't need the netdev, but this is
@@ -873,8 +854,7 @@ static int nl80211_set_wiphy(struct sk_b
 		rdev = __cfg80211_rdev_from_info(info);
 		if (IS_ERR(rdev)) {
 			mutex_unlock(&cfg80211_mutex);
-			result = PTR_ERR(rdev);
-			goto unlock;
+			return PTR_ERR(rdev);
 		}
 		wdev = NULL;
 		netdev = NULL;
@@ -1056,8 +1036,6 @@ static int nl80211_set_wiphy(struct sk_b
 	mutex_unlock(&rdev->mtx);
 	if (netdev)
 		dev_put(netdev);
- unlock:
-	rtnl_unlock();
 	return result;
 }
 
@@ -1137,33 +1115,20 @@ static int nl80211_dump_interface(struct
 static int nl80211_get_interface(struct sk_buff *skb, struct genl_info *info)
 {
 	struct sk_buff *msg;
-	struct cfg80211_registered_device *dev;
-	struct net_device *netdev;
-	int err;
-
-	err = get_rdev_dev_by_info_ifindex(info, &dev, &netdev);
-	if (err)
-		return err;
+	struct cfg80211_registered_device *dev = info->user_ptr[0];
+	struct net_device *netdev = info->user_ptr[1];
 
 	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
 	if (!msg)
-		goto out_err;
+		return -ENOMEM;
 
 	if (nl80211_send_iface(msg, info->snd_pid, info->snd_seq, 0,
-			       dev, netdev) < 0)
-		goto out_free;
-
-	dev_put(netdev);
-	cfg80211_unlock_rdev(dev);
+			       dev, netdev) < 0) {
+		nlmsg_free(msg);
+		return -ENOBUFS;
+	}
 
 	return genlmsg_reply(msg, info);
-
- out_free:
-	nlmsg_free(msg);
- out_err:
-	dev_put(netdev);
-	cfg80211_unlock_rdev(dev);
-	return -ENOBUFS;
 }
 
 static const struct nla_policy mntr_flags_policy[NL80211_MNTR_FLAG_MAX + 1] = {
@@ -1223,39 +1188,29 @@ static int nl80211_valid_4addr(struct cf
 
 static int nl80211_set_interface(struct sk_buff *skb, struct genl_info *info)
 {
-	struct cfg80211_registered_device *rdev;
+	struct cfg80211_registered_device *rdev = info->user_ptr[0];
 	struct vif_params params;
 	int err;
 	enum nl80211_iftype otype, ntype;
-	struct net_device *dev;
+	struct net_device *dev = info->user_ptr[1];
 	u32 _flags, *flags = NULL;
 	bool change = false;
 
 	memset(&params, 0, sizeof(params));
 
-	rtnl_lock();
-
-	err = get_rdev_dev_by_info_ifindex(info, &rdev, &dev);
-	if (err)
-		goto unlock_rtnl;
-
 	otype = ntype = dev->ieee80211_ptr->iftype;
 
 	if (info->attrs[NL80211_ATTR_IFTYPE]) {
 		ntype = nla_get_u32(info->attrs[NL80211_ATTR_IFTYPE]);
 		if (otype != ntype)
 			change = true;
-		if (ntype > NL80211_IFTYPE_MAX) {
-			err = -EINVAL;
-			goto unlock;
-		}
+		if (ntype > NL80211_IFTYPE_MAX)
+			return -EINVAL;
 	}
 
 	if (info->attrs[NL80211_ATTR_MESH_ID]) {
-		if (ntype != NL80211_IFTYPE_MESH_POINT) {
-			err = -EINVAL;
-			goto unlock;
-		}
+		if (ntype != NL80211_IFTYPE_MESH_POINT)
+			return -EINVAL;
 		params.mesh_id = nla_data(info->attrs[NL80211_ATTR_MESH_ID]);
 		params.mesh_id_len = nla_len(info->attrs[NL80211_ATTR_MESH_ID]);
 		change = true;
@@ -1266,20 +1221,18 @@ static int nl80211_set_interface(struct
 		change = true;
 		err = nl80211_valid_4addr(rdev, dev, params.use_4addr, ntype);
 		if (err)
-			goto unlock;
+			return err;
 	} else {
 		params.use_4addr = -1;
 	}
 
 	if (info->attrs[NL80211_ATTR_MNTR_FLAGS]) {
-		if (ntype != NL80211_IFTYPE_MONITOR) {
-			err = -EINVAL;
-			goto unlock;
-		}
+		if (ntype != NL80211_IFTYPE_MONITOR)
+			return -EINVAL;
 		err = parse_monitor_flags(info->attrs[NL80211_ATTR_MNTR_FLAGS],
 					  &_flags);
 		if (err)
-			goto unlock;
+			return err;
 
 		flags = &_flags;
 		change = true;
@@ -1293,17 +1246,12 @@ static int nl80211_set_interface(struct
 	if (!err && params.use_4addr != -1)
 		dev->ieee80211_ptr->use_4addr = params.use_4addr;
 
- unlock:
-	dev_put(dev);
-	cfg80211_unlock_rdev(rdev);
- unlock_rtnl:
-	rtnl_unlock();
 	return err;
 }
 
 static int nl80211_new_interface(struct sk_buff *skb, struct genl_info *info)
 {
-	struct cfg80211_registered_device *rdev;
+	struct cfg80211_registered_device *rdev = info->user_ptr[0];
 	struct vif_params params;
 	int err;
 	enum nl80211_iftype type = NL80211_IFTYPE_UNSPECIFIED;
@@ -1320,19 +1268,9 @@ static int nl80211_new_interface(struct
 			return -EINVAL;
 	}
 
-	rtnl_lock();
-
-	rdev = cfg80211_get_dev_from_info(info);
-	if (IS_ERR(rdev)) {
-		err = PTR_ERR(rdev);
-		goto unlock_rtnl;
-	}
-
 	if (!rdev->ops->add_virtual_intf ||
-	    !(rdev->wiphy.interface_modes & (1 << type))) {
-		err = -EOPNOTSUPP;
-		goto unlock;
-	}
+	    !(rdev->wiphy.interface_modes & (1 << type)))
+		return -EOPNOTSUPP;
 
 	if (type == NL80211_IFTYPE_MESH_POINT &&
 	    info->attrs[NL80211_ATTR_MESH_ID]) {
@@ -1344,7 +1282,7 @@ static int nl80211_new_interface(struct
 		params.use_4addr = !!nla_get_u8(info->attrs[NL80211_ATTR_4ADDR]);
 		err = nl80211_valid_4addr(rdev, NULL, params.use_4addr, type);
 		if (err)
-			goto unlock;
+			return err;
 	}
 
 	err = parse_monitor_flags(type == NL80211_IFTYPE_MONITOR ?
@@ -1354,38 +1292,18 @@ static int nl80211_new_interface(struct
 		nla_data(info->attrs[NL80211_ATTR_IFNAME]),
 		type, err ? NULL : &flags, &params);
 
- unlock:
-	cfg80211_unlock_rdev(rdev);
- unlock_rtnl:
-	rtnl_unlock();
 	return err;
 }
 
 static int nl80211_del_interface(struct sk_buff *skb, struct genl_info *info)
 {
-	struct cfg80211_registered_device *rdev;
-	int err;
-	struct net_device *dev;
-
-	rtnl_lock();
-
-	err = get_rdev_dev_by_info_ifindex(info, &rdev, &dev);
-	if (err)
-		goto unlock_rtnl;
-
-	if (!rdev->ops->del_virtual_intf) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
+	struct cfg80211_registered_device *rdev = info->user_ptr[0];
+	struct net_device *dev = info->user_ptr[1];
 
-	err = rdev->ops->del_virtual_intf(&rdev->wiphy, dev);
+	if (!rdev->ops->del_virtual_intf)
+		return -EOPNOTSUPP;
 
- out:
-	cfg80211_unlock_rdev(rdev);
-	dev_put(dev);
- unlock_rtnl:
-	rtnl_unlock();
-	return err;
+	return rdev->ops->del_virtual_intf(&rdev->wiphy, dev);
 }
 
 struct get_key_cookie {
@@ -1438,9 +1356,9 @@ static void get_key_callback(void *c, st
 
 static int nl80211_get_key(struct sk_buff *skb, struct genl_info *info)
 {
-	struct cfg80211_registered_device *rdev;
+	struct cfg80211_registered_device *rdev = info->user_ptr[0];
 	int err;
-	struct net_device *dev;
+	struct net_device *dev = info->user_ptr[1];
 	u8 key_idx = 0;
 	u8 *mac_addr = NULL;
 	struct get_key_cookie cookie = {
@@ -1458,30 +1376,17 @@ static int nl80211_get_key(struct sk_buf
 	if (info->attrs[NL80211_ATTR_MAC])
 		mac_addr = nla_data(info->attrs[NL80211_ATTR_MAC]);
 
-	rtnl_lock();
-
-	err = get_rdev_dev_by_info_ifindex(info, &rdev, &dev);
-	if (err)
-		goto unlock_rtnl;
-
-	if (!rdev->ops->get_key) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
+	if (!rdev->ops->get_key)
+		return -EOPNOTSUPP;
 
 	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
-	if (!msg) {
-		err = -ENOMEM;
-		goto out;
-	}
+	if (!msg)
+		return -ENOMEM;
 
 	hdr = nl80211hdr_put(msg, info->snd_pid, info->snd_seq, 0,
 			     NL80211_CMD_NEW_KEY);
-
-	if (IS_ERR(hdr)) {
-		err = PTR_ERR(hdr);
-		goto free_msg;
-	}
+	if (IS_ERR(hdr))
+		return PTR_ERR(hdr);
 
 	cookie.msg = msg;
 	cookie.idx = key_idx;
@@ -1501,28 +1406,21 @@ static int nl80211_get_key(struct sk_buf
 		goto nla_put_failure;
 
 	genlmsg_end(msg, hdr);
-	err = genlmsg_reply(msg, info);
-	goto out;
+	return genlmsg_reply(msg, info);
 
  nla_put_failure:
 	err = -ENOBUFS;
  free_msg:
 	nlmsg_free(msg);
- out:
-	cfg80211_unlock_rdev(rdev);
-	dev_put(dev);
- unlock_rtnl:
-	rtnl_unlock();
-
 	return err;
 }
 
 static int nl80211_set_key(struct sk_buff *skb, struct genl_info *info)
 {
-	struct cfg80211_registered_device *rdev;
+	struct cfg80211_registered_device *rdev = info->user_ptr[0];
 	struct key_parse key;
 	int err;
-	struct net_device *dev;
+	struct net_device *dev = info->user_ptr[1];
 	int (*func)(struct wiphy *wiphy, struct net_device *netdev,
 		    u8 key_index);
 
@@ -1537,21 +1435,13 @@ static int nl80211_set_key(struct sk_buf
 	if (!key.def && !key.defmgmt)
 		return -EINVAL;
 
-	rtnl_lock();
-
-	err = get_rdev_dev_by_info_ifindex(info, &rdev, &dev);
-	if (err)
-		goto unlock_rtnl;
-
 	if (key.def)
 		func = rdev->ops->set_default_key;
 	else
 		func = rdev->ops->set_default_mgmt_key;
 
-	if (!func) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
+	if (!func)
+		return -EOPNOTSUPP;
 
 	wdev_lock(dev->ieee80211_ptr);
 	err = nl80211_key_allowed(dev->ieee80211_ptr);
@@ -1568,21 +1458,14 @@ static int nl80211_set_key(struct sk_buf
 #endif
 	wdev_unlock(dev->ieee80211_ptr);
 
- out:
-	cfg80211_unlock_rdev(rdev);
-	dev_put(dev);
-
- unlock_rtnl:
-	rtnl_unlock();
-
 	return err;
 }
 
 static int nl80211_new_key(struct sk_buff *skb, struct genl_info *info)
 {
-	struct cfg80211_registered_device *rdev;
+	struct cfg80211_registered_device *rdev = info->user_ptr[0];
 	int err;
-	struct net_device *dev;
+	struct net_device *dev = info->user_ptr[1];
 	struct key_parse key;
 	u8 *mac_addr = NULL;
 
@@ -1596,21 +1479,11 @@ static int nl80211_new_key(struct sk_buf
 	if (info->attrs[NL80211_ATTR_MAC])
 		mac_addr = nla_data(info->attrs[NL80211_ATTR_MAC]);
 
-	rtnl_lock();
-
-	err = get_rdev_dev_by_info_ifindex(info, &rdev, &dev);
-	if (err)
-		goto unlock_rtnl;
-
-	if (!rdev->ops->add_key) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
+	if (!rdev->ops->add_key)
+		return -EOPNOTSUPP;
 
-	if (cfg80211_validate_key_settings(rdev, &key.p, key.idx, mac_addr)) {
-		err = -EINVAL;
-		goto out;
-	}
+	if (cfg80211_validate_key_settings(rdev, &key.p, key.idx, mac_addr))
+		return -EINVAL;
 
 	wdev_lock(dev->ieee80211_ptr);
 	err = nl80211_key_allowed(dev->ieee80211_ptr);
@@ -1619,20 +1492,14 @@ static int nl80211_new_key(struct sk_buf
 					 mac_addr, &key.p);
 	wdev_unlock(dev->ieee80211_ptr);
 
- out:
-	cfg80211_unlock_rdev(rdev);
-	dev_put(dev);
- unlock_rtnl:
-	rtnl_unlock();
-
 	return err;
 }
 
 static int nl80211_del_key(struct sk_buff *skb, struct genl_info *info)
 {
-	struct cfg80211_registered_device *rdev;
+	struct cfg80211_registered_device *rdev = info->user_ptr[0];
 	int err;
-	struct net_device *dev;
+	struct net_device *dev = info->user_ptr[1];
 	u8 *mac_addr = NULL;
 	struct key_parse key;
 
@@ -1643,16 +1510,8 @@ static int nl80211_del_key(struct sk_buf
 	if (info->attrs[NL80211_ATTR_MAC])
 		mac_addr = nla_data(info->attrs[NL80211_ATTR_MAC]);
 
-	rtnl_lock();
-
-	err = get_rdev_dev_by_info_ifindex(info, &rdev, &dev);
-	if (err)
-		goto unlock_rtnl;
-
-	if (!rdev->ops->del_key) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
+	if (!rdev->ops->del_key)
+		return -EOPNOTSUPP;
 
 	wdev_lock(dev->ieee80211_ptr);
 	err = nl80211_key_allowed(dev->ieee80211_ptr);
@@ -1669,13 +1528,6 @@ static int nl80211_del_key(struct sk_buf
 #endif
 	wdev_unlock(dev->ieee80211_ptr);
 
- out:
-	cfg80211_unlock_rdev(rdev);
-	dev_put(dev);
-
- unlock_rtnl:
-	rtnl_unlock();
-
 	return err;
 }
 
@@ -1683,36 +1535,25 @@ static int nl80211_addset_beacon(struct
 {
         int (*call)(struct wiphy *wiphy, struct net_device *dev,
 		    struct beacon_parameters *info);
-	struct cfg80211_registered_device *rdev;
-	int err;
-	struct net_device *dev;
+	struct cfg80211_registered_device *rdev = info->user_ptr[0];
+	struct net_device *dev = info->user_ptr[1];
 	struct beacon_parameters params;
 	int haveinfo = 0;
 
 	if (!is_valid_ie_attr(info->attrs[NL80211_ATTR_BEACON_TAIL]))
 		return -EINVAL;
 
-	rtnl_lock();
-
-	err = get_rdev_dev_by_info_ifindex(info, &rdev, &dev);
-	if (err)
-		goto unlock_rtnl;
-
 	if (dev->ieee80211_ptr->iftype != NL80211_IFTYPE_AP &&
-	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_P2P_GO) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
+	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_P2P_GO)
+		return -EOPNOTSUPP;
 
 	switch (info->genlhdr->cmd) {
 	case NL80211_CMD_NEW_BEACON:
 		/* these are required for NEW_BEACON */
 		if (!info->attrs[NL80211_ATTR_BEACON_INTERVAL] ||
 		    !info->attrs[NL80211_ATTR_DTIM_PERIOD] ||
-		    !info->attrs[NL80211_ATTR_BEACON_HEAD]) {
-			err = -EINVAL;
-			goto out;
-		}
+		    !info->attrs[NL80211_ATTR_BEACON_HEAD])
+			return -EINVAL;
 
 		call = rdev->ops->add_beacon;
 		break;
@@ -1721,14 +1562,11 @@ static int nl80211_addset_beacon(struct
 		break;
 	default:
 		WARN_ON(1);
-		err = -EOPNOTSUPP;
-		goto out;
+		return -EOPNOTSUPP;
 	}
 
-	if (!call) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
+	if (!call)
+		return -EOPNOTSUPP;
 
 	memset(&params, 0, sizeof(params));
 
@@ -1758,53 +1596,25 @@ static int nl80211_addset_beacon(struct
 		haveinfo = 1;
 	}
 
-	if (!haveinfo) {
-		err = -EINVAL;
-		goto out;
-	}
-
-	err = call(&rdev->wiphy, dev, &params);
-
- out:
-	cfg80211_unlock_rdev(rdev);
-	dev_put(dev);
- unlock_rtnl:
-	rtnl_unlock();
+	if (!haveinfo)
+		return -EINVAL;
 
-	return err;
+	return call(&rdev->wiphy, dev, &params);
 }
 
 static int nl80211_del_beacon(struct sk_buff *skb, struct genl_info *info)
 {
-	struct cfg80211_registered_device *rdev;
-	int err;
-	struct net_device *dev;
-
-	rtnl_lock();
+	struct cfg80211_registered_device *rdev = info->user_ptr[0];
+	struct net_device *dev = info->user_ptr[1];
 
-	err = get_rdev_dev_by_info_ifindex(info, &rdev, &dev);
-	if (err)
-		goto unlock_rtnl;
-
-	if (!rdev->ops->del_beacon) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
+	if (!rdev->ops->del_beacon)
+		return -EOPNOTSUPP;
 
 	if (dev->ieee80211_ptr->iftype != NL80211_IFTYPE_AP &&
-	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_P2P_GO) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
-	err = rdev->ops->del_beacon(&rdev->wiphy, dev);
-
- out:
-	cfg80211_unlock_rdev(rdev);
-	dev_put(dev);
- unlock_rtnl:
-	rtnl_unlock();
+	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_P2P_GO)
+		return -EOPNOTSUPP;
 
-	return err;
+	return rdev->ops->del_beacon(&rdev->wiphy, dev);
 }
 
 static const struct nla_policy sta_flags_policy[NL80211_STA_FLAG_MAX + 1] = {
@@ -2001,12 +1811,12 @@ static int nl80211_dump_station(struct s
 
 static int nl80211_get_station(struct sk_buff *skb, struct genl_info *info)
 {
-	struct cfg80211_registered_device *rdev;
-	int err;
-	struct net_device *dev;
+	struct cfg80211_registered_device *rdev = info->user_ptr[0];
+	struct net_device *dev = info->user_ptr[1];
 	struct station_info sinfo;
 	struct sk_buff *msg;
 	u8 *mac_addr = NULL;
+	int err;
 
 	memset(&sinfo, 0, sizeof(sinfo));
 
@@ -2015,42 +1825,25 @@ static int nl80211_get_station(struct sk
 
 	mac_addr = nla_data(info->attrs[NL80211_ATTR_MAC]);
 
-	rtnl_lock();
-
-	err = get_rdev_dev_by_info_ifindex(info, &rdev, &dev);
-	if (err)
-		goto out_rtnl;
-
-	if (!rdev->ops->get_station) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
+	if (!rdev->ops->get_station)
+		return -EOPNOTSUPP;
 
 	err = rdev->ops->get_station(&rdev->wiphy, dev, mac_addr, &sinfo);
 	if (err)
-		goto out;
+		return err;
 
 	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
 	if (!msg)
-		goto out;
+		return -ENOMEM;
 
 	if (nl80211_send_station(msg, info->snd_pid, info->snd_seq, 0,
-				 dev, mac_addr, &sinfo) < 0)
-		goto out_free;
+				 dev, mac_addr, &sinfo) < 0) {
+		nlmsg_free(msg);
+		return -ENOBUFS;
+	}
 
-	err = genlmsg_reply(msg, info);
-	goto out;
-
- out_free:
-	nlmsg_free(msg);
- out:
-	cfg80211_unlock_rdev(rdev);
-	dev_put(dev);
- out_rtnl:
-	rtnl_unlock();
-
-	return err;
-}
+	return genlmsg_reply(msg, info);
+}
 
 /*
  * Get vlan interface making sure it is running and on the right wiphy.
@@ -2079,9 +1872,9 @@ static int get_vlan(struct genl_info *in
 
 static int nl80211_set_station(struct sk_buff *skb, struct genl_info *info)
 {
-	struct cfg80211_registered_device *rdev;
+	struct cfg80211_registered_device *rdev = info->user_ptr[0];
 	int err;
-	struct net_device *dev;
+	struct net_device *dev = info->user_ptr[1];
 	struct station_parameters params;
 	u8 *mac_addr = NULL;
 
@@ -2119,12 +1912,6 @@ static int nl80211_set_station(struct sk
 		params.plink_action =
 		    nla_get_u8(info->attrs[NL80211_ATTR_STA_PLINK_ACTION]);
 
-	rtnl_lock();
-
-	err = get_rdev_dev_by_info_ifindex(info, &rdev, &dev);
-	if (err)
-		goto out_rtnl;
-
 	err = get_vlan(info, rdev, &params.vlan);
 	if (err)
 		goto out;
@@ -2186,19 +1973,15 @@ static int nl80211_set_station(struct sk
  out:
 	if (params.vlan)
 		dev_put(params.vlan);
-	cfg80211_unlock_rdev(rdev);
-	dev_put(dev);
- out_rtnl:
-	rtnl_unlock();
 
 	return err;
 }
 
 static int nl80211_new_station(struct sk_buff *skb, struct genl_info *info)
 {
-	struct cfg80211_registered_device *rdev;
+	struct cfg80211_registered_device *rdev = info->user_ptr[0];
 	int err;
-	struct net_device *dev;
+	struct net_device *dev = info->user_ptr[1];
 	struct station_parameters params;
 	u8 *mac_addr = NULL;
 
@@ -2235,18 +2018,10 @@ static int nl80211_new_station(struct sk
 	if (parse_station_flags(info, &params))
 		return -EINVAL;
 
-	rtnl_lock();
-
-	err = get_rdev_dev_by_info_ifindex(info, &rdev, &dev);
-	if (err)
-		goto out_rtnl;
-
 	if (dev->ieee80211_ptr->iftype != NL80211_IFTYPE_AP &&
 	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_AP_VLAN &&
-	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_P2P_GO) {
-		err = -EINVAL;
-		goto out;
-	}
+	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_P2P_GO)
+		return -EINVAL;
 
 	err = get_vlan(info, rdev, &params.vlan);
 	if (err)
@@ -2270,52 +2045,28 @@ static int nl80211_new_station(struct sk
  out:
 	if (params.vlan)
 		dev_put(params.vlan);
-	cfg80211_unlock_rdev(rdev);
-	dev_put(dev);
- out_rtnl:
-	rtnl_unlock();
-
 	return err;
 }
 
 static int nl80211_del_station(struct sk_buff *skb, struct genl_info *info)
 {
-	struct cfg80211_registered_device *rdev;
-	int err;
-	struct net_device *dev;
+	struct cfg80211_registered_device *rdev = info->user_ptr[0];
+	struct net_device *dev = info->user_ptr[1];
 	u8 *mac_addr = NULL;
 
 	if (info->attrs[NL80211_ATTR_MAC])
 		mac_addr = nla_data(info->attrs[NL80211_ATTR_MAC]);
 
-	rtnl_lock();
-
-	err = get_rdev_dev_by_info_ifindex(info, &rdev, &dev);
-	if (err)
-		goto out_rtnl;
-
 	if (dev->ieee80211_ptr->iftype != NL80211_IFTYPE_AP &&
 	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_AP_VLAN &&
 	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_MESH_POINT &&
-	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_P2P_GO) {
-		err = -EINVAL;
-		goto out;
-	}
-
-	if (!rdev->ops->del_station) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
-
-	err = rdev->ops->del_station(&rdev->wiphy, dev, mac_addr);
+	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_P2P_GO)
+		return -EINVAL;
 
- out:
-	cfg80211_unlock_rdev(rdev);
-	dev_put(dev);
- out_rtnl:
-	rtnl_unlock();
+	if (!rdev->ops->del_station)
+		return -EOPNOTSUPP;
 
-	return err;
+	return rdev->ops->del_station(&rdev->wiphy, dev, mac_addr);
 }
 
 static int nl80211_send_mpath(struct sk_buff *msg, u32 pid, u32 seq,
@@ -2442,9 +2193,9 @@ static int nl80211_dump_mpath(struct sk_
 
 static int nl80211_get_mpath(struct sk_buff *skb, struct genl_info *info)
 {
-	struct cfg80211_registered_device *rdev;
+	struct cfg80211_registered_device *rdev = info->user_ptr[0];
 	int err;
-	struct net_device *dev;
+	struct net_device *dev = info->user_ptr[1];
 	struct mpath_info pinfo;
 	struct sk_buff *msg;
 	u8 *dst = NULL;
@@ -2457,53 +2208,33 @@ static int nl80211_get_mpath(struct sk_b
 
 	dst = nla_data(info->attrs[NL80211_ATTR_MAC]);
 
-	rtnl_lock();
-
-	err = get_rdev_dev_by_info_ifindex(info, &rdev, &dev);
-	if (err)
-		goto out_rtnl;
-
-	if (!rdev->ops->get_mpath) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
+	if (!rdev->ops->get_mpath)
+		return -EOPNOTSUPP;
 
-	if (dev->ieee80211_ptr->iftype != NL80211_IFTYPE_MESH_POINT) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
+	if (dev->ieee80211_ptr->iftype != NL80211_IFTYPE_MESH_POINT)
+		return -EOPNOTSUPP;
 
 	err = rdev->ops->get_mpath(&rdev->wiphy, dev, dst, next_hop, &pinfo);
 	if (err)
-		goto out;
+		return err;
 
 	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
 	if (!msg)
-		goto out;
+		return -ENOMEM;
 
 	if (nl80211_send_mpath(msg, info->snd_pid, info->snd_seq, 0,
-				 dev, dst, next_hop, &pinfo) < 0)
-		goto out_free;
-
-	err = genlmsg_reply(msg, info);
-	goto out;
-
- out_free:
-	nlmsg_free(msg);
- out:
-	cfg80211_unlock_rdev(rdev);
-	dev_put(dev);
- out_rtnl:
-	rtnl_unlock();
+				 dev, dst, next_hop, &pinfo) < 0) {
+		nlmsg_free(msg);
+		return -ENOBUFS;
+	}
 
-	return err;
+	return genlmsg_reply(msg, info);
 }
 
 static int nl80211_set_mpath(struct sk_buff *skb, struct genl_info *info)
 {
-	struct cfg80211_registered_device *rdev;
-	int err;
-	struct net_device *dev;
+	struct cfg80211_registered_device *rdev = info->user_ptr[0];
+	struct net_device *dev = info->user_ptr[1];
 	u8 *dst = NULL;
 	u8 *next_hop = NULL;
 
@@ -2516,42 +2247,22 @@ static int nl80211_set_mpath(struct sk_b
 	dst = nla_data(info->attrs[NL80211_ATTR_MAC]);
 	next_hop = nla_data(info->attrs[NL80211_ATTR_MPATH_NEXT_HOP]);
 
-	rtnl_lock();
-
-	err = get_rdev_dev_by_info_ifindex(info, &rdev, &dev);
-	if (err)
-		goto out_rtnl;
-
-	if (!rdev->ops->change_mpath) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
-
-	if (dev->ieee80211_ptr->iftype != NL80211_IFTYPE_MESH_POINT) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
-
-	if (!netif_running(dev)) {
-		err = -ENETDOWN;
-		goto out;
-	}
+	if (!rdev->ops->change_mpath)
+		return -EOPNOTSUPP;
 
-	err = rdev->ops->change_mpath(&rdev->wiphy, dev, dst, next_hop);
+	if (dev->ieee80211_ptr->iftype != NL80211_IFTYPE_MESH_POINT)
+		return -EOPNOTSUPP;
 
- out:
-	cfg80211_unlock_rdev(rdev);
-	dev_put(dev);
- out_rtnl:
-	rtnl_unlock();
+	if (!netif_running(dev))
+		return -ENETDOWN;
 
-	return err;
+	return rdev->ops->change_mpath(&rdev->wiphy, dev, dst, next_hop);
 }
+
 static int nl80211_new_mpath(struct sk_buff *skb, struct genl_info *info)
 {
-	struct cfg80211_registered_device *rdev;
-	int err;
-	struct net_device *dev;
+	struct cfg80211_registered_device *rdev = info->user_ptr[0];
+	struct net_device *dev = info->user_ptr[1];
 	u8 *dst = NULL;
 	u8 *next_hop = NULL;
 
@@ -2564,75 +2275,37 @@ static int nl80211_new_mpath(struct sk_b
 	dst = nla_data(info->attrs[NL80211_ATTR_MAC]);
 	next_hop = nla_data(info->attrs[NL80211_ATTR_MPATH_NEXT_HOP]);
 
-	rtnl_lock();
-
-	err = get_rdev_dev_by_info_ifindex(info, &rdev, &dev);
-	if (err)
-		goto out_rtnl;
-
-	if (!rdev->ops->add_mpath) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
-
-	if (dev->ieee80211_ptr->iftype != NL80211_IFTYPE_MESH_POINT) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
-
-	if (!netif_running(dev)) {
-		err = -ENETDOWN;
-		goto out;
-	}
+	if (!rdev->ops->add_mpath)
+		return -EOPNOTSUPP;
 
-	err = rdev->ops->add_mpath(&rdev->wiphy, dev, dst, next_hop);
+	if (dev->ieee80211_ptr->iftype != NL80211_IFTYPE_MESH_POINT)
+		return -EOPNOTSUPP;
 
- out:
-	cfg80211_unlock_rdev(rdev);
-	dev_put(dev);
- out_rtnl:
-	rtnl_unlock();
+	if (!netif_running(dev))
+		return -ENETDOWN;
 
-	return err;
+	return rdev->ops->add_mpath(&rdev->wiphy, dev, dst, next_hop);
 }
 
 static int nl80211_del_mpath(struct sk_buff *skb, struct genl_info *info)
 {
-	struct cfg80211_registered_device *rdev;
-	int err;
-	struct net_device *dev;
+	struct cfg80211_registered_device *rdev = info->user_ptr[0];
+	struct net_device *dev = info->user_ptr[1];
 	u8 *dst = NULL;
 
 	if (info->attrs[NL80211_ATTR_MAC])
 		dst = nla_data(info->attrs[NL80211_ATTR_MAC]);
 
-	rtnl_lock();
-
-	err = get_rdev_dev_by_info_ifindex(info, &rdev, &dev);
-	if (err)
-		goto out_rtnl;
-
-	if (!rdev->ops->del_mpath) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
-
-	err = rdev->ops->del_mpath(&rdev->wiphy, dev, dst);
-
- out:
-	cfg80211_unlock_rdev(rdev);
-	dev_put(dev);
- out_rtnl:
-	rtnl_unlock();
+	if (!rdev->ops->del_mpath)
+		return -EOPNOTSUPP;
 
-	return err;
+	return rdev->ops->del_mpath(&rdev->wiphy, dev, dst);
 }
 
 static int nl80211_set_bss(struct sk_buff *skb, struct genl_info *info)
 {
-	struct cfg80211_registered_device *rdev;
-	int err;
-	struct net_device *dev;
+	struct cfg80211_registered_device *rdev = info->user_ptr[0];
+	struct net_device *dev = info->user_ptr[1];
 	struct bss_parameters params;
 
 	memset(&params, 0, sizeof(params));
@@ -2660,32 +2333,14 @@ static int nl80211_set_bss(struct sk_buf
 	if (info->attrs[NL80211_ATTR_AP_ISOLATE])
 		params.ap_isolate = !!nla_get_u8(info->attrs[NL80211_ATTR_AP_ISOLATE]);
 
-	rtnl_lock();
-
-	err = get_rdev_dev_by_info_ifindex(info, &rdev, &dev);
-	if (err)
-		goto out_rtnl;
-
-	if (!rdev->ops->change_bss) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
+	if (!rdev->ops->change_bss)
+		return -EOPNOTSUPP;
 
 	if (dev->ieee80211_ptr->iftype != NL80211_IFTYPE_AP &&
-	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_P2P_GO) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
-
-	err = rdev->ops->change_bss(&rdev->wiphy, dev, &params);
-
- out:
-	cfg80211_unlock_rdev(rdev);
-	dev_put(dev);
- out_rtnl:
-	rtnl_unlock();
+	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_P2P_GO)
+		return -EOPNOTSUPP;
 
-	return err;
+	return rdev->ops->change_bss(&rdev->wiphy, dev, &params);
 }
 
 static const struct nla_policy reg_rule_policy[NL80211_REG_RULE_ATTR_MAX + 1] = {
@@ -2764,37 +2419,26 @@ static int nl80211_req_set_reg(struct sk
 static int nl80211_get_mesh_params(struct sk_buff *skb,
 	struct genl_info *info)
 {
-	struct cfg80211_registered_device *rdev;
+	struct cfg80211_registered_device *rdev = info->user_ptr[0];
 	struct mesh_config cur_params;
 	int err;
-	struct net_device *dev;
+	struct net_device *dev = info->user_ptr[1];
 	void *hdr;
 	struct nlattr *pinfoattr;
 	struct sk_buff *msg;
 
-	rtnl_lock();
-
-	/* Look up our device */
-	err = get_rdev_dev_by_info_ifindex(info, &rdev, &dev);
-	if (err)
-		goto out_rtnl;
-
-	if (!rdev->ops->get_mesh_params) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
+	if (!rdev->ops->get_mesh_params)
+		return -EOPNOTSUPP;
 
 	/* Get the mesh params */
 	err = rdev->ops->get_mesh_params(&rdev->wiphy, dev, &cur_params);
 	if (err)
-		goto out;
+		return err;
 
 	/* Draw up a netlink message to send back */
 	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
-	if (!msg) {
-		err = -ENOBUFS;
-		goto out;
-	}
+	if (!msg)
+		return -ENOMEM;
 	hdr = nl80211hdr_put(msg, info->snd_pid, info->snd_seq, 0,
 			     NL80211_CMD_GET_MESH_PARAMS);
 	if (!hdr)
@@ -2833,21 +2477,12 @@ static int nl80211_get_mesh_params(struc
 			cur_params.dot11MeshHWMPRootMode);
 	nla_nest_end(msg, pinfoattr);
 	genlmsg_end(msg, hdr);
-	err = genlmsg_reply(msg, info);
-	goto out;
+	return genlmsg_reply(msg, info);
 
  nla_put_failure:
 	genlmsg_cancel(msg, hdr);
 	nlmsg_free(msg);
-	err = -EMSGSIZE;
- out:
-	/* Cleanup */
-	cfg80211_unlock_rdev(rdev);
-	dev_put(dev);
- out_rtnl:
-	rtnl_unlock();
-
-	return err;
+	return -ENOBUFS;
 }
 
 #define FILL_IN_MESH_PARAM_IF_SET(table, cfg, param, mask, attr_num, nla_fn) \
@@ -2877,10 +2512,9 @@ static const struct nla_policy nl80211_m
 
 static int nl80211_set_mesh_params(struct sk_buff *skb, struct genl_info *info)
 {
-	int err;
 	u32 mask;
-	struct cfg80211_registered_device *rdev;
-	struct net_device *dev;
+	struct cfg80211_registered_device *rdev = info->user_ptr[0];
+	struct net_device *dev = info->user_ptr[1];
 	struct mesh_config cfg;
 	struct nlattr *tb[NL80211_MESHCONF_ATTR_MAX + 1];
 	struct nlattr *parent_attr;
@@ -2892,16 +2526,8 @@ static int nl80211_set_mesh_params(struc
 			parent_attr, nl80211_meshconf_params_policy))
 		return -EINVAL;
 
-	rtnl_lock();
-
-	err = get_rdev_dev_by_info_ifindex(info, &rdev, &dev);
-	if (err)
-		goto out_rtnl;
-
-	if (!rdev->ops->set_mesh_params) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
+	if (!rdev->ops->set_mesh_params)
+		return -EOPNOTSUPP;
 
 	/* This makes sure that there aren't more than 32 mesh config
 	 * parameters (otherwise our bitfield scheme would not work.) */
@@ -2947,16 +2573,7 @@ static int nl80211_set_mesh_params(struc
 			nla_get_u8);
 
 	/* Apply changes */
-	err = rdev->ops->set_mesh_params(&rdev->wiphy, dev, &cfg, mask);
-
- out:
-	/* cleanup */
-	cfg80211_unlock_rdev(rdev);
-	dev_put(dev);
- out_rtnl:
-	rtnl_unlock();
-
-	return err;
+	return rdev->ops->set_mesh_params(&rdev->wiphy, dev, &cfg, mask);
 }
 
 #undef FILL_IN_MESH_PARAM_IF_SET
@@ -3139,8 +2756,8 @@ static int validate_scan_freqs(struct nl
 
 static int nl80211_trigger_scan(struct sk_buff *skb, struct genl_info *info)
 {
-	struct cfg80211_registered_device *rdev;
-	struct net_device *dev;
+	struct cfg80211_registered_device *rdev = info->user_ptr[0];
+	struct net_device *dev = info->user_ptr[1];
 	struct cfg80211_scan_request *request;
 	struct cfg80211_ssid *ssid;
 	struct ieee80211_channel *channel;
@@ -3153,36 +2770,22 @@ static int nl80211_trigger_scan(struct s
 	if (!is_valid_ie_attr(info->attrs[NL80211_ATTR_IE]))
 		return -EINVAL;
 
-	rtnl_lock();
-
-	err = get_rdev_dev_by_info_ifindex(info, &rdev, &dev);
-	if (err)
-		goto out_rtnl;
-
 	wiphy = &rdev->wiphy;
 
-	if (!rdev->ops->scan) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
+	if (!rdev->ops->scan)
+		return -EOPNOTSUPP;
 
-	if (!netif_running(dev)) {
-		err = -ENETDOWN;
-		goto out;
-	}
+	if (!netif_running(dev))
+		return -ENETDOWN;
 
-	if (rdev->scan_req) {
-		err = -EBUSY;
-		goto out;
-	}
+	if (rdev->scan_req)
+		return -EBUSY;
 
 	if (info->attrs[NL80211_ATTR_SCAN_FREQUENCIES]) {
 		n_channels = validate_scan_freqs(
 				info->attrs[NL80211_ATTR_SCAN_FREQUENCIES]);
-		if (!n_channels) {
-			err = -EINVAL;
-			goto out;
-		}
+		if (!n_channels)
+			return -EINVAL;
 	} else {
 		n_channels = 0;
 
@@ -3195,29 +2798,23 @@ static int nl80211_trigger_scan(struct s
 		nla_for_each_nested(attr, info->attrs[NL80211_ATTR_SCAN_SSIDS], tmp)
 			n_ssids++;
 
-	if (n_ssids > wiphy->max_scan_ssids) {
-		err = -EINVAL;
-		goto out;
-	}
+	if (n_ssids > wiphy->max_scan_ssids)
+		return -EINVAL;
 
 	if (info->attrs[NL80211_ATTR_IE])
 		ie_len = nla_len(info->attrs[NL80211_ATTR_IE]);
 	else
 		ie_len = 0;
 
-	if (ie_len > wiphy->max_scan_ie_len) {
-		err = -EINVAL;
-		goto out;
-	}
+	if (ie_len > wiphy->max_scan_ie_len)
+		return -EINVAL;
 
 	request = kzalloc(sizeof(*request)
 			+ sizeof(*ssid) * n_ssids
 			+ sizeof(channel) * n_channels
 			+ ie_len, GFP_KERNEL);
-	if (!request) {
-		err = -ENOMEM;
-		goto out;
-	}
+	if (!request)
+		return -ENOMEM;
 
 	if (n_ssids)
 		request->ssids = (void *)&request->channels[n_channels];
@@ -3305,18 +2902,11 @@ static int nl80211_trigger_scan(struct s
 	if (!err) {
 		nl80211_send_scan_start(rdev, dev);
 		dev_hold(dev);
-	}
-
+	} else {
  out_free:
-	if (err) {
 		rdev->scan_req = NULL;
 		kfree(request);
 	}
- out:
-	cfg80211_unlock_rdev(rdev);
-	dev_put(dev);
- out_rtnl:
-	rtnl_unlock();
 
 	return err;
 }
@@ -3593,8 +3183,8 @@ static bool nl80211_valid_cipher_suite(u
 
 static int nl80211_authenticate(struct sk_buff *skb, struct genl_info *info)
 {
-	struct cfg80211_registered_device *rdev;
-	struct net_device *dev;
+	struct cfg80211_registered_device *rdev = info->user_ptr[0];
+	struct net_device *dev = info->user_ptr[1];
 	struct ieee80211_channel *chan;
 	const u8 *bssid, *ssid, *ie = NULL;
 	int err, ssid_len, ie_len = 0;
@@ -3636,12 +3226,6 @@ static int nl80211_authenticate(struct s
 		key.p.key = NULL;
 	}
 
-	rtnl_lock();
-
-	err = get_rdev_dev_by_info_ifindex(info, &rdev, &dev);
-	if (err)
-		goto unlock_rtnl;
-
 	if (key.idx >= 0) {
 		int i;
 		bool ok = false;
@@ -3651,35 +3235,25 @@ static int nl80211_authenticate(struct s
 				break;
 			}
 		}
-		if (!ok) {
-			err = -EINVAL;
-			goto out;
-		}
+		if (!ok)
+			return -EINVAL;
 	}
 
-	if (!rdev->ops->auth) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
+	if (!rdev->ops->auth)
+		return -EOPNOTSUPP;
 
 	if (dev->ieee80211_ptr->iftype != NL80211_IFTYPE_STATION &&
-	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_P2P_CLIENT) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
+	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_P2P_CLIENT)
+		return -EOPNOTSUPP;
 
-	if (!netif_running(dev)) {
-		err = -ENETDOWN;
-		goto out;
-	}
+	if (!netif_running(dev))
+		return -ENETDOWN;
 
 	bssid = nla_data(info->attrs[NL80211_ATTR_MAC]);
 	chan = ieee80211_get_channel(&rdev->wiphy,
 		nla_get_u32(info->attrs[NL80211_ATTR_WIPHY_FREQ]));
-	if (!chan || (chan->flags & IEEE80211_CHAN_DISABLED)) {
-		err = -EINVAL;
-		goto out;
-	}
+	if (!chan || (chan->flags & IEEE80211_CHAN_DISABLED))
+		return -EINVAL;
 
 	ssid = nla_data(info->attrs[NL80211_ATTR_SSID]);
 	ssid_len = nla_len(info->attrs[NL80211_ATTR_SSID]);
@@ -3690,24 +3264,15 @@ static int nl80211_authenticate(struct s
 	}
 
 	auth_type = nla_get_u32(info->attrs[NL80211_ATTR_AUTH_TYPE]);
-	if (!nl80211_valid_auth_type(auth_type)) {
-		err = -EINVAL;
-		goto out;
-	}
+	if (!nl80211_valid_auth_type(auth_type))
+		return -EINVAL;
 
 	local_state_change = !!info->attrs[NL80211_ATTR_LOCAL_STATE_CHANGE];
 
-	err = cfg80211_mlme_auth(rdev, dev, chan, auth_type, bssid,
-				 ssid, ssid_len, ie, ie_len,
-				 key.p.key, key.p.key_len, key.idx,
-				 local_state_change);
-
-out:
-	cfg80211_unlock_rdev(rdev);
-	dev_put(dev);
-unlock_rtnl:
-	rtnl_unlock();
-	return err;
+	return cfg80211_mlme_auth(rdev, dev, chan, auth_type, bssid,
+				  ssid, ssid_len, ie, ie_len,
+				  key.p.key, key.p.key_len, key.idx,
+				  local_state_change);
 }
 
 static int nl80211_crypto_settings(struct cfg80211_registered_device *rdev,
@@ -3791,8 +3356,8 @@ static int nl80211_crypto_settings(struc
 
 static int nl80211_associate(struct sk_buff *skb, struct genl_info *info)
 {
-	struct cfg80211_registered_device *rdev;
-	struct net_device *dev;
+	struct cfg80211_registered_device *rdev = info->user_ptr[0];
+	struct net_device *dev = info->user_ptr[1];
 	struct cfg80211_crypto_settings crypto;
 	struct ieee80211_channel *chan;
 	const u8 *bssid, *ssid, *ie = NULL, *prev_bssid = NULL;
@@ -3807,36 +3372,22 @@ static int nl80211_associate(struct sk_b
 	    !info->attrs[NL80211_ATTR_WIPHY_FREQ])
 		return -EINVAL;
 
-	rtnl_lock();
-
-	err = get_rdev_dev_by_info_ifindex(info, &rdev, &dev);
-	if (err)
-		goto unlock_rtnl;
-
-	if (!rdev->ops->assoc) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
+	if (!rdev->ops->assoc)
+		return -EOPNOTSUPP;
 
 	if (dev->ieee80211_ptr->iftype != NL80211_IFTYPE_STATION &&
-	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_P2P_CLIENT) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
+	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_P2P_CLIENT)
+		return -EOPNOTSUPP;
 
-	if (!netif_running(dev)) {
-		err = -ENETDOWN;
-		goto out;
-	}
+	if (!netif_running(dev))
+		return -ENETDOWN;
 
 	bssid = nla_data(info->attrs[NL80211_ATTR_MAC]);
 
 	chan = ieee80211_get_channel(&rdev->wiphy,
 		nla_get_u32(info->attrs[NL80211_ATTR_WIPHY_FREQ]));
-	if (!chan || (chan->flags & IEEE80211_CHAN_DISABLED)) {
-		err = -EINVAL;
-		goto out;
-	}
+	if (!chan || (chan->flags & IEEE80211_CHAN_DISABLED))
+		return -EINVAL;
 
 	ssid = nla_data(info->attrs[NL80211_ATTR_SSID]);
 	ssid_len = nla_len(info->attrs[NL80211_ATTR_SSID]);
@@ -3851,10 +3402,8 @@ static int nl80211_associate(struct sk_b
 			nla_get_u32(info->attrs[NL80211_ATTR_USE_MFP]);
 		if (mfp == NL80211_MFP_REQUIRED)
 			use_mfp = true;
-		else if (mfp != NL80211_MFP_NO) {
-			err = -EINVAL;
-			goto out;
-		}
+		else if (mfp != NL80211_MFP_NO)
+			return -EINVAL;
 	}
 
 	if (info->attrs[NL80211_ATTR_PREV_BSSID])
@@ -3866,20 +3415,15 @@ static int nl80211_associate(struct sk_b
 					  ssid, ssid_len, ie, ie_len, use_mfp,
 					  &crypto);
 
-out:
-	cfg80211_unlock_rdev(rdev);
-	dev_put(dev);
-unlock_rtnl:
-	rtnl_unlock();
 	return err;
 }
 
 static int nl80211_deauthenticate(struct sk_buff *skb, struct genl_info *info)
 {
-	struct cfg80211_registered_device *rdev;
-	struct net_device *dev;
+	struct cfg80211_registered_device *rdev = info->user_ptr[0];
+	struct net_device *dev = info->user_ptr[1];
 	const u8 *ie = NULL, *bssid;
-	int err, ie_len = 0;
+	int ie_len = 0;
 	u16 reason_code;
 	bool local_state_change;
 
@@ -3892,35 +3436,22 @@ static int nl80211_deauthenticate(struct
 	if (!info->attrs[NL80211_ATTR_REASON_CODE])
 		return -EINVAL;
 
-	rtnl_lock();
-
-	err = get_rdev_dev_by_info_ifindex(info, &rdev, &dev);
-	if (err)
-		goto unlock_rtnl;
-
-	if (!rdev->ops->deauth) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
+	if (!rdev->ops->deauth)
+		return -EOPNOTSUPP;
 
 	if (dev->ieee80211_ptr->iftype != NL80211_IFTYPE_STATION &&
-	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_P2P_CLIENT) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
+	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_P2P_CLIENT)
+		return -EOPNOTSUPP;
 
-	if (!netif_running(dev)) {
-		err = -ENETDOWN;
-		goto out;
-	}
+	if (!netif_running(dev))
+		return -ENETDOWN;
 
 	bssid = nla_data(info->attrs[NL80211_ATTR_MAC]);
 
 	reason_code = nla_get_u16(info->attrs[NL80211_ATTR_REASON_CODE]);
 	if (reason_code == 0) {
 		/* Reason Code 0 is reserved */
-		err = -EINVAL;
-		goto out;
+		return -EINVAL;
 	}
 
 	if (info->attrs[NL80211_ATTR_IE]) {
@@ -3930,23 +3461,16 @@ static int nl80211_deauthenticate(struct
 
 	local_state_change = !!info->attrs[NL80211_ATTR_LOCAL_STATE_CHANGE];
 
-	err = cfg80211_mlme_deauth(rdev, dev, bssid, ie, ie_len, reason_code,
-				   local_state_change);
-
-out:
-	cfg80211_unlock_rdev(rdev);
-	dev_put(dev);
-unlock_rtnl:
-	rtnl_unlock();
-	return err;
+	return cfg80211_mlme_deauth(rdev, dev, bssid, ie, ie_len, reason_code,
+				    local_state_change);
 }
 
 static int nl80211_disassociate(struct sk_buff *skb, struct genl_info *info)
 {
-	struct cfg80211_registered_device *rdev;
-	struct net_device *dev;
+	struct cfg80211_registered_device *rdev = info->user_ptr[0];
+	struct net_device *dev = info->user_ptr[1];
 	const u8 *ie = NULL, *bssid;
-	int err, ie_len = 0;
+	int ie_len = 0;
 	u16 reason_code;
 	bool local_state_change;
 
@@ -3959,35 +3483,22 @@ static int nl80211_disassociate(struct s
 	if (!info->attrs[NL80211_ATTR_REASON_CODE])
 		return -EINVAL;
 
-	rtnl_lock();
-
-	err = get_rdev_dev_by_info_ifindex(info, &rdev, &dev);
-	if (err)
-		goto unlock_rtnl;
-
-	if (!rdev->ops->disassoc) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
+	if (!rdev->ops->disassoc)
+		return -EOPNOTSUPP;
 
 	if (dev->ieee80211_ptr->iftype != NL80211_IFTYPE_STATION &&
-	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_P2P_CLIENT) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
+	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_P2P_CLIENT)
+		return -EOPNOTSUPP;
 
-	if (!netif_running(dev)) {
-		err = -ENETDOWN;
-		goto out;
-	}
+	if (!netif_running(dev))
+		return -ENETDOWN;
 
 	bssid = nla_data(info->attrs[NL80211_ATTR_MAC]);
 
 	reason_code = nla_get_u16(info->attrs[NL80211_ATTR_REASON_CODE]);
 	if (reason_code == 0) {
 		/* Reason Code 0 is reserved */
-		err = -EINVAL;
-		goto out;
+		return -EINVAL;
 	}
 
 	if (info->attrs[NL80211_ATTR_IE]) {
@@ -3997,21 +3508,14 @@ static int nl80211_disassociate(struct s
 
 	local_state_change = !!info->attrs[NL80211_ATTR_LOCAL_STATE_CHANGE];
 
-	err = cfg80211_mlme_disassoc(rdev, dev, bssid, ie, ie_len, reason_code,
-				     local_state_change);
-
-out:
-	cfg80211_unlock_rdev(rdev);
-	dev_put(dev);
-unlock_rtnl:
-	rtnl_unlock();
-	return err;
+	return cfg80211_mlme_disassoc(rdev, dev, bssid, ie, ie_len, reason_code,
+				      local_state_change);
 }
 
 static int nl80211_join_ibss(struct sk_buff *skb, struct genl_info *info)
 {
-	struct cfg80211_registered_device *rdev;
-	struct net_device *dev;
+	struct cfg80211_registered_device *rdev = info->user_ptr[0];
+	struct net_device *dev = info->user_ptr[1];
 	struct cfg80211_ibss_params ibss;
 	struct wiphy *wiphy;
 	struct cfg80211_cached_keys *connkeys = NULL;
@@ -4036,26 +3540,14 @@ static int nl80211_join_ibss(struct sk_b
 			return -EINVAL;
 	}
 
-	rtnl_lock();
-
-	err = get_rdev_dev_by_info_ifindex(info, &rdev, &dev);
-	if (err)
-		goto unlock_rtnl;
-
-	if (!rdev->ops->join_ibss) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
+	if (!rdev->ops->join_ibss)
+		return -EOPNOTSUPP;
 
-	if (dev->ieee80211_ptr->iftype != NL80211_IFTYPE_ADHOC) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
+	if (dev->ieee80211_ptr->iftype != NL80211_IFTYPE_ADHOC)
+		return -EOPNOTSUPP;
 
-	if (!netif_running(dev)) {
-		err = -ENETDOWN;
-		goto out;
-	}
+	if (!netif_running(dev))
+		return -ENETDOWN;
 
 	wiphy = &rdev->wiphy;
 
@@ -4073,24 +3565,12 @@ static int nl80211_join_ibss(struct sk_b
 		nla_get_u32(info->attrs[NL80211_ATTR_WIPHY_FREQ]));
 	if (!ibss.channel ||
 	    ibss.channel->flags & IEEE80211_CHAN_NO_IBSS ||
-	    ibss.channel->flags & IEEE80211_CHAN_DISABLED) {
-		err = -EINVAL;
-		goto out;
-	}
+	    ibss.channel->flags & IEEE80211_CHAN_DISABLED)
+		return -EINVAL;
 
 	ibss.channel_fixed = !!info->attrs[NL80211_ATTR_FREQ_FIXED];
 	ibss.privacy = !!info->attrs[NL80211_ATTR_PRIVACY];
 
-	if (ibss.privacy && info->attrs[NL80211_ATTR_KEYS]) {
-		connkeys = nl80211_parse_connkeys(rdev,
-					info->attrs[NL80211_ATTR_KEYS]);
-		if (IS_ERR(connkeys)) {
-			err = PTR_ERR(connkeys);
-			connkeys = NULL;
-			goto out;
-		}
-	}
-
 	if (info->attrs[NL80211_ATTR_BSS_BASIC_RATES]) {
 		u8 *rates =
 			nla_data(info->attrs[NL80211_ATTR_BSS_BASIC_RATES]);
@@ -4100,10 +3580,8 @@ static int nl80211_join_ibss(struct sk_b
 			wiphy->bands[ibss.channel->band];
 		int i, j;
 
-		if (n_rates == 0) {
-			err = -EINVAL;
-			goto out;
-		}
+		if (n_rates == 0)
+			return -EINVAL;
 
 		for (i = 0; i < n_rates; i++) {
 			int rate = (rates[i] & 0x7f) * 5;
@@ -4116,60 +3594,39 @@ static int nl80211_join_ibss(struct sk_b
 					break;
 				}
 			}
-			if (!found) {
-				err = -EINVAL;
-				goto out;
-			}
+			if (!found)
+				return -EINVAL;
 		}
 	}
 
-	err = cfg80211_join_ibss(rdev, dev, &ibss, connkeys);
+	if (ibss.privacy && info->attrs[NL80211_ATTR_KEYS]) {
+		connkeys = nl80211_parse_connkeys(rdev,
+					info->attrs[NL80211_ATTR_KEYS]);
+		if (IS_ERR(connkeys))
+			return PTR_ERR(connkeys);
+	}
 
-out:
-	cfg80211_unlock_rdev(rdev);
-	dev_put(dev);
-unlock_rtnl:
+	err = cfg80211_join_ibss(rdev, dev, &ibss, connkeys);
 	if (err)
 		kfree(connkeys);
-	rtnl_unlock();
 	return err;
 }
 
 static int nl80211_leave_ibss(struct sk_buff *skb, struct genl_info *info)
 {
-	struct cfg80211_registered_device *rdev;
-	struct net_device *dev;
-	int err;
-
-	rtnl_lock();
-
-	err = get_rdev_dev_by_info_ifindex(info, &rdev, &dev);
-	if (err)
-		goto unlock_rtnl;
-
-	if (!rdev->ops->leave_ibss) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
+	struct cfg80211_registered_device *rdev = info->user_ptr[0];
+	struct net_device *dev = info->user_ptr[1];
 
-	if (dev->ieee80211_ptr->iftype != NL80211_IFTYPE_ADHOC) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
+	if (!rdev->ops->leave_ibss)
+		return -EOPNOTSUPP;
 
-	if (!netif_running(dev)) {
-		err = -ENETDOWN;
-		goto out;
-	}
+	if (dev->ieee80211_ptr->iftype != NL80211_IFTYPE_ADHOC)
+		return -EOPNOTSUPP;
 
-	err = cfg80211_leave_ibss(rdev, dev, false);
+	if (!netif_running(dev))
+		return -ENETDOWN;
 
-out:
-	cfg80211_unlock_rdev(rdev);
-	dev_put(dev);
-unlock_rtnl:
-	rtnl_unlock();
-	return err;
+	return cfg80211_leave_ibss(rdev, dev, false);
 }
 
 #ifdef CONFIG_NL80211_TESTMODE
@@ -4179,20 +3636,12 @@ static struct genl_multicast_group nl802
 
 static int nl80211_testmode_do(struct sk_buff *skb, struct genl_info *info)
 {
-	struct cfg80211_registered_device *rdev;
+	struct cfg80211_registered_device *rdev = info->user_ptr[0];
 	int err;
 
 	if (!info->attrs[NL80211_ATTR_TESTDATA])
 		return -EINVAL;
 
-	rtnl_lock();
-
-	rdev = cfg80211_get_dev_from_info(info);
-	if (IS_ERR(rdev)) {
-		err = PTR_ERR(rdev);
-		goto unlock_rtnl;
-	}
-
 	err = -EOPNOTSUPP;
 	if (rdev->ops->testmode_cmd) {
 		rdev->testmode_info = info;
@@ -4202,10 +3651,6 @@ static int nl80211_testmode_do(struct sk
 		rdev->testmode_info = NULL;
 	}
 
-	cfg80211_unlock_rdev(rdev);
-
- unlock_rtnl:
-	rtnl_unlock();
 	return err;
 }
 
@@ -4296,8 +3741,8 @@ EXPORT_SYMBOL(cfg80211_testmode_event);
 
 static int nl80211_connect(struct sk_buff *skb, struct genl_info *info)
 {
-	struct cfg80211_registered_device *rdev;
-	struct net_device *dev;
+	struct cfg80211_registered_device *rdev = info->user_ptr[0];
+	struct net_device *dev = info->user_ptr[1];
 	struct cfg80211_connect_params connect;
 	struct wiphy *wiphy;
 	struct cfg80211_cached_keys *connkeys = NULL;
@@ -4326,22 +3771,13 @@ static int nl80211_connect(struct sk_buf
 				      NL80211_MAX_NR_CIPHER_SUITES);
 	if (err)
 		return err;
-	rtnl_lock();
-
-	err = get_rdev_dev_by_info_ifindex(info, &rdev, &dev);
-	if (err)
-		goto unlock_rtnl;
 
 	if (dev->ieee80211_ptr->iftype != NL80211_IFTYPE_STATION &&
-	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_P2P_CLIENT) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
+	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_P2P_CLIENT)
+		return -EOPNOTSUPP;
 
-	if (!netif_running(dev)) {
-		err = -ENETDOWN;
-		goto out;
-	}
+	if (!netif_running(dev))
+		return -ENETDOWN;
 
 	wiphy = &rdev->wiphy;
 
@@ -4360,39 +3796,27 @@ static int nl80211_connect(struct sk_buf
 			ieee80211_get_channel(wiphy,
 			    nla_get_u32(info->attrs[NL80211_ATTR_WIPHY_FREQ]));
 		if (!connect.channel ||
-		    connect.channel->flags & IEEE80211_CHAN_DISABLED) {
-			err = -EINVAL;
-			goto out;
-		}
+		    connect.channel->flags & IEEE80211_CHAN_DISABLED)
+			return -EINVAL;
 	}
 
 	if (connect.privacy && info->attrs[NL80211_ATTR_KEYS]) {
 		connkeys = nl80211_parse_connkeys(rdev,
 					info->attrs[NL80211_ATTR_KEYS]);
-		if (IS_ERR(connkeys)) {
-			err = PTR_ERR(connkeys);
-			connkeys = NULL;
-			goto out;
-		}
+		if (IS_ERR(connkeys))
+			return PTR_ERR(connkeys);
 	}
 
 	err = cfg80211_connect(rdev, dev, &connect, connkeys);
-
-out:
-	cfg80211_unlock_rdev(rdev);
-	dev_put(dev);
-unlock_rtnl:
 	if (err)
 		kfree(connkeys);
-	rtnl_unlock();
 	return err;
 }
 
 static int nl80211_disconnect(struct sk_buff *skb, struct genl_info *info)
 {
-	struct cfg80211_registered_device *rdev;
-	struct net_device *dev;
-	int err;
+	struct cfg80211_registered_device *rdev = info->user_ptr[0];
+	struct net_device *dev = info->user_ptr[1];
 	u16 reason;
 
 	if (!info->attrs[NL80211_ATTR_REASON_CODE])
@@ -4403,36 +3827,19 @@ static int nl80211_disconnect(struct sk_
 	if (reason == 0)
 		return -EINVAL;
 
-	rtnl_lock();
-
-	err = get_rdev_dev_by_info_ifindex(info, &rdev, &dev);
-	if (err)
-		goto unlock_rtnl;
-
 	if (dev->ieee80211_ptr->iftype != NL80211_IFTYPE_STATION &&
-	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_P2P_CLIENT) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
-
-	if (!netif_running(dev)) {
-		err = -ENETDOWN;
-		goto out;
-	}
+	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_P2P_CLIENT)
+		return -EOPNOTSUPP;
 
-	err = cfg80211_disconnect(rdev, dev, reason, true);
+	if (!netif_running(dev))
+		return -ENETDOWN;
 
-out:
-	cfg80211_unlock_rdev(rdev);
-	dev_put(dev);
-unlock_rtnl:
-	rtnl_unlock();
-	return err;
+	return cfg80211_disconnect(rdev, dev, reason, true);
 }
 
 static int nl80211_wiphy_netns(struct sk_buff *skb, struct genl_info *info)
 {
-	struct cfg80211_registered_device *rdev;
+	struct cfg80211_registered_device *rdev = info->user_ptr[0];
 	struct net *net;
 	int err;
 	u32 pid;
@@ -4442,43 +3849,26 @@ static int nl80211_wiphy_netns(struct sk
 
 	pid = nla_get_u32(info->attrs[NL80211_ATTR_PID]);
 
-	rtnl_lock();
-
-	rdev = cfg80211_get_dev_from_info(info);
-	if (IS_ERR(rdev)) {
-		err = PTR_ERR(rdev);
-		goto out_rtnl;
-	}
-
 	net = get_net_ns_by_pid(pid);
-	if (IS_ERR(net)) {
-		err = PTR_ERR(net);
-		goto out;
-	}
+	if (IS_ERR(net))
+		return PTR_ERR(net);
 
 	err = 0;
 
 	/* check if anything to do */
-	if (net_eq(wiphy_net(&rdev->wiphy), net))
-		goto out_put_net;
+	if (!net_eq(wiphy_net(&rdev->wiphy), net))
+		err = cfg80211_switch_netns(rdev, net);
 
-	err = cfg80211_switch_netns(rdev, net);
- out_put_net:
 	put_net(net);
- out:
-	cfg80211_unlock_rdev(rdev);
- out_rtnl:
-	rtnl_unlock();
 	return err;
 }
 
 static int nl80211_setdel_pmksa(struct sk_buff *skb, struct genl_info *info)
 {
-	struct cfg80211_registered_device *rdev;
+	struct cfg80211_registered_device *rdev = info->user_ptr[0];
 	int (*rdev_ops)(struct wiphy *wiphy, struct net_device *dev,
 			struct cfg80211_pmksa *pmksa) = NULL;
-	int err;
-	struct net_device *dev;
+	struct net_device *dev = info->user_ptr[1];
 	struct cfg80211_pmksa pmksa;
 
 	memset(&pmksa, 0, sizeof(struct cfg80211_pmksa));
@@ -4489,20 +3879,12 @@ static int nl80211_setdel_pmksa(struct s
 	if (!info->attrs[NL80211_ATTR_PMKID])
 		return -EINVAL;
 
-	rtnl_lock();
-
-	err = get_rdev_dev_by_info_ifindex(info, &rdev, &dev);
-	if (err)
-		goto out_rtnl;
-
 	pmksa.pmkid = nla_data(info->attrs[NL80211_ATTR_PMKID]);
 	pmksa.bssid = nla_data(info->attrs[NL80211_ATTR_MAC]);
 
 	if (dev->ieee80211_ptr->iftype != NL80211_IFTYPE_STATION &&
-	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_P2P_CLIENT) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
+	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_P2P_CLIENT)
+		return -EOPNOTSUPP;
 
 	switch (info->genlhdr->cmd) {
 	case NL80211_CMD_SET_PMKSA:
@@ -4516,62 +3898,32 @@ static int nl80211_setdel_pmksa(struct s
 		break;
 	}
 
-	if (!rdev_ops) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
-
-	err = rdev_ops(&rdev->wiphy, dev, &pmksa);
-
- out:
-	cfg80211_unlock_rdev(rdev);
-	dev_put(dev);
- out_rtnl:
-	rtnl_unlock();
+	if (!rdev_ops)
+		return -EOPNOTSUPP;
 
-	return err;
+	return rdev_ops(&rdev->wiphy, dev, &pmksa);
 }
 
 static int nl80211_flush_pmksa(struct sk_buff *skb, struct genl_info *info)
 {
-	struct cfg80211_registered_device *rdev;
-	int err;
-	struct net_device *dev;
-
-	rtnl_lock();
-
-	err = get_rdev_dev_by_info_ifindex(info, &rdev, &dev);
-	if (err)
-		goto out_rtnl;
+	struct cfg80211_registered_device *rdev = info->user_ptr[0];
+	struct net_device *dev = info->user_ptr[1];
 
 	if (dev->ieee80211_ptr->iftype != NL80211_IFTYPE_STATION &&
-	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_P2P_CLIENT) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
-
-	if (!rdev->ops->flush_pmksa) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
-
-	err = rdev->ops->flush_pmksa(&rdev->wiphy, dev);
-
- out:
-	cfg80211_unlock_rdev(rdev);
-	dev_put(dev);
- out_rtnl:
-	rtnl_unlock();
+	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_P2P_CLIENT)
+		return -EOPNOTSUPP;
 
-	return err;
+	if (!rdev->ops->flush_pmksa)
+		return -EOPNOTSUPP;
 
+	return rdev->ops->flush_pmksa(&rdev->wiphy, dev);
 }
 
 static int nl80211_remain_on_channel(struct sk_buff *skb,
 				     struct genl_info *info)
 {
-	struct cfg80211_registered_device *rdev;
-	struct net_device *dev;
+	struct cfg80211_registered_device *rdev = info->user_ptr[0];
+	struct net_device *dev = info->user_ptr[1];
 	struct ieee80211_channel *chan;
 	struct sk_buff *msg;
 	void *hdr;
@@ -4593,21 +3945,11 @@ static int nl80211_remain_on_channel(str
 	if (!duration || !msecs_to_jiffies(duration) || duration > 5000)
 		return -EINVAL;
 
-	rtnl_lock();
-
-	err = get_rdev_dev_by_info_ifindex(info, &rdev, &dev);
-	if (err)
-		goto unlock_rtnl;
-
-	if (!rdev->ops->remain_on_channel) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
+	if (!rdev->ops->remain_on_channel)
+		return -EOPNOTSUPP;
 
-	if (!netif_running(dev)) {
-		err = -ENETDOWN;
-		goto out;
-	}
+	if (!netif_running(dev))
+		return -ENETDOWN;
 
 	if (info->attrs[NL80211_ATTR_WIPHY_CHANNEL_TYPE]) {
 		channel_type = nla_get_u32(
@@ -4615,24 +3957,18 @@ static int nl80211_remain_on_channel(str
 		if (channel_type != NL80211_CHAN_NO_HT &&
 		    channel_type != NL80211_CHAN_HT20 &&
 		    channel_type != NL80211_CHAN_HT40PLUS &&
-		    channel_type != NL80211_CHAN_HT40MINUS) {
-			err = -EINVAL;
-			goto out;
-		}
+		    channel_type != NL80211_CHAN_HT40MINUS)
+			return -EINVAL;
 	}
 
 	freq = nla_get_u32(info->attrs[NL80211_ATTR_WIPHY_FREQ]);
 	chan = rdev_freq_to_chan(rdev, freq, channel_type);
-	if (chan == NULL) {
-		err = -EINVAL;
-		goto out;
-	}
+	if (chan == NULL)
+		return -EINVAL;
 
 	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
-	if (!msg) {
-		err = -ENOMEM;
-		goto out;
-	}
+	if (!msg)
+		return -ENOMEM;
 
 	hdr = nl80211hdr_put(msg, info->snd_pid, info->snd_seq, 0,
 			     NL80211_CMD_REMAIN_ON_CHANNEL);
@@ -4651,58 +3987,35 @@ static int nl80211_remain_on_channel(str
 	NLA_PUT_U64(msg, NL80211_ATTR_COOKIE, cookie);
 
 	genlmsg_end(msg, hdr);
-	err = genlmsg_reply(msg, info);
-	goto out;
+
+	return genlmsg_reply(msg, info);
 
  nla_put_failure:
 	err = -ENOBUFS;
  free_msg:
 	nlmsg_free(msg);
- out:
-	cfg80211_unlock_rdev(rdev);
-	dev_put(dev);
- unlock_rtnl:
-	rtnl_unlock();
 	return err;
 }
 
 static int nl80211_cancel_remain_on_channel(struct sk_buff *skb,
 					    struct genl_info *info)
 {
-	struct cfg80211_registered_device *rdev;
-	struct net_device *dev;
+	struct cfg80211_registered_device *rdev = info->user_ptr[0];
+	struct net_device *dev = info->user_ptr[1];
 	u64 cookie;
-	int err;
 
 	if (!info->attrs[NL80211_ATTR_COOKIE])
 		return -EINVAL;
 
-	rtnl_lock();
-
-	err = get_rdev_dev_by_info_ifindex(info, &rdev, &dev);
-	if (err)
-		goto unlock_rtnl;
-
-	if (!rdev->ops->cancel_remain_on_channel) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
+	if (!rdev->ops->cancel_remain_on_channel)
+		return -EOPNOTSUPP;
 
-	if (!netif_running(dev)) {
-		err = -ENETDOWN;
-		goto out;
-	}
+	if (!netif_running(dev))
+		return -ENETDOWN;
 
 	cookie = nla_get_u64(info->attrs[NL80211_ATTR_COOKIE]);
 
-	err = rdev->ops->cancel_remain_on_channel(&rdev->wiphy, dev, cookie);
-
- out:
-	cfg80211_unlock_rdev(rdev);
-	dev_put(dev);
- unlock_rtnl:
-	rtnl_unlock();
-	return err;
+	return rdev->ops->cancel_remain_on_channel(&rdev->wiphy, dev, cookie);
 }
 
 static u32 rateset_to_mask(struct ieee80211_supported_band *sband,
@@ -4738,26 +4051,18 @@ static int nl80211_set_tx_bitrate_mask(s
 				       struct genl_info *info)
 {
 	struct nlattr *tb[NL80211_TXRATE_MAX + 1];
-	struct cfg80211_registered_device *rdev;
+	struct cfg80211_registered_device *rdev = info->user_ptr[0];
 	struct cfg80211_bitrate_mask mask;
-	int err, rem, i;
-	struct net_device *dev;
+	int rem, i;
+	struct net_device *dev = info->user_ptr[1];
 	struct nlattr *tx_rates;
 	struct ieee80211_supported_band *sband;
 
 	if (info->attrs[NL80211_ATTR_TX_RATES] == NULL)
 		return -EINVAL;
 
-	rtnl_lock();
-
-	err = get_rdev_dev_by_info_ifindex(info, &rdev, &dev);
-	if (err)
-		goto unlock_rtnl;
-
-	if (!rdev->ops->set_bitrate_mask) {
-		err = -EOPNOTSUPP;
-		goto unlock;
-	}
+	if (!rdev->ops->set_bitrate_mask)
+		return -EOPNOTSUPP;
 
 	memset(&mask, 0, sizeof(mask));
 	/* Default to all rates enabled */
@@ -4774,15 +4079,11 @@ static int nl80211_set_tx_bitrate_mask(s
 	nla_for_each_nested(tx_rates, info->attrs[NL80211_ATTR_TX_RATES], rem)
 	{
 		enum ieee80211_band band = nla_type(tx_rates);
-		if (band < 0 || band >= IEEE80211_NUM_BANDS) {
-			err = -EINVAL;
-			goto unlock;
-		}
+		if (band < 0 || band >= IEEE80211_NUM_BANDS)
+			return -EINVAL;
 		sband = rdev->wiphy.bands[band];
-		if (sband == NULL) {
-			err = -EINVAL;
-			goto unlock;
-		}
+		if (sband == NULL)
+			return -EINVAL;
 		nla_parse(tb, NL80211_TXRATE_MAX, nla_data(tx_rates),
 			  nla_len(tx_rates), nl80211_txattr_policy);
 		if (tb[NL80211_TXRATE_LEGACY]) {
@@ -4790,29 +4091,19 @@ static int nl80211_set_tx_bitrate_mask(s
 				sband,
 				nla_data(tb[NL80211_TXRATE_LEGACY]),
 				nla_len(tb[NL80211_TXRATE_LEGACY]));
-			if (mask.control[band].legacy == 0) {
-				err = -EINVAL;
-				goto unlock;
-			}
+			if (mask.control[band].legacy == 0)
+				return -EINVAL;
 		}
 	}
 
-	err = rdev->ops->set_bitrate_mask(&rdev->wiphy, dev, NULL, &mask);
-
- unlock:
-	dev_put(dev);
-	cfg80211_unlock_rdev(rdev);
- unlock_rtnl:
-	rtnl_unlock();
-	return err;
+	return rdev->ops->set_bitrate_mask(&rdev->wiphy, dev, NULL, &mask);
 }
 
 static int nl80211_register_mgmt(struct sk_buff *skb, struct genl_info *info)
 {
-	struct cfg80211_registered_device *rdev;
-	struct net_device *dev;
+	struct cfg80211_registered_device *rdev = info->user_ptr[0];
+	struct net_device *dev = info->user_ptr[1];
 	u16 frame_type = IEEE80211_FTYPE_MGMT | IEEE80211_STYPE_ACTION;
-	int err;
 
 	if (!info->attrs[NL80211_ATTR_FRAME_MATCH])
 		return -EINVAL;
@@ -4820,44 +4111,28 @@ static int nl80211_register_mgmt(struct
 	if (info->attrs[NL80211_ATTR_FRAME_TYPE])
 		frame_type = nla_get_u16(info->attrs[NL80211_ATTR_FRAME_TYPE]);
 
-	rtnl_lock();
-
-	err = get_rdev_dev_by_info_ifindex(info, &rdev, &dev);
-	if (err)
-		goto unlock_rtnl;
-
 	if (dev->ieee80211_ptr->iftype != NL80211_IFTYPE_STATION &&
 	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_ADHOC &&
 	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_P2P_CLIENT &&
 	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_AP &&
 	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_AP_VLAN &&
-	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_P2P_GO) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
+	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_P2P_GO)
+		return -EOPNOTSUPP;
 
 	/* not much point in registering if we can't reply */
-	if (!rdev->ops->mgmt_tx) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
+	if (!rdev->ops->mgmt_tx)
+		return -EOPNOTSUPP;
 
-	err = cfg80211_mlme_register_mgmt(dev->ieee80211_ptr, info->snd_pid,
+	return cfg80211_mlme_register_mgmt(dev->ieee80211_ptr, info->snd_pid,
 			frame_type,
 			nla_data(info->attrs[NL80211_ATTR_FRAME_MATCH]),
 			nla_len(info->attrs[NL80211_ATTR_FRAME_MATCH]));
- out:
-	cfg80211_unlock_rdev(rdev);
-	dev_put(dev);
- unlock_rtnl:
-	rtnl_unlock();
-	return err;
 }
 
 static int nl80211_tx_mgmt(struct sk_buff *skb, struct genl_info *info)
 {
-	struct cfg80211_registered_device *rdev;
-	struct net_device *dev;
+	struct cfg80211_registered_device *rdev = info->user_ptr[0];
+	struct net_device *dev = info->user_ptr[1];
 	struct ieee80211_channel *chan;
 	enum nl80211_channel_type channel_type = NL80211_CHAN_NO_HT;
 	bool channel_type_valid = false;
@@ -4871,31 +4146,19 @@ static int nl80211_tx_mgmt(struct sk_buf
 	    !info->attrs[NL80211_ATTR_WIPHY_FREQ])
 		return -EINVAL;
 
-	rtnl_lock();
-
-	err = get_rdev_dev_by_info_ifindex(info, &rdev, &dev);
-	if (err)
-		goto unlock_rtnl;
-
-	if (!rdev->ops->mgmt_tx) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
+	if (!rdev->ops->mgmt_tx)
+		return -EOPNOTSUPP;
 
 	if (dev->ieee80211_ptr->iftype != NL80211_IFTYPE_STATION &&
 	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_ADHOC &&
 	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_P2P_CLIENT &&
 	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_AP &&
 	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_AP_VLAN &&
-	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_P2P_GO) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
+	    dev->ieee80211_ptr->iftype != NL80211_IFTYPE_P2P_GO)
+		return -EOPNOTSUPP;
 
-	if (!netif_running(dev)) {
-		err = -ENETDOWN;
-		goto out;
-	}
+	if (!netif_running(dev))
+		return -ENETDOWN;
 
 	if (info->attrs[NL80211_ATTR_WIPHY_CHANNEL_TYPE]) {
 		channel_type = nla_get_u32(
@@ -4903,25 +4166,19 @@ static int nl80211_tx_mgmt(struct sk_buf
 		if (channel_type != NL80211_CHAN_NO_HT &&
 		    channel_type != NL80211_CHAN_HT20 &&
 		    channel_type != NL80211_CHAN_HT40PLUS &&
-		    channel_type != NL80211_CHAN_HT40MINUS) {
-			err = -EINVAL;
-			goto out;
-		}
+		    channel_type != NL80211_CHAN_HT40MINUS)
+			return -EINVAL;
 		channel_type_valid = true;
 	}
 
 	freq = nla_get_u32(info->attrs[NL80211_ATTR_WIPHY_FREQ]);
 	chan = rdev_freq_to_chan(rdev, freq, channel_type);
-	if (chan == NULL) {
-		err = -EINVAL;
-		goto out;
-	}
+	if (chan == NULL)
+		return -EINVAL;
 
 	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
-	if (!msg) {
-		err = -ENOMEM;
-		goto out;
-	}
+	if (!msg)
+		return -ENOMEM;
 
 	hdr = nl80211hdr_put(msg, info->snd_pid, info->snd_seq, 0,
 			     NL80211_CMD_FRAME);
@@ -4941,110 +4198,72 @@ static int nl80211_tx_mgmt(struct sk_buf
 	NLA_PUT_U64(msg, NL80211_ATTR_COOKIE, cookie);
 
 	genlmsg_end(msg, hdr);
-	err = genlmsg_reply(msg, info);
-	goto out;
+	return genlmsg_reply(msg, info);
 
  nla_put_failure:
 	err = -ENOBUFS;
  free_msg:
 	nlmsg_free(msg);
- out:
-	cfg80211_unlock_rdev(rdev);
-	dev_put(dev);
-unlock_rtnl:
-	rtnl_unlock();
 	return err;
 }
 
 static int nl80211_set_power_save(struct sk_buff *skb, struct genl_info *info)
 {
-	struct cfg80211_registered_device *rdev;
+	struct cfg80211_registered_device *rdev = info->user_ptr[0];
 	struct wireless_dev *wdev;
-	struct net_device *dev;
+	struct net_device *dev = info->user_ptr[1];
 	u8 ps_state;
 	bool state;
 	int err;
 
-	if (!info->attrs[NL80211_ATTR_PS_STATE]) {
-		err = -EINVAL;
-		goto out;
-	}
+	if (!info->attrs[NL80211_ATTR_PS_STATE])
+		return -EINVAL;
 
 	ps_state = nla_get_u32(info->attrs[NL80211_ATTR_PS_STATE]);
 
-	if (ps_state != NL80211_PS_DISABLED && ps_state != NL80211_PS_ENABLED) {
-		err = -EINVAL;
-		goto out;
-	}
-
-	rtnl_lock();
-
-	err = get_rdev_dev_by_info_ifindex(info, &rdev, &dev);
-	if (err)
-		goto unlock_rtnl;
+	if (ps_state != NL80211_PS_DISABLED && ps_state != NL80211_PS_ENABLED)
+		return -EINVAL;
 
 	wdev = dev->ieee80211_ptr;
 
-	if (!rdev->ops->set_power_mgmt) {
-		err = -EOPNOTSUPP;
-		goto unlock_rdev;
-	}
+	if (!rdev->ops->set_power_mgmt)
+		return -EOPNOTSUPP;
 
 	state = (ps_state == NL80211_PS_ENABLED) ? true : false;
 
 	if (state == wdev->ps)
-		goto unlock_rdev;
-
-	wdev->ps = state;
-
-	if (rdev->ops->set_power_mgmt(wdev->wiphy, dev, wdev->ps,
-				      wdev->ps_timeout))
-		/* assume this means it's off */
-		wdev->ps = false;
-
-unlock_rdev:
-	cfg80211_unlock_rdev(rdev);
-	dev_put(dev);
-unlock_rtnl:
-	rtnl_unlock();
+		return 0;
 
-out:
+	err = rdev->ops->set_power_mgmt(wdev->wiphy, dev, state,
+					wdev->ps_timeout);
+	if (!err)
+		wdev->ps = state;
 	return err;
 }
 
 static int nl80211_get_power_save(struct sk_buff *skb, struct genl_info *info)
 {
-	struct cfg80211_registered_device *rdev;
+	struct cfg80211_registered_device *rdev = info->user_ptr[0];
 	enum nl80211_ps_state ps_state;
 	struct wireless_dev *wdev;
-	struct net_device *dev;
+	struct net_device *dev = info->user_ptr[1];
 	struct sk_buff *msg;
 	void *hdr;
 	int err;
 
-	rtnl_lock();
-
-	err = get_rdev_dev_by_info_ifindex(info, &rdev, &dev);
-	if (err)
-		goto unlock_rtnl;
-
 	wdev = dev->ieee80211_ptr;
 
-	if (!rdev->ops->set_power_mgmt) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
+	if (!rdev->ops->set_power_mgmt)
+		return -EOPNOTSUPP;
 
 	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
-	if (!msg) {
-		err = -ENOMEM;
-		goto out;
-	}
+	if (!msg)
+		return -ENOMEM;
 
 	hdr = nl80211hdr_put(msg, info->snd_pid, info->snd_seq, 0,
 			     NL80211_CMD_GET_POWER_SAVE);
 	if (!hdr) {
-		err = -ENOMEM;
+		err = -ENOBUFS;
 		goto free_msg;
 	}
 
@@ -5056,22 +4275,12 @@ static int nl80211_get_power_save(struct
 	NLA_PUT_U32(msg, NL80211_ATTR_PS_STATE, ps_state);
 
 	genlmsg_end(msg, hdr);
-	err = genlmsg_reply(msg, info);
-	goto out;
+	return genlmsg_reply(msg, info);
 
-nla_put_failure:
+ nla_put_failure:
 	err = -ENOBUFS;
-
-free_msg:
+ free_msg:
 	nlmsg_free(msg);
-
-out:
-	cfg80211_unlock_rdev(rdev);
-	dev_put(dev);
-
-unlock_rtnl:
-	rtnl_unlock();
-
 	return err;
 }
 
@@ -5085,43 +4294,24 @@ nl80211_attr_cqm_policy[NL80211_ATTR_CQM
 static int nl80211_set_cqm_rssi(struct genl_info *info,
 				s32 threshold, u32 hysteresis)
 {
-	struct cfg80211_registered_device *rdev;
+	struct cfg80211_registered_device *rdev = info->user_ptr[0];
 	struct wireless_dev *wdev;
-	struct net_device *dev;
-	int err;
+	struct net_device *dev = info->user_ptr[1];
 
 	if (threshold > 0)
 		return -EINVAL;
 
-	rtnl_lock();
-
-	err = get_rdev_dev_by_info_ifindex(info, &rdev, &dev);
-	if (err)
-		goto unlock_rtnl;
-
 	wdev = dev->ieee80211_ptr;
 
-	if (!rdev->ops->set_cqm_rssi_config) {
-		err = -EOPNOTSUPP;
-		goto unlock_rdev;
-	}
+	if (!rdev->ops->set_cqm_rssi_config)
+		return -EOPNOTSUPP;
 
 	if (wdev->iftype != NL80211_IFTYPE_STATION &&
-	    wdev->iftype != NL80211_IFTYPE_P2P_CLIENT) {
-		err = -EOPNOTSUPP;
-		goto unlock_rdev;
-	}
-
-	err = rdev->ops->set_cqm_rssi_config(wdev->wiphy, dev,
-					     threshold, hysteresis);
-
- unlock_rdev:
-	cfg80211_unlock_rdev(rdev);
-	dev_put(dev);
- unlock_rtnl:
-	rtnl_unlock();
+	    wdev->iftype != NL80211_IFTYPE_P2P_CLIENT)
+		return -EOPNOTSUPP;
 
-	return err;
+	return rdev->ops->set_cqm_rssi_config(wdev->wiphy, dev,
+					      threshold, hysteresis);
 }
 
 static int nl80211_set_cqm(struct sk_buff *skb, struct genl_info *info)
@@ -5155,6 +4345,54 @@ out:
 	return err;
 }
 
+#define NL80211_FLAG_NEED_WIPHY		0x01
+#define NL80211_FLAG_NEED_NETDEV	0x02
+#define NL80211_FLAG_NEED_RTNL		0x04
+
+static int nl80211_pre_doit(struct genl_ops *ops, struct sk_buff *skb,
+			    struct genl_info *info)
+{
+	struct cfg80211_registered_device *rdev;
+	struct net_device *dev;
+	int err;
+	bool rtnl = ops->internal_flags & NL80211_FLAG_NEED_RTNL;
+
+	if (rtnl)
+		rtnl_lock();
+
+	if (ops->internal_flags & NL80211_FLAG_NEED_WIPHY) {
+		rdev = cfg80211_get_dev_from_info(info);
+		if (IS_ERR(rdev)) {
+			if (rtnl)
+				rtnl_unlock();
+			return PTR_ERR(rdev);
+		}
+		info->user_ptr[0] = rdev;
+	} else if (ops->internal_flags & NL80211_FLAG_NEED_NETDEV) {
+		err = get_rdev_dev_by_info_ifindex(info, &rdev, &dev);
+		if (err) {
+			if (rtnl)
+				rtnl_unlock();
+			return err;
+		}
+		info->user_ptr[0] = rdev;
+		info->user_ptr[1] = dev;
+	}
+
+	return 0;
+}
+
+static void nl80211_post_doit(struct genl_ops *ops, struct sk_buff *skb,
+			      struct genl_info *info)
+{
+	if (info->user_ptr[0])
+		cfg80211_unlock_rdev(info->user_ptr[0]);
+	if (info->user_ptr[1])
+		dev_put(info->user_ptr[1]);
+	if (ops->internal_flags & NL80211_FLAG_NEED_RTNL)
+		rtnl_unlock();
+}
+
 static struct genl_ops nl80211_ops[] = {
 	{
 		.cmd = NL80211_CMD_GET_WIPHY,
@@ -5162,12 +4400,14 @@ static struct genl_ops nl80211_ops[] = {
 		.dumpit = nl80211_dump_wiphy,
 		.policy = nl80211_policy,
 		/* can be retrieved by unprivileged users */
+		.internal_flags = NL80211_FLAG_NEED_WIPHY,
 	},
 	{
 		.cmd = NL80211_CMD_SET_WIPHY,
 		.doit = nl80211_set_wiphy,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL80211_FLAG_NEED_RTNL,
 	},
 	{
 		.cmd = NL80211_CMD_GET_INTERFACE,
@@ -5175,90 +4415,119 @@ static struct genl_ops nl80211_ops[] = {
 		.dumpit = nl80211_dump_interface,
 		.policy = nl80211_policy,
 		/* can be retrieved by unprivileged users */
+		.internal_flags = NL80211_FLAG_NEED_NETDEV,
 	},
 	{
 		.cmd = NL80211_CMD_SET_INTERFACE,
 		.doit = nl80211_set_interface,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
 		.cmd = NL80211_CMD_NEW_INTERFACE,
 		.doit = nl80211_new_interface,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL80211_FLAG_NEED_WIPHY |
+				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
 		.cmd = NL80211_CMD_DEL_INTERFACE,
 		.doit = nl80211_del_interface,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
 		.cmd = NL80211_CMD_GET_KEY,
 		.doit = nl80211_get_key,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
 		.cmd = NL80211_CMD_SET_KEY,
 		.doit = nl80211_set_key,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
 		.cmd = NL80211_CMD_NEW_KEY,
 		.doit = nl80211_new_key,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
 		.cmd = NL80211_CMD_DEL_KEY,
 		.doit = nl80211_del_key,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
 		.cmd = NL80211_CMD_SET_BEACON,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
 		.doit = nl80211_addset_beacon,
+		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
 		.cmd = NL80211_CMD_NEW_BEACON,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
 		.doit = nl80211_addset_beacon,
+		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
 		.cmd = NL80211_CMD_DEL_BEACON,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
 		.doit = nl80211_del_beacon,
+		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
 		.cmd = NL80211_CMD_GET_STATION,
 		.doit = nl80211_get_station,
 		.dumpit = nl80211_dump_station,
 		.policy = nl80211_policy,
+		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
 		.cmd = NL80211_CMD_SET_STATION,
 		.doit = nl80211_set_station,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
 		.cmd = NL80211_CMD_NEW_STATION,
 		.doit = nl80211_new_station,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
 		.cmd = NL80211_CMD_DEL_STATION,
 		.doit = nl80211_del_station,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
 		.cmd = NL80211_CMD_GET_MPATH,
@@ -5266,30 +4535,40 @@ static struct genl_ops nl80211_ops[] = {
 		.dumpit = nl80211_dump_mpath,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
 		.cmd = NL80211_CMD_SET_MPATH,
 		.doit = nl80211_set_mpath,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
 		.cmd = NL80211_CMD_NEW_MPATH,
 		.doit = nl80211_new_mpath,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
 		.cmd = NL80211_CMD_DEL_MPATH,
 		.doit = nl80211_del_mpath,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
 		.cmd = NL80211_CMD_SET_BSS,
 		.doit = nl80211_set_bss,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
 		.cmd = NL80211_CMD_GET_REG,
@@ -5314,18 +4593,24 @@ static struct genl_ops nl80211_ops[] = {
 		.doit = nl80211_get_mesh_params,
 		.policy = nl80211_policy,
 		/* can be retrieved by unprivileged users */
+		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
 		.cmd = NL80211_CMD_SET_MESH_PARAMS,
 		.doit = nl80211_set_mesh_params,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
 		.cmd = NL80211_CMD_TRIGGER_SCAN,
 		.doit = nl80211_trigger_scan,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
 		.cmd = NL80211_CMD_GET_SCAN,
@@ -5337,36 +4622,48 @@ static struct genl_ops nl80211_ops[] = {
 		.doit = nl80211_authenticate,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
 		.cmd = NL80211_CMD_ASSOCIATE,
 		.doit = nl80211_associate,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
 		.cmd = NL80211_CMD_DEAUTHENTICATE,
 		.doit = nl80211_deauthenticate,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
 		.cmd = NL80211_CMD_DISASSOCIATE,
 		.doit = nl80211_disassociate,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
 		.cmd = NL80211_CMD_JOIN_IBSS,
 		.doit = nl80211_join_ibss,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
 		.cmd = NL80211_CMD_LEAVE_IBSS,
 		.doit = nl80211_leave_ibss,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+				  NL80211_FLAG_NEED_RTNL,
 	},
 #ifdef CONFIG_NL80211_TESTMODE
 	{
@@ -5374,6 +4671,8 @@ static struct genl_ops nl80211_ops[] = {
 		.doit = nl80211_testmode_do,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL80211_FLAG_NEED_WIPHY |
+				  NL80211_FLAG_NEED_RTNL,
 	},
 #endif
 	{
@@ -5381,18 +4680,24 @@ static struct genl_ops nl80211_ops[] = {
 		.doit = nl80211_connect,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
 		.cmd = NL80211_CMD_DISCONNECT,
 		.doit = nl80211_disconnect,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
 		.cmd = NL80211_CMD_SET_WIPHY_NETNS,
 		.doit = nl80211_wiphy_netns,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL80211_FLAG_NEED_WIPHY |
+				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
 		.cmd = NL80211_CMD_GET_SURVEY,
@@ -5404,72 +4709,96 @@ static struct genl_ops nl80211_ops[] = {
 		.doit = nl80211_setdel_pmksa,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
 		.cmd = NL80211_CMD_DEL_PMKSA,
 		.doit = nl80211_setdel_pmksa,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
 		.cmd = NL80211_CMD_FLUSH_PMKSA,
 		.doit = nl80211_flush_pmksa,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
 		.cmd = NL80211_CMD_REMAIN_ON_CHANNEL,
 		.doit = nl80211_remain_on_channel,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
 		.cmd = NL80211_CMD_CANCEL_REMAIN_ON_CHANNEL,
 		.doit = nl80211_cancel_remain_on_channel,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
 		.cmd = NL80211_CMD_SET_TX_BITRATE_MASK,
 		.doit = nl80211_set_tx_bitrate_mask,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
 		.cmd = NL80211_CMD_REGISTER_FRAME,
 		.doit = nl80211_register_mgmt,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
 		.cmd = NL80211_CMD_FRAME,
 		.doit = nl80211_tx_mgmt,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
 		.cmd = NL80211_CMD_SET_POWER_SAVE,
 		.doit = nl80211_set_power_save,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
 		.cmd = NL80211_CMD_GET_POWER_SAVE,
 		.doit = nl80211_get_power_save,
 		.policy = nl80211_policy,
 		/* can be retrieved by unprivileged users */
+		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
 		.cmd = NL80211_CMD_SET_CQM,
 		.doit = nl80211_set_cqm,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
 		.cmd = NL80211_CMD_SET_CHANNEL,
 		.doit = nl80211_set_channel,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+				  NL80211_FLAG_NEED_RTNL,
 	},
 };
 


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
