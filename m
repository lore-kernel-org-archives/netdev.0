From: raj@tardy.usa.hp.com (Rick Jones)
Subject: [PATCH v3 net-next] udp: Increment UDP_MIB_IGNOREDMULTI for arriving unmatched multicasts
Date: Thu,  6 Nov 2014 10:36:15 -0800 (PST)
Message-ID: <20141106183615.A8DA829007D9@tardy>
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3426.houston.hp.com ([15.201.208.54]:14314 "EHLO
	g4t3426.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751692AbaKFSgS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 13:36:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Rick Jones <rick.jones2@hp.com>

As NIC multicast filtering isn't perfect, and some platforms are
quite content to spew broadcasts, we should not trigger an event
for skb:kfree_skb when we do not have a match for such an incoming
datagram.  We do though want to avoid sweeping the matter under the
rug entirely, so increment a suitable statistic.

This incorporates feedback from David L. Stevens, Karl Neiss and Eric
Dumazet.

Signed-off-by: Rick Jones <rick.jones2@hp.com>

---

Noticed __udp4_lib_mcast_deliver showing-up in a perf dropped packet
profile on a system sitting on a network with a bunch of Windows boxes
sending what they are fond of sending.

Verified that the new UDP_MIB_IGNOREDMULTI increments when ignored
datagrams are encountered, but was unable to cross the i's and dot
the t's of perf because the perf built from the tree at the time
wasn't happy in general.  Also hit a test system with some netperf
multicast UDP_STREAM and UDP_RR testing but that is the extent of 
the testing performed.

diff --git a/include/uapi/linux/snmp.h b/include/uapi/linux/snmp.h
index df40137..30f541b 100644
--- a/include/uapi/linux/snmp.h
+++ b/include/uapi/linux/snmp.h
@@ -156,6 +156,7 @@ enum
 	UDP_MIB_RCVBUFERRORS,			/* RcvbufErrors */
 	UDP_MIB_SNDBUFERRORS,			/* SndbufErrors */
 	UDP_MIB_CSUMERRORS,			/* InCsumErrors */
+	UDP_MIB_IGNOREDMULTI,			/* IgnoredMulti */
 	__UDP_MIB_MAX
 };
 
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 8e3eb39..5c5450c 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -181,6 +181,7 @@ static const struct snmp_mib snmp4_udp_list[] = {
 	SNMP_MIB_ITEM("RcvbufErrors", UDP_MIB_RCVBUFERRORS),
 	SNMP_MIB_ITEM("SndbufErrors", UDP_MIB_SNDBUFERRORS),
 	SNMP_MIB_ITEM("InCsumErrors", UDP_MIB_CSUMERRORS),
+	SNMP_MIB_ITEM("IgnoredMulti", UDP_MIB_IGNOREDMULTI),
 	SNMP_MIB_SENTINEL
 };
 
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index cd0db54..1215f89 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1647,7 +1647,8 @@ static void udp_sk_rx_dst_set(struct sock *sk, struct dst_entry *dst)
 static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 				    struct udphdr  *uh,
 				    __be32 saddr, __be32 daddr,
-				    struct udp_table *udptable)
+				    struct udp_table *udptable,
+				    int proto)
 {
 	struct sock *sk, *stack[256 / sizeof(struct sock *)];
 	struct hlist_nulls_node *node;
@@ -1656,6 +1657,7 @@ static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 	int dif = skb->dev->ifindex;
 	unsigned int count = 0, offset = offsetof(typeof(*sk), sk_nulls_node);
 	unsigned int hash2 = 0, hash2_any = 0, use_hash2 = (hslot->count > 10);
+	unsigned int inner_flushed = 0;
 
 	if (use_hash2) {
 		hash2_any = udp4_portaddr_hash(net, htonl(INADDR_ANY), hnum) &
@@ -1674,6 +1676,7 @@ start_lookup:
 					dif, hnum)) {
 			if (unlikely(count == ARRAY_SIZE(stack))) {
 				flush_stack(stack, count, skb, ~0);
+				inner_flushed = 1;
 				count = 0;
 			}
 			stack[count++] = sk;
@@ -1695,7 +1698,10 @@ start_lookup:
 	if (count) {
 		flush_stack(stack, count, skb, count - 1);
 	} else {
-		kfree_skb(skb);
+		if (!inner_flushed)
+			UDP_INC_STATS_BH(net, UDP_MIB_IGNOREDMULTI,
+					 proto == IPPROTO_UDPLITE);
+		consume_skb(skb);
 	}
 	return 0;
 }
@@ -1780,7 +1786,7 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 	} else {
 		if (rt->rt_flags & (RTCF_BROADCAST|RTCF_MULTICAST))
 			return __udp4_lib_mcast_deliver(net, skb, uh,
-					saddr, daddr, udptable);
+					saddr, daddr, udptable, proto);
 
 		sk = __udp4_lib_lookup_skb(skb, uh->source, uh->dest, udptable);
 	}
diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index 1752cd0..679253d0 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -136,6 +136,7 @@ static const struct snmp_mib snmp6_udp6_list[] = {
 	SNMP_MIB_ITEM("Udp6RcvbufErrors", UDP_MIB_RCVBUFERRORS),
 	SNMP_MIB_ITEM("Udp6SndbufErrors", UDP_MIB_SNDBUFERRORS),
 	SNMP_MIB_ITEM("Udp6InCsumErrors", UDP_MIB_CSUMERRORS),
+	SNMP_MIB_ITEM("Udp6IgnoredMulti", UDP_MIB_IGNOREDMULTI),
 	SNMP_MIB_SENTINEL
 };
 
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index f6ba535..d80f21e 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -771,7 +771,7 @@ static void udp6_csum_zero_error(struct sk_buff *skb)
  */
 static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 		const struct in6_addr *saddr, const struct in6_addr *daddr,
-		struct udp_table *udptable)
+		struct udp_table *udptable, int proto)
 {
 	struct sock *sk, *stack[256 / sizeof(struct sock *)];
 	const struct udphdr *uh = udp_hdr(skb);
@@ -781,6 +781,7 @@ static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 	int dif = inet6_iif(skb);
 	unsigned int count = 0, offset = offsetof(typeof(*sk), sk_nulls_node);
 	unsigned int hash2 = 0, hash2_any = 0, use_hash2 = (hslot->count > 10);
+	int inner_flushed = 0;
 
 	if (use_hash2) {
 		hash2_any = udp6_portaddr_hash(net, &in6addr_any, hnum) &
@@ -803,6 +804,7 @@ start_lookup:
 		    (uh->check || udp_sk(sk)->no_check6_rx)) {
 			if (unlikely(count == ARRAY_SIZE(stack))) {
 				flush_stack(stack, count, skb, ~0);
+				inner_flushed = 1;
 				count = 0;
 			}
 			stack[count++] = sk;
@@ -821,7 +823,10 @@ start_lookup:
 	if (count) {
 		flush_stack(stack, count, skb, count - 1);
 	} else {
-		kfree_skb(skb);
+		if (!inner_flushed)
+			UDP_INC_STATS_BH(net, UDP_MIB_IGNOREDMULTI,
+					 proto == IPPROTO_UDPLITE);
+		consume_skb(skb);
 	}
 	return 0;
 }
@@ -873,7 +878,7 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 	 */
 	if (ipv6_addr_is_multicast(daddr))
 		return __udp6_lib_mcast_deliver(net, skb,
-				saddr, daddr, udptable);
+				saddr, daddr, udptable, proto);
 
 	/* Unicast */
 
