From: Craig Gallek <kraigatgoog@gmail.com>
Subject: [PATCH net-next v4 2/7] inet: create IPv6-equivalent inet_hash function
Date: Wed, 10 Feb 2016 11:50:36 -0500
Message-ID: <1455123041-22638-3-git-send-email-kraigatgoog@gmail.com>
References: <1455123041-22638-1-git-send-email-kraigatgoog@gmail.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:34507 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753057AbcBJQuu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2016 11:50:50 -0500
Received: by mail-qg0-f54.google.com with SMTP id b67so17947442qgb.1
        for <netdev@vger.kernel.org>; Wed, 10 Feb 2016 08:50:49 -0800 (PST)
In-Reply-To: <1455123041-22638-1-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraig@google.com>

In order to support fast lookups for TCP sockets with SO_REUSEPORT,
the function that adds sockets to the listening hash set needs
to be able to check receive address equality.  Since this equality
check is different for IPv4 and IPv6, we will need two different
socket hashing functions.

This patch adds inet6_hash identical to the existing inet_hash function
and updates the appropriate references.  A following patch will
differentiate the two by passing different comparison functions to
__inet_hash.

Additionally, in order to use the IPv6 address equality function from
inet6_hashtables (which is compiled as a built-in object when IPv6 is
enabled) it also needs to be in a built-in object file as well.  This
moves ipv6_rcv_saddr_equal into inet_hashtables to accomplish this.

Signed-off-by: Craig Gallek <kraig@google.com>
---
 include/net/inet6_hashtables.h |  2 ++
 net/dccp/ipv6.c                |  2 +-
 net/ipv6/inet6_hashtables.c    | 56 ++++++++++++++++++++++++++++++++++++++++++
 net/ipv6/tcp_ipv6.c            |  2 +-
 net/ipv6/udp.c                 | 44 +--------------------------------
 net/l2tp/l2tp_ip6.c            |  3 ++-
 6 files changed, 63 insertions(+), 46 deletions(-)

diff --git a/include/net/inet6_hashtables.h b/include/net/inet6_hashtables.h
index 7ff588ca6817..b3c28a9dfbf1 100644
--- a/include/net/inet6_hashtables.h
+++ b/include/net/inet6_hashtables.h
@@ -96,6 +96,8 @@ struct sock *inet6_lookup(struct net *net, struct inet_hashinfo *hashinfo,
 			  const struct in6_addr *saddr, const __be16 sport,
 			  const struct in6_addr *daddr, const __be16 dport,
 			  const int dif);
+
+int inet6_hash(struct sock *sk);
 #endif /* IS_ENABLED(CONFIG_IPV6) */
 
 #define INET6_MATCH(__sk, __net, __saddr, __daddr, __ports, __dif)	\
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 9c6d0508e63a..90a8269b28d0 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -993,7 +993,7 @@ static struct proto dccp_v6_prot = {
 	.sendmsg	   = dccp_sendmsg,
 	.recvmsg	   = dccp_recvmsg,
 	.backlog_rcv	   = dccp_v6_do_rcv,
-	.hash		   = inet_hash,
+	.hash		   = inet6_hash,
 	.unhash		   = inet_unhash,
 	.accept		   = inet_csk_accept,
 	.get_port	   = inet_csk_get_port,
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 21ace5a2bf7c..072653dd9c98 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -274,3 +274,59 @@ int inet6_hash_connect(struct inet_timewait_death_row *death_row,
 				   __inet6_check_established);
 }
 EXPORT_SYMBOL_GPL(inet6_hash_connect);
+
+int inet6_hash(struct sock *sk)
+{
+	if (sk->sk_state != TCP_CLOSE) {
+		local_bh_disable();
+		__inet_hash(sk, NULL);
+		local_bh_enable();
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(inet6_hash);
+
+/* match_wildcard == true:  IPV6_ADDR_ANY equals to any IPv6 addresses if IPv6
+ *                          only, and any IPv4 addresses if not IPv6 only
+ * match_wildcard == false: addresses must be exactly the same, i.e.
+ *                          IPV6_ADDR_ANY only equals to IPV6_ADDR_ANY,
+ *                          and 0.0.0.0 equals to 0.0.0.0 only
+ */
+int ipv6_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2,
+			 bool match_wildcard)
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
+EXPORT_SYMBOL_GPL(ipv6_rcv_saddr_equal);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 006396e31cb0..d72bcfb326d8 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1865,7 +1865,7 @@ struct proto tcpv6_prot = {
 	.sendpage		= tcp_sendpage,
 	.backlog_rcv		= tcp_v6_do_rcv,
 	.release_cb		= tcp_release_cb,
-	.hash			= inet_hash,
+	.hash			= inet6_hash,
 	.unhash			= inet_unhash,
 	.get_port		= inet_csk_get_port,
 	.enter_memory_pressure	= tcp_enter_memory_pressure,
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 22e28a44e3c8..ac4e7e03dded 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -37,6 +37,7 @@
 #include <linux/slab.h>
 #include <asm/uaccess.h>
 
+#include <net/addrconf.h>
 #include <net/ndisc.h>
 #include <net/protocol.h>
 #include <net/transp_v6.h>
@@ -77,49 +78,6 @@ static u32 udp6_ehashfn(const struct net *net,
 			       udp_ipv6_hash_secret + net_hash_mix(net));
 }
 
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
-
 static u32 udp6_portaddr_hash(const struct net *net,
 			      const struct in6_addr *addr6,
 			      unsigned int port)
diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index a2c8747d2936..6b54ff3ff4cb 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -25,6 +25,7 @@
 #include <net/udp.h>
 #include <net/inet_common.h>
 #include <net/inet_hashtables.h>
+#include <net/inet6_hashtables.h>
 #include <net/tcp_states.h>
 #include <net/protocol.h>
 #include <net/xfrm.h>
@@ -718,7 +719,7 @@ static struct proto l2tp_ip6_prot = {
 	.sendmsg	   = l2tp_ip6_sendmsg,
 	.recvmsg	   = l2tp_ip6_recvmsg,
 	.backlog_rcv	   = l2tp_ip6_backlog_recv,
-	.hash		   = inet_hash,
+	.hash		   = inet6_hash,
 	.unhash		   = inet_unhash,
 	.obj_size	   = sizeof(struct l2tp_ip6_sock),
 #ifdef CONFIG_COMPAT
-- 
2.7.0.rc3.207.g0ac5344
