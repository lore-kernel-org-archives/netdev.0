From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 01/10] tcp: add tp->tcp_mstamp field
Date: Tue, 25 Apr 2017 10:15:32 -0700
Message-ID: <20170425171541.3417-2-edumazet@google.com>
References: <20170425171541.3417-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f52.google.com ([209.85.214.52]:37181 "EHLO
        mail-it0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1951784AbdDYRPx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 13:15:53 -0400
Received: by mail-it0-f52.google.com with SMTP id x188so80275129itb.0
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 10:15:53 -0700 (PDT)
In-Reply-To: <20170425171541.3417-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We want to use precise timestamps in TCP stack, but we do not
want to call possibly expensive kernel time services too often.

tp->tcp_mstamp is guaranteed to be updated once per incoming packet.

We will use it in the following patches, removing specific
skb_mstamp_get() calls, and removing ack_time from
struct tcp_sacktag_state.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/tcp.h  | 1 +
 net/ipv4/tcp_input.c | 3 +++
 2 files changed, 4 insertions(+)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index cbe5b602a2d349fdeb1e878305f37b4da1e6cc86..99a22f44c32e1587a6bf4835b65c7a4314807aa8 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -240,6 +240,7 @@ struct tcp_sock {
 	u32	tlp_high_seq;	/* snd_nxt at the time of TLP retransmit. */
 
 /* RTT measurement */
+	struct skb_mstamp tcp_mstamp; /* most recent packet received/sent */
 	u32	srtt_us;	/* smoothed round trip time << 3 in usecs */
 	u32	mdev_us;	/* medium deviation			*/
 	u32	mdev_max_us;	/* maximal mdev for the last rtt period	*/
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 5af2f04f885914491a7116c20056b3d2188d2d7d..bd18c65df4a9d9c2b66d8005f2cc4ff468140a73 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5362,6 +5362,7 @@ void tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
+	skb_mstamp_get(&tp->tcp_mstamp);
 	if (unlikely(!sk->sk_rx_dst))
 		inet_csk(sk)->icsk_af_ops->sk_rx_dst_set(sk, skb);
 	/*
@@ -5922,6 +5923,7 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb)
 
 	case TCP_SYN_SENT:
 		tp->rx_opt.saw_tstamp = 0;
+		skb_mstamp_get(&tp->tcp_mstamp);
 		queued = tcp_rcv_synsent_state_process(sk, skb, th);
 		if (queued >= 0)
 			return queued;
@@ -5933,6 +5935,7 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb)
 		return 0;
 	}
 
+	skb_mstamp_get(&tp->tcp_mstamp);
 	tp->rx_opt.saw_tstamp = 0;
 	req = tp->fastopen_rsk;
 	if (req) {
-- 
2.13.0.rc0.306.g87b477812d-goog
