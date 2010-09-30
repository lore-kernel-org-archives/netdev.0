From: Johannes Berg <johannes@sipsolutions.net>
Subject: [RFC 2/2] nl80211: use the new genetlink pre/post_doit hooks
Date: Thu, 30 Sep 2010 23:10:15 +0200
Message-ID: <20100930211131.231087890@sipsolutions.net>
References: <20100930211013.472957770@sipsolutions.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch
To: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:36843 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932463Ab0I3VMO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 17:12:14 -0400
Content-Disposition: inline; filename=nl80211-use-pre-post.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

This makes nl80211 use the new genetlink
pre_doit/post_doit hooks for locking and
checking the interface/wiphy index.

This is only partial and serves to demonstrate
the code improvement.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 net/wireless/nl80211.c |  329 +++++++++++++++++++------------------------------
 1 file changed, 130 insertions(+), 199 deletions(-)

--- wireless-testing.orig/net/wireless/nl80211.c	2010-09-30 23:05:34.000000000 +0200
+++ wireless-testing/net/wireless/nl80211.c	2010-09-30 23:08:40.000000000 +0200
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
@@ -1137,33 +1134,20 @@ static int nl80211_dump_interface(struct
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
@@ -1223,39 +1207,29 @@ static int nl80211_valid_4addr(struct cf
 
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
@@ -1266,20 +1240,18 @@ static int nl80211_set_interface(struct
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
@@ -1293,17 +1265,12 @@ static int nl80211_set_interface(struct
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
@@ -1320,19 +1287,9 @@ static int nl80211_new_interface(struct
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
@@ -1344,7 +1301,7 @@ static int nl80211_new_interface(struct
 		params.use_4addr = !!nla_get_u8(info->attrs[NL80211_ATTR_4ADDR]);
 		err = nl80211_valid_4addr(rdev, NULL, params.use_4addr, type);
 		if (err)
-			goto unlock;
+			return err;
 	}
 
 	err = parse_monitor_flags(type == NL80211_IFTYPE_MONITOR ?
@@ -1354,38 +1311,18 @@ static int nl80211_new_interface(struct
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
+	struct cfg80211_registered_device *rdev = info->user_ptr[0];
+	struct net_device *dev = info->user_ptr[1];
 
-	err = get_rdev_dev_by_info_ifindex(info, &rdev, &dev);
-	if (err)
-		goto unlock_rtnl;
-
-	if (!rdev->ops->del_virtual_intf) {
-		err = -EOPNOTSUPP;
-		goto out;
-	}
-
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
@@ -1438,9 +1375,9 @@ static void get_key_callback(void *c, st
 
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
@@ -1458,30 +1395,17 @@ static int nl80211_get_key(struct sk_buf
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
@@ -1501,28 +1425,21 @@ static int nl80211_get_key(struct sk_buf
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
 
@@ -1537,21 +1454,13 @@ static int nl80211_set_key(struct sk_buf
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
@@ -1568,21 +1477,14 @@ static int nl80211_set_key(struct sk_buf
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
 
@@ -1596,21 +1498,11 @@ static int nl80211_new_key(struct sk_buf
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
@@ -1619,12 +1511,6 @@ static int nl80211_new_key(struct sk_buf
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
 
@@ -5085,43 +4971,24 @@ nl80211_attr_cqm_policy[NL80211_ATTR_CQM
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
@@ -5155,6 +5022,54 @@ out:
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
@@ -5162,6 +5077,7 @@ static struct genl_ops nl80211_ops[] = {
 		.dumpit = nl80211_dump_wiphy,
 		.policy = nl80211_policy,
 		/* can be retrieved by unprivileged users */
+		.internal_flags = NL80211_FLAG_NEED_WIPHY,
 	},
 	{
 		.cmd = NL80211_CMD_SET_WIPHY,
@@ -5175,42 +5091,55 @@ static struct genl_ops nl80211_ops[] = {
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
@@ -5464,6 +5393,8 @@ static struct genl_ops nl80211_ops[] = {
 		.doit = nl80211_set_cqm,
 		.policy = nl80211_policy,
 		.flags = GENL_ADMIN_PERM,
+		.internal_flags = NL80211_FLAG_NEED_NETDEV |
+				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
 		.cmd = NL80211_CMD_SET_CHANNEL,


