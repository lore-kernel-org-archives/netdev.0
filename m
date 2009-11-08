From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 2/8] udp: split sk_hash into two u16 hashes
Date: Sun, 08 Nov 2009 21:17:30 +0100
Message-ID: <4AF7275A.2010200@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Lucian Adrian Grijincu <lgrijincu@ixiacom.com>,
	Octavian Purdila <opurdila@ixiacom.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:39131 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754516AbZKHURe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2009 15:17:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Union sk_hash with two u16 hashes for udp (no extra memory taken)

One 16 bits hash on (local port) value (the previous udp 'hash')

One 16 bits hash on (local address, local port) values, initialized
but not yet used. This second hash is using jenkin hash for better
distribution.

Because the 'port' is xored later, a partial hash is performed
on local address + net_hash_mix(net)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/udp.h |    2 ++
 include/net/sock.h  |    6 +++++-
 net/ipv4/udp.c      |   25 +++++++++++++++++++------
 net/ipv6/udp.c      |   27 +++++++++++++++++++++++++--
 4 files changed, 51 insertions(+), 9 deletions(-)

diff --git a/include/linux/udp.h b/include/linux/udp.h
index 832361e..5b4b527 100644
--- a/include/linux/udp.h
+++ b/include/linux/udp.h
@@ -55,6 +55,8 @@ static inline int udp_hashfn(struct net *net, unsigned num, unsigned mask)
 struct udp_sock {
 	/* inet_sock has to be the first member */
 	struct inet_sock inet;
+#define udp_port_hash		inet.sk.__sk_common.skc_u16hashes[0]
+#define udp_portaddr_hash	inet.sk.__sk_common.skc_u16hashes[1]
 	int		 pending;	/* Any pending frames ? */
 	unsigned int	 corkflag;	/* Cork is required */
   	__u16		 encap_type;	/* Is this an Encapsulation socket? */
diff --git a/include/net/sock.h b/include/net/sock.h
index 55de3bd..827366b 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -109,6 +109,7 @@ struct net;
  *	@skc_refcnt: reference count
  *	@skc_tx_queue_mapping: tx queue number for this connection
  *	@skc_hash: hash value used with various protocol lookup tables
+ *	@skc_u16hashes: two u16 hash values used by UDP lookup tables
  *	@skc_family: network address family
  *	@skc_state: Connection state
  *	@skc_reuse: %SO_REUSEADDR setting
@@ -131,7 +132,10 @@ struct sock_common {
 	atomic_t		skc_refcnt;
 	int			skc_tx_queue_mapping;
 
-	unsigned int		skc_hash;
+	union  {
+		unsigned int	skc_hash;
+		__u16		skc_u16hashes[2];
+	};
 	unsigned short		skc_family;
 	volatile unsigned char	skc_state;
 	unsigned char		skc_reuse;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index ffc8376..af72de1 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -138,13 +138,14 @@ static int udp_lib_lport_inuse(struct net *net, __u16 num,
 	sk_nulls_for_each(sk2, node, &hslot->head)
 		if (net_eq(sock_net(sk2), net)			&&
 		    sk2 != sk					&&
-		    (bitmap || sk2->sk_hash == num)		&&
+		    (bitmap || udp_sk(sk2)->udp_port_hash == num) &&
 		    (!sk2->sk_reuse || !sk->sk_reuse)		&&
 		    (!sk2->sk_bound_dev_if || !sk->sk_bound_dev_if
 			|| sk2->sk_bound_dev_if == sk->sk_bound_dev_if) &&
 		    (*saddr_comp)(sk, sk2)) {
 			if (bitmap)
-				__set_bit(sk2->sk_hash >> log, bitmap);
+				__set_bit(udp_sk(sk2)->udp_port_hash >> log,
+					  bitmap);
 			else
 				return 1;
 		}
@@ -215,7 +216,8 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
 	}
 found:
 	inet_sk(sk)->inet_num = snum;
-	sk->sk_hash = snum;
+	udp_sk(sk)->udp_port_hash = snum;
+	udp_sk(sk)->udp_portaddr_hash ^= snum;
 	if (sk_unhashed(sk)) {
 		sk_nulls_add_node_rcu(sk, &hslot->head);
 		hslot->count++;
@@ -238,8 +240,19 @@ static int ipv4_rcv_saddr_equal(const struct sock *sk1, const struct sock *sk2)
 		   inet1->inet_rcv_saddr == inet2->inet_rcv_saddr));
 }
 
+static unsigned int udp4_portaddr_hash(struct net *net, __be32 saddr,
+				       unsigned int port)
+{
+	return jhash_1word(saddr, net_hash_mix(net)) ^ port;
+}
+
 int udp_v4_get_port(struct sock *sk, unsigned short snum)
 {
+	/* precompute partial secondary hash */
+	udp_sk(sk)->udp_portaddr_hash =
+		udp4_portaddr_hash(sock_net(sk),
+				   inet_sk(sk)->inet_rcv_saddr,
+				   0);
 	return udp_lib_get_port(sk, snum, ipv4_rcv_saddr_equal);
 }
 
@@ -249,7 +262,7 @@ static inline int compute_score(struct sock *sk, struct net *net, __be32 saddr,
 {
 	int score = -1;
 
-	if (net_eq(sock_net(sk), net) && sk->sk_hash == hnum &&
+	if (net_eq(sock_net(sk), net) && udp_sk(sk)->udp_port_hash == hnum &&
 			!ipv6_only_sock(sk)) {
 		struct inet_sock *inet = inet_sk(sk);
 
@@ -360,7 +373,7 @@ static inline struct sock *udp_v4_mcast_next(struct net *net, struct sock *sk,
 		struct inet_sock *inet = inet_sk(s);
 
 		if (!net_eq(sock_net(s), net)				||
-		    s->sk_hash != hnum					||
+		    udp_sk(s)->udp_port_hash != hnum			||
 		    (inet->inet_daddr && inet->inet_daddr != rmt_addr)	||
 		    (inet->inet_dport != rmt_port && inet->inet_dport)	||
 		    (inet->inet_rcv_saddr	&&
@@ -1050,7 +1063,7 @@ void udp_lib_unhash(struct sock *sk)
 	if (sk_hashed(sk)) {
 		struct udp_table *udptable = sk->sk_prot->h.udp_table;
 		struct udp_hslot *hslot = udp_hashslot(udptable, sock_net(sk),
-						     sk->sk_hash);
+						       udp_sk(sk)->udp_port_hash);
 
 		spin_lock_bh(&hslot->lock);
 		if (sk_nulls_del_node_init_rcu(sk)) {
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 5bc7cdb..1e5fadd 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -81,8 +81,30 @@ int ipv6_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2)
 	return 0;
 }
 
+static unsigned int udp6_portaddr_hash(struct net *net,
+				       const struct in6_addr *addr6,
+				       unsigned int port)
+{
+	unsigned int hash, mix = net_hash_mix(net);
+
+	if (ipv6_addr_any(addr6))
+		hash = jhash_1word(0, mix);
+	else if (ipv6_addr_type(addr6) == IPV6_ADDR_MAPPED)
+		hash = jhash_1word(addr6->s6_addr32[3], mix);
+	else
+		hash = jhash2(addr6->s6_addr32, 4, mix);
+
+	return hash ^ port;
+}
+
+
 int udp_v6_get_port(struct sock *sk, unsigned short snum)
 {
+	/* precompute partial secondary hash */
+	udp_sk(sk)->udp_portaddr_hash =
+		udp6_portaddr_hash(sock_net(sk),
+				   &inet6_sk(sk)->rcv_saddr,
+				   0);
 	return udp_lib_get_port(sk, snum, ipv6_rcv_saddr_equal);
 }
 
@@ -94,7 +116,7 @@ static inline int compute_score(struct sock *sk, struct net *net,
 {
 	int score = -1;
 
-	if (net_eq(sock_net(sk), net) && sk->sk_hash == hnum &&
+	if (net_eq(sock_net(sk), net) && udp_sk(sk)->udp_port_hash == hnum &&
 			sk->sk_family == PF_INET6) {
 		struct ipv6_pinfo *np = inet6_sk(sk);
 		struct inet_sock *inet = inet_sk(sk);
@@ -415,7 +437,8 @@ static struct sock *udp_v6_mcast_next(struct net *net, struct sock *sk,
 		if (!net_eq(sock_net(s), net))
 			continue;
 
-		if (s->sk_hash == num && s->sk_family == PF_INET6) {
+		if (udp_sk(s)->udp_port_hash == num &&
+		    s->sk_family == PF_INET6) {
 			struct ipv6_pinfo *np = inet6_sk(s);
 			if (inet->inet_dport) {
 				if (inet->inet_dport != rmt_port)
