From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] NET : UDP can use sk_hash to speedup lookups
Date: Fri, 9 Feb 2007 18:44:16 +0100
Message-ID: <200702091844.16803.dada1@cosmosbay.com>
References: <200702091006.24242.dada1@cosmosbay.com> <200702091036.58474.dada1@cosmosbay.com> <20070209.014344.63999119.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_wLLzFj8NZU1GN7R"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:55954 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992458AbXBIRoW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Feb 2007 12:44:22 -0500
In-Reply-To: <20070209.014344.63999119.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_wLLzFj8NZU1GN7R
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

In a prior patch, I introduced a sk_hash field (__sk_common.skc_hash)  to let 
tcp lookups use one cache line per unmatched entry instead of two.

We can also use sk_hash to speedup UDP part as well. We store in sk_hash the 
hnum value, and use sk->sk_hash (same cache line than 'next' pointer), 
instead of inet->num (different cache line)

Note : We still have a false sharing problem for SMP machines, because 
sock_hold(sock) dirties the cache line containing the 'next' pointer. Not 
counting the udp_hash_lock rwlock. (did someone mentioned RCU ? :) )

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

--Boundary-00=_wLLzFj8NZU1GN7R
Content-Type: text/plain;
  charset="iso-8859-1";
  name="udp_can_use_sk_hash.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="udp_can_use_sk_hash.patch"

--- linux-2.6.20/net/ipv4/udp.c	2007-02-09 19:17:28.000000000 +0100
+++ linux-2.6.20-ed/net/ipv4/udp.c	2007-02-09 19:21:07.000000000 +0100
@@ -120,7 +120,7 @@ static inline int __udp_lib_lport_inuse(
 	struct hlist_node *node;
 
 	sk_for_each(sk, node, &udptable[num & (UDP_HTABLE_SIZE - 1)])
-		if (inet_sk(sk)->num == num)
+		if (sk->sk_hash == num)
 			return 1;
 	return 0;
 }
@@ -191,7 +191,7 @@ gotit:
 		head = &udptable[snum & (UDP_HTABLE_SIZE - 1)];
 
 		sk_for_each(sk2, node, head)
-			if (inet_sk(sk2)->num == snum                        &&
+			if (sk2->sk_hash == snum                             &&
 			    sk2 != sk                                        &&
 			    (!sk2->sk_reuse        || !sk->sk_reuse)         &&
 			    (!sk2->sk_bound_dev_if || !sk->sk_bound_dev_if
@@ -200,6 +200,7 @@ gotit:
 				goto fail;
 	}
 	inet_sk(sk)->num = snum;
+	sk->sk_hash = snum;
 	if (sk_unhashed(sk)) {
 		head = &udptable[snum & (UDP_HTABLE_SIZE - 1)];
 		sk_add_node(sk, head);
@@ -247,7 +248,7 @@ static struct sock *__udp4_lib_lookup(__
 	sk_for_each(sk, node, &udptable[hnum & (UDP_HTABLE_SIZE - 1)]) {
 		struct inet_sock *inet = inet_sk(sk);
 
-		if (inet->num == hnum && !ipv6_only_sock(sk)) {
+		if (sk->sk_hash == hnum && !ipv6_only_sock(sk)) {
 			int score = (sk->sk_family == PF_INET ? 1 : 0);
 			if (inet->rcv_saddr) {
 				if (inet->rcv_saddr != daddr)
@@ -296,7 +297,7 @@ static inline struct sock *udp_v4_mcast_
 	sk_for_each_from(s, node) {
 		struct inet_sock *inet = inet_sk(s);
 
-		if (inet->num != hnum					||
+		if (s->sk_hash != hnum					||
 		    (inet->daddr && inet->daddr != rmt_addr)		||
 		    (inet->dport != rmt_port && inet->dport)		||
 		    (inet->rcv_saddr && inet->rcv_saddr != loc_addr)	||
--- linux-2.6.20/net/ipv6/udp.c	2007-02-09 19:17:28.000000000 +0100
+++ linux-2.6.20-ed/net/ipv6/udp.c	2007-02-09 19:17:28.000000000 +0100
@@ -71,7 +71,7 @@ static struct sock *__udp6_lib_lookup(st
 	sk_for_each(sk, node, &udptable[hnum & (UDP_HTABLE_SIZE - 1)]) {
 		struct inet_sock *inet = inet_sk(sk);
 
-		if (inet->num == hnum && sk->sk_family == PF_INET6) {
+		if (sk->sk_hash == hnum && sk->sk_family == PF_INET6) {
 			struct ipv6_pinfo *np = inet6_sk(sk);
 			int score = 0;
 			if (inet->dport) {
@@ -309,7 +309,7 @@ static struct sock *udp_v6_mcast_next(st
 	sk_for_each_from(s, node) {
 		struct inet_sock *inet = inet_sk(s);
 
-		if (inet->num == num && s->sk_family == PF_INET6) {
+		if (s->sk_hash == num && s->sk_family == PF_INET6) {
 			struct ipv6_pinfo *np = inet6_sk(s);
 			if (inet->dport) {
 				if (inet->dport != rmt_port)

--Boundary-00=_wLLzFj8NZU1GN7R--
