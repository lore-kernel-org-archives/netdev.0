From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/3] net: Abstract RTAX_HOPLIMIT metric accesses behind
 helper.
Date: Mon, 13 Dec 2010 10:03:09 -0800 (PST)
Message-ID: <20101213.100309.112584330.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57047
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758640Ab0LMSCl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 13:02:41 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id AD83E24C088
	for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 10:03:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/pptp.c              |    2 +-
 include/net/dst.h               |   15 ++++++++++++++-
 net/ipv4/ip_gre.c               |    2 +-
 net/ipv4/ip_output.c            |    2 +-
 net/ipv4/netfilter/ipt_REJECT.c |    2 +-
 net/ipv4/route.c                |    2 +-
 net/ipv4/xfrm4_mode_tunnel.c    |    2 +-
 net/ipv6/route.c                |    4 ++--
 8 files changed, 22 insertions(+), 9 deletions(-)

diff --git a/drivers/net/pptp.c b/drivers/net/pptp.c
index 7556a92..c83e168 100644
--- a/drivers/net/pptp.c
+++ b/drivers/net/pptp.c
@@ -277,7 +277,7 @@ static int pptp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 	iph->tos      = 0;
 	iph->daddr    = rt->rt_dst;
 	iph->saddr    = rt->rt_src;
-	iph->ttl      = dst_metric(&rt->dst, RTAX_HOPLIMIT);
+	iph->ttl      = dst_metric_hoplimit(&rt->dst);
 	iph->tot_len  = htons(skb->len);
 
 	skb_dst_drop(skb);
diff --git a/include/net/dst.h b/include/net/dst.h
index 85dee3a..9208b50 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -104,11 +104,24 @@ struct dst_entry {
 #ifdef __KERNEL__
 
 static inline u32
-dst_metric(const struct dst_entry *dst, int metric)
+dst_metric_raw(const struct dst_entry *dst, const int metric)
 {
 	return dst->_metrics[metric-1];
 }
 
+static inline u32
+dst_metric(const struct dst_entry *dst, const int metric)
+{
+	WARN_ON_ONCE(metric == RTAX_HOPLIMIT);
+	return dst_metric_raw(dst, metric);
+}
+
+static inline u32
+dst_metric_hoplimit(const struct dst_entry *dst)
+{
+	return dst_metric_raw(dst, RTAX_HOPLIMIT);
+}
+
 static inline void dst_metric_set(struct dst_entry *dst, int metric, u32 val)
 {
 	dst->_metrics[metric-1] = val;
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index ff4e7a4..46eb3dc 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -890,7 +890,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 			iph->ttl = ((struct ipv6hdr *)old_iph)->hop_limit;
 #endif
 		else
-			iph->ttl = dst_metric(&rt->dst, RTAX_HOPLIMIT);
+			iph->ttl = dst_metric_hoplimit(&rt->dst);
 	}
 
 	((__be16 *)(iph + 1))[0] = tunnel->parms.o_flags;
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 5090c7f..ea28fa5 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -130,7 +130,7 @@ static inline int ip_select_ttl(struct inet_sock *inet, struct dst_entry *dst)
 	int ttl = inet->uc_ttl;
 
 	if (ttl < 0)
-		ttl = dst_metric(dst, RTAX_HOPLIMIT);
+		ttl = dst_metric_hoplimit(dst);
 	return ttl;
 }
 
diff --git a/net/ipv4/netfilter/ipt_REJECT.c b/net/ipv4/netfilter/ipt_REJECT.c
index 43eec80..f130907 100644
--- a/net/ipv4/netfilter/ipt_REJECT.c
+++ b/net/ipv4/netfilter/ipt_REJECT.c
@@ -116,7 +116,7 @@ static void send_reset(struct sk_buff *oldskb, int hook)
 	if (ip_route_me_harder(nskb, addr_type))
 		goto free_nskb;
 
-	niph->ttl	= dst_metric(skb_dst(nskb), RTAX_HOPLIMIT);
+	niph->ttl	= dst_metric_hoplimit(skb_dst(nskb));
 
 	/* "Never happens" */
 	if (nskb->len > dst_mtu(skb_dst(nskb)))
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 26ac396..90b5a37 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1821,7 +1821,7 @@ static void rt_set_nexthop(struct rtable *rt, struct fib_result *res, u32 itag)
 	} else
 		dst_metric_set(dst, RTAX_MTU, dst->dev->mtu);
 
-	if (dst_metric(dst, RTAX_HOPLIMIT) == 0)
+	if (dst_metric_raw(dst, RTAX_HOPLIMIT) == 0)
 		dst_metric_set(dst, RTAX_HOPLIMIT, sysctl_ip_default_ttl);
 	if (dst_mtu(dst) > IP_MAX_MTU)
 		dst_metric_set(dst, RTAX_MTU, IP_MAX_MTU);
diff --git a/net/ipv4/xfrm4_mode_tunnel.c b/net/ipv4/xfrm4_mode_tunnel.c
index 6f36841..63b854e 100644
--- a/net/ipv4/xfrm4_mode_tunnel.c
+++ b/net/ipv4/xfrm4_mode_tunnel.c
@@ -56,7 +56,7 @@ static int xfrm4_mode_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 		0 : (XFRM_MODE_SKB_CB(skb)->frag_off & htons(IP_DF));
 	ip_select_ident(top_iph, dst->child, NULL);
 
-	top_iph->ttl = dst_metric(dst->child, RTAX_HOPLIMIT);
+	top_iph->ttl = dst_metric_hoplimit(dst->child);
 
 	top_iph->saddr = x->props.saddr.a4;
 	top_iph->daddr = x->id.daddr.a4;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 9b2d7bc..d9405d1 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1104,7 +1104,7 @@ static int ipv6_get_mtu(struct net_device *dev)
 
 int ip6_dst_hoplimit(struct dst_entry *dst)
 {
-	int hoplimit = dst_metric(dst, RTAX_HOPLIMIT);
+	int hoplimit = dst_metric_raw(dst, RTAX_HOPLIMIT);
 	if (hoplimit < 0) {
 		struct net_device *dev = dst->dev;
 		struct inet6_dev *idev;
@@ -1310,7 +1310,7 @@ install_route:
 		}
 	}
 
-	if (dst_metric(&rt->dst, RTAX_HOPLIMIT) == 0)
+	if (dst_metric_raw(&rt->dst, RTAX_HOPLIMIT) == 0)
 		dst_metric_set(&rt->dst, RTAX_HOPLIMIT, -1);
 	if (!dst_mtu(&rt->dst))
 		dst_metric_set(&rt->dst, RTAX_MTU, ipv6_get_mtu(dev));
-- 
1.7.3.2

