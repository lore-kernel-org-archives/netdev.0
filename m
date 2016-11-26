From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next 4/6] tcp: instrument how long TCP is limited by insufficient send buffer
Date: Sat, 26 Nov 2016 12:10:14 -0800
Message-ID: <1480191016-73210-5-git-send-email-ycheng@google.com>
References: <1480191016-73210-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, ncardwell@google.com, edumazet@google.com,
        Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, soheil@google.com, francisyyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:36127 "EHLO
        mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751453AbcKZUKk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 26 Nov 2016 15:10:40 -0500
Received: by mail-io0-f170.google.com with SMTP id m5so33678014ioe.3
        for <netdev@vger.kernel.org>; Sat, 26 Nov 2016 12:10:39 -0800 (PST)
In-Reply-To: <1480191016-73210-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francis Yan <francisyyan@gmail.com>

This patch measures the amount of time when TCP runs out of new data
to send to the network due to insufficient send buffer, while TCP
is still busy delivering (i.e. write queue is not empty). The goal
is to indicate either the send buffer autotuning or user SO_SNDBUF
setting has resulted network under-utilization.

The measurement starts conservatively by checking various conditions
to minimize false claims (i.e. under-estimation is more likely).
The measurement stops when the SOCK_NOSPACE flag is cleared. But it
does not account the time elapsed till the next application write.
Also the measurement only starts if the sender is still busy sending
data, s.t. the limit accounted is part of the total busy time.

Signed-off-by: Francis Yan <francisyyan@gmail.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
---
 net/ipv4/tcp.c        | 10 ++++++++--
 net/ipv4/tcp_input.c  |  5 ++++-
 net/ipv4/tcp_output.c | 12 ++++++++++++
 3 files changed, 24 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 913f9bb..259ffb5 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -996,8 +996,11 @@ static ssize_t do_tcp_sendpages(struct sock *sk, struct page *page, int offset,
 		goto out;
 out_err:
 	/* make sure we wake any epoll edge trigger waiter */
-	if (unlikely(skb_queue_len(&sk->sk_write_queue) == 0 && err == -EAGAIN))
+	if (unlikely(skb_queue_len(&sk->sk_write_queue) == 0 &&
+		     err == -EAGAIN)) {
 		sk->sk_write_space(sk);
+		tcp_chrono_stop(sk, TCP_CHRONO_SNDBUF_LIMITED);
+	}
 	return sk_stream_error(sk, flags, err);
 }
 
@@ -1331,8 +1334,11 @@ int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 out_err:
 	err = sk_stream_error(sk, flags, err);
 	/* make sure we wake any epoll edge trigger waiter */
-	if (unlikely(skb_queue_len(&sk->sk_write_queue) == 0 && err == -EAGAIN))
+	if (unlikely(skb_queue_len(&sk->sk_write_queue) == 0 &&
+		     err == -EAGAIN)) {
 		sk->sk_write_space(sk);
+		tcp_chrono_stop(sk, TCP_CHRONO_SNDBUF_LIMITED);
+	}
 	release_sock(sk);
 	return err;
 }
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a5d1727..56fe736 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5059,8 +5059,11 @@ static void tcp_check_space(struct sock *sk)
 		/* pairs with tcp_poll() */
 		smp_mb__after_atomic();
 		if (sk->sk_socket &&
-		    test_bit(SOCK_NOSPACE, &sk->sk_socket->flags))
+		    test_bit(SOCK_NOSPACE, &sk->sk_socket->flags)) {
 			tcp_new_space(sk);
+			if (!test_bit(SOCK_NOSPACE, &sk->sk_socket->flags))
+				tcp_chrono_stop(sk, TCP_CHRONO_SNDBUF_LIMITED);
+		}
 	}
 }
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index b74444c..d3545d0 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1514,6 +1514,18 @@ static void tcp_cwnd_validate(struct sock *sk, bool is_cwnd_limited)
 		if (sysctl_tcp_slow_start_after_idle &&
 		    (s32)(tcp_time_stamp - tp->snd_cwnd_stamp) >= inet_csk(sk)->icsk_rto)
 			tcp_cwnd_application_limited(sk);
+
+		/* The following conditions together indicate the starvation
+		 * is caused by insufficient sender buffer:
+		 * 1) just sent some data (see tcp_write_xmit)
+		 * 2) not cwnd limited (this else condition)
+		 * 3) no more data to send (null tcp_send_head )
+		 * 4) application is hitting buffer limit (SOCK_NOSPACE)
+		 */
+		if (!tcp_send_head(sk) && sk->sk_socket &&
+		    test_bit(SOCK_NOSPACE, &sk->sk_socket->flags) &&
+		    (1 << sk->sk_state) & (TCPF_ESTABLISHED | TCPF_CLOSE_WAIT))
+			tcp_chrono_start(sk, TCP_CHRONO_SNDBUF_LIMITED);
 	}
 }
 
-- 
2.8.0.rc3.226.g39d4020
