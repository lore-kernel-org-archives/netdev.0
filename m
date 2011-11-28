From: Ulrich Weber <ulrich.weber@sophos.com>
Subject: [PATCH 2/3] route: set iif and oif information in flowi struct
Date: Mon, 28 Nov 2011 21:14:51 +0100
Message-ID: <1322511292-1413-3-git-send-email-ulrich.weber@sophos.com>
References: <1322511292-1413-1-git-send-email-ulrich.weber@sophos.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.sophos.com ([216.47.234.212]:45782 "EHLO mx3.sophos.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754091Ab1K1UZ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Nov 2011 15:25:57 -0500
In-Reply-To: <1322511292-1413-1-git-send-email-ulrich.weber@sophos.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Outgoing packets have loopback interface as incoming interface.

Signed-off-by: Ulrich Weber <ulrich.weber@sophos.com>
---
 net/ipv4/route.c        |    4 ++++
 net/ipv4/xfrm4_policy.c |   19 +++++++++++++++++--
 net/ipv6/fib6_rules.c   |   10 ++++++++--
 net/ipv6/xfrm6_policy.c |   18 ++++++++++++++++--
 4 files changed, 45 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index fb47c8f..1702ec0 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2744,6 +2744,10 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *flp4)
 				flp4->saddr = rth->rt_src;
 			if (!flp4->daddr)
 				flp4->daddr = rth->rt_dst;
+			if (!flp4->flowi4_iif)
+				flp4->flowi4_iif = net->loopback_dev->ifindex;
+			if (!flp4->flowi4_oif)
+				flp4->flowi4_oif = rth->rt_iif;
 			return rth;
 		}
 		RT_CACHE_STAT_INC(out_hlist_search);
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index a0b4c5d..ad9c620 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -110,6 +110,8 @@ static int xfrm4_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
 static void
 _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 {
+	const struct net *net = dev_net(skb->dev);
+	const struct rtable *rt = skb_rtable(skb);
 	const struct iphdr *iph = ip_hdr(skb);
 	u8 *xprth = skb_network_header(skb) + iph->ihl * 4;
 	struct flowi4 *fl4 = &fl->u.ip4;
@@ -185,9 +187,22 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 		}
 	}
 	fl4->flowi4_proto = iph->protocol;
-	fl4->daddr = reverse ? iph->saddr : iph->daddr;
-	fl4->saddr = reverse ? iph->daddr : iph->saddr;
 	fl4->flowi4_tos = iph->tos;
+
+	if (reverse) {
+		fl4->daddr = iph->saddr;
+		fl4->saddr = iph->daddr;
+		fl4->flowi4_oif = skb->skb_iif ?: net->loopback_dev->ifindex;
+		if (rt)
+			fl4->flowi4_iif = rt->rt_oif ?: rt->dst.dev->ifindex;
+	}
+	else {
+		fl4->daddr = iph->daddr;
+		fl4->saddr = iph->saddr;
+		fl4->flowi4_iif = skb->skb_iif ?: net->loopback_dev->ifindex;
+		if (rt)
+			fl4->flowi4_oif = rt->rt_oif ?: rt->dst.dev->ifindex;
+	}
 }
 
 static inline int xfrm4_garbage_collect(struct dst_ops *ops)
diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index b6c5731..fd520b5 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -108,8 +108,14 @@ again:
 discard_pkt:
 	dst_hold(&rt->dst);
 out:
-	arg->result = rt;
-	return rt == NULL ? -EAGAIN : 0;
+	if ((arg->result = rt)) {
+		if (!flp6->flowi6_iif)
+			flp6->flowi6_iif = net->loopback_dev->ifindex;
+		if (!flp6->flowi6_oif)
+			flp6->flowi6_oif = rt->rt6i_dev->ifindex;
+		return 0;
+	}
+	return -EAGAIN;
 }
 
 
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 8ea65e0..7c0196f 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -121,6 +121,8 @@ static int xfrm6_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
 static inline void
 _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 {
+	const struct net *net = dev_net(skb->dev);
+	const struct rt6_info *rt = (struct rt6_info*)skb_dst(skb);
 	struct flowi6 *fl6 = &fl->u.ip6;
 	int onlyproto = 0;
 	u16 offset = skb_network_header_len(skb);
@@ -132,8 +134,20 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 	memset(fl6, 0, sizeof(struct flowi6));
 	fl6->flowi6_mark = skb->mark;
 
-	fl6->daddr = reverse ? hdr->saddr : hdr->daddr;
-	fl6->saddr = reverse ? hdr->daddr : hdr->saddr;
+	if (reverse) {
+		fl6->daddr = hdr->saddr;
+		fl6->saddr = hdr->daddr;
+		fl6->flowi6_oif = skb->skb_iif ?: net->loopback_dev->ifindex;
+		if (rt)
+			fl6->flowi6_iif = rt->rt6i_dev->ifindex;
+	}
+	else {
+		fl6->daddr = hdr->daddr;
+		fl6->saddr = hdr->saddr;
+		fl6->flowi6_iif = skb->skb_iif ?: net->loopback_dev->ifindex;
+		if (rt)
+			fl6->flowi6_oif = rt->rt6i_dev->ifindex;
+	}
 
 	while (nh + offset + 1 < skb->data ||
 	       pskb_may_pull(skb, nh + offset + 1 - skb->data)) {
-- 
1.7.4.1
