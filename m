From: David L Stevens <dlstevens@us.ibm.com>
Subject: [PATCHv2] fragment locally-generated IPsec6 packets that need it
Date: Tue, 14 Dec 2010 10:32:34 -0800
Message-ID: <1292351554.4720.7.camel@IBM-1B506CFC885>
Mime-Version: 1.0
Content-Type: text/plain; charset="cp1252"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:41046 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756304Ab0LNSco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Dec 2010 13:32:44 -0500
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e31.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id oBEIJ129001812
	for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 11:19:01 -0700
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oBEIWdTn157336
	for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 11:32:39 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oBEIWcHm032057
	for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 11:32:39 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch modifies IPsec6 to fragment IPv6 packets that are
locally generated as needed.

Signed-off-by: David L Stevens <dlstevens@us.ibm.com>

diff -ruNp linux-2.6.36-rc8/include/net/ip6_route.h linux-2.6.36-rc8DLS/include/net/ip6_route.h
--- linux-2.6.36-rc8/include/net/ip6_route.h	2010-10-14 16:26:43.000000000 -0700
+++ linux-2.6.36-rc8DLS/include/net/ip6_route.h	2010-12-12 09:22:48.582141401 -0800
@@ -164,5 +164,15 @@ static inline int ipv6_unicast_destinati
 	return rt->rt6i_flags & RTF_LOCAL;
 }
 
+int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *));
+
+static inline int ip6_skb_dst_mtu(struct sk_buff *skb)
+{
+	struct ipv6_pinfo *np = skb->sk ? inet6_sk(skb->sk) : NULL;
+
+	return (np && np->pmtudisc == IPV6_PMTUDISC_PROBE) ?
+	       skb_dst(skb)->dev->mtu : dst_mtu(skb_dst(skb));
+}
+
 #endif
 #endif
diff -ruNp linux-2.6.36-rc8/net/ipv6/ip6_output.c linux-2.6.36-rc8DLS/net/ipv6/ip6_output.c
--- linux-2.6.36-rc8/net/ipv6/ip6_output.c	2010-10-14 16:26:43.000000000 -0700
+++ linux-2.6.36-rc8DLS/net/ipv6/ip6_output.c	2010-12-14 09:51:45.260779308 -0800
@@ -56,7 +56,7 @@
 #include <net/checksum.h>
 #include <linux/mroute6.h>
 
-static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *));
+int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *));
 
 int __ip6_local_out(struct sk_buff *skb)
 {
@@ -145,14 +145,6 @@ static int ip6_finish_output2(struct sk_
 	return -EINVAL;
 }
 
-static inline int ip6_skb_dst_mtu(struct sk_buff *skb)
-{
-	struct ipv6_pinfo *np = skb->sk ? inet6_sk(skb->sk) : NULL;
-
-	return (np && np->pmtudisc == IPV6_PMTUDISC_PROBE) ?
-	       skb_dst(skb)->dev->mtu : dst_mtu(skb_dst(skb));
-}
-
 static int ip6_finish_output(struct sk_buff *skb)
 {
 	if ((skb->len > ip6_skb_dst_mtu(skb) && !skb_is_gso(skb)) ||
@@ -601,7 +593,7 @@ int ip6_find_1stfragopt(struct sk_buff *
 	return offset;
 }
 
-static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
+int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 {
 	struct sk_buff *frag;
 	struct rt6_info *rt = (struct rt6_info*)skb_dst(skb);
diff -ruNp linux-2.6.36-rc8/net/ipv6/xfrm6_output.c linux-2.6.36-rc8DLS/net/ipv6/xfrm6_output.c
--- linux-2.6.36-rc8/net/ipv6/xfrm6_output.c	2010-10-14 16:26:43.000000000 -0700
+++ linux-2.6.36-rc8DLS/net/ipv6/xfrm6_output.c	2010-12-12 09:30:21.019560623 -0800
@@ -17,6 +17,7 @@
 #include <linux/netfilter_ipv6.h>
 #include <net/dst.h>
 #include <net/ipv6.h>
+#include <net/ip6_route.h>
 #include <net/xfrm.h>
 
 int xfrm6_find_1stfragopt(struct xfrm_state *x, struct sk_buff *skb,
@@ -88,8 +89,17 @@ static int xfrm6_output_finish(struct sk
 	return xfrm_output(skb);
 }
 
-int xfrm6_output(struct sk_buff *skb)
+static int __xfrm6_output(struct sk_buff *skb)
 {
 	return NF_HOOK(NFPROTO_IPV6, NF_INET_POST_ROUTING, skb, NULL,
 		       skb_dst(skb)->dev, xfrm6_output_finish);
 }
+
+int xfrm6_output(struct sk_buff *skb)
+{
+	if ((skb->len > ip6_skb_dst_mtu(skb) && !skb_is_gso(skb)) ||
+		dst_allfrag(skb_dst(skb))) {
+			return ip6_fragment(skb, __xfrm6_output);
+	}
+	return __xfrm6_output(skb);
+}



