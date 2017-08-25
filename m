From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net] udp6: set rx_dst_cookie on rx_dst updates
Date: Fri, 25 Aug 2017 14:31:01 +0200
Message-ID: <9e52c29f4bd47d591cdc7bf6c3a88b2fc57e4422.1503664112.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49721 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754694AbdHYMbX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Aug 2017 08:31:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, in the udp6 code, the dst cookie is not initialized/updated
concurrently with the RX dst used by early demux.

As a result, the dst_check() in the early_demux path always fails,
the rx dst cache is always invalidated, and we can't really
leverage significant gain from the demux lookup.

Fix it adding udp6 specific variant of sk_rx_dst_set() and use it
to set the dst cookie when the dst entry is really changed.

The issue is there since the introduction of early demux for ipv6.

Fixes: 5425077d73e0 ("net: ipv6: Add early demux handler for UDP unicast")
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 include/net/udp.h |  2 +-
 net/ipv4/udp.c    |  4 +++-
 net/ipv6/udp.c    | 11 ++++++++++-
 3 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/include/net/udp.h b/include/net/udp.h
index 586de4b811b5..626c2d8a70c5 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -260,7 +260,7 @@ static inline struct sk_buff *skb_recv_udp(struct sock *sk, unsigned int flags,
 }
 
 void udp_v4_early_demux(struct sk_buff *skb);
-void udp_sk_rx_dst_set(struct sock *sk, struct dst_entry *dst);
+bool udp_sk_rx_dst_set(struct sock *sk, struct dst_entry *dst);
 int udp_get_port(struct sock *sk, unsigned short snum,
 		 int (*saddr_cmp)(const struct sock *,
 				  const struct sock *));
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index cd1d044a7fa5..a6dc48d76a29 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1929,14 +1929,16 @@ static int udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 /* For TCP sockets, sk_rx_dst is protected by socket lock
  * For UDP, we use xchg() to guard against concurrent changes.
  */
-void udp_sk_rx_dst_set(struct sock *sk, struct dst_entry *dst)
+bool udp_sk_rx_dst_set(struct sock *sk, struct dst_entry *dst)
 {
 	struct dst_entry *old;
 
 	if (dst_hold_safe(dst)) {
 		old = xchg(&sk->sk_rx_dst, dst);
 		dst_release(old);
+		return old != dst;
 	}
+	return false;
 }
 EXPORT_SYMBOL(udp_sk_rx_dst_set);
 
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 20039c8501eb..d6886228e1d0 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -768,6 +768,15 @@ static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 	return 0;
 }
 
+static void udp6_sk_rx_dst_set(struct sock *sk, struct dst_entry *dst)
+{
+	if (udp_sk_rx_dst_set(sk, dst)) {
+		const struct rt6_info *rt = (const struct rt6_info *)dst;
+
+		inet6_sk(sk)->rx_dst_cookie = rt6_get_cookie(rt);
+	}
+}
+
 int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 		   int proto)
 {
@@ -817,7 +826,7 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 		int ret;
 
 		if (unlikely(sk->sk_rx_dst != dst))
-			udp_sk_rx_dst_set(sk, dst);
+			udp6_sk_rx_dst_set(sk, dst);
 
 		ret = udpv6_queue_rcv_skb(sk, skb);
 		sock_put(sk);
-- 
2.13.5
