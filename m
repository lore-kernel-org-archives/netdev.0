From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 05/15] tcp: use tcp_jiffies32 to feed tp->snd_cwnd_stamp
Date: Tue, 16 May 2017 14:00:04 -0700
Message-ID: <20170516210014.31176-6-edumazet@google.com>
References: <20170516210014.31176-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Wei Wang <weiwan@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:32935 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752635AbdEPV2O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 17:28:14 -0400
Received: by mail-pf0-f173.google.com with SMTP id e193so86499710pfh.0
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 14:28:09 -0700 (PDT)
In-Reply-To: <20170516210014.31176-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use tcp_jiffies32 instead of tcp_time_stamp to feed
tp->snd_cwnd_stamp.

tcp_time_stamp will soon be a litle bit more expensive
than simply reading 'jiffies'.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_input.c   | 14 +++++++-------
 net/ipv4/tcp_metrics.c |  2 +-
 net/ipv4/tcp_output.c  |  8 ++++----
 3 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c0b3f909df394214785749704f2760171fe9d160..6a15c9b80b09829799dc37d89ecdbf11ec9ff904 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -463,7 +463,7 @@ void tcp_init_buffer_space(struct sock *sk)
 		tp->window_clamp = max(2 * tp->advmss, maxwin - tp->advmss);
 
 	tp->rcv_ssthresh = min(tp->rcv_ssthresh, tp->window_clamp);
-	tp->snd_cwnd_stamp = tcp_time_stamp;
+	tp->snd_cwnd_stamp = tcp_jiffies32;
 }
 
 /* 5. Recalculate window clamp after socket hit its memory bounds. */
@@ -1954,7 +1954,7 @@ void tcp_enter_loss(struct sock *sk)
 	}
 	tp->snd_cwnd	   = 1;
 	tp->snd_cwnd_cnt   = 0;
-	tp->snd_cwnd_stamp = tcp_time_stamp;
+	tp->snd_cwnd_stamp = tcp_jiffies32;
 
 	tp->retrans_out = 0;
 	tp->lost_out = 0;
@@ -2383,7 +2383,7 @@ static void tcp_undo_cwnd_reduction(struct sock *sk, bool unmark_loss)
 			tcp_ecn_withdraw_cwr(tp);
 		}
 	}
-	tp->snd_cwnd_stamp = tcp_time_stamp;
+	tp->snd_cwnd_stamp = tcp_jiffies32;
 	tp->undo_marker = 0;
 }
 
@@ -2520,7 +2520,7 @@ static inline void tcp_end_cwnd_reduction(struct sock *sk)
 	if (inet_csk(sk)->icsk_ca_state == TCP_CA_CWR ||
 	    (tp->undo_marker && tp->snd_ssthresh < TCP_INFINITE_SSTHRESH)) {
 		tp->snd_cwnd = tp->snd_ssthresh;
-		tp->snd_cwnd_stamp = tcp_time_stamp;
+		tp->snd_cwnd_stamp = tcp_jiffies32;
 	}
 	tcp_ca_event(sk, CA_EVENT_COMPLETE_CWR);
 }
@@ -2590,7 +2590,7 @@ static void tcp_mtup_probe_success(struct sock *sk)
 		       tcp_mss_to_mtu(sk, tp->mss_cache) /
 		       icsk->icsk_mtup.probe_size;
 	tp->snd_cwnd_cnt = 0;
-	tp->snd_cwnd_stamp = tcp_time_stamp;
+	tp->snd_cwnd_stamp = tcp_jiffies32;
 	tp->snd_ssthresh = tcp_current_ssthresh(sk);
 
 	icsk->icsk_mtup.search_low = icsk->icsk_mtup.probe_size;
@@ -2976,7 +2976,7 @@ static void tcp_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 
 	icsk->icsk_ca_ops->cong_avoid(sk, ack, acked);
-	tcp_sk(sk)->snd_cwnd_stamp = tcp_time_stamp;
+	tcp_sk(sk)->snd_cwnd_stamp = tcp_jiffies32;
 }
 
 /* Restart timer after forward progress on connection.
@@ -5019,7 +5019,7 @@ static void tcp_new_space(struct sock *sk)
 
 	if (tcp_should_expand_sndbuf(sk)) {
 		tcp_sndbuf_expand(sk);
-		tp->snd_cwnd_stamp = tcp_time_stamp;
+		tp->snd_cwnd_stamp = tcp_jiffies32;
 	}
 
 	sk->sk_write_space(sk);
diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 653bbd67e3a39b68d27d26d17571c00ce2854bfd..102b2c90bb807d3a88d31b59324baf72cf901cdf 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -524,7 +524,7 @@ void tcp_init_metrics(struct sock *sk)
 		tp->snd_cwnd = 1;
 	else
 		tp->snd_cwnd = tcp_init_cwnd(tp, dst);
-	tp->snd_cwnd_stamp = tcp_time_stamp;
+	tp->snd_cwnd_stamp = tcp_jiffies32;
 }
 
 bool tcp_peer_is_proven(struct request_sock *req, struct dst_entry *dst)
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index be9f8f483e21bdbb4d944fcdae8560f3ae11ee64..4bd50f0b236ba23fe521a76dd9d35ee16acb061f 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -151,7 +151,7 @@ void tcp_cwnd_restart(struct sock *sk, s32 delta)
 	while ((delta -= inet_csk(sk)->icsk_rto) > 0 && cwnd > restart_cwnd)
 		cwnd >>= 1;
 	tp->snd_cwnd = max(cwnd, restart_cwnd);
-	tp->snd_cwnd_stamp = tcp_time_stamp;
+	tp->snd_cwnd_stamp = tcp_jiffies32;
 	tp->snd_cwnd_used = 0;
 }
 
@@ -1576,7 +1576,7 @@ static void tcp_cwnd_application_limited(struct sock *sk)
 		}
 		tp->snd_cwnd_used = 0;
 	}
-	tp->snd_cwnd_stamp = tcp_time_stamp;
+	tp->snd_cwnd_stamp = tcp_jiffies32;
 }
 
 static void tcp_cwnd_validate(struct sock *sk, bool is_cwnd_limited)
@@ -1597,14 +1597,14 @@ static void tcp_cwnd_validate(struct sock *sk, bool is_cwnd_limited)
 	if (tcp_is_cwnd_limited(sk)) {
 		/* Network is feed fully. */
 		tp->snd_cwnd_used = 0;
-		tp->snd_cwnd_stamp = tcp_time_stamp;
+		tp->snd_cwnd_stamp = tcp_jiffies32;
 	} else {
 		/* Network starves. */
 		if (tp->packets_out > tp->snd_cwnd_used)
 			tp->snd_cwnd_used = tp->packets_out;
 
 		if (sysctl_tcp_slow_start_after_idle &&
-		    (s32)(tcp_time_stamp - tp->snd_cwnd_stamp) >= inet_csk(sk)->icsk_rto &&
+		    (s32)(tcp_jiffies32 - tp->snd_cwnd_stamp) >= inet_csk(sk)->icsk_rto &&
 		    !ca_ops->cong_control)
 			tcp_cwnd_application_limited(sk);
 
-- 
2.13.0.303.g4ebf302169-goog
