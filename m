From: Natale Patriciello <natale.patriciello@gmail.com>
Subject: [RFC PATCH v1 2/5] tcp: Implemented the timing-based operations
Date: Fri, 28 Jul 2017 21:59:16 +0200
Message-ID: <20170728195919.10099-3-natale.patriciello@gmail.com>
References: <20170728195919.10099-1-natale.patriciello@gmail.com>
Cc: netdev <netdev@vger.kernel.org>,
        Ahmed Said <ahmed.said@uniroma2.it>,
        Natale Patriciello <natale.patriciello@gmail.com>,
        Francesco Zampognaro <zampognaro@ing.uniroma2.it>,
        Cesare Roseti <roseti@ing.uniroma2.it>
To: "David S . Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:32850 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752836AbdG1UAx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 16:00:53 -0400
Received: by mail-wr0-f194.google.com with SMTP id y43so27202772wrd.0
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 13:00:53 -0700 (PDT)
In-Reply-To: <20170728195919.10099-1-natale.patriciello@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timing the TCP operation based on the timer returned by the congestion control.
If the congestion control does not implement the timing interface, the TCP
behaves as usual, by sending down segments as soon as it is possible. Otherwise,
it will wait until the timer expires (and so respecting the timing constraint
set by the congestion control).

Signed-off-by: Natale Patriciello <natale.patriciello@gmail.com>
Tested-by: Ahmed Said <ahmed.said@uniroma2.it>
---
 include/linux/tcp.h   |  3 +++
 net/ipv4/tcp_ipv4.c   |  2 ++
 net/ipv4/tcp_output.c | 56 ++++++++++++++++++++++++++++++++++++++++++++++++---
 3 files changed, 58 insertions(+), 3 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index b6d5adcee8fc..140bc20ec17e 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -369,6 +369,9 @@ struct tcp_sock {
 	 */
 	struct request_sock *fastopen_rsk;
 	u32	*saved_syn;
+
+/* TCP send timer */
+	struct timer_list send_timer;
 };
 
 enum tsq_enum {
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 5ab2aac5ca19..ef5fdba096e8 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1351,6 +1351,8 @@ struct sock *tcp_v4_syn_recv_sock(const struct sock *sk, struct sk_buff *skb,
 	if (*own_req)
 		tcp_move_syn(newtp, req);
 
+	init_timer(&newtp->send_timer);
+
 	return newsk;
 
 exit_overflow:
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 4858e190f6ac..357b9cd5019e 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2187,6 +2187,7 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 			   int push_one, gfp_t gfp)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
+	const struct tcp_congestion_ops *ca_ops;
 	struct sk_buff *skb;
 	unsigned int tso_segs, sent_pkts;
 	int cwnd_quota;
@@ -2194,6 +2195,7 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 	bool is_cwnd_limited = false, is_rwnd_limited = false;
 	u32 max_segs;
 
+	ca_ops = inet_csk(sk)->icsk_ca_ops;
 	sent_pkts = 0;
 
 	if (!push_one) {
@@ -2292,8 +2294,16 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 			tcp_schedule_loss_probe(sk);
 		is_cwnd_limited |= (tcp_packets_in_flight(tp) >= tp->snd_cwnd);
 		tcp_cwnd_validate(sk, is_cwnd_limited);
+
+		/* Duplicated because of tp->prr_out value */
+		if (ca_ops && ca_ops->segment_sent)
+			ca_ops->segment_sent(sk, sent_pkts);
 		return false;
 	}
+
+	if (ca_ops && ca_ops->segment_sent)
+		ca_ops->segment_sent(sk, 0);
+
 	return !tp->packets_out && tcp_send_head(sk);
 }
 
@@ -2433,6 +2443,15 @@ void tcp_send_loss_probe(struct sock *sk)
 	tcp_rearm_rto(sk);
 }
 
+static void __tcp_push_pending_frames_handler(unsigned long data)
+{
+	struct sock *sk = (struct sock *)data;
+
+	lock_sock(sk);
+	tcp_push_pending_frames(sk);
+	release_sock(sk);
+}
+
 /* Push out any pending frames which were held back due to
  * TCP_CORK or attempt at coalescing tiny packets.
  * The socket must be locked by the caller.
@@ -2440,6 +2459,8 @@ void tcp_send_loss_probe(struct sock *sk)
 void __tcp_push_pending_frames(struct sock *sk, unsigned int cur_mss,
 			       int nonagle)
 {
+	struct tcp_sock *tp = tcp_sk(sk);
+
 	/* If we are closed, the bytes will have to remain here.
 	 * In time closedown will finish, we empty the write queue and
 	 * all will be happy.
@@ -2447,9 +2468,38 @@ void __tcp_push_pending_frames(struct sock *sk, unsigned int cur_mss,
 	if (unlikely(sk->sk_state == TCP_CLOSE))
 		return;
 
-	if (tcp_write_xmit(sk, cur_mss, nonagle, 0,
-			   sk_gfp_mask(sk, GFP_ATOMIC)))
-		tcp_check_probe_timer(sk);
+	if (timer_pending(&tp->send_timer) == 0) {
+		/* Timer is not running, push data out */
+		int ret;
+		const struct tcp_congestion_ops *ca_ops;
+
+		ca_ops = inet_csk(sk)->icsk_ca_ops;
+
+		if (ca_ops && ca_ops->send_timer_expired)
+			ca_ops->send_timer_expired(sk);
+
+		if (tcp_write_xmit(sk, cur_mss, nonagle, 0, sk_gfp_mask(sk, GFP_ATOMIC)))
+			tcp_check_probe_timer(sk);
+
+		/* And now let's init the timer only if we have data */
+		if (tcp_send_head(sk)) {
+			if (ca_ops && ca_ops->get_send_timer_exp_time) {
+				unsigned long expiration;
+
+				setup_timer(&tp->send_timer,
+					    __tcp_push_pending_frames_handler,
+					    (unsigned long)sk);
+				expiration = ca_ops->get_send_timer_exp_time(sk);
+				ret = mod_timer(&tp->send_timer,
+						jiffies + expiration);
+				BUG_ON(ret != 0);
+			}
+		} else {
+			del_timer(&tp->send_timer);
+			if (ca_ops && ca_ops->no_data_to_transmit)
+				ca_ops->no_data_to_transmit(sk);
+		}
+	}
 }
 
 /* Send _single_ skb sitting at the send head. This function requires
-- 
2.13.2
