From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] inet: consolidate INET_TW_MATCH
Date: Wed, 02 Oct 2013 04:29:50 -0700
Message-ID: <1380713390.19002.87.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:37922 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753414Ab3JBL3w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 07:29:52 -0400
Received: by mail-pb0-f52.google.com with SMTP id wz12so739401pbc.25
        for <netdev@vger.kernel.org>; Wed, 02 Oct 2013 04:29:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

TCP listener refactoring, part 2 :

We can use a generic lookup, sockets being in whatever state, if
we are sure all relevant fields are at the same place in all socket
types (ESTABLISH, TIME_WAIT, SYN_RECV)

This patch removes these macros :

 inet_addrpair, inet_addrpair, tw_addrpair, tw_portpair

And adds :

 sk_portpair, sk_addrpair, sk_daddr, sk_rcv_saddr

Then, INET_TW_MATCH() is really the same than INET_MATCH()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/ipv6.h             |    4 ++--
 include/net/inet_hashtables.h    |   26 ++++++++------------------
 include/net/inet_sock.h          |    2 --
 include/net/inet_timewait_sock.h |    8 --------
 include/net/sock.h               |    4 ++++
 net/ipv4/inet_connection_sock.c  |   11 +++++------
 net/ipv6/udp.c                   |    6 ++----
 7 files changed, 21 insertions(+), 40 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 28ea384..b7f1f3b 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -370,7 +370,7 @@ static inline struct raw6_sock *raw6_sk(const struct sock *sk)
 #endif /* IS_ENABLED(CONFIG_IPV6) */
 
 #define INET6_MATCH(__sk, __net, __saddr, __daddr, __ports, __dif)	\
-	((inet_sk(__sk)->inet_portpair == (__ports))		&&	\
+	(((__sk)->sk_portpair == (__ports))			&&	\
 	 ((__sk)->sk_family == AF_INET6)			&&	\
 	 ipv6_addr_equal(&inet6_sk(__sk)->daddr, (__saddr))	&&	\
 	 ipv6_addr_equal(&inet6_sk(__sk)->rcv_saddr, (__daddr))	&&	\
@@ -379,7 +379,7 @@ static inline struct raw6_sock *raw6_sk(const struct sock *sk)
 	 net_eq(sock_net(__sk), (__net)))
 
 #define INET6_TW_MATCH(__sk, __net, __saddr, __daddr, __ports, __dif)	   \
-	((inet_twsk(__sk)->tw_portpair == (__ports))			&& \
+	(((__sk)->sk_portpair == (__ports))				&& \
 	 ((__sk)->sk_family == AF_INET6)				&& \
 	 ipv6_addr_equal(&inet6_twsk(__sk)->tw_v6_daddr, (__saddr))	&& \
 	 ipv6_addr_equal(&inet6_twsk(__sk)->tw_v6_rcv_saddr, (__daddr)) && \
diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 594dfee..10d6838 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -302,35 +302,25 @@ static inline struct sock *inet_lookup_listener(struct net *net,
 				   ((__force __u64)(__be32)(__saddr)));
 #endif /* __BIG_ENDIAN */
 #define INET_MATCH(__sk, __net, __cookie, __saddr, __daddr, __ports, __dif)	\
-	((inet_sk(__sk)->inet_portpair == (__ports))		&&	\
-	 (inet_sk(__sk)->inet_addrpair == (__cookie))		&&	\
+	(((__sk)->sk_portpair == (__ports))			&&	\
+	 ((__sk)->sk_addrpair == (__cookie))			&&	\
 	 (!(__sk)->sk_bound_dev_if	||				\
 	   ((__sk)->sk_bound_dev_if == (__dif))) 		&& 	\
 	 net_eq(sock_net(__sk), (__net)))
-#define INET_TW_MATCH(__sk, __net, __cookie, __saddr, __daddr, __ports, __dif)\
-	((inet_twsk(__sk)->tw_portpair == (__ports))	&&		\
-	 (inet_twsk(__sk)->tw_addrpair == (__cookie))	&&		\
-	 (!(__sk)->sk_bound_dev_if	||				\
-	   ((__sk)->sk_bound_dev_if == (__dif)))	&&		\
-	 net_eq(sock_net(__sk), (__net)))
 #else /* 32-bit arch */
 #define INET_ADDR_COOKIE(__name, __saddr, __daddr)
 #define INET_MATCH(__sk, __net, __cookie, __saddr, __daddr, __ports, __dif) \
-	((inet_sk(__sk)->inet_portpair == (__ports))	&&		\
-	 (inet_sk(__sk)->inet_daddr	== (__saddr))	&&		\
-	 (inet_sk(__sk)->inet_rcv_saddr	== (__daddr))	&&		\
-	 (!(__sk)->sk_bound_dev_if	||				\
-	   ((__sk)->sk_bound_dev_if == (__dif))) 	&&		\
-	 net_eq(sock_net(__sk), (__net)))
-#define INET_TW_MATCH(__sk, __net, __cookie, __saddr, __daddr, __ports, __dif) \
-	((inet_twsk(__sk)->tw_portpair == (__ports))	&&		\
-	 (inet_twsk(__sk)->tw_daddr	== (__saddr))	&&		\
-	 (inet_twsk(__sk)->tw_rcv_saddr	== (__daddr))	&&		\
+	(((__sk)->sk_portpair == (__ports))		&&		\
+	 ((__sk)->sk_daddr	== (__saddr))		&&		\
+	 ((__sk)->sk_rcv_saddr	== (__daddr))		&&		\
 	 (!(__sk)->sk_bound_dev_if	||				\
 	   ((__sk)->sk_bound_dev_if == (__dif))) 	&&		\
 	 net_eq(sock_net(__sk), (__net)))
 #endif /* 64-bit arch */
 
+#define INET_TW_MATCH(__sk, __net, __cookie, __saddr, __daddr, __ports, __dif)\
+	INET_MATCH(__sk, __net, __cookie, __saddr, __daddr, __ports, __dif)
+
 /*
  * Sockets in TCP_CLOSE state are _always_ taken out of the hash, so we need
  * not check it for lookups anymore, thanks Alexey. -DaveM
diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index f314177..6d9a7e6 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -146,10 +146,8 @@ struct inet_sock {
 	/* Socket demultiplex comparisons on incoming packets. */
 #define inet_daddr		sk.__sk_common.skc_daddr
 #define inet_rcv_saddr		sk.__sk_common.skc_rcv_saddr
-#define inet_addrpair		sk.__sk_common.skc_addrpair
 #define inet_dport		sk.__sk_common.skc_dport
 #define inet_num		sk.__sk_common.skc_num
-#define inet_portpair		sk.__sk_common.skc_portpair
 
 	__be32			inet_saddr;
 	__s16			uc_ttl;
diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
index 828200a..48fd356 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -112,10 +112,8 @@ struct inet_timewait_sock {
 #define tw_net			__tw_common.skc_net
 #define tw_daddr        	__tw_common.skc_daddr
 #define tw_rcv_saddr    	__tw_common.skc_rcv_saddr
-#define tw_addrpair		__tw_common.skc_addrpair
 #define tw_dport		__tw_common.skc_dport
 #define tw_num			__tw_common.skc_num
-#define tw_portpair		__tw_common.skc_portpair
 
 	int			tw_timeout;
 	volatile unsigned char	tw_substate;
@@ -189,12 +187,6 @@ static inline struct inet_timewait_sock *inet_twsk(const struct sock *sk)
 	return (struct inet_timewait_sock *)sk;
 }
 
-static inline __be32 sk_rcv_saddr(const struct sock *sk)
-{
-/* both inet_sk() and inet_twsk() store rcv_saddr in skc_rcv_saddr */
-	return sk->__sk_common.skc_rcv_saddr;
-}
-
 void inet_twsk_put(struct inet_timewait_sock *tw);
 
 int inet_twsk_unhash(struct inet_timewait_sock *tw);
diff --git a/include/net/sock.h b/include/net/sock.h
index f0a44cc..e3bf213 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -300,6 +300,10 @@ struct sock {
 #define sk_dontcopy_begin	__sk_common.skc_dontcopy_begin
 #define sk_dontcopy_end		__sk_common.skc_dontcopy_end
 #define sk_hash			__sk_common.skc_hash
+#define sk_portpair		__sk_common.skc_portpair
+#define sk_addrpair		__sk_common.skc_addrpair
+#define sk_daddr		__sk_common.skc_daddr
+#define sk_rcv_saddr		__sk_common.skc_rcv_saddr
 #define sk_family		__sk_common.skc_family
 #define sk_state		__sk_common.skc_state
 #define sk_reuse		__sk_common.skc_reuse
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 7ac7aa1..56e82a4 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -71,17 +71,16 @@ int inet_csk_bind_conflict(const struct sock *sk,
 			    (!reuseport || !sk2->sk_reuseport ||
 			    (sk2->sk_state != TCP_TIME_WAIT &&
 			     !uid_eq(uid, sock_i_uid(sk2))))) {
-				const __be32 sk2_rcv_saddr = sk_rcv_saddr(sk2);
-				if (!sk2_rcv_saddr || !sk_rcv_saddr(sk) ||
-				    sk2_rcv_saddr == sk_rcv_saddr(sk))
+
+				if (!sk2->sk_rcv_saddr || !sk->sk_rcv_saddr ||
+				    sk2->sk_rcv_saddr == sk->sk_rcv_saddr)
 					break;
 			}
 			if (!relax && reuse && sk2->sk_reuse &&
 			    sk2->sk_state != TCP_LISTEN) {
-				const __be32 sk2_rcv_saddr = sk_rcv_saddr(sk2);
 
-				if (!sk2_rcv_saddr || !sk_rcv_saddr(sk) ||
-				    sk2_rcv_saddr == sk_rcv_saddr(sk))
+				if (!sk2->sk_rcv_saddr || !sk->sk_rcv_saddr ||
+				    sk2->sk_rcv_saddr == sk->sk_rcv_saddr)
 					break;
 			}
 		}
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 72b7eaa..8119791 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -57,8 +57,6 @@ int ipv6_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2)
 {
 	const struct in6_addr *sk_rcv_saddr6 = &inet6_sk(sk)->rcv_saddr;
 	const struct in6_addr *sk2_rcv_saddr6 = inet6_rcv_saddr(sk2);
-	__be32 sk1_rcv_saddr = sk_rcv_saddr(sk);
-	__be32 sk2_rcv_saddr = sk_rcv_saddr(sk2);
 	int sk_ipv6only = ipv6_only_sock(sk);
 	int sk2_ipv6only = inet_v6_ipv6only(sk2);
 	int addr_type = ipv6_addr_type(sk_rcv_saddr6);
@@ -67,8 +65,8 @@ int ipv6_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2)
 	/* if both are mapped, treat as IPv4 */
 	if (addr_type == IPV6_ADDR_MAPPED && addr_type2 == IPV6_ADDR_MAPPED)
 		return (!sk2_ipv6only &&
-			(!sk1_rcv_saddr || !sk2_rcv_saddr ||
-			  sk1_rcv_saddr == sk2_rcv_saddr));
+			(!sk->sk_rcv_saddr || !sk2->sk_rcv_saddr ||
+			  sk->sk_rcv_saddr == sk2->sk_rcv_saddr));
 
 	if (addr_type2 == IPV6_ADDR_ANY &&
 	    !(sk2_ipv6only && addr_type == IPV6_ADDR_MAPPED))
