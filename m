From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [RFC] [PATCH 1/5] net: Introduce sk_tx_queue_mapping
Date: Thu, 15 Oct 2009 11:26:32 +0530
Message-ID: <20091015055632.30145.52459.sendpatchset@localhost.localdomain>
References: <20091015055602.30145.65852.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	Krishna Kumar <krkumar2@in.ibm.com>, dada1@cosmosbay.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp06.au.ibm.com ([202.81.31.148]:54041 "EHLO
	e23smtp06.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753414AbZJOF5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2009 01:57:40 -0400
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp06.au.ibm.com (8.14.3/8.13.1) with ESMTP id n9F5ukY8017421
	for <netdev@vger.kernel.org>; Thu, 15 Oct 2009 16:56:46 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9F5ur9m1404984
	for <netdev@vger.kernel.org>; Thu, 15 Oct 2009 16:56:53 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n9F5uqI5002447
	for <netdev@vger.kernel.org>; Thu, 15 Oct 2009 16:56:52 +1100
In-Reply-To: <20091015055602.30145.65852.sendpatchset@localhost.localdomain>
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
+++ new/include/net/sock.h	2009-10-14 17:59:44.000000000 +0530
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
+        sk->sk_tx_queue_mapping = tx_queue;
+}
+
+static inline int sk_get_tx_queue(const struct sock *sk)
+{
+        return sk->sk_tx_queue_mapping;
+}
+
+static inline bool sk_tx_queue_recorded(const struct sock *sk)
+{
+        return (sk && sk->sk_tx_queue_mapping >= 0);
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
--- org/net/core/sock.c	2009-10-14 10:36:52.000000000 +0530
+++ new/net/core/sock.c	2009-10-14 17:59:46.000000000 +0530
@@ -358,6 +358,7 @@ struct dst_entry *__sk_dst_check(struct 
 	struct dst_entry *dst = sk->sk_dst_cache;
 
 	if (dst && dst->obsolete && dst->ops->check(dst, cookie) == NULL) {
+		sk_record_tx_queue(sk, -1);
 		sk->sk_dst_cache = NULL;
 		dst_release(dst);
 		return NULL;
@@ -954,7 +955,8 @@ static void sock_copy(struct sock *nsk, 
 	void *sptr = nsk->sk_security;
 #endif
 	BUILD_BUG_ON(offsetof(struct sock, sk_copy_start) !=
-		     sizeof(osk->sk_node) + sizeof(osk->sk_refcnt));
+		     sizeof(osk->sk_node) + sizeof(osk->sk_refcnt) +
+		     sizeof(osk->sk_tx_queue_mapping));
 	memcpy(&nsk->sk_copy_start, &osk->sk_copy_start,
 	       osk->sk_prot->obj_size - offsetof(struct sock, sk_copy_start));
 #ifdef CONFIG_SECURITY_NETWORK
@@ -998,6 +1000,7 @@ static struct sock *sk_prot_alloc(struct
 
 		if (!try_module_get(prot->owner))
 			goto out_free_sec;
+		sk_record_tx_queue(sk, -1);
 	}
 
 	return sk;
@@ -1017,6 +1020,8 @@ static void sk_prot_free(struct proto *p
 	struct kmem_cache *slab;
 	struct module *owner;
 
+	sk_record_tx_queue(sk, -1);
+
 	owner = prot->owner;
 	slab = prot->slab;
 
