From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: make TCP_INFO more consistent
Date: Mon, 09 Jan 2017 10:29:27 -0800
Message-ID: <1483986567.21472.10.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35715 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S939559AbdAIS3a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 13:29:30 -0500
Received: by mail-pf0-f193.google.com with SMTP id f144so6090248pfa.2
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 10:29:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

tcp_get_info() has to lock the socket, so lets lock it
for an extended critical section, so that various fields
have consistent values.

This solves an annoying issue that some applications
reported when multiple counters are updated during one
particular rx/rx event, and TCP_INFO was called from
another cpu.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index ec97e4b4a62f44decdcb559991500a737c7d6379..c8d46c140b4a47ee7c954317977393664e295abf 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2766,6 +2766,9 @@ void tcp_get_info(struct sock *sk, struct tcp_info *info)
 		info->tcpi_sacked = sk->sk_max_ack_backlog;
 		return;
 	}
+
+	slow = lock_sock_fast(sk);
+
 	info->tcpi_ca_state = icsk->icsk_ca_state;
 	info->tcpi_retransmits = icsk->icsk_retransmits;
 	info->tcpi_probes = icsk->icsk_probes_out;
@@ -2816,15 +2819,11 @@ void tcp_get_info(struct sock *sk, struct tcp_info *info)
 
 	info->tcpi_total_retrans = tp->total_retrans;
 
-	slow = lock_sock_fast(sk);
-
 	info->tcpi_bytes_acked = tp->bytes_acked;
 	info->tcpi_bytes_received = tp->bytes_received;
 	info->tcpi_notsent_bytes = max_t(int, 0, tp->write_seq - tp->snd_nxt);
 	tcp_get_info_chrono_stats(tp, info);
 
-	unlock_sock_fast(sk, slow);
-
 	info->tcpi_segs_out = tp->segs_out;
 	info->tcpi_segs_in = tp->segs_in;
 
@@ -2840,6 +2839,7 @@ void tcp_get_info(struct sock *sk, struct tcp_info *info)
 		do_div(rate64, intv);
 		info->tcpi_delivery_rate = rate64;
 	}
+	unlock_sock_fast(sk, slow);
 }
 EXPORT_SYMBOL_GPL(tcp_get_info);
 
