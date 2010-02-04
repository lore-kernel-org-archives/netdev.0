From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH] netfilter: Fix a unregister_netdevice hang
Date: Thu, 04 Feb 2010 14:44:47 +0530
Message-ID: <20100204091447.710.97148.sendpatchset@krkumar2.in.ibm.com>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Krishna Kumar <krkumar2@in.ibm.com>, sri@us.ibm.com
To: davem@davemloft.net, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp02.au.ibm.com ([202.81.31.144]:33749 "EHLO
	e23smtp02.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751567Ab0BDJOx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2010 04:14:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>

When using ipv6+netfilter on vlan devices, we were getting
this hang consistantly in an internal distribution:

"unregister_netdevice: waiting for eth0.103 to become free. Usage count = 9"

Sometimes the hang is temporary lasting ~45 secs, and at
other times it is permanent. While fixing the internal bug,
I found the same bug exists in the current kernel.

In ip6_route_me_harder, besides dropping dst, I also moved
the check for dst->error up instead of waiting for the
xfrm_lookup result.

(untested since this bug was not reproducible on my system,
 but this patch fixes the hang on the internal distro bits)

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 net/ipv6/netfilter.c             |   13 +++++++------
 net/ipv6/netfilter/ip6t_REJECT.c |    6 ++++--
 2 files changed, 11 insertions(+), 8 deletions(-)

diff -ruNp org/net/ipv6/netfilter/ip6t_REJECT.c new/net/ipv6/netfilter/ip6t_REJECT.c
--- org/net/ipv6/netfilter/ip6t_REJECT.c	2010-02-04 14:05:26.000000000 +0530
+++ new/net/ipv6/netfilter/ip6t_REJECT.c	2010-02-04 14:23:23.000000000 +0530
@@ -43,7 +43,7 @@ static void send_reset(struct net *net, 
 	int tcphoff, needs_ack;
 	const struct ipv6hdr *oip6h = ipv6_hdr(oldskb);
 	struct ipv6hdr *ip6h;
-	struct dst_entry *dst = NULL;
+	struct dst_entry *dst;
 	u8 proto;
 	struct flowi fl;
 
@@ -97,8 +97,10 @@ static void send_reset(struct net *net, 
 	dst = ip6_route_output(net, NULL, &fl);
 	if (dst == NULL)
 		return;
-	if (dst->error || xfrm_lookup(net, &dst, &fl, NULL, 0))
+	if (dst->error || xfrm_lookup(net, &dst, &fl, NULL, 0)) {
+		dst_release(dst);
 		return;
+	}
 
 	hh_len = (dst->dev->hard_header_len + 15)&~15;
 	nskb = alloc_skb(hh_len + 15 + dst->header_len + sizeof(struct ipv6hdr)
diff -ruNp org/net/ipv6/netfilter.c new/net/ipv6/netfilter.c
--- org/net/ipv6/netfilter.c	2010-02-04 14:05:16.000000000 +0530
+++ new/net/ipv6/netfilter.c	2010-02-04 14:07:16.000000000 +0530
@@ -25,6 +25,12 @@ int ip6_route_me_harder(struct sk_buff *
 	};
 
 	dst = ip6_route_output(net, skb->sk, &fl);
+	if (dst->error) {
+		IP6_INC_STATS(net, ip6_dst_idev(dst), IPSTATS_MIB_OUTNOROUTES);
+		LIMIT_NETDEBUG(KERN_DEBUG "ip6_route_me_harder: No more route.\n");
+		dst_release(dst);
+		return -EINVAL;
+	}
 
 #ifdef CONFIG_XFRM
 	if (!(IP6CB(skb)->flags & IP6SKB_XFRM_TRANSFORMED) &&
@@ -32,6 +38,7 @@ int ip6_route_me_harder(struct sk_buff *
 		struct dst_entry *dst2 = skb_dst(skb);
 
 		if (xfrm_lookup(net, &dst2, &fl, skb->sk, 0)) {
+			dst_release(dst);
 			skb_dst_set(skb, NULL);
 			return -1;
 		}
@@ -39,12 +46,6 @@ int ip6_route_me_harder(struct sk_buff *
 	}
 #endif
 
-	if (dst->error) {
-		IP6_INC_STATS(net, ip6_dst_idev(dst), IPSTATS_MIB_OUTNOROUTES);
-		LIMIT_NETDEBUG(KERN_DEBUG "ip6_route_me_harder: No more route.\n");
-		dst_release(dst);
-		return -EINVAL;
-	}
 
 	/* Drop old route. */
 	skb_dst_drop(skb);
