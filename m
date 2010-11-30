From: David Miller <davem@davemloft.net>
Subject: [PATCH 8/8] inet: Turn ->remember_stamp into ->get_peer in
 connection AF ops.
Date: Tue, 30 Nov 2010 13:22:19 -0800 (PST)
Message-ID: <20101130.132219.229728297.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58869
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752066Ab0K3VVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 16:21:52 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 69CB124C088
	for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 13:22:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Then we can make a completely generic tcp_remember_stamp()
that uses ->get_peer() as a helper, minimizing the AF specific
code and minimizing the eventual code duplication when we implement
the ipv6 side of TW recycling.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/inet_connection_sock.h |    2 +-
 include/net/tcp.h                  |    2 +-
 net/ipv4/tcp_ipv4.c                |   35 ++++++++---------------------------
 net/ipv4/tcp_minisocks.c           |   31 ++++++++++++++++++++++++++++++-
 net/ipv6/tcp_ipv6.c                |    8 ++++----
 5 files changed, 44 insertions(+), 34 deletions(-)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index e4f494b..6c93a56 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -43,7 +43,7 @@ struct inet_connection_sock_af_ops {
 	struct sock *(*syn_recv_sock)(struct sock *sk, struct sk_buff *skb,
 				      struct request_sock *req,
 				      struct dst_entry *dst);
-	int	    (*remember_stamp)(struct sock *sk);
+	struct inet_peer *(*get_peer)(struct sock *sk, bool *release_it);
 	u16	    net_header_len;
 	u16	    sockaddr_len;
 	int	    (*setsockopt)(struct sock *sk, int level, int optname, 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index e36c874..3e23964 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -312,7 +312,7 @@ extern void tcp_shutdown (struct sock *sk, int how);
 
 extern int tcp_v4_rcv(struct sk_buff *skb);
 
-extern int tcp_v4_remember_stamp(struct sock *sk);
+extern struct inet_peer *tcp_v4_get_peer(struct sock *sk, bool *release_it);
 extern int tcp_v4_tw_remember_stamp(struct inet_timewait_sock *tw);
 extern int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		       size_t size);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 00285fc..0ddf819 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1763,44 +1763,25 @@ do_time_wait:
 	goto discard_it;
 }
 
-/* VJ's idea. Save last timestamp seen from this destination
- * and hold it at least for normal timewait interval to use for duplicate
- * segment detection in subsequent connections, before they enter synchronized
- * state.
- */
-
-int tcp_v4_remember_stamp(struct sock *sk)
+struct inet_peer *tcp_v4_get_peer(struct sock *sk, bool *release_it)
 {
+	struct rtable *rt = (struct rtable *) __sk_dst_get(sk);
 	struct inet_sock *inet = inet_sk(sk);
-	struct tcp_sock *tp = tcp_sk(sk);
-	struct rtable *rt = (struct rtable *)__sk_dst_get(sk);
-	struct inet_peer *peer = NULL;
-	int release_it = 0;
+	struct inet_peer *peer;
 
 	if (!rt || rt->rt_dst != inet->inet_daddr) {
 		peer = inet_getpeer_v4(inet->inet_daddr, 1);
-		release_it = 1;
+		*release_it = true;
 	} else {
 		if (!rt->peer)
 			rt_bind_peer(rt, 1);
 		peer = rt->peer;
+		*release_it = false;
 	}
 
-	if (peer) {
-		if ((s32)(peer->tcp_ts - tp->rx_opt.ts_recent) <= 0 ||
-		    ((u32)get_seconds() - peer->tcp_ts_stamp > TCP_PAWS_MSL &&
-		     peer->tcp_ts_stamp <= (u32)tp->rx_opt.ts_recent_stamp)) {
-			peer->tcp_ts_stamp = (u32)tp->rx_opt.ts_recent_stamp;
-			peer->tcp_ts = tp->rx_opt.ts_recent;
-		}
-		if (release_it)
-			inet_putpeer(peer);
-		return 1;
-	}
-
-	return 0;
+	return peer;
 }
-EXPORT_SYMBOL(tcp_v4_remember_stamp);
+EXPORT_SYMBOL(tcp_v4_get_peer);
 
 int tcp_v4_tw_remember_stamp(struct inet_timewait_sock *tw)
 {
@@ -1828,7 +1809,7 @@ const struct inet_connection_sock_af_ops ipv4_specific = {
 	.rebuild_header	   = inet_sk_rebuild_header,
 	.conn_request	   = tcp_v4_conn_request,
 	.syn_recv_sock	   = tcp_v4_syn_recv_sock,
-	.remember_stamp	   = tcp_v4_remember_stamp,
+	.get_peer	   = tcp_v4_get_peer,
 	.net_header_len	   = sizeof(struct iphdr),
 	.setsockopt	   = ip_setsockopt,
 	.getsockopt	   = ip_getsockopt,
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 43cf901..059082c 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -49,6 +49,35 @@ struct inet_timewait_death_row tcp_death_row = {
 };
 EXPORT_SYMBOL_GPL(tcp_death_row);
 
+/* VJ's idea. Save last timestamp seen from this destination
+ * and hold it at least for normal timewait interval to use for duplicate
+ * segment detection in subsequent connections, before they enter synchronized
+ * state.
+ */
+
+static int tcp_remember_stamp(struct sock *sk)
+{
+	const struct inet_connection_sock *icsk = inet_csk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct inet_peer *peer;
+	bool release_it;
+
+	peer = icsk->icsk_af_ops->get_peer(sk, &release_it);
+	if (peer) {
+		if ((s32)(peer->tcp_ts - tp->rx_opt.ts_recent) <= 0 ||
+		    ((u32)get_seconds() - peer->tcp_ts_stamp > TCP_PAWS_MSL &&
+		     peer->tcp_ts_stamp <= (u32)tp->rx_opt.ts_recent_stamp)) {
+			peer->tcp_ts_stamp = (u32)tp->rx_opt.ts_recent_stamp;
+			peer->tcp_ts = tp->rx_opt.ts_recent;
+		}
+		if (release_it)
+			inet_putpeer(peer);
+		return 1;
+	}
+
+	return 0;
+}
+
 static __inline__ int tcp_in_window(u32 seq, u32 end_seq, u32 s_win, u32 e_win)
 {
 	if (seq == s_win)
@@ -274,7 +303,7 @@ void tcp_time_wait(struct sock *sk, int state, int timeo)
 	int recycle_ok = 0;
 
 	if (tcp_death_row.sysctl_tw_recycle && tp->rx_opt.ts_recent_stamp)
-		recycle_ok = icsk->icsk_af_ops->remember_stamp(sk);
+		recycle_ok = tcp_remember_stamp(sk);
 
 	if (tcp_death_row.tw_count < tcp_death_row.sysctl_max_tw_buckets)
 		tw = inet_twsk_alloc(sk, state);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 7e41e2c..e394d00 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1818,10 +1818,10 @@ do_time_wait:
 	goto discard_it;
 }
 
-static int tcp_v6_remember_stamp(struct sock *sk)
+struct inet_peer *tcp_v6_get_peer(struct sock *sk, bool *release_it)
 {
 	/* Alas, not yet... */
-	return 0;
+	return NULL;
 }
 
 static const struct inet_connection_sock_af_ops ipv6_specific = {
@@ -1830,7 +1830,7 @@ static const struct inet_connection_sock_af_ops ipv6_specific = {
 	.rebuild_header	   = inet6_sk_rebuild_header,
 	.conn_request	   = tcp_v6_conn_request,
 	.syn_recv_sock	   = tcp_v6_syn_recv_sock,
-	.remember_stamp	   = tcp_v6_remember_stamp,
+	.get_peer	   = tcp_v6_get_peer,
 	.net_header_len	   = sizeof(struct ipv6hdr),
 	.setsockopt	   = ipv6_setsockopt,
 	.getsockopt	   = ipv6_getsockopt,
@@ -1862,7 +1862,7 @@ static const struct inet_connection_sock_af_ops ipv6_mapped = {
 	.rebuild_header	   = inet_sk_rebuild_header,
 	.conn_request	   = tcp_v6_conn_request,
 	.syn_recv_sock	   = tcp_v6_syn_recv_sock,
-	.remember_stamp	   = tcp_v4_remember_stamp,
+	.get_peer	   = tcp_v4_get_peer,
 	.net_header_len	   = sizeof(struct iphdr),
 	.setsockopt	   = ipv6_setsockopt,
 	.getsockopt	   = ipv6_getsockopt,
-- 
1.7.3.2

