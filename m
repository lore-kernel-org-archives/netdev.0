From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 07/10] tcp: do not pass timestamp to tcp_rack_advance()
Date: Tue, 25 Apr 2017 10:15:38 -0700
Message-ID: <20170425171541.3417-8-edumazet@google.com>
References: <20170425171541.3417-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f51.google.com ([209.85.214.51]:38463 "EHLO
        mail-it0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1951800AbdDYRQI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 13:16:08 -0400
Received: by mail-it0-f51.google.com with SMTP id f187so18148787ite.1
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 10:16:08 -0700 (PDT)
In-Reply-To: <20170425171541.3417-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No longer needed, since tp->tcp_mstamp holds the information.

This is needed to remove sack_state.ack_time in a following patch.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Acked-by: Soheil Hassas Yeganeh <soheil@google.com>
---
 include/net/tcp.h       | 3 +--
 net/ipv4/tcp_input.c    | 6 ++----
 net/ipv4/tcp_recovery.c | 5 ++---
 3 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index d7aae25efc7f9664a482ce50974a2d79f7fc8e0c..270e5cc43c99e7030e95af218095cf9f283950bc 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1855,8 +1855,7 @@ void tcp_init(void);
 /* tcp_recovery.c */
 extern void tcp_rack_mark_lost(struct sock *sk);
 extern void tcp_rack_advance(struct tcp_sock *tp, u8 sacked, u32 end_seq,
-			     const struct skb_mstamp *xmit_time,
-			     const struct skb_mstamp *ack_time);
+			     const struct skb_mstamp *xmit_time);
 extern void tcp_rack_reo_timeout(struct sock *sk);
 
 /*
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 2d84483de2e10ab10d4906f2cca01d76da83dc06..5485204853d3aefaea5027bcf6480ed20a1e8efa 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1214,8 +1214,7 @@ static u8 tcp_sacktag_one(struct sock *sk,
 		return sacked;
 
 	if (!(sacked & TCPCB_SACKED_ACKED)) {
-		tcp_rack_advance(tp, sacked, end_seq,
-				 xmit_time, &state->ack_time);
+		tcp_rack_advance(tp, sacked, end_seq, xmit_time);
 
 		if (sacked & TCPCB_SACKED_RETRANS) {
 			/* If the segment is not tagged as lost,
@@ -3118,8 +3117,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 			tp->delivered += acked_pcount;
 			if (!tcp_skb_spurious_retrans(tp, skb))
 				tcp_rack_advance(tp, sacked, scb->end_seq,
-						 &skb->skb_mstamp,
-						 &sack->ack_time);
+						 &skb->skb_mstamp);
 		}
 		if (sacked & TCPCB_LOST)
 			tp->lost_out -= acked_pcount;
diff --git a/net/ipv4/tcp_recovery.c b/net/ipv4/tcp_recovery.c
index 6ca8b5d9d803d872ec7043b02c72fffaec5c7270..cd72b3d3879e88181c8a4639f0334a24e4cda852 100644
--- a/net/ipv4/tcp_recovery.c
+++ b/net/ipv4/tcp_recovery.c
@@ -127,8 +127,7 @@ void tcp_rack_mark_lost(struct sock *sk)
  * draft-cheng-tcpm-rack-00.txt
  */
 void tcp_rack_advance(struct tcp_sock *tp, u8 sacked, u32 end_seq,
-		      const struct skb_mstamp *xmit_time,
-		      const struct skb_mstamp *ack_time)
+		      const struct skb_mstamp *xmit_time)
 {
 	u32 rtt_us;
 
@@ -137,7 +136,7 @@ void tcp_rack_advance(struct tcp_sock *tp, u8 sacked, u32 end_seq,
 				 end_seq, tp->rack.end_seq))
 		return;
 
-	rtt_us = skb_mstamp_us_delta(ack_time, xmit_time);
+	rtt_us = skb_mstamp_us_delta(&tp->tcp_mstamp, xmit_time);
 	if (sacked & TCPCB_RETRANS) {
 		/* If the sacked packet was retransmitted, it's ambiguous
 		 * whether the retransmission or the original (or the prior
-- 
2.13.0.rc0.306.g87b477812d-goog
