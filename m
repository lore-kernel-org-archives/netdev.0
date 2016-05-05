From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 12/13] net: vrf: Implement get_saddr for IPv6
Date: Wed,  4 May 2016 20:33:29 -0700
Message-ID: <1462419210-10463-13-git-send-email-dsa@cumulusnetworks.com>
References: <1462419210-10463-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:36833 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755906AbcEEDeY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 23:34:24 -0400
Received: by mail-pa0-f43.google.com with SMTP id bt5so30790728pac.3
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 20:34:24 -0700 (PDT)
In-Reply-To: <1462419210-10463-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Right now source address selection is all screwed up for a number of
use cases. It does not properly take into account VRF centric addresses
or even valid routes for a VRF. Fix by implementating a get_saddr method
similar to what was done for IPv4. The get_saddr6 method does a full
lookup which means pulling a route from the VRF FIB table. Lookup
failures (eg., unreachable) then cause the source address selection
to fail which gets propagated back to the caller.

Since ipv6_dev_get_saddr is already exported move ip6_route_get_saddr to
the header as an inline since it only checks for a preferred source
address prior to calling ipv6_dev_get_saddr.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c       | 86 +++++++++++++++++++++++++++++++++++++++----------
 include/net/ip6_route.h | 21 ++++++++++--
 include/net/l3mdev.h    | 11 +++++++
 net/ipv6/ip6_output.c   | 12 +++++--
 net/ipv6/route.c        | 17 ----------
 net/l3mdev/l3mdev.c     | 25 ++++++++++++++
 6 files changed, 133 insertions(+), 39 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index fb2d0b2052ea..d83d903dc674 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -774,20 +774,11 @@ static bool ipv6_ndisc_frame(const struct sk_buff *skb)
 	return rc;
 }
 
-static void vrf_ip6_input_dst(struct sk_buff *skb, struct net_device *vrf_dev,
-			      int ifindex)
+static struct rt6_info *vrf_ip6_route_lookup(struct net_device *dev,
+					     struct flowi6 *fl6, int ifindex)
 {
-	const struct ipv6hdr *iph = ipv6_hdr(skb);
-	struct flowi6 fl6 = {
-		.daddr		= iph->daddr,
-		.saddr		= iph->saddr,
-		.flowlabel	= ip6_flowinfo(iph),
-		.flowi6_mark	= skb->mark,
-		.flowi6_proto	= iph->nexthdr,
-		.flowi6_iif	= ifindex,
-	};
-	struct net_vrf *vrf = netdev_priv(vrf_dev);
-	struct net *net = dev_net(vrf_dev);
+	struct net_vrf *vrf = netdev_priv(dev);
+	struct net *net = dev_net(dev);
 	struct fib6_table *table = NULL;
 	struct rt6_info *rt6;
 
@@ -801,14 +792,36 @@ static void vrf_ip6_input_dst(struct sk_buff *skb, struct net_device *vrf_dev,
 	rcu_read_unlock();
 
 	if (!table)
-		return;
+		return NULL;
 
-	rt6 = ip6_pol_route(net, table, ifindex, &fl6,
-			    RT6_LOOKUP_F_HAS_SADDR | RT6_LOOKUP_F_IFACE);
+	return ip6_pol_route(net, table, ifindex, fl6,
+			     RT6_LOOKUP_F_HAS_SADDR | RT6_LOOKUP_F_IFACE);
+}
 
-	if (unlikely(&rt6->dst == &net->ipv6.ip6_null_entry->dst))
+static void vrf_ip6_input_dst(struct sk_buff *skb, struct net_device *dev,
+			      int ifindex)
+{
+	const struct ipv6hdr *iph = ipv6_hdr(skb);
+	struct flowi6 fl6 = {
+		.daddr		= iph->daddr,
+		.saddr		= iph->saddr,
+		.flowlabel	= ip6_flowinfo(iph),
+		.flowi6_mark	= skb->mark,
+		.flowi6_proto	= iph->nexthdr,
+		.flowi6_iif	= ifindex,
+	};
+	struct net *net = dev_net(dev);
+	struct rt6_info *rt6;
+
+	rt6 = vrf_ip6_route_lookup(dev, &fl6, ifindex);
+	if (unlikely(!rt6))
 		return;
 
+	if (unlikely(&rt6->dst == &net->ipv6.ip6_null_entry->dst)) {
+		dst_release(&rt6->dst);
+		return;
+	}
+
 	skb_dst_set(skb, &rt6->dst);
 }
 
@@ -836,6 +849,44 @@ static struct sk_buff *vrf_ip6_rcv(struct net_device *vrf_dev,
 	return skb;
 }
 
+/* called under rcu_read_lock */
+static int vrf_get_saddr6(struct net_device *dev, const struct sock *sk,
+			  struct flowi6 *fl6)
+{
+	struct net *net = dev_net(dev);
+	struct dst_entry *dst;
+	struct rt6_info *rt;
+	int err;
+
+	if (rt6_need_strict(&fl6->daddr)) {
+		rt = vrf_ip6_route_lookup(dev, fl6, fl6->flowi6_oif);
+		if (unlikely(!rt))
+			return 0;
+
+		dst = &rt->dst;
+	} else {
+		__u8 flags = fl6->flowi6_flags;
+
+		fl6->flowi6_flags |= FLOWI_FLAG_L3MDEV_SRC;
+		fl6->flowi6_flags |= FLOWI_FLAG_SKIP_NH_OIF;
+
+		dst = ip6_route_output(net, sk, fl6);
+		rt = (struct rt6_info *)dst;
+
+		fl6->flowi6_flags = flags;
+	}
+
+	err = dst->error;
+	if (!err) {
+		err = ip6_route_get_saddr(net, rt, &fl6->daddr,
+					  sk ? inet6_sk(sk)->srcprefs : 0,
+					  &fl6->saddr);
+	}
+
+	dst_release(dst);
+
+	return err;
+}
 #else
 static struct sk_buff *vrf_ip6_rcv(struct net_device *vrf_dev,
 				   struct sk_buff *skb)
@@ -947,6 +998,7 @@ static const struct l3mdev_ops vrf_l3mdev_ops = {
 	.l3mdev_l3_rcv		= vrf_l3_rcv,
 #if IS_ENABLED(CONFIG_IPV6)
 	.l3mdev_get_rt6_dst	= vrf_get_rt6_dst,
+	.l3mdev_get_saddr6	= vrf_get_saddr6,
 #endif
 };
 
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index f73a65e97597..6886deb45679 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -18,6 +18,7 @@ struct route_info {
 	__u8			prefix[0];	/* 0,8 or 16 */
 };
 
+#include <net/addrconf.h>
 #include <net/flow.h>
 #include <net/ip6_fib.h>
 #include <net/sock.h>
@@ -89,9 +90,23 @@ int ip6_route_add(struct fib6_config *cfg);
 int ip6_ins_rt(struct rt6_info *);
 int ip6_del_rt(struct rt6_info *);
 
-int ip6_route_get_saddr(struct net *net, struct rt6_info *rt,
-			const struct in6_addr *daddr, unsigned int prefs,
-			struct in6_addr *saddr);
+static inline int ip6_route_get_saddr(struct net *net, struct rt6_info *rt,
+				      const struct in6_addr *daddr,
+				      unsigned int prefs,
+				      struct in6_addr *saddr)
+{
+	struct inet6_dev *idev =
+			rt ? ip6_dst_idev((struct dst_entry *)rt) : NULL;
+	int err = 0;
+
+	if (rt && rt->rt6i_prefsrc.plen)
+		*saddr = rt->rt6i_prefsrc.addr;
+	else
+		err = ipv6_dev_get_saddr(net, idev ? idev->dev : NULL,
+					 daddr, prefs, saddr);
+
+	return err;
+}
 
 struct rt6_info *rt6_lookup(struct net *net, const struct in6_addr *daddr,
 			    const struct in6_addr *saddr, int oif, int flags);
diff --git a/include/net/l3mdev.h b/include/net/l3mdev.h
index d575185600a5..6ba0a206db45 100644
--- a/include/net/l3mdev.h
+++ b/include/net/l3mdev.h
@@ -38,6 +38,9 @@ struct l3mdev_ops {
 	struct dst_entry * (*l3mdev_get_rt6_dst)(const struct net_device *dev,
 						 struct flowi6 *fl6,
 						 int flags);
+	int		   (*l3mdev_get_saddr6)(struct net_device *dev,
+						const struct sock *sk,
+						struct flowi6 *fl6);
 };
 
 #ifdef CONFIG_NET_L3_MASTER_DEV
@@ -137,6 +140,8 @@ int l3mdev_get_saddr(struct net *net, int ifindex, struct flowi4 *fl4);
 
 struct dst_entry *l3mdev_get_rt6_dst(struct net *net, struct flowi6 *fl6,
 				     int flags);
+int l3mdev_get_saddr6(struct net *net, const struct sock *sk,
+		      struct flowi6 *fl6);
 
 static inline
 struct sk_buff *l3mdev_l3_rcv(struct sk_buff *skb, u16 proto)
@@ -229,6 +234,12 @@ struct dst_entry *l3mdev_get_rt6_dst(struct net *net, struct flowi6 *fl6,
 	return NULL;
 }
 
+static inline int l3mdev_get_saddr6(struct net *net, const struct sock *sk,
+				    struct flowi6 *fl6)
+{
+	return 0;
+}
+
 static inline
 struct sk_buff *l3mdev_ip_rcv(struct sk_buff *skb)
 {
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index cbf127ae7c67..cfd01782a621 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -910,6 +910,13 @@ static int ip6_dst_lookup_tail(struct net *net, const struct sock *sk,
 	int err;
 	int flags = 0;
 
+	if (ipv6_addr_any(&fl6->saddr) && fl6->flowi6_oif &&
+	    (!*dst || !(*dst)->error)) {
+		err = l3mdev_get_saddr6(net, sk, fl6);
+		if (err)
+			goto out_err;
+	}
+
 	/* The correct way to handle this would be to do
 	 * ip6_route_get_saddr, and then ip6_route_output; however,
 	 * the route-specific preferred source forces the
@@ -999,10 +1006,11 @@ static int ip6_dst_lookup_tail(struct net *net, const struct sock *sk,
 	return 0;
 
 out_err_release:
-	if (err == -ENETUNREACH)
-		IP6_INC_STATS(net, NULL, IPSTATS_MIB_OUTNOROUTES);
 	dst_release(*dst);
 	*dst = NULL;
+out_err:
+	if (err == -ENETUNREACH)
+		IP6_INC_STATS(net, NULL, IPSTATS_MIB_OUTNOROUTES);
 	return err;
 }
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index a87e66d2284f..67ec5594be9c 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2584,23 +2584,6 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 	return rt;
 }
 
-int ip6_route_get_saddr(struct net *net,
-			struct rt6_info *rt,
-			const struct in6_addr *daddr,
-			unsigned int prefs,
-			struct in6_addr *saddr)
-{
-	struct inet6_dev *idev =
-		rt ? ip6_dst_idev((struct dst_entry *)rt) : NULL;
-	int err = 0;
-	if (rt && rt->rt6i_prefsrc.plen)
-		*saddr = rt->rt6i_prefsrc.addr;
-	else
-		err = ipv6_dev_get_saddr(net, idev ? idev->dev : NULL,
-					 daddr, prefs, saddr);
-	return err;
-}
-
 /* remove deleted ip from prefsrc entries */
 struct arg_dev_net_ip {
 	struct net_device *dev;
diff --git a/net/l3mdev/l3mdev.c b/net/l3mdev/l3mdev.c
index dceac272b8c4..3e08d3e27a8a 100644
--- a/net/l3mdev/l3mdev.c
+++ b/net/l3mdev/l3mdev.c
@@ -164,3 +164,28 @@ int l3mdev_get_saddr(struct net *net, int ifindex, struct flowi4 *fl4)
 	return rc;
 }
 EXPORT_SYMBOL_GPL(l3mdev_get_saddr);
+
+int l3mdev_get_saddr6(struct net *net, const struct sock *sk,
+		      struct flowi6 *fl6)
+{
+	struct net_device *dev;
+	int rc = 0;
+
+	if (fl6->flowi6_oif) {
+		rcu_read_lock();
+
+		dev = dev_get_by_index_rcu(net, fl6->flowi6_oif);
+		if (dev && netif_is_l3_slave(dev))
+			dev = netdev_master_upper_dev_get_rcu(dev);
+
+		if (dev && netif_is_l3_master(dev) &&
+		    dev->l3mdev_ops->l3mdev_get_saddr6) {
+			rc = dev->l3mdev_ops->l3mdev_get_saddr6(dev, sk, fl6);
+		}
+
+		rcu_read_unlock();
+	}
+
+	return rc;
+}
+EXPORT_SYMBOL_GPL(l3mdev_get_saddr6);
-- 
2.1.4
