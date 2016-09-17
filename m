From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH v2 net-next 09/16] tcp: export data delivery rate
Date: Sat, 17 Sep 2016 13:35:42 -0400
Message-ID: <1474133749-12895-10-git-send-email-ncardwell@google.com>
References: <1474133749-12895-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
        Van Jacobson <vanj@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Nandita Dukkipati <nanditad@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f182.google.com ([209.85.216.182]:36838 "EHLO
        mail-qt0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754226AbcIQRg0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2016 13:36:26 -0400
Received: by mail-qt0-f182.google.com with SMTP id l91so55917077qte.3
        for <netdev@vger.kernel.org>; Sat, 17 Sep 2016 10:36:26 -0700 (PDT)
In-Reply-To: <1474133749-12895-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>

This commit export two new fields in struct tcp_info:

  tcpi_delivery_rate: The most recent goodput, as measured by
    tcp_rate_gen(). If the socket is limited by the sending
    application (e.g., no data to send), it reports the highest
    measurement instead of the most recent. The unit is bytes per
    second (like other rate fields in tcp_info).

  tcpi_delivery_rate_app_limited: A boolean indicating if the goodput
    was measured when the socket's throughput was limited by the
    sending application.

This delivery rate information can be useful for applications that
want to know the current throughput the TCP connection is seeing,
e.g. adaptive bitrate video streaming. It can also be very useful for
debugging or troubleshooting.

Signed-off-by: Van Jacobson <vanj@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Nandita Dukkipati <nanditad@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
---
 include/linux/tcp.h      |  5 ++++-
 include/uapi/linux/tcp.h |  3 +++
 net/ipv4/tcp.c           | 11 ++++++++++-
 net/ipv4/tcp_rate.c      | 12 +++++++++++-
 4 files changed, 28 insertions(+), 3 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index fdcd00f..a17ae7b 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -213,7 +213,8 @@ struct tcp_sock {
 		u8 reord;    /* reordering detected */
 	} rack;
 	u16	advmss;		/* Advertised MSS			*/
-	u8	unused;
+	u8	rate_app_limited:1,  /* rate_{delivered,interval_us} limited? */
+		unused:7;
 	u8	nonagle     : 4,/* Disable Nagle algorithm?             */
 		thin_lto    : 1,/* Use linear timeouts for thin streams */
 		thin_dupack : 1,/* Fast retransmit on first dupack      */
@@ -271,6 +272,8 @@ struct tcp_sock {
 	u32	app_limited;	/* limited until "delivered" reaches this val */
 	struct skb_mstamp first_tx_mstamp;  /* start of window send phase */
 	struct skb_mstamp delivered_mstamp; /* time we reached "delivered" */
+	u32	rate_delivered;    /* saved rate sample: packets delivered */
+	u32	rate_interval_us;  /* saved rate sample: time elapsed */
 
  	u32	rcv_wnd;	/* Current receiver window		*/
 	u32	write_seq;	/* Tail(+1) of data held in tcp send buffer */
diff --git a/include/uapi/linux/tcp.h b/include/uapi/linux/tcp.h
index 482898f..73ac0db 100644
--- a/include/uapi/linux/tcp.h
+++ b/include/uapi/linux/tcp.h
@@ -167,6 +167,7 @@ struct tcp_info {
 	__u8	tcpi_backoff;
 	__u8	tcpi_options;
 	__u8	tcpi_snd_wscale : 4, tcpi_rcv_wscale : 4;
+	__u8	tcpi_delivery_rate_app_limited:1;
 
 	__u32	tcpi_rto;
 	__u32	tcpi_ato;
@@ -211,6 +212,8 @@ struct tcp_info {
 	__u32	tcpi_min_rtt;
 	__u32	tcpi_data_segs_in;	/* RFC4898 tcpEStatsDataSegsIn */
 	__u32	tcpi_data_segs_out;	/* RFC4898 tcpEStatsDataSegsOut */
+
+	__u64   tcpi_delivery_rate;
 };
 
 /* for TCP_MD5SIG socket option */
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 0327a44..46b05b2 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2695,7 +2695,7 @@ void tcp_get_info(struct sock *sk, struct tcp_info *info)
 {
 	const struct tcp_sock *tp = tcp_sk(sk); /* iff sk_type == SOCK_STREAM */
 	const struct inet_connection_sock *icsk = inet_csk(sk);
-	u32 now = tcp_time_stamp;
+	u32 now = tcp_time_stamp, intv;
 	unsigned int start;
 	int notsent_bytes;
 	u64 rate64;
@@ -2785,6 +2785,15 @@ void tcp_get_info(struct sock *sk, struct tcp_info *info)
 	info->tcpi_min_rtt = tcp_min_rtt(tp);
 	info->tcpi_data_segs_in = tp->data_segs_in;
 	info->tcpi_data_segs_out = tp->data_segs_out;
+
+	info->tcpi_delivery_rate_app_limited = tp->rate_app_limited ? 1 : 0;
+	rate = READ_ONCE(tp->rate_delivered);
+	intv = READ_ONCE(tp->rate_interval_us);
+	if (rate && intv) {
+		rate64 = (u64)rate * tp->mss_cache * USEC_PER_SEC;
+		do_div(rate64, intv);
+		put_unaligned(rate64, &info->tcpi_delivery_rate);
+	}
 }
 EXPORT_SYMBOL_GPL(tcp_get_info);
 
diff --git a/net/ipv4/tcp_rate.c b/net/ipv4/tcp_rate.c
index 52ff84b..9be1581 100644
--- a/net/ipv4/tcp_rate.c
+++ b/net/ipv4/tcp_rate.c
@@ -149,12 +149,22 @@ void tcp_rate_gen(struct sock *sk, u32 delivered, u32 lost,
 	 * for connections suffer heavy or prolonged losses.
 	 */
 	if (unlikely(rs->interval_us < tcp_min_rtt(tp))) {
-		rs->interval_us = -1;
 		if (!rs->is_retrans)
 			pr_debug("tcp rate: %ld %d %u %u %u\n",
 				 rs->interval_us, rs->delivered,
 				 inet_csk(sk)->icsk_ca_state,
 				 tp->rx_opt.sack_ok, tcp_min_rtt(tp));
+		rs->interval_us = -1;
+		return;
+	}
+
+	/* Record the last non-app-limited or the highest app-limited bw */
+	if (!rs->is_app_limited ||
+	    ((u64)rs->delivered * tp->rate_interval_us >=
+	     (u64)tp->rate_delivered * rs->interval_us)) {
+		tp->rate_delivered = rs->delivered;
+		tp->rate_interval_us = rs->interval_us;
+		tp->rate_app_limited = rs->is_app_limited;
 	}
 }
 
-- 
2.8.0.rc3.226.g39d4020
