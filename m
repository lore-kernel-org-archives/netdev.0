From: Koichiro Den <den@klaipeden.com>
Subject: [net-next] tcp: do tcp_mstamp_refresh before retransmits on TSQ handler
Date: Sun, 22 Oct 2017 12:38:08 +0900
Message-ID: <20171022033808.12641-1-den@klaipeden.com>
Cc: eric.dumazet@gmail.com, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
        yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sender-of-o52.zoho.com ([135.84.80.217]:21373 "EHLO
        sender-of-o52.zoho.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750996AbdJVDiZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Oct 2017 23:38:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When retransmission on TSQ handler was introduced in the commit
f9616c35a0d7 ("tcp: implement TSQ for retransmits"), the retransmitted
skbs' timestamps were updated on the actual transmission. In the later
commit 385e20706fac ("tcp: use tp->tcp_mstamp in output path"), it stops
being done so. In the commit, the comment says "We try to refresh
tp->tcp_mstamp only when necessary", and at present tcp_tsq_handler and
tcp_v4_mtu_reduced applies to this. About the latter, it's okay since
it's rare enough.

About the former, even though possible retransmissions on the tasklet
comes just after the destructor run in NET_RX softirq handling, the time
between them could be nonnegligibly large to the extent that
tcp_rack_advance or rto rearming be affected if other (remaining) RX,
BLOCK and (preceding) TASKLET sofirq handlings are unexpectedly heavy.

So in the same way as tcp_write_timer_handler does, doing tcp_mstamp_refresh
ensures the accuracy of algorithms relying on it.

Signed-off-by: Koichiro Den <den@klaipeden.com>
---
 net/ipv4/tcp_output.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 988733f289c8..7a4d9b719b47 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -743,8 +743,10 @@ static void tcp_tsq_handler(struct sock *sk)
 		struct tcp_sock *tp = tcp_sk(sk);
 
 		if (tp->lost_out > tp->retrans_out &&
-		    tp->snd_cwnd > tcp_packets_in_flight(tp))
+		    tp->snd_cwnd > tcp_packets_in_flight(tp)) {
+			tcp_mstamp_refresh(tp);
 			tcp_xmit_retransmit_queue(sk);
+		}
 
 		tcp_write_xmit(sk, tcp_current_mss(sk), tp->nonagle,
 			       0, GFP_ATOMIC);
-- 
2.9.4
