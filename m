From: David Miller <davem@davemloft.net>
Subject: [PATCH net-next] tcp: Cache inetpeer in timewait socket, and only
 when necessary.
Date: Sat, 09 Jun 2012 15:01:03 -0700 (PDT)
Message-ID: <20120609.150103.1286755619805480037.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59935 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751591Ab2FIWBF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jun 2012 18:01:05 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 39C35583F5E
	for <netdev@vger.kernel.org>; Sat,  9 Jun 2012 15:01:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Since it's guarenteed that we will access the inetpeer if we're trying
to do timewait recycling and TCP options were enabled on the
connection, just cache the peer in the timewait socket.

In the future, inetpeer lookups will be context dependent (per routing
realm), and this helps facilitate that as well.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/tcp.h         |    3 ++-
 include/net/tcp.h           |    1 -
 include/net/timewait_sock.h |    8 --------
 net/ipv4/tcp_ipv4.c         |   10 ----------
 net/ipv4/tcp_minisocks.c    |   27 ++++++++++++++++++++-------
 net/ipv6/tcp_ipv6.c         |   13 -------------
 6 files changed, 22 insertions(+), 40 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 4c5b632..23e8234 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -506,8 +506,9 @@ struct tcp_timewait_sock {
 	u32			  tw_rcv_wnd;
 	u32			  tw_ts_recent;
 	long			  tw_ts_recent_stamp;
+	struct inet_peer	  *tw_peer;
 #ifdef CONFIG_TCP_MD5SIG
-	struct tcp_md5sig_key	*tw_md5_key;
+	struct tcp_md5sig_key	  *tw_md5_key;
 #endif
 	/* Few sockets in timewait have cookies; in that case, then this
 	 * object holds a reference to them (tw_cookie_values->kref).
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 4245918..9332f34 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -328,7 +328,6 @@ extern void tcp_shutdown (struct sock *sk, int how);
 extern int tcp_v4_rcv(struct sk_buff *skb);
 
 extern struct inet_peer *tcp_v4_get_peer(struct sock *sk);
-extern void *tcp_v4_tw_get_peer(struct sock *sk);
 extern int tcp_v4_tw_remember_stamp(struct inet_timewait_sock *tw);
 extern int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		       size_t size);
diff --git a/include/net/timewait_sock.h b/include/net/timewait_sock.h
index 8d6689c..68f0eca 100644
--- a/include/net/timewait_sock.h
+++ b/include/net/timewait_sock.h
@@ -22,7 +22,6 @@ struct timewait_sock_ops {
 	int		(*twsk_unique)(struct sock *sk,
 				       struct sock *sktw, void *twp);
 	void		(*twsk_destructor)(struct sock *sk);
-	void		*(*twsk_getpeer)(struct sock *sk);
 };
 
 static inline int twsk_unique(struct sock *sk, struct sock *sktw, void *twp)
@@ -41,11 +40,4 @@ static inline void twsk_destructor(struct sock *sk)
 		sk->sk_prot->twsk_prot->twsk_destructor(sk);
 }
 
-static inline void *twsk_getpeer(struct sock *sk)
-{
-	if (sk->sk_prot->twsk_prot->twsk_getpeer)
-		return sk->sk_prot->twsk_prot->twsk_getpeer(sk);
-	return NULL;
-}
-
 #endif /* _TIMEWAIT_SOCK_H */
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 77f049d..fda2ca1 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1835,20 +1835,10 @@ struct inet_peer *tcp_v4_get_peer(struct sock *sk)
 }
 EXPORT_SYMBOL(tcp_v4_get_peer);
 
-void *tcp_v4_tw_get_peer(struct sock *sk)
-{
-	const struct inet_timewait_sock *tw = inet_twsk(sk);
-	struct net *net = sock_net(sk);
-
-	return inet_getpeer_v4(net, tw->tw_daddr, 1);
-}
-EXPORT_SYMBOL(tcp_v4_tw_get_peer);
-
 static struct timewait_sock_ops tcp_timewait_sock_ops = {
 	.twsk_obj_size	= sizeof(struct tcp_timewait_sock),
 	.twsk_unique	= tcp_twsk_unique,
 	.twsk_destructor= tcp_twsk_destructor,
-	.twsk_getpeer	= tcp_v4_tw_get_peer,
 };
 
 const struct inet_connection_sock_af_ops ipv4_specific = {
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index fef9dbf..cb01531 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -77,20 +77,19 @@ static bool tcp_remember_stamp(struct sock *sk)
 
 static bool tcp_tw_remember_stamp(struct inet_timewait_sock *tw)
 {
+	const struct tcp_timewait_sock *tcptw;
 	struct sock *sk = (struct sock *) tw;
 	struct inet_peer *peer;
 
-	peer = twsk_getpeer(sk);
+	tcptw = tcp_twsk(sk);
+	peer = tcptw->tw_peer;
 	if (peer) {
-		const struct tcp_timewait_sock *tcptw = tcp_twsk(sk);
-
 		if ((s32)(peer->tcp_ts - tcptw->tw_ts_recent) <= 0 ||
 		    ((u32)get_seconds() - peer->tcp_ts_stamp > TCP_PAWS_MSL &&
 		     peer->tcp_ts_stamp <= (u32)tcptw->tw_ts_recent_stamp)) {
 			peer->tcp_ts_stamp = (u32)tcptw->tw_ts_recent_stamp;
 			peer->tcp_ts	   = tcptw->tw_ts_recent;
 		}
-		inet_putpeer(peer);
 		return true;
 	}
 	return false;
@@ -314,9 +313,12 @@ void tcp_time_wait(struct sock *sk, int state, int timeo)
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	const struct tcp_sock *tp = tcp_sk(sk);
 	bool recycle_ok = false;
+	bool recycle_on = false;
 
-	if (tcp_death_row.sysctl_tw_recycle && tp->rx_opt.ts_recent_stamp)
+	if (tcp_death_row.sysctl_tw_recycle && tp->rx_opt.ts_recent_stamp) {
 		recycle_ok = tcp_remember_stamp(sk);
+		recycle_on = true;
+	}
 
 	if (tcp_death_row.tw_count < tcp_death_row.sysctl_max_tw_buckets)
 		tw = inet_twsk_alloc(sk, state);
@@ -324,8 +326,10 @@ void tcp_time_wait(struct sock *sk, int state, int timeo)
 	if (tw != NULL) {
 		struct tcp_timewait_sock *tcptw = tcp_twsk((struct sock *)tw);
 		const int rto = (icsk->icsk_rto << 2) - (icsk->icsk_rto >> 1);
+		struct inet_sock *inet = inet_sk(sk);
+		struct inet_peer *peer = NULL;
 
-		tw->tw_transparent	= inet_sk(sk)->transparent;
+		tw->tw_transparent	= inet->transparent;
 		tw->tw_rcv_wscale	= tp->rx_opt.rcv_wscale;
 		tcptw->tw_rcv_nxt	= tp->rcv_nxt;
 		tcptw->tw_snd_nxt	= tp->snd_nxt;
@@ -347,6 +351,12 @@ void tcp_time_wait(struct sock *sk, int state, int timeo)
 		}
 #endif
 
+		if (recycle_on)
+			peer = icsk->icsk_af_ops->get_peer(sk);
+		tcptw->tw_peer = peer;
+		if (peer)
+			atomic_inc(&peer->refcnt);
+
 #ifdef CONFIG_TCP_MD5SIG
 		/*
 		 * The timewait bucket does not have the key DB from the
@@ -398,8 +408,11 @@ void tcp_time_wait(struct sock *sk, int state, int timeo)
 
 void tcp_twsk_destructor(struct sock *sk)
 {
-#ifdef CONFIG_TCP_MD5SIG
 	struct tcp_timewait_sock *twsk = tcp_twsk(sk);
+
+	if (twsk->tw_peer)
+		inet_putpeer(twsk->tw_peer);
+#ifdef CONFIG_TCP_MD5SIG
 	if (twsk->tw_md5_key) {
 		tcp_free_md5sig_pool();
 		kfree_rcu(twsk->tw_md5_key, rcu);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index b5ecf37..f91b0bf 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1746,23 +1746,10 @@ static struct inet_peer *tcp_v6_get_peer(struct sock *sk)
 	return rt6_get_peer_create(rt);
 }
 
-static void *tcp_v6_tw_get_peer(struct sock *sk)
-{
-	const struct inet6_timewait_sock *tw6 = inet6_twsk(sk);
-	const struct inet_timewait_sock *tw = inet_twsk(sk);
-	struct net *net = sock_net(sk);
-
-	if (tw->tw_family == AF_INET)
-		return tcp_v4_tw_get_peer(sk);
-
-	return inet_getpeer_v6(net, &tw6->tw_v6_daddr, 1);
-}
-
 static struct timewait_sock_ops tcp6_timewait_sock_ops = {
 	.twsk_obj_size	= sizeof(struct tcp6_timewait_sock),
 	.twsk_unique	= tcp_twsk_unique,
 	.twsk_destructor= tcp_twsk_destructor,
-	.twsk_getpeer	= tcp_v6_tw_get_peer,
 };
 
 static const struct inet_connection_sock_af_ops ipv6_specific = {
-- 
1.7.10
