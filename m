From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 14/15] tcp: replace misc tcp_time_stamp to tcp_jiffies32
Date: Tue, 16 May 2017 14:00:13 -0700
Message-ID: <20170516210014.31176-15-edumazet@google.com>
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
Received: from mail-pf0-f178.google.com ([209.85.192.178]:33029 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753045AbdEPV2k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 17:28:40 -0400
Received: by mail-pf0-f178.google.com with SMTP id e193so86504203pfh.0
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 14:28:39 -0700 (PDT)
In-Reply-To: <20170516210014.31176-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After this patch, all uses of tcp_time_stamp will require
a change when we introduce 1 ms and/or 1 us TCP TS option.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp.c           | 2 +-
 net/ipv4/tcp_htcp.c      | 2 +-
 net/ipv4/tcp_input.c     | 2 +-
 net/ipv4/tcp_minisocks.c | 2 +-
 net/ipv4/tcp_output.c    | 4 ++--
 5 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index b85bfe7cb11dca68952cc4be19b169d893963fef..85005480052626c5769ef100a868c88fad803f75 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -386,7 +386,7 @@ void tcp_init_sock(struct sock *sk)
 
 	icsk->icsk_rto = TCP_TIMEOUT_INIT;
 	tp->mdev_us = jiffies_to_usecs(TCP_TIMEOUT_INIT);
-	minmax_reset(&tp->rtt_min, tcp_time_stamp, ~0U);
+	minmax_reset(&tp->rtt_min, tcp_jiffies32, ~0U);
 
 	/* So many TCP implementations out there (incorrectly) count the
 	 * initial SYN frame in their delayed-ACK and congestion control
diff --git a/net/ipv4/tcp_htcp.c b/net/ipv4/tcp_htcp.c
index 4a4d8e76738fa2831dcc3ecec5924dd3dfb7bf58..3eb78cde6ff0a22b7b411f0ae4258b6ef74ffe73 100644
--- a/net/ipv4/tcp_htcp.c
+++ b/net/ipv4/tcp_htcp.c
@@ -104,7 +104,7 @@ static void measure_achieved_throughput(struct sock *sk,
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	const struct tcp_sock *tp = tcp_sk(sk);
 	struct htcp *ca = inet_csk_ca(sk);
-	u32 now = tcp_time_stamp;
+	u32 now = tcp_jiffies32;
 
 	if (icsk->icsk_ca_state == TCP_CA_Open)
 		ca->pkts_acked = sample->pkts_acked;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 85575888365a10643e096f9e019adaa3eda87d40..10e6775464f647a65ea0d19c10b421f9cd38923d 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2911,7 +2911,7 @@ static void tcp_update_rtt_min(struct sock *sk, u32 rtt_us)
 	struct tcp_sock *tp = tcp_sk(sk);
 	u32 wlen = sysctl_tcp_min_rtt_wlen * HZ;
 
-	minmax_running_min(&tp->rtt_min, wlen, tcp_time_stamp,
+	minmax_running_min(&tp->rtt_min, wlen, tcp_jiffies32,
 			   rtt_us ? : jiffies_to_usecs(1));
 }
 
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 59c32e0086c0e46d7955dffe211ec03bb18dcb12..6504f1082bdfda77bfc1b53d0d85928e5083a24e 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -445,7 +445,7 @@ struct sock *tcp_create_openreq_child(const struct sock *sk,
 
 		newtp->srtt_us = 0;
 		newtp->mdev_us = jiffies_to_usecs(TCP_TIMEOUT_INIT);
-		minmax_reset(&newtp->rtt_min, tcp_time_stamp, ~0U);
+		minmax_reset(&newtp->rtt_min, tcp_jiffies32, ~0U);
 		newicsk->icsk_rto = TCP_TIMEOUT_INIT;
 		newicsk->icsk_ack.lrcvtime = tcp_jiffies32;
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 1011ea40c2ba4c12cce21149cab176e1fa4db583..65472e931a0b79f7078a4da7db802dfcc32c7621 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2418,10 +2418,10 @@ bool tcp_schedule_loss_probe(struct sock *sk)
 	timeout = max_t(u32, timeout, msecs_to_jiffies(10));
 
 	/* If RTO is shorter, just schedule TLP in its place. */
-	tlp_time_stamp = tcp_time_stamp + timeout;
+	tlp_time_stamp = tcp_jiffies32 + timeout;
 	rto_time_stamp = (u32)inet_csk(sk)->icsk_timeout;
 	if ((s32)(tlp_time_stamp - rto_time_stamp) > 0) {
-		s32 delta = rto_time_stamp - tcp_time_stamp;
+		s32 delta = rto_time_stamp - tcp_jiffies32;
 		if (delta > 0)
 			timeout = delta;
 	}
-- 
2.13.0.303.g4ebf302169-goog
