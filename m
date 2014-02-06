From: Tom Herbert <therbert@google.com>
Subject: [RFC PATCH] udp4: Don't take socket reference in receive path
Date: Thu, 6 Feb 2014 11:58:26 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1402061154580.17707@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org, edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f73.google.com ([209.85.220.73]:58899 "EHLO
	mail-pa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756611AbaBFT63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 14:58:29 -0500
Received: by mail-pa0-f73.google.com with SMTP id kp14so192823pab.4
        for <netdev@vger.kernel.org>; Thu, 06 Feb 2014 11:58:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The reference counting in the UDP receive path is quite expensive for
a socket that is share amoungst CPUs. This is probably true for normal
sockets, but really is painful when just using the socket for
receive encapsulation.

udp4_lib_lookup always takes a socket reference, and we also put back
the reference after calling udp_queue_rcv_skb in the normal receive
path, so the need for taking the reference seems to be to hold the
socket after doing rcu_read_unlock. This patch modifies udp_lib_lookup
to optionally take a reference and is always called with rcu_read_lock.
In udp4_lib_rcv we call lib_lookup and udp_queue_rcv under the
rcu_read_lock but without having taken the reference.

Requesting comments because I suspect there are nuances to this!

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv4/udp.c | 90 ++++++++++++++++++++++++++++++++++++++++------------------
 1 file changed, 62 insertions(+), 28 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 48d8cb2..6043a2f 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -424,7 +424,8 @@ static unsigned int udp_ehashfn(struct net *net, const __be32 laddr,
 static struct sock *udp4_lib_lookup2(struct net *net,
 		__be32 saddr, __be16 sport,
 		__be32 daddr, unsigned int hnum, int dif,
-		struct udp_hslot *hslot2, unsigned int slot2)
+		struct udp_hslot *hslot2, unsigned int slot2,
+		bool get_ref)
 {
 	struct sock *sk, *result;
 	struct hlist_nulls_node *node;
@@ -461,12 +462,20 @@ begin:
 	if (get_nulls_value(node) != slot2)
 		goto begin;
 	if (result) {
-		if (unlikely(!atomic_inc_not_zero_hint(&result->sk_refcnt, 2)))
-			result = NULL;
-		else if (unlikely(compute_score2(result, net, saddr, sport,
-				  daddr, hnum, dif) < badness)) {
-			sock_put(result);
-			goto begin;
+		if (get_ref) {
+			if (unlikely(!atomic_inc_not_zero_hint(&result->sk_refcnt, 2)))
+				result = NULL;
+			else if (unlikely(compute_score2(result, net, saddr, sport,
+-                                 daddr, hnum, dif) < badness)) {
+				sock_put(result);
+				goto begin;
+			}
+		} else {
+			if (unlikely(atomic_read(&result->sk_refcnt) == 0))
+				result = NULL;
+			else if (unlikely(compute_score2(result, net, saddr, sport,
+-                                 daddr, hnum, dif) < badness))
+				goto begin;
 		}
 	}
 	return result;
@@ -475,9 +484,10 @@ begin:
 /* UDP is nearly always wildcards out the wazoo, it makes no sense to try
  * harder than this. -DaveM
  */
-struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
+/* called with read_rcu_lock() */
+struct sock *___udp4_lib_lookup(struct net *net, __be32 saddr,
 		__be16 sport, __be32 daddr, __be16 dport,
-		int dif, struct udp_table *udptable)
+		int dif, struct udp_table *udptable, bool get_ref)
 {
 	struct sock *sk, *result;
 	struct hlist_nulls_node *node;
@@ -487,7 +497,6 @@ struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 	int score, badness, matches = 0, reuseport = 0;
 	u32 hash = 0;
 
-	rcu_read_lock();
 	if (hslot->count > 10) {
 		hash2 = udp4_portaddr_hash(net, daddr, hnum);
 		slot2 = hash2 & udptable->mask;
@@ -497,7 +506,7 @@ struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 
 		result = udp4_lib_lookup2(net, saddr, sport,
 					  daddr, hnum, dif,
-					  hslot2, slot2);
+					  hslot2, slot2, get_ref);
 		if (!result) {
 			hash2 = udp4_portaddr_hash(net, htonl(INADDR_ANY), hnum);
 			slot2 = hash2 & udptable->mask;
@@ -507,9 +516,8 @@ struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 
 			result = udp4_lib_lookup2(net, saddr, sport,
 						  htonl(INADDR_ANY), hnum, dif,
-						  hslot2, slot2);
+						  hslot2, slot2, get_ref);
 		}
-		rcu_read_unlock();
 		return result;
 	}
 begin:
@@ -543,28 +551,50 @@ begin:
 		goto begin;
 
 	if (result) {
-		if (unlikely(!atomic_inc_not_zero_hint(&result->sk_refcnt, 2)))
-			result = NULL;
-		else if (unlikely(compute_score(result, net, saddr, hnum, sport,
-				  daddr, dport, dif) < badness)) {
-			sock_put(result);
-			goto begin;
+		if (get_ref) {
+			if (unlikely(!atomic_inc_not_zero_hint(&result->sk_refcnt, 2)))
+				result = NULL;
+			else if (unlikely(compute_score(result, net, saddr, hnum, sport,
+					  daddr, dport, dif) < badness)) {
+				sock_put(result);
+				goto begin;
+			}
+		} else {
+			if (unlikely(atomic_read(&result->sk_refcnt) == 0))
+				result = NULL;
+			else if (unlikely(compute_score(result, net, saddr, hnum, sport,
+					  daddr, dport, dif) < badness))
+				goto begin;
 		}
 	}
+	return result;
+}
+
+struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
+		__be16 sport, __be32 daddr, __be16 dport,
+		int dif, struct udp_table *udptable)
+{
+	struct sock *result;
+
+	rcu_read_lock();
+	result = ___udp4_lib_lookup(net, saddr, sport, daddr, dport, dif, udptable, true);
 	rcu_read_unlock();
+
 	return result;
 }
+
 EXPORT_SYMBOL_GPL(__udp4_lib_lookup);
 
+/* called with read_rcu_lock() */
 static inline struct sock *__udp4_lib_lookup_skb(struct sk_buff *skb,
 						 __be16 sport, __be16 dport,
 						 struct udp_table *udptable)
 {
 	const struct iphdr *iph = ip_hdr(skb);
 
-	return __udp4_lib_lookup(dev_net(skb_dst(skb)->dev), iph->saddr, sport,
+	return ___udp4_lib_lookup(dev_net(skb_dst(skb)->dev), iph->saddr, sport,
 				 iph->daddr, dport, inet_iif(skb),
-				 udptable);
+				 udptable, false);
 }
 
 struct sock *udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
@@ -1755,19 +1785,21 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 		if (ret > 0)
 			return -ret;
 		return 0;
-	} else {
-		if (rt->rt_flags & (RTCF_BROADCAST|RTCF_MULTICAST))
-			return __udp4_lib_mcast_deliver(net, skb, uh,
-					saddr, daddr, udptable);
-
-		sk = __udp4_lib_lookup_skb(skb, uh->source, uh->dest, udptable);
 	}
 
+
+	if (rt->rt_flags & (RTCF_BROADCAST|RTCF_MULTICAST))
+		return __udp4_lib_mcast_deliver(net, skb, uh,
+				saddr, daddr, udptable);
+
+	rcu_read_lock();
+	sk = __udp4_lib_lookup_skb(skb, uh->source, uh->dest, udptable);
+
 	if (sk != NULL) {
 		int ret;
 
 		ret = udp_queue_rcv_skb(sk, skb);
-		sock_put(sk);
+		rcu_read_unlock();
 
 		/* a return value > 0 means to resubmit the input, but
 		 * it wants the return to be -protocol, or 0
@@ -1777,6 +1809,8 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 		return 0;
 	}
 
+	rcu_read_unlock();
+
 	if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb))
 		goto drop;
 	nf_reset(skb);
-- 
1.9.0.rc1.175.g0b1dcb5
