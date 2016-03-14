From: Wei Wang <weiwan@google.com>
Subject: [PATCH] ipv6: Fix the pmtu path for connected UDP socket
Date: Mon, 14 Mar 2016 13:59:47 -0700
Message-ID: <1457989187-92851-1-git-send-email-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	Wei Wang <weiwan@google.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35135 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933307AbcCNVAW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 17:00:22 -0400
Received: by mail-pa0-f45.google.com with SMTP id td3so137624768pab.2
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2016 14:00:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

When ICMPV6_PKT_TOOBIG message is received by a connected UDP socket,
the new mtu value is not properly updated in the dst_entry associated
with the socket.
This leads to the issue that the mtu value returned by getsockopt(sockfd,
IPPROTO_IPV6, IPV6_MTU, ...) is wrong.
The fix is to update sk->sk_dst_cache and other corresponding fields
when a new routing cache is allocated for the new pmtu in UDP connected
socket case.

Signed-off-by: Wei Wang <weiwan@google.com>
---
 include/net/ip6_route.h |  4 ++--
 net/ipv6/ah6.c          |  2 +-
 net/ipv6/esp6.c         |  2 +-
 net/ipv6/icmp.c         |  2 +-
 net/ipv6/ip6_vti.c      |  2 +-
 net/ipv6/ipcomp6.c      |  2 +-
 net/ipv6/route.c        | 21 +++++++++------------
 7 files changed, 16 insertions(+), 19 deletions(-)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 295d291..2b147a8 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -115,8 +115,8 @@ void rt6_purge_dflt_routers(struct net *net);
 int rt6_route_rcv(struct net_device *dev, u8 *opt, int len,
 		  const struct in6_addr *gwaddr);
 
-void ip6_update_pmtu(struct sk_buff *skb, struct net *net, __be32 mtu, int oif,
-		     u32 mark);
+void ip6_update_pmtu(struct net *net, struct sock *sk, struct sk_buff *skb,
+		     __be32 mtu, int oif, u32 mark);
 void ip6_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, __be32 mtu);
 void ip6_redirect(struct sk_buff *skb, struct net *net, int oif, u32 mark);
 void ip6_redirect_no_header(struct sk_buff *skb, struct net *net, int oif,
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index 0630a4d5..2c926ec 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -664,7 +664,7 @@ static int ah6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	if (type == NDISC_REDIRECT)
 		ip6_redirect(skb, net, skb->dev->ifindex, 0);
 	else
-		ip6_update_pmtu(skb, net, info, 0, 0);
+		ip6_update_pmtu(net, NULL, skb, info, 0, 0);
 	xfrm_state_put(x);
 
 	return 0;
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 060a60b..b74847a 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -476,7 +476,7 @@ static int esp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	if (type == NDISC_REDIRECT)
 		ip6_redirect(skb, net, skb->dev->ifindex, 0);
 	else
-		ip6_update_pmtu(skb, net, info, 0, 0);
+		ip6_update_pmtu(net, NULL, skb, info, 0, 0);
 	xfrm_state_put(x);
 
 	return 0;
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 0a37ddc..03816f5 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -92,7 +92,7 @@ static void icmpv6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	struct net *net = dev_net(skb->dev);
 
 	if (type == ICMPV6_PKT_TOOBIG)
-		ip6_update_pmtu(skb, net, info, 0, 0);
+		ip6_update_pmtu(net, NULL, skb, info, 0, 0);
 	else if (type == NDISC_REDIRECT)
 		ip6_redirect(skb, net, skb->dev->ifindex, 0);
 
diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index d90a11f..fa873ca 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -599,7 +599,7 @@ static int vti6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	if (type == NDISC_REDIRECT)
 		ip6_redirect(skb, net, skb->dev->ifindex, 0);
 	else
-		ip6_update_pmtu(skb, net, info, 0, 0);
+		ip6_update_pmtu(net, NULL, skb, info, 0, 0);
 	xfrm_state_put(x);
 
 	return 0;
diff --git a/net/ipv6/ipcomp6.c b/net/ipv6/ipcomp6.c
index 1b9316e..c07a5ac 100644
--- a/net/ipv6/ipcomp6.c
+++ b/net/ipv6/ipcomp6.c
@@ -76,7 +76,7 @@ static int ipcomp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	if (type == NDISC_REDIRECT)
 		ip6_redirect(skb, net, skb->dev->ifindex, 0);
 	else
-		ip6_update_pmtu(skb, net, info, 0, 0);
+		ip6_update_pmtu(net, NULL, skb, info, 0, 0);
 	xfrm_state_put(x);
 
 	return 0;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index ed44663..8f6a5f1 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1346,7 +1346,7 @@ static bool rt6_cache_allowed_for_pmtu(const struct rt6_info *rt)
 		(rt->rt6i_flags & RTF_PCPU || rt->rt6i_node);
 }
 
-static void __ip6_rt_update_pmtu(struct dst_entry *dst, const struct sock *sk,
+static void __ip6_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
 				 const struct ipv6hdr *iph, u32 mtu)
 {
 	struct rt6_info *rt6 = (struct rt6_info *)dst;
@@ -1377,12 +1377,8 @@ static void __ip6_rt_update_pmtu(struct dst_entry *dst, const struct sock *sk,
 		nrt6 = ip6_rt_cache_alloc(rt6, daddr, saddr);
 		if (nrt6) {
 			rt6_do_update_pmtu(nrt6, mtu);
-
-			/* ip6_ins_rt(nrt6) will bump the
-			 * rt6->rt6i_node->fn_sernum
-			 * which will fail the next rt6_check() and
-			 * invalidate the sk->sk_dst_cache.
-			 */
+			if (sk)
+				ip6_dst_store(sk, &nrt6->dst, daddr, saddr);
 			ip6_ins_rt(nrt6);
 		}
 	}
@@ -1394,8 +1390,8 @@ static void ip6_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
 	__ip6_rt_update_pmtu(dst, sk, skb ? ipv6_hdr(skb) : NULL, mtu);
 }
 
-void ip6_update_pmtu(struct sk_buff *skb, struct net *net, __be32 mtu,
-		     int oif, u32 mark)
+void ip6_update_pmtu(struct net *net, struct sock *sk,
+		     struct sk_buff *skb, __be32 mtu, int oif, u32 mark)
 {
 	const struct ipv6hdr *iph = (struct ipv6hdr *) skb->data;
 	struct dst_entry *dst;
@@ -1410,15 +1406,16 @@ void ip6_update_pmtu(struct sk_buff *skb, struct net *net, __be32 mtu,
 
 	dst = ip6_route_output(net, NULL, &fl6);
 	if (!dst->error)
-		__ip6_rt_update_pmtu(dst, NULL, iph, ntohl(mtu));
+		__ip6_rt_update_pmtu(dst, sk, iph, ntohl(mtu));
 	dst_release(dst);
 }
 EXPORT_SYMBOL_GPL(ip6_update_pmtu);
 
 void ip6_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, __be32 mtu)
 {
-	ip6_update_pmtu(skb, sock_net(sk), mtu,
-			sk->sk_bound_dev_if, sk->sk_mark);
+	ip6_update_pmtu(sock_net(sk),
+			(sk->sk_state != TCP_ESTABLISHED) ? NULL : sk,
+			skb, mtu, sk->sk_bound_dev_if, sk->sk_mark);
 }
 EXPORT_SYMBOL_GPL(ip6_sk_update_pmtu);
 
-- 
2.7.0.rc3.207.g0ac5344
