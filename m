From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next v4] mpls: support for dead routes
Date: Fri, 20 Nov 2015 21:16:08 -0800
Message-ID: <1448082968-63882-1-git-send-email-roopa@cumulusnetworks.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: ebiederm@xmission.com, rshearma@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35548 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750753AbbKUFQN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2015 00:16:13 -0500
Received: by pacej9 with SMTP id ej9so136375775pac.2
        for <netdev@vger.kernel.org>; Fri, 20 Nov 2015 21:16:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

Adds support for RTNH_F_DEAD and RTNH_F_LINKDOWN flags on mpls
routes due to link events. Also adds code to ignore dead
routes during route selection.

Unlike ip routes, mpls routes are not deleted when the route goes
dead. This is current mpls behaviour and this patch does not change
that. With this patch however, routes will be marked dead.
dead routes are not notified to userspace (this is consistent with ipv4
routes).

dead routes:
-----------
$ip -f mpls route show
100
    nexthop as to 200 via inet 10.1.1.2  dev swp1
    nexthop as to 700 via inet 10.1.1.6  dev swp2

$ip link set dev swp1 down

$ip link show dev swp1
4: swp1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN mode
DEFAULT group default qlen 1000
    link/ether 00:02:00:00:00:01 brd ff:ff:ff:ff:ff:ff

$ip -f mpls route show
100
    nexthop as to 200 via inet 10.1.1.2  dev swp1 dead linkdown
    nexthop as to 700 via inet 10.1.1.6  dev swp2

linkdown routes:
----------------
$ip -f mpls route show
100
    nexthop as to 200 via inet 10.1.1.2  dev swp1
    nexthop as to 700 via inet 10.1.1.6  dev swp2

$ip link show dev swp1
4: swp1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
state UP mode DEFAULT group default qlen 1000
    link/ether 00:02:00:00:00:01 brd ff:ff:ff:ff:ff:ff

/* carrier goes down */
$ip link show dev swp1
4: swp1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast
state DOWN mode DEFAULT group default qlen 1000
    link/ether 00:02:00:00:00:01 brd ff:ff:ff:ff:ff:ff

$ip -f mpls route show
100
    nexthop as to 200 via inet 10.1.1.2  dev swp1 linkdown
    nexthop as to 700 via inet 10.1.1.6  dev swp2

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
RFC to v1:
        Addressed a few comments from Eric and Robert:
        - remove support for weighted nexthops
        - Use rt_nhn_alive in the rt structure to keep count of alive
        routes.
        What i have not done is: sort nexthops on link events.
        I am not comfortable recreating or sorting nexthops on
        every carrier change. This leaves scope for optimizing in the
future

v1 to v2:
        Fix dead nexthop checks as suggested by dave

v2 to v3:
        Fix duplicated argument reported by kbuild test robot

v3 - v4:
        - removed per route rt_flags and derive it from the nh_flags during dumps
        - use kmemdup to make a copy of the route during route updates
          due to link events

 net/mpls/af_mpls.c  | 248 ++++++++++++++++++++++++++++++++++++++++++++--------
 net/mpls/internal.h |   2 +
 2 files changed, 213 insertions(+), 37 deletions(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index c70d750..c72c8e1 100644
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
@@ -165,7 +158,37 @@ static struct mpls_nh *mpls_select_multipath(struct mpls_route *rt,
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
+	int nh_index = 0;
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
+	if (rt->rt_nhn_alive == rt->rt_nhn)
+		goto out;
+	for_nexthops(rt) {
+		if (nh->nh_flags & (RTNH_F_DEAD | RTNH_F_LINKDOWN))
+			continue;
+		if (n == nh_index)
+			return nh;
+		n++;
+	} endfor_nexthops(rt);
+
 out:
 	return &rt->rt_nh[nh_index];
 }
@@ -354,17 +377,24 @@ struct mpls_route_config {
 	int			rc_mp_len;
 };
 
+static inline int mpls_route_alloc_size(int num_nh, u8 max_alen_aligned)
+{
+	struct mpls_route *rt;
+
+	return (ALIGN(sizeof(*rt) + num_nh * sizeof(*rt->rt_nh),
+		      VIA_ALEN_ALIGN) + num_nh * max_alen_aligned);
+}
+
 static struct mpls_route *mpls_rt_alloc(int num_nh, u8 max_alen)
 {
 	u8 max_alen_aligned = ALIGN(max_alen, VIA_ALEN_ALIGN);
 	struct mpls_route *rt;
 
-	rt = kzalloc(ALIGN(sizeof(*rt) + num_nh * sizeof(*rt->rt_nh),
-			   VIA_ALEN_ALIGN) +
-		     num_nh * max_alen_aligned,
+	rt = kzalloc(mpls_route_alloc_size(num_nh, max_alen_aligned),
 		     GFP_KERNEL);
 	if (rt) {
 		rt->rt_nhn = num_nh;
+		rt->rt_nhn_alive = num_nh;
 		rt->rt_max_alen = max_alen_aligned;
 	}
 
@@ -393,7 +423,8 @@ static void mpls_notify_route(struct net *net, unsigned index,
 
 static void mpls_route_update(struct net *net, unsigned index,
 			      struct mpls_route *new,
-			      const struct nl_info *info)
+			      const struct nl_info *info,
+			      bool notify)
 {
 	struct mpls_route __rcu **platform_label;
 	struct mpls_route *rt;
@@ -404,7 +435,8 @@ static void mpls_route_update(struct net *net, unsigned index,
 	rt = rtnl_dereference(platform_label[index]);
 	rcu_assign_pointer(platform_label[index], new);
 
-	mpls_notify_route(net, index, rt, new, info);
+	if (notify)
+		mpls_notify_route(net, index, rt, new, info);
 
 	/* If we removed a route free it now */
 	mpls_rt_free(rt);
@@ -536,6 +568,16 @@ static int mpls_nh_assign_dev(struct net *net, struct mpls_route *rt,
 
 	RCU_INIT_POINTER(nh->nh_dev, dev);
 
+	if (!(dev->flags & IFF_UP)) {
+		nh->nh_flags |= RTNH_F_DEAD;
+	} else {
+		unsigned int flags;
+
+		flags = dev_get_flags(dev);
+		if (!(flags & (IFF_RUNNING | IFF_LOWER_UP)))
+			nh->nh_flags |= RTNH_F_LINKDOWN;
+	}
+
 	return 0;
 
 errout:
@@ -570,6 +612,9 @@ static int mpls_nh_build_from_cfg(struct mpls_route_config *cfg,
 	if (err)
 		goto errout;
 
+	if (nh->nh_flags & (RTNH_F_DEAD | RTNH_F_LINKDOWN))
+		rt->rt_nhn_alive--;
+
 	return 0;
 
 errout:
@@ -577,8 +622,8 @@ errout:
 }
 
 static int mpls_nh_build(struct net *net, struct mpls_route *rt,
-			 struct mpls_nh *nh, int oif,
-			 struct nlattr *via, struct nlattr *newdst)
+			 struct mpls_nh *nh, int oif, struct nlattr *via,
+			 struct nlattr *newdst)
 {
 	int err = -ENOMEM;
 
@@ -681,11 +726,13 @@ static int mpls_nh_build_multi(struct mpls_route_config *cfg,
 			goto errout;
 
 		err = mpls_nh_build(cfg->rc_nlinfo.nl_net, rt, nh,
-				    rtnh->rtnh_ifindex, nla_via,
-				    nla_newdst);
+				    rtnh->rtnh_ifindex, nla_via, nla_newdst);
 		if (err)
 			goto errout;
 
+		if (nh->nh_flags & (RTNH_F_DEAD | RTNH_F_LINKDOWN))
+			rt->rt_nhn_alive--;
+
 		rtnh = rtnh_next(rtnh, &remaining);
 		nhs++;
 	} endfor_nexthops(rt);
@@ -764,7 +811,7 @@ static int mpls_route_add(struct mpls_route_config *cfg)
 	if (err)
 		goto freert;
 
-	mpls_route_update(net, index, rt, &cfg->rc_nlinfo);
+	mpls_route_update(net, index, rt, &cfg->rc_nlinfo, true);
 
 	return 0;
 
@@ -790,7 +837,7 @@ static int mpls_route_del(struct mpls_route_config *cfg)
 	if (index >= net->mpls.platform_labels)
 		goto errout;
 
-	mpls_route_update(net, index, NULL, &cfg->rc_nlinfo);
+	mpls_route_update(net, index, NULL, &cfg->rc_nlinfo, true);
 
 	err = 0;
 errout:
@@ -875,34 +922,112 @@ free:
 	return ERR_PTR(err);
 }
 
-static void mpls_ifdown(struct net_device *dev)
+static inline bool mpls_route_dev_exists(struct mpls_route *rt,
+					 struct net_device *dev)
+{
+	for_nexthops(rt) {
+		if (rtnl_dereference(nh->nh_dev) != dev)
+			continue;
+		return true;
+	} endfor_nexthops(rt);
+
+	return false;
+}
+
+static void mpls_ifdown(struct net_device *dev, int event)
 {
 	struct mpls_route __rcu **platform_label;
 	struct net *net = dev_net(dev);
-	struct mpls_dev *mdev;
+	struct mpls_route *rt_new;
 	unsigned index;
 
 	platform_label = rtnl_dereference(net->mpls.platform_label);
 	for (index = 0; index < net->mpls.platform_labels; index++) {
 		struct mpls_route *rt = rtnl_dereference(platform_label[index]);
+
 		if (!rt)
 			continue;
-		for_nexthops(rt) {
+
+		if (!mpls_route_dev_exists(rt, dev))
+			continue;
+
+		rt_new = kmemdup(rt, mpls_route_alloc_size(rt->rt_nhn,
+							   rt->rt_max_alen),
+							   GFP_KERNEL);
+		if (!rt_new) {
+			pr_warn("mpls_ifdown: kmemdup failed\n");
+			return;
+		}
+
+		for_nexthops(rt_new) {
 			if (rtnl_dereference(nh->nh_dev) != dev)
 				continue;
-			nh->nh_dev = NULL;
-		} endfor_nexthops(rt);
+			switch (event) {
+			case NETDEV_DOWN:
+			case NETDEV_UNREGISTER:
+				nh->nh_flags |= RTNH_F_DEAD;
+				/* fall through */
+			case NETDEV_CHANGE:
+				nh->nh_flags |= RTNH_F_LINKDOWN;
+				rt_new->rt_nhn_alive--;
+				break;
+			}
+			if (event == NETDEV_UNREGISTER)
+				RCU_INIT_POINTER(nh->nh_dev, NULL);
+		} endfor_nexthops(rt_new);
+
+		mpls_route_update(net, index, rt_new, NULL, false);
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
+	struct mpls_route *rt_new;
+	unsigned index;
+	int alive;
+
+	platform_label = rtnl_dereference(net->mpls.platform_label);
+	for (index = 0; index < net->mpls.platform_labels; index++) {
+		struct mpls_route *rt = rtnl_dereference(platform_label[index]);
+
+		if (!rt)
+			continue;
+
+		if (!mpls_route_dev_exists(rt, dev))
+			continue;
 
-	mpls_dev_sysctl_unregister(mdev);
+		rt_new = kmemdup(rt, mpls_route_alloc_size(rt->rt_nhn,
+							   rt->rt_max_alen),
+							   GFP_KERNEL);
+		if (!rt_new) {
+			pr_warn("mpls_ifdown: kmemdup failed\n");
+			return;
+		}
 
-	RCU_INIT_POINTER(dev->mpls_ptr, NULL);
+		alive = 0;
+		for_nexthops(rt_new) {
+			struct net_device *nh_dev =
+				rtnl_dereference(nh->nh_dev);
 
-	kfree_rcu(mdev, rcu);
+			if (!(nh->nh_flags & nh_flags)) {
+				alive++;
+				continue;
+			}
+			if (nh_dev != dev)
+				continue;
+			alive++;
+			nh->nh_flags &= ~nh_flags;
+		} endfor_nexthops(rt_new);
+
+		rt_new->rt_nhn_alive = alive;
+		mpls_route_update(net, index, rt_new, NULL, false);
+	}
+
+	return;
 }
 
 static int mpls_dev_notify(struct notifier_block *this, unsigned long event,
@@ -910,9 +1035,9 @@ static int mpls_dev_notify(struct notifier_block *this, unsigned long event,
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
@@ -920,10 +1045,39 @@ static int mpls_dev_notify(struct notifier_block *this, unsigned long event,
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
@@ -1237,9 +1391,15 @@ static int mpls_dump_route(struct sk_buff *skb, u32 portid, u32 seq, int event,
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
+		int dead = 0;
+		int linkdown = 0;
 
 		mp = nla_nest_start(skb, RTA_MULTIPATH);
 		if (!mp)
@@ -1253,6 +1413,15 @@ static int mpls_dump_route(struct sk_buff *skb, u32 portid, u32 seq, int event,
 			dev = rtnl_dereference(nh->nh_dev);
 			if (dev)
 				rtnh->rtnh_ifindex = dev->ifindex;
+			if (nh->nh_flags & RTNH_F_LINKDOWN) {
+				rtnh->rtnh_flags |= RTNH_F_LINKDOWN;
+				linkdown++;
+			}
+			if (nh->nh_flags & RTNH_F_DEAD) {
+				rtnh->rtnh_flags |= RTNH_F_DEAD;
+				dead++;
+			}
+
 			if (nh->nh_labels && nla_put_labels(skb, RTA_NEWDST,
 							    nh->nh_labels,
 							    nh->nh_label))
@@ -1266,6 +1435,11 @@ static int mpls_dump_route(struct sk_buff *skb, u32 portid, u32 seq, int event,
 			rtnh->rtnh_len = nlmsg_get_pos(skb) - (void *)rtnh;
 		} endfor_nexthops(rt);
 
+		if (linkdown == rt->rt_nhn)
+			rtm->rtm_flags |= RTNH_F_LINKDOWN;
+		if (dead == rt->rt_nhn)
+			rtm->rtm_flags |= RTNH_F_DEAD;
+
 		nla_nest_end(skb, mp);
 	}
 
@@ -1419,7 +1593,7 @@ static int resize_platform_label_table(struct net *net, size_t limit)
 
 	/* Free any labels beyond the new table */
 	for (index = limit; index < old_limit; index++)
-		mpls_route_update(net, index, NULL, NULL);
+		mpls_route_update(net, index, NULL, NULL, true);
 
 	/* Copy over the old labels */
 	cp_size = size;
diff --git a/net/mpls/internal.h b/net/mpls/internal.h
index bde52ce..732a5c1 100644
--- a/net/mpls/internal.h
+++ b/net/mpls/internal.h
@@ -41,6 +41,7 @@ enum mpls_payload_type {
 
 struct mpls_nh { /* next hop label forwarding entry */
 	struct net_device __rcu *nh_dev;
+	unsigned int		nh_flags;
 	u32			nh_label[MAX_NEW_LABELS];
 	u8			nh_labels;
 	u8			nh_via_alen;
@@ -74,6 +75,7 @@ struct mpls_route { /* next hop label forwarding entry */
 	u8			rt_payload_type;
 	u8			rt_max_alen;
 	unsigned int		rt_nhn;
+	unsigned int		rt_nhn_alive;
 	struct mpls_nh		rt_nh[0];
 };
 
-- 
1.9.1
