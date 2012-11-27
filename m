From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: move inet_dport/inet_num in sock_common
Date: Tue, 27 Nov 2012 07:06:55 -0800
Message-ID: <1354028815.14302.35.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Ling Ma <ling.ma.program@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:57553 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755698Ab2K0PG7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2012 10:06:59 -0500
Received: by mail-ia0-f174.google.com with SMTP id y25so9015636iay.19
        for <netdev@vger.kernel.org>; Tue, 27 Nov 2012 07:06:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

commit 68835aba4d9b (net: optimize INET input path further)
moved some fields used for tcp/udp sockets lookup in the first cache
line of struct sock_common.

This patch moves inet_dport/inet_num as well, filling a 32bit hole
on 64 bit arches and reducing number of cache line misses.

Also change INET_MATCH()/INET_TW_MATCH() to perform the ports match
before addresses match, as this check is more discriminant.
The namespace check can also be done at last.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Ling Ma <ling.ma.program@gmail.com>
---
 include/linux/ipv6.h             |   26 ++++++++++---------
 include/net/inet_hashtables.h    |   38 ++++++++++++++++-------------
 include/net/inet_sock.h          |    4 +--
 include/net/inet_timewait_sock.h |    5 ++-
 include/net/sock.h               |   10 ++++++-
 5 files changed, 48 insertions(+), 35 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 5e11905..196ede4 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -365,19 +365,21 @@ static inline struct raw6_sock *raw6_sk(const struct sock *sk)
 #endif /* IS_ENABLED(CONFIG_IPV6) */
 
 #define INET6_MATCH(__sk, __net, __hash, __saddr, __daddr, __ports, __dif)\
-	(((__sk)->sk_hash == (__hash)) && sock_net((__sk)) == (__net)	&& \
-	 ((*((__portpair *)&(inet_sk(__sk)->inet_dport))) == (__ports)) && \
-	 ((__sk)->sk_family		== AF_INET6)		&& \
-	 ipv6_addr_equal(&inet6_sk(__sk)->daddr, (__saddr))	&& \
-	 ipv6_addr_equal(&inet6_sk(__sk)->rcv_saddr, (__daddr))	&& \
-	 (!((__sk)->sk_bound_dev_if) || ((__sk)->sk_bound_dev_if == (__dif))))
+	(((__sk)->sk_hash == (__hash)) &&					\
+	 ((*((__portpair *)&(inet_sk(__sk)->inet_dport))) == (__ports)) &&	\
+	 ((__sk)->sk_family		== AF_INET6)		&&		\
+	 ipv6_addr_equal(&inet6_sk(__sk)->daddr, (__saddr))	&&		\
+	 ipv6_addr_equal(&inet6_sk(__sk)->rcv_saddr, (__daddr))	&&		\
+	 (!((__sk)->sk_bound_dev_if) || ((__sk)->sk_bound_dev_if == (__dif))) && \
+	 net_eq(sock_net(__sk), (__net)))
 
 #define INET6_TW_MATCH(__sk, __net, __hash, __saddr, __daddr, __ports, __dif) \
-	(((__sk)->sk_hash == (__hash)) && sock_net((__sk)) == (__net)	&& \
-	 (*((__portpair *)&(inet_twsk(__sk)->tw_dport)) == (__ports))	&& \
-	 ((__sk)->sk_family	       == PF_INET6)			&& \
-	 (ipv6_addr_equal(&inet6_twsk(__sk)->tw_v6_daddr, (__saddr)))	&& \
-	 (ipv6_addr_equal(&inet6_twsk(__sk)->tw_v6_rcv_saddr, (__daddr))) && \
-	 (!((__sk)->sk_bound_dev_if) || ((__sk)->sk_bound_dev_if == (__dif))))
+	(((__sk)->sk_hash == (__hash)) &&					\
+	 (*((__portpair *)&(inet_twsk(__sk)->tw_dport)) == (__ports))	&&	\
+	 ((__sk)->sk_family	       == PF_INET6)			&&	\
+	 (ipv6_addr_equal(&inet6_twsk(__sk)->tw_v6_daddr, (__saddr)))	&&	\
+	 (ipv6_addr_equal(&inet6_twsk(__sk)->tw_v6_rcv_saddr, (__daddr))) &&	\
+	 (!((__sk)->sk_bound_dev_if) || ((__sk)->sk_bound_dev_if == (__dif))) && \
+	 net_eq(sock_net(__sk), (__net)))
 
 #endif /* _IPV6_H */
diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 54be028..cd6766a 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -300,29 +300,33 @@ typedef __u64 __bitwise __addrpair;
 				   ((__force __u64)(__be32)(__saddr)));
 #endif /* __BIG_ENDIAN */
 #define INET_MATCH(__sk, __net, __hash, __cookie, __saddr, __daddr, __ports, __dif)\
-	(((__sk)->sk_hash == (__hash)) && net_eq(sock_net(__sk), (__net)) &&	\
-	 ((*((__addrpair *)&(inet_sk(__sk)->inet_daddr))) == (__cookie))  &&	\
-	 ((*((__portpair *)&(inet_sk(__sk)->inet_dport))) == (__ports))   &&	\
-	 (!((__sk)->sk_bound_dev_if) || ((__sk)->sk_bound_dev_if == (__dif))))
+	(((__sk)->sk_hash == (__hash)) &&					\
+	 ((*((__portpair *)&(inet_sk(__sk)->inet_dport))) == (__ports)) &&	\
+	 ((*((__addrpair *)&(inet_sk(__sk)->inet_daddr))) == (__cookie)) &&	\
+	 (!((__sk)->sk_bound_dev_if) || ((__sk)->sk_bound_dev_if == (__dif))) && \
+	 net_eq(sock_net(__sk), (__net)))
 #define INET_TW_MATCH(__sk, __net, __hash, __cookie, __saddr, __daddr, __ports, __dif)\
-	(((__sk)->sk_hash == (__hash)) && net_eq(sock_net(__sk), (__net)) &&	\
-	 ((*((__addrpair *)&(inet_twsk(__sk)->tw_daddr))) == (__cookie)) &&	\
+	(((__sk)->sk_hash == (__hash)) &&					\
 	 ((*((__portpair *)&(inet_twsk(__sk)->tw_dport))) == (__ports)) &&	\
-	 (!((__sk)->sk_bound_dev_if) || ((__sk)->sk_bound_dev_if == (__dif))))
+	 ((*((__addrpair *)&(inet_twsk(__sk)->tw_daddr))) == (__cookie)) &&	\
+	 (!((__sk)->sk_bound_dev_if) || ((__sk)->sk_bound_dev_if == (__dif))) && \
+	 net_eq(sock_net(__sk), (__net)))
 #else /* 32-bit arch */
 #define INET_ADDR_COOKIE(__name, __saddr, __daddr)
 #define INET_MATCH(__sk, __net, __hash, __cookie, __saddr, __daddr, __ports, __dif)	\
-	(((__sk)->sk_hash == (__hash)) && net_eq(sock_net(__sk), (__net))	&&	\
-	 (inet_sk(__sk)->inet_daddr	== (__saddr))		&&	\
-	 (inet_sk(__sk)->inet_rcv_saddr	== (__daddr))		&&	\
-	 ((*((__portpair *)&(inet_sk(__sk)->inet_dport))) == (__ports))	&&	\
-	 (!((__sk)->sk_bound_dev_if) || ((__sk)->sk_bound_dev_if == (__dif))))
+	(((__sk)->sk_hash == (__hash)) &&						\
+	 ((*((__portpair *)&(inet_sk(__sk)->inet_dport))) == (__ports))	&&		\
+	 (inet_sk(__sk)->inet_daddr	== (__saddr))		&&			\
+	 (inet_sk(__sk)->inet_rcv_saddr	== (__daddr))		&&			\
+	 (!((__sk)->sk_bound_dev_if) || ((__sk)->sk_bound_dev_if == (__dif))) &&	\
+	 net_eq(sock_net(__sk), (__net)))
 #define INET_TW_MATCH(__sk, __net, __hash,__cookie, __saddr, __daddr, __ports, __dif)	\
-	(((__sk)->sk_hash == (__hash)) && net_eq(sock_net(__sk), (__net))	&&	\
-	 (inet_twsk(__sk)->tw_daddr	== (__saddr))		&&	\
-	 (inet_twsk(__sk)->tw_rcv_saddr	== (__daddr))		&&	\
-	 ((*((__portpair *)&(inet_twsk(__sk)->tw_dport))) == (__ports)) &&	\
-	 (!((__sk)->sk_bound_dev_if) || ((__sk)->sk_bound_dev_if == (__dif))))
+	(((__sk)->sk_hash == (__hash)) &&						\
+	 ((*((__portpair *)&(inet_twsk(__sk)->tw_dport))) == (__ports)) &&		\
+	 (inet_twsk(__sk)->tw_daddr	== (__saddr))		&&			\
+	 (inet_twsk(__sk)->tw_rcv_saddr	== (__daddr))		&&			\
+	 (!((__sk)->sk_bound_dev_if) || ((__sk)->sk_bound_dev_if == (__dif))) &&	\
+	 net_eq(sock_net(__sk), (__net)))
 #endif /* 64-bit arch */
 
 /*
diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 256c1ed..ae6cfa5 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -144,9 +144,9 @@ struct inet_sock {
 	/* Socket demultiplex comparisons on incoming packets. */
 #define inet_daddr		sk.__sk_common.skc_daddr
 #define inet_rcv_saddr		sk.__sk_common.skc_rcv_saddr
+#define inet_dport		sk.__sk_common.skc_dport
+#define inet_num		sk.__sk_common.skc_num
 
-	__be16			inet_dport;
-	__u16			inet_num;
 	__be32			inet_saddr;
 	__s16			uc_ttl;
 	__u16			cmsg_flags;
diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
index ba52c83..671dbb7 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -112,6 +112,9 @@ struct inet_timewait_sock {
 #define tw_net			__tw_common.skc_net
 #define tw_daddr        	__tw_common.skc_daddr
 #define tw_rcv_saddr    	__tw_common.skc_rcv_saddr
+#define tw_dport		__tw_common.skc_dport
+#define tw_num			__tw_common.skc_num
+
 	int			tw_timeout;
 	volatile unsigned char	tw_substate;
 	unsigned char		tw_rcv_wscale;
@@ -119,8 +122,6 @@ struct inet_timewait_sock {
 	/* Socket demultiplex comparisons on incoming packets. */
 	/* these three are in inet_sock */
 	__be16			tw_sport;
-	__be16			tw_dport;
-	__u16			tw_num;
 	kmemcheck_bitfield_begin(flags);
 	/* And these are ours. */
 	unsigned int		tw_ipv6only     : 1,
diff --git a/include/net/sock.h b/include/net/sock.h
index c945fba..e4bab2e 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -132,6 +132,8 @@ struct net;
  *	@skc_rcv_saddr: Bound local IPv4 addr
  *	@skc_hash: hash value used with various protocol lookup tables
  *	@skc_u16hashes: two u16 hash values used by UDP lookup tables
+ *	@skc_dport: placeholder for inet_dport/tw_dport
+ *	@skc_num: placeholder for inet_num/tw_num
  *	@skc_family: network address family
  *	@skc_state: Connection state
  *	@skc_reuse: %SO_REUSEADDR setting
@@ -149,8 +151,8 @@ struct net;
  *	for struct sock and struct inet_timewait_sock.
  */
 struct sock_common {
-	/* skc_daddr and skc_rcv_saddr must be grouped :
-	 * cf INET_MATCH() and INET_TW_MATCH()
+	/* skc_daddr and skc_rcv_saddr must be grouped on a 8 bytes aligned
+	 * address on 64bit arches : cf INET_MATCH() and INET_TW_MATCH()
 	 */
 	__be32			skc_daddr;
 	__be32			skc_rcv_saddr;
@@ -159,6 +161,10 @@ struct sock_common {
 		unsigned int	skc_hash;
 		__u16		skc_u16hashes[2];
 	};
+	/* skc_dport && skc_num must be grouped as well */
+	__be16			skc_dport;
+	__u16			skc_num;
+
 	unsigned short		skc_family;
 	volatile unsigned char	skc_state;
 	unsigned char		skc_reuse;
