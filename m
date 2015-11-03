From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next v2] mpls: support for dead routes
Date: Mon,  2 Nov 2015 21:13:01 -0800
Message-ID: <1446527581-64787-1-git-send-email-roopa@cumulusnetworks.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: ebiederm@xmission.com, rshearma@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:36153 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752122AbbKCFNF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 00:13:05 -0500
Received: by pacfv9 with SMTP id fv9so8135498pac.3
        for <netdev@vger.kernel.org>; Mon, 02 Nov 2015 21:13:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

Adds support for RTNH_F_DEAD and RTNH_F_LINKDOWN flags on mpls
routes due to link events. Also adds code to ignore dead
routes during route selection

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
RFC to v1:
        Addressed a few comments from Eric and Robert:
        - remove support for weighted nexthops
        - Use rt_nhn_alive in the rt structure to keep count of alive
        routes.
        What i have not done is: sort nexthops on link events.
        I am not comfortable recreating or sorting nexthops on
        every carrier change. This leaves scope for optimizing in the future

v1 to v2:
	Fix dead nexthop checks as suggested by dave

 net/mpls/af_mpls.c  | 191 ++++++++++++++++++++++++++++++++++++++++++++--------
 net/mpls/internal.h |   3 +
 2 files changed, 166 insertions(+), 28 deletions(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index c70d750..5e88118 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -96,22 +96,15 @@ bool mpls_pkt_too_big(const struct sk_buff *skb, unsigned int mtu)
 }
 EXPORT_SYMBOL_GPL(mpls_pkt_too_big);
 
-static struct mpls_nh *mpls_select_multipath(struct mpls_route *rt,
-					     struct sk_buff *skb, bool bos)
+static u32 mpls_multipath_hash(struct mpls_route *rt,
+			       struct sk_buff *skb, bool bos)
 {
 	struct mpls_entry_decoded dec;
 	struct mpls_shim_hdr *hdr;
 	bool eli_seen = false;
 	int label_index;
-	int nh_index = 0;
 	u32 hash = 0;
 
-	/* No need to look further into packet if there's only
-	 * one path
-	 */
-	if (rt->rt_nhn == 1)
-		goto out;
-
 	for (label_index = 0; label_index < MAX_MP_SELECT_LABELS && !bos;
 	     label_index++) {
 		if (!pskb_may_pull(skb, sizeof(*hdr) * label_index))
@@ -165,9 +158,37 @@ static struct mpls_nh *mpls_select_multipath(struct mpls_route *rt,
 		}
 	}
 
-	nh_index = hash % rt->rt_nhn;
+	return hash;
+}
+
+static struct mpls_nh *mpls_select_multipath(struct mpls_route *rt,
+					     struct sk_buff *skb, bool bos)
+{
+	u32 hash = 0;
+	int nh_index;
+	int n = 0;
+
+	/* No need to look further into packet if there's only
+	 * one path
+	 */
+	if (rt->rt_nhn == 1)
+		goto out;
+
+	if (rt->rt_nhn_alive <= 0)
+		return NULL;
+
+	hash = mpls_multipath_hash(rt, skb, bos);
+	nh_index = hash % rt->rt_nhn_alive;
+	for_nexthops(rt) {
+		if (nh->nh_flags & (RTNH_F_DEAD | RTNH_F_LINKDOWN))
+			continue;
+		if (n == nh_index)
+			return nh;
+		n++;
+	} endfor_nexthops(rt);
+
 out:
-	return &rt->rt_nh[nh_index];
+	return &rt->rt_nh[0];
 }
 
 static bool mpls_egress(struct mpls_route *rt, struct sk_buff *skb,
@@ -365,6 +386,7 @@ static struct mpls_route *mpls_rt_alloc(int num_nh, u8 max_alen)
 		     GFP_KERNEL);
 	if (rt) {
 		rt->rt_nhn = num_nh;
+		rt->rt_nhn_alive = num_nh;
 		rt->rt_max_alen = max_alen_aligned;
 	}
 
@@ -536,6 +558,15 @@ static int mpls_nh_assign_dev(struct net *net, struct mpls_route *rt,
 
 	RCU_INIT_POINTER(nh->nh_dev, dev);
 
+	if (!netif_carrier_ok(dev))
+		nh->nh_flags |= RTNH_F_LINKDOWN;
+
+	if (!(dev->flags & IFF_UP))
+		nh->nh_flags |= RTNH_F_DEAD;
+
+	if (nh->nh_flags & (RTNH_F_DEAD | RTNH_F_LINKDOWN))
+		rt->rt_nhn_alive--;
+
 	return 0;
 
 errout:
@@ -577,7 +608,7 @@ errout:
 }
 
 static int mpls_nh_build(struct net *net, struct mpls_route *rt,
-			 struct mpls_nh *nh, int oif,
+			 struct mpls_nh *nh, int oif, int hops,
 			 struct nlattr *via, struct nlattr *newdst)
 {
 	int err = -ENOMEM;
@@ -666,7 +697,7 @@ static int mpls_nh_build_multi(struct mpls_route_config *cfg,
 		/* neither weighted multipath nor any flags
 		 * are supported
 		 */
-		if (rtnh->rtnh_hops || rtnh->rtnh_flags)
+		if (rtnh->rtnh_flags || rtnh->rtnh_flags)
 			goto errout;
 
 		attrlen = rtnh_attrlen(rtnh);
@@ -681,8 +712,8 @@ static int mpls_nh_build_multi(struct mpls_route_config *cfg,
 			goto errout;
 
 		err = mpls_nh_build(cfg->rc_nlinfo.nl_net, rt, nh,
-				    rtnh->rtnh_ifindex, nla_via,
-				    nla_newdst);
+				    rtnh->rtnh_ifindex, rtnh->rtnh_hops,
+				    nla_via, nla_newdst);
 		if (err)
 			goto errout;
 
@@ -875,34 +906,100 @@ free:
 	return ERR_PTR(err);
 }
 
-static void mpls_ifdown(struct net_device *dev)
+static void mpls_ifdown(struct net_device *dev, int event)
 {
 	struct mpls_route __rcu **platform_label;
 	struct net *net = dev_net(dev);
-	struct mpls_dev *mdev;
 	unsigned index;
+	int dead;
 
 	platform_label = rtnl_dereference(net->mpls.platform_label);
 	for (index = 0; index < net->mpls.platform_labels; index++) {
 		struct mpls_route *rt = rtnl_dereference(platform_label[index]);
+
 		if (!rt)
 			continue;
+		dead = 0;
 		for_nexthops(rt) {
+			if ((event == NETDEV_DOWN &&
+			     (nh->nh_flags & RTNH_F_DEAD)) ||
+			     (event == NETDEV_CHANGE &&
+			     (nh->nh_flags & RTNH_F_LINKDOWN))) {
+				dead++;
+				continue;
+			}
+
 			if (rtnl_dereference(nh->nh_dev) != dev)
 				continue;
-			nh->nh_dev = NULL;
+			switch (event) {
+			case NETDEV_DOWN:
+			case NETDEV_UNREGISTER:
+				nh->nh_flags |= RTNH_F_DEAD;
+				/* fall through */
+			case NETDEV_CHANGE:
+				nh->nh_flags |= RTNH_F_LINKDOWN;
+				rt->rt_nhn_alive--;
+				break;
+			}
+			if (event == NETDEV_UNREGISTER) {
+				nh->nh_dev = NULL;
+				dead = rt->rt_nhn;
+				break;
+			}
+			dead++;
 		} endfor_nexthops(rt);
+
+		if (dead == rt->rt_nhn) {
+			switch (event) {
+			case NETDEV_DOWN:
+			case NETDEV_UNREGISTER:
+				rt->rt_flags |= RTNH_F_DEAD;
+				/* fall through */
+			case NETDEV_CHANGE:
+				rt->rt_flags |= RTNH_F_LINKDOWN;
+				rt->rt_nhn_alive = 0;
+				break;
+			}
+		}
 	}
 
-	mdev = mpls_dev_get(dev);
-	if (!mdev)
-		return;
+	return;
+}
+
+static void mpls_ifup(struct net_device *dev, unsigned int nh_flags)
+{
+	struct mpls_route __rcu **platform_label;
+	struct net *net = dev_net(dev);
+	unsigned index;
+	int alive;
+
+	platform_label = rtnl_dereference(net->mpls.platform_label);
+	for (index = 0; index < net->mpls.platform_labels; index++) {
+		struct mpls_route *rt = rtnl_dereference(platform_label[index]);
+
+		if (!rt)
+			continue;
+		alive = 0;
+		for_nexthops(rt) {
+			struct net_device *nh_dev =
+				rtnl_dereference(nh->nh_dev);
 
-	mpls_dev_sysctl_unregister(mdev);
+			if (!(nh->nh_flags & nh_flags)) {
+				alive++;
+				continue;
+			}
+			if (nh_dev != dev)
+				continue;
+			alive++;
+			nh->nh_flags &= ~nh_flags;
+		} endfor_nexthops(rt);
 
-	RCU_INIT_POINTER(dev->mpls_ptr, NULL);
+		if (alive > 0)
+			rt->rt_flags &= ~nh_flags;
+		rt->rt_nhn_alive = alive;
+	}
 
-	kfree_rcu(mdev, rcu);
+	return;
 }
 
 static int mpls_dev_notify(struct notifier_block *this, unsigned long event,
@@ -910,9 +1007,9 @@ static int mpls_dev_notify(struct notifier_block *this, unsigned long event,
 {
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
 	struct mpls_dev *mdev;
+	unsigned int flags;
 
-	switch(event) {
-	case NETDEV_REGISTER:
+	if (event == NETDEV_REGISTER) {
 		/* For now just support ethernet devices */
 		if ((dev->type == ARPHRD_ETHER) ||
 		    (dev->type == ARPHRD_LOOPBACK)) {
@@ -920,10 +1017,39 @@ static int mpls_dev_notify(struct notifier_block *this, unsigned long event,
 			if (IS_ERR(mdev))
 				return notifier_from_errno(PTR_ERR(mdev));
 		}
-		break;
+		return NOTIFY_OK;
+	}
 
+	mdev = mpls_dev_get(dev);
+	if (!mdev)
+		return NOTIFY_OK;
+
+	switch (event) {
+	case NETDEV_DOWN:
+		mpls_ifdown(dev, event);
+		break;
+	case NETDEV_UP:
+		flags = dev_get_flags(dev);
+		if (flags & (IFF_RUNNING | IFF_LOWER_UP))
+			mpls_ifup(dev, RTNH_F_DEAD | RTNH_F_LINKDOWN);
+		else
+			mpls_ifup(dev, RTNH_F_DEAD);
+		break;
+	case NETDEV_CHANGE:
+		flags = dev_get_flags(dev);
+		if (flags & (IFF_RUNNING | IFF_LOWER_UP))
+			mpls_ifup(dev, RTNH_F_DEAD | RTNH_F_LINKDOWN);
+		else
+			mpls_ifdown(dev, event);
+		break;
 	case NETDEV_UNREGISTER:
-		mpls_ifdown(dev);
+		mpls_ifdown(dev, event);
+		mdev = mpls_dev_get(dev);
+		if (mdev) {
+			mpls_dev_sysctl_unregister(mdev);
+			RCU_INIT_POINTER(dev->mpls_ptr, NULL);
+			kfree_rcu(mdev, rcu);
+		}
 		break;
 	case NETDEV_CHANGENAME:
 		mdev = mpls_dev_get(dev);
@@ -1237,6 +1363,10 @@ static int mpls_dump_route(struct sk_buff *skb, u32 portid, u32 seq, int event,
 		dev = rtnl_dereference(nh->nh_dev);
 		if (dev && nla_put_u32(skb, RTA_OIF, dev->ifindex))
 			goto nla_put_failure;
+		if (nh->nh_flags & RTNH_F_LINKDOWN)
+			rtm->rtm_flags |= RTNH_F_LINKDOWN;
+		if (nh->nh_flags & RTNH_F_DEAD)
+			rtm->rtm_flags |= RTNH_F_DEAD;
 	} else {
 		struct rtnexthop *rtnh;
 		struct nlattr *mp;
@@ -1253,6 +1383,11 @@ static int mpls_dump_route(struct sk_buff *skb, u32 portid, u32 seq, int event,
 			dev = rtnl_dereference(nh->nh_dev);
 			if (dev)
 				rtnh->rtnh_ifindex = dev->ifindex;
+			if (nh->nh_flags & RTNH_F_LINKDOWN)
+				rtnh->rtnh_flags |= RTNH_F_LINKDOWN;
+			if (nh->nh_flags & RTNH_F_DEAD)
+				rtnh->rtnh_flags |= RTNH_F_DEAD;
+
 			if (nh->nh_labels && nla_put_labels(skb, RTA_NEWDST,
 							    nh->nh_labels,
 							    nh->nh_label))
diff --git a/net/mpls/internal.h b/net/mpls/internal.h
index bde52ce..4f9bf2b 100644
--- a/net/mpls/internal.h
+++ b/net/mpls/internal.h
@@ -41,6 +41,7 @@ enum mpls_payload_type {
 
 struct mpls_nh { /* next hop label forwarding entry */
 	struct net_device __rcu *nh_dev;
+	unsigned int		nh_flags;
 	u32			nh_label[MAX_NEW_LABELS];
 	u8			nh_labels;
 	u8			nh_via_alen;
@@ -70,10 +71,12 @@ struct mpls_nh { /* next hop label forwarding entry */
  */
 struct mpls_route { /* next hop label forwarding entry */
 	struct rcu_head		rt_rcu;
+	unsigned int		rt_flags;
 	u8			rt_protocol;
 	u8			rt_payload_type;
 	u8			rt_max_alen;
 	unsigned int		rt_nhn;
+	unsigned int		rt_nhn_alive;
 	struct mpls_nh		rt_nh[0];
 };
 
-- 
1.9.1
