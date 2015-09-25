From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 02/17] tcp: constify tcp_openreq_init_rwin()
Date: Fri, 25 Sep 2015 07:39:09 -0700
Message-ID: <1443191964-923-3-git-send-email-edumazet@google.com>
References: <1443191964-923-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <edumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33835 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932113AbbIYOjr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 10:39:47 -0400
Received: by padhy16 with SMTP id hy16so107760440pad.1
        for <netdev@vger.kernel.org>; Fri, 25 Sep 2015 07:39:47 -0700 (PDT)
In-Reply-To: <1443191964-923-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Soon, listener socket wont be locked when tcp_openreq_init_rwin()
is called. We need to read socket fields once, as their value
could change under us.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h        |  3 ++-
 net/ipv4/tcp_minisocks.c | 28 ++++++++++++++++++----------
 2 files changed, 20 insertions(+), 11 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 50af10ef1a3d..a89ec41fa3d9 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1207,7 +1207,8 @@ static inline int tcp_full_space(const struct sock *sk)
 }
 
 extern void tcp_openreq_init_rwin(struct request_sock *req,
-				  struct sock *sk, struct dst_entry *dst);
+				  const struct sock *sk_listener,
+				  const struct dst_entry *dst);
 
 void tcp_enter_memory_pressure(struct sock *sk);
 
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 6e23c36d26e9..e4fe62b6b106 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -361,27 +361,35 @@ void tcp_twsk_destructor(struct sock *sk)
 }
 EXPORT_SYMBOL_GPL(tcp_twsk_destructor);
 
+/* Warning : This function is called without sk_listener being locked.
+ * Be sure to read socket fields once, as their value could change under us.
+ */
 void tcp_openreq_init_rwin(struct request_sock *req,
-			   struct sock *sk, struct dst_entry *dst)
+			   const struct sock *sk_listener,
+			   const struct dst_entry *dst)
 {
 	struct inet_request_sock *ireq = inet_rsk(req);
-	struct tcp_sock *tp = tcp_sk(sk);
-	__u8 rcv_wscale;
+	const struct tcp_sock *tp = tcp_sk(sk_listener);
+	u16 user_mss = READ_ONCE(tp->rx_opt.user_mss);
+	int full_space = tcp_full_space(sk_listener);
 	int mss = dst_metric_advmss(dst);
+	u32 window_clamp;
+	__u8 rcv_wscale;
 
-	if (tp->rx_opt.user_mss && tp->rx_opt.user_mss < mss)
-		mss = tp->rx_opt.user_mss;
+	if (user_mss && user_mss < mss)
+		mss = user_mss;
 
+	window_clamp = READ_ONCE(tp->window_clamp);
 	/* Set this up on the first call only */
-	req->window_clamp = tp->window_clamp ? : dst_metric(dst, RTAX_WINDOW);
+	req->window_clamp = window_clamp ? : dst_metric(dst, RTAX_WINDOW);
 
 	/* limit the window selection if the user enforce a smaller rx buffer */
-	if (sk->sk_userlocks & SOCK_RCVBUF_LOCK &&
-	    (req->window_clamp > tcp_full_space(sk) || req->window_clamp == 0))
-		req->window_clamp = tcp_full_space(sk);
+	if (sk_listener->sk_userlocks & SOCK_RCVBUF_LOCK &&
+	    (req->window_clamp > full_space || req->window_clamp == 0))
+		req->window_clamp = full_space;
 
 	/* tcp_full_space because it is guaranteed to be the first packet */
-	tcp_select_initial_window(tcp_full_space(sk),
+	tcp_select_initial_window(full_space,
 		mss - (ireq->tstamp_ok ? TCPOLEN_TSTAMP_ALIGNED : 0),
 		&req->rcv_wnd,
 		&req->window_clamp,
-- 
2.6.0.rc2.230.g3dd15c0
