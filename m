From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 06/10] tcp: do not pass timestamp to tcp_rate_gen()
Date: Tue, 25 Apr 2017 10:15:37 -0700
Message-ID: <20170425171541.3417-7-edumazet@google.com>
References: <20170425171541.3417-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f48.google.com ([209.85.214.48]:38444 "EHLO
        mail-it0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1951807AbdDYRQL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 13:16:11 -0400
Received: by mail-it0-f48.google.com with SMTP id f187so18147935ite.1
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 10:16:06 -0700 (PDT)
In-Reply-To: <20170425171541.3417-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No longer needed, since tp->tcp_mstamp holds the information.

This is needed to remove sack_state.ack_time in a following patch.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Acked-by: Soheil Hassas Yeganeh <soheil@google.com>
---
 include/net/tcp.h    | 2 +-
 net/ipv4/tcp_input.c | 3 +--
 net/ipv4/tcp_rate.c  | 7 ++++---
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 8b4433c4aaa221b83af90d2b44ba4b01a872a7af..d7aae25efc7f9664a482ce50974a2d79f7fc8e0c 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1004,7 +1004,7 @@ void tcp_rate_skb_sent(struct sock *sk, struct sk_buff *skb);
 void tcp_rate_skb_delivered(struct sock *sk, struct sk_buff *skb,
 			    struct rate_sample *rs);
 void tcp_rate_gen(struct sock *sk, u32 delivered, u32 lost,
-		  struct skb_mstamp *now, struct rate_sample *rs);
+		  struct rate_sample *rs);
 void tcp_rate_check_app_limited(struct sock *sk);
 
 /* These functions determine how the current flow behaves in respect of SACK
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 68094aa8cfb2ee2dc6939ea1931277b745deae4a..2d84483de2e10ab10d4906f2cca01d76da83dc06 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3657,8 +3657,7 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 		tcp_schedule_loss_probe(sk);
 	delivered = tp->delivered - delivered;	/* freshly ACKed or SACKed */
 	lost = tp->lost - lost;			/* freshly marked lost */
-	tcp_rate_gen(sk, delivered, lost, &sack_state.ack_time,
-		     sack_state.rate);
+	tcp_rate_gen(sk, delivered, lost, sack_state.rate);
 	tcp_cong_control(sk, ack, delivered, flag, sack_state.rate);
 	tcp_xmit_recovery(sk, rexmit);
 	return 1;
diff --git a/net/ipv4/tcp_rate.c b/net/ipv4/tcp_rate.c
index 9be1581a5a08c36f4544fbdabedd9741fb266a1e..c6a9fa8946462100947ab62d86464ff8f99565c2 100644
--- a/net/ipv4/tcp_rate.c
+++ b/net/ipv4/tcp_rate.c
@@ -106,7 +106,7 @@ void tcp_rate_skb_delivered(struct sock *sk, struct sk_buff *skb,
 
 /* Update the connection delivery information and generate a rate sample. */
 void tcp_rate_gen(struct sock *sk, u32 delivered, u32 lost,
-		  struct skb_mstamp *now, struct rate_sample *rs)
+		  struct rate_sample *rs)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	u32 snd_us, ack_us;
@@ -120,7 +120,7 @@ void tcp_rate_gen(struct sock *sk, u32 delivered, u32 lost,
 	 * to carry current time, flags, stats like "tcp_sacktag_state".
 	 */
 	if (delivered)
-		tp->delivered_mstamp = *now;
+		tp->delivered_mstamp = tp->tcp_mstamp;
 
 	rs->acked_sacked = delivered;	/* freshly ACKed or SACKed */
 	rs->losses = lost;		/* freshly marked lost */
@@ -138,7 +138,8 @@ void tcp_rate_gen(struct sock *sk, u32 delivered, u32 lost,
 	 * longer phase.
 	 */
 	snd_us = rs->interval_us;				/* send phase */
-	ack_us = skb_mstamp_us_delta(now, &rs->prior_mstamp);	/* ack phase */
+	ack_us = skb_mstamp_us_delta(&tp->tcp_mstamp,
+				     &rs->prior_mstamp); /* ack phase */
 	rs->interval_us = max(snd_us, ack_us);
 
 	/* Normally we expect interval_us >= min-rtt.
-- 
2.13.0.rc0.306.g87b477812d-goog
