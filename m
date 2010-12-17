From: David L Stevens <dlstevens@us.ibm.com>
Subject: [PATCHv4] fragment locally generated tunnel-mode IPSec6 packets as
 needed
Date: Fri, 17 Dec 2010 13:42:42 -0800
Message-ID: <1292622162.1700.3.camel@IBM-1B506CFC885>
Mime-Version: 1.0
Content-Type: text/plain; charset="cp1252"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:48972 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754817Ab0LQVmx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Dec 2010 16:42:53 -0500
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e35.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id oBHLUDwd006699
	for <netdev@vger.kernel.org>; Fri, 17 Dec 2010 14:30:13 -0700
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oBHLgmTC141748
	for <netdev@vger.kernel.org>; Fri, 17 Dec 2010 14:42:48 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oBHLglvG030514
	for <netdev@vger.kernel.org>; Fri, 17 Dec 2010 14:42:48 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch modifies IPsec6 to fragment IPv6 packets that are
locally generated as needed.

This version of the patch only fragments in tunnel mode, so that fragment
headers will not be obscured by ESP in transport mode.

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
+++ linux-2.6.36-rc8DLS/net/ipv6/xfrm6_output.c	2010-12-17 09:28:40.426989866 -0800
@@ -17,6 +17,7 @@
 #include <linux/netfilter_ipv6.h>
 #include <net/dst.h>
 #include <net/ipv6.h>
+#include <net/ip6_route.h>
 #include <net/xfrm.h>
 
 int xfrm6_find_1stfragopt(struct xfrm_state *x, struct sk_buff *skb,
@@ -88,8 +89,21 @@ static int xfrm6_output_finish(struct sk
 	return xfrm_output(skb);
 }
 
+static int __xfrm6_output(struct sk_buff *skb)
+{
+	struct dst_entry *dst = skb_dst(skb);
+	struct xfrm_state *x = dst->xfrm;
+
+	if ((x && x->props.mode == XFRM_MODE_TUNNEL) &&
+	    ((skb->len > ip6_skb_dst_mtu(skb) && !skb_is_gso(skb)) ||
+		dst_allfrag(skb_dst(skb)))) {
+			return ip6_fragment(skb, xfrm6_output_finish);
+	}
+	return xfrm6_output_finish(skb);
+}
+
 int xfrm6_output(struct sk_buff *skb)
 {
 	return NF_HOOK(NFPROTO_IPV6, NF_INET_POST_ROUTING, skb, NULL,
-		       skb_dst(skb)->dev, xfrm6_output_finish);
+		       skb_dst(skb)->dev, __xfrm6_output);
 }



