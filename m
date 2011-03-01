From: David Miller <davem@davemloft.net>
Subject: [PATCH 7/8] ipv6: Normalize arguments to ip6_dst_blackhole().
Date: Tue, 01 Mar 2011 15:11:36 -0800 (PST)
Message-ID: <20110301.151136.35033499.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48522
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757139Ab1CAXK7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 18:10:59 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id BACAC24C087
	for <netdev@vger.kernel.org>; Tue,  1 Mar 2011 15:11:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Return a dst pointer which is potentitally error encoded.

Don't pass original dst pointer by reference, pass a struct net
instead of a socket, and elide the flow argument since it is
unnecessary.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ipv6.h    |    5 ++---
 net/ipv6/ip6_output.c |    4 ++--
 net/ipv6/route.c      |   12 +++++-------
 3 files changed, 9 insertions(+), 12 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 8f78aac..5d125c1 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -520,9 +520,8 @@ extern struct dst_entry *	ip6_sk_dst_lookup_flow(struct sock *sk,
 						       struct flowi *fl,
 						       const struct in6_addr *final_dst,
 						       bool can_sleep);
-extern int			ip6_dst_blackhole(struct sock *sk,
-						  struct dst_entry **dst,
-						  struct flowi *fl);
+extern struct dst_entry *	ip6_dst_blackhole(struct net *net,
+						  struct dst_entry *orig_dst);
 
 /*
  *	skb processing functions
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index faf7b9d..ac16f3b 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1029,7 +1029,7 @@ struct dst_entry *ip6_dst_lookup_flow(struct sock *sk, struct flowi *fl,
 		fl->flags |= FLOWI_FLAG_CAN_SLEEP;
 		err = __xfrm_lookup(sock_net(sk), &dst, fl, sk, 0);
 		if (err == -EREMOTE)
-			err = ip6_dst_blackhole(sk, &dst, fl);
+			return ip6_dst_blackhole(sock_net(sk), dst);
 		if (err)
 			return ERR_PTR(err);
 	} else {
@@ -1074,7 +1074,7 @@ struct dst_entry *ip6_sk_dst_lookup_flow(struct sock *sk, struct flowi *fl,
 		fl->flags |= FLOWI_FLAG_CAN_SLEEP;
 		err = __xfrm_lookup(sock_net(sk), &dst, fl, sk, 0);
 		if (err == -EREMOTE)
-			err = ip6_dst_blackhole(sk, &dst, fl);
+			return ip6_dst_blackhole(sock_net(sk), dst);
 		if (err)
 			return ERR_PTR(err);
 	} else {
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 7e9443f..cf6fdea 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -870,11 +870,10 @@ struct dst_entry * ip6_route_output(struct net *net, struct sock *sk,
 
 EXPORT_SYMBOL(ip6_route_output);
 
-int ip6_dst_blackhole(struct sock *sk, struct dst_entry **dstp, struct flowi *fl)
+struct dst_entry *ip6_dst_blackhole(struct net *net, struct dst_entry *dst_orig)
 {
-	struct rt6_info *ort = (struct rt6_info *) *dstp;
-	struct rt6_info *rt = (struct rt6_info *)
-		dst_alloc(&ip6_dst_blackhole_ops, 1);
+	struct rt6_info *rt = dst_alloc(&ip6_dst_blackhole_ops, 1);
+	struct rt6_info *ort = (struct rt6_info *) dst_orig;
 	struct dst_entry *new = NULL;
 
 	if (rt) {
@@ -905,9 +904,8 @@ int ip6_dst_blackhole(struct sock *sk, struct dst_entry **dstp, struct flowi *fl
 		dst_free(new);
 	}
 
-	dst_release(*dstp);
-	*dstp = new;
-	return new ? 0 : -ENOMEM;
+	dst_release(dst_orig);
+	return new ? new : ERR_PTR(-ENOMEM);
 }
 EXPORT_SYMBOL_GPL(ip6_dst_blackhole);
 
-- 
1.7.4.1

