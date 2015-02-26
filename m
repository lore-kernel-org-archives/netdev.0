From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/3] tcp: tso: restore IW10 after TSO autosizing
Date: Thu, 26 Feb 2015 14:10:19 -0800
Message-ID: <1424988620-10781-3-git-send-email-edumazet@google.com>
References: <1424988620-10781-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f201.google.com ([209.85.160.201]:33510 "EHLO
	mail-yk0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932092AbbBZWML (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 17:12:11 -0500
Received: by ykbq200 with SMTP id q200so1812314ykb.0
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 14:12:10 -0800 (PST)
In-Reply-To: <1424988620-10781-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With sysctl_tcp_min_tso_segs being 4, it is very possible
that tcp_tso_should_defer() decides not sending last 2 MSS
of initial window of 10 packets. This also applies if
autosizing decides to send X MSS per GSO packet, and cwnd
is not a multiple of X.

This patch implements an heuristic based on age of first
skb in write queue : If it was sent very recently (less than half srtt),
we can predict that no ACK packet will come in less than half rtt,
so deferring might cause an under utilization of our window.

This is visible on initial send (IW10) on web servers,
but more generally on some RPC, as the last part of the message
might need an extra RTT to get delivered.

Tested:

Ran following packetdrill test
// A simple server-side test that sends exactly an initial window (IW10)
// worth of packets.

`sysctl -e -q net.ipv4.tcp_min_tso_segs=4`

0.000 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
+0    setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
+0    bind(3, ..., ...) = 0
+0    listen(3, 1) = 0

+.1   < S 0:0(0) win 32792 <mss 1460,sackOK,nop,nop,nop,wscale 7>
+0    > S. 0:0(0) ack 1 <mss 1460,nop,nop,sackOK,nop,wscale 6>
+.1   < . 1:1(0) ack 1 win 257
+0    accept(3, ..., ...) = 4

+0    write(4, ..., 14600) = 14600
+0    > . 1:5841(5840) ack 1 win 457
+0    > . 5841:11681(5840) ack 1 win 457
// Following packet should be sent right now.
+0    > P. 11681:14601(2920) ack 1 win 457

+.1   < . 1:1(0) ack 14601 win 257

+0    close(4) = 0
+0    > F. 14601:14601(0) ack 1
+.1   < F. 1:1(0) ack 14602 win 257
+0    > . 14602:14602(0) ack 2

Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp_output.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index cb95c7a9d1e7..5f4fb4d5bbd6 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1752,9 +1752,11 @@ static int tso_fragment(struct sock *sk, struct sk_buff *skb, unsigned int len,
 static bool tcp_tso_should_defer(struct sock *sk, struct sk_buff *skb,
 				 bool *is_cwnd_limited, u32 max_segs)
 {
-	struct tcp_sock *tp = tcp_sk(sk);
 	const struct inet_connection_sock *icsk = inet_csk(sk);
-	u32 send_win, cong_win, limit, in_flight;
+	u32 age, send_win, cong_win, limit, in_flight;
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct skb_mstamp now;
+	struct sk_buff *head;
 	int win_divisor;
 
 	if (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN)
@@ -1808,6 +1810,13 @@ static bool tcp_tso_should_defer(struct sock *sk, struct sk_buff *skb,
 			goto send_now;
 	}
 
+	head = tcp_write_queue_head(sk);
+	skb_mstamp_get(&now);
+	age = skb_mstamp_us_delta(&now, &head->skb_mstamp);
+	/* If next ACK is likely to come too late (half srtt), do not defer */
+	if (age < (tp->srtt_us >> 4))
+		goto send_now;
+
 	/* Ok, it looks like it is advisable to defer. */
 
 	if (cong_win < send_win && cong_win < skb->len)
-- 
2.2.0.rc0.207.ga3a616c
