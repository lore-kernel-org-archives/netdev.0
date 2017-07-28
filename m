From: Wei Wang <weiwan@google.com>
Subject: [PATCH net-next 2/2] tcp: add related fields into SCM_TIMESTAMPING_OPT_STATS
Date: Fri, 28 Jul 2017 10:28:21 -0700
Message-ID: <20170728172821.102562-2-tracywwnj@gmail.com>
References: <20170728172821.102562-1-tracywwnj@gmail.com>
Cc: Yuchung Cheng <ycheng@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:32774 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752292AbdG1R3u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 13:29:50 -0400
Received: by mail-pf0-f178.google.com with SMTP id d67so30335607pfc.0
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 10:29:50 -0700 (PDT)
In-Reply-To: <20170728172821.102562-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

Add the following stats into SCM_TIMESTAMPING_OPT_STATS control msg:
    TCP_NLA_PACING_RATE
    TCP_NLA_DELIVERY_RATE
    TCP_NLA_SND_CWND
    TCP_NLA_REORDERING
    TCP_NLA_MIN_RTT
    TCP_NLA_RECUR_RETRANS
    TCP_NLA_DELIVERY_RATE_APP_LMT

Signed-off-by: Wei Wang <weiwan@google.com>
Acked-by: Yuchung Cheng <ycheng@google.com>
Acked-by: Soheil Hassas Yeganeh <soheil@google.com>
---
 include/uapi/linux/tcp.h |  8 ++++++++
 net/ipv4/tcp.c           | 20 +++++++++++++++++++-
 2 files changed, 27 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/tcp.h b/include/uapi/linux/tcp.h
index a5507c977497..030e594bab45 100644
--- a/include/uapi/linux/tcp.h
+++ b/include/uapi/linux/tcp.h
@@ -231,6 +231,14 @@ enum {
 	TCP_NLA_SNDBUF_LIMITED,	/* Time (usec) limited by send buffer */
 	TCP_NLA_DATA_SEGS_OUT,	/* Data pkts sent including retransmission */
 	TCP_NLA_TOTAL_RETRANS,	/* Data pkts retransmitted */
+	TCP_NLA_PACING_RATE,    /* Pacing rate in bytes per second */
+	TCP_NLA_DELIVERY_RATE,  /* Delivery rate in bytes per second */
+	TCP_NLA_SND_CWND,       /* Sending congestion window */
+	TCP_NLA_REORDERING,     /* Reordering metric */
+	TCP_NLA_MIN_RTT,        /* minimum RTT */
+	TCP_NLA_RECUR_RETRANS,  /* Recurring retransmits for the current pkt */
+	TCP_NLA_DELIVERY_RATE_APP_LMT, /* delivery rate application limited ? */
+
 };
 
 /* for TCP_MD5SIG socket option */
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 65d210d0394c..be78662faa1a 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2947,8 +2947,12 @@ struct sk_buff *tcp_get_timestamping_opt_stats(const struct sock *sk)
 	const struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *stats;
 	struct tcp_info info;
+	u64 rate64;
+	u32 rate;
 
-	stats = alloc_skb(5 * nla_total_size_64bit(sizeof(u64)), GFP_ATOMIC);
+	stats = alloc_skb(7 * nla_total_size_64bit(sizeof(u64)) +
+			  3 * nla_total_size(sizeof(u32)) +
+			  2 * nla_total_size(sizeof(u8)), GFP_ATOMIC);
 	if (!stats)
 		return NULL;
 
@@ -2963,6 +2967,20 @@ struct sk_buff *tcp_get_timestamping_opt_stats(const struct sock *sk)
 			  tp->data_segs_out, TCP_NLA_PAD);
 	nla_put_u64_64bit(stats, TCP_NLA_TOTAL_RETRANS,
 			  tp->total_retrans, TCP_NLA_PAD);
+
+	rate = READ_ONCE(sk->sk_pacing_rate);
+	rate64 = rate != ~0U ? rate : ~0ULL;
+	nla_put_u64_64bit(stats, TCP_NLA_PACING_RATE, rate64, TCP_NLA_PAD);
+
+	rate64 = tcp_compute_delivery_rate(tp);
+	nla_put_u64_64bit(stats, TCP_NLA_DELIVERY_RATE, rate64, TCP_NLA_PAD);
+
+	nla_put_u32(stats, TCP_NLA_SND_CWND, tp->snd_cwnd);
+	nla_put_u32(stats, TCP_NLA_REORDERING, tp->reordering);
+	nla_put_u32(stats, TCP_NLA_MIN_RTT, tcp_min_rtt(tp));
+
+	nla_put_u8(stats, TCP_NLA_RECUR_RETRANS, inet_csk(sk)->icsk_retransmits);
+	nla_put_u8(stats, TCP_NLA_DELIVERY_RATE_APP_LMT, !!tp->rate_app_limited);
 	return stats;
 }
 
-- 
2.14.0.rc0.400.g1c36432dff-goog
