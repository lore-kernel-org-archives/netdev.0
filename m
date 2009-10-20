From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 1/4 v4] net: Introduce sk_tx_queue_mapping
Date: Tue, 20 Oct 2009 15:16:20 +0530
Message-ID: <20091020094620.10404.32429.sendpatchset@localhost.localdomain>
References: <20091020094607.10404.81794.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	Krishna Kumar <krkumar2@in.ibm.com>, dada1@cosmosbay.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp08.in.ibm.com ([59.145.155.8]:49514 "EHLO
	e28smtp08.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751750AbZJTJqV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 05:46:21 -0400
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp08.in.ibm.com (8.14.3/8.13.1) with ESMTP id n9K9XQLr012951
	for <netdev@vger.kernel.org>; Tue, 20 Oct 2009 15:03:26 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9K9kNY72490504
	for <netdev@vger.kernel.org>; Tue, 20 Oct 2009 15:16:23 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n9K9kMgw024087
	for <netdev@vger.kernel.org>; Tue, 20 Oct 2009 20:46:23 +1100
In-Reply-To: <20091020094607.10404.81794.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>

Introduce sk_tx_queue_mapping; and functions that set, test and
get this value. Reset sk_tx_queue_mapping to -1 whenever the dst
cache is set/reset, and in socket alloc. Setting txq to -1 and
using valid txq=<0 to n-1> allows the tx path to use the value
of sk_tx_queue_mapping directly instead of subtracting 1 on every
tx.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 include/net/sock.h |   26 ++++++++++++++++++++++++++
 net/core/sock.c    |    5 ++++-
 2 files changed, 30 insertions(+), 1 deletion(-)

diff -ruNp org/include/net/sock.h new/include/net/sock.h
--- org/include/net/sock.h	2009-10-16 18:53:40.000000000 +0530
+++ new/include/net/sock.h	2009-10-16 21:38:44.000000000 +0530
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
@@ -1094,8 +1097,29 @@ static inline void sock_put(struct sock 
 extern int sk_receive_skb(struct sock *sk, struct sk_buff *skb,
 			  const int nested);
 
+static inline void sk_tx_queue_set(struct sock *sk, int tx_queue)
+{
+	sk->sk_tx_queue_mapping = tx_queue;
+}
+
+static inline void sk_tx_queue_clear(struct sock *sk)
+{
+	sk->sk_tx_queue_mapping = -1;
+}
+
+static inline int sk_tx_queue_get(const struct sock *sk)
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
+	sk_tx_queue_clear(sk);
 	sk->sk_socket = sock;
 }
 
@@ -1152,6 +1176,7 @@ __sk_dst_set(struct sock *sk, struct dst
 {
 	struct dst_entry *old_dst;
 
+	sk_tx_queue_clear(sk);
 	old_dst = sk->sk_dst_cache;
 	sk->sk_dst_cache = dst;
 	dst_release(old_dst);
@@ -1170,6 +1195,7 @@ __sk_dst_reset(struct sock *sk)
 {
 	struct dst_entry *old_dst;
 
+	sk_tx_queue_clear(sk);
 	old_dst = sk->sk_dst_cache;
 	sk->sk_dst_cache = NULL;
 	dst_release(old_dst);
diff -ruNp org/net/core/sock.c new/net/core/sock.c
--- org/net/core/sock.c	2009-10-16 18:53:40.000000000 +0530
+++ new/net/core/sock.c	2009-10-16 21:29:02.000000000 +0530
@@ -357,6 +357,7 @@ struct dst_entry *__sk_dst_check(struct 
 	struct dst_entry *dst = sk->sk_dst_cache;
 
 	if (dst && dst->obsolete && dst->ops->check(dst, cookie) == NULL) {
+		sk_tx_queue_clear(sk);
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
+		sk_tx_queue_clear(sk);
 	}
 
 	return sk;
