From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC 2/9] udp: Add noreference lookup functions
Date: Wed, 23 Mar 2016 15:36:51 -0700
Message-ID: <1458772618-845742-3-git-send-email-tom@herbertland.com>
References: <1458772618-845742-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:37681 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751769AbcCWWkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 18:40:31 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u2NMdA7d008859
	for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 15:40:30 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 21uet8rvfv-8
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 15:40:30 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 c83c1b42f14711e5ae670002c9521c9e-781fb3f0 for <netdev@vger.kernel.org>;	Wed,
 23 Mar 2016 15:37:11 -0700
In-Reply-To: <1458772618-845742-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patches adds udp6_lib_lookup_skb_noref, udp4_lib_lookup_skb_noref
and related support to allow a caller to lookup a UDP socket
without automatically taking a reference. The lookup and caller
use of the socket must be done under rcu_read_lock.

This feature will be used in a fast receive encapsulation path and
also when performing GRO through callout in the UDP socket.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/udp.h | 12 ++++++++
 net/ipv4/udp.c    | 88 +++++++++++++++++++++++++++++++++++++++----------------
 net/ipv6/udp.c    | 85 ++++++++++++++++++++++++++++++++++++++---------------
 3 files changed, 136 insertions(+), 49 deletions(-)

diff --git a/include/net/udp.h b/include/net/udp.h
index 92927f7..2a6f7b2 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -260,6 +260,8 @@ struct sock *udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
 struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
 			       __be32 daddr, __be16 dport, int dif,
 			       struct udp_table *tbl, struct sk_buff *skb);
+struct sock *udp4_lib_lookup_skb_noref(struct sk_buff *skb,
+				       __be16 sport, __be16 dport);
 struct sock *udp6_lib_lookup(struct net *net,
 			     const struct in6_addr *saddr, __be16 sport,
 			     const struct in6_addr *daddr, __be16 dport,
@@ -269,6 +271,16 @@ struct sock *__udp6_lib_lookup(struct net *net,
 			       const struct in6_addr *daddr, __be16 dport,
 			       int dif, struct udp_table *tbl,
 			       struct sk_buff *skb);
+struct sock *udp6_lib_lookup_skb_noref(struct sk_buff *skb,
+				       __be16 sport, __be16 dport);
+
+static inline struct sock *udp_get_ref(struct sock *sk)
+{
+	if (unlikely(!atomic_inc_not_zero_hint(&sk->sk_refcnt, 2)))
+		return NULL;
+
+	return sk;
+}
 
 /*
  * 	SNMP statistics for UDP and UDP-Lite
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 836abe5..324d008 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -494,7 +494,7 @@ static struct sock *udp4_lib_lookup2(struct net *net,
 		__be32 saddr, __be16 sport,
 		__be32 daddr, unsigned int hnum, int dif,
 		struct udp_hslot *hslot2, unsigned int slot2,
-		struct sk_buff *skb)
+		struct sk_buff *skb, bool get_ref)
 {
 	struct sock *sk, *result;
 	struct hlist_nulls_node *node;
@@ -544,12 +544,14 @@ begin:
 		goto begin;
 	if (result) {
 found:
-		if (unlikely(!atomic_inc_not_zero_hint(&result->sk_refcnt, 2)))
-			result = NULL;
-		else if (unlikely(compute_score2(result, net, saddr, sport,
-				  daddr, hnum, dif) < badness)) {
-			sock_put(result);
-			goto begin;
+		if (get_ref) {
+			if (!udp_get_ref(result)) {
+				result = NULL;
+			} else if (unlikely(compute_score2(result, net, saddr,
+					  sport, daddr, hnum, dif) < badness)) {
+				sock_put(result);
+				goto begin;
+			}
 		}
 	}
 	return result;
@@ -558,9 +560,11 @@ found:
 /* UDP is nearly always wildcards out the wazoo, it makes no sense to try
  * harder than this. -DaveM
  */
-struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
+/* called with read_rcu_lock() */
+static struct sock *___udp4_lib_lookup(struct net *net, __be32 saddr,
 		__be16 sport, __be32 daddr, __be16 dport,
-		int dif, struct udp_table *udptable, struct sk_buff *skb)
+		int dif, struct udp_table *udptable, struct sk_buff *skb,
+		bool get_ref)
 {
 	struct sock *sk, *result;
 	struct hlist_nulls_node *node;
@@ -571,7 +575,6 @@ struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 	bool select_ok = true;
 	u32 hash = 0;
 
-	rcu_read_lock();
 	if (hslot->count > 10) {
 		hash2 = udp4_portaddr_hash(net, daddr, hnum);
 		slot2 = hash2 & udptable->mask;
@@ -581,7 +584,7 @@ struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 
 		result = udp4_lib_lookup2(net, saddr, sport,
 					  daddr, hnum, dif,
-					  hslot2, slot2, skb);
+					  hslot2, slot2, skb, get_ref);
 		if (!result) {
 			hash2 = udp4_portaddr_hash(net, htonl(INADDR_ANY), hnum);
 			slot2 = hash2 & udptable->mask;
@@ -591,9 +594,8 @@ struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 
 			result = udp4_lib_lookup2(net, saddr, sport,
 						  htonl(INADDR_ANY), hnum, dif,
-						  hslot2, slot2, skb);
+						  hslot2, slot2, skb, get_ref);
 		}
-		rcu_read_unlock();
 		return result;
 	}
 begin:
@@ -639,19 +641,43 @@ begin:
 
 	if (result) {
 found:
-		if (unlikely(!atomic_inc_not_zero_hint(&result->sk_refcnt, 2)))
-			result = NULL;
-		else if (unlikely(compute_score(result, net, saddr, hnum, sport,
-				  daddr, dport, dif) < badness)) {
-			sock_put(result);
-			goto begin;
+		if (get_ref) {
+			if (!udp_get_ref(result)) {
+				result = NULL;
+			} else if (unlikely(compute_score(result, net, saddr,
+					  hnum, sport, daddr, dport,
+					  dif) < badness)) {
+				sock_put(result);
+				goto begin;
+			}
 		}
 	}
-	rcu_read_unlock();
 	return result;
 }
+
+struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
+		__be16 sport, __be32 daddr, __be16 dport,
+		int dif, struct udp_table *udptable, struct sk_buff *skb)
+{
+	struct sock *sk;
+
+	rcu_read_lock();
+	sk = ___udp4_lib_lookup(net, saddr, sport, daddr, dport, dif, udptable,
+				skb, true);
+	rcu_read_unlock();
+
+	return sk;
+}
 EXPORT_SYMBOL_GPL(__udp4_lib_lookup);
 
+struct sock *udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
+			     __be32 daddr, __be16 dport, int dif)
+{
+	return __udp4_lib_lookup(net, saddr, sport, daddr, dport, dif,
+				 &udp_table, NULL);
+}
+EXPORT_SYMBOL_GPL(udp4_lib_lookup);
+
 static inline struct sock *__udp4_lib_lookup_skb(struct sk_buff *skb,
 						 __be16 sport, __be16 dport,
 						 struct udp_table *udptable)
@@ -663,13 +689,24 @@ static inline struct sock *__udp4_lib_lookup_skb(struct sk_buff *skb,
 				 udptable, skb);
 }
 
-struct sock *udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
-			     __be32 daddr, __be16 dport, int dif)
+static inline struct sock *__udp4_lib_lookup_skb_noref(struct sk_buff *skb,
+					__be16 sport, __be16 dport,
+					struct udp_table *udptable)
 {
-	return __udp4_lib_lookup(net, saddr, sport, daddr, dport, dif,
-				 &udp_table, NULL);
+	const struct iphdr *iph = ip_hdr(skb);
+	struct net_device *dev = skb_dst(skb) ? skb_dst(skb)->dev : skb->dev;
+
+	return ___udp4_lib_lookup(dev_net(dev), iph->saddr, sport,
+				  iph->daddr, dport, inet_iif(skb),
+				  udptable, skb, false);
 }
-EXPORT_SYMBOL_GPL(udp4_lib_lookup);
+
+struct sock *udp4_lib_lookup_skb_noref(struct sk_buff *skb,
+				       __be16 sport, __be16 dport)
+{
+	return __udp4_lib_lookup_skb_noref(skb, sport, dport, &udp_table);
+}
+EXPORT_SYMBOL_GPL(udp4_lib_lookup_skb_noref);
 
 static inline bool __udp_is_mcast_sock(struct net *net, struct sock *sk,
 				       __be16 loc_port, __be32 loc_addr,
@@ -1563,7 +1600,6 @@ static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	}
 
 	return 0;
-
 }
 
 static struct static_key udp_encap_needed __read_mostly;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index fd25e44..281469c 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -210,7 +210,7 @@ static struct sock *udp6_lib_lookup2(struct net *net,
 		const struct in6_addr *saddr, __be16 sport,
 		const struct in6_addr *daddr, unsigned int hnum, int dif,
 		struct udp_hslot *hslot2, unsigned int slot2,
-		struct sk_buff *skb)
+		struct sk_buff *skb, bool get_ref)
 {
 	struct sock *sk, *result;
 	struct hlist_nulls_node *node;
@@ -261,22 +261,25 @@ begin:
 
 	if (result) {
 found:
-		if (unlikely(!atomic_inc_not_zero_hint(&result->sk_refcnt, 2)))
-			result = NULL;
-		else if (unlikely(compute_score2(result, net, saddr, sport,
-				  daddr, hnum, dif) < badness)) {
-			sock_put(result);
-			goto begin;
+		if (get_ref) {
+			if (!udp_get_ref(result)) {
+				result = NULL;
+			} else if (unlikely(compute_score2(result, net, saddr,
+					  sport, daddr, hnum, dif) < badness)) {
+				sock_put(result);
+				goto begin;
+			}
 		}
 	}
 	return result;
 }
 
-struct sock *__udp6_lib_lookup(struct net *net,
-				      const struct in6_addr *saddr, __be16 sport,
-				      const struct in6_addr *daddr, __be16 dport,
-				      int dif, struct udp_table *udptable,
-				      struct sk_buff *skb)
+/* called with read_rcu_lock() */
+struct sock *___udp6_lib_lookup(struct net *net,
+				const struct in6_addr *saddr, __be16 sport,
+				const struct in6_addr *daddr, __be16 dport,
+				int dif, struct udp_table *udptable,
+				struct sk_buff *skb, bool get_ref)
 {
 	struct sock *sk, *result;
 	struct hlist_nulls_node *node;
@@ -287,7 +290,6 @@ struct sock *__udp6_lib_lookup(struct net *net,
 	bool select_ok = true;
 	u32 hash = 0;
 
-	rcu_read_lock();
 	if (hslot->count > 10) {
 		hash2 = udp6_portaddr_hash(net, daddr, hnum);
 		slot2 = hash2 & udptable->mask;
@@ -297,7 +299,7 @@ struct sock *__udp6_lib_lookup(struct net *net,
 
 		result = udp6_lib_lookup2(net, saddr, sport,
 					  daddr, hnum, dif,
-					  hslot2, slot2, skb);
+					  hslot2, slot2, skb, get_ref);
 		if (!result) {
 			hash2 = udp6_portaddr_hash(net, &in6addr_any, hnum);
 			slot2 = hash2 & udptable->mask;
@@ -307,9 +309,8 @@ struct sock *__udp6_lib_lookup(struct net *net,
 
 			result = udp6_lib_lookup2(net, saddr, sport,
 						  &in6addr_any, hnum, dif,
-						  hslot2, slot2, skb);
+						  hslot2, slot2, skb, get_ref);
 		}
-		rcu_read_unlock();
 		return result;
 	}
 begin:
@@ -354,17 +355,35 @@ begin:
 
 	if (result) {
 found:
-		if (unlikely(!atomic_inc_not_zero_hint(&result->sk_refcnt, 2)))
-			result = NULL;
-		else if (unlikely(compute_score(result, net, hnum, saddr, sport,
-					daddr, dport, dif) < badness)) {
-			sock_put(result);
-			goto begin;
+		if (get_ref) {
+			if (!udp_get_ref(result)) {
+				result = NULL;
+			} else if (unlikely(compute_score(result, net, hnum,
+						saddr, sport, daddr, dport,
+						dif) < badness)) {
+				sock_put(result);
+				goto begin;
+			}
 		}
 	}
-	rcu_read_unlock();
 	return result;
 }
+
+struct sock *__udp6_lib_lookup(struct net *net,
+			       const struct in6_addr *saddr, __be16 sport,
+			       const struct in6_addr *daddr, __be16 dport,
+			       int dif, struct udp_table *udptable,
+			       struct sk_buff *skb)
+{
+	struct sock *sk;
+
+	rcu_read_lock();
+	sk = ___udp6_lib_lookup(net, saddr, sport, daddr, dport, dif,
+				udptable, skb, true);
+	rcu_read_unlock();
+
+	return sk;
+}
 EXPORT_SYMBOL_GPL(__udp6_lib_lookup);
 
 static struct sock *__udp6_lib_lookup_skb(struct sk_buff *skb,
@@ -389,6 +408,26 @@ struct sock *udp6_lib_lookup(struct net *net, const struct in6_addr *saddr, __be
 }
 EXPORT_SYMBOL_GPL(udp6_lib_lookup);
 
+static inline struct sock *__udp6_lib_lookup_skb_noref(struct sk_buff *skb,
+						       __be16 sport,
+						       __be16 dport,
+						       struct udp_table *udptable)
+{
+	const struct ipv6hdr *iph = ipv6_hdr(skb);
+	struct net_device *dev = skb_dst(skb) ? skb_dst(skb)->dev : skb->dev;
+
+	return ___udp6_lib_lookup(dev_net(dev), &iph->saddr, sport,
+				  &iph->daddr, dport, inet6_iif(skb),
+				  udptable, skb, false);
+}
+
+struct sock *udp6_lib_lookup_skb_noref(struct sk_buff *skb, __be16 sport,
+				       __be16 dport)
+{
+	return __udp6_lib_lookup_skb_noref(skb, sport, dport, &udp_table);
+}
+EXPORT_SYMBOL(udp6_lib_lookup_skb_noref);
+
 /*
  *	This should be easy, if there is something there we
  *	return it, otherwise we block.
-- 
2.8.0.rc2
