From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/7] timewait_sock: Create and use getpeer op.
Date: Thu, 02 Dec 2010 12:42:10 -0800 (PST)
Message-ID: <20101202.124210.112602035.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37740
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757877Ab0LBUln (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 15:41:43 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 9A41E24C088
	for <netdev@vger.kernel.org>; Thu,  2 Dec 2010 12:42:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The only thing AF-specific about remembering the timestamp
for a time-wait TCP socket is getting the peer.

Abstract that behind a new timewait_sock_ops vector.

Support for real IPV6 sockets is not filled in yet, but
curiously this makes timewait recycling start to work
for v4-mapped ipv6 sockets.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/tcp.h           |    1 +
 include/net/timewait_sock.h |    8 ++++++++
 net/ipv4/tcp_ipv4.c         |   33 +++++++++++----------------------
 net/ipv4/tcp_minisocks.c    |   32 ++++++++++++++++++++++++--------
 net/ipv6/tcp_ipv6.c         |   26 +++++++++++++++++++-------
 5 files changed, 63 insertions(+), 37 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 3e23964..4097320 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -313,6 +313,7 @@ extern void tcp_shutdown (struct sock *sk, int how);
 extern int tcp_v4_rcv(struct sk_buff *skb);
 
 extern struct inet_peer *tcp_v4_get_peer(struct sock *sk, bool *release_it);
+extern void *tcp_v4_tw_get_peer(struct sock *sk);
 extern int tcp_v4_tw_remember_stamp(struct inet_timewait_sock *tw);
 extern int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		       size_t size);
diff --git a/include/net/timewait_sock.h b/include/net/timewait_sock.h
index 97c3b14..053b3cf 100644
--- a/include/net/timewait_sock.h
+++ b/include/net/timewait_sock.h
@@ -21,6 +21,7 @@ struct timewait_sock_ops {
 	int		(*twsk_unique)(struct sock *sk,
 				       struct sock *sktw, void *twp);
 	void		(*twsk_destructor)(struct sock *sk);
+	void		*(*twsk_getpeer)(struct sock *sk);
 };
 
 static inline int twsk_unique(struct sock *sk, struct sock *sktw, void *twp)
@@ -39,4 +40,11 @@ static inline void twsk_destructor(struct sock *sk)
 		sk->sk_prot->twsk_prot->twsk_destructor(sk);
 }
 
+static inline void *twsk_getpeer(struct sock *sk)
+{
+	if (sk->sk_prot->twsk_prot->twsk_getpeer)
+		return sk->sk_prot->twsk_prot->twsk_getpeer(sk);
+	return NULL;
+}
+
 #endif /* _TIMEWAIT_SOCK_H */
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 0ddf819..dd55505 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1210,12 +1210,6 @@ static const struct tcp_request_sock_ops tcp_request_sock_ipv4_ops = {
 };
 #endif
 
-static struct timewait_sock_ops tcp_timewait_sock_ops = {
-	.twsk_obj_size	= sizeof(struct tcp_timewait_sock),
-	.twsk_unique	= tcp_twsk_unique,
-	.twsk_destructor= tcp_twsk_destructor,
-};
-
 int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_extend_values tmp_ext;
@@ -1783,25 +1777,20 @@ struct inet_peer *tcp_v4_get_peer(struct sock *sk, bool *release_it)
 }
 EXPORT_SYMBOL(tcp_v4_get_peer);
 
-int tcp_v4_tw_remember_stamp(struct inet_timewait_sock *tw)
+void *tcp_v4_tw_get_peer(struct sock *sk)
 {
-	struct inet_peer *peer = inet_getpeer_v4(tw->tw_daddr, 1);
-
-	if (peer) {
-		const struct tcp_timewait_sock *tcptw = tcp_twsk((struct sock *)tw);
-
-		if ((s32)(peer->tcp_ts - tcptw->tw_ts_recent) <= 0 ||
-		    ((u32)get_seconds() - peer->tcp_ts_stamp > TCP_PAWS_MSL &&
-		     peer->tcp_ts_stamp <= (u32)tcptw->tw_ts_recent_stamp)) {
-			peer->tcp_ts_stamp = (u32)tcptw->tw_ts_recent_stamp;
-			peer->tcp_ts	   = tcptw->tw_ts_recent;
-		}
-		inet_putpeer(peer);
-		return 1;
-	}
+	struct inet_timewait_sock *tw = inet_twsk(sk);
 
-	return 0;
+	return inet_getpeer_v4(tw->tw_daddr, 1);
 }
+EXPORT_SYMBOL(tcp_v4_tw_get_peer);
+
+static struct timewait_sock_ops tcp_timewait_sock_ops = {
+	.twsk_obj_size	= sizeof(struct tcp_timewait_sock),
+	.twsk_unique	= tcp_twsk_unique,
+	.twsk_destructor= tcp_twsk_destructor,
+	.twsk_getpeer	= tcp_v4_tw_get_peer,
+};
 
 const struct inet_connection_sock_af_ops ipv4_specific = {
 	.queue_xmit	   = ip_queue_xmit,
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 059082c..3527b51 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -78,6 +78,27 @@ static int tcp_remember_stamp(struct sock *sk)
 	return 0;
 }
 
+static int tcp_tw_remember_stamp(struct inet_timewait_sock *tw)
+{
+	struct sock *sk = (struct sock *) tw;
+	struct inet_peer *peer;
+
+	peer = twsk_getpeer(sk);
+	if (peer) {
+		const struct tcp_timewait_sock *tcptw = tcp_twsk(sk);
+
+		if ((s32)(peer->tcp_ts - tcptw->tw_ts_recent) <= 0 ||
+		    ((u32)get_seconds() - peer->tcp_ts_stamp > TCP_PAWS_MSL &&
+		     peer->tcp_ts_stamp <= (u32)tcptw->tw_ts_recent_stamp)) {
+			peer->tcp_ts_stamp = (u32)tcptw->tw_ts_recent_stamp;
+			peer->tcp_ts	   = tcptw->tw_ts_recent;
+		}
+		inet_putpeer(peer);
+		return 1;
+	}
+	return 0;
+}
+
 static __inline__ int tcp_in_window(u32 seq, u32 end_seq, u32 s_win, u32 e_win)
 {
 	if (seq == s_win)
@@ -178,14 +199,9 @@ kill_with_rst:
 			tcptw->tw_ts_recent	  = tmp_opt.rcv_tsval;
 		}
 
-		/* I am shamed, but failed to make it more elegant.
-		 * Yes, it is direct reference to IP, which is impossible
-		 * to generalize to IPv6. Taking into account that IPv6
-		 * do not understand recycling in any case, it not
-		 * a big problem in practice. --ANK */
-		if (tw->tw_family == AF_INET &&
-		    tcp_death_row.sysctl_tw_recycle && tcptw->tw_ts_recent_stamp &&
-		    tcp_v4_tw_remember_stamp(tw))
+		if (tcp_death_row.sysctl_tw_recycle &&
+		    tcptw->tw_ts_recent_stamp &&
+		    tcp_tw_remember_stamp(tw))
 			inet_twsk_schedule(tw, &tcp_death_row, tw->tw_timeout,
 					   TCP_TIMEWAIT_LEN);
 		else
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index e394d00..5f73a18 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -906,12 +906,6 @@ static const struct tcp_request_sock_ops tcp_request_sock_ipv6_ops = {
 };
 #endif
 
-static struct timewait_sock_ops tcp6_timewait_sock_ops = {
-	.twsk_obj_size	= sizeof(struct tcp6_timewait_sock),
-	.twsk_unique	= tcp_twsk_unique,
-	.twsk_destructor= tcp_twsk_destructor,
-};
-
 static void __tcp_v6_send_check(struct sk_buff *skb,
 				struct in6_addr *saddr, struct in6_addr *daddr)
 {
@@ -1818,12 +1812,30 @@ do_time_wait:
 	goto discard_it;
 }
 
-struct inet_peer *tcp_v6_get_peer(struct sock *sk, bool *release_it)
+static struct inet_peer *tcp_v6_get_peer(struct sock *sk, bool *release_it)
+{
+	/* Alas, not yet... */
+	return NULL;
+}
+
+static void *tcp_v6_tw_get_peer(struct sock *sk)
 {
+	struct inet_timewait_sock *tw = inet_twsk(sk);
+
+	if (tw->tw_family == AF_INET)
+		return tcp_v4_tw_get_peer(sk);
+
 	/* Alas, not yet... */
 	return NULL;
 }
 
+static struct timewait_sock_ops tcp6_timewait_sock_ops = {
+	.twsk_obj_size	= sizeof(struct tcp6_timewait_sock),
+	.twsk_unique	= tcp_twsk_unique,
+	.twsk_destructor= tcp_twsk_destructor,
+	.twsk_getpeer	= tcp_v6_tw_get_peer,
+};
+
 static const struct inet_connection_sock_af_ops ipv6_specific = {
 	.queue_xmit	   = inet6_csk_xmit,
 	.send_check	   = tcp_v6_send_check,
-- 
1.7.3.2

