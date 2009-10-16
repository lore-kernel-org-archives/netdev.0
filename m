From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 1/4 v2] net: Introduce sk_tx_queue_mapping
Date: Fri, 16 Oct 2009 12:51:20 +0530
Message-ID: <20091016072120.24384.54449.sendpatchset@localhost.localdomain>
References: <20091016072107.24384.17358.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	Krishna Kumar <krkumar2@in.ibm.com>, dada1@cosmosbay.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp04.in.ibm.com ([59.145.155.4]:54341 "EHLO
	e28smtp04.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756116AbZJPHWM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2009 03:22:12 -0400
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp04.in.ibm.com (8.14.3/8.13.1) with ESMTP id n9G7LNag003923
	for <netdev@vger.kernel.org>; Fri, 16 Oct 2009 12:51:23 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9G7LNHJ2584822
	for <netdev@vger.kernel.org>; Fri, 16 Oct 2009 12:51:23 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n9G7LM44001193
	for <netdev@vger.kernel.org>; Fri, 16 Oct 2009 18:21:23 +1100
In-Reply-To: <20091016072107.24384.17358.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>

Introduce sk_tx_queue_mapping; and functions that set, test and get
this value. Reset sk_tx_queue_mapping to -1 whenever the dst cache
is set/reset, and in socket alloc & free (free probably doesn't need
it).

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 include/net/sock.h |   21 +++++++++++++++++++++
 net/core/sock.c    |    7 ++++++-
 2 files changed, 27 insertions(+), 1 deletion(-)

diff -ruNp org/include/net/sock.h new/include/net/sock.h
--- org/include/net/sock.h	2009-10-14 10:36:52.000000000 +0530
+++ new/include/net/sock.h	2009-10-16 12:09:54.000000000 +0530
@@ -107,6 +107,7 @@ struct net;
  *	@skc_node: main hash linkage for various protocol lookup tables
  *	@skc_nulls_node: main hash linkage for UDP/UDP-Lite protocol
  *	@skc_refcnt: reference count
+ *	@skc_tx_queue_mapping: tx queue number for this connection
  *	@skc_hash: hash value used with various protocol lookup tables
  *	@skc_family: network address family
  *	@skc_state: Connection state
@@ -128,6 +129,7 @@ struct sock_common {
 		struct hlist_nulls_node skc_nulls_node;
 	};
 	atomic_t		skc_refcnt;
+	int			skc_tx_queue_mapping;
 
 	unsigned int		skc_hash;
 	unsigned short		skc_family;
@@ -215,6 +217,7 @@ struct sock {
 #define sk_node			__sk_common.skc_node
 #define sk_nulls_node		__sk_common.skc_nulls_node
 #define sk_refcnt		__sk_common.skc_refcnt
+#define sk_tx_queue_mapping	__sk_common.skc_tx_queue_mapping
 
 #define sk_copy_start		__sk_common.skc_hash
 #define sk_hash			__sk_common.skc_hash
@@ -1094,8 +1097,24 @@ static inline void sock_put(struct sock 
 extern int sk_receive_skb(struct sock *sk, struct sk_buff *skb,
 			  const int nested);
 
+static inline void sk_record_tx_queue(struct sock *sk, int tx_queue)
+{
+	sk->sk_tx_queue_mapping = tx_queue;
+}
+
+static inline int sk_get_tx_queue(const struct sock *sk)
+{
+	return sk->sk_tx_queue_mapping;
+}
+
+static inline bool sk_tx_queue_recorded(const struct sock *sk)
+{
+	return (sk && sk->sk_tx_queue_mapping >= 0);
+}
+
 static inline void sk_set_socket(struct sock *sk, struct socket *sock)
 {
+	sk_record_tx_queue(sk, -1);
 	sk->sk_socket = sock;
 }
 
@@ -1152,6 +1171,7 @@ __sk_dst_set(struct sock *sk, struct dst
 {
 	struct dst_entry *old_dst;
 
+	sk_record_tx_queue(sk, -1);
 	old_dst = sk->sk_dst_cache;
 	sk->sk_dst_cache = dst;
 	dst_release(old_dst);
@@ -1170,6 +1190,7 @@ __sk_dst_reset(struct sock *sk)
 {
 	struct dst_entry *old_dst;
 
+	sk_record_tx_queue(sk, -1);
 	old_dst = sk->sk_dst_cache;
 	sk->sk_dst_cache = NULL;
 	dst_release(old_dst);
diff -ruNp org/net/core/sock.c new/net/core/sock.c
--- org/net/core/sock.c	2009-10-16 11:53:40.000000000 +0530
+++ new/net/core/sock.c	2009-10-16 12:07:00.000000000 +0530
@@ -357,6 +357,7 @@ struct dst_entry *__sk_dst_check(struct 
 	struct dst_entry *dst = sk->sk_dst_cache;
 
 	if (dst && dst->obsolete && dst->ops->check(dst, cookie) == NULL) {
+		sk_record_tx_queue(sk, -1);
 		sk->sk_dst_cache = NULL;
 		dst_release(dst);
 		return NULL;
@@ -953,7 +954,8 @@ static void sock_copy(struct sock *nsk, 
 	void *sptr = nsk->sk_security;
 #endif
 	BUILD_BUG_ON(offsetof(struct sock, sk_copy_start) !=
-		     sizeof(osk->sk_node) + sizeof(osk->sk_refcnt));
+		     sizeof(osk->sk_node) + sizeof(osk->sk_refcnt) +
+		     sizeof(osk->sk_tx_queue_mapping));
 	memcpy(&nsk->sk_copy_start, &osk->sk_copy_start,
 	       osk->sk_prot->obj_size - offsetof(struct sock, sk_copy_start));
 #ifdef CONFIG_SECURITY_NETWORK
@@ -997,6 +999,7 @@ static struct sock *sk_prot_alloc(struct
 
 		if (!try_module_get(prot->owner))
 			goto out_free_sec;
+		sk_record_tx_queue(sk, -1);
 	}
 
 	return sk;
@@ -1016,6 +1019,8 @@ static void sk_prot_free(struct proto *p
 	struct kmem_cache *slab;
 	struct module *owner;
 
+	sk_record_tx_queue(sk, -1);
+
 	owner = prot->owner;
 	slab = prot->slab;
 
