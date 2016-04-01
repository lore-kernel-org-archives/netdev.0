From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 09/11] tcp: increment sk_drops for listeners
Date: Fri,  1 Apr 2016 08:52:20 -0700
Message-ID: <1459525942-30399-10-git-send-email-edumazet@google.com>
References: <1459525942-30399-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <tom@herbertland.com>,
	Willem de Bruijn <willemb@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	=?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:32807 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759023AbcDAPwr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 11:52:47 -0400
Received: by mail-pa0-f47.google.com with SMTP id zm5so94043277pac.0
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 08:52:47 -0700 (PDT)
In-Reply-To: <1459525942-30399-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Goal: packets dropped by a listener are accounted for.

This adds tcp_listendrop() helper, and clears sk_drops in sk_clone_lock()
so that children do not inherit their parent drop count.

Note that we no longer increment LINUX_MIB_LISTENDROPS counter when
sending a SYNCOOKIE, since the SYN packet generated a SYNACK.
We already have a separate LINUX_MIB_SYNCOOKIESSENT

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h    | 13 +++++++++++++
 net/core/sock.c      |  1 +
 net/ipv4/tcp_input.c |  8 +++++---
 net/ipv4/tcp_ipv4.c  |  6 +++---
 net/ipv6/tcp_ipv6.c  |  4 ++--
 5 files changed, 24 insertions(+), 8 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index b91370f61be6..0da2e6fcc7aa 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1846,4 +1846,17 @@ static inline void tcp_segs_in(struct tcp_sock *tp, const struct sk_buff *skb)
 		tp->data_segs_in += segs_in;
 }
 
+/*
+ * TCP listen path runs lockless.
+ * We forced "struct sock" to be const qualified to make sure
+ * we don't modify one of its field by mistake.
+ * Here, we increment sk_drops which is an atomic_t, so we can safely
+ * make sock writable again.
+ */
+static inline void tcp_listendrop(const struct sock *sk)
+{
+	atomic_inc(&((struct sock *)sk)->sk_drops);
+	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
+}
+
 #endif	/* _TCP_H */
diff --git a/net/core/sock.c b/net/core/sock.c
index 238a94f879ca..62918344ff2b 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1524,6 +1524,7 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
 		newsk->sk_dst_cache	= NULL;
 		newsk->sk_wmem_queued	= 0;
 		newsk->sk_forward_alloc = 0;
+		atomic_set(&newsk->sk_drops, 0);
 		newsk->sk_send_head	= NULL;
 		newsk->sk_userlocks	= sk->sk_userlocks & ~SOCK_BINDPORT_LOCK;
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d994d358ccbe..f2445cabf734 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -6350,8 +6350,10 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 			inet_csk_reqsk_queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
 		af_ops->send_synack(sk, dst, &fl, req,
 				    &foc, !want_cookie);
-		if (want_cookie)
-			goto drop_and_free;
+		if (want_cookie) {
+			reqsk_free(req);
+			return 0;
+		}
 	}
 	reqsk_put(req);
 	return 0;
@@ -6361,7 +6363,7 @@ drop_and_release:
 drop_and_free:
 	reqsk_free(req);
 drop:
-	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
+	tcp_listendrop(sk);
 	return 0;
 }
 EXPORT_SYMBOL(tcp_conn_request);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 059a98f5e7e1..f3ce0afe70aa 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -329,7 +329,7 @@ void tcp_req_err(struct sock *sk, u32 seq, bool abort)
 		 * errors returned from accept().
 		 */
 		inet_csk_reqsk_queue_drop(req->rsk_listener, req);
-		NET_INC_STATS_BH(net, LINUX_MIB_LISTENDROPS);
+		tcp_listendrop(req->rsk_listener);
 	}
 	reqsk_put(req);
 }
@@ -1246,7 +1246,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 				&tcp_request_sock_ipv4_ops, sk, skb);
 
 drop:
-	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
+	tcp_listendrop(sk);
 	return 0;
 }
 EXPORT_SYMBOL(tcp_v4_conn_request);
@@ -1348,7 +1348,7 @@ exit_overflow:
 exit_nonewsk:
 	dst_release(dst);
 exit:
-	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
+	tcp_listendrop(sk);
 	return NULL;
 put_and_exit:
 	inet_csk_prepare_forced_close(newsk);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 5fa8fea394c9..7cde1b6fdda3 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -964,7 +964,7 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 				&tcp_request_sock_ipv6_ops, sk, skb);
 
 drop:
-	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
+	tcp_listendrop(sk);
 	return 0; /* don't send reset */
 }
 
@@ -1169,7 +1169,7 @@ out_overflow:
 out_nonewsk:
 	dst_release(dst);
 out:
-	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
+	tcp_listendrop(sk);
 	return NULL;
 }
 
-- 
2.8.0.rc3.226.g39d4020
