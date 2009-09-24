From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] inet_peer: Optimize inet_getid()
Date: Thu, 24 Sep 2009 21:04:56 +0200
Message-ID: <4ABBC2D8.2040901@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:53168 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752946AbZIXTEy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2009 15:04:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While investigating for network latencies, I found inet_getid() was a contention point
for some workloads.

Fix is straightforward, using cmpxchg() instead of
a spin_lock_bh()/spin_unlock_bh() pair on a central lock.

Another possibility was to use an atomic_t and atomic_add_return() but
the size of struct inet_peer object would had doubled on x86_64 because of
SLAB_HWCACHE_ALIGN constraint.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/inetpeer.h |   16 ++++++++--------
 net/ipv4/inetpeer.c    |    3 ---
 2 files changed, 8 insertions(+), 11 deletions(-)

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index 15e1f8f..952f0ad 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -37,17 +37,17 @@ struct inet_peer	*inet_getpeer(__be32 daddr, int create);
 /* can be called from BH context or outside */
 extern void inet_putpeer(struct inet_peer *p);
 
-extern spinlock_t inet_peer_idlock;
 /* can be called with or without local BH being disabled */
 static inline __u16	inet_getid(struct inet_peer *p, int more)
 {
-	__u16 id;
-
-	spin_lock_bh(&inet_peer_idlock);
-	id = p->ip_id_count;
-	p->ip_id_count += 1 + more;
-	spin_unlock_bh(&inet_peer_idlock);
-	return id;
+	__u16 old;
+
+	while (1) {
+		old = p->ip_id_count;
+		if (cmpxchg(&p->ip_id_count, old, old + 1 + more) == old)
+			break;
+	}
+	return old;
 }
 
 #endif /* _NET_INETPEER_H */
diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index b1fbe18..5dc29b8 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -67,9 +67,6 @@
  *		ip_id_count: idlock
  */
 
-/* Exported for inet_getid inline function.  */
-DEFINE_SPINLOCK(inet_peer_idlock);
-
 static struct kmem_cache *peer_cachep __read_mostly;
 
 #define node_height(x) x->avl_height
