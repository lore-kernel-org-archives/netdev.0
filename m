From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 1/2] tcp: shortcut listeners in tcp_get_info()
Date: Fri,  4 Nov 2016 11:54:31 -0700
Message-ID: <1478285672-3195-2-git-send-email-edumazet@google.com>
References: <1478285672-3195-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:35293 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934998AbcKDSyn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 14:54:43 -0400
Received: by mail-pf0-f176.google.com with SMTP id i88so55837931pfk.2
        for <netdev@vger.kernel.org>; Fri, 04 Nov 2016 11:54:43 -0700 (PDT)
In-Reply-To: <1478285672-3195-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Being lockless in tcp_get_info() is hard, because we need to add
specific synchronization in TCP fast path, like seqcount.

Following patch will change inet_diag_dump_icsk() to no longer
hold any lock for non listeners, so that we can properly acquire
socket lock in get_tcp_info() and let it return more consistent counters.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Acked-by: Soheil Hassas Yeganeh <soheil@google.com>
Acked-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp.c | 41 ++++++++++++++++++++++++-----------------
 1 file changed, 24 insertions(+), 17 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 3251fe71f39f..117982be0cab 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2721,6 +2721,27 @@ void tcp_get_info(struct sock *sk, struct tcp_info *info)
 
 	info->tcpi_state = sk_state_load(sk);
 
+	/* Report meaningful fields for all TCP states, including listeners */
+	rate = READ_ONCE(sk->sk_pacing_rate);
+	rate64 = rate != ~0U ? rate : ~0ULL;
+	put_unaligned(rate64, &info->tcpi_pacing_rate);
+
+	rate = READ_ONCE(sk->sk_max_pacing_rate);
+	rate64 = rate != ~0U ? rate : ~0ULL;
+	put_unaligned(rate64, &info->tcpi_max_pacing_rate);
+
+	info->tcpi_reordering = tp->reordering;
+	info->tcpi_snd_cwnd = tp->snd_cwnd;
+
+	if (info->tcpi_state == TCP_LISTEN) {
+		/* listeners aliased fields :
+		 * tcpi_unacked -> Number of children ready for accept()
+		 * tcpi_sacked  -> max backlog
+		 */
+		info->tcpi_unacked = sk->sk_ack_backlog;
+		info->tcpi_sacked = sk->sk_max_ack_backlog;
+		return;
+	}
 	info->tcpi_ca_state = icsk->icsk_ca_state;
 	info->tcpi_retransmits = icsk->icsk_retransmits;
 	info->tcpi_probes = icsk->icsk_probes_out;
@@ -2748,13 +2769,9 @@ void tcp_get_info(struct sock *sk, struct tcp_info *info)
 	info->tcpi_snd_mss = tp->mss_cache;
 	info->tcpi_rcv_mss = icsk->icsk_ack.rcv_mss;
 
-	if (info->tcpi_state == TCP_LISTEN) {
-		info->tcpi_unacked = sk->sk_ack_backlog;
-		info->tcpi_sacked = sk->sk_max_ack_backlog;
-	} else {
-		info->tcpi_unacked = tp->packets_out;
-		info->tcpi_sacked = tp->sacked_out;
-	}
+	info->tcpi_unacked = tp->packets_out;
+	info->tcpi_sacked = tp->sacked_out;
+
 	info->tcpi_lost = tp->lost_out;
 	info->tcpi_retrans = tp->retrans_out;
 	info->tcpi_fackets = tp->fackets_out;
@@ -2768,23 +2785,13 @@ void tcp_get_info(struct sock *sk, struct tcp_info *info)
 	info->tcpi_rtt = tp->srtt_us >> 3;
 	info->tcpi_rttvar = tp->mdev_us >> 2;
 	info->tcpi_snd_ssthresh = tp->snd_ssthresh;
-	info->tcpi_snd_cwnd = tp->snd_cwnd;
 	info->tcpi_advmss = tp->advmss;
-	info->tcpi_reordering = tp->reordering;
 
 	info->tcpi_rcv_rtt = jiffies_to_usecs(tp->rcv_rtt_est.rtt)>>3;
 	info->tcpi_rcv_space = tp->rcvq_space.space;
 
 	info->tcpi_total_retrans = tp->total_retrans;
 
-	rate = READ_ONCE(sk->sk_pacing_rate);
-	rate64 = rate != ~0U ? rate : ~0ULL;
-	put_unaligned(rate64, &info->tcpi_pacing_rate);
-
-	rate = READ_ONCE(sk->sk_max_pacing_rate);
-	rate64 = rate != ~0U ? rate : ~0ULL;
-	put_unaligned(rate64, &info->tcpi_max_pacing_rate);
-
 	do {
 		start = u64_stats_fetch_begin_irq(&tp->syncp);
 		put_unaligned(tp->bytes_acked, &info->tcpi_bytes_acked);
-- 
2.8.0.rc3.226.g39d4020
