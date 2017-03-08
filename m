From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH net-next] net: ipv6: Add early demux handler for UDP unicast
Date: Wed,  8 Mar 2017 11:24:17 -0700
Message-ID: <1488997457-24554-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
To: netdev@vger.kernel.org, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:57226 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753921AbdCHStw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 13:49:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While running a single stream UDPv6 test, we observed that amount
of CPU spent in NET_RX softirq was much greater than UDPv4 for an
equivalent receive rate. The test here was run on an ARM64 based
Android system. On further analysis with perf, we found that UDPv6
was spending significant time in the statistics netfilter targets
which did socket lookup per packet. These statistics rules perform
a lookup when there is no socket associated with the skb. Since
there are multiple instances of these rules based on UID, there
will be equal number of lookups per skb.

By introducing early demux for UDPv6, we avoid the redundant lookups.
This also helped to improve the performance (800Mbps -> 870Mbps) on a
CPU limited system in a single stream UDPv6 receive test with 1450
byte sized datagrams using iperf.

Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
---
 net/ipv6/udp.c | 60 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 60 insertions(+)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 221825a..76501ce 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -851,6 +851,65 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 	return 0;
 }
 
+static struct sock *__udp6_lib_demux_lookup(struct net *net,
+			__be16 loc_port, const struct in6_addr *loc_addr,
+			__be16 rmt_port, const struct in6_addr *rmt_addr,
+			int dif)
+{
+	struct sock *sk;
+
+	rcu_read_lock();
+	sk = __udp6_lib_lookup(net, rmt_addr, rmt_port, loc_addr, loc_port,
+			       dif, &udp_table, NULL);
+	if (sk && !atomic_inc_not_zero(&sk->sk_refcnt))
+		sk = NULL;
+	rcu_read_unlock();
+
+	return sk;
+}
+
+static void udp_v6_early_demux(struct sk_buff *skb)
+{
+	struct net *net = dev_net(skb->dev);
+	const struct udphdr *uh;
+	struct sock *sk;
+	struct dst_entry *dst;
+	int dif = skb->dev->ifindex;
+
+	if (!pskb_may_pull(skb, skb_transport_offset(skb) +
+	    sizeof(struct udphdr)))
+		return;
+
+	uh = udp_hdr(skb);
+
+	if (skb->pkt_type == PACKET_HOST)
+		sk = __udp6_lib_demux_lookup(net, uh->dest,
+					     &ipv6_hdr(skb)->daddr,
+					     uh->source, &ipv6_hdr(skb)->saddr,
+					     dif);
+	else
+		return;
+
+	if (!sk)
+		return;
+
+	skb->sk = sk;
+
+	skb->destructor = sock_efree;
+	dst = READ_ONCE(sk->sk_rx_dst);
+
+	if (dst)
+		dst = dst_check(dst, 0);
+	if (dst) {
+		if (dst->flags & DST_NOCACHE) {
+			if (likely(atomic_inc_not_zero(&dst->__refcnt)))
+				skb_dst_set(skb, dst);
+		} else {
+			skb_dst_set_noref(skb, dst);
+		}
+	}
+}
+
 static __inline__ int udpv6_rcv(struct sk_buff *skb)
 {
 	return __udp6_lib_rcv(skb, &udp_table, IPPROTO_UDP);
@@ -1365,6 +1424,7 @@ int compat_udpv6_getsockopt(struct sock *sk, int level, int optname,
 #endif
 
 static const struct inet6_protocol udpv6_protocol = {
+	.early_demux	=	udp_v6_early_demux,
 	.handler	=	udpv6_rcv,
 	.err_handler	=	udpv6_err,
 	.flags		=	INET6_PROTO_NOPOLICY|INET6_PROTO_FINAL,
-- 
1.9.1
