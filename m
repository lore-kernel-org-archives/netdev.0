From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] udp: add rehash on connect()
Date: Wed, 08 Sep 2010 12:10:46 +0200
Message-ID: <1283940646.2880.36.camel@edumazet-laptop>
References: <1283895316.2634.248.camel@edumazet-laptop>
	 <4C86F653.6070707@hp.com> <1283921857.2634.747.camel@edumazet-laptop>
	 <20100907.223654.70187707.davem@davemloft.net>
	 <1283925171.2634.838.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, ole@ans.pl, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:60536 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751342Ab0IHKKw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 06:10:52 -0400
Received: by fxm16 with SMTP id 16so591651fxm.19
        for <netdev@vger.kernel.org>; Wed, 08 Sep 2010 03:10:51 -0700 (PDT)
In-Reply-To: <1283925171.2634.838.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 30fff923 introduced in linux-2.6.33 (udp: bind() optimisation)
added a secondary hash on UDP, hashed on (local addr, local port).

Problem is that following sequence :

fd = socket(...)
connect(fd, &remote, ...)

not only selects remote end point (address and port), but also sets
local address, while UDP stack stored in secondary hash table the socket
while its local address was INADDR_ANY (or ipv6 equivalent)

Sequence is :
 - autobind() : choose a random local port, insert socket in hash tables
              [while local address is INADDR_ANY]
 - connect() : set remote address and port, change local address to IP
              given by a route lookup.

When an incoming UDP frame comes, if more than 10 sockets are found in
primary hash table, we switch to secondary table, and fail to find
socket because its local address changed.

One solution to this problem is to rehash datagram socket if needed.

We add a new rehash(struct socket *) method in "struct proto", and
implement this method for UDP v4 & v6, using a common helper.

This rehashing only takes care of secondary hash table, since primary
hash (based on local port only) is not changed.

Reported-by: Krzysztof Piotr Oledzki <ole@ans.pl>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/sock.h  |    1 +
 include/net/udp.h   |    1 +
 net/ipv4/datagram.c |    5 ++++-
 net/ipv4/udp.c      |   37 +++++++++++++++++++++++++++++++++++++
 net/ipv6/datagram.c |    7 ++++++-
 net/ipv6/udp.c      |   10 ++++++++++
 6 files changed, 59 insertions(+), 2 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index ac53bfb..adab9dc 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -752,6 +752,7 @@ struct proto {
 	/* Keeping track of sk's, looking them up, and port selection methods. */
 	void			(*hash)(struct sock *sk);
 	void			(*unhash)(struct sock *sk);
+	void			(*rehash)(struct sock *sk);
 	int			(*get_port)(struct sock *sk, unsigned short snum);
 
 	/* Keeping track of sockets in use */
diff --git a/include/net/udp.h b/include/net/udp.h
index 7abdf30..a184d34 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -151,6 +151,7 @@ static inline void udp_lib_hash(struct sock *sk)
 }
 
 extern void udp_lib_unhash(struct sock *sk);
+extern void udp_lib_rehash(struct sock *sk, u16 new_hash);
 
 static inline void udp_lib_close(struct sock *sk, long timeout)
 {
diff --git a/net/ipv4/datagram.c b/net/ipv4/datagram.c
index f055094..721a8a3 100644
--- a/net/ipv4/datagram.c
+++ b/net/ipv4/datagram.c
@@ -62,8 +62,11 @@ int ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	}
 	if (!inet->inet_saddr)
 		inet->inet_saddr = rt->rt_src;	/* Update source address */
-	if (!inet->inet_rcv_saddr)
+	if (!inet->inet_rcv_saddr) {
 		inet->inet_rcv_saddr = rt->rt_src;
+		if (sk->sk_prot->rehash)
+			sk->sk_prot->rehash(sk);
+	}
 	inet->inet_daddr = rt->rt_dst;
 	inet->inet_dport = usin->sin_port;
 	sk->sk_state = TCP_ESTABLISHED;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 32e0bef..c871758 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1260,6 +1260,42 @@ void udp_lib_unhash(struct sock *sk)
 }
 EXPORT_SYMBOL(udp_lib_unhash);
 
+/*
+ * inet_rcv_saddr was changed, we must rehash secondary hash
+ */
+void udp_lib_rehash(struct sock *sk, u16 newhash)
+{
+	if (sk_hashed(sk)) {
+		struct udp_table *udptable = sk->sk_prot->h.udp_table;
+		struct udp_hslot *hslot2, *nhslot2;
+
+		hslot2 = udp_hashslot2(udptable, udp_sk(sk)->udp_portaddr_hash);
+		nhslot2 = udp_hashslot2(udptable, newhash);
+		udp_sk(sk)->udp_portaddr_hash = newhash;
+		if (hslot2 != nhslot2) {
+			spin_lock_bh(&hslot2->lock);
+			hlist_nulls_del_init_rcu(&udp_sk(sk)->udp_portaddr_node);
+			hslot2->count--;
+			spin_unlock_bh(&hslot2->lock);
+
+			spin_lock_bh(&nhslot2->lock);
+			hlist_nulls_add_head_rcu(&udp_sk(sk)->udp_portaddr_node,
+						 &nhslot2->head);
+			nhslot2->count++;
+			spin_unlock_bh(&nhslot2->lock);
+		}
+	}
+}
+EXPORT_SYMBOL(udp_lib_rehash);
+
+static void udp_v4_rehash(struct sock *sk)
+{
+	u16 new_hash = udp4_portaddr_hash(sock_net(sk),
+					  inet_sk(sk)->inet_rcv_saddr,
+					  inet_sk(sk)->inet_num);
+	udp_lib_rehash(sk, new_hash);
+}
+
 static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
 	int rc;
@@ -1843,6 +1879,7 @@ struct proto udp_prot = {
 	.backlog_rcv	   = __udp_queue_rcv_skb,
 	.hash		   = udp_lib_hash,
 	.unhash		   = udp_lib_unhash,
+	.rehash		   = udp_v4_rehash,
 	.get_port	   = udp_v4_get_port,
 	.memory_allocated  = &udp_memory_allocated,
 	.sysctl_mem	   = sysctl_udp_mem,
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 7d929a2..cb61d9a 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -105,9 +105,12 @@ ipv4_connected:
 		if (ipv6_addr_any(&np->saddr))
 			ipv6_addr_set_v4mapped(inet->inet_saddr, &np->saddr);
 
-		if (ipv6_addr_any(&np->rcv_saddr))
+		if (ipv6_addr_any(&np->rcv_saddr)) {
 			ipv6_addr_set_v4mapped(inet->inet_rcv_saddr,
 					       &np->rcv_saddr);
+			if (sk->sk_prot->rehash)
+				sk->sk_prot->rehash(sk);
+			}
 
 		goto out;
 	}
@@ -181,6 +184,8 @@ ipv4_connected:
 	if (ipv6_addr_any(&np->rcv_saddr)) {
 		ipv6_addr_copy(&np->rcv_saddr, &fl.fl6_src);
 		inet->inet_rcv_saddr = LOOPBACK4_IPV6;
+		if (sk->sk_prot->rehash)
+			sk->sk_prot->rehash(sk);
 	}
 
 	ip6_dst_store(sk, dst,
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 1dd1aff..5acb356 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -111,6 +111,15 @@ int udp_v6_get_port(struct sock *sk, unsigned short snum)
 	return udp_lib_get_port(sk, snum, ipv6_rcv_saddr_equal, hash2_nulladdr);
 }
 
+static void udp_v6_rehash(struct sock *sk)
+{
+	u16 new_hash = udp6_portaddr_hash(sock_net(sk),
+					  &inet6_sk(sk)->rcv_saddr,
+					  inet_sk(sk)->inet_num);
+
+	udp_lib_rehash(sk, new_hash);
+}
+
 static inline int compute_score(struct sock *sk, struct net *net,
 				unsigned short hnum,
 				struct in6_addr *saddr, __be16 sport,
@@ -1447,6 +1456,7 @@ struct proto udpv6_prot = {
 	.backlog_rcv	   = udpv6_queue_rcv_skb,
 	.hash		   = udp_lib_hash,
 	.unhash		   = udp_lib_unhash,
+	.rehash		   = udp_v6_rehash,
 	.get_port	   = udp_v6_get_port,
 	.memory_allocated  = &udp_memory_allocated,
 	.sysctl_mem	   = sysctl_udp_mem,


