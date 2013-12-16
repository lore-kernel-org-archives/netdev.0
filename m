From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next] ipv6: use interface mtu for determining if packet-too-big should be send
Date: Mon, 16 Dec 2013 09:09:14 +0100
Message-ID: <20131216080914.GA28677@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:58236 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752260Ab3LPIJP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 03:09:15 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6 forwarding path should also not depend on the path mtu values to
judge if a packet should get dropped and an ICMP PTB should be returned.

For the accompanying change in IPv4, have a look at "ipv4: introduce
ip_dst_mtu_secure and protect forwarding path against pmtu spoofing".

I needed to move in6_dev_dev around to keep ip6_dst_mtu_secure as a static
inline function in the header and to keep header dependencies happy.

For the IPv4 change, see patch "ipv4: introduce ip_dst_mtu_secure and
protect forwarding path against pmtu spoofing".

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/addrconf.h     | 32 --------------------------------
 include/net/ip6_route.h    | 31 ++++++++++++++++++++++++++++---
 include/net/ipv6.h         | 32 ++++++++++++++++++++++++++++++++
 include/net/netns/ipv6.h   |  1 +
 net/ipv6/ip6_output.c      |  3 ++-
 net/ipv6/sysctl_net_ipv6.c |  8 ++++++++
 6 files changed, 71 insertions(+), 36 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 66c4a44..d2db1be 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -216,38 +216,6 @@ int inet6addr_notifier_call_chain(unsigned long val, void *v);
 void inet6_netconf_notify_devconf(struct net *net, int type, int ifindex,
 				  struct ipv6_devconf *devconf);
 
-/**
- * __in6_dev_get - get inet6_dev pointer from netdevice
- * @dev: network device
- *
- * Caller must hold rcu_read_lock or RTNL, because this function
- * does not take a reference on the inet6_dev.
- */
-static inline struct inet6_dev *__in6_dev_get(const struct net_device *dev)
-{
-	return rcu_dereference_rtnl(dev->ip6_ptr);
-}
-
-/**
- * in6_dev_get - get inet6_dev pointer from netdevice
- * @dev: network device
- *
- * This version can be used in any context, and takes a reference
- * on the inet6_dev. Callers must use in6_dev_put() later to
- * release this reference.
- */
-static inline struct inet6_dev *in6_dev_get(const struct net_device *dev)
-{
-	struct inet6_dev *idev;
-
-	rcu_read_lock();
-	idev = rcu_dereference(dev->ip6_ptr);
-	if (idev)
-		atomic_inc(&idev->refcnt);
-	rcu_read_unlock();
-	return idev;
-}
-
 static inline struct neigh_parms *__in6_dev_nd_parms_get_rcu(const struct net_device *dev)
 {
 	struct inet6_dev *idev = __in6_dev_get(dev);
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index c2626ce..7b5039d 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -174,12 +174,37 @@ static inline bool ipv6_unicast_destination(const struct sk_buff *skb)
 
 int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *));
 
-static inline int ip6_skb_dst_mtu(struct sk_buff *skb)
+static inline unsigned int ip6_dst_mtu_secure(const struct dst_entry *dst,
+					      bool forward)
+{
+	unsigned int mtu;
+	struct inet6_dev *idev;
+	struct net *net = dev_net(dst->dev);
+
+	if (net->ipv6.sysctl.fwd_use_pmtu ||
+	    dst_metric_locked(dst, RTAX_MTU))
+		return dst_mtu(dst);
+
+	mtu = IPV6_MIN_MTU;
+	rcu_read_lock();
+	idev = __in6_dev_get(dst->dev);
+	if (idev)
+		mtu = idev->cnf.mtu6;
+	rcu_read_unlock();
+
+	return mtu;
+}
+
+static inline unsigned int ip6_skb_dst_mtu(struct sk_buff *skb)
 {
 	struct ipv6_pinfo *np = skb->sk ? inet6_sk(skb->sk) : NULL;
 
-	return (np && np->pmtudisc >= IPV6_PMTUDISC_PROBE) ?
-	       skb_dst(skb)->dev->mtu : dst_mtu(skb_dst(skb));
+	if (np && np->pmtudisc >= IPV6_PMTUDISC_PROBE) {
+		return skb_dst(skb)->dev->mtu;
+	} else {
+		bool forward = !!(IP6CB(skb)->flags & IP6SKB_FORWARDED);
+		return ip6_dst_mtu_secure(skb_dst(skb), forward);
+	}
 }
 
 static inline bool ip6_sk_accept_pmtu(const struct sock *sk)
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index d0bfe3e..34e11db 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -684,6 +684,38 @@ static inline __be32 ip6_flowlabel(const struct ipv6hdr *hdr)
 	return *(__be32 *)hdr & IPV6_FLOWLABEL_MASK;
 }
 
+/**
+ * __in6_dev_get - get inet6_dev pointer from netdevice
+ * @dev: network device
+ *
+ * Caller must hold rcu_read_lock or RTNL, because this function
+ * does not take a reference on the inet6_dev.
+ */
+static inline struct inet6_dev *__in6_dev_get(const struct net_device *dev)
+{
+	return rcu_dereference_rtnl(dev->ip6_ptr);
+}
+
+/**
+ * in6_dev_get - get inet6_dev pointer from netdevice
+ * @dev: network device
+ *
+ * This version can be used in any context, and takes a reference
+ * on the inet6_dev. Callers must use in6_dev_put() later to
+ * release this reference.
+ */
+static inline struct inet6_dev *in6_dev_get(const struct net_device *dev)
+{
+	struct inet6_dev *idev;
+
+	rcu_read_lock();
+	idev = rcu_dereference(dev->ip6_ptr);
+	if (idev)
+		atomic_inc(&idev->refcnt);
+	rcu_read_unlock();
+	return idev;
+}
+
 /*
  *	Prototypes exported by ipv6
  */
diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index 0fb2401..05fef12 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -19,6 +19,7 @@ struct netns_sysctl_ipv6 {
 	struct ctl_table_header *xfrm6_hdr;
 #endif
 	int bindv6only;
+	int fwd_use_pmtu;
 	int flush_delay;
 	int ip6_rt_max_size;
 	int ip6_rt_gc_min_interval;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index bc4e1bc..668a567 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -441,7 +441,8 @@ int ip6_forward(struct sk_buff *skb)
 		}
 	}
 
-	mtu = dst_mtu(dst);
+	IP6CB(skb)->flags |= IP6SKB_FORWARDED;
+	mtu = ip6_dst_mtu_secure(dst, true);
 	if (mtu < IPV6_MIN_MTU)
 		mtu = IPV6_MIN_MTU;
 
diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index 107b2f1..ac0e838 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -24,6 +24,13 @@ static struct ctl_table ipv6_table_template[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "forward_use_pmtu",
+		.data		= &init_net.ipv6.sysctl.fwd_use_pmtu,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 	{ }
 };
 
@@ -51,6 +58,7 @@ static int __net_init ipv6_sysctl_net_init(struct net *net)
 	if (!ipv6_table)
 		goto out;
 	ipv6_table[0].data = &net->ipv6.sysctl.bindv6only;
+	ipv6_table[1].data = &net->ipv6.sysctl.fwd_use_pmtu;
 
 	ipv6_route_table = ipv6_route_sysctl_init(net);
 	if (!ipv6_route_table)
-- 
1.8.3.1
