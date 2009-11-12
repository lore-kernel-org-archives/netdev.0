From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] inetpeer: Optimize inet_getid()
Date: Thu, 12 Nov 2009 20:33:09 +0100
Message-ID: <4AFC62F5.60700@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:55641 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751117AbZKLTdI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 14:33:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While investigating for network latencies, I found inet_getid() was a
contention point for some workloads, as inet_peer_idlock is shared
by all inet_getid() users regardless of peers.

One way to fix this is to make ip_id_count an atomic_t instead
of __u16, and use atomic_add_return().

In order to keep sizeof(struct inet_peer) = 64 on 64bit arches
tcp_ts_stamp is also converted to __u32 instead of "unsigned long".

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/inetpeer.h |   16 +++++-----------
 net/ipv4/inetpeer.c    |    5 +----
 net/ipv4/route.c       |    2 +-
 net/ipv4/tcp_ipv4.c    |   16 ++++++++--------
 4 files changed, 15 insertions(+), 24 deletions(-)

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index 35ad7b9..87b1df0 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -17,15 +17,15 @@ struct inet_peer {
 	/* group together avl_left,avl_right,v4daddr to speedup lookups */
 	struct inet_peer	*avl_left, *avl_right;
 	__be32			v4daddr;	/* peer's address */
-	__u16			avl_height;
-	__u16			ip_id_count;	/* IP ID for the next packet */
+	__u32			avl_height;
 	struct list_head	unused;
 	__u32			dtime;		/* the time of last use of not
 						 * referenced entries */
 	atomic_t		refcnt;
 	atomic_t		rid;		/* Frag reception counter */
+	atomic_t		ip_id_count;	/* IP ID for the next packet */
 	__u32			tcp_ts;
-	unsigned long		tcp_ts_stamp;
+	__u32			tcp_ts_stamp;
 };
 
 void			inet_initpeers(void) __init;
@@ -36,17 +36,11 @@ struct inet_peer	*inet_getpeer(__be32 daddr, int create);
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
+	more++;
+	return atomic_add_return(more, &p->ip_id_count) - more;
 }
 
 #endif /* _NET_INETPEER_H */
diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index b1fbe18..6bcfe52 100644
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
@@ -390,7 +387,7 @@ struct inet_peer *inet_getpeer(__be32 daddr, int create)
 	n->v4daddr = daddr;
 	atomic_set(&n->refcnt, 1);
 	atomic_set(&n->rid, 0);
-	n->ip_id_count = secure_ip_id(daddr);
+	atomic_set(&n->ip_id_count, secure_ip_id(daddr));
 	n->tcp_ts_stamp = 0;
 
 	write_lock_bh(&peer_pool_lock);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index ff258b5..4284cee 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2852,7 +2852,7 @@ static int rt_fill_info(struct net *net,
 	error = rt->u.dst.error;
 	expires = rt->u.dst.expires ? rt->u.dst.expires - jiffies : 0;
 	if (rt->peer) {
-		id = rt->peer->ip_id_count;
+		id = atomic_read(&rt->peer->ip_id_count) & 0xffff;
 		if (rt->peer->tcp_ts_stamp) {
 			ts = rt->peer->tcp_ts;
 			tsage = get_seconds() - rt->peer->tcp_ts_stamp;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 657ae33..b7b8c74 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -204,7 +204,7 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 		 * when trying new connection.
 		 */
 		if (peer != NULL &&
-		    peer->tcp_ts_stamp + TCP_PAWS_MSL >= get_seconds()) {
+		    (u32)get_seconds() - peer->tcp_ts_stamp <= TCP_PAWS_MSL) {
 			tp->rx_opt.ts_recent_stamp = peer->tcp_ts_stamp;
 			tp->rx_opt.ts_recent = peer->tcp_ts;
 		}
@@ -1308,7 +1308,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 		    tcp_death_row.sysctl_tw_recycle &&
 		    (peer = rt_get_peer((struct rtable *)dst)) != NULL &&
 		    peer->v4daddr == saddr) {
-			if (get_seconds() < peer->tcp_ts_stamp + TCP_PAWS_MSL &&
+			if ((u32)get_seconds() - peer->tcp_ts_stamp < TCP_PAWS_MSL &&
 			    (s32)(peer->tcp_ts - req->ts_recent) >
 							TCP_PAWS_WINDOW) {
 				NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_PAWSPASSIVEREJECTED);
@@ -1727,9 +1727,9 @@ int tcp_v4_remember_stamp(struct sock *sk)
 
 	if (peer) {
 		if ((s32)(peer->tcp_ts - tp->rx_opt.ts_recent) <= 0 ||
-		    (peer->tcp_ts_stamp + TCP_PAWS_MSL < get_seconds() &&
-		     peer->tcp_ts_stamp <= tp->rx_opt.ts_recent_stamp)) {
-			peer->tcp_ts_stamp = tp->rx_opt.ts_recent_stamp;
+		    ((u32)get_seconds() - peer->tcp_ts_stamp > TCP_PAWS_MSL &&
+		     peer->tcp_ts_stamp <= (u32)tp->rx_opt.ts_recent_stamp)) {
+			peer->tcp_ts_stamp = (u32)tp->rx_opt.ts_recent_stamp;
 			peer->tcp_ts = tp->rx_opt.ts_recent;
 		}
 		if (release_it)
@@ -1748,9 +1748,9 @@ int tcp_v4_tw_remember_stamp(struct inet_timewait_sock *tw)
 		const struct tcp_timewait_sock *tcptw = tcp_twsk((struct sock *)tw);
 
 		if ((s32)(peer->tcp_ts - tcptw->tw_ts_recent) <= 0 ||
-		    (peer->tcp_ts_stamp + TCP_PAWS_MSL < get_seconds() &&
-		     peer->tcp_ts_stamp <= tcptw->tw_ts_recent_stamp)) {
-			peer->tcp_ts_stamp = tcptw->tw_ts_recent_stamp;
+		    ((u32)get_seconds() - peer->tcp_ts_stamp > TCP_PAWS_MSL &&
+		     peer->tcp_ts_stamp <= (u32)tcptw->tw_ts_recent_stamp)) {
+			peer->tcp_ts_stamp = (u32)tcptw->tw_ts_recent_stamp;
 			peer->tcp_ts	   = tcptw->tw_ts_recent;
 		}
 		inet_putpeer(peer);
