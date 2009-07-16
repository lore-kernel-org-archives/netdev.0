From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: sock_copy() fixes
Date: Thu, 16 Jul 2009 11:13:10 +0200
Message-ID: <4A5EEF26.5040209@gmail.com>
References: <20090707.191424.167842005.davem@davemloft.net>	<4A5441A0.3050504@gmail.com>	<4A5581C5.5070409@gmail.com> <20090711.202727.18146102.davem@davemloft.net> <4A598BAB.6030400@gmail.com> <4A5DCB7C.9000502@gmail.com> <4A5DF5B4.5090809@trash.net> <4A5E33D9.2030602@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	paulmck@linux.vnet.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:45770 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754340AbZGPJN1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 05:13:27 -0400
In-Reply-To: <4A5E33D9.2030602@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David, I believe following patch could be 2.6.31 candidate
(and stable (2.6.29/2.6.30) as well)

Note : Because we clear all sock fields in sk_prot_alloc(),
setting sk_refcnt to 1 in sock_init_data() is safe, even if
sock not yet added to hash table (with correct keys).
Lockless readers have to re-check their key after getting a
reference on the found object anyway, their re-check
should not catch old key values.

Next problem to fix (but it can wait 2.6.32 I believe) is
to delay sk_refcnt initialization *after* sock lookup keys
are setup for new socket, not after being set to 0.

A lockless reader could :
- find an old sock, with old keys
      (at this point, another cpu re-allocate this sock, clear fields,
       and sets sk_refcnt to 1)
- succeed to increment sk_refcnt
      (at this point, other cpu is filling lookup fields (remote address/port, local address...)
- re-check keys and find a match, while socket still being initialized by other cpu.

Only way to fix this is to set sk_refcnt to a non null value only at the
point it is safe for a reader to find the socket and use it.

Thanks

[PATCH] net: sock_copy() fixes

Commit e912b1142be8f1e2c71c71001dc992c6e5eb2ec1
(net: sk_prot_alloc() should not blindly overwrite memory)
took care of not zeroing whole new socket at allocation time.

sock_copy() is another spot where we should be very careful.
We should not set refcnt to a non null value, until
we are sure other fields are correctly setup, or
a lockless reader could catch this socket by mistake,
while not fully (re)initialized.

This patch puts sk_node & sk_refcnt to the very beginning
of struct sock to ease sock_copy() & sk_prot_alloc() job.

We add appropriate smp_wmb() before sk_refcnt initializations
to match our RCU requirements (changes to sock keys should
be committed to memory before sk_refcnt setting)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/sock.h |   32 +++++++++++++++++++-------------
 net/core/sock.c    |   20 ++++++++++++++++++--
 2 files changed, 37 insertions(+), 15 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 2c0da92..ae0906e 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -104,15 +104,15 @@ struct net;
 
 /**
  *	struct sock_common - minimal network layer representation of sockets
+ *	@skc_node: main hash linkage for various protocol lookup tables
+ *	@skc_nulls_node: main hash linkage for UDP/UDP-Lite protocol
+ *	@skc_refcnt: reference count
+ *	@skc_hash: hash value used with various protocol lookup tables
  *	@skc_family: network address family
  *	@skc_state: Connection state
  *	@skc_reuse: %SO_REUSEADDR setting
  *	@skc_bound_dev_if: bound device index if != 0
- *	@skc_node: main hash linkage for various protocol lookup tables
- *	@skc_nulls_node: main hash linkage for UDP/UDP-Lite protocol
  *	@skc_bind_node: bind hash linkage for various protocol lookup tables
- *	@skc_refcnt: reference count
- *	@skc_hash: hash value used with various protocol lookup tables
  *	@skc_prot: protocol handlers inside a network family
  *	@skc_net: reference to the network namespace of this socket
  *
@@ -120,17 +120,21 @@ struct net;
  *	for struct sock and struct inet_timewait_sock.
  */
 struct sock_common {
-	unsigned short		skc_family;
-	volatile unsigned char	skc_state;
-	unsigned char		skc_reuse;
-	int			skc_bound_dev_if;
+	/*
+	 * first fields are not copied in sock_copy()
+	 */
 	union {
 		struct hlist_node	skc_node;
 		struct hlist_nulls_node skc_nulls_node;
 	};
-	struct hlist_node	skc_bind_node;
 	atomic_t		skc_refcnt;
+
 	unsigned int		skc_hash;
+	unsigned short		skc_family;
+	volatile unsigned char	skc_state;
+	unsigned char		skc_reuse;
+	int			skc_bound_dev_if;
+	struct hlist_node	skc_bind_node;
 	struct proto		*skc_prot;
 #ifdef CONFIG_NET_NS
 	struct net	 	*skc_net;
@@ -208,15 +212,17 @@ struct sock {
 	 * don't add nothing before this first member (__sk_common) --acme
 	 */
 	struct sock_common	__sk_common;
+#define sk_node			__sk_common.skc_node
+#define sk_nulls_node		__sk_common.skc_nulls_node
+#define sk_refcnt		__sk_common.skc_refcnt
+
+#define sk_copy_start		__sk_common.skc_hash
+#define sk_hash			__sk_common.skc_hash
 #define sk_family		__sk_common.skc_family
 #define sk_state		__sk_common.skc_state
 #define sk_reuse		__sk_common.skc_reuse
 #define sk_bound_dev_if		__sk_common.skc_bound_dev_if
-#define sk_node			__sk_common.skc_node
-#define sk_nulls_node		__sk_common.skc_nulls_node
 #define sk_bind_node		__sk_common.skc_bind_node
-#define sk_refcnt		__sk_common.skc_refcnt
-#define sk_hash			__sk_common.skc_hash
 #define sk_prot			__sk_common.skc_prot
 #define sk_net			__sk_common.skc_net
 	kmemcheck_bitfield_begin(flags);
diff --git a/net/core/sock.c b/net/core/sock.c
index ba5d211..d9eec15 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -919,13 +919,19 @@ static inline void sock_lock_init(struct sock *sk)
 			af_family_keys + sk->sk_family);
 }
 
+/*
+ * Copy all fields from osk to nsk but nsk->sk_refcnt must not change yet,
+ * even temporarly, because of RCU lookups. sk_node should also be left as is.
+ */
 static void sock_copy(struct sock *nsk, const struct sock *osk)
 {
 #ifdef CONFIG_SECURITY_NETWORK
 	void *sptr = nsk->sk_security;
 #endif
-
-	memcpy(nsk, osk, osk->sk_prot->obj_size);
+	BUILD_BUG_ON(offsetof(struct sock, sk_copy_start) !=
+		     sizeof(osk->sk_node) + sizeof(osk->sk_refcnt));
+	memcpy(&nsk->sk_copy_start, &osk->sk_copy_start,
+	       osk->sk_prot->obj_size - offsetof(struct sock, sk_copy_start));
 #ifdef CONFIG_SECURITY_NETWORK
 	nsk->sk_security = sptr;
 	security_sk_clone(osk, nsk);
@@ -1140,6 +1146,11 @@ struct sock *sk_clone(const struct sock *sk, const gfp_t priority)
 
 		newsk->sk_err	   = 0;
 		newsk->sk_priority = 0;
+		/*
+		 * Before updating sk_refcnt, we must commit prior changes to memory
+		 * (Documentation/RCU/rculist_nulls.txt for details)
+		 */
+		smp_wmb();
 		atomic_set(&newsk->sk_refcnt, 2);
 
 		/*
@@ -1855,6 +1866,11 @@ void sock_init_data(struct socket *sock, struct sock *sk)
 
 	sk->sk_stamp = ktime_set(-1L, 0);
 
+	/*
+	 * Before updating sk_refcnt, we must commit prior changes to memory
+	 * (Documentation/RCU/rculist_nulls.txt for details)
+	 */
+	smp_wmb();
 	atomic_set(&sk->sk_refcnt, 1);
 	atomic_set(&sk->sk_wmem_alloc, 1);
 	atomic_set(&sk->sk_drops, 0);
