From: Fan Du <fan.du@windriver.com>
Subject: [RFC PATCH net-next V2] net: split rt_genid for ipv4 and ipv6
Date: Tue, 23 Jul 2013 09:37:00 +0800
Message-ID: <1374543420-12657-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>, <nicolas.dichtel@6wind.com>,
	<yoshfuji@linux-ipv6.org>, <jmorris@namei.org>,
	<steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49405 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753320Ab3GWBhH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 21:37:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current net name space has only one genid for both IPv4 and IPv6, it has below drawbacks:

- Add/delete an IPv4 address will invalidate all IPv6 routing table entries.
- Insert/remove XFRM policy will also invalidate both IPv4/IPv6 routing table entries
  even when the policy is only applied for one address family.

Thus, this patch attempt to split one genid for two to cater for IPv4 and IPv6 separately
in a fine granularity.

Signed-off-by: Fan Du <fan.du@windriver.com>

V2:
 -Fix compile issue when IPv6 not enabled
 -Put genid into struct netns_ipv4/ipv6
---
 include/net/net_namespace.h |   39 ++++++++++++++++++++++++++++++++++-----
 include/net/netns/ipv4.h    |    1 +
 include/net/netns/ipv6.h    |    1 +
 net/ipv4/route.c            |   16 ++++++++--------
 net/ipv6/af_inet6.c         |    1 +
 net/ipv6/route.c            |    4 ++--
 net/xfrm/xfrm_policy.c      |    8 +++++++-
 7 files changed, 54 insertions(+), 16 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 84e37b1..763e63f 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -119,7 +119,6 @@ struct net {
 	struct netns_ipvs	*ipvs;
 #endif
 	struct sock		*diag_nlsk;
-	atomic_t		rt_genid;
 	atomic_t		fnhe_genid;
 };
 
@@ -333,14 +332,44 @@ static inline void unregister_net_sysctl_table(struct ctl_table_header *header)
 }
 #endif
 
-static inline int rt_genid(struct net *net)
+static inline int rt_genid_ipv4(struct net *net)
 {
-	return atomic_read(&net->rt_genid);
+	return atomic_read(&net->ipv4.rt_genid_ipv4);
 }
 
-static inline void rt_genid_bump(struct net *net)
+static inline void rt_genid_bump_ipv4(struct net *net)
 {
-	atomic_inc(&net->rt_genid);
+	atomic_inc(&net->ipv4.rt_genid_ipv4);
+}
+
+#if IS_ENABLED(CONFIG_IPV6)
+static inline int rt_genid_ipv6(struct net *net)
+{
+	return atomic_read(&net->ipv6.rt_genid_ipv6);
+}
+
+static inline void rt_genid_bump_ipv6(struct net *net)
+{
+	atomic_inc(&net->ipv6.rt_genid_ipv6);
+}
+#else
+static inline int rt_genid_ipv6(struct net *net)
+{
+	return 0;
+}
+
+static inline void rt_genid_bump_ipv6(struct net *net)
+{
+}
+#endif
+
+/* For callers who don't really care about whether it's IPv4 or IPv6 */
+static inline void rt_genid_bump_all(struct net *net)
+{
+	atomic_inc(&net->ipv4.rt_genid_ipv4);
+#if IS_ENABLED(CONFIG_IPV6)
+	atomic_inc(&net->ipv6.rt_genid_ipv6);
+#endif
 }
 
 static inline int fnhe_genid(struct net *net)
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 2ba9de8..d87af01 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -77,5 +77,6 @@ struct netns_ipv4 {
 	struct fib_rules_ops	*mr_rules_ops;
 #endif
 #endif
+	atomic_t	rt_genid_ipv4;
 };
 #endif
diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index 005e2c2..1dfe2dcb 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -72,6 +72,7 @@ struct netns_ipv6 {
 #endif
 #endif
 	atomic_t		dev_addr_genid;
+	atomic_t		rt_genid_ipv6;
 };
 
 #if IS_ENABLED(CONFIG_NF_DEFRAG_IPV6)
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index a9a54a2..ff78925 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -435,12 +435,12 @@ static inline int ip_rt_proc_init(void)
 
 static inline bool rt_is_expired(const struct rtable *rth)
 {
-	return rth->rt_genid != rt_genid(dev_net(rth->dst.dev));
+	return rth->rt_genid != rt_genid_ipv4(dev_net(rth->dst.dev));
 }
 
 void rt_cache_flush(struct net *net)
 {
-	rt_genid_bump(net);
+	rt_genid_bump_ipv4(net);
 }
 
 static struct neighbour *ipv4_neigh_lookup(const struct dst_entry *dst,
@@ -1458,7 +1458,7 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 #endif
 	rth->dst.output = ip_rt_bug;
 
-	rth->rt_genid	= rt_genid(dev_net(dev));
+	rth->rt_genid	= rt_genid_ipv4(dev_net(dev));
 	rth->rt_flags	= RTCF_MULTICAST;
 	rth->rt_type	= RTN_MULTICAST;
 	rth->rt_is_input= 1;
@@ -1589,7 +1589,7 @@ static int __mkroute_input(struct sk_buff *skb,
 		goto cleanup;
 	}
 
-	rth->rt_genid = rt_genid(dev_net(rth->dst.dev));
+	rth->rt_genid = rt_genid_ipv4(dev_net(rth->dst.dev));
 	rth->rt_flags = flags;
 	rth->rt_type = res->type;
 	rth->rt_is_input = 1;
@@ -1760,7 +1760,7 @@ local_input:
 	rth->dst.tclassid = itag;
 #endif
 
-	rth->rt_genid = rt_genid(net);
+	rth->rt_genid = rt_genid_ipv4(net);
 	rth->rt_flags 	= flags|RTCF_LOCAL;
 	rth->rt_type	= res.type;
 	rth->rt_is_input = 1;
@@ -1945,7 +1945,7 @@ add:
 
 	rth->dst.output = ip_output;
 
-	rth->rt_genid = rt_genid(dev_net(dev_out));
+	rth->rt_genid = rt_genid_ipv4(dev_net(dev_out));
 	rth->rt_flags	= flags;
 	rth->rt_type	= type;
 	rth->rt_is_input = 0;
@@ -2227,7 +2227,7 @@ struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_or
 		rt->rt_iif = ort->rt_iif;
 		rt->rt_pmtu = ort->rt_pmtu;
 
-		rt->rt_genid = rt_genid(net);
+		rt->rt_genid = rt_genid_ipv4(net);
 		rt->rt_flags = ort->rt_flags;
 		rt->rt_type = ort->rt_type;
 		rt->rt_gateway = ort->rt_gateway;
@@ -2665,7 +2665,7 @@ static __net_initdata struct pernet_operations sysctl_route_ops = {
 
 static __net_init int rt_genid_init(struct net *net)
 {
-	atomic_set(&net->rt_genid, 0);
+	atomic_set(&net->ipv4.rt_genid_ipv4, 0);
 	atomic_set(&net->fnhe_genid, 0);
 	get_random_bytes(&net->ipv4.dev_addr_genid,
 			 sizeof(net->ipv4.dev_addr_genid));
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index a5ac969..df26399 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -766,6 +766,7 @@ static int __net_init inet6_net_init(struct net *net)
 
 	net->ipv6.sysctl.bindv6only = 0;
 	net->ipv6.sysctl.icmpv6_time = 1*HZ;
+	atomic_set(&net->ipv6.rt_genid_ipv6, 0);
 
 	err = ipv6_init_mibs(net);
 	if (err)
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index a8c891a..45ca9af 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -283,7 +283,7 @@ static inline struct rt6_info *ip6_dst_alloc(struct net *net,
 
 		memset(dst + 1, 0, sizeof(*rt) - sizeof(*dst));
 		rt6_init_peer(rt, table ? &table->tb6_peers : net->ipv6.peers);
-		rt->rt6i_genid = rt_genid(net);
+		rt->rt6i_genid = rt_genid_ipv6(net);
 		INIT_LIST_HEAD(&rt->rt6i_siblings);
 		rt->rt6i_nsiblings = 0;
 	}
@@ -1062,7 +1062,7 @@ static struct dst_entry *ip6_dst_check(struct dst_entry *dst, u32 cookie)
 	 * DST_OBSOLETE_FORCE_CHK which forces validation calls down
 	 * into this function always.
 	 */
-	if (rt->rt6i_genid != rt_genid(dev_net(rt->dst.dev)))
+	if (rt->rt6i_genid != rt_genid_ipv6(dev_net(rt->dst.dev)))
 		return NULL;
 
 	if (rt->rt6i_node && (rt->rt6i_node->fn_sernum == cookie))
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index e52cab3..dbd36e0 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -660,7 +660,13 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 	xfrm_pol_hold(policy);
 	net->xfrm.policy_count[dir]++;
 	atomic_inc(&flow_cache_genid);
-	rt_genid_bump(net);
+
+	/* After previous checking, family can either be AF_INET or AF_INET6 */
+	if (policy->family == AF_INET)
+		rt_genid_bump_ipv4(net);
+	else
+		rt_genid_bump_ipv6(net);
+
 	if (delpol) {
 		xfrm_policy_requeue(delpol, policy);
 		__xfrm_policy_unlink(delpol, dir);
-- 
1.7.9.5
