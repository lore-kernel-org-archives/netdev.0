From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 02/10] tcp: do not pass timestamp to tcp_rack_detect_loss()
Date: Tue, 25 Apr 2017 10:15:33 -0700
Message-ID: <20170425171541.3417-3-edumazet@google.com>
References: <20170425171541.3417-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:34701 "EHLO
        mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1951798AbdDYRQG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 13:16:06 -0400
Received: by mail-io0-f171.google.com with SMTP id a103so219100043ioj.1
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 10:16:06 -0700 (PDT)
In-Reply-To: <20170425171541.3417-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can use tp->tcp_mstamp as it contains a recent timestamp.

This removes a call to skb_mstamp_get() from tcp_rack_reo_timeout()

Signed-off-by: Eric Dumazet <edumazet@google.com>
Acked-by: Soheil Hassas Yeganeh <soheil@google.com>
---
 net/ipv4/tcp_recovery.c | 11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/tcp_recovery.c b/net/ipv4/tcp_recovery.c
index d8acbd9f477a2ac6b0f8eee1bf59f3ab43abff07..fdac262e277b2f25492f155bbb295d6d87e31d02 100644
--- a/net/ipv4/tcp_recovery.c
+++ b/net/ipv4/tcp_recovery.c
@@ -45,8 +45,7 @@ static bool tcp_rack_sent_after(const struct skb_mstamp *t1,
  * or tcp_time_to_recover()'s "Trick#1: the loss is proven" code path will
  * make us enter the CA_Recovery state.
  */
-static void tcp_rack_detect_loss(struct sock *sk, const struct skb_mstamp *now,
-				 u32 *reo_timeout)
+static void tcp_rack_detect_loss(struct sock *sk, u32 *reo_timeout)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
@@ -79,7 +78,7 @@ static void tcp_rack_detect_loss(struct sock *sk, const struct skb_mstamp *now,
 			 * A packet is lost if its elapsed time is beyond
 			 * the recent RTT plus the reordering window.
 			 */
-			u32 elapsed = skb_mstamp_us_delta(now,
+			u32 elapsed = skb_mstamp_us_delta(&tp->tcp_mstamp,
 							  &skb->skb_mstamp);
 			s32 remaining = tp->rack.rtt_us + reo_wnd - elapsed;
 
@@ -115,7 +114,7 @@ void tcp_rack_mark_lost(struct sock *sk, const struct skb_mstamp *now)
 
 	/* Reset the advanced flag to avoid unnecessary queue scanning */
 	tp->rack.advanced = 0;
-	tcp_rack_detect_loss(sk, now, &timeout);
+	tcp_rack_detect_loss(sk, &timeout);
 	if (timeout) {
 		timeout = usecs_to_jiffies(timeout + TCP_REO_TIMEOUT_MIN);
 		inet_csk_reset_xmit_timer(sk, ICSK_TIME_REO_TIMEOUT,
@@ -165,12 +164,10 @@ void tcp_rack_advance(struct tcp_sock *tp, u8 sacked, u32 end_seq,
 void tcp_rack_reo_timeout(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct skb_mstamp now;
 	u32 timeout, prior_inflight;
 
-	skb_mstamp_get(&now);
 	prior_inflight = tcp_packets_in_flight(tp);
-	tcp_rack_detect_loss(sk, &now, &timeout);
+	tcp_rack_detect_loss(sk, &timeout);
 	if (prior_inflight != tcp_packets_in_flight(tp)) {
 		if (inet_csk(sk)->icsk_ca_state != TCP_CA_Recovery) {
 			tcp_enter_recovery(sk, false);
-- 
2.13.0.rc0.306.g87b477812d-goog
