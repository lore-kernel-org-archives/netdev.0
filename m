From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH ipsec v2 3/3] xfrm: choose protocol family by skb protocol
Date: Sun, 18 Aug 2013 13:47:01 +0200
Message-ID: <20130818114701.GA10270@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: steffen.klassert@secunet.com, edumazet@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:58915 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754440Ab3HRLrC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Aug 2013 07:47:02 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to choose the protocol family by skb->protocol. Otherwise we
call the wrong xfrm{4,6}_local_error handler in case an ipv6 sockets is
used in ipv4 mode, in which case we should call down to xfrm4_local_error
(ip6 sockets are a superset of ip4 ones).

We are called before before ip_output functions, so skb->protocol is
not reset.

v2:
a) unchanged

Cc: Steffen Klassert <steffen.klassert@secunet.com>
Acked-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---

This patch is based on Steffen Klassert's ipsec tree.

 include/net/xfrm.h     |  4 ++--
 net/xfrm/xfrm_output.c | 10 +++++++++-
 2 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index b41d2d1..ac5b025 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1728,9 +1728,9 @@ static inline int xfrm_skb_dst_mtu(struct sk_buff *skb)
 {
 	struct sock *sk = skb->sk;
 
-	if (sk && sk->sk_family == AF_INET6)
+	if (sk && skb->protocol == htons(ETH_P_IPV6))
 		return ip6_skb_dst_mtu(skb);
-	else if (sk && sk->sk_family == AF_INET)
+	else if (sk && skb->protocol == htons(ETH_P_IP))
 		return ip_skb_dst_mtu(skb);
 	return dst_mtu(skb_dst(skb));
 }
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 6f5fc61..3bb2cdc 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -216,9 +216,17 @@ int xfrm_inner_extract_output(struct xfrm_state *x, struct sk_buff *skb)
 
 void xfrm_local_error(struct sk_buff *skb, int mtu)
 {
+	unsigned int proto;
 	struct xfrm_state_afinfo *afinfo;
 
-	afinfo = xfrm_state_get_afinfo(skb->sk->sk_family);
+	if (skb->protocol == htons(ETH_P_IP))
+		proto = AF_INET;
+	else if (skb->protocol == htons(ETH_P_IPV6))
+		proto = AF_INET6;
+	else
+		return;
+
+	afinfo = xfrm_state_get_afinfo(proto);
 	if (!afinfo)
 		return;
 
-- 
1.8.3.1
