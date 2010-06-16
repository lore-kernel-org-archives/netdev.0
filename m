From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] inetpeer: restore small inet_peer structures
Date: Wed, 16 Jun 2010 16:52:13 +0200
Message-ID: <1276699933.2632.102.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:54151 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752189Ab0FPOwR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 10:52:17 -0400
Received: by wwb18 with SMTP id 18so5746793wwb.19
        for <netdev@vger.kernel.org>; Wed, 16 Jun 2010 07:52:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Addition of rcu_head to struct inet_peer added 16bytes on 64bit arches.

Thats a bit unfortunate, since old size was exactly 64 bytes.

This can be solved, using an union between this rcu_head an four fields,
that are normally used only when a refcount is taken on inet_peer.
rcu_head is used only when refcnt=-1, right before structure freeing.

Add a inet_peer_refcheck() function to check this assertion for a while.

We can bring back SLAB_HWCACHE_ALIGN qualifier in kmem cache creation.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/inetpeer.h |   31 ++++++++++++++++++++++++++-----
 net/ipv4/inetpeer.c    |    4 ++--
 net/ipv4/route.c       |    1 +
 net/ipv4/tcp_ipv4.c    |   11 +++++++----
 4 files changed, 36 insertions(+), 11 deletions(-)

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index 6174047..51c06af 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -22,11 +22,21 @@ struct inet_peer {
 	__u32			dtime;		/* the time of last use of not
 						 * referenced entries */
 	atomic_t		refcnt;
-	atomic_t		rid;		/* Frag reception counter */
-	atomic_t		ip_id_count;	/* IP ID for the next packet */
-	__u32			tcp_ts;
-	__u32			tcp_ts_stamp;
-	struct rcu_head		rcu;
+	/*
+	 * Once inet_peer is queued for deletion (refcnt == -1), following fields
+	 * are not available: rid, ip_id_count, tcp_ts, tcp_ts_stamp
+	 * We can share memory with rcu_head to keep inet_peer small
+	 * (less then 64 bytes)
+	 */
+	union {
+		struct {
+			atomic_t	rid;		/* Frag reception counter */
+			atomic_t	ip_id_count;	/* IP ID for the next packet */
+			__u32		tcp_ts;
+			__u32		tcp_ts_stamp;
+		};
+		struct rcu_head         rcu;
+	};
 };
 
 void			inet_initpeers(void) __init;
@@ -37,10 +47,21 @@ struct inet_peer	*inet_getpeer(__be32 daddr, int create);
 /* can be called from BH context or outside */
 extern void inet_putpeer(struct inet_peer *p);
 
+/*
+ * temporary check to make sure we dont access rid, ip_id_count, tcp_ts,
+ * tcp_ts_stamp if no refcount is taken on inet_peer
+ */
+static inline void inet_peer_refcheck(const struct inet_peer *p)
+{
+	WARN_ON_ONCE(atomic_read(&p->refcnt) <= 0);
+}
+
+
 /* can be called with or without local BH being disabled */
 static inline __u16	inet_getid(struct inet_peer *p, int more)
 {
 	more++;
+	inet_peer_refcheck(p);
 	return atomic_add_return(more, &p->ip_id_count) - more;
 }
 
diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index 349249f..bb58aed 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -64,7 +64,7 @@
  *		   usually under some other lock to prevent node disappearing
  *		dtime: unused node list lock
  *		v4daddr: unchangeable
- *		ip_id_count: idlock
+ *		ip_id_count: atomic value (no lock needed)
  */
 
 static struct kmem_cache *peer_cachep __read_mostly;
@@ -129,7 +129,7 @@ void __init inet_initpeers(void)
 
 	peer_cachep = kmem_cache_create("inet_peer_cache",
 			sizeof(struct inet_peer),
-			0, SLAB_PANIC,
+			0, SLAB_HWCACHE_ALIGN | SLAB_PANIC,
 			NULL);
 
 	/* All the timers, started at system startup tend
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index a291edb..03430de 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2881,6 +2881,7 @@ static int rt_fill_info(struct net *net,
 	error = rt->dst.error;
 	expires = rt->dst.expires ? rt->dst.expires - jiffies : 0;
 	if (rt->peer) {
+		inet_peer_refcheck(rt->peer);
 		id = atomic_read(&rt->peer->ip_id_count) & 0xffff;
 		if (rt->peer->tcp_ts_stamp) {
 			ts = rt->peer->tcp_ts;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 7f9515c..2e41e6f 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -204,10 +204,12 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 		 * TIME-WAIT * and initialize rx_opt.ts_recent from it,
 		 * when trying new connection.
 		 */
-		if (peer != NULL &&
-		    (u32)get_seconds() - peer->tcp_ts_stamp <= TCP_PAWS_MSL) {
-			tp->rx_opt.ts_recent_stamp = peer->tcp_ts_stamp;
-			tp->rx_opt.ts_recent = peer->tcp_ts;
+		if (peer) {
+			inet_peer_refcheck(peer);
+			if ((u32)get_seconds() - peer->tcp_ts_stamp <= TCP_PAWS_MSL) {
+				tp->rx_opt.ts_recent_stamp = peer->tcp_ts_stamp;
+				tp->rx_opt.ts_recent = peer->tcp_ts;
+			}
 		}
 	}
 
@@ -1351,6 +1353,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 		    (dst = inet_csk_route_req(sk, req)) != NULL &&
 		    (peer = rt_get_peer((struct rtable *)dst)) != NULL &&
 		    peer->v4daddr == saddr) {
+			inet_peer_refcheck(peer);
 			if ((u32)get_seconds() - peer->tcp_ts_stamp < TCP_PAWS_MSL &&
 			    (s32)(peer->tcp_ts - req->ts_recent) >
 							TCP_PAWS_WINDOW) {


