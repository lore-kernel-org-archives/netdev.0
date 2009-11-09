From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] udp: bind() optimisation
Date: Mon, 09 Nov 2009 16:26:33 +0100
Message-ID: <4AF834A9.2050005@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Lucian Adrian Grijincu <lgrijincu@ixiacom.com>,
	Octavian Purdila <opurdila@ixiacom.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:43690 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755969AbZKIP0e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 10:26:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

UDP bind() can be O(N^2) in some pathological cases.

Thanks to secondary hash tables, we can make it O(N)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/udp.h |    6 +++
 include/net/udp.h   |    3 +
 net/ipv4/udp.c      |   73 +++++++++++++++++++++++++++++++++++++-----
 net/ipv6/udp.c      |   14 ++++----
 4 files changed, 80 insertions(+), 16 deletions(-)

diff --git a/include/linux/udp.h b/include/linux/udp.h
index 59f0ddf..03f72a2 100644
--- a/include/linux/udp.h
+++ b/include/linux/udp.h
@@ -88,6 +88,12 @@ static inline struct udp_sock *udp_sk(const struct sock *sk)
 	return (struct udp_sock *)sk;
 }
 
+#define udp_portaddr_for_each_entry(__sk, node, list) \
+	hlist_nulls_for_each_entry(__sk, node, list, __sk_common.skc_portaddr_node)
+
+#define udp_portaddr_for_each_entry_rcu(__sk, node, list) \
+	hlist_nulls_for_each_entry_rcu(__sk, node, list, __sk_common.skc_portaddr_node)
+
 #define IS_UDPLITE(__sk) (udp_sk(__sk)->pcflag)
 
 #endif
diff --git a/include/net/udp.h b/include/net/udp.h
index af41850..5348d80 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -158,7 +158,8 @@ static inline void udp_lib_close(struct sock *sk, long timeout)
 }
 
 extern int	udp_lib_get_port(struct sock *sk, unsigned short snum,
-		int (*)(const struct sock*,const struct sock*));
+		int (*)(const struct sock *,const struct sock *),
+		unsigned int hash2_nulladdr);
 
 /* net/ipv4/udp.c */
 extern int	udp_get_port(struct sock *sk, unsigned short snum,
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index d73e917..1eaf575 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -152,16 +152,49 @@ static int udp_lib_lport_inuse(struct net *net, __u16 num,
 	return 0;
 }
 
+/*
+ * Note: we still hold spinlock of primary hash chain, so no other writer
+ * can insert/delete a socket with local_port == num
+ */
+static int udp_lib_lport_inuse2(struct net *net, __u16 num,
+			       struct udp_hslot *hslot2,
+			       struct sock *sk,
+			       int (*saddr_comp)(const struct sock *sk1,
+						 const struct sock *sk2))
+{
+	struct sock *sk2;
+	struct hlist_nulls_node *node;
+	int res = 0;
+
+	spin_lock(&hslot2->lock);
+	udp_portaddr_for_each_entry(sk2, node, &hslot2->head)
+		if (net_eq(sock_net(sk2), net)			&&
+		    sk2 != sk					&&
+		    (udp_sk(sk2)->udp_port_hash == num)		&&
+		    (!sk2->sk_reuse || !sk->sk_reuse)		&&
+		    (!sk2->sk_bound_dev_if || !sk->sk_bound_dev_if
+			|| sk2->sk_bound_dev_if == sk->sk_bound_dev_if) &&
+		    (*saddr_comp)(sk, sk2)) {
+			res = 1;
+			break;
+		}
+	spin_unlock(&hslot2->lock);
+	return res;
+}
+
 /**
  *  udp_lib_get_port  -  UDP/-Lite port lookup for IPv4 and IPv6
  *
  *  @sk:          socket struct in question
  *  @snum:        port number to look up
  *  @saddr_comp:  AF-dependent comparison of bound local IP addresses
+ *  @hash2_nulladdr: AF-dependant hash value in secondary hash chains,
+ *                   with NULL address
  */
 int udp_lib_get_port(struct sock *sk, unsigned short snum,
 		       int (*saddr_comp)(const struct sock *sk1,
-					 const struct sock *sk2))
+					 const struct sock *sk2),
+		     unsigned int hash2_nulladdr)
 {
 	struct udp_hslot *hslot, *hslot2;
 	struct udp_table *udptable = sk->sk_prot->h.udp_table;
@@ -210,6 +243,30 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
 	} else {
 		hslot = udp_hashslot(udptable, net, snum);
 		spin_lock_bh(&hslot->lock);
+		if (hslot->count > 10) {
+			int exist;
+			unsigned int slot2 = udp_sk(sk)->udp_portaddr_hash ^ snum;
+
+			slot2          &= udptable->mask;
+			hash2_nulladdr &= udptable->mask;
+
+			hslot2 = udp_hashslot2(udptable, slot2);
+			if (hslot->count < hslot2->count)
+				goto scan_primary_hash;
+
+			exist = udp_lib_lport_inuse2(net, snum, hslot2,
+						     sk, saddr_comp);
+			if (!exist && (hash2_nulladdr != slot2)) {
+				hslot2 = udp_hashslot2(udptable, hash2_nulladdr);
+				exist = udp_lib_lport_inuse2(net, snum, hslot2,
+							     sk, saddr_comp);
+			}
+			if (exist)
+				goto fail_unlock;
+			else
+				goto found;
+		}
+scan_primary_hash:
 		if (udp_lib_lport_inuse(net, snum, hslot, NULL, sk,
 					saddr_comp, 0))
 			goto fail_unlock;
@@ -255,12 +312,14 @@ static unsigned int udp4_portaddr_hash(struct net *net, __be32 saddr,
 
 int udp_v4_get_port(struct sock *sk, unsigned short snum)
 {
+	unsigned int hash2_nulladdr =
+		udp4_portaddr_hash(sock_net(sk), INADDR_ANY, snum);
+	unsigned int hash2_partial =
+		udp4_portaddr_hash(sock_net(sk), inet_sk(sk)->inet_rcv_saddr, 0);
+
 	/* precompute partial secondary hash */
-	udp_sk(sk)->udp_portaddr_hash =
-		udp4_portaddr_hash(sock_net(sk),
-				   inet_sk(sk)->inet_rcv_saddr,
-				   0);
-	return udp_lib_get_port(sk, snum, ipv4_rcv_saddr_equal);
+	udp_sk(sk)->udp_portaddr_hash = hash2_partial;
+	return udp_lib_get_port(sk, snum, ipv4_rcv_saddr_equal, hash2_nulladdr);
 }
 
 static inline int compute_score(struct sock *sk, struct net *net, __be32 saddr,
@@ -336,8 +395,6 @@ static inline int compute_score2(struct sock *sk, struct net *net,
 	return score;
 }
 
-#define udp_portaddr_for_each_entry_rcu(__sk, node, list) \
-	hlist_nulls_for_each_entry_rcu(__sk, node, list, __sk_common.skc_portaddr_node)
 
 /* called with read_rcu_lock() */
 static struct sock *udp4_lib_lookup2(struct net *net,
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 2915e1d..f4c85b2 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -100,12 +100,14 @@ static unsigned int udp6_portaddr_hash(struct net *net,
 
 int udp_v6_get_port(struct sock *sk, unsigned short snum)
 {
+	unsigned int hash2_nulladdr =
+		udp6_portaddr_hash(sock_net(sk), &in6addr_any, snum);
+	unsigned int hash2_partial = 
+		udp6_portaddr_hash(sock_net(sk), &inet6_sk(sk)->rcv_saddr, 0);
+
 	/* precompute partial secondary hash */
-	udp_sk(sk)->udp_portaddr_hash =
-		udp6_portaddr_hash(sock_net(sk),
-				   &inet6_sk(sk)->rcv_saddr,
-				   0);
-	return udp_lib_get_port(sk, snum, ipv6_rcv_saddr_equal);
+	udp_sk(sk)->udp_portaddr_hash = hash2_partial;
+	return udp_lib_get_port(sk, snum, ipv6_rcv_saddr_equal, hash2_nulladdr);
 }
 
 static inline int compute_score(struct sock *sk, struct net *net,
@@ -181,8 +183,6 @@ static inline int compute_score2(struct sock *sk, struct net *net,
 	return score;
 }
 
-#define udp_portaddr_for_each_entry_rcu(__sk, node, list) \
-	hlist_nulls_for_each_entry_rcu(__sk, node, list, __sk_common.skc_portaddr_node)
 
 /* called with read_rcu_lock() */
 static struct sock *udp6_lib_lookup2(struct net *net,
