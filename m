From: Dmitry Popov <dp@highloadlab.com>
Subject: [PATCH 5/5] tcp: ipv4 listen state scaled
Date: Wed, 27 Oct 2010 17:32:23 +0400
Message-ID: <AANLkTikRsOevLBHn0xb0S_YvfPMWpAdw373bxQUc+xbV@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: "David S. Miller" <davem@davemloft.net>,
	William.Allen.Simpson@gmail.com,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Andreas Petlund <apetlund@simula.no>,
	Shan Wei <shanwei@cn.fujitsu.co
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:51163 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756640Ab0J0Nc0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 09:32:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Popov <dp@highloadlab.com>

Fast path for TCP_LISTEN state processing added.

tcp_v4_rcv_listen is called from tcp_v4_rcv without socket lock.
However, it may acquire main socket lock in 3 cases:
1) To check syn_table in tcp_v4_hnd_req.
2) To check syn_table and modify accept queue in tcp_v4_conn_request.
3) To modify accept queue in get_cookie_sock.

In cases 1 and 2 we check for user lock and add skb to sk_backlog if
socket is locked.
In case 3 we don't check for user lock and it may lead to wrong
behavior. That's why we need socket locking in tcp_set_state(sk,
TCP_CLOSE).

Additional state in sk->sk_lock.owned is needed to prevent infinite
loop in backlog processing.

Signed-off-by: Dmitry Popov <dp@highloadlab.com>
---
 include/net/sock.h    |    6 ++-
 net/core/sock.c       |    4 +-
 net/ipv4/syncookies.c |   20 +++++-
 net/ipv4/tcp.c        |    5 ++
 net/ipv4/tcp_ipv4.c   |  159 +++++++++++++++++++++++++++++++++++++++++--------
 5 files changed, 162 insertions(+), 32 deletions(-)
diff --git a/include/net/sock.h b/include/net/sock.h
index adab9dc..b6d0ca1 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -994,7 +994,11 @@ static inline void sk_wmem_free_skb(struct sock
*sk, struct sk_buff *skb)
  * Since ~2.3.5 it is also exclusive sleep lock serializing
  * accesses from user process context.
  */
-#define sock_owned_by_user(sk)	((sk)->sk_lock.owned)
+#define sock_owned_by_user(sk)		((sk)->sk_lock.owned)
+/* backlog processing, see __release_sock(sk) */
+#define sock_owned_by_backlog(sk)	((sk)->sk_lock.owned < 0)
+/* sock owned by user, but not for backlog processing */
+#define __sock_owned_by_user(sk)	((sk)->sk_lock.owned > 0)

 /*
  * Macro so as to not evaluate some arguments when
diff --git a/net/core/sock.c b/net/core/sock.c
index e73dfe3..f4233c7 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2015,8 +2015,10 @@ void release_sock(struct sock *sk)
 	mutex_release(&sk->sk_lock.dep_map, 1, _RET_IP_);

 	spin_lock_bh(&sk->sk_lock.slock);
-	if (sk->sk_backlog.tail)
+	if (sk->sk_backlog.tail) {
+		sk->sk_lock.owned = -1;
 		__release_sock(sk);
+	}
 	sk->sk_lock.owned = 0;
 	if (waitqueue_active(&sk->sk_lock.wq))
 		wake_up(&sk->sk_lock.wq);
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 650cace..a37f8e8 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -211,10 +211,22 @@ static inline struct sock
*get_cookie_sock(struct sock *sk, struct sk_buff *skb,
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct sock *child;

-	child = icsk->icsk_af_ops->syn_recv_sock(sk, skb, req, dst);
-	if (child)
-		inet_csk_reqsk_queue_add(sk, req, child);
-	else
+	bh_lock_sock_nested(sk);
+	/* TODO: move syn_recv_sock before this lock */
+	spin_lock(&icsk->icsk_accept_queue.rskq_accept_lock);
+
+	if (likely(icsk->icsk_accept_queue.rskq_active)) {
+		child = icsk->icsk_af_ops->syn_recv_sock(sk, skb, req, dst);
+		if (child)
+			inet_csk_reqsk_queue_do_add(sk, req, child);
+	} else {
+		child = NULL;
+	}
+
+	spin_unlock(&icsk->icsk_accept_queue.rskq_accept_lock);
+	bh_unlock_sock(sk);
+
+	if (unlikely(child == NULL))
 		reqsk_free(req);

 	return child;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index ebb9d80..417f2d9 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1812,10 +1812,15 @@ void tcp_set_state(struct sock *sk, int state)
 		if (oldstate == TCP_CLOSE_WAIT || oldstate == TCP_ESTABLISHED)
 			TCP_INC_STATS(sock_net(sk), TCP_MIB_ESTABRESETS);

+		if (oldstate == TCP_LISTEN)
+			/* We have to prevent race condition in syn_recv_sock */
+			bh_lock_sock_nested(sk);
 		sk->sk_prot->unhash(sk);
 		if (inet_csk(sk)->icsk_bind_hash &&
 		    !(sk->sk_userlocks & SOCK_BINDPORT_LOCK))
 			inet_put_port(sk);
+		if (oldstate == TCP_LISTEN)
+			bh_unlock_sock(sk);
 		/* fall through */
 	default:
 		if (oldstate == TCP_ESTABLISHED)
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 1e641b0..f22931d 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1338,7 +1338,24 @@ int tcp_v4_conn_request(struct sock *sk, struct
sk_buff *skb)

 	/* Never answer to SYNs send to broadcast or multicast */
 	if (skb_rtable(skb)->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST))
+		return 0;
+
+	bh_lock_sock_nested(sk);
+
+	if (__sock_owned_by_user(sk)) {
+		/* Some inefficiency: it leads to double syn_table lookup */
+		if (likely(!sk_add_backlog(sk, skb)))
+			skb_get(skb);
+		else
+			NET_INC_STATS_BH(dev_net(skb->dev),
+					 LINUX_MIB_TCPBACKLOGDROP);
 		goto drop;
+	}
+
+	if (inet_csk(sk)->icsk_accept_queue.listen_opt == NULL) {
+		/* socket is closing */
+		goto drop;
+	}

 	/* TW buckets are converted to open requests without
 	 * limitations, they conserve resources and peer is
@@ -1353,6 +1370,7 @@ int tcp_v4_conn_request(struct sock *sk, struct
sk_buff *skb)
 			syn_flood_warning(skb);
 		if (sysctl_tcp_syncookies) {
 			tcp_inc_syncookie_stats(&tp->syncookie_stats);
+			bh_unlock_sock(sk);
 			want_cookie = 1;
 		} else
 #else
@@ -1405,9 +1423,6 @@ int tcp_v4_conn_request(struct sock *sk, struct
sk_buff *skb)
 		while (l-- > 0)
 			*c++ ^= *hash_location++;

-#ifdef CONFIG_SYN_COOKIES
-		want_cookie = 0;	/* not our kind of cookie */
-#endif
 		tmp_ext.cookie_out_never = 0; /* false */
 		tmp_ext.cookie_plus = tmp_opt.cookie_plus;
 		tmp_ext.cookie_in_always = tp->rx_opt.cookie_in_always;
@@ -1494,6 +1509,7 @@ int tcp_v4_conn_request(struct sock *sk, struct
sk_buff *skb)
 		goto drop_and_free;

 	inet_csk_reqsk_queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
+	bh_unlock_sock(sk);
 	return 0;

 drop_and_release:
@@ -1501,6 +1517,8 @@ drop_and_release:
 drop_and_free:
 	reqsk_free(req);
 drop:
+	if (!want_cookie)
+		bh_unlock_sock(sk);
 	return 0;
 }
 EXPORT_SYMBOL(tcp_v4_conn_request);
@@ -1588,10 +1606,35 @@ static struct sock *tcp_v4_hnd_req(struct sock
*sk, struct sk_buff *skb)
 	struct sock *nsk;
 	struct request_sock **prev;
 	/* Find possible connection requests. */
-	struct request_sock *req = inet_csk_search_req(sk, &prev, th->source,
+	struct request_sock *req;
+
+	bh_lock_sock_nested(sk);
+
+	if (__sock_owned_by_user(sk)) {
+		if (likely(!sk_add_backlog(sk, skb)))
+			skb_get(skb);
+		else
+			NET_INC_STATS_BH(dev_net(skb->dev),
+					 LINUX_MIB_TCPBACKLOGDROP);
+		bh_unlock_sock(sk);
+		return NULL;
+	}
+
+	if (inet_csk(sk)->icsk_accept_queue.listen_opt == NULL) {
+		/* socket is closing */
+		bh_unlock_sock(sk);
+		return NULL;
+	}
+
+	req = inet_csk_search_req(sk, &prev, th->source,
 						       iph->saddr, iph->daddr);
-	if (req)
-		return tcp_check_req(sk, skb, req, prev);
+	if (req) {
+		nsk = tcp_check_req(sk, skb, req, prev);
+		bh_unlock_sock(sk);
+		return nsk;
+	} else {
+		bh_unlock_sock(sk);
+	}

 	nsk = inet_lookup_established(sock_net(sk), &tcp_hashinfo, iph->saddr,
 			th->source, iph->daddr, th->dest, inet_iif(skb));
@@ -1633,6 +1676,72 @@ static __sum16 tcp_v4_checksum_init(struct sk_buff *skb)
 	return 0;
 }

+/* Beware! This may be called without socket lock.
+ * TCP Checksum should be checked before this call.
+ */
+int tcp_v4_rcv_listen(struct sock *sk, struct sk_buff *skb)
+{
+	struct sock *nsk;
+	struct sock *rsk;
+	struct tcphdr *th = tcp_hdr(skb);
+
+	nsk = tcp_v4_hnd_req(sk, skb);
+
+	if (!nsk)
+		goto discard;
+
+	if (nsk != sk) {
+		/* Probable SYN-ACK */
+		if (tcp_child_process(sk, nsk, skb)) {
+			rsk = nsk;
+			goto reset;
+		}
+		return 0;
+	}
+
+	/* Probable SYN */
+	TCP_CHECK_TIMER(sk);
+
+	if (th->ack) {
+		rsk = sk;
+		goto reset;
+	}
+
+	if (!th->rst && th->syn) {
+		if (inet_csk(sk)->icsk_af_ops->conn_request(sk, skb) < 0) {
+			rsk = sk;
+			goto reset;
+		}
+		/* Now we have several options: In theory there is
+		 * nothing else in the frame. KA9Q has an option to
+		 * send data with the syn, BSD accepts data with the
+		 * syn up to the [to be] advertised window and
+		 * Solaris 2.1 gives you a protocol error. For now
+		 * we just ignore it, that fits the spec precisely
+		 * and avoids incompatibilities. It would be nice in
+		 * future to drop through and process the data.
+		 *
+		 * Now that TTCP is starting to be used we ought to
+		 * queue this data.
+		 * But, this leaves one open to an easy denial of
+		 * service attack, and SYN cookies can't defend
+		 * against this problem. So, we drop the data
+		 * in the interest of security over speed unless
+		 * it's still in use.
+		 */
+	}
+
+	TCP_CHECK_TIMER(sk);
+
+discard:
+	kfree_skb(skb);
+	return 0;
+
+reset:
+	tcp_v4_send_reset(rsk, skb);
+	goto discard;
+}
+

 /* The socket must have it's spinlock held when we get
  * here.
@@ -1644,15 +1753,11 @@ static __sum16 tcp_v4_checksum_init(struct sk_buff *skb)
  */
 int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 {
-	struct sock *rsk;
-
 	if (sk->sk_state == TCP_ESTABLISHED) { /* Fast path */
 		sock_rps_save_rxhash(sk, skb->rxhash);
 		TCP_CHECK_TIMER(sk);
-		if (tcp_rcv_established(sk, skb, tcp_hdr(skb), skb->len)) {
-			rsk = sk;
+		if (tcp_rcv_established(sk, skb, tcp_hdr(skb), skb->len))
 			goto reset;
-		}
 		TCP_CHECK_TIMER(sk);
 		return 0;
 	}
@@ -1660,32 +1765,23 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 	if (skb->len < tcp_hdrlen(skb) || tcp_checksum_complete(skb))
 		goto csum_err;

-	if (sk->sk_state == TCP_LISTEN) {
-		struct sock *nsk = tcp_v4_hnd_req(sk, skb);
-		if (!nsk)
-			goto discard;
-
-		if (nsk != sk) {
-			if (tcp_child_process(sk, nsk, skb)) {
-				rsk = nsk;
-				goto reset;
-			}
-			return 0;
-		}
-	} else
+	if (sk->sk_state == TCP_LISTEN)
+		/* This is for IPv4-mapped IPv6 addresses
+		   and backlog processing */
+		return tcp_v4_rcv_listen(sk, skb);
+	else
 		sock_rps_save_rxhash(sk, skb->rxhash);


 	TCP_CHECK_TIMER(sk);
 	if (tcp_rcv_state_process(sk, skb, tcp_hdr(skb), skb->len)) {
-		rsk = sk;
 		goto reset;
 	}
 	TCP_CHECK_TIMER(sk);
 	return 0;

 reset:
-	tcp_v4_send_reset(rsk, skb);
+	tcp_v4_send_reset(sk, skb);
 discard:
 	kfree_skb(skb);
 	/* Be careful here. If this function gets more complicated and
@@ -1779,6 +1875,17 @@ process:
 		goto discard_and_relse;
 #endif

+	if (sk->sk_state == TCP_LISTEN) {
+		/* Fast path for listening socket */
+		if (skb->len < tcp_hdrlen(skb) || tcp_checksum_complete(skb)) {
+			TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_INERRS);
+			goto discard_and_relse;
+		}
+		tcp_v4_rcv_listen(sk, skb);
+		sock_put(sk);
+		return 0;
+	}
+
 	bh_lock_sock_nested(sk);
 	ret = 0;
 	if (!sock_owned_by_user(sk)) {
