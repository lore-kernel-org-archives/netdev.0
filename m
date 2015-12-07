From: Per Hurtig <per.hurtig@kau.se>
Subject: [RFC PATCH net-next 2/2] tcp: TLP restart (TLPR)
Date: Mon,  7 Dec 2015 10:00:12 +0100
Message-ID: <08279b20c3e14039d97b1b2a7ddeb2b663482313.1449478261.git.per.hurtig@kau.se>
References: <cover.1449478261.git.per.hurtig@kau.se>
Cc: anna.brunstrom@kau.se, apetlund@simula.no, michawe@ifi.uio.no,
	mohammad.rajiullah@kau.se, Per Hurtig <per.hurtig@kau.se>
To: davem@davemloft.net, edumazet@google.com, ncardwell@google.com,
	nanditad@google.com, tom@herbertland.com, ycheng@google.com,
	viro@zeniv.linux.org.uk, fw@strlen.de, mleitner@redhat.com,
	daniel@iogearbox.net, willemb@google.com,
	ilpo.jarvinen@helsinki.fi, pasi.sarolahti@iki.fi,
	stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.kau.se ([193.10.220.39]:21292 "EHLO nasse.dc.kau.se"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754549AbbLGJGy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Dec 2015 04:06:54 -0500
In-Reply-To: <cover.1449478261.git.per.hurtig@kau.se>
In-Reply-To: <cover.1449478261.git.per.hurtig@kau.se>
References: <cover.1449478261.git.per.hurtig@kau.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements the TLP restart modification (TLPR). When data is
ACKed, and TLP's PTO timer is restarted, the time elapsed since the last
outstanding segment was transmitted is subtracted from the calculated RTO
value to not unnecessarily delay loss probes.

Signed-off-by: Per Hurtig <per.hurtig@kau.se>
---
 include/net/tcp.h     |  2 +-
 net/ipv4/tcp_input.c  |  2 +-
 net/ipv4/tcp_output.c | 12 ++++++++++--
 3 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index bf98768..8ac4118 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -566,7 +566,7 @@ void tcp_push_one(struct sock *, unsigned int mss_now);
 void tcp_send_ack(struct sock *sk);
 void tcp_send_delayed_ack(struct sock *sk);
 void tcp_send_loss_probe(struct sock *sk);
-bool tcp_schedule_loss_probe(struct sock *sk);
+bool tcp_schedule_loss_probe(struct sock *sk, bool restart);
 
 /* tcp_input.c */
 void tcp_resume_early_retransmit(struct sock *sk);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 66e0425..28d3b21 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3655,7 +3655,7 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 	}
 
 	if (icsk->icsk_pending == ICSK_TIME_RETRANS)
-		tcp_schedule_loss_probe(sk);
+		tcp_schedule_loss_probe(sk, true);
 	tcp_update_pacing_rate(sk);
 	return 1;
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index cb7ca56..752db3d 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2135,7 +2135,7 @@ repair:
 
 		/* Send one loss probe per tail loss episode. */
 		if (push_one != 2)
-			tcp_schedule_loss_probe(sk);
+			tcp_schedule_loss_probe(sk, false);
 		is_cwnd_limited |= (tcp_packets_in_flight(tp) >= tp->snd_cwnd);
 		tcp_cwnd_validate(sk, is_cwnd_limited);
 		return false;
@@ -2143,10 +2143,11 @@ repair:
 	return !tp->packets_out && tcp_send_head(sk);
 }
 
-bool tcp_schedule_loss_probe(struct sock *sk)
+bool tcp_schedule_loss_probe(struct sock *sk, bool restart)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
+	struct sk_buff *skb = tcp_write_queue_head(sk);
 	u32 timeout, tlp_time_stamp, rto_time_stamp;
 	u32 rtt = usecs_to_jiffies(tp->srtt_us >> 3);
 
@@ -2186,6 +2187,13 @@ bool tcp_schedule_loss_probe(struct sock *sk)
 	if (tp->packets_out == 1)
 		timeout = max_t(u32, timeout,
 				(rtt + (rtt >> 1) + TCP_DELACK_MAX));
+	if (sysctl_tcp_timer_restart > 1 && restart && skb) {
+		const u32 rto_time_stamp = tcp_skb_timestamp(skb);
+		s32 delta = (s32)(tcp_time_stamp - rto_time_stamp);
+
+		if (delta > 0 && timeout > delta)
+			timeout -= delta;
+	}
 	timeout = max_t(u32, timeout, msecs_to_jiffies(10));
 
 	/* If RTO is shorter, just schedule TLP in its place. */
-- 
1.9.1
