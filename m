From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: ip_route_output_key() is better as an inline.
Date: Wed, 02 Mar 2011 15:03:19 -0800 (PST)
Message-ID: <20110302.150319.245380993.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43579
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756193Ab1CBXCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 18:02:42 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 2761B24C087
	for <netdev@vger.kernel.org>; Wed,  2 Mar 2011 15:03:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This avoid a stack frame at zero cost.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/route.h |    6 +++++-
 net/ipv4/route.c    |    6 ------
 2 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index 088a186..60daf74 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -119,11 +119,15 @@ extern void		ip_rt_redirect(__be32 old_gw, __be32 dst, __be32 new_gw,
 extern void		rt_cache_flush(struct net *net, int how);
 extern void		rt_cache_flush_batch(struct net *net);
 extern struct rtable *__ip_route_output_key(struct net *, const struct flowi *flp);
-extern struct rtable *ip_route_output_key(struct net *, struct flowi *flp);
 extern struct rtable *ip_route_output_flow(struct net *, struct flowi *flp,
 					   struct sock *sk);
 extern struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_orig);
 
+static inline struct rtable *ip_route_output_key(struct net *net, struct flowi *flp)
+{
+	return ip_route_output_flow(net, flp, NULL);
+}
+
 extern int ip_route_input_common(struct sk_buff *skb, __be32 dst, __be32 src,
 				 u8 tos, struct net_device *devin, bool noref);
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 5090e95..432eee6 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2736,12 +2736,6 @@ struct rtable *ip_route_output_flow(struct net *net, struct flowi *flp,
 }
 EXPORT_SYMBOL_GPL(ip_route_output_flow);
 
-struct rtable *ip_route_output_key(struct net *net, struct flowi *flp)
-{
-	return ip_route_output_flow(net, flp, NULL);
-}
-EXPORT_SYMBOL(ip_route_output_key);
-
 static int rt_fill_info(struct net *net,
 			struct sk_buff *skb, u32 pid, u32 seq, int event,
 			int nowait, unsigned int flags)
-- 
1.7.4.1

