From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH V4 2/4] net: implements ip_route_input_noref()
Date: Mon, 10 May 2010 23:32:55 +0200
Message-ID: <1273527175.10889.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41372 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753889Ab0EJVc7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 17:32:59 -0400
Received: by mail-wy0-f174.google.com with SMTP id 32so463791wyb.19
        for <netdev@vger.kernel.org>; Mon, 10 May 2010 14:32:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip_route_input() is the version returning a refcounted dst, while
ip_route_input_noref() returns a non refcounted one.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
include/net/route.h |   17 ++++++++++++++++-
net/ipv4/route.c    |   15 ++++++++++-----
2 files changed, 26 insertions(+), 6 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index 2c9fba7..af6cf4b 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -112,7 +112,22 @@ extern void		rt_cache_flush_batch(void);
 extern int		__ip_route_output_key(struct net *, struct rtable **, const struct flowi *flp);
 extern int		ip_route_output_key(struct net *, struct rtable **, struct flowi *flp);
 extern int		ip_route_output_flow(struct net *, struct rtable **rp, struct flowi *flp, struct sock *sk, int flags);
-extern int		ip_route_input(struct sk_buff*, __be32 dst, __be32 src, u8 tos, struct net_device *devin);
+
+extern int ip_route_input_common(struct sk_buff *skb, __be32 dst, __be32 src,
+				 u8 tos, struct net_device *devin, bool noref);
+
+static inline int ip_route_input(struct sk_buff *skb, __be32 dst, __be32 src,
+				 u8 tos, struct net_device *devin)
+{
+	return ip_route_input_common(skb, dst, src, tos, devin, false);
+}
+
+static inline int ip_route_input_noref(struct sk_buff *skb, __be32 dst, __be32 src,
+				       u8 tos, struct net_device *devin)
+{
+	return ip_route_input_common(skb, dst, src, tos, devin, true);
+}
+
 extern unsigned short	ip_rt_frag_needed(struct net *net, struct iphdr *iph, unsigned short new_mtu, struct net_device *dev);
 extern void		ip_rt_send_redirect(struct sk_buff *skb);
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 705eccf..560acc6 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2277,8 +2277,8 @@ martian_source:
 	goto e_inval;
 }
 
-int ip_route_input(struct sk_buff *skb, __be32 daddr, __be32 saddr,
-		   u8 tos, struct net_device *dev)
+int ip_route_input_common(struct sk_buff *skb, __be32 daddr, __be32 saddr,
+			   u8 tos, struct net_device *dev, bool noref)
 {
 	struct rtable * rth;
 	unsigned	hash;
@@ -2304,10 +2304,15 @@ int ip_route_input(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 		    rth->fl.mark == skb->mark &&
 		    net_eq(dev_net(rth->u.dst.dev), net) &&
 		    !rt_is_expired(rth)) {
-			dst_use(&rth->u.dst, jiffies);
+			if (noref) {
+				dst_use_noref(&rth->u.dst, jiffies);
+				skb_dst_set_noref(skb, &rth->u.dst);
+			} else {
+				dst_use(&rth->u.dst, jiffies);
+				skb_dst_set(skb, &rth->u.dst);
+			}
 			RT_CACHE_STAT_INC(in_hit);
 			rcu_read_unlock();
-			skb_dst_set(skb, &rth->u.dst);
 			return 0;
 		}
 		RT_CACHE_STAT_INC(in_hlist_search);
@@ -2350,6 +2355,7 @@ skip_cache:
 	}
 	return ip_route_input_slow(skb, daddr, saddr, tos, dev);
 }
+EXPORT_SYMBOL(ip_route_input_common);
 
 static int __mkroute_output(struct rtable **result,
 			    struct fib_result *res,
@@ -3361,5 +3367,4 @@ void __init ip_static_sysctl_init(void)
 #endif
 
 EXPORT_SYMBOL(__ip_select_ident);
-EXPORT_SYMBOL(ip_route_input);
 EXPORT_SYMBOL(ip_route_output_key);




