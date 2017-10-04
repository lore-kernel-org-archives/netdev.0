From: Wei Wang <weiwan@google.com>
Subject: [PATCH v2 net-next 1/2] tcp: uniform the set up of sockets after successful connection
Date: Wed,  4 Oct 2017 10:03:44 -0700
Message-ID: <20171004170344.132339-1-tracywwnj@gmail.com>
Cc: Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:46822 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751240AbdJDRDz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 13:03:55 -0400
Received: by mail-pf0-f180.google.com with SMTP id r68so6559939pfj.3
        for <netdev@vger.kernel.org>; Wed, 04 Oct 2017 10:03:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

Currently in the TCP code, the initialization sequence for cached
metrics, congestion control, BPF, etc, after successful connection
is very inconsistent. This introduces inconsistent bevhavior and is
prone to bugs. The current call sequence is as follows:

(1) for active case (tcp_finish_connect() case):
        tcp_mtup_init(sk);
        icsk->icsk_af_ops->rebuild_header(sk);
        tcp_init_metrics(sk);
        tcp_call_bpf(sk, BPF_SOCK_OPS_ACTIVE_ESTABLISHED_CB);
        tcp_init_congestion_control(sk);
        tcp_init_buffer_space(sk);

(2) for passive case (tcp_rcv_state_process() TCP_SYN_RECV case):
        icsk->icsk_af_ops->rebuild_header(sk);
        tcp_call_bpf(sk, BPF_SOCK_OPS_PASSIVE_ESTABLISHED_CB);
        tcp_init_congestion_control(sk);
        tcp_mtup_init(sk);
        tcp_init_buffer_space(sk);
        tcp_init_metrics(sk);

(3) for TFO passive case (tcp_fastopen_create_child()):
        inet_csk(child)->icsk_af_ops->rebuild_header(child);
        tcp_init_congestion_control(child);
        tcp_mtup_init(child);
        tcp_init_metrics(child);
        tcp_call_bpf(child, BPF_SOCK_OPS_PASSIVE_ESTABLISHED_CB);
        tcp_init_buffer_space(child);

This commit uniforms the above functions to have the following sequence:
        tcp_mtup_init(sk);
        icsk->icsk_af_ops->rebuild_header(sk);
        tcp_init_metrics(sk);
        tcp_call_bpf(sk, BPF_SOCK_OPS_ACTIVE/PASSIVE_ESTABLISHED_CB);
        tcp_init_congestion_control(sk);
        tcp_init_buffer_space(sk);
This sequence is the same as the (1) active case. We pick this sequence
because this order correctly allows BPF to override the settings
including congestion control module and initial cwnd, etc from
the route, and then allows the CC module to see those settings.

Suggested-by: Neal Cardwell <ncardwell@google.com>
Tested-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Wei Wang <weiwan@google.com>
Acked-by: Neal Cardwell <ncardwell@google.com>
Acked-by: Yuchung Cheng <ycheng@google.com>
Acked-by: Eric Dumazet <edumazet@google.com>
---
change in v2:
 removed EXPORT_SYMBOL(tcp_init_transfer);

 include/net/tcp.h       |  1 +
 net/ipv4/tcp.c          | 12 ++++++++++++
 net/ipv4/tcp_fastopen.c |  7 +------
 net/ipv4/tcp_input.c    | 21 +++------------------
 4 files changed, 17 insertions(+), 24 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 770b608c8439..f45fdc57d29d 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -417,6 +417,7 @@ bool tcp_peer_is_proven(struct request_sock *req, struct dst_entry *dst);
 void tcp_disable_fack(struct tcp_sock *tp);
 void tcp_close(struct sock *sk, long timeout);
 void tcp_init_sock(struct sock *sk);
+void tcp_init_transfer(struct sock *sk, int bpf_op);
 unsigned int tcp_poll(struct file *file, struct socket *sock,
 		      struct poll_table_struct *wait);
 int tcp_getsockopt(struct sock *sk, int level, int optname,
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 5091402720ab..3ed21e281c39 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -456,6 +456,18 @@ void tcp_init_sock(struct sock *sk)
 }
 EXPORT_SYMBOL(tcp_init_sock);
 
+void tcp_init_transfer(struct sock *sk, int bpf_op)
+{
+	struct inet_connection_sock *icsk = inet_csk(sk);
+
+	tcp_mtup_init(sk);
+	icsk->icsk_af_ops->rebuild_header(sk);
+	tcp_init_metrics(sk);
+	tcp_call_bpf(sk, bpf_op);
+	tcp_init_congestion_control(sk);
+	tcp_init_buffer_space(sk);
+}
+
 static void tcp_tx_timestamp(struct sock *sk, u16 tsflags, struct sk_buff *skb)
 {
 	if (tsflags && skb) {
diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index e3c33220c418..515a757f02a8 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -216,12 +216,7 @@ static struct sock *tcp_fastopen_create_child(struct sock *sk,
 	refcount_set(&req->rsk_refcnt, 2);
 
 	/* Now finish processing the fastopen child socket. */
-	inet_csk(child)->icsk_af_ops->rebuild_header(child);
-	tcp_init_congestion_control(child);
-	tcp_mtup_init(child);
-	tcp_init_metrics(child);
-	tcp_call_bpf(child, BPF_SOCK_OPS_PASSIVE_ESTABLISHED_CB);
-	tcp_init_buffer_space(child);
+	tcp_init_transfer(child, BPF_SOCK_OPS_PASSIVE_ESTABLISHED_CB);
 
 	tp->rcv_nxt = TCP_SKB_CB(skb)->seq + 1;
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index db9bb46b5776..bd3a35f5dbf2 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5513,20 +5513,13 @@ void tcp_finish_connect(struct sock *sk, struct sk_buff *skb)
 		security_inet_conn_established(sk, skb);
 	}
 
-	/* Make sure socket is routed, for correct metrics.  */
-	icsk->icsk_af_ops->rebuild_header(sk);
-
-	tcp_init_metrics(sk);
-	tcp_call_bpf(sk, BPF_SOCK_OPS_ACTIVE_ESTABLISHED_CB);
-	tcp_init_congestion_control(sk);
+	tcp_init_transfer(sk, BPF_SOCK_OPS_ACTIVE_ESTABLISHED_CB);
 
 	/* Prevent spurious tcp_cwnd_restart() on first data
 	 * packet.
 	 */
 	tp->lsndtime = tcp_jiffies32;
 
-	tcp_init_buffer_space(sk);
-
 	if (sock_flag(sk, SOCK_KEEPOPEN))
 		inet_csk_reset_keepalive_timer(sk, keepalive_time_when(tp));
 
@@ -5693,7 +5686,6 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 		if (tcp_is_sack(tp) && sysctl_tcp_fack)
 			tcp_enable_fack(tp);
 
-		tcp_mtup_init(sk);
 		tcp_sync_mss(sk, icsk->icsk_pmtu_cookie);
 		tcp_initialize_rcv_mss(sk);
 
@@ -5920,14 +5912,8 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb)
 			inet_csk(sk)->icsk_retransmits = 0;
 			reqsk_fastopen_remove(sk, req, false);
 		} else {
-			/* Make sure socket is routed, for correct metrics. */
-			icsk->icsk_af_ops->rebuild_header(sk);
-			tcp_call_bpf(sk, BPF_SOCK_OPS_PASSIVE_ESTABLISHED_CB);
-			tcp_init_congestion_control(sk);
-
-			tcp_mtup_init(sk);
+			tcp_init_transfer(sk, BPF_SOCK_OPS_PASSIVE_ESTABLISHED_CB);
 			tp->copied_seq = tp->rcv_nxt;
-			tcp_init_buffer_space(sk);
 		}
 		smp_mb();
 		tcp_set_state(sk, TCP_ESTABLISHED);
@@ -5957,8 +5943,7 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb)
 			 * are sent out.
 			 */
 			tcp_rearm_rto(sk);
-		} else
-			tcp_init_metrics(sk);
+		}
 
 		if (!inet_csk(sk)->icsk_ca_ops->cong_control)
 			tcp_update_pacing_rate(sk);
-- 
2.14.2.920.gcf0c67979c-goog
