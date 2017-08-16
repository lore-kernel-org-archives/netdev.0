From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next] net: ipv6: put host and anycast routes on device with address
Date: Wed, 16 Aug 2017 15:37:56 -0700
Message-ID: <1502923076-12292-1-git-send-email-dsahern@gmail.com>
Cc: yoshfuji@linux-ipv6.org, hannes@stressinduktion.org,
        David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36804 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752262AbdHPWiE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 18:38:04 -0400
Received: by mail-pg0-f66.google.com with SMTP id y129so6681366pgy.3
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 15:38:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One nagging difference between ipv4 and ipv6 is host routes for ipv6
addresses are installed using the loopback device or VRF / L3 Master
device. e.g.,

    2001:db8:1::/120 dev veth0 proto kernel metric 256 pref medium
    local 2001:db8:1::1 dev lo table local proto kernel metric 0 pref medium

Using the loopback device is convenient -- necessary for local tx, but
has some nasty side effects, most notably setting the 'lo' device down
causes all host routes for all local IPv6 address to be removed from the
FIB and completely breaks IPv6 networking across all interfaces.

This patch puts FIB entries for IPv6 routes against the device. This
simplifies the routes in the FIB, for example by making dst->dev and
rt6i_idev->dev the same (a future patch can look at removing the device
reference taken for rt6i_idev for FIB entries). For example:

    $ ip -6 r ls table all | grep veth1
    2001:db8:99::/120 dev veth1 proto kernel metric 256 pref medium
    anycast 2001:db8:99:: dev veth1 table local proto kernel metric 0 pref medium
    local 2001:db8:99::1 dev veth1 table local proto kernel metric 0 pref medium

When copies are made on FIB lookups, the cloned route has dst->dev
set to loopback (or the L3 master device). This is needed for the
local Tx of packets to local addresses.

With fib entries allocated against the real network device, the addrconf
code that reinserts host routes on admin up of 'lo' is no longer needed.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 net/ipv6/addrconf.c | 42 ------------------------------------------
 net/ipv6/route.c    | 46 ++++++++++++++++++++++++++++++++++------------
 2 files changed, 34 insertions(+), 54 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 640792e1ecb7..45d0a24644de 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3030,9 +3030,6 @@ static void sit_add_v4_addrs(struct inet6_dev *idev)
 static void init_loopback(struct net_device *dev)
 {
 	struct inet6_dev  *idev;
-	struct net_device *sp_dev;
-	struct inet6_ifaddr *sp_ifa;
-	struct rt6_info *sp_rt;
 
 	/* ::1 */
 
@@ -3045,45 +3042,6 @@ static void init_loopback(struct net_device *dev)
 	}
 
 	add_addr(idev, &in6addr_loopback, 128, IFA_HOST);
-
-	/* Add routes to other interface's IPv6 addresses */
-	for_each_netdev(dev_net(dev), sp_dev) {
-		if (!strcmp(sp_dev->name, dev->name))
-			continue;
-
-		idev = __in6_dev_get(sp_dev);
-		if (!idev)
-			continue;
-
-		read_lock_bh(&idev->lock);
-		list_for_each_entry(sp_ifa, &idev->addr_list, if_list) {
-
-			if (sp_ifa->flags & (IFA_F_DADFAILED | IFA_F_TENTATIVE))
-				continue;
-
-			if (sp_ifa->rt) {
-				/* This dst has been added to garbage list when
-				 * lo device down, release this obsolete dst and
-				 * reallocate a new router for ifa.
-				 */
-				if (!sp_ifa->rt->rt6i_node) {
-					ip6_rt_put(sp_ifa->rt);
-					sp_ifa->rt = NULL;
-				} else {
-					continue;
-				}
-			}
-
-			sp_rt = addrconf_dst_alloc(idev, &sp_ifa->addr, false);
-
-			/* Failure cases are ignored */
-			if (!IS_ERR(sp_rt)) {
-				sp_ifa->rt = sp_rt;
-				ip6_ins_rt(sp_rt);
-			}
-		}
-		read_unlock_bh(&idev->lock);
-	}
 }
 
 void addrconf_add_linklocal(struct inet6_dev *idev,
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index dc021ed6dd37..1864effcaf00 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -958,10 +958,34 @@ int ip6_ins_rt(struct rt6_info *rt)
 	return __ip6_ins_rt(rt, &info, &mxc, NULL);
 }
 
+/* called with rcu_lock held */
+static struct net_device *ip6_rt_get_dev_rcu(struct rt6_info *rt)
+{
+	struct net_device *dev = rt->dst.dev;
+
+	if (rt->rt6i_flags & RTF_LOCAL) {
+		/* for copies of local routes, dst->dev needs to be the
+		 * device if it is a master device, the master device if
+		 * device is enslaved, and the loopback as the default
+		 */
+		if (netif_is_l3_slave(dev) &&
+		    !rt6_need_strict(&rt->rt6i_dst.addr))
+			dev = l3mdev_master_dev_rcu(dev);
+		else if (!netif_is_l3_master(dev))
+			dev = dev_net(dev)->loopback_dev;
+		/* last case is netif_is_l3_master(dev) is true in which
+		 * case we want dev returned to be dev
+		 */
+	}
+
+	return dev;
+}
+
 static struct rt6_info *ip6_rt_cache_alloc(struct rt6_info *ort,
 					   const struct in6_addr *daddr,
 					   const struct in6_addr *saddr)
 {
+	struct net_device *dev;
 	struct rt6_info *rt;
 
 	/*
@@ -971,8 +995,10 @@ static struct rt6_info *ip6_rt_cache_alloc(struct rt6_info *ort,
 	if (ort->rt6i_flags & (RTF_CACHE | RTF_PCPU))
 		ort = (struct rt6_info *)ort->dst.from;
 
-	rt = __ip6_dst_alloc(dev_net(ort->dst.dev), ort->dst.dev, 0);
-
+	rcu_read_lock();
+	dev = ip6_rt_get_dev_rcu(ort);
+	rt = __ip6_dst_alloc(dev_net(dev), dev, 0);
+	rcu_read_unlock();
 	if (!rt)
 		return NULL;
 
@@ -1000,11 +1026,13 @@ static struct rt6_info *ip6_rt_cache_alloc(struct rt6_info *ort,
 
 static struct rt6_info *ip6_rt_pcpu_alloc(struct rt6_info *rt)
 {
+	struct net_device *dev;
 	struct rt6_info *pcpu_rt;
 
-	pcpu_rt = __ip6_dst_alloc(dev_net(rt->dst.dev),
-				  rt->dst.dev, rt->dst.flags);
-
+	rcu_read_lock();
+	dev = ip6_rt_get_dev_rcu(rt);
+	pcpu_rt = __ip6_dst_alloc(dev_net(dev), dev, rt->dst.flags);
+	rcu_read_unlock();
 	if (!pcpu_rt)
 		return NULL;
 	ip6_rt_copy_init(pcpu_rt, rt);
@@ -2688,15 +2716,9 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 {
 	u32 tb_id;
 	struct net *net = dev_net(idev->dev);
-	struct net_device *dev = net->loopback_dev;
+	struct net_device *dev = idev->dev;
 	struct rt6_info *rt;
 
-	/* use L3 Master device as loopback for host routes if device
-	 * is enslaved and address is not link local or multicast
-	 */
-	if (!rt6_need_strict(addr))
-		dev = l3mdev_master_dev_rcu(idev->dev) ? : dev;
-
 	rt = ip6_dst_alloc(net, dev, DST_NOCOUNT);
 	if (!rt)
 		return ERR_PTR(-ENOMEM);
-- 
2.1.4
