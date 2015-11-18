From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next] net: tcp: move to timewait when receiving data post active-close
Date: Wed, 18 Nov 2015 16:03:44 +0100
Message-ID: <1447859024-1040-1-git-send-email-fw@strlen.de>
Cc: marcelo.leitner@gmail.com, eric.dumazet@gmail.com,
	Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:45923 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755799AbbKRPEE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 10:04:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC 1122, 4.2.2.13:
 [..] if new data is received after CLOSE is called, its TCP
 SHOULD send a RST to show that data was lost.

 When a connection is closed actively, it MUST linger in
 TIME-WAIT state [..].

We reset a connection, but destroy state immediately.

After discussing this with Hannes, we decided it was preferable
to also move to TW state to avoid immediate port reuse.

packetdrill testcase:

0.000 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
0.000 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
0.000 bind(3, ..., ...) = 0
0.000 listen(3, 1) = 0
0.100 < S 0:0(0) win 29200 <mss 1460>
0.100 > S. 0:0(0) ack 1 <mss 1460>
0.200 < . 1:1(0) ack 1 win 257
0.200 accept(3, ..., ...) = 4
// close our side.
0.210 close(4) = 0
// we should expect to see FIN now, sk moves to FIN_WAIT_1
0.210 > F. 1:1(0) ack 1 win 29200
// receive data, but sk already closed -> Reset
0.300 < P. 1:1001(1000) ack 1 win 46
0.300 > R 1:1(0) win 0

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
We got complaint from customer that CLOSED state transition
is RFC violation.

The advantage of current behaviour is that further packets will also
result in RST.

I'm interested if others think its worth changing this now.

Thanks.

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index fdd88c3..3bcdad1 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5904,11 +5904,16 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb)
 			break;
 		}
 
-		if (tp->linger2 < 0 ||
-		    (TCP_SKB_CB(skb)->end_seq != TCP_SKB_CB(skb)->seq &&
-		     after(TCP_SKB_CB(skb)->end_seq - th->fin, tp->rcv_nxt))) {
+		if (tp->linger2 < 0) {
+			NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPABORTONDATA);
 			tcp_done(sk);
+			return 1;
+		}
+
+		if (TCP_SKB_CB(skb)->end_seq != TCP_SKB_CB(skb)->seq &&
+		    after(TCP_SKB_CB(skb)->end_seq - th->fin, tp->rcv_nxt)) {
 			NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPABORTONDATA);
+			tcp_time_wait(sk, TCP_TIME_WAIT, 0);
 			return 1;
 		}
 
@@ -5966,7 +5971,13 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb)
 			if (TCP_SKB_CB(skb)->end_seq != TCP_SKB_CB(skb)->seq &&
 			    after(TCP_SKB_CB(skb)->end_seq - th->fin, tp->rcv_nxt)) {
 				NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPABORTONDATA);
-				tcp_reset(sk);
+
+				if (sk->sk_state == TCP_CLOSE_WAIT ||
+				    sk->sk_state == TCP_LAST_ACK)
+					tcp_reset(sk);
+				else
+					tcp_time_wait(sk, TCP_TIME_WAIT, 0);
+
 				return 1;
 			}
 		}
-- 
2.4.10
