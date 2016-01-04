From: Craig Gallek <kraigatgoog@gmail.com>
Subject: [PATCH v4 net-next 2/4] soreuseport: fast reuseport UDP socket selection
Date: Mon,  4 Jan 2016 17:41:46 -0500
Message-ID: <1451947308-7867-3-git-send-email-kraigatgoog@gmail.com>
References: <1451947308-7867-1-git-send-email-kraigatgoog@gmail.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:36092 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753627AbcADWly (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 17:41:54 -0500
Received: by mail-qg0-f42.google.com with SMTP id e32so175418579qgf.3
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 14:41:53 -0800 (PST)
In-Reply-To: <1451947308-7867-1-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraig@google.com>

Include a struct sock_reuseport instance when a UDP socket binds to
a specific address for the first time with the reuseport flag set.
When selecting a socket for an incoming UDP packet, use the information
available in sock_reuseport if present.

This required adding an additional field to the UDP source address
equality function to differentiate between exact and wildcard matches.
The original use case allowed wildcard matches when checking for
existing port uses during bind.  The new use case of adding a socket
to a reuseport group requires exact address matching.

Performance test (using a machine with 2 CPU sockets and a total of
48 cores):  Create reuseport groups of varying size.  Use one socket
from this group per user thread (pinning each thread to a different
core) calling recvmmsg in a tight loop.  Record number of messages
received per second while saturating a 10G link.
  10 sockets: 18% increase (~2.8M -> 3.3M pkts/s)
  20 sockets: 14% increase (~2.9M -> 3.3M pkts/s)
  40 sockets: 13% increase (~3.0M -> 3.4M pkts/s)

This work is based off a similar implementation written by
Ying Cai <ycai@google.com> for implementing policy-based reuseport
selection.

Signed-off-by: Craig Gallek <kraig@google.com>
---
 include/net/addrconf.h           |   3 +-
 include/net/udp.h                |   2 +-
 net/ipv4/udp.c                   | 119 +++++++++++++++++++++++++++++++--------
 net/ipv6/inet6_connection_sock.c |   4 +-
 net/ipv6/udp.c                   |  48 +++++++++++++---
 5 files changed, 141 insertions(+), 35 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 78003df..47f52d3 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -87,7 +87,8 @@ int __ipv6_get_lladdr(struct inet6_dev *idev, struct in6_addr *addr,
 		      u32 banned_flags);
 int ipv6_get_lladdr(struct net_device *dev, struct in6_addr *addr,
 		    u32 banned_flags);
-int ipv6_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2);
+int ipv6_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2,
+			 bool match_wildcard);
 void addrconf_join_solict(struct net_device *dev, const struct in6_addr *addr);
 void addrconf_leave_solict(struct inet6_dev *idev, const struct in6_addr *addr);
 
diff --git a/include/net/udp.h b/include/net/udp.h
index 6d4ed18..3b5d7f9 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -191,7 +191,7 @@ static inline void udp_lib_close(struct sock *sk, long timeout)
 }
 
 int udp_lib_get_port(struct sock *sk, unsigned short snum,
-		     int (*)(const struct sock *, const struct sock *),
+		     int (*)(const struct sock *, const struct sock *, bool),
 		     unsigned int hash2_nulladdr);
 
 u32 udp_flow_hashrnd(void);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index ac14ae4..762b01f 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -113,6 +113,7 @@
 #include <trace/events/skb.h>
 #include <net/busy_poll.h>
 #include "udp_impl.h"
+#include <net/sock_reuseport.h>
 
 struct udp_table udp_table __read_mostly;
 EXPORT_SYMBOL(udp_table);
@@ -137,7 +138,8 @@ static int udp_lib_lport_inuse(struct net *net, __u16 num,
 			       unsigned long *bitmap,
 			       struct sock *sk,
 			       int (*saddr_comp)(const struct sock *sk1,
-						 const struct sock *sk2),
+						 const struct sock *sk2,
+						 bool match_wildcard),
 			       unsigned int log)
 {
 	struct sock *sk2;
@@ -152,8 +154,9 @@ static int udp_lib_lport_inuse(struct net *net, __u16 num,
 		    (!sk2->sk_bound_dev_if || !sk->sk_bound_dev_if ||
 		     sk2->sk_bound_dev_if == sk->sk_bound_dev_if) &&
 		    (!sk2->sk_reuseport || !sk->sk_reuseport ||
+		     rcu_access_pointer(sk->sk_reuseport_cb) ||
 		     !uid_eq(uid, sock_i_uid(sk2))) &&
-		    saddr_comp(sk, sk2)) {
+		    saddr_comp(sk, sk2, true)) {
 			if (!bitmap)
 				return 1;
 			__set_bit(udp_sk(sk2)->udp_port_hash >> log, bitmap);
@@ -170,7 +173,8 @@ static int udp_lib_lport_inuse2(struct net *net, __u16 num,
 				struct udp_hslot *hslot2,
 				struct sock *sk,
 				int (*saddr_comp)(const struct sock *sk1,
-						  const struct sock *sk2))
+						  const struct sock *sk2,
+						  bool match_wildcard))
 {
 	struct sock *sk2;
 	struct hlist_nulls_node *node;
@@ -186,8 +190,9 @@ static int udp_lib_lport_inuse2(struct net *net, __u16 num,
 		    (!sk2->sk_bound_dev_if || !sk->sk_bound_dev_if ||
 		     sk2->sk_bound_dev_if == sk->sk_bound_dev_if) &&
 		    (!sk2->sk_reuseport || !sk->sk_reuseport ||
+		     rcu_access_pointer(sk->sk_reuseport_cb) ||
 		     !uid_eq(uid, sock_i_uid(sk2))) &&
-		    saddr_comp(sk, sk2)) {
+		    saddr_comp(sk, sk2, true)) {
 			res = 1;
 			break;
 		}
@@ -196,6 +201,35 @@ static int udp_lib_lport_inuse2(struct net *net, __u16 num,
 	return res;
 }
 
+static int udp_reuseport_add_sock(struct sock *sk, struct udp_hslot *hslot,
+				  int (*saddr_same)(const struct sock *sk1,
+						    const struct sock *sk2,
+						    bool match_wildcard))
+{
+	struct net *net = sock_net(sk);
+	struct hlist_nulls_node *node;
+	kuid_t uid = sock_i_uid(sk);
+	struct sock *sk2;
+
+	sk_nulls_for_each(sk2, node, &hslot->head) {
+		if (net_eq(sock_net(sk2), net) &&
+		    sk2 != sk &&
+		    sk2->sk_family == sk->sk_family &&
+		    ipv6_only_sock(sk2) == ipv6_only_sock(sk) &&
+		    (udp_sk(sk2)->udp_port_hash == udp_sk(sk)->udp_port_hash) &&
+		    (sk2->sk_bound_dev_if == sk->sk_bound_dev_if) &&
+		    sk2->sk_reuseport && uid_eq(uid, sock_i_uid(sk2)) &&
+		    (*saddr_same)(sk, sk2, false)) {
+			return reuseport_add_sock(sk, sk2);
+		}
+	}
+
+	/* Initial allocation may have already happened via setsockopt */
+	if (!rcu_access_pointer(sk->sk_reuseport_cb))
+		return reuseport_alloc(sk);
+	return 0;
+}
+
 /**
  *  udp_lib_get_port  -  UDP/-Lite port lookup for IPv4 and IPv6
  *
@@ -207,7 +241,8 @@ static int udp_lib_lport_inuse2(struct net *net, __u16 num,
  */
 int udp_lib_get_port(struct sock *sk, unsigned short snum,
 		     int (*saddr_comp)(const struct sock *sk1,
-				       const struct sock *sk2),
+				       const struct sock *sk2,
+				       bool match_wildcard),
 		     unsigned int hash2_nulladdr)
 {
 	struct udp_hslot *hslot, *hslot2;
@@ -290,6 +325,14 @@ found:
 	udp_sk(sk)->udp_port_hash = snum;
 	udp_sk(sk)->udp_portaddr_hash ^= snum;
 	if (sk_unhashed(sk)) {
+		if (sk->sk_reuseport &&
+		    udp_reuseport_add_sock(sk, hslot, saddr_comp)) {
+			inet_sk(sk)->inet_num = 0;
+			udp_sk(sk)->udp_port_hash = 0;
+			udp_sk(sk)->udp_portaddr_hash ^= snum;
+			goto fail_unlock;
+		}
+
 		sk_nulls_add_node_rcu(sk, &hslot->head);
 		hslot->count++;
 		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
@@ -309,13 +352,22 @@ fail:
 }
 EXPORT_SYMBOL(udp_lib_get_port);
 
-static int ipv4_rcv_saddr_equal(const struct sock *sk1, const struct sock *sk2)
+/* match_wildcard == true:  0.0.0.0 equals to any IPv4 addresses
+ * match_wildcard == false: addresses must be exactly the same, i.e.
+ *                          0.0.0.0 only equals to 0.0.0.0
+ */
+static int ipv4_rcv_saddr_equal(const struct sock *sk1, const struct sock *sk2,
+				bool match_wildcard)
 {
 	struct inet_sock *inet1 = inet_sk(sk1), *inet2 = inet_sk(sk2);
 
-	return 	(!ipv6_only_sock(sk2)  &&
-		 (!inet1->inet_rcv_saddr || !inet2->inet_rcv_saddr ||
-		   inet1->inet_rcv_saddr == inet2->inet_rcv_saddr));
+	if (!ipv6_only_sock(sk2)) {
+		if (inet1->inet_rcv_saddr == inet2->inet_rcv_saddr)
+			return 1;
+		if (!inet1->inet_rcv_saddr || !inet2->inet_rcv_saddr)
+			return match_wildcard;
+	}
+	return 0;
 }
 
 static u32 udp4_portaddr_hash(const struct net *net, __be32 saddr,
@@ -459,8 +511,14 @@ begin:
 			badness = score;
 			reuseport = sk->sk_reuseport;
 			if (reuseport) {
+				struct sock *sk2;
 				hash = udp_ehashfn(net, daddr, hnum,
 						   saddr, sport);
+				sk2 = reuseport_select_sock(sk, hash);
+				if (sk2) {
+					result = sk2;
+					goto found;
+				}
 				matches = 1;
 			}
 		} else if (score == badness && reuseport) {
@@ -478,6 +536,7 @@ begin:
 	if (get_nulls_value(node) != slot2)
 		goto begin;
 	if (result) {
+found:
 		if (unlikely(!atomic_inc_not_zero_hint(&result->sk_refcnt, 2)))
 			result = NULL;
 		else if (unlikely(compute_score2(result, net, saddr, sport,
@@ -540,8 +599,14 @@ begin:
 			badness = score;
 			reuseport = sk->sk_reuseport;
 			if (reuseport) {
+				struct sock *sk2;
 				hash = udp_ehashfn(net, daddr, hnum,
 						   saddr, sport);
+				sk2 = reuseport_select_sock(sk, hash);
+				if (sk2) {
+					result = sk2;
+					goto found;
+				}
 				matches = 1;
 			}
 		} else if (score == badness && reuseport) {
@@ -560,6 +625,7 @@ begin:
 		goto begin;
 
 	if (result) {
+found:
 		if (unlikely(!atomic_inc_not_zero_hint(&result->sk_refcnt, 2)))
 			result = NULL;
 		else if (unlikely(compute_score(result, net, saddr, hnum, sport,
@@ -587,7 +653,8 @@ static inline struct sock *__udp4_lib_lookup_skb(struct sk_buff *skb,
 struct sock *udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
 			     __be32 daddr, __be16 dport, int dif)
 {
-	return __udp4_lib_lookup(net, saddr, sport, daddr, dport, dif, &udp_table);
+	return __udp4_lib_lookup(net, saddr, sport, daddr, dport, dif,
+				 &udp_table);
 }
 EXPORT_SYMBOL_GPL(udp4_lib_lookup);
 
@@ -1398,6 +1465,8 @@ void udp_lib_unhash(struct sock *sk)
 		hslot2 = udp_hashslot2(udptable, udp_sk(sk)->udp_portaddr_hash);
 
 		spin_lock_bh(&hslot->lock);
+		if (rcu_access_pointer(sk->sk_reuseport_cb))
+			reuseport_detach_sock(sk);
 		if (sk_nulls_del_node_init_rcu(sk)) {
 			hslot->count--;
 			inet_sk(sk)->inet_num = 0;
@@ -1425,22 +1494,28 @@ void udp_lib_rehash(struct sock *sk, u16 newhash)
 		hslot2 = udp_hashslot2(udptable, udp_sk(sk)->udp_portaddr_hash);
 		nhslot2 = udp_hashslot2(udptable, newhash);
 		udp_sk(sk)->udp_portaddr_hash = newhash;
-		if (hslot2 != nhslot2) {
+
+		if (hslot2 != nhslot2 ||
+		    rcu_access_pointer(sk->sk_reuseport_cb)) {
 			hslot = udp_hashslot(udptable, sock_net(sk),
 					     udp_sk(sk)->udp_port_hash);
 			/* we must lock primary chain too */
 			spin_lock_bh(&hslot->lock);
-
-			spin_lock(&hslot2->lock);
-			hlist_nulls_del_init_rcu(&udp_sk(sk)->udp_portaddr_node);
-			hslot2->count--;
-			spin_unlock(&hslot2->lock);
-
-			spin_lock(&nhslot2->lock);
-			hlist_nulls_add_head_rcu(&udp_sk(sk)->udp_portaddr_node,
-						 &nhslot2->head);
-			nhslot2->count++;
-			spin_unlock(&nhslot2->lock);
+			if (rcu_access_pointer(sk->sk_reuseport_cb))
+				reuseport_detach_sock(sk);
+
+			if (hslot2 != nhslot2) {
+				spin_lock(&hslot2->lock);
+				hlist_nulls_del_init_rcu(&udp_sk(sk)->udp_portaddr_node);
+				hslot2->count--;
+				spin_unlock(&hslot2->lock);
+
+				spin_lock(&nhslot2->lock);
+				hlist_nulls_add_head_rcu(&udp_sk(sk)->udp_portaddr_node,
+							 &nhslot2->head);
+				nhslot2->count++;
+				spin_unlock(&nhslot2->lock);
+			}
 
 			spin_unlock_bh(&hslot->lock);
 		}
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index a7ca2cd..36c3f01 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -51,12 +51,12 @@ int inet6_csk_bind_conflict(const struct sock *sk,
 			     (sk2->sk_state != TCP_TIME_WAIT &&
 			      !uid_eq(uid,
 				      sock_i_uid((struct sock *)sk2))))) {
-				if (ipv6_rcv_saddr_equal(sk, sk2))
+				if (ipv6_rcv_saddr_equal(sk, sk2, true))
 					break;
 			}
 			if (!relax && reuse && sk2->sk_reuse &&
 			    sk2->sk_state != TCP_LISTEN &&
-			    ipv6_rcv_saddr_equal(sk, sk2))
+			    ipv6_rcv_saddr_equal(sk, sk2, true))
 				break;
 		}
 	}
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 00775ee..6204b89 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -47,6 +47,7 @@
 #include <net/xfrm.h>
 #include <net/inet6_hashtables.h>
 #include <net/busy_poll.h>
+#include <net/sock_reuseport.h>
 
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
@@ -76,7 +77,14 @@ static u32 udp6_ehashfn(const struct net *net,
 			       udp_ipv6_hash_secret + net_hash_mix(net));
 }
 
-int ipv6_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2)
+/* match_wildcard == true:  IPV6_ADDR_ANY equals to any IPv6 addresses if IPv6
+ *                          only, and any IPv4 addresses if not IPv6 only
+ * match_wildcard == false: addresses must be exactly the same, i.e.
+ *                          IPV6_ADDR_ANY only equals to IPV6_ADDR_ANY,
+ *                          and 0.0.0.0 equals to 0.0.0.0 only
+ */
+int ipv6_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2,
+			 bool match_wildcard)
 {
 	const struct in6_addr *sk2_rcv_saddr6 = inet6_rcv_saddr(sk2);
 	int sk2_ipv6only = inet_v6_ipv6only(sk2);
@@ -84,16 +92,24 @@ int ipv6_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2)
 	int addr_type2 = sk2_rcv_saddr6 ? ipv6_addr_type(sk2_rcv_saddr6) : IPV6_ADDR_MAPPED;
 
 	/* if both are mapped, treat as IPv4 */
-	if (addr_type == IPV6_ADDR_MAPPED && addr_type2 == IPV6_ADDR_MAPPED)
-		return (!sk2_ipv6only &&
-			(!sk->sk_rcv_saddr || !sk2->sk_rcv_saddr ||
-			  sk->sk_rcv_saddr == sk2->sk_rcv_saddr));
+	if (addr_type == IPV6_ADDR_MAPPED && addr_type2 == IPV6_ADDR_MAPPED) {
+		if (!sk2_ipv6only) {
+			if (sk->sk_rcv_saddr == sk2->sk_rcv_saddr)
+				return 1;
+			if (!sk->sk_rcv_saddr || !sk2->sk_rcv_saddr)
+				return match_wildcard;
+		}
+		return 0;
+	}
+
+	if (addr_type == IPV6_ADDR_ANY && addr_type2 == IPV6_ADDR_ANY)
+		return 1;
 
-	if (addr_type2 == IPV6_ADDR_ANY &&
+	if (addr_type2 == IPV6_ADDR_ANY && match_wildcard &&
 	    !(sk2_ipv6only && addr_type == IPV6_ADDR_MAPPED))
 		return 1;
 
-	if (addr_type == IPV6_ADDR_ANY &&
+	if (addr_type == IPV6_ADDR_ANY && match_wildcard &&
 	    !(ipv6_only_sock(sk) && addr_type2 == IPV6_ADDR_MAPPED))
 		return 1;
 
@@ -253,8 +269,14 @@ begin:
 			badness = score;
 			reuseport = sk->sk_reuseport;
 			if (reuseport) {
+				struct sock *sk2;
 				hash = udp6_ehashfn(net, daddr, hnum,
 						    saddr, sport);
+				sk2 = reuseport_select_sock(sk, hash);
+				if (sk2) {
+					result = sk2;
+					goto found;
+				}
 				matches = 1;
 			}
 		} else if (score == badness && reuseport) {
@@ -273,6 +295,7 @@ begin:
 		goto begin;
 
 	if (result) {
+found:
 		if (unlikely(!atomic_inc_not_zero_hint(&result->sk_refcnt, 2)))
 			result = NULL;
 		else if (unlikely(compute_score2(result, net, saddr, sport,
@@ -332,8 +355,14 @@ begin:
 			badness = score;
 			reuseport = sk->sk_reuseport;
 			if (reuseport) {
+				struct sock *sk2;
 				hash = udp6_ehashfn(net, daddr, hnum,
 						    saddr, sport);
+				sk2 = reuseport_select_sock(sk, hash);
+				if (sk2) {
+					result = sk2;
+					goto found;
+				}
 				matches = 1;
 			}
 		} else if (score == badness && reuseport) {
@@ -352,6 +381,7 @@ begin:
 		goto begin;
 
 	if (result) {
+found:
 		if (unlikely(!atomic_inc_not_zero_hint(&result->sk_refcnt, 2)))
 			result = NULL;
 		else if (unlikely(compute_score(result, net, hnum, saddr, sport,
@@ -549,8 +579,8 @@ void __udp6_lib_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	int err;
 	struct net *net = dev_net(skb->dev);
 
-	sk = __udp6_lib_lookup(net, daddr, uh->dest,
-			       saddr, uh->source, inet6_iif(skb), udptable);
+	sk = __udp6_lib_lookup(net, daddr, uh->dest, saddr, uh->source,
+			       inet6_iif(skb), udptable);
 	if (!sk) {
 		ICMP6_INC_STATS_BH(net, __in6_dev_get(skb->dev),
 				   ICMP6_MIB_INERRORS);
-- 
2.6.0.rc2.230.g3dd15c0
