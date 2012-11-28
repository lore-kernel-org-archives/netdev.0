From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next] net: move inet_dport/inet_num in sock_common
Date: Wed, 28 Nov 2012 04:56:18 -0800
Message-ID: <1354107378.14302.149.camel@edumazet-glaptop>
References: <1354028815.14302.35.camel@edumazet-glaptop>
	 <1354037000.2116.19.camel@joe-AO722>
	 <1354051475.14302.42.camel@edumazet-glaptop>
	 <1354069414.8918.13.camel@joe-AO722>
	 <1354075918.14302.77.camel@edumazet-glaptop>
	 <1354102061.14302.84.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Ling Ma <ling.ma.program@gmail.com>,
	Joe Perches <joe@perches.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:50935 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754475Ab2K1M4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 07:56:21 -0500
Received: by mail-ie0-f174.google.com with SMTP id k11so9978127iea.19
        for <netdev@vger.kernel.org>; Wed, 28 Nov 2012 04:56:20 -0800 (PST)
In-Reply-To: <1354102061.14302.84.camel@edumazet-glaptop>
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

Remove the hash check from MATCH() macros because we dont need to
re validate the hash value after taking a refcount on socket, and
use likely/unlikely compiler hints, as the sk_hash/hash check
makes the following conditional tests 100% predicted by cpu.

Introduce skc_addrpair/skc_portpair pair values to better
document the alignment requirements of the port/addr pairs
used in the various MATCH() macros, and remove some casts.

The namespace check can also be done at last.

This slightly improves TCP/UDP lookup times.

With help from Ben Hutchings & Joe Perches.

Idea of this patch came after Ling Ma proposal to move skc_hash
to the beginning of struct sock_common, and should allow him
to submit a final version of his patch.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>
Cc: Joe Perches <joe@perches.com>
Cc: Ling Ma <ling.ma.program@gmail.com>
---
 include/linux/ipv6.h             |   32 ++++++++++---------
 include/net/inet_hashtables.h    |   48 +++++++++++++++--------------
 include/net/inet_sock.h          |    6 ++-
 include/net/inet_timewait_sock.h |    7 +++-
 include/net/sock.h               |   25 ++++++++++++---
 net/ipv4/inet_hashtables.c       |   36 +++++++++++++--------
 net/ipv6/inet6_hashtables.c      |   27 +++++++++++-----
 7 files changed, 114 insertions(+), 67 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 5e11905..12729e9 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -364,20 +364,22 @@ static inline struct raw6_sock *raw6_sk(const struct sock *sk)
 #define inet_v6_ipv6only(__sk)		0
 #endif /* IS_ENABLED(CONFIG_IPV6) */
 
-#define INET6_MATCH(__sk, __net, __hash, __saddr, __daddr, __ports, __dif)\
-	(((__sk)->sk_hash == (__hash)) && sock_net((__sk)) == (__net)	&& \
-	 ((*((__portpair *)&(inet_sk(__sk)->inet_dport))) == (__ports)) && \
-	 ((__sk)->sk_family		== AF_INET6)		&& \
-	 ipv6_addr_equal(&inet6_sk(__sk)->daddr, (__saddr))	&& \
-	 ipv6_addr_equal(&inet6_sk(__sk)->rcv_saddr, (__daddr))	&& \
-	 (!((__sk)->sk_bound_dev_if) || ((__sk)->sk_bound_dev_if == (__dif))))
-
-#define INET6_TW_MATCH(__sk, __net, __hash, __saddr, __daddr, __ports, __dif) \
-	(((__sk)->sk_hash == (__hash)) && sock_net((__sk)) == (__net)	&& \
-	 (*((__portpair *)&(inet_twsk(__sk)->tw_dport)) == (__ports))	&& \
-	 ((__sk)->sk_family	       == PF_INET6)			&& \
-	 (ipv6_addr_equal(&inet6_twsk(__sk)->tw_v6_daddr, (__saddr)))	&& \
-	 (ipv6_addr_equal(&inet6_twsk(__sk)->tw_v6_rcv_saddr, (__daddr))) && \
-	 (!((__sk)->sk_bound_dev_if) || ((__sk)->sk_bound_dev_if == (__dif))))
+#define INET6_MATCH(__sk, __net, __saddr, __daddr, __ports, __dif)	\
+	((inet_sk(__sk)->inet_portpair == (__ports))		&&	\
+	 ((__sk)->sk_family == AF_INET6)			&&	\
+	 ipv6_addr_equal(&inet6_sk(__sk)->daddr, (__saddr))	&&	\
+	 ipv6_addr_equal(&inet6_sk(__sk)->rcv_saddr, (__daddr))	&&	\
+	 (!(__sk)->sk_bound_dev_if	||				\
+	   ((__sk)->sk_bound_dev_if == (__dif))) 		&&	\
+	 net_eq(sock_net(__sk), (__net)))
+
+#define INET6_TW_MATCH(__sk, __net, __saddr, __daddr, __ports, __dif)	   \
+	((inet_twsk(__sk)->tw_portpair == (__ports))			&& \
+	 ((__sk)->sk_family == AF_INET6)				&& \
+	 ipv6_addr_equal(&inet6_twsk(__sk)->tw_v6_daddr, (__saddr))	&& \
+	 ipv6_addr_equal(&inet6_twsk(__sk)->tw_v6_rcv_saddr, (__daddr)) && \
+	 (!(__sk)->sk_bound_dev_if	||				   \
+	  ((__sk)->sk_bound_dev_if == (__dif)))				&& \
+	 net_eq(sock_net(__sk), (__net)))
 
 #endif /* _IPV6_H */
diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 54be028..5dc8521 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -299,30 +299,34 @@ typedef __u64 __bitwise __addrpair;
 				   (((__force __u64)(__be32)(__daddr)) << 32) | \
 				   ((__force __u64)(__be32)(__saddr)));
 #endif /* __BIG_ENDIAN */
-#define INET_MATCH(__sk, __net, __hash, __cookie, __saddr, __daddr, __ports, __dif)\
-	(((__sk)->sk_hash == (__hash)) && net_eq(sock_net(__sk), (__net)) &&	\
-	 ((*((__addrpair *)&(inet_sk(__sk)->inet_daddr))) == (__cookie))  &&	\
-	 ((*((__portpair *)&(inet_sk(__sk)->inet_dport))) == (__ports))   &&	\
-	 (!((__sk)->sk_bound_dev_if) || ((__sk)->sk_bound_dev_if == (__dif))))
-#define INET_TW_MATCH(__sk, __net, __hash, __cookie, __saddr, __daddr, __ports, __dif)\
-	(((__sk)->sk_hash == (__hash)) && net_eq(sock_net(__sk), (__net)) &&	\
-	 ((*((__addrpair *)&(inet_twsk(__sk)->tw_daddr))) == (__cookie)) &&	\
-	 ((*((__portpair *)&(inet_twsk(__sk)->tw_dport))) == (__ports)) &&	\
-	 (!((__sk)->sk_bound_dev_if) || ((__sk)->sk_bound_dev_if == (__dif))))
+#define INET_MATCH(__sk, __net, __cookie, __saddr, __daddr, __ports, __dif)	\
+	((inet_sk(__sk)->inet_portpair == (__ports))		&&	\
+	 (inet_sk(__sk)->inet_addrpair == (__addrpair))		&&	\
+	 (!(__sk)->sk_bound_dev_if	||				\
+	   ((__sk)->sk_bound_dev_if == (__dif))) 		&& 	\
+	 net_eq(sock_net(__sk), (__net)))
+#define INET_TW_MATCH(__sk, __net, __cookie, __saddr, __daddr, __ports, __dif)\
+	((inet_twsk(__sk)->tw_portpair == (__ports))	&&		\
+	 (inet_twsk(__sk)->tw_addrpair == (__addrpair))	&&		\
+	 (!(__sk)->sk_bound_dev_if	||				\
+	   ((__sk)->sk_bound_dev_if == (__dif)))	&&		\
+	 net_eq(sock_net(__sk), (__net)))
 #else /* 32-bit arch */
 #define INET_ADDR_COOKIE(__name, __saddr, __daddr)
-#define INET_MATCH(__sk, __net, __hash, __cookie, __saddr, __daddr, __ports, __dif)	\
-	(((__sk)->sk_hash == (__hash)) && net_eq(sock_net(__sk), (__net))	&&	\
-	 (inet_sk(__sk)->inet_daddr	== (__saddr))		&&	\
-	 (inet_sk(__sk)->inet_rcv_saddr	== (__daddr))		&&	\
-	 ((*((__portpair *)&(inet_sk(__sk)->inet_dport))) == (__ports))	&&	\
-	 (!((__sk)->sk_bound_dev_if) || ((__sk)->sk_bound_dev_if == (__dif))))
-#define INET_TW_MATCH(__sk, __net, __hash,__cookie, __saddr, __daddr, __ports, __dif)	\
-	(((__sk)->sk_hash == (__hash)) && net_eq(sock_net(__sk), (__net))	&&	\
-	 (inet_twsk(__sk)->tw_daddr	== (__saddr))		&&	\
-	 (inet_twsk(__sk)->tw_rcv_saddr	== (__daddr))		&&	\
-	 ((*((__portpair *)&(inet_twsk(__sk)->tw_dport))) == (__ports)) &&	\
-	 (!((__sk)->sk_bound_dev_if) || ((__sk)->sk_bound_dev_if == (__dif))))
+#define INET_MATCH(__sk, __net, __cookie, __saddr, __daddr, __ports, __dif) \
+	((inet_sk(__sk)->inet_portpair == (__ports))	&&		\
+	 (inet_sk(__sk)->inet_daddr	== (__saddr))	&&		\
+	 (inet_sk(__sk)->inet_rcv_saddr	== (__daddr))	&&		\
+	 (!(__sk)->sk_bound_dev_if	||				\
+	   ((__sk)->sk_bound_dev_if == (__dif))) 	&&		\
+	 net_eq(sock_net(__sk), (__net)))
+#define INET_TW_MATCH(__sk, __net, __cookie, __saddr, __daddr, __ports, __dif) \
+	((inet_twsk(__sk)->tw_portpair == (__ports))	&&		\
+	 (inet_twsk(__sk)->tw_daddr	== (__saddr))	&&		\
+	 (inet_twsk(__sk)->tw_rcv_saddr	== (__daddr))	&&		\
+	 (!(__sk)->sk_bound_dev_if	||				\
+	   ((__sk)->sk_bound_dev_if == (__dif))) 	&&		\
+	 net_eq(sock_net(__sk), (__net)))
 #endif /* 64-bit arch */
 
 /*
diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 256c1ed..ee5ddcd 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -144,9 +144,11 @@ struct inet_sock {
 	/* Socket demultiplex comparisons on incoming packets. */
 #define inet_daddr		sk.__sk_common.skc_daddr
 #define inet_rcv_saddr		sk.__sk_common.skc_rcv_saddr
+#define inet_addrpair		sk.__sk_common.skc_addrpair
+#define inet_dport		sk.__sk_common.skc_dport
+#define inet_num		sk.__sk_common.skc_num
+#define inet_portpair		sk.__sk_common.skc_portpair
 
-	__be16			inet_dport;
-	__u16			inet_num;
 	__be32			inet_saddr;
 	__s16			uc_ttl;
 	__u16			cmsg_flags;
diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
index ba52c83..7d658d5 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -112,6 +112,11 @@ struct inet_timewait_sock {
 #define tw_net			__tw_common.skc_net
 #define tw_daddr        	__tw_common.skc_daddr
 #define tw_rcv_saddr    	__tw_common.skc_rcv_saddr
+#define tw_addrpair		__tw_common.skc_addrpair
+#define tw_dport		__tw_common.skc_dport
+#define tw_num			__tw_common.skc_num
+#define tw_portpair		__tw_common.skc_portpair
+
 	int			tw_timeout;
 	volatile unsigned char	tw_substate;
 	unsigned char		tw_rcv_wscale;
@@ -119,8 +124,6 @@ struct inet_timewait_sock {
 	/* Socket demultiplex comparisons on incoming packets. */
 	/* these three are in inet_sock */
 	__be16			tw_sport;
-	__be16			tw_dport;
-	__u16			tw_num;
 	kmemcheck_bitfield_begin(flags);
 	/* And these are ours. */
 	unsigned int		tw_ipv6only     : 1,
diff --git a/include/net/sock.h b/include/net/sock.h
index c945fba..c4132c1 100644
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
@@ -149,16 +151,29 @@ struct net;
  *	for struct sock and struct inet_timewait_sock.
  */
 struct sock_common {
-	/* skc_daddr and skc_rcv_saddr must be grouped :
-	 * cf INET_MATCH() and INET_TW_MATCH()
+	/* skc_daddr and skc_rcv_saddr must be grouped on a 8 bytes aligned
+	 * address on 64bit arches : cf INET_MATCH() and INET_TW_MATCH()
 	 */
-	__be32			skc_daddr;
-	__be32			skc_rcv_saddr;
-
+	union {
+		unsigned long	skc_addrpair;
+		struct {
+			__be32	skc_daddr;
+			__be32	skc_rcv_saddr;
+		};
+	};
 	union  {
 		unsigned int	skc_hash;
 		__u16		skc_u16hashes[2];
 	};
+	/* skc_dport && skc_num must be grouped as well */
+	union {
+		u32		skc_portpair;
+		struct {
+			__be16	skc_dport;
+			__u16	skc_num;
+		};
+	};
+
 	unsigned short		skc_family;
 	volatile unsigned char	skc_state;
 	unsigned char		skc_reuse;
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 7880af9..fa3ae81 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -237,12 +237,14 @@ struct sock *__inet_lookup_established(struct net *net,
 	rcu_read_lock();
 begin:
 	sk_nulls_for_each_rcu(sk, node, &head->chain) {
-		if (INET_MATCH(sk, net, hash, acookie,
-					saddr, daddr, ports, dif)) {
+		if (sk->sk_hash != hash)
+			continue;
+		if (likely(INET_MATCH(sk, net, acookie,
+				      saddr, daddr, ports, dif))) {
 			if (unlikely(!atomic_inc_not_zero(&sk->sk_refcnt)))
 				goto begintw;
-			if (unlikely(!INET_MATCH(sk, net, hash, acookie,
-				saddr, daddr, ports, dif))) {
+			if (unlikely(!INET_MATCH(sk, net, acookie,
+						 saddr, daddr, ports, dif))) {
 				sock_put(sk);
 				goto begin;
 			}
@@ -260,14 +262,18 @@ begin:
 begintw:
 	/* Must check for a TIME_WAIT'er before going to listener hash. */
 	sk_nulls_for_each_rcu(sk, node, &head->twchain) {
-		if (INET_TW_MATCH(sk, net, hash, acookie,
-					saddr, daddr, ports, dif)) {
+		if (sk->sk_hash != hash)
+			continue;
+		if (likely(INET_TW_MATCH(sk, net, acookie,
+					 saddr, daddr, ports,
+					 dif))) {
 			if (unlikely(!atomic_inc_not_zero(&sk->sk_refcnt))) {
 				sk = NULL;
 				goto out;
 			}
-			if (unlikely(!INET_TW_MATCH(sk, net, hash, acookie,
-				 saddr, daddr, ports, dif))) {
+			if (unlikely(!INET_TW_MATCH(sk, net, acookie,
+						    saddr, daddr, ports,
+						    dif))) {
 				sock_put(sk);
 				goto begintw;
 			}
@@ -314,10 +320,12 @@ static int __inet_check_established(struct inet_timewait_death_row *death_row,
 
 	/* Check TIME-WAIT sockets first. */
 	sk_nulls_for_each(sk2, node, &head->twchain) {
-		tw = inet_twsk(sk2);
+		if (sk2->sk_hash != hash)
+			continue;
 
-		if (INET_TW_MATCH(sk2, net, hash, acookie,
-					saddr, daddr, ports, dif)) {
+		if (likely(INET_TW_MATCH(sk2, net, acookie,
+					 saddr, daddr, ports, dif))) {
+			tw = inet_twsk(sk2);
 			if (twsk_unique(sk, sk2, twp))
 				goto unique;
 			else
@@ -328,8 +336,10 @@ static int __inet_check_established(struct inet_timewait_death_row *death_row,
 
 	/* And established part... */
 	sk_nulls_for_each(sk2, node, &head->chain) {
-		if (INET_MATCH(sk2, net, hash, acookie,
-					saddr, daddr, ports, dif))
+		if (sk2->sk_hash != hash)
+			continue;
+		if (likely(INET_MATCH(sk2, net, acookie,
+				      saddr, daddr, ports, dif)))
 			goto not_unique;
 	}
 
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 73f1a00..dea17fd 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -87,11 +87,13 @@ struct sock *__inet6_lookup_established(struct net *net,
 	rcu_read_lock();
 begin:
 	sk_nulls_for_each_rcu(sk, node, &head->chain) {
-		/* For IPV6 do the cheaper port and family tests first. */
-		if (INET6_MATCH(sk, net, hash, saddr, daddr, ports, dif)) {
+		if (sk->sk_hash != hash)
+			continue;
+		if (likely(INET6_MATCH(sk, net, saddr, daddr, ports, dif))) {
 			if (unlikely(!atomic_inc_not_zero(&sk->sk_refcnt)))
 				goto begintw;
-			if (!INET6_MATCH(sk, net, hash, saddr, daddr, ports, dif)) {
+			if (unlikely(!INET6_MATCH(sk, net, saddr, daddr,
+						  ports, dif))) {
 				sock_put(sk);
 				goto begin;
 			}
@@ -104,12 +106,16 @@ begin:
 begintw:
 	/* Must check for a TIME_WAIT'er before going to listener hash. */
 	sk_nulls_for_each_rcu(sk, node, &head->twchain) {
-		if (INET6_TW_MATCH(sk, net, hash, saddr, daddr, ports, dif)) {
+		if (sk->sk_hash != hash)
+			continue;
+		if (likely(INET6_TW_MATCH(sk, net, saddr, daddr,
+					  ports, dif))) {
 			if (unlikely(!atomic_inc_not_zero(&sk->sk_refcnt))) {
 				sk = NULL;
 				goto out;
 			}
-			if (!INET6_TW_MATCH(sk, net, hash, saddr, daddr, ports, dif)) {
+			if (unlikely(!INET6_TW_MATCH(sk, net, saddr, daddr,
+						     ports, dif))) {
 				sock_put(sk);
 				goto begintw;
 			}
@@ -236,9 +242,12 @@ static int __inet6_check_established(struct inet_timewait_death_row *death_row,
 
 	/* Check TIME-WAIT sockets first. */
 	sk_nulls_for_each(sk2, node, &head->twchain) {
-		tw = inet_twsk(sk2);
+		if (sk2->sk_hash != hash)
+			continue;
 
-		if (INET6_TW_MATCH(sk2, net, hash, saddr, daddr, ports, dif)) {
+		if (likely(INET6_TW_MATCH(sk2, net, saddr, daddr,
+					  ports, dif))) {
+			tw = inet_twsk(sk2);
 			if (twsk_unique(sk, sk2, twp))
 				goto unique;
 			else
@@ -249,7 +258,9 @@ static int __inet6_check_established(struct inet_timewait_death_row *death_row,
 
 	/* And established part... */
 	sk_nulls_for_each(sk2, node, &head->chain) {
-		if (INET6_MATCH(sk2, net, hash, saddr, daddr, ports, dif))
+		if (sk2->sk_hash != hash)
+			continue;
+		if (likely(INET6_MATCH(sk2, net, saddr, daddr, ports, dif)))
 			goto not_unique;
 	}
 
