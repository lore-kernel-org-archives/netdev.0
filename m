From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: optimize INET input path further
Date: Wed, 01 Dec 2010 06:04:07 +0100
Message-ID: <1291179847.2856.452.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:49734 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750807Ab0LAFEM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 00:04:12 -0500
Received: by wwa36 with SMTP id 36so6939821wwa.1
        for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 21:04:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Followup of commit b178bb3dfc30 (net: reorder struct sock fields)

Optimize INET input path a bit further, by :

1) moving sk_refcnt close to sk_lock.

This reduces number of dirtied cache lines by one on 64bit arches (and
64 bytes cache line size).

2) moving inet_daddr & inet_rcv_saddr at the beginning of sk

(same cache line than hash / family / bound_dev_if / nulls_node)

This reduces number of accessed cache lines in lookups by one, and dont
increase size of inet and timewait socks.
inet and tw sockets now share same place-holder for these fields. 

Before patch :

offsetof(struct sock, sk_refcnt) = 0x10
offsetof(struct sock, sk_lock) = 0x40
offsetof(struct sock, sk_receive_queue) = 0x60
offsetof(struct inet_sock, inet_daddr) = 0x270
offsetof(struct inet_sock, inet_rcv_saddr) = 0x274

After patch :

offsetof(struct sock, sk_refcnt) = 0x44
offsetof(struct sock, sk_lock) = 0x48
offsetof(struct sock, sk_receive_queue) = 0x68
offsetof(struct inet_sock, inet_daddr) = 0x0
offsetof(struct inet_sock, inet_rcv_saddr) = 0x4

compute_score() (udp or tcp) now use a single cache line per ignored
item, instead of two.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/inet_sock.h          |    5 ++-
 include/net/inet_timewait_sock.h |   20 +++++----------
 include/net/sock.h               |   37 ++++++++++++++++++-----------
 net/core/sock.c                  |   11 ++++----
 net/ipv4/inet_connection_sock.c  |    7 ++---
 net/ipv6/udp.c                   |    4 +--
 6 files changed, 45 insertions(+), 39 deletions(-)

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 8945f9f..8181498 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -116,8 +116,9 @@ struct inet_sock {
 	struct ipv6_pinfo	*pinet6;
 #endif
 	/* Socket demultiplex comparisons on incoming packets. */
-	__be32			inet_daddr;
-	__be32			inet_rcv_saddr;
+#define inet_daddr		sk.__sk_common.skc_daddr
+#define inet_rcv_saddr		sk.__sk_common.skc_rcv_saddr
+
 	__be16			inet_dport;
 	__u16			inet_num;
 	__be32			inet_saddr;
diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
index a066fdd..17404b5 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -88,12 +88,6 @@ extern void inet_twdr_hangman(unsigned long data);
 extern void inet_twdr_twkill_work(struct work_struct *work);
 extern void inet_twdr_twcal_tick(unsigned long data);
 
-#if (BITS_PER_LONG == 64)
-#define INET_TIMEWAIT_ADDRCMP_ALIGN_BYTES 8
-#else
-#define INET_TIMEWAIT_ADDRCMP_ALIGN_BYTES 4
-#endif
-
 struct inet_bind_bucket;
 
 /*
@@ -117,15 +111,15 @@ struct inet_timewait_sock {
 #define tw_hash			__tw_common.skc_hash
 #define tw_prot			__tw_common.skc_prot
 #define tw_net			__tw_common.skc_net
+#define tw_daddr        	__tw_common.skc_daddr
+#define tw_rcv_saddr    	__tw_common.skc_rcv_saddr
 	int			tw_timeout;
 	volatile unsigned char	tw_substate;
-	/* 3 bits hole, try to pack */
 	unsigned char		tw_rcv_wscale;
+
 	/* Socket demultiplex comparisons on incoming packets. */
-	/* these five are in inet_sock */
+	/* these three are in inet_sock */
 	__be16			tw_sport;
-	__be32			tw_daddr __attribute__((aligned(INET_TIMEWAIT_ADDRCMP_ALIGN_BYTES)));
-	__be32			tw_rcv_saddr;
 	__be16			tw_dport;
 	__u16			tw_num;
 	kmemcheck_bitfield_begin(flags);
@@ -191,10 +185,10 @@ static inline struct inet_timewait_sock *inet_twsk(const struct sock *sk)
 	return (struct inet_timewait_sock *)sk;
 }
 
-static inline __be32 inet_rcv_saddr(const struct sock *sk)
+static inline __be32 sk_rcv_saddr(const struct sock *sk)
 {
-	return likely(sk->sk_state != TCP_TIME_WAIT) ?
-		inet_sk(sk)->inet_rcv_saddr : inet_twsk(sk)->tw_rcv_saddr;
+/* both inet_sk() and inet_twsk() store rcv_saddr in skc_rcv_saddr */
+	return sk->__sk_common.skc_rcv_saddr;
 }
 
 extern void inet_twsk_put(struct inet_timewait_sock *tw);
diff --git a/include/net/sock.h b/include/net/sock.h
index 5557dfb..f694a8c 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -105,10 +105,8 @@ struct net;
 
 /**
  *	struct sock_common - minimal network layer representation of sockets
- *	@skc_node: main hash linkage for various protocol lookup tables
- *	@skc_nulls_node: main hash linkage for TCP/UDP/UDP-Lite protocol
- *	@skc_refcnt: reference count
- *	@skc_tx_queue_mapping: tx queue number for this connection
+ *	@skc_daddr: Foreign IPv4 addr
+ *	@skc_rcv_saddr: Bound local IPv4 addr
  *	@skc_hash: hash value used with various protocol lookup tables
  *	@skc_u16hashes: two u16 hash values used by UDP lookup tables
  *	@skc_family: network address family
@@ -119,20 +117,20 @@ struct net;
  *	@skc_portaddr_node: second hash linkage for UDP/UDP-Lite protocol
  *	@skc_prot: protocol handlers inside a network family
  *	@skc_net: reference to the network namespace of this socket
+ *	@skc_node: main hash linkage for various protocol lookup tables
+ *	@skc_nulls_node: main hash linkage for TCP/UDP/UDP-Lite protocol
+ *	@skc_tx_queue_mapping: tx queue number for this connection
+ *	@skc_refcnt: reference count
  *
  *	This is the minimal network layer representation of sockets, the header
  *	for struct sock and struct inet_timewait_sock.
  */
 struct sock_common {
-	/*
-	 * first fields are not copied in sock_copy()
+	/* skc_daddr and skc_rcv_saddr must be grouped :
+	 * cf INET_MATCH() and INET_TW_MATCH()
 	 */
-	union {
-		struct hlist_node	skc_node;
-		struct hlist_nulls_node skc_nulls_node;
-	};
-	atomic_t		skc_refcnt;
-	int			skc_tx_queue_mapping;
+	__be32			skc_daddr;
+	__be32			skc_rcv_saddr;
 
 	union  {
 		unsigned int	skc_hash;
@@ -150,6 +148,18 @@ struct sock_common {
 #ifdef CONFIG_NET_NS
 	struct net	 	*skc_net;
 #endif
+	/*
+	 * fields between dontcopy_begin/dontcopy_end
+	 * are not copied in sock_copy()
+	 */
+	int			skc_dontcopy_begin[0];
+	union {
+		struct hlist_node	skc_node;
+		struct hlist_nulls_node skc_nulls_node;
+	};
+	int			skc_tx_queue_mapping;
+	atomic_t		skc_refcnt;
+	int                     skc_dontcopy_end[0];
 };
 
 /**
@@ -232,7 +242,8 @@ struct sock {
 #define sk_refcnt		__sk_common.skc_refcnt
 #define sk_tx_queue_mapping	__sk_common.skc_tx_queue_mapping
 
-#define sk_copy_start		__sk_common.skc_hash
+#define sk_dontcopy_begin	__sk_common.skc_dontcopy_begin
+#define sk_dontcopy_end		__sk_common.skc_dontcopy_end
 #define sk_hash			__sk_common.skc_hash
 #define sk_family		__sk_common.skc_family
 #define sk_state		__sk_common.skc_state
diff --git a/net/core/sock.c b/net/core/sock.c
index fb60801..bcdb6ff 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -992,17 +992,18 @@ static inline void sock_lock_init(struct sock *sk)
 /*
  * Copy all fields from osk to nsk but nsk->sk_refcnt must not change yet,
  * even temporarly, because of RCU lookups. sk_node should also be left as is.
+ * We must not copy fields between sk_dontcopy_begin and sk_dontcopy_end
  */
 static void sock_copy(struct sock *nsk, const struct sock *osk)
 {
 #ifdef CONFIG_SECURITY_NETWORK
 	void *sptr = nsk->sk_security;
 #endif
-	BUILD_BUG_ON(offsetof(struct sock, sk_copy_start) !=
-		     sizeof(osk->sk_node) + sizeof(osk->sk_refcnt) +
-		     sizeof(osk->sk_tx_queue_mapping));
-	memcpy(&nsk->sk_copy_start, &osk->sk_copy_start,
-	       osk->sk_prot->obj_size - offsetof(struct sock, sk_copy_start));
+	memcpy(nsk, osk, offsetof(struct sock, sk_dontcopy_begin));
+
+	memcpy(&nsk->sk_dontcopy_end, &osk->sk_dontcopy_end,
+	       osk->sk_prot->obj_size - offsetof(struct sock, sk_dontcopy_end));
+
 #ifdef CONFIG_SECURITY_NETWORK
 	nsk->sk_security = sptr;
 	security_sk_clone(osk, nsk);
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 06f5f8f..25e3181 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -55,7 +55,6 @@ EXPORT_SYMBOL(inet_get_local_port_range);
 int inet_csk_bind_conflict(const struct sock *sk,
 			   const struct inet_bind_bucket *tb)
 {
-	const __be32 sk_rcv_saddr = inet_rcv_saddr(sk);
 	struct sock *sk2;
 	struct hlist_node *node;
 	int reuse = sk->sk_reuse;
@@ -75,9 +74,9 @@ int inet_csk_bind_conflict(const struct sock *sk,
 		     sk->sk_bound_dev_if == sk2->sk_bound_dev_if)) {
 			if (!reuse || !sk2->sk_reuse ||
 			    sk2->sk_state == TCP_LISTEN) {
-				const __be32 sk2_rcv_saddr = inet_rcv_saddr(sk2);
-				if (!sk2_rcv_saddr || !sk_rcv_saddr ||
-				    sk2_rcv_saddr == sk_rcv_saddr)
+				const __be32 sk2_rcv_saddr = sk_rcv_saddr(sk2);
+				if (!sk2_rcv_saddr || !sk_rcv_saddr(sk) ||
+				    sk2_rcv_saddr == sk_rcv_saddr(sk))
 					break;
 			}
 		}
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index b541a4e..7aad127 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -54,8 +54,8 @@ int ipv6_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2)
 {
 	const struct in6_addr *sk_rcv_saddr6 = &inet6_sk(sk)->rcv_saddr;
 	const struct in6_addr *sk2_rcv_saddr6 = inet6_rcv_saddr(sk2);
-	__be32 sk1_rcv_saddr = inet_sk(sk)->inet_rcv_saddr;
-	__be32 sk2_rcv_saddr = inet_rcv_saddr(sk2);
+	__be32 sk1_rcv_saddr = sk_rcv_saddr(sk);
+	__be32 sk2_rcv_saddr = sk_rcv_saddr(sk2);
 	int sk_ipv6only = ipv6_only_sock(sk);
 	int sk2_ipv6only = inet_v6_ipv6only(sk2);
 	int addr_type = ipv6_addr_type(sk_rcv_saddr6);


