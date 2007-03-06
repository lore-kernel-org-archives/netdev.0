From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] NET : Optimizes inet_getpeer()
Date: Tue, 6 Mar 2007 11:33:20 +0100
Message-ID: <200703061133.20389.dada1@cosmosbay.com>
References: <45ED14E6.7090109@cosmosbay.com> <45ED1F35.4070600@cosmosbay.com> <20070306.010523.15263796.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_wNU7Fspbgjj9gfC"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:36622 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934019AbXCFKdY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 05:33:24 -0500
In-Reply-To: <20070306.010523.15263796.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_wNU7Fspbgjj9gfC
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi David

Please find this patch against net-2.6.22

Thank you

[PATCH] NET : Optimizes inet_getpeer()

1) Some sysctl vars are declared __read_mostly

2) We can avoid updating stack[] when doing an AVL lookup only.

    lookup() macro is extended to receive a second parameter, that may be NULL 
in case of a pure lookup (no need to save the AVL path). This removes 
unnecessary instructions, because compiler knows if this _stack parameter is 
NULL or not.

    text size of net/ipv4/inetpeer.o is 2063 bytes instead of 2107 on x86_64

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

--Boundary-00=_wNU7Fspbgjj9gfC
Content-Type: text/plain;
  charset="iso-8859-1";
  name="inetpeer.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="inetpeer.patch"

diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index db3ef96..2f44e61 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -87,10 +87,12 @@ #define PEER_MAXDEPTH 40 /* sufficient f
 
 static int peer_total;
 /* Exported for sysctl_net_ipv4.  */
-int inet_peer_threshold = 65536 + 128;	/* start to throw entries more
+int inet_peer_threshold __read_mostly = 65536 + 128;	/* start to throw entries more
 					 * aggressively at this stage */
-int inet_peer_minttl = 120 * HZ;	/* TTL under high load: 120 sec */
-int inet_peer_maxttl = 10 * 60 * HZ;	/* usual time to live: 10 min */
+int inet_peer_minttl __read_mostly = 120 * HZ;	/* TTL under high load: 120 sec */
+int inet_peer_maxttl __read_mostly = 10 * 60 * HZ;	/* usual time to live: 10 min */
+int inet_peer_gc_mintime __read_mostly = 10 * HZ;
+int inet_peer_gc_maxtime __read_mostly = 120 * HZ;
 
 static struct inet_peer *inet_peer_unused_head;
 static struct inet_peer **inet_peer_unused_tailp = &inet_peer_unused_head;
@@ -99,9 +101,6 @@ static DEFINE_SPINLOCK(inet_peer_unused_
 static void peer_check_expire(unsigned long dummy);
 static DEFINE_TIMER(peer_periodic_timer, peer_check_expire, 0, 0);
 
-/* Exported for sysctl_net_ipv4.  */
-int inet_peer_gc_mintime = 10 * HZ,
-    inet_peer_gc_maxtime = 120 * HZ;
 
 /* Called from ip_output.c:ip_init  */
 void __init inet_initpeers(void)
@@ -151,20 +150,27 @@ static void unlink_from_unused(struct in
 	spin_unlock_bh(&inet_peer_unused_lock);
 }
 
-/* Called with local BH disabled and the pool lock held. */
-#define lookup(daddr) 						\
+/*
+ * Called with local BH disabled and the pool lock held.
+ * _stack is known to be NULL or not at compile time,
+ * so compiler will optimize the if (_stack) tests.
+ */
+#define lookup(_daddr,_stack) 					\
 ({								\
 	struct inet_peer *u, **v;				\
-	stackptr = stack;					\
-	*stackptr++ = &peer_root;				\
+	if (_stack) {						\
+		stackptr = _stack;				\
+		*stackptr++ = &peer_root;			\
+	}							\
 	for (u = peer_root; u != peer_avl_empty; ) {		\
-		if (daddr == u->v4daddr)			\
+		if (_daddr == u->v4daddr)			\
 			break;					\
-		if ((__force __u32)daddr < (__force __u32)u->v4daddr)	\
+		if ((__force __u32)_daddr < (__force __u32)u->v4daddr)	\
 			v = &u->avl_left;			\
 		else						\
 			v = &u->avl_right;			\
-		*stackptr++ = v;				\
+		if (_stack)					\
+			*stackptr++ = v;			\
 		u = *v;						\
 	}							\
 	u;							\
@@ -288,7 +294,7 @@ static void unlink_from_pool(struct inet
 	if (atomic_read(&p->refcnt) == 1) {
 		struct inet_peer **stack[PEER_MAXDEPTH];
 		struct inet_peer ***stackptr, ***delp;
-		if (lookup(p->v4daddr) != p)
+		if (lookup(p->v4daddr, stack) != p)
 			BUG();
 		delp = stackptr - 1; /* *delp[0] == p */
 		if (p->avl_left == peer_avl_empty) {
@@ -373,7 +379,7 @@ struct inet_peer *inet_getpeer(__be32 da
 
 	/* Look up for the address quickly. */
 	read_lock_bh(&peer_pool_lock);
-	p = lookup(daddr);
+	p = lookup(daddr, NULL);
 	if (p != peer_avl_empty)
 		atomic_inc(&p->refcnt);
 	read_unlock_bh(&peer_pool_lock);
@@ -400,7 +406,7 @@ struct inet_peer *inet_getpeer(__be32 da
 
 	write_lock_bh(&peer_pool_lock);
 	/* Check if an entry has suddenly appeared. */
-	p = lookup(daddr);
+	p = lookup(daddr, stack);
 	if (p != peer_avl_empty)
 		goto out_free;
 

--Boundary-00=_wNU7Fspbgjj9gfC--
