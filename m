From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next 3/5] udp: do not touch socket refcount in early demux
Date: Wed, 20 Sep 2017 18:54:03 +0200
Message-ID: <7ea71bca0be872959e0a585e2589c2a14715394b.1505926196.git.pabeni@redhat.com>
References: <cover.1505926196.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37132 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750825AbdITQ6O (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 20 Sep 2017 12:58:14 -0400
In-Reply-To: <cover.1505926196.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

use noref sockets instead. This gives some small performance
improvements and will allow efficient early demux for unconnected
sockets in a later patch.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv4/udp.c | 18 ++++++++++--------
 net/ipv6/udp.c | 10 ++++++----
 2 files changed, 16 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 784ced0b9150..ba49d5aa9f09 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2050,12 +2050,13 @@ static inline int udp4_csum_init(struct sk_buff *skb, struct udphdr *uh,
 int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 		   int proto)
 {
-	struct sock *sk;
-	struct udphdr *uh;
-	unsigned short ulen;
+	struct net *net = dev_net(skb->dev);
 	struct rtable *rt = skb_rtable(skb);
+	unsigned short ulen;
 	__be32 saddr, daddr;
-	struct net *net = dev_net(skb->dev);
+	struct udphdr *uh;
+	struct sock *sk;
+	bool noref_sk;
 
 	/*
 	 *  Validate the packet.
@@ -2081,6 +2082,7 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 	if (udp4_csum_init(skb, uh, proto))
 		goto csum_error;
 
+	noref_sk = skb_has_noref_sk(skb);
 	sk = skb_steal_sock(skb);
 	if (sk) {
 		struct dst_entry *dst = skb_dst(skb);
@@ -2090,7 +2092,8 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 			udp_sk_rx_dst_set(sk, dst);
 
 		ret = udp_queue_rcv_skb(sk, skb);
-		sock_put(sk);
+		if (!noref_sk)
+			sock_put(sk);
 		/* a return value > 0 means to resubmit the input, but
 		 * it wants the return to be -protocol, or 0
 		 */
@@ -2261,11 +2264,10 @@ void udp_v4_early_demux(struct sk_buff *skb)
 					     uh->source, iph->saddr, dif, sdif);
 	}
 
-	if (!sk || !refcount_inc_not_zero(&sk->sk_refcnt))
+	if (!sk)
 		return;
 
-	skb->sk = sk;
-	skb->destructor = sock_efree;
+	skb_set_noref_sk(skb, sk);
 	dst = READ_ONCE(sk->sk_rx_dst);
 
 	if (dst)
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index e2ecfb137297..8f62392c4c35 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -787,6 +787,7 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 	struct net *net = dev_net(skb->dev);
 	struct udphdr *uh;
 	struct sock *sk;
+	bool noref_sk;
 	u32 ulen = 0;
 
 	if (!pskb_may_pull(skb, sizeof(struct udphdr)))
@@ -823,6 +824,7 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 		goto csum_error;
 
 	/* Check if the socket is already available, e.g. due to early demux */
+	noref_sk = skb_has_noref_sk(skb);
 	sk = skb_steal_sock(skb);
 	if (sk) {
 		struct dst_entry *dst = skb_dst(skb);
@@ -832,7 +834,8 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 			udp6_sk_rx_dst_set(sk, dst);
 
 		ret = udpv6_queue_rcv_skb(sk, skb);
-		sock_put(sk);
+		if (!noref_sk)
+			sock_put(sk);
 
 		/* a return value > 0 means to resubmit the input */
 		if (ret > 0)
@@ -948,11 +951,10 @@ static void udp_v6_early_demux(struct sk_buff *skb)
 	else
 		return;
 
-	if (!sk || !refcount_inc_not_zero(&sk->sk_refcnt))
+	if (!sk)
 		return;
 
-	skb->sk = sk;
-	skb->destructor = sock_efree;
+	skb_set_noref_sk(skb, sk);
 	dst = READ_ONCE(sk->sk_rx_dst);
 
 	if (dst)
-- 
2.13.5
