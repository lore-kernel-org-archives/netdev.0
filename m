From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net] tcp: initialize passive-side sk_pacing_rate after 3WHS
Date: Mon, 21 Oct 2013 15:40:19 -0400
Message-ID: <1382384419-6081-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f202.google.com ([209.85.223.202]:43179 "EHLO
	mail-ie0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751669Ab3JUTr4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 15:47:56 -0400
Received: by mail-ie0-f202.google.com with SMTP id qd12so1344833ieb.3
        for <netdev@vger.kernel.org>; Mon, 21 Oct 2013 12:47:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For passive TCP connections, upon receiving the ACK that completes the
3WHS, make sure we set our pacing rate after we get our first RTT
sample.

On passive TCP connections, when we receive the ACK completing the
3WHS we do not take an RTT sample in tcp_ack(), but rather in
tcp_synack_rtt_meas(). So upon receiving the ACK that completes the
3WHS, tcp_ack() leaves sk_pacing_rate at its initial value.

Originally the initial sk_pacing_rate value was 0, so passive-side
connections defaulted to sysctl_tcp_min_tso_segs (2 segs) in skbuffs
made in the first RTT. With a default initial cwnd of 10 packets, this
happened to be correct for RTTs 5ms or bigger, so it was hard to
see problems in WAN or emulated WAN testing.

Since 7eec4174ff ("pkt_sched: fq: fix non TCP flows pacing"), the
initial sk_pacing_rate is 0xffffffff. So after that change, passive
TCP connections were keeping this value (and using large numbers of
segments per skbuff) until receiving an ACK for data.

Signed-off-by: Neal Cardwell <ncardwell@google.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_input.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 53974c7..a16b01b 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5712,6 +5712,8 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 		} else
 			tcp_init_metrics(sk);
 
+		tcp_update_pacing_rate(sk);
+
 		/* Prevent spurious tcp_cwnd_restart() on first data packet */
 		tp->lsndtime = tcp_time_stamp;
 
-- 
1.8.4
