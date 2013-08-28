From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 5/8] xfrm: choose protocol family by skb protocol
Date: Wed, 28 Aug 2013 13:04:52 +0200
Message-ID: <1377687895-5780-6-git-send-email-steffen.klassert@secunet.com>
References: <1377687895-5780-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:56728 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753718Ab3H1LFH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 07:05:07 -0400
In-Reply-To: <1377687895-5780-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>

We need to choose the protocol family by skb->protocol. Otherwise we
call the wrong xfrm{4,6}_local_error handler in case an ipv6 sockets is
used in ipv4 mode, in which case we should call down to xfrm4_local_error
(ip6 sockets are a superset of ip4 ones).

We are called before before ip_output functions, so skb->protocol is
not reset.

Cc: Steffen Klassert <steffen.klassert@secunet.com>
Acked-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h     |    4 ++--
 net/xfrm/xfrm_output.c |   10 +++++++++-
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
1.7.9.5
