From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next v6] mpls: support for dead routes
Date: Sat, 28 Nov 2015 19:38:33 -0800
Message-ID: <1448768313-34809-1-git-send-email-roopa@cumulusnetworks.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: ebiederm@xmission.com, rshearma@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:36186 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752899AbbK2Dii (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Nov 2015 22:38:38 -0500
Received: by pacdm15 with SMTP id dm15so149111974pac.3
        for <netdev@vger.kernel.org>; Sat, 28 Nov 2015 19:38:38 -0800 (PST)
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

v4 -v5
	- if kmemdup fails, modify the original route in place. This is a
	corner case and only side effect is that in the remote case
	of kmemdup failure, the changes will not be atomically visible
	to datapath.
	- replace for_nexthops with change_nexthops in a bunch of places.
	- fix indent

v5 - v6
	- update routes in place in mpls netdev notifier handlers. 
	the additional kmemdup complexity and failure path recovery
	does not seem necessary to support the transient atomic update
	case


 net/mpls/af_mpls.c  | 184 ++++++++++++++++++++++++++++++++++++++++++++--------
 net/mpls/internal.h |   2 +
 2 files changed, 158 insertions(+), 28 deletions(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index c70d750..ab01d9e 100644
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
@@ -365,6 +388,7 @@ static struct mpls_route *mpls_rt_alloc(int num_nh, u8 max_alen)
 		     GFP_KERNEL);
 	if (rt) {
 		rt->rt_nhn = num_nh;
+		rt->rt_nhn_alive = num_nh;
 		rt->rt_max_alen = max_alen_aligned;
 	}
 
@@ -536,6 +560,16 @@ static int mpls_nh_assign_dev(struct net *net, struct mpls_route *rt,
 
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
@@ -570,6 +604,9 @@ static int mpls_nh_build_from_cfg(struct mpls_route_config *cfg,
 	if (err)
 		goto errout;
 
+	if (nh->nh_flags & (RTNH_F_DEAD | RTNH_F_LINKDOWN))
+		rt->rt_nhn_alive--;
+
 	return 0;
 
 errout:
@@ -577,8 +614,8 @@ errout:
 }
 
 static int mpls_nh_build(struct net *net, struct mpls_route *rt,
-			 struct mpls_nh *nh, int oif,
-			 struct nlattr *via, struct nlattr *newdst)
+			 struct mpls_nh *nh, int oif, struct nlattr *via,
+			 struct nlattr *newdst)
 {
 	int err = -ENOMEM;
 
@@ -681,11 +718,13 @@ static int mpls_nh_build_multi(struct mpls_route_config *cfg,
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
@@ -875,34 +914,74 @@ free:
 	return ERR_PTR(err);
 }
 
-static void mpls_ifdown(struct net_device *dev)
+static void mpls_ifdown(struct net_device *dev, int event)
 {
 	struct mpls_route __rcu **platform_label;
 	struct net *net = dev_net(dev);
-	struct mpls_dev *mdev;
 	unsigned index;
 
 	platform_label = rtnl_dereference(net->mpls.platform_label);
 	for (index = 0; index < net->mpls.platform_labels; index++) {
 		struct mpls_route *rt = rtnl_dereference(platform_label[index]);
+
 		if (!rt)
 			continue;
-		for_nexthops(rt) {
+
+		change_nexthops(rt) {
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
+			if (event == NETDEV_UNREGISTER)
+				RCU_INIT_POINTER(nh->nh_dev, NULL);
 		} endfor_nexthops(rt);
 	}
 
-	mdev = mpls_dev_get(dev);
-	if (!mdev)
-		return;
 
-	mpls_dev_sysctl_unregister(mdev);
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
+
+		alive = 0;
+		change_nexthops(rt) {
+			struct net_device *nh_dev =
+				rtnl_dereference(nh->nh_dev);
+
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
+		rt->rt_nhn_alive = alive;
+	}
 
-	kfree_rcu(mdev, rcu);
+	return;
 }
 
 static int mpls_dev_notify(struct notifier_block *this, unsigned long event,
@@ -910,9 +989,9 @@ static int mpls_dev_notify(struct notifier_block *this, unsigned long event,
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
@@ -920,10 +999,39 @@ static int mpls_dev_notify(struct notifier_block *this, unsigned long event,
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
@@ -1237,9 +1345,15 @@ static int mpls_dump_route(struct sk_buff *skb, u32 portid, u32 seq, int event,
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
@@ -1253,6 +1367,15 @@ static int mpls_dump_route(struct sk_buff *skb, u32 portid, u32 seq, int event,
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
@@ -1266,6 +1389,11 @@ static int mpls_dump_route(struct sk_buff *skb, u32 portid, u32 seq, int event,
 			rtnh->rtnh_len = nlmsg_get_pos(skb) - (void *)rtnh;
 		} endfor_nexthops(rt);
 
+		if (linkdown == rt->rt_nhn)
+			rtm->rtm_flags |= RTNH_F_LINKDOWN;
+		if (dead == rt->rt_nhn)
+			rtm->rtm_flags |= RTNH_F_DEAD;
+
 		nla_nest_end(skb, mp);
 	}
 
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
