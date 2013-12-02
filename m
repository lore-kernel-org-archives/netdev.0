From: Kamala R <kamala@aristanetworks.com>
Subject: [Patch v4] IPv6: Fixed support for blackhole and prohibit routes
Date: Mon,  2 Dec 2013 19:55:21 +0530
Message-ID: <1385994322-23117-1-git-send-email-kamala@aristanetworks.com>
Cc: linux-kernel@vger.kernel.org, Kamala R <kamala@aristanetworks.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The behaviour of blackhole and prohibit routes has been corrected by setting
the input and output pointers of the dst variable appropriately. For
blackhole routes, they are set to dst_discard and to ip6_pkt_discard and
ip6_pkt_discard_out respectively for prohibit routes.

ipv6: ip6_pkt_prohibit(_out) should not depend on
CONFIG_IPV6_MULTIPLE_TABLES

We need ip6_pkt_prohibit(_out) available without
CONFIG_IPV6_MULTIPLE_TABLES

Signed-off-by: Kamala R <kamala@aristanetworks.com>
---
 net/ipv6/route.c |   22 ++++++++++------------
 1 file changed, 10 insertions(+), 12 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 7faa9d5..ddb9d41 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -84,6 +84,8 @@ static int		 ip6_dst_gc(struct dst_ops *ops);
 
 static int		ip6_pkt_discard(struct sk_buff *skb);
 static int		ip6_pkt_discard_out(struct sk_buff *skb);
+static int		ip6_pkt_prohibit(struct sk_buff *skb);
+static int		ip6_pkt_prohibit_out(struct sk_buff *skb);
 static void		ip6_link_failure(struct sk_buff *skb);
 static void		ip6_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
 					   struct sk_buff *skb, u32 mtu);
@@ -234,9 +236,6 @@ static const struct rt6_info ip6_null_entry_template = {
 
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 
-static int ip6_pkt_prohibit(struct sk_buff *skb);
-static int ip6_pkt_prohibit_out(struct sk_buff *skb);
-
 static const struct rt6_info ip6_prohibit_entry_template = {
 	.dst = {
 		.__refcnt	= ATOMIC_INIT(1),
@@ -1565,21 +1564,24 @@ int ip6_route_add(struct fib6_config *cfg)
 				goto out;
 			}
 		}
-		rt->dst.output = ip6_pkt_discard_out;
-		rt->dst.input = ip6_pkt_discard;
 		rt->rt6i_flags = RTF_REJECT|RTF_NONEXTHOP;
 		switch (cfg->fc_type) {
 		case RTN_BLACKHOLE:
 			rt->dst.error = -EINVAL;
+			rt->dst.output = dst_discard;
+			rt->dst.input = dst_discard;
 			break;
 		case RTN_PROHIBIT:
 			rt->dst.error = -EACCES;
+			rt->dst.output = ip6_pkt_prohibit_out;
+			rt->dst.input = ip6_pkt_prohibit;
 			break;
 		case RTN_THROW:
-			rt->dst.error = -EAGAIN;
-			break;
 		default:
-			rt->dst.error = -ENETUNREACH;
+			rt->dst.error = (cfg->fc_type == RTN_THROW) ? -EAGAIN
+					: -ENETUNREACH;
+			rt->dst.output = ip6_pkt_discard_out;
+			rt->dst.input = ip6_pkt_discard;
 			break;
 		}
 		goto install_route;
@@ -2144,8 +2146,6 @@ static int ip6_pkt_discard_out(struct sk_buff *skb)
 	return ip6_pkt_drop(skb, ICMPV6_NOROUTE, IPSTATS_MIB_OUTNOROUTES);
 }
 
-#ifdef CONFIG_IPV6_MULTIPLE_TABLES
-
 static int ip6_pkt_prohibit(struct sk_buff *skb)
 {
 	return ip6_pkt_drop(skb, ICMPV6_ADM_PROHIBITED, IPSTATS_MIB_INNOROUTES);
@@ -2157,8 +2157,6 @@ static int ip6_pkt_prohibit_out(struct sk_buff *skb)
 	return ip6_pkt_drop(skb, ICMPV6_ADM_PROHIBITED, IPSTATS_MIB_OUTNOROUTES);
 }
 
-#endif
-
 /*
  *	Allocate a dst for local (unicast / anycast) address.
  */
-- 
1.7.9.5
