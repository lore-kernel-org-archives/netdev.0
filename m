From: Shawn Bohrer <shawn.bohrer@gmail.com>
Subject: [PATCH net-next v2 2/3] udp: Add udp early demux
Date: Fri,  4 Oct 2013 14:28:15 -0500
Message-ID: <1380914896-24754-3-git-send-email-shawn.bohrer@gmail.com>
References: <1380914896-24754-1-git-send-email-shawn.bohrer@gmail.com>
Cc: netdev <netdev@vger.kernel.org>, tomk@rgmadvisors.com,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Shawn Bohrer <sbohrer@rgmadvisors.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f50.google.com ([209.85.219.50]:57374 "EHLO
	mail-oa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751352Ab3JDT2u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Oct 2013 15:28:50 -0400
Received: by mail-oa0-f50.google.com with SMTP id j1so4483446oag.9
        for <netdev@vger.kernel.org>; Fri, 04 Oct 2013 12:28:49 -0700 (PDT)
In-Reply-To: <1380914896-24754-1-git-send-email-shawn.bohrer@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shawn Bohrer <sbohrer@rgmadvisors.com>

The removal of the routing cache introduced a performance regression for
some UDP workloads since a dst lookup must be done for each packet.
This change caches the dst per socket in a similar manner to what we do
for TCP by implementing early_demux.

For UDP multicast we can only cache the dst if there is only one
receiving socket on the host.  Since caching only works when there is
one receiving socket we do the multicast socket lookup using RCU.

For UDP unicast we only demux sockets with an exact match in order to
not break forwarding setups.  Additionally since the hash chains may be
long we only check the first socket to see if it is a match and not
waste extra time searching the whole chain when we might not find an
exact match.

Benchmark results from a netperf UDP_RR test:
Before 87961.22 transactions/s
After  89789.68 transactions/s

Benchmark results from a fio 1 byte UDP multicast pingpong test
(Multicast one way unicast response):
Before 12.97us RTT
After  12.63us RTT

Signed-off-by: Shawn Bohrer <sbohrer@rgmadvisors.com>
---
v2 Changes:

* Unicast UDP early demux now requires an exact socket match and only
tests first socket in UDP hash chain.

 include/net/sock.h |    2 +-
 include/net/udp.h  |    1 +
 net/ipv4/af_inet.c |    1 +
 net/ipv4/udp.c     |  188 +++++++++++++++++++++++++++++++++++++++++++++++-----
 4 files changed, 173 insertions(+), 19 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index e3bf213..7953254 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -218,7 +218,7 @@ struct cg_proto;
   *	@sk_lock:	synchronizer
   *	@sk_rcvbuf: size of receive buffer in bytes
   *	@sk_wq: sock wait queue and async head
-  *	@sk_rx_dst: receive input route used by early tcp demux
+  *	@sk_rx_dst: receive input route used by early demux
   *	@sk_dst_cache: destination cache
   *	@sk_dst_lock: destination cache lock
   *	@sk_policy: flow policy
diff --git a/include/net/udp.h b/include/net/udp.h
index 510b8cb..fe4ba9f 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -175,6 +175,7 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
 		     unsigned int hash2_nulladdr);
 
 /* net/ipv4/udp.c */
+void udp_v4_early_demux(struct sk_buff *skb);
 int udp_get_port(struct sock *sk, unsigned short snum,
 		 int (*saddr_cmp)(const struct sock *,
 				  const struct sock *));
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index cfeb85c..35913fb 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1546,6 +1546,7 @@ static const struct net_protocol tcp_protocol = {
 };
 
 static const struct net_protocol udp_protocol = {
+	.early_demux =	udp_v4_early_demux,
 	.handler =	udp_rcv,
 	.err_handler =	udp_err,
 	.no_policy =	1,
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 5950e12..a3e575f 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -103,6 +103,7 @@
 #include <linux/seq_file.h>
 #include <net/net_namespace.h>
 #include <net/icmp.h>
+#include <net/inet_hashtables.h>
 #include <net/route.h>
 #include <net/checksum.h>
 #include <net/xfrm.h>
@@ -565,6 +566,26 @@ struct sock *udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
 }
 EXPORT_SYMBOL_GPL(udp4_lib_lookup);
 
+static inline bool __udp_is_mcast_sock(struct net *net, struct sock *sk,
+				       __be16 loc_port, __be32 loc_addr,
+				       __be16 rmt_port, __be32 rmt_addr,
+				       int dif, unsigned short hnum)
+{
+	struct inet_sock *inet = inet_sk(sk);
+
+	if (!net_eq(sock_net(sk), net) ||
+	    udp_sk(sk)->udp_port_hash != hnum ||
+	    (inet->inet_daddr && inet->inet_daddr != rmt_addr) ||
+	    (inet->inet_dport != rmt_port && inet->inet_dport) ||
+	    (inet->inet_rcv_saddr && inet->inet_rcv_saddr != loc_addr) ||
+	    ipv6_only_sock(sk) ||
+	    (sk->sk_bound_dev_if && sk->sk_bound_dev_if != dif))
+		return false;
+	if (!ip_mc_sf_allow(sk, loc_addr, rmt_addr, dif))
+		return false;
+	return true;
+}
+
 static inline struct sock *udp_v4_mcast_next(struct net *net, struct sock *sk,
 					     __be16 loc_port, __be32 loc_addr,
 					     __be16 rmt_port, __be32 rmt_addr,
@@ -575,20 +596,11 @@ static inline struct sock *udp_v4_mcast_next(struct net *net, struct sock *sk,
 	unsigned short hnum = ntohs(loc_port);
 
 	sk_nulls_for_each_from(s, node) {
-		struct inet_sock *inet = inet_sk(s);
-
-		if (!net_eq(sock_net(s), net) ||
-		    udp_sk(s)->udp_port_hash != hnum ||
-		    (inet->inet_daddr && inet->inet_daddr != rmt_addr) ||
-		    (inet->inet_dport != rmt_port && inet->inet_dport) ||
-		    (inet->inet_rcv_saddr &&
-		     inet->inet_rcv_saddr != loc_addr) ||
-		    ipv6_only_sock(s) ||
-		    (s->sk_bound_dev_if && s->sk_bound_dev_if != dif))
-			continue;
-		if (!ip_mc_sf_allow(s, loc_addr, rmt_addr, dif))
-			continue;
-		goto found;
+		if (__udp_is_mcast_sock(net, s,
+					loc_port, loc_addr,
+					rmt_port, rmt_addr,
+					dif, hnum))
+			goto found;
 	}
 	s = NULL;
 found:
@@ -1581,6 +1593,14 @@ static void flush_stack(struct sock **stack, unsigned int count,
 		kfree_skb(skb1);
 }
 
+static void udp_sk_rx_dst_set(struct sock *sk, const struct sk_buff *skb)
+{
+	struct dst_entry *dst = skb_dst(skb);
+
+	dst_hold(dst);
+	sk->sk_rx_dst = dst;
+}
+
 /*
  *	Multicasts and broadcasts go to each listener.
  *
@@ -1709,11 +1729,28 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 	if (udp4_csum_init(skb, uh, proto))
 		goto csum_error;
 
-	if (rt->rt_flags & (RTCF_BROADCAST|RTCF_MULTICAST))
-		return __udp4_lib_mcast_deliver(net, skb, uh,
-				saddr, daddr, udptable);
+	if (skb->sk) {
+		int ret;
+		sk = skb->sk;
+
+		if (unlikely(sk->sk_rx_dst == NULL))
+			udp_sk_rx_dst_set(sk, skb);
+
+		ret = udp_queue_rcv_skb(sk, skb);
+
+		/* a return value > 0 means to resubmit the input, but
+		 * it wants the return to be -protocol, or 0
+		 */
+		if (ret > 0)
+			return -ret;
+		return 0;
+	} else {
+		if (rt->rt_flags & (RTCF_BROADCAST|RTCF_MULTICAST))
+			return __udp4_lib_mcast_deliver(net, skb, uh,
+					saddr, daddr, udptable);
 
-	sk = __udp4_lib_lookup_skb(skb, uh->source, uh->dest, udptable);
+		sk = __udp4_lib_lookup_skb(skb, uh->source, uh->dest, udptable);
+	}
 
 	if (sk != NULL) {
 		int ret;
@@ -1771,6 +1808,121 @@ drop:
 	return 0;
 }
 
+/* We can only early demux multicast if there is a single matching socket.
+ * If more than one socket found returns NULL
+ */
+static struct sock *__udp4_lib_mcast_demux_lookup(struct net *net,
+						  __be16 loc_port, __be32 loc_addr,
+						  __be16 rmt_port, __be32 rmt_addr,
+						  int dif)
+{
+	struct sock *sk, *result;
+	struct hlist_nulls_node *node;
+	unsigned short hnum = ntohs(loc_port);
+	unsigned int count, slot = udp_hashfn(net, hnum, udp_table.mask);
+	struct udp_hslot *hslot = &udp_table.hash[slot];
+
+	rcu_read_lock();
+begin:
+	count = 0;
+	result = NULL;
+	sk_nulls_for_each_rcu(sk, node, &hslot->head) {
+		if (__udp_is_mcast_sock(net, sk,
+					loc_port, loc_addr,
+					rmt_port, rmt_addr,
+					dif, hnum)) {
+			result = sk;
+			++count;
+		}
+	}
+	/*
+	 * if the nulls value we got at the end of this lookup is
+	 * not the expected one, we must restart lookup.
+	 * We probably met an item that was moved to another chain.
+	 */
+	if (get_nulls_value(node) != slot)
+		goto begin;
+
+	if (result) {
+		if (count != 1 ||
+		    unlikely(!atomic_inc_not_zero_hint(&result->sk_refcnt, 2)))
+			result = NULL;
+	}
+	rcu_read_unlock();
+	return result;
+}
+
+/* For unicast we should only early demux connected sockets or we can
+ * break forwarding setups.  The chains here can be long so only check
+ * if the first socket is an exact match and if not move on.
+ */
+static struct sock *__udp4_lib_demux_lookup(struct net *net,
+					    __be16 loc_port, __be32 loc_addr,
+					    __be16 rmt_port, __be32 rmt_addr,
+					    int dif)
+{
+	struct sock *sk, *result;
+	struct hlist_nulls_node *node;
+	unsigned short hnum = ntohs(loc_port);
+	unsigned int slot = udp_hashfn(net, hnum, udp_table.mask);
+	struct udp_hslot *hslot = &udp_table.hash[slot];
+	INET_ADDR_COOKIE(acookie, rmt_addr, loc_addr)
+	const __portpair ports = INET_COMBINED_PORTS(rmt_port, hnum);
+
+	rcu_read_lock();
+	result = NULL;
+	sk_nulls_for_each_rcu(sk, node, &hslot->head) {
+		if (INET_MATCH(sk, net, acookie,
+			       rmt_addr, loc_addr, ports, dif))
+			result = sk;
+		/* Only check first socket in chain */
+		break;
+	}
+
+	if (result) {
+		if (unlikely(!atomic_inc_not_zero_hint(&result->sk_refcnt, 2)))
+			result = NULL;
+	}
+	rcu_read_unlock();
+	return result;
+}
+
+void udp_v4_early_demux(struct sk_buff *skb)
+{
+	const struct iphdr *iph = ip_hdr(skb);
+	const struct udphdr *uh = udp_hdr(skb);
+	struct sock *sk;
+	struct dst_entry *dst;
+	struct net *net = dev_net(skb->dev);
+	int dif = skb->dev->ifindex;
+
+	/* validate the packet */
+	if (!pskb_may_pull(skb, skb_transport_offset(skb) + sizeof(struct udphdr)))
+		return;
+
+	if (skb->pkt_type == PACKET_BROADCAST ||
+	    skb->pkt_type == PACKET_MULTICAST)
+		sk = __udp4_lib_mcast_demux_lookup(net, uh->dest, iph->daddr,
+						   uh->source, iph->saddr, dif);
+	else if (skb->pkt_type == PACKET_HOST)
+		sk = __udp4_lib_demux_lookup(net, uh->dest, iph->daddr,
+					     uh->source, iph->saddr, dif);
+	else
+		return;
+
+	if (!sk)
+		return;
+
+	skb->sk = sk;
+	skb->destructor = sock_edemux;
+	dst = sk->sk_rx_dst;
+
+	if (dst)
+		dst = dst_check(dst, 0);
+	if (dst)
+		skb_dst_set_noref(skb, dst);
+}
+
 int udp_rcv(struct sk_buff *skb)
 {
 	return __udp4_lib_rcv(skb, &udp_table, IPPROTO_UDP);
-- 
1.7.7.6
