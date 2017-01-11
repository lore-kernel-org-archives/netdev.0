From: Josef Bacik <jbacik@fb.com>
Subject: [PATCH 6/6 net-next] inet: reset tb->fastreuseport when adding a reuseport sk
Date: Wed, 11 Jan 2017 15:22:44 -0500
Message-ID: <1484166164-21250-5-git-send-email-jbacik@fb.com>
References: <1484165171-19210-1-git-send-email-jbacik@fb.com>
 <1484166164-21250-1-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <hannes@stressinduktion.org>,
        <kraigatgoog@gmail.com>, <eric.dumazet@gmail.com>,
        <tom@herbertland.com>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:55293 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S934316AbdAKUXb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 15:23:31 -0500
In-Reply-To: <1484166164-21250-1-git-send-email-jbacik@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we have non reuseport sockets on a tb we will set tb->fastreuseport to 0 and
never set it again.  Which means that in the future if we end up adding a bunch
of reuseport sk's to that tb we'll have to do the expensive scan every time.
Instead add the ipv4/ipv6 saddr fields to the bind bucket, as well as the family
so we know what comparison to make, and the ipv6 only setting so we can make
sure to compare with new sockets appropriately.  Once one sk has made it onto
the list we know that there are no potential bind conflicts on the owners list
that match that sk's rcv_addr.  So copy the sk's information into our bind
bucket and set tb->fastruseport to FASTREUSESOCK_STRICT so we know we have to do
an extra check for subsequent reuseport sockets and skip the expensive bind
conflict check.

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 include/net/inet_hashtables.h   |   9 ++++
 net/ipv4/inet_connection_sock.c | 106 ++++++++++++++++++++++++++++++++--------
 2 files changed, 95 insertions(+), 20 deletions(-)

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 3fc0366..1178931 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -74,12 +74,21 @@ struct inet_ehash_bucket {
  * users logged onto your box, isn't it nice to know that new data
  * ports are created in O(1) time?  I thought so. ;-)	-DaveM
  */
+#define FASTREUSEPORT_ANY	1
+#define FASTREUSEPORT_STRICT	2
+
 struct inet_bind_bucket {
 	possible_net_t		ib_net;
 	unsigned short		port;
 	signed char		fastreuse;
 	signed char		fastreuseport;
 	kuid_t			fastuid;
+#if IS_ENABLED(CONFIG_IPV6)
+	struct in6_addr		fast_v6_rcv_saddr;
+#endif
+	__be32			fast_rcv_saddr;
+	unsigned short		fast_sk_family;
+	bool			fast_ipv6_only;
 	struct hlist_node	node;
 	struct hlist_head	owners;
 };
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index bbe2892..096a085 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -38,20 +38,21 @@ EXPORT_SYMBOL(inet_csk_timer_bug_msg);
  *                          IPV6_ADDR_ANY only equals to IPV6_ADDR_ANY,
  *                          and 0.0.0.0 equals to 0.0.0.0 only
  */
-static int ipv6_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2,
+static int ipv6_rcv_saddr_equal(const struct in6_addr *sk1_rcv_saddr6,
+				const struct in6_addr *sk2_rcv_saddr6,
+				__be32 sk1_rcv_saddr, __be32 sk2_rcv_saddr,
+				bool sk1_ipv6only, bool sk2_ipv6only,
 				bool match_wildcard)
 {
-	const struct in6_addr *sk2_rcv_saddr6 = inet6_rcv_saddr(sk2);
-	int sk2_ipv6only = inet_v6_ipv6only(sk2);
-	int addr_type = ipv6_addr_type(&sk->sk_v6_rcv_saddr);
+	int addr_type = ipv6_addr_type(sk1_rcv_saddr6);
 	int addr_type2 = sk2_rcv_saddr6 ? ipv6_addr_type(sk2_rcv_saddr6) : IPV6_ADDR_MAPPED;
 
 	/* if both are mapped, treat as IPv4 */
 	if (addr_type == IPV6_ADDR_MAPPED && addr_type2 == IPV6_ADDR_MAPPED) {
 		if (!sk2_ipv6only) {
-			if (sk->sk_rcv_saddr == sk2->sk_rcv_saddr)
+			if (sk1_rcv_saddr == sk2_rcv_saddr)
 				return 1;
-			if (!sk->sk_rcv_saddr || !sk2->sk_rcv_saddr)
+			if (!sk1_rcv_saddr || !sk2_rcv_saddr)
 				return match_wildcard;
 		}
 		return 0;
@@ -65,11 +66,11 @@ static int ipv6_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2,
 		return 1;
 
 	if (addr_type == IPV6_ADDR_ANY && match_wildcard &&
-	    !(ipv6_only_sock(sk) && addr_type2 == IPV6_ADDR_MAPPED))
+	    !(sk1_ipv6only && addr_type2 == IPV6_ADDR_MAPPED))
 		return 1;
 
 	if (sk2_rcv_saddr6 &&
-	    ipv6_addr_equal(&sk->sk_v6_rcv_saddr, sk2_rcv_saddr6))
+	    ipv6_addr_equal(sk1_rcv_saddr6, sk2_rcv_saddr6))
 		return 1;
 
 	return 0;
@@ -80,13 +81,13 @@ static int ipv6_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2,
  * match_wildcard == false: addresses must be exactly the same, i.e.
  *                          0.0.0.0 only equals to 0.0.0.0
  */
-static int ipv4_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2,
-				bool match_wildcard)
+static int ipv4_rcv_saddr_equal(__be32 sk1_rcv_saddr, __be32 sk2_rcv_saddr,
+				bool sk2_ipv6only, bool match_wildcard)
 {
-	if (!ipv6_only_sock(sk2)) {
-		if (sk->sk_rcv_saddr == sk2->sk_rcv_saddr)
+	if (!sk2_ipv6only) {
+		if (sk1_rcv_saddr == sk2_rcv_saddr)
 			return 1;
-		if (!sk->sk_rcv_saddr || !sk2->sk_rcv_saddr)
+		if (!sk1_rcv_saddr || !sk2_rcv_saddr)
 			return match_wildcard;
 	}
 	return 0;
@@ -97,9 +98,16 @@ int inet_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2,
 {
 #if IS_ENABLED(CONFIG_IPV6)
 	if (sk->sk_family == AF_INET6)
-		return ipv6_rcv_saddr_equal(sk, sk2, match_wildcard);
+		return ipv6_rcv_saddr_equal(&sk->sk_v6_rcv_saddr,
+					    &sk2->sk_v6_rcv_saddr,
+					    sk->sk_rcv_saddr,
+					    sk2->sk_rcv_saddr,
+					    ipv6_only_sock(sk),
+					    ipv6_only_sock(sk2),
+					    match_wildcard);
 #endif
-	return ipv4_rcv_saddr_equal(sk, sk2, match_wildcard);
+	return ipv4_rcv_saddr_equal(sk->sk_rcv_saddr, sk2->sk_rcv_saddr,
+				    ipv6_only_sock(sk2), match_wildcard);
 }
 EXPORT_SYMBOL(inet_rcv_saddr_equal);
 
@@ -234,6 +242,39 @@ inet_csk_find_open_port(struct sock *sk, struct inet_bind_bucket **tb_ret, int *
 	return head;
 }
 
+static inline int sk_reuseport_match(struct inet_bind_bucket *tb,
+				     struct sock *sk)
+{
+	kuid_t uid = sock_i_uid(sk);
+
+	if (tb->fastreuseport <= 0)
+		return 0;
+	if (!sk->sk_reuseport)
+		return 0;
+	if (rcu_access_pointer(sk->sk_reuseport_cb))
+		return 0;
+	if (!uid_eq(tb->fastuid, uid))
+		return 0;
+	/* We only need to check the rcv_saddr if this tb was once marked
+	 * without fastreuseport and then was reset, as we can only know that
+	 * the fast_*rcv_saddr doesn't have any conflicts with the socks on the
+	 * owners list.
+	 */
+	if (tb->fastreuseport == FASTREUSEPORT_ANY)
+		return 1;
+#if IS_ENABLED(CONFIG_IPV6)
+	if (tb->fast_sk_family == AF_INET6)
+		return ipv6_rcv_saddr_equal(&tb->fast_v6_rcv_saddr,
+					    &sk->sk_v6_rcv_saddr,
+					    tb->fast_rcv_saddr,
+					    sk->sk_rcv_saddr,
+					    tb->fast_ipv6_only,
+					    ipv6_only_sock(sk), true);
+#endif
+	return ipv4_rcv_saddr_equal(tb->fast_rcv_saddr, sk->sk_rcv_saddr,
+				    ipv6_only_sock(sk), true);
+}
+
 /* Obtain a reference to a local port for the given sock,
  * if snum is zero it means select any available local port.
  * We try to allocate an odd port (and leave even ports for connect())
@@ -273,9 +314,7 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 			goto success;
 
 		if ((tb->fastreuse > 0 && reuse) ||
-		     (tb->fastreuseport > 0 &&
-		      !rcu_access_pointer(sk->sk_reuseport_cb) &&
-		      sk->sk_reuseport && uid_eq(tb->fastuid, uid)))
+		    sk_reuseport_match(tb, sk))
 			goto success;
 		if (inet_csk_bind_conflict(sk, tb, true, true))
 			goto fail_unlock;
@@ -284,16 +323,43 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 	if (!hlist_empty(&tb->owners)) {
 		tb->fastreuse = reuse;
 		if (sk->sk_reuseport) {
-			tb->fastreuseport = 1;
+			tb->fastreuseport = FASTREUSEPORT_ANY;
 			tb->fastuid = uid;
+			tb->fast_rcv_saddr = sk->sk_rcv_saddr;
+			tb->fast_ipv6_only = ipv6_only_sock(sk);
+#if IS_ENABLED(CONFIG_IPV6)
+			tb->fast_v6_rcv_saddr = sk->sk_v6_rcv_saddr;
+#endif
 		} else {
 			tb->fastreuseport = 0;
 		}
 	} else {
 		if (!reuse)
 			tb->fastreuse = 0;
-		if (!sk->sk_reuseport || !uid_eq(tb->fastuid, uid))
+		if (sk->sk_reuseport) {
+			/* We didn't match or we don't have fastreuseport set on
+			 * the tb, but we have sk_reuseport set on this socket
+			 * and we know that there are no bind conflicts with
+			 * this socket in this tb, so reset our tb's reuseport
+			 * settings so that any subsequent sockets that match
+			 * our current socket will be put on the fast path.
+			 *
+			 * If we reset we need to set FASTREUSEPORT_STRICT so we
+			 * do extra checking for all subsequent sk_reuseport
+			 * socks.
+			 */
+			if (!sk_reuseport_match(tb, sk)) {
+				tb->fastreuseport = FASTREUSEPORT_STRICT;
+				tb->fastuid = uid;
+				tb->fast_rcv_saddr = sk->sk_rcv_saddr;
+				tb->fast_ipv6_only = ipv6_only_sock(sk);
+#if IS_ENABLED(CONFIG_IPV6)
+				tb->fast_v6_rcv_saddr = sk->sk_v6_rcv_saddr;
+#endif
+			}
+		} else {
 			tb->fastreuseport = 0;
+		}
 	}
 	if (!inet_csk(sk)->icsk_bind_hash)
 		inet_bind_hash(sk, tb, port);
-- 
2.5.5
