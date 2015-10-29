From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next RFC] mpls: support for dead routes
Date: Thu, 29 Oct 2015 08:49:08 -0700
Message-ID: <1446133748-13738-1-git-send-email-roopa@cumulusnetworks.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: ebiederm@xmission.com, rshearma@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34934 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750891AbbJ2PtM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 11:49:12 -0400
Received: by pasz6 with SMTP id z6so44333640pas.2
        for <netdev@vger.kernel.org>; Thu, 29 Oct 2015 08:49:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

Adds support for both RTNH_F_DEAD and RTNH_F_LINKDOWN flags.
This resembles ipv4 fib code. I also picked fib_rebalance from
ipv4. Enabled weights support for nexthop, just because the
infrastructure is already there.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
I want to get this in before net-next closes as promised.
I have tested it for the dead/linkdown flags. The multipath selection
and hash calculation in the face of dead routes needs some more
work. I am short on cycles this week and thought of getting some 
early feedback. Hence sending this out as RFC. I will continue with some
more testing.  Robert, I am using your hash algo but it needs some more
work with dead routes. If you already have any thoughts on this, i will
take them. thanks!.


 net/mpls/af_mpls.c  | 228 +++++++++++++++++++++++++++++++++++++++++++++-------
 net/mpls/internal.h |   4 +
 2 files changed, 202 insertions(+), 30 deletions(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index c70d750..7db9678 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -27,6 +27,8 @@
  */
 #define MAX_MP_SELECT_LABELS 4
 
+u32 mpls_multipath_secret __read_mostly;
+
 static int zero = 0;
 static int label_limit = (1 << 20) - 1;
 
@@ -96,22 +98,52 @@ bool mpls_pkt_too_big(const struct sk_buff *skb, unsigned int mtu)
 }
 EXPORT_SYMBOL_GPL(mpls_pkt_too_big);
 
-static struct mpls_nh *mpls_select_multipath(struct mpls_route *rt,
-					     struct sk_buff *skb, bool bos)
+static void mpls_multipath_rebalance(struct mpls_route *rt)
+{
+	int total;
+	int w;
+
+	if (rt->rt_nhn < 2)
+		return;
+
+	total = 0;
+	for_nexthops(rt) {
+		if ((nh->nh_flags & RTNH_F_DEAD) ||
+		    (nh->nh_flags & RTNH_F_LINKDOWN))
+			continue;
+
+		total += nh->nh_weight;
+	} endfor_nexthops(rt);
+
+	w = 0;
+	change_nexthops(rt) {
+		int upper_bound;
+
+		if ((nh->nh_flags & RTNH_F_DEAD) ||
+		    (nh->nh_flags & RTNH_F_LINKDOWN)) {
+			upper_bound = -1;
+		} else {
+			w += nh->nh_weight;
+			upper_bound = DIV_ROUND_CLOSEST_ULL((u64)w << 31,
+							    total) - 1;
+		}
+
+		atomic_set(&nh->nh_upper_bound, upper_bound);
+	} endfor_nexthops(rt);
+
+	net_get_random_once(&mpls_multipath_secret,
+			    sizeof(mpls_multipath_secret));
+}
+
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
@@ -165,9 +197,29 @@ static struct mpls_nh *mpls_select_multipath(struct mpls_route *rt,
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
+
+	/* No need to look further into packet if there's only
+	 * one path
+	 */
+	if (rt->rt_nhn == 1)
+		goto out;
+
+	hash = mpls_multipath_hash(rt, skb, bos);
+	for_nexthops(rt) {
+		if (hash > atomic_read(&nh->nh_upper_bound))
+			continue;
+		return nh;
+	} endfor_nexthops(rt);
+
 out:
-	return &rt->rt_nh[nh_index];
+	return &rt->rt_nh[0];
 }
 
 static bool mpls_egress(struct mpls_route *rt, struct sk_buff *skb,
@@ -577,7 +629,7 @@ errout:
 }
 
 static int mpls_nh_build(struct net *net, struct mpls_route *rt,
-			 struct mpls_nh *nh, int oif,
+			 struct mpls_nh *nh, int oif, int hops,
 			 struct nlattr *via, struct nlattr *newdst)
 {
 	int err = -ENOMEM;
@@ -597,6 +649,7 @@ static int mpls_nh_build(struct net *net, struct mpls_route *rt,
 	if (err)
 		goto errout;
 
+	nh->nh_weight = hops + 1;
 	err = mpls_nh_assign_dev(net, rt, nh, oif);
 	if (err)
 		goto errout;
@@ -663,10 +716,9 @@ static int mpls_nh_build_multi(struct mpls_route_config *cfg,
 		if (!rtnh_ok(rtnh, remaining))
 			goto errout;
 
-		/* neither weighted multipath nor any flags
-		 * are supported
+		/* flags are not supported
 		 */
-		if (rtnh->rtnh_hops || rtnh->rtnh_flags)
+		if (rtnh->rtnh_flags)
 			goto errout;
 
 		attrlen = rtnh_attrlen(rtnh);
@@ -681,8 +733,8 @@ static int mpls_nh_build_multi(struct mpls_route_config *cfg,
 			goto errout;
 
 		err = mpls_nh_build(cfg->rc_nlinfo.nl_net, rt, nh,
-				    rtnh->rtnh_ifindex, nla_via,
-				    nla_newdst);
+				    rtnh->rtnh_ifindex, rtnh->rtnh_hops,
+				    nla_via, nla_newdst);
 		if (err)
 			goto errout;
 
@@ -875,34 +927,111 @@ free:
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
+		int changed = 0;
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
+				changed = 1;
+				break;
+			}
+			if (event == NETDEV_UNREGISTER) {
+				nh->nh_dev = NULL;
+				dead = rt->rt_nhn;
+				changed = 1;
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
+				changed = 1;
+				break;
+			}
+		}
+
+		if (changed)
+			mpls_multipath_rebalance(rt);
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
+		int changed = 0;
+
+		if (!rt)
+			continue;
+		alive = 0;
+		for_nexthops(rt) {
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
+			changed = 1;
+		} endfor_nexthops(rt);
 
-	mpls_dev_sysctl_unregister(mdev);
+		if (alive > 0) {
+			rt->rt_flags &= ~nh_flags;
+			changed = 1;
+		}
 
-	RCU_INIT_POINTER(dev->mpls_ptr, NULL);
+		if (changed)
+			mpls_multipath_rebalance(rt);
+	}
 
-	kfree_rcu(mdev, rcu);
+	return;
 }
 
 static int mpls_dev_notify(struct notifier_block *this, unsigned long event,
@@ -910,9 +1039,9 @@ static int mpls_dev_notify(struct notifier_block *this, unsigned long event,
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
@@ -920,10 +1049,39 @@ static int mpls_dev_notify(struct notifier_block *this, unsigned long event,
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
@@ -1237,6 +1395,10 @@ static int mpls_dump_route(struct sk_buff *skb, u32 portid, u32 seq, int event,
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
@@ -1253,6 +1415,12 @@ static int mpls_dump_route(struct sk_buff *skb, u32 portid, u32 seq, int event,
 			dev = rtnl_dereference(nh->nh_dev);
 			if (dev)
 				rtnh->rtnh_ifindex = dev->ifindex;
+			if (nh->nh_flags & RTNH_F_LINKDOWN)
+				rtnh->rtnh_flags |= RTNH_F_LINKDOWN;
+			if (nh->nh_flags & RTNH_F_DEAD)
+				rtnh->rtnh_flags |= RTNH_F_DEAD;
+
+			rtnh->rtnh_hops = nh->nh_weight - 1;
 			if (nh->nh_labels && nla_put_labels(skb, RTA_NEWDST,
 							    nh->nh_labels,
 							    nh->nh_label))
diff --git a/net/mpls/internal.h b/net/mpls/internal.h
index bde52ce..7014032 100644
--- a/net/mpls/internal.h
+++ b/net/mpls/internal.h
@@ -41,6 +41,9 @@ enum mpls_payload_type {
 
 struct mpls_nh { /* next hop label forwarding entry */
 	struct net_device __rcu *nh_dev;
+	unsigned int		nh_flags;
+	int			nh_weight;
+	atomic_t                nh_upper_bound;
 	u32			nh_label[MAX_NEW_LABELS];
 	u8			nh_labels;
 	u8			nh_via_alen;
@@ -70,6 +73,7 @@ struct mpls_nh { /* next hop label forwarding entry */
  */
 struct mpls_route { /* next hop label forwarding entry */
 	struct rcu_head		rt_rcu;
+	unsigned int		rt_flags;
 	u8			rt_protocol;
 	u8			rt_payload_type;
 	u8			rt_max_alen;
-- 
1.9.1
