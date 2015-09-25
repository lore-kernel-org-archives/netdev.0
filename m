From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 04/11] net: Replace vrf_master_ifindex{,_rcu} with l3mdev equivalents
Date: Thu, 24 Sep 2015 18:21:00 -0600
Message-ID: <1443140467-69297-5-git-send-email-dsa@cumulusnetworks.com>
References: <1443140467-69297-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33106 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752854AbbIYAVU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 20:21:20 -0400
Received: by pacex6 with SMTP id ex6so87395260pac.0
        for <netdev@vger.kernel.org>; Thu, 24 Sep 2015 17:21:20 -0700 (PDT)
In-Reply-To: <1443140467-69297-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace calls to vrf_master_ifindex_rcu and vrf_master_ifindex with either
l3mdev_master_ifindex_rcu or l3mdev_master_ifindex.

The pattern:
    oif = vrf_master_ifindex(dev) ? : dev->ifindex;
is replaced with
    oif = l3mdev_fib_oif(dev);

And remove the now unused vrf macros.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/vrf.h       | 41 -----------------------------------------
 net/ipv4/fib_frontend.c |  5 +++--
 net/ipv4/icmp.c         |  8 ++++----
 net/ipv4/ip_fragment.c  |  6 +++---
 net/ipv4/route.c        |  7 ++++---
 net/ipv4/xfrm4_policy.c |  8 +++-----
 net/ipv6/xfrm6_policy.c |  8 +++-----
 7 files changed, 20 insertions(+), 63 deletions(-)

diff --git a/include/net/vrf.h b/include/net/vrf.h
index 34bb3f69def2..874a6c9e4217 100644
--- a/include/net/vrf.h
+++ b/include/net/vrf.h
@@ -34,37 +34,6 @@ struct net_vrf {
 
 
 #if IS_ENABLED(CONFIG_NET_VRF)
-/* called with rcu_read_lock() */
-static inline int vrf_master_ifindex_rcu(const struct net_device *dev)
-{
-	struct net_vrf_dev *vrf_ptr;
-	int ifindex = 0;
-
-	if (!dev)
-		return 0;
-
-	if (netif_is_l3_master(dev)) {
-		ifindex = dev->ifindex;
-	} else {
-		vrf_ptr = rcu_dereference(dev->vrf_ptr);
-		if (vrf_ptr)
-			ifindex = vrf_ptr->ifindex;
-	}
-
-	return ifindex;
-}
-
-static inline int vrf_master_ifindex(const struct net_device *dev)
-{
-	int ifindex;
-
-	rcu_read_lock();
-	ifindex = vrf_master_ifindex_rcu(dev);
-	rcu_read_unlock();
-
-	return ifindex;
-}
-
 /* called with rcu_read_lock */
 static inline u32 vrf_dev_table_rcu(const struct net_device *dev)
 {
@@ -139,16 +108,6 @@ static inline struct rtable *vrf_dev_get_rth(const struct net_device *dev)
 }
 
 #else
-static inline int vrf_master_ifindex_rcu(const struct net_device *dev)
-{
-	return 0;
-}
-
-static inline int vrf_master_ifindex(const struct net_device *dev)
-{
-	return 0;
-}
-
 static inline u32 vrf_dev_table_rcu(const struct net_device *dev)
 {
 	return 0;
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 6fcbd215cdbc..b901b344f22d 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -46,6 +46,7 @@
 #include <net/rtnetlink.h>
 #include <net/xfrm.h>
 #include <net/vrf.h>
+#include <net/l3mdev.h>
 #include <trace/events/fib.h>
 
 #ifndef CONFIG_IP_MULTIPLE_TABLES
@@ -332,7 +333,7 @@ static int __fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 	bool dev_match;
 
 	fl4.flowi4_oif = 0;
-	fl4.flowi4_iif = vrf_master_ifindex_rcu(dev);
+	fl4.flowi4_iif = l3mdev_master_ifindex_rcu(dev);
 	if (!fl4.flowi4_iif)
 		fl4.flowi4_iif = oif ? : LOOPBACK_IFINDEX;
 	fl4.daddr = src;
@@ -366,7 +367,7 @@ static int __fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 		if (nh->nh_dev == dev) {
 			dev_match = true;
 			break;
-		} else if (vrf_master_ifindex_rcu(nh->nh_dev) == dev->ifindex) {
+		} else if (l3mdev_master_ifindex_rcu(nh->nh_dev) == dev->ifindex) {
 			dev_match = true;
 			break;
 		}
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 79fe05befcae..6b96dee2800b 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -96,7 +96,7 @@
 #include <net/xfrm.h>
 #include <net/inet_common.h>
 #include <net/ip_fib.h>
-#include <net/vrf.h>
+#include <net/l3mdev.h>
 
 /*
  *	Build xmit assembly blocks
@@ -309,7 +309,7 @@ static bool icmpv4_xrlim_allow(struct net *net, struct rtable *rt,
 
 	rc = false;
 	if (icmp_global_allow()) {
-		int vif = vrf_master_ifindex(dst->dev);
+		int vif = l3mdev_master_ifindex(dst->dev);
 		struct inet_peer *peer;
 
 		peer = inet_getpeer_v4(net->ipv4.peers, fl4->daddr, vif, 1);
@@ -427,7 +427,7 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 	fl4.flowi4_mark = mark;
 	fl4.flowi4_tos = RT_TOS(ip_hdr(skb)->tos);
 	fl4.flowi4_proto = IPPROTO_ICMP;
-	fl4.flowi4_oif = vrf_master_ifindex(skb->dev) ? : skb->dev->ifindex;
+	fl4.flowi4_oif = l3mdev_master_ifindex(skb->dev);
 	security_skb_classify_flow(skb, flowi4_to_flowi(&fl4));
 	rt = ip_route_output_key(net, &fl4);
 	if (IS_ERR(rt))
@@ -461,7 +461,7 @@ static struct rtable *icmp_route_lookup(struct net *net,
 	fl4->flowi4_proto = IPPROTO_ICMP;
 	fl4->fl4_icmp_type = type;
 	fl4->fl4_icmp_code = code;
-	fl4->flowi4_oif = vrf_master_ifindex(skb_in->dev) ? : skb_in->dev->ifindex;
+	fl4->flowi4_oif = l3mdev_master_ifindex(skb_in->dev);
 
 	security_skb_classify_flow(skb_in, flowi4_to_flowi(fl4));
 	rt = __ip_route_output_key(net, fl4);
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index fa7f15305f9a..9772b789adf3 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -48,7 +48,7 @@
 #include <linux/inet.h>
 #include <linux/netfilter_ipv4.h>
 #include <net/inet_ecn.h>
-#include <net/vrf.h>
+#include <net/l3mdev.h>
 
 /* NOTE. Logic of IP defragmentation is parallel to corresponding IPv6
  * code now. If you change something here, _PLEASE_ update ipv6/reassembly.c
@@ -78,7 +78,7 @@ struct ipq {
 	u8		ecn; /* RFC3168 support */
 	u16		max_df_size; /* largest frag with DF set seen */
 	int             iif;
-	int             vif;   /* VRF device index */
+	int             vif;   /* L3 master device index */
 	unsigned int    rid;
 	struct inet_peer *peer;
 };
@@ -657,7 +657,7 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 int ip_defrag(struct sk_buff *skb, u32 user)
 {
 	struct net_device *dev = skb->dev ? : skb_dst(skb)->dev;
-	int vif = vrf_master_ifindex_rcu(dev);
+	int vif = l3mdev_master_ifindex_rcu(dev);
 	struct net *net = dev_net(dev);
 	struct ipq *qp;
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 163bb955fdc5..90cf915c36d9 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -113,6 +113,7 @@
 #include <net/secure_seq.h>
 #include <net/ip_tunnels.h>
 #include <net/vrf.h>
+#include <net/l3mdev.h>
 
 #define RT_FL_TOS(oldflp4) \
 	((oldflp4)->flowi4_tos & (IPTOS_RT_MASK | RTO_ONLINK))
@@ -847,7 +848,7 @@ void ip_rt_send_redirect(struct sk_buff *skb)
 		return;
 	}
 	log_martians = IN_DEV_LOG_MARTIANS(in_dev);
-	vif = vrf_master_ifindex_rcu(rt->dst.dev);
+	vif = l3mdev_master_ifindex_rcu(rt->dst.dev);
 	rcu_read_unlock();
 
 	net = dev_net(rt->dst.dev);
@@ -941,7 +942,7 @@ static int ip_error(struct sk_buff *skb)
 	}
 
 	peer = inet_getpeer_v4(net->ipv4.peers, ip_hdr(skb)->saddr,
-			       vrf_master_ifindex(skb->dev), 1);
+			       l3mdev_master_ifindex(skb->dev), 1);
 
 	send = true;
 	if (peer) {
@@ -1740,7 +1741,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	 *	Now we are ready to route packet.
 	 */
 	fl4.flowi4_oif = 0;
-	fl4.flowi4_iif = vrf_master_ifindex_rcu(dev) ? : dev->ifindex;
+	fl4.flowi4_iif = l3mdev_fib_oif_rcu(dev);
 	fl4.flowi4_mark = skb->mark;
 	fl4.flowi4_tos = tos;
 	fl4.flowi4_scope = RT_SCOPE_UNIVERSE;
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 671011055ad5..05fa198c40ed 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -15,7 +15,7 @@
 #include <net/dst.h>
 #include <net/xfrm.h>
 #include <net/ip.h>
-#include <net/vrf.h>
+#include <net/l3mdev.h>
 
 static struct xfrm_policy_afinfo xfrm4_policy_afinfo;
 
@@ -109,10 +109,8 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 	struct flowi4 *fl4 = &fl->u.ip4;
 	int oif = 0;
 
-	if (skb_dst(skb)) {
-		oif = vrf_master_ifindex(skb_dst(skb)->dev) ?
-			: skb_dst(skb)->dev->ifindex;
-	}
+	if (skb_dst(skb))
+		oif = l3mdev_fib_oif(skb_dst(skb)->dev);
 
 	memset(fl4, 0, sizeof(struct flowi4));
 	fl4->flowi4_mark = skb->mark;
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 30caa289c5db..69cee4e0d728 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -20,7 +20,7 @@
 #include <net/ip.h>
 #include <net/ipv6.h>
 #include <net/ip6_route.h>
-#include <net/vrf.h>
+#include <net/l3mdev.h>
 #if IS_ENABLED(CONFIG_IPV6_MIP6)
 #include <net/mip6.h>
 #endif
@@ -132,10 +132,8 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 
 	nexthdr = nh[nhoff];
 
-	if (skb_dst(skb)) {
-		oif = vrf_master_ifindex(skb_dst(skb)->dev) ?
-			: skb_dst(skb)->dev->ifindex;
-	}
+	if (skb_dst(skb))
+		oif = l3mdev_fib_oif(skb_dst(skb)->dev);
 
 	memset(fl6, 0, sizeof(struct flowi6));
 	fl6->flowi6_mark = skb->mark;
-- 
2.3.8 (Apple Git-58)
