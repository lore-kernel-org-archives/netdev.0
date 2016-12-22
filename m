From: Josef Bacik <jbacik@fb.com>
Subject: [PATCH 1/6 net-next] inet: collapse ipv4/v6 rcv_saddr_equal functions into one
Date: Thu, 22 Dec 2016 16:26:33 -0500
Message-ID: <1482441998-28359-2-git-send-email-jbacik@fb.com>
References: <1482441998-28359-1-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <hannes@stressinduktion.org>,
        <kraigatgoog@gmail.com>, <eric.dumazet@gmail.com>,
        <tom@herbertland.com>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:58747 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1760577AbcLVV1B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2016 16:27:01 -0500
In-Reply-To: <1482441998-28359-1-git-send-email-jbacik@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We pass these per-protocol equal functions around in various places, but
we can just have one function that checks the sk->sk_family and then do
the right comparison function.  I've also changed the ipv4 version to
not cast to inet_sock since it is unneeded.

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 include/net/addrconf.h           |  4 +--
 include/net/inet_hashtables.h    |  5 +--
 include/net/udp.h                |  1 -
 net/ipv4/inet_connection_sock.c  | 72 ++++++++++++++++++++++++++++++++++++++++
 net/ipv4/inet_hashtables.c       | 16 +++------
 net/ipv4/udp.c                   | 58 +++++++-------------------------
 net/ipv6/inet6_connection_sock.c |  4 +--
 net/ipv6/inet6_hashtables.c      | 46 +------------------------
 net/ipv6/udp.c                   |  2 +-
 9 files changed, 95 insertions(+), 113 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 8f998af..17c6fd8 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -88,9 +88,7 @@ int __ipv6_get_lladdr(struct inet6_dev *idev, struct in6_addr *addr,
 		      u32 banned_flags);
 int ipv6_get_lladdr(struct net_device *dev, struct in6_addr *addr,
 		    u32 banned_flags);
-int ipv4_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2,
-			 bool match_wildcard);
-int ipv6_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2,
+int inet_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2,
 			 bool match_wildcard);
 void addrconf_join_solict(struct net_device *dev, const struct in6_addr *addr);
 void addrconf_leave_solict(struct inet6_dev *idev, const struct in6_addr *addr);
diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 0574493..756ed16 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -203,10 +203,7 @@ void inet_hashinfo_init(struct inet_hashinfo *h);
 
 bool inet_ehash_insert(struct sock *sk, struct sock *osk);
 bool inet_ehash_nolisten(struct sock *sk, struct sock *osk);
-int __inet_hash(struct sock *sk, struct sock *osk,
-		int (*saddr_same)(const struct sock *sk1,
-				  const struct sock *sk2,
-				  bool match_wildcard));
+int __inet_hash(struct sock *sk, struct sock *osk);
 int inet_hash(struct sock *sk);
 void inet_unhash(struct sock *sk);
 
diff --git a/include/net/udp.h b/include/net/udp.h
index 1661791..c9d8b8e 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -204,7 +204,6 @@ static inline void udp_lib_close(struct sock *sk, long timeout)
 }
 
 int udp_lib_get_port(struct sock *sk, unsigned short snum,
-		     int (*)(const struct sock *, const struct sock *, bool),
 		     unsigned int hash2_nulladdr);
 
 u32 udp_flow_hashrnd(void);
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 19ea045..ba597cb 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -31,6 +31,78 @@ const char inet_csk_timer_bug_msg[] = "inet_csk BUG: unknown timer value\n";
 EXPORT_SYMBOL(inet_csk_timer_bug_msg);
 #endif
 
+#if IS_ENABLED(CONFIG_IPV6)
+/* match_wildcard == true:  IPV6_ADDR_ANY equals to any IPv6 addresses if IPv6
+ *                          only, and any IPv4 addresses if not IPv6 only
+ * match_wildcard == false: addresses must be exactly the same, i.e.
+ *                          IPV6_ADDR_ANY only equals to IPV6_ADDR_ANY,
+ *                          and 0.0.0.0 equals to 0.0.0.0 only
+ */
+static int ipv6_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2,
+				bool match_wildcard)
+{
+	const struct in6_addr *sk2_rcv_saddr6 = inet6_rcv_saddr(sk2);
+	int sk2_ipv6only = inet_v6_ipv6only(sk2);
+	int addr_type = ipv6_addr_type(&sk->sk_v6_rcv_saddr);
+	int addr_type2 = sk2_rcv_saddr6 ? ipv6_addr_type(sk2_rcv_saddr6) : IPV6_ADDR_MAPPED;
+
+	/* if both are mapped, treat as IPv4 */
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
+
+	if (addr_type2 == IPV6_ADDR_ANY && match_wildcard &&
+	    !(sk2_ipv6only && addr_type == IPV6_ADDR_MAPPED))
+		return 1;
+
+	if (addr_type == IPV6_ADDR_ANY && match_wildcard &&
+	    !(ipv6_only_sock(sk) && addr_type2 == IPV6_ADDR_MAPPED))
+		return 1;
+
+	if (sk2_rcv_saddr6 &&
+	    ipv6_addr_equal(&sk->sk_v6_rcv_saddr, sk2_rcv_saddr6))
+		return 1;
+
+	return 0;
+}
+#endif
+
+/* match_wildcard == true:  0.0.0.0 equals to any IPv4 addresses
+ * match_wildcard == false: addresses must be exactly the same, i.e.
+ *                          0.0.0.0 only equals to 0.0.0.0
+ */
+static int ipv4_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2,
+				bool match_wildcard)
+{
+	if (!ipv6_only_sock(sk2)) {
+		if (sk->sk_rcv_saddr == sk2->sk_rcv_saddr)
+			return 1;
+		if (!sk->sk_rcv_saddr || !sk2->sk_rcv_saddr)
+			return match_wildcard;
+	}
+	return 0;
+}
+
+int inet_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2,
+			 bool match_wildcard)
+{
+#if IS_ENABLED(CONFIG_IPV6)
+	if (sk->sk_family == AF_INET6)
+		return ipv6_rcv_saddr_equal(sk, sk2, match_wildcard);
+#endif
+	return ipv4_rcv_saddr_equal(sk, sk2, match_wildcard);
+}
+EXPORT_SYMBOL(inet_rcv_saddr_equal);
+
 void inet_get_local_port_range(struct net *net, int *low, int *high)
 {
 	unsigned int seq;
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index ca97835..2ef9b01 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -435,10 +435,7 @@ bool inet_ehash_nolisten(struct sock *sk, struct sock *osk)
 EXPORT_SYMBOL_GPL(inet_ehash_nolisten);
 
 static int inet_reuseport_add_sock(struct sock *sk,
-				   struct inet_listen_hashbucket *ilb,
-				   int (*saddr_same)(const struct sock *sk1,
-						     const struct sock *sk2,
-						     bool match_wildcard))
+				   struct inet_listen_hashbucket *ilb)
 {
 	struct inet_bind_bucket *tb = inet_csk(sk)->icsk_bind_hash;
 	struct sock *sk2;
@@ -451,7 +448,7 @@ static int inet_reuseport_add_sock(struct sock *sk,
 		    sk2->sk_bound_dev_if == sk->sk_bound_dev_if &&
 		    inet_csk(sk2)->icsk_bind_hash == tb &&
 		    sk2->sk_reuseport && uid_eq(uid, sock_i_uid(sk2)) &&
-		    saddr_same(sk, sk2, false))
+		    inet_rcv_saddr_equal(sk, sk2, false))
 			return reuseport_add_sock(sk, sk2);
 	}
 
@@ -461,10 +458,7 @@ static int inet_reuseport_add_sock(struct sock *sk,
 	return 0;
 }
 
-int __inet_hash(struct sock *sk, struct sock *osk,
-		 int (*saddr_same)(const struct sock *sk1,
-				   const struct sock *sk2,
-				   bool match_wildcard))
+int __inet_hash(struct sock *sk, struct sock *osk)
 {
 	struct inet_hashinfo *hashinfo = sk->sk_prot->h.hashinfo;
 	struct inet_listen_hashbucket *ilb;
@@ -479,7 +473,7 @@ int __inet_hash(struct sock *sk, struct sock *osk,
 
 	spin_lock(&ilb->lock);
 	if (sk->sk_reuseport) {
-		err = inet_reuseport_add_sock(sk, ilb, saddr_same);
+		err = inet_reuseport_add_sock(sk, ilb);
 		if (err)
 			goto unlock;
 	}
@@ -503,7 +497,7 @@ int inet_hash(struct sock *sk)
 
 	if (sk->sk_state != TCP_CLOSE) {
 		local_bh_disable();
-		err = __inet_hash(sk, NULL, ipv4_rcv_saddr_equal);
+		err = __inet_hash(sk, NULL);
 		local_bh_enable();
 	}
 
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 9ca279b..cffbb65 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -137,11 +137,7 @@ EXPORT_SYMBOL(udp_memory_allocated);
 static int udp_lib_lport_inuse(struct net *net, __u16 num,
 			       const struct udp_hslot *hslot,
 			       unsigned long *bitmap,
-			       struct sock *sk,
-			       int (*saddr_comp)(const struct sock *sk1,
-						 const struct sock *sk2,
-						 bool match_wildcard),
-			       unsigned int log)
+			       struct sock *sk, unsigned int log)
 {
 	struct sock *sk2;
 	kuid_t uid = sock_i_uid(sk);
@@ -156,7 +152,7 @@ static int udp_lib_lport_inuse(struct net *net, __u16 num,
 		    (!sk2->sk_reuseport || !sk->sk_reuseport ||
 		     rcu_access_pointer(sk->sk_reuseport_cb) ||
 		     !uid_eq(uid, sock_i_uid(sk2))) &&
-		    saddr_comp(sk, sk2, true)) {
+		    inet_rcv_saddr_equal(sk, sk2, true)) {
 			if (!bitmap)
 				return 1;
 			__set_bit(udp_sk(sk2)->udp_port_hash >> log, bitmap);
@@ -171,10 +167,7 @@ static int udp_lib_lport_inuse(struct net *net, __u16 num,
  */
 static int udp_lib_lport_inuse2(struct net *net, __u16 num,
 				struct udp_hslot *hslot2,
-				struct sock *sk,
-				int (*saddr_comp)(const struct sock *sk1,
-						  const struct sock *sk2,
-						  bool match_wildcard))
+				struct sock *sk)
 {
 	struct sock *sk2;
 	kuid_t uid = sock_i_uid(sk);
@@ -191,7 +184,7 @@ static int udp_lib_lport_inuse2(struct net *net, __u16 num,
 		    (!sk2->sk_reuseport || !sk->sk_reuseport ||
 		     rcu_access_pointer(sk->sk_reuseport_cb) ||
 		     !uid_eq(uid, sock_i_uid(sk2))) &&
-		    saddr_comp(sk, sk2, true)) {
+		    inet_rcv_saddr_equal(sk, sk2, true)) {
 			res = 1;
 			break;
 		}
@@ -200,10 +193,7 @@ static int udp_lib_lport_inuse2(struct net *net, __u16 num,
 	return res;
 }
 
-static int udp_reuseport_add_sock(struct sock *sk, struct udp_hslot *hslot,
-				  int (*saddr_same)(const struct sock *sk1,
-						    const struct sock *sk2,
-						    bool match_wildcard))
+static int udp_reuseport_add_sock(struct sock *sk, struct udp_hslot *hslot)
 {
 	struct net *net = sock_net(sk);
 	kuid_t uid = sock_i_uid(sk);
@@ -217,7 +207,7 @@ static int udp_reuseport_add_sock(struct sock *sk, struct udp_hslot *hslot,
 		    (udp_sk(sk2)->udp_port_hash == udp_sk(sk)->udp_port_hash) &&
 		    (sk2->sk_bound_dev_if == sk->sk_bound_dev_if) &&
 		    sk2->sk_reuseport && uid_eq(uid, sock_i_uid(sk2)) &&
-		    (*saddr_same)(sk, sk2, false)) {
+		    inet_rcv_saddr_equal(sk, sk2, false)) {
 			return reuseport_add_sock(sk, sk2);
 		}
 	}
@@ -233,14 +223,10 @@ static int udp_reuseport_add_sock(struct sock *sk, struct udp_hslot *hslot,
  *
  *  @sk:          socket struct in question
  *  @snum:        port number to look up
- *  @saddr_comp:  AF-dependent comparison of bound local IP addresses
  *  @hash2_nulladdr: AF-dependent hash value in secondary hash chains,
  *                   with NULL address
  */
 int udp_lib_get_port(struct sock *sk, unsigned short snum,
-		     int (*saddr_comp)(const struct sock *sk1,
-				       const struct sock *sk2,
-				       bool match_wildcard),
 		     unsigned int hash2_nulladdr)
 {
 	struct udp_hslot *hslot, *hslot2;
@@ -269,7 +255,7 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
 			bitmap_zero(bitmap, PORTS_PER_CHAIN);
 			spin_lock_bh(&hslot->lock);
 			udp_lib_lport_inuse(net, snum, hslot, bitmap, sk,
-					    saddr_comp, udptable->log);
+					    udptable->log);
 
 			snum = first;
 			/*
@@ -301,12 +287,11 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
 			if (hslot->count < hslot2->count)
 				goto scan_primary_hash;
 
-			exist = udp_lib_lport_inuse2(net, snum, hslot2,
-						     sk, saddr_comp);
+			exist = udp_lib_lport_inuse2(net, snum, hslot2, sk);
 			if (!exist && (hash2_nulladdr != slot2)) {
 				hslot2 = udp_hashslot2(udptable, hash2_nulladdr);
 				exist = udp_lib_lport_inuse2(net, snum, hslot2,
-							     sk, saddr_comp);
+							     sk);
 			}
 			if (exist)
 				goto fail_unlock;
@@ -314,8 +299,7 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
 				goto found;
 		}
 scan_primary_hash:
-		if (udp_lib_lport_inuse(net, snum, hslot, NULL, sk,
-					saddr_comp, 0))
+		if (udp_lib_lport_inuse(net, snum, hslot, NULL, sk, 0))
 			goto fail_unlock;
 	}
 found:
@@ -324,7 +308,7 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
 	udp_sk(sk)->udp_portaddr_hash ^= snum;
 	if (sk_unhashed(sk)) {
 		if (sk->sk_reuseport &&
-		    udp_reuseport_add_sock(sk, hslot, saddr_comp)) {
+		    udp_reuseport_add_sock(sk, hslot)) {
 			inet_sk(sk)->inet_num = 0;
 			udp_sk(sk)->udp_port_hash = 0;
 			udp_sk(sk)->udp_portaddr_hash ^= snum;
@@ -356,24 +340,6 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
 }
 EXPORT_SYMBOL(udp_lib_get_port);
 
-/* match_wildcard == true:  0.0.0.0 equals to any IPv4 addresses
- * match_wildcard == false: addresses must be exactly the same, i.e.
- *                          0.0.0.0 only equals to 0.0.0.0
- */
-int ipv4_rcv_saddr_equal(const struct sock *sk1, const struct sock *sk2,
-			 bool match_wildcard)
-{
-	struct inet_sock *inet1 = inet_sk(sk1), *inet2 = inet_sk(sk2);
-
-	if (!ipv6_only_sock(sk2)) {
-		if (inet1->inet_rcv_saddr == inet2->inet_rcv_saddr)
-			return 1;
-		if (!inet1->inet_rcv_saddr || !inet2->inet_rcv_saddr)
-			return match_wildcard;
-	}
-	return 0;
-}
-
 static u32 udp4_portaddr_hash(const struct net *net, __be32 saddr,
 			      unsigned int port)
 {
@@ -389,7 +355,7 @@ int udp_v4_get_port(struct sock *sk, unsigned short snum)
 
 	/* precompute partial secondary hash */
 	udp_sk(sk)->udp_portaddr_hash = hash2_partial;
-	return udp_lib_get_port(sk, snum, ipv4_rcv_saddr_equal, hash2_nulladdr);
+	return udp_lib_get_port(sk, snum, hash2_nulladdr);
 }
 
 static int compute_score(struct sock *sk, struct net *net,
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index 7396e75..55ee2ea 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -54,12 +54,12 @@ int inet6_csk_bind_conflict(const struct sock *sk,
 			     (sk2->sk_state != TCP_TIME_WAIT &&
 			      !uid_eq(uid,
 				      sock_i_uid((struct sock *)sk2))))) {
-				if (ipv6_rcv_saddr_equal(sk, sk2, true))
+				if (inet_rcv_saddr_equal(sk, sk2, true))
 					break;
 			}
 			if (!relax && reuse && sk2->sk_reuse &&
 			    sk2->sk_state != TCP_LISTEN &&
-			    ipv6_rcv_saddr_equal(sk, sk2, true))
+			    inet_rcv_saddr_equal(sk, sk2, true))
 				break;
 		}
 	}
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 02761c9..d090091 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -268,54 +268,10 @@ int inet6_hash(struct sock *sk)
 
 	if (sk->sk_state != TCP_CLOSE) {
 		local_bh_disable();
-		err = __inet_hash(sk, NULL, ipv6_rcv_saddr_equal);
+		err = __inet_hash(sk, NULL);
 		local_bh_enable();
 	}
 
 	return err;
 }
 EXPORT_SYMBOL_GPL(inet6_hash);
-
-/* match_wildcard == true:  IPV6_ADDR_ANY equals to any IPv6 addresses if IPv6
- *                          only, and any IPv4 addresses if not IPv6 only
- * match_wildcard == false: addresses must be exactly the same, i.e.
- *                          IPV6_ADDR_ANY only equals to IPV6_ADDR_ANY,
- *                          and 0.0.0.0 equals to 0.0.0.0 only
- */
-int ipv6_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2,
-			 bool match_wildcard)
-{
-	const struct in6_addr *sk2_rcv_saddr6 = inet6_rcv_saddr(sk2);
-	int sk2_ipv6only = inet_v6_ipv6only(sk2);
-	int addr_type = ipv6_addr_type(&sk->sk_v6_rcv_saddr);
-	int addr_type2 = sk2_rcv_saddr6 ? ipv6_addr_type(sk2_rcv_saddr6) : IPV6_ADDR_MAPPED;
-
-	/* if both are mapped, treat as IPv4 */
-	if (addr_type == IPV6_ADDR_MAPPED && addr_type2 == IPV6_ADDR_MAPPED) {
-		if (!sk2_ipv6only) {
-			if (sk->sk_rcv_saddr == sk2->sk_rcv_saddr)
-				return 1;
-			if (!sk->sk_rcv_saddr || !sk2->sk_rcv_saddr)
-				return match_wildcard;
-		}
-		return 0;
-	}
-
-	if (addr_type == IPV6_ADDR_ANY && addr_type2 == IPV6_ADDR_ANY)
-		return 1;
-
-	if (addr_type2 == IPV6_ADDR_ANY && match_wildcard &&
-	    !(sk2_ipv6only && addr_type == IPV6_ADDR_MAPPED))
-		return 1;
-
-	if (addr_type == IPV6_ADDR_ANY && match_wildcard &&
-	    !(ipv6_only_sock(sk) && addr_type2 == IPV6_ADDR_MAPPED))
-		return 1;
-
-	if (sk2_rcv_saddr6 &&
-	    ipv6_addr_equal(&sk->sk_v6_rcv_saddr, sk2_rcv_saddr6))
-		return 1;
-
-	return 0;
-}
-EXPORT_SYMBOL_GPL(ipv6_rcv_saddr_equal);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 649efc2..9d2886f 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -103,7 +103,7 @@ int udp_v6_get_port(struct sock *sk, unsigned short snum)
 
 	/* precompute partial secondary hash */
 	udp_sk(sk)->udp_portaddr_hash = hash2_partial;
-	return udp_lib_get_port(sk, snum, ipv6_rcv_saddr_equal, hash2_nulladdr);
+	return udp_lib_get_port(sk, snum, hash2_nulladdr);
 }
 
 static void udp_v6_rehash(struct sock *sk)
-- 
2.5.5
