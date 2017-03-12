From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next RFC v1 18/27] afnetns: afnetns should influence source address selection
Date: Mon, 13 Mar 2017 00:01:42 +0100
Message-ID: <20170312230151.5185-19-hannes@stressinduktion.org>
References: <20170312230151.5185-1-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:51880 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S935651AbdCLXCQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 19:02:16 -0400
Received: from compute7.internal (compute7.nyi.internal [10.202.2.47])
        by mailout.nyi.internal (Postfix) with ESMTP id 8A4DA20685
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:02:10 -0400 (EDT)
Received: from m.localhost.localhost (unknown [213.55.211.72])
        by mail.messagingengine.com (Postfix) with ESMTPA id 87172240CF
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:02:09 -0400 (EDT)
In-Reply-To: <20170312230151.5185-1-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/target/iscsi/cxgbit/cxgbit_cm.c |  2 +-
 include/linux/inetdevice.h              |  5 +++--
 include/net/route.h                     | 10 ++++++----
 net/ipv4/devinet.c                      | 19 ++++++++++++++++---
 net/ipv4/icmp.c                         |  4 ++--
 net/ipv4/igmp.c                         |  2 +-
 net/ipv4/route.c                        | 21 ++++++++++++---------
 net/ipv4/xfrm4_policy.c                 |  2 +-
 net/sctp/protocol.c                     |  4 ++--
 net/tipc/udp_media.c                    |  2 +-
 10 files changed, 45 insertions(+), 26 deletions(-)

diff --git a/drivers/target/iscsi/cxgbit/cxgbit_cm.c b/drivers/target/iscsi/cxgbit/cxgbit_cm.c
index 37a05185dcbe0e..4ae59d20d8e260 100644
--- a/drivers/target/iscsi/cxgbit/cxgbit_cm.c
+++ b/drivers/target/iscsi/cxgbit/cxgbit_cm.c
@@ -266,7 +266,7 @@ static struct net_device *cxgbit_ipv4_netdev(__be32 saddr)
 {
 	struct net_device *ndev;
 
-	ndev = __ip_dev_find(&init_net, saddr, false);
+	ndev = __ip_dev_find(&init_net, NULL, saddr, false);
 	if (!ndev)
 		return NULL;
 
diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index a41bfce099e0a1..9411270cb0fe64 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -160,10 +160,11 @@ void inet_netconf_notify_devconf(struct net *net, int type, int ifindex,
 				 struct ipv4_devconf *devconf);
 
 struct in_ifaddr *ifa_find_rcu(struct net *net, __be32 addr);
-struct net_device *__ip_dev_find(struct net *net, __be32 addr, bool devref);
+struct net_device *__ip_dev_find(struct net *net, struct afnetns *afnetns,
+				 __be32 addr, bool devref);
 static inline struct net_device *ip_dev_find(struct net *net, __be32 addr)
 {
-	return __ip_dev_find(net, addr, true);
+	return __ip_dev_find(net, NULL, addr, true);
 }
 
 int inet_addr_onlink(struct in_device *in_dev, __be32 a, __be32 b);
diff --git a/include/net/route.h b/include/net/route.h
index c0874c87c17371..d29449d1863636 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -113,13 +113,15 @@ struct in_device;
 int ip_rt_init(void);
 void rt_cache_flush(struct net *net);
 void rt_flush_dev(struct net_device *dev);
-struct rtable *__ip_route_output_key_hash(struct net *, struct flowi4 *flp,
-					  int mp_hash);
+struct rtable *__ip_route_output_key_hash(struct net *net,
+					  struct afnetns *afnetns,
+					  struct flowi4 *flp, int mp_hash);
 
 static inline struct rtable *__ip_route_output_key(struct net *net,
+						   struct afnetns *afnetns,
 						   struct flowi4 *flp)
 {
-	return __ip_route_output_key_hash(net, flp, -1);
+	return __ip_route_output_key_hash(net, afnetns, flp, -1);
 }
 
 struct rtable *ip_route_output_flow(struct net *, struct flowi4 *flp,
@@ -286,7 +288,7 @@ static inline struct rtable *ip_route_connect(struct flowi4 *fl4,
 			      sport, dport, sk);
 
 	if (!dst || !src) {
-		rt = __ip_route_output_key(net, fl4);
+		rt = __ip_route_output_key(net, NULL, fl4);
 		if (IS_ERR(rt))
 			return rt;
 		ip_rt_put(rt);
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 0844d917aa8d7d..82a7389ec86faa 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -150,14 +150,27 @@ struct in_ifaddr *ifa_find_rcu(struct net *net, __be32 addr)
  *
  * If a caller uses devref=false, it should be protected by RCU, or RTNL
  */
-struct net_device *__ip_dev_find(struct net *net, __be32 addr, bool devref)
+struct net_device *__ip_dev_find(struct net *net, struct afnetns *afnetns,
+				 __be32 addr, bool devref)
 {
-	struct net_device *result;
+	struct net_device *result = NULL;
 	struct in_ifaddr *ifa;
 
 	rcu_read_lock();
 	ifa = ifa_find_rcu(net, addr);
-	result = ifa ? ifa->ifa_dev->dev : NULL;
+#if IS_ENABLED(CONFIG_AFNETNS)
+	if (afnetns && afnetns != net->afnet_ns) {
+		/* we are in a child namespace, thus only allow to
+		 * explicitly configured addresses
+		 */
+		if (!ifa || ifa->afnetns != afnetns) {
+			rcu_read_unlock();
+			return NULL;
+		}
+	}
+#endif
+	if (ifa)
+		result = ifa->ifa_dev->dev;
 	if (!result) {
 		struct flowi4 fl4 = { .daddr = addr };
 		struct fib_result res = { 0 };
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index fc310db2708bf6..74261d6b86e4fc 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -505,7 +505,7 @@ static struct rtable *icmp_route_lookup(struct net *net,
 	fl4->flowi4_oif = l3mdev_master_ifindex(skb_dst(skb_in)->dev);
 
 	security_skb_classify_flow(skb_in, flowi4_to_flowi(fl4));
-	rt = __ip_route_output_key_hash(net, fl4,
+	rt = __ip_route_output_key_hash(net, NULL, fl4,
 					icmp_multipath_hash_skb(skb_in));
 	if (IS_ERR(rt))
 		return rt;
@@ -529,7 +529,7 @@ static struct rtable *icmp_route_lookup(struct net *net,
 
 	if (inet_addr_type_dev_table(net, skb_dst(skb_in)->dev,
 				     fl4_dec.saddr) == RTN_LOCAL) {
-		rt2 = __ip_route_output_key(net, &fl4_dec);
+		rt2 = __ip_route_output_key(net, NULL, &fl4_dec);
 		if (IS_ERR(rt2))
 			err = PTR_ERR(rt2);
 	} else {
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 44fd86de2823dd..d246bf1704f4d8 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1754,7 +1754,7 @@ static struct in_device *ip_mc_find_dev(struct net *net, struct ip_mreqn *imr)
 		return idev;
 	}
 	if (imr->imr_address.s_addr) {
-		dev = __ip_dev_find(net, imr->imr_address.s_addr, false);
+		dev = __ip_dev_find(net, NULL, imr->imr_address.s_addr, false);
 		if (!dev)
 			return NULL;
 	}
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 8471dd11677146..f3304647082182 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1045,7 +1045,7 @@ void ipv4_update_pmtu(struct sk_buff *skb, struct net *net, u32 mtu,
 
 	__build_flow_key(net, &fl4, NULL, iph, oif,
 			 RT_TOS(iph->tos), protocol, mark, flow_flags);
-	rt = __ip_route_output_key(net, &fl4);
+	rt = __ip_route_output_key(net, NULL, &fl4);
 	if (!IS_ERR(rt)) {
 		__ip_rt_update_pmtu(rt, &fl4, mtu);
 		ip_rt_put(rt);
@@ -1064,7 +1064,7 @@ static void __ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
 	if (!fl4.flowi4_mark)
 		fl4.flowi4_mark = IP4_REPLY_MARK(sock_net(sk), skb->mark);
 
-	rt = __ip_route_output_key(sock_net(sk), &fl4);
+	rt = __ip_route_output_key(sock_net(sk), NULL, &fl4);
 	if (!IS_ERR(rt)) {
 		__ip_rt_update_pmtu(rt, &fl4, mtu);
 		ip_rt_put(rt);
@@ -1134,7 +1134,7 @@ void ipv4_redirect(struct sk_buff *skb, struct net *net,
 
 	__build_flow_key(net, &fl4, NULL, iph, oif,
 			 RT_TOS(iph->tos), protocol, mark, flow_flags);
-	rt = __ip_route_output_key(net, &fl4);
+	rt = __ip_route_output_key(net, NULL, &fl4);
 	if (!IS_ERR(rt)) {
 		__ip_do_redirect(rt, skb, &fl4, false);
 		ip_rt_put(rt);
@@ -1150,7 +1150,7 @@ void ipv4_sk_redirect(struct sk_buff *skb, struct sock *sk)
 	struct net *net = sock_net(sk);
 
 	__build_flow_key(net, &fl4, sk, iph, 0, 0, 0, 0, 0);
-	rt = __ip_route_output_key(net, &fl4);
+	rt = __ip_route_output_key(net, NULL, &fl4);
 	if (!IS_ERR(rt)) {
 		__ip_do_redirect(rt, skb, &fl4, false);
 		ip_rt_put(rt);
@@ -2202,8 +2202,9 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
  * Major route resolver routine.
  */
 
-struct rtable *__ip_route_output_key_hash(struct net *net, struct flowi4 *fl4,
-					  int mp_hash)
+struct rtable *__ip_route_output_key_hash(struct net *net,
+					  struct afnetns *afnetns,
+					  struct flowi4 *fl4, int mp_hash)
 {
 	struct net_device *dev_out = NULL;
 	__u8 tos = RT_FL_TOS(fl4);
@@ -2244,7 +2245,7 @@ struct rtable *__ip_route_output_key_hash(struct net *net, struct flowi4 *fl4,
 		    (ipv4_is_multicast(fl4->daddr) ||
 		     ipv4_is_lbcast(fl4->daddr))) {
 			/* It is equivalent to inet_addr_type(saddr) == RTN_LOCAL */
-			dev_out = __ip_dev_find(net, fl4->saddr, false);
+			dev_out = __ip_dev_find(net, NULL, fl4->saddr, false);
 			if (!dev_out)
 				goto out;
 
@@ -2269,7 +2270,7 @@ struct rtable *__ip_route_output_key_hash(struct net *net, struct flowi4 *fl4,
 
 		if (!(fl4->flowi4_flags & FLOWI_FLAG_ANYSRC)) {
 			/* It is equivalent to inet_addr_type(saddr) == RTN_LOCAL */
-			if (!__ip_dev_find(net, fl4->saddr, false))
+			if (!__ip_dev_find(net, afnetns, fl4->saddr, false))
 				goto out;
 		}
 	}
@@ -2458,7 +2459,9 @@ struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_or
 struct rtable *ip_route_output_flow(struct net *net, struct flowi4 *flp4,
 				    const struct sock *sk)
 {
-	struct rtable *rt = __ip_route_output_key(net, flp4);
+	struct rtable *rt;
+
+	rt = __ip_route_output_key(net, sk ? sock_afnetns(sk) : NULL, flp4);
 
 	if (IS_ERR(rt))
 		return rt;
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 71b4ecc195c707..c8d9eaa59be8fc 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -33,7 +33,7 @@ static struct dst_entry *__xfrm4_dst_lookup(struct net *net, struct flowi4 *fl4,
 
 	fl4->flowi4_flags = FLOWI_FLAG_SKIP_NH_OIF;
 
-	rt = __ip_route_output_key(net, fl4);
+	rt = __ip_route_output_key(net, NULL, fl4);
 	if (!IS_ERR(rt))
 		return &rt->dst;
 
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 1b6d4574d2b02a..cd77ec87c5f9ef 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -520,8 +520,8 @@ static void sctp_v4_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
 		/* Ensure the src address belongs to the output
 		 * interface.
 		 */
-		odev = __ip_dev_find(sock_net(sk), laddr->a.v4.sin_addr.s_addr,
-				     false);
+		odev = __ip_dev_find(sock_net(sk), NULL,
+				     laddr->a.v4.sin_addr.s_addr, false);
 		if (!odev || odev->ifindex != fl4->flowi4_oif) {
 			if (&rt->dst != dst)
 				dst_release(&rt->dst);
diff --git a/net/tipc/udp_media.c b/net/tipc/udp_media.c
index 46061cf48cd135..98bc29e63058a2 100644
--- a/net/tipc/udp_media.c
+++ b/net/tipc/udp_media.c
@@ -688,7 +688,7 @@ static int tipc_udp_enable(struct net *net, struct tipc_bearer *b,
 	if (local.proto == htons(ETH_P_IP)) {
 		struct net_device *dev;
 
-		dev = __ip_dev_find(net, local.ipv4.s_addr, false);
+		dev = __ip_dev_find(net, NULL, local.ipv4.s_addr, false);
 		if (!dev) {
 			err = -ENODEV;
 			goto err;
-- 
2.9.3
