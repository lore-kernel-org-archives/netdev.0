From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 8/8] udp: multicast RX should increment SNMP/sk_drops counter
 in allocation failures
Date: Sun, 08 Nov 2009 21:20:19 +0100
Message-ID: <4AF72803.5020805@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Lucian Adrian Grijincu <lgrijincu@ixiacom.com>,
	Octavian Purdila <opurdila@ixiacom.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:46213 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754516AbZKHUUW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2009 15:20:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When skb_clone() fails, we should increment sk_drops and SNMP counters.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/udp.c |   12 +++++++++++-
 net/ipv6/udp.c |    8 +++++++-
 2 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 9d9072c..d73e917 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1335,12 +1335,22 @@ static void flush_stack(struct sock **stack, unsigned int count,
 {
 	unsigned int i;
 	struct sk_buff *skb1 = NULL;
+	struct sock *sk;
 
 	for (i = 0; i < count; i++) {
+		sk = stack[i];
 		if (likely(skb1 == NULL))
 			skb1 = (i == final) ? skb : skb_clone(skb, GFP_ATOMIC);
 
-		if (skb1 && udp_queue_rcv_skb(stack[i], skb1) <= 0)
+		if (!skb1) {
+			atomic_inc(&sk->sk_drops);
+			UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_RCVBUFERRORS,
+					 IS_UDPLITE(sk));
+			UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_INERRORS,
+					 IS_UDPLITE(sk));
+		}
+
+		if (skb1 && udp_queue_rcv_skb(sk, skb1) <= 0)
 			skb1 = NULL;
 	}
 	if (unlikely(skb1))
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 173e531..84cc4a8 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -579,14 +579,20 @@ static void flush_stack(struct sock **stack, unsigned int count,
 	for (i = 0; i < count; i++) {
 		skb1 = (i == final) ? skb : skb_clone(skb, GFP_ATOMIC);
 
+		sk = stack[i];
 		if (skb1) {
-			sk = stack[i];
 			bh_lock_sock(sk);
 			if (!sock_owned_by_user(sk))
 				udpv6_queue_rcv_skb(sk, skb1);
 			else
 				sk_add_backlog(sk, skb1);
 			bh_unlock_sock(sk);
+		} else {
+			atomic_inc(&sk->sk_drops);
+			UDP6_INC_STATS_BH(sock_net(sk),
+					UDP_MIB_RCVBUFERRORS, IS_UDPLITE(sk));
+			UDP6_INC_STATS_BH(sock_net(sk),
+					UDP_MIB_INERRORS, IS_UDPLITE(sk));
 		}
 	}
 }
